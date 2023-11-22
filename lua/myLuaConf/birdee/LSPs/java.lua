local username = vim.fn.expand('$USER')
require'lspconfig'.jdtls.setup {
  cmd = { "jdt-language-server", "-configuration", "/home/".. username .."/.cache/jdtls/config", "-data", "/home/".. username .."/.cache/jdtls/workspace" },
  capabilities = require("myLuaConf.caps-onattach").get_capabilities(),
  on_attach = require("myLuaConf.caps-onattach").on_attach,
  filetypes = { "kotlin", "java" },
  settings = {
    java = {
      formatters = {
        ignoreComments = true,
      },
      signatureHelp = { enabled = true },
    },
    workspace = { checkThirdParty = true },
    telemetry = { enabled = false },
  },
}
