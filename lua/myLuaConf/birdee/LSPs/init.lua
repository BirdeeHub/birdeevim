local M = {}
function M.setup(serverlist)
  vim.lsp.set_log_level("debug")
  -- require('fidget').setup()
  require("myLuaConf.birdee.LSPs.neonixdev")
end
return M
