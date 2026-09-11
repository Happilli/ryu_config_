return {
  {
    "stevearc/conform.nvim",
    -- event = 'BufWritePre', -- uncomment for format on save
    opts = require "configs.conform",
  },

  -- These are some examples, uncomment them if you want to see them work!
  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },
  {
    dir = "~/development/neo_plug/crescenting",
    name = "crescenting",
    lazy = false,
    config = function()
      require("crescenting").setup {}
    end,
  },
}
