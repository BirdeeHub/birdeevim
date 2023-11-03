local myLuaConf = {}
function myLuaConf.setup(categories)
  if vim.g.vscode == nil then
    -- if you have your own lua config, it starts here.

    -- Make sure categories is passed to where you want to use it
    -- It contains the table of name = boolean values 
    -- you created when choosing categories of packages and plugins

    -- use lspconfig and dap and setup functions. 
    -- no package manager or mason
    -- (they honestly might still work though I dont actually know)

    -- other than that, its just a normal config now.
    require("myLuaConf.birdee").setup(categories)
  else
    -- just in case I need to show someone something in vscode idk
    -- currently not implemented
    -- its basically to be just a stripped down version for embedding
    require('myLuaConf.vscody')
  end
end
return myLuaConf
