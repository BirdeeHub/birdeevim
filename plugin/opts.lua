if os.getenv('WAYLAND_DISPLAY') and vim.fn.exepath('wl-copy') ~= "" then
  vim.g.clipboard = {
      name = 'wl-clipboard',
      copy = {
          ['+'] = 'wl-copy',
          ['*'] = 'wl-copy',
      },
      paste = {
          ['+'] = 'wl-paste',
          ['*'] = 'wl-paste',
      },
      cache_enabled = 1,
  }
end
vim.filetype.add {
  extension = {
    templ = "templ",
    tmpl = "templ",
    ebnf = "EBNF",
    bnf = "EBNF",
    EBNF = "EBNF",
    nvim = "lua",
  }
}

-- [[ Setting options ]]
-- See `:help vim.o`

-- vim.opt.list = true
-- vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
-- vim.opt.listchars:append("space:⋅")
-- Set highlight on search
vim.opt.hlsearch = false
-- vim.opt.hlsearch = true
-- vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Preview substitutions live, as you type!
vim.opt.inccommand = 'split'

-- Minimal number of screen lines to keep above and below the cursor.
vim.opt.scrolloff = 3

-- Make line numbers default
vim.wo.number = true

-- Enable mouse mode
vim.o.mouse = 'a'

-- Indent
vim.o.smarttab = true
-- vim.o.smartindent = true
-- vim.o.indentexpr = true
vim.o.autoindent = true
vim.opt.cpoptions:append('I')
vim.o.tabstop = 4
vim.o.softtabstop = 4
vim.o.shiftwidth = 4
vim.o.expandtab = true

-- stops line wrapping from being confusing
vim.o.wrap = true
vim.o.linebreak = true
vim.o.breakindent = true

-- Save undo history
vim.o.undofile = true

-- Case-insensitive searching UNLESS \C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true

-- Keep signcolumn on by default
vim.wo.signcolumn = 'yes'
vim.wo.relativenumber = true
vim.opt.lazyredraw = true

-- Decrease update time
vim.o.updatetime = 250
vim.o.timeoutlen = 300

-- Set completeopt to have a better completion experience
vim.o.completeopt = 'menu,preview,noselect'

-- NOTE: You should make sure your terminal supports this
vim.o.termguicolors = true

-- how to remove e37 and e162 errors, which force you to force quit if you don't want to save changes
vim.opt.confirm = true

-- remove empty buffer text
vim.opt.shortmess:append("I")

vim.g.netrw_liststyle = 0
vim.g.netrw_banner = 0

-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.hl.on_yank()
  end,
  group = highlight_group,
  pattern = '*',
})

local augroup = vim.api.nvim_create_augroup("UserConfig", {})

-- [[ Disable auto comment on enter ]]
-- See :help formatoptions
vim.api.nvim_create_autocmd("FileType", {
  desc = "remove formatoptions",
  group = augroup,
  callback = function()
    vim.opt.formatoptions:remove({ "c", "r", "o" })
  end,
})

vim.api.nvim_create_autocmd('FileType', {
  group = augroup,
  pattern = 'help',
  callback = function()
    vim.bo.bufhidden = 'unload'
    vim.cmd.wincmd('L')
  end,
})

-- -- Create directories when saving files
-- vim.api.nvim_create_autocmd("BufWritePre", {
--   group = augroup,
--   callback = function()
--     local dir = vim.fn.expand('<afile>:p:h')
--     if vim.fn.isdirectory(dir) == 0 then
--       vim.fn.mkdir(dir, 'p')
--     end
--   end,
-- })
