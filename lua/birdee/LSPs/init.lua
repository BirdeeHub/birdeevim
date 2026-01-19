local MP = ...
-- TODO: figure out how to conditionally enable lsps and other programs (such as scooter)
return {
  {
    "mason.nvim",
    enabled = not nixInfo.utils.isNix,
    on_plugin = { "nvim-lspconfig" },
    load = function(name)
      require('lzextras').loaders.multi { name, "mason-lspconfig.nvim" }
      require('mason').setup()
      require('mason-lspconfig').setup { automatic_installation = true, }
    end,
  },
  {
    "nvim-lspconfig",
    auto_enable = true,
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
    lsp = {
      filetypes = { "cmake" },
    },
  },
  {
    "clangd",
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
    lsp = {
      filetypes = { "go", "gomod", "gowork", "gotmpl", "templ", },
    },
  },
  {
    "fennel_ls",
    lsp = {
      filetypes = { "fennel" },
    },
  },
  {
    "elixirls",
    lsp = {
      filetypes = { "elixir", "eelixir", "heex", "surface" },
      cmd = { "elixir-ls" },
    }
  },
  {
    "tinymist",
    lsp = {
      filetypes = { 'typst', },
    }
  },
  {
    "jdtls",
    lsp = {
      filetypes = { 'java', },
    }
  },
  {
    "zls",
    lsp = {
      filetypes = { 'zig', 'zir' },
    }
  },
  {
    "gradle_ls",
    lsp = {
      filetypes = { "kotlin", "java" },
      root_pattern = { "settings.gradle", "settings.gradle.kts", 'gradlew', 'mvnw' },
      cmd = nixInfo(nil, "info", "javaExtras", "gradle-ls") and { nixInfo.info.javaExtras["gradle-ls"] .. "/share/vscode/extensions/vscjava.vscode-gradle/lib/gradle-server" } or nil,
    }
  },
  {
    "bashls",
    lsp = {
      filetypes = { "bash", "sh" },
    },
  },
  -- {"pyright", lsp = {}, },
  {
    "pylsp",
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
    lsp = {
      filetypes = { "markdown", "markdown.mdx" },
    },
  },
  {
    "roc_ls",
    lsp = {
      filetypes = { "roc" },
    },
  },
  {
    "harper_ls",
    lsp = {
      filetypes = { "markdown", "norg" },
      settings = {
        ["harper-ls"] = {},
      },
    },
  },
  -- {
  --   "kotlin_lsp",
  --   lsp = {
  --     filetypes = { 'kotlin' },
  --   }
  -- },
  {
    "kotlin_language_server",
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
