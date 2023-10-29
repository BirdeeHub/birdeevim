{ 
  self
  , pkgs
  , viAlias ? true
  , vimAlias ? true
  , startup ? {}
  , optional ? {}
  , debug ? true
  , lspsAndDeps ? {}
  , categories ? {}
  }:
  # todo: swap to new wrapper maybe and add debug
  let
    filterAndFlatten = SetOfCategoryLists: categories: let
      inputsToCheck = builtins.intersectAttrs SetOfCategoryLists categories;
      thingsIncluded = builtins.mapAttrs (name: value:
          if value == true then builtins.getAttr name SetOfCategoryLists else []
        ) inputsToCheck;
      listOfLists = builtins.attrValues thingsIncluded;
      flattenedList = builtins.concatLists listOfLists;
    in
    flattenedList;

    propInputs = filterAndFlatten lspsAndDeps categories;
    startupPlugs = filterAndFlatten startup categories;
    optionalPlugs = filterAndFlatten optional categories;
    # generate lua table entries from servers attribute set.
    # values for devShell = "neonixdev = true, lua = false, nix = false, AI = false, "
    # note: false entries can be omitted because lua says its not true.
    luatableprinter = categorySet: let
      nameandstringmap = builtins.mapAttrs (name: value:
        if value == true then
          "${name} = true"
        else
          "${name} = false"
      ) categorySet;
      resultList = builtins.attrValues nameandstringmap;
      resultString = builtins.concatStringsSep ", " resultList;
    in
      resultString
    ;
    setupTableRC = luatableprinter categories;
    customRC = "lua require('myLuaConf').setup({ " + setupTableRC + "})";
    myLuaConf = pkgs.stdenv.mkDerivation { 
      name = "myLuaConf";
      src = self;
      installPhase = ''
        mkdir -p $out
        cp -r $src/* $out
      '';
    };
    myNeovimUnwrapped = pkgs.neovim-unwrapped.overrideAttrs (prev: {
      # I didnt add stdenv.cc.cc.lib, so I would suggest not removing it.
      propagatedBuildInputs = propInputs ++ [ pkgs.stdenv.cc.cc.lib ];
    });
  in
pkgs.wrapNeovim myNeovimUnwrapped {
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

