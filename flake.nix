{
  description = "A Lua-natic's neovim flake, with extra cats! nixCats!";
        # TO DO: 
        # connect debuggers for languages (dap & dapui installed)
        # install formatters

    # see :help nixCats.flake.inputs
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils = {
      url = "github:numtide/flake-utils";
      # inputs.nixpkgs.follows = "nixpkgs"; 
        # ^^ why does this throw a warning now that 
            # warning: 
            # input 'flake-utils' has an override for a non-existent input 'nixpkgs'
    };
    "bash-debug-adapter" = {
      url = "github:rogalmic/vscode-bash-debug";
      flake = false;
    };
    # If you want your plugin to be loaded by the standard overlay,
    # Then you should name it "plugins-something"
    # Theme
    "plugins-onedark-vim" = {
      url = "github:joshdick/onedark.vim";
      flake = false;
    };
    # "plugins-catppuccin" = {
    #   url = "github:catppuccin/nvim";
    #   flake = false;
    # };

    "plugins-gitsigns" = {
      url = "github:lewis6991/gitsigns.nvim";
      flake = false;
    };
    "plugins-which-key" = {
      url = "github:folke/which-key.nvim";
      flake = false;
    };
    "plugins-lualine" = {
      url = "github:nvim-lualine/lualine.nvim";
      flake = false;
    };
    "plugins-lspconfig" = {
      url = "github:neovim/nvim-lspconfig";
      flake = false;
    };
    "plugins-Comment" = {
      url = "github:numToStr/Comment.nvim";
      flake = false;
    };
    "plugins-nvim-luaref" = {
      url = "github:milisims/nvim-luaref";
      flake = false;
    };
    "plugins-harpoon" = {
      url = "github:ThePrimeagen/harpoon";
      flake = false;
    };
    "plugins-hlargs" = {
      url = "github:m-demare/hlargs.nvim";
      flake = false;
    };
    "plugins-marks" = {
      url = "github:chentoast/marks.nvim";
      flake = false;
    };
    "plugins-fidget" = {
      url = "github:j-hui/fidget.nvim/legacy";
      flake = false;
    };
    nixd.url = "github:nix-community/nixd";
    # I use this for autocomplete filler especially for comments. 
    "codeium" = {
      url = "github:Exafunction/codeium.nvim";
    };
    # I ask this questions I couldnt google the answer to and/or
    # need things I havent heard of. Its better than gpt and has context.
    # It also occasionally helps with goto definition.
    sg-nvim = {
      url = "github:sourcegraph/sg.nvim";
    };
  };

  # see :help nixCats.flake.outputs
  outputs = { self, nixpkgs, flake-utils, ... }@inputs:
    # This line makes this package availeable for all systems
    # ("x86_64-linux", "aarch64-linux", "i686-linux", "x86_64-darwin",...)
    flake-utils.lib.eachDefaultSystem (system:
      let
        # see :help nixCats.flake.outputs.overlays

        overlays = (import ./overlays inputs) ++ [
          # add any flake overlays here.
          inputs.nixd.outputs.overlays.default
          inputs.codeium.outputs.overlays.${system}.default
        ];
        pkgs = import nixpkgs {
          inherit system overlays;
          # config.allowUnfree = true;
        };

        # see :help nixCats.flake.outputs.builder

        nixVimBuilder = settings: categories: (import ./builder {
          # these are required
          inherit self pkgs;
          # you supply these when you apply this function
          inherit categories settings;

          # propagatedBuildInputs:
          # this section is for dependencies that should be available
          # at BUILD TIME for plugins. WILL NOT be available to PATH
          # However, they WILL be available to the shell 
          # and neovim path when using nix develop
          propagatedBuildInputs = {
            generalBuildInputs = with pkgs; [
            ];
          };

          # lspsAndRuntimeDeps:
          # this section is for dependencies that should be available
          # at RUN TIME for plugins. Will be available to path within neovim terminal
          # this includes LSPs
          lspsAndRuntimeDeps = {
            general = with pkgs; [
              universal-ctags
            ];
            telescope = with pkgs; [
              ripgrep
              fd
            ];
            AI = [
              inputs.codeium.outputs.packages.${system}.codeium-lsp

              inputs.sg-nvim.packages.${system}.default
              pkgs.nodejs
            ];
            java = with pkgs; [
              jdt-language-server
            ];
            kotlin = with pkgs; [
              jdt-language-server
              kotlin-language-server
            ];
            lua = with pkgs; [
              lua-language-server
            ];
            nix = with pkgs; [
              nix-doc
              nil
              nixd
            ];
            neonixdev = with pkgs; [
              # nix-doc tags will make your tags much better in nix
              # but only if you have nil as well for some reason
              nix-doc
              nil
              lua-language-server
              nixd
            ];
            bash = with pkgs; [
              bashdb # a bash debugger. seemed like an easy first debugger to add, and would be useful
              pkgs.stubbornRuntimeDeps.bash-debug-adapter
            ];
          };

          # This is for plugins that will load at startup without using packadd:
          startupPlugins = {
            neonixdev = [
              pkgs.vimPlugins.neodev-nvim
              pkgs.neovimPlugins.nvim-luaref
            ];
            AI = [
              pkgs.vimPlugins.codeium-nvim
              inputs.sg-nvim.packages.${system}.sg-nvim
              # cmp-tabnine
            ];
            customPlugins = with pkgs.customPlugins; [
            ];
            markdown = with pkgs.customPlugins; [
              markdown-preview-nvim
            ];
            telescope = with pkgs.vimPlugins; [
              telescope-fzf-native-nvim
              plenary-nvim
              telescope-nvim
            ];
            cmp = with pkgs.vimPlugins; [
              nvim-cmp
              luasnip
              cmp_luasnip
              cmp-buffer
              cmp-path
              cmp-nvim-lua
              cmp-nvim-lsp
              friendly-snippets
              cmp-cmdline
              cmp-nvim-lsp-signature-help
              cmp-cmdline-history
            ];
            treesitter = with pkgs.vimPlugins; [
              nvim-treesitter-textobjects
              nvim-treesitter.withAllGrammars
              # (nvim-treesitter.withPlugins (
              #   plugins: with plugins; [
              #     nix
              #     lua
              #   ]
              # ))
            ];
            gitPlugins = with pkgs.neovimPlugins; [
              # catppuccin
              onedark-vim
              gitsigns
              which-key
              lspconfig
              lualine
              Comment
              harpoon
              hlargs
              marks
              fidget
            ];
            general = with pkgs.vimPlugins; [
              lspkind-nvim
              vim-sleuth
              vim-fugitive
              vim-rhubarb
              vim-repeat
              nvim-surround
              eyeliner-nvim
              indent-blankline-nvim
              undotree
              nvim-web-devicons
              nui-nvim
              neo-tree-nvim
              nvim-dap
              nvim-dap-ui
              nvim-dap-virtual-text
            ];
          };

          # not loaded automatically at startup.
          # use with packadd in config to achieve something like lazy loading
          optionalPlugins = {
            customPlugins = with pkgs.customPlugins; [ ];
            gitPlugins = with pkgs.neovimPlugins; [ ];
            general = with pkgs.vimPlugins; [ ];
          };

          # environmentVariables:
          # this section is for environmentVariables that should be available
          # at RUN TIME for plugins. Will be available to path within neovim terminal
          environmentVariables = {
            test = {
              BIRDTVAR = "It worked!";
            };
          };

          # If you know what these are, you can provide custom ones by category here.
          # If you dont, check this link out:
          # https://github.com/NixOS/nixpkgs/blob/master/pkgs/build-support/setup-hooks/make-wrapper.sh
          extraWrapperArgs = {
            test = [
              '' --set BIRDTVAR2 "It worked again!"''
            ];
          };

          # there are more available sections, extraPythonPackages, extraPython3Packages, extraLuaPackages.
          # see :help nixCats.flake.outputs.builder and :help nixCats.flake.nixperts.nvimBuilder
        });

        # see :help nixCats.flake.outputs.settings
        settings = {
          birdee = {
            wrapRc = true;
            # to use a different lua folder other than myLuaConf, change this value:
            RCName = "myLuaConf";
            viAlias = true;
            vimAlias = true;
            withNodeJs = false;
            withRuby = true;
            extraName = "";
            withPython3 = true;
          };
          unwrappedLua = {
            wrapRc = false;
            viAlias = true;
          };
        };



        # And then build a package with specific categories from above here:
        # All categories you wish to include must be marked true,
        # but false may be omitted.
        # This entire set is also passed to nixCats for querying within the lua.
        # It is passed as a Lua table with values name = boolean. same as here.

        # see :help nixCats.flake.outputs.packaging
        birdeeVim = nixVimBuilder settings.birdee {
          generalBuildInputs = true;
          bash = true;
          cmp = true;
          telescope = true;
          treesitter = true;
          markdown = true;
          customPlugins = true;
          gitPlugins = true;
          general = true;
          neonixdev = true;
          AI = true;
          java = false; # is included in kotlin category
          kotlin = true;
          test = true;
          lspDebugMode = false;
          colorscheme = "onedark";
          # see :help nixCats
        };
        noAIneodev = nixVimBuilder settings.birdee {
          generalBuildInputs = true;
          cmp = true;
          telescope = true;
          treesitter = true;
          markdown = true;
          customPlugins = true;
          gitPlugins = true;
          general = true;
          neonixdev = true;
          AI = false;
          lspDebugMode = true;
          test = true;
          colorscheme = "onedark";
        };
        coffeeVim = nixVimBuilder settings.birdee {
          generalBuildInputs = true;
          cmp = true;
          telescope = true;
          treesitter = true;
          markdown = true;
          customPlugins = true;
          gitPlugins = true;
          general = true;
          AI = true;
          java = true;
          colorscheme = "onedark";
        };
        kotlinVim = nixVimBuilder settings.birdee {
          generalBuildInputs = true;
          cmp = true;
          telescope = true;
          treesitter = true;
          markdown = true;
          customPlugins = true;
          gitPlugins = true;
          general = true;
          AI = true;
          kotlin = true;
          java = false; #is included in kotlin category
          colorscheme = "onedark";
        };
        birdeeUnwrapped = nixVimBuilder settings.unwrappedLua {
          generalBuildInputs = true;
          bash = true;
          cmp = true;
          telescope = true;
          treesitter = true;
          markdown = true;
          customPlugins = true;
          gitPlugins = true;
          general = true;
          neonixdev = true;
          AI = true;
          java = false; # is included in kotlin category
          kotlin = true;
          test = true;
          lspDebugMode = false;
          colorscheme = "onedark";
        };

      in



      # see :help nixCats.flake.outputs.packages

      { # choose your package
        overlays = {
          default = final: prev: { inherit birdeeVim; };
          birdeeVim = final: prev: { inherit birdeeVim; };
          noAIneodev = final: prev: { inherit noAIneodev; };
          coffeeVim = final: prev: { inherit coffeeVim; };
          kotlinVim = final: prev: { inherit kotlinVim; };
          birdeeUnwrapped = final: prev: { inherit kotlinVim; };
        };
        devShell = pkgs.mkShell {
          name = "neodevshell";
          packages = [ noAIneodev ];
          inputsFrom = [ ];
          shellHook = ''
          '';
        };
        packages = {
          default = birdeeVim;
          inherit birdeeVim noAIneodev coffeeVim kotlinVim birdeeUnwrapped;
        };
      }



    ); # end of flake utils, which returns the value of outputs
}
