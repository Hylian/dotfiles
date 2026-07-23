# Deduplicate Zsh precmd and chpwd Zellij Hooks ٩(◕‿◕｡)۶

*Date: 2026-07-23*

## Context

`chpwd` and `precmd` were both firing duplicate calls to `_zellij_osc7_cwd` and `_zellij_refresh_git_branch` on every directory change. Because `precmd` runs automatically right before every prompt (including after `cd` finishes), registering `_zellij_osc7_cwd` and `_zellij_refresh_git_branch` in `precmd_functions` alone guarantees single-execution coverage per prompt without duplication.

## Clean Hook Division

- **`precmd_functions`:** `_zellij_osc7_cwd` and `_zellij_refresh_git_branch` (emits ANSI OSC 7 and triggers git status rerun once per prompt right before drawing).
- **`chpwd_functions`:** `zellij_tab_name_update` (renames Zellij tab when `$PWD` changes).

## Verification

1. `chezmoi execute-template < dot_zshrc.tmpl | zsh -n` passed syntax check.
2. `chezmoi diff` confirmed removal of double-execution.
3. `chezmoi apply` completed without error.
