-- File: lua/zk_link_status.lua

local Path = require("plenary.path")
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local previewers = require("telescope.previewers")
local conf = require("telescope.config").values

local M = {}

-- Fallback file for preview errors
local fallback_txt = vim.fn.stdpath("data") .. "/zk_preview_fallback.txt"
local function ensure_fallback_file()
  if vim.fn.filereadable(fallback_txt) == 0 then
    local f = io.open(fallback_txt, "w")
    if f then
      f:write("No preview available.")
      f:close()
    end
  end
end
ensure_fallback_file()

-- Extract all wikilinks from markdown content
local function extract_wikilinks(content)
  local links = {}
  for link in content:gmatch("%[%[([^%]]+)%]%]") do
    table.insert(links, link)
  end
  return links
end

-- Get all markdown files in the vault
local function get_all_notes(root_dir)
  local notes = {}
  for _, path in ipairs(vim.fn.glob(root_dir .. "/**/*.md", true, true)) do
    table.insert(notes, path)
  end
  return notes
end

-- Read all links from all files
local function scan_links_from_notes(root_dir)
  local seen = {}
  local link_table = {}
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

-- Check if each link resolves to an actual note using ZkIndex, or fallback to filename
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

  local result = {}
  local pending = #link_list
  if pending == 0 then
    on_resolved(result)
    return
  end

  for _, link in ipairs(link_list) do
    index({ title = link, match = "contains" }, function(notes)
      local fallback_path = vim.fn.glob(cwd .. "/**/" .. link .. ".md")
      local found = notes and #notes > 0 or fallback_path ~= ""
      local final_path = (notes and #notes > 0 and notes[1].path)
        or (fallback_path ~= "" and fallback_path)
        or "[missing]"

      table.insert(result, {
        link = link,
        exists = found,
        path = final_path,
      })

      pending = pending - 1
      if pending == 0 then
        on_resolved(result)
      end
    end)
  end
end

function M.run()
  local cwd = vim.fn.getcwd()
  local link_list = scan_links_from_notes(cwd)

  resolve_links(link_list, cwd, function(results)
    if not results or #results == 0 then
      vim.notify("No links resolved after indexing.", vim.log.levels.WARN)
      return
    end

    pickers.new({}, {
      prompt_title = "Vault Link Status",
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
        end
      }),
      previewer = previewers.new_buffer_previewer({
        define_preview = function(self, entry)
          vim.defer_fn(function()
             local path = entry.value and entry.value.path
             if not path or path == "[missing]" or type(path) ~= "string" or vim.fn.filereadable(path) == 0 then
               path = fallback_txt
             end

             local lines = {}
             local ok, err = pcall(function()
               for line in io.lines(path) do
                 table.insert(lines, line)
               end
             end)

             if not ok then
               vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, { "Preview failed: " .. tostring(err) })
               return
             end

             if #lines == 0 then
               lines = { "[Empty file]" }
             end

             vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, lines)
        end, 20) -- delay in ms
    end
      }),
      sorter = conf.generic_sorter({}),
    }):find()
  end)
end

return M
