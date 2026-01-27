return {
  {
    "which-key.nvim",
    wk = "which-key.nvim",
    auto_enable = true,
    -- cmd = { "" },
    event = "DeferredUIEnter",
    -- ft = "",
    -- keys = "",
    -- colorscheme = "",
    after = function (_)
      require('which-key').setup({})
      local leaderCmsg
      if nixInfo.utils.get_nix_plugin_path "opencode-nvim" then
        leaderCmsg = "[c]olor [p]icker (and [c]lippy)"
      else
        leaderCmsg = "[c]olor [p]icker"
      end
      -- TODO: move more of these prefixes to wk spec values on the plugins
      require('which-key').add {
        { "<leader><leader>", group = "buffer commands" },
        { "<leader><leader>_", hidden = true },
        { "<leader>c", group = leaderCmsg },
        { "<leader>c_", hidden = true },
        { "<leader>t", group = "[T]oggle" },
        { "<leader>t_", hidden = true },
      }
    end,
  },
}
