return {
  "conform.nvim",
  auto_enable = true,
  -- cmd = { "" },
  -- event = "",
  -- ft = "",
  keys = {
    { "<leader>FF", desc = "[F]ormat [F]ile" },
  },
  wk = {
    { "<leader>F", group = "[F]ormat" },
    { "<leader>F_", hidden = true },
  },
  -- colorscheme = "",
  after = function (_)
    local conform = require("conform")
    local ft_to_language = {
      sh = "bash",
      query = "tree_sitter_query",
    }
    conform.formatters.topiary = {
      command = "topiary",
      args = function(self, ctx)
        local ft = vim.bo[ctx.buf].filetype
        local language = self.options.languages[ft] or ft_to_language[ft] or ft
        if not language then
          return {}
        end

        return {
          "format",
          "--language",
          language,
        }
      end,
      stdin = true,
      options = {
        languages = {},
      },
    }

    conform.setup({
      formatters_by_ft = {
        lua = { "stylua" },
        nix = { "topiary" },
        bash = { "topiary" },
        go = { "gofmt", "golint" },
        templ = { "templ" },
        -- Conform will run multiple formatters sequentially
        python = { "isort", "black" },
        kotlin = { 'ktlint' },
        c = { "clang_format" },
        cpp = { "clang_format" },
        cmake = { "cmake_format" },
        elixir = { "mix" },
        fennel = { "fnlfmt" },
        -- Use a sub-list to run only the first available formatter
        javascript = { { "prettierd", "prettier" } },
      },
    })

    vim.keymap.set({ "n", "v" }, "<leader>FF", function()
      conform.format({
        lsp_fallback = true,
        async = false,
        timeout_ms = 1000,
      })
    end, { desc = "[F]ormat [F]ile" })


    -- vim.keymap.set("n", "<leader>Fm", "<cmd>Format<CR>", { noremap = true, desc = '[F]or[m]at (lsp)' })
  end,
}
