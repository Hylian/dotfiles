# Optimize Zsh Startup, Antigen Caching & FZF Widget Portability ٩(◕‿◕｡)۶

*Date: 2026-07-31*

## Summary

1. **Removed Broken `antigen cache-gen` / `ANTIGEN_INIT` Static Caching & Restored Oh-My-Zsh Termsupport (`termsupport.zsh`):**
   - Investigated why Zellij pane CWD title synchronization broke after adding `antigen cache-gen` to `dot_zshrc.tmpl`.
   - Root cause: In Debian's Antigen 2.2.3 (`/usr/share/zsh-antigen/antigen.zsh`), `antigen cache-gen` does not capture dynamically bundled plugins unless `-antigen-cache-init` is explicitly invoked via `antigen init /path/to/file`. Calling `antigen cache-gen` after inline `antigen bundle` commands generated an empty `~/.antigen/init.zsh` file with zero sourced bundles.
   - On subsequent shell launches, `.zshrc` sourced the empty `~/.antigen/init.zsh` file, silently skipping Oh-My-Zsh (`termsupport.zsh`, which emits OSC 2 / OSC 1 terminal title sequences), `zsh-vi-mode`, `fzf`, `direnv`, and `zsh-autosuggestions`.
   - Additionally discovered that the existing `if [[ ! -f "$ANTIGEN_INIT" || ... ]]` check was dead code because `antigen apply` never creates `~/.antigen/init.zsh`; `.zshrc` was already running `antigen use oh-my-zsh` and bundle definitions directly on every boot in **~38ms** via Antigen's compiled wordcode cache (`.zwc`).
   - Fix: Removed the `ANTIGEN_INIT` wrapper and `antigen cache-gen` entirely from [dot_zshrc.tmpl](../dot_zshrc.tmpl) and deleted `/usr/local/google/home/shined/.antigen/init.zsh`. All bundles and Oh-My-Zsh libraries (`termsupport.zsh`, `omz_termsupport_precmd`) load reliably on every boot in **~60ms**.
2. **Lazy-Loaded `_zellij_track_git_dirty_cache`:**
   - In [dot_zshrc.tmpl](../dot_zshrc.tmpl), removed the synchronous `_zellij_track_git_dirty_cache` invocation from the `$ZELLIJ` initialization block.
   - Instead, `_zellij_track_git_dirty_cache` runs lazily on the first prompt inside `_zellij_refresh_git_branch()` or on directory change (`chpwd`), eliminating a synchronous **`5.6ms`** `git rev-parse` subprocess during `.zshrc` boot.
3. **Disabled Insecure `compaudit` Stat Loops (`ZSH_DISABLE_COMPFIX="true"`):**
   - In [dot_zshrc.tmpl](../dot_zshrc.tmpl), set `ZSH_DISABLE_COMPFIX="true"` before completion caching configuration to prevent Oh-My-Zsh from running redundant filesystem stat audits across `$fpath` during completion initialization.
4. **Fixed Hardcoded `fd` in FZF Directory Navigation:**
   - In [dot_config/zsh/widgets.tmpl](../dot_config/zsh/widgets.tmpl), replaced hardcoded `fd` commands in `cd-fzf-helper()` and `vim-fzf()` with `${FD_COMMAND:-fd}` to support Ubuntu/Debian hosts where `fd` is installed as `fdfind`.

## Verification

1. `chezmoi diff` and `chezmoi apply` completed cleanly.
2. Verified syntax with `zsh -n` across all templates.
3. Verified in interactive Zsh (`zsh -i -c 'print -l $precmd_functions'`) that `omz_termsupport_precmd`, `zvm_init`, `_direnv_hook`, `_zsh_autosuggest_start`, `_zellij_osc7_cwd`, and `_zellij_refresh_git_branch` are all registered and active.
4. Benchmarked `zsh -c 'source ~/.zshrc'`: completed in **`60ms`**.
5. Benchmarked interactive startup (`zsh -i -c 'exit'`): completed in **`120ms`** (down from **`130ms`** baseline, saving **10ms** of synchronous subprocess and stat loop overhead).
