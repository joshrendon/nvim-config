return {
  "windwp/nvim-autopairs",
  event = "InsertEnter",  -- Load only when you start typing
  config = function()
    require("nvim-autopairs").setup({
      check_ts = true,     -- Enable Treesitter-based rules (optional)
      fast_wrap = {},
    })

    -- Optional: integrate with nvim-cmp
    local cmp_autopairs = require("nvim-autopairs.completion.cmp")
    local cmp = require("cmp")
    cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
  end,
}

