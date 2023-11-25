-- print(debug.getinfo(1, "S").source:sub(2))
if vim.g.vscode == nil then
  require("birdeeLua.birdee")
else
  -- a stripped down version for embedding
  require('birdeeLua.vscody')
end
