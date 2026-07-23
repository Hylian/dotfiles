# System Profile & Living Ground Truth ٩(◕‿◕｡)۶

*Last Updated: 2026-07-23*

This document represents the current, living ground truth for this cross-platform dotfiles repository (`Hylian/dotfiles`). It is maintained autonomously by `chez` to preserve preferences, quirks, and architectural decisions across sessions.

---

## 1. Host & Machine Matrix

* **Collaborator / Engineer:** Rachel — Senior firmware engineer.
* **Workstation (Linux):** `shined` — Primary Linux development machine.
* **Secondary Linux:** `eterna` — Linux machine.
* **Client (macOS):** Darwin machine — Client laptop / desktop.
* **Primary Remote Workflow:** macOS Client running **Ghostty** -> SSH into Linux Workstation (`shined`) -> **Zellij** multiplexer session.

### Privacy & Security Policy
* **Public Repository:** Absolute zero-secrets policy. No API tokens, credentials, or private work paths.
* **Work Separation:** Work-specific aliases and paths live in external untracked files (e.g. `~/.config/zsh/paths`, `aliases`, `gemini`).

---

## 2. Core Toolstack & Configuration

### A. Window Management & Compositors
* **Linux (Wayland):** `sway`, `niri`, `waybar`, `dunst`, `kanshi`, `swaylock`, `swayidle`, `tofi`.
* **macOS:** `aerospace`, `sketchybar`, `borders`.

### B. Terminal Emulator (Ghostty)
* **Configuration:** Shared chezmoi template (`dot_config/ghostty/config.tmpl`).
* **Key Features:** PragmataPro Mono font, custom dark/light theme palette, `clipboard-read = allow`, `shell-integration-features = true`.
* **Clipboard Interception:** Ghostty intercepts ANSI OSC 52 escape sequences emitted over SSH to update the macOS system pasteboard.

### C. Terminal Multiplexer (Zellij 0.44.x)
* **Status Bar & Event-Driven Refresh:** `zjstatus` `command_git_branch_interval` is set to `"5"` (updates background git status every 5 seconds) using `--no-optional-locks` on git commands (`symbolic-ref`, `rev-parse`, `diff-index`) to prevent index locking. Zsh registers `_zellij_refresh_git_branch` and `_zellij_osc7_cwd` (`\e]7;file://...`) in `precmd` to update CWD and trigger git branch reruns once per prompt, while `chpwd` registers `zellij_tab_name_update` to rename tabs on directory changes.
* **Scrollback Editor:** `scrollback_editor "nvim"`.
* **Keyboard Protocol & SSH Repeat Stability:** `support_kitty_keyboard_protocol` is explicitly set to `false`. This prevents multiplexer-level Kitty protocol negotiation and ensures Ctrl modifier keys emit atomic single-byte C0 control characters (e.g. `^K` -> `\x0b`). Over SSH, rapid key repeats (such as scrolling in `fzf` pickers) avoid TCP packet fragmentation and escape sequence delay timeouts, completely eliminating dropped escapes and partial escape string leaks.

### D. Shell (Zsh) & Prompt (Starship)
* **Shell Framework:** `zsh` + `antigen` with cached initialization in `$XDG_CACHE_HOME/zsh`.
* **Prompt:** `starship` with active prompt character `❯` (U+276F).
* **CLI Utilities & Themes:** `fzf` (with ripgrep/fd integration), `zoxide` (aliased to `j`), `bat`, `direnv`, and `delta` git previews (`gshow`, `^l` / `git-pick-fzf`) rendered via chezmoi templates (`aliases.tmpl`, `widgets.tmpl`) to match active `.theme` (e.g. Everforest light with `OneHalfLight` syntax highlighting). See [notes/EVERFOREST.md](EVERFOREST.md) for canonical palette tables.
* **Chezmoi Source Navigation:** `czcd` changes the current shell directly to `chezmoi source-path`, avoiding the nested `chezmoi cd` shell whose parent-process CWD confuses Zellij's `{focused_pane_cwd}` tracking.
* **History Configuration:** `HISTFILE=~/.zsh_history`, `HISTSIZE=50000`, `SAVEHIST=50000` with `EXTENDED_HISTORY`, `SHARE_HISTORY`, duplicate pruning, and startup `fc -R` to instantly load existing history into session memory for fzf (`^R`).
* **Vi Mode & Readkey Engine:** `zsh-vi-mode` (`zvm`) configured with `ZVM_READKEY_ENGINE=zle`, `ZVM_KEYTIMEOUT=0.01`, and `KEYTIMEOUT=1` (10ms) to delegate escape sequence handling to native ZLE, completely eliminating normal mode escape lag and key buffering issues when passing `Alt+Left` / `Alt+Right` tab switches to Zellij.
* **Vi Mode Clipboard & Visual Selection Highlight:** `zsh-vi-mode` (`zvm`) configured with `zsh_clipboard_copy` to broadcast ANSI OSC 52 sequences directly to `/dev/tty` upon yanks (`y`, `yy`, `yw`, visual mode `y`, deletions) AND persist to `~/.cache/clipboard`. `zvm` rebinds `vicmd` / `visual` mode `p` and `P` to `zvm_paste_clipboard_after` and `zvm_paste_clipboard_before`, querying local display servers (`wl-paste`, `xclip`, `pbpaste`) and falling back to `~/.cache/clipboard` so normal-mode `p` seamlessly pastes Neovim and workstation yanks. Visual selection highlights are themed with Everforest Light (`#e5e8c5` soft sage background, `#5c6a72` foreground, `bold`) to eliminate harsh red highlight defaults.

### E. Editor (Neovim 0.11.x) & Clipboard Stack
* **Clipboard Mode:** `vim.opt.clipboard = 'unnamedplus'`.
* **Universal Clipboard & Headless Sync:** Neovim yanks (`y`, `yy`, `d`, etc.) always copy directly to local display servers if available (`wl-copy`, `pbcopy`, `xclip`, `xsel`), persist to the shared workstation cache `~/.cache/clipboard`, AND broadcast ANSI OSC 52 sequences to `/dev/tty` for connected terminal emulators (Ghostty on macOS).
* **Instant Local & Headless Paste:** Paste operations query local display tools (`wl-paste`, `pbpaste`, `xclip`, `xsel`), fall back to `~/.cache/clipboard`, and then to Neovim's unnamed register (`"`), guaranteeing seamless interoperability with `zsh-vi-mode` (`p` in `zvm`) across headless SSH and GUI environments.
* **Long-Running & LSP Stability:** `clangd` is configured with `--enable-config` (reads project/user `.clangd` configs), `--pch-storage=memory` (fast RAM preamble caching), `-j=8` (bounds indexing concurrency to 8 worker threads), `--background-index-priority=low`, bounded completion/reference limits, and `vim.lsp.set_log_level("warn")` to eliminate memory bloat and event-loop lag.
* **Treesitter & Syntax Engine:** `nvim-treesitter` is pinned to the stable `master` branch with `lazy = false` for Neovim 0.11 compatibility, configured via `nvim-treesitter.configs` with `auto_install = true`, baseline `ensure_installed` parsers (`c`, `lua`, `vim`, `vimdoc`, `query`, `markdown`, `markdown_inline`), and a 100KB buffer size guard.

---

## 3. Standard Keybinding Conventions

### Zellij
* `Alt` is the primary modifier for pane, tab, and navigation management.
* `Alt + \``: `ToggleTab` — quick switch back and forth between the two most recent tabs.
* `Alt + e` (or `Ctrl + s` -> `e`): Instant `EditScrollback` — dumps active pane scrollback into Neovim.
* `Alt + q` (in scroll/editor): Quick quit.

### Neovim
* `Alt + q` (`<A-q>`): `:q<CR>` (close current window/buffer).
* `Alt + Shift + q` (`<A-S-q>` / `<A-Q>`): `:q!<CR>` (force quit).
* `Alt + w` (`<A-w>`): `:w<CR>` (save).
* `<C-k>`: Jump backwards to previous shell prompt line (`❯`).
* `<C-j>`: Jump forwards to next shell prompt line (`❯`).

### Zsh Interactive Widgets
* Deferred via `zvm_after_init_commands` to ensure persistence across `zsh-vi-mode` (`zvm_init`) keymap resets.
* `^k`: `zoxide-fzf-curdir` (interactive directory jump scoped to current directory subtree; dispatches `zjstatus::rerun::command_git_branch` for instant branch status refresh).
* `^j`: `zoxide-fzf` (interactive global zoxide query and jump; dispatches `zjstatus::rerun::command_git_branch` for instant branch status refresh).
* `^g`: `cd-fzf` (interactive directory navigator).
* `^f`: `rg-fzf` (interactive ripgrep file/line search into Neovim).
* `^v`: `vim-fzf` (interactive fd file search into Neovim).
* `^n`: `git-pick-fzf` (interactive git commit picker with delta preview, pastes/appends selected commit SHA(s) to current line).
* `^b`: `git-branch-fzf` (interactive git branch picker sorted with current branch on top, local branches by most recent, then remote branches, with pretty short log preview).
