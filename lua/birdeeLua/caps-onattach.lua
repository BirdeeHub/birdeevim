local M
if vim.g.vscode == nil then
  M = require(require('nixCats').RCName .. '.birdee.caps-onattach')
else
  M = require(require('nixCats').RCName .. '.vscody.caps-onattach')
end
return M
