My attempt at a Neovim Flake using 

inpiration taken HEAVILY from this repo as this was my first intro to nix.

https://github.com/Quoteme/neovim-flake/tree/master

Unfortunately, customRC only takes vimscript.
The solution? Include my Lua as a plugin. 
Unfortunately, I did it incompletely. I can only include the 1 file in birdeeLua.

I could use some help.

I am new to nix. 
I have an okish neovim config. 
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

I haven't added any LSP's yet, thats next.
I should just be able to add them as inputs
then require('lspconfig') I think? not sure.

    1. I dont know how to build nvim plugins with a build step in nix using the 
        overlay in this config. Or in general really. I barely know what an Overlay is.
        I have never programmed in a functional language before.

    2. I need to know why treesitter parsers cant install

    3. Why markdown preview isnt working.

    4. How to include as input to flake something that isnt the main branch

    4. how to make it so I can package and require more than just the 1 init.lua 
        file from within the lua files. squeezing it all into one file isn't fun.
        I cannot require other lua files from my config from within my config 
        by using require('birdeeLua.anythingElse')

