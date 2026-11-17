return {
  "kevinhwang91/nvim-ufo",
  dependencies = { "kevinhwang91/promise-async" },
  event = { "BufReadPost", "BufNewFile" },
  config = function()
    vim.o.foldcolumn = "0"
    vim.o.foldlevel = 99
    vim.o.foldlevelstart = 99
    vim.o.foldenable = true

    require("ufo").setup({
      provider_selector = function()
        return { "lsp", "indent" }
      end,

      close_fold_kinds_for_ft = {
        default = {},
      },
      close_fold_current_line_for_ft = {
        default = false,
      },

      fold_virt_text_handler = function(virtText, lnum, endLnum, width, truncate)
        local newVirtText = {}
        local line_count = endLnum - lnum + 1

        for _, chunk in ipairs(virtText) do
          table.insert(newVirtText, chunk)
        end

        if line_count > 1 then
          table.insert(newVirtText, { "  ~[" .. line_count .. "]", "Comment" })
        end

        local totalWidth = 0
        for i, chunk in ipairs(newVirtText) do
          totalWidth = totalWidth + vim.fn.strdisplaywidth(chunk[1])
          if totalWidth > width then
            chunk[1] = truncate(chunk[1], width - (totalWidth - vim.fn.strdisplaywidth(chunk[1])))
            for j = i + 1, #newVirtText do
              newVirtText[j][1] = ""
            end
            break
          end
        end

        return newVirtText
      end,

      open_fold_hl_timeout = 0,

      -- Configure hover preview
      preview = {
        win_config = {
          border = "rounded",
          winblend = 12,
          winhighlight = "Normal:Normal",
        },
        mappings = {
          scrollU = "<C-u>",
          scrollD = "<C-d>",
        },
      },
    })

    vim.keymap.set("n", "zR", require("ufo").openAllFolds)
    vim.keymap.set("n", "zM", require("ufo").closeAllFolds)

    vim.keymap.set("n", "K", function()
      local winid = require("ufo").peekFoldedLinesUnderCursor()
      if not winid then
        -- fallback to normal LSP hover
        vim.lsp.buf.hover()
      else
        -- adjust window height to match fold size (up to maxheight)
        local bufnr = vim.api.nvim_win_get_buf(winid)
        local cursor = vim.api.nvim_win_get_cursor(0)
        local lnum = cursor[1]

        -- get the fold start and end
        local fold_start = vim.fn.foldclosed(lnum)
        local fold_end = vim.fn.foldclosedend(lnum)
        if fold_start ~= -1 and fold_end ~= -1 then
          local fold_lines = fold_end - fold_start + 1
          local new_height = math.min(fold_lines, 20) -- 20 = max height
          vim.api.nvim_win_set_height(winid, new_height)
        end
      end
    end)
    -- vim.keymap.set("n", "K", function()
    --   local winid = require("ufo").peekFoldedLinesUnderCursor()
    --   if not winid then
    --     vim.lsp.buf.hover()
    --   end
    -- end)
  end,
}
