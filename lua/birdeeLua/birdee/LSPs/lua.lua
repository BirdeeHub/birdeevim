require'lspconfig'.lua_ls.setup {
  capabilities = require(require('nixCats').RCName .. ".caps-onattach").get_capabilities(),
  on_attach = require(require('nixCats').RCName .. ".caps-onattach").on_attach,
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
