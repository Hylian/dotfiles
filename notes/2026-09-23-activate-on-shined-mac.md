# Activate and Sync Dotfiles & Software Forks on `shined-mac`

**Date:** 2026-09-23  
**Context:** Session activation on macOS client `shined-mac`, applying accumulated dotfiles changes and upgrading local `zellij` and `zjstatus` builds from July 2026 to the current fleet submodule commits.

## Summary of Actions

1. **Dotfiles Synchronization (`chezmoi apply --no-pager`):**
   - Applied all pending dotfile templates on `shined-mac`, including [dot_cargo/config.toml.tmpl](../dot_cargo/config.toml.tmpl) (`jobs = 12`, `incremental = false`, omitting `sccache`), Ghostty scroll multipliers, Git `defaultRefFormat = files`, Zsh startup optimizations, and Neovim 0.12 configuration (`diffview`, `git-conflict`, `root`, `markdown` 80-col auto-wrap).

2. **Software Fork Submodules & Upstream Sync:**
   - Initialized `software/zellij` (`6384f04c`) and `software/zjstatus` (`de9e22e7`).
   - Fetched `de9e22e7` (`fix(command): seed new tab command widgets from shared /tmp cache on frame 0`) from the primary Linux workstation and pushed `de9e22e7` to `origin/hylian/autorender` on GitHub so all client hosts can fetch the submodule commit directly from GitHub.
   - Rebuilt and installed both forks on `shined-mac` via [manage-forks.sh](../.agents/skills/chez/scripts/manage-forks.sh):
     - `zjstatus` (`de9e22e7`) -> `~/.config/zellij/plugins/zjstatus.wasm` (with plugin cache pruned).
     - `zellij` (`6384f04c`) -> `~/.local/bin/zellij` (fresh inode + ad-hoc `codesign -s - --force`).
   - Recorded build receipts in `~/.local/state/builds/{zellij,zjstatus}.json` and updated `manage-forks.sh` to reset `cargo xtask` asset mutations in `software/zellij` after installation.

3. **macOS SSH Configuration (`~/.ssh/config`):**
   - Added `Host github.com` block with `IdentityFile ~/.ssh/id_ed25519`, `IdentitiesOnly yes`, and `AddKeysToAgent yes` (omitting `UseKeychain` since `/usr/local/bin/gnubby-ssh` rejects Apple-specific ssh_config directives).
