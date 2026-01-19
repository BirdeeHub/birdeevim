local load_w_after = require("lzextras").loaders.with_after
local MP = ...
return {
  {
    "cmp-conjure",
    auto_enable = true,
    on_plugin = { "conjure" },
    load = load_w_after,
  },
  {
    "conjure",
    auto_enable = true,
    ft = { "clojure", "fennel", "python" },
    before = function ()
      package.preload["conjure.client.fennel.nvim"] = function() return require(MP:relpath 'nvim_client') end
      vim.g["conjure#filetype#fennel"] = "conjure.client.fennel.nvim"
    end,
  },
}
