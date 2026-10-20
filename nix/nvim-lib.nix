# adds some spec fields, and some other useful things
{ config, lib, wlib, pkgs, options, ... }: {
  options.settings.cats = lib.mkOption {
    readOnly = true;
    type = lib.types.attrsOf lib.types.raw;
    default = builtins.mapAttrs (_: v: v.enable) config.specs;
    description = "Puts which specs I have enabled into the generated info plugin";
  };
  options.nvim-lib.pluginsFromPrefix = lib.mkOption {
    type = lib.types.raw;
    readOnly = true;
    default = prefix: inputs: lib.pipe inputs [
      builtins.attrNames
      (builtins.filter (s: lib.hasPrefix prefix s))
      (map (input: let
        name = lib.removePrefix prefix input;
      in {
        inherit name;
        value = config.nvim-lib.mkPlugin name inputs.${input};
      }))
      builtins.listToAttrs
    ];
  };
  config.specMods = { config, ... }: {
    options.runtimePkgs = lib.mkOption {
      inherit (options.runtimePkgs) type;
      default = [];
      description = ''
        A runtimePkgs spec field to put packages on the PATH
        If the spec is disabled, this value will not be included in the resulting neovim derivation
      '';
    };
    config.runtimePkgs = lib.pipe config.wrappers [
      builtins.attrValues
      (builtins.filter (v: v.nvim-include.enable))
      (lib.partition (v: v.nvim-include.prefix))
      ({ right, wrong, }: let
        wrapper-mapper = pre: map (v: { prefix = pre; data = v.wrapper; name = v.binName; });
      in wrapper-mapper true right ++ wrapper-mapper false wrong)
    ];
    options.mainInfo = lib.mkOption {
      type = wlib.types.attrsRecursive;
      default = {};
      description = "an optional mainInfo spec field to add to the main info plugin instead of the spec specific one";
    };
    options.settings = lib.mkOption {
      type = lib.types.submoduleWith { modules = [ { freeformType = wlib.types.attrsRecursive; } ]; };
      default = {};
      description = "no-op freeform submodule for putting stuff in a spec and grabbing it in that spec in a way that acts like settings for that spec";
    };
    options.wrappers = lib.mkOption {
      type = lib.types.attrsOf (wlib.types.subWrapperModule {
        config.pkgs = pkgs;
        options.nvim-include.prefix = lib.mkOption {
          type = lib.types.bool;
          default = false;
        };
        options.nvim-include.enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
        };
      });
      default = {};
      description = "attrs of wrapper modules to be installed with this spec";
    };
  };
  config.info = lib.mkMerge (config.specCollect (acc: v: acc ++ lib.optional (v.mainInfo or {} != {}) v.mainInfo) []);
  config.runtimePkgs = config.specCollect (acc: v: acc ++ (v.runtimePkgs or [])) [];
}
