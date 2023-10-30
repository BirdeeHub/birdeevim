local M = {}
function M.setup(categories)
  if (categories.neonixdev) then
    require("myLuaConf.birdee.LSPs.neonixdev")
  elseif (categories.nix) then
    require("myLuaConf.birdee.LSPs.nix")
  elseif (categories.lua) then
    require("myLuaConf.birdee.LSPs.lua")
  elseif (categories.java) then
    require("myLuaConf.birdee.LSPs.java")
  elseif (categories.kotlin) then
    require("myLuaConf.birdee.LSPs.kotlin")
  end
end
return M
