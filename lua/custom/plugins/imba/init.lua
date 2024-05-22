local function treesitter()
  local parser_config = require('nvim-treesitter.parsers').get_parser_configs()
  parser_config.imba = {
    install_info = {
      -- Change this url to your grammar
      url = '~/.config/tree-sitter/tree-sitter-imba',
      branch = 'main',
      -- If you use an external scanner it needs to be included here
      files = { 'src/parser.c', 'src/scanner.cc' },
      generate_requires_npm = false,
      requires_generate_from_grammar = false,
    },
    -- The filetype you want it registered as
    filetype = 'imba',
  }
  vim.filetype.add {
    extension = {
      imba = 'imba',
    },
  }
  vim.treesitter.language.register('imba', 'imba')
end

treesitter()
require('Comment.ft').set('imba', '# %s')

return {}
