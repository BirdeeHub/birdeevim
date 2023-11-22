require("sg").setup({
  on_attach = require('myLuaConf.caps-onattach').on_attach,
  enable_cody = true,
})
local result
local appname = vim.fn.expand('$NVIM_APPNAME')
if (appname == "$NVIM_APPNAME") then
  appname = 'nvim'
end
local handle = io.popen("cat ~/.cache/".. appname .."/codyToken")
if handle then
  result = handle:read("*a")
  handle:close()
end
require('sg.auth').set_nvim_auth({
  tos_accepted = true,
  endpoint = 'https://sourcegraph.com',
  token = result,
})
vim.keymap.set('n', '<leader>cs', require('sg.extensions.telescope').fuzzy_search_results, { noremap = true, desc = 'cody search' })
vim.keymap.set('n', '<leader>cc', [[<cmd>CodyToggle<CR>]], { noremap = true, desc = 'CodyChat' })
vim.keymap.set('v', '<leader>cc', [[:CodyAsk ]], { noremap = true, desc = 'CodyAsk' })
