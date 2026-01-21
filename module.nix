inputs:
{
  config,
  wlib,
  lib,
  pkgs,
  ...
}:
let
  neovimPlugins = config.nvim-lib.pluginsFromPrefix "plugins-" inputs;
in
{
  imports = [
    wlib.wrapperModules.neovim
    ./nix/nvim-lib.nix
  ];
  options.settings.test_mode = lib.mkOption {
    type = lib.types.bool;
    default = false;
  };
  config.settings.config_directory =
    if config.settings.test_mode then config.settings.unwrapped_config else config.settings.wrapped_config;
  options.settings.wrapped_config = lib.mkOption {
    type = wlib.types.stringable;
    default = ./.;
  };
  options.settings.unwrapped_config = lib.mkOption {
    type = wlib.types.nonEmptyline;
    default = "/home/birdee/.birdeevim";
  };
  config.settings.dont_link = config.binName != "nvim";
  config.binName = lib.mkIf config.settings.test_mode "vim";
  config.settings.aliases = lib.mkIf (config.binName == "nvim") [ "vi" ];
  config.package = inputs.neovim-nightly-overlay.packages.${pkgs.stdenv.hostPlatform.system}.neovim;
  config.env.NVIM_APPNAME = "birdeevim";

  config.specMods =
    { parentSpec, ... }:
    {
      config.collateGrammars = lib.mkDefault (parentSpec.collateGrammars or true);
    };

  config.settings.nvim_lua_env = lp: with lp; lib.optional config.specs.fennel.enable fennel;
  config.hosts.ruby.gemdir = ./nix/ruby_provider;

  config.specs.general = {
    postpkgs = with pkgs; [
      tree-sitter
      universal-ctags
      ripgrep
      fd
      ast-grep
      jq
      lazygit
    ];
    data = with pkgs.vimPlugins; [
      neovimPlugins.lze
      neovimPlugins.lzextras
      oil-nvim
      vim-repeat
      neovimPlugins.nvim-luaref
      nvim-nio
      nui-nvim
      nvim-web-devicons
      plenary-nvim
      mini-nvim
      neovimPlugins."snacks.nvim"
      nvim-ts-autotag
      neovimPlugins.argmark
      neovimPlugins.tmux-navigate
      inputs.tomlua.packages.${pkgs.stdenv.hostPlatform.system}.vimPlugins-tomlua
      neovimPlugins.shelua
      nvim-spectre
      luvit-meta
    ];
  };

  config.specs.lazy = {
    lazy = true;
    data = with pkgs.vimPlugins; [
      img-clip-nvim
      vim-dadbod
      vim-dadbod-ui
      vim-dadbod-completion
      otter-nvim
      nvim-dap
      nvim-dap-ui
      nvim-dap-virtual-text
      nvim-highlight-colors
      which-key-nvim
      eyeliner-nvim
      todo-comments-nvim
      vim-startuptime
      neovimPlugins.visual-whitespace
      luasnip
      cmp-cmdline
      blink-cmp
      blink-compat
      colorful-menu-nvim
      nvim-treesitter-textobjects
      nvim-treesitter.withAllGrammars
      vim-rhubarb
      vim-fugitive
      neovimPlugins.nvim-lspconfig
      lualine-lsp-progress
      lualine-nvim
      gitsigns-nvim
      grapple-nvim
      # marks-nvim
      nvim-lint
      conform-nvim
      undotree
      nvim-surround
      treesj
      dial-nvim
      vim-sleuth
    ];
  };

  config.specs.images = {
    lazy = true;
    data = pkgs.vimPlugins.image-nvim;
    postpkgs = with pkgs; [
      imagemagick
      ueberzugpp
    ];
  };

  config.specs.scooter = {
    data = null;
    postpkgs = [
      (wlib.wrapPackage [
        { inherit pkgs; }
        ({ pkgs, ... }: {
          package = pkgs.scooter;
          flags."--config-dir" = "${placeholder "out"}/share/bundled_config";
          drv.configJSON = builtins.toJSON {
            editor_open.command = "${config.binName} --server $NVIM --remote-send '<cmd>lua require('scooter').EditLineFromScooter(\"%file\", %line)<CR>'";
          };
          drv.passAsFile = [ "configJSON" ];
          drv.nativeBuildInputs = [ pkgs.remarshal ];
          drv.buildPhase = ''
            runHook preBuild
            mkdir -p "$out/share/bundled_config"
            json2toml "$configJSONPath" "$out/share/bundled_config/config.toml"
            runHook postBuild
          '';
        })
      ])
    ];
  };

  config.info.colorscheme = "moonfly";
  config.specs.colorscheme = {
    data = builtins.getAttr (config.info.colorscheme or "onedark") (
      with pkgs.vimPlugins;
      {
        "onedark" = onedarkpro-nvim;
        "onedark_dark" = onedarkpro-nvim;
        "onedark_vivid" = onedarkpro-nvim;
        "onelight" = onedarkpro-nvim;
        "catppuccin" = catppuccin-nvim;
        "catppuccin-mocha" = catppuccin-nvim;
        "moonfly" = vim-moonfly-colors;
        "tokyonight" = tokyonight-nvim;
        "tokyonight-day" = tokyonight-nvim;
      }
    );
  };

  config.info.bitwarden_uuids = lib.mkIf config.specs.AI.enable {
    gemini = [
      "notes"
      "bcd197b5-ba11-4c86-8969-b2bd01506654"
    ];
    windsurf = [
      "notes"
      "d9124a28-89ad-4335-b84f-b0c20135b048"
    ];
  };
  config.specs.AI = {
    lazy = true;
    data = with pkgs.vimPlugins; [
      windsurf-nvim
      neovimPlugins.opencode-nvim
    ];
    postpkgs = with pkgs; [
      bitwarden-cli
      (wlib.evalPackage {
        imports = [ wlib.wrapperModules.opencode ];
        inherit pkgs;
        settings = {
          "$schema" = "https://opencode.ai/config.json";
          provider = {
            ollama = {
              npm = "@ai-sdk/openai-compatible";
              name = "Ollama (local)";
              options = {
                baseURL = "http://localhost:11434/v1";
              };
              models = {
                "gpt-oss:20b" = {
                  name = "gpt-oss:20b";
                };
                "qwen3:14b" = {
                  name = "qwen3:14b";
                };
                "qwen3:8b" = {
                  name = "qwen3:8b";
                };
              };
            };
          };
        };
      })
    ];
  };

  config.specs.typst = {
    lazy = true;
    data = with pkgs.vimPlugins; [
      typst-preview-nvim
    ];
    postpkgs = with pkgs; [
      typst
      typst-live
      tinymist
      websocat
    ];
  };
  config.specs.markdown = {
    lazy = true;
    data = with pkgs.vimPlugins; [
      render-markdown-nvim
      markdown-preview-nvim
    ];
    postpkgs = with pkgs; [
      marksman
      python311Packages.pylatexenc
      harper
    ];
  };

  config.info.nixdExtras = lib.mkIf config.specs.nix.enable {
    nixpkgs = "import ${builtins.path { path = pkgs.path; }} {}";
    get_configs =
      lib.generators.mkLuaInline # lua
        ''function(type, path) return [[import ${./nix/nixd.nix} ${
          builtins.path { path = pkgs.path; }
        } "]] .. type .. [[" ]] .. (path or "./.") end'';
  };
  config.specs.nix = {
    data = null;
    postpkgs = with pkgs; [
      nix-doc
      nil
      nixd
      nixfmt
      alejandra
    ];
  };
  config.specs.lua = {
    lazy = true;
    data = with pkgs.vimPlugins; [
      lazydev-nvim
    ];
    postpkgs = with pkgs; [
      lua-language-server
      stylua
    ];
  };
  config.specs.bash = {
    data = null;
    postpkgs = with pkgs; [
      nodePackages.bash-language-server
    ];
  };
  config.specs.elixir = {
    data = null;
    postpkgs = with pkgs; [
      elixir-ls
    ];
  };
  config.specs.zig = {
    data = null;
    postpkgs = with pkgs; [
      zls
      zig
      zig-shell-completions
    ];
  };
  config.specs.fennel = {
    lazy = true;
    data = with pkgs.vimPlugins; [
      { data = neovimPlugins.fn_finder; lazy = false; }
      (cmp-conjure.overrideAttrs {
        dependencies = [
          (conjure.overrideAttrs (prev: {
            doCheck = false;
            nvimSkipModules = (prev.nvimSkipModules or [ ]) ++ [ "conjure-spec.process_spec" ];
          }))
        ];
      })
    ];
    postpkgs = with pkgs; [
      fnlfmt
      fennel-ls
    ];
  };
  config.specs.roc = {
    data = null;
    postpkgs = with pkgs; [
      inputs.roc.packages.${stdenv.hostPlatform.system}.lang-server
    ];
  };
  config.specs.rust = {
    data = with pkgs.vimPlugins; [
      neovimPlugins.rustaceanvim
    ];
    postpkgs = with pkgs; [
      (config.info.toolchain or inputs.fenix.packages.${stdenv.hostPlatform.system}.latest.toolchain)
      rustup
      llvmPackages.bintools
      lldb
    ];
  };
  config.specs.C = {
    lazy = true;
    data = with pkgs.vimPlugins; [
      vim-cmake
      clangd_extensions-nvim
    ];
    postpkgs = with pkgs; [
      clang-tools
      valgrind
      cmake-language-server
      cpplint
      cmake
      cmake-format
      llvmPackages.bintools
      lldb
    ];
  };
  config.specs.web = {
    lazy = true;
    data = with pkgs.vimPlugins; [
    ];
    postpkgs = with pkgs; [
      htmx-lsp
      htmx-lsp
      vscode-langservers-extracted
      typescript-language-server
      eslint
      prettier
      tailwindcss-language-server
      typescript-language-server
      eslint
      prettier
    ];
  };

  config.hosts.python3.withPackages = lib.mkIf config.specs.python.enable (py: [
    (py.debugpy.overrideAttrs {
      doCheck = false;
      doInstallCheck = false;
      pytestCheckPhase = "";
      installCheckPhase = "";
    })
    (py.pylsp-mypy.overrideAttrs {
      doCheck = false;
      doInstallCheck = false;
      pytestCheckPhase = "";
      installCheckPhase = "";
    })
    (py.pyls-isort.overrideAttrs {
      doCheck = false;
      doInstallCheck = false;
      pytestCheckPhase = "";
      installCheckPhase = "";
    })
    # py.python-lsp-server
    # py.python-lsp-black
    (py.pytest.overrideAttrs {
      doCheck = false;
      doInstallCheck = false;
      pytestCheckPhase = "";
      installCheckPhase = "";
    })
  ]);
  config.specs.python = {
    lazy = true;
    data = with pkgs.vimPlugins; [
      nvim-dap-python
    ];
    postpkgs = with pkgs; [
      (python311Packages.python-lsp-server.overrideAttrs {
        doCheck = false;
        doInstallCheck = false;
        pytestCheckPhase = "";
        installCheckPhase = "";
      })
      (python311Packages.debugpy.overrideAttrs {
        doCheck = false;
        doInstallCheck = false;
        pytestCheckPhase = "";
        installCheckPhase = "";
      })
      (python311Packages.pytest.overrideAttrs {
        doCheck = false;
        doInstallCheck = false;
        pytestCheckPhase = "";
        installCheckPhase = "";
      })
    ];
  };

  config.specs.go = {
    lazy = true;
    data = with pkgs.vimPlugins; [
      nvim-dap-go
    ];
    postpkgs = with pkgs; [
      gopls
      delve
      golint
      golangci-lint
      gotools
      go-tools
      go
      inputs.templ.packages.${stdenv.hostPlatform.system}.templ
    ];
  };
  config.info.javaExtras = lib.mkIf config.specs.jvm.enable {
    java-test = pkgs.vscode-extensions.vscjava.vscode-java-test;
    java-debug-adapter = pkgs.vscode-extensions.vscjava.vscode-java-debug;
    gradle-ls = pkgs.vscode-extensions.vscjava.vscode-gradle;
  };
  config.specs.jvm = {
    lazy = true;
    data = with pkgs.vimPlugins; [
      nvim-jdtls
    ];
    postpkgs = with pkgs; [
      jdt-language-server
      kotlin-language-server
      ktlint
    ];
  };
}
