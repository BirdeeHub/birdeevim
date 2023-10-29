{ ... }@inputs: let
  customPluginOverlay = final: prev: { 
    customNVIMplugins = {

      # cmp-tabnine = prev.stdenv.mkDerivation {
      #   name = "cmp-tabnine";
      #   src = inputs.cmp-tabnine;
      #   buildInputs = [ prev.unzip prev.curl ];
      #   buildPhase = ''$src/install.sh'';
      #   installPhase = ''
      #     mkdir -p $out
      #     cp -r ./* $out
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

