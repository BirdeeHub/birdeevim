if vim.g.vscode == nil then
  require("myLuaConf.birdee")
else
  -- just in case I need to show someone something in vscode idk
  require('myLuaConf.vscody')
end
