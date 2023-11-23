local M = {}
local function AuthTerminal()
  local result
  local handle
  handle = io.popen([[bw login --check ]], "r")
  if handle then
    result = handle:read("*l")
    handle:close()
  end
  if result == "You are logged in!" then
    handle = io.popen([[bw unlock --raw --nointeraction ]] .. vim.fn.inputsecret('Enter password: '), "r")
    if handle then
      result = handle:read("*l")
      handle:close()
    end
  else
    local email = vim.fn.inputsecret('Enter email: ')
    local pass = vim.fn.inputsecret('Enter password: ')
    local client_secret = vim.fn.inputsecret('Enter api key client_secret: ')
    handle = io.popen([[bw login --raw --quiet ]] .. email .. " " .. pass .. ">/dev/null 2>&1", "w")
    if handle then
      handle:write(client_secret)
      handle:close()
    end
    handle = io.popen([[bw unlock --raw --nointeraction ]] .. pass, "r")
    if handle then
      result = handle:read("*l")
      handle:close()
    end
  end
  return result
end

local authItemIDs = require('nixCats').bitwardenItemIDs
local bitwardenAuth = require('nixCats').bitwarden
local codeiumDir = vim.fn.stdpath('cache') .. '/' .. 'codeium'
local codeiumAuthFile = codeiumDir .. '/' .. 'config.json'
local session
if bitwardenAuth then
  if (require('sg.auth').valid() == false or vim.fn.filereadable(codeiumAuthFile) == 0) then
    session = AuthTerminal()
  end
end
if (require('sg.auth').valid() == false) then
  local tokenPath = vim.fn.expand("$HOME") .. "/.secrets/codyToken"
  if (bitwardenAuth or vim.fn.filereadable(tokenPath) == 1) then
    local result
    local handle
    if bitwardenAuth then
      handle = io.popen("bw get --nointeraction --session " .. session .. " " .. authItemIDs.cody, "r")
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
require("sg").setup({
  on_attach = require('myLuaConf.caps-onattach').on_attach,
  enable_cody = true,
})
vim.keymap.set('n', '<leader>cs', require('sg.extensions.telescope').fuzzy_search_results, { noremap = true, desc = 'cody search' })
vim.keymap.set('n', '<leader>cc', [[<cmd>CodyToggle<CR>]], { noremap = true, desc = 'CodyChat' })
vim.keymap.set('v', '<leader>cc', [[:CodyAsk ]], { noremap = true, desc = 'CodyAsk' })

if vim.fn.filereadable(codeiumAuthFile) == 0 then
  local keyPath = vim.fn.expand("$HOME") .. "/.secrets/codeiumToken"
  if (bitwardenAuth or vim.fn.filereadable(keyPath) == 1) then
    local result
    local handle
    if bitwardenAuth then
      handle = io.popen("bw get --nointeraction --session " .. session .. " " .. authItemIDs.codeium, "r")
    else
      handle = io.open(keyPath, "r")
    end
    if handle then
      result = handle:read("*l")
      handle:close()
    end
    if vim.fn.isdirectory(codeiumDir) == 0 then
      -- Directory does not exist, so create it
      vim.fn.mkdir(codeiumDir, 'p')
    end
    if (string.len(result) == 36) then
      -- Open the file in write mode
      local file = io.open(codeiumAuthFile, 'w')
      -- Check if the file was successfully opened
      if file then
        file:write('{"api_key": "' .. result .. '"}')
        file:close()
      end
    end
  end
end

function M.deleteFileIfExists(file_path)
  if vim.fn.filereadable(file_path) == 1 then
    os.remove(file_path)
  end
end
vim.cmd([[command! ClearSGAuth lua require('myLuaConf.birdee.plugins.AI').deleteFileIfExists(vim.fn.stdpath('data') .. '/cody.json')]])
vim.cmd([[command! ClearCodeiumAuth lua require('myLuaConf.birdee.plugins.AI').deleteFileIfExists(vim.fn.stdpath('cache') .. '/codeium/config.json')]])
return M
