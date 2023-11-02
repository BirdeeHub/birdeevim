local myLuaConf = {}
function myLuaConf.setup(categories)
  if vim.g.vscode == nil then
    require("myLuaConf.birdee").setup(categories)
  else
    -- just in case I need to show someone something in vscode idk
    -- currently not implemented
    require('myLuaConf.vscody')
  end
end
return myLuaConf
