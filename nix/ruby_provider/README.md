You really don't need to do this, but if I use the feature I find out if it breaks.

It is just an updated version of [this directory from nixpkgs.](https://github.com/NixOS/nixpkgs/tree/74ad6cb1d2b14edb4ad1fffc0791e94910c61453/pkgs/applications/editors/neovim/ruby_provider)

If you don't provide it, it will grab it from there.

To update it when required, cd here and then run:

nix run --no-write-lock-file github:BirdeeHub/neovim_ruby_updater
