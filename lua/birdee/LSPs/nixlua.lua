local get_nixd_opts = nixInfo(nil, "info", "nixdExtras", "get_configs")
return {
  {
    "lazydev.nvim",
    auto_enable = true,
    cmd = { "LazyDev" },
    ft = "lua",
    after = function(_)
      require('lazydev').setup({
        library = {
          { words = { "uv", "vim%.uv", "vim%.loop" }, path = nixInfo("luvit-meta", "plugins", "start", "luvit-meta") .. "/library" },
          { words = { "nixInfo" }, path = nixInfo("", "info_plugin_path") .. '/lua' },
        },
      })
    end,
  },
  {
    "lua_ls",
    for_cat = "lua",
    lsp = {
      filetypes = { 'lua' },
      settings = {
        Lua = {
          runtime = { version = 'LuaJIT' },
          formatters = {
            ignoreComments = true,
          },
          signatureHelp = { enabled = true },
          diagnostics = {
            globals = { "vim", "make_test" },
            disable = { },
          },
          workspace = {
            checkThirdParty = false,
            library = {
              -- '${3rd}/luv/library',
              -- unpack(vim.api.nvim_get_runtime_file('', true)),
            },
          },
          completion = {
            callSnippet = 'Replace',
          },
          telemetry = { enabled = false },
        },
      },
    },
  },
  {
    "nixd",
    for_cat = "nix",
    after = function(_)
      vim.api.nvim_create_user_command("StartNilLSP", function()
        vim.lsp.start(vim.lsp.config.nil_ls)
      end, { desc = 'Run nil-ls (when you really need docs for the builtins and nixd refuse)' })
    end,
    lsp = {
      filetypes = { 'nix' },
      settings = {
        nixd = {
          nixpkgs = {
            expr = nixInfo("import <nixpkgs> {}", "info", "nixdExtras", "nixpkgs"),
          },
          formatting = {
            command = { "nixfmt" }
          },
          options = {
            -- (builtins.getFlake "path:${builtins.toString <path_to_system_flake>}").legacyPackages.<system>.nixosConfigurations."<user@host>".options
            nixos = {
              expr = get_nixd_opts and get_nixd_opts("nixos", nixInfo(nil, "info", "nixdExtras", "flake-path"))
            },
            -- (builtins.getFlake "path:${builtins.toString <path_to_system_flake>}").legacyPackages.<system>.homeConfigurations."<user@host>".options
            ["home-manager"] = {
              expr = get_nixd_opts and get_nixd_opts("home-manager", nixInfo(nil, "info", "nixdExtras", "flake-path")) -- <-  if flake-path is nil it will be lsp root dir
            }
          },
          diagnostic = {
            suppress = {
              "sema-escaping-with"
            }
          }
        }
      },
    },
  },
  {
    "rnix",
    enabled = not nixInfo.isNix,
    lsp = {
      filetypes = { "nix" },
    },
  },
  {
    "nil_ls",
    enabled = not nixInfo.isNix,
    lsp = {
      filetypes = { "nix" },
    },
  },
}
