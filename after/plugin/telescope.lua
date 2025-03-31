--- config outside of kickstart
vim.keymap.set('n', '<leader>fd', require('telescope.builtin').find_files)
vim.keymap.set('n', '<leader>en', function()
  require('telescope.builtin').find_files {
    cwd = vim.fn.stdpath 'config',
  }
end)
