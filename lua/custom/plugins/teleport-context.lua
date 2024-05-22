-- Autocmd to customize the Telescope previewer
vim.api.nvim_create_autocmd('User', {
  pattern = 'TelescopePreviewerLoaded',
  callback = function()
    -- Enable Treesitter context
    vim.cmd 'TSContextEnable'
  end,
})

return {}
