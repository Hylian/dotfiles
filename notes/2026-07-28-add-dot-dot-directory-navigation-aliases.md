# Added Directory Navigation Aliases (`..`, `...`, `....`) ٩(◕‿◕｡)۶

*Date: 2026-07-28*

## Symptom

Typing `..` at the zsh prompt returned `zsh: permission denied: ..`.

## Cause

In Unix/Linux, `..` is a directory (the parent directory entry). When typed at a shell prompt without an alias or `AUTO_CD`, the shell attempts to execute `execve("..")`. The kernel returns `EACCES` ("Permission denied") because directories are non-executable. In Zsh, `autocd` requires a trailing slash (`../`) or path components to auto-cd `..`.

## Fix & Antigen Findings

1. Bundled `antigen bundle robbyrussell/oh-my-zsh lib/directories.zsh` in `dot_zshrc.tmpl` so Antigen includes OMZ's `directories.zsh` in `~/.antigen/init.zsh` (`...` / `....` global aliases and directory functions).
2. Because OMZ's `directories.zsh` relies solely on `setopt auto_cd` (which fails on Linux for literal `..` without a trailing slash), explicit navigation aliases (`alias ..='cd ..'`) in `dot_config/zsh/aliases.tmpl` remain required.

## Verification

1. `chezmoi diff` and `chezmoi apply` completed cleanly.
2. Verified in Zsh that `..` navigates up to parent directory cleanly via alias and `...` works via OMZ global alias.
