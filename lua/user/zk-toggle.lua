local zk_diagnostics_enabled = {}

-- Toggle Zk Diagnostics per buffer
function ToggleZkDiagnostics()
	local bufnr = vim.api.nvim_get_current_buf()
	local enabled = zk_diagnostics_enabled[bufnr]

	if enabled == nil or enabled == false then
		vim.diagnostic.enable({enable = true, bufnr = bufnr})
		zk_diagnostics_enabled[bufnr] = true
		vim.notify("ZK diagnostics: ON", vim.log.levels.INFO)
	else
		vim.diagnostic.enable({enable = false, bufnr = bufnr})
		zk_diagnostics_enabled[bufnr] = false
		vim.notify("ZK diagnostics: OFF", vim.log.levels.INFO)
	end

end

-- Create a user command
vim.api.vim_create_user_command("ZkToggleDiagnostics", ToggleZkDiagnostics, {})
