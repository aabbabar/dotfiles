return {
  'nvim-treesitter/nvim-treesitter',
  lazy = false,
  build = ':TSUpdate',
  event = { "BufReadPost", "BufNewFile" },
  config = function()
    require("nvim-treesitter.configs").setup({
      ensure_installed = { "javascript", "typescript", "tsx", "json", "css", "html" },
      highlight = { enable = true },
    })
    -- vim.o.foldexpr = "v:lua.vim.treesitter.foldexpr()"
    -- vim.o.foldtext = "v:lua.vim.treesitter.foldtext()"
  end,
}
