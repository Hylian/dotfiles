# Rebasing Nine Local Commits Onto the Upstream Scroll Work ٩(◕‿◕｡)۶

*Date: 2026-08-07*

`main` on `midnight-future` was 9 ahead / 24 behind. `pull.rebase = true`, so `git pull`
replayed the local stack on top of the 24 upstream commits (Ghostty/Zellij smooth-scroll
work, nvim lazy-loading, zsh antigen fixes, the zero-fork git-status memo). Four conflict
stops, all resolved by hand.

## Conflicts and how they were called

| file | conflict | resolution |
| --- | --- | --- |
| [SYSTEM.md](SYSTEM.md) ×3 | the whole Zellij bullet list, rewritten on both sides | merged fact-by-fact, not side-by-side |
| [dot_config/nvim/lua/plugins/init.lua](../dot_config/nvim/lua/plugins/init.lua) | upstream lazy-loaded the codecompanion spec we deleted | took the deletion; `render-markdown` keeps `ft = { "markdown" }` |
| [dot_config/nvim/init.lua.tmpl](../dot_config/nvim/init.lua.tmpl) | upstream moved `focus`/`telescope`/`fzf-lua`/`ibl`/`mini.diff` out of the eager require block; our commit only dropped the codecompanion line from it | took upstream's empty block after confirming all five now live in lazy specs |

The `SYSTEM.md` merges were the real work: each side had newer facts about the *same*
bullets. Kept from upstream — the sccache cargo config, the smooth scroll queue, the
zero-fork widget memo tiers. Kept from local — the per-host brew/PATH nuance, the tracing
build, the Rust toolchain shims, `format_hide_on_overlength`, the `run_onchange_` rendered-
hash requirement, the cache-clearing rules, and "branch is blank until the first `cd`".

## One claim was stale on both sides

Local notes said `hylian/latency` had *re-adopted* the two server-side render patches;
upstream said they were pruned. Checked the actual remote instead of picking:
`git fetch` in `~/software/zellij` reported a **forced update**, and
`origin/hylian/latency` is now the three latency commits with the scroll stack on top —
no render patches. So upstream was right, and the local checkout (`28baaa76`) has
diverged and must be reset before the next build. The installed
`~/.local/bin/zellij` therefore predates the scroll work. Recorded in
[SYSTEM.md](SYSTEM.md); the old `strings … ZELLIJ_PLUGIN_AUTORENDER` verification is
retired with the patches.

## The pull carried a landmine

`dot_cargo/config.toml.tmpl` arrived hardcoded:

```toml
rustc-wrapper = "sccache"
jobs = 64
```

Neither holds here. `sccache` is not installed on `midnight-future`, and a missing
`rustc-wrapper` fails *every* cargo invocation — that would have broken both fork builds
the moment it applied. `jobs = 64` also oversubscribes a 16-core M4 Max. Made it
host-aware rather than installing anything:

```
{{ if lookPath "sccache" -}}
rustc-wrapper = "sccache"
{{ end -}}
jobs = {{ output "getconf" "_NPROCESSORS_ONLN" | trim }}
```

Renders `jobs = 16` and no wrapper here; unchanged on a host that has sccache.

## Verification

* `chezmoi apply` clean, `chezmoi diff` empty afterwards.
* `nvim --headless +qa` silent, exit 0; no `codecompanion` match anywhere under
  `dot_config/`.
* `zsh -ic` reaches the prompt; `~/.config/zellij/widgets/git-status.sh` returns
  `main ●` in this repo.
* `~/.cargo/config.toml` contains only `jobs = 16` / `incremental = false`.

Nothing pushed — the rebased branch is 9 ahead of `origin/main` and stays local.
