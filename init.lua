vim.env.ZK_NOTEBOOK_DIR = vim.fn.expand("C:/Users/v-jrendon/zettelkasten")
require("config.lazy")
require("user.options")
require("user.mappings")
require("user.colorschemes")
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

