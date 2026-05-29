local actions = require("telescope.actions")
return {
  'nvim-telescope/telescope.nvim',
  dependencies = {
    'nvim-lua/plenary.nvim',
    -- optional but recommended
    { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
  },
  config = function()
    require("telescope").setup({
      defaults = {
        layout_strategy = "vertical",
        mappings = {
          i = {
            ["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist, -- selected only
            ["<C-a>"] = actions.smart_send_to_qflist + actions.open_qflist, -- all entries (Ctrl+Shift+q)
          },
          n = {
            ["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
            ["<C-a>"] = actions.smart_send_to_qflist + actions.open_qflist,
          },
        },
      },
      pickers = {
        find_files = {
          hidden = true,
        },
      },
    })
  end,
}
