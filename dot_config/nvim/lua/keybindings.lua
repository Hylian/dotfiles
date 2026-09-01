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
--map('n', '<A-S-s>',       function() require('focus').split_nicely() end)
map('n', '<A-S-s>',       function() require('focus').split_command('l') end)
map('n', '<A-S-e>',       function() require('focus').focus_equalise() end)
map('n', '<A-S-r>',       function() require('focus').focus_autoresize() end)
--map('n', '<A-S-f>',       function() require('focus').focus_max_or_equal() end)
map('n', '<A-S-f>',       function() require('maximize').toggle() end)
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
map('n', '<A-S-0>',       "10gt")

map('n', '<A-!>',         "1gt")
map('n', '<A-@>',         "2gt")
map('n', '<A-#>',         "3gt")
map('n', '<A-$>',         "4gt")
map('n', '<A-%>',         "5gt")
map('n', '<A-^>',         "6gt")
map('n', '<A-&>',         "7gt")
map('n', '<A-*>',         "8gt")
map('n', '<A-(>',         "9gt")
map('n', '<A-)>',         "10gt")

map('n', '<A-S-`>',       "g<Tab>")
map('n', '<A-~>',         "g<Tab>")
map('n', '<C-A-S-Left>',  ":-tabmove<CR>")
map('n', '<C-A-S-Right>', ":+tabmove<CR>")
map('n', '<leader>t',     ":Tabby jump_to_tab<CR>")
map('n', '<leader>w',     ":Tabby pick_window<CR>")
map('n', '<leader>nh',    "<cmd>Noice history<CR>")
map('n', '<leader>nl',    "<cmd>Noice last<CR>")
map('n', '<leader>ne',    "<cmd>Noice errors<CR>")
map('n', '<leader>nd',    "<cmd>Noice dismiss<CR>")
map('n', '\\',            ":NvimTreeFindFileToggle<CR>")

map('n', '<C-p>',     ":set paste<CR>o<ESC>p:set nopaste<CR>")
map('n', '<C-S-p>',   ":set paste<CR>O<ESC>p:set nopaste<CR>")
map('n', '<CR>',      ":noh<CR><CR>")
-- Switch between source and header file (clangd LSP with filesystem fallback)
local function fallback_switch_source_header()
  local file = vim.api.nvim_buf_get_name(0)
  if file == '' then return false end

  local ext = vim.fn.fnamemodify(file, ':e'):lower()
  local dir = vim.fn.fnamemodify(file, ':h')
  local stem = vim.fn.fnamemodify(file, ':t:r')

  local source_exts = { 'c', 'cc', 'cpp', 'cxx', 'm', 'mm', 's' }
  local header_exts = { 'h', 'hh', 'hpp', 'hxx', 'inc' }

  local is_source = vim.tbl_contains(source_exts, ext)
  local is_header = vim.tbl_contains(header_exts, ext)
  if not is_source and not is_header then return false end

  local target_exts = is_source and header_exts or source_exts

  -- 1. Same directory
  local root = vim.fn.fnamemodify(file, ':r')
  for _, e in ipairs(target_exts) do
    local target = root .. '.' .. e
    if vim.uv.fs_stat(target) then
      vim.cmd.edit(target)
      return true
    end
  end

  -- 2. Sister include/src directories
  local candidate_dirs = {}
  if is_source then
    table.insert(candidate_dirs, (dir:gsub('/src$', '/include')))
    table.insert(candidate_dirs, (dir:gsub('/src$', '/inc')))
    table.insert(candidate_dirs, dir .. '/../include')
    table.insert(candidate_dirs, dir .. '/../inc')
    table.insert(candidate_dirs, dir .. '/include')
  else
    table.insert(candidate_dirs, (dir:gsub('/include$', '/src')))
    table.insert(candidate_dirs, (dir:gsub('/inc$', '/src')))
    table.insert(candidate_dirs, dir .. '/../src')
    table.insert(candidate_dirs, dir .. '/src')
  end

  for _, cdir in ipairs(candidate_dirs) do
    for _, e in ipairs(target_exts) do
      local target = cdir .. '/' .. stem .. '.' .. e
      if vim.uv.fs_stat(target) then
        vim.cmd.edit(vim.fs.normalize(target))
        return true
      end
    end
  end

  return false
end

local function switch_source_header()
  local bufnr = vim.api.nvim_get_current_buf()
  local clients = vim.lsp.get_clients({ bufnr = bufnr, name = 'clangd' })
  if #clients > 0 then
    local client = clients[1]
    local method = 'textDocument/switchSourceHeader'
    local params = vim.lsp.util.make_text_document_params(bufnr)
    client:request(method, params, function(err, result)
      if err then
        vim.notify(tostring(err), vim.log.levels.ERROR)
        return
      end
      if not result or result == '' then
        if not fallback_switch_source_header() then
          vim.notify('Corresponding source/header file cannot be determined', vim.log.levels.WARN)
        end
        return
      end
      vim.cmd.edit(vim.uri_to_fname(result))
    end, bufnr)
    return
  end

  if vim.fn.exists(':LspClangdSwitchSourceHeader') == 2 then
    vim.cmd('LspClangdSwitchSourceHeader')
    return
  end

  if vim.fn.exists(':ClangdSwitchSourceHeader') == 2 then
    vim.cmd('ClangdSwitchSourceHeader')
    return
  end

  if not fallback_switch_source_header() then
    vim.notify('No corresponding header or source file found', vim.log.levels.WARN)
  end
end

map('n', 'gd',        "<cmd>lua require('fzf-lua').lsp_definitions()<CR>")
map('n', 'gD',        "<cmd>lua require('fzf-lua').lsp_definitions({ jump1_action = require('fzf-lua.actions').file_tabedit, actions = { enter = require('fzf-lua.actions').file_tabedit } })<CR>")
map('n', 'gr',        "<cmd>lua require('fzf-lua').lsp_references()<CR>")
map('n', 'gh',        switch_source_header, { desc = "Switch between header and source" })
map('n', '[',         switch_source_header, { desc = "Switch between header and source" })
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
