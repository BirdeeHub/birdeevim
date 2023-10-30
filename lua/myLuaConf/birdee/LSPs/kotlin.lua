require'lspconfig'.jdtls.setup {
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
require'lspconfig'.kotlin_language_server.setup {
  capabilities = require("myLuaConf.caps-onattach").get_capabilities(),
  on_attach = require("myLuaConf.caps-onattach").on_attach,
  filetypes = { "kotlin" },
  settings = {
    kotlin = {
      formatters = {
        ignoreComments = true,
      },
      signatureHelp = { enabled = true },
    },
    workspace = { checkThirdParty = false },
    telemetry = { enabled = false },
  }
}
