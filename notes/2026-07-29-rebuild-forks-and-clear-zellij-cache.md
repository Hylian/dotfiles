# Rebuilding Both Forks on `midnight-future` and Clearing the Zellij Cache (｡•̀ᴗ-)✧

*Date: 2026-07-29*

Rachel pulled new work into both fork checkouts — which now live at `~/software/zellij` and
`~/software/zjstatus`, not `~/dev/*` — and asked for a build, an install, and a cache clear.
All three done, both artifacts live and smoke-tested.

## What arrived

`Hylian/zellij` @ `hylian/latency`, four commits, local branch level with `origin`:

* the two latency commits (`/proc` cwd reads, `close_range` in `pre_exec`)
* **both plugin-render patches are back** — `fix(plugins): render a plugin when its command
  result arrives` and `expose ZELLIJ_PLUGIN_AUTORENDER to plugin-spawned commands`. These are
  the ones [2026-07-25-move-autorender-fix-into-zjstatus.md](2026-07-25-move-autorender-fix-into-zjstatus.md)
  dropped in favour of the one-line zjstatus fix, and the ones
  [2026-07-26-build-forks-on-midnight-future.md](2026-07-26-build-forks-on-midnight-future.md)
  reset out of a fresh clone. They are now pushed, so this is adoption, not the stale
  pre-rewrite state resurfacing: the server-side repaint and the plugin-side one both ship.
  `strings ~/.local/bin/zellij | grep -c ZELLIJ_PLUGIN_AUTORENDER` → 1. Ground truth updated;
  the "still needs a force push" follow-up is closed.
* `fix(pty): optimized get_cmds_by_ppid on linux via /proc` — reads
  `/proc/<pid>/task/<pid>/children` instead of crawling all of `/proc`, so a many-core host
  stops blowing zellij's 100ms plugin-request budget. Linux-only; inert on this host, and it
  is `shined`-facing work.

`Hylian/zjstatus` @ `hylian/autorender`, three commits on `v0.24.0`:

* `fix(command): render when a command result changes` (the original autorender fix)
* `fix(command): reject out-of-order stale command results`
* `fix(command): gracefully survive Zellij PTY GetPaneCwd timeouts` — keeps its own
  `PaneId -> PathBuf` mirror from asynchronous `CwdChanged` events and falls back to it when
  `get_pane_cwd()` misses the 100ms budget. Without it a `None` cwd wedged that pane's widget
  permanently, because the OS cwd never changed so no `CwdChanged` was ever coming.

The two client-side fixes pair exactly with the server-side `/proc` optimisation: same
100ms budget, one side making it cheaper to answer, the other surviving a miss.

## Build & install

zjstatus `cargo build --release` — 15s incremental; copied
`target/wasm32-wasip1/release/zjstatus.wasm` to `~/.config/zellij/plugins/zjstatus.wasm`,
sha256 verified identical.

zellij `cargo xtask install ~/.local/bin/zellij` — 2m09s incremental, then
`codesign -s - --force ~/.local/bin/zellij` as the ground truth requires; `--version` execs
cleanly (0.44.3) instead of dying on SIGKILL. The build leaves 13
`zellij-utils/assets/plugins/*.wasm` modified in the worktree — regenerated built-in plugins,
left alone.

## Clearing the cache, minus two things

Cache dir on macOS: `~/Library/Caches/org.Zellij-Contributors.Zellij`, 29M in 428 dirs. What
was actually in there:

* `<url-path-safe>/plugin_cache` — per-plugin persistent state, keyed by plugin location
  (`file:`, `https:`, `zellij:session-manager`)
* a 4.3M hash-named wasm blob at the root — the release zjstatus downloaded back when the
  layout's `stat` check fell through to the URL
* 421 UUID session dirs, mostly empty leaves (plugin data dirs)
* `0.43.1/` (25M of compiled artifacts from an older layout), `0.44.0/`, `0.44.1/`

Two survivors, deliberately:

* `permissions.kdl` — the `RunCommands` grants. chezmoi keys `run_onchange_` re-runs on
  rendered contents, and
  [run_onchange_after_20-zjstatus-plugin-permissions.sh.tmpl](../run_onchange_after_20-zjstatus-plugin-permissions.sh.tmpl)
  has not changed, so a deleted grant would not come back on the next apply — it would come
  back as an empty bar and a permission prompt drawn inside a one-row pane where it cannot be
  answered.
* `contract_version_1/` — holds `session_info`, which is how `list-sessions` and `attach`
  find a **live** server. The `persist` session has been up 2d21h (on the brew binary, in
  fact, not the fork) and its `session-metadata.kdl` was being rewritten every few seconds.
  Orphaning that for a cache clear would have been a bad trade.

29M → 632K, grants intact, `persist` still listed.

Worth knowing for next time: 0.44.x does **not** cache compiled modules on disk.
`ZELLIJ_PLUGIN_ARTIFACT_DIR` is still defined in `consts.rs` but nothing reads it, and
`plugin_loader.rs` calls `Module::new(&self.engine, &wasm_bytes)` on every load. So the
stale-plugin hazard is entirely `plugin_cache` plus downloaded blobs; a rebuilt wasm is
compiled fresh regardless.

## Smoke test

Fresh sessions in a 200x50 PTY (`zellij attach -c <name>` — `--session` would attach, not
create, with `attach_to_session true`), driven straight off `~/.local/bin/zellij`, never
touching `persist`. Pulled the git segment out of the raw escape stream by its background
colour:

| cwd | segment |
| --- | --- |
| `~/software/zellij` (initial) | `  ` |
| `~/software/zjstatus` after `cd` | ` hylian/autorender ` |
| `~/.local/share/chezmoi` after `cd` | ` main ` |
| `~/software/zellij` after `cd` | ` hylian/latency ● ` |

Branch, repo-to-repo tracking, and the dirty marker all correct. Zero `zjs_render_kick`
processes and zero `zellij pipe` clients left behind — the local build sets
`ZJSTATUS_AUTORENDER` via the layout, so the widget skips its kick, which is the whole point.

## The one thing that stays blank

The **initial** cwd of a fresh session renders an empty git segment; it populates on the
first `cd`. Held for 14s and across the explicit `zjstatus::rerun::git_branch` pipe that
`precmd` fires, in two different repos, while the widget script itself returned
`hylian/latency ●` in 52ms in that same directory. So the widget is innocent: zjstatus wants
a cwd before it will spawn a focused-cwd command, and at boot no `CwdChanged` has arrived, so
the new timeout fallback has nothing cached to fall back to either.

Not new — [2026-07-26-build-forks-on-midnight-future.md](2026-07-26-build-forks-on-midnight-future.md)
already recorded "branch paints on `cd`". Recorded in [SYSTEM.md](SYSTEM.md) so it stops
looking like a fresh regression. If it ever becomes annoying rather than cosmetic, the fix
belongs in zjstatus: seed the cwd mirror from the pane list at load instead of waiting for
the first event.

## State

* `~/.local/bin/zellij` — fork with all four commits, ad-hoc signed, first on PATH.
* `~/.config/zellij/plugins/zjstatus.wasm` — fork with all three commits, non-tracing.
* Cache cleared; grants and live-session discovery preserved.
* All smoke sessions deleted, their memo files removed, no stray processes.
* `persist` (2d21h, brew binary) untouched — it holds the old binary and old plugin in
  memory and will only pick these up when it is restarted. Rachel's call when.
