vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
if require('nixCats').nixCats_packageName ~= "minimal" then
  require("birdee.plugins")
  require("birdee.LSPs")
  if require('nixCats').debug then
    require("birdee.debug")
  end
  require("birdee.format")
end
require("birdee.keymaps")
require("birdee.clippy")
require("birdee.opts")
