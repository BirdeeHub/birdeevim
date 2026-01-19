importName: inputs:
self: super: { 
  ${importName} = super.callPackage ({
    stdenv,
    makeBinaryWrapper,
    aider-chat-full,
    lib
  }: let
    args = [
      "--add-flag"
      "--model"
      "--add-flag"
      "gemini-2.5-flash"
    ];
  in stdenv.mkDerivation {
    name = importName;
    src = builtins.path { path = aider-chat-full; };
    nativeBuildInputs = [ makeBinaryWrapper ];
    buildPhase = ''
      makeWrapper $src/bin/aider $out/bin/aider ${lib.escapeShellArgs args}
    '';
  }) {};
}
