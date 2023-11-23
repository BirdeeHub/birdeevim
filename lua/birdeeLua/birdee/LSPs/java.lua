local userHome = vim.fn.expand('$HOME')
require'lspconfig'.jdtls.setup {
  cmd = { "jdt-language-server", "-configuration", userHome .."/.cache/jdtls/config", "-data", userHome .."/.cache/jdtls/workspace" },
  capabilities = require(require('nixCats').RCName .. ".caps-onattach").get_capabilities(),
  on_attach = require(require('nixCats').RCName .. ".caps-onattach").on_attach,
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
