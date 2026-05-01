return {
    "https://github.com/mason-org/mason.nvim",
    dependencies = {
        "https://github.com/mason-org/mason-lspconfig.nvim",
        "https://github.com/neovim/nvim-lspconfig",
    },
    config = function()
        vim.env.GIT_ASKPASS = ""
        require("mason").setup()
        require("mason-lspconfig").setup({
            ensure_installed =
            {
                "lua_ls",
                "marksman",
                "verible"
            },
            handlers = {
                function(server_name)
                    require("lspconfig")[server_name].setup({})
                end,
            },
        })
    end,
}
