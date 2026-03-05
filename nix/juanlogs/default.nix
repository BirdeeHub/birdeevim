{
  rustPlatform,
  fetchFromGitHub,
  juan-logs-src ? fetchFromGitHub {
    owner = "minigian";
    repo = "juan-logs.nvim";
    rev = "dfbcbd237c78d8a3f060fa654df4c0496e667090";
    hash = "sha256-YWXKrr+0xFdSBrOaxyFJDqRFmGe25lU9w4Fyk6nlf+k=";
  },
  ...
}:
rustPlatform.buildRustPackage {
  pname = "juan-logs";
  version = "main";
  src = juan-logs-src;
  cargoHash = "sha256-DlrFiJjE6wNLfMwpeI6iz32GxfOlTozKTTRT2LP88BQ=";
  postInstall = ''
    cp -r $src/* $out
    mv $out/lib $out/bin
  '';
}
