local M = {}
  function M.setup(serverlist)
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
    require("ibl").setup()
    if(serverlist.AI == true) then
      require("sg").setup({
        on_attach = require('myLuaConf.caps-onattach').on_attach,
      })
      vim.keymap.set('n', '<leader>ss', require('sg.extensions.telescope').fuzzy_search_results, { noremap = true, desc = 'sourcegraph search' })
      vim.keymap.set('n', '<leader>sc', [[<cmd>CodyToggle<CR>]], { noremap = true, desc = 'CodyChat' })
      vim.keymap.set('v', '<leader>sc', [[:CodyAsk ]], { noremap = true, desc = 'CodyAsk' })
    end
    require('myLuaConf.birdee.completion').setup(serverlist)
  end
return M
