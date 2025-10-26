```lua
vim.keymap.set("n", "<leader>lb", function() require("lsp_breadcrumbs")() end, { desc = "Toggle [l]sp [b]readcrumbs" })
vim.keymap.set("n", "<leader>lB", function() require("lsp_breadcrumbs")(false) end, { desc = "Clear [l]sp [B]readcrumbs" })
```
