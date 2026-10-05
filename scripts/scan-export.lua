-- Turns what /codex scan recorded into JSON, for writing new pages.
--   luajit scripts/scan-export.lua "<WoW>/_classic_beta_/WTF/Account/<ACCOUNT>/SavedVariables/LorekeepersCodex.lua" > scan.json
local path = arg[1]
if not path then
  io.stderr:write("usage: luajit scripts/scan-export.lua <SavedVariables/LorekeepersCodex.lua>\n")
  os.exit(2)
end

-- The file only assigns globals: run it in an empty environment.
local env = {}
local chunk = assert(loadfile(path))
setfenv(chunk, env)
chunk()
local scan = env.LorekeepersCodexScan
if not scan then
  io.stderr:write("no scan in this file (use /codex scan on in game, then log out)\n")
  os.exit(1)
end

local function str(s)
  return '"' .. s:gsub('[%c"\\]', function(c)
    local esc = { ['"'] = '\\"', ["\\"] = "\\\\", ["\n"] = "\\n", ["\r"] = "\\r", ["\t"] = "\\t" }
    return esc[c] or string.format("\\u%04x", c:byte())
  end) .. '"'
end

local function encode(v, indent)
  indent = indent or ""
  local t = type(v)
  if t == "string" then return str(v) end
  if t == "number" or t == "boolean" then return tostring(v) end
  if t ~= "table" then return "null" end
  local keys = {}
  for k in pairs(v) do keys[#keys + 1] = k end
  table.sort(keys, function(a, b)
    if type(a) == type(b) then return a < b end
    return type(a) == "number"
  end)
  if #keys == 0 then return "{}" end
  local inner = indent .. "  "
  local parts = {}
  for _, k in ipairs(keys) do
    parts[#parts + 1] = inner .. str(tostring(k)) .. ": " .. encode(v[k], inner)
  end
  return "{\n" .. table.concat(parts, ",\n") .. "\n" .. indent .. "}"
end

io.write(encode(scan), "\n")
