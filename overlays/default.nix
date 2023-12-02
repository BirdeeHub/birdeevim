/*
This file imports overlays defined in the following format.
It imports them all under the same entry so that
you dont need to keep track of what you named things.
Plugins will still only be downloaded if included in a category.
You may copy past this example into a new file and then import that file here.
*/
# Example overlay:
/*
importName: inputs: let
  overlay = self: super: { 
    ${importName} = {
      # define your overlay derivations here
    };
  };
in
overlay
*/
# And this is what it does.
inputs: let 
  overlaySet = {

    # this is how you would add another overlay file
    # for if your customBuildsOverlay gets too long
    nixCatsBuilds = import ./debuggerOverlay.nix;

  };
in
# then it calls the functions we imported with importName and inputs
# and turns that into a list by getting just the values of overlaySet
builtins.attrValues (builtins.mapAttrs (name: value: (value name inputs)) overlaySet)
