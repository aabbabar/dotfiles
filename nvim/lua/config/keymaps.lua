vim.keymap.set("n", "<leader>w", ":w<CR>")
vim.keymap.set("n", "<leader>W", ":wa<CR>")
vim.keymap.set("n", "<leader>q", ":q<CR>")
vim.keymap.set("n", "<leader>Q", ":qa!<CR>")
vim.keymap.set("n", "<leader>h", ":noh<CR>")
vim.keymap.set("n", "<leader>r", ":e!<CR>")
vim.keymap.set("n", "<leader>so", ":source<CR>")
vim.keymap.set("n", "<C-p>", ":Oil --float<CR>")
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

vim.api.nvim_set_keymap("n", "<C-w>h", ":split<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<C-w>v", ":vsplit<CR>", { noremap = true, silent = true })

vim.keymap.set({ "n", "v", "x" }, "<leader>y", '"+y', { noremap = true })
vim.keymap.set({ "n", "v", "x" }, "<leader>p", '"+p', { noremap = true })

vim.keymap.set("n", "<space>fo", function()
  vim.lsp.buf.format({ async = true })
end, {})

vim.keymap.set("n", "<leader>e", function()
  vim.diagnostic.open_float(nil, { focusable = false })
end, {})

local builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>ff", builtin.find_files)
vim.keymap.set("n", "<leader>fg", builtin.live_grep)
vim.keymap.set("n", "<leader>fs", builtin.grep_string)
vim.keymap.set("n", "<leader>fh", builtin.current_buffer_fuzzy_find)
vim.keymap.set("n", "<leader>fb", builtin.buffers)
vim.keymap.set("n", "<leader>fr", builtin.registers)
vim.keymap.set("n", "<leader>fe", builtin.diagnostics)
vim.keymap.set("n", "<leader>fr", builtin.lsp_references)
vim.keymap.set("n", "<leader>fm", builtin.man_pages)
vim.keymap.set("n", "<leader>ft", builtin.treesitter)
vim.keymap.set("n", "<leader>fu", builtin.resume)
vim.keymap.set("n", "<leader>fq", builtin.quickfix)

vim.keymap.set("n", "K", vim.lsp.buf.hover)
vim.keymap.set("n", "<leader>gD", vim.lsp.buf.declaration)
vim.keymap.set("n", "gi", vim.lsp.buf.implementation)
vim.keymap.set("n", "<space>rn", vim.lsp.buf.rename)
vim.keymap.set({ "n", "v" }, "<space>ca", vim.lsp.buf.code_action)


vim.keymap.set("n", "tn", ":tabnew<CR>", { silent = true })
vim.keymap.set("n", "tc", ":tabclose<CR>", { silent = true })
vim.keymap.set("n", "]t", ":tabnext<CR>", { silent = true })
vim.keymap.set("n", "[t", ":tabprevious<CR>", { silent = true })
for i = 1, 9 do
  vim.keymap.set('n', '<leader>' .. i, function()
    vim.cmd(i .. 'tabnext')
  end, { desc = 'Go to tab ' .. i })
end

vim.api.nvim_create_autocmd('FileType', {
  pattern = { '<filetype>' },
  callback = function() vim.treesitter.start() end,
})

vim.lsp.enable({ "lua_ls", "yamlls", "ts_ls", "eslint", "gopls", "clangd", "marksman", "arduino_language_server" })

vim.api.nvim_set_hl(0, "NormalFloat", { bg = "#282828" })
vim.api.nvim_set_hl(0, "FloatBorder", { bg = "#282828" })

local function copy_to_clipboard(text)
  vim.fn.setreg("+", text)
  vim.notify("Copied: " .. text, vim.log.levels.INFO)
end

local function get_git_root()
  local root = vim.fn.systemlist("git rev-parse --show-toplevel")[1]
  if vim.v.shell_error ~= 0 or root == nil or root == "" then
    root = vim.loop.cwd()
  end
  return root
end

-- Full absolute path
vim.keymap.set("n", "<leader>fpa", function()
  local path = vim.fn.expand("%:p")
  copy_to_clipboard(path)
end, { desc = "Copy full absolute path" })

-- Full relative path (relative to git root)
vim.keymap.set("n", "<leader>fpr", function()
  local git_root = get_git_root()
  local abs_path = vim.fn.expand("%:p")
  local rel_path = vim.fn.fnamemodify(abs_path, ":." .. git_root)
  copy_to_clipboard(rel_path)
end, { desc = "Copy path relative to git root" })

-- Just filename
vim.keymap.set("n", "<leader>fpf", function()
  local filename = vim.fn.expand("%:t")
  copy_to_clipboard(filename)
end, { desc = "Copy filename only" })

vim.filetype.add({
  extension = {
    mdx = "markdown",
  },
})

-- Function to copy GitHub URL for selected lines
function CopyGitHubUrl()
  local file_path = vim.fn.expand("%:p") -- Full path of the current file
  local repo_url = vim.fn.system("git config --get remote.origin.url"):gsub("\n", "")

  -- Convert git URL to GitHub URL (handle HTTPS and SSH)
  repo_url = repo_url:gsub("git@github.com:", "https://github.com/"):gsub("%.git$", "")

  local branch = vim.fn.system("git rev-parse --abbrev-ref HEAD"):gsub("\n", "")
  local relative_path = vim.fn.system("git ls-files --full-name " .. file_path):gsub("\n", "")

  -- Get visual selection range
  local start_line = vim.fn.getpos("'<")[2] -- Line number of the selection start
  local end_line = vim.fn.getpos("'>")[2]   -- Line number of the selection end
  local line_range = start_line == end_line and ("#L" .. start_line) or ("#L" .. start_line .. "-L" .. end_line)

  -- Construct GitHub URL
  local github_url = repo_url .. "/blob/" .. branch .. "/" .. relative_path .. line_range

  -- Copy to system clipboard
  vim.fn.setreg("+", github_url)
  print("Copied GitHub URL: " .. github_url)
end

-- Map shortcut for visual mode
vim.api.nvim_set_keymap("v", "<leader>gu", ":lua CopyGitHubUrl()<CR>", { noremap = true, silent = true })

vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight when yanking (copying) text",
  group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

local group = vim.api.nvim_create_augroup("AutoReadOnFocus", { clear = true })
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter" }, {
  group = group,
  pattern = "*",
  command = "silent! checktime",
})

vim.api.nvim_create_autocmd("FileChangedShellPost", {
  pattern = "*",
  callback = function()
    vim.api.nvim_echo({ { "File changed on disk. Buffer reloaded.", "WarningMsg" } }, false, {})
  end,
})


vim.keymap.set("n", "<leader>gc", function()
  local builtin = require("telescope.builtin")
  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local conf = require("telescope.config").values
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")

  local current_file = vim.fn.expand("%")

  -- Get all branches (local + remote)
  local output = vim.fn.systemlist("git branch --all --format='%(refname:short)'")
  if vim.v.shell_error ~= 0 then
    vim.notify("Not a git repo or git error", vim.log.levels.ERROR)
    return
  end

  -- Custom Telescope picker
  pickers
      .new({}, {
        prompt_title = "Git Branches",
        finder = finders.new_table({
          results = output,
        }),
        sorter = conf.generic_sorter({}),
        attach_mappings = function(prompt_bufnr, map)
          actions.select_default:replace(function()
            local selection = action_state.get_selected_entry()[1]
            actions.close(prompt_bufnr)

            local cmd = string.format("Gvdiffsplit %s:%s", selection, current_file)
            vim.cmd(cmd)
          end)
          return true
        end,
      })
      :find()
end, { desc = "Diff current file vs selected Git branch" })
