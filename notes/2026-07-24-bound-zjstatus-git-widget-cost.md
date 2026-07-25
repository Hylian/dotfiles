# Bound the zjstatus Git Widget Under Pane-Switch Spam ٩(◕‿◕｡)۶

*Date: 2026-07-24*

## Problem

Low-latency git status on pane switch and `cd` seemed to trade off against a swarm of
background git processes when pane switches were held down. Previous rounds attacked
this from the Zsh side — focus hooks added, throttled, then removed entirely; the poll
interval walked from 1s to 60s to 5s — without ever measuring where the cost actually
was.

## Root Cause

Two separate things, only one of which the shell can see.

**1. The dirty check is the only part that scales.** Measured per invocation, warm, on a
synthetic 40k-file worktree:

| component | small repo | 40k-file repo |
|---|---|---|
| `sh -c true` (spawn floor) | 2.5 ms | 3.5 ms |
| `git symbolic-ref --short HEAD` | 3.9 ms | 4.7 ms |
| `git diff-index --quiet HEAD --` | 4.8 ms | **30.0 ms** |
| `find <file> -newermt` | 1.8 ms | 1.8 ms |

Branch resolution is O(1); `diff-index` lstats every tracked file. On a real firmware
worktree that term dominates everything else by an order of magnitude.

**2. zjstatus amplifies each pane switch ~18×.** Reading v0.24.0's source
(`src/bin/zjstatus.rs`, `src/widgets/command.rs`) explains it: a focused-cwd change calls
`invalidate_focus_cwd_commands`, which backdates the stored result timestamp so
`run_command_if_needed` fires on the *next render* — and keeps firing on every render
until a result lands, because the timestamp only advances when a result is stored.
Results are additionally discarded when they arrive after the cwd changed again
(`context["cwd"] != state.focused_pane_cwd`). Instrumenting the widget in a live session
and switching between two panes in different repositories at three switches per second
measured **181 invocations for 10 switches**. The poll interval does not gate this; it
is render-driven, so a faster command does not reduce the count.

The good news from the same reading: `set_focused_pane_cwd` only invalidates when the
cwd genuinely *changes*, so switching among panes sharing a directory costs nothing, and
an idle session costs exactly one invocation per interval (measured: 2 in 10s at
`interval "5"`).

## Change

The widget command moved out of the KDL string into
[dot_config/zellij/widgets/executable_git-status.sh](../dot_config/zellij/widgets/executable_git-status.sh),
which memoises in two tiers:

1. **One-slot output memo** (`$XDG_RUNTIME_DIR/zjstatus-git-memo`, TTL 1s), keyed by cwd
   and holding the last rendered string. zjstatus only ever asks about the focused pane,
   so a single slot absorbs the whole re-spawn burst with no git process at all. Every
   exit path is routed through `emit` so that non-repo directories are memoised too.
2. **Per-repository dirty memo** (`$GIT_DIR/zjstatus-dirty`, TTL 3s) behind it, holding
   the result of the `diff-index` scan.

The branch itself is read straight out of `$GIT_DIR/HEAD` with builtins, leaving exactly
one git process (`rev-parse --absolute-git-dir`) on a full recompute. `--absolute-git-dir`
keeps subdirectories, linked worktrees and submodules correct.

Zsh deletes both memos in `precmd`, so nothing stands between an interactive command and
the bar; the TTLs are only a backstop for changes made outside the shell. The repo path
is resolved in `chpwd`, keeping the per-prompt hook fork-free, and deletion uses `zf_rm`
from `zsh/files` (loaded as `zmodload -F zsh/files b:zf_rm`, which does not clobber the
interactive `rm`).

Two incidental fixes found on the way:

* `_zellij_refresh_git_branch` was defined **twice** — in `dot_zshrc.tmpl` and again in
  `dot_config/zsh/widgets.tmpl`, which is sourced afterwards and therefore silently won.
  Deduplicated to the zshrc definition, which now carries its own `$ZELLIJ` guard because
  the fzf widgets call it directly.
* `_zellij_osc7_cwd` forked `printf | sed` on every prompt despite being documented as
  zero-subprocess. Replaced with `${PWD// /%20}`.

`command_git_branch_interval` stays at `"5"`; the fix was to make an invocation cheap,
not to poll less.

## Results

Per invocation, and as sustained load at three pane switches per second:

| | old inline command | new script |
|---|---|---|
| 40k-file repo, burst path | 38.4 ms | **6.4 ms** |
| 40k-file repo, full recompute | 38.4 ms | 13 ms |
| small repo, burst path | 12.9 ms | 5.8 ms |
| CPU during sustained switching, 40k repo | **197% of a core** | **33%** |
| CPU during sustained switching, small repo | 66% | 30% |

The remaining 33% is 18 unavoidable `/bin/sh` spawns per switch; the floor for this
design is ~16%. Process spawn is cheaper on Linux than on the macOS box these numbers
came from, so `shined` should land below this.

## Verification

1. Widget script exercised directly across clean, dirty, unborn-branch, detached-HEAD,
   linked-worktree, subdirectory, spaces-in-path and non-repo cases; detached output
   matches `git rev-parse --short HEAD` exactly. `dash -n` and `zsh -n` both parse.
2. Zsh hooks extracted from the rendered `.zshrc` and exercised standalone: cache path
   tracking on `chpwd`, both memos dropped on `precmd`, clean exit outside a repository,
   and `_zellij_osc7_cwd` confirmed free of subprocesses.
3. Live zellij session (`zellij -n <layout>`) on this host: bar empty in `$HOME`, branch
   appearing on `cd` into a repo, correct per-pane branches while switching between two
   repositories, `●` appearing 0.51s after dirtying plus a command in the pane, and the
   TTL backstop healing an external cleanup without any hook firing.
4. Idle cost re-measured in that session: 2 invocations per 10s, matching `interval "5"`.

## Known Limits

* The ~18× re-spawn amplification is zjstatus-side and cannot be configured away; only
  the per-invocation cost is ours to control. Worth an upstream issue.
* `diff-index` trusts the index stat cache, and this repo deliberately keeps the index
  read-only (`core.fsmonitor`/`untrackedCache` off, `--no-optional-locks` everywhere), so
  a worktree whose files were re-stamped without an index write can read as dirty until
  any ordinary git command refreshes it. Reproduced during testing with a `cp -r` of a
  clean repo; healed by a single `git status`. Accepted rather than trading it for index
  writes on every poll.
