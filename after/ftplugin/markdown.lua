if vim.g.vscode ~= nil and (nixInfo(nil, "plugins", "lazy", "otter.nvim") or nixInfo(nil, "plugins", "start", "otter.nvim"))then
    require('otter').activate()
end
