# Repaint the Git Widget When Its Value Changes ٩(◕‿◕｡)۶

*Date: 2026-07-24*

## Problem

After bounding the widget's cost ([2026-07-24-bound-zjstatus-git-widget-cost.md](2026-07-24-bound-zjstatus-git-widget-cost.md)),
the branch still lagged visibly on pane switch. Measured on a PTY harness, keystroke
(`Alt+h`/`Alt+l`) to the new branch appearing in the bar: **median 784 ms, max 799 ms**.

## Root Cause

`Event::RunCommandResult` in zjstatus v0.24.0 (`src/bin/zjstatus.rs`) stores the command
result and sets `cache_mask`, but never sets `should_render`. The freshly computed branch
therefore sits in plugin state, unpainted, until some *other* event triggers a render —
in practice the 1 s `REFRESH_INTERVAL_SECONDS` timer. Decomposed for a single switch:

| | |
|---|---|
| keystroke | t+0 ms |
| widget spawned by zjstatus | t+8 ms |
| widget produced its value | t+64 ms |
| bar repainted | t+310 ms (was ~784 ms) |

So the plugin reacts fast; only the repaint was late.

## Change

`zjstatus::pipe::<name>::<content>` sets `should_render = true` in `parse_protocol`, and a
pipe name no format string references has no other effect — a side-effect-free repaint
trigger. The widget now fires one at the end of `emit`, but **only when the rendered value
or the directory actually changed**, so a settled bar costs nothing and a pane switch costs
at most one.

Three pieces of hardening, all of them learned the hard way:

1. **`zellij pipe` is a streaming client, not fire-and-forget.** It relays plugin output on
   stdout and exits when the plugin is done (~40 ms measured). Given an inherited stdin, or
   pointed at a session whose server is gone or wedged, it blocks indefinitely while holding
   a socket. It now gets `</dev/null` plus a plain-sh watchdog that kills it after two
   seconds; macOS has no `timeout(1)`, so the watchdog is a subshell with `sleep`.
2. **The output memo MUST be keyed per session** (`zjstatus-git-memo.$ZELLIJ_SESSION_NAME`).
   A single shared slot makes concurrent sessions invalidate each other's entry on every
   render; combined with the repaint kick that becomes a feedback loop between their status
   bars. Measured at **4 widget invocations per second while completely idle**, versus the
   0.2/s the 5 s interval should produce.
3. The same per-session key applies in `_zellij_git_memo` in `dot_zshrc.tmpl`, which deletes
   the memo on `precmd`.

## Incident

While measuring this, the zellij server on the macOS client ran out of file descriptors and
crashed, taking Rachel's session with it. Cause was the combination above: a PTY harness that
created sessions in a loop without closing master fds, `zellij delete-session` run against
sessions whose clients were still live, and an unbounded kick that then blocked forever
against those corpses — each stuck client holding a socket. Every one of those three is now
either fixed (watchdog, `</dev/null`, per-session memo) or was harness-only.

Worth keeping in mind: in normal operation a kick can only be spawned *by* a live server,
because the widget only runs while that server is rendering. The runaway needed a session
corpse, which only the harness manufactured.

## Results

| | before | after |
|---|---|---|
| keystroke to repainted branch, median | 784 ms | **319 ms** |
| same, max over 12 switches | 799 ms | 435 ms |
| missed repaints | — | 0 / 12 |
| idle invocations (20 s, `interval "5"`) | 4 | 4 |
| kicks fired while idle | — | 0 |
| peak concurrent kick clients (12 rapid switches) | — | 14, draining to 0 |

## Known Limits

The residual ~245 ms is `zellij pipe`'s own client startup, which is not something a shell
script can avoid. The real fix is one line upstream — setting `should_render = true` in the
`Event::RunCommandResult` arm — which would repaint as soon as the result lands, around
t+64 ms, and make the kick unnecessary. Worth an issue or PR against dj95/zjstatus, along
with the re-spawn amplification noted in the previous round.

## Verification

1. Widget output unchanged across clean, dirty, detached, unborn, worktree, subdirectory and
   non-repo cases; `dash -n` clean.
2. Latency measured on a real PTY with `Alt+h`/`Alt+l` keystrokes written straight to the
   master fd — no CLI client in the timing path — 12 switches, no misses.
3. Idle audit over 20 s: 4 invocations, 0 kicks, one memo file per session.
4. Leak audit after 12 rapid switches: peak 14 kick clients, 0 after a 3 s settle, 0 stray
   watchdogs, all test sessions deleted and no leftover processes.
