return {
  {
    'mfussenegger/nvim-dap',
    dependencies = {
      'nvim-neotest/nvim-nio',
      'rcarriga/nvim-dap-ui',
      'mfussenegger/nvim-dap-python',
      'theHamsta/nvim-dap-virtual-text',
      -- Mason integration for automatic debugger installation
      'mason-org/mason.nvim',
      'jay-babu/mason-nvim-dap.nvim',
      -- Go debugging support
      'leoluz/nvim-dap-go',
    },
    config = function()
      local dap = require 'dap'
      local dapui = require 'dapui'
      local dap_python = require 'dap-python'

      -- Mason-nvim-dap setup for automatic debugger installation
      require('mason-nvim-dap').setup {
        automatic_installation = true,
        handlers = {},
        ensure_installed = {
          'delve', -- Go debugger
        },
      }

      require('dapui').setup {}
      require('nvim-dap-virtual-text').setup {
        commented = true, -- Show virtual text alongside comment
      }

      -- Python debugging setup
      dap_python.setup 'python3'

      -- Go debugging setup
      require('dap-go').setup {
        delve = {
          -- On Windows delve must be run attached or it crashes.
          detached = vim.fn.has 'win32' == 0,
        },
      }

      vim.fn.sign_define('DapBreakpoint', {
        text = '',
        texthl = 'DiagnosticSignError',
        linehl = '',
        numhl = '',
      })

      vim.fn.sign_define('DapBreakpointRejected', {
        text = '', -- or "❌"
        texthl = 'DiagnosticSignError',
        linehl = '',
        numhl = '',
      })

      vim.fn.sign_define('DapStopped', {
        text = '', -- or "→"
        texthl = 'DiagnosticSignWarn',
        linehl = 'Visual',
        numhl = 'DiagnosticSignWarn',
      })

      -- Automatically open/close DAP UI
      dap.listeners.after.event_initialized['dapui_config'] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated['dapui_config'] = dapui.close
      dap.listeners.before.event_exited['dapui_config'] = dapui.close

      -- Toggle breakpoint
      vim.keymap.set('n', '<leader>db', function()
        dap.toggle_breakpoint()
      end, { noremap = true, silent = true, desc = '[D]ebug: Toggle [B]reakpoint' })

      -- Continue / Start
      vim.keymap.set('n', '<leader>dc', function()
        dap.continue()
      end, { noremap = true, silent = true, desc = '[D]ebug: [C]ontinue' })

      -- Step Over
      vim.keymap.set('n', '<leader>do', function()
        dap.step_over()
      end, { noremap = true, silent = true, desc = '[D]ebug: Step [O]ver' })

      -- Step Into
      vim.keymap.set('n', '<leader>di', function()
        dap.step_into()
      end, { noremap = true, silent = true, desc = '[D]ebug: Step [I]nto' })

      -- Step Out
      vim.keymap.set('n', '<leader>dO', function()
        dap.step_out()
      end, { noremap = true, silent = true, desc = '[D]ebug: Step [O]ut' })

      -- Terminate debugging
      vim.keymap.set('n', '<leader>dq', function()
        dap.terminate()
      end, { noremap = true, silent = true, desc = '[D]ebug: [Q]uit/Terminate' })

      -- Toggle DAP UI
      vim.keymap.set('n', '<leader>du', function()
        dapui.toggle()
      end, { noremap = true, silent = true, desc = '[D]ebug: Toggle [U]I' })
    end,
  },
}
