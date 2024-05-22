local M = {
  'akinsho/toggleterm.nvim',
  version = '*',
  opts = {},
  config = function()
    local Terminal = require('toggleterm.terminal').Terminal

    require('toggleterm').setup {
      size = 30,
      open_mapping = [[<c-\>]],
    }

    local function central_terminal(cmd)
      local terminal = Terminal:new {
        cmd = cmd,
        dir = 'git_dir',
        direction = 'float',
        float_opts = {
          border = 'double',
        },
        -- function to run on opening the terminal
        on_open = function(term)
          vim.cmd 'startinsert!'
          vim.api.nvim_buf_set_keymap(term.bufnr, 'n', 'q', '<cmd>close<CR>', { noremap = true, silent = true })
        end,
        -- function to run on closing the terminal
        on_close = function(term)
          vim.cmd 'startinsert!'
        end,
      }
      return terminal
    end

    local lazygit = central_terminal 'lazygit'
    local dooit = central_terminal 'dooit'

    local test_terminal = Terminal:new {
      cmd = 'zsh',
      dir = 'git_dir',
      direction = 'horizontal',
      -- function to run on opening the terminal
      on_open = function(term)
        -- Get the path of the previous buffer
        local prev_buf = vim.fn.bufnr '#'
        local prev_buf_path = vim.fn.expand('#' .. prev_buf .. ':p')

        -- Set the command to be executed in the terminal
        -- Determine the command to run based on file type
        local filetype = vim.api.nvim_get_option_value('filetype', { buf = prev_buf })

        local cmd
        if filetype == 'imba' then
          cmd = 'imba '
        else
          cmd = 'node '
        end

        cmd = cmd .. prev_buf_path
        -- Send the command to the terminal and execute it
        vim.api.nvim_chan_send(term.job_id, cmd .. '\r')
        -- vim.cmd 'startinsert!'
        vim.api.nvim_buf_set_keymap(term.bufnr, 'n', 'q', '<cmd>close<CR>', { noremap = true, silent = true })
      end,
      -- function to run on closing the terminal
      on_close = function(term)
        -- vim.cmd 'startinsert!'
      end,
      -- function to set the command before opening the terminal
      -- on_open_pre = function(term)
      --   local current_buffer = vim.api.nvim_buf_get_name(0)
      --   term.cmd = 'node ' .. current_buffer
      -- end,
    }

    local _dooit_toggle = function()
      dooit:toggle()
    end
    local _lazygit_toggle = function()
      lazygit:toggle()
    end
    local _test_toggle = function()
      test_terminal:toggle()
    end
    vim.keymap.set('n', '<leader>tg', _lazygit_toggle, { noremap = true, silent = true, desc = '[T]oggle [G]it (lazy git terminal)' })
    vim.keymap.set('n', '<leader>tf', _test_toggle, { noremap = true, silent = true, desc = '[T]oggle [P]layground for file' })
    vim.keymap.set('n', '<leader>td', _dooit_toggle, { noremap = true, silent = true, desc = '[T]oggle to[D]o list' })
  end,
}

return M
