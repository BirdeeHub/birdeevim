vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
require("birdee.plugins")
require("birdee.LSPs")
if require('nixCats').debug then
  require("birdee.debug")
end
-- if require('nixCats').formatting then
  require("birdee.format")
-- end
require("birdee.keymaps")
require("birdee.clippy")
require("birdee.opts")
