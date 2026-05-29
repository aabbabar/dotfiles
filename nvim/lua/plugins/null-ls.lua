return {
  {
    "nvimtools/none-ls.nvim",
    event = { "BufReadPre", "BufNewFile" }, -- lazy load on buffer open
    dependencies = { "nvim-lua/plenary.nvim" },
  },
}
