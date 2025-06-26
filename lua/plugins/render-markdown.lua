return {
    "https://github.com/MeanderingProgrammer/render-markdown.nvim",
    config = function()
        require('render-markdown').setup({
            link = {
                enabled = true,
                render_modes = false,
                footnote = {
                    enabled = true,
                    superscript = true,
                    prefix = '',
                    suffix = '',
                },
                image = '󰥶 ',
                email = '󰀓 ',
                hyperlink = '󰌹 ',
                highlight = 'RenderMarkdownLink',
                wiki = {
                    icon = '󱗖 ',
                    body = function()
                        return nil
                    end,
                    highlight = 'RenderMarkdownWikiLink',
                },
                custom = {
                    web = { pattern = '^http', icon = '󰖟 ' },
                    discord = { pattern = 'discord%.com', icon = '󰙯 ' },
                    github = { pattern = 'github%.com', icon = '󰊤 ' },
                    gitlab = { pattern = 'gitlab%.com', icon = '󰮠 ' },
                    google = { pattern = 'google%.com', icon = '󰊭 ' },
                    neovim = { pattern = 'neovim%.io', icon = ' ' },
                    reddit = { pattern = 'reddit%.com', icon = '󰑍 ' },
                    stackoverflow = { pattern = 'stackoverflow%.com', icon = '󰓌 ' },
                    wikipedia = { pattern = 'wikipedia%.org', icon = '󰖬 ' },
                    youtube = { pattern = 'youtube%.com', icon = '󰗃 ' },
                },
            },
        })
    end
}
