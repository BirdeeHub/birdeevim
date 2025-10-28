# Copyright (c) 2023 BirdeeHub
# Licensed under the MIT license
{
  description = "my neovim config using nixCats";
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
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    # nixpkgsLocked.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixCats.url = "github:BirdeeHub/nixCats-nvim";
    tomlua = {
      # url = "git+file:/home/birdee/Projects/tomlua";
      url = "github:BirdeeHub/tomlua";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # nixCats.url = "git+file:/home/birdee/Projects/nixCats-nvim";
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

    scooter.url = "github:thomasschafer/scooter";
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
    "plugins-hlargs" = {
      url = "github:m-demare/hlargs.nvim";
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
  };

  # see :help nixCats.flake.outputs
  outputs = { self, nixpkgs, nixCats, ... }@inputs: let
    inherit (nixCats) utils;
    luaPath = ./.;
    forEachSystem = utils.eachSystem nixpkgs.lib.platforms.all;
    extra_pkg_config = {
      allowUnfree = true;
      doCheck = false; # <- seriously, python stuff runs 10 years of tests its not worth it.
    };
    dependencyOverlays = import ./misc_nix/overlays inputs;
    categoryDefinitions = import ./cats.nix inputs;
    packageDefinitions = import ./nvims.nix inputs;
    defaultPackageName = "birdeevim";

    module_args = {
      moduleNamespace = [ defaultPackageName ];
      inherit nixpkgs defaultPackageName dependencyOverlays
        luaPath categoryDefinitions packageDefinitions;
    };
    nixosModule = utils.mkNixosModules module_args;
    homeModule = utils.mkHomeModules module_args;
    overlays = utils.makeOverlaysWithMultiDefault luaPath {
      inherit nixpkgs dependencyOverlays extra_pkg_config;
    } categoryDefinitions packageDefinitions defaultPackageName;
  in
    forEachSystem (system: let
      nixCatsBuilder = utils.baseBuilder luaPath {
        inherit nixpkgs system dependencyOverlays extra_pkg_config;
      } categoryDefinitions packageDefinitions;
      defaultPackage = nixCatsBuilder defaultPackageName;
    in {
      packages = utils.mkAllWithDefault defaultPackage;
      # legacyPackages = utils.mkAllWithDefault (defaultPackage.overrideAttrs { nativeBuildInputs = [ (inputs.nixpkgs.legacyPackages.${system}.callPackage inputs.makeBinWrap {}) ];});
      app-images = let bundler = inputs.nix-appimage.bundlers.${system}.default; in {
        portableVim = bundler (nixCatsBuilder "portableVim");
      };
    }
  ) // {
    inherit utils overlays nixosModule homeModule;
    nixosModules.default = nixosModule;
    homeModules.default = homeModule;
  };
}
