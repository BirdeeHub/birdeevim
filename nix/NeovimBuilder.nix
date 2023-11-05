{ 
  self
  , pkgs
  , viAlias ? false
  , vimAlias ? false
  , RCName
  , startup ? {}
  , optional ? {}
  , lspsAndDeps ? {}
  , propagatedBuildInputs ? {}
  , categories ? {}
  }:
  # todo: swap to new wrapper maybe
  let
    # this is what allows for dynamic packaging in flake.nix
    filterAndFlatten = SetOfCategoryLists: categories: let
      inputsToCheck = builtins.intersectAttrs SetOfCategoryLists categories;
      thingsIncluded = builtins.mapAttrs (name: value:
          if value == true then builtins.getAttr name SetOfCategoryLists else []
        ) inputsToCheck;
      listOfLists = builtins.attrValues thingsIncluded;
      flattenedList = builtins.concatLists listOfLists;
      deDupedFlatList = pkgs.lib.unique flattenedList;
    in
    deDupedFlatList;

    luaTablePrinter = cats: let
      luatableformatter = categorySet: let
        nameandstringmap = builtins.mapAttrs (name: value:
          if value == true then "${name} = true"
          else "${name} = false"
        ) categorySet;
        resultList = builtins.attrValues nameandstringmap;
        resultString = builtins.concatStringsSep ", " resultList;
      in
      resultString;
      catset = luatableformatter cats;
      LuaTable = "{ " + catset + " }";
    in
    LuaTable;

    # create nixCats plugin
    RCTable = luaTablePrinter categories;
    nixCats = pkgs.stdenv.mkDerivation {
      name = "nixCats";
      builder = let
        cats = builtins.toFile "nixCats.lua" "return ${RCTable}";
      in builtins.toFile "builder.sh" ''
        source $stdenv/setup
        mkdir -p $out/lua
        cp ${cats} $out/lua/nixCats.lua
      '';
    };

    # package the entire flake as plugin
    # and create our customRC to call it
    vimRC = "lua require('" + RCName + "')";
    customRC = if RCName != "" then vimRC else "";
    LuaConfig = pkgs.stdenv.mkDerivation {
      name = RCName;
      src = self;
      installPhase = ''
        mkdir -p $out
        cp -r $src/* $out
      '';
    };

    # I didnt add stdenv.cc.cc.lib, so I would suggest not removing it.
    buildInputs = [ pkgs.stdenv.cc.cc.lib ] ++ filterAndFlatten propagatedBuildInputs categories;
    runtimedeps = [ pkgs.stdenv.cc.cc.lib ] ++ filterAndFlatten lspsAndDeps categories;
    startupPlugs = [ nixCats LuaConfig ] ++ filterAndFlatten startup categories;
    optionalPlugs = filterAndFlatten optional categories;

    # add any dependencies/lsps/whatever we need available at runtime
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
      start = startupPlugs;
      opt = optionalPlugs;
    };
  };
}

