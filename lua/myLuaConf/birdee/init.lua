vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.cmd.colorscheme "onedark"
require("myLuaConf.birdee.plugins")
require("myLuaConf.birdee.LSPs")
require("myLuaConf.birdee.debug")
require("myLuaConf.birdee.format")
require("myLuaConf.birdee.opts")
require("myLuaConf.birdee.keymaps")
