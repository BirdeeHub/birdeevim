-- TODO: make this into a keybind with operator pending to select text to surround with,
-- like vim-surrounds but for visual selection instead of motion
-- vim.keymap.set({'v', 'x'}, "<leader>s", [[:'<,'>s/\%V\(.*\)\%V/<before-text>\1<after-text>/]], { desc = 'Replace inside selection with text' })


-- dont worry about it.... it saved me some time in the end
  -- vim.keymap.set({ 'v', 'x' }, '<leader>Fp',
  --   [["ad:let @a = substitute(@a, '\\(favicon-.\\{-}\\)\\(\\.com\\|\\.org\\|\\.net\\|\\.edu\\|\\.gov\\|\\.mil\\|\\.int\\|\\.io\\|\\.co\\|\\.ai\\|\\.ly\\|\\.me\\|\\.tv\\|\\.info\\|\\.co\\.uk\\|\\.de\\|\\.jp\\|\\.cn\\|\\.au\\|\\.fr\\|\\.it\\|\\.es\\|\\.br\\|\\.gay\\)', 'https:\/\/', 'g')<CR>dd:while substitute(@a, '\\(https:\\/\\/.\\{-}\\) > ', '\\1\/', 'g') != @a | let @a = substitute(@a, '\\(https:\\/\\/.\\{-}\\) > ', '\\1\/', 'g') | endwhile<CR>"ap]],
  --   { desc = 'fix the links in copies from phind' })

  -- {
  --   "indent-blankline.nvim",
  --   event = "DeferredUIEnter",
  --   after = function(plugin)
  --     require("ibl").setup()
  --   end,
  -- },


-- local ok, notify = pcall(require, "notify")
-- if ok then
--   notify.setup({
--     on_open = function(win)
--       vim.api.nvim_win_set_config(win, { focusable = false })
--     end,
--   })
--   vim.notify = notify
--   vim.keymap.set("n", "<Esc>", function()
--       notify.dismiss({ silent = true, })
--   end, { desc = "dismiss notify popup and clear hlsearch" })
-- end


local function tbl_get(t, ...)
  if #{...} == 0 then return nil end
  for _, key in ipairs({...}) do
	if type(t) ~= "table" then return nil end
	t = t[key]
  end
  return t
end

-- so, my normal mode <leader>y randomly didnt accept motions.
-- If that ever happens to you, comment out the normal one for normal mode, then uncomment this keymap and the function below it.
-- A full purge of all previous config files installed via pacman fixed it for me, as the pacman config was the one that had that problem.
-- I thought I was cool, but apparently I was doing a workaround to restore default behavior.

-- vim.keymap.set("n", '<leader>y', [[:set opfunc=Yank_to_clipboard<CR>g@]], { silent = true, desc = 'Yank to clipboard (accepts motions)' })
-- vim.cmd([[
--   function! Yank_to_clipboard(type)
--     silent exec 'normal! `[v`]"+y'
--   endfunction
--   " nmap <silent> <leader>y :set opfunc=Yank_to_clipboard<CR>g@
-- ]])

--silent exec 'let @/=@"' " <- this sets search register to contents of unnamed?


-- doesnt fire the TextYankPost event, and it needed a workaround to make vim.hl.on_yank() work correctly
-- this is a yank to clipboard that doesnt overwrite the unnamed register
_G.Yank_to_clipboard = function(stype)
  local regtype = ({ char = "v", line = "V", block = "\22" })[stype]
  if not regtype then return end
  local region = vim.fn.getregion(vim.fn.getpos("'["), vim.fn.getpos("']"), {
    type = regtype,
    exclusive = false,
    eol = true,
  })
  vim.fn.setreg("+", table.concat(region, "\n"), regtype)
  vim.hl.on_yank {
    event = {
      regname = "+",
      operator = "y",
      regtype = regtype,
    },
  }
end
vim.keymap.set({ "n", "v", "x" }, '<leader>y', function()
  vim.go.operatorfunc = "v:lua.Yank_to_clipboard"
  return "g@"
end, {
  expr = true,
  silent = true,
  desc = 'Yank to clipboard (accepts motions)',
})
local line_yank = function ()
  local start_line = vim.api.nvim_win_get_cursor(0)[1]
  local count = vim.v.count1
  local end_line = start_line + count - 1
  local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
  local ok, endcol = pcall(function() return #lines[#lines] end)
  if not ok then endcol = 99999 end
  vim.fn.setreg("+", table.concat(lines, "\n"), "V") -- linewise register
  vim.fn.setpos("'[", { 0, start_line, 1, 0 })
  vim.fn.setpos("']", { 0, end_line, endcol, 0 })
  vim.hl.on_yank {
    event = {
      regname = "+",
      operator = "y",
      regtype = "V",
    },
  }
end
vim.keymap.set({ "n", "v", "x" }, '<leader>yy', line_yank, { silent = true, desc = 'Yank current line to clipboard', })
vim.keymap.set({ "n", "v", "x" }, '<leader>Y', line_yank, { silent = true, desc = 'Yank current line to clipboard', })
