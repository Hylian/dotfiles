# Building the zellij + zjstatus Forks on `midnight-future` ٩(◕‿◕｡)۶

*Date: 2026-07-26*

Rachel cloned both forks to `~/dev/zellij` and `~/dev/zjstatus` and asked for a local build
and install on this host. Done; both are live. Three things were worth more than the build
itself.

## The clone was one force-push behind

`hylian/latency` still carried `fix(plugins): render a plugin when its command result
arrives` and `expose ZELLIJ_PLUGIN_AUTORENDER…` on top of the two genuine latency commits —
the state that
[2026-07-25-move-autorender-fix-into-zjstatus.md](2026-07-25-move-autorender-fix-into-zjstatus.md)
removed in favour of the one-line zjstatus fix. The follow-up in that note ("still needs a
force push") is exactly why: `origin` never got the rewrite, so a fresh clone resurrects the
rejected design.

Rachel chose to reset the branch, so this clone is now at `d715f638` (`close_range`) with the
two render commits gone. `origin/hylian/latency` still needs the force push. Confirmed in the
installed binary: `strings ~/.local/bin/zellij | grep -c ZELLIJ_PLUGIN_AUTORENDER` → 0.

## Toolchain from scratch

No rust at all on this host. `brew install rustup` is keg-only and no longer ships
`rustup-init`, so the shims sit in `/opt/homebrew/opt/rustup/bin`;
[dot_zshrc.tmpl](../dot_zshrc.tmpl) now prepends that and `~/.cargo/bin` behind the same
`-d` guards the other PATH entries use. Both toolchains come from the checkouts'
`rust-toolchain.toml` — 1.95.0 for zjstatus, 1.92.0 for zellij, both with `wasm32-wasip1` —
plus `protobuf` from brew and `mandown` from cargo.

zjstatus builds in ~50s, zellij in ~4 min (`cargo xtask install ~/.local/bin/zellij`).
Re-signed after install as the ground truth requires. brew's zellij is left installed here
and simply shadowed by PATH order rather than uninstalled — same effect, and it steps around
the autoremove sweep that cost `baumkuchen` its pythons.

## The permission script could not fire

`run_onchange_after_20-zjstatus-plugin-permissions.sh` had already run on this host during an
earlier apply, when there was no local plugin, and exited 0. chezmoi keys re-runs on the
**rendered contents** of the script, which had not changed, so building the plugin afterwards
could never trigger the seeding — the exact ordering any new host hits. The script now
embeds `{{ if stat $wasm }}` presence in a comment, so the plugin appearing changes the hash
and the grant gets seeded on the next apply. Verified: apply re-ran it, the entry landed, and
running the rendered script twice more leaves exactly one entry.

## The bar was empty, and the widget was innocent

After the install the git segment rendered blank. The chase, in order:

1. The widget script itself: correct, `hylian/autorender` on stdout.
2. Its memo under the live session: correct cwd, correct branch — so zjstatus *was* running
   it with the focused pane's cwd.
3. A tracing build (`--features tracing`, logs to `~/.zjstatus.log`): `RunCommandResult`
   arrived with a matching `cwd`, so the stale-result guard was not eating it.
4. Probes inside `CommandWidget::process`: it returned `"hylian/autorender ●"`.
5. A probe on the printed bar: no branch — and, on the renders where the widget *did* return
   a branch, no right section at all.

That last pair is the tell. `format_hide_on_overlength "true"` makes zjstatus drop the whole
right section when the line does not fit, and the git branch is the widest variable part of
it. The bar fit at 120 columns with an empty branch and stopped fitting the moment a branch
appeared. My test harness was 120 columns wide with a long random session name; Rachel's
Ghostty is not.

Re-verified in a PTY sized 200x50: branch paints on `cd`, follows a second `cd`
(`hylian/latency`), and shows ` main ● ` for a dirty tree. No `zjs_render_kick` processes —
the local build sets `ZJSTATUS_AUTORENDER`, so the widget skips the kick, which is the whole
point of the patched plugin.

Lesson recorded in [SYSTEM.md](SYSTEM.md): check the terminal width before debugging the
widget. A layout that hides a section rather than truncating it fails silently and looks
exactly like a broken plugin.

## Also noticed

The zellij log carries `Action CliPipe did not complete within 1s timeout` going back to
before any of today's changes, on the release plugin. Same family as the 36 wedged
`zellij pipe` clients reaped earlier today — see
[2026-07-26-activate-on-midnight-future.md](2026-07-26-activate-on-midnight-future.md) for the
unguarded spawn path in `precmd` and the fork-free liveness guard proposed for it.

## State

* `~/.local/bin/zellij` — fork, two latency commits, ad-hoc signed, first on PATH.
* `~/.config/zellij/plugins/zjstatus.wasm` — patched build, non-tracing, permissions seeded.
* Both checkouts clean; probes reverted; all benchmark sessions deleted, no leftover zellij
  processes, memo and capture files removed.
