 -- 🔍 Telescope core
 return {
    "https://github.com/nvim-telescope/telescope.nvim",
        dependencies = { "https://github.com/nvim-lua/plenary.nvim" },
        config = function()
            require("telescope").setup({
                    pickers = {
                         find_files = { hidden = true },
                    },
                    extensions = {
                        fzf = {
                            fuzzy = true,
                            override_generic_sorter = true,
                            override_file_sorter = true,
                            case_mode = "smart_case",
                        },
                    },
            })

            -- Load extensions if available
            --pcall(telescope.load_extension, "zk")
            --require('telescope').load_extension('zk')
            --require('telescope').load_extension('fzf')
            --require('telescope').load_extension('session-lens')
            --pcall(telescope.load_extension, "fzf")
            --pcall(telescope.load_extension, "session-lens")
    end,
}
