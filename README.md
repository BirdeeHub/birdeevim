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
even though it is supposed to be loaded as a plugin and thus should work, 
I am unsure if including an ftplugin folder works or not as I have not checked.

## Questions:

    1. I dont know how to build nvim plugins with a build step 
        like build = ./install.sh included by a plugin in nix?
        Do I just define a custom derivation for those and pass 
        them in like I did my config?

    2. How to include as input to flake something that isnt the main branch, 
        i.e. legacy tags and branch names.
