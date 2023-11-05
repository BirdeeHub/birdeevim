--[[ Lua config Intro: meet nixCats!

if you have your own lua config, it starts here.
when you want to query if a category is enabled do:

local categories = require('nixCats')
if(categories.categoryname) then
  do stuff
end

It contains the table of name = boolean values 
you created when choosing categories of packages and plugins

use lspconfig and dap and setup functions. 
no package manager or mason
(they honestly might still work though I dont actually know)
(It would kinda defeat the purpose though)

other than that, its just a normal config now. 
]]

if vim.g.vscode == nil then
  require("myLuaConf.birdee")
else
  -- currently not implemented
  -- its basically to be just a stripped down version for embedding
  require('myLuaConf.vscody')
end
