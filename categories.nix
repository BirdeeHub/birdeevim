self: pkgs: inputs: system: settings: categories: (import ./builder {
  # these are required
  inherit self pkgs;
  # you supply these when you apply this function
  inherit categories settings;

  propagatedBuildInputs = {
    generalBuildInputs = with pkgs; [
    ];
  };

  lspsAndRuntimeDeps = {
    general = with pkgs; [
      universal-ctags
    ];
    telescope = with pkgs; [
      ripgrep
      fd
    ];
    bitwarden = with pkgs; [
      bitwarden-cli
    ];
    AI = [
      inputs.codeium.outputs.packages.${system}.codeium-lsp

      inputs.sg-nvim.packages.${system}.default
    ];
    java = with pkgs; [
      jdt-language-server
    ];
    kotlin = with pkgs; [
      jdt-language-server
      kotlin-language-server
    ];
    lua = with pkgs; [
      lua-language-server
    ];
    nix = with pkgs; [
      nix-doc
      nil
      nixd
    ];
    neonixdev = with pkgs; [
      # nix-doc tags will make your tags much better in nix
      # but only if you have nil as well for some reason
      nix-doc
      nil
      lua-language-server
      nixd
    ];
    bash = with pkgs; [
      bashdb # a bash debugger. seemed like an easy first debugger to add, and would be useful
      pkgs.nixCatsDebug.bash-debug-adapter
    ];
  };

  startupPlugins = {
    neonixdev = [
      pkgs.vimPlugins.neodev-nvim
      pkgs.vimPlugins.neoconf-nvim
      pkgs.neovimPlugins.nvim-luaref
    ];
    AI = [
      pkgs.vimPlugins.codeium-nvim
      inputs.sg-nvim.packages.${system}.sg-nvim
    ];
    customPlugins = with pkgs.customPlugins; [
    ];
    markdown = with pkgs.customPlugins; [
      markdown-preview-nvim
    ];
    telescope = with pkgs.vimPlugins; [
      telescope-fzf-native-nvim
      plenary-nvim
      telescope-nvim
    ];
    cmp = with pkgs.vimPlugins; [
      nvim-cmp
      luasnip
      cmp_luasnip
      cmp-buffer
      cmp-path
      cmp-nvim-lua
      cmp-nvim-lsp
      friendly-snippets
      cmp-cmdline
      cmp-nvim-lsp-signature-help
      cmp-cmdline-history
    ];
    treesitter = with pkgs.vimPlugins; [
      nvim-treesitter-textobjects
      nvim-treesitter.withAllGrammars
      # (nvim-treesitter.withPlugins (
      #   plugins: with plugins; [
      #     nix
      #     lua
      #   ]
      # ))
    ];
    gitPlugins = with pkgs.neovimPlugins; [
      # catppuccin
      onedark-vim
      gitsigns
      which-key
      lspconfig
      lualine
      Comment
      harpoon
      hlargs
      marks
      fidget
    ];
    general = with pkgs.vimPlugins; [
      lspkind-nvim
      vim-sleuth
      vim-fugitive
      vim-rhubarb
      vim-repeat
      nvim-surround
      eyeliner-nvim
      indent-blankline-nvim
      undotree
      nvim-web-devicons
      nui-nvim
      neo-tree-nvim
      nvim-dap
      nvim-dap-ui
      nvim-dap-virtual-text
    ];
  };

  optionalPlugins = {
    customPlugins = with pkgs.customPlugins; [ ];
    gitPlugins = with pkgs.neovimPlugins; [ ];
    general = with pkgs.vimPlugins; [ ];
  };

  environmentVariables = {
    AI = {
      # I provision the auth in the lua from bitwarden
      # so I don't have to put my token on github
      # But this is a way you could do it
      # SRC_ENDPOINT = "https://sourcegraph.com";
      # SRC_ACCESS_TOKEN = builtins.readFile ./secrets/codyToken;
      # this only works if you use the --impure option when building.
      # SRC_ACCESS_TOKEN = builtins.readFile /absolute/path/to/secrets/codyToken;
    };
    test = {
      BIRDTVAR = "It worked!";
    };
    bash = {
      BASHDAP = "${pkgs.nixCatsDebug.bash-debug-adapter}";
    };
  };

  extraWrapperArgs = {
  # https://github.com/NixOS/nixpkgs/blob/master/pkgs/build-support/setup-hooks/make-wrapper.sh
    test = [
      '' --set BIRDTVAR2 "It worked again!"''
    ];
  };

  # there are more available sections, extraPythonPackages, extraPython3Packages, extraLuaPackages.
  # see :help nixCats.flake.outputs.builder and :help nixCats.flake.nixperts.nvimBuilder
})
