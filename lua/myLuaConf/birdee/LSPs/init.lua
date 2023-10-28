local M = {}
function M.setup(serverlist)
  if (serverlist.neonixdev) then
    require("myLuaConf.birdee.LSPs.neonixdev")
  elseif (serverlist.nix) then
    require("myLuaConf.birdee.LSPs.nix")
  elseif (serverlist.lua) then
    require("myLuaConf.birdee.LSPs.lua")
  end
end
return M
