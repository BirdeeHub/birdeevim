vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
-- I just passed categories into everything 
-- whether it was needed or not
require("myLuaConf.birdee.plugins")
require("myLuaConf.birdee.LSPs")
require("myLuaConf.birdee.debug")
require("myLuaConf.birdee.format")
require("myLuaConf.birdee.opts")
require("myLuaConf.birdee.keymaps")
