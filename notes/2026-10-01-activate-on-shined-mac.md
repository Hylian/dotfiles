# Activate Dotfiles on `shined-mac`

*Date: 2026-10-01*
*Host: `shined-mac` (macOS Apple Silicon Client)*

- **Upstream & Fork Fleet:**
  - Upstream `main` was already current.
  - Software forks (`zellij` at `c85ff12c`, `zjstatus` at `f38e8e99`) were already up to date with receipts recorded in `~/.local/state/builds/`.
- **Chezmoi Sync:**
  - Applied pending Neovim configuration updates via `chezmoi apply --no-pager` ([dot_config/nvim/lua/config/markdown.lua](../dot_config/nvim/lua/config/markdown.lua) compound code-span delimiter and bold auto-wrapping fixes, [dot_config/nvim/lua/plugins/init.lua](../dot_config/nvim/lua/plugins/init.lua) render-markdown config).
  - Headless Neovim verified cleanly via `nvim --headless +qa`.
  - `chezmoi status` is completely clean.
