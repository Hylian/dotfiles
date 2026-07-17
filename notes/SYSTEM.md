# System Profile & Living Ground Truth ٩(◕‿◕｡)۶

*Last Updated: 2026-07-17*

This document represents the current, living ground truth for this cross-platform dotfiles repository (`Hylian/dotfiles`). It is maintained autonomously by `chez` to preserve preferences, quirks, and architectural decisions across sessions.

---

## 1. Host & Machine Matrix

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
* **Status Bar:** `zjstatus` WASM plugin configured with 1s interval polling.
* **Decoupled Shell IPC:** Zsh prompts are decoupled from Zellij IPC status hooks to maintain maximum shell startup and prompt redraw speed.
* **Focus Sequence Handling:** Zsh registers a silent `zle-focus-out` no-op widget to absorb terminal `\e[O` focus-loss escapes and prevent pink `[!]` bell alert flashes.
* **Scrollback Editor:** `scrollback_editor "nvim"`.

### D. Shell (Zsh) & Prompt (Starship)
* **Shell Framework:** `zsh` + `antigen` with cached initialization in `$XDG_CACHE_HOME/zsh`.
* **Prompt:** `starship` with active prompt character `❯` (U+276F).
* **CLI Utilities:** `fzf` (with ripgrep/fd integration), `zoxide` (aliased to `j`), `bat`, `direnv`.

### E. Editor (Neovim 0.11.x) & Clipboard Stack
* **Clipboard Mode:** `vim.opt.clipboard = 'unnamedplus'`.
* **Remote Yanks (OSC 52 Copy):** Over SSH (`SSH_TTY`, `SSH_CONNECTION`, `SSH_CLIENT`, `NVIM_SSH_OVERRIDE`), yanks broadcast OSC 52 sequences via `vim.ui.clipboard.osc52.copy('+')` and a `TextYankPost` autocommand. This immediately updates the connected macOS pasteboard over SSH.
* **Instant Local Paste:** Paste operations are decoupled from OSC 52 read queries (`osc52.paste`) to prevent terminal query timeouts. Pasting queries local clipboard tools (`wl-paste`, `pbpaste`, `xclip`, `xsel`) and falls back immediately to Neovim's unnamed register (`"`).

---

## 3. Standard Keybinding Conventions

### Zellij
* `Alt` is the primary modifier for pane, tab, and navigation management.
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
* `^k`: `zoxide-fzf-curdir` (interactive directory jump scoped to current directory subtree).
* `^j`: `zoxide-fzf` (interactive global zoxide query and jump).
* `^g`: `cd-fzf` (interactive directory navigator).
* `^f`: `rg-fzf` (interactive ripgrep file/line search into Neovim).
* `^v`: `vim-fzf` (interactive fd file search into Neovim).
* `^l`: `git-pick-fzf` (interactive git commit picker).
