{
  description = "Birdee's Neovim flake with mostly regular Lua config.";
        # TO DO: 
        # install vim-markdown-composer
        # add cmp-tabnine, 
        # install cody/sourcegraph
        # install jdtls and kotlin-language-server
        # install debuggers
        # install formatters
        # install neo-tree because no one added the icons to netrw yet for when they are nice
        # if you want, install fidget from legacy tag, but lualine-lsp-progress is fine
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils = {
      url = "github:numtide/flake-utils";
      # inputs.nixpkgs.follows = "nixpkgs"; 
        # ^^ why does this throw a warning now that 
            # warning: 
            # input 'flake-utils' has an override for a non-existent input 'nixpkgs'
    };
    # rnix-lsp.url = "github:nix-community/rnix-lsp";
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
  };

  outputs = { self, nixpkgs, flake-utils, ... }@inputs:
    # This line makes this package availeable for all systems
    # ("x86_64-linux", "aarch64-linux", "i686-linux", "x86_64-darwin",...)
    flake-utils.lib.eachDefaultSystem (system:
      let
        # Apply the overlay and load nixpkgs as `pkgs`
        # Once we add this overlay to our nixpkgs, we are able to
        # use `pkgs.neovimPlugins`, which is a map of our plugins.
        standardPluginOverlay = import ./nix/pluginOverlay.nix inputs;
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ standardPluginOverlay ];
          config.allowUnfree = true;
        };
        # If you cant import them with that overlay, define a derivation here
        # also if you do that, dont name the input "plugins-something"
        # because that would be loaded by the overlay

        birdeeVim = import ./nix/NeovimBuilder.nix {
          inherit self;
          inherit pkgs;
          propagatedBuildInputs = with pkgs; [ 
            # you can put dependencies and language servers here
            nil
            lua-language-server

            # cody and markdown composer deps
            # cargo

            # tab9 deps
            # curl
            # unzip
          ];
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
              # vim-markdown-composer
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
          gitPlugins ++ nixvimplugins;
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
