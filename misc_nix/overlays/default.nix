# Example overlay:
/*
importName: inputs: let
  overlay = self: super: { 
    ${importName} = SOME_DRV;
    # or
    ${importName} = {
      # define your overlay derivations here
    };
  };
in
overlay
*/

inputs: let 
  inherit (inputs.nixCats) utils;
  overlaySet = {

    # kotlin-lsp = import ./kotlin-lsp.nix;
    aider-wrapped = import ./aider-wrapped.nix;
    # locked = import ./locked.nix;
    scooter = import ./scooter.nix;
    # internalvim = import ./build;
    # lua-git2 = import ./lua-git2.nix;
    opencode = import ./opencode.nix;

  };
  extra = [
    (utils.sanitizedPluginOverlay inputs)
    # add any flake overlays here.
    inputs.neorg-overlay.overlays.default
    inputs.tomlua.overlays.default
    inputs.neovim-nightly-overlay.overlays.default
    # (utils.fixSystemizedOverlay inputs.windsurf.overlays
    #   (system: inputs.windsurf.overlays.${system}.default)
    # )
  ];
in
builtins.attrValues (builtins.mapAttrs (name: value: (value name inputs)) overlaySet) ++ extra
