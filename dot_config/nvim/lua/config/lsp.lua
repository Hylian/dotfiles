require('toggle_lsp_diagnostics').init({ start_on = false })

require('mason').setup({
  PATH = "append"
})

local capabilities = require('cmp_nvim_lsp').default_capabilities()
vim.lsp.config('*', {
  capabilities = capabilities,
})

vim.lsp.config('clangd', {
  cmd = {"clangd", "--header-insertion=never"}
})
vim.lsp.enable('clangd')

vim.lsp.enable('rust_analyzer')
