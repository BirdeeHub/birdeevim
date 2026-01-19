-- TODO: this in another file and require here.
-- require('birdee.non_nix_download').setup({ your plugins })

-- vim.g.lze = {
--   load = vim.cmd.packadd,
--   verbose = true,
--   default_priority = 50,
--   without_default_handlers = false,
-- }
local MP = ...
nixInfo.utils = require(MP:relpath 'utils')
require('lze').register_handlers {
    require('lzextras').lsp,
    nixInfo.utils.auto_enable_handler,
}
require('lze').h.lsp.set_ft_fallback(nixInfo.utils.lsp_ft_fallback)
require('lze').load {
    { import = MP:relpath "plugins" },
    { import = MP:relpath "LSPs" },
    { import = MP:relpath "debug" },
    { import = MP:relpath "format" },
    { import = MP:relpath "lint" },
}
