if vim.g.vscode ~= nil and nixInfo.utils.get_nix_plugin_path "otter.nvim" then
    require('otter').activate()
end
