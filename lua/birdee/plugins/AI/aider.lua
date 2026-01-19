return {
  "nvim-aider",
  cmd = "Aider",
  -- Example key mappings for common actions:
  keys = {
    { "<leader>c/", "<cmd>Aider toggle<cr>", desc = "Toggle Aider" },
    { "<leader>cs", "<cmd>Aider send<cr>", desc = "Send to Aider", mode = { "n", "v" } },
    { "<leader>cm", "<cmd>Aider command<cr>", desc = "Aider Commands" },
    { "<leader>cb", "<cmd>Aider buffer<cr>", desc = "Send Buffer" },
    { "<leader>c+", "<cmd>Aider add<cr>", desc = "Add File" },
    { "<leader>c-", "<cmd>Aider drop<cr>", desc = "Drop File" },
    { "<leader>cr", "<cmd>Aider add readonly<cr>", desc = "Add Read-Only" },
    { "<leader>cR", "<cmd>Aider reset<cr>", desc = "Reset Session" },
    -- Example nvim-tree.lua integration if needed
    { "<leader>c+", "<cmd>AiderTreeAddFile<cr>", desc = "Add File from Tree to Aider", ft = "NvimTree" },
    { "<leader>c-", "<cmd>AiderTreeDropFile<cr>", desc = "Drop File from Tree from Aider", ft = "NvimTree" },
  },
  after = function()
    require("nvim_aider").setup({
      -- Command that executes Aider
      aider_cmd = "aider",
      -- Command line arguments passed to aider
      args = {
        "--no-auto-commits",
        "--pretty",
        "--stream",
      },
      -- Automatically reload buffers changed by Aider (requires vim.o.autoread = true)
      auto_reload = false,
      -- Theme colors (automatically uses Catppuccin flavor if available)
      theme = {
        user_input_color = "#a6da95",
        tool_output_color = "#8aadf4",
        tool_error_color = "#ed8796",
        tool_warning_color = "#eed49f",
        assistant_output_color = "#c6a0f6",
        completion_menu_color = "#cad3f5",
        completion_menu_bg_color = "#24273a",
        completion_menu_current_color = "#181926",
        completion_menu_current_bg_color = "#f4dbd6",
      },
      -- snacks.picker.layout.Config configuration
      picker_cfg = {
        preset = "vscode",
      },
      -- Other snacks.terminal.Opts options
      config = {
        os = { editPreset = "nvim-remote" },
        gui = { nerdFontsVersion = "3" },
      },
      win = {
        wo = { winbar = "Aider" },
        style = "nvim_aider",
        position = "right",
      },
    })
  end,
}
