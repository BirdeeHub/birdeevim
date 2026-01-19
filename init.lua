string.relpath = function(str, sub, n)
    local result = {}
    n = type(sub) == "string" and n or sub
    if type(n) == "number" and n > 0 then
        for match in (str .. "."):gmatch("(.-)%.") do
            table.insert(result, match)
        end
        while n > 0 do
            table.remove(result)
            n = n - 1
        end
    else
        table.insert(result, str)
    end
    if type(sub) == "string" then
        table.insert(result, sub)
    end
    return #result == 1 and result[1] or table.concat(result, ".")
end

if not table.pack then
  table.pack = function(...)
    return { n = select("#", ...), ... }
  end
end

vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.loader.enable()
vim.o.exrc = true
if vim.g.vscode == nil then
    local ok, nixInfo = pcall(require, vim.g.nix_info_plugin_name)
    if ok and nixInfo(nil, "plugins", "start", "fn_finder") then
        -- NOTE: <c-k>*l is λ
        require("fn_finder").fnl.install {
            search_opts = { nvim = true },
            -- hack: a unique value (will be hashed into bytecode cache for invalidation)
            [nixInfo(nil, "wrapper_drv")] = nixInfo(vim.g.nix_info_plugin_name)(nil, "wrapper_drv"),
        }
    end
    require('birdee')
end
