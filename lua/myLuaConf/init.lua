local myLuaConf = {}
function myLuaConf.setup(serverList)
  if vim.g.vscode == nil then
    require("myLuaConf.birdee").setup(serverList)
  else
    -- just in case I need to show someone something in vscode idk
    require('myLuaConf.vscody')
  end
end
return myLuaConf
