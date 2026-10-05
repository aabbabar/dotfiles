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

    -- ts_ls advertises prepareRename support but tsserver often returns
    -- "No Project" for that request. Disable it on attach so Neovim calls
    -- textDocument/rename directly instead.
    vim.api.nvim_create_autocmd("LspAttach", {
      callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if client and client.name == "ts_ls" then
          if type(client.server_capabilities.renameProvider) == "table" then
            client.server_capabilities.renameProvider.prepareProvider = false
          end
        end
      end,
    })

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
