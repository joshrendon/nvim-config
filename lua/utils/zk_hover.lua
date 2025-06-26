local M = {}

--- Extract [[wikilink]] under the cursor
local function get_link_under_cursor()
  local line = vim.api.nvim_get_current_line()
  local col = vim.fn.col(".")
  local left = line:sub(1, col)
  local right = line:sub(col)

  local link = left:match("%[%[([^%]]+)%]%]$")
    or right:match("^%[%[([^%]]+)%]%]")
    or line:match("%[%[([^%]]+)%]%]")

  return link
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
