return {
    "mickael-menu/zk-nvim",
    dependencies = { "nvim-telescope/telescope.nvim" },
    ft = "markdown",
    config = function()
        require("zk").setup({
            picker = "telescope",
            lsp = {
                config = {
                    name = "zk",
                    cmd = { "zk", "lsp" },
                filetypes = { "markdown" },
                auto_attach = { enabled = true, filetypes = { "markdown"}, },
                },
            },
    	})
        --require('telescope').load_extension('zk')
    end,
}

