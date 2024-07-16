local function map(mode, combo, mapping, opts)
  local options = {noremap = true}
  if opts then
    options = vim.tbl_extend('force', options, opts)
  end
  vim.api.nvim_set_keymap(mode, combo, mapping, options)
end

vim.g.mapleader = ',' -- change the <leader> key to be comma

map('n', '<CR>',     ":noh<CR><CR>", {noremap = true})
map('n', 'gd',       "<cmd>lua require('fzf-lua').lsp_definitions()<CR>")
map('n', 'gr',       "<cmd>lua require('fzf-lua').lsp_references()<CR>")
map('n', ']',        "<cmd>lua require('fzf-lua').lsp_finder()<CR>")
map('n', '{',        "<cmd>lua require('fzf-lua').lsp_live_workspace_symbols()<CR>")
map('n', '}',        "<cmd>lua require('fzf-lua').lsp_document_symbols()<CR>")
map('n', '[',        "<cmd>:ClangdSwitchSourceHeader<CR>")
map('n', '<TAB>',    "<cmd>:ToggleDiag<CR>")
map('n', '<silent>', "gb :BufferLinePick<CR>")
map('n', '<C-A-1>',  "<Cmd>BufferLineGoToBuffer 1<CR>")
map('n', '<C-A-2>',  "<Cmd>BufferLineGoToBuffer 2<CR>")
map('n', '<C-A-3>',  "<Cmd>BufferLineGoToBuffer 3<CR>")
map('n', '<C-A-4>',  "<Cmd>BufferLineGoToBuffer 4<CR>")
map('n', '<C-A-5>',  "<Cmd>BufferLineGoToBuffer 5<CR>")
map('n', '<C-A-6>',  "<Cmd>BufferLineGoToBuffer 6<CR>")
map('n', '<C-A-7>',  "<Cmd>BufferLineGoToBuffer 7<CR>")
map('n', '<C-A-8>',  "<Cmd>BufferLineGoToBuffer 8<CR>")
map('n', '<C-A-9>',  "<Cmd>BufferLineGoToBuffer 9<CR>")
