local categories = require('nixCats')
local colorschemer = categories.colorscheme-- also schemes lualine
local hlargsColor =  '#32a88f' -- if this doesnt work for new theme, change it here
if colorschemer ~= "" then
  vim.cmd.colorscheme(colorschemer)
end

require('birdee.plugins.telescope')

require('birdee.plugins.nestsitter')

require('birdee.plugins.completion')

if(categories.markdown) then
  vim.g.mkdp_auto_close = 0
  vim.keymap.set('n','<leader>mp','<cmd>MarkdownPreview <CR>',{ noremap = true, desc = 'markdown preview' })
  vim.keymap.set('n','<leader>ms','<cmd>MarkdownPreviewStop <CR>',{ noremap = true, desc = 'markdown preview stop' })
  vim.keymap.set('n','<leader>mt','<cmd>MarkdownPreviewToggle <CR>',{ noremap = true, desc = 'markdown preview toggle' })
end

require('birdee.plugins.gutter')


vim.keymap.set('n', '<leader>U', vim.cmd.UndotreeToggle, { desc = "Undo Tree" })
vim.g.undotree_WindowLayout = 1
vim.g.undotree_SplitWidth = 40

-- Highlights unique characters for f/F and t/T motions
require('eyeliner').setup {
  highlight_on_key = true, -- show highlights only after key press
  dim = true, -- dim all other characters
}
require('hlargs').setup({
  color = hlargsColor,
})
require('Comment').setup()
  -- require('fidget').setup()
require('lualine').setup({
  options = {
    icons_enabled = false,
    theme = colorschemer,
    component_separators = '|',
    section_separators = '',
  },
  sections = {
    lualine_c = {
      {
        'filename', path = 1, status = true,
      },
      -- 'lsp_progress',
    },
  },
})
require('fidget').setup({})
require('nvim-surround').setup()

require('harpoon').setup()
vim.keymap.set('n', '<leader>hh', [[:lua require("harpoon.ui").toggle_quick_menu()<CR>]], { noremap = true, silent = true, desc = 'open harpoon menu' })
vim.keymap.set('n', '<leader>hm', [[:lua require("harpoon.mark").add_file()<CR>]], { noremap = true, silent = true, desc = 'add file to harpoon' })
vim.keymap.set('n', '<leader>hb', [[:lua require("harpoon.ui").nav_prev()<CR>]], { noremap = true, silent = true, desc = 'open prev harpoon' })
vim.keymap.set('n', '<leader>hn', [[:lua require("harpoon.ui").nav_next()<CR>]], { noremap = true, silent = true, desc = 'open next harpoon' })

require("ibl").setup()

-- I honestly only use this to see the little git icons. 
-- I wanna figure out how to add them to netrw instead and ditch this
require('neo-tree').setup({
  close_if_last_window = true,
  window = {
    position = "float",
    mappings = {
      ["<space>"] = {
        nowait = false, -- disable `nowait` if you have existing combos starting with this char that you want to use 
        noremap = false,
      },
    },
  },
  filesystem = {
    filtered_items = {
      visible = true,
      hide_dotfiles = true,
      hide_gitignored = true,
      hide_hidden = true,
    },
    hijack_netrw_behavior = "disabled",
  },
  buffers = {
    follow_current_file = {
      enabled = true,
    },
  },
})
vim.keymap.set("n", "<leader>FT", "<cmd>Neotree toggle<CR>", { noremap = true, desc = '[F]ile [T]ree' })

local leaderCmsg
if categories.AI then
  leaderCmsg = "[C]ode (and [C]ody)"
else
  leaderCmsg = "[C]ode"
end

require('which-key').setup()
require('which-key').register {
  ['<leader>c'] = { name = leaderCmsg, _ = 'which_key_ignore' },
  ['<leader>d'] = { name = '[D]ocument', _ = 'which_key_ignore' },
  ['<leader>g'] = { name = '[G]it', _ = 'which_key_ignore' },
  ['<leader>r'] = { name = '[R]ename', _ = 'which_key_ignore' },
  ['<leader>s'] = { name = '[S]earch', _ = 'which_key_ignore' },
  ['<leader>w'] = { name = '[W]orkspace', _ = 'which_key_ignore' },
  ['<leader>m'] = { name = '[M]arkdown', _ = 'which_key_ignore' },
  ['<leader>F'] = { name = '[F]ile or [F]ormat', _ = 'which_key_ignore' },
  ['<leader>h'] = { name = '[H]arpoon', _ = 'which_key_ignore' },
}
