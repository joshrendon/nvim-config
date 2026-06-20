return {
    "https://github.com/mason-org/mason.nvim",
    dependencies = {
        "https://github.com/mason-org/mason-lspconfig.nvim",
        "https://github.com/neovim/nvim-lspconfig",
    },
    config = function()
        vim.env.GIT_ASKPASS = ""

        local capabilities = vim.lsp.protocol.make_client_capabilities()
        capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)
        require("mason").setup()
        require("mason-lspconfig").setup({
            ensure_installed =
            {
                "lua_ls",
                "marksman",
                "pyright",
                "verible",
                "svlangserver"
            },
            handlers = {
                function(server_name)
                    require("lspconfig")[server_name].setup({})
                end,
            },
        })
       vim.lsp.config("pyright", {
           setup = {
               capabilities = capabilities,
           },
       })
    end,
}
