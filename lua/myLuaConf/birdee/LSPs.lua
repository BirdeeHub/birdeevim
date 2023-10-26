vim.lsp.set_log_level("debug")
-- require('fidget').setup()
require('neodev').setup({

})
-- require('neodev').setup({ lspconfig = false, })
-- require("neodev").setup({
--   override = function(root_dir, library)
--     if root_dir:find("/home/birdee/Downloads/birdeevim", 1, true) == 1 then
--       library.enabled = true
--       library.plugins = true
--     end
--   end,
-- })
-- vim.lsp.start({
--   name = "lua_ls",
--   cmd = { "lua-lsp" },
--   before_init = require("neodev.lsp").before_init,
--   root_dir = vim.fn.getcwd(),
--   settings = { Lua = {} },
-- })

require'lspconfig'.lua_ls.setup {
  capabilities = require("myLuaConf.cap-onattach").get_capabilities(),
  on_attach = require("myLuaConf.cap-onattach").on_attach,
  filetypes = { "lua" },
  -- before_init = require("neodev.lsp").before_init,
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
