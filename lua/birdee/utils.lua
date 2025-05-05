local M = {}
require('shelua')
function os.write_file(opts, filename, content)
  local file = io.open(filename, opts.append and "a" or "w")
  if not file then return nil end
  file:write(content .. (opts.newline ~= false and "\n" or ""))
  file:close()
  return filename
end
function os.read_file(filename)
  local file = io.open(filename, "r")
  if not file then return nil end
  local content = file:read("*a")
  file:close()
  return content
end
function M.split_string(str, delimiter)
  local result = {}
  for match in (str .. delimiter):gmatch("(.-)" .. delimiter) do
    table.insert(result, match)
  end
  return result
end

local sh = sh { proper_pipes = false, escape_args = false, assert_zero = false, transforms = {}, shell = "nvim" }
function M.authTerminal()
  local function full_logon()
    local email = vim.fn.inputsecret('Enter email: ')
    local pass = vim.fn.inputsecret('Enter password: ')
    local done = false
    local ret = sh.bw("login", "--raw", "--quiet", "--passwordenv", "BWPASS", email, {
      __env = { BWPASS = pass, },
      __input = function()
        if not done then
          done = true
          return vim.fn.inputsecret('New device login code: ')
        else
          return nil
        end
      end
    })
    return pass, ret.__exitcode == 0
  end
  local function unlock(password)
    local ret = sh.bw("unlock", "--raw", "--nointeraction", "--passwordenv", "BWPASS", {
      __input = function() end,
      __env = { BWPASS = password or vim.fn.inputsecret('Enter password: ') },
    })
    return tostring(ret), ret.__exitcode == 0
  end
  local session = os.getenv('BW_SESSION')
  if session then
    return session, true
  else
    if tostring(sh.bw("login", "--check")) == "You are logged in!" then
      return unlock()
    else
      local pass, ok = full_logon()
      if ok and pass then
        return unlock(pass)
      end
    end
    return session, false
  end
end

---@class birdee.authentry
---@field enable boolean
---@field cache boolean
---@field bw_id string[]
---@field localpath string
---@field action fun(key)

---@param entries table<string, birdee.authentry>
function M.get_auths(entries)
  local to_fetch = {}
  local cached = {}
  for name, entry in pairs(entries) do
    if entry.enable ~= false and entry.bw_id and entry.localpath and vim.fn.filereadable(entry.localpath) == 0 then
      to_fetch[name] = entry
    elseif entry.enable ~= false and entry.localpath and vim.fn.filereadable(entry.localpath) ~= 0 then
      cached[name] = entry
    end
  end
  local final = {}
  if next(to_fetch) ~= nil then
    local session, ok = M.authTerminal()
    if session and ok then
      for name, entry in pairs(to_fetch) do
        local ret = sh.bw("get", "--nointeraction", "--session", session, unpack(entry.bw_id))
        local key = ret.__exitcode == 0 and tostring(ret) or nil
        if entry.cache and key then
          local handle = io.open(entry.localpath, "w")
          if handle then
            handle:write(key)
            handle:close()
            vim.loop.fs_chmod(entry.localpath, 384, function(err, success)
              if err then
                print("Failed to set file permissions: " .. err)
              end
            end)
          end
        end
        final[name] = key
      end
    end
  end
  for name, entry in pairs(cached) do
    local handle = io.open(entry.localpath, "r")
    local key
    if handle then
      key = handle:read("*l")
      handle:close()
    end
    final[name] = handle and key or nil
  end
  for name, key in pairs(final) do
    if entries[name].action then
      entries[name].action(key)
    end
  end
end

---@type fun(moduleName: string): any
function M.lazy_require_funcs(moduleName)
  return setmetatable({}, {
    __call = function (_, ...)
        return require(moduleName)(...)
    end,
    __index = function(_, key)
      return function(...)
        local module = require(moduleName)
        return module[key](...)
      end
    end,
  })
end

function M.nix_table()
  local allow_createfn = true
  local createfn
  createfn = function(key)
      return allow_createfn and vim.defaulttable(createfn) or nil
  end
  return setmetatable({}, {
    __index = function(tbl, key)
      if allow_createfn and key == "resolve" then
        return function()
          allow_createfn = false
          return tbl
        end
      end
      rawset(tbl, key, createfn(key))
      return rawget(tbl, key)
    end,
  })
end

function M.lsp_ft_fallback(name)
  local nvimlspcfg = nixCats.pawsible({ "allPlugins", "opt", "nvim-lspconfig" }) or nixCats.pawsible({ "allPlugins", "start", "nvim-lspconfig" })
  if not nvimlspcfg then
    local matches = vim.api.nvim_get_runtime_file("pack/*/*/nvim-lspconfig", false)
    nvimlspcfg = assert(matches[1], "nvim-lspconfig not found!")
  end
  vim.api.nvim_create_user_command("LspGetFiletypesToClipboard",function(opts)
    local lspname = assert(opts.fargs[1] or vim.fn.getreg("+") or name, "no name to search for provided or in clipboard")
    local ok, lspcfg = pcall(dofile, nvimlspcfg .. "/lsp/" .. lspname .. ".lua")
    if not ok or not lspcfg then error("failed to get config for lsp: " .. lspname) end
    vim.fn.setreg("+",
      "filetypes = "
      .. vim.inspect(lspcfg.filetypes or {})
      .. ","
    )
  end, { nargs = '?' })
  vim.schedule(function() vim.notify((name or "lsp") .. " not provided filetype", vim.log.levels.WARN) end)
  return name and dofile(nvimlspcfg .. "/lsp/" .. name .. ".lua").filetypes or {}
end

function M.insert_many(dst, ...)
  for i = 1, select('#', ...) do
    local val = select(i, ...)
    if val ~= nil then
      table.insert(dst, val)
    end
  end
  return dst
end

function M.extend_many(dst, ...)
  for i = 1, select('#', ...) do
    local val = select(i, ...)
    if type(val) == 'table' then
      vim.list_extend(dst, val)
    end
  end
  return dst
end

return M
