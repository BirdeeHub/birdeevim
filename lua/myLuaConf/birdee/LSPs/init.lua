local categories = require('nixCats')
if (categories.neonixdev) then
  require('neodev').setup({
    library = {
      -- runtime = categories.packpath + "," + vim.o.rtp,
      -- runtime = false,
      -- runtime = "/home/birdee/Projects/birdeeVim/"
    },
  })
  require("myLuaConf.birdee.LSPs.nix")
  require("myLuaConf.birdee.LSPs.lua")
elseif (categories.nix) then
  require("myLuaConf.birdee.LSPs.nix")
elseif (categories.lua) then
  require("myLuaConf.birdee.LSPs.lua")
end
if (categories.kotlin) then
  require("myLuaConf.birdee.LSPs.kotlin")
elseif (categories.java) then
  require("myLuaConf.birdee.LSPs.java")
end
if (categories.lspDebugMode) then
  vim.lsp.set_log_level("debug")
end
