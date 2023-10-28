{
  description = "Birdee's Neovim flake with mostly regular Lua config.";
        # TO DO: 
        # install vim-markdown-composer
        # add cmp-tabnine, 
        # install cody/sourcegraph
        # separate out langauge server sets into packages.
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
    "vim-markdown-composer" = {
      url = "github:euclio/vim-markdown-composer";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, flake-utils, ... }@inputs:
    # This line makes this package availeable for all systems
    # ("x86_64-linux", "aarch64-linux", "i686-linux", "x86_64-darwin",...)
    flake-utils.lib.eachDefaultSystem (system:
      let
        # If you cant import them with the standard overlay, define a derivation here
        # and then put them in customPlugins or customOptPlugins
        # because that would be loaded by the other overlay
        customPluginOverlay = final: prev: { 
          customNVIMplugins = {

            # vim-markdown-composer = prev.vimUtils.buildVimPlugin {
            #   pname = "vim-markdown-composer";
            #   version = "master";
            #   src = inputs.markdown-composer;
            #   buildInputs = [ prev.rustup ];
            #   installPhase = ''
            #     cd $src
            #     cargo build --release
            #     mkdir -p $out
            #     cp -r $src/* $out
            #   '';
            # };

            vim-markdown-composer = prev.rustPlatform.buildRustPackage {
                name = "vim-markdown-composer";
                src = inputs.vim-markdown-composer;
                cargoLock = {
                  lockFile = "${inputs.vim-markdown-composer}/Cargo.lock";
                };
                buildType = "release";
                installPhase = ''
                  mkdir -p $out
                  currdir="$(pwd)"
                  cd target
                  rm -r release
                  readarray -t subdirs <<< "$(ls -1 ./*)"
                  for entry in "$''+''{subdirs[@]}"; do
                    [[ $entry =~ :$ ]] && subdir="$''+''{entry%?}"
                    [[ "$entry" == "release" ]] && ln -s "$subdir/release" .
                  done
                  cd "$currdir"
                  cp -r ./* $out
                '';
              };
          };
        };
        # Apply the overlays and load nixpkgs as `pkgs`
        # Once we add this overlay to our nixpkgs, we are able to
        # use `pkgs.neovimPlugins`, which is a map of our plugins.
        standardPluginOverlay = import ./nix/pluginOverlay.nix inputs;
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ standardPluginOverlay customPluginOverlay ];
          config.allowUnfree = true;
        };
        birdeeVimBuild = { ... }@servers: (import ./nix/NeovimBuilder.nix {
          viAlias = true;
          vimAlias = true;
          inherit self;
          inherit pkgs;
          # add dependencies you always want here
          genDeps = with pkgs; [
            # cody and markdown composer deps
            # cargo

            # tab9 deps
            # curl
            # unzip
          ];
          start = let
            customPlugins = with pkgs.customNVIMplugins; [
              vim-markdown-composer
            ];
            # add desired plugins to pre load from overlay here
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
            # and add here for regular pkgs.vimPlugin and also self derived plugins
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
          gitPlugins ++ nixvimplugins ++ customPlugins;
          # same as above, but not loaded at startup.
          # use this with packadd in config to achieve something like lazy loading
          opt = let
            customOptPlugins = /* with pkgs.customNVIMplugins; */ [ ];
            gitOptPlugins = with pkgs.neovimPlugins; [ ];
            nixOptPlugins = with pkgs.vimPlugins; [ ];
          in
          gitOptPlugins ++ nixOptPlugins ++ customOptPlugins;

          # lsp stuff
          inherit servers;
          lspLists = {
            # you can put lsps and lang specific dependencies here
            neonixdev = with pkgs; [ 
              nil
              lua-language-server
            ];
          };
        });
        # and then build a package with specific ones here
         birdeeVim = birdeeVimBuild { neonixdev = true; };
         # you will need to go to myLuaConf.birdee.LSPs to set up 
         # new categories and servers in lua.
      in
      { # choose your package
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
