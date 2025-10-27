local M = {}

function M.get_display_text()
  local res = ""
  local arglist = vim.fn.argv(-1)
  arglist = type(arglist) == "table" and arglist or { arglist }
  ---@cast arglist string[]
  for i = 1, #arglist do
    local name = vim.fn.fnamemodify(arglist[i], ":t")
    if name == "" then
      name = vim.fn.fnamemodify(name .. ".", ":h:t")
    end
    if name == "" then name = "~No~Name~" end
    if i == vim.fn.argidx() + 1 then
      res = res .. " [" .. name .. "]"
    else
      res = res .. " " .. name
    end
  end
  return res
end

function M.add(num_or_name)
  local arglen = vim.fn.argc(-1)
  local argtype = type(num_or_name)
  if argtype == "number" then
    num_or_name = num_or_name < 1 and "%" or vim.fn.bufname(num_or_name)
  elseif argtype ~= "string" then
    num_or_name = "%"
  end
  local ok, err = pcall(vim.cmd.argadd, {
    args = { num_or_name },
    range = { arglen, arglen },
  })
  if not ok then
    vim.notify(err, vim.log.levels.WARN)
  end
  vim.cmd.argdedupe()
end

function M.go(num)
  local arglen = vim.fn.argc(-1)
  if num > 0 and arglen >= num then
    vim.cmd.argument(num)
  elseif arglen > 0 then
    vim.cmd.argument(vim.fn.argidx() + 1)
  else
    vim.notify("No args to go to!", vim.log.levels.WARN)
  end
end

function M.rm(num_or_name)
  local atype = type(num_or_name)
  if atype == "number" and num_or_name > 0 and vim.fn.argc(-1) >= num_or_name then
    vim.cmd.argdelete { range = { num_or_name, num_or_name } }
  elseif atype == "string" then
    vim.cmd.argdelete(num_or_name)
  else
    local ok, err = pcall(vim.cmd.argdelete, "%")
    if not ok then
      vim.notify(err, vim.log.levels.WARN)
    end
  end
end

function M.edit()
  -- Set dimensions
  local abs_height = 15
  local rel_width = 0.7

  -- Create buf
  local argseditor = vim.api.nvim_create_buf(false, true)
  local filetype = "argseditor"
  vim.api.nvim_set_option_value("filetype", filetype, { buf = argseditor })
  vim.api.nvim_set_option_value("buftype", "acwrite", { buf = argseditor })
  vim.api.nvim_set_option_value("bufhidden", "wipe", { buf = argseditor })
  vim.api.nvim_set_option_value("swapfile", false, { buf = argseditor })

  -- Create centered floating window
  local rows, cols = vim.opt.lines._value, vim.opt.columns._value
  local winid = vim.api.nvim_open_win(argseditor, true, {
    relative = "editor",
    height = math.min(vim.fn.argc(-1) + 2, abs_height),
    width = math.ceil(cols * rel_width),
    row = math.ceil(rows / 2 - abs_height / 2),
    col = math.ceil(cols / 2 - cols * rel_width / 2),
    border = "single",
    title = filetype,
  })

  -- Put current arglist
  local arglist = vim.fn.argv(-1)
  local to_read = type(arglist) == "table" and arglist or { arglist }
  vim.api.nvim_buf_set_lines(argseditor, 0, -1, false, to_read)

  -- Go to file under cursor
  vim.keymap.set("n", "<CR>", function()
    local f = vim.fn.getline(".")
    vim.api.nvim_win_close(winid, true)
    vim.cmd.edit(f)
  end, { buffer = argseditor, desc = "Go to file under cursor" })

  -- Write new arglist and close argseditor
  vim.keymap.set("n", "q", function()
    local to_write = vim.api.nvim_buf_get_lines(argseditor, 0, -1, true) or {}
    pcall(vim.cmd.argdelete, { range = { 1, vim.fn.argc(-1) } })
    local ok, err = pcall(vim.cmd.argadd, table.concat(to_write, " "))
    if not ok then
      vim.notify(err, vim.log.levels.ERROR)
    end
    vim.cmd.argdedupe()
    vim.api.nvim_win_close(winid, true)
  end, { buffer = argseditor, desc = "Update arglist and exit" })

  vim.api.nvim_create_autocmd("BufWriteCmd", {
    buffer = argseditor,
    callback = function()
      local to_write = vim.api.nvim_buf_get_lines(argseditor, 0, -1, true) or {}
      pcall(vim.cmd.argdelete, { range = { 1, vim.fn.argc(-1) } })
      local ok, err = pcall(vim.cmd.argadd, table.concat(to_write, " "))
      if not ok then
        vim.notify(err, vim.log.levels.ERROR)
      end
      vim.cmd.argdedupe()
    end
  })

  vim.api.nvim_create_autocmd({ "WinLeave", "BufWinLeave", "BufLeave" } ,{
    buffer = argseditor,
    callback = function()
      pcall(vim.api.nvim_win_close, winid, true)
    end
  })
end

function M.clear()
  pcall(vim.cmd.argdelete, { range = { 1, vim.fn.argc(-1) } })
end

function M.add_windows()
  for _, wins in ipairs(vim.api.nvim_list_wins()) do
    vim.cmd.argadd(vim.fn.bufname(vim.api.nvim_win_get_buf(wins)))
  end
  vim.cmd.argdedupe()
end

function M.setup(opts)
  local keys = (opts or {}).keys or {}
  if keys.rm ~= false then
    vim.keymap.set("n", keys.rm or "<leader><leader>x", function()
      M.rm(vim.v.count)
    end, { silent = true, desc = "Remove buffer at count (or current) from arglist"})
  end
  if keys.add ~= false then
    vim.keymap.set("n", keys.add or "<leader><leader>a", function()
      M.add(vim.v.count)
    end, { silent = true, desc = "Add buffer (count or current) to arglist" })
  end
  if keys.go ~= false then
    vim.keymap.set("n", keys.go or "<leader><leader><leader>", function()
      M.go(vim.v.count)
    end, { silent = true, desc = "Go to buffer at count in arglist" })
  end
  if keys.edit ~= false then
    vim.keymap.set("n", keys.edit or "<leader><leader>e", M.edit, { silent = true, desc = "edit arglist in floating window"})
  end
  if keys.clear ~= false then
    vim.keymap.set("n", keys.clear or "<leader><leader>X", M.clear, { desc = "Clear arglist" })
  end
  if keys.add_windows ~= false then
    vim.keymap.set("n", keys.add_windows or "<leader><leader>A", M.add_windows, { desc = "Add currently visible buffers to arglist" })
  end
end

return M
