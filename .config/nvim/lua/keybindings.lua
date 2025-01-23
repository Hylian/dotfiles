local function map(mode, combo, mapping, opts)
  local options = {noremap = true}
  if opts then
    options = vim.tbl_extend('force', options, opts)
  end
  vim.api.nvim_set_keymap(mode, combo, mapping, options)
end

vim.g.mapleader = ';'
vim.g.maplocalleader = ';;'

-- Zellij-related Bindings
map('n', '<A-h>',         ":ZellijNavigateLeft<CR>")
map('n', '<A-j>',         ":ZellijNavigateDown<CR>")
map('n', '<A-k>',         ":ZellijNavigateUp<CR>")
map('n', '<A-l>',         ":ZellijNavigateRight<CR>")
map('n', '<A-Left>',      "<cmd>lua vim.fn.system('zellij action go-to-previous-tab')<CR>")
map('n', '<A-Right>',     "<cmd>lua vim.fn.system('zellij action go-to-next-tab')<CR>")
map('n', '<A-S-h>',       "<cmd>lua vim.fn.system('zellij action move-pane left')<CR>")
map('n', '<A-S-l>',       "<cmd>lua vim.fn.system('zellij action move-pane right')<CR>")
map('n', '<A-S-j>',       "<cmd>lua vim.fn.system('zellij action move-pane down')<CR>")
map('n', '<A-S-k>',       "<cmd>lua vim.fn.system('zellij action move-pane up')<CR>")
map('n', '<A-C-Left>',    "<cmd>lua vim.fn.system('zellij action move-tab left')<CR>")
map('n', '<A-C-Right>',   "<cmd>lua vim.fn.system('zellij action move-tab right')<CR>")
map('n', '<A-S-[>',       "<cmd>lua vim.fn.system('zellij action previous-swap-layout')<CR>")
map('n', '<A-S-]>',       "<cmd>lua vim.fn.system('zellij action next-swap-layout')<CR>")
map('n', '<A-1>',         "<cmd>lua vim.fn.system('zellij action go-to-tab 1')<CR>")
map('n', '<A-2>',         "<cmd>lua vim.fn.system('zellij action go-to-tab 2')<CR>")
map('n', '<A-3>',         "<cmd>lua vim.fn.system('zellij action go-to-tab 3')<CR>")
map('n', '<A-4>',         "<cmd>lua vim.fn.system('zellij action go-to-tab 4')<CR>")
map('n', '<A-5>',         "<cmd>lua vim.fn.system('zellij action go-to-tab 5')<CR>")
map('n', '<A-6>',         "<cmd>lua vim.fn.system('zellij action go-to-tab 6')<CR>")
map('n', '<A-7>',         "<cmd>lua vim.fn.system('zellij action go-to-tab 7')<CR>")
map('n', '<A-8>',         "<cmd>lua vim.fn.system('zellij action go-to-tab 8')<CR>")
map('n', '<A-9>',         "<cmd>lua vim.fn.system('zellij action go-to-tab 9')<CR>")
map('n', '<A-0>',         "<cmd>lua vim.fn.system('zellij action go-to-tab 10')<CR>")
map('n', '<A-s>',         ":ZellijNewPaneVSplit<CR>")
--map('n', '<A-s>',         "<cmd>lua vim.fn.system('zellij action new-pane --cwd '..vim.fn.getcwd())<CR>")
map('n', '<A-n>',         ":ZellijNewTab<CR>")
map('n', '<A-f>',         "<cmd>lua vim.fn.system('zellij action toggle-fullscreen')<CR>")
map('n', '<A-S-s>',       "<cmd>lua require('focus').split_nicely()<CR>")
map('n', '<A-w>',         ":w<CR>")
map('n', '<A-d>',         ":q<CR>")
--map('n', '<A-]>',         ":tab split<CR>")
map('n', '<A-C-S-]>',       "<C-w>r")
map('n', '<A-S-n>',       ":$tabnew<CR>")
map('n', '<A-S-d>',       "<cmd>NvimTreeClose<CR><cmd>tabclose<CR>")
map('n', '<A-S-Left>',    ":tabp<CR>")
map('n', '<A-S-Right>',   ":tabn<CR>")
map('n', '<A-S-`>',       "g<Tab>")
map('n', '<C-A-S-Left>',  ":-tabmove<CR>")
map('n', '<C-A-S-Right>', ":+tabmove<CR>")
map('n', '<leader>t',     ":Tabby jump_to_tab<CR>")
map('n', '<leader>w',     ":Tabby pick_window<CR>")
map('n', '<A-S-f>',       "<cmd>lua require('maximize').toggle()<CR>")
map('n', '\\',            ":NvimTreeFindFileToggle<CR>")
map('n', '}',             ":CodeCompanionChat Toggle<CR>")
map('v', '}',             ":CodeCompanionChat Toggle<CR>")
map('v', 'ga',            "<cmd>CodeCompanionChat Add<cr>")

map('n', '<C-p>',     ":set paste<CR>o<ESC>p:set nopaste<CR>", {noremap = true, silent = true})
map('n', '<C-S-p>',   ":set paste<>O<ESC>p:set nopaste<CR>", {noremap = true, silent = true})
map('n', '<CR>',      ":noh<CR><CR>", {noremap = true})
map('n', 'gd',        "<cmd>lua require('fzf-lua').lsp_definitions()<CR>")
map('n', 'gr',        "<cmd>lua require('fzf-lua').lsp_references()<CR>")
map('n', ']',         "<cmd>lua require('fzf-lua').lsp_finder()<CR>")
map('n', '{',         "<cmd>lua require('fzf-lua').lsp_document_symbols()<CR>")
map('n', '|',         "<cmd>lua require('fzf-lua').oldfiles({ cwd_only = true })<CR>")
map('n', '<C-S-\\>',  "<cmd>lua require('fzf-lua').oldfiles()<CR>")
map('n', '_',         "<cmd>lua require('fzf-lua').files()<CR>")
--map('n', '\'',        "<cmd>lua require('fzf-lua').grep_curbuf()<CR>")
--map('n', '\"',        "<cmd>lua require('fzf-lua').grep_project()<CR>")
--map('n', '<C-\'>',    "<cmd>lua require('fzf-lua').grep_cword()<CR>")

-- grug-far.nvim bindings
-- current cursor word, current file
map('n', '\'', "<cmd>lua require('grug-far').open({ prefills = { search = vim.fn.expand('<cword>'), paths = vim.fn.expand('%') }})<CR>")
-- current visual selection, current file
map('v', '\'', "<cmd>lua require('grug-far').with_visual_selection({ prefills = { search = vim.fn.expand('<cword>'), paths = vim.fn.expand('%') }})<CR>")
-- current cursor word
map('n', '\"', "<cmd>lua require('grug-far').open({ prefills = { search = vim.fn.expand('<cword>') } })<CR>")
-- current visual selection
map('v', '\"', "<cmd>lua require('grug-far').with_visual_selection()<CR>")

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
