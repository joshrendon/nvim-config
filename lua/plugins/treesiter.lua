return {
       'nvim-treesitter/nvim-treesitter', 
       'nvim-tree/nvim-web-devicons',
       config =  function()
         require("lazy").setup({
           branch = 'master', lazy = false, build = ":TSUpdate",
         })
       end,
}
