{ config, wlib, lib, pkgs, ... }: {
  imports = [ ./module.nix ];
  queryDir = ./queries;
  languages = {
    nix = {
      extensions = [ "nix" ];
      grammar = pkgs.tree-sitter-grammars.tree-sitter-nix;
    };
  };
}
