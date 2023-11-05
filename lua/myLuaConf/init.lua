  -- if you have your own lua config, it starts here.
  -- when you want to query if a category is enabled do:
  -- local categories = require('nixCats')
  -- if(categories.categoryname) then

  -- It contains the table of name = boolean values 
  -- you created when choosing categories of packages and plugins
  -- nothing happens if you dont pass it in but you wont be able to use it.
  -- I just passed it in everywhere because why not.

  -- use lspconfig and dap and setup functions. 
  -- no package manager or mason
  -- (they honestly might still work though I dont actually know)
  -- (It would kinda defeat the purpose though)

  -- other than that, its just a normal config now.
if vim.g.vscode == nil then
  local categories = require('nixCats')
  require("myLuaConf.birdee").setup(categories)
else
  -- just in case I need to show someone something in vscode idk
  -- currently not implemented
  -- its basically to be just a stripped down version for embedding
  require('myLuaConf.vscody')
end
