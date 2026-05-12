---@param sh Shelua
return function(sh)
    ---@type Shelua.Opts
    local sh_settings = getmetatable(sh)
    local escapeShellArg = sh_settings.repr.posix.escape
    local sherun = require('shelua.system').run

    ---@param t table
    ---@param default any
    ---@vararg any
    ---@return any
    local function tbl_get(t, default, ...)
        if #{ ... } == 0 then return default end
        for _, key in ipairs({ ... }) do
            if type(t) ~= "table" then return default end
            t = t[key]
        end
        return t or default
    end

    ---@param opts Shelua.Opts
    ---@param attr string
    ---@return function
    local get_repr_fn = function(opts, attr)
        return tbl_get(opts, tbl_get(opts, function()
            error("Shelua Repr Error: " ..
                tostring(attr) .. " function required for shell: " .. tostring(opts.shell or "posix"))
        end, "repr", "posix", attr), "repr", opts.shell or "posix", attr)
    end

    ---@type Shelua.Repr
    sh_settings.repr.posix_plus = {
        escape = escapeShellArg,
        arg_tbl = function(opts, k, a)
            k = (#k > 1 and '--' or '-') .. k
            if type(a) == 'boolean' and a then return k end
            if type(a) == 'string' then return { k, escapeShellArg(a) } end
            if type(a) == 'number' then return { k, tostring(a) } end
            return nil
        end,
        add_args = function(opts, cmd, args)
            return cmd .. " " .. table.concat(args, ' ')
        end,
        extra_cmd_results = { "__env", "__stderr", "__cwd" },
    }
    -- TODO: allow AND, OR, CD, __cwd, and __env.
    function sh_settings.repr.posix_plus.concat_cmd(opts, cmd, input)
        local function normalize_shell_expr(v, cmd_mod)
            if v.c then return v.c end
            if v.s and cmd_mod and (v.e.__exitcode or 0) ~= 0 then
                return "{ printf '%s' " .. get_repr_fn(opts, "escape")(v.e.__stderr or v.s, opts) .. " 1>&2; false; }"
            end
            return "printf '%s' " .. get_repr_fn(opts, "escape")(v.s, opts)
        end
        if cmd:sub(1, 3) == "AND" then
            local initial = normalize_shell_expr(input[1], "AND")
            local res = {}
            for i = 2, #input do
                table.insert(res, normalize_shell_expr(input[i]))
            end
            if #res == 0 then error("AND requires at least 2 commands") end
            if #res == 1 then return initial .. " && " .. res[1] end
            return initial .. " && { " .. table.concat(res, " ; ") .. " ; }"
        elseif cmd:sub(1, 2) == "OR" then
            local initial = normalize_shell_expr(input[1], "OR")
            local res = {}
            for i = 2, #input do
                table.insert(res, normalize_shell_expr(input[i]))
            end
            if #res == 0 then error("OR requires at least 2 commands") end
            if #res == 1 then return initial .. " || " .. res[1] end
            return initial .. " || { " .. table.concat(res, " ; ") .. " ; }"
        elseif #input == 1 then
            return normalize_shell_expr(input[1]) .. " | " .. cmd
        elseif #input > 1 then
            for i, v in ipairs(input) do
                input[i] = normalize_shell_expr(v)
            end
            return "{ " .. table.concat(input, " ; ") .. " ; } | " .. cmd
        else
            return cmd
        end
    end

    -- TODO: allow AND, OR, CD, __cwd, and __env.
    function sh_settings.repr.posix_plus.single_stdin(opts, cmd, inputs, codes)
        local tmp
        if inputs then
            tmp = os.tmpname()
            local f = io.open(tmp, 'w')
            if f then
                f:write(table.concat(inputs))
                f:close()
                cmd = cmd .. ' <' .. tmp
            end
        end
        return cmd, { tmp = tmp }
    end

    local function run_command(opts, cmd, msg)
        local result = sherun({ "bash" }, { stdin = cmd, text = true }):wait()
        pcall(os.remove, (msg or {}).tmp)
        return {
            __input = result.stdout,
            __stderr = result.stderr,
            __exitcode = result.code,
            __signal = result.signal,
        }
    end
    sh_settings.repr.posix_plus.run_cmd = run_command
    return sh
end
