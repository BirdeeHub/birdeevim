THIS IS NOT A DISTRO

This is my, quite messy config.

You can build it with `nix build github:BirdeeHub/birdeevim` or run it directly with `nix run github:BirdeeHub/birdeevim`

It will install a lot of stuff. Maybe just do `nix run github:BirdeeHub/birdeevim#minimal` if you are curious, which also isn't that minimal because it still installs all the treesitter grammars because i don't care to mess with that, but it at least won't install every lsp in the universe.

To get your own like it, see [nix-wrapper-modules#neovim](https://birdeehub.github.io/nix-wrapper-modules/neovim.html)

To have an easy time lazy loading, use [lze](https://github.com/BirdeeHub/lze) or [lz.n](https://github.com/lumen-oss/lz.n) (this config uses [lze](https://github.com/BirdeeHub/lze))
