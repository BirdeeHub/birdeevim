require'lspconfig'.kotlin_language_server.setup {
  capabilities = require("birdeeLua.caps-onattach").get_capabilities(),
  on_attach = require("birdeeLua.caps-onattach").on_attach,
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




--local autocmd = vim.api.nvim_create_autocmd
--autocmd("FileType", {
--    pattern = "kotlin",
--    callback = function()
--        local root_dir = vim.fs.dirname(
--            vim.fs.find({ 'mvnw', 'gradlew', '.git' }, { upward = true })[1]
--        )
--        local client = vim.lsp.start({
--            name = 'kotlin-language-server',
--            cmd = { 'kotlin-language-server' },
--            root_dir = root_dir,
--        })
--        if(client ~= nil)
--        then
--          vim.lsp.buf_attach_client(0, client)
--        end
--    end
--})
