```lua
vim.keymap.set("n", "<leader>lb", require("lsp_breadcrumbs"), { desc = "Toggle [l]sp [b]readcrumbs" })
vim.keymap.set("n", "<leader>lb", function() require("lsp_breadcrumbs")() end, { desc = "Toggle [l]sp [b]readcrumbs" })
vim.keymap.set("n", "<leader>lBc", function() require("lsp_breadcrumbs")(false) end, { desc = "Clear lsp Breadcrumbs" })
vim.keymap.set("n", "<leader>lBe", function() require("lsp_breadcrumbs")(true) end, { desc = "Enable lsp Breadcrumbs" })
```
