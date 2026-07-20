# Fix Neovim & Clangd Multi-Day Session Lag ٩(◕‿◕｡)۶

*Date: 2026-07-20*

## Problem Diagnosis
Leaving Neovim open for multiple days resulted in severe editor lag and high resource consumption. Investigation identified multiple compounding factors:

1. **Clangd Memory Bloat & Glibc Fragmentation:**
   - On Linux/glibc, `clangd` allocates large volumes of transient memory during AST parsing and background indexing. Without explicit heap trimming, glibc retains freed heap arenas, causing memory footprint to expand monotonically over days.
   - Precompiled header preambles (PCH) were retained in RAM across all opened translation units.
   - Unbounded worker threads competed with the main editor thread during background indexing passes.

2. **Continuous Statusline & Background Polling:**
   - `lualine.lua` was configured with `refresh_time = 16` (60Hz continuous timer in Neovim's main event loop), driving 24/7 timer interrupts and event loop CPU wakeups.
   - `lazy.nvim` background checker was polling git repos periodically in background subprocesses.
   - Unbounded LSP log levels risked unbounded disk I/O and memory buffers.

## Resolutions Applied
- **Clangd Flag Hardening (`dot_config/nvim/lua/config/lsp.lua`):**
  - `--malloc-trim`: Instructs clangd to release unused heap memory back to the OS periodically.
  - `--pch-storage=memory`: Retains precompiled header preambles in RAM for peak navigation performance while letting malloc-trim handle memory reclamation.
  - `-j=8`: Bounds background indexing concurrency to 8 worker threads.
  - `--background-index-priority=low`: Prevents background indexing from interrupting interactive typing and editor responsiveness.
  - `--limit-results=100` / `--limit-references=1000`: Bounds LSP completion and reference payload sizes.
  - `--clang-tidy=false`: Prevents heavy per-keystroke AST matchers from running continuously.
- **LSP Logging (`lsp.lua`):**
  - `vim.lsp.set_log_level("warn")` to eliminate verbose RPC logging.
- **Statusline Optimization (`dot_config/nvim/lua/config/lualine.lua`):**
  - Removed `refresh_time = 16` and set standard `statusline = 500` interval to prevent idle timer loop churn.
- **Lazy Update Polling (`dot_config/nvim/lua/config/lazy.lua`):**
  - Disabled `checker.enabled` to eliminate periodic background git process spawning.
