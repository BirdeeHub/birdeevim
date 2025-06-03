local load_w_after = require("lzextras").loaders.with_after
return {
  {
    "cmp-cmdline",
    for_cat = "general.blink",
    on_plugin = { "blink.cmp" },
    load = load_w_after,
  },
  {
    "blink.compat",
    for_cat = "general.blink",
    dep_of = { "cmp-cmdline", "cmp-conjure" },
  },
  {
    "luasnip",
    for_cat = "general.blink",
    dep_of = { "blink.cmp" },
    after = function (_)
      require('birdee.snippets')
    end,
  },
  {
    "colorful-menu.nvim",
    for_cat = "general.blink",
    on_plugin = { "blink.cmp" },
  },
  {
    "blink.cmp",
    for_cat = "general.blink",
    event = "DeferredUIEnter",
    after = function (plugin)
      require("blink.cmp").setup({
        -- 'default' (recommended) for mappings similar to built-in completions (C-y to accept)
        -- See :h blink-cmp-config-keymap for configuring keymaps
        keymap = nixCats('tabCompletionKeys') and { preset = 'super-tab' } or {
          preset = 'none',
          ['<M-c>'] = { 'show', 'show_documentation', 'hide_documentation' },
          ['<M-h>'] = { 'hide' },
          ['<M-l>'] = { 'select_and_accept' },
          ['<M-k>'] = { 'select_prev', 'fallback_to_mappings' },
          ['<M-j>'] = { 'select_next', 'fallback_to_mappings' },
          ['<C-p>'] = { 'scroll_documentation_up', 'fallback' },
          ['<C-n>'] = { 'scroll_documentation_down', 'fallback' },
          ['<Tab>'] = { 'snippet_forward', 'fallback' },
          ['<S-Tab>'] = { 'snippet_backward', 'fallback' },
          ['<C-s>'] = { 'show_signature', 'hide_signature', 'fallback_to_mappings', 'fallback' },
        },
        cmdline = {
          enabled = true,
          completion = {
            menu = {
              auto_show = true,
            },
          },
          sources = function()
            local type = vim.fn.getcmdtype()
            -- Search forward and backward
            if type == '/' or type == '?' then return { 'buffer' } end
            -- Commands
            if type == ':' or type == '@' then return { 'cmdline', 'cmp_cmdline' } end
            return {}
          end,
          keymap = {
            preset = nixCats('tabCompletionKeys') and 'cmdline' or 'inherit',
            ['<Tab>'] = { 'select_next', 'fallback_to_mappings' },
            ['<S-Tab>'] = {'select_prev','fallback_to_mappings' },
          },
        },
        term = {
          enabled = false,
        },
        fuzzy = {
          sorts = {
            'exact',
            -- defaults
            'score',
            'sort_text',
          },
        },
        appearance = {
          nerd_font_variant = 'mono'
        },
        signature = {
          enabled = true,
          window = {
            show_documentation = true,
          },
        },
        completion = {
          menu = {
            draw = {
              columns = {
                { "label", "label_description", gap = 1 }, { "srckind" }
              },
              treesitter = { 'lsp' },
              components = {
                srckind = {
                  ellipsis = false,
                  width = { fill = true },
                  text = function (ctx)
                    if ctx.item.source_id == 'minuet' or ctx.item.source_id == 'windsurf' then
                      return "AI"
                    end
                    return ctx.kind
                  end,
                  highlight = function(ctx) return ctx.kind_hl end,
                },
                label = {
                  text = function(ctx)
                    return require("colorful-menu").blink_components_text(ctx)
                  end,
                  highlight = function(ctx)
                    return require("colorful-menu").blink_components_highlight(ctx)
                  end,
                },
              },
            },
          },
          documentation = {
            auto_show = true,
          },
        },
        ---@type blink.cmp.SnippetsConfig
        snippets = {
          -- preset = "luasnip",
          active = function(filter)
            local snippet = require "luasnip"
            local blink = require "blink.cmp"
            if snippet.in_snippet() and not blink.is_visible() then
              return true
            else
              if not snippet.in_snippet() and vim.fn.mode() == "n" then snippet.unlink_current() end
              return false
            end
          end,
        },
        sources = {
          default = require("birdee.utils").insert_many(
            { 'lsp', 'path', 'snippets', 'buffer', 'omni' },
            nixCats('AI.minuet') and 'minuet' or nil,
            nixCats('AI.windsurf') and 'windsurf' or nil
          ),
          per_filetype = {
            codecompanion = { "codecompanion" },
          },
          providers = {
            path = {
              score_offset = 50,
            },
            lsp = {
              score_offset = 40,
            },
            snippets = {
              score_offset = 40,
            },
            minuet = nixCats('AI.minuet') and {
              name = 'minuet',
              module = 'minuet.blink',
              async = true,
              timeout_ms = 3000, -- minuet.config.request_timeout * 1000,
              score_offset = 50,
            } or nil,
            windsurf = nixCats('AI.windsurf') and {
              name = 'windsurf',
              module = 'blink.compat.source',
              opts = {
                cmp_name = 'codeium',
              },
              score_offset = 39,
            } or nil,
            cmp_cmdline = {
              name = 'cmp_cmdline',
              module = 'blink.compat.source',
              score_offset = -100,
              opts = {
                cmp_name = 'cmdline',
              },
            },
          },
        },
      })
    end,
  },
}
