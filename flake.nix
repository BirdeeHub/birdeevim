{
  description = "Birdee's Neovim flake with mostly regular Lua config.";
        # TO DO: 
        # install debuggers for languages (dap & dapui installed)
        # install formatters
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils = {
      url = "github:numtide/flake-utils";
      # inputs.nixpkgs.follows = "nixpkgs"; 
        # ^^ why does this throw a warning now that 
            # warning: 
            # input 'flake-utils' has an override for a non-existent input 'nixpkgs'
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
    # Git
    "plugins-gitsigns" = {
      url = "github:lewis6991/gitsigns.nvim";
      flake = false;
    };
    "plugins-which-key" = {
      url = "github:folke/which-key.nvim";
      flake = false;
    };
    # "plugins-fidget" = {
    #   url = "https://github.com/j-hui/fidget.nvim/tree/legacy";
    #   flake = false;
    # };
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
    # "cmp-tabnine" = { # download binaries too OP
    #   url = "github:tzachar/cmp-tabnine";
    #   flake = false;
    # };
    # I use this for autocomplete filler especially for comments. 
    # tab9 slightly better but meh
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

  outputs = { self, nixpkgs, flake-utils, ... }@inputs:
    # This line makes this package availeable for all systems
    # ("x86_64-linux", "aarch64-linux", "i686-linux", "x86_64-darwin",...)
    flake-utils.lib.eachDefaultSystem (system:
      let
        # If you cant import them with the standard overlay, 
        # define a derivation in ./nix/customPluginOverlay.nix
        # if it has a build step, do that there.
        # afterwards, you can add as pkgs.customNVIMplugins.pluginname
        # If you do that, don't name the flake input "plugins-something",
        # because that would be loaded by the standard overlay.
        customPluginOverlay = import ./nix/customPluginOverlay.nix inputs;

        # Apply the overlays and load nixpkgs as `pkgs`
        # Once we add these overlays to our nixpkgs, we are able to
        # use `pkgs.neovimPlugins`, which is a map of our plugins.
        # or use `pkgs.customNVIMplugins`, which is a map of our custom built plugins.
        standardPluginOverlay = import ./nix/pluginOverlay.nix inputs;
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            standardPluginOverlay
            customPluginOverlay
            inputs.codeium.outputs.overlays.${system}.default
          ];
          config.allowUnfree = true;
        };




        # Now that our plugin inputs/overlays and pkgs have been defined,
        # We define a function to facilitate package building for particular categories
        # it intakes a set of categories with a true false value for each
        birdeeVimBuild = { ... }@categories: (import ./nix/NeovimBuilder.nix {
          # It will need these
          inherit self;
          inherit pkgs;
          inherit categories;
          # you can set these
          viAlias = true;
          vimAlias = true;

          # to use a different folder other than myLuaConf, change this value:
          RCName = "myLuaConf"; # <-- the default value

          # for the following items: lspsAndDeps, propagatedBuildInputs, startup, and optional,
          # you define lists within the set with a particular name.
          # Then, you include that name in the categories set,
          # which you provide when you call this function to build a package.

          # to define and use a new category, simply add a new list to the set,
          # and include categoryname = true;
          # in the set you provide when you build the package using this function

          # propagatedBuildInputs:
          # this section is for dependencies that should be available
          # at BUILD TIME for plugins. WILL NOT be available to PATH
          # However, they WILL be available to the shell and neovim path when using nix develop
          propagatedBuildInputs = {
            generalBuildInputs = with pkgs; [
            ];
          };

          # lspsAndDeps:
          # this section is for dependencies that should be available
          # at RUN TIME for plugins. Will be available to path within neovim terminal
          # this includes LSPs
          lspsAndDeps = {
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
            ];
            neonixdev = with pkgs; [
              nix-doc
              nil
              lua-language-server
            ];
            bash = with pkgs; [
              # bashdb
            ];
          };

          # startup plugins:
          # This is for plugins that will load at startup without using packadd:
          startup = {
            neonixdev = [
              pkgs.vimPlugins.neodev-nvim
            ];
            AI = [
              pkgs.vimPlugins.codeium-nvim
              inputs.sg-nvim.packages.${system}.sg-nvim
              # cmp-tabnine
            ];
            customPlugins = with pkgs.customNVIMplugins; [
            ];
            markdown = with pkgs.customNVIMplugins; [
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
              # fidget # once you figure out how to import from legacy tag
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
              lualine-lsp-progress
              undotree
              nvim-web-devicons
              nui-nvim
              neo-tree-nvim
              nvim-dap
              nvim-dap-ui
            ];
          };

          # optional plugins:
          # not loaded automatically at startup.
          # use with packadd in config to achieve something like lazy loading
          optional = {
            customPlugins = with pkgs.customNVIMplugins; [ ];
            gitPlugins = with pkgs.neovimPlugins; [ ];
            general = with pkgs.vimPlugins; [ ];
          };
        });





        # And then build a package with specific categories from above here:
        # All categories you wish to include must be marked true,
        # but false may be omitted.
        # This entire set is also passed to the setup function for our config.
        # It is passed as a Lua table with values name = boolean. same as here.
        # if you have categories with the same name in 
        # startup, lspsAndDeps, propagatedBuildInputs, and/or optional, 
        # all plugins in those categories will be
        # included when you set "thatname = true;" here.
        # hence, AI = true; will include the AI lspsAndDeps category,
        # as well as the AI startup category
        # you can also add extra entries that dont have associated
        # categories if you wish to pass an extra boolean into the lua.
        birdeeVim = birdeeVimBuild {
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
          # this does not have an associated category of plugins, but lua can still check for it
          lspDebugMode = false;
        };
        noAIneodev = birdeeVimBuild {
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
        };
        coffeeVim = birdeeVimBuild {
          cmp = true;
          telescope = true;
          treesitter = true;
          markdown = true;
          customPlugins = true;
          gitPlugins = true;
          general = true;
          AI = true;
          java = true;
        };
        kotlinVim = birdeeVimBuild {
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
        };
      in





      { # choose your package
        devShell = pkgs.mkShell {
          name = "birdeeVim";
          packages = [ noAIneodev ];
          inputsFrom = [ ];
          shellHook = ''
          '';
        };
        packages = {
          default = birdeeVim;
          inherit birdeeVim;
          inherit noAIneodev;
          inherit coffeeVim;
          inherit kotlinVim;
        };
      }



    ); # end of flake utils, which returns the value of outputs
}
