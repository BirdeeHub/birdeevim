{ ... }@inputs: let
  customPluginOverlay = final: prev: { 
    customNVIMplugins = {

      # markdown-preview = prev.stdenv.mkDerivation {
      #   name = "markdown-preview";
      #   src = inputs.markdown-preview-nvim;
      #   buildInputs = [ prev.nodejs prev.yarn ];
      #   buildPhase = ''
      #     npx --yes yarn install
      #     npx --yes yarn build
      #   '';
      #   installPhase = ''
      #     mkdir -p $out
      #     cp -r ./* $out
      #   '';
      # };
      # markdown-preview = prev.mkYarnPackage {
      #   name = "markdown-preview";
      #   src = inputs.markdown-preview-nvim;
      #   yarnLock = "${inputs.markdown-preview-nvim}/yarn.lock";
      #   # installPhase = ''
      #   #   mkdir -p $out
      #   #   cp -r $src/* $out
      #   #   # cd $out
      #   #   # cd app
      #   #   # $out/app/install.sh
      #   # '';
      #   # yarnPostBuild = ''
      #   #   mkdir -p $out
      #   #   cp -r $src/* $out
      #   # '';
      #   # doDist = false;
      #   distPhase = ''
      #     mkdir -p $out
      #     cp -rf $src/* $out
      #   '';
      # };
      vim-markdown-composer = prev.rustPlatform.buildRustPackage {
        name = "vim-markdown-composer";
        src = inputs.vim-markdown-composer;
        cargoLock = {
          lockFile = "${inputs.vim-markdown-composer}/Cargo.lock";
        };
        buildType = "release";
        # it builds it to the wrong directory.......
        # So we symlink it to the correct one
        installPhase = ''
          mkdir -p $out
          currdir="$(pwd)"
          cd target
          rm -r release
          readarray -t subdirs <<< "$(ls -1 ./*)"
          for entry in "$''+''{subdirs[@]}"; do
            [[ $entry =~ :$ ]] && subdir="$''+''{entry%?}"
            [[ "$entry" == "release" ]] && ln -s "$subdir/release" .
          done
          cd "$currdir"
          cp -r ./* $out
        '';
      };
    };
  };
in
customPluginOverlay

