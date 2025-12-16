-- Neo-tree is a Neovim plugin to browse the file system
-- https://github.com/nvim-neo-tree/neo-tree.nvim

return {
  'nvim-neo-tree/neo-tree.nvim',
  version = '*',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-web-devicons', -- not strictly required, but recommended
    'MunifTanjim/nui.nvim',
  },
  lazy = false,
  keys = {
    { '\\', ':Neotree reveal<CR>', desc = 'NeoTree reveal', silent = true },
  },
  opts = {
    filesystem = {
      window = {
        mappings = {
          ['\\'] = 'close_window',
          -- Movement (k/l for up/down in tree)
          ['k'] = 'move_cursor_down',
          ['l'] = 'move_cursor_up',

          -- Enter directory / open file (was 'l' by default, now 'm')
          ['m'] = 'move_cursor_right',

          -- Navigate up to parent (was 'h' or backspace, now 'j')
          ['j'] = 'move_cursor_left',
        },
      },
    },
  },
}
