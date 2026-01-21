local MP = ...
return {
  {
    "cmp-conjure",
    auto_enable = true,
    on_plugin = { "conjure" },
    load = nixInfo.lze.loaders.with_after,
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
