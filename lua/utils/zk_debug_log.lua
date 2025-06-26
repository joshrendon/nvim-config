-- File: lua/utils/zk_debug_log.lua
local M = {}

local ring = {}
local max_entries = 50

-- Store logs as { timestamp, message, level }
local function add_log(message, level)
  if #ring >= max_entries then
    table.remove(ring, 1)
  end
  table.insert(ring, {
    time = os.date("%Y-%m-%d %H:%M:%S"),
    msg = message,
    level = level or "INFO",
  })
end

-- Override vim.notify to intercept messages
local original_notify = vim.notify
vim.notify = function(msg, level, opts)
  add_log(msg, level == vim.log.levels.ERROR and "ERROR" or "INFO")
  original_notify(msg, level, opts)
end

-- Optionally intercept error writes too
local original_err_write = vim.api.nvim_err_write
vim.api.nvim_err_write = function(msg)
  add_log(msg, "ERROR")
  original_err_write(msg)
end

function M.show_log()
  local buf = vim.api.nvim_create_buf(false, true)
  local lines = {}

  for _, entry in ipairs(ring) do
    local prefix = string.format("[%s] [%s] ", entry.time, entry.level)
    for i, line in ipairs(vim.split(entry.msg, "\n", { plain = true })) do
      if i == 1 then
        table.insert(lines, prefix .. line)
      else
        table.insert(lines, string.rep(" ", #prefix) .. line)
      end
    end
  end

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

  local width = math.min(120, vim.o.columns - 4)
  local height = math.min(#lines, vim.o.lines - 4)

  vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    col = math.floor((vim.o.columns - width) / 2),
    row = math.floor((vim.o.lines - height) / 2),
    style = "minimal",
    border = "rounded",
  })

    -- Automatically map 'q' to close the floating window
    vim.api.nvim_buf_set_keymap(buf, 'n', 'q', '<cmd>close<CR>', { nowait = true, noremap = true, silent = true })
end

-- Optional: expose logs as table
function M.get_logs()
  return ring
end

return M
