vim.lsp.set_log_level("debug")
-- require('fidget').setup()
require('neodev').setup()

require'lspconfig'.lua_ls.setup {
  capabilities = require("myLuaConf.cap-onattach").get_capabilities(),
  on_attach = require("myLuaConf.cap-onattach").on_attach,
  filetypes = { "lua" },
  cmd = { "lua-lsp" },
  settings = {
    Lua = {
      formatters = {
        ignoreComments = true,
      },
      signatureHelp = { enabled = true },
    },
    workspace = { checkThirdParty = true },
    telemetry = { enabled = false },
  },
}
-- require'lspconfig'.nil_ls.setup {
--   capabilities = require("birdee.lsp.birdeelspconfigs").get_capabilities(),
--   on_attach = require("birdee.lsp.birdeelspconfigs").on_attach,
--   filetypes = { "nix" },
--   settings = {
--     nix = {
--       formatters = {
--         ignoreComments = true,
--       },
--       signatureHelp = { enabled = true },
--     },
--     workspace = { checkThirdParty = true },
--     telemetry = { enabled = false },
--   },
-- }
local autocmd = vim.api.nvim_create_autocmd
autocmd("FileType", {
   pattern = "lua",
   callback = function()
      print("autocommand for lua ran")
      -- vim.highlight.priorities.semantic_tokens = 150
      -- vim.highlight.priorities.syntax = 100
   end
})
