# Activate Dotfiles and Forks on `baumkuchen`

*Date: 2026-10-01*

- Upstream `main` was already current. Submodules were uninitialized and no
  build receipts existed; the installed binaries were stale (Zellij `0.44.3`
  from 2026-08-19, zjstatus from 2026-08-02), so `record` would have lied.
  `manage-forks.sh sync` initialized the submodules at the pins and built both:
  Zellij `c85ff12c` (`0.45.1`, 252s with a cold sccache) and zjstatus
  `f38e8e99` (51s). `manage-forks.sh check` passes.
- Applied the pending chezmoi backlog (Cargo, git shared config, Neovim, Zellij,
  Zsh) **except** `aerospace.toml`: the deployed file carries a local-only
  floating rule for `com.google.GeminiMacOS` that was never in the source
  template, and applying would delete it. Left for Rachel to decide (port into
  the `baumkuchen` block or drop).
- Verification: `zsh -n` on rc files and widgets, login shell resolves
  `~/.local/bin/zellij`, `zellij --version` = `0.45.1`, zjstatus is a wasm
  module, headless Neovim starts with empty `:messages` after Lazy installed
  `git-conflict.nvim`/`diffview.nvim` and treesitter fetched its parsers.
- Running Zellij servers keep the old binary/plugin in memory until restarted.
- Follow-up: Rachel chose to drop the Gemini rule; `aerospace.toml` applied
  and `aerospace reload-config` succeeded. `chezmoi status` is clean.
