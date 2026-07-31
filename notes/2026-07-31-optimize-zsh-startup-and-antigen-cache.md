# Optimize Zsh Startup, Antigen Caching & FZF Widget Portability ٩(◕‿◕｡)۶

*Date: 2026-07-31*

## Summary

1. **Fixed Permanent `antigen apply` Startup Loop (`antigen cache-gen`):**
   - In [dot_zshrc.tmpl](../dot_zshrc.tmpl), added `antigen cache-gen` immediately after `antigen apply` inside the cache invalidation block (`if [[ ! -f "$ANTIGEN_INIT" || "$HOME/.zshrc" -nt "$ANTIGEN_INIT" ]]`).
   - Previously, modifying `.zshrc` triggered `antigen apply` without generating a new `~/.antigen/init.zsh` cache file, trapping all subsequent terminal launches in a permanent **~1.5-second** `antigen apply` rebuild loop.
   - Now, updating `.zshrc` regenerates `~/.antigen/init.zsh` automatically on the first run, bringing subsequent warm `.zshrc` startup time down to **`20ms`** (**`80ms`** total interactive boot including `/etc/zshrc` and Starship).
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
3. Benchmarked `zsh -c 'source ~/.zshrc'`: completed in **`20ms`** (warm cache).
4. Benchmarked interactive startup (`zsh -i -c 'exit'`): completed in **`80ms`** (down from **`130ms`**, a **38.5% reduction** in total interactive startup latency).
