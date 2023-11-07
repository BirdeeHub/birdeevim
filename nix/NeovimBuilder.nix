{ 
  self
  , pkgs
  , RCName
  , viAlias ? false
  , vimAlias ? false
  , startupPlugins ? {}
  , optionalPlugins ? {}
  , lspsAndDeps ? {}
  , propagatedBuildInputs ? {}
  , categories ? {}
  }:
  # todo: swap to new wrapper maybe
  let
    # package the entire flake as plugin
    # and create our customRC to call it
    customRC = if RCName != "" then 
        "lua require('" + RCName + "')" 
      else "";
    LuaConfig = pkgs.stdenv.mkDerivation {
      name = RCName;
      builder = builtins.toFile "builder.sh" ''
        source $stdenv/setup
        mkdir -p $out
        cp -r ${self}/* $out
      '';
    };

    utils = import ./utils.nix;
    # this is what allows for dynamic packaging in flake.nix
    # includes categories marked as true
    filterAndFlatten = SetOfCategoryLists: categories: 
      pkgs.lib.unique (utils.filterAndFlattenAttrsOfLists SetOfCategoryLists categories);

    nixCats = import ./nixCats.nix { inherit pkgs; inherit categories; };

    # I didnt add stdenv.cc.cc.lib, so I would suggest not removing it.
    buildInputs = [ pkgs.stdenv.cc.cc.lib ] ++ filterAndFlatten propagatedBuildInputs categories;
    runtimedeps = [ pkgs.stdenv.cc.cc.lib ] ++ filterAndFlatten lspsAndDeps categories;
    start = [ nixCats LuaConfig ] ++ filterAndFlatten startupPlugins categories;
    opt = filterAndFlatten optionalPlugins categories;

    # add any dependencies/lsps/whatever we need available at runtime
    # learned this from kickstarter-nix
    # Then I found more info at
    # https://github.com/NixOS/nixpkgs/blob/master/pkgs/build-support/setup-hooks/make-wrapper.sh
    extraMakeWrapperArgs = builtins.concatStringsSep " " (
      (pkgs.lib.optional (runtimedeps != [])
        ''--prefix PATH : "${pkgs.lib.makeBinPath runtimedeps}"'')
    );

    # add our propagated build dependencies
    myNeovimUnwrapped = pkgs.neovim-unwrapped.overrideAttrs (prev: {
      propagatedBuildInputs = buildInputs;
    });
  in
  # add our lsps and plugins and our config, and wrap it all up!
pkgs.wrapNeovim myNeovimUnwrapped {
  inherit extraMakeWrapperArgs;
  inherit viAlias;
  inherit vimAlias;
  configure = {
    inherit customRC;
    packages.myVimPackage = {
      inherit start;
      inherit opt;
    };
  };
}

