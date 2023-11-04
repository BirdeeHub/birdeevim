{ 
  self
  , pkgs
  , viAlias ? false
  , vimAlias ? false
  , startup ? {}
  , optional ? {}
  , debug ? false
  , lspsAndDeps ? {}
  , propagatedBuildInputs ? {}
  , categories ? {}
  }:
  # todo: swap to new wrapper maybe and add debug
  let
    # this is what allows for dynamic packaging in flake.nix
    filterAndFlatten = SetOfCategoryLists: categories: let
      inputsToCheck = builtins.intersectAttrs SetOfCategoryLists categories;
      thingsIncluded = builtins.mapAttrs (name: value:
          if value == true then builtins.getAttr name SetOfCategoryLists else []
        ) inputsToCheck;
      listOfLists = builtins.attrValues thingsIncluded;
      flattenedList = builtins.concatLists listOfLists;
    in
    flattenedList;

    # I didnt add stdenv.cc.cc.lib, so I would suggest not removing it.
    propInputs = [ pkgs.stdenv.cc.cc.lib ] ++ filterAndFlatten propagatedBuildInputs categories;
    runtimedeps = [ pkgs.stdenv.cc.cc.lib ] ++ filterAndFlatten lspsAndDeps categories;
    startupPlugs = filterAndFlatten startup categories;
    optionalPlugs = filterAndFlatten optional categories;

    # and this just sends whatever booleans we had in the caregories we packaged
    luatableprinter = categorySet: let
      nameandstringmap = builtins.mapAttrs (name: value:
        if value == true then "${name} = true"
        else "${name} = false"
      ) categorySet;
      resultList = builtins.attrValues nameandstringmap;
      resultString = builtins.concatStringsSep ", " resultList;
    in
    resultString;

    setupTableRC = luatableprinter categories;
    customRC = "lua require('myLuaConf').setup({ " + setupTableRC + " })";
    # package the entire flake as plugin
    myLuaConf = pkgs.stdenv.mkDerivation {
      name = "myLuaConf";
      src = self;
      installPhase = ''
        mkdir -p $out
        cp -r $src/* $out
      '';
    };

    # add our propagated dependencies
    myNeovimUnwrapped = pkgs.neovim-unwrapped.overrideAttrs (prev: {
      propagatedBuildInputs = propInputs;
    });
  in
  # add our lsps and plugins and our config, and wrap it all up!
pkgs.wrapNeovim myNeovimUnwrapped {
  extraMakeWrapperArgs = builtins.concatStringsSep " " (
    (pkgs.lib.optional (runtimedeps != [])
      ''--prefix PATH : "${pkgs.lib.makeBinPath runtimedeps}"'')
  );
  inherit viAlias;
  inherit vimAlias;
  configure = {
    inherit customRC;
    packages.myVimPackage = {
      start = startupPlugs ++ [ myLuaConf ];
      opt = optionalPlugs;
    };
  };
}

