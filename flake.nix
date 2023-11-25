# Copyright (c) 2023 BirdeeHub 
# Licensed under the MIT license 
{
  description = "A Lua-natic's neovim flake, with extra cats! nixCats!";
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
    # have not figured out how to download a debug adapter not on nixpkgs
    # Will be attempting to build this from source in an overlay
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
    flake-utils.lib.eachDefaultSystem (system: let
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
      # I sent it to another file because idk it seemed nicer
      nixVimBuilder = (import ./categories.nix) self pkgs inputs;

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

      packageDefinitions = {
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
      };
    in
    # see :help nixCats.flake.outputs.packages
    {
      # choose your default overlay package
      overlays = { default = self: super: { inherit (packageDefinitions) birdeeVim; }; }
        # this will make an overlay out of each of the packageDefinitions defined above
        // builtins.mapAttrs (name: value: (self: super: { ${name} = value; })) packageDefinitions;

      # choose your default package
      packages = { default = packageDefinitions.birdeeVim; }
        # this will add all packageDefinitions defined above
        // packageDefinitions;

      # choose your package for devShell
      # and whatever else you want in it.
      devShell = pkgs.mkShell {
        name = "nixCats.nvim";
        packages = [ packageDefinitions.birdeeVim ];
        inputsFrom = [ ];
        shellHook = ''
        '';
      };
    }
  );
}
