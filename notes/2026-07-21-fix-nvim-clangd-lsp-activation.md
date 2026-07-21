# Fix Clangd LSP Activation & CLI Compatibility ٩(◕‿◕｡)۶

*Date: 2026-07-21*

## Issue
`clangd` LSP was not activating for C/C++ repositories. The LSP log showed that `clangd` exited immediately upon startup with:
`clangd: Unknown command line argument '--malloc-trim'`

## Fix Details
1. **Removed Unsupported Flag:** Removed `--malloc-trim` from `vim.lsp.config('clangd', { ... })` in `dot_config/nvim/lua/config/lsp.lua`.
2. **Added `--enable-config`:** Added `--enable-config` so `clangd` automatically reads project-level `.clangd` configuration files and custom compilation databases.
3. **Validated & Applied:** Applied via `chezmoi apply`, verified seamless `clangd` LSP client attachment and root directory discovery on C/C++ buffers.
