return {
  {
    'sainnhe/gruvbox-material',
    lazy = false,
    priority = 1000,
    config = function()
      -- Optionally configure and load the colorscheme
      -- directly inside the plugin declaration.
      vim.g.gruvbox_material_enable_italic = true
      vim.cmd.colorscheme('gruvbox-material')
      vim.api.nvim_set_hl(0, "CmpPmenu", {
        bg = "#1e22ff", -- change to your desired color
      })
    end
  },
  --   {
  --   "vague-theme/vague.nvim",
  --   lazy = false, -- make sure we load this during startup if it is your main colorscheme
  --   priority = 1000, -- make sure to load this before all the other plugins
  --   config = function()
  --     -- NOTE: you do not need to call setup if you don't want to.
  --     require("vague").setup({
  --       -- optional configuration here
  --     })
  --     vim.cmd("colorscheme vague")
  --   end
  -- }
}
