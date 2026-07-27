# Activation on `midnight-future` — Pending Apply, Stray Whitespace, Wedged Pipes ＾▽＾

*Date: 2026-07-26*

## Host

`midnight-future` (macOS 27, arm64), a second Apple silicon client alongside `baumkuchen`.
Already known to [dot_config/aerospace/aerospace.toml.tmpl](../dot_config/aerospace/aerospace.toml.tmpl)
but missing from the host matrix in [SYSTEM.md](SYSTEM.md); added.

Stock Homebrew `zellij 0.44.3`, no `~/.config/zellij/plugins/zjstatus.wasm`. So
[default.kdl.tmpl](../dot_config/zellij/layouts/default.kdl.tmpl)'s `stat` check picks the
release plugin URL, `ZJSTATUS_AUTORENDER` stays unset, and
[executable_git-status.sh](../dot_config/zellij/widgets/executable_git-status.sh) keeps its
repaint kick. That is the intended fallback, not a gap.

## Pending apply

The host was five targets behind: the git-status widget script, the layout switch to it, the
`^j` → `^o` zoxide rebind, the `.zshrc` hook rework, and the zjstatus permission script.
`chezmoi apply` clean; `zsh -n` clean on `.zshrc` and `widgets`; `sh -n` clean on the widget,
which emits `main` in this repo.

## Stray whitespace in the rendered layout

`{{ if $patched }}command_git_branch_env …{{ end }}` sat behind 16 spaces of indent, so an
unpatched host rendered a whitespace-only line into `default.kdl`. Moved to `{{- if $patched }}`
on its own line in both the light and dark blocks. Verified both branches: the patched render
still emits the env line, the unpatched render now has zero trailing-whitespace lines, and a
fresh `zellij --layout default` session comes up with the layout parsed.

`zellij --session <new-name>` errors `There is no active session!` on this config — `config.kdl`
sets `attach_to_session true`, which turns a named launch into an attach. Use
`zellij attach -c <name>`, or an unnamed launch, when smoke-testing a layout.

## 36 wedged `zellij pipe` clients

Found 36 `zellij pipe zjstatus::rerun::git_branch` processes, all spawned inside a four-second
window ~35 minutes earlier, with no zellij session alive. Reaped.

This is the fd-exhaustion mode already documented for the widget — but on the *other* spawn
path. The widget's kick is capped by a two-second plain-sh watchdog;
`_zellij_refresh_git_branch` in [dot_zshrc.tmpl](../dot_zshrc.tmpl) is not. It fires
`command zellij pipe … &!` from `precmd`, and `zellij pipe` is a streaming client that blocks
forever against a dead or wedged server, holding a socket each time. One server death plus a
handful of live panes still typing produces exactly this burst.

Not fixed here, because the obvious fix is wrong: a watchdog subshell costs two extra forks on
every prompt, on the hot path whose fork count is what widens the held-Enter race in
[2026-07-26-held-enter-triggers-zoxide-widget.md](2026-07-26-held-enter-triggers-zoxide-widget.md).
The cheap candidate is a fork-free liveness guard — skip the pipe unless the session's control
socket still exists (`[[ -S … ]]`, one stat, no subprocess). It covers a dead server, which is
this case; it does not cover a live-but-wedged one. Rachel's call.
