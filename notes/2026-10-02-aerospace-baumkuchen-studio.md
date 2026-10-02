# AeroSpace `cmd-shift-enter` Remote `studio` Launcher on `baumkuchen`

*Date: 2026-10-02*

## Context & Goal

On `baumkuchen`, we want `cmd-shift-enter` to launch a Ghostty instance that SSHs directly into the `studio` SSH alias and attaches to (or creates) the `persist` Zellij session on the remote without autolaunching a local Zellij session.

## Solution

- Added an `{{- else if eq .chezmoi.hostname "baumkuchen" -}}` branch in [dot_config/aerospace/aerospace.toml.tmpl](../dot_config/aerospace/aerospace.toml.tmpl):
  ```toml
  cmd-shift-enter = "exec-and-forget open -n /Applications/Ghostty.app --env ZELLIJ_NO_AUTOSTART=1 --args -e /bin/zsh -lic \"ssh -t studio 'zellij a -c persist options --on-force-close detach'\""
  ```
- Passes `ZELLIJ_NO_AUTOSTART=1` so local Zellij is skipped in `.zshrc`.
- Uses `/bin/zsh -lic` for full login + interactive environment and `ssh -t` for remote PTY allocation with `zellij a -c persist options --on-force-close detach`.
- Verified rendered TOML output for `baumkuchen` via `chezmoi execute-template --override-data '{"chezmoi":{"hostname":"baumkuchen"}}'`.
