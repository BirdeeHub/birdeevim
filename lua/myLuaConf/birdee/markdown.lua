local M = {}
function M.setup(categories)
  -- vim.g.mkdp_auto_close = 0
  vim.keymap.set('n','<leader>mp','<cmd>MarkdownPreviewToggle <CR>',{ noremap = true, desc = 'markdown preview toggle' })



  -- well I guess now that I have that I dont need the other stuff but
  -- Im going to keep it here for notes purposes


  -- if(categories.ghmarkdown) then
  --   vim.keymap.set('n', '<leader>mp', [[:execute 'silent !gh-markdown-preview ' . expand('%:p') . ' &> /dev/null &' <CR> ]], { noremap = true, desc = "gh-markdown-preview" })
  --
  --   -- TODO:
  --     -- Make this close just the current buffer's markdown preview
  --     -- The plan for that? do same thing as quit, except with expand('%:p') in it somehow
  --   -- vim.keymap.set('n', "<leader>mc", [[:execute 'silent !gh-markdown-preview ' . expand('%:p') . ' &> /dev/null &' <CR> ]], { noremap = true, desc = "gh-markdown-preview close current buffer" })
  --
  --   vim.keymap.set('n', '<leader>mq', [[<cmd>silent ! for pid in $(ps aux | grep gh-markdown-preview | awk '{print $2}'); do kill $pid; done <CR>]], { noremap = true, desc = "gh-markdown-preview quit" })
  --
  --   local autocmd = vim.api.nvim_create_autocmd
  --   autocmd("VimLeavePre", {
  --      pattern = "*",
  --      callback = function()
  --        vim.cmd([[
  --          silent ! for pid in $(ps aux | grep gh-markdown-preview | awk '{print $2}'); do kill $pid; done
  --        ]])
  --      end
  --   })
  -- end
  -- if(categories.markdown) then
  --   vim.g.markdown_composer_autostart = 0
  --   vim.keymap.set('n', "<leader>ms", [[<cmd>:ComposerStart <CR>]], { noremap = true, desc = 'composer start' })
  --   vim.keymap.set('n', "<leader>mu", [[<cmd>:ComposerUpdate <CR>]], { noremap = true, desc = 'composer update' })
  --   vim.keymap.set('n', "<leader>mo", [[<cmd>:ComposerOpen <CR>]], { noremap = true, desc = 'composer open' })
  --   vim.keymap.set('n', "<leader>mj", [[<cmd>:ComposerJob <CR>]], { noremap = true, desc = 'composer job channel' })
  -- end
end
return M
