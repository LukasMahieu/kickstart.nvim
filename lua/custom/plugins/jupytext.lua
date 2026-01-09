return {
  {
    'GCBallesteros/jupytext.nvim',
    config = function()
      require('jupytext').setup {
        style = 'markdown', -- Convert .ipynb to markdown format
        output_extension = 'md', -- Use .md extension (creates paired files)
        force_ft = 'markdown', -- Force markdown filetype
        custom_language_formatting = {
          python = {
            extension = 'md',
            style = 'markdown',
            force_ft = 'markdown',
          },
        },
      }
      -- Set up PATH to include virtualenv
      vim.env.PATH = vim.fn.expand('~/.virtualenvs/neovim/bin') .. ':' .. vim.env.PATH
    end,
  },
  {
    'quarto-dev/quarto-nvim',
    dependencies = {
      'jmbuhr/otter.nvim',
      'nvim-treesitter/nvim-treesitter',
    },
    ft = { 'quarto', 'markdown' },
    config = function()
      require('quarto').setup {
        lspFeatures = {
          enabled = true,
          languages = { 'python', 'bash', 'r' },
          diagnostics = {
            enabled = true,
            triggers = { 'BufWritePost' },
          },
          completion = {
            enabled = true,
          },
        },
        codeRunner = {
          enabled = true,
          default_method = 'molten',
        },
      }
    end,
  },
}
