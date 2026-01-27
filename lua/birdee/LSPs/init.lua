local MP = ...
return {
  {
    "mason.nvim",
    auto_enable = true,
    priority = 55,
    on_plugin = { "nvim-lspconfig" },
    lsp = function(plugin)
      vim.cmd.MasonInstall(plugin.name)
    end,
  },
  {
    "nvim-lspconfig",
    auto_enable = true,
    priority = 50,
    wk = {
      { "<leader>r", group = "[R]ename" },
      { "<leader>r_", hidden = true },
      { "<leader>w", group = "[W]orkspace" },
      { "<leader>w_", hidden = true },
    },
    lsp = function(plugin)
      vim.lsp.config(plugin.name, plugin.lsp or {})
      vim.lsp.enable(plugin.name)
    end,
    before = function(_)
      vim.lsp.config('*', {
        on_attach = require(MP:relpath 'on_attach'),
      })
    end,
  },
  { import = MP:relpath "web", },
  { import = MP:relpath "nixlua", },
  {
    "clangd_extensions.nvim",
    auto_enable = true,
    dep_of = { "nvim-lspconfig", "blink.cmp", },
  },
  {
    "cmake",
    for_cat = "C",
    lsp = {
      filetypes = { "cmake" },
    },
  },
  {
    "clangd",
    for_cat = "C",
    lsp = {
      filetypes = { "c", "cpp", "objc", "objcpp", "cuda", "proto" },
      -- unneded thanks to clangd_extensions-nvim I think
      -- settings = {
      --   clangd_config = {
      --     init_options = {
      --       compilationDatabasePath="./build",
      --     },
      --   }
      -- }
    },
  },
  {
    "vim-cmake",
    auto_enable = true,
    ft = { "cmake" },
    cmd = {
      "CMakeGenerate", "CMakeClean", "CMakeBuild", "CMakeInstall",
      "CMakeRun", "CMakeTest", "CMakeSwitch", "CMakeOpen", "CMakeClose",
      "CMakeToggle", "CMakeCloseOverlay", "CMakeStop",
    },
    after = function(_)
      vim.api.nvim_create_user_command('BirdeeCMake', [[:CMake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON .<CR>]],
        { desc = 'Run CMake with compile_commands.json' })
      vim.cmd [[let g:cmake_link_compile_commands = 1]]
    end,
  },
  {
    "gopls",
    for_cat = "go",
    lsp = {
      filetypes = { "go", "gomod", "gowork", "gotmpl", "templ", },
    },
  },
  {
    "fennel_ls",
    for_cat = "fennel",
    lsp = {
      filetypes = { "fennel" },
    },
  },
  {
    "elixirls",
    for_cat = "elixir",
    lsp = {
      filetypes = { "elixir", "eelixir", "heex", "surface" },
      cmd = { "elixir-ls" },
    }
  },
  {
    "tinymist",
    for_cat = "typst",
    lsp = {
      filetypes = { 'typst', },
    }
  },
  {
    "jdtls",
    for_cat = "jvm",
    lsp = {
      filetypes = { 'java', },
    }
  },
  {
    "zls",
    for_cat = "zig",
    lsp = {
      filetypes = { 'zig', 'zir' },
    }
  },
  {
    "gradle_ls",
    for_cat = "jvm",
    lsp = {
      filetypes = { "kotlin", "java" },
      root_pattern = { "settings.gradle", "settings.gradle.kts", 'gradlew', 'mvnw' },
      cmd = nixInfo(nil, "info", "javaExtras", "gradle-ls") and { nixInfo.info.javaExtras["gradle-ls"] .. "/share/vscode/extensions/vscjava.vscode-gradle/lib/gradle-server" } or nil,
    }
  },
  {
    "bashls",
    for_cat = "bash",
    lsp = {
      filetypes = { "bash", "sh" },
    },
  },
  -- {"pyright", lsp = {}, },
  {
    "pylsp",
    for_cat = "python",
    lsp = {
      filetypes = { "python" },
      settings = {
        pylsp = {
          plugins = {
            -- formatter options
            black = { enabled = false },
            autopep8 = { enabled = false },
            yapf = { enabled = false },
            -- linter options
            pylint = { enabled = true, executable = "pylint" },
            pyflakes = { enabled = false },
            pycodestyle = { enabled = false },
            -- type checker
            pylsp_mypy = { enabled = true },
            -- auto-completion options
            jedi_completion = { fuzzy = true },
            -- import sorting
            pyls_isort = { enabled = true },
          },
        },
      },
    }
  },
  {
    "marksman",
    for_cat = "markdown",
    lsp = {
      filetypes = { "markdown", "markdown.mdx" },
    },
  },
  {
    "roc_ls",
    for_cat = "roc",
    lsp = {
      filetypes = { "roc" },
    },
  },
  {
    "harper_ls",
    for_cat = "markdown",
    lsp = {
      filetypes = { "markdown", "norg" },
      settings = {
        ["harper-ls"] = {},
      },
    },
  },
  -- {
  --   "kotlin_lsp",
  --   for_cat = "jvm",
  --   lsp = {
  --     filetypes = { 'kotlin' },
  --   }
  -- },
  {
    "kotlin_language_server",
    for_cat = "jvm",
    lsp = {
      filetypes = { 'kotlin' },
      -- root_pattern = {"settings.gradle", "settings.gradle.kts", 'gradlew', 'mvnw'},
      settings = {
        kotlin = {
          formatters = {
            ignoreComments = true,
          },
          signatureHelp = { enabled = true },
          workspace = { checkThirdParty = true },
          telemetry = { enabled = false },
        },
      },
    }
  },
}
