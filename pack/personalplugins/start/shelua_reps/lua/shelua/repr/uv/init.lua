---@param sh Shelua
return function(sh)
  ---@type Shelua.Opts
  local sh_settings = getmetatable(sh)
  local sherun = require('shelua.system').run
  ---@type Shelua.Repr
  sh_settings.repr.uv = {
    escape = function(s) return s end,
    arg_tbl = function(opts, k, a)
      k = (#k > 1 and '--' or '-') .. k
      if type(a) == 'boolean' and a then return k end
      if type(a) == 'string' then return { k, tostring(a) } end
      if type(a) == 'number' then return { k, tostring(a) } end
      return nil
    end,
    add_args = function(opts, cmd, args)
      return setmetatable({ cmd, unpack(args) }, {
        __tostring = function(self) return table.concat(self, " ") end,
      })
    end,
    extra_cmd_results = { "__env", "__stderr", "__cwd" },
  }
  local SPECIAL = require('shelua.repr.uv.specials')
  -- allow AND, OR, CD, __cwd, and __env. Allows function type __input, escape_args == false doesnt work
  function sh_settings.repr.uv.concat_cmd(opts, cmd, input)
    local special
    for k, def in pairs(SPECIAL) do
      if cmd[1] == k then
        special = def
      end
    end
    if special then
      return special.resolve(opts, cmd, input), special
    elseif #input == 1 then
      local v = input[1] or {}
      return function()
        local mkopts, towrite
        if v.m then
          mkopts, towrite = v.m.recieve(opts, v.c)
        elseif v.c then
          local cstate = v.c()._state
          towrite = cstate.stdout
          mkopts = function(prev)
            prev.cwd = cstate.cwd or prev.cwd
            return prev
          end
        else
          mkopts = function(prev)
            prev.cwd = (v.e or {}).__cwd or prev.cwd
            prev.env = (v.e or {}).__env
            return prev
          end
          towrite = v.s
        end
        local runargs = {
          stdin = true,
          text = true,
          cwd = opts.cwd or nil,
        }
        if not towrite then
          runargs.stdin = false
        end
        runargs = mkopts and mkopts(runargs) or runargs
        local result = sherun(cmd, runargs)
        if towrite then
          result:write_many({ towrite })
        end
        return result
      end
    elseif #input > 1 then
      return function ()
        local env = {}
        local cwd
        for _, v in ipairs(input) do
          cwd = (v.e or {}).__cwd or cwd
          for k, val in pairs((v.e or {}).__env or {}) do
            env[k] = val
          end
        end
        local runargs = {
          stdin = true,
          env = env,
          cwd = cwd or opts.cwd or nil,
          text = true,
        }
        local towrite = {}
        for _, v in ipairs(input) do
          if v.m then
            local mkopts, w = v.m.recieve(opts, v.c)
            if mkopts then
              runargs = mkopts(runargs)
            end
            if w then
              table.insert(towrite, w)
            end
          elseif v.c then
            local cstate = v.c()._state
            table.insert(towrite, cstate.stdout)
            runargs.cwd = cstate.cwd or runargs.cwd
          else
            table.insert(towrite, v.s)
          end
        end
        local result = sherun(cmd, runargs)
        result:write_many(towrite)
        return result
      end
    else
      return function()
        return sherun(cmd, { cwd = opts.cwd or nil, text = true })
      end
    end
  end
  -- allow AND, OR, CD, __cwd, and __env. Allows function type __input, escape_args == false doesnt work
  function sh_settings.repr.uv.single_stdin(opts, cmd, inputs, codes)
    local special
    for k, def in pairs(SPECIAL) do
      if cmd[1] == k then
        special = def
        break
      end
    end
    if special then
      return special.single(opts, cmd, inputs, codes)
    else
      local env = {}
      local cwd
      local towrite = {}
      for i, res in ipairs(codes or {}) do
        local newin = inputs[i]
        if newin then
          table.insert(towrite, newin)
        end
        if res.__env then
          for k, v in pairs(res.__env or {}) do
            env[k] = v
          end
        end
        if res.__cwd then cwd = res.__cwd end
      end
      return cmd, { env = env, towrite = towrite, cwd = cwd }
    end
  end

  local function run_command(opts, cmd, msg)
    local result
    if opts.proper_pipes then
      result = cmd():wait()
    elseif type(cmd) == "function" then
      result = cmd()
      result.__exitcode = result.__exitcode or 0
      result.__signal = result.__signal or 0
      result.__cwd = result.__cwd or opts.cwd or nil
      return result
    else
      result = sherun(cmd, {
        env = msg.env or nil,
        cwd = msg.cwd or opts.cwd or nil,
        stdin = msg.towrite and true or false,
        text = true,
      })
      if msg.towrite then
        result:write_many(msg.towrite)
      end
      result = result:wait()
    end
    return {
      __input = result.stdout,
      __stderr = result.stderr,
      __exitcode = result.code,
      __signal = result.signal,
      __cwd = result.cwd,
    }
  end
  sh_settings.repr.uv.run_cmd = run_command
  return sh
end
