-- Draws the book as HTML for a look before a build goes to the game: the real
-- list (chapters, pages, the unread dots), the real longest page, the real
-- search results, the kit's real colours for the look the run chose (PAPER=1:
-- the paper). The geometry is the book's (K.BOOK_W by K.BOOK_H, a list 244
-- wide, a page 440) with Chrome's fonts in place of the game's: wrapping and a
-- title's width are close, not the game's own, so the game has the last word.
--   RENDER=dir luajit addon/test/sim.lua              (the dark look)
--   RENDER=dir PAPER=1 luajit addon/test/sim.lua      (the paper look)
-- writes dir/<scene>_<dark|paper>_<size 1 to 4>.html; the PNGs are Chrome's:
--   "Google Chrome" --headless --screenshot=x.png --window-size=W,H file://x.html
return function(ns, K, dir)
  local C = ns.content
  local T = K.T
  local look = K.paper and "paper" or "dark"
  local DARK = { ground = { 0.05, 0.045, 0.04, 0.9 }, back = { 0.10, 0.09, 0.075 }, edge = { 0.40, 0.33, 0.20 } }
  local function col(c, a)
    return ("rgba(%d,%d,%d,%.2f)"):format(c[1] * 255 + 0.5, c[2] * 255 + 0.5, c[3] * 255 + 0.5, a or c[4] or 1)
  end
  local ground = K.paper and T.ground or DARK.ground
  local back = K.paper and T.back or DARK.back
  local edge = K.paper and T.edge or DARK.edge
  local function esc(s) return (tostring(s):gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;")) end
  -- A string with a colour code, as the game draws it.
  local function coded(s)
    return (
      esc(s):gsub(
        "|cff(%x%x%x%x%x%x)(.-)|r",
        function(hex, text) return ('<span style="color:#%s">%s</span>'):format(hex, text) end
      )
    )
  end

  local function row(text, kind, extra)
    if kind == "chapter" then
      return ('<div style="height:32px;position:relative"><div style="position:absolute;left:18px;top:3px;font:14px Palatino,serif;color:%s">%s</div><div style="position:absolute;left:18px;right:44px;bottom:4px;height:4px;background:%s"><div style="width:%d%%;height:4px;background:%s"></div></div><div style="position:absolute;right:4px;bottom:0;font-size:10px;color:%s">%s</div></div>'):format(
        col(T.gold),
        esc(text),
        col(T.trough),
        extra.pct,
        col(T.bar),
        col(T.dim),
        esc(extra.count)
      )
    elseif kind == "overview" then
      return ('<div style="height:22px;line-height:22px;padding-left:4px;font:14px Palatino,serif;color:%s">%s</div>'):format(
        col(T.gold),
        esc(text)
      )
    elseif kind == "empty" then
      return ('<div style="height:18px;line-height:18px;padding-left:8px;font-size:12px;color:%s">%s</div>'):format(
        col(T.soft),
        esc(text)
      )
    end
    return ('<div style="height:18px;line-height:18px;padding-left:18px;font-size:12px;white-space:nowrap;overflow:hidden;color:%s;%s">%s</div>'):format(
      col(T.text),
      extra and extra.picked and ("background:" .. col(T.highlight, 0.25)) or "",
      coded(text)
    )
  end

  -- The pages found, as the list shows them (read, or not).
  local function title(id) return C.entries[id].title end
  local function dot(id) return ns.isRead(id) and "" or ("|cff%s•|r "):format(K.linkColour()) end

  local function frame(inner, label, W, H)
    return ('<body style="margin:0;background:%s"><div style="width:%dpx;height:%dpx;position:relative;background:%s;border:2px solid %s;box-sizing:border-box;font-family:\'Trebuchet MS\',sans-serif;overflow:hidden">%s</div></body>'):format(
      K.paper and "#2a3a2a" or "#101010",
      W,
      H,
      col(back),
      col(edge),
      inner
    )
  end

  local function windowChrome(count, searchText)
    return ('<div style="position:absolute;left:0;right:0;top:0;height:28px;background:%s"></div><div style="position:absolute;left:10px;top:6px;font:16px Palatino,serif;color:%s">Lorekeeper\'s Codex</div><div style="position:absolute;left:262px;top:36px;font-size:11px;color:%s">%s</div><div style="position:absolute;left:8px;top:30px;width:244px;height:22px;background:%s;border:1px solid %s;box-sizing:border-box;font-size:12px;line-height:20px;padding-left:22px;color:%s">%s</div>'):format(
      col(K.paper and edge or { 0.12, 0.10, 0.08 }),
      K.paper and "#f3e6c0" or "#e8d9a8",
      col(T.soft),
      esc(count),
      col(T.field),
      col(edge),
      col(T.text),
      esc(searchText or "")
    )
  end

  local function listPanel(rows)
    return ('<div style="position:absolute;left:8px;top:58px;width:244px;bottom:8px;background:%s;border:1px solid %s;box-sizing:border-box;overflow:hidden"><div style="margin:10px 12px 0 12px">%s</div></div>'):format(
      col(ground),
      col(edge),
      table.concat(rows)
    )
  end

  local function pagePanel(inner)
    return ('<div style="position:absolute;left:260px;top:58px;right:8px;bottom:8px;background:%s;border:1px solid %s;box-sizing:border-box;overflow:hidden"><div style="position:absolute;left:26px;top:22px;width:440px;bottom:14px">%s</div></div>'):format(
      col(ground),
      col(edge),
      inner
    )
  end

  local KIND = {
    place = "Place",
    figure = "Figure",
    faction = "Faction",
    creature = "Creature",
    history = "History",
    note = "Note",
    calling = "Calling",
  }
  local function about(e)
    local ch
    for _, c in ipairs(C.chapters) do
      if c.id == e.chapter then ch = c.title end
    end
    return (ch and (ch .. "  -  ") or "") .. (KIND[e.kind] or "Note")
  end

  local function pageHtml(id)
    local e = C.entries[id]
    local out = {}
    table.insert(
      out,
      ('<div style="width:64px;height:64px;border-radius:50%%;border:3px solid %s;position:absolute;left:2px;top:2px;box-sizing:border-box;background:%s"></div>'):format(
        col(T.ring),
        col(T.wash, 0.5)
      )
    )
    table.insert(
      out,
      ('<div style="position:absolute;left:86px;top:10px;font:24px Palatino,serif;color:%s;white-space:nowrap">%s</div><div style="position:absolute;left:86px;top:41px;font-size:12px;color:%s">%s</div><div style="position:absolute;left:0;right:0;top:76px;height:1px;background:%s"></div>'):format(
        col(T.gold),
        esc(e.title),
        col(T.soft),
        esc(about(e)),
        col(T.rule)
      )
    )
    local body = {}
    for _, para in ipairs(e.text) do
      if ns.shown(para) then
        if para.aside then
          table.insert(
            body,
            ('<div style="margin:0 0 20px 4px;padding-left:18px;font:15px Palatino,serif;color:%s;border-left:2px solid %s">%s</div>'):format(
              col(T.aside),
              col(T.aside, 0.5),
              esc(para[1])
            )
          )
        else
          table.insert(
            body,
            ('<p style="margin:0 0 20px;font-size:13px;line-height:17px;color:%s%s">%s</p>'):format(
              col(T.text),
              para.italic and ";font-style:italic" or "",
              esc(para[1])
            )
          )
        end
      end
    end
    table.insert(
      body,
      ('<p style="margin:0 0 20px;font-size:12px;color:%s">Found in Dun Morogh, at level 3, on 6 Nov 2026.</p>'):format(
        col(T.soft)
      )
    )
    -- See also: cards of the pages found
    local cards = {}
    for _, other in ipairs(e.also) do
      if ns.page(other) and #cards < 3 then
        local o = C.entries[other]
        table.insert(
          cards,
          ('<div style="height:50px;margin-bottom:6px;background:%s;border:1px solid %s;box-sizing:border-box;padding:8px 10px 0 60px;position:relative"><div style="position:absolute;left:8px;top:6px;width:36px;height:36px;border-radius:50%%;border:2px solid %s;box-sizing:border-box"></div><div style="font:15px Palatino,serif;color:%s">%s</div><div style="font-size:11px;color:%s">%s</div></div>'):format(
            col(T.field),
            col(edge),
            col(T.ring),
            col(T.gold),
            esc(o.title),
            col(T.soft),
            esc(about(o))
          )
        )
      end
    end
    if #cards > 0 then
      table.insert(
        body,
        ('<div style="font:16px Palatino,serif;color:%s;border-bottom:1px solid %s;height:24px;line-height:24px;margin-bottom:10px">See also</div>'):format(
          col(T.gold),
          col(T.rule)
        )
      )
      for _, c in ipairs(cards) do
        table.insert(body, c)
      end
    end
    table.insert(out, '<div style="position:absolute;left:0;top:90px;width:440px">' .. table.concat(body) .. "</div>")
    return table.concat(out)
  end

  -- The longest page this character has found.
  local longest, size = nil, 0
  for id, e in pairs(C.entries) do
    if ns.page(id) and e.kind ~= "tune" then
      local n = 0
      for _, para in ipairs(e.text) do
        if ns.shown(para) then n = n + #para[1] end
      end
      if n > size or (longest and n == size and id < longest) then
        longest, size = id, n
      end
    end
  end

  -- The list: the overview, then the chapters with a page found, the first open.
  local function chapters(pick)
    local rows = { row("The Codex", "overview") }
    local shown = 0
    for _, ch in ipairs(C.chapters) do
      local found = ns.found(ch)
      if found > 0 and shown < 5 then
        shown = shown + 1
        table.insert(
          rows,
          row(ch.title, "chapter", { pct = math.floor(found * 100 / #ch.entries), count = found .. "/" .. #ch.entries })
        )
        if shown == 1 then
          for _, id in ipairs(ch.entries) do
            if ns.page(id) then table.insert(rows, row(dot(id) .. title(id), "page", { picked = id == pick })) end
          end
        end
      end
    end
    return rows
  end

  local W, H = K.BOOK_W, K.BOOK_H
  local function write(scene, step, inner)
    local scale = K.scaleFor(step, W, H)
    local html = frame(inner, scene, W, H)
    html = html:gsub('<body style="', ('<body style="zoom:%s;'):format(scale), 1)
    local f = assert(io.open(("%s/%s_%s_%d.html"):format(dir, scene, look, step), "w"))
    f:write(html)
    f:close()
  end

  local count = ("%d of %d pages"):format(ns.count(), ns.knownTotal())
  local picked = longest
  local results = {}
  for _, id in ipairs(ns.search("ironforge")) do
    if #results < 12 then table.insert(results, row(dot(id) .. title(id), "page")) end
  end
  local toast = ('<div style="position:absolute;left:240px;top:200px;width:300px;height:70px;background:%s;border:2px solid %s;box-sizing:border-box"><div style="position:absolute;left:10px;top:10px;width:48px;height:48px;border-radius:50%%;border:3px solid %s;box-sizing:border-box"></div><div style="position:absolute;left:68px;top:10px;font-size:11px;color:%s">A new page in the codex</div><div style="position:absolute;left:68px;top:28px;font:17px Palatino,serif;color:%s;white-space:nowrap">%s</div></div>'):format(
    col(K.paper and ground or { 0.07, 0.06, 0.05 }),
    col(edge),
    col(T.ring),
    col(T.soft),
    col(T.gold),
    esc(title(longest))
  )
  for step = 1, 4 do
    if step == 1 or step == 4 then
      write("book", step, windowChrome(count) .. listPanel(chapters(picked)) .. pagePanel(pageHtml(picked)))
      write("search", step, windowChrome(count, "ironforge") .. listPanel(results) .. pagePanel(pageHtml(picked)))
      -- a chapter's progress, nothing found for a search, the overview's figures
      local rows = chapters(nil)
      table.insert(rows, row("No page found.", "empty"))
      local overview = ('<div style="position:absolute;left:86px;top:10px;font:24px Palatino,serif;color:%s">The Codex</div><div style="position:absolute;left:86px;top:41px;font-size:12px;color:%s">%s</div><div style="position:absolute;left:0;right:0;top:76px;height:1px;background:%s"></div><div style="position:absolute;left:0;top:96px;display:flex;gap:10px">'):format(
        col(T.gold),
        col(T.soft),
        esc(count .. " found"),
        col(T.rule)
      )
      for _, s in ipairs({ { ns.count(), "pages found" }, { 9, "chapters" }, { 4, "unread" }, { 3, "library texts" } }) do
        overview = overview
          .. ('<div style="width:100px;height:60px;background:%s;border:1px solid %s;box-sizing:border-box;text-align:center"><div style="font:22px Palatino,serif;color:%s;margin-top:6px">%s</div><div style="font-size:11px;color:%s">%s</div></div>'):format(
            col(T.field),
            col(edge),
            col(T.gold),
            s[1],
            col(T.soft),
            s[2]
          )
      end
      overview = overview .. "</div>"
      write("overview", step, windowChrome(count) .. listPanel(rows) .. pagePanel(overview) .. toast)
    end
  end
end
