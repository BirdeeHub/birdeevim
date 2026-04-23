{ config, wlib, lib, pkgs, ... }:
{
  imports = [ wlib.modules.default ];
  options.queryDir = lib.mkOption {
    type = wlib.types.stringable;
  };
  options.languages = lib.mkOption {
    type = lib.types.attrsOf (lib.types.submodule {
      options = {
        extensions = lib.mkOption {
          type = lib.types.listOf lib.types.str;
        };
        grammar = lib.mkOption {
          type = wlib.types.stringable;
        };
        indent = lib.mkOption {
          type = lib.types.str;
          default = "  ";
        };
        symbol = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
        };
      };
    });
    default = {};
  };
  config.package = pkgs.topiary;
  config.env.TOPIARY_LANGUAGE_DIR = config.queryDir;
  config.env.TOPIARY_CONFIG_FILE = config.constructFiles.languages.path;
  config.constructFiles.languages = {
    relPath = "${config.binName}-config/languages.ncl";
    content = let
      toNickelValue = val:
        if lib.isList val then
          "[${lib.concatStringsSep ", " (map toNickelValue val)}]"
        else if lib.isStringLike val then
          builtins.toJSON val
        else if builtins.isAttrs val then
          "{ ${lib.concatStringsSep ", " (lib.mapAttrsToList (k: v: "${k} = ${toNickelValue v}") val)} }"
        else
          toString val;
      # Convert a single language config to Nickel source with | default annotations
      languageToNickel = name: lang: let
          fields = [
            "extensions = ${toNickelValue lang.extensions}"
            "indent = ${toNickelValue lang.indent}"
          ] ++ [
            (let
              grammarFields = [
                "source.path = ${toNickelValue (if lang.grammar ? language then "${lang.grammar}/parser" else lang.grammar)}"
              ] ++ lib.optional (builtins.isString lang.symbol) "symbol = ${toNickelValue lang.grammar.symbol}";
            in "grammar = { ${lib.concatStringsSep ", " grammarFields} }")
          ];
        in "${name} = {\n      ${lib.concatStringsSep ",\n      " fields},\n    }";
    in ''
        {
          languages = {
            ${lib.concatStringsSep ",\n\n    " (lib.mapAttrsToList languageToNickel config.languages)},
          }
        }
      '';
  };
}
