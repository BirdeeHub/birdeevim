{
  description = "Birdee's Neovim flake with mostly regular Lua config.";
        # TO DO: 
        # install debuggers
        # install formatters
        # go back to messing with building markdown-preview-nvim
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
    # I want this one:
    # "markdown-preview-nvim" = {
    #   url = "github:iamcco/markdown-preview.nvim";
    #   flake = false;
    # };
    # but for now, I have this one working
    # Its faster and more responsive, but you can only have 1 open
    # at a time, which doesnt work for me
    "vim-markdown-composer" = {
      url = "github:euclio/vim-markdown-composer";
      flake = false;
    };
    # "cmp-tabnine" = { #binaries too OP
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
        # and then put them in customPlugins or customOptPlugins
        # if it has a build step, do that there.
        # afterwards, you can add as pkgs.customNVIMplugins.pluginname
        # If you do that, don't name the flake input "plugins-something",
        # because that would be loaded by the standard overlay.
        customPluginOverlay = import ./nix/customPluginOverlay.nix inputs;
        # sourcegraph said do this??
        # no idea what to do with it though.
        # sg = let
        #   system = "x86_64-linux";
        #   package = inputs.sg-nvim.packages.${system}.default;
        # in {
        #   inherit package;
        #   init = pkgs.writeTextFile {
        #     name = "sg.lua";
        #     text = ''
        #       return function()
        #         package.cpath = package.cpath .. ";" .. "${package}/lib/?.so"
        #       end
        #     '';
        #   };
        # };
        # Apply the overlays and load nixpkgs as `pkgs`
        # Once we add this overlay to our nixpkgs, we are able to
        # use `pkgs.neovimPlugins`, which is a map of our plugins.
        standardPluginOverlay = import ./nix/pluginOverlay.nix inputs;
        codeium = inputs.codeium.outputs.overlays.${system}.default;
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ standardPluginOverlay customPluginOverlay codeium ];
          config.allowUnfree = true;
        };
        birdeeVimBuild = { ... }@categories: (import ./nix/NeovimBuilder.nix {
          viAlias = true;
          vimAlias = true;
          inherit self;
          inherit pkgs;
          inherit categories;

          # for the following items: lspsAndDeps, startup, and optional,
          # you define lists within the set with a particular name.
          # Then, you include that name in the categories set,
          # which you provide when you call this function to build a package.
          # to define and use a new category, simply add a new list to the set,
          # and include categoryname = true;
          # in the set you provide when you build the package.

          # lspsAndDeps:
          # this section is for dependencies that should be available
          # at runtime for plugins. Will not be available to PATH
          # this includes LSPs
          lspsAndDeps= {
            general = with pkgs; [
              ripgrep
              fd
            ];
            ghmarkdown = [ 
              # I ended up just writing some keybinds to interface with this
              # I use it when I want to just view, the other when I want to edit
              # The reason being that it can have multiple open,
              # and also I didnt have to figure out importing custom css for darkmode
              # Its pretty decent though, drawback is you need to save for it to update
              pkgs.gh
              pkgs.gh-markdown-preview
            ];
            AI = [
              inputs.codeium.outputs.packages.${system}.codeium-lsp
              # apparently im still working on sourcegraph/cody
              # because it doesnt work on my fresh vm.
              inputs.sg-nvim.packages.${system}.default
              # sg
              # pkgs.rustup
              # pkgs.nodejs
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
              nil
            ];
            neonixdev = with pkgs; [
              nil
              lua-language-server
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
            # this is from the customPluginOverlay
            customPlugins = with pkgs.customNVIMplugins; [
            ];
            # This one is also from customPluginOverlay but I wanted it in markdown list
            markdown = with pkgs.customNVIMplugins; [
              # You might want to use this one, its pretty good, it updates in realtime
              # I did get it working. However, you cant have multiple open. 
              # Its rust so... building takes forever
              vim-markdown-composer
              
              # this one I never got to work because yarn build step
              # It puts the bin directory in the wrong place for the plugin
              # and everything I try with mkYarnPackage the permissions cause issues.
              # Otherwise, this would be my only markdown plugin
              # markdown-preview
            ];
            # this is from the pluginOverlay for when you name the input plugins-name
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
              # fidget # once you figure out how to import from legacy tag
            ];
            # and add here for regular pkgs.vimPlugin
            nixvimplugins = with pkgs.vimPlugins; [
              nvim-treesitter-textobjects
              nvim-treesitter.withAllGrammars
              # (nvim-treesitter.withPlugins (
              #   plugins: with plugins; [
              #     nix
              #     lua
              #   ]
              # ))
              lspkind-nvim
              nvim-web-devicons
              vim-sleuth
              vim-fugitive
              vim-rhubarb
              telescope-fzf-native-nvim
              plenary-nvim
              telescope-nvim
              nvim-surround
              indent-blankline-nvim
              lualine-lsp-progress
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
              nui-nvim
              neo-tree-nvim
              eyeliner-nvim # Highlights unique characters for f/F and t/T motions | https://github.com/jinh0/eyeliner.nvim
            ];
          };

          # optional plugins:
          # not loaded automatically at startup.
          # use with packadd in config to achieve something like lazy loading
          optional = {
            customPlugins = with pkgs.customNVIMplugins; [ ];
            gitPlugins = with pkgs.neovimPlugins; [ ];
            nixvimplugins = with pkgs.vimPlugins; [ ];
          };
        });


        # And then build a package with specific categories from above here:
        # All categories you wish to include must be marked true,
        # but false may be omitted.
        # This entire set is also passed to the setup function for our config.
        # It is passed as a Lua table with values name = boolean. same as here.
        # if you have categories with the same name in 
        # startup, lspsAndDeps and/or optional, all plugins will be
        # included when you set "thatname = true;" here.
        # hence, AI = true; will include the AI lspsAndDeps category,
        # as well as the AI startup category
        birdeeVim = birdeeVimBuild {
          general = true;
          markdown = true;
          ghmarkdown = true;
          customPlugins = true;
          gitPlugins = true;
          nixvimplugins = true;
          neonixdev = true;
          AI = true;
          kotlin = true;
          java = false;
        };
        noAIneodev = birdeeVimBuild {
          general = true;
          markdown = false;
          ghmarkdown = true;
          customPlugins = true;
          gitPlugins = true;
          nixvimplugins = true;
          neonixdev = true;
          AI = false;
        };
        coffeeVim = birdeeVimBuild {
          general = true;
          ghmarkdown = true;
          customPlugins = true;
          gitPlugins = true;
          nixvimplugins = true;
          AI = true;
          java = true;
        };
        kotlinVim = birdeeVimBuild {
          general = true;
          ghmarkdown = true;
          customPlugins = true;
          gitPlugins = true;
          nixvimplugins = true;
          AI = true;
          kotlin = true;
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
          inherit noAIneodev;
          inherit coffeeVim;
          inherit kotlinVim;
        };
      }
    );
}
