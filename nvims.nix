inputs: let
  inherit (inputs.nixCats) utils;
  birdeevim_settings = { pkgs, name, ... }@misc: {
    # so that it finds my ai auths in ~/.cache/birdeevim
    extraName = "birdeevim";
    configDirName = "birdeevim";
    wrapRc = true;
    useBinaryWrapper = true;
    hosts.node.enable = true;
    hosts.python3.enable = true;
    hosts.python3.path = depfn: {
      value = ((pkgs.python3.withPackages (p: depfn p ++ [p.pynvim])).overrideAttrs {
        doCheck = false;
        doInstallCheck = false;
        pytestCheckPhase = "";
        installCheckPhase = "";
      }).interpreter;
      args = [ "--unset" "PYTHONPATH" ];
    };
    hosts.perl.enable = false;
    hosts.ruby.enable = true;
    hosts.ruby.path = let
      rubyEnv = pkgs.bundlerEnv {
        name = "neovim-ruby-env";
        postBuild = "ln -sf ${pkgs.ruby}/bin/* $out/bin";
        gemdir = ./misc_nix/ruby_provider;
      };
    in {
      value = "${rubyEnv}/bin/neovim-ruby-host";
      nvimArgs = [
        "--set" "GEM_HOME" "${rubyEnv}/${rubyEnv.ruby.gemPath}"
        "--suffix" "PATH" ":" "${rubyEnv}/bin"
      ];
    };
    unwrappedCfgPath = utils.n2l.types.inline-unsafe.mk {
      body = /*lua*/ ''(os.getenv("HOME") or "/home/birdee") .. "/.birdeevim"'';
    };
    # moduleNamespace = [ defaultPackageName ];
    hosts.neovide.path = {
      value = "${pkgs.neovide}/bin/neovide";
      args = [ "--add-flags" "--neovim-bin ${placeholder "out"}/bin/${name}" ];
    };
  };
  birdeevim_categories = { pkgs, ... }@misc: {
    AI.windsurf = true;
    AI.opencode = true;
    vimagePreview = true;
    lspDebugMode = false;
    other = true;
    theme = true;
    debug = true;
    customPlugins = true;
    general = true;
    otter = true;
    bash = true;
    roc = true;
    neonixdev = true;
    markdown = true;
    java = true;
    web = true;
    go = true;
    kotlin = true;
    python = true;
    rust = true;
    SQL = true;
    C = true;
    fennel = true;
    zig = true;
    typst = true;
    mass_find_and_replace.scooter = true;
    mass_find_and_replace.spectre = true;
  };
  birdeevim_extra = { pkgs, ... }@misc: {
    colorscheme = "onedark";
    javaExtras = {
      java-test = pkgs.vscode-extensions.vscjava.vscode-java-test;
      java-debug-adapter = pkgs.vscode-extensions.vscjava.vscode-java-debug;
      gradle-ls = pkgs.vscode-extensions.vscjava.vscode-gradle;
    };
    nixdExtras = {
      nixpkgs = "import ${builtins.path { path = pkgs.path; }} {}";
      get_configs = utils.n2l.types.function-unsafe.mk {
        args = [ "type" "path" ];
        body = ''return [[import ${./misc_nix/nixd.nix} ${builtins.path { path = pkgs.path; }} "]] .. type .. [[" ]] .. (path or "./.")'';
      };
    };
    bitwarden_uuids = {
      gemini = [ "notes" "bcd197b5-ba11-4c86-8969-b2bd01506654" ];
      windsurf = [ "notes" "d9124a28-89ad-4335-b84f-b0c20135b048" ];
    };
  };
in {
  birdeevim = args: {
    settings =  birdeevim_settings args // {
      wrapRc = true;
      aliases = [ "vi" "nvim" ];
    };
    categories =  birdeevim_categories args // {
    };
    extra = birdeevim_extra args // {
    };
  };
  nightlytest = { pkgs, ... }@args: {
    settings = birdeevim_settings args // {
      wrapRc = false;
      aliases = [ "tvim" ];
    };
    categories = birdeevim_categories args // {
      test = true;
      lspDebugMode = true;
    };
    extra = birdeevim_extra args // {
    };
  };
  testvim = args: {
    settings = birdeevim_settings args // {
      wrapRc = false;
      aliases = [ "vim" ];
    };
    categories = birdeevim_categories args // {
      test = true;
      lspDebugMode = true;
    };
    extra = birdeevim_extra args // {
    };
  };
  vigo = { pkgs, ... }@args: {
    settings = birdeevim_settings args // {
      wrapRc = true;
      extraName = "vigo";
      # aliases = [ "vigo" ];
    };
    categories = {
      theme = true;
      other = true;
      debug = true;
      markdown = true;
      customPlugins = true;
      general = true;
      otter = true;
      nix = true;
      web = true;
      go = true;
      SQL = true;
    };
    extra = {
      inherit (birdeevim_extra args) nixdExtras;
    };
  };
  nvim_for_u = { pkgs, ... }@args: {
    settings = birdeevim_settings args // {
      wrapRc = true;
      extraName = "nvim_for_u";
      aliases = [ "vi" "vim" "nvim" ];
    };
    categories = birdeevim_categories args // {
      AI = false;
      tabCompletionKeys = true;
    };
    extra = birdeevim_extra args // {
      AIextras = null;
    };
  };
  noAInvim = { pkgs, ... }@args: {
    settings = birdeevim_settings args // {
      wrapRc = true;
      extraName = "noAInvim";
      aliases = [ "vi" "vim" "nvim" ];
    };
    categories = birdeevim_categories args // {
      AI = false;
    };
    extra = birdeevim_extra args // {
      AIextras = null;
    };
  };
  portableVim = { pkgs, ... }@args: {
    settings = birdeevim_settings args // {
      extraName = "portableVim";
      aliases = [ "vi" "vim" "nvim" ];
    };
    categories = birdeevim_categories args // {
      portableExtras = true;
      AI = false;
    };
    extra = birdeevim_extra args // {
      AIextras = null;
    };
  };
  minimalVim = { pkgs, ... }@args: {
    settings = birdeevim_settings args // {
      wrapRc = false;
      aliases = null;
      extraName = "minimalVim";
      hosts.node.enable = false;
      hosts.ruby.enable = false;
      hosts.perl.enable = false;
      hosts.python3.enable = false;
    };
    categories = {};
    extra = {};
  };
}
