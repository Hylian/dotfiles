# Automatic Project Root Detection and Clangd Compilation Database Resolution

**Date:** 2026-09-04  
**Context:** Neovim / Clangd LSP integration for firmware and multi-repo / submodule trees.

## Problem & Motivation

When launching Neovim on a file from a deep subdirectory or submodule within a Git repository (e.g. `cd sidecar/pigweed/pw_sync && nvim interrupt_spin_lock.cc`), Clangd failed to load the compilation database (`compile_commands.json`).

### Root Cause Analysis

1. **Process Working Directory Mismatch:**
   - In `.clangd` configuration files, `CompilationDatabase` is frequently specified as a relative path (e.g. `CompileFlags: CompilationDatabase: ".compile_commands/..."`).
   - Clangd evaluates relative `CompilationDatabase` paths against its process working directory.
   - When Neovim was launched from a subdirectory, Neovim's `pwd` was that subdirectory, and Clangd inherited that subdirectory as its working directory. Thus, Clangd failed to resolve `.compile_commands/...`.

2. **LSP Root Detection Stopping Prematurely:**
   - Neovim 0.11's default `root_markers` for `clangd` included `.clang-format` and `.clang-tidy`.
   - Submodules (such as `pigweed`) and subdirectories often contain localized `.clang-format`, `.clang-tidy`, or submodule `.git` files.
   - `vim.fs.root` stopped ascending at the first marker found in the submodule rather than continuing upward to the true project root where `compile_commands.json` lives.
   - Clangd only searches parent directories up to its declared `rootUri`, meaning it never inspected the parent directory containing the actual compilation database.

## Solution

### 1. Hierarchical Root Discovery (`lua/config/root.lua`)

Implemented [dot_config/nvim/lua/config/root.lua](../dot_config/nvim/lua/config/root.lua) with hierarchical priority:
1. **Compilation Database / Clangd Config:** Upward search for `compile_commands.json`, `.compile_commands`, or `.clangd`.
2. **Build Output Databases:** Upward search for `build/compile_commands.json` or `out/compile_commands.json`.
3. **Git Superproject / Worktree:** Queries `git rev-parse --show-superproject-working-tree` (looping up through nested submodules to the outermost parent) and `--show-toplevel`.
4. **Standard Project Markers:** Falls back to `.git`, `Cargo.toml`, `pyproject.toml`, or `package.json`.
5. **In-Memory Cache:** Memoizes resolved roots per directory (`root_cache`) for sub-microsecond subsequent lookups without extra subprocess forks.

### 2. Clangd Dynamic Root & Process Working Directory (`lua/config/lsp.lua`)

Configured `clangd` in [dot_config/nvim/lua/config/lsp.lua](../dot_config/nvim/lua/config/lsp.lua) with a dynamic `root_dir` function:
```lua
root_dir = function(bufnr, on_dir)
  local fname = vim.api.nvim_buf_get_name(bufnr)
  local path = (fname ~= '') and vim.fs.dirname(fname) or vim.fn.getcwd()
  local root = root_util.find_project_root(path)
  if root and root ~= '' and root ~= vim.fn.getcwd() then
    vim.fn.chdir(root)
  end
  on_dir(root)
end
```
When `clangd` starts, Neovim's `chdir` is updated to the project root, ensuring Clangd spawns with `Working directory = <project_root>` and receives the authentic project root as `rootUri`.

### 3. Editor Auto-Rooting (`init.lua.tmpl`)

Hooked `require('config.root').setup()` into `VimEnter` and `BufReadPost` in [dot_config/nvim/init.lua.tmpl](../dot_config/nvim/init.lua.tmpl) to ensure Neovim's `:pwd`, fuzzy pickers (`fzf-lua`), and Zellij pane spawning (`<A-s>`, `<A-n>`) consistently operate from the project root.

## Verification

1. Tested launching Neovim from `sidecar-google/pigweed/pw_sync`:
   - `Neovim getcwd()` automatically resolved to `/usr/local/google/home/shined/sidecar-google`.
   - `clangd` spawned with `Working directory: /usr/local/google/home/shined/sidecar-google`.
   - Verified via LSP logs that `.clangd` loaded cleanly and `CompilationDatabase` was resolved.
2. Verified syntax and startup via `nvim --headless`.
