{ 
  self
  , pkgs
  , viAlias ? true
  , vimAlias ? true
  , startup ? { }
  , optional ? { }
  # todo: swap to new wrapper maybe, and add debug
  , debug ? true
  , lspsAndDeps ? {},
    categories ? {}
  }:
  let
    propInputs = let
      inputsToCheck = builtins.intersectAttrs lspsAndDeps categories;
      langDepsIncluded = builtins.mapAttrs (name: value:
          if value == true then builtins.getAttr name lspsAndDeps else []
        ) inputsToCheck;
      listOfLists = builtins.attrValues langDepsIncluded;
      flattenedDeps = builtins.concatLists listOfLists;
      resultDeps = flattenedDeps;
    in
      resultDeps;
    startupPlugs = let
      inputsToCheck = builtins.intersectAttrs startup categories;
      plugsIncluded = builtins.mapAttrs (name: value:
          if value == true then builtins.getAttr name startup else []
        ) inputsToCheck;
      listOfLists = builtins.attrValues plugsIncluded;
      flattenedPlugs = builtins.concatLists listOfLists;
      resultPlugs = flattenedPlugs;
    in
      resultPlugs;
    optionalPlugs = let
      inputsToCheck = builtins.intersectAttrs optional categories;
      plugsIncluded = builtins.mapAttrs (name: value:
          if value == true then builtins.getAttr name optional else []
        ) inputsToCheck;
      listOfLists = builtins.attrValues plugsIncluded;
      flattenedPlugs = builtins.concatLists listOfLists;
      resultPlugs = flattenedPlugs;
    in
      resultPlugs;
    # generate lua table entries from servers attribute set.
    # values for devShell = "neonixdev = true, lua = false, nix = false, AI = false, "
    # note: false entries can be omitted because lua says its not true.
    luatableprinter = categorySet: (let
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
    );
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

