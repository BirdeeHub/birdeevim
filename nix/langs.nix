inputs:
{
  config,
  wlib,
  lib,
  pkgs,
  ...
}:
{
  _file = ./langs.nix;
  key = ./langs.nix;
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

  config.specs.nix = {
    mainInfo.nixdExtras = {
      nixpkgs = "import ${builtins.path { path = pkgs.path; }} {}";
      get_configs =
        lib.generators.mkLuaInline # lua
          ''function(type, path) return [[import ${./nixd.nix} ${
            builtins.path { path = pkgs.path; }
          } "]] .. type .. [[" ]] .. (path or "./.") end'';
    };
    enable = lib.mkIf config.settings.minimal (lib.mkDefault true);
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
    enable = lib.mkIf config.settings.minimal (lib.mkDefault true);
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
  config.specs.fennel =
    let
      conjure_nocheck = (
        pkgs.vimPlugins.conjure.overrideAttrs (prev: {
          doCheck = false;
          nvimSkipModules = (prev.nvimSkipModules or [ ]) ++ [ "conjure-spec.process_spec" ];
        })
      );
    in
    {
      lazy = true;
      data = with pkgs.vimPlugins; [
        {
          data = config.nvim-lib.neovimPlugins.fn_finder;
          lazy = false;
        }
        conjure_nocheck
        (cmp-conjure.overrideAttrs {
          dependencies = [ conjure_nocheck ];
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
      config.nvim-lib.neovimPlugins.rustaceanvim
    ];
    postpkgs = with pkgs; [
      (config.info.rust.toolchain or inputs.fenix.packages.${stdenv.hostPlatform.system}.latest.toolchain)
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
      vscode-langservers-extracted
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
  config.specs.jvm = {
    mainInfo.javaExtras = {
      java-test = pkgs.vscode-extensions.vscjava.vscode-java-test;
      java-debug-adapter = pkgs.vscode-extensions.vscjava.vscode-java-debug;
      gradle-ls = pkgs.vscode-extensions.vscjava.vscode-gradle;
    };
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
