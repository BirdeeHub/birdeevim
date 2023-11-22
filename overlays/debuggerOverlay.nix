inputs: let
  debuggerOverlay = self: super: { 
    nixCatsDebug = {

      # this is not accurate.
      bash-debug-adapter = inputs.bash-debug-adapter;

    };
  };
in
debuggerOverlay
