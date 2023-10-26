My attempt at a Neovim Flake

inpiration taken HEAVILY from this repo as this was my first intro to nix.

https://github.com/Quoteme/neovim-flake/tree/master

## Attention: This repo is unfinished

customRC only takes vimscript.
The solution? Include my Lua config as a plugin. 

I could use some help.
I am new to nix. 
I had an okish neovim config. 
I want to make it in nix so I can use it anywhere and not worry about
that computer not having cargo or something.

The idea is, replace lazy and mason with nix, 
keep everything else in lua by inputting it as a plugin,
and then requiring it from the customRC init.vim
managing LSP's with nvim-lspconfig and managing 
filetype specific plugins with autocommands if needed.

The reason I want to do it this way is the setup instructions 
for new plugins are all in Lua, and if I want to not load it on startup, 
I can just put it in opt section and call packadd 
from an autocommand if I want to only load it when needed.

## Questions:

    1. I dont know how to build nvim plugins with a build step 
        like build = ./install.sh included by a plugin in nix using the 
        overlay in this config. Or in general really.
        I have never programmed in a functional language before. 
        That stuff all comes from the repo I cited. All I did was add some plugins,
        and import my config as a plugin.
        I feel like my main issue here is not knowing where 
        those $src and $out variables come from

    2. Why markdown preview isnt working. although that one is probably due to dependencies on node I think?

    3. How to include as input to flake something that isnt the main branch, 
        i.e. legacy tags and branch names.
