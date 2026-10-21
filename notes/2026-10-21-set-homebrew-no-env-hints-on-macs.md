# Set $HOMEBREW_NO_ENV_HINTS=1 on macOS

*Date: 2026-10-21*
*Host: `shined-mac` (macOS Apple Silicon Client)*

## Context & Problem
When executing Homebrew commands on macOS clients (`shined-mac`, `baumkuchen`, `midnight-future`), Homebrew regularly prints informational hints proposing environment variables to configure or tune Homebrew's behavior. To eliminate these repetitive warnings and maintain clean, concise terminal output, Rachel requested setting `$HOMEBREW_NO_ENV_HINTS=1` on macOS machines.

## Implementation Details
1. **Guarded Environment Variable in [dot_zshenv.tmpl](../dot_zshenv.tmpl):**
   - Added `export HOMEBREW_NO_ENV_HINTS=1` guarded by `{{ if eq .chezmoi.os "darwin" -}}`.
   - Placed in `~/.zshenv` so the variable is exported across all Zsh instances on macOS—including interactive shells, non-interactive subshells, scripts, and commands spawned by editors or launchers—while introducing zero overhead or extraneous lines on Linux machines (`shined`, `eterna`).
2. **Validation & Compilation:**
   - Verified template rendering and syntax via `chezmoi diff` and `chezmoi execute-template < dot_zshenv.tmpl | zsh -n`.
   - Applied cleanly via `chezmoi apply --no-pager` and recompiled wordcode via `zcompile ~/.zshenv`.
   - Verified that both interactive (`zsh -i -c`) and non-interactive (`zsh -c`) subshells report `HOMEBREW_NO_ENV_HINTS=1`.
