inputs: let
  debuggerOverlay = self: super: { 
    neovimDebuggers = {

      # this is not accurate.
      bash-debug-adapter = inputs.bash-debug-adapter;

    };
  };
in
debuggerOverlay
