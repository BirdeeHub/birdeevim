### Another Neovim flake

## Attention: This repo is unfinished. The lua hasnt been cleaned up, it has no debuggers or formatters. This is my first time using nix.

The idea is, replace lazy and mason with nix, 
keep everything else in lua. I am managing LSP's with nvim-lspconfig, 
and will be managing debuggers with regular dap stuff when I get to it.
Fully reproducble package management, reasonably non-painful config.

But I wanted to also manage and download the lua with the flake.
I wanted to also be able to easily specifically package for projects.
Also the wrapper I have figured out how to use only does init.vim

The solution? Include my flake itself as a plugin. 
I decided to also pass in a table of categories to the config to
aid in creating packages specific to languages or projects.
thus, the automatically generated init.vim calls:
```
lua require('myLuaConfig').setup({<table of categories with values true or false (or not included)>})
```
The reason I want to do it this way is the setup instructions 
for new plugins are all in Lua.

If I want to not load it on startup, 
I can just put it in opt section and call packadd 
from an autocommand if I want to do lazy loading.

Even though it is supposed to be loaded as a plugin and thus should work, 
I am unsure if including an ftplugin folder works or not as I have not checked.
Make sure it is added to your git staging or committed or it wont update and find the new file.

inpiration taken HEAVILY from this repo as this was my first intro to nix.

https://github.com/Quoteme/neovim-flake/tree/master

---

## Overview:

#### The 2 main files you would need to use if you used this:

---

the flake itself is mostly just a couple big lists of what you want to add.

```
flake.nix structure:

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

a builder function containing the following:
a flexible set of categories containing lists of startup plugins,
a flexible set of categories containing lists of optional plugins,
a flexible set of categories containing lists of LSP's or internal *runtime* dependencies

generate packages by calling that builder function,
passing it a set of categories to include.

output packages and devshell definition
```
nix/customPluginOverlay.nix
```
I have a separate file in which I do all the custom derivations for plugins with build steps.

That separate file is located at ./nix/customPluginOverlay.nix

Access the plugins defined there with pkgs.customNVIMplugins

they were the only thing that isnt just a big list in the main file so I moved them to their own place.
```

### And 2 files you shouldn't need to mess with much:

---

an overlay for convenience that autoadds non-flake github plugins that dont need build steps.

Used by naming the flake input "plugins-pluginName"

---

A file where all the lists of plugins and lsps are combined, filtered appropriately based on categories included,

The init.vim is generated in that file as mentioned above in the introduction.

The flake directory is included as a plugin there.

The neovim package itself is also built there.

---

## Questions:

    1. How to include as input to flake something that isnt the main branch, 
        i.e. legacy tags and branch names.

    2. How to give the option to compile nvim for debug mode.
