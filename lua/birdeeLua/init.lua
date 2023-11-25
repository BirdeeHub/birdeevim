
if vim.g.vscode == nil then
  require(require('nixCats').RCName .. ".birdee")
else
  -- a stripped down version for embedding
  require(require('nixCats').RCName .. '.vscody')
end
