require'lspconfig'.nil_ls.setup {
  capabilities = require("myLuaConf.caps-onattach").get_capabilities(),
  on_attach = require("myLuaConf.caps-onattach").on_attach,
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
