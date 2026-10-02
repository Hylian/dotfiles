# AeroSpace `cmd-ctrl-enter` Cloudtop Remote Launcher (`rwc`) without Local Zellij Autostart

*Date: 2026-10-01*

## Context & Goal

On `shined-mac`, `cmd-enter` launches local Ghostty (with local Zellij autostart), while `cmd-shift-enter` launches Ghostty directly into the `rwd` remote workstation workflow without autolaunching a local Zellij session.

We wanted an analogous keybinding (`cmd-ctrl-enter`) that launches Ghostty directly into `cloudtop` via an `rwc` workflow (attaching/creating the `persist` Zellij session on the remote) without local Zellij autostart.

## Solution

1. **`rwc` Alias in Local `~/.config/zsh/galiases`:**
   - Defined `rwc` matching `rwd` with `-i 'zellij a -c persist options --on-force-close detach'` so it attaches to (or creates) the `persist` Zellij session on the remote machine.
   - Loaded conditionally by [dot_zshrc.tmpl](../dot_zshrc.tmpl) for interactive shells.
2. **AeroSpace Binding in [dot_config/aerospace/aerospace.toml.tmpl](../dot_config/aerospace/aerospace.toml.tmpl):**
   - Added `cmd-ctrl-enter` under `{{ if eq .chezmoi.hostname "shined-mac" -}}`:
     ```toml
     cmd-ctrl-enter = "exec-and-forget open -n /Applications/Ghostty.app --env ZELLIJ_NO_AUTOSTART=1 --args -e /bin/zsh -lic rwc"
     ```
   - Passes `ZELLIJ_NO_AUTOSTART=1` so local Zellij is bypassed.
   - Uses `/bin/zsh -lic` (login + interactive + command) to ensure full environment, `PATH`, and alias sourcing.
   - Retired the legacy `cmd-semicolon` binding (superseded by `cmd-shift-enter`).
3. **Skill & Workflow Refinements ([SKILL.md](../.agents/skills/chez/SKILL.md) & [.rgignore](../.rgignore)):**
   - Added `chezmoi status` / `chezmoi diff` inspection and automatic clean upstream application to Step 2 (**Context Priming on Activation**).
   - Added root [.rgignore](../.rgignore) excluding `software/` so `rg` searches dotfiles and notes instantaneously without scanning submodule source trees or multi-GB Rust `target/` directories, and documented `rg`-first and headless Lazy plugin sync (`nvim --headless "+Lazy! sync" +qa`) in Step 5 (**Modification Lifecycle**).
   - Documented the `~/.config/zsh/galiases` privacy boundary pattern in [SYSTEM.md](SYSTEM.md).
4. **Verification & Deployment:**
   - Applied configuration via `chezmoi apply --no-pager`.
   - Reloaded live AeroSpace configuration via `aerospace reload-config`.
   - Verified `rwc` alias resolution via `/bin/zsh -lic "which rwc"`.
