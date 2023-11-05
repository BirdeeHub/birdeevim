{ 
  self
  , pkgs
  , RCName
  , viAlias ? false
  , vimAlias ? false
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
        helptags = builtins.toFile "tags" "nixCats	nixCats.txt	/*nixCats*";
        helpCats = builtins.toFile "nixCats.txt" ''
          =======================================================================================
          NIX CATEGORIES                                                       *nixCats*
          nixCats: returns category names included by nix for this package 

          Use this to check if this neovim was packaged with 
          a particular category included:

              local cats = require('nixCats')
              if(cats.nix) then
                  -- some stuff here
              end

          The nixCats "plugin" is just a table.

              :lua print(vim.inspect(require('nixCats')))

          will return something like this:
              {
                  AI = true,
                  bash = true,
                  cmp = true,
                  customPlugins = true,
                  general = true,
                  gitPlugins = true,
                  java = false,
                  kotlin = true,
                  lspDebugMode = false,
                  markdown = true,
                  neonixdev = true,
                  telescope = true,
                  treesitter = true
              }

          You will notice it is the same table of booleans we were passed from the
          flake.nix file where we choose categories for different packages.

          ----------------------------------------------------------------------------------------
          vim:tw=78:ts=8:ft=help:norl:
        '';
      in builtins.toFile "builder.sh" ''
        source $stdenv/setup
        mkdir -p $out/lua
        mkdir -p $out/doc
        cp ${cats} $out/lua/nixCats.lua
        cp ${helpCats} $out/doc/nixCats.txt
        cp ${helptags} $out/doc/tags
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

