# Added Directory Navigation Aliases (`..`, `...`, `....`) ٩(◕‿◕｡)۶

*Date: 2026-07-28*

## Symptom

Typing `..` at the zsh prompt returned `zsh: permission denied: ..`.

## Cause

In Unix/Linux, `..` is a directory (the parent directory entry). When typed at a shell prompt without an alias or `AUTO_CD`, the shell attempts to execute `execve("..")`. The kernel returns `EACCES` ("Permission denied") because directories are non-executable. In Zsh, `autocd` requires a trailing slash (`../`) or path components to auto-cd `..`.

## Fix

Added explicit directory navigation aliases to `dot_config/zsh/aliases.tmpl`:
- `alias ..='cd ..'`
- `alias ...='cd ../..'`
- `alias ....='cd ../../..'`

(Investigation confirmed OMZ's `lib/directories.zsh` relies solely on `setopt auto_cd` without an explicit `..` alias, which fails on Linux for literal `..` without a trailing slash. Explicit aliases in `aliases.tmpl` are clean, lightweight, and framework-independent.)

## Verification

1. `chezmoi diff` and `chezmoi apply` completed cleanly.
2. Verified in Zsh that `..` navigates up to parent directory cleanly.
