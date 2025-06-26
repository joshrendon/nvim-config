local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- Zettelkasten note managment
vim.keymap.set("n", "<leader>zn", function()
    require("zk.commands").get("ZkNotes")()
end, { desc = "Zk: List all Notes" })
map("n", "<leader>zz", "<cmd>ZkNotes<CR>", opts)
map("n", "<leader>zf", "<cmd>ZkFind<CR>", opts)
vim.keymap.set("n", "<leader>zT", function()
    require("zk.commands").get("ZkTags")()
end, { desc = "Zk: Search tags" })
vim.keymap.set("n", "<leader>zl", function()
    require("zk.commands").get("ZkInsertLink")()
end, { desc = "Zk: Insert Link" })
vim.keymap.set("n", "<leader>zb", function()
    require("zk.commands").get("ZkBacklinks")()
end, { desc = "Zk: Show Backlinks" })
vim.keymap.set("n", "<leader>gf", function()
    require("zk.commands").get("ZkFollowLink")()
end, { desc = "Zk: Follow Link under cursor" })

vim.keymap.set("n", "<leader>zc", function()
    require("zk.commands").get("ZkCd")()
end, { desc = "ZkCd " })

-- Metadata hover mapping
--vim.keymap.set("n", "<leader>zh", function()
--    require("utils.zk_hover").show_zk_note_metadata()
--end, { desc = "Zk: Show metadata hover" })

--vim.keymap.set("n", "K", require("utils.zk_hover").hover, { buffer = true, desc = "ZK hover preview" })

-- Insert mode link helper (e.g. `[[link]]`
map("i", "<C-l>", "<cmd>ZkInsertLink<CR>", opts)

--vim.keymap.set("v", "<leader>zl", function()
--    require("zk.commands").get("ZkInsertLink")({select = true})
--end, { desc = "Zk: Insert Link(visual)", mode = "v" })


local zk = require("zk")

vim.keymap.set("n", "<leader>zd", function()
                require("utils.zk").new({
                    dir = "work/debug",
                    template = "debug.md",
                    --title = vim.fn.input("Debug Title: "),
                })
            end, { desc = "New debug note" })

vim.keymap.set("n", "<leader>zm", function()
                zk.new({
                    dir = "work/meetings",
                    template = "meeting.md",
                    --title = vim.fn.input("Meeting Title: "),
                })
            end, { desc = "New meeting note" })
vim.keymap.set("n", "<leader>zD", function()
                zk.new({
                    dir = "work/daily",
                    template = "daily.md",
                })
            end, { desc = "New daily note" })


-- Telescope
vim.keymap.set("n", "<leader>ff", function()
        require("telescope.builtin").find_files()
end, { desc = "Find Files" })
vim.keymap.set("n", "<leader>fg", function()
        require("telescope.builtin").live_grep()
end, { desc = "Live Grep" })
vim.keymap.set("n", "<leader>fb", function()
        require("telescope.builtin").buffers()
end, { desc = "Find Buffers" })
vim.keymap.set("n", "<leader>fr", function()
        require("telescope.builtin").oldfiles()
end, { desc = "Recent Files" })
vim.keymap.set("n", "<leader>fh", function()
        require("telescope.builtin").help_tags()
end, { desc = "Help Tags" })

-- General conveniences
map("n", "<leader>w", ":w<CR>", opts)
map("n", "<leader>q", ":q<CR>", opts)

-- auto-session keymappings
vim.keymap.set("n", "<leader>sg", ":SessionSearch<CR>", {desc = "Session Search"} )
vim.keymap.set("n", '<leader>ss', ':SessionSave<cr>', {desc = 'save session'})
vim.keymap.set("n", '<leader>sr', ':SessionRestore<cr>', {desc = 'save restore'})
--vim.keymap.set("n", '<leader>wa', ':Sessiontoggleautosave<cr>', {desc = 'toggle autosave'}) 

-- ZK preview mapping
vim.keymap.set("n", "<leader>zp", function()
        require("utils.zk_preview").preview_note_under_cursor()
end, { desc = "Zk note preview" })

--vim.keymap.set("n", "<leader>zo", function()
--        require("zk.commands").get("zk.open")()
--end, { desc = "Zk Open link" })


vim.keymap.set("n", "<leader>fd", function()
	vim.cmd("e ~/zettelkasten/dashboard.md")
end, { desc = "Open ZK Dashboard" })

vim.api.nvim_create_autocmd("FileType", {
	pattern = "markdown",
	callback = function()
	  vim.keymap.set("n", "<CR>", function()
	    require("zk.commands").get("ZkLinks")()
	  end, { buffer = true, desc = "Open zk link under cursor" })
	end,
})

vim.api.nvim_create_user_command("ZkLinks", function()
	require("zk.commands").get("links")()
end, {})

--vim.api.nvim_create_autocmd("FileType", {
--	pattern = "markdown",
--	callback = function()
--	  vim.keymap.set("n", "<CR>", function()
--	    require("zk.commands").get("zk.open")()
--	  end, { buffer = true, desc = "Follow zk" })
--	end,
--})

-- Keymap for toggling zk diagnostics
vim.keymap.set("n", "<leader>td", ":ZkToggleDiagnostics<CR>", { desc = "Toggle ZK Diagnostics" })

vim.api.nvim_create_user_command("ZkReindex", function()
  vim.fn.jobstart({ "zk", "index" }, {
    stdout_buffered = true,
    on_stdout = function(_, data)
      if data then
        vim.notify(table.concat(data, "\n"), vim.log.levels.INFO)
      end
    end,
    on_exit = function(_, code)
      if code == 0 then
        vim.notify("Zk index rebuilt ✅", vim.log.levels.INFO)
      else
        vim.notify("Zk index failed ❌", vim.log.levels.ERROR)
      end
    end,
  })
end, {})

--local zk = require("utils.zk_utils")
vim.keymap.set("n", "<leader>zt", function()
    require("utils.zk_utils").zk_edit_in_tab()
end, { desc = "ZkEdit (tabbed)" })

vim.keymap.set("n", "<leader>zd", function()
    require("utils.zk_debug_log").show_log()
end, {desc = "ZkDebugLog "})

vim.keymap.set({"i", "s" }, "<Tab>", function()
    return require("luasnip").expand_or_jumpable()
    and "<Plug>luasnip-expand-or-jump"
    or "<Tab>"
end, { expr = true, silent =  true })

vim.keymap.set({"i", "s" }, "<S-Tab>", function()
    return require("luasnip").jumpable(-1)
    and "<Plug>luasnip-jump-prev"
    or "<S-Tab>"
end, { expr = true, silent =  true })

