local M = {}

function M.lualine_component()
  local res = ""
  local current = vim.api.nvim_buf_get_name(0)
  local arglist = vim.fn.argv()
  arglist = type(arglist) == "table" and arglist or { arglist }
  ---@cast arglist string[]
  for i = 1, #arglist do
    local this_path = arglist[i]
    if vim.fn.fnamemodify(this_path, ":p") == current then
      res = res .. " [" .. vim.fn.fnamemodify(this_path, ":t") .. "]"
    else
      res = res .. " " .. vim.fn.fnamemodify(this_path, ":t")
    end
  end
  return res
end

function M.add(num_or_name)
  local arglen = vim.fn.argc()
  vim.cmd.argadd {
    args = { type(num_or_name) == "string" and num_or_name or vim.fn.bufname(num_or_name or 0) },
    range = { arglen, arglen },
  }
  vim.cmd.argdedupe()
end

function M.go(num)
  if num > 0 and vim.fn.argc() >= num then
    vim.cmd.argu(num)
  end
end

function M.rm(num_or_name)
  local atype = type(num_or_name)
  if atype == "number" and num_or_name > 0 and vim.fn.argc() >= num_or_name then
    vim.cmd.argdel { range = { num_or_name, num_or_name } }
  elseif atype == "string" then
    vim.cmd.argdelete(num_or_name)
  else
    vim.cmd.argdel("%")
  end
end

function M.setup(opts)
  local keys = (opts or {}).keys or {}
  if keys.rm then
    vim.keymap.set("n", keys.rm or "<leader><leader>x", function()
      M.rm(vim.v.count)
    end, { silent = true, desc = "Remove buffer at count (or current) from arglist"})
  end
  if keys.add then
    vim.keymap.set("n", keys.add or "<leader><leader>a", function()
      M.add(vim.v.count)
    end, { silent = true, desc = "Add buffer (count or current) to arglist" })
  end
  if keys.go then
    vim.keymap.set("n", keys.go or "<leader><leader><leader>", function()
      M.go(vim.v.count)
    end, { silent = true, desc = "Go to buffer at count in arglist" })
  end
end

return M
