return {
  "conform.nvim",
  auto_enable = true,
  cmd = { "TopiaryFormat" },
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

    local with_topiary = nixInfo(false, "settings", "cats", "topiary")
    conform.setup({
      formatters_by_ft = {
        lua = { "stylua" },
        nix = { "nixfmt" },
        bash = with_topiary and { "topiary" } or nil,
        query = with_topiary and { "topiary" } or nil,
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

    vim.api.nvim_create_user_command("TopiaryFormat", function(args)
      local range = nil
      if args.count ~= -1 then
        local end_line = vim.api.nvim_buf_get_lines(0, args.line2 - 1, args.line2, true)[1]
        range = {
          start = { args.line1, 0 },
          ["end"] = { args.line2, end_line:len() },
        }
      end
      require("conform").format({
        formatters = { "topiary" }, -- Replace with your formatter
        async = true,
        timeout_ms = 1000,
        range = range,
      })
    end, {
      range = true,
      desc = "Format buffer or selection with Topiary",
    })

    -- vim.keymap.set("n", "<leader>Fm", "<cmd>Format<CR>", { noremap = true, desc = '[F]or[m]at (lsp)' })
  end,
}
