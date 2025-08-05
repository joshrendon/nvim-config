return {
  "david-kunz/gen.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    require("gen").setup({
      model = "gpt-4o",
      show_prompt = true,
      show_model = true,
      -- SYSTEM PROMPT: This is your Milo daemon
    })
  end,
}

