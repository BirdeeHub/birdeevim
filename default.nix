{ self, pkgs }:
let
  #LuaFS = {
  #  dir1 = {
  #     subdir1 = {
  #       file1 = filecontents;
  #       file2 = filecontents;
  #     }
  #     file3 = filecontents;
  #   }
  #   dir2 = { file4 = filecontents; };
  #   file5 = filecontents;
  # }
  LuaFS = import ./FileSysImport.nix self;
in
{ url = ""; flake = false; }
