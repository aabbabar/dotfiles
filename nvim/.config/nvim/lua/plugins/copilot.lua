return {
  {
    "github/copilot.vim",

    -- Load when you use a Copilot command or enter Insert mode:
    cmd = "Copilot",
    event = "InsertEnter",

    config = function()
      vim.g.copilot_no_tab_map = true
      vim.keymap.set("i", "<C-l>", 'copilot#Accept("<CR>")', {
        expr = true,
        replace_keycodes = false,
        desc = "Copilot Accept",
      })
      -- vim.keymap.set("i", "<C-;>", 'copilot#AcceptWord("<CR>")', {
      --   expr = true,
      --   replace_keycodes = false,
      --   desc = "Copilot Accept Word",
      -- })

      -- Toggle Copilot globally with <leader>co (for the session)
      vim.keymap.set("n", "<leader>co", function()
        -- Ensure Copilot is loaded (safe even if already loaded)
        pcall(vim.cmd, "Copilot status")

        -- Query copilot#Enabled() robustly
        local ok, enabled = pcall(vim.api.nvim_call_function, "copilot#Enabled", {})
        if not ok then
          -- If we can't determine the state (e.g. plugin not found), try enabling once
          vim.notify("Copilot: could not read state; enabling once", vim.log.levels.WARN, { title = "GitHub Copilot" })
          pcall(vim.cmd, "Copilot enable")
          return
        end

        if enabled == 1 then
          vim.cmd("Copilot disable")
          vim.notify("Copilot: OFF", vim.log.levels.INFO, { title = "GitHub Copilot" })
        else
          vim.cmd("Copilot enable")
          vim.notify("Copilot: ON", vim.log.levels.INFO, { title = "GitHub Copilot" })
        end
      end, { desc = "Toggle Copilot (global)" })


      -- (B) Optional: enable/disable per filetype
      -- vim.g.copilot_filetypes = {
      --   ["*"] = true,  -- enable everywhere by default
      --   markdown = true,
      --   help = true,
      --   ["yaml"] = true,
      --   ["gitcommit"] = true,
      -- }

      -- (C) Optional: pin Node if needed (works with nvm, as an example)
      -- vim.g.copilot_node_command = vim.fn.expand("~/.nvm/versions/node/v20.11.1/bin/node")
    end,
  },
}
