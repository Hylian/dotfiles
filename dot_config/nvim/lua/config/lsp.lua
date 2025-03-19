require('toggle_lsp_diagnostics').init({ start_on = false })

require('mason').setup({
  PATH = "append"
})

local capabilities = require('cmp_nvim_lsp').default_capabilities()
require('lspconfig').clangd.setup{
  cmd = {"clangd", "--header-insertion=never"}
}
require('lspconfig').rust_analyzer.setup{}
