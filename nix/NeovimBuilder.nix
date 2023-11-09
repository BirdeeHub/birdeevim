{ 
  self
  , pkgs
  , RCName
  , viAlias ? false
  , vimAlias ? false
  , startupPlugins ? {}
  , optionalPlugins ? {}
  , lspsAndRuntimeDeps ? {}
  , propagatedBuildInputs ? {}
  , environmentVariables ? {}
  , extraWrapperArgs ? {}
  , categories ? {}
  # I dont know what these do so I didnt add their categories
  # to the flake itself. I implemented them though.
  # for the the extra packages fields, 
  # rather than requiring a set of lists of derivations,
  # they instead require a set of lists of functions that return lists.
  # which is the same as the normal wrapper, just in categories
  , withNodeJs ? false
  , withRuby ? true
  , extraName ? ""
  , extraPythonPackages ? {}
  , withPython3 ? true
  , extraPython3Packages ? {}
  , extraLuaPackages ? {}
  }:
  # for a more extensive guide to this file
  # see :help birdee.nixperts.neovimBuilder
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

    # see :help nixCats
    nixCats = import ./nixCats.nix { inherit pkgs; inherit categories; };

    # this is what allows for dynamic packaging in flake.nix
    # It includes categories marked as true, then flattens to a single list
    filterAndFlatten = (import ./utils.nix)
          .filterAndFlattenAttrsOfLists pkgs categories;

    # I didnt add stdenv.cc.cc.lib, so I would suggest not removing it.
    # It has cmake in it I think among other things?
    buildInputs = [ pkgs.stdenv.cc.cc.lib ] ++ filterAndFlatten propagatedBuildInputs;
    start = [ nixCats LuaConfig ] ++ filterAndFlatten startupPlugins;
    opt = filterAndFlatten optionalPlugins;

    #For wrapperArgs:
    # This one filters and flattens like above but for attrs of attrs 
    # and then maps name and value
    # into a list based on the function we provide it.
    # its like a flatmap function but with a built in filter for category.
    filterAndFlattenWrapAttrs = (import ./utils.nix)
          .FilterAttrsOfAttrsFlatMapInner pkgs categories;
    # This one filters and flattens attrs of lists and then maps value
    # into a list of strings based on the function we provide it.
    # it the same as above but for a mapping function with 1 argument
    # because the inner is a list not a set.
    filterAndFlattenWrapLists = (import ./utils.nix)
          .FilterAttrsOfListsFlatMapInner pkgs categories;

    # and then applied:

    FandF_envVarSet = filterAndFlattenWrapAttrs 
          (name: value: ''--set ${name} "${value}"'');

    FandF_passWrapperArgs = filterAndFlattenWrapLists (value: value);

    # add any dependencies/lsps/whatever we need available at runtime
    FandF_WrapRuntimeDeps = filterAndFlattenWrapLists (value:
      ''--prefix PATH : "${pkgs.lib.makeBinPath [ value ] }"''
    );

    # extraPythonPackages and the like require FUNCTIONS that return lists.
    # so we make a function that returns a function that returns lists.
    # this is used for the fields in the wrapper where the default value is (_: [])
    combineCatsOfFuncs = sect:
      (x: let
        appliedfunctions = builtins.map (value: (value) x ) (filterAndFlatten sect);
        combinedFuncRes = builtins.concatLists appliedfunctions;
        uniquifiedList = pkgs.lib.unique combinedFuncRes;
      in
      uniquifiedList);

    # cat our args
    extraMakeWrapperArgs = builtins.concatStringsSep " " (
      (FandF_WrapRuntimeDeps lspsAndRuntimeDeps)
      ++ (FandF_envVarSet environmentVariables)
      ++ (FandF_passWrapperArgs extraWrapperArgs)
      # https://github.com/NixOS/nixpkgs/blob/master/pkgs/build-support/setup-hooks/make-wrapper.sh
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
  # I dont know what these do, but I implemented them?
    /* the function you would have passed to python.withPackages */
  extraPythonPackages = combineCatsOfFuncs extraPythonPackages;
    /* the function you would have passed to python.withPackages */
  inherit withPython3;
  extraPython3Packages = combineCatsOfFuncs extraPython3Packages;
    /* the function you would have passed to lua.withPackages */
  extraLuaPackages = combineCatsOfFuncs extraLuaPackages;
  inherit withNodeJs;
  inherit withRuby;
  inherit extraName;
}

