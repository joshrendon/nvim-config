return {
    "https://github.com/nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
        require("nvim-treesitter.configs").setup({
            ensure_installed = {"markdown", "markdown_inline"},
            highlight = {
                enabled = true,
                additional_vim_regex_highlighting = { "markdown" },
            },
        })
    end,
}
