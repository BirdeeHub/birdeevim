local MP = ...
local colorschemer = nixInfo("onedark", "info", 'colorscheme') -- also schemes lualine
if colorschemer and colorschemer ~= "" then
  vim.cmd.colorscheme(colorschemer)
end

if nixInfo.utils.get_nix_plugin_path("argmark") then
  require("argmark").setup {}
  vim.keymap.set('n', '<leader><leader>n', function()
    vim.cmd.next()
  end, { desc = "Arglist next" })
  vim.keymap.set('n', '<leader><leader>N', function()
    vim.cmd.prev()
  end, { desc = "Arglist prev" })
  vim.keymap.set('n', '<leader><leader>t', function()
    if vim.fn.arglistid() == 0 then
      vim.cmd.arglocal()
    else
      vim.cmd.argglobal()
    end
  end, { desc = "Arglist local/global toggle" })
end

-- TODO: make an option to disable or enable this, it isnt a plugin
vim.keymap.set('n', '<leader>rr', function() require('scooter').open_scooter() end, { desc = 'Open scooter' })
vim.keymap.set('v', '<leader>rr',
  function()
      local selection = vim.fn.getreg('"')
      vim.cmd('normal! "ay')
      require('scooter').open_scooter_with_text(vim.fn.getreg('a'))
      vim.fn.setreg('"', selection)
  end,
  { desc = 'Search selected text in scooter' })

if nixInfo.utils.get_nix_plugin_path("nvim-spectre") then
  vim.keymap.set('n', '<leader>rs', '<cmd>lua require("spectre").toggle()<CR>', {
    desc = "Toggle Spectre"
  })
  vim.keymap.set('n', '<leader>rw', '<cmd>lua require("spectre").open_visual({select_word=true})<CR>', {
    desc = "Search current word"
  })
  vim.keymap.set('v', '<leader>rw', '<esc><cmd>lua require("spectre").open_visual()<CR>', {
    desc = "Search current word"
  })
  vim.keymap.set('n', '<leader>rf', '<cmd>lua require("spectre").open_file_search({select_word=true})<CR>', {
    desc = "Search on current file"
  })
end

-- NOTE: This is already lazy. It doesnt require it until you use the keybinding
vim.keymap.set({ 'n', }, "<leader>cpc", function() require("color_picker").rgbPicker() end, { desc = "color_picker rgb" })
vim.keymap.set({ 'n', }, "<leader>cph", function() require("color_picker").hsvPicker() end, { desc = "color_picker hsv" })
vim.keymap.set({ 'n', }, "<leader>cps", function() require("color_picker").hslPicker() end, { desc = "color_picker hsl" })
vim.keymap.set({ 'n', }, "<leader>cpg", function() require("color_picker").rgbGradientPicker() end, { desc = "color_picker rgb gradient" })
vim.keymap.set({ 'n', }, "<leader>cpd", function() require("color_picker").hsvGradientPicker() end, { desc = "color_picker hsv gradient" })
vim.keymap.set({ 'n', }, "<leader>cpb", function() require("color_picker").hslGradientPicker() end, { desc = "color_picker hsl gradient"})

if nixInfo.utils.get_nix_plugin_path("mini.nvim") then
  require("mini.sessions").setup {
    -- Whether to read default session if Neovim opened without file arguments
    autoread = true,

    -- Whether to write currently read session before leaving it
    autowrite = true,

    -- Directory where global sessions are stored (use `''` to disable)
    directory = vim.fn.stdpath('data') .. "/sessions",

    -- File for local session (use `''` to disable)
    file = 'Session.vim',

    -- Whether to force possibly harmful actions (meaning depends on function)
    force = { read = false, write = true, delete = false },

    -- Hook functions for actions. Default `nil` means 'do nothing'.
    hooks = {
      -- Before successful action
      pre = { read = nil, write = nil, delete = nil },
      -- After successful action
      post = { read = nil, write = nil, delete = nil },
    },

    -- Whether to print session path after action
    verbose = { read = false, write = true, delete = true },
  }
end

if nixInfo.utils.get_nix_plugin_path("snacks.nvim") then
  require(MP:relpath 'oil')
end

return {
  { import = MP:relpath "snacks", },
  { import = MP:relpath "nestsitter", },
  { import = MP:relpath "blink", },
  { import = MP:relpath "conjure", },
  { import = MP:relpath "grapple", },
  { import = MP:relpath "lualine", },
  { import = MP:relpath "git", },
  { import = MP:relpath "image", },
  { import = MP:relpath "which-key", },
  { import = MP:relpath "AI", },
  {
    "treesj",
    auto_enable = true,
    cmd = { "TSJToggle" },
    keys = { { "<leader>Ft", ":TSJToggle<CR>", mode = { "n" }, desc = "treesj split/join" }, },
    after = function(_)
      local tsj = require('treesj')

      -- local langs = {--[[ configuration for languages ]]}

      tsj.setup({
        ---@type boolean Use default keymaps (<space>m - toggle, <space>j - join, <space>s - split)
        use_default_keymaps = false,
        ---@type boolean Node with syntax error will not be formatted
        check_syntax_error = true,
        ---If line after join will be longer than max value,
        ---@type number If line after join will be longer than max value, node will not be formatted
        max_join_length = 120,
        ---Cursor behavior:
        ---hold - cursor follows the node/place on which it was called
        ---start - cursor jumps to the first symbol of the node being formatted
        ---end - cursor jumps to the last symbol of the node being formatted
        ---@type 'hold'|'start'|'end'
        cursor_behavior = 'hold',
        ---@type boolean Notify about possible problems or not
        notify = true,
        ---@type boolean Use `dot` for repeat action
        dot_repeat = true,
        ---@type nil|function Callback for treesj error handler. func (err_text, level, ...other_text)
        on_error = nil,
        ---@type table Presets for languages
        -- langs = langs, -- See the default presets in lua/treesj/langs
      })
    end,
  },
  {
    "typst-preview.nvim",
    auto_enable = true,
    ft = "typst",
    after = function()
      require 'typst-preview'.setup {
        -- Setting this true will enable logging debug information to
        -- `vim.fn.stdpath 'data' .. '/typst-preview/log.txt'`
        debug = false,
        -- Custom format string to open the output link provided with %s
        -- Example: open_cmd = 'firefox %s -P typst-preview --class typst-preview'
        open_cmd = nil,
        -- Custom port to open the preview server. Default is random.
        -- Example: port = 8000
        port = nil,
        -- Setting this to 'always' will invert black and white in the preview
        -- Setting this to 'auto' will invert depending if the browser has enable
        -- dark mode
        -- Setting this to '{"rest": "<option>","image": "<option>"}' will apply
        -- your choice of color inversion to images and everything else
        -- separately.
        invert_colors = 'never',
        -- Whether the preview will follow the cursor in the source file
        follow_cursor = true,
        -- Provide the path to binaries for dependencies.
        -- Setting this will skip the download of the binary by the plugin.
        -- Warning: Be aware that your version might be older than the one
        -- required.
        dependencies_bin = {
          tinymist = 'tinymist',
          websocat = 'websocat'
        },
        -- A list of extra arguments (or nil) to be passed to previewer.
        -- For example, extra_args = { "--input=ver=draft", "--ignore-system-fonts" }
        extra_args = nil,
        -- This function will be called to determine the root of the typst project
        get_root = function(path_of_main_file)
          local root = os.getenv 'TYPST_ROOT'
          if root then
            return root
          end
          return vim.fn.fnamemodify(path_of_main_file, ':p:h')
        end,
        -- This function will be called to determine the main file of the typst
        -- project.
        get_main_file = function(path_of_buffer)
          return path_of_buffer
        end,
      }
    end,
  },
  {
    "markdown-preview.nvim",
    auto_enable = true,
    cmd = { "MarkdownPreview", "MarkdownPreviewStop", "MarkdownPreviewToggle", },
    ft = "markdown",
    keys = {
      {"<leader>mp", "<cmd>MarkdownPreview <CR>", mode = {"n"}, noremap = true, desc = "markdown preview"},
      {"<leader>ms", "<cmd>MarkdownPreviewStop <CR>", mode = {"n"}, noremap = true, desc = "markdown preview stop"},
      {"<leader>mt", "<cmd>MarkdownPreviewToggle <CR>", mode = {"n"}, noremap = true, desc = "markdown preview toggle"},
    },
    before = function(_)
      vim.g.mkdp_auto_close = 0
    end,
  },
  {
    "render-markdown.nvim",
    auto_enable = true,
    ft = "markdown",
    after = function(_)
      require('render-markdown').setup({})
    end,
  },
  {
    "otter.nvim",
    auto_enable = true,
    -- event = "DeferredUIEnter",
    on_require = { "otter" },
    -- ft = { "markdown", "norg", "templ", "nix", "javascript", "html", "typescript", },
    after = function(_)
      local otter = require 'otter'
      otter.setup {
        lsp = {
          -- `:h events` that cause the diagnostics to update. Set to:
          -- { "BufWritePost", "InsertLeave", "TextChanged" } for less performant
          -- but more instant diagnostic updates
          diagnostic_update_events = { "BufWritePost" },
          -- function to find the root dir where the otter-ls is started
          root_dir = function(_, bufnr)
            return vim.fs.root(bufnr or 0, {
              ".git",
              "_quarto.yml",
              "package.json",
            }) or vim.fn.getcwd(0)
          end,
        },
        buffers = {
          -- if set to true, the filetype of the otterbuffers will be set.
          -- otherwise only the autocommand of lspconfig that attaches
          -- the language server will be executed without setting the filetype
          set_filetype = false,
          -- write <path>.otter.<embedded language extension> files
          -- to disk on save of main buffer.
          -- usefule for some linters that require actual files
          -- otter files are deleted on quit or main buffer close
          write_to_disk = false,
        },
        verbose = {          -- set to false to disable all verbose messages
          no_code_found = false, -- warn if otter.activate is called, but no injected code was found
        },
        strip_wrapping_quote_characters = { "'", '"', "`" },
        -- otter may not work the way you expect when entire code blocks are indented (eg. in Org files)
        -- When true, otter handles these cases fully.
        handle_leading_whitespace = false,
      }
    end,
  },
  {
    "dial.nvim",
    auto_enable = true,
    keys = {
      { "<C-a>", function() require("dial.map").manipulate("increment", "normal") end, mode = "n", desc = "Increment" },
      { "<C-x>", function() require("dial.map").manipulate("decrement", "normal") end, mode = "n", desc = "Decrement" },
      { "<C-x>", function() require("dial.map").manipulate("decrement", "normal") end, mode = "n", desc = "Decrement" },
      { "g<C-a>", function() require("dial.map").manipulate("increment", "gnormal") end, mode = "n", desc = "Increment" },
      { "g<C-x>", function() require("dial.map").manipulate("decrement", "gnormal") end, mode = "n", desc = "Decrement" },
      { "<C-a>", function() require("dial.map").manipulate("increment", "visual") end, mode = "v", desc = "Increment" },
      { "<C-x>", function() require("dial.map").manipulate("decrement", "visual") end, mode = "v", desc = "Increment" },
      { "g<C-a>", function() require("dial.map").manipulate("increment", "gvisual") end, mode = "v", desc = "Increment" },
      { "g<C-x>", function() require("dial.map").manipulate("decrement", "gvisual") end, mode = "v", desc = "Increment" },
    },
    after = function(_)
      local augend = require("dial.augend")
      require("dial.config").augends:register_group{
        default = {
          augend.integer.alias.decimal,
          augend.integer.alias.hex,
          augend.date.alias["%Y/%m/%d"],
          augend.date.alias["%Y-%m-%d"],
          augend.date.alias["%m/%d"],
          augend.date.alias["%H:%M"],
          augend.constant.alias.ja_weekday_full,
          augend.constant.alias.bool,
          augend.semver.alias.semver,
        },
      }
    end
  },
  {
    "undotree",
    auto_enable = true,
    cmd = { "UndotreeToggle", "UndotreeHide", "UndotreeShow", "UndotreeFocus", "UndotreePersistUndo", },
    keys = { { "<leader>U", "<cmd>UndotreeToggle<CR>", mode = { "n" }, desc = "Undo Tree" }, },
    before = function(_)
      vim.g.undotree_WindowLayout = 1
      vim.g.undotree_SplitWidth = 40
    end,
  },
  {
    "todo-comments.nvim",
    auto_enable = true,
    event = "DeferredUIEnter",
    after = function(_)
      require("todo-comments").setup({ signs = false })
    end,
  },
  {
    "visual-whitespace",
    auto_enable = true,
    event = "DeferredUIEnter",
    after = function(_)
      require('visual-whitespace').setup({
        highlight = { link = 'Visual' },
        space_char = '·',
        tab_char = '→',
        nl_char = '↲'
      })
    end,
  },
  {
    "vim-startuptime",
    auto_enable = true,
    cmd = { "StartupTime" },
    before = function(_)
      vim.g.startuptime_event_width = 0
      vim.g.startuptime_tries = 10
      vim.g.startuptime_exe_path = nixInfo.progpath
    end,
  },
  {
    "nvim-surround",
    auto_enable = true,
    event = "DeferredUIEnter",
    -- keys = "",
    after = function(_)
      require('nvim-surround').setup()
    end,
  },
  {
    "eyeliner.nvim",
    auto_enable = true,
    event = "DeferredUIEnter",
    -- keys = "",
    after = function(_)
      -- Highlights unique characters for f/F and t/T motions
      require('eyeliner').setup {
        highlight_on_key = true, -- show highlights only after key press
        dim = true,          -- dim all other characters
      }
    end,
  },
  {
    "vim-dadbod",
    auto_enable = {
      "vim-dadbod",
      "vim-dadbod-ui",
      "vim-dadbod-completion",
    },
    cmd = { "DB", "DBUI", "DBUIAddConnection", "DBUIClose",
      "DBUIToggle", "DBUIFindBuffer", "DBUILastQueryInfo", "DBUIRenameBuffer", },
    load = function(name)
      require("lzextras").loaders.multi {
        name,
        "vim-dadbod-ui",
      }
      require("lzextras").loaders.with_after("vim-dadbod-completion")
    end,
    after = function(_)
    end,
  },
  {
    "vim-sleuth",
    auto_enable = true,
    event = "DeferredUIEnter",
  },
  {
    "nvim-highlight-colors",
    auto_enable = true,
    event = "DeferredUIEnter",
    -- ft = "",
    after = function(_)
      require("nvim-highlight-colors").setup {
        ---Render style
        ---@usage 'background'|'foreground'|'virtual'
        render = 'virtual',

        ---Set virtual symbol (requires render to be set to 'virtual')
        virtual_symbol = '■',

        ---Highlight named colors, e.g. 'green'
        enable_named_colors = true,

        ---Highlight tailwind colors, e.g. 'bg-blue-500'
        enable_tailwind = true,

        ---Set custom colors
        ---Label must be properly escaped with '%' to adhere to `string.gmatch`
        --- :help string.gmatch
        custom_colors = {
          { label = '%-%-theme%-primary%-color',   color = '#0f1219' },
          { label = '%-%-theme%-secondary%-color', color = '#5a5d64' },
        }
      }
    end,
  },
}
