require("keybindings")
require("config.lazy")

vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.g.python3_host_prog = '/usr/bin/python3'
vim.opt.laststatus = 2
vim.opt.showmode = false
vim.opt.wrap = true
vim.opt.number = true
vim.opt.linebreak = true
vim.opt.showbreak = ''
vim.opt.textwidth = 0
vim.opt.wrapmargin = 0
vim.opt.showmatch = true
vim.opt.list = false
vim.opt.hlsearch = true
vim.opt.smartcase = true
vim.opt.ignorecase = true
vim.opt.incsearch = true
vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.cindent = true
vim.opt.cinkeys = '0{,0},0),0],:,0#,!^F,o,O,e'
vim.opt.cinoptions = 'g1,l1,h1,N-s,>2'
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.smarttab = true
vim.opt.softtabstop = 2
vim.opt.tabstop = 2
vim.opt.previewheight = 20
vim.opt.termguicolors = true
vim.opt.ruler = true
vim.opt.mouse = 'a'
vim.opt.clipboard = 'unnamedplus'
vim.opt.updatetime = 300
vim.opt.undolevels = 1000
vim.opt.backspace = 'indent,eol,start'
vim.opt.hidden = true
vim.opt.backup = false
vim.opt.writebackup = false
vim.opt.cmdheight = 0
vim.opt.colorcolumn = '80'
vim.opt.shortmess = 'ostTAcCWFSI'
vim.opt.timeoutlen = 250
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.background = 'dark'
vim.opt.scrolloff = 4
vim.o.showtabline = 2

vim.cmd('highlight LineNr ctermfg=blue')
--vim.cmd('highlight MsgArea guibg=#edeada guifg=#5c6a72')

if (os.getenv("SSH_TTY") ~= nil) or (os.getenv("NVIM_SSH_OVERRIDE") ~= nil) then
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
end

local function update_wayland_display()
  --if os.getenv("ZELLIJ") ~= nil and os.getenv("SSH_TTY") ~= nil then
  if vim.env.ZELLIJ ~= nil then
    local file = io.open("/tmp/wayland_display", "r")
    if file then
      local wayland_display = file:read("*l")
      file:close()
      if wayland_display then
        vim.env.WAYLAND_DISPLAY = wayland_display
        --print(wayland_display)
      end
    else
      print("Error: Could not open /tmp/wayland_display")
    end
  end
end

vim.api.nvim_create_autocmd({'BufEnter', 'FocusGained'}, {
  desc = 'Update WAYLAND_DISPLAY envvar',
  pattern = '*',
  callback = update_wayland_display,
})

vim.api.nvim_create_autocmd({'BufWinEnter'}, {
  desc = 'Cursor history across file opens',
  pattern = '*',
  command = 'silent! normal! g`"zv',
})

vim.api.nvim_create_autocmd("VimLeave", {
    desc = 'Unlock Zellij when leaving the window',
    pattern = "*",
    command = "silent !zellij action switch-mode normal"
})

require('config.everforest')
require('config.lualine')
require('config.toggleterm')
require('config.nvim-web-devicons')
require('config.treesitter')
require('config.lsp')
require('config.notify')
require('config.noice')
require('config.trim')
require('config.deadcolumn')
require('config.spider')
require('config.cmp')
require('config.tabby')
require('config.codecompanion')
require('config.focus')
require('config.telescope')

require('ibl').setup() --indent-blankline.nvim
require('mini.diff').setup()
