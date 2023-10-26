local M
if vim.g.vscode == nil then
  M = require('myLuaConf.birdee.caps-onattach')
else
  M = require('myLuaConf.vscody.caps-onattach')
end
return M
