return {
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    lazy = false,
    config = function()
      -- Enable treesitter highlighting for these filetypes
      vim.api.nvim_create_autocmd('FileType', {
        pattern = { 'bash', 'diff', 'html', 'lua', 'markdown', 'python', 'vim' },
        callback = function(args)
          vim.treesitter.start(args.buf)
        end,
      })
    end,
  },
}
