vim.lsp.set_log_level("debug")
-- require('fidget').setup()
require('neodev').setup({})
require'lspconfig'.lua_ls.setup {
  capabilities = require("myLuaConf.cap-onattach").get_capabilities(),
  on_attach = require("myLuaConf.cap-onattach").on_attach,
  filetypes = { "lua" },
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
require'lspconfig'.nil_ls.setup {
  capabilities = require("myLuaConf.cap-onattach").get_capabilities(),
  on_attach = require("myLuaConf.cap-onattach").on_attach,
  filetypes = { "nix" },
  settings = {
    nix = {
      formatters = {
        ignoreComments = true,
      },
      signatureHelp = { enabled = true },
    },
    workspace = { checkThirdParty = true },
    telemetry = { enabled = false },
  },
}
