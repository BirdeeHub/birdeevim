```lua
vim.keymap.set('n', '<leader>rr', function() require('scooter').open_scooter() end, { desc = 'Open scooter' })
vim.keymap.set('v', '<leader>rr', function()
  local selection = vim.fn.getreg('"')
  vim.cmd('normal! "ay')
  require('scooter').open_scooter_with_text(vim.fn.getreg('a'))
  vim.fn.setreg('"', selection)
end, { desc = 'Search selected text in scooter' })
```

```nix
(pkgs.symlinkJoin {
  name = "scooter-w-cfg";
  paths = [ inputs.scooter.packages.${pkgs.stdenv.hostPlatform.system}.default ];
  nativeBuildInputs = [ pkgs.makeBinaryWrapper ];
  scootcfg = builtins.toFile "config.toml" /*toml*/''
    [editor_open]
    command = "${name} --server $NVIM --remote-send '<cmd>lua require('scooter').EditLineFromScooter(\"%file\", %line)<CR>'"
  '';
  postBuild = ''
    mkdir -p "$out/share/bundled_config"
    cp "$scootcfg" "$out/share/bundled_config/config.toml"
    wrapProgram ${pkgs.lib.escapeShellArgs [
      "${placeholder "out"}/bin/scooter" "--inherit-argv0"
      "--add-flag" "--config-dir" "--add-flag"
      "${placeholder "out"}/share/bundled_config"
    ]}
  '';
})
```
