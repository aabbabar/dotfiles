return {
  'nvim-treesitter/nvim-treesitter',
  branch = 'main',
  lazy = false,
  build = ':TSUpdate',
  event = { "BufReadPost", "BufNewFile" },
  config = function()
    if vim.fn.executable('tree-sitter') == 1 then
      require("nvim-treesitter").install({
        "javascript", "typescript", "tsx", "json", "css", "html",
      })
    end
    vim.api.nvim_create_autocmd("FileType", {
      callback = function()
        pcall(vim.treesitter.start)
      end,
    })
  end,
}
