local zk = require("zk")
local M = {}

function M.new(opts)
    print("Sourced!")
    opts = opts or {}
    local final_opts = vim.tbl_deep_extend("force", {}, opts, {
        date = opts.date or os.date("%Y-%m-%d"),
    })
    return zk.new(final_opts)
    --opts.date = opts.date or os.date("%Y-%m-%d")
    --opts.title = opts.title or vim.fn.input("Note Title: ")
    --opts.dir = opts.dir or "inbox"
    --return require("zk").new(opts)
end

return M
