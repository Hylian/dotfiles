# Resetting and Rebuilding Zellij With the Scroll Stack on `midnight-future` (｡•̀ᴗ-)✧

*Date: 2026-08-07*

Follow-on from [2026-08-07-rebase-onto-upstream-scroll-work.md](2026-08-07-rebase-onto-upstream-scroll-work.md):
the dotfiles had the scroll config, the binary did not.

## Reset

`~/software/zellij` sat on `28baaa76` with the two server-side render patches; the branch
had since been force-pushed. Only dirty paths were the 13 regenerated
`zellij-utils/assets/plugins/*.wasm` built-ins, so `git checkout --` then
`git reset --hard origin/hylian/latency` → `302f6e63 feat(scroll): lighter friction
(0.955), lower flick threshold, and smoother impulse scaling`.

The remote branch is now the three latency commits plus a 12-commit scroll stack:
1-line wheel handling → per-frame rate limiting → the animation queue → logarithmic step
scaling with the 200ms ceiling → configurable `scroll_acceleration_factor` → gesture
inference, momentum, grab-to-halt, friction tuning.

## Build

`cargo xtask install ~/.local/bin/zellij`, full rebuild (the reset invalidated everything):
39s of wasm plugins + 2m26s of the workspace, 186s total on 16 cores. No sccache — the
guarded [dot_cargo/config.toml.tmpl](../dot_cargo/config.toml.tmpl) renders `jobs = 16`
and omits the wrapper here.

Order that proves what is installed, per [SYSTEM.md](SYSTEM.md): install → hash the pair
*before* signing (`f9c81148…` both) → `codesign -s - --force` → `codesign -v` → `zellij
--version` (0.44.3).

**The old `strings … ZELLIJ_PLUGIN_AUTORENDER` check is retired.** It returns 0 now, and
correctly so — those commits were pruned. `scroll_acceleration_factor` (2 hits) is the
marker for a current binary.

## Verification

* `zellij setup --check` → `[CONFIG FILE]: Well defined.` The rendered
  `~/.config/zellij/config.kdl` already carried `scroll_acceleration_factor 3.5`, which
  only this binary understands.
* Git segment, fresh 200x50 session on the new binary, branch pulled from the raw escape
  stream by background colour:

  | cwd | segment |
  | --- | --- |
  | `~/software/zellij` | ` hylian/latency ● ` |
  | `~/.local/share/chezmoi` | ` main ` |

  Dirty marker correct (the zellij worktree has `target/`).
* Animation queue is live: six wheel-up events written 4ms apart into a 120x40 PTY produce
  output across **120 distinct timestamps** spanning ~3s of settling, against 4 for a
  single event. A non-animating build would emit roughly one render per event.
* At 120 columns the right section blanks the moment `hylian/latency ●` appears — the
  documented `format_hide_on_overlength` behaviour, not a regression. Reproduced, then
  confirmed fine at 200.

zjstatus needed nothing: still `8a03875`, level with `origin/hylian/autorender`, and the
installed `.wasm` hashes identically to `target/` (`cc1e5c16…`).

## State

Running servers keep the old binary in memory — the 11-day `persist` session and anything
else already attached still runs `28baaa76`. New sessions get the scroll stack.
