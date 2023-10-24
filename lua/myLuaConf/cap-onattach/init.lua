local M
if vim.g.vscode == nil then
  M = require('myLuaConf.cap-onattach.birdee')
else
  M = require('myLuaConf.cap-onattach.vscody')
end
return M
