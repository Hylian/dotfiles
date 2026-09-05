require('toggle_lsp_diagnostics').init({ start_on = false })

-- Silence verbose LSP logging to prevent log file and memory bloat over days
vim.lsp.log.set_level(vim.log.levels.WARN)

require('mason').setup({
  PATH = "append"
})

local capabilities = require('cmp_nvim_lsp').default_capabilities()
vim.lsp.config('*', {
  capabilities = capabilities,
})

local root_util = require('config.root')

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
  },
  root_dir = function(bufnr, on_dir)
    local fname = vim.api.nvim_buf_get_name(bufnr)
    local path = (fname ~= '') and vim.fs.dirname(fname) or vim.fn.getcwd()
    local root = root_util.find_project_root(path)
    if root and root ~= '' and root ~= vim.fn.getcwd() then
      vim.fn.chdir(root)
    end
    on_dir(root)
  end,
})
vim.lsp.enable('clangd')

vim.lsp.enable('rust_analyzer')

