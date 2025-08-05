-- File: lua/zk_link_status_safe.lua

local Path = require("plenary.path")
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values

local M = {}

local fallback_txt = vim.fn.stdpath("data") .. "/zk_preview_fallback.txt"
local function ensure_fallback_file()
  if vim.fn.filereadable(fallback_txt) == 0 then
    local f = io.open(fallback_txt, "w")
    if f then f:write("No preview available.") f:close() end
  end
end
ensure_fallback_file()

local function extract_wikilinks(content)
  local links = {}
  for link in content:gmatch("%[%[([^%]]+)%]%]") do
    table.insert(links, link)
  end
  return links
end

local function get_all_notes(root_dir)
  local notes = {}
  for _, path in ipairs(vim.fn.glob(root_dir .. "/**/*.md", true, true)) do
    table.insert(notes, path)
  end
  return notes
end

local function scan_links_from_notes(root_dir)
  local seen, link_table = {}, {}
  for _, file in ipairs(get_all_notes(root_dir)) do
    for line in io.lines(file) do
      for _, link in ipairs(extract_wikilinks(line)) do
        if not seen[link] then
          seen[link] = true
          table.insert(link_table, link)
        end
      end
    end
  end
  return link_table
end

local function resolve_links(link_list, cwd, on_resolved)
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

  local result, pending = {}, #link_list
  if pending == 0 then on_resolved(result) return end

  for _, link in ipairs(link_list) do
    index({ title = link, match = "contains" }, function(notes)
      local fallback_path = vim.fn.glob(cwd .. "/**/" .. link .. ".md")
      local found = notes and #notes > 0 or fallback_path ~= ""
      local final_path = (notes and #notes > 0 and notes[1].path)
        or (fallback_path ~= "" and fallback_path)
        or fallback_txt

      table.insert(result, {
        link = link,
        exists = found,
        path = final_path,
      })

      pending = pending - 1
      if pending == 0 then on_resolved(result) end
    end)
  end
end

-- 🧪 Termopen preview
local function preview_path(path)
  vim.cmd("vsplit")
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_win_set_buf(0, buf)

  local cmd
  if vim.fn.executable("bat") == 1 then
    cmd = { "bat", "--style=plain", path }
  elseif vim.fn.has("win32") == 1 then
    cmd = { "powershell", "-Command", "Get-Content -Path '" .. path .. "'" }
  else
    cmd = { "cat", path }
  end
  vim.fn.termopen(cmd)
end

function M.run()
  local cwd = vim.fn.getcwd()
  local link_list = scan_links_from_notes(cwd)

  resolve_links(link_list, cwd, function(results)
    pickers.new({}, {
      prompt_title = "Vault Link Status (Safe)",
      finder = finders.new_table({
        results = results,
        entry_maker = function(entry)
          local status = entry.exists and "✓" or "✗"
          local display = string.format("%s  %-30s  %s", status, entry.link, entry.path or "[missing]")
          return {
            value = entry,
            display = display,
            ordinal = entry.link,
          }
        end,
      }),
      sorter = conf.generic_sorter({}),
      attach_mappings = function(_, map)
        map("i", "<CR>", function(bufnr)
          local entry = require("telescope.actions.state").get_selected_entry()
          require("telescope.actions").close(bufnr)
          preview_path(entry.value.path)
        end)
        return true
      end,
    }):find()
  end)
end

return M

