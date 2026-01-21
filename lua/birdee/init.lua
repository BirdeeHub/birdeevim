local MP = ...
do
  local ok
  ok, _G.nixInfo = pcall(require, vim.g.nix_info_plugin_name)
  if not ok then
    package.loaded[vim.g.nix_info_plugin_name] = setmetatable({}, {
      __call = function (_, default) return default end
    })
    _G.nixInfo = require(vim.g.nix_info_plugin_name)
    -- TODO: for non-nix compat, vim.pack.add in another file and require here.
  end
  nixInfo.isNix = vim.g.nix_info_plugin_name ~= nil
  nixInfo.utils = require(MP:relpath 'utils')
  nixInfo.icons = require(MP:relpath 'icons')
  local lzex = require('lzextras')
  ---@type lzextras | lze
  nixInfo.lze = setmetatable(require('lze'), getmetatable(lzex))
end

if nixInfo.utils.get_nix_plugin_path "fn_finder" then
  -- NOTE: <c-k>*l is λ
  require("fn_finder").fnl.install {
      search_opts = { nvim = true },
      -- hack: a unique value (will be hashed into bytecode cache for invalidation)
      [nixInfo(nil, "wrapper_drv")] = nixInfo(nil, "wrapper_drv"),
  }
end

-- vim.g.lze = {
--   load = vim.cmd.packadd,
--   verbose = true,
--   default_priority = 50,
--   without_default_handlers = false,
-- }
nixInfo.lze.register_handlers {
    nixInfo.lze.lsp,
    nixInfo.utils.auto_enable_handler,
    nixInfo.utils.for_cat_handler,
}
nixInfo.lze.h.lsp.set_ft_fallback(nixInfo.utils.lsp_ft_fallback)
nixInfo.lze.load {
    { import = MP:relpath "plugins" },
    { import = MP:relpath "LSPs" },
    { import = MP:relpath "debug" },
    { import = MP:relpath "format" },
    { import = MP:relpath "lint" },
}
