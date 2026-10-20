# Activate Dotfiles on `shined-mac`

*Date: 2026-10-20*
*Host: `shined-mac` (macOS Apple Silicon Client)*

- **Upstream & Fork Fleet Sync:**
  - Pulled upstream `main` (`ecd0c80..7ec446a`), bringing in centralized `.chezmoidata.toml` colorschemes and `~/.local/bin/theme` switcher (10 schemes including Everforest Light/Dark and 8 seasonal Madoromi Japanese ink palettes), native Zellij `LinkHints` (`Alt + o` / `f`), `zellij-autolock` 0.3.0 (`lock_regex "^(nvim|vim)$"`), Neovim persistent undo and non-blocking swap management (`config/swap.lua`), compact `nvim-notify` layout, `:cppwd` buffer filepath yank, `gshow` 85% vertical split with unified gitconfig Delta styling, and `^v` (`vim-fzf`) mtime sorting with `<Tab>` current-directory/recursive toggle.
  - Rebuilt and installed `zellij` (`hylian/latency` at `c11e9729`) via `.agents/skills/chez/scripts/manage-forks.sh sync` and updated `~/.local/state/builds/zellij.json` (`zjstatus` already up to date at `f38e8e99`).
- **Chezmoi & Shell Verification:**
  - Applied all pending upstream dotfile changes via `chezmoi apply --no-pager`.
  - Verified `zsh -n ~/.zshrc`, `nvim --headless +qa`, `chezmoi status`, and `manage-forks.sh status`.
