local M = {}
function M.setup(categories)
  vim.g.mapleader = ' '
  vim.g.maplocalleader = ' '
  -- I just passed categories into everything 
  -- whether it was needed or not
  require("myLuaConf.birdee.plugins").setup(categories)
  require("myLuaConf.birdee.LSPs").setup(categories)
  require("myLuaConf.birdee.debug").setup(categories)
  require("myLuaConf.birdee.format").setup(categories)
  require("myLuaConf.birdee.opts").setup(categories)
  require("myLuaConf.birdee.keymaps").setup(categories)
end
return M
