return {
  {
    'benlubas/molten-nvim',
    version = '^1.0.0', -- use version <2.0.0 to avoid breaking changes
    dependencies = { '3rd/image.nvim' },
    build = function()
      -- Create virtualenv and install Python dependencies
      local venv_path = vim.fn.expand '~/.virtualenvs/neovim'
      local python_bin = venv_path .. '/bin/python3'

      -- Check if virtualenv exists
      if vim.fn.isdirectory(venv_path) == 0 then
        print('Creating neovim virtualenv at ' .. venv_path)
        vim.fn.system('python3 -m venv ' .. venv_path)
      end

      -- Install required packages
      print('Installing Python dependencies...')
      local packages = {
        'pynvim',
        'jupyter_client',
        'jupytext',     -- required: for jupytext.nvim plugin
        'cairosvg',     -- optional: for transparent SVG images
        'pnglatex',     -- optional: for TeX formulas (requires TeX distribution)
        'plotly',       -- optional: for Plotly figures
        'kaleido',      -- optional: for Plotly figures
        'pyperclip',    -- optional: for molten_copy_output
      }

      vim.fn.system(python_bin .. ' -m pip install --upgrade pip')
      vim.fn.system(python_bin .. ' -m pip install ' .. table.concat(packages, ' '))

      -- Run UpdateRemotePlugins
      vim.cmd('UpdateRemotePlugins')
      print('Python dependencies installed successfully!')
    end,
    init = function()
      -- Point Neovim to the dedicated virtual environment
      vim.g.python3_host_prog = vim.fn.expand '~/.virtualenvs/neovim/bin/python3'

      -- Configuration settings for notebook workflow
      vim.g.molten_image_provider = 'image.nvim'
      vim.g.molten_output_win_max_height = 20
      vim.g.molten_auto_open_output = false -- Don't auto-open, use <leader>mo
      vim.g.molten_wrap_output = true -- Wrap long lines in output
      vim.g.molten_virt_text_output = true -- Show output as virtual text
      vim.g.molten_virt_lines_off_by_1 = true -- Fix virtual text positioning
    end,
    config = function()
      -- Function to run code block under cursor
      local function run_code_block()
        -- Save current cursor position
        local current_pos = vim.api.nvim_win_get_cursor(0)
        local current_line = current_pos[1]

        -- Get current line content to check if we're on a fence
        local current_line_content = vim.api.nvim_buf_get_lines(0, current_line - 1, current_line, false)[1]

        -- If we're on the opening fence, move down one line
        if current_line_content and (current_line_content:match '^```python' or current_line_content:match '^```{python}') then
          current_line = current_line + 1
        end

        -- Search backwards for start of code block (```python or ```{python})
        local start_line = nil
        for i = current_line, 1, -1 do
          local line = vim.api.nvim_buf_get_lines(0, i - 1, i, false)[1]
          if line and (line:match '^```python' or line:match '^```{python}') then
            start_line = i
            break
          end
        end

        if not start_line then
          print 'Not inside a Python code block'
          return
        end

        -- Search forwards for end of code block (```)
        local end_line = nil
        local total_lines = vim.api.nvim_buf_line_count(0)
        for i = current_line, total_lines do
          local line = vim.api.nvim_buf_get_lines(0, i - 1, i, false)[1]
          -- Match closing fence: exactly ``` at start of line
          if line and line:match '^```%s*$' then
            end_line = i
            break
          end
        end

        if not end_line then
          print 'Could not find end of code block'
          return
        end

        -- Make sure start comes before end
        if start_line >= end_line then
          print 'Invalid code block boundaries'
          return
        end

        -- Select the code (excluding the ``` markers)
        local code_start = start_line + 1
        local code_end = end_line - 1

        if code_start > code_end then
          print 'Empty code block'
          return
        end

        -- Debug: print what we're selecting
        print(string.format('Selecting lines %d to %d', code_start, code_end))

        -- Select the range in visual mode
        vim.cmd(string.format('normal! %dGV%dG', code_start, code_end))

        -- Execute MoltenEvaluateVisual from visual mode
        -- Use feedkeys to properly send the command while in visual mode
        local keys = vim.api.nvim_replace_termcodes(':<C-u>MoltenEvaluateVisual<CR>', true, false, true)
        vim.api.nvim_feedkeys(keys, 'n', false)
      end

      -- Create the command
      vim.api.nvim_create_user_command('MoltenRunCodeBlock', run_code_block, {})
    end,
    keys = {
      { '<leader>mi', ':MoltenInit<CR>', desc = 'Molten [I]nit kernel' },
      { '<leader>mI', ':MoltenRestart<CR>', desc = 'Molten restart kernel' },
      { '<leader>me', ':MoltenEvaluateOperator<CR>', mode = 'n', desc = 'Molten [E]valuate operator' },
      { '<leader>ml', ':MoltenEvaluateLine<CR>', desc = 'Molten evaluate [L]ine' },
      { '<leader>mc', ':MoltenRunCodeBlock<CR>', desc = 'Molten run [C]ode block' },
      { '<leader>mr', ':MoltenReevaluateCell<CR>', desc = 'Molten [R]e-evaluate cell' },
      { '<leader>mv', ':<C-u>MoltenEvaluateVisual<CR>gv', mode = 'v', desc = 'Molten evaluate [V]isual' },
      { '<leader>md', ':MoltenDelete<CR>', desc = 'Molten [D]elete cell' },
      { '<leader>mo', ':MoltenShowOutput<CR>', desc = 'Molten show [O]utput' },
      { '<leader>mh', ':MoltenHideOutput<CR>', desc = 'Molten [H]ide output' },
      { '<leader>mx', ':MoltenInterrupt<CR>', desc = 'Molten interrupt e[X]ecution' },
      -- Notebook operations
      { '<leader>mn', ':MoltenNext<CR>', desc = 'Molten [N]ext cell' },
      { '<leader>mp', ':MoltenPrev<CR>', desc = 'Molten [P]rev cell' },
      { '<leader>ms', ':MoltenSave<CR>', desc = 'Molten [S]ave outputs' },
      { '<leader>mL', ':MoltenLoad<CR>', desc = 'Molten [L]oad saved outputs' },
      { '<leader>mX', ':MoltenExportOutput<CR>', desc = 'Molten e[X]port output' },
    },
  },
  {
    -- Optional but recommended for image support
    '3rd/image.nvim',
    rocks = true,
    opts = {
      backend = 'kitty', -- or 'ueberzug' depending on your terminal
      integrations = {
        markdown = {
          enabled = true,
          clear_in_insert_mode = false,
          download_remote_images = true,
          only_render_image_at_cursor = false,
          filetypes = { 'markdown', 'vimwiki' },
        },
      },
      max_width = nil,
      max_height = nil,
      max_width_window_percentage = nil,
      max_height_window_percentage = 50,
      window_overlap_clear_enabled = false,
      window_overlap_clear_ft_ignore = { 'cmp_menu', 'cmp_docs', '' },
      editor_only_render_when_focused = false,
      tmux_show_only_in_active_window = false,
      hijack_file_patterns = { '*.png', '*.jpg', '*.jpeg', '*.gif', '*.webp' },
    },
  },
}
