vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
require(require('nixCats').RCName .. ".birdee.plugins")
require(require('nixCats').RCName .. ".birdee.LSPs")
if require('nixCats').debug then
  require(require('nixCats').RCName .. ".birdee.debug")
end
require(require('nixCats').RCName .. ".birdee.format")
require(require('nixCats').RCName .. ".birdee.keymaps")
require(require('nixCats').RCName .. ".clippy")
require(require('nixCats').RCName .. ".birdee.opts")
require(require('nixCats').RCName .. '.birdee.AI')
