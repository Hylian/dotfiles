# Activate Dotfiles on `shined-mac`

*Date: 2026-10-20*
*Host: `shined-mac` (macOS Apple Silicon Client)*

- **Upstream & Fork Fleet Sync:**
  - Pulled upstream `main` (`ecd0c80..7ec446a`), bringing in centralized `.chezmoidata.toml` colorschemes and `~/.local/bin/theme` switcher (10 schemes including Everforest Light/Dark and 8 seasonal Madoromi Japanese ink palettes), native Zellij `LinkHints` (`Alt + o` / `f`), `zellij-autolock` 0.3.0 (`lock_regex "^(nvim|vim)$"`), Neovim persistent undo and non-blocking swap management (`config/swap.lua`), compact `nvim-notify` layout, `:cppwd` buffer filepath yank, `gshow` 85% vertical split with unified gitconfig Delta styling, and `^v` (`vim-fzf`) mtime sorting with `<Tab>` current-directory/recursive toggle.
  - Rebuilt and installed `zellij` (`hylian/latency` at `c11e9729`) via `.agents/skills/chez/scripts/manage-forks.sh sync` and updated `~/.local/state/builds/zellij.json` (`zjstatus` already up to date at `f38e8e99`).
- **Chezmoi & Shell Verification:**
  - Applied all pending upstream dotfile changes via `chezmoi apply --no-pager`.
  - Verified `zsh -n ~/.zshrc`, `nvim --headless +qa`, `chezmoi status`, and `manage-forks.sh status`.
- **Fix `theme` CLI on macOS Python 3.9 & Per-File `zcompile` ([private_dot_local/bin/executable_theme](../private_dot_local/bin/executable_theme)):**
  - **Root Cause 1 (`tomllib` on Python 3.9):** On `shined-mac`, `python3` resolves to Apple Command Line Tools `/usr/bin/python3` (`Python 3.9.6`), where `import tomllib` (introduced in Python 3.11) fails with `ModuleNotFoundError: No module named 'tomllib'`. Added a zero-dependency `load_toml()` helper that uses `tomllib` when available and falls back to a regex TOML table/key-value parser on Python 3.9/3.10.
  - **Root Cause 2 (Multi-Arg `zcompile` Archive Hazard):** In Zsh, `zcompile file1 file2 file3` treats `file1` (`~/.zshrc`) as the target `.zwc` archive for `file2` and `file3` rather than compiling each file separately, which would overwrite `~/.zshrc.zwc` with `widgets` and `aliases`. Changed `apply_theme` to loop `for f in ~/.zshrc ~/.config/zsh/widgets ~/.config/zsh/aliases; do [[ -f "$f" ]] && zcompile "$f"; done`.

