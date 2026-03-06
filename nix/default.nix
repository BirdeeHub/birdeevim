inputs:
{
  config,
  wlib,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    wlib.wrapperModules.neovim
    ./nvim-lib.nix
    ./general.nix
    (lib.modules.importApply ./langs.nix inputs)
  ];
  options.nvim-lib.neovimPlugins = lib.mkOption {
    type = lib.types.raw;
    readOnly = true;
    default = config.nvim-lib.pluginsFromPrefix "plugins-" inputs // {
      tomlua = inputs.tomlua.packages.${pkgs.stdenv.hostPlatform.system}.vimPlugins-tomlua;
      juan-logs = pkgs.rustPlatform.buildRustPackage {
        pname = "juan-logs";
        version = "main";
        src = inputs.juan-logs-src;
        cargoHash = "sha256-DlrFiJjE6wNLfMwpeI6iz32GxfOlTozKTTRT2LP88BQ=";
        postInstall = ''
          mv $out/lib $out/bin
          cp -r $src/* $out
        '';
      };
    };
  };
  config.package = inputs.neovim-nightly-overlay.packages.${pkgs.stdenv.hostPlatform.system}.neovim;

  options.settings.test_mode = lib.mkOption {
    type = lib.types.enum [
      true
      false
      "dynamic"
    ];
    default = false;
  };
  config.settings.config_directory =
    if config.settings.test_mode == "dynamic" then
      let
        toLua = lib.generators.toLua { };
      in
      lib.generators.mkLuaInline "(vim.fn.isdirectory(${toLua config.settings.unwrapped_config}) == 1) and ${toLua config.settings.unwrapped_config} or ${toLua config.settings.wrapped_config}"
    else if config.settings.test_mode == true then
      config.settings.unwrapped_config
    else
      config.settings.wrapped_config;

  options.settings.wrapped_config = lib.mkOption {
    type = lib.types.either wlib.types.stringable lib.types.luaInline;
    default = ./..;
  };
  options.settings.unwrapped_config = lib.mkOption {
    type = lib.types.either wlib.types.stringable lib.types.luaInline;
    default = lib.generators.mkLuaInline "vim.uv.os_homedir() .. '/.birdeevim'";
  };
  config.settings.dont_link = config.binName != "nvim";
  config.binName = lib.mkIf (config.settings.test_mode == true) (lib.mkDefault "vim");
  config.settings.aliases = lib.mkIf (config.binName == "nvim") [ "vi" ];

  options.settings.minimal = lib.mkOption {
    type = lib.types.bool;
    default = false;
  };
  config.specMods = lib.mkIf config.settings.minimal (
    { parentSpec, ... }:
    {
      config.enable = lib.mkOverride 999 (parentSpec.enable or false); # 999 is 1 higher than mkOptionDefault (1000)
    }
  );
  config.hosts.python3.nvim-host.enable = config.specs.python.enable;
  config.hosts.node.nvim-host.enable = !config.settings.minimal;
  config.hosts.ruby.nvim-host.enable = !config.settings.minimal;
  config.hosts.perl.nvim-host.enable = false;
  config.hosts.neovide.nvim-host.enable = false;

  config.env.NVIM_APPNAME = "birdeevim";
  config.settings.nvim_lua_env = lp: with lp; lib.optional config.specs.fennel.enable fennel;
  config.hosts.ruby.gemdir = ./ruby_provider;
  # config.settings.compile_generated_lua = false;
  config.wrapperImplementation = "binary";

  options.settings.appimage = lib.mkOption {
    type = lib.types.bool;
    default = false;
  };
  # the appimage needs extra stuff because its chroot shadows the store
  config.extraPackages = lib.mkIf config.settings.appimage (
    with pkgs;
    [
      git
      nix
      wl-clipboard
      xclip
      xsel
    ]
  );
}
