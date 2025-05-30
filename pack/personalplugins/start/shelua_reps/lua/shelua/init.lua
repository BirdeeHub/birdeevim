local M = {}
M.add_reprs = function (sh, ...)
    ---@cast sh Shelua
    sh = sh or require('sh')
    for _, v in ipairs({...}) do
      if not getmetatable(sh).repr[v] then
        sh = require('shelua.repr.' .. v)(sh)
      end
    end
    return sh
end
M.force_add_reprs = function (sh, ...)
    ---@cast sh Shelua
    sh = sh or require('sh')
    for _, v in ipairs({...}) do
      package.loaded['shelua.repr.' .. v] = nil
      sh = require('shelua.repr.' .. v)(sh)
    end
    return sh
end
return M
