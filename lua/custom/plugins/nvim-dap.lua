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

      -- Python debugging setup - auto-detect environment
      -- Priority: VIRTUAL_ENV > CONDA_PREFIX > PATH
      local function get_python_path()
        -- 1. Check if VIRTUAL_ENV is set (works with hatch, venv, virtualenv)
        local venv = vim.env.VIRTUAL_ENV
        if venv and venv ~= '' then
          local venv_python = venv .. '/bin/python'
          if vim.fn.executable(venv_python) == 1 then
            return venv_python
          end
        end

        -- 2. Check if CONDA_PREFIX is set
        local conda = vim.env.CONDA_PREFIX
        if conda and conda ~= '' then
          local conda_python = conda .. '/bin/python'
          if vim.fn.executable(conda_python) == 1 then
            return conda_python
          end
        end

        -- 3. Fall back to PATH
        local python_path = vim.fn.exepath 'python'
        if python_path ~= '' then
          return python_path
        end

        return vim.fn.exepath 'python3'
      end

      --[[
      local python_path = get_python_path()
      print('nvim-dap using Python: ' .. python_path)
      dap_python.setup(python_path)

      -- Override resolve_python to use the same logic
      dap_python.resolve_python = get_python_path

      -- Enable DAP logging for debugging
      dap.set_log_level 'TRACE'

      -- Add custom configurations (nvim-dap-python already adds defaults)
      table.insert(dap.configurations.python, {
        type = 'python',
        request = 'launch',
        name = 'Debug Current File',
        program = '${file}',
        console = 'integratedTerminal',
        justMyCode = false,
        cwd = '${workspaceFolder}',
        -- Use the resolved Python from the function above
        pythonPath = function()
          return dap_python.resolve_python()
        end,
      })

      table.insert(dap.configurations.python, {
        type = 'python',
        request = 'attach',
        name = 'Attach to Running Process',
        connect = {
          host = 'localhost',
          port = 5678,
        },
        pathMappings = {
          {
            localRoot = '${workspaceFolder}',
            remoteRoot = '.',
          },
        },
        justMyCode = false,
})
	]]
      --
      -- Go debugging setup
      require('dap-go').setup {
        delve = {
          -- On Windows delve must be run attached or it crashes.
          detached = vim.fn.has 'win32' == 0,
        },
      }

      -- Define breakpoint signs (make them more visible)
      vim.fn.sign_define('DapBreakpoint', {
        text = '●',
        texthl = 'DapBreakpoint',
        linehl = '',
        numhl = '',
      })

      vim.fn.sign_define('DapBreakpointCondition', {
        text = '◆',
        texthl = 'DapBreakpoint',
        linehl = '',
        numhl = '',
      })

      vim.fn.sign_define('DapBreakpointRejected', {
        text = '✖',
        texthl = 'DapBreakpoint',
        linehl = '',
        numhl = '',
      })

      vim.fn.sign_define('DapStopped', {
        text = '→',
        texthl = 'DapStopped',
        linehl = 'Visual',
        numhl = 'DapStopped',
      })

      vim.fn.sign_define('DapLogPoint', {
        text = '◉',
        texthl = 'DapLogPoint',
        linehl = '',
        numhl = '',
      })

      -- Define highlight groups for signs
      vim.api.nvim_set_hl(0, 'DapBreakpoint', { fg = '#e51400' })
      vim.api.nvim_set_hl(0, 'DapStopped', { fg = '#ffcc00' })
      vim.api.nvim_set_hl(0, 'DapLogPoint', { fg = '#61afef' })

      -- Automatically open DAP UI (but don't auto-close)
      dap.listeners.after.event_initialized['dapui_config'] = function()
        print 'DAP: Session initialized'
        dapui.open()
      end
      dap.listeners.before.event_terminated['dapui_config'] = function()
        print 'DAP: Session terminated (UI stays open - close with <leader>du)'
        -- Don't close UI - let user review output
      end
      dap.listeners.before.event_exited['dapui_config'] = function()
        print 'DAP: Session exited (UI stays open - close with <leader>du)'
        -- Don't close UI - let user review output
      end

      -- Debug session lifecycle events
      dap.listeners.after.event_stopped['custom'] = function()
        print 'DAP: Stopped at breakpoint or exception'
      end

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

      -- Run to cursor
      vim.keymap.set('n', '<leader>dC', function()
        dap.run_to_cursor()
      end, { noremap = true, silent = true, desc = '[D]ebug: Run to [C]ursor' })

      -- Start debugging current file (shortcut to most common workflow)
      vim.keymap.set('n', '<leader>df', function()
        -- Find "Debug Current File" configuration and run it directly
        for _, config in ipairs(dap.configurations.python or {}) do
          if config.name == 'Debug Current File' then
            dap.run(config)
            return
          end
        end
        -- Fallback: show config picker if not found
        dap.continue()
      end, { noremap = true, silent = true, desc = '[D]ebug: Current [F]ile' })

      -- Select and run configuration (for other debug configs)
      vim.keymap.set('n', '<leader>ds', function()
        dap.continue()
      end, { noremap = true, silent = true, desc = '[D]ebug: [S]elect Config' })

      -- Python-specific: Debug selection (BEST for interactive debugging!)
      vim.keymap.set('v', '<leader>ds', function()
        dap_python.debug_selection()
      end, { noremap = true, silent = true, desc = '[D]ebug: [S]election (Python)' })

      -- Python-specific: Debug test method
      vim.keymap.set('n', '<leader>dtm', function()
        dap_python.test_method()
      end, { noremap = true, silent = true, desc = '[D]ebug: [T]est [M]ethod' })

      -- Python-specific: Debug test class
      vim.keymap.set('n', '<leader>dtc', function()
        dap_python.test_class()
      end, { noremap = true, silent = true, desc = '[D]ebug: [T]est [C]lass' })

      -- List all breakpoints (for debugging)
      vim.keymap.set('n', '<leader>dl', function()
        local breakpoints = require('dap.breakpoints').get()
        local count = 0
        for _, buf_bps in pairs(breakpoints) do
          count = count + #buf_bps
        end
        if count == 0 then
          print 'No breakpoints set'
        else
          print('Breakpoints (' .. count .. '):')
          for bufnr, buf_bps in pairs(breakpoints) do
            local filename = vim.api.nvim_buf_get_name(bufnr)
            for _, bp in ipairs(buf_bps) do
              print(string.format('  %s:%d', vim.fn.fnamemodify(filename, ':t'), bp.line))
            end
          end
        end
      end, { noremap = true, silent = true, desc = '[D]ebug: [L]ist breakpoints' })

      -- Check which Python debugger will use
      vim.keymap.set('n', '<leader>dp', function()
        local python = get_python_path()
        print('Python: ' .. python)
        print('VIRTUAL_ENV: ' .. (vim.env.VIRTUAL_ENV or 'not set'))
      end, { noremap = true, silent = true, desc = '[D]ebug: Check [P]ython' })

      -- View DAP logs
      vim.keymap.set('n', '<leader>dL', function()
        local log_path = vim.fn.stdpath 'cache' .. '/dap.log'
        vim.cmd('tabnew ' .. log_path)
      end, { noremap = true, silent = true, desc = '[D]ebug: View [L]ogs' })
    end,
  },
}
