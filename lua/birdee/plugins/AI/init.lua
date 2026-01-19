local MP = ...
local isNix = vim.g.nix_info_plugin_name ~= nil
return {
  {
    "AI_auths",
    enabled = false, -- isNix and nixInfo(false, "info", "bitwarden_uuids"),
    dep_of = { "windsurf.nvim", "minuet-ai.nvim", "nvim-aider", "opencode.nvim" },
    load = function(_)
      local bitwardenAuths = nixInfo(nil, "info", "bitwarden_uuids")
      local windsurfDir = vim.fn.stdpath('cache') .. '/' .. 'codeium'
      local windsurfAuthFile = windsurfDir .. '/' .. 'config.json'
      local windsurfAuthInvalid = vim.fn.filereadable(windsurfAuthFile) == 0
      require('birdee.utils').get_auths({
        windsurf = {
          enable = isNix and windsurfAuthInvalid and bitwardenAuths.windsurf or false,
          cache = false, -- <- this one is cached by its action
          bw_id = bitwardenAuths.windsurf,
          localpath = (os.getenv("HOME") or "~") .. "/.secrets/windsurf",
          action = function (key)
            if vim.fn.isdirectory(windsurfDir) == 0 then
              vim.fn.mkdir(windsurfDir, 'p')
            end
            if (string.len(key) > 10) then
              local file = io.open(windsurfAuthFile, 'w')
              if file then
                file:write('{"api_key": "' .. key .. '"}')
                file:close()
                vim.loop.fs_chmod(windsurfAuthFile, 384, function(err, success)
                  if err then
                    print("Failed to set file permissions: " .. err)
                  end
                end)
              end
            end
          end,
        },
        gemini = {
          enable = isNix and bitwardenAuths.gemini or false,
          cache = true,
          bw_id = bitwardenAuths.gemini,
          localpath = (os.getenv("HOME") or "~") .. "/.secrets/gemini",
          action = function(key)
            vim.env.GEMINI_API_KEY = key
          end,
        },
      })
      local function mkClear(cmd, file)
        vim.api.nvim_create_user_command(cmd, function(_) os.remove(file) end, {})
      end
      mkClear("ClearWindsurfAuth", windsurfAuthFile)
      mkClear("ClearGeminiAuth", (os.getenv("HOME") or "~") .. "/.secrets/gemini")
      mkClear("ClearBitwardenData", vim.fn.stdpath('config') .. [[/../Bitwarden\ CLI/data.json]])
    end
  },
  {
    "windsurf.nvim",
    event = "InsertEnter",
    after = function (_)
      require("codeium").setup({ enable_chat = false, })
    end,
  },
  { import = MP:relpath "opencode", enabled = true, },
  { import = MP:relpath "minuet", enabled = false, },
  { import = MP:relpath "aider", enabled = false, },
  { import = MP:relpath "codecompanion", enabled = false, },
}
