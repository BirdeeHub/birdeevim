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

I haven't added any LSP's yet, thats next.
I should just be able to add them as inputs in the flake and then 
As inputs into something else?
then require('lspconfig') I think? not sure.

## Questions:

    1. I dont know how to build nvim plugins with a build step 
        like build = ./install.sh included by a plugin in nix using the 
        overlay in this config. Or in general really.
        I have never programmed in a functional language before. 
        That stuff all comes from the repo I cited. All I did was add some plugins,
        and import my config as a plugin.
        I feel like my main issue here is not knowing where 
        those $src and $out variables come from

    2. I need to know why treesitter parsers cant install

    3. Why markdown preview isnt working. although that one is probably due to dependencies on node I think?

    4. How to include dependencies like cargo or node that plugins require.
        in a way that they can actually use them.

    5. How to include as input to flake something that isnt the main branch, 
        i.e. legacy tags and branch names.

    6. why lspconfig.lua_ls runs but neodev does not.





this error in LspLogs seems to be from lua-lsp though

[ERROR][2023-10-25 08:19:08] .../vim/lsp/rpc.lua:734	"rpc"	"/nix/store/kaizklhznir24y7l706hjnqvndw55kj9-luajit2.1-lua-lsp-0.1.0-2/bin/lua-lsp"	"stderr"	"Error: ...jit2.1-lua-lsp-0.1.0-2/share/lua/5.1/lua-lsp/methods.lua:521: attempt to index local 'top_value' (a nil value)\nstack traceback:\n\t...jit2.1-lua-lsp-0.1.0-2/share/lua/5.1/lua-lsp/methods.lua:521: in function 'definition_of'\n\t...jit2.1-lua-lsp-0.1.0-2/share/lua/5.1/lua-lsp/methods.lua:624: in function <...jit2.1-lua-lsp-0.1.0-2/share/lua/5.1/lua-lsp/methods.lua:614>\n\t...luajit2.1-lua-lsp-0.1.0-2/share/lua/5.1/lua-lsp/loop.lua:57: in function <...luajit2.1-lua-lsp-0.1.0-2/share/lua/5.1/lua-lsp/loop.lua:56>\n\t[C]: in function 'xpcall'\n\t...luajit2.1-lua-lsp-0.1.0-2/share/lua/5.1/lua-lsp/loop.lua:56: in function 'main'\n\t....1.0-2/lua-lsp-0.1.0-2-rocks/lua-lsp/0.1.0-2/bin/lua-lsp:3: in main chunk\n\t[C]: at 0x004062d0\n"
