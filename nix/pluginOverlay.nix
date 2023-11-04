# Source: https://github.com/Quoteme/neovim-flake/tree/master
inputs:
  # Once we add this overlay to our nixpkgs, we are able to
  # use `pkgs.neovimPlugins`, which is a map of our plugins.
(self: super:
let
  inherit (super.vimUtils) buildVimPlugin;
  plugins = builtins.filter
    (s: (builtins.match "plugins-.*" s) != null)
    (builtins.attrNames inputs);
  plugName = input:
    builtins.substring
      (builtins.stringLength "plugins-")
      (builtins.stringLength input)
      input;
  buildPlug = name: buildVimPlugin {
    pname = plugName name;
    version = "master";
    src = builtins.getAttr name inputs;
  };
in
{
  neovimPlugins = builtins.listToAttrs (map
    (plugin: {
      name = plugName plugin;
      value = buildPlug plugin;
    })
    plugins);
})
