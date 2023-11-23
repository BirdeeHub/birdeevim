require'lspconfig'.nil_ls.setup {
  capabilities = require(require('nixCats').RCName .. ".caps-onattach").get_capabilities(),
  on_attach = require(require('nixCats').RCName .. ".caps-onattach").on_attach,
  -- settings = {
  --   nix = {
  --     formatters = {
  --       ignoreComments = true,
  --     },
  --     signatureHelp = { enabled = true },
  --   },
  --   workspace = { checkThirdParty = true },
  --   telemetry = { enabled = false },
  -- },
}
require'lspconfig'.nixd.setup {
  capabilities = require(require('nixCats').RCName .. ".caps-onattach").get_capabilities(),
  on_attach = require(require('nixCats').RCName .. ".caps-onattach").on_attach,
  -- settings = {
  --   nix = {
  --     formatters = {
  --       ignoreComments = true,
  --     },
  --     signatureHelp = { enabled = true },
  --   },
  --   workspace = { checkThirdParty = true },
  --   telemetry = { enabled = false },
  -- },
}
