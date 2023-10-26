{
  description = "Birdee's Neovim flake with mostly regular Lua config.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils = {
      url = "github:numtide/flake-utils";
      # inputs.nixpkgs.follows = "nixpkgs"; 
            #why does this throw a warning now that warning: 
            #input 'flake-utils' has an override for a non-existent input 'nixpkgs'
    };
    # rnix-lsp.url = "github:nix-community/rnix-lsp";
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
    # "plugins-markdown-preview" = {
    #   url = "github:iamcco/markdown-preview.nvim";
    #   flake = false;
    # };
    # "plugins-fidget" = {
    #   url = "https://github.com/j-hui/fidget.nvim/tree/legacy";
    #   flake = false;
    # };
    "plugins-lualine" = {
      url = "github:nvim-lualine/lualine.nvim";
      flake = false;
    };
    # "plugins-neodev" = {
    #   url = "github:folke/neodev.nvim";
    #   flake = false;
    # };
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
  };

  outputs = { self, nixpkgs, flake-utils, ... }@inputs:
    # This line makes this package availeable for all systems
    # ("x86_64-linux", "aarch64-linux", "i686-linux", "x86_64-darwin",...)
    flake-utils.lib.eachDefaultSystem (system:
      let
        # Once we add this overlay to our nixpkgs, we are able to
        # use `pkgs.neovimPlugins`, which is a map of our plugins.
        pluginOverlay = final: prev:
          let
            inherit (prev.vimUtils) buildVimPlugin;
            plugins = builtins.filter
              (s: (builtins.match "plugins-.*" s) != null)
              (builtins.attrNames inputs);
            plugName = input:
              builtins.substring
                (builtins.stringLength "plugins-")
                (builtins.stringLength input)
                input;
            buildPlug = name: buildVimPlugin {
              pname = plugName name;
              version = "master";
              src = builtins.getAttr name inputs;
            };
          in
          {
            neovimPlugins = builtins.listToAttrs (map
              (plugin: {
                name = plugName plugin;
                value = buildPlug plugin;
              })
              plugins);
          };

        # Apply the overlay and load nixpkgs as `pkgs`
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            pluginOverlay
          ];
          config.allowUnfree = true;
        };
        # we will put our stuff into here when we call it below, 
        # and it will wrap it for us.
        neovimBuilder =
          { customRC ? ""
          , viAlias ? true
          , vimAlias ? true
          , start ? builtins.attrValues pkgs.neovimPlugins
          , opt ? [ ]
          , debug ? true
          }:
          let
            myNeovimUnwrapped = pkgs.neovim-unwrapped.overrideAttrs (prev: {
              # I didnt add stdenv.cc.cc.lib, so I would suggest not removing it.
              propagatedBuildInputs = with pkgs; [ 
                stdenv.cc.cc.lib
                # apparently you can put dependencies and language servers here
                pkgs.nil
                pkgs.lua-language-server
                # cargo
                # curl and unzip needed for tabnine
                # nodejs possibly needed for markdown-preview
              ];
            });
          in
          pkgs.wrapNeovim myNeovimUnwrapped {
            inherit viAlias;
            inherit vimAlias;
            configure = {
              inherit customRC;
              packages.myVimPackage = {
                start = start;
                opt = opt;
              };
            };
          };
      in
      let
        # This is where we package this directory as if it was a plugin.
        myLuaConf = pkgs.stdenv.mkDerivation { 
            name = "myLuaConf";
            src = ./.;
            installPhase = ''
              mkdir -p $out
              cp -r $src/* $out
            '';
          };
        # now to put the pieces into our custom neovim!
        birdeeVim = neovimBuilder {
          # the next line loads a trivial example of a init.vim:
          customRC = ''
            lua require('myLuaConf').setup()
          '';

          # TO DO: 
          # install markdown-preview
          # install fugitive
          # add cmp-tabnine, 
          # install cody/sourcegraph
          # install jdtls and kotlin-language-server
          # install debuggers
          # install formatters
          # install neo-tree because no one added the icons to netrw yet for when they are nice
          # if you want, install fidget from legacy tag, but lualine-lsp-progress should be fine
          start = let
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
            nixvimplugins = with pkgs.vimPlugins; [ 
              nvim-treesitter-textobjects
              nvim-treesitter.withAllGrammars
              # (nvim-treesitter.withPlugins (
              #   plugins: with plugins; [
              #     nix
              #     lua
              #   ]
              # ))
              nvim-web-devicons
              vim-sleuth
              vim-fugitive
              vim-rhubarb
              neodev-nvim
              telescope-fzf-native-nvim
              plenary-nvim
              telescope-nvim
              nvim-surround
              indent-blankline-nvim
              # markdown-preview-nvim
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
            ];
          in
          gitPlugins ++ nixvimplugins ++ [ myLuaConf ];
          opt = let
            gitOptPlugins = with pkgs.neovimPlugins; [ ];
            nixOptPlugins = with pkgs.vimPlugins; [ ];
          in
          gitOptPlugins ++ nixOptPlugins;
        };
      in
      {
        devShell = pkgs.mkShell {
          name = "birdeeVim";
          packages = [ birdeeVim ];
          inputsFrom = [ ];
          shellHook = ''
          '';
        };
        packages = {
          default = birdeeVim;
          inherit birdeeVim;
        };
      }
    );
}
