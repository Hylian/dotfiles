--local vimrc = vim.fn.stdpath("config") .. "/vimrc.vim"
--vim.cmd.source(vimrc)

require("keybindings")

require("config.lazy");
require("lazy").setup("plugins")

vim.opt.laststatus = 2
vim.opt.showmode = false
vim.opt.wrap = true
vim.opt.number = true
vim.opt.linebreak = true
vim.opt.showbreak = '⤶'
vim.opt.textwidth = 0
vim.opt.wrapmargin = 0
vim.opt.showmatch = true
vim.opt.list = false
vim.opt.hlsearch = true
vim.opt.smartcase = true
vim.opt.ignorecase = true
vim.opt.incsearch = true
vim.opt.autoindent = true
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.smartindent = true
vim.opt.smarttab = true
vim.opt.softtabstop = 2
vim.opt.tabstop = 4
vim.opt.previewheight = 20
vim.opt.termguicolors = true
vim.opt.ruler = true
vim.opt.mouse = 'a'
vim.opt.clipboard = 'unnamedplus'
vim.opt.updatetime = 300
vim.opt.undolevels = 1000
vim.opt.backspace = 'indent,eol,start'
vim.opt.termguicolors = true
vim.opt.hidden = true
vim.opt.backup = false
vim.opt.writebackup = false
vim.opt.cmdheight = 0
vim.opt.colorcolumn = '80'
vim.opt.shortmess = 'ostTAcCWFSI'
vim.opt.timeoutlen = 0
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.background = 'light'

vim.g.bufferline_echo = 0
vim.g.python3_host_prog = '/usr/bin/python3'

vim.cmd('highlight LineNr ctermfg=blue')
vim.cmd('highlight MsgArea guibg=#edeada guifg=#5c6a72')

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

require('mason').setup()
require('lspconfig').clangd.setup{}
require('toggle_lsp_diagnostics').init({ start_on = false })
require('config.lualine')
require('config.toggleterm')
require('config.nvim-web-devicons')
require('config.everforest')
require('everforest').load()
require('treesitter-context').setup{
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
require('notify').setup({
    fps = 24,
    render = "compact",
    max_width = 80,
    minimum_width = 10,
    stages = "fade",
    timeout = 300,
})
require('noice').setup({
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
require('trim').setup({
  -- if you want to ignore markdown file.
  -- you can specify filetypes.
  ft_blocklist = {"markdown"},

  patterns = {},

  -- if you want to disable trim on write by default
  trim_on_write = true,

  -- highlight trailing spaces
  highlight = true,
  highlight_bg = '#ffe7de',
  highlight_ctermbg = 'red',
})
