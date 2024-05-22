return {
  {
    'mfussenegger/nvim-dap',
    dependencies = {
      'leoluz/nvim-dap-go',
      'rcarriga/nvim-dap-ui',
      'theHamsta/nvim-dap-virtual-text',
      'nvim-neotest/nvim-nio',
      'williamboman/mason.nvim',
      'MunifTanjim/nui.nvim',
      'jbyuki/one-small-step-for-vimkind',
    },
    config = function()
      local dap = require 'dap'
      local ui = require 'dapui'
      local Input = require 'nui.input'
      local event = require('nui.utils.autocmd').event

      require('dapui').setup()
      require('dap-go').setup()

      require('nvim-dap-virtual-text').setup {}

      dap.adapters['pwa-node'] = {
        type = 'server',
        host = 'localhost',
        port = '${port}',
        executable = {
          command = 'node',
          -- 💀 Make sure to update this path to point to your installation
          args = { '/Users/abdellah/.config/nvim/lua/custom/plugins/js-debug/src/dapDebugServer.js', '${port}' },
        },
      }

      dap.configurations.javascript = {
        {
          type = 'pwa-node',
          request = 'launch',
          name = 'Launch file',
          program = '${file}',
          cwd = '${workspaceFolder}',
        },
      }

      -- DEBUG NEOVIM PLUGINS
      dap.configurations.lua = {
        {
          type = 'nlua',
          request = 'attach',
          name = 'Attach to running Neovim instance',
        },
      }

      dap.adapters.nlua = function(callback, config)
        callback { type = 'server', host = config.host or '127.0.0.1', port = config.port or 8086 }
      end

      vim.keymap.set('n', '<space>bn', function()
        require('osv').launch { port = 8086 }
      end, { desc = '[B]reakpoint start [N]eovim server for debugging' })

      -- END DEBUG NEOVIM PLUGINS

      vim.keymap.set('n', '<space>bb', dap.toggle_breakpoint, { desc = 'dap.toggle_breakpoint' })
      vim.keymap.set('n', '<space>gb', dap.run_to_cursor, { desc = 'dap.run_to_cursor' })

      vim.keymap.set('n', '<space>bj', function()
        dap.set_breakpoint()
        dap.continue()
      end, { desc = 'Setup [B]reakpoint and [J]ump to it' })

      -- Eval var under cursor
      local b_eval = function()
        require('dapui').eval(nil, { enter = true })
      end
      vim.keymap.set('n', '<space>b?', b_eval)
      vim.keymap.set('n', '<space>?', b_eval)

      vim.keymap.set('n', '<space>b0', dap.continue, { desc = 'dap.continue' })
      vim.keymap.set('n', '<space>bc', dap.continue, { desc = 'dap.continue' })
      vim.keymap.set('n', '<space>b1', dap.step_into, { desc = 'dap.step_into' })
      vim.keymap.set('n', '<space>bsi', dap.step_into, { desc = 'dap.step_into' })
      vim.keymap.set('n', '<space>b2', dap.step_over, { desc = 'dap.step_over' })
      vim.keymap.set('n', '<space>bsv', dap.step_over, { desc = 'dap.step_over' })
      vim.keymap.set('n', '<space>b3', dap.step_out, { desc = 'dap.step_out' })
      vim.keymap.set('n', '<space>bso', dap.step_out, { desc = 'dap.step_out' })
      vim.keymap.set('n', '<space>b4', dap.step_back, { desc = 'dap.step_back' })
      vim.keymap.set('n', '<space>bsb', dap.step_back, { desc = 'dap.step_back' })
      vim.keymap.set('n', '<space>b5', dap.restart, { desc = 'dap.restart' })
      vim.keymap.set('n', '<space>br', dap.restart, { desc = 'dap.restart' })

      dap.listeners.before.attach.dapui_config = function()
        ui.open()
      end
      dap.listeners.before.launch.dapui_config = function()
        ui.open()
      end
      dap.listeners.before.event_terminated.dapui_config = function()
        ui.close()
      end
      dap.listeners.before.event_exited.dapui_config = function()
        ui.close()
      end

      -- Advanced stuff (conditionals, logpoints and exceptions)
      --
      local function prompt(msg, default, cb)
        local layout_center = {
          position = '50%',
          size = {
            width = 80,
          },
          border = {
            style = 'single',
            text = {
              top = msg,
              top_align = 'center',
            },
          },
          win_options = {
            winhighlight = 'Normal:Normal,FloatBorder:Normal',
          },
        }

        local input = Input(layout_center, {
          default = default,
          on_submit = cb,
        })

        input:mount()
        vim.api.nvim_buf_set_keymap(input.bufnr, 'n', 'q', '<cmd>close<CR>', { noremap = true, silent = true })

        input:on(event.BufLeave, function()
          input:unmount()
        end)
      end

      local function set_logpoint_with_prompt()
        -- Get the current selection if any
        local selection = '{' .. (vim.fn.getreg 'v' or '') .. '}'

        prompt('What do you want to log? you can use {new Date()} to eval', selection, function(txt)
          require('dap').set_breakpoint(nil, nil, txt)
        end)
      end

      local function set_cb_with_condition(selection, cb)
        prompt('Type your condition', selection, cb)
      end

      local function set_logpoint_with_prompt_and_condition()
        -- Get the current selection if any
        local selection = '{' .. (vim.fn.getreg 'v' or '') .. '}'

        prompt('1/2 Log: What do you want to log? you can use {new Date()} to eval', selection, function(txt)
          set_cb_with_condition(selection, function(condition)
            require('dap').set_breakpoint(condition, nil, txt)
          end)
        end)
      end

      vim.keymap.set('n', '<space>bll', set_logpoint_with_prompt, { desc = '[B]reakpoint, [L]ogpoint actua[l]ly' })
      vim.keymap.set('v', '<space>bll', set_logpoint_with_prompt, { desc = '[B]reakpoint, [L]ogpoint actua[l]ly' })

      vim.keymap.set('n', '<space>blc', set_logpoint_with_prompt_and_condition, { desc = '[B]reakpoint, [L]ogpoint with [C]ondition' })
      vim.keymap.set('v', '<space>blc', set_logpoint_with_prompt_and_condition, { desc = '[B]reakpoint, [L]ogpoint with [C]ondition' })
    end,
  },
}
