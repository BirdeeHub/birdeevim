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
    ./nvim-lib.nix
  ];
  options.settings.wrapRc = lib.mkOption {
    type = lib.types.bool;
    default = true;
  };
  config.settings.config_directory =
    if config.settings.wrapRc then config.settings.wrapped_config else config.settings.unwrapped_config;
  options.settings.wrapped_config = lib.mkOption {
    type = wlib.types.stringable;
    default = ./.;
  };
  options.settings.unwrapped_config = lib.mkOption {
    type = wlib.types.nonEmptyline;
    default = "/home/birdee/.birdeevim";
  };
  config.settings.dont_link = config.binName != "nvim";
  config.binName = if config.settings.wrapRc then "nvim" else "vim";
  config.settings.aliases = lib.mkIf config.settings.wrapRc [ "vi" ];
  config.package = inputs.neovim-nightly-overlay.packages.${pkgs.stdenv.hostPlatform.system}.neovim;
  config.env.NVIM_APPNAME = "birdeevim";

  config.specMods =
    { parentSpec, ... }:
    {
      config.collateGrammars = lib.mkDefault (parentSpec.collateGrammars or true);
    };

  config.settings.nvim_lua_env = lp: with lp; [ fennel ];

  # The makeWrapper options are available
  config.extraPackages = with pkgs; [
    lazygit
    lua-language-server
    tree-sitter
    stylua
    nixd
    alejandra
    marksman
    python311Packages.pylatexenc
    harper
    fnlfmt
    fennel-ls
    universal-ctags
    ripgrep
    fd
    ast-grep
    lazygit
    jq
    inputs.roc.packages.${stdenv.hostPlatform.system}.lang-server
    jdt-language-server
    zls
    zig
    zig-shell-completions
    kotlin-language-server
    ktlint
    gopls
    delve
    golint
    golangci-lint
    gotools
    go-tools
    go
    typst
    typst-live
    tinymist
    websocat
    elixir-ls
    (config.info.toolchain or inputs.fenix.packages.${stdenv.hostPlatform.system}.latest.toolchain)
    rustup
    llvmPackages.bintools
    lldb
    nix-doc
    nil
    lua-language-server
    nixd
    nixfmt
    imagemagick
    ueberzugpp
    nodePackages.bash-language-server
    inputs.templ.packages.${stdenv.hostPlatform.system}.templ
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
    bitwarden-cli
    (inputs.wrappers.wrappedModules.opencode.wrap {
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
    clang-tools
    valgrind
    cmake-language-server
    cpplint
    cmake
    cmake-format
    (inputs.wrappers.lib.wrapPackage [
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

  config.info.javaExtras = {
    java-test = pkgs.vscode-extensions.vscjava.vscode-java-test;
    java-debug-adapter = pkgs.vscode-extensions.vscjava.vscode-java-debug;
    gradle-ls = pkgs.vscode-extensions.vscjava.vscode-gradle;
  };
  config.info.nixdExtras = {
    nixpkgs = "import ${builtins.path { path = pkgs.path; }} {}";
    get_configs =
      lib.generators.mkLuaInline # lua
        ''function(type, path) return [[import ${./misc_nix/nixd.nix} ${
          builtins.path { path = pkgs.path; }
        } "]] .. type .. [[" ]] .. (path or "./.") end'';
  };
  config.info.bitwarden_uuids = {
    gemini = [
      "notes"
      "bcd197b5-ba11-4c86-8969-b2bd01506654"
    ];
    windsurf = [
      "notes"
      "d9124a28-89ad-4335-b84f-b0c20135b048"
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

  config.specs.general = with pkgs.vimPlugins; [
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
    neovimPlugins.fn_finder
    neovimPlugins.rustaceanvim
    luvit-meta
  ];

  config.specs.lazy = {
    lazy = true;
    after = [ "general" ];
    data = with pkgs.vimPlugins; [
      vim-dadbod
      vim-dadbod-ui
      vim-dadbod-completion
      image-nvim
      vim-cmake
      clangd_extensions-nvim
      nvim-dap-python
      otter-nvim
      nvim-dap-go
      (cmp-conjure.overrideAttrs {
        dependencies = [
          (conjure.overrideAttrs (prev: {
            doCheck = false;
            nvimSkipModules = (prev.nvimSkipModules or [ ]) ++ [ "conjure-spec.process_spec" ];
          }))
        ];
      })
      nvim-jdtls
      typst-preview-nvim
      lazydev-nvim
      windsurf-nvim
      neovimPlugins.opencode-nvim
      nvim-dap
      nvim-dap-ui
      nvim-dap-virtual-text
      img-clip-nvim
      nvim-highlight-colors
      which-key-nvim
      eyeliner-nvim
      todo-comments-nvim
      vim-startuptime
      neovimPlugins.visual-whitespace
      render-markdown-nvim
      markdown-preview-nvim
      luasnip
      cmp-cmdline
      blink-cmp
      blink-compat
      colorful-menu-nvim
      neovimPlugins.treesitter-textobjects
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

  config.hosts.ruby.gemdir = ./misc_nix/ruby_provider;
  config.hosts.python3.withPackages = py: [
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
  ];
}
