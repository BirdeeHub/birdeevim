local M = {}
function M.setup(categories)
  -- local colorschemer = "catppuccin"
  local colorschemer = 'onedark'
  vim.cmd.colorscheme(colorschemer) -- also schemes lualine
  local hlargsColor =  '#32a88f'

  if(categories.telescope) then
    require('myLuaConf.birdee.plugins.telescope').setup(categories)
  end
  if(categories.treesitter) then
    require('myLuaConf.birdee.plugins.nestsitter').setup(categories)
  end
  if(categories.AI) then
    require("sg").setup({
      on_attach = require('myLuaConf.caps-onattach').on_attach,
    })
    vim.keymap.set('n', '<leader>cs', require('sg.extensions.telescope').fuzzy_search_results, { noremap = true, desc = 'sourcegraph search' })
    vim.keymap.set('n', '<leader>cc', [[<cmd>CodyToggle<CR>]], { noremap = true, desc = 'CodyChat' })
    vim.keymap.set('v', '<leader>cc', [[:CodyAsk ]], { noremap = true, desc = 'CodyAsk' })
  end
  if(categories.cmp) then
    require('myLuaConf.birdee.plugins.completion').setup(categories)
  end
  if(categories.markdown) then
    vim.g.mkdp_auto_close = 0
    vim.keymap.set('n','<leader>mp','<cmd>MarkdownPreview <CR>',{ noremap = true, desc = 'markdown preview' })
    vim.keymap.set('n','<leader>ms','<cmd>MarkdownPreviewStop <CR>',{ noremap = true, desc = 'markdown preview stop' })
    vim.keymap.set('n','<leader>mt','<cmd>MarkdownPreviewToggle <CR>',{ noremap = true, desc = 'markdown preview toggle' })
  end

  require('myLuaConf.birdee.plugins.gutter').setup(categories)


  vim.keymap.set('n', '<leader>U', vim.cmd.UndotreeToggle, { desc = "Undo Tree" })
  vim.g.undotree_WindowLayout = 4
  -- Highlights unique characters for f/F and t/T motions
  require('eyeliner').setup {
    highlight_on_key = true, -- show highlights only after key press
    dim = true, -- dim all other characters
  }
  require('hlargs').setup({
    color = hlargsColor,
  })
  require('which-key').setup()
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
        'lsp_progress',
      },
    },
  })
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


end
return M
