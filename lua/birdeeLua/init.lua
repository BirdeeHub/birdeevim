local birdeeLua = {}
                   
  --[[ 
          KEYMAPS          KEYMAPS       KEYMAPS          KEYMAPS       KEYMAPS
          KEYMAPS          KEYMAPS       KEYMAPS          KEYMAPS       KEYMAPS
          KEYMAPS          KEYMAPS       KEYMAPS          KEYMAPS       KEYMAPS
          KEYMAPS          KEYMAPS       KEYMAPS          KEYMAPS       KEYMAPS
          KEYMAPS          KEYMAPS       KEYMAPS          KEYMAPS       KEYMAPS
  ]]
                   
function birdeeLua.keymaps()

  vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = 'Moves Line Down' })
  vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = 'Moves Line Up' })
  vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = 'Scroll Down' })
  vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = 'Scroll Up' })
  vim.keymap.set("n", "n", "nzzzv", { desc = 'Next Search Result' })
  vim.keymap.set("n", "N", "Nzzzv", { desc = 'Previous Search Result' })
  vim.keymap.set({"n", "v", "x"}, '<leader>y', '"+y', { noremap = true, silent = true, desc = 'Yank to clipboard' })
  vim.keymap.set({"n", "v", "x"}, '<leader>yy', '"+yy', { noremap = true, silent = true, desc = 'Yank line to clipboard' })
  vim.keymap.set('n', '<leader>p', '"+p', { noremap = true, silent = true, desc = 'Paste from clipboard' })
  vim.keymap.set("x", "<leader>P", '"_dP', { desc = 'Paste from Selection' })
  vim.cmd([[command! W w]])
  vim.cmd([[command! Wq wq]])
  vim.cmd([[command! WQ wq]])
  vim.cmd([[command! Q q]])

  -- See `:help telescope.builtin`
  vim.keymap.set('n', '<leader>?', require('telescope.builtin').oldfiles, { desc = '[?] Find recently opened files' })
  vim.keymap.set('n', '<leader><space>', require('telescope.builtin').buffers, { desc = '[ ] Find existing buffers' })
  vim.keymap.set('n', '<leader>/', function()
    -- You can pass additional configuration to telescope to change theme, layout, etc.
    require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
      winblend = 10,
      previewer = false,
    })
  end, { desc = '[/] Fuzzily search in current buffer' })

  vim.keymap.set('n', '<C-W>', '<c-w>', { desc = '+window'})
  vim.keymap.set({"n", "v", "x"}, '"', '"', { desc = '+registers'})

  vim.keymap.set('n', '<leader>hg', require('telescope.builtin').git_files, { desc = 'Searc[h] [g]it' })
  vim.keymap.set('n', '<leader>sf', require('telescope.builtin').find_files, { desc = '[S]earch [F]iles' })
  vim.keymap.set('n', '<leader>sh', require('telescope.builtin').help_tags, { desc = '[S]earch [H]elp' })
  vim.keymap.set('n', '<leader>sw', require('telescope.builtin').grep_string, { desc = '[S]earch current [W]ord' })
  vim.keymap.set('n', '<leader>sg', require('telescope.builtin').live_grep, { desc = '[S]earch by [G]rep' })
  vim.keymap.set('n', '<leader>sd', require('telescope.builtin').diagnostics, { desc = '[S]earch [D]iagnostics' })
  vim.keymap.set('n', '<leader>sr', require('telescope.builtin').resume, { desc = '[S]earch [R]resume' })

  -- Diagnostic keymaps
  vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous diagnostic message' })
  vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next diagnostic message' })
  vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Open floating diagnostic message' })
  vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostics list' })

  -- [[ Basic Keymaps ]]

  -- Keymaps for better default experience
  -- See `:help vim.keymap.set()`
  vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

  -- Remap for dealing with word wrap
  vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
  vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

  vim.keymap.set({'v', 'x'}, '<leader>Fp', [["ad:let @a = substitute(@a, '\\(favicon-.\\{-}\\)\\(\\.com\\|\\.org\\|\\.net\\|\\.edu\\|\\.gov\\|\\.mil\\|\\.int\\|\\.io\\|\\.co\\|\\.ai\\|\\.ly\\|\\.me\\|\\.tv\\|\\.info\\|\\.co\\.uk\\|\\.de\\|\\.jp\\|\\.cn\\|\\.au\\|\\.fr\\|\\.it\\|\\.es\\|\\.br\\|\\.gay\\)', 'https:\/\/', 'g')<CR>dd:while substitute(@a, '\\(https:\\/\\/.\\{-}\\) > ', '\\1\/', 'g') != @a | let @a = substitute(@a, '\\(https:\\/\\/.\\{-}\\) > ', '\\1\/', 'g') | endwhile<CR>"ap]], { desc = 'fix the links in copies from phind' })

  vim.keymap.set('n', '<leader>hh', [[:lua require("harpoon.ui").toggle_quick_menu()<CR>]], { noremap = true, silent = true, desc = 'open harpoon menu' })
  vim.keymap.set('n', '<leader>hm', [[:lua require("harpoon.mark").add_file()<CR>]], { noremap = true, silent = true, desc = 'add file to harpoon' })
  vim.keymap.set('n', '<leader>hb', [[:lua require("harpoon.ui").nav_prev()<CR>]], { noremap = true, silent = true, desc = 'open prev harpoon' })
  vim.keymap.set('n', '<leader>hn', [[:lua require("harpoon.ui").nav_next()<CR>]], { noremap = true, silent = true, desc = 'open next harpoon' })

  -- vim.keymap.set('n', '<leader>ss', require('sg.extensions.telescope').fuzzy_search_results, { noremap = true, desc = 'sourcegraph search' })
  -- vim.keymap.set('n', '<leader>sc', [[<cmd>CodyToggle<CR>]], { noremap = true, desc = 'CodyChat' })
  -- vim.keymap.set('v', '<leader>sc', [[:CodyAsk ]], { noremap = true, desc = 'CodyAsk' })

  vim.keymap.set("n", "<leader>FF", "<cmd>E<CR>", { noremap = true, desc = '[F]ile[F]inder' })
  vim.keymap.set("n", "<leader>Fh", "<cmd>e .<CR>", { noremap = true, desc = '[F]ile[h]ome' })
  -- vim.keymap.set("n", "<leader>Fc", require('conform').format, { noremap = true, desc = '[F]ormat ([c]onform.nvim)' })
  -- vim.keymap.set("n", "<leader>Fm", "<cmd>Format<CR>", { noremap = true, desc = '[F]or[m]at' })
  -- vim.keymap.set("n", "<leader>FT", "<cmd>Neotree toggle<CR>", { noremap = true, desc = '[F]ile [T]ree' })

end
                   
  --[[ 
          OPTIONS          OPTIONS       OPTIONS          OPTIONS       OPTIONS
          OPTIONS          OPTIONS       OPTIONS          OPTIONS       OPTIONS
          OPTIONS          OPTIONS       OPTIONS          OPTIONS       OPTIONS
          OPTIONS          OPTIONS       OPTIONS          OPTIONS       OPTIONS
          OPTIONS          OPTIONS       OPTIONS          OPTIONS       OPTIONS
  ]]
                   
function birdeeLua.opts()
-- [[ Setting options ]]
-- See `:help vim.o`
-- NOTE: You can change these options as you wish!
  vim.opt.list = true
  vim.opt.listchars:append("space:⋅")
  -- Set highlight on search
  vim.o.hlsearch = false

  -- Make line numbers default
  vim.wo.number = true

  -- Enable mouse mode
  vim.o.mouse = 'a'

  -- Indent
  vim.o.smarttab = true
  vim.o.smartindent = true
  vim.o.autoindent = true
  vim.o.cpoptions = 'I'

  -- Save undo history
  vim.o.undofile = true

  -- Case-insensitive searching UNLESS \C or capital in search
  vim.o.ignorecase = true
  vim.o.smartcase = true

  -- Keep signcolumn on by default
  vim.wo.signcolumn = 'yes'

  -- Decrease update time
  vim.o.updatetime = 250
  vim.o.timeoutlen = 300

  -- Set completeopt to have a better completion experience
  vim.o.completeopt = 'menu,preview,noselect'

  -- NOTE: You should make sure your terminal supports this
  vim.o.termguicolors = true

  -- [[ Disable auto comment on enter ]]
  -- See :help formatoptions
  vim.api.nvim_create_autocmd("FileType", {
    desc = "remove formatoptions",
    callback = function()
      vim.opt.formatoptions:remove({ "c", "r", "o" })
    end,
  })

  -- [[ Highlight on yank ]]
  -- See `:help vim.highlight.on_yank()`
  local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
  vim.api.nvim_create_autocmd('TextYankPost', {
    callback = function()
      vim.highlight.on_yank()
    end,
    group = highlight_group,
    pattern = '*',
  })

  vim.g.netrw_liststyle=0
  vim.g.netrw_banner=0
  vim.o.tabstop = 4
  vim.o.softtabstop = 4
  vim.o.shiftwidth = 4
  vim.o.expandtab = true
  vim.wo.relativenumber = true

  -- vim.cmd.colorscheme "onedark"
  vim.cmd([[hi LineNr guifg=#bb9af7]])
end
                   
  --[[ 
          PLUGINS          PLUGINS       PLUGINS          PLUGINS       PLUGINS
          PLUGINS          PLUGINS       PLUGINS          PLUGINS       PLUGINS
          PLUGINS          PLUGINS       PLUGINS          PLUGINS       PLUGINS
          PLUGINS          PLUGINS       PLUGINS          PLUGINS       PLUGINS
          PLUGINS          PLUGINS       PLUGINS          PLUGINS       PLUGINS
  ]]
                   

function birdeeLua.plugins()
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
end

                  
  --[[ 
          LSP ATTACH AND CAPS          LSP ATTACH AND CAPS       LSP ATTACH AND CAPS
          LSP ATTACH AND CAPS          LSP ATTACH AND CAPS       LSP ATTACH AND CAPS
          LSP ATTACH AND CAPS          LSP ATTACH AND CAPS       LSP ATTACH AND CAPS
          LSP ATTACH AND CAPS          LSP ATTACH AND CAPS       LSP ATTACH AND CAPS
          LSP ATTACH AND CAPS          LSP ATTACH AND CAPS       LSP ATTACH AND CAPS
  ]]
                   


function birdeeLua.on_attach(_, bufnr)
  -- NOTE: Remember that lua is a real programming language, and as such it is possible
  -- to define small helper and utility functions so you don't have to repeat yourself
  -- many times.
  -- In this case, we create a function that lets us more easily define mappings specific
  -- for LSP related items. It sets the mode, buffer and description for us each time.

  local nmap = function(keys, func, desc)
    if desc then
      desc = 'LSP: ' .. desc
    end

    vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
  end

  nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
  nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')

  nmap('gd', vim.lsp.buf.definition, '[G]oto [D]efinition')
  nmap('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
  nmap('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
  nmap('<leader>D', vim.lsp.buf.type_definition, 'Type [D]efinition')
  nmap('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
  nmap('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

  -- See `:help K` for why this keymap
  nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
  nmap('<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation')

  -- Lesser used LSP functionality
  nmap('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
  nmap('<leader>wa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd Folder')
  nmap('<leader>wr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder')
  nmap('<leader>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, '[W]orkspace [L]ist Folders')

  -- Create a command `:Format` local to the LSP buffer
  vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
    vim.lsp.buf.format()
  end, { desc = 'Format current buffer with LSP' })
end

function birdeeLua.get_capabilities()
  -- nvim-cmp supports additional completion capabilities, so broadcast that to servers
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)
  --vim.tbl_extend('keep', capabilities, require'coq'.lsp_ensure_capabilities())
  --vim.api.nvim_out_write(vim.inspect(capabilities))
  return capabilities
end

                   
  --[[ 
          LSP     LSP          LSP     LSP       LSP     LSP          LSP     LSP
          LSP     LSP          LSP     LSP       LSP     LSP          LSP     LSP
          LSP     LSP          LSP     LSP       LSP     LSP          LSP     LSP
          LSP     LSP          LSP     LSP       LSP     LSP          LSP     LSP
          LSP     LSP          LSP     LSP       LSP     LSP          LSP     LSP
  ]]
                   

function birdeeLua.LSPs( on_attach, capabilities )
  -- require('fidget').setup()
  require('neodev').setup()

end

                   
  --[[ 
          DEBUG          DEBUG       DEBUG          DEBUG       DEBUG
          DEBUG          DEBUG       DEBUG          DEBUG       DEBUG
          DEBUG          DEBUG       DEBUG          DEBUG       DEBUG
          DEBUG          DEBUG       DEBUG          DEBUG       DEBUG
          DEBUG          DEBUG       DEBUG          DEBUG       DEBUG
  ]]
                   

function birdeeLua.debug()

end

                   
  --[[ 
          AUTOFORMAT          AUTOFORMAT       AUTOFORMAT          AUTOFORMAT
          AUTOFORMAT          AUTOFORMAT       AUTOFORMAT          AUTOFORMAT
          AUTOFORMAT          AUTOFORMAT       AUTOFORMAT          AUTOFORMAT
          AUTOFORMAT          AUTOFORMAT       AUTOFORMAT          AUTOFORMAT
          AUTOFORMAT          AUTOFORMAT       AUTOFORMAT          AUTOFORMAT
  ]]
                   

function birdeeLua.autoformat()
require('birdeeLua.nixee')
end

  -- require('birdeeLua.nixee')
return birdeeLua
