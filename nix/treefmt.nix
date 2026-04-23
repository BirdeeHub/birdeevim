{ pkgs, config, lib, wlib, ... }: {
  imports = [ wlib.modules.default ];
  config.extraPackages = [];
  options.settings = lib.mkOption {
    type = lib.types.json // { description = "TOML value"; };
    default = {};
  };
  config.package = pkgs.treefmt;
  config.flags."--config-file" = config.constructFiles.configFile.path;
  config.constructFiles.configFile = {
    relPath = "${config.binName}-config.toml";
    content = builtins.toJSON (lib.filterAttrsRecursive (_: v: v != null) config.settings);
    builder = ''mkdir -p "$(dirname "$2")" && ${pkgs.remarshal}/bin/json2toml "$1" "$2"'';
  };
}
