local M = {}

-- Your other Neovim configuration code

-- Helper function to find git root
local function get_git_root()
  local git_root = vim.fn.systemlist('git rev-parse --show-toplevel')[1]
  if vim.v.shell_error == 0 then
    return git_root
  else
    return nil
  end
end

-- Autocommand to set the working directory on VimEnter
vim.api.nvim_create_autocmd({ 'VimEnter' }, {
  callback = function()
    local bufname = vim.fn.expand '%:p'
    local is_directory = vim.fn.isdirectory(bufname)

    -- If the buffer is a directory
    if is_directory == 1 then
      vim.cmd('cd ' .. bufname)
    else
      -- Check for git root directory
      local git_root = get_git_root()
      if git_root then
        vim.cmd('cd ' .. git_root)
      else
        -- If no git root, set to the directory of the file
        vim.cmd('cd ' .. vim.fn.expand '%:p:h')
      end
    end
  end,
})

return M
