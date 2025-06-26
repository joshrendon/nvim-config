---- 💾 Telescope integration for auto-session
return {
    "rmagatti/session-lens",
        dependencies = {
            "rmagatti/auto-session",
            "nvim-telescope/telescope.nvim",
        },
        config = function()
            require("session-lens").setup({
            path_display = { "shorten" },
        })
        require('telescope').load_extension('session-lens')
    end,
}
