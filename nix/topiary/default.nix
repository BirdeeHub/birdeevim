inputs: {
  config,
  wlib,
  lib,
  pkgs,
  ...
}: {
  _file = ./default.nix;
  key = ./default.nix;
  package = inputs.topiary.packages.${pkgs.stdenv.hostPlatform.system}.default;
  imports = [ ./module.nix ];
  queryDir = ./queries;
  # queryDir = "/home/birdee/.birdeevim/nix/topiary/queries";
  languages = {
    bash = {
      grammar = pkgs.tree-sitter-grammars.tree-sitter-bash;
    };
    css = {
      grammar = pkgs.tree-sitter-grammars.tree-sitter-css;
    };
    json = {
      grammar = pkgs.tree-sitter-grammars.tree-sitter-json;
    };
    nickel = {
      grammar = pkgs.tree-sitter-grammars.tree-sitter-nickel;
    };
    nix = {
      extensions = [ "nix" ];
      grammar = pkgs.tree-sitter-grammars.tree-sitter-nix;
    };
    ocaml = {
      grammar = pkgs.tree-sitter-grammars.tree-sitter-ocaml;
    };
    ocaml_interface = {
      grammar = pkgs.tree-sitter-grammars.tree-sitter-ocaml;
    };
    ocamllex = {
      grammar = pkgs.tree-sitter-grammars.tree-sitter-ocaml;
    };
    openscad = {
      grammar = pkgs.tree-sitter-grammars.tree-sitter-openscad;
    };
    rust = {
      grammar = pkgs.tree-sitter-grammars.tree-sitter-rust;
    };
    # sdml = {
    #   grammar = pkgs.tree-sitter.buildGrammar {
    #     language = "sdml";
    #     version = "master";
    #     # src = inputs.tree-sitter-sdml;
    #     location = null;
    #   };
    # };
    toml = {
      grammar = pkgs.tree-sitter-grammars.tree-sitter-toml;
    };
    tree_sitter_query = {
      extensions = [ "scm" ];
      grammar = pkgs.tree-sitter-grammars.tree-sitter-query;
    };
    wit = {
      grammar = pkgs.tree-sitter-grammars.tree-sitter-wit;
    };
  };
}
