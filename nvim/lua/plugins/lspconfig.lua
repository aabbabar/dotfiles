return {
  "neovim/nvim-lspconfig",
  config = function()
    local lspconfig = require("lspconfig")

    lspconfig.lua_ls.setup{
      settings = {
        Lua = {
          diagnostics = {
            globals = { "vim" },  -- recognize 'vim' as global
          },
        },
      },
    }

    lspconfig.eslint.setup{
      -- attach only to JS/TS filetypes
      filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },

      -- use prettierd for formatting
      settings = {
        format = {
          enable = false,
        },
      },
      -- on_attach = function(client, bufnr)
      --   -- disable formatting (you already have a format shortcut)
      --   client.server_capabilities.documentFormattingProvider = false
      --
      --   -- example keymap for hover
      --   vim.api.nvim_buf_set_keymap(bufnr, 'n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', { noremap=true, silent=true })
      -- end,
    }
  end,
}

