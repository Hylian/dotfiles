local function map(mode, combo, mapping, opts)
  local options = {noremap = true, silent = true}
  if opts then
    options = vim.tbl_extend('force', options, opts)
  end
  vim.keymap.set(mode, combo, mapping, options)
end

vim.g.mapleader = ';'
vim.g.maplocalleader = ';;'

-- Zellij-related Bindings
local function zellij(...)
  vim.system({ 'zellij', 'action', ... })
end

map('n', '<A-h>',         function() require('smart-splits').move_cursor_left() end)
map('n', '<A-j>',         function() require('smart-splits').move_cursor_down() end)
map('n', '<A-k>',         function() require('smart-splits').move_cursor_up() end)
map('n', '<A-l>',         function() require('smart-splits').move_cursor_right() end)

map('n', '<A-C-h>',       function() require('smart-splits').resize_left() end)
map('n', '<A-C-j>',       function() require('smart-splits').resize_down() end)
map('n', '<A-C-k>',       function() require('smart-splits').resize_up() end)
map('n', '<A-C-l>',       function() require('smart-splits').resize_right() end)

map('n', '<A-Left>',      function() zellij('go-to-previous-tab') end)
map('n', '<A-Right>',     function() zellij('go-to-next-tab') end)
map('n', '<A-S-h>',       function() zellij('move-pane', 'left') end)
map('n', '<A-S-l>',       function() zellij('move-pane', 'right') end)
map('n', '<A-S-j>',       function() zellij('move-pane', 'down') end)
map('n', '<A-S-k>',       function() zellij('move-pane', 'up') end)
map('n', '<A-C-Left>',    function() zellij('move-tab', 'left') end)
map('n', '<A-C-Right>',   function() zellij('move-tab', 'right') end)
map('n', '<A-S-[>',       function() zellij('previous-swap-layout') end)
map('n', '<A-S-]>',       function() zellij('next-swap-layout') end)
map('n', '<A-1>',         function() zellij('go-to-tab', '1') end)
map('n', '<A-2>',         function() zellij('go-to-tab', '2') end)
map('n', '<A-3>',         function() zellij('go-to-tab', '3') end)
map('n', '<A-4>',         function() zellij('go-to-tab', '4') end)
map('n', '<A-5>',         function() zellij('go-to-tab', '5') end)
map('n', '<A-6>',         function() zellij('go-to-tab', '6') end)
map('n', '<A-7>',         function() zellij('go-to-tab', '7') end)
map('n', '<A-8>',         function() zellij('go-to-tab', '8') end)
map('n', '<A-9>',         function() zellij('go-to-tab', '9') end)
map('n', '<A-0>',         function() zellij('go-to-tab', '10') end)
map('n', '<A-s>',         function() zellij('new-pane', '-d', 'right', '--cwd', vim.fn.getcwd()) end)
map('n', '<A-n>',         function() zellij('new-tab', '--cwd', vim.fn.getcwd()) end)
map('n', '<A-f>',         function() zellij('toggle-fullscreen') end)
map('n', '<A-S-s>',       "<cmd>lua require('focus').split_nicely()<CR>")
map('n', '<A-w>',         ":w<CR>")
map('n', '<A-d>',         ":q<CR>")
map('n', '<A-q>',         ":q<CR>")
map('n', '<A-S-q>',       ":q!<CR>")
map('n', '<A-Q>',         ":q!<CR>")
--map('n', '<A-]>',         ":tab split<CR>")
map('n', '<A-C-S-]>',       "<C-w>r")
map('n', '<A-S-n>',       ":$tabnew<CR>")
map('n', '<A-S-d>',       "<cmd>NvimTreeClose<CR><cmd>tabclose<CR>")
map('n', '<A-S-Left>',    ":tabp<CR>")
map('n', '<A-S-Right>',   ":tabn<CR>")
map('n', '<A-S-1>',       "1gt")
map('n', '<A-S-2>',       "2gt")
map('n', '<A-S-3>',       "3gt")
map('n', '<A-S-4>',       "4gt")
map('n', '<A-S-5>',       "5gt")
map('n', '<A-S-6>',       "6gt")
map('n', '<A-S-7>',       "7gt")
map('n', '<A-S-8>',       "8gt")
map('n', '<A-S-9>',       "9gt")
map('n', '<A-S-`>',       "g<Tab>")
map('n', '<C-A-S-Left>',  ":-tabmove<CR>")
map('n', '<C-A-S-Right>', ":+tabmove<CR>")
map('n', '<leader>t',     ":Tabby jump_to_tab<CR>")
map('n', '<leader>w',     ":Tabby pick_window<CR>")
map('n', '<A-S-f>',       "<cmd>lua require('maximize').toggle()<CR>")
map('n', '\\',            ":NvimTreeFindFileToggle<CR>")

map('n', '<C-p>',     ":set paste<CR>o<ESC>p:set nopaste<CR>")
map('n', '<C-S-p>',   ":set paste<CR>O<ESC>p:set nopaste<CR>")
map('n', '<CR>',      ":noh<CR><CR>")
map('n', 'gd',        "<cmd>lua require('fzf-lua').lsp_definitions()<CR>")
map('n', 'gr',        "<cmd>lua require('fzf-lua').lsp_references()<CR>")
map('n', ']',         "<cmd>lua require('fzf-lua').lsp_finder()<CR>")
map('n', '{',         "<cmd>lua require('fzf-lua').lsp_document_symbols()<CR>")
map('n', '\"',        "<cmd>lua require('fzf-lua').oldfiles({ cwd_only = true })<CR>")
map('n', '<C-S-\'>',  "<cmd>lua require('fzf-lua').oldfiles()<CR>")
map('n', '\'',        "<cmd>lua require('fzf-lua').files()<CR>")
--map('n', '\'',        "<cmd>lua require('fzf-lua').grep_curbuf()<CR>")
--map('n', '\"',        "<cmd>lua require('fzf-lua').grep_project()<CR>")
--map('n', '<C-\'>',    "<cmd>lua require('fzf-lua').grep_cword()<CR>")

-- grug-far.nvim bindings
-- current cursor word, current file
map('n', '_', "<cmd>lua require('grug-far').open({ prefills = { search = vim.fn.expand('<cword>'), paths = vim.fn.expand('%') }})<CR>")
-- current visual selection, current file
map('v', '_', "<cmd>lua require('grug-far').with_visual_selection({ prefills = { search = vim.fn.expand('<cword>'), paths = vim.fn.expand('%') }})<CR>")
-- current cursor word
--map('n', '\"', "<cmd>lua require('grug-far').open({ prefills = { search = vim.fn.expand('<cword>') } })<CR>")
-- current visual selection
--map('v', '\"', "<cmd>lua require('grug-far').with_visual_selection()<CR>")

map('n', '[',         "<cmd>:ClangdSwitchSourceHeader<CR>")
map('n', '<TAB>',     "<cmd>:ToggleDiag<CR>")
map('n', '.',   "ms*")
map('n', ',',   "ms#")
map('n', '<Esc>', ":noh<CR>")

map('n', '<',      "<<", {noremap = true})
map('n', '>',      ">>", {noremap = true})

map('v', '<',      "<gv", {noremap = true})
map('v', '>',      ">gv", {noremap = true})

map('i', '', '<C-W>')
map('i', '<C-Del>', '<C-o>dw')

map('n', 'yp', '<cmd>lua vim.fn.setreg("\\\"", vim.fn.expand("%:p:h"))<CR>')

map('v', 'r', '"_dp')

-- Prompt navigation motions (Zellij scrollback & terminal buffers)
local function jump_prompt(backwards)
  local flags = backwards and 'bW' or 'W'
  local found = vim.fn.search([[❯]], flags)
  if found == 0 then
    vim.fn.search([[\v(^\s*[\$#%] |❯)]], flags)
  end
end

vim.keymap.set({ 'n', 'v', 'o' }, '<C-k>', function() jump_prompt(true) end, { desc = 'Jump to previous prompt' })
vim.keymap.set({ 'n', 'v', 'o' }, '<C-j>', function() jump_prompt(false) end, { desc = 'Jump to next prompt' })

vim.keymap.set(
	{ "n" },
	"M",
	"<cmd>lua require('maximize').toggle()<CR>",
	{ desc = "MaximizekToggle" }
)

vim.keymap.set(
	{ "n", "o", "x" },
	"W",
	"<cmd>lua require('spider').motion('w')<CR>",
	{ desc = "Spider-w" }
)
vim.keymap.set(
	{ "n", "o", "x" },
	"E",
	"<cmd>lua require('spider').motion('e')<CR>",
	{ desc = "Spider-e" }
)
vim.keymap.set(
	{ "n", "o", "x" },
	"B",
	"<cmd>lua require('spider').motion('b')<CR>",
	{ desc = "Spider-b" }
)
