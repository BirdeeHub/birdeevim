local completion = {}
  -- [[ Configure nvim-cmp ]]
  -- See `:help cmp`
function completion.setup()

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
    sources = cmp.config.sources {
      -- The insertion order influences the priority of the sources
      { name = 'nvim_lsp'--[[ , keyword_length = 3 ]] },
      { name = 'nvim_lsp_signature_help'--[[ , keyword_length = 3  ]]},
      -- { name = 'cmp_tabnine' },
      { name = 'buffer' },
      { name = 'path' },
    },
    enabled = function()
      return vim.bo[0].buftype ~= 'prompt'
    end,
    experimental = {
      native_menu = false,
      ghost_text = true,
    },
  }

  cmp.setup.filetype('lua', {
    sources = cmp.config.sources {
      { name = 'nvim_lua' },
      { name = 'nvim_lsp'--[[ , keyword_length = 3  ]]},
      { name = 'path' },
      { name = 'luasnip' },
    },{
      {
        name = 'cmdline',
        option = {
          ignore_cmds = { 'Man', '!' },
        },
      },
    },
  })

  -- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
  cmp.setup.cmdline({ '/', '?' }, {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
      { name = 'nvim_lsp_document_symbol'--[[ , keyword_length = 3  ]]},
      { name = 'buffer' },
      { name = 'cmdline_history' },
    },
    view = {
      entries = { name = 'wildmenu', separator = '|' },
    },
  })

  -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
  cmp.setup.cmdline(':', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources {
      { name = 'cmdline' },
      -- { name = 'cmdline_history' },
      { name = 'path' },
    },
  })
end

return completion