# A Lua-natic's neovim flake: birdeeVim

:help [birdee.flake](./doc/birdeeVimDoc.txt)

:help [nixCats](./nix/nixCats.nix)

There is no lua help file. 

Its just regular lua config without an initial init.lua file.

And also nixCats. see 
:help [nixCats](./nix/nixCats.nix)

## Introduction

The idea is, replace lazy and mason with nix, 
keep everything else in lua. 

I am managing LSP's with nvim-lspconfig, 
and will be managing debuggers with regular dap stuff when I get to it.
Fully reproducble package management, reasonably non-painful config.

You should only need to interact with flake.nix, and occasionally customPluginOverlay.nix.
Both are in the root directory of this repo.
The help pages I have provided should be useful. Other than that, it is all lua.

#### Attention!! This repo is unfinished!
    The flake scheme itself is very useable, including how it
        communicates with the lua config.
        The ./nix directory is where the
        magic happens for sorting the categories
        and creating nixCats.
        All you have to do is add plugins to lists.
        And then enable those lists.

    The lua config itself still leaves many things to be desired.
        I'm not the most seasoned at neovim config.
        But its regular, I'm having regular nvim lua problems.
        Like, how to do debuggers and stuff. Nothing to do with nix.
        You should probably scrap most of my lua config if
        you are any good at configuring neovim.

This is not a minimal config. It is my config where I try to do all the things. 

It is, however, very easy to make a minimal package with it should you choose to do so.

To do that:

    Optionally delete all the categories of plugins you dont want,
    (it is optional because you could just create new categories and only enable those)
    copy your config in (minus the init.lua at the root of your config folder),
    change RCName to point to your config,
    add your plugins to your desired categories,
    enable any categories you want to use to package for YOUR specific projects/languages/environments
    add your new package to the list of outputs.

    Within the lua you will also have to change any 
    package manager plugin setups to regular .setup() calls
    because they have already been installed via nix. 
    but thats just swapping to a new plugin manager.
    Except this time you are simultaneously learning the default way
    that all the other managers call.

    You can check for what categories are available to your config
    in your lua with nixCats so that you can use the same 
    lua config for many different projects and not get any plugin not found errors.

There are more features you COULD use, but thats the basics!

Oh, and, for the rare plugin not handled well by nixpkgs, 
that doesnt have a flake, AND has a non-cmake build step?

Thats what customPluginOverlay exists for. I have only needed it 1 time.

To learn to use this flake and get an overview of how it works,

:help [birdee.flake](./doc/birdeeVimDoc.txt)

## Philosophy and Design

This is my first time using nix. I'm also semi new to neovim but I like it a lot.
So I wanted my scheme to be simple.
I also wanted to be able to copy paste setup functions for new plugins
right into my lua rather than adding hooks for a DSL.

But I wanted to also be able to easily specifically package for projects.
Also the wrapper I have figured out how to use only does init.vim

The solution to a regular config? 
Include my flake itself as a plugin. 

The solution to project specific config?
It also creates a new plugin called nixCats

require('nixCats') returns a table of booleans stating if that category is enabled in the flake
to aid in creating packages specific to languages or projects.

You can find out what cats you have whenever you require nixCats, 
and you may do this as much as you want, even in ftplugin and autoload folders!

They can also say meow in tables of lists of tables if you wish.

for more info, see :help [nixCats](./nix/nixCats.nix)

To add new categories, simply add a new list in flake.nix in the desired section, and enable the category

Currently the automatically generated init.vim calls: lua require('myLuaConf').
If you want to change the name of the folder used from lua directory, 
you must provide a different name to RCName attribute in flake.nix so that it uses the new folder.
It will change myLuaConf to your new folder name in the generated init.vim and require it instead.

This would be a good idea, for example, if you wanted to copy your own folder in and then 
change mason for lspconfig and package manager for setup functions.

That way you dont have to change all your internal require calls.

see :help birdee.flake.outputs.RCName

#### These are the reasons I wanted to do it this way: 

    The setup instructions for new plugins are all in Lua so translating them is effort.
    
    I didnt want to be forced into creating a new lua file for every plugin.
    
    I wanted my neovim config to be neovim flavored 
        (so that I can take advantage of all the neovim dev tools with minimal fuss)

    I still wanted my config to know what plugins and LSPs I included in the package

The table of categories allows me to react to 
dynamic packaging within the lua config.

Lua doesn't throw errors if the index wasnt included, it just returns nil
which allows you check if it is true and not worry about index out of range.

If I want to not load it on startup, 
I can just put it in opt section and call packadd 
from an autocommand if I want to do lazy loading.

ftplugin folder works. The others all should as well. 
Plugins and config files are the same thing.
Make sure new lua files are added to your git staging or committed
before testing it or it wont update and find the new file.

It runs correctly on a fresh nixOs install 
with only i3, xfce.xfce4-terminal, xclip, xsel, git, and flakes enabled.
Any terminal that supports bracketed paste will work, I just like that one's default font.

It also runs correctly on a manjaro system with random stuff installed including other versions of all of it's dependencies.
Also I am not sure I even have nix package manager installed correctly on it because I can only import specific packages on the nixOS vm....

It runs correctly with less as well but you wont be able to copy paste into the terminal 
section of nvim without bracketed paste and without a clipboard at all you cant copy paste into or out of it at all. Or, well, into or out of anything.

I have not tested on wsl or mac yet, but it might work. It has cmake and neovim and the plugins with external portions are cross platform?

## To Do:
It has dap and dap-ui but no debuggers for languages
and no auto formatters. 

If you add a debugger to it please let me know.

I didn't really have time to understand configuring dap yet before I heard about nix.
I was only using neovim for about 3 months before making this flake, and hadn't tried to do that yet.
You just put the debugger in lspAndDeps and then configure in lua, but I don't know how to do the lua part?

It might remain incomplete for a little while as I work on
getting the rest of my stuff working on nixOS like nvidia and whatnot so I can swap.

## Questions:

    1. How to include as input to flake something that isnt the main branch, 
        i.e. legacy tags and branch names.

    2. Can someone provide links showing people setting up 
        language debuggers for dap and dap-ui without mason in Lua?
        Regular or Nix it doesnt matter, just no non-nix package managers for the debugger itself.

    3. Why can I only select a non-default package in bash? In zsh it says bad pattern or no match.

---

Many thanks to Quoteme for a great repo to teach me the basics of nix!!! I borrowed some code from it as well because I couldn't have written it better yet.

[pluginOverlay](./nix/pluginOverlay.nix) is a file copy pasted from [a section of Quoteme's repo.](https://github.com/Quoteme/neovim-flake/blob/34c47498114f43c243047bce680a9df66abfab18/flake.nix#L42C8-L42C8)

Thank you!!! It taught me both about an overlay's existence and how it works.

for finer details on the builder function itself in the nix directory

see: [birdee.nixperts.neovimBuilder](./doc/nvimBuilder.txt)

If you are new to nix, dont worry about that one. You won't need it, and if you do, 
it is as simple as adding an argument and calling a function an extra time 
and you should look at the bottom of the file for how to do that.
