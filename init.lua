vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.cmd.colorscheme "catppuccin"
require('birdeeLua').plugins()
require('birdeeLua').opts()
require('birdeeLua').keymaps()
require('birdeeLua').LSPs(require('birdeeLua').on_attach, require('birdeeLua').get_capabilities())
require('birdeeLua').debug()
require('birdeeLua').autoformat()
