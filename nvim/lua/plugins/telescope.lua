return {
  {
    "nvim-telescope/telescope.nvim",
    event = "VimEnter",
    branch = "0.1.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
        cond = function()
          return vim.fn.executable("make") == 1
        end,
      },
    },

    config = function()
      -- [[ Configure Telescope ]]
      -- See `:help telescope` and `:help telescope.setup()`
      local function custom_entry_maker(entry)
        local file_name = entry.filename or '[No Name]'
        local line_number = entry.lnum or '0'
        return {
          value = entry,
          display = function()
            return string.format("%s:%d", file_name, line_number)
          end,
          ordinal = file_name .. ":" .. line_number,
          filename = file_name,
          lnum = line_number,
        }
      end

      require('telescope').setup {
        defaults = {
          mappings = {
            i = {
              ['<C-u>'] = false,
              ['<C-d>'] = false,
            },
          },
          layout_strategy = 'vertical',
          layout_config = {
            width = 0.9,
            mirror = true,
            prompt_position = 'top'
          },
          sorting_strategy = 'descending',
        },
        pickers = {
          lsp_references = {
            entry_maker = custom_entry_maker
          },
          lsp_definitions = {
            entry_maker = custom_entry_maker
          }
        }
      }

      pcall(require('telescope').load_extension, 'fzf')

      -- Git root helpers
      local function find_git_root()
        local current_file = vim.api.nvim_buf_get_name(0)
        local current_dir
        local cwd = vim.fn.getcwd()

        if current_file == '' then
          current_dir = cwd
        else
          current_dir = vim.fn.fnamemodify(current_file, ':h')
        end

        local git_root = vim.fn.systemlist(
          'git -C ' .. vim.fn.escape(current_dir, ' ') .. ' rev-parse --show-toplevel'
        )[1]

        if vim.v.shell_error ~= 0 then
          print 'Not a git repository. Searching on current working directory'
          return cwd
        end

        return git_root
      end

      local function live_grep_git_root()
        local git_root = find_git_root()
        if git_root then
          require('telescope.builtin').live_grep {
            search_dirs = { git_root },
          }
        end
      end

      vim.api.nvim_create_user_command('LiveGrepGitRoot', live_grep_git_root, {})

      -- Keymaps
      local builtin = require('telescope.builtin')

      vim.keymap.set('n', '<leader>?', builtin.oldfiles, { desc = '[?] Recently opened files' })
      vim.keymap.set('n', '<leader><space>', builtin.buffers, { desc = '[ ] Find buffers' })
      vim.keymap.set('n', '<leader>/', function()
        builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
          winblend = 10,
          previewer = false,
        })
      end, { desc = 'Fuzzy search current buffer' })

      local function telescope_live_grep_open_files()
        builtin.live_grep {
          grep_open_files = true,
          prompt_title = 'Live Grep in Open Files',
        }
      end

      local function telescope_find_hidden_and_ignored()
        builtin.find_files({
          hidden = true,
          no_ignore = true,
          no_ignore_parent = true
        })
      end

      vim.keymap.set('n', '<leader>s/', telescope_live_grep_open_files, { desc = '[S]earch [/] Open Files' })
      vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[S]elect Telescope' })
      vim.keymap.set('n', '<leader>gf', builtin.git_files, { desc = '[G]it [F]iles' })
      vim.keymap.set('n', '<leader>sf', telescope_find_hidden_and_ignored, { desc = '[S]earch [F]iles' })
      vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
      vim.keymap.set('n', '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
      vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
      vim.keymap.set('n', '<leader>sG', ':LiveGrepGitRoot<cr>', { desc = '[G]rep Git Root' })
      vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
      vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })

    end,
  }
}

