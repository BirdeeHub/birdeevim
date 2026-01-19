importName: inputs: let
  ktls = {
    stdenv
  }: stdenv.mkDerivation {
    name = importName;
    src = builtins.path { path = inputs.${importName}; };
    buildPhase = ''
      mkdir -p $out/bin
      cp -r ./* $out
      ln -s $out/kotlin-lsp.sh $out/bin/kotlin-lsp
      chmod +x $out/bin/kotlin-lsp
    '';
  };
in
self: super: { 
  ${importName} = super.callPackage ktls {};
}
