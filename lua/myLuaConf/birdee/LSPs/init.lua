local M = {}
function M.setup(categories)
  if (categories.neonixdev) then
    require('neodev').setup({})
    require("myLuaConf.birdee.LSPs.nix")
    require("myLuaConf.birdee.LSPs.lua")
  elseif (categories.nix) then
    require("myLuaConf.birdee.LSPs.nix")
  elseif (categories.lua) then
    require("myLuaConf.birdee.LSPs.lua")
  elseif (categories.java) then
    require("myLuaConf.birdee.LSPs.java")
  elseif (categories.kotlin) then
    require("myLuaConf.birdee.LSPs.kotlin")
  elseif (categories.lspDebugMode) then
    vim.lsp.set_log_level("debug")
  end
end
return M
