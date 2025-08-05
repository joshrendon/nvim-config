-- ⚡ Native fuzzy sorting (optional but fast)
return {
}
--return {
--    'nvim-telescope/telescope-fzf-native.nvim',
--    build = 'make',
--    dependencies = { "nvim-telescope/telescope.nvim" },
--    config = function()
--	require('telescope').load_extension('fzf')
--    end,
--}
--return {
--    "nvim-telescope/telescope-fzf-native.nvim",
--    build = "make",
--    --cond = function()
--    --    return vim.fn.executable("make") == 1
--    --end,
--}
