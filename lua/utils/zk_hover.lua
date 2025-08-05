local M = {}

local function get_wikilink_under_cursor()
  local log = require("utils.zk_debug_log")
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  local line = vim.api.nvim_buf_get_lines(0, row - 1, row, false)[1]
  log.append(" Cursor col = ".. col, vim.log.levels.INFO)
  log.append(" Line: = ".. line, vim.log.levels.INFO)

  if not line then return nil end

  local i = 1
  while true do
    local start_pos, _ = line:find("%[%[", i)
    if not start_pos then break end

    local end_pos = line:find("%]%]", start_pos)
    if end_pos then
      local link_start = start_pos - 1
      local link_end = end_pos + 1
      if col >= link_start and col <= link_end then
        local raw = line:sub(start_pos + 2, end_pos - 1)
        return raw
      end
      i = end_pos + 1
    else
      break
    end
  end

  return nil
end

--local function get_wikilink_under_cursor()
--  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
--  local line = vim.api.nvim_buf_get_lines(0, row - 1, row, false)[1]
--  if not line then return nil end
--
--  -- Look for all [[wikilinks]] in the line
--  for s, e in line:gmatch("()(%[%[[^%]]+%]%])()") do
--    log.append("⚠️ s ".. s)
--    log.append("⚠️ e ".. e)
--    vim.notify("s: ".. s, vim.levels.INFO)
--    vim.notify("e: ".. e, vim.levels.INFO)
--    local start_col = s - 1
--    local end_col = e - 2
--    if col >= start_col and col <= end_col then
--      local match = line:sub(start_col + 1, end_col + 1)
--      return match:match("%[%[([^%]]+)%]%]")
--    end
--  end
--
--  return nil
--end

--- Extract [[wikilink]] under the cursor
--- V1
--local function get_link_under_cursor()
--  local line = vim.api.nvim_get_current_line()
--  local col = vim.fn.col(".")
--  local left = line:sub(1, col)
--  local right = line:sub(col)
--
--  local link = left:match("%[%[([^%]]+)%]%]$")
--    or right:match("^%[%[([^%]]+)%]%]")
--    or line:match("%[%[([^%]]+)%]%]")
--
--  return link
--end
-- V2
--local function get_wikilink_under_cursor()
--  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
--  local line = vim.api.nvim_buf_get_lines(0, row - 1, row, false)[1]
--  if not line then return nil end
--
--  for s, e, match in line:gmatch("()(%[%[.-%]%])()") do
--    local link_start = s - 1
--    local link_end = e - 1
--    if col >= link_start and col <= link_end then
--      local inner = match:match("%[%[([^%]]+)%]%]")
--      return inner
--    end
--  end
--
--  return nil
--end

function M.hover_metadata()
  local log = require("utils.zk_debug_log")
  log.append("🔍 Hover triggered")

  local link = get_wikilink_under_cursor()
  if not link then
    log.append("⚠️ No wikilink found under cursor")
    return
  else
    log.append("📌 Raw link: " .. vim.inspect(link))
  end
  if not link then
    log.append("⚠️ No wikilink found under cursor")
    vim.notify("No wikilink under cursor", vim.log.levels.WARN)
    return
  end
  log.append("📌 Raw Wikilink: " .. link)

  -- Normalize for path lookup
  local normalized = link:gsub("\\\\", "/")
  log.append("📌 Normalized Wikilink: " .. normalized)

  vim.notify("normalized link: "..normalized, vim.log.levels.WARN)
  local comp_link = vim.env.ZK_NOTEBOOK_DIR .. "/" .. link .. ".md"
  local fixed_link = comp_link:gsub("\\", "/")
  fixed_link = fixed_link:gsub("//", "/")
  vim.notify("completed link: "..fixed_link, vim.log.levels.WARN)

  local note = vim.tbl_filter(function(n)
      return n.path:find(fixed_link, 1, true) or n.title == fixed_link
  end, notes)[1]

  if not note then
      log.append("? No matching note found for normalized link: ".. fixed_link)
      vim.notify("Note not found: "..fixed_link, vim.log.levels.WARN)
      return
  end

  log.append(" Found note: ".. note.path)

  local zk = require("zk")
  zk.index({ select = { "title", "tags", "path", "modified" } }, function(err, notes)
    if err then
      local msg = "zk index failed: " .. err.message
      log.append("❌ " .. msg)
      vim.notify(msg, vim.log.levels.ERROR)
      return
    end

    local note = vim.tbl_filter(function(n)
      return n.title == link
    end, notes)[1]

    if not note then
      local msg = "Note not found in index: " .. link
      log.append("⚠️ " .. msg)
      vim.notify(msg, vim.log.levels.WARN)
      return
    end

    log.append("✅ Note found: " .. note.path)

    local metadata = {
      "📄 **" .. (note.title or "Untitled") .. "**",
      "📁 Path: " .. (note.path or "unknown"),
      "🏷️ Tags: " .. table.concat(note.tags or {}, ", "),
      "📝 Modified: " .. (note.modified or "unknown"),
    }

    local width = 0
    for _, line in ipairs(metadata) do
      width = math.max(width, #line)
    end

    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, metadata)
    vim.api.nvim_open_win(buf, false, {
      relative = "cursor",
      row = 1,
      col = 1,
      width = width + 2,
      height = #metadata,
      style = "minimal",
      border = "rounded",
    })

    log.append("📦 Metadata window shown successfully")
  end)
end


--- Show a floating preview with note metadata
function M.hover()
  local link = get_link_under_cursor()
  if not link then
    vim.notify("No wikilink under cursor", vim.log.levels.INFO)
    return
  end

  local ok, zk = pcall(require, "zk.commands")
  if not ok then
    vim.notify("zk-nvim not available", vim.log.levels.ERROR)
    return
  end

  local index = zk.get("ZkIndex")
  if not index then
    vim.notify("ZkIndex command not available", vim.log.levels.ERROR)
    return
  end

  index({ title = link, select = { "title", "path", "modified", "tags" } }, function(notes)
    if not notes or #notes == 0 then
      vim.notify("No note found for: " .. link, vim.log.levels.WARN)
      return
    end

    local note = notes[1]
    local lines = {
        "# Metadata",
        "**Title:** " .. (note.title or "Untitled"),
        "**Path:** " .. (note.path or "unknown"),
        "**Created:** " ..(note.created or "unknown"),
        "**Tags:** " .. table.concat(note.tags or {},", "),
        "**Words:** " .. (note.wordCount or 0),
        "**Last Modified:** " .. (note.modified or "Unknown"),
    }
    --local lines = {
    --  "# " .. (note.title or "Untitled"),
    --  "",
    --  "Path: " .. note.path,
    --  "Modified: " .. (note.modified or ""),
    --  "Tags: " .. table.concat(note.tags or {}, ", ")
    --}

    local bufnr, winnr = vim.lsp.util.open_floating_preview(lines, "markdown", { border = "single" })
  end)
end

return M

--function M.show_zk_note_metadata()
--    vim.notify("[zk-hover] mapping triggered", vim.log.levels.INFO)
--
--    local raw_path = vim.api.nvim_buf_get_name(0)
--    local path = vim.loop.fs_realpath(raw_path) or vim.fn.fnamemodify(raw_path, ":p")
--    local zk = require("zk.api")
--
--    vim.notify("[zk-hover] Normalized path: " .. path)
--
--    zk.list({ path = path }, function(err, notes)
--        if err then
--            vim.notify("Zk error: ".. tostring(err), vim.log.levels.ERROR)
--            return
--        end
--
--        --if not notes or vim.tbl_isempty(notes) then
--        --if not notes or vim.empty_dict(notes) then
--        if not notes then
--            vim.notify("No metadata found for: ".. path, vim.log.levels.WARN)
--            return
--        end
--        vim.notify("Notes found: "..notes, vim.log.levels.INFO)
--
--        local note = notes[1]
--        local lines = {
--            "# Metadata",
--            "**Title:** " .. (note.title or "Untitled"),
--            "**Path:** " .. (note.path or "unknown"),
--            "**Created:** " ..(note.created or "unknown"),
--            "**Tags:** " .. table.concat(note.tags or {},", "),
--            "**Words:** " .. (note.wordCount or 0),
--            "**Last Modified:** " .. (note.modified or "Unknown"),
--        }
--
--        vim.lsp.util.open_floating_preview(lines, "markdown", {
--            border = "single",
--            max_width = 80,
--        })
--    end)
--end
