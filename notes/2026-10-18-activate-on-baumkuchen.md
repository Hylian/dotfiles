# Activate Dotfiles on `baumkuchen`

*Date: 2026-10-18*
*Host: `baumkuchen` (macOS Apple Silicon Client)*

- **Upstream & Fork Fleet Sync:**
  - Pulled upstream `main` (`ad9a161..fa276b3`), bringing in Neovim persistent undo, non-blocking swap management (`config/swap.lua`), compact `nvim-notify` layout, LSP inlay hints (`;h`), `:cppwd` buffer filepath yank, `zellij-autolock` 0.3.x (`lock_regex "^(nvim|vim)$"`), `gshow` 85% vertical split, `^v` mtime sorting + `<Tab>` directory toggle, and guarded Bun / Homebrew `site-functions` `fpath` setup.
  - Rebuilt and installed `zellij` (`hylian/latency` at `ac0c3596`) via `.agents/skills/chez/scripts/manage-forks.sh sync` and updated `~/.local/state/builds/zellij.json` (`zjstatus` already up to date at `f38e8e99`).
- **Chezmoi & Shell Verification:**
  - Applied all pending upstream dotfile changes via `chezmoi apply --no-pager`.
  - Verified `zsh -n ~/.zshrc`, `nvim --headless +qa`, `chezmoi status`, and `manage-forks.sh status`.
