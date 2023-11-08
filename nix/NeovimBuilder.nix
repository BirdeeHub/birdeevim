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
  # todo: swap to new wrapper maybe, definitely add environmentVariables
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

    # we are going to provide a function to map name and value
    # into a wrapper argument that sets an environment variable
    FandF_envVarSet = filterAndFlattenWrapAttrs 
          (name: value: ''--set ${name} "${value}"'');

    # and this one we define a function that just passes it through.
    # this one takes an a set of lists rather than a set of sets
    FandF_passWrapperArgs = filterAndFlattenWrapLists (value: value);


    # you can use filterAndFlattenWrapAttrs and its list counterpart in order
    # to create new sets of categories in the flake's builder function.
    # pass it a new wrapping function. I.E. 
    # FandFpassFlags = filterAndFlattenWrapLists (value: "--add-flags ${value}")
    # I just figured, environmentVariables are the main thing, and any extra,
    # by the time you actually need the other wrapper args,
    # you will already know what you are doing, and would prefer to just
    # pass in a list of wrapper args. Hence the passthrough.

    # and this is how we add our lsps!
    # add any dependencies/lsps/whatever we need available at runtime
    FandF_WrapRuntimeDeps = filterAndFlattenWrapLists (value:
      ''--prefix PATH : "${pkgs.lib.makeBinPath [ value ] }"''
    );

    extraMakeWrapperArgs = builtins.concatStringsSep " " (
      (FandF_WrapRuntimeDeps lspsAndRuntimeDeps)
      ++ (FandF_envVarSet environmentVariables)
      ++ (FandF_passWrapperArgs extraWrapperArgs)
      # I learned this from https://github.com/mrcjkb/kickstart-nix.nvim
      # Then I found more info at
      # https://github.com/NixOS/nixpkgs/blob/master/pkgs/build-support/setup-hooks/make-wrapper.sh
      # with kickstarters method I did this before:
      # outside of extraMakeWrapperArgs I would do:

      # runtimedeps = filterAndFlatten lspsAndDeps;

      # and then in here I would do:

      # (pkgs.lib.optional (runtimedeps != [])
      #   ''--prefix PATH : "${pkgs.lib.makeBinPath runtimedeps}"'')

      # vs now I do
      # (FandF_WrapRuntimeDeps lspsAndDeps)
      # Im pretty sure mine takes longer to evaluate the flake, but like
      # it shouldnt have any other impact, and that is a very small portion
      # of the overall install time. Plus mine calls unique on it.
      # I like my method because it was a natural extension of me writing a
      # generalized system for packaging wrapper args by category.
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

