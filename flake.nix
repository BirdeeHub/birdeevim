# Copyright (c) 2023 BirdeeHub 
# Licensed under the MIT license 
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
    codeium.url = "github:Exafunction/codeium.nvim";
    # I ask this questions I couldnt google the answer to and/or
    # need things I havent heard of. It has better code context than gpt.
    # It also occasionally helps with goto definition.
    sg-nvim.url = "github:sourcegraph/sg.nvim";
  };

  # see :help nixCats.flake.outputs
  outputs = { self, nixpkgs, flake-utils, ... }@inputs:
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

          propagatedBuildInputs = {
            generalBuildInputs = with pkgs; [
            ];
          };

          lspsAndRuntimeDeps = {
            general = with pkgs; [
              universal-ctags
            ];
            telescope = with pkgs; [
              ripgrep
              fd
            ];
            bitwarden = with pkgs; [
              bitwarden-cli
            ];
            AI = [
              inputs.codeium.outputs.packages.${system}.codeium-lsp

              inputs.sg-nvim.packages.${system}.default
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
              pkgs.nixCatsDebug.bash-debug-adapter
            ];
          };

          startupPlugins = {
            neonixdev = [
              pkgs.vimPlugins.neodev-nvim
              pkgs.vimPlugins.neoconf-nvim
              pkgs.neovimPlugins.nvim-luaref
            ];
            AI = [
              pkgs.vimPlugins.codeium-nvim
              inputs.sg-nvim.packages.${system}.sg-nvim
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

          optionalPlugins = {
            customPlugins = with pkgs.customPlugins; [ ];
            gitPlugins = with pkgs.neovimPlugins; [ ];
            general = with pkgs.vimPlugins; [ ];
          };

          environmentVariables = {
            AI = {
              # I provision the auth in the lua from bitwarden
              # so I don't have to put my token on github
              # But this is a way you could do it
              # SRC_ENDPOINT = "https://sourcegraph.com";
              # SRC_ACCESS_TOKEN = builtins.readFile ./secrets/codyToken;
              # this only works if you use the --impure option when building.
              # SRC_ACCESS_TOKEN = builtins.readFile /absolute/path/to/secrets/codyToken;
            };
            test = {
              BIRDTVAR = "It worked!";
            };
            bash = {
              BASHDAP = "${pkgs.nixCatsDebug.bash-debug-adapter}";
            };
          };

          extraWrapperArgs = {
          # https://github.com/NixOS/nixpkgs/blob/master/pkgs/build-support/setup-hooks/make-wrapper.sh
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
            RCName = "birdeeLua";
            # so that it finds my ai auths in ~/.cache/birdeevim
            configDirName = "birdeevim";
            viAlias = true;
            vimAlias = true;
            withNodeJs = true;
            withRuby = true;
            extraName = "";
            withPython3 = true;
          };
          unwrappedLua = {
            # so that it looks for .config/birdeevim instead
            configDirName = "birdeevim";
            RCName = "birdeeLua";
            wrapRc = false;
            withNodeJs = true;
            viAlias = true;
            vimAlias = true;
          };
          unwrapNOjs = {
            configDirName = "birdeevim";
            RCName = "birdeeLua";
            wrapRc = false;
            withNodeJs = false;
            viAlias = true;
            vimAlias = true;
          };
        };

        # just to select the right thing out of bitwarden. 
        # Don't get excited its just a UUID
        bitwardenItemIDs = {
          codeium = "notes d9124a28-89ad-4335-b84f-b0c20135b048";
          cody = "notes d0bddbff-ec1f-4151-a2a7-b0c20134eb34";
        };

        # see :help nixCats.flake.outputs.packaging
        birdeeVim = nixVimBuilder settings.birdee {
          inherit bitwardenItemIDs;
          bitwarden = true;
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
          inherit bitwardenItemIDs;
          bitwarden = true;
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
          inherit bitwardenItemIDs;
          bitwarden = true;
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
          inherit bitwardenItemIDs;
          bitwarden = true;
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
        noAIunwrapped = nixVimBuilder settings.unwrapNOjs {
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
          AI = false;
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
          birdeeUnwrapped = final: prev: { inherit birdeeUnwrapped; };
          noAIunwrapped = final: prev: { inherit noAIunwrapped; };
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
          inherit birdeeVim noAIneodev coffeeVim kotlinVim birdeeUnwrapped noAIunwrapped;
        };
      }



    ); # end of flake utils, which returns the value of outputs
}
