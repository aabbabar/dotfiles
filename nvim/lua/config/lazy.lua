-- Ensure NVM node is on PATH (works on any machine with NVM)
local nvm_versions = vim.fn.expand("~/.nvm/versions/node")
if vim.fn.isdirectory(nvm_versions) == 1 then
  local handle = io.popen('ls "' .. nvm_versions .. '" 2>/dev/null | sort -V | tail -1')
  if handle then
    local version = handle:read("*l")
    handle:close()
    if version and version ~= "" then
      vim.env.PATH = nvm_versions .. "/" .. version .. "/bin:" .. vim.env.PATH
    end
  end
end

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

require("config.options")

-- Setup lazy.nvim
require("lazy").setup({
  spec = {
    -- import your plugins
    { import = "plugins" },
  },
  -- Configure any other settings here. See the documentation for more details.
  -- colorscheme that will be used when installing plugins.
  install = { colorscheme = { "kanagawa" } },
  -- automatically check for plugin updates
  checker = { enabled = false },
})
