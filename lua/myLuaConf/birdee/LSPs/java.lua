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
