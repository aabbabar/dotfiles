return {
  dir = "~/dev/presenting.nvim",
  name = 'presenting.nvim' ,
  opts = {
    width = 250,
    separator = {
      -- Separators for different filetypes.
      -- You can add your own or overwrite existing ones.
      -- Note: separators are lua patterns, not regexes.
      markdown = "---",
    },
    keep_separator = false,
    -- fill in your options here
    -- see :help Presenting.config
  },
  cmd = { "Presenting" },
  keys = {
    {
      "<leader>f5",
      "<cmd>Presenting<cr>",
      desc = "Start presentation",
    },
  },
}
