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
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";
    # for stuff to follow
    flake-utils.url = "github:numtide/flake-utils";
    tomlua = {
      # url = "git+file:/home/birdee/Projects/tomlua";
      url = "github:BirdeeHub/tomlua";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # neovim-src = { url = "github:BirdeeHub/neovim/pack_add_spec_passthru"; flake = false; };
    # neovim-src = { url = "github:neovim/neovim/nightly"; flake = false; };
    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs.flake-parts.follows = "flake-parts";
      # inputs.neovim-src.follows = "neovim-src";
      inputs.nixpkgs.follows = "nixpkgs";
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

    # scooter.url = "github:thomasschafer/scooter";
    roc.url = "github:roc-lang/roc";
    # roc.inputs.nixpkgs.follows = "nixpkgs";
    roc.inputs.flake-utils.follows = "flake-utils";
    fenix.url = "github:nix-community/fenix";
    fenix.inputs.nixpkgs.follows = "nixpkgs";
    nix-appimage.url = "github:ralismark/nix-appimage";
    nix-appimage.inputs.nixpkgs.follows = "nixpkgs";
    nix-appimage.inputs.flake-utils.follows = "flake-utils";
    templ.url = "github:a-h/templ";
    templ.inputs.nixpkgs.follows = "nixpkgs";
    templ.inputs.nixpkgs-unstable.follows = "nixpkgs";
    # neorg-overlay.url = "github:nvim-neorg/nixpkgs-neorg-overlay";
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
    # "plugins-nvim-aider" = {
    #   url = "github:GeorgesAlkhouri/nvim-aider";
    #   flake = false;
    # };
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
    "plugins-snacks-nvim" = {
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
      flake-parts,
      ...
    }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        wrappers.flakeModules.wrappers
        inputs.flake-parts.flakeModules.bundlers
      ];
      systems = nixpkgs.lib.platforms.all;
      flake.overlays = {
        neovim = final: prev: { neovim = self.wrappers.neovim.wrap { pkgs = final; }; };
        default = self.overlays.neovim;
      };
      flake.wrappers = {
        neovim = nixpkgs.lib.modules.importApply ./module.nix inputs;
        default = self.wrapperModules.neovim;
      };
      perSystem =
        { system, config, ... }:
        {
          _module.args.pkgs = import inputs.nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
          packages = {
            minimal = config.packages.neovim.wrap { settings.minimal = true; };
            testing = config.packages.neovim.wrap { settings.test_mode = true; };
            dynamic = config.packages.neovim.wrap { settings.test_mode = "dynamic"; };
            bundle = config.packages.neovim.wrap { settings.appimage = true; };
            bundle-dyn = config.packages.bundle.wrap { settings.test_mode = "dynamic"; };
            bundle-min = config.packages.bundle.wrap { settings.minimal = true; };
          };
          # nix bundle --bundler .\#default .\#bundle
          # nix bundle --bundler .\#default .\#bundle-min
          # nix bundle --bundler .\#default .\#bundle-dyn
          bundlers.default = inputs.nix-appimage.bundlers.${system}.default;
        };
    };
}
