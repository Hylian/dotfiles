# Move the Autorender Fix Out of Zellij and Into zjstatus ٩(◕‿◕｡)۶

*Date: 2026-07-25*

## Context

Rachel pushed back on yesterday's approach ([2026-07-24-zellij-fork-plugin-autorender.md](2026-07-24-zellij-fork-plugin-autorender.md)):
if a plugin can return `true` from `update()` to request a render, why patch the server
to force it? She was right, and the patch was in the wrong layer.

`zellij-server/src/plugins/wasm_bridge.rs` calls the plugin's `update()` and honours its
return value, then overrides it for `PermissionRequestResult` — and, with our patch, for
`RunCommandResult`. That override applies to *every* plugin, to compensate for one plugin
forgetting one line.

## Finding

zjstatus v0.24.0, `src/bin/zjstatus.rs`, the `Event::RunCommandResult` arm: a stale result
returns `false` early, and every other path falls out of the arm with `should_render` still
`false`. The value is stored and nothing asks for a repaint. That is the entire bug.

(Worth recording how nearly this was missed: a grep showed `should_render = true` a few
lines below the arm and looked like a refutation. It belongs to the *next* arm,
`Event::SessionUpdate`. Reading the range, not the grep hit, settled it.)

## The Fix

One arm in [`Hylian/zjstatus`](https://github.com/dj95/zjstatus), branch `hylian/autorender`,
commit `fix(command): render when a command result changes`:

```rust
let key = name.to_owned();
let result = CommandResult { exit_code, stdout, stderr, context };

should_render = self.state.command_results.get(&key).is_none_or(|previous| {
    previous.exit_code != result.exit_code
        || previous.stdout != result.stdout
        || previous.stderr != result.stderr
});

self.state.command_results.insert(key, result);
```

It repaints on *change*, not on arrival, which the server-side patch could not do. `context`
is excluded from the comparison deliberately: it carries a per-invocation timestamp, and
zjstatus re-runs a focus-following command on every render until its result lands (~18 times
per pane switch), so comparing it would repaint that many times for identical output. The
rendered fields are exactly `exit_code`, `stdout` and `stderr` — `context` is never displayed.

`key` is bound before the struct is built because `name` borrows from `context`, which the
struct consumes. Still one `to_owned()`, as before.

Upstreamable to dj95/zjstatus as-is.

## What This Removes

Both zellij patches are gone; `hylian/latency` is back to the two genuine latency commits
(`/proc` cwd reads, `close_range` syscall). Previous state backed up as
`hylian/latency-pre-zjstatus`. The branch `fix/render-plugin-on-command-result`, prepared as
an upstream zellij PR, is now moot — left in place, not deleted, for Rachel to decide.

The capability marker never needed a patch either. zjstatus already supports per-command
environment variables from layout config (`command_<name>_env`), so
[dot_config/zellij/layouts/default.kdl.tmpl](../dot_config/zellij/layouts/default.kdl.tmpl)
declares `ZJSTATUS_AUTORENDER` itself and the widget's repaint kick keys off that instead of
a server-set variable. The kick survives for hosts still on the release build.

The layout picks the plugin with `stat`: a local build at
`~/.config/zellij/plugins/zjstatus.wasm` if present, otherwise the release URL. A host with
no local build gets the release plugin, no marker, and the kick — exactly today's behaviour.

## Permission Cache Hazard

Zellij keys its plugin permission cache by plugin location, so URL → local path is an
unknown plugin needing a fresh `RunCommands` grant. The grant prompt renders inside the
plugin's own pane, and the status bar is **one row tall** — there is nowhere to draw it and
no way to answer. The bar simply comes up empty, with nothing in the log to say why. This
cost a debugging detour and would have hit Rachel on her next session.

[run_onchange_after_20-zjstatus-plugin-permissions.sh.tmpl](../run_onchange_after_20-zjstatus-plugin-permissions.sh.tmpl)
seeds the entry with exactly the permissions the release build already holds, and no-ops when
there is no local build. First `run_` script in this repo. Verified idempotent across a
forced re-apply.

## Results

Keystroke to new branch painted, two `sh` panes in different repositories, keys written
straight to a PTY master fd, 12 switches per condition, all on the **unpatched** zellij:

| condition | median | max | misses | extra processes |
|---|---|---|---|---|
| stock zjstatus, no kick | 700 ms | 704 ms | 0 | 0 |
| stock zjstatus + repaint kick | 67 ms | 76 ms | 0 | 1 per change |
| **patched zjstatus, kick self-disabled** | **47 ms** | **59 ms** | **0** | **0** |

The one-line plugin fix beats the server patch plus the whole kick apparatus, on a zellij
carrying neither. Absolute numbers are not comparable with yesterday's table — that harness
drove interactive zsh panes, this one drives `sh` — but the three conditions here were
measured identically.

## Verification

1. Installed zellij rebuilt from `hylian/latency` with both render commits dropped;
   `ZELLIJ_PLUGIN_AUTORENDER` absent from the binary, so no measurement can be crediting it.
2. zjstatus: `cargo clippy` clean for the change (one pre-existing warning in an unrelated
   test), 21 tests pass under the `wasmtime` runner.
3. End-to-end on the real layout with real zsh hooks: `cd` into two repositories, branch
   appears in the bar both times.
4. Widget output unchanged across clean, dirty, detached, unborn, worktree, subdirectory and
   non-repo cases; `dash -n` clean.
5. Fallback path exercised (marker absent): kick fires, no misses, no leaked `zellij pipe`
   clients or watchdogs afterwards.
6. All benchmark sessions deleted; no leftover zellij processes.

## Follow-ups

* `hylian/latency` was rewritten and still needs a force push, as does the new
  `hylian/autorender` on a zjstatus fork.
* The zjstatus fix is worth a PR upstream. If it lands, the local build, the marker, the
  kick and the permission-seeding script all go away and the layout returns to the release
  URL unconditionally.
* `shined` was not reachable from this host, so it is still on the release plugin and the
  kick path. `cargo build --release` in a zjstatus checkout, copy
  `target/wasm32-wasip1/release/zjstatus.wasm` into `~/.config/zellij/plugins/`, then
  `chezmoi apply` to seed permissions and switch the layout.
* `wasmtime` installed via brew on this host, needed only to run zjstatus's test suite.
* Still upstream's problem: zjstatus re-spawns a focus-following command on every render
  until its result lands. The change-detecting comparison means those duplicates no longer
  cause repaints, but they are still processes.
