# Activate Dotfiles and Software Forks on `shined`

*Date: 2026-10-01*
*Host: `shined` (Linux x86_64 Development Workstation)*

- Upstream `main` was already current. Submodules were uninitialized and no
  build receipts existed in `~/.local/state/builds/`; the installed binary was
  stale (Zellij `0.44.3` from 2026-07-28).
- **Fork Fleet & Inode Replacement Hardening ([manage-forks.sh](../.agents/skills/chez/scripts/manage-forks.sh)):**
  - When building Zellij on a machine with an active Zellij session running,
    `cargo xtask install` previously attempted to overwrite the binary in place,
    failing with `ETXTBSY` (`Text file busy (os error 26)`).
  - Hardened `build_zellij()` in `manage-forks.sh` to install into a temporary file
    (`${target}.tmp.$$`) and replace `$target` on a fresh inode (`rm -f "$target" && mv "$tmp_target" "$target"`).
    Running Zellij sessions continue executing undisturbed on their unlinked inode
    without triggering Linux `ETXTBSY` or macOS vnode CDHash signature mismatch `SIGKILL`.
  - Added the `wasm32-wasip1` Rust target via `rustup target add wasm32-wasip1`.
  - Built and installed both fleet pins: Zellij `c85ff12c` (`0.45.1`) and zjstatus
    `f38e8e99`. Receipts recorded in `~/.local/state/builds/{zellij,zjstatus}.json`;
    `manage-forks.sh check` passes cleanly.
- **Chezmoi Backlog:**
  - Applied the pending configuration backlog via `chezmoi apply` (Cargo CPU jobs,
    Dunst monitor pinning, Ghostty scroll scaling, Neovim Diffview / Git Conflict /
    80-col Markdown auto-wrap / smart project root discovery, Zellij OSC 133 prompt
    integration, and Zsh Antigen bypass / startup optimizations).
- **Verification:**
  - `manage-forks.sh check` exits 0; both forks report `✨ UP TO DATE`.
  - `chezmoi status` is completely clean.
  - `zsh -n` passes cleanly across all shell files and widgets.
  - `nvim --headless` starts cleanly with zero warnings/errors after Lazy fetched
    `smart-splits.nvim` and `git-conflict.nvim`.
  - `zellij --version` reports `0.45.1` and `zjstatus.wasm` is a valid wasm module.
  - Running Zellij servers keep the prior binary in memory until restarted.
