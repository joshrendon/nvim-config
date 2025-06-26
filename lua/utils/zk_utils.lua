local M = {}
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

function M.open_note_in_tab(path)
  if not path or path == "" then
    vim.notify("No path provided to open_note_in_tab", vim.log.levels.WARN)
    return
  end
  vim.cmd("tabnew " .. vim.fn.fnameescape(path))
end

function M.zk_edit_in_tab(opts)
  local lazy_ok, lazy = pcall(require, "lazy")
  if lazy_ok then
    local plugin = require("lazy.core.config").plugins["zk-nvim"]
    if plugin and not plugin._.loaded then
      require("lazy.core.loader").load({ plugins = { "zk-nvim" } }, { force = true })
    end
  end

  -- This is key: manually load zk and run setup if needed
  local ok, zk_mod = pcall(require, "zk")
  if not ok then
    vim.notify("zk-nvim could not be required", vim.log.levels.ERROR)
    return
  end

  if not zk_mod._setup_ran then
    zk_mod.setup({
      picker = "telescope",
    })
  end

  local zk = require("zk.commands")
  local edit = zk.get("ZkEdit")
  if not edit then
    vim.notify("ZkEdit command still not available — setup may have failed", vim.log.levels.ERROR)
    return
  end

  edit(opts or {}, {
    title = "Zk Notes",
    attach_mappings = function(_, map)
      local function open_selected(bufnr)
        local entry = action_state.get_selected_entry()
        actions.close(bufnr)
        M.open_note_in_tab(entry.value.path)
      end
      map("i", "<CR>", open_selected)
      map("n", "<CR>", open_selected)
      return true
    end,
  })
end

function M.open_link_under_cursor()
  local link = M.get_link_under_cursor()
  if not link then
    vim.notify("No wikilink under cursor.", vim.log.levels.INFO)
    return
  end

  vim.defer_fn(function()
    local ok, zk = pcall(require, "zk.commands")
    if not ok then
      vim.notify("zk-nvim not available", vim.log.levels.ERROR)
      return
    end

    local zk_edit = require("zk.commands").get("ZkEdit")
    if not zk_edit then
      vim.notify("ZkEdit command not available yet (plugin setup race?)", vim.log.levels.WARN)
      return
    end

    zk_edit({ title = link })
  end, 50)  -- Wait 50 ms
end

-- Check if the cursor is currently on a [[wikilink]]
-- If yes, return the link title; otherwise return nil
function M.get_link_under_cursor()
  local line = vim.api.nvim_get_current_line()
  local cursor_col = vim.api.nvim_win_get_cursor(0)[2] + 1

  for start_idx, link_text, end_idx in line:gmatch("()%[%[([^%]]+)%]%]()") do
    if cursor_col >= start_idx and cursor_col <= end_idx then
      return link_text
    end
  end

  return nil
end

return M

---- Open a note based on visually selected text (for [[...]] or just note titles)
--function M.open_visual_selection()
--  local mode = vim.fn.mode()
--  if mode ~= "v" and mode ~= "V" then return end
--
--  local start_pos = vim.fn.getpos("v")
--  local end_pos = vim.fn.getpos(".")
--  local start_col = math.min(start_pos[3], end_pos[3])
--  local end_col = math.max(start_pos[3], end_pos[3])
--
--  local line = vim.api.nvim_get_current_line()
--  local selection = line:sub(start_col, end_col)
--
--  -- Strip [[ ]] if selected
--  local title = selection:gsub("^%[%[", ""):gsub("%]%]$", "")
--
--  local link = M.open_link_under_cursor()
--
--  if #title > 0 then
--
--    require("zk").open({ title = title })
--  else
--    vim.notify("No selection found to open.", vim.log.levels.WARN)
--  end
--end
