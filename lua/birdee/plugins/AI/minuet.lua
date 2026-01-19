return {
  "minuet-ai.nvim",
  event = "InsertEnter",
  cmd = { "Minuet" },
  after = function()
    require('minuet').setup {
      provider = 'gemini',
      cmp = {
        enable_auto_complete = false,
      },
      blink = {
        enable_auto_complete = true,
      },
      n_completions = 1, -- recommend for local model for resource saving
      context_ratio = 0.75,
      throttle = 1000, -- only send the request every x milliseconds, use 0 to disable throttle.
      debounce = 250, -- debounce the request in x milliseconds, set to 0 to disable debounce
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
}
