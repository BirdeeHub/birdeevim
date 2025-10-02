-- [[ Basic Keymaps ]]
-- inoremap <silent> <F1> <C-o>
vim.keymap.set("i", "<F1>", "<C-o>", { noremap = true, silent = true, desc = "Temp normal (same as insert mode <c-o>)" })

-- Keymaps for better default experience
-- See `:help vim.keymap.set()`
vim.api.nvim_set_keymap('', '<M-h>', '<Esc>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('t', '<M-h>', '<C-\\><C-n>', { noremap = true, silent = true, desc = "escape terminal mode" })
-- vim.keymap.set("n", , ":m .+1<CR>==", { desc = 'Moves Line Down' })
-- vim.keymap.set("n", , ":m .-2<CR>==", { desc = 'Moves Line Up' })
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = 'Moves Line Down' })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = 'Moves Line Up' })
-- vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = 'Scroll Down' })
-- vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = 'Scroll Up' })
vim.keymap.set("n", "n", "nzzzv", { desc = 'Next Search Result' })
vim.keymap.set("n", "N", "Nzzzv", { desc = 'Previous Search Result' })

vim.keymap.set("n", "<leader><leader>[", "<cmd>bprev<CR>", { desc = 'Previous buffer' })
vim.keymap.set("n", "<leader><leader>]", "<cmd>bnext<CR>", { desc = 'Next buffer' })
vim.keymap.set("n", "<leader><leader>l", "<cmd>b#<CR>", { desc = 'Last buffer' })
vim.keymap.set("n", "<leader><leader>d", "<cmd>bdelete<CR>", { desc = 'delete buffer' })
vim.keymap.set("n", "<leader><leader>r", function()
  local n = vim.v.count
  if pcall(vim.cmd.buffer, n > 0 and n or "#") then
    vim.cmd.bdelete("#")
  end
end, { desc = "Replace buffer (with count or #)" })
vim.keymap.set('n', '<leader><leader>g', function()
  local n = vim.v.count
  vim.cmd.buffer(n > 0 and n or "#")
end, { noremap = true, silent = true, desc = 'Go to buffer by number [num]<keybind>', })

vim.keymap.set("v", "<", "<gv", { desc = 'Indent left and reselect' })
vim.keymap.set("v", ">", ">gv", { desc = 'Indent right and reselect' })

-- see help sticky keys on windows
vim.cmd([[command! W w]])
vim.cmd([[command! Wq wq]])
vim.cmd([[command! WQ wq]])
vim.cmd([[command! Q q]])

vim.keymap.set("n", "<leader>:", ":<C-f>", { desc = 'cli buffer' })

-- Remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Netrw
-- vim.keymap.set("n", "<leader>FF", "<cmd>Explore<CR>", { noremap = true, desc = '[F]ile[F]inder' })
-- vim.keymap.set("n", "<leader>Fh", "<cmd>e .<CR>", { noremap = true, desc = '[F]ile[h]ome' })

-- Diagnostic keymaps
-- vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous diagnostic message' }) -- now included by default
-- vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next diagnostic message' }) -- now included by default
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Open floating diagnostic message' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostics list' })

local current_virt_lines_value = false
vim.diagnostic.config {
  virtual_text = not current_virt_lines_value,
  virtual_lines = current_virt_lines_value,
}
vim.keymap.set('n', '<leader>tv', function()
  current_virt_lines_value = not current_virt_lines_value
  vim.diagnostic.config {
    virtual_text = not current_virt_lines_value,
    virtual_lines = current_virt_lines_value,
  }
end, { desc = 'Toggle virtual lines' })


vim.keymap.set('n', '<leader>lh', function () vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled()) end, { desc = 'Toggle inlay hints' })

--TODO: get this to ask you your sudo password
vim.api.nvim_create_user_command('Swq', function(args)
    vim.cmd([[w !sudo tee %]])
end, {})

-- kickstart.nvim starts you with this.
-- But it constantly clobbers your system clipboard whenever you delete anything.

-- Sync clipboard between OS and Neovim.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
-- vim.o.clipboard = 'unnamedplus'

vim.keymap.set({ "n", "v", "x" }, '<leader>y', '"+y', { noremap = true, silent = true, desc = 'Yank to clipboard' })
vim.keymap.set({ "n", "v", "x" }, '<leader>Y', '"+yy', { noremap = true, silent = true, desc = 'Yank line to clipboard' })
vim.keymap.set({ "n" }, 'v<C-a>', 'gg0vG$', { noremap = true, silent = true, desc = 'Select all' })
vim.keymap.set({ "n", "v", "x" }, '<leader>p', '"+p', { noremap = true, silent = true, desc = 'Paste from clipboard' })
vim.keymap.set('i', '<C-p>', '<C-r><C-p>+',
  { noremap = true, silent = true, desc = 'Paste from clipboard from within insert mode' })
-- vim.keymap.set("x", "<leader>P", '"_dP', { noremap = true, silent = true, desc = 'Paste over selection without erasing unnamed register' })
