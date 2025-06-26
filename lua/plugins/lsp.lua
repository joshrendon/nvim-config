return {
    "https://github.com/neovim/nvim-lspconfig",
    event = {"BufReadPre", "BufNewFile" },
    config = function()
        local lspconfig = require("lspconfig")

        -- Lua LSP
        lspconfig.lua_ls.setup({
            settings = {
                Lua = {
                   diagonstics = { globals = { "vim" } },
                }
            }
        })
        -- Markdown pseudo-LSP: plaintext server (basic completion)
        lspconfig.marksman.setup({}) -- simple LSP for markdown, optional
    end,
}
