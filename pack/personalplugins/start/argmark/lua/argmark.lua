local M = {}

---@return string
function M.get_display_text()
  local lid = vim.fn.arglistid()
  local res = lid == 0 and "" or "L"..lid..":"
  local arglist = vim.fn.argv(-1)
  ---@cast arglist string[] -- -1 as arg returns a list
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

---@param num_or_name_s? number|string|string[]
function M.add(num_or_name_s)
  local arglen = vim.fn.argc()
  local argtype = type(num_or_name_s)
  local to_add = {}
  if argtype == "number" and num_or_name_s > 0 and arglen >= num_or_name_s then
    to_add[1] = vim.fn.bufname(num_or_name_s)
    if to_add[1] == "" then to_add[1] = "%" end
  elseif argtype == "table" then
    to_add = num_or_name_s
  elseif argtype ~= "string" then
    to_add[1] = "%"
  end
  local ok, err = pcall(vim.cmd.argadd, {
    args = to_add,
    range = { arglen, arglen },
  })
  if not ok then
    vim.notify(err, vim.log.levels.WARN)
  end
  vim.cmd.argdedupe()
end

---@param num? number
function M.go(num)
  local arglen = vim.fn.argc()
  if num > 0 and arglen >= num then
    vim.cmd.argument(num)
  elseif arglen > 0 then
    vim.cmd.argument(vim.fn.argidx() + 1)
  else
    vim.notify("No args to go to!", vim.log.levels.WARN)
  end
end

---@param num_or_name? number|string|string[]
---@param num? number
function M.rm(num_or_name, num)
  local atype = type(num_or_name)
  local arglen = vim.fn.argc()
  if atype == "number" and num_or_name > 0 and arglen >= num_or_name then
    if type(num) == "number" and num > 0 and arglen >= num then
      pcall(vim.cmd.argdelete, { range = { num_or_name, num } })
    else
      pcall(vim.cmd.argdelete, { range = { num_or_name, num_or_name } })
    end
  elseif atype == "string" then
    pcall(vim.cmd.argdelete, num_or_name)
  elseif atype == "table" then
    pcall(vim.cmd.argdelete, { args = num_or_name })
  else
    local ok, err = pcall(vim.cmd.argdelete, "%")
    if not ok then
      vim.notify(err, vim.log.levels.WARN)
    end
  end
end

function M.add_windows()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    vim.cmd.argadd(vim.fn.bufname(vim.api.nvim_win_get_buf(win)))
  end
  vim.cmd.argdedupe()
end

---@param bufnr number
---@param winid? number
---@param tar_win_id? number
---@return number bufnr
---@return number winid
local function setup_window(bufnr, winid, tar_win_id)
  local abs_height, rel_width = 15, 0.7
  local rows, cols = vim.opt.lines._value, vim.opt.columns._value
  local lid = vim.fn.arglistid(tar_win_id)
  local filetype = "ArglistEditor"
  vim.api.nvim_buf_set_name(bufnr, "ArglistEditor")
  vim.api.nvim_set_option_value("filetype", filetype, { buf = bufnr })
  vim.api.nvim_set_option_value("buftype", "acwrite", { buf = bufnr })
  vim.api.nvim_set_option_value("bufhidden", "wipe", { buf = bufnr })
  vim.api.nvim_set_option_value("swapfile", false, { buf = bufnr })
  local winconfig = {
    relative = "editor",
    height = math.min(vim.fn.argc(lid == 0 and -1 or tar_win_id) + 2, abs_height),
    width = math.ceil(cols * rel_width),
    row = math.ceil(rows / 2 - abs_height / 2),
    col = math.ceil(cols / 2 - cols * rel_width / 2),
    border = "single",
    title = "ArglistEditor" .. (lid ~= 0 and " L:"..lid or ""),
    title_pos = "center",
  }
  if type(winid) == "number" and vim.api.nvim_win_is_valid(winid) then
    vim.api.nvim_win_set_config(winid, winconfig)
  else
    winid = vim.api.nvim_open_win(bufnr, true, winconfig)
  end
  vim.api.nvim_set_option_value("number", false, { win = winid })
  vim.api.nvim_set_option_value("relativenumber", false, { win = winid })
  -- argv(-1) is always a list
  ---@diagnostic disable-next-line: param-type-mismatch
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, vim.fn.argv(-1, tar_win_id))
  return bufnr, winid
end

function M.edit()
  local argseditor, winid = setup_window(vim.api.nvim_create_buf(false, true), nil, nil)

  vim.keymap.set("n", "<CR>", function()
    local f = vim.fn.getline(".")
    vim.api.nvim_win_close(winid, true)
    vim.cmd.edit(f)
  end, { buffer = argseditor, desc = "Go to file under cursor" })

  local function overwrite_argslist()
    local to_write = vim.api.nvim_buf_get_lines(argseditor, 0, -1, true) or {}
    for i = #to_write, 1, -1 do
      if to_write[i]:match("^%s*$") then
        table.remove(to_write, i)
      end
    end
    pcall(vim.cmd.argdelete, { range = { 1, vim.fn.argc() } })
    if #to_write > 0 then
      local ok, err = pcall(vim.cmd.argadd, { args = to_write })
      if not ok then vim.notify(err, vim.log.levels.ERROR) end
      vim.cmd.argdedupe()
    end
  end
  vim.api.nvim_create_autocmd("BufWriteCmd", {
    buffer = argseditor,
    callback = overwrite_argslist
  })
  vim.keymap.set("n", "q", function()
    overwrite_argslist()
    pcall(vim.api.nvim_win_close, winid, true)
  end, { buffer = argseditor, desc = "Update arglist and exit" })

  vim.api.nvim_create_autocmd({ "WinLeave", "BufWinLeave", "BufLeave" } ,{
    buffer = argseditor,
    callback = function()
      pcall(vim.api.nvim_win_close, winid, true)
    end
  })
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
    vim.keymap.set("n", keys.clear or "<leader><leader>X", function()
      M.rm(1, vim.fn.argc())
    end, { desc = "Clear arglist" })
  end
  if keys.add_windows ~= false then
    vim.keymap.set("n", keys.add_windows or "<leader><leader>A", M.add_windows, { desc = "Add current buffers for all windows to arglist" })
  end
end

return M
