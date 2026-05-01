-- 📦 Session management core
return {
    "rmagatti/auto-session",
    config = function()
        vim.o.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"
        require("auto-session").setup({
            log_level = "info",
            auto_restore = true,
            auto_save_enabled = true,
            auto_restore_last_session = false,
            auto_save = true,
            --root_dir = "/Users/josh/.local/share/nvim/sessions",
            auto_session_supress_dirs = { '~/', '~/Downloads'},
            auto_session_root_dir = vim.fn.stdpath('data')..'/sessions',
            suppressed_dirs = { "~/", "~/Downloads", "/" }
        })

    end,
}
