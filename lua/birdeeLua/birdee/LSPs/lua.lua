require'lspconfig'.lua_ls.setup {
  capabilities = require("birdeeLua.caps-onattach").get_capabilities(),
  on_attach = require("birdeeLua.caps-onattach").on_attach,
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
