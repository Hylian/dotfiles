# Activate Dotfiles on `midnight-future`

*Date: 2026-10-02*
*Host: `midnight-future` (macOS Apple Silicon Client)*

- **Upstream & Fork Fleet:**
  - Fast-forwarded upstream `main` (`5daa591..ba4a9af`), bringing in recent Markdown auto-wrap improvements and AeroSpace `cmd-ctrl-enter` updates.
  - Maintained software forks (`zellij` at `c85ff12c`, `zjstatus` at `f38e8e99`) were already up to date with local receipts in `~/.local/state/builds/`.
- **Chezmoi Sync:**
  - Applied pending updates via `chezmoi apply --no-pager`:
    - [dot_cargo/config.toml.tmpl](../dot_cargo/config.toml.tmpl) (`sccache` wrapper path).
    - [dot_config/nvim/lua/config/markdown.lua](../dot_config/nvim/lua/config/markdown.lua) (compound code-span delimiter and bold auto-wrapping fixes).
    - [dot_config/nvim/lua/plugins/init.lua](../dot_config/nvim/lua/plugins/init.lua) (render-markdown options).
  - Headless Neovim verified cleanly via `nvim --headless +qa`.
  - `chezmoi status` is completely clean.
