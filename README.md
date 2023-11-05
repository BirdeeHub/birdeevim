# A Lua-natic's nvim flake: birdeeVim

## Introduction

The idea is, replace lazy and mason with nix, 
keep everything else in lua. 

I am managing LSP's with nvim-lspconfig, 
and will be managing debuggers with regular dap stuff when I get to it.
Fully reproducble package management, reasonably non-painful config.

This is my first time using nix. I'm also semi new to neovim but I like it a lot.
So I wanted my scheme to be simple.
I also wanted to be able to copy paste setup functions for new plugins
right into my lua rather than adding hooks for a DSL.

But I wanted to also manage and download the lua with the flake.
I wanted to also be able to easily specifically package for projects.
Also the wrapper I have figured out how to use only does init.vim

The solution? Include my flake itself as a plugin. 

It also creates a new plugin called nixCats

require('nixCats') returns a table of booleans stating if that category is enabled in the flake
to aid in creating packages specific to languages or projects.
```lua
    local cats = require('nixCats')
    if(cats.nix) then
        -- some stuff here
    end
```
    you can find out what cats you have whenever you require nixCats, 
    and you may do this as much as you want.

To add new categories, simply add a new list in flake.nix in the desired section, and enable the category

Currently the automatically generated init.vim calls:
```
lua require('myLuaConf')
```
If you want to change the name of the folder used from lua directory, 
you must provide a different name to RCName attribute in [flake.nix](./flake.nix).
That attribute is provided to [NeovimBuilder](./nix/NeovimBuilder.nix), and
you do this in the same place you add plugins to categories.
It will change myLuaConf to your new folder name in the generated init.vim and require it instead.

#### These are the reasons I wanted to do it this way: 

    The setup instructions for new plugins are all in Lua so translating them is effort, 
    I didnt want to be forced into creating a new lua file for every plugin,
    I wanted my neovim config to be neovim flavored 
        (so that I can take advantage of all the neovim dev tools with minimal fuss)

The table of categories allows me to react to 
dynamic packaging within the lua config.

Lua doesn't throw errors if the index wasnt included, 
it just returns nil which allows you check if and not worry.

If I want to not load it on startup, 
I can just put it in opt section and call packadd 
from an autocommand if I want to do lazy loading.

ftplugin folder works. The others all should as well. 
Plugins and config files are the same thing.
Make sure new lua files are added to your git staging or committed
before testing it or it wont update and find the new file.

It runs correctly on a fresh nixOs install 
with only i3, xfce.xfce4-terminal, xclip, xsel, git, and flakes enabled.
Any terminal that supports bracketed paste will work, I just like that one's defaults.
It runs correctly with less as well but you wont be able to copy paste without a clipboard and you might want that anyway...
I have not tested on wsl or mac yet, but it might work. It has cmake and neovim and the plugins with external portions are cross platform?


---
Also I have questions and to do's and I list them at the end to ask for guidance because I really am very new to nix

---

## Overview:

### The 3 main files you would need to use if you used this:

---

##### the flake itself is mostly just a couple big lists of what you want to add.
When I want to add plugins or package for a specific project, 
this is usually the only nix file I need to interact with.

-- [flake.nix](./flake.nix)

    A set of inputs:
    name the plugins you import "plugins-somepluginname" if they dont have a build step.
    Then add them to the desired category in the builder function.
    Access them to add them to builder with pkgs.neovimPlugins.somepluginname
    If they have a build step or are not a plugin, i.e. an lsp, dont name them in that format.

    outputs function:

    a few overlay imports, including the custom plugin overlay 
    (used for defining plugins with build steps. 
    Access them later to add with pkgs.customNVIMplugins)

    the generation of pkgs object with applied overlays and system variable.

    a builder function created by importing nix/NeovimBuilder containing the following:
    - a flexible set of categories containing lists of startup plugins,
    - a flexible set of categories containing lists of optional plugins,
    - a flexible set of categories containing lists of LSP's or internal *runtime* dependencies
    - a flexible set of categories containing lists of internal *build time* dependencies

    generate packages by calling that builder function,
    passing it a set of categories to include. (You can require'nixCats' for it later)

    output packages and devshell definition

-- [require('myLuaConf')](./lua/myLuaConf/init.lua)

    It is the start of your lua config, exactly like normal.
    In your normal config file, there is an init.lua at root level.
    In our case, it is called from the init.vim generated by NeovimBuilder
    if you wish to change the folder name to something other than myLuaConf, 
    you can change the value of RCName in flake.nix

    you can ask what cats you have whenever you require nixCats
    and you may do this as much as you want.

    if you want to add ftplugin folder and stuff, add that at root level of the flake, 
    at the same level as lua folder. The whole flake is a plugin, which works the same as a config.

-- [customPluginOverlay](./nix/customPluginOverlay.nix)

    I have this separate overlay file in which I do all the 
    custom derivations for plugins with build steps not handled by nixpkgs.
    That separate file is located at ./nix/customPluginOverlay.nix
    Access the plugins defined there with pkgs.customNVIMplugins

    they were the only thing that isnt just a big list in the main flake
    file so I moved them to their own place. Plus, they can be messy occasionally

---

### And 2 files you shouldn't need to mess with much:

---

-- [pluginOverlay](./nix/pluginOverlay.nix)

[A file copy pasted from a section of Quoteme's repo.](https://github.com/Quoteme/neovim-flake/blob/34c47498114f43c243047bce680a9df66abfab18/flake.nix#L42C8-L42C8)

Thank you!!! It taught me both about an overlay and how it works.

    an overlay for convenience that autoadds non-flake github plugins that dont need build steps.
    Used by naming the flake input "plugins-pluginName"

-- [NeovimBuilder](./nix/NeovimBuilder.nix)

    A file where all the lists of plugins and lsps are combined, 
    filtered appropriately based on categories included.

    The init.vim is generated in that file.
    nixCats is generated in that file.
    The flake directory is included as a plugin there.
    The neovim package itself is also built there.

---

## To Do:
It has dap and dap-ui but no debuggers for languages
and no auto formatters. If you add a debugger to it please let me know.
I didnt really have time to understand configuring dap yet before I heard about nix.
I was only using neovim for about 3 months before making this flake, and hadn't tried to do that yet.

It might remain incomplete for a little while as I work on
getting the rest of my stuff working on nixOS like nvidia and whatnot so I can swap.

## Questions:

    1. How to include as input to flake something that isnt the main branch, 
        i.e. legacy tags and branch names.

    2. Can someone provide links showing people setting up 
        language debuggers for dap and dap-ui without mason in Lua?
        Regular or Nix it doesnt matter, just no non-nix package managers for the debugger itself.

    3. how to actually target a specific flake package from cli commands
        note, I have tried every variation of .#packagename and ./.#packagename 
        and .#<something>.packagename and ./.#<something>.packagename
        that I could find in the repl. I even tried it straight from github!
