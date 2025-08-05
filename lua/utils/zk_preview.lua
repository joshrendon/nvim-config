local M = {}

function M.preview_note_under_cursor()

    local cursor_word = vim.fn.expand("<cWORD>")
    local note_title = cursor_word:match("%[%[([^%]]+)%]%]")
    if not note_title then
        vim.notify("No zk link under cursor", vim.log.levels.WARN)
        return
    end

    local zk = require("zk")

    vim.notify("Found note title: ".. note_title, vim.log.levels.INFO)
    zk.list({
        select = { "title" },
        predicate = function(note)
            return note.title == note_title
        end,
        callback = function(note)
            if #notes == 0 then
                vim.notify("note not found: " .. note_title, vim.log.levels.ERROR)
                return
            end
            local path = notes[1].path
            local lines = vim.fn.readfile(path)
            local content = table.concat(lines, "\n")

            vim.api.nvim_open_win(vim.api.nvim_create_buf(false, true), true, {
                relative = "cursor",
                width = math.min(80, vim.o.columns - 4),
                height = math.min(20, vim.o.lines -6),
                row = 1,
                col = 1,
                style = "minimal",
                border = "rounded",
            })
            vim.api.nvim_buf_set_lines(0,0,-1,false,vim.split(content, "\n"))
        end
    })
end

return M
