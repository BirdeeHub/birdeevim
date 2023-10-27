{ 
  self
  , pkgs
  , customRC ? "lua require('myLuaConf').setup()"
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
          # TODO use servers list passed in and customRC
          # and pass a table to myLuaConf.setup()
          # and install only necessary servers to make
          # different packages for different languages
    propInputs = let
      inputsToCheck = builtins.intersectAttrs lspLists servers;
      langDepsIncluded = builtins.mapAttrs (name: value:
          if value == true then builtins.getAttr name lspLists else []
        ) inputsToCheck;
      listOfLists = builtins.attrValues langDepsIncluded;
      flattenedDeps = builtins.concatLists listOfLists;
      langDepsList = flattenedDeps;
      resultDeps = langDepsList;
    in
      resultDeps ++ genDeps;
    startRC = "lua require('myLuaConf').setup({ ";
    # currently hardcoded because TODO basically just print servers to 1 line
    langSetupRC = "neonixdev = true, lua = false, nix = false,";
    endRC = " })"; 
    createdRC = startRC + langSetupRC + endRC;

    # end of TODO section

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

