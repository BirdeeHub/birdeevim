-- Telescope is a fuzzy finder that comes with a lot of different things that
-- it can fuzzy find! It's more than just a "file finder", it can search
-- many different aspects of Neovim, your workspace, LSP, and more!
--
-- The easiest way to use telescope, is to start by doing something like:
--  :Telescope help_tags
--
-- After running this command, a window will open up and you're able to
-- type in the prompt window. You'll see a list of help_tags options and
-- a corresponding preview of the help.
--
-- Two important keymaps to use while in telescope are:
--  - Insert mode: <c-/>
--  - Normal mode: ?
--
-- This opens a window that shows you all of the keymaps for the current
-- telescope picker. This is really useful to discover what Telescope can
-- do as well as how to actually do it!

-- [[ Configure Telescope ]]
-- See `:help telescope` and `:help telescope.setup()`
-- Telescope live_grep in git root
-- Function to find the git root directory based on the current buffer's path
local function find_git_root()
  -- Use the current buffer's path as the starting point for the git search
  local current_file = vim.api.nvim_buf_get_name(0)
  local current_dir
  local cwd = vim.fn.getcwd()
  -- If the buffer is not associated with a file, return nil
  if current_file == "" then
    current_dir = cwd
  else
    -- Extract the directory from the current file's path
    current_dir = vim.fn.fnamemodify(current_file, ":h")
  end

  -- Find the Git root directory from the current file's path
  local git_root = vim.fn.systemlist("git -C " .. vim.fn.escape(current_dir, " ") .. " rev-parse --show-toplevel")[1]
  if vim.v.shell_error ~= 0 then
    print("Not a git repository. Searching on current working directory")
    return cwd
  end
  return git_root
end

-- Custom live_grep function to search in git root
local function live_grep_git_root()
  local git_root = find_git_root()
  if git_root then
    require('telescope.builtin').live_grep({
      search_dirs = { git_root },
    })
  end
end

local tele_builtin = require('birdee.utils').lazy_require_funcs('telescope.builtin')

return {
  {
    "telescope.nvim",
    for_cat = "telescope",
    cmd = { "Telescope", "TodoTelescope", "LiveGrepGitRoot" },
    dep_of = { "nvim-neoclip.lua", "neorg" },
    on_require = { "telescope", },
    -- event = "",
    -- ft = "",
    keys = {
      -- { "<leader>sM", '<cmd>Telescope notify<CR>', mode = {"n"}, desc = '[S]earch [M]essage', },
      { "<leader>sb", '<cmd>Telescope git_file_history<CR>', mode = {"n"}, desc = '[S]earch [B]ackup history', },
      { "<leader>sp",live_grep_git_root, mode = {"n"}, desc = '[S]earch git [P]roject root', },
      { "<leader>/", function()
        -- Slightly advanced example of overriding default behavior and theme
        -- You can pass additional configuration to telescope to change theme, layout, etc.
        require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
          winblend = 10,
          previewer = false,
        })
      end, mode = {"n"}, desc = '[/] Fuzzily search in current buffer', },
      { "<leader>s/", function()
        require('telescope.builtin').live_grep {
          grep_open_files = true,
          prompt_title = 'Live Grep in Open Files',
        }
      end, mode = {"n"}, desc = '[S]earch [/] in Open Files', },
      { "<leader><leader>s", tele_builtin.buffers, mode = {"n"}, desc = '[ ] Find existing buffers', },
      { "<leader>s.", tele_builtin.oldfiles, mode = {"n"}, desc = '[S]earch Recent Files ("." for repeat)', },
      { "<leader>sr", tele_builtin.resume, mode = {"n"}, desc = '[S]earch [R]esume', },
      { "<leader>sd", tele_builtin.diagnostics, mode = {"n"}, desc = '[S]earch [D]iagnostics', },
      { "<leader>sg", tele_builtin.live_grep, mode = {"n"}, desc = '[S]earch by [G]rep', },
      { "<leader>sw", tele_builtin.grep_string, mode = {"n"}, desc = '[S]earch current [W]ord', },
      { "<leader>sf", tele_builtin.find_files, mode = {"n"}, desc = '[S]earch [F]iles', },
      { "<leader>sk", tele_builtin.keymaps, mode = {"n"}, desc = '[S]earch [K]eymaps', },
      { "<leader>sh", tele_builtin.help_tags, mode = {"n"}, desc = '[S]earch [H]elp', },
    },
    -- colorscheme = "",
    load = function (name)
      require('lzextras').loaders.multi {
        name,
        "telescope-fzf-native.nvim",
        "vim-fugitive",
        "telescope-git-file-history",
        "telescope-ui-select.nvim",
      }
    end,
    after = function (_)
      require('telescope').setup {
        -- You can put your default mappings / updates / etc. in here
        --  All the info you're looking for is in `:help telescope.setup()`
        --
        defaults = {
          mappings = {
            i = { ['<c-enter>'] = 'to_fuzzy_refine' },
          },
        },
        -- pickers = {}
        extensions = {
          ['ui-select'] = {
            require('telescope.themes').get_dropdown(),
          },
        },
      }

      -- Enable telescope extensions, if they are installed
      pcall(require('telescope').load_extension, 'fzf')
      pcall(require('telescope').load_extension, 'ui-select')
      -- pcall(require("telescope").load_extension, "notify")
      pcall(require("telescope").load_extension, "git_file_history")

      vim.api.nvim_create_user_command('LiveGrepGitRoot', live_grep_git_root, {})
    end,
  },
}
