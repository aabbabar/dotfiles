vim.keymap.set("n", "<leader>w", ":w<CR>")
vim.keymap.set("n", "<leader>W", ":wa<CR>")
vim.keymap.set("n", "<leader>q", ":q<CR>")
vim.keymap.set("n", "<leader>Q", ":qa!<CR>")
vim.keymap.set("n", "<leader>h", ":noh<CR>")
vim.keymap.set("n", "<leader>r", ":e!<CR>")
local git_review

local function close_review_diff()
  if not git_review then
    return true
  end
  for _, win in ipairs(git_review.comparisons) do
    if vim.api.nvim_win_is_valid(win) and vim.bo[vim.api.nvim_win_get_buf(win)].modified then
      vim.notify("Save the modified comparison buffer before continuing", vim.log.levels.WARN)
      return false
    end
  end
  for _, win in ipairs(git_review.comparisons) do
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, false)
    end
  end
  if vim.api.nvim_win_is_valid(git_review.work) then
    vim.api.nvim_win_call(git_review.work, function()
      vim.cmd("diffoff")
    end)
  end
  git_review = nil
  return true
end

local function open_review_diff()
  local work = vim.api.nvim_get_current_win()
  local context = vim.fn.getqflist({ context = 0 }).context
  if type(context) ~= "table" or not context.git_review then
    vim.cmd("Gdiffsplit")
    return
  end
  if git_review and vim.api.nvim_win_is_valid(git_review.work) then
    work = git_review.work
  end
  if not close_review_diff() then
    return
  end
  vim.api.nvim_set_current_win(work)
  local path = vim.api.nvim_buf_get_name(0)
  local tracked = vim.system(
    { "git", "ls-files", "--error-unmatch", "--", path },
    { cwd = context.root, text = true }
  ):wait()
  git_review = { work = work, comparisons = {}, list = vim.fn.getqflist({ id = 0 }).id }
  if tracked.code ~= 0 then
    return
  end
  local existing = {}
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    existing[win] = true
  end
  local ok, err = pcall(vim.cmd, "Gdiffsplit")
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if not existing[win] then
      table.insert(git_review.comparisons, win)
    end
  end
  vim.api.nvim_set_current_win(work)
  if not ok then
    vim.notify(tostring(err), vim.log.levels.ERROR)
  end
end

local function navigate_quickfix(direction)
  local list = vim.fn.getqflist({ id = 0, idx = 0, size = 0, context = 0 })
  local reviewing = git_review and git_review.list == list.id
    and type(list.context) == "table" and list.context.git_review
  if reviewing and not vim.api.nvim_win_is_valid(git_review.work) then
    close_review_diff()
    reviewing = false
  end
  if reviewing then
    local target = list.idx + direction
    if target < 1 or target > list.size then
      vim.notify("No more quickfix entries", vim.log.levels.INFO)
      return
    end
    local work = git_review.work
    if vim.bo[vim.api.nvim_win_get_buf(work)].modified and not vim.o.hidden then
      vim.notify("Save the working buffer before continuing", vim.log.levels.WARN)
      return
    end
    if not close_review_diff() then
      return
    end
    vim.api.nvim_set_current_win(work)
  end
  local ok, err = pcall(vim.cmd, direction == 1 and "cnext" or "cprevious")
  if not ok then
    vim.notify(tostring(err), vim.log.levels.WARN)
    return
  end
  if reviewing then
    open_review_diff()
  end
end

vim.keymap.set("n", "<leader>d", open_review_diff, { desc = "Git diff split" })
vim.keymap.set("n", "<leader>so", ":source<CR>")
vim.keymap.set("n", "<C-p>", ":Oil --float<CR>")
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")
vim.keymap.set("n", "]g", "<Plug>(GitGutterNextHunk)zz", { desc = "Next Git change hunk" })
vim.keymap.set("n", "[g", "<Plug>(GitGutterPrevHunk)zz", { desc = "Previous Git change hunk" })
vim.keymap.set("n", "]q", function() navigate_quickfix(1) end, { desc = "Next quickfix entry" })
vim.keymap.set("n", "[q", function() navigate_quickfix(-1) end, { desc = "Previous quickfix entry" })

vim.keymap.set("n", "<leader>gq", function()
  local buffer_path = vim.api.nvim_buf_get_name(0)
  local cwd = buffer_path ~= "" and vim.fs.dirname(buffer_path) or vim.fn.getcwd()
  local root_result = vim.system({ "git", "rev-parse", "--show-toplevel" }, { cwd = cwd, text = true }):wait()
  if root_result.code ~= 0 then
    vim.notify("Not inside a Git repository", vim.log.levels.WARN)
    return
  end

  local root = root_result.stdout:gsub("\n$", "")
  local result = vim.system(
    { "git", "status", "--porcelain=v1", "-z", "--untracked-files=all" },
    { cwd = root }
  ):wait()
  if result.code ~= 0 then
    vim.notify("Failed to read Git status: " .. result.stderr, vim.log.levels.ERROR)
    return
  end

  local records = vim.split(result.stdout, "\0", { plain = true, trimempty = true })
  local items, seen = {}, {}
  local skipped, index = 0, 1
  while index <= #records do
    local record = records[index]
    local status, path = record:sub(1, 2), record:sub(4)
    -- In NUL-delimited status, a rename/copy's source follows its destination.
    if status:find("[RC]") then
      index = index + 1
    end
    local absolute_path = root .. "/" .. path
    if vim.fn.filereadable(absolute_path) == 1 then
      if not seen[path] then
        items[#items + 1] = { filename = absolute_path, lnum = 1, text = status .. " " .. path }
        seen[path] = true
      end
    else
      skipped = skipped + 1
    end
    index = index + 1
  end

  if not close_review_diff() then
    return
  end
  vim.fn.setqflist({}, " ", {
    title = "Git changes: " .. root,
    items = items,
    context = { git_review = true, root = root },
  })
  if #items > 0 then
    vim.cmd("copen")
  else
    vim.notify("No changed files to open", vim.log.levels.INFO)
  end
  if skipped > 0 then
    vim.notify("Skipped " .. skipped .. " deleted or non-file Git entries", vim.log.levels.INFO)
  end
end, { desc = "Git changed files to quickfix" })

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

local telescope = function(picker)
  return function()
    require("telescope.builtin")[picker]()
  end
end
vim.keymap.set("n", "<leader>ff", telescope("find_files"))
vim.keymap.set("n", "<leader>fg", telescope("live_grep"))
vim.keymap.set("n", "<leader>fs", telescope("grep_string"))
vim.keymap.set("n", "<leader>fh", telescope("current_buffer_fuzzy_find"))
vim.keymap.set("n", "<leader>fb", telescope("buffers"))
vim.keymap.set("n", "<leader>fr", telescope("registers"))
vim.keymap.set("n", "<leader>fe", telescope("diagnostics"))
vim.keymap.set("n", "<leader>fr", telescope("lsp_references"))
vim.keymap.set("n", "<leader>fm", telescope("man_pages"))
vim.keymap.set("n", "<leader>ft", telescope("treesitter"))
vim.keymap.set("n", "<leader>fu", telescope("resume"))
vim.keymap.set("n", "<leader>fq", telescope("quickfix"))

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

local function get_git_relative_path(abs_path)
  return vim.fn.fnamemodify(abs_path, ":." .. get_git_root())
end

local function copy_visual_file_reference()
  local abs_path = vim.api.nvim_buf_get_name(0)
  if abs_path == "" then
    vim.notify("Cannot copy a file reference from an unnamed buffer", vim.log.levels.ERROR)
    return
  end

  -- '< and '> are updated only after Visual mode ends.
  local start_line = vim.fn.line("v")
  local end_line = vim.fn.line(".")
  if start_line <= 0 or end_line <= 0 then
    vim.notify("Cannot determine the visual selection", vim.log.levels.ERROR)
    return
  end

  start_line, end_line = math.min(start_line, end_line), math.max(start_line, end_line)
  local line_anchor = start_line == end_line and ("#L" .. start_line) or ("#L" .. start_line .. "-L" .. end_line)
  copy_to_clipboard("@" .. get_git_relative_path(abs_path) .. line_anchor)
  vim.api.nvim_feedkeys(vim.keycode("<Esc>"), "nx", false)
end

-- Full absolute path
vim.keymap.set("n", "<leader>fpa", function()
  local path = vim.fn.expand("%:p")
  copy_to_clipboard(path)
end, { desc = "Copy full absolute path" })

-- Full relative path (relative to git root)
vim.keymap.set("n", "<leader>fpr", function()
  local abs_path = vim.fn.expand("%:p")
  copy_to_clipboard(get_git_relative_path(abs_path))
end, { desc = "Copy path relative to git root" })

-- Just filename
vim.keymap.set("n", "<leader>fpf", function()
  local filename = vim.fn.expand("%:t")
  copy_to_clipboard(filename)
end, { desc = "Copy filename only" })

vim.keymap.set("x", "<leader>cl", copy_visual_file_reference, { desc = "Copy Copilot line reference" })

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
