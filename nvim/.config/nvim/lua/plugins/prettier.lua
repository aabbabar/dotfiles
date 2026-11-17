return {
  {
    "MunifTanjim/prettier.nvim",
    -- lazy-load only for the filetypes you want
    ft = {
      "javascript",
      "javascriptreact",
      "typescript",
      "typescriptreact",
    },
    config = function()
      local prettier = require("prettier")

      prettier.setup({
        bin = "prettierd",
        filetypes = {
          "javascript",
          "javascriptreact",
          "typescript",
          "typescriptreact",
        },
      })
    end,
  },
}

