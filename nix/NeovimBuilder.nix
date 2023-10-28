{ 
  self
  , pkgs
  # , customRC ? "lua require('myLuaConf').setup()"
  , viAlias ? true
  , vimAlias ? true
  , start ? builtins.attrValues pkgs.neovimPlugins
  , opt ? [ ]
  # todo: swap to new wrapper maybe, and add debug
  , debug ? true
  , lspLists ? {},
    genDeps ? [],
    servers ? {}
  }:
  let
    propInputs = let
      inputsToCheck = builtins.intersectAttrs lspLists servers;
      langDepsIncluded = builtins.mapAttrs (name: value:
          if value == true then builtins.getAttr name lspLists else []
        ) inputsToCheck;
      listOfLists = builtins.attrValues langDepsIncluded;
      flattenedDeps = builtins.concatLists listOfLists;
      resultDeps = flattenedDeps;
    in
      resultDeps ++ genDeps;
    # generate lua table entries from servers attribute set.
    luatableprinter = serverSet: (let
      nameandstringmap = builtins.mapAttrs (name: value:
        if value == true then
          "${name} = true"
        else
          "${name} = false"
      ) serverSet;
      resultList = builtins.attrValues nameandstringmap;
      resultString = builtins.concatStringsSep ", " resultList;
    in
      resultString
      # values for devShell = "neonixdev = true, lua = false, nix = false,"
      # note: false entries can be omitted because lua says its not true.
    );
    langSetupRC = luatableprinter servers;
    customRC = "lua require('myLuaConf').setup({ " + langSetupRC + "})";
    myNeovimUnwrapped = pkgs.neovim-unwrapped.overrideAttrs (prev: {
      # I didnt add stdenv.cc.cc.lib, so I would suggest not removing it.
      propagatedBuildInputs = propInputs ++ [ pkgs.stdenv.cc.cc.lib ];
    });
    myLuaConf = pkgs.stdenv.mkDerivation { 
      name = "myLuaConf";
      src = self;
      installPhase = ''
        mkdir -p $out
        cp -r $src/* $out
      '';
    };
  in
pkgs.wrapNeovim myNeovimUnwrapped {
  inherit viAlias;
  inherit vimAlias;
  configure = {
    inherit customRC;
    packages.myVimPackage = {
      start = start ++ [ myLuaConf ];
      opt = opt;
    };
  };
}

