local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- Telescope settings
local builtin = require("telescope.builtin")
map("n", "<leader>ff", builtin.find_files, { desc = "Find Files" })
map("n", "<leader>fg", builtin.live_grep,  { desc = "Live Grep" })
map("n", "<leader>fb", builtin.buffers,    { desc = "Find Buffers" })
map("n", "<leader>fr", builtin.oldfiles,   { desc = "Recent Files" })
map("n", "<leader>fh", builtin.help_tags, { desc = "Help Tags" })

-- zk-nvim
