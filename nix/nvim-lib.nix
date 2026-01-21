{
  config,
  lib,
  wlib,
  ...
}:
{
  options.settings.cats = lib.mkOption {
    readOnly = true;
    type = lib.types.attrsOf lib.types.raw;
    default = builtins.mapAttrs (_: v: v.enable) config.specs;
  };
  options.nvim-lib.pluginsFromPrefix = lib.mkOption {
    type = lib.types.raw;
    readOnly = true;
    default =
      prefix: inputs:
      lib.pipe inputs [
        builtins.attrNames
        (builtins.filter (s: lib.hasPrefix prefix s))
        (map (
          input:
          let
            name = lib.removePrefix prefix input;
          in
          {
            inherit name;
            value = config.nvim-lib.mkPlugin name inputs.${input};
          }
        ))
        builtins.listToAttrs
      ];
  };
  config.specMods = {
    options.prepkgs = lib.mkOption {
      type = lib.types.listOf wlib.types.stringable;
      default = [ ];
      description = "a prepkgs spec field to put packages to prefix to the PATH";
    };
    options.postpkgs = lib.mkOption {
      type = lib.types.listOf wlib.types.stringable;
      default = [ ];
      description = "a postpkgs spec field to put packages to suffix to the PATH";
    };
  };
  config.prefixVar =
    let
      autodeps = config.specCollect (acc: v: acc ++ (v.prepkgs or [ ])) [ ];
    in
    lib.optional (autodeps != [ ]) {
      name = "PREPKGS_ADDITIONS";
      data = [
        "PATH"
        ":"
        "${lib.makeBinPath (lib.unique autodeps)}"
      ];
    };
  config.suffixVar =
    let
      autodeps = config.specCollect (acc: v: acc ++ (v.postpkgs or [ ])) [ ];
    in
    lib.optional (autodeps != [ ]) {
      name = "POSTPKGS_ADDITIONS";
      data = [
        "PATH"
        ":"
        "${lib.makeBinPath (lib.unique autodeps)}"
      ];
    };
}
