vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
require("birdee.plugins")
require("birdee.LSPs")
if require('nixCats').debug then
  require("birdee.debug")
end
require("birdee.format")
require("birdee.keymaps")
require("clippy")
require("birdee.opts")
require("birdee.AI")