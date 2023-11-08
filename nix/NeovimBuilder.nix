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
    # These are the extra arguments you have available that I didnt use.
    # I did not use them because I do not know what they do.
    # What I do know is, you could use:
    # extraPythonPackages = filterAndFlatten setOfCategoriesOfextraPythonPackages
    # and pass the set in as an argument to this file to add a section to the builder.

    # Copied verbatim from source:
    /* the function you would have passed to python.withPackages */
    # , extraPythonPackages ? (_: [])
    /* the function you would have passed to python.withPackages */
    # , withPython3 ? true
    # , extraPython3Packages ? (_: [])
    /* the function you would have passed to lua.withPackages */
    # , extraLuaPackages ? (_: [])
    # , withNodeJs ? false
    # , withRuby ? true
    # , extraName ? ""
}

