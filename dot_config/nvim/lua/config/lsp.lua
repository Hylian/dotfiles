require('toggle_lsp_diagnostics').init({ start_on = false })

-- Silence verbose LSP logging to prevent log file and memory bloat over days
vim.lsp.set_log_level("warn")

require('mason').setup({
  PATH = "append"
})

local capabilities = require('cmp_nvim_lsp').default_capabilities()
vim.lsp.config('*', {
  capabilities = capabilities,
})

vim.lsp.config('clangd', {
  cmd = {
    "clangd",
    "--enable-config",
    "--header-insertion=never",
    "--pch-storage=memory",
    "-j=8",
    "--background-index-priority=low",
    "--limit-results=100",
    "--limit-references=1000",
    "--clang-tidy=false",
  }
})
vim.lsp.enable('clangd')

vim.lsp.enable('rust_analyzer')

