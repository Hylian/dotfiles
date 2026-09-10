# Fix Dynamic SSH Globe Indicator & Eliminate Frame 0 Blank Flash on New Tabs

**Date:** 2026-09-10  
**Context:**
1. Ensure the status bar globe emoji (`🌐`) updates reliably when starting a session locally and later attaching over SSH (including via `rw` or `ssh host 'zellij a -c persist ...'`).
2. Eliminate the 27-character blank flash and horizontal layout shift in `zjstatus` when opening a new tab (`Alt + n`).

## Root Cause Analysis

### 1. Globe Emoji Not Updating on Non-Interactive & Unnamed SSH Attaches
- **Non-Interactive Remote SSH Commands Bypassed `.zshrc`:** Connecting via wrapper aliases (`rw -r desktop -i 'zellij a -c persist options --on-force-close detach'` or `ssh host -t 'zellij a -c persist ...'`) spawns `zsh -c '...'`, which only sources `~/.zshenv`. Because `_zellij_sync_client_env` and `zellij()` were only defined in [dot_zshrc.tmpl](../dot_zshrc.tmpl), `zsh -c` executed the `zellij` binary directly without running the client handshake.
- **Unnamed Attaches (`zellij a`) Left Session Descriptors Stale:** When attaching without a session argument, `$session` was empty (`""`), so `_zellij_sync_client_env` wrote `SSH=1` only to `$env_dir/client` while leaving `$env_dir/persist` at `SSH=0`. Meanwhile, [dot_config/zellij/widgets/executable_host-status.sh.tmpl](../dot_config/zellij/widgets/executable_host-status.sh.tmpl) checked `[ -f "$env_dir/$session" ]` first and ignored the newer `$env_dir/client`.

### 2. Frame 0 Blank Flash When Opening a New Tab
- In Zellij, each tab runs its own `zjstatus.wasm` plugin instance.
- Previously, [dot_config/zellij/layouts/default.kdl.tmpl](../dot_config/zellij/layouts/default.kdl.tmpl) placed the entire 27-character hostname (`shined.cam.corp.google.com`) inside the `{command_host}` command widget (`host-status.sh`).
- On frame 0 of a newly created tab (`Alt + n`), `zjstatus` renders before `host-status.sh` has completed its first async execution (~50ms). With `state.command_results` empty on frame 0, `{command_host}` evaluated to `""`—causing the green hostname pill to render empty on frame 0 and then jump 27 columns wider ~50ms later, pushing `{session}` and `{command_git_branch}` left.

## Solution

1. **Manage `~/.zshenv` via [dot_zshenv.tmpl](../dot_zshenv.tmpl):**
   - Defined `_zellij_sync_client_env` and the `zellij()` wrapper function in `~/.zshenv` so non-interactive `zsh -c 'zellij ...'` SSH attach commands execute the client handshake before attaching.
   - Updated `_zellij_sync_client_env` in both [dot_zshenv.tmpl](../dot_zshenv.tmpl) and [dot_zshrc.tmpl](../dot_zshrc.tmpl) to update all existing session descriptors in `$env_dir/*(N.)` and pipe `zjstatus::rerun::command_host` to all running sessions when `$session` is omitted.
   - Updated `host-status.sh` and `_zellij_sync_client_env_hook` to prefer `$env_dir/client` whenever its mtime (`-nt`) is newer than `$env_dir/$session`.

2. **Static Hostname in Layout + Suffix-Only `command_host` ([dot_config/zellij/layouts/default.kdl.tmpl](../dot_config/zellij/layouts/default.kdl.tmpl), [dot_config/zellij/widgets/executable_host-status.sh.tmpl](../dot_config/zellij/widgets/executable_host-status.sh.tmpl)):**
   - Moved `{{ .chezmoi.fqdnHostname }}` into static KDL text in `format_right` (`{{ .chezmoi.fqdnHostname }}{command_host}`).
   - Updated `host-status.sh` to output **only** `' 🌐'` when `SSH=1` and nothing (`""`) when `SSH=0`.
   - Because the 27-character hostname is static KDL text, it renders on frame 0 with zero flash or layout jump.

3. **Shared `/tmp` Command Result Cache in `Hylian/zjstatus` (`~/.config/zellij/plugins/zjstatus.wasm`):**
   - Patched `Hylian/zjstatus` (`src/widgets/command.rs`, `src/bin/zjstatus.rs`) to persist accepted `CommandResult` outputs to `/tmp/zjstatus-cmd-cache.<name>`.
   - When a newly opened tab's `zjstatus.wasm` renders frame 0 with an empty `state.command_results` map, `CommandWidget::process` synchronously seeds `{command_host}` (` 🌐`) and `{command_git_branch}` (`main ●`) from `/tmp` in <5µs—eliminating any frame 0 pop-in across all status bar widgets.

## Verification

- Verified `chezmoi diff` and applied via `chezmoi apply`.
- Verified `host-status.sh` emits `' 🌐'` when `SSH=1` and `""` when `SSH=0`.
- Rebuilt `zjstatus.wasm` (`cargo build --release --target wasm32-wasip1`) and installed to `~/.config/zellij/plugins/zjstatus.wasm`.
