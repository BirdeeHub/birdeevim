
local bitwardenAuth = require('nixCats').bitwarden

require("sg").setup({
  on_attach = require('myLuaConf.caps-onattach').on_attach,
  enable_cody = true,
})
if (require('sg.auth').valid() == false) then
  local tokenPath = vim.fn.expand("$HOME") .. "/.secrets/codyToken"
  if (bitwardenAuth or vim.fn.filereadable(tokenPath) == 1) then
    local result
    local handle
    if bitwardenAuth then
      handle = io.popen("bw get notes d0bddbff-ec1f-4151-a2a7-b0c20134eb34", "r")
    else
      handle = io.open(tokenPath, "r")
    end
    if handle then
      result = handle:read("*l")
      handle:close()
    end
    if (string.len(result) == 44) then
      require('sg.auth').set_nvim_auth({
        tos_accepted = true,
        endpoint = 'https://sourcegraph.com',
        token = result,
      })
    end
  end
end
vim.keymap.set('n', '<leader>cs', require('sg.extensions.telescope').fuzzy_search_results, { noremap = true, desc = 'cody search' })
vim.keymap.set('n', '<leader>cc', [[<cmd>CodyToggle<CR>]], { noremap = true, desc = 'CodyChat' })
vim.keymap.set('v', '<leader>cc', [[:CodyAsk ]], { noremap = true, desc = 'CodyAsk' })

local full_dir_path = vim.fn.stdpath('cache') .. '/' .. 'codeium'
local full_file_path = full_dir_path .. '/' .. 'config.json'
if vim.fn.filereadable(full_file_path) == 0 then
  local keyPath = vim.fn.expand("$HOME") .. "/.secrets/codeiumToken"
  if (bitwardenAuth or vim.fn.filereadable(keyPath) == 1) then
    local codeiumKey
    local codeiumHandle
    if bitwardenAuth then
      codeiumHandle = io.popen("bw get notes d9124a28-89ad-4335-b84f-b0c20135b048", "r")
    else
      codeiumHandle = io.open(keyPath, "r")
    end
    if codeiumHandle then
      codeiumKey = codeiumHandle:read("*l")
      codeiumHandle:close()
    end
    if vim.fn.isdirectory(full_dir_path) == 0 then
      -- Directory does not exist, so create it
      vim.fn.mkdir(full_dir_path, 'p')
    end
    if (string.len(codeiumKey) == 36) then
      -- Open the file in write mode
      local file = io.open(full_file_path, 'w')
      -- Check if the file was successfully opened
      if file then
        file:write('{"api_key": "' .. codeiumKey .. '"}')
        file:close()
      end
    end
  end
end

local M = {}
function M.deleteFileIfExists(file_path)
  if vim.fn.filereadable(file_path) == 1 then
    os.remove(file_path)
  end
end
vim.cmd([[command! DeleteSGAuth lua require('myLuaConf.birdee.plugins.AI').deleteFileIfExists(vim.fn.stdpath('data') .. '/cody.json')]])
vim.cmd([[command! DeleteCodeiumAuth lua require('myLuaConf.birdee.plugins.AI').deleteFileIfExists(vim.fn.stdpath('cache') .. '/codeium/config.json')]])
return M
