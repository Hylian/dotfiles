# Optimize Zsh Init & New Zellij Pane Creation Latency

**Date:** 2026-09-10  
**Context:** Reduce Zsh startup latency when spawning new Zellij panes/tabs (`Alt + s`, `Alt + n`).

## Profiling & Bottlenecks Identified (`zprof` & `strace`)

Baseline wall-clock startup (`zsh -i -c exit`) was **~140ms** (`0.14s`), with `.zshrc` internal function time (`zprof`) at **87.2ms**. Profiling with `zprof` and `strace -tt -f -e execve` exposed five distinct bottlenecks:

1. **Four Redundant `compinit` / `compaudit` Invocations (~73ms):**
   - `/etc/zsh/zshrc` ran `compinit` (without `-C`) prior to `~/.zshrc` because `google_zsh_flysolo` was unset in `~/.zshenv`.
   - Antigen called `compinit $ANTIGEN_COMPINIT_OPTS -d "$ANTIGEN_COMPDUMP"` twice (in `-antigen-env-setup` and `antigen apply`). Because `ANTIGEN_COMPINIT_OPTS` was unset, `compaudit` scanned `$fpath` 4 times (41.0ms).
   - Oh-My-Zsh's `oh-my-zsh.sh` invoked `compinit` again.
2. **Antigen Runtime Framework Parsing (~39ms):**
   - Even with all bundles already cloned on disk (`~/.antigen/bundles/...`), sourcing `antigen.zsh` and running `antigen use` / `antigen bundle` / `antigen apply` spent 39ms parsing arguments and checking bundle state.
3. **System Global RCS Subprocess Forks in Zellij Panes (~40ms):**
   - `/etc/zsh/zshrc` sourced `/etc/zsh/zshrc.d/skippy-zsh.sh`, synchronously forking `/usr/bin/skippy --check-bypass` on every new pane creation.
4. **Synchronous `starship prompt --continuation` Subprocess Fork:**
   - `starship init zsh` emitted `PROMPT2="$(/usr/local/bin/starship prompt --continuation)"` in double quotes, causing Zsh to synchronously fork `starship` during `.zshrc` load just to populate `PROMPT2`.
5. **Unused Oh-My-Zsh Libs & Startup Subprocesses:**
   - Sourcing all `$ZSH/lib/*.zsh` loaded unused libraries (`cli.zsh` 23KB, `diagnostics.zsh` 11KB, `bzr.zsh`, `vcs_info.zsh`) and ran `diff --color /dev/null /dev/null` and `ls --color /dev/null` (`theme-and-appearance.zsh`), despite `ls` being aliased to `eza` and Starship handling the prompt.
   - `_zellij_sync_client_env_hook` unconditionally forked `zellij pipe "zjstatus::rerun::command_host"` on initial pane boot (`_zellij_client_env_mtime == 0`).

## Solution

1. **Direct Bundle Fast-Path & Single `compinit -C` ([dot_zshrc.tmpl](../dot_zshrc.tmpl)):**
   - Set `ANTIGEN_COMPINIT_OPTS="-C"` and `DISABLE_LS_COLORS="true"`.
   - When `~/.antigen/bundles/{robbyrussell/oh-my-zsh,jeffreytse/zsh-vi-mode,zsh-users/zsh-autosuggestions}` exist on disk, `.zshrc` bypasses `antigen.zsh` parsing entirely: it sets `fpath`, runs `compinit -C -d "$ZSH_CACHE_DIR/zcompdump"` once, sources only the 8 essential Oh-My-Zsh lib files (`completion`, `directories`, `functions`, `git`, `history`, `key-bindings`, `misc`, `termsupport`), and sources the 4 active plugin scripts (`direnv`, `zsh-vi-mode`, `zsh-autosuggestions`, `fzf`). Automatically falls back to `antigen apply` on fresh hosts.
   - Added background `.zwc` compilation (`zcompile`) for `$ZSH_CACHE_DIR/zcompdump`, `~/.zshrc`, `~/.zshenv`, `~/.config/zsh/widgets`, and `~/.config/zsh/aliases`.
2. **Skip Redundant Global RCS Inside Zellij Panes ([dot_zshenv.tmpl](../dot_zshenv.tmpl)):**
   - Added `export google_zsh_flysolo=1` and `[[ -n "$ZELLIJ" ]] && setopt NO_GLOBAL_RCS` in `~/.zshenv` so new Zellij panes skip `/etc/zsh/zshrc` and `/usr/bin/skippy --check-bypass`.
3. **Single-Quote `PROMPT2` in Cached `starship.zsh` ([dot_zshrc.tmpl](../dot_zshrc.tmpl)):**
   - Post-processed `starship init zsh` cache generation to convert double-quoted `PROMPT2="$(...)"` into single-quoted `PROMPT2='$(...)'`, eliminating the synchronous `starship` fork at startup.
4. **Guard Initial `zellij pipe` in `_zellij_sync_client_env_hook` ([dot_zshrc.tmpl](../dot_zshrc.tmpl)):**
   - Only fork `command zellij pipe "zjstatus::rerun::command_host"` when `prev_mtime != 0` (live client connection change, not initial pane startup).

## Verification & Results

- **`.zshrc` execution time (`zprof`):** Reduced from **87.2ms -> 16.0ms** (>5x faster).
- **External subprocess forks (`strace -e execve`):** Reduced from 7 subprocesses (`skippy`, `cat`, `diff`, `ls`, `starship`, `zellij pipe`, `stty`) down to **1** (`stty susp undef`, <1ms).
- **Total wall-clock time (`zsh -i -c exit`):** Reduced from **140ms (0.14s) -> 80ms (0.08s)**.
