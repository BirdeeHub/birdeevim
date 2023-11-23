
if vim.g.vscode == nil then
  require(require('nixCats').RCName .. ".birdee")
else
  -- currently not implemented
  -- its basically to be just a stripped down version for embedding
  require(require('nixCats').RCName .. '.vscody')
end
