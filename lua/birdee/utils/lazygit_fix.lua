return function (path, line)
  local prev = vim.fn.bufnr("#")
  vim.api.nvim_feedkeys("q", "n", false)
  if line then
    vim.api.nvim_buf_call(prev, function()
      vim.cmd.edit(path)
      local buf = vim.api.nvim_get_current_buf()
      vim.schedule(function()
        if buf then
          vim.cmd.buffer(buf)
          vim.api.nvim_win_set_cursor(0, { line or 0, 0})
        end
      end)
    end)
  else
    vim.api.nvim_buf_call(prev, function()
      vim.cmd.edit(path)
      local buf = vim.api.nvim_get_current_buf()
      vim.schedule(function()
        if buf then
          vim.cmd.buffer(buf)
        end
      end)
    end)
  end
end
