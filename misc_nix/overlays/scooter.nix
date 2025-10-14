importName: inputs: let
  scooter-wrapped = {
    makeRustPlatform,
    system,
    ...
  }: (makeRustPlatform inputs.fenix.packages.${system}.latest).buildRustPackage {
    pname = "scooter";
    version = "dev";
    src = inputs.scooter-src;
    cargoLock.lockFileContents = builtins.readFile "${inputs.scooter-src}/Cargo.lock";
  };
in
self: super: {
  scooter = super.callPackage scooter-wrapped {};
}
