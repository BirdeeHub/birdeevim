{
  description = "Flake exporting a configured package using wlib.evalModule";
  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };
  # https://nixos.org/manual/nix/stable/command-ref/new-cli/nix3-flake.html#examples
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    wrappers.url = "github:BirdeeHub/nix-wrapper-modules";
    wrappers.inputs.nixpkgs.follows = "nixpkgs";
    tomlua = {
      # url = "git+file:/home/birdee/Projects/tomlua";
      url = "github:BirdeeHub/tomlua";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # neovim-src = { url = "github:BirdeeHub/neovim/pack_add_spec_passthru"; flake = false; };
    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
      # inputs.neovim-src.follows = "neovim-src";
      # inputs.nixpkgs.follows = "nixpkgs";
    };

    # kotlin-lsp = {
    #   url = "https://download-cdn.jetbrains.com/kotlin-lsp/0.252.17811/kotlin-0.252.17811.zip";
    #   flake = false;
    # };

    # makeBinWrap = {
    #   url = "github:BirdeeHub/testBinWrapper";
    # #   url = "git+file:/home/birdee/Projects/testBinWrapper";
    #   flake = false;
    # };

    # Until nixpkgs also fetches from its main branch
    plugins-treesitter-textobjects = {
      url = "github:nvim-treesitter/nvim-treesitter-textobjects/main";
      flake = false;
    };

    # scooter.url = "github:thomasschafer/scooter";
    roc.url = "github:roc-lang/roc";
    fenix.url = "github:nix-community/fenix";
    nix-appimage.url = "github:ralismark/nix-appimage";
    templ.url = "github:a-h/templ";
    neorg-overlay.url = "github:nvim-neorg/nixpkgs-neorg-overlay";
    plugins-argmark = {
      url = "github:BirdeeHub/argmark";
      # url = "git+file:/home/birdee/Projects/argmark";
      flake = false;
    };
    plugins-rustaceanvim = {
      url = "github:mrcjkb/rustaceanvim";
      flake = false;
    };

    plugins-lze = {
      url = "github:BirdeeHub/lze";
      # url = "git+file:/home/birdee/Projects/lze";
      flake = false;
    };
    plugins-lzextras = {
      url = "github:BirdeeHub/lzextras";
      # url = "git+file:/home/birdee/Projects/lzextras";
      flake = false;
    };
    plugins-shelua = {
      url = "github:BirdeeHub/shelua";
      flake = false;
    };
    plugins-fn_finder = {
      url = "github:BirdeeHub/fn_finder";
      # url = "git+file:/home/birdee/Projects/fn_finder";
      flake = false;
    };
    "plugins-nvim-aider" = {
      url = "github:GeorgesAlkhouri/nvim-aider";
      flake = false;
    };
    "plugins-nvim-lspconfig" = {
      url = "github:neovim/nvim-lspconfig";
      flake = false;
    };
    "plugins-nvim-luaref" = {
      url = "github:milisims/nvim-luaref";
      flake = false;
    };
    "plugins-visual-whitespace" = {
      url = "github:mcauley-penney/visual-whitespace.nvim";
      flake = false;
    };
    "plugins-snacks.nvim" = {
      url = "github:folke/snacks.nvim";
      # url = "git+file:/home/birdee/Projects/snacks.nvim";
      flake = false;
    };
    "plugins-opencode-nvim" = {
      url = "github:NickvanDyke/opencode.nvim";
      flake = false;
    };
    "plugins-tmux-navigate" = {
      url = "github:sunaku/tmux-navigate";
      flake = false;
    };
  };
  outputs =
    {
      self,
      nixpkgs,
      wrappers,
      ...
    }@inputs:
    let
      forAllSystems = nixpkgs.lib.genAttrs nixpkgs.lib.platforms.all;
      module = nixpkgs.lib.modules.importApply ./module.nix inputs;
      wrapper = wrappers.lib.evalModule module;
    in
    {
      overlays = {
        default = final: prev: { neovim = wrapper.config.wrap { pkgs = final; }; };
        neovim = self.overlays.default;
      };
      wrapperModules = {
        default = module;
        neovim = self.wrapperModules.default;
      };
      wrappedModules = {
        default = wrapper.config;
        neovim = self.wrappedModules.default;
      };
      packages = forAllSystems (
        system:
        let
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
        in
        {
          default = wrapper.config.wrap { inherit pkgs; };
          neovim = self.packages.${system}.default;
        }
      );
    };
}
