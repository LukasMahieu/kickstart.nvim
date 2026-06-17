return {
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    lazy = false,
    opts = {
      ensure_installed = {
        'bash',
        'css',
        'diff',
        'html',
        'javascript',
        'json',
        'lua',
        'markdown',
        'python',
        'svelte',
        'typescript',
        'vim',
        'vimdoc',
      },
      auto_install = true,
      highlight = {
        enable = true,
      },
    },
  },
}
