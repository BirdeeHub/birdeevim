return {
  'opencode-nvim',
  auto_enable = true,
  keys = {
    -- opencode.nvim exposes a general, flexible API — customize it to your workflow!
    -- But here are some examples to get you started :)
    { '<leader>ct', function() require('opencode').toggle() end, desc = 'Toggle opencode', },
    { '<leader>ca', function() require('opencode').ask() end, desc = 'Ask opencode', mode = { 'n', 'v' }, },
    { '<leader>cA', function() require('opencode').ask('@file ') end, desc = 'Ask opencode about current file', mode = { 'n', 'v' }, },
    { '<leader>cn', function() require('opencode').command('/new') end, desc = 'New session', },
    { '<leader>ce', function() require('opencode').prompt('Explain @cursor and its context') end, desc = 'Explain code near cursor' },
    { '<leader>cr', function() require('opencode').prompt('Review @file for correctness and readability') end, desc = 'Review file', },
    { '<leader>cf', function() require('opencode').prompt('Fix these @diagnostics') end, desc = 'Fix errors', },
    { '<leader>co', function() require('opencode').prompt('Optimize @selection for performance and readability') end, desc = 'Optimize selection', mode = 'v', },
    { '<leader>cd', function() require('opencode').prompt('Add documentation comments for @selection') end, desc = 'Document selection', mode = 'v', },
    { '<leader>ct', function() require('opencode').prompt('Add tests for @selection') end, desc = 'Test selection', mode = 'v', },
  },
  after = function()
    ---@type opencode.Config
    require('opencode').setup {
      auto_register_cmp_sources = { "opencode", "buffer" },
      auto_reload = false,  -- Automatically reload buffers edited by opencode
      auto_focus = false,   -- Focus the opencode window after prompting 
      command = "opencode", -- Command to launch opencode
      context = {           -- Context to inject in prompts
        ["@file"] = require("opencode.context").file,
        ["@files"] = require("opencode.context").files,
        ["@cursor"] = require("opencode.context").cursor_position,
        ["@selection"] = require("opencode.context").visual_selection,
        ["@diagnostics"] = require("opencode.context").diagnostics,
        ["@quickfix"] = require("opencode.context").quickfix,
        ["@diff"] = require("opencode.context").git_diff,
      },
      win = {
        position = "right",
        -- See https://github.com/folke/snacks.nvim/blob/main/docs/win.md for more window options
      },
      -- See https://github.com/folke/snacks.nvim/blob/main/docs/terminal.md for more terminal options
    }
  end,
}
