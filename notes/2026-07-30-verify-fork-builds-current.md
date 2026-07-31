# Verifying Both Forks Are Built and Installed on `midnight-future` (｡•̀ᴗ-)✧

*Date: 2026-07-30*

Rachel asked to make sure the latest zellij and zjstatus we worked on are actually built and
installed. Verification pass, not a rebuild: nothing had drifted, both artifacts are current,
and the smoke test still passes.

## What was checked

Both checkouts sit exactly where [2026-07-29-rebuild-forks-and-clear-zellij-cache.md](2026-07-29-rebuild-forks-and-clear-zellij-cache.md)
left them, and both are level with `origin`:

| repo | HEAD | branch |
| --- | --- | --- |
| `~/software/zellij` | `28baaa76 fix(pty): optimized get_cmds_by_ppid on linux via /proc` | `hylian/latency` |
| `~/software/zjstatus` | `8a03875 fix(command): gracefully survive Zellij PTY GetPaneCwd timeouts` | `hylian/autorender` |

`git rev-parse HEAD origin/<branch>` matches for both, so there is nothing unpushed and
nothing unpulled. The only dirty paths in the zellij worktree are the 13 regenerated
`zellij-utils/assets/plugins/*.wasm` built-ins — expected, left alone.

Both builds were re-run rather than trusted: `cargo build --release` (zjstatus) and
`cargo xtask install ~/.local/bin/zellij` (zellij) both finished in under a second with
nothing to recompile. So the installed artifacts were already the current sources.

## The hash trap

Worth writing down, because a naive check here reads as a failure:

* Before the install ran, `~/.local/bin/zellij` was 40,579,552 bytes while
  `target/release/zellij` was 40,816,736 — a 237K difference that is **only** the ad-hoc code
  signature applied after the previous install. Same build, different bytes.
* `cargo xtask install` copies unconditionally and preserves the source mtime, so the file
  timestamp says "Jul 29 20:50" even for a copy made today. mtime proves nothing.
* Re-signing (`codesign -s - --force`) rewrites the binary again, so the post-install hash
  never matches `target/` either.

Order that actually tells you something: install → `shasum` the pair (matched,
`f7d936de…`) → sign → verify with `codesign -v`, `zellij --version` (0.44.3) and
`strings ~/.local/bin/zellij | grep -c ZELLIJ_PLUGIN_AUTORENDER` → 1. Recorded in
[SYSTEM.md](SYSTEM.md) so the next pass does not chase the size delta.

zjstatus has no such wrinkle — it is a plain copy, and
`target/wasm32-wasip1/release/zjstatus.wasm` and `~/.config/zellij/plugins/zjstatus.wasm`
hash identically (`cc1e5c16…`).

## Smoke test

Fresh throwaway session in a 200x50 PTY driven straight off `~/.local/bin/zellij`
(`attach -c`), git segment pulled out of the raw escape stream by its background colour
(`48;2;223;105;186`):

| cwd | segment |
| --- | --- |
| `~/software/zjstatus` | ` hylian/autorender ` |
| `~/.local/share/chezmoi` | ` main ` |
| `~/software/zellij` | ` hylian/latency ● ` |

Branch tracking across repos and the dirty marker both correct. Initial-cwd segment still
blank until the first `cd`, as documented — cosmetic, still not a regression. Session
deleted afterwards, no memo files and no stray `zellij pipe` / `zjs_render_kick` processes.

## State

Unchanged from yesterday, now confirmed rather than assumed. `persist` (4d) is still on the
brew binary and the old plugin in memory; it picks these up only on restart.
