inputs: let
  inherit (inputs.nixCats) utils;
in { pkgs, settings, categories, name, extra, mkPlugin, ... }@packageDef: {

  extraCats = {
    kotlin = [
      [ "java" ]
    ];
    AI = [
      [ "AI" "default" ]
    ];
  };

  environmentVariables = {
    test = {
      BIRDTVAR = "It worked!";
    };
  };
  sharedLibraries = {};
  # https://github.com/NixOS/nixpkgs/blob/master/pkgs/build-support/setup-hooks/make-wrapper.sh
  extraWrapperArgs = {};

  # python.withPackages or lua.withPackages
  # vim.g.python3_host_prog
  # :!nvim-python3
  python3.libraries = {
    python = (py:[
      # NOTE: check disabled globally for nvim because they take SO LONG OMG
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
      # py.pylint
      # python-lsp-ruff
      # pyls-flake8
      # pylsp-rope
      # yapf
      # autopep8
      # py.google-generativeai
    ]);
  };

  # populates $LUA_PATH and $LUA_CPATH
  extraLuaPackages = {
    fennel = [ (lp: with lp; [ fennel ]) ];
    # other = [ (lp: with lp; [ tomlua ]) ];
  };

  lspsAndRuntimeDeps = with pkgs; {
    portableExtras = [
      xclip
      wl-clipboard
      git
      nix
      coreutils-full
      curl
    ];
    markdown = [
      marksman
      python311Packages.pylatexenc
      harper
    ];
    fennel = [
      fnlfmt
      fennel-ls
    ];
    general = {
      core = [
        universal-ctags
        ripgrep
        fd
        ast-grep
        lazygit
        jq
      ];
    };
    AI = {
      default = [
        bitwarden-cli
      ];
      opencode = [
        opencode
      ];
    };
    roc = [
      inputs.roc.packages.${stdenv.hostPlatform.system}.lang-server
    ];
    java = [
      jdt-language-server
    ];
    zig = [
      zls
      zig
      zig-shell-completions
    ];
    kotlin = [
      # kotlin-lsp
      kotlin-language-server
      ktlint
    ];
    go = [
      gopls
      delve
      golint
      golangci-lint
      gotools
      go-tools
      go
    ];
    elixir = [
      elixir-ls
    ];
    web = {
      templ = with inputs; [
        templ.packages.${stdenv.hostPlatform.system}.templ
      ];
      tailwindcss = [
        tailwindcss-language-server
      ];
      HTMX = [
        htmx-lsp
      ];
      HTML = [
        vscode-langservers-extracted
      ];
      JS = with nodePackages; [
        typescript-language-server
        eslint
        prettier
      ];
    };
    rustToolchain = [
      (extra.rust.toolchain or inputs.fenix.packages.${stdenv.hostPlatform.system}.latest.toolchain)
    ];
    rust = [
      rustup
      llvmPackages.bintools
      lldb
    ];
    lua = [
      lua-language-server
    ];
    typst = [
      typst
      typst-live
      tinymist
      websocat
    ];
    nix = [
      nix-doc
      nil
      nixd
      nixfmt-rfc-style
    ];
    neonixdev = [
      nix-doc
      nil
      lua-language-server
      nixd
      nixfmt-rfc-style
    ];
    vimagePreview = [
      imagemagick
      ueberzugpp
    ];
    bash = [
      nodePackages.bash-language-server
    ];
    python = with python311Packages; [
      # jedi-language-server
      (python-lsp-server.overrideAttrs {
        doCheck = false;
        doInstallCheck = false;
        pytestCheckPhase = "";
        installCheckPhase = "";
      })
      (debugpy.overrideAttrs {
        doCheck = false;
        doInstallCheck = false;
        pytestCheckPhase = "";
        installCheckPhase = "";
      })
      (pytest.overrideAttrs {
        doCheck = false;
        doInstallCheck = false;
        pytestCheckPhase = "";
        installCheckPhase = "";
      })
      # pylint
      # python-lsp-ruff
      # pyls-flake8
      # pylsp-rope
      # yapf
      # autopep8
    ];
    C = [
      clang-tools
      valgrind
      cmake-language-server
      cpplint
      cmake
      cmake-format
    ];
    SQL = [
    ];
    mass_find_and_replace = {
      scooter = [
        (inputs.wrappers.lib.wrapPackage {
          inherit pkgs;
          package = pkgs.scooter;
          flags."--config-dir" = "${placeholder "out"}/share/bundled_config";
          drv.passAsFile = [ "scootcfg" ];
          drv.scootcfg = /*toml*/''
            [editor_open]
            command = "${name} --server $NVIM --remote-send '<cmd>lua require('scooter').EditLineFromScooter(\"%file\", %line)<CR>'"
          '';
          drv.postBuild = ''
            mkdir -p "$out/share/bundled_config"
            { [ -e "$scootcfgPath" ] && cat "$scootcfgPath" || echo "$scootcfg"; } > "$out/share/bundled_config/config.toml"
          '';
        })
      ];
    };
  };

  startupPlugins = with pkgs.vimPlugins; {
    theme = builtins.getAttr (extra.colorscheme or "onedark") {
      "onedark" = onedarkpro-nvim;
      "onedark_dark" = onedarkpro-nvim;
      "onedark_vivid" = onedarkpro-nvim;
      "onelight" = onedarkpro-nvim;
      "catppuccin" = catppuccin-nvim;
      "catppuccin-mocha" = catppuccin-nvim;
      "moonfly" = vim-moonfly-colors;
      "tokyonight" = tokyonight-nvim;
      "tokyonight-day" = tokyonight-nvim;
    };
    general = [
      pkgs.neovimPlugins.lze
      pkgs.neovimPlugins.lzextras
      oil-nvim
      vim-repeat
      pkgs.neovimPlugins.nvim-luaref
      nvim-nio
      nui-nvim
      nvim-web-devicons
      plenary-nvim
      mini-nvim
      pkgs.neovimPlugins.snacks-nvim
      nvim-ts-autotag
      pkgs.neovimPlugins.argmark
      pkgs.neovimPlugins.tmux-navigate
    ];
    other = [
      tomlua
      pkgs.neovimPlugins.shelua
      # (pkgs.neovimUtils.grammarToPlugin (pkgs.tree-sitter-grammars.tree-sitter-nu.overrideAttrs (p: { installQueries = true; })))
    ];
    mass_find_and_replace = {
      spectre = [
        nvim-spectre
      ];
    };
    lua = [
      luvit-meta
    ];
    fennel = [
      pkgs.neovimPlugins.fn_finder
    ];
    rust = [
      pkgs.neovimPlugins.rustaceanvim
    ];
    neonixdev = [
      luvit-meta
    ];
  };

  optionalPlugins = with pkgs.vimPlugins; {
    SQL = [
      vim-dadbod
      vim-dadbod-ui
      vim-dadbod-completion
    ];
    vimagePreview = [
      image-nvim
    ];
    C = [
      vim-cmake
      clangd_extensions-nvim
    ];
    python = [
      nvim-dap-python
    ];
    otter = [
      otter-nvim
    ];
    go = [
      nvim-dap-go
    ];
    fennel = [
      (conjure.overrideAttrs { doCheck = false; })
      cmp-conjure
    ];
    java = [
      nvim-jdtls
    ];
    typst = [
      typst-preview-nvim
    ];
    neonixdev = [
      lazydev-nvim
    ];
    AI = {
      companion = [
        codecompanion-nvim
      ];
      minuet = [
        minuet-ai-nvim
      ];
      opencode = [
        pkgs.neovimPlugins.opencode-nvim
      ];
      windsurf = [
        windsurf-nvim
      ];
    };
    debug = [
      nvim-dap
      nvim-dap-ui
      nvim-dap-virtual-text
    ];
    other = [
      img-clip-nvim
      nvim-highlight-colors
      which-key-nvim
      eyeliner-nvim
      todo-comments-nvim
      vim-startuptime
      pkgs.neovimPlugins.visual-whitespace
    ];
    markdown = [
      render-markdown-nvim
      markdown-preview-nvim
    ];
    general = with pkgs.neovimPlugins; {
      blink = with pkgs.vimPlugins; [
        luasnip
        cmp-cmdline
        blink-cmp
        blink-compat
        colorful-menu-nvim
      ];
      core = [
        nvim-treesitter-textobjects
        nvim-treesitter.withAllGrammars
        vim-rhubarb
        vim-fugitive
        pkgs.neovimPlugins.nvim-lspconfig
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
  };
}
