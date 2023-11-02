local M = {}
  function M.setup(categories)
    -- local colorschemer = "catppuccin"
    local colorschemer = 'onedark'
    vim.cmd.colorscheme(colorschemer)

    if(categories.ghmarkdown or categories.markdown) then
      require('myLuaConf.birdee.markdown').setup(categories)
    end
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


    require'marks'.setup {
      -- whether to map keybinds or not. default true
      -- default_mappings = true,
      -- which builtin marks to show. default {}
      builtin_marks = {},
      -- whether movements cycle back to the beginning/end of buffer. default true
      cyclic = true,
      -- whether the shada file is updated after modifying uppercase marks. default false
      force_write_shada = false,
      -- how often (in ms) to redraw signs/recompute mark positions. 
      -- higher values will have better performance but may cause visual lag, 
      -- while lower values may cause performance penalties. default 150.
      refresh_interval = 250,
      -- sign priorities for each type of mark - builtin marks, uppercase marks, lowercase
      -- marks, and bookmarks.
      -- can be either a table with all/none of the keys, or a single number, in which case
      -- the priority applies to all marks.
      -- default 10.
      sign_priority = { lower=10, upper=15, builtin=8, bookmark=20 },
      -- disables mark tracking for specific filetypes. default {}
      excluded_filetypes = {},
      -- marks.nvim allows you to configure up to 10 bookmark groups, each with its own
      -- sign/virttext. Bookmarks can be used to group together positions and quickly move
      -- across multiple buffers. default sign is '!@#$%^&*()' (from 0 to 9), and
      -- default virt_text is "".
      bookmark_0 = {
        sign = "⚑",
        virt_text = "hello world",
        -- explicitly prompt for a virtual line annotation when setting a bookmark from this group.
        -- defaults to false.
        annotate = false,
      },
      mappings = {}
    }

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
        vim.keymap.set('n', '<leader>gp', require('gitsigns').preview_hunk, { buffer = bufnr, desc = 'Preview git hunk' })

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
  end
return M
