# Bringing `baumkuchen` Up to the Current Stack ＾▽＾

*Date: 2026-08-07*

First session logged from `baumkuchen` (macOS 27.0, M5 Pro, 15 cores). It had been idle
while every recent change landed on `midnight-future`, so it was behind on two axes at
once: unapplied dotfiles and a pre-scroll-stack binary.

## What was stale

* `chezmoi diff` → 258 lines: `.zshrc` (rustup/cargo PATH guards), `.cargo/config.toml`
  (new file), `.config/zellij/config.kdl` (`scroll_acceleration_factor 3.5`),
  `.config/ghostty/config` (`mouse-scroll-multiplier = precision:0.75,discrete:1`), the
  nvim tree (codecompanion removal, deprecation fixes), and the zjstatus permission
  script. All committed work this host simply never applied.
* `~/.local/bin/zellij` was 0.44.3 but `strings … scroll_acceleration_factor` → **0**.
* `~/dev/zellij` sat on the force-pushed `28baaa76`, dirty only in the 13 regenerated
  `zellij-utils/assets/plugins/*.wasm` built-ins.

Order mattered: the pending `config.kdl` carries a key only the new binary parses, so
rebuild before apply.

## Rebuild

`git checkout -- zellij-utils/assets/plugins/` → `fetch` → `reset --hard
origin/hylian/latency` → `302f6e63`. `~/.cargo/config.toml` applied first so the build
picked up `jobs = 15`; unlike `midnight-future`, sccache **is** installed here, so
[dot_cargo/config.toml.tmpl](../dot_cargo/config.toml.tmpl) rendered the wrapper — the
`lookPath` guard doing exactly its job on two hosts that differ.

`cargo xtask install ~/.local/bin/zellij`: 41s wasm plugins + 2m46s workspace, 3m30 wall
with a cold sccache. Then the order from [SYSTEM.md](SYSTEM.md) — hash the pair *before*
signing (`0715d7c7…` both) → `codesign -s - --force` → `codesign -v` → `--version`
(0.44.3) → marker `scroll_acceleration_factor` **2 hits**.

zjstatus needed nothing: clean at `8a03875`, level with `origin/hylian/autorender`,
installed `.wasm` hashing identically to `target/` (`61488ed2…`).

## Apply & verification

`chezmoi apply` clean, drift → 0. Then, on the new binary:

* `zellij setup --check` → `[CONFIG FILE]: Well defined.` with
  `scroll_acceleration_factor 3.5` present, which only this binary understands.
* Permission cache already grants `RunCommands` to the **local**
  `~/.config/zellij/plugins/zjstatus.wasm` path, not just the release URLs.
* Git segment, fresh 200x50 PTY session in `~/dev/zellij`: blank at boot in both test
  repos, then ` hylian/latency ● ` the moment a `cd` lands — the documented
  boot-blank-until-first-`cd` behaviour, dirty marker correct (`target/`).
* Animation queue live: 6 wheel-up events 4ms apart into a 120x40 PTY produce **470**
  distinct render timestamps against **14** for a single event over the same 7s window.

## State

Two host-specific facts folded into [SYSTEM.md](SYSTEM.md): `baumkuchen` has no
`~/.cargo/bin/zellij` (the `~/.local/bin` copy is the only one), and full-rebuild timing
now covers the M5 Pro. Running servers still hold the old binary in memory; new sessions
get the scroll stack.
