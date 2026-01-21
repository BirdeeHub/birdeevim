local MP = ...
return {
  {
    "AI_auths",
    enabled = false, -- nixInfo.isNix and nixInfo(false, "info", "bitwarden_uuids"),
    dep_of = { "windsurf.nvim", "minuet-ai.nvim", "nvim-aider", "opencode.nvim" },
    load = function(_)
      local bitwardenAuths = nixInfo(nil, "info", "bitwarden_uuids")
      local windsurfDir = vim.fn.stdpath('cache') .. '/' .. 'codeium'
      local windsurfAuthFile = windsurfDir .. '/' .. 'config.json'
      local windsurfAuthInvalid = vim.fn.filereadable(windsurfAuthFile) == 0
      nixInfo.utils.get_auths({
        windsurf = {
          enable = nixInfo.isNix and windsurfAuthInvalid and bitwardenAuths.windsurf or false,
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
          enable = nixInfo.isNix and bitwardenAuths.gemini or false,
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
    auto_enable = true,
    event = "InsertEnter",
    after = function (_)
      require("codeium").setup({ enable_chat = false, })
    end,
  },
  { import = MP:relpath "opencode", },
  { import = MP:relpath "minuet", },
  { import = MP:relpath "aider", },
  { import = MP:relpath "codecompanion", },
}
