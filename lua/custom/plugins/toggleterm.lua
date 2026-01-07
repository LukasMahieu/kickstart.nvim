return {
  'akinsho/toggleterm.nvim',
  version = '*',
  opts = {
    -- Size can be a number or function which is passed the current terminal
    size = 20,
    hide_numbers = true,
    shade_terminals = true,
    start_in_insert = true,
    insert_mappings = true, -- whether or not the open mapping applies in insert mode
    terminal_mappings = true, -- whether or not the open mapping applies in the opened terminals
    persist_size = true,
    persist_mode = true, -- if set to true (default) the previous terminal mode will be remembered
    direction = 'float',
    close_on_exit = true, -- close the terminal window when the process exits
    shell = vim.o.shell, -- change the default shell
    auto_scroll = true, -- automatically scroll to the bottom on terminal output
    -- This field is only relevant if direction is set to 'float'
    float_opts = {
      border = 'curved',
      width = math.floor(vim.o.columns * 0.8),
      height = math.floor(vim.o.lines * 0.8),
      winblend = 3,
    },
  },
  config = function(_, opts)
    require('toggleterm').setup(opts)

    -- Custom keybindings
    local keymap = vim.keymap.set
    local opts_desc = { noremap = true, silent = true }

    -- Toggle terminal with Ctrl+t (Ctrl+\ conflicts with terminal escape)
    keymap('n', '<C-t>', '<cmd>ToggleTerm<CR>', vim.tbl_extend('force', opts_desc, { desc = 'Toggle terminal' }))
    keymap('t', '<C-t>', '<cmd>ToggleTerm<CR>', vim.tbl_extend('force', opts_desc, { desc = 'Toggle terminal' }))

    -- Alternative: use <leader>tt as well
    keymap('n', '<leader>tt', '<cmd>ToggleTerm<CR>', vim.tbl_extend('force', opts_desc, { desc = '[T]oggle [T]erminal' }))

    -- Multiple terminal instances
    keymap('n', '<leader>t1', '<cmd>1ToggleTerm<CR>', vim.tbl_extend('force', opts_desc, { desc = '[T]erminal [1]' }))
    keymap('n', '<leader>t2', '<cmd>2ToggleTerm<CR>', vim.tbl_extend('force', opts_desc, { desc = '[T]erminal [2]' }))
    keymap('n', '<leader>t3', '<cmd>3ToggleTerm<CR>', vim.tbl_extend('force', opts_desc, { desc = '[T]erminal [3]' }))
    keymap('n', '<leader>t4', '<cmd>4ToggleTerm<CR>', vim.tbl_extend('force', opts_desc, { desc = '[T]erminal [4]' }))

    -- Optional: Additional keybindings for specific terminal numbers
    keymap('n', '<leader>tf', '<cmd>ToggleTerm direction=float<CR>', vim.tbl_extend('force', opts_desc, { desc = '[T]erminal [F]loat' }))
    keymap('n', '<leader>th', '<cmd>ToggleTerm direction=horizontal<CR>', vim.tbl_extend('force', opts_desc, { desc = '[T]erminal [H]orizontal' }))
    keymap('n', '<leader>tv', '<cmd>ToggleTerm direction=vertical<CR>', vim.tbl_extend('force', opts_desc, { desc = '[T]erminal [V]ertical' }))

    -- Function to create a lazygit terminal toggle
    local Terminal = require('toggleterm.terminal').Terminal
    local lazygit = Terminal:new {
      cmd = 'lazygit',
      dir = 'git_dir',
      direction = 'float',
      float_opts = {
        border = 'curved',
      },
      -- function to run on opening the terminal
      on_open = function(term)
        vim.cmd 'startinsert!'
        vim.api.nvim_buf_set_keymap(term.bufnr, 'n', 'q', '<cmd>close<CR>', { noremap = true, silent = true })
      end,
    }

    function _lazygit_toggle()
      lazygit:toggle()
    end

    -- Keybinding for lazygit (optional, requires lazygit to be installed)
    keymap('n', '<leader>tg', '<cmd>lua _lazygit_toggle()<CR>', vim.tbl_extend('force', opts_desc, { desc = '[T]erminal lazy[G]it' }))
  end,
}
