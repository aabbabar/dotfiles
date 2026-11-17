-- return { 'echasnovski/mini.statusline', version = false, opts={} }
return {
  "nvim-lualine/lualine.nvim",
  config = function()
    require('lualine').setup({
      options = {
        theme = "auto",
        globalstatus = true,
      },
      sections = {
        lualine_c = {
          {
            'filename',
            path = 1, -- 0 = just filename, 1 = relative path, 2 = absolute path, 3 = filename and parent dir
          },
        },
      },
    })
  end
}

