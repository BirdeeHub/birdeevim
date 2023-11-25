vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
require("birdeeLua.birdee.plugins")
require("birdeeLua.birdee.LSPs")
if require('nixCats').debug then
  require("birdeeLua.birdee.debug")
end
require("birdeeLua.birdee.format")
require("birdeeLua.birdee.keymaps")
require("birdeeLua.clippy")
require("birdeeLua.birdee.opts")
require("birdeeLua.birdee.AI")
