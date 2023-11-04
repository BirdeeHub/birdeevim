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
I decided to also pass in a table of categories to the config to
aid in creating packages specific to languages or projects.

To add new categories, simply add a new list, and enable the category

#### thus, the automatically generated init.vim calls:
```
lua require('myLuaConfig').setup({<table of categories with boolean values>})
```
This is generated in [NeovimBuilder](./nix/NeovimBuilder.nix) 
based on the categories enabled, and the categories of plugins or dependencies present

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

inpiration taken heavily on core sections from this repo as this was my first intro to nix.

[Luca's super simple neovim flake configuration](https://github.com/Quoteme/neovim-flake/tree/master)

[pluginOverlay is directly from there](./nix/pluginOverlay.nix)

It taught me how to use an overlay. Thank you.

---
Also I have questions and to do's and I list them at the end to ask for guidance because I really am very new to nix

---

## Overview:

### The 3 main files you would need to use if you used this:

---

##### the flake itself is mostly just a couple big lists of what you want to add.
-- [flake.nix](./flake.nix) structure:

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
    passing it a set of categories to include.

    output packages and devshell definition

-- [customPluginOverlay](./nix/customPluginOverlay.nix)

    I have this separate overlay file in which I do all the 
    custom derivations for plugins with build steps not handled by nixpkgs.
    That separate file is located at ./nix/customPluginOverlay.nix
    Access the plugins defined there with pkgs.customNVIMplugins
    they were the only thing that isnt just a big list 
    in the main flake file so I moved them to their own place.

-- [require('myLuaConf')](./lua/myLuaConf/init.lua)

    its the start of your lua config, if you skipped the first init.lua at root.
    it gets called with setup(categories) which is a table of 
    booleans passed from when you add categories to packages in the flake.nix file
    if you wish to change the name to something other than myLuaConf you can go to ./nix/NeovimBuilder.nix
    if you want to add ftplugin folder and stuff, add that at root, same level as lua folder.
    the whole flake is a config folder, minus the inital init.lua, which is in ./nix/NeovimBuilder.nix

---

### And 2 files you shouldn't need to mess with much:

---

-- [pluginOverlay](./nix/pluginOverlay.nix)

    an overlay for convenience that autoadds non-flake github plugins that dont need build steps.
    Used by naming the flake input "plugins-pluginName"

-- [NeovimBuilder](./nix/NeovimBuilder.nix)

    A file where all the lists of plugins and lsps are combined, 
    filtered appropriately based on categories included.

    The init.vim is generated in that file as mentioned above in the introduction.
    The flake directory is included as a plugin there.
    The neovim package itself is also built there.

    To change the name of myLuaConf folder, you must also change the name
    in the 3 places this file mentions it

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
