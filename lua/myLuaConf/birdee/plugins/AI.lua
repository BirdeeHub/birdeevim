require("sg").setup({
  on_attach = require('myLuaConf.caps-onattach').on_attach,
  enable_cody = true,
})
local result
local tokenPath = vim.fn.expand("$HOME") .. "/.secrets/codyToken"
if vim.fn.filereadable(tokenPath) == 1 then
  local handle = io.open(tokenPath, "r")
  if handle then
    result = handle:read("*l")
    handle:close()
  end
  require('sg.auth').set_nvim_auth({
    tos_accepted = true,
    endpoint = 'https://sourcegraph.com',
    token = result,
  })
end
vim.keymap.set('n', '<leader>cs', require('sg.extensions.telescope').fuzzy_search_results, { noremap = true, desc = 'cody search' })
vim.keymap.set('n', '<leader>cc', [[<cmd>CodyToggle<CR>]], { noremap = true, desc = 'CodyChat' })
vim.keymap.set('v', '<leader>cc', [[:CodyAsk ]], { noremap = true, desc = 'CodyAsk' })

local full_dir_path = vim.fn.stdpath('cache') .. '/' .. 'codeium'
local full_file_path = full_dir_path .. '/' .. 'config.json'
local keyPath = vim.fn.expand("$HOME") .. "/.secrets/codeiumToken"
if vim.fn.filereadable(keyPath) == 1 then
  if vim.fn.filereadable(full_file_path) == 0 then
    local codeiumKey
    local codeiumHandle = io.open(keyPath, "r")
    if codeiumHandle then
      codeiumKey = codeiumHandle:read("*l")
      codeiumHandle:close()
    end
    if vim.fn.isdirectory(full_dir_path) == 0 then
      -- Directory does not exist, so create it
      vim.fn.mkdir(full_dir_path, 'p')
    end
    -- Open the file in write mode
    local file = io.open(full_file_path, 'w')
    -- Check if the file was successfully opened
    if file then
      file:write('{"api_key": "' .. codeiumKey .. '"}')
      file:close()
    end
  end
end
