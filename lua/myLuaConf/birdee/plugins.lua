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
  -- require('nvim-treesitter.configs').setup {
  --   --parser_install_dir = absolute_path,
  --   -- Add languages to be installed here that you want installed for treesitter
  --   ensure_installed = { 'c', 'cpp', 'go', 'lua', 'python', 'rust', 'tsx', 'javascript', 'typescript', 'vimdoc', 'vim' },
  --
  --   -- Autoinstall languages that are not installed. Defaults to false (but you can change for yourself!)
  --   auto_install = true,
  --
  --   highlight = {
  --     enable = true,
  --     -- additional_vim_regex_highlighting = { "kotlin" },
  --   },
  --   indent = { enable = false },
  --   incremental_selection = {
  --     enable = true,
  --     keymaps = {
  --       init_selection = '<c-space>',
  --       node_incremental = '<c-space>',
  --       scope_incremental = '<c-s>',
  --       node_decremental = '<M-space>',
  --     },
  --   },
  --   textobjects = {
  --     select = {
  --       enable = true,
  --       lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
  --       keymaps = {
  --         -- You can use the capture groups defined in textobjects.scm
  --         ['aa'] = '@parameter.outer',
  --         ['ia'] = '@parameter.inner',
  --         ['af'] = '@function.outer',
  --         ['if'] = '@function.inner',
  --         ['ac'] = '@class.outer',
  --         ['ic'] = '@class.inner',
  --       },
  --     },
  --     move = {
  --       enable = true,
  --       set_jumps = true, -- whether to set jumps in the jumplist
  --       goto_next_start = {
  --         [']m'] = '@function.outer',
  --         [']]'] = '@class.outer',
  --       },
  --       goto_next_end = {
  --         [']M'] = '@function.outer',
  --         [']['] = '@class.outer',
  --       },
  --       goto_previous_start = {
  --         ['[m'] = '@function.outer',
  --         ['[['] = '@class.outer',
  --       },
  --       goto_previous_end = {
  --         ['[M'] = '@function.outer',
  --         ['[]'] = '@class.outer',
  --       },
  --     },
  --     swap = {
  --       enable = true,
  --       swap_next = {
  --         ['<leader>a'] = '@parameter.inner',
  --       },
  --       swap_previous = {
  --         ['<leader>A'] = '@parameter.inner',
  --       },
  --     },
  --   },
  -- }
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
  require('lualine').setup({
    options = {
      icons_enabled = false,
      -- theme = 'tokyonight',
      theme = 'catppuccin',
      component_separators = '|',
      section_separators = '',
    },
    sections = {
      lualine_c = {
        {
          'filename', path = 1, status = true,
          'lsp_progress',
        },
      },
    },
  })
  require('hlargs').setup({
    color = '#32a88f',
  })
  require('nvim-surround').setup()
  require('harpoon').setup()
  require("ibl").setup()

  -- [[ Configure nvim-cmp ]]
  -- See `:help cmp`
  local cmp = require 'cmp'
  local luasnip = require 'luasnip'
  require('luasnip.loaders.from_vscode').lazy_load()
  luasnip.config.setup {}

  cmp.setup {
    snippet = {
      expand = function(args)
        luasnip.lsp_expand(args.body)
      end,
    },
    mapping = cmp.mapping.preset.insert {
      ['<C-p>'] = cmp.mapping.scroll_docs(-4),
      ['<C-n>'] = cmp.mapping.scroll_docs(4),
      ['<C-Space>'] = cmp.mapping.complete {},
      ['<CR>'] = cmp.mapping.confirm {
        behavior = cmp.ConfirmBehavior.Replace,
        select = true,
      },
      ['<Tab>'] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_next_item()
        elseif luasnip.expand_or_locally_jumpable() then
          luasnip.expand_or_jump()
        else
          fallback()
        end
      end, { 'i', 's' }),
      ['<S-Tab>'] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_prev_item()
        elseif luasnip.locally_jumpable(-1) then
          luasnip.jump(-1)
        else
          fallback()
        end
      end, { 'i', 's' }),
    },
    sources = {
      -- { name = "cody" },
      -- { name = 'cmp_tabnine' },
      -- { name = "codeium" },
      { name = 'nvim_lsp' },
      { name = 'luasnip' },
      { name = 'path' },
      { name = 'buffer' },
    },
  }
  cmp.setup.cmdline('/', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
      { name = 'buffer' },
    },
  })
  cmp.setup.cmdline(':', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({
      { name = 'path' },
    }, {
      {
        name = 'cmdline',
        option = {
          ignore_cmds = { 'Man', '!' },
        },
      },
    })
  })
  -- require('markdown-preview').config = function()
  --   vim.fn['mkdp#util#install']()
  --   vim.g.mkdp_auto_close = 0
  --   vim.api.nvim_set_keymap('n', '<leader>mp', '<Plug>MarkdownPreviewToggle', {})
  -- end

