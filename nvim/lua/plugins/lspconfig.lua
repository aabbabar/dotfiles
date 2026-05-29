return {
  "neovim/nvim-lspconfig",
  config = function()
    vim.lsp.config["lua_ls"] = {
      settings = {
        Lua = {
          diagnostics = {
            globals = { "vim" },
          },
        },
      },
    }

    vim.lsp.config["gopls"] = {
      settings = {
        gopls = {
          analyses = {
            unusedparams = true,
          },
          staticcheck = true,
        },
      },
    }

    vim.lsp.config["eslint"] = {
      filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
      settings = {
        format = {
          enable = false,
        },
      },
    }
  end,
}
