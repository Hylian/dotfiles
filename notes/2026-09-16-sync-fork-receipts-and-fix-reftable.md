# Software Fork Fleet Sync & Git Reftable Compatibility

**Date:** 2026-09-16  
**Context:** Context priming on Linux workstation `shined`, software fork submodule initialization, and resolving Git `reftable` backend breakages in Neovim `lazy.nvim`.

## Observations & Root Causes

1. **Software Fork Submodule Tracking:**
   - Git submodules (`software/zellij` and `software/zjstatus`) were added in `Hylian/dotfiles` on macOS clients.
   - On `shined`, `~/.local/bin/zellij` was already running `6384f04c` (matching `software/zellij` submodule HEAD).
   - In `~/software/zjstatus`, commit `de9e22e7` (`fix(command): seed new tab command widgets from shared /tmp cache on frame 0`) had been committed on 2026-09-10 and installed to `~/.config/zellij/plugins/zjstatus.wasm`, but was ahead of `origin/hylian/autorender` (`8a038754`).
   - Running `manage-forks.sh check` previously exited 1 due to uninitialized submodules and missing machine receipts in `~/.local/state/builds/`.

2. **Submodule Cloning in Non-Interactive Subshells:**
   - Non-interactive subshells do not inherit `SSH_AUTH_SOCK` unless sourced through interactive rc files.
   - When attempting to clone submodules via `git@github.com`, Git blocked waiting for an SSH key passphrase.

3. **Neovim Treesitter Version Compatibility:**
   - The dotfiles were updated to `branch = 'main'` for `nvim-treesitter` to support Neovim 0.12+ query predicates on macOS clients.
   - On `shined` (running Neovim 0.11.0 without `tree-sitter-cli`), `nvim-treesitter`'s `main` branch is unsupported.

4. **Git Reftable Backend & `lazy.nvim` Lockfile Failures:**
   - On newer Linux systems with Git 2.45+, repositories cloned with `reftable` backend store references in reftables instead of loose files, leaving `$GIT_DIR/HEAD` with the `ref: refs/heads/.invalid` sentinel.
   - `lazy.nvim` inspects `.git/HEAD` and `.git/refs/heads/` directly on the filesystem. When encountering `.invalid`, `info.commit` returned `nil`, crashing `lock.lua` (`commit is nil`).

## Solutions

1. **Manage-Forks Hardening ([manage-forks.sh](../.agents/skills/chez/scripts/manage-forks.sh)):**
   - Automatically discovers and exports `SSH_AUTH_SOCK` from `$XDG_RUNTIME_DIR/zellij-env/ssh-auth-sock` when running in subshells.
   - Configured `cmd_sync` with `ssh -o BatchMode=yes` and automatic HTTPS fallback for GitHub forks.
   - Initialized submodules, updated `software/zjstatus` to `de9e22e7`, and recorded receipts via `manage-forks.sh record`.
   - Verified both forks report `✨ UP TO DATE` and `manage-forks.sh check` exits 0.

2. **Dynamic Treesitter Branch ([plugins/init.lua](../dot_config/nvim/lua/plugins/init.lua)):**
   - Set `branch = vim.fn.has('nvim-0.12') == 1 and 'main' or 'master'`.
   - Preserves `main` branch for Neovim 0.12+ while cleanly falling back to `master` with `nvim-treesitter.configs` on Neovim 0.11 hosts.

3. **Git Reftable Mitigation ([shared_config.tmpl](../dot_config/git/shared_config.tmpl)):**
   - Added `[init] defaultRefFormat = files` to shared Git configuration, guaranteeing all future tool/plugin clones use standard files backend.
   - Migrated existing reftable plugins (`LuaSnip`, `smart-splits.nvim`, `git-conflict.nvim`) via `git refs migrate --ref-format=files`.
   - Verified headless Neovim exits cleanly with code 0.
