vim.env.ZK_NOTEBOOK_DIR = vim.fn.expand("/home/jrendon/zettelkasten")
require("config.lazy")
require("user.options")
require("user.mappings")
require("user.colorschemes")
--require("utils.zk_commands")
require("utils.zk_highlight")
require("utils.zk_debug_log")

vim.api.nvim_set_hl(0, "@test.reference.markdown_inline", { link = "Identifier" })
vim.api.nvim_set_hl(0, "@test.literal.markdown_inline", { link = "Comment" })
-- Optinal to emphasize wiki links more
vim.api.nvim_set_hl(0, "@test.url.markdown_inline", { fg = "#89b4fa", italic = true })

-- Disable ZK's LSP diagnostics
vim.api.nvim_create_autocmd("FileType", {
	pattern = "markdown",
	callback = function()
		-- Find and disable only zk.nvim diagnostics
		for ns, info in pairs(vim.diagnostic.get_namespaces()) do
			if info.name == "vim.lsp.zk.1" then
				vim.diagnostic.disable(0, ns)
			end
		end
	end,
})

-- Optionally, set filetype-specific settings for Markdown
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "markdown" },
  callback = function()
    -- Enable spell checking for Markdown
    vim.cmd("setlocal spell spelllang=en_us")
  end,
})

vim.api.nvim_create_user_command("ZkLinkStatus", function()
  require("zk_link_status").run()
end, {})

vim.api.nvim_create_autocmd("BufReadPre", {
  pattern = "*/zettelkasten/*.md",
  callback = function()
    if vim.fn.tabpagenr('$') == 1 or vim.fn.buflisted(vim.fn.bufnr('%')) == 0 then
      -- only open in new tab if not already tabbed or not explicitly listed
      vim.cmd("tabnew %")
    end
  end,
})

vim.api.nvim_create_user_command("ZkDebugLog", function()
  require("utils.zk_debug_log").show_log()
end, {})

require("luasnip.loaders.from_lua").load({
  paths = { vim.fn.stdpath("config") .. "/lua/snippets" },
})

require("luasnip").filetype_extend("markdown", { "markdown" })

vim.api.nvim_create_user_command("ZkRename", function(opts)
  local new_title = table.concat(opts.fargs, " ")
  local file      = vim.fn.expand('%:p')
  vim.fn.system({'bash', '/path/to/zk-mass-rename.sh'}, file .. '\0')
end, { nargs = "+" })

vim.api.nvim_create_user_command("ZkEncryptPrivate", function()
  local file = vim.api.nvim_buf_get_name(0)
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)

  -- Check for #private tag
  local is_private = false
  for _, line in ipairs(lines) do
    if line:match("#private") then
      is_private = true
      break
    end
  end

  if not is_private then
    print("No #private tag found in this note.")
    return
  end

  local age_file = file .. ".age"

  -- Confirm before encrypting
  vim.ui.input({ prompt = "Encrypt and replace with .age? (y/N): " }, function(input)
    if input == "y" or input == "Y" then
      vim.cmd("write")  -- Save current buffer
      local cmd = string.format('age -p -o "%s" "%s"', age_file, file)
      os.execute(cmd)
      os.execute(string.format('shred -u "%s"', file))
      vim.cmd("edit " .. age_file)
      print("Encrypted and reloaded: " .. age_file)
    else
      print("Encryption aborted.")
    end
  end)
end, {})

vim.treesitter.language.add(
    "systemverilog",
    {path = '/home/jrendon/.local/share/tree-sitter/tree-sitter-systemverilog/systemverilog.so'}
)
vim.treesitter.language.register('systemverilog', {'sv'})

vim.api.nvim_create_autocmd('User', { pattern = 'TSUpdate',
callback = function()
  require('nvim-treesitter.parsers').systemverilog= {
    install_info = {
      path = '~/.local/share/tree-sitter/tree-sitter-systemverilog',
      location = 'parser', -- only needed if the parser is in subdirectory of a "monorepo"
      generate = true, -- only needed if repo does not contain pre-generated `src/parser.c`
      generate_from_json = false, -- only needed if repo does not contain `src/grammar.json` either
      queries = 'queries/neovim', -- also install queries from given directory
    },
  }
end})

--vim.api.nvim_create_autocmd("BufWritePost", {
--	pattern = {"*.v", "*.sv"},
--	callback = function() vim.lsp.buf.format({ async = false }) end,
--})

