vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    vim.cmd([[
      syntax match ZkTechWord /\<[A-Z_]\{2,}\>/
      syntax match ZkSignal /\<l1_[a-zA-Z0-9_]*\>/
      syntax match ZkHex /\<0x[0-9A-Fa-f]\+\>/

      highlight default link ZkTechWord Keyword
      highlight default link ZkSignal Identifier
      highlight default link ZkHex Number
    ]])
  end,
})

