local M = {}
  function M.setup(categories)
    -- local colorschemer = "catppuccin"
    local colorschemer = 'onedark'
    vim.cmd.colorscheme(colorschemer)

    -- Enable telescope fzf native, if installed
    pcall(require('telescope').load_extension, 'fzf')
    -- [[ Configure Telescope ]]
    -- See `:help telescope` and `:help telescope.setup()`
    require('telescope').setup {
      defaults = {
        mappings = {
          i = {
            ['<C-u>'] = false,
            ['<C-d>'] = false,
          },
        },
      },
    }

    require('myLuaConf.birdee.nestsitter')
    require('gitsigns').setup({
        -- See `:help gitsigns.txt`
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
      },
      on_attach = function(bufnr)
        vim.keymap.set('n', '<leader>hp', require('gitsigns').preview_hunk, { buffer = bufnr, desc = 'Preview git hunk' })

        -- don't override the built-in and fugitive keymaps
        local gs = package.loaded.gitsigns
        vim.keymap.set({ 'n', 'v' }, ']c', function()
          if vim.wo.diff then return ']c' end
          vim.schedule(function() gs.next_hunk() end)
          return '<Ignore>'
        end, { expr = true, buffer = bufnr, desc = "Jump to next hunk" })
        vim.keymap.set({ 'n', 'v' }, '[c', function()
          if vim.wo.diff then return '[c' end
          vim.schedule(function() gs.prev_hunk() end)
          return '<Ignore>'
        end, { expr = true, buffer = bufnr, desc = "Jump to previous hunk" })
      end,
    })
    vim.cmd([[hi GitSignsAdd guifg=#04de21]])
    vim.cmd([[hi GitSignsChange guifg=#83fce6]])
    vim.cmd([[hi GitSignsDelete guifg=#fa2525]])
    vim.g.mkdp_auto_close = 0
    -- vim.g.mkdp_browser = 'firefox'
    vim.api.nvim_set_keymap('n', '<leader>mp', '<Plug>MarkdownPreviewToggle', {})
    -- Highlights unique characters for f/F and t/T motions
    require('eyeliner').setup {
      highlight_on_key = true, -- show highlights only after key press
      dim = true, -- dim all other characters
    }
    require('which-key').setup()
    require('Comment').setup()
      -- require('fidget').setup()
    require('lualine').setup({
      options = {
        icons_enabled = false,
        theme = tostring(colorschemer),
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
    require('hlargs').setup({
      color = '#32a88f',
    })
    require('nvim-surround').setup()

    require('harpoon').setup()
    vim.keymap.set('n', '<leader>hh', [[:lua require("harpoon.ui").toggle_quick_menu()<CR>]], { noremap = true, silent = true, desc = 'open harpoon menu' })
    vim.keymap.set('n', '<leader>hm', [[:lua require("harpoon.mark").add_file()<CR>]], { noremap = true, silent = true, desc = 'add file to harpoon' })
    vim.keymap.set('n', '<leader>hb', [[:lua require("harpoon.ui").nav_prev()<CR>]], { noremap = true, silent = true, desc = 'open prev harpoon' })
    vim.keymap.set('n', '<leader>hn', [[:lua require("harpoon.ui").nav_next()<CR>]], { noremap = true, silent = true, desc = 'open next harpoon' })

    require("ibl").setup()
    if(categories.AI) then
      require("sg").setup({
        on_attach = require('myLuaConf.caps-onattach').on_attach,
      })
      vim.keymap.set('n', '<leader>ss', require('sg.extensions.telescope').fuzzy_search_results, { noremap = true, desc = 'sourcegraph search' })
      vim.keymap.set('n', '<leader>sc', [[<cmd>CodyToggle<CR>]], { noremap = true, desc = 'CodyChat' })
      vim.keymap.set('v', '<leader>sc', [[:CodyAsk ]], { noremap = true, desc = 'CodyAsk' })
    end
    require('myLuaConf.birdee.completion').setup(categories)

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
