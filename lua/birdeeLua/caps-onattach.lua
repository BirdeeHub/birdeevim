local M
if vim.g.vscode == nil then
  M = require('birdeeLua.birdee.caps-onattach')
else
  M = require('birdeeLua.vscody.caps-onattach')
end
return M
