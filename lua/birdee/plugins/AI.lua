local catUtils = require('nixCatsUtils')
return {
  {
    "codecompanion.nvim",
    for_cat = { cat = 'AI.default', default = false },
    cmd = {
      "CodeCompanion",
      "CodeCompanionCmd",
      "CodeCompanionChat",
      "CodeCompanionAction",
    },
    keys = {
      { "<leader>cc", ":CodeCompanionChat<CR>", mode = { "n", "v", "x" }, desc = "[C]lippy[C]hat" },
      { "<leader>cv", ":CodeCompanionCmd", mode = { "n", "v", "x" }, desc = "[C]lippy[V]imcmd" },
      { "<leader>cd", ":CodeCompanionAction<CR>", mode = { "n", "v", "x" }, desc = "[C]lippy[D]o" },
    },
    after = function()
      require("codecompanion").setup({
        strategies = {
          chat = {
            adapter = "ollama",
          },
          inline = {
            adapter = "qwen7",
          },
          cmd = {
            adapter = "ollama",
          }
        },
        adapters = {
          qwen7 = function()
            return require("codecompanion.adapters").extend("ollama", {
              name = "qwen7", -- Give this adapter a different name to differentiate it from the default ollama adapter
              schema = {
                model = {
                  default = "qwen2.5-coder:7b",
                },
                num_ctx = {
                  default = 16384,
                },
                num_predict = {
                  default = -1,
                },
              },
            })
          end,
          llama3 = function()
            return require("codecompanion.adapters").extend("ollama", {
              name = "llama3", -- Give this adapter a different name to differentiate it from the default ollama adapter
              schema = {
                model = {
                  default = "llama3.1:latest",
                },
                num_ctx = {
                  default = 16384,
                },
                num_predict = {
                  default = -1,
                },
              },
            })
          end,
        },
      })
    end,
  },
  {
    "minuet-ai.nvim",
    event = "InsertEnter",
    for_cat = { cat = 'AI.minuet', default = false },
    cmd = { "Minuet" },
    after = function()
      require('minuet').setup {
        provider = 'openai_fim_compatible',
        cmp = {
          enable_auto_complete = false,
        },
        blink = {
          enable_auto_complete = nixCats('blink') or false,
        },
        n_completions = 1, -- recommend for local model for resource saving
        -- I recommend beginning with a small context window size and incrementally
        -- expanding it, depending on your local computing power. A context window
        -- of 512, serves as an good starting point to estimate your computing
        -- power. Once you have a reliable estimate of your local computing power,
        -- you should adjust the context window to a larger value.
        context_ratio = 0.75,
        throttle = 1000, -- only send the request every x milliseconds, use 0 to disable throttle.
        -- debounce the request in x milliseconds, set to 0 to disable debounce
        debounce = 250,
        context_window = 512,
        request_timeout = 3,
        -- notify = "debug",
        provider_options = {
          gemini = {
            model = 'gemini-2.0-flash',
            api_key = 'GEMINI_API_KEY',
            optional = {
              generationConfig = {
                maxOutputTokens = 256,
              },
            },
          },
          openai_fim_compatible = {
            api_key = 'TERM',
            name = 'Ollama',
            stream = true,
            end_point = 'http://localhost:11434/v1/completions',
            model = 'qwen2.5-coder:7b',
            optional = {
              max_tokens = nil,
              top_p = nil,
              stop = nil,
            },
          },
        },
      }
    end,
  },
  {
    "windsurf.nvim",
    for_cat = { cat = 'AI.windsurf', default = false },
    event = "InsertEnter",
    after = function (_)
      local bitwardenAuth = nixCats.extra('AIextras.codeium_bitwarden_uuid')
      if not catUtils.isNixCats then bitwardenAuth = false end

      local codeiumDir = vim.fn.stdpath('cache') .. '/' .. 'codeium'
      local codeiumAuthFile = codeiumDir .. '/' .. 'config.json'

      local localKeyPath = vim.fn.expand("$HOME") .. "/.secrets/codeium"
      local havelocalkey = vim.fn.filereadable(localKeyPath) == 1

      local codeiumAuthInvalid = vim.fn.filereadable(codeiumAuthFile) == 0

      local session
      local ok
      if bitwardenAuth then
        if codeiumAuthInvalid and not havelocalkey then
          local bw_secret = vim.fn.expand("$HOME") .. "/.secrets/bw"
          local result = nil
          if vim.fn.filereadable(bw_secret) == 1 then
            local handle = io.open(bw_secret, "r")
            if handle then
              result = handle:read("*l")
              handle:close()
            end
          end
          session, ok = require("birdee.utils").authTerminal(result)
          if not ok then
            bitwardenAuth = false
          end
        end
      end
      if codeiumAuthInvalid then
        if (bitwardenAuth or havelocalkey) then
          local result
          local handle
          if havelocalkey then
            handle = io.open(localKeyPath, "r")
          elseif bitwardenAuth then
            handle = io.popen("bw get --nointeraction --session " .. session .. " " .. bitwardenAuth, "r")
          end
          if handle then
            result = handle:read("*l")
            handle:close()
          end
          if vim.fn.isdirectory(codeiumDir) == 0 then
            vim.fn.mkdir(codeiumDir, 'p')
          end
          if (string.len(result) > 10) then
            local file = io.open(codeiumAuthFile, 'w')
            if file then
              file:write('{"api_key": "' .. result .. '"}')
              file:close()
              vim.loop.fs_chmod(codeiumAuthFile, 384, function(err, success)
                if err then
                  print("Failed to set file permissions: " .. err)
                end
              end)
            end
          end
        end
      end

      require("codeium").setup({ enable_chat = false, })

      vim.api.nvim_create_user_command("ClearCodeiumAuth", function (opts)
        print(require("birdee.utils").deleteFileIfExists(codeiumAuthFile))
      end, {})
      vim.api.nvim_create_user_command("ClearBitwardenData", function (opts)
        print(require("birdee.utils").deleteFileIfExists(vim.fn.stdpath('config') .. [[/../Bitwarden\ CLI/data.json]]))
      end, {})
    end,
  },
}
