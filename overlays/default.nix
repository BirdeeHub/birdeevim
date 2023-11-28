inputs: let 
  overlaySet = {

    # this is how you would add another overlay file
    # for if your customBuildsOverlay gets too long
    customBuilds = import ./customBuildsOverlay.nix inputs;
    debuggers = import ./debuggerOverlay.nix inputs;

  };
in
builtins.attrValues overlaySet
