{ self,
  pkgs,
  customRC ? "lua require('myLuaConf').setup()"
  , viAlias ? true
  , vimAlias ? true
  , start ? builtins.attrValues pkgs.neovimPlugins
  , opt ? [ ]
  , debug ? true
  , propagatedBuildInputs ? []
  }:
  let
    myNeovimUnwrapped = pkgs.neovim-unwrapped.overrideAttrs (prev: {
      # I didnt add stdenv.cc.cc.lib, so I would suggest not removing it.
      propagatedBuildInputs = propagatedBuildInputs ++ [ pkgs.stdenv.cc.cc.lib ];
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

