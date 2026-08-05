# Zero-Fork Timestamp Memoization in `git-status.sh` ٩(◕‿◕｡)۶

*Date: 2026-08-05*

## Motivation

In [dot_config/zellij/widgets/executable_git-status.sh](../dot_config/zellij/widgets/executable_git-status.sh), TTL expiration checks previously called:
```sh
[ -n "$(find "$memo" -newermt '-1 seconds' 2>/dev/null)" ]
```
and
```sh
[ -z "$(find "$cache" -newermt "-$ttl seconds" 2>/dev/null)" ]
```

Each `find` invocation forked a `/usr/bin/find` binary subprocess (~1.7ms). Under the ~18x command re-spawn burst fired by `zjstatus` on focused CWD change, forking `find` accounted for a significant fraction of CPU time and added ~2.6ms of baseline overhead to every burst hit.

## Mechanism & Fix

1. **Zero-Fork Kernel Clock Resolution:**
   - On Linux (`/proc/uptime` available): reads system uptime seconds directly via pure shell builtins (`read -r _now_s _ </proc/uptime; now=${_now_s%.*}`) in **~160 microseconds** with **0 subprocess forks**.
   - On macOS (fallback): calls `date +%s` once at script startup.

2. **Expiration Timestamps Embedded in Memo Files:**
   - **Output Memo (`$XDG_RUNTIME_DIR/zjstatus-git-memo.$ZELLIJ_SESSION_NAME`):**
     Stores `EXPIRES_AT\tPWD\tOUTPUT`.
     Validating the memo is a pure integer arithmetic check (`[ "$memo_exp" -ge "$now" ]`) in `read` builtins. Burst hits exit 0 with **zero forks**.
   - **Dirty Cache (`$GIT_DIR/zjstatus-dirty`):**
     Stores `EXPIRES_AT\tMARKER`.
     If the dirty cache is warm, reads the marker in pure builtins without running `find` or `git diff-index`.

## Results & Benchmarks

Benchmarked across 100 iterations on `shined`:

| Component / State | Previous (`find -newermt`) | New (Zero-Fork Timestamp) | Improvement |
|---|---|---|---|
| **Burst memo hit** | **4.52 ms** | **1.95 ms** | **2.3× faster (sub-2ms)** |
| **Subprocesses in burst path** | 1 (`/usr/bin/find`) | **0 (pure builtins)** | Zero child processes |
| **Full recompute path** | ~38 ms | ~16 ms | ~2.4× faster |

## Verification

1. `dash -n dot_config/zellij/widgets/executable_git-status.sh` validated clean POSIX syntax.
2. `chezmoi diff` and `chezmoi apply ~/.config/zellij/widgets/git-status.sh` completed smoothly.
3. Verified outputs across clean repo, dirty repo, unborn repo, detached HEAD, subdirectories, and non-repo directories.
