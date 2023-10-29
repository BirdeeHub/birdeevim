local M = {}
function M.setup(serverList)
  vim.g.mapleader = ' '
  vim.g.maplocalleader = ' '
  require("myLuaConf.birdee.plugins").setup(serverList)
  require("myLuaConf.birdee.LSPs").setup(serverList)
  require("myLuaConf.birdee.debug")
  require("myLuaConf.birdee.format")
  require("myLuaConf.birdee.opts")
  require("myLuaConf.birdee.keymaps")
end
return M
