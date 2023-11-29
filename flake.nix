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
    nixCats.url = "github:BirdeeHub/nixCats-nvim";
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
      url = "github:ThePrimeagen/harpoon";
      flake = false;
    };
    "plugins-hlargs" = {
      url = "github:m-demare/hlargs.nvim";
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
  outputs = { self, nixpkgs, flake-utils, nixCats, ... }@inputs:
    flake-utils.lib.eachDefaultSystem (system: let
      # see :help nixCats.flake.outputs.overlays
      overlays = (import ./overlays inputs) ++ [
        (nixCats.outputs.standardPluginOverlay.${system} inputs)
        # add any flake overlays here.
        inputs.nixd.outputs.overlays.default
        inputs.codeium.outputs.overlays.${system}.default
      ];
      pkgs = import nixpkgs {
        inherit system overlays;
        # config.allowUnfree = true;
      };
      nixCatsFreshest = nixCats.outputs.customBuilders.${system}.newLuaPath;

      # see :help nixCats.flake.outputs.builder
      nixVimBuilder = nixCatsFreshest self pkgs categoryDefinitions;

      categoryDefinitions = {
        # see :help nixCats.flake.outputs.builder
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
            inputs.codeium.outputs.packages.${pkgs.system}.codeium-lsp

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
            pkgs.neovimDebuggers.bash-debug-adapter # I unfortunately need to build it I think... IDK how yet.
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
          markdown = with pkgs.customPlugins; [
            markdown-preview-nvim
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
            # theme
            onedark-vim
            # catppuccin-nvim
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
            BASHDAP = "${pkgs.neovimDebuggers.bash-debug-adapter}";
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
      };

      # see :help nixCats.flake.outputs.settings
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
          # so that it looks for .config/birdeevim instead
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
      };

      # just to select the right thing out of bitwarden. 
      # Don't get excited its just a UUID
      bitwardenItemIDs = {
        codeium = "notes d9124a28-89ad-4335-b84f-b0c20135b048";
        cody = "notes d0bddbff-ec1f-4151-a2a7-b0c20134eb34";
      };

      packageDefinitions = {
        # see :help nixCats.flake.outputs.packaging
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
            java = true; # is included in kotlin category
            kotlin = true;
            test = true;
            lspDebugMode = false;
            colorscheme = "onedark";
            # see :help nixCats
          };
        };
        noAIneodev = {
          settings = settings.birdee;
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
            colorscheme = "onedark";
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
    # see :help nixCats.flake.outputs.packages
    {
      # choose your default package
      packages = { default = (nixVimBuilder packageDefinitions.birdeeVim); }
        # this will add all packageDefinitions defined above
        // (builtins.mapAttrs (value: nixVimBuilder value) packageDefinitions);

      # choose your package for devShell
      # and whatever else you want in it.
      devShell = pkgs.mkShell {
        name = "birdeeVim";
        packages = [ (nixVimBuilder packageDefinitions.birdeeVim) ];
        inputsFrom = [ ];
        shellHook = ''
        '';
      };

      # this will make an overlay out of each of the packageDefinitions defined above
      overlays = let
        # choose the name and value of your defaultOverlayPackage
        defaultOverlayPackage = {
          name = "birdeeVim";
          value = packageDefinitions.birdeeVim;
        };
      in
      { default = (self: super: { ${defaultOverlayPackage.name} = nixVimBuilder defaultOverlayPackage.value; }); } 
      // (builtins.mapAttrs (name: value: (self: super: { ${name} = nixVimBuilder value; })) packageDefinitions);

      # To choose settings and categories from the flake that calls this flake.
      customPackager = nixVimBuilder;

      # The overlay that allows for auto import with plugins-pluginname
      standardPluginOverlay = nixCats.outputs.standardPluginOverlay.${system};
      # You may use these to modify some or all of your categoryDefinitions
      customBuilders = {
        # These 2 will still recieve the flake's lua when wrapRc = true;
        fresh = nixCatsFreshest self;
        merged = newPkgs: categoryDefs:
          (nixCatsFreshest self (pkgs // newPkgs) (categoryDefinitions // categoryDefs));
        # for these ones, you may specify a new path to lua that can be used with wrapRc = true
        newLuaPath = nixCatsFreshest;
        mergedNewLuaPath = path: newPkgs: categoryDefs:
          (nixCatsFreshest path (pkgs // newPkgs) (categoryDefinitions // categoryDefs));
      };
    }
  );
}
