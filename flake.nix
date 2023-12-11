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
    nixCats.url = "github:BirdeeHub/nixCats-nvim/v3.0_update";
    # have not figured out how to download a debug adapter not on nixpkgs
    # Will be attempting to build this from source in an overlay
    "bash-debug-adapter" = {
      url = "github:rogalmic/vscode-bash-debug";
      flake = false;
    };
    # If you want your plugin to be loaded by the standard overlay,
    # Then you should name it "plugins-something"
    "plugins-nvim-luaref" = {
      url = "github:milisims/nvim-luaref";
      flake = false;
    };
    "plugins-harpoon" = {
      url = "github:ThePrimeagen/harpoon/harpoon2";
      flake = false;
    };
    # I use this for autocomplete filler especially for comments. 
    codeium.url = "github:Exafunction/codeium.nvim/822e762567a0bf50b1a4e733c8c93691934d7606";
    # I ask this questions I couldnt google the answer to and/or
    # need things I havent heard of. It has better code context than gpt.
    # It also occasionally helps with goto definition.
    sg-nvim.url = "github:sourcegraph/sg.nvim";
  };

  # see :help nixCats.flake.outputs
  outputs = { self, nixpkgs, flake-utils, nixCats, ... }@inputs:
    flake-utils.lib.eachDefaultSystem (system: let
      utils = nixCats.utils.${system};

      otherOverlays = [ (utils.mergeOverlayLists nixCats.otherOverlays.${system}
      ((import ./overlays inputs) ++ [
        # add any flake overlays here.
        inputs.codeium.overlays.${system}.default
      ])) ];
      pkgs = import nixpkgs {
        inherit system;
        overlays = otherOverlays ++ [
            (utils.standardPluginOverlay (nixCats.inputs // inputs))
          ];
        # config.allowUnfree = true;
      };

      baseBuilder = nixCats.customBuilders.${system}.fresh;
      nixCatsBuilder = baseBuilder self pkgs categoryDefinitions packageDefinitions;

      categoryDefinitions = packageDef: {

        propagatedBuildInputs = {
          generalBuildInputs = with pkgs; [
          ];
        };

        lspsAndRuntimeDeps = {
          general = with pkgs; [
            universal-ctags
            ripgrep
            fd
          ];
          bitwarden = with pkgs; [
            bitwarden-cli
          ];
          AI = [
            inputs.codeium.packages.${pkgs.system}.codeium-lsp
            inputs.sg-nvim.packages.${pkgs.system}.default
          ];
          java = with pkgs; [
            jdt-language-server
          ];
          kotlin = with pkgs; [
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
            pkgs.nixCatsBuilds.bash-debug-adapter # I unfortunately need to build it I think... IDK how yet.
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
            inputs.sg-nvim.packages.${pkgs.system}.sg-nvim
          ];
          markdown = with pkgs.vimPlugins; [
            pkgs.nixCatsBuilds.markdown-preview-nvim
          ];
          debug = with pkgs.vimPlugins; [
            nvim-dap
            nvim-dap-ui
            nvim-dap-virtual-text
          ];
          gitPlugins = with pkgs.neovimPlugins; [
            harpoon
            hlargs
            fidget
          ];
          general = with pkgs.vimPlugins; [
            (builtins.getAttr packageDef.categories.colorscheme { 
                "onedark" = onedark-vim;
                "catppuccin" = catppuccin-nvim;
                "catppuccin-mocha" = catppuccin-nvim;
                "tokyonight" = tokyonight-nvim;
                "tokyonight-day" = tokyonight-nvim;
              }
            ) 
          ] ++ [
            # telescope
            telescope-fzf-native-nvim
            plenary-nvim
            telescope-nvim
            # treesitter
            nvim-treesitter-textobjects
            nvim-treesitter.withAllGrammars
            # (nvim-treesitter.withPlugins (
            #   plugins: with plugins; [
            #     nix
            #     lua
            #   ]
            # ))
            # cmp stuff
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
            lspkind-nvim
            # other
            conform-nvim
            nvim-lspconfig
            lualine-nvim
            gitsigns-nvim
            which-key-nvim
            comment-nvim
            marks-nvim
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
          ];
        };

        optionalPlugins = {
          customPlugins = with pkgs.nixCatsBuilds; [ ];
          gitPlugins = with pkgs.neovimPlugins; [ ];
          general = with pkgs.vimPlugins; [ ];
        };

        environmentVariables = {
          test = {
            BIRDTVAR = "It worked!";
          };
          bash = {
            BASHDAP = "${pkgs.nixCatsBuilds.bash-debug-adapter}";
          };
        };

        extraWrapperArgs = {
        # https://github.com/NixOS/nixpkgs/blob/master/pkgs/build-support/setup-hooks/make-wrapper.sh
          test = [
            '' --set BIRDTVAR2 "It worked again!"''
          ];
        };

      };

      settings = {
        birdee = {
          wrapRc = true;
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
          configDirName = "birdeevim";
          wrapRc = false;
          withNodeJs = true;
          viAlias = true;
          vimAlias = true;
        };
        unwrapNOjs = {
          configDirName = "birdeevim";
          wrapRc = false;
          withNodeJs = false;
          viAlias = true;
          vimAlias = true;
        };
        wrappedNOjs = {
          configDirName = "birdeevim";
          wrapRc = true;
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
        minimal = {settings = settings.unwrapNOjs; categories = {};};
        birdeeVim = {
          settings = settings.birdee;
          categories = {
            inherit bitwardenItemIDs;
            bitwarden = true;
            generalBuildInputs = true;
            bash = true;
            debug = true;
            markdown = true;
            customPlugins = true;
            gitPlugins = true;
            general = true;
            neonixdev = true;
            AI = true;
            java = true;
            kotlin = true;
            test = true;
            lspDebugMode = false;
            colorscheme = "onedark";
          };
        };
        birdeeUnwrapped = {
          settings = settings.unwrappedLua;
          categories = {
            inherit bitwardenItemIDs;
            bitwarden = true;
            generalBuildInputs = true;
            bash = true;
            debug = true;
            markdown = true;
            customPlugins = true;
            gitPlugins = true;
            general = true;
            neonixdev = true;
            AI = true;
            java = true;
            kotlin = true;
            test = true;
            lspDebugMode = false;
            colorscheme = "onedark";
          };
        };
        coffeeVim = {
          settings = settings.birdee;
          categories = {
            inherit bitwardenItemIDs;
            bitwarden = true;
            generalBuildInputs = true;
            debug = true;
            markdown = true;
            customPlugins = true;
            gitPlugins = true;
            general = true;
            AI = true;
            java = true;
            lspDebugMode = false;
            colorscheme = "catppuccin";
          };
        };
        kotlinVim = {
          settings = settings.birdee;
          categories = {
            inherit bitwardenItemIDs;
            bitwarden = true;
            generalBuildInputs = true;
            debug = true;
            markdown = true;
            customPlugins = true;
            gitPlugins = true;
            general = true;
            AI = true;
            java = true;
            kotlin = true;
            lspDebugMode = false;
            colorscheme = "catppuccin";
          };
        };
        noAIneodev = {
          settings = settings.wrappedNOjs;
          categories = {
            generalBuildInputs = true;
            debug = true;
            markdown = true;
            customPlugins = true;
            gitPlugins = true;
            general = true;
            neonixdev = true;
            test = true;
            lspDebugMode = true;
            colorscheme = "onedark";
          };
        };
        noAIunwrapped = {
          settings = settings.unwrapNOjs;
          categories = {
            generalBuildInputs = true;
            bash = true;
            debug = true;
            markdown = true;
            customPlugins = true;
            gitPlugins = true;
            general = true;
            neonixdev = true;
            java = true;
            kotlin = true;
            test = true;
            lspDebugMode = false;
            colorscheme = "onedark";
          };
        };
      };
    in
    {
      packages = utils.mkPackages nixCatsBuilder packageDefinitions "birdeeVim";

      overlays = utils.mkOverlays nixCatsBuilder packageDefinitions "birdeeVim";

      devShell = pkgs.mkShell {
        name = "birdeeVim";
        packages = [ (nixCatsBuilder "birdeeVim") ];
        inputsFrom = [ ];
        shellHook = ''
        '';
      };

      # To choose settings and categories from the flake that calls this flake.
      customPackager = baseBuilder self pkgs categoryDefinitions;

      # You may use these to modify some or all of your categoryDefinitions
      customBuilders = {
        fresh = baseBuilder;
        keepLua = baseBuilder self;
      };
      inherit utils;

      # and you export this so people dont have to redefine stuff.
      inherit otherOverlays;
      inherit categoryDefinitions;
      inherit packageDefinitions;

      # we also export a nixos module to allow configuration from configuration.nix
      nixosModules.default = utils.mkNixosModules {
        defaultPackageName = "birdeeVim";
        luaPath = "${self}";
        inherit nixpkgs inputs baseBuilder otherOverlays 
          pkgs categoryDefinitions packageDefinitions;
      };
      # and the same for home manager
      homeModule = utils.mkHomeModules {
        defaultPackageName = "birdeeVim";
        luaPath = "${self}";
        inherit nixpkgs inputs baseBuilder otherOverlays 
          pkgs categoryDefinitions packageDefinitions;
      };

    }
  ) // { templates = nixCats.utils."x86_64-linux".templates; };
}
