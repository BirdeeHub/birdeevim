return {
  "codecompanion.nvim",
  auto_enable = true,
  cmd = {
    "CodeCompanion",
    "CodeCompanionCmd",
    "CodeCompanionChat",
    "CodeCompanionAction",
  },
  keys = {
    { "<leader>cc", ":CodeCompanionChat<CR>", mode = { "n", "v", "x" }, desc = "[C]lippy[C]hat" },
    { "<leader>cv", ":CodeCompanionCmd", mode = { "n", "v", "x" }, desc = "[C]lippy[V]imcmd" },
    { "<leader>cd", ":CodeCompanionAction<CR>", mode = { "n", "v", "x" }, desc = "[C]lippy[D]o" },
  },
  after = function()
    require("codecompanion").setup({
      strategies = {
        chat = {
          adapter = "ollama",
        },
        inline = {
          adapter = "qwen7",
        },
        cmd = {
          adapter = "ollama",
        }
      },
      adapters = {
        qwen7 = function()
          return require("codecompanion.adapters").extend("ollama", {
            name = "qwen7", -- Give this adapter a different name to differentiate it from the default ollama adapter
            schema = {
              model = {
                default = "qwen2.5-coder:7b",
              },
              num_ctx = {
                default = 16384,
              },
              num_predict = {
                default = -1,
              },
            },
          })
        end,
        llama3 = function()
          return require("codecompanion.adapters").extend("ollama", {
            name = "llama3", -- Give this adapter a different name to differentiate it from the default ollama adapter
            schema = {
              model = {
                default = "llama3.1:latest",
              },
              num_ctx = {
                default = 16384,
              },
              num_predict = {
                default = -1,
              },
            },
          })
        end,
      },
    })
  end,
}
