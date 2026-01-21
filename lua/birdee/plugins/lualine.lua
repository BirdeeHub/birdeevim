-- NOTE: do not set winbar via lualine it will override the winbar
-- that is why you are calling this here, to remind yourself
vim.keymap.set("n", "<leader>lb", function() require("lsp_breadcrumbs")() end, { desc = "Toggle [l]sp [b]readcrumbs" })
return {
  {
    "lualine.nvim",
    auto_enable = true,
    -- cmd = { "" },
    event = "DeferredUIEnter",
    -- ft = "",
    -- keys = "",
    -- colorscheme = "",
    load = function (name)
      nixInfo.lze.loaders.multi {
        name,
        "lualine-lsp-progress",
      }
    end,
    after = function (_)
      local colorschemer = nixInfo("onedark", "info", 'colorscheme') -- also schemes lualine
      -- local has_printed = false
      -- local components = {
      --   function(config, is_focused)
      --     -- in tabline, is_focused == 3 always, otherwise it is a boolean?
      --     -- Or whatever non-nil value that gets passed to require('lualine').statusline(any_arg) ? For some reason ?
      --     print(is_focused)
      --     if not has_printed then
      --       print(vim.inspect(config))
      --       has_printed = true
      --     end
      --   end,
      --   python_env = {
      --     function()
      --       if vim.bo.filetype == "python" then
      --         local venv = os.getenv "CONDA_DEFAULT_ENV" or os.getenv "VIRTUAL_ENV"
      --         if venv then
      --           local icons = require "nvim-web-devicons"
      --           local py_icon, _ = icons.get_icon ".py"
      --           return string.format(" " .. py_icon .. " (%s)", venv)
      --         end
      --       end
      --       return ""
      --     end
      --   },
      -- }
      require('lualine').setup({
        options = {
          icons_enabled = true,
          theme = colorschemer,
          component_separators = { left = '|', right = '|' },
          section_separators = { left = '', right = '' },
          disabled_filetypes = {
            statusline = {},
          },
          ignore_focus = {},
          always_divide_middle = true,
          globalstatus = false,
          refresh = {
            statusline = 1000,
            tabline = 1000,
          },
        },
        sections = {
          lualine_a = { 'mode' },
          lualine_b = {
            'branch',
            {
              "diff",
              symbols = {
                added = nixInfo.icons.git.added,
                modified = nixInfo.icons.git.modified,
                removed = nixInfo.icons.git.removed,
              },
            },
            'diagnostics',
          },
          lualine_c = {
            {
              'filename', path = 1, status = true,
            },
          },
          lualine_x = {
            -- components.python_env,
            'encoding',
            'fileformat',
            'filetype',
          },
          lualine_y = { 'progress' },
          lualine_z = { 'location' }
        },
        inactive_sections = {
          lualine_a = {},
          lualine_b = {
            {
              'filename', path = 3, status = true,
            },
          },
          lualine_c = {
          },
          lualine_x = { 'filetype' },
          lualine_y = {},
          lualine_z = {}
        },
        tabline = {
          lualine_a = {
            {
              'buffers',
              mode = 4,
            },
          },
          lualine_c = {},
          lualine_b = { 'lsp_progress', },
          lualine_x = { require("argmark").get_display_text },
          lualine_y = { 'grapple', },
          lualine_z = { 'tabs' }
        },
        extensions = {}
      })
    end,
  },
}
