# Activate on `midnight-future` and Add Guarded Bun Setup

*Date: 2026-10-17*
*Host: `midnight-future` (macOS Apple Silicon Client)*

- **Upstream & Fork Fleet Sync:**
  - Fast-forwarded `main` (`ad9a161..dae90be`) with recent Neovim, Zellij, and Zsh updates.
  - Applied upstream changes to `~/.config/nvim`, `~/.config/zellij`, and `~/.config/zsh`.
  - Rebuilt and installed `zellij` (`hylian/latency` at `ac0c3596`) via `.agents/skills/chez/scripts/manage-forks.sh sync` and updated the local build receipt (`zjstatus` already up to date at `f38e8e99`).
- **Guarded Bun Environment (`dot_zshrc.tmpl`):**
  - Replaced the unmerged Bun installer snippet at the bottom of `~/.zshrc` with a clean `if [[ -d "$HOME/.bun" ]]; then ... fi` block in [dot_zshrc.tmpl](../dot_zshrc.tmpl) setting `BUN_INSTALL`, prepending `$BUN_INSTALL/bin` to `PATH`, and sourcing `$BUN_INSTALL/_bun` completions when present.
  - Applied `~/.zshrc` via `chezmoi apply` and verified with `zsh -n ~/.zshrc` and `chezmoi status`.
