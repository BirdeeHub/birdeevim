local categories = require('nixCats')
if (categories.neonixdev) then
  require('neodev').setup({})
  -- someone who forked me showed me about this plugin
  -- it allows our thing to have plugin library detection
  -- despite not being in our .config/nvim folder
  -- I was unaware of this plugin.
  -- https://github.com/lecoqjacob/nixCats-nvim/blob/main/.neoconf.json
  require("neoconf").setup({
    plugins = {
      lua_ls = {
        enabled = true,
        enabled_for_neovim_config = true,
      },
    },
  })
  require("myLuaConf.birdee.LSPs.nix")
  require("myLuaConf.birdee.LSPs.lua")
elseif (categories.nix) then
  require("myLuaConf.birdee.LSPs.nix")
elseif (categories.lua) then
  require("myLuaConf.birdee.LSPs.lua")
end
if (categories.kotlin) then
  require("myLuaConf.birdee.LSPs.kotlin")
elseif (categories.java) then
  require("myLuaConf.birdee.LSPs.java")
end
if (categories.lspDebugMode) then
  vim.lsp.set_log_level("debug")
end
