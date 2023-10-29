local M = {}
function M.setup(categories)
  vim.g.mapleader = ' '
  vim.g.maplocalleader = ' '
  require("myLuaConf.birdee.plugins").setup(categories)
  require("myLuaConf.birdee.LSPs").setup(categories)
  require("myLuaConf.birdee.debug")
  require("myLuaConf.birdee.format")
  require("myLuaConf.birdee.opts")
  require("myLuaConf.birdee.keymaps")
end
return M
