-- lua/lsp/diagnostics.lua
vim.diagnostic.config({
  virtual_text = false,
  severity_sort = true,
  float = { border = "rounded" },
})

-- Show diagnostics on CursorHold
vim.api.nvim_create_autocmd("CursorHold", {
  callback = function()
    vim.diagnostic.open_float(nil, { focus = false })
  end,
})
