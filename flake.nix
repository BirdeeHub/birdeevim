{
  description = "Luca's simple Neovim flake for easy configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils = {
      # inputs.nixpkgs.follows = "nixpkgs";
      url = "github:numtide/flake-utils";
    };
    # "plugins-birdeeLua" = { 
    #   url = "./.";
    #   flake = false; 
    # };
    # Theme
    # "plugins-onedark-vim" = {
    #   url = "github:joshdick/onedark.vim";
    #   flake = false;
    # };
    "plugins-catppuccin" = {
      url = "github:catppuccin/nvim";
      flake = false;
    };
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
    "plugins-neodev" = {
      url = "github:folke/neodev.nvim";
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
        # Once we add this overlay to our nixpkgs, we are able to
        # use `pkgs.neovimPlugins`, which is a map of our plugins.
        # Each input in the format:
        # ```
        # "plugin_yourPluginName" = {
        #   url   = "github:exampleAuthor/examplePlugin";
        #   flake = false;
        # };
        # ```
        # included in the `inputs` section is packaged to a (neo-)vim
        # plugin and can then be used via
        # ```
        # pkgs.neovimPlugins.yourPluginName
        # ```
        pluginOverlay = final: prev:
          let
            inherit (prev.vimUtils) buildVimPlugin;
            treesitterGrammars = prev.tree-sitter.withPlugins (_: prev.tree-sitter.allGrammars);
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

              # Tree-sitter fails for a variety of lang grammars unless using :TSUpdate
              # For now install imperatively
              #postPatch =
              #  if (name == "nvim-treesitter") then ''
              #    rm -r parser
              #    ln -s ${treesitterGrammars} parser
              #  '' else "";
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
        # neovimBuilder is a function that takes your prefered
        # configuration as input and just returns a version of
        # neovim where the default config was overwritten with your
        # config.
        # 
        # Parameters:
        # customRC | your init.vim as string
        # viAlias  | allow calling neovim using `vi`
        # vimAlias | allow calling neovim using `vim`
        # start    | The set of plugins to load on every startup
        #          | The list is in the form ["yourPluginName" "anotherPluginYouLike"];
        #          |
        #          | Important: The default is to load all plugins, if
        #          |            `start = [ "blabla" "blablabla" ]` is
        #          |            not passed as an argument to neovimBuilder!
        #          |
        #          | Make sure to add:
        #          | ```
        #          | "plugin_yourPluginName" = {
        #          |   url   = "github:exampleAuthor/examplePlugin";
        #          |   flake = false;
        #          | };
        #          | 
        #          | "plugin_anotherPluginYouLike" = {
        #          |   url   = "github:exampleAuthor/examplePlugin";
        #          |   flake = false;
        #          | };
        #          | ```
        #          | to your imports!
        # opt      | List of optional plugins to load only when 
        #          | explicitly loaded from inside neovim
        neovimBuilder =
          { customRC ? ""
          , viAlias ? true
          , vimAlias ? true
          , start ? builtins.attrValues pkgs.neovimPlugins
          , opt ? [ ]
          , debug ? false
          }:
          let
          birdeeLua = pkgs.stdenv.mkDerivation { name = "birdeeLua"; src = ./.; };
            myNeovimUnwrapped = pkgs.neovim-unwrapped.overrideAttrs (prev: {
              propagatedBuildInputs = with pkgs; [ stdenv.cc.cc.lib cargo cmake birdeeLua ];
            });
          in
          pkgs.wrapNeovim myNeovimUnwrapped {
            extraMakeWrapperArgs = "-u ${birdeeLua.outPath}";
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
        birdeeVim = neovimBuilder {
          # the next line loads a trivial example of a init.vim:
          # customRC = ''luafile $out/lib/init.lua'';
          # customRC = ''colorscheme onedark'';
          # customRC = ''
          #   ${pkgs.lib.readFile ./init.vim}
          # '';
          # customRC = ''
          #   vim.opt.config = "/home/birdee/.config/nvimflakes"
          # '';
          # customRC = ''
          #   let g:mapleader = ' '
          #   let g:maplocalleader = ' '
          #   colorscheme catppuccin
          #   lua require('birdeeLua').plugins()
          #   lua require('birdeeLua').opts()
          #   lua require('birdeeLua').keymaps()
          #   lua require('birdeeLua').LSPs(require('birdeeLua').on_attach, require('birdeeLua').get_capabilities())
          #   lua require('birdeeLua').debug()
          #   lua require('birdeeLua').autoformat()
          # '';
          # customRC = ''
          #   let g:mapleader = ' '
          #   let g:maplocalleader = ' '
          #   lua require('birdeeLua')
          # '';


          # TO DO: 
          # install lsps
          # fix treesitter parser install
          # install markdown-preview
          # add cmp-tabnine, 
          # install cody/sourcegraph
          # install neo-tree
          # install debuggers
          # install formatter
          # if you want, install fidget from legacy tag, but lualine-lsp-progress should be fine
          start = with pkgs.neovimPlugins; [ 
            catppuccin
            # onedark-vim
            # pkgs.vimPlugins.nvim-treesitter-textobjects
            # pkgs.vimPlugins.nvim-treesitter
            pkgs.vimPlugins.telescope-fzf-native-nvim
            pkgs.vimPlugins.plenary-nvim
            pkgs.vimPlugins.telescope-nvim
            gitsigns
            which-key
            neodev
            lspconfig
            lualine
            Comment
            harpoon
            hlargs
            pkgs.vimPlugins.nvim-surround
            pkgs.vimPlugins.indent-blankline-nvim
            # pkgs.vimPlugins.markdown-preview-nvim

            # fidget # once you figure out how to import from legacy tag
            pkgs.vimPlugins.lualine-lsp-progress

            pkgs.vimPlugins.nvim-cmp
            pkgs.vimPlugins.luasnip
            pkgs.vimPlugins.cmp_luasnip
            pkgs.vimPlugins.cmp-buffer
            pkgs.vimPlugins.cmp-path
            pkgs.vimPlugins.cmp-nvim-lua
            pkgs.vimPlugins.cmp-nvim-lsp
            pkgs.vimPlugins.friendly-snippets
            pkgs.vimPlugins.cmp-cmdline

          ];
          opt = with pkgs.neovimPlugins; [ ];
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
          # birdeeLua = inputs.plugins-birdeeLua;
        };
      }
    );
}
