local M = {}

-- Function to get visible lines in the buffer
local function get_visible_lines()
  local topline = vim.fn.line 'w0'
  local botline = vim.fn.line 'w$'
  local lines = vim.api.nvim_buf_get_lines(0, topline - 1, botline, false)
  return lines, topline - 1
end

-- Function to find paths in lines
local function find_paths(lines)
  local paths = {}
  local path_pattern = 'file://%S+'

  for i, line in ipairs(lines) do
    for path in line:gmatch(path_pattern) do
      if path:sub(-1) == ')' then
        path = path:sub(1, -2)
      end

      local cwd = vim.fn.getcwd() .. '/'
      path = path:gsub('file://' .. cwd, ''):gsub('file://', '')

      table.insert(paths, { path = path, line = i })
    end
  end

  return paths
end

-- Function to add virtual text
local function add_virtual_text(paths, topline)
  for i, entry in ipairs(paths) do
    local virt_text = string.format(' [%s] ', i <= 9 and i or string.char(i + 86))
    vim.api.nvim_buf_set_extmark(0, vim.api.nvim_create_namespace 'path_namespace', topline + entry.line - 1, 0, {
      virt_text = { { virt_text, 'String' } },
      virt_text_pos = 'eol',
    })
  end
end

local function open_path(path)
  -- return vim.cmd(':e ' .. path:gsub('file://', ''))
  path = path:gsub('file://', '')
  local previous_bufnr = vim.fn.bufnr '%'
  if previous_bufnr and vim.api.nvim_buf_is_valid(previous_bufnr) then
    vim.api.nvim_set_current_buf(previous_bufnr)
    vim.cmd('vsplit ' .. path)
  else
    vim.cmd('vsplit ' .. path)
  end
end

-- Function to set keymaps
local function set_keymaps(paths)
  for i, entry in ipairs(paths) do
    local key = i <= 9 and tostring(i) or string.char(i + 86)

    local desc = string.format('Go to "%s"', entry.path)

    local function split_open()
      open_path(entry.path)
    end
    -- local desc = string.format('Go to "%s"', entry.path)
    vim.keymap.set('n', '<leader>gp' .. key, split_open, { buffer = true, noremap = true, silent = true, desc = desc })
    -- vim.keymap.set('n', '<leader>gp' .. key, split_open, { buffer = true, noremap = true, silent = true, desc = desc })
  end
end

local function parse_path(path)
  local file, line, col = path:match '([^:]+):(%d+):(%d+)$'
  return file, tonumber(line), tonumber(col)
end

local function add_to_qf_list(paths)
  local qf_list = {}
  for _, item in ipairs(paths) do
    local file, line, col = parse_path(item.path)
    if file and line and col then
      -- table.insert(qf_list, { filename = file, lnum = line, col = col, text = 'Found path' })
      local bufnr = vim.fn.bufnr(file, true)
      vim.fn.bufload(bufnr)
      table.insert(qf_list, { filename = file, lnum = line, col = col })
    end
  end

  -- Set the quickfix list
  vim.fn.setqflist(qf_list, 'r')

  -- Open the quickfix window to display the list
  -- vim.cmd 'copen'
  require('telescope.builtin').quickfix()
end

-- Main function to process the buffer
local function process_buffer()
  local lines, topline = get_visible_lines()
  local paths = find_paths(lines)
  -- add_virtual_text(paths, topline)
  add_to_qf_list(paths)
  -- set_keymaps(paths)
end

-- Function to clear virtual text and keymaps
local function clear()
  vim.api.nvim_buf_clear_namespace(0, vim.api.nvim_create_namespace 'path_namespace', 0, -1)
end

-- Setup command and keybindings
local function setup()
  -- vim.api.nvim_create_user_command('GoToPathsPrint', process_buffer, { desc = '[G]o to [P]ath. [Print] them' })
  vim.keymap.set('n', '<leader>gpp', process_buffer, { noremap = true, silent = true, desc = '[G]o to [P]ath. [Print] them' })
  vim.keymap.set('n', '<leader>gpr', clear, { noremap = true, silent = true, desc = 'Remove path keymaps and virtual text' })
end
setup()
return M
