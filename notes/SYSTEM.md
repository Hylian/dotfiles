# System Profile & Living Ground Truth ٩(◕‿◕｡)۶

*Last Updated: 2026-07-26*

This document represents the current, living ground truth for this cross-platform dotfiles repository (`Hylian/dotfiles`). It is maintained autonomously by `chez` to preserve preferences, quirks, and architectural decisions across sessions.

---

## 1. Host & Machine Matrix

* **Collaborator / Engineer:** Rachel — Senior firmware engineer.
* **Workstation (Linux):** `shined` — Primary Linux development machine.
* **Secondary Linux:** `eterna` — Linux machine.
* **Client (macOS):** `baumkuchen` — Apple silicon laptop running macOS 27 (Ghostty + aerospace/sketchybar/borders).
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
* **Build Provenance (macOS client):** Zellij is built from the personal fork `Hylian/zellij`, branch `hylian/latency`, and installed to `~/.local/bin/zellij` (which precedes `/opt/homebrew/bin` on PATH); the brew package has been removed on this host. Rebuild with `cargo xtask install ~/.local/bin/zellij`, which needs `protobuf` (brew) and `mandown` (`cargo install --locked mandown`). **After installing, re-sign:** the install overwrites the binary in place, invalidating the cached code signature so the next exec dies with SIGKILL (exit 137) — `codesign -s - --force ~/.local/bin/zellij`, or delete the old binary first. Beware `brew uninstall` here: it autoremoves orphaned formulae, and removing zellij also swept `python@3.14`, `python@3.13`, `certifi`, `pydantic`, `cffi` and `pycparser` (all reinstalled since). Other hosts may still run stock zellij; every config below is written to work either way. The branch now carries **only** the two genuine latency commits (`/proc` cwd reads, `close_range` syscall) — the two plugin-render patches were dropped in favour of fixing zjstatus itself. Backups: `hylian/latency-pre-zjstatus` (with the render patches), `hylian/latency-pre-cleanup` (pre-review state); the moot upstream branch `fix/render-plugin-on-command-result` is still present, undeleted.
* **zjstatus Build & Autorender (macOS client):** zjstatus is built from the personal fork `Hylian/zjstatus`, branch `hylian/autorender`, and installed to `~/.config/zellij/plugins/zjstatus.wasm`. Its one patch sets `should_render` in the `Event::RunCommandResult` arm when the stored result differs in `exit_code`, `stdout` or `stderr` — upstream stores the value and never asks for a repaint, so a new branch waits for the render timer. `context` is excluded from the comparison because it carries a per-invocation timestamp. Build with `cargo build --release` (pins toolchain 1.95.0 + `wasm32-wasip1`); `cargo test` needs the `wasmtime` runner from brew. This replaced two zellij fork patches that forced the render server-side for every plugin — the plugin API already returns `should_render`, so the fix belongs here. Pane-switch repaint: 700ms stock, **47ms** patched, zero extra processes. See [2026-07-25-move-autorender-fix-into-zjstatus.md](2026-07-25-move-autorender-fix-into-zjstatus.md).
* **Plugin Selection & Permissions:** [dot_config/zellij/layouts/default.kdl.tmpl](../dot_config/zellij/layouts/default.kdl.tmpl) uses chezmoi's `stat` to pick the local build when present and fall back to the zjstatus release URL otherwise, and declares `ZJSTATUS_AUTORENDER` through zjstatus's own `command_git_branch_env` — no server patch is involved in advertising the capability. **Zellij keys its plugin permission cache by plugin location**, so switching URL → local path needs a fresh `RunCommands` grant, and the prompt is drawn inside the one-row status bar pane where it cannot be seen or answered; the bar just renders empty. [run_onchange_after_20-zjstatus-plugin-permissions.sh.tmpl](../run_onchange_after_20-zjstatus-plugin-permissions.sh.tmpl) seeds the cache entry and no-ops without a local build.
* **Status Bar Git Widget:** `command_git_branch` runs `dot_config/zellij/widgets/executable_git-status.sh` (rendered to `~/.config/zellij/widgets/git-status.sh`) rather than an inline KDL command, with `command_git_branch_interval "5"` and `--no-optional-locks` on every git call. zjstatus invalidates focused-cwd widgets only when the cwd genuinely changes, but then re-spawns the command on every render until a result lands — measured at ~18 invocations per pane switch — so the script memoises in two tiers: a one-slot output memo (`$XDG_RUNTIME_DIR/zjstatus-git-memo.$ZELLIJ_SESSION_NAME`, TTL 1s) keyed by cwd that absorbs the burst with no git process, and a per-repository dirty memo (`$GIT_DIR/zjstatus-dirty`, TTL 3s) guarding the O(worktree) `diff-index` scan. The branch is read from `$GIT_DIR/HEAD` with builtins. **The output memo must stay per session** — a shared slot makes concurrent sessions invalidate each other every render, which with the repaint kick below becomes a feedback loop (measured 4 invocations/s while idle). Sustained switching in a 40k-file repo costs ~33% of a core, down from ~197%. See [2026-07-24-bound-zjstatus-git-widget-cost.md](2026-07-24-bound-zjstatus-git-widget-cost.md).
* **Status Bar Repaint Kick (release-zjstatus fallback):** A zjstatus that stores a command result without scheduling a render leaves a new branch waiting for the 1s render timer — median 700ms after a pane switch. When `ZJSTATUS_AUTORENDER` is **absent** the widget pipes `zjstatus::pipe::zjs_render_kick::-` (a pipe name no format references, so it only forces a render) whenever its value or directory changed, giving a median of 67ms; with the patched plugin the marker is set by the layout and the kick is skipped entirely. `zellij pipe` is a *streaming* client: it needs `</dev/null` and a plain-sh watchdog (macOS has no `timeout(1)`) or it blocks forever against a dead or wedged server, holding a socket each time — this exhausted file descriptors and crashed a server once. The watchdog subshell must also redirect **stdout**, since zellij reads the command's output to EOF and a grandchild holding that pipe stalls the result for the full watchdog window. See [2026-07-24-repaint-git-widget-on-change.md](2026-07-24-repaint-git-widget-on-change.md).
* **Event-Driven Refresh:** Zsh `precmd` runs `_zellij_osc7_cwd` (emits `\e]7;file://...` via pure parameter expansion, no subprocess, so Zellij learns the pane CWD synchronously and can invalidate immediately on pane switch) and `_zellij_refresh_git_branch` (deletes both widget memos with `zf_rm`, then pipes `zjstatus::rerun::git_branch`). `chpwd` runs `zellij_tab_name_update` and `_zellij_track_git_dirty_cache`, which resolves the repo memo path once per directory so the per-prompt hook stays fork-free. `_zellij_refresh_git_branch` is defined **only** in `dot_zshrc.tmpl` and carries its own `$ZELLIJ` guard; the fzf widgets call it directly.
* **Scrollback Editor:** `scrollback_editor "nvim"`.
* **Keyboard Protocol & SSH Repeat Stability:** `support_kitty_keyboard_protocol` is explicitly set to `false`. This prevents multiplexer-level Kitty protocol negotiation and ensures Ctrl modifier keys emit atomic single-byte C0 control characters (e.g. `^K` -> `\x0b`). Over SSH, rapid key repeats (such as scrolling in `fzf` pickers) avoid TCP packet fragmentation and escape sequence delay timeouts, completely eliminating dropped escapes and partial escape string leaks.

### D. Shell (Zsh) & Prompt (Starship)
* **Shell Framework:** `zsh` + `antigen` with cached initialization in `$XDG_CACHE_HOME/zsh`.
* **Git Configuration:** Chezmoi manages shared core defaults and theme-aware Delta settings in `~/.config/git/shared_config` (via `dot_config/git/shared_config.tmpl`). Per-machine configuration remains in `~/.gitconfig` (unmanaged), which optionally includes the shared config via `[include] path = ~/.config/git/shared_config`. Shared defaults set `splitIndex = false`, `untrackedCache = false`, and `fsmonitor = false` under `[core]` to guarantee read-only index operations across all hosts and prevent lock contention with background prompt/status bar reruns. Accepted tradeoff: `diff-index` trusts the index stat cache, so a worktree whose files were re-stamped without an index write (a `cp -r`, an external checkout) can read as dirty in the status bar until any ordinary git command refreshes the index.
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
* `^k`: `zoxide-fzf-curdir` (interactive directory jump scoped to current directory subtree; calls `_zellij_refresh_git_branch`, which drops the widget memos and pipes `zjstatus::rerun::git_branch`, for instant branch status refresh).
* `^o`: `zoxide-fzf` (interactive global zoxide query and jump; same instant refresh path as `^k`).
* **`^j` is reserved for `accept-line` and MUST NOT be bound to a widget.** `^J` is LF, and the tty line discipline runs in cooked mode with `ICRNL` between `accept-line` and the next ZLE read — an Enter autorepeated into that window is enqueued as LF and dispatched as `^J`, making Enter and Ctrl-J the same byte with no way to distinguish them. A held Enter therefore fires whatever `^j` is bound to; widening the window (hook forks on `chpwd`) widens the race. `widgets.tmpl` rebinds `^j` to `accept-line` explicitly in all three keymaps so re-sourcing it in a live shell cannot leave a stale binding. See [2026-07-26-held-enter-triggers-zoxide-widget.md](2026-07-26-held-enter-triggers-zoxide-widget.md). No other control key in this set has a CR relationship.
* `^g`: `cd-fzf` (interactive directory navigator).
* `^f`: `rg-fzf` (interactive ripgrep file/line search into Neovim).
* `^v`: `vim-fzf` (interactive fd file search into Neovim).
* `^n`: `git-pick-fzf` (interactive git commit picker with delta preview, pastes/appends selected commit SHA(s) to current line).
* `^b`: `git-branch-fzf` (interactive git branch picker sorted with current branch on top, local branches by most recent, then remote branches, with pretty short log preview).
