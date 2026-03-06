{
  config,
  wlib,
  lib,
  pkgs,
  ...
}:
{
  config.specs.general = {
    enable = lib.mkIf config.settings.minimal (lib.mkDefault true);
    postpkgs = with pkgs; [
      tree-sitter
      universal-ctags
      ripgrep
      fd
      ast-grep
      jq
      lazygit
    ];
    data = with pkgs.vimPlugins; [
      config.nvim-lib.neovimPlugins.lze
      # "/home/birdee/Projects/lzextras"
      config.nvim-lib.neovimPlugins.lzextras
      oil-nvim
      vim-repeat
      config.nvim-lib.neovimPlugins.nvim-luaref
      nvim-nio
      nui-nvim
      nvim-web-devicons
      plenary-nvim
      mini-nvim
      {
        enable = !config.settings.minimal;
        data = config.nvim-lib.neovimPlugins.juan-logs;
      }
      {
        pname = "snacks.nvim";
        # data = "/home/birdee/Projects/snacks.nvim";
        data = config.nvim-lib.neovimPlugins.snacks-nvim;
      }
      nvim-ts-autotag
      config.nvim-lib.neovimPlugins.argmark
      config.nvim-lib.neovimPlugins.tmux-navigate
      config.nvim-lib.neovimPlugins.tomlua
      config.nvim-lib.neovimPlugins.shelua
      nvim-spectre
      luvit-meta
    ];
  };

  config.specs.lazy = {
    enable = lib.mkIf config.settings.minimal (lib.mkDefault true);
    lazy = true;
    data = with pkgs.vimPlugins; [
      img-clip-nvim
      vim-dadbod
      vim-dadbod-ui
      vim-dadbod-completion
      otter-nvim
      nvim-dap
      nvim-dap-ui
      nvim-dap-virtual-text
      nvim-highlight-colors
      which-key-nvim
      eyeliner-nvim
      todo-comments-nvim
      vim-startuptime
      config.nvim-lib.neovimPlugins.visual-whitespace
      luasnip
      cmp-cmdline
      blink-cmp
      blink-compat
      colorful-menu-nvim
      nvim-treesitter-textobjects
      nvim-treesitter.withAllGrammars
      vim-rhubarb
      vim-fugitive
      config.nvim-lib.neovimPlugins.nvim-lspconfig
      lualine-lsp-progress
      lualine-nvim
      gitsigns-nvim
      grapple-nvim
      # marks-nvim
      nvim-lint
      conform-nvim
      undotree
      nvim-surround
      treesj
      dial-nvim
      vim-sleuth
    ];
  };

  config.specs.images = {
    lazy = true;
    data = pkgs.vimPlugins.image-nvim;
    postpkgs = with pkgs; [
      imagemagick
      ueberzugpp
    ];
  };

  config.specs.scooter = {
    data = null;
    postpkgs = [
      (wlib.wrapPackage [
        { inherit pkgs; }
        (
          { pkgs, ... }:
          {
            package = pkgs.scooter;
            flags."--config-dir" = "${placeholder "out"}/share/bundled_config";
            drv.configJSON = builtins.toJSON {
              editor_open.command = "${config.binName} --server $NVIM --remote-send '<cmd>lua require('scooter').EditLineFromScooter(\"%file\", %line)<CR>'";
            };
            drv.passAsFile = [ "configJSON" ];
            drv.nativeBuildInputs = [ pkgs.remarshal ];
            drv.buildPhase = ''
              runHook preBuild
              mkdir -p "$out/share/bundled_config"
              json2toml "$configJSONPath" "$out/share/bundled_config/config.toml"
              runHook postBuild
            '';
          }
        )
      ])
    ];
  };

  options.settings.colorscheme = lib.mkOption {
    type = lib.types.str;
    default = "moonfly";
  };
  config.specs.colorscheme = {
    enable = lib.mkIf config.settings.minimal (lib.mkDefault true);
    lazy = true;
    data = builtins.getAttr (config.settings.colorscheme or "onedark") (
      with pkgs.vimPlugins;
      {
        "onedark" = onedarkpro-nvim;
        "onedark_dark" = onedarkpro-nvim;
        "onedark_vivid" = onedarkpro-nvim;
        "onelight" = onedarkpro-nvim;
        "catppuccin" = catppuccin-nvim;
        "catppuccin-mocha" = catppuccin-nvim;
        "moonfly" = vim-moonfly-colors;
        "tokyonight" = tokyonight-nvim;
        "tokyonight-day" = tokyonight-nvim;
      }
    );
  };

  config.specs.AI = {
    mainInfo.bitwarden_uuids = {
      gemini = [
        "notes"
        "bcd197b5-ba11-4c86-8969-b2bd01506654"
      ];
      windsurf = [
        "notes"
        "d9124a28-89ad-4335-b84f-b0c20135b048"
      ];
    };
    lazy = true;
    data = with pkgs.vimPlugins; [
      windsurf-nvim
      config.nvim-lib.neovimPlugins.opencode-nvim
    ];
    postpkgs = with pkgs; [
      bitwarden-cli
      (wlib.evalPackage {
        imports = [ wlib.wrapperModules.opencode ];
        inherit pkgs;
        settings = {
          "$schema" = "https://opencode.ai/config.json";
          provider = {
            ollama = {
              npm = "@ai-sdk/openai-compatible";
              name = "Ollama (local)";
              options = {
                baseURL = "http://localhost:11434/v1";
              };
              models = {
                "gpt-oss:20b" = {
                  name = "gpt-oss:20b";
                };
                "qwen3:14b" = {
                  name = "qwen3:14b";
                };
                "qwen3:8b" = {
                  name = "qwen3:8b";
                };
              };
            };
          };
        };
      })
    ];
  };
}
