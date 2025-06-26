vim.opt.number = true
vim.opt.relativenumber = false
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.mouse = "a"
--vim.opt.terguicolors = true

-- options for auto-session
vim.o.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal"

vim.api.nvim_create_autocmd("FileType", {
  pattern = {
    "markdown", "text", "gitcommit", "help", "man", "alpha", "netrw",
    "TelescopePrompt", "checkhealth", "lspinfo"
  },
  callback = function()
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
  end,
})

