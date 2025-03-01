require('toggle_lsp_diagnostics').init({ start_on = false })

require('mason').setup({
})

local capabilities = require('cmp_nvim_lsp').default_capabilities()
require('lspconfig').clangd.setup{}
require('lspconfig').rust_analyzer.setup{}
