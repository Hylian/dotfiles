local vimrc = vim.fn.stdpath("config") .. "/vimrc.vim"
vim.cmd.source(vimrc)

function tmux_copy(reg)
  local clipboard = reg == '+' and 'c' or 'p'
  return function(lines)
    local s = table.concat(lines, '\n')
    vim.api.nvim_chan_send(2, osc52(clipboard, vim.base64.encode(s)))
  end
end

if os.getenv("TMUX") ~= nil then
  vim.cmd(
    "let g:clipboard = {" ..
       "'name': 'Tmux Clipboard'," ..
       "'copy': {" ..
          "'+': ['tmux', 'load-buffer', '-w', '-']," ..
          "'*': ['tmux', 'load-buffer', '-']," ..
        "}," ..
       "'paste': {" ..
          "'+': ['tmux', 'save-buffer', '-']," ..
          "'*': ['tmux', 'save-buffer', '-']," ..
       "}," ..
       "'cache_enabled': 1," ..
    "}")
elseif os.getenv("ZELLIJ") ~= nil then
  vim.cmd(
    "let g:clipboard = {" ..
       "'name': 'Zellij Clipboard'," ..
       "'copy': {" ..
          "'+': ['wl-copy', '-p', '--type', 'text/plain']," ..
          "'*': ['wl-copy', '-p', '--type', 'text/plain']," ..
        "}," ..
       "'paste': {" ..
          "'+': ['wl-paste']," ..
          "'*': ['wl-paste']," ..
       "}," ..
       "'cache_enabled': 1," ..
    "}")
  vim.api.nvim_create_autocmd('TextYankPost', {
    callback = function()
        local copy_to_unnamedplus = require('vim.ui.clipboard.osc52').copy('+')
        copy_to_unnamedplus(vim.v.event.regcontents)
        local copy_to_unnamed = require('vim.ui.clipboard.osc52').copy('*')
        copy_to_unnamed(vim.v.event.regcontents)
    end
  })
else
  if pcall(require, 'vim.ui.clipboard.osc52') then
    vim.g.clipboard = {
      name = 'OSC 52',
      copy = {
        ['+'] = require('vim.ui.clipboard.osc52').copy('+'),
        ['*'] = require('vim.ui.clipboard.osc52').copy('*'),
      },
      paste = {
        ['+'] = require('vim.ui.clipboard.osc52').paste('+'),
        ['*'] = require('vim.ui.clipboard.osc52').paste('*'),
      },
    }
  end
end

vim.api.nvim_create_autocmd({'BufWinEnter'}, {
  desc = 'return cursor to where it was last time closing the file',
  pattern = '*',
  command = 'silent! normal! g`"zv',
})

--require('config.bufferline')
require('config.lualine')
--require('config.gitsigns')
require('config.toggleterm')
require('config.nvim-web-devicons')
require('config.everforest')
require('everforest').load()
require'treesitter-context'.setup{
  enable = true, -- Enable this plugin (Can be enabled/disabled later via commands)
  max_lines = 3, -- How many lines the window should span. Values <= 0 mean no limit.
  min_window_height = 0, -- Minimum editor window height to enable context. Values <= 0 mean no limit.
  line_numbers = true,
  multiline_threshold = 20, -- Maximum number of lines to show for a single context
  trim_scope = 'outer', -- Which context lines to discard if `max_lines` is exceeded. Choices: 'inner', 'outer'
  mode = 'cursor',  -- Line used to calculate context. Choices: 'cursor', 'topline'
  -- Separator between context and content. Should be a single character string, like '-'.
  -- When separator is set, the context will only show up when there are at least 2 lines above cursorline.
  separator = nil,
  zindex = 20, -- The Z-index of the context window
  on_attach = nil, -- (fun(buf: integer): boolean) return false to disable attaching
}
require("notify").setup({
    fps = 60,
    render = "compact",
    minimum_width = 30,
    timeout = 1000,
})
require("noice").setup({
  lsp = {
    -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
    override = {
      ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
      ["vim.lsp.util.stylize_markdown"] = true,
      ["cmp.entry.get_documentation"] = true, -- requires hrsh7th/nvim-cmp
    },
  },
  -- you can enable a preset for easier configuration
  presets = {
    bottom_search = true, -- use a classic bottom cmdline for search
    command_palette = true, -- position the cmdline and popupmenu together
    long_message_to_split = true, -- long messages will be sent to a split
    inc_rename = false, -- enables an input dialog for inc-rename.nvim
    lsp_doc_border = false, -- add a border to hover docs and signature help
  },
  cmdline = {
    view = "cmdline",
  },
  routes = {
    {
      filter = {
        event = "msg_show",
        kind = "",
      },
      opts = { skip = true },
    },
    {
      filter = {
        event = "msg_show",
        find = "Pattern not found",
      },
      opts = { skip = true },
    },
    {
      filter = {
        event = "msg_show",
        kind = "search_count",
      },
      opts = { skip = true },
    },
  },
})
--require("git-conflict").setup({
--  default_mappings = {
--    ours = 'o',
--    theirs = 't',
--    none = '0',
--    both = 'b',
--    next = 'n',
--    prev = 'p',
--  },
--  default_commands = true, -- disable commands created by this plugin
--  disable_diagnostics = false, -- This will disable the diagnostics in a buffer whilst it is conflicted
--  list_opener = 'copen' -- command or function to open the conflicts list
--})
