local M = {}
function M.setup(categories)
  if (categories.neonixdev) then
    require("myLuaConf.birdee.LSPs.neonixdev")
  elseif (categories.nix) then
    require("myLuaConf.birdee.LSPs.nix")
  elseif (categories.lua) then
    require("myLuaConf.birdee.LSPs.lua")
  end
end
return M
