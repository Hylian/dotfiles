# Update Zellij Pane Title with Current Neovim Filepath (｡•̀ᴗ-)✧

*Date: 2026-10-27*  
*Host: `shined` (Linux x86_64 Workstation)*

---

## 1. Context & Design Choice

Previously, Neovim left `vim.opt.title` disabled (`false`), so a Zellij pane
running Neovim either kept the static command line emitted by Zsh's
`omz_termsupport_preexec` (e.g. `nvim foo.rs` or `nvim`) or kept Zellij's static
`Editing: /path/to/file` fallback from `zellij action edit` / `LinkHints`, never
updating as buffers, splits, or tabs changed inside the editor.

### Why Native ANSI OSC 0/2 (`vim.opt.title`) Over `zellij action rename-pane`

1. **Pane-Scoped PTY Delivery (Zero Focus Races):** `zellij action rename-pane`
   mutates `pane_name` on whichever pane currently holds client focus, so an
   unfocused Neovim instance reloading or starting up can rename the wrong pane.
   Writing ANSI OSC 0/2 directly to Neovim's stdout updates `grid.title` on that
   exact `TerminalPane` PTY unconditionally.
2. **Clean Exit & Manual-Rename Semantics:** Setting `pane_name` via
   `rename-pane` permanently shadows Zsh's OSC 2 prompt title after `:q` (or on
   crash/`SIGKILL`) unless manually undone. With `grid.title`, Neovim's TUI
   pushes and pops Zellij's native CSI `22t`/`23t` title stack on enter/exit, Zsh
   `precmd` immediately restores `%n@%m:%~`, and any explicit manual pane rename
   (`Alt + p` -> `c`) still takes priority as intended.
3. **Zero Subprocess Overhead & Native Middle Truncation:** Updating
   `vim.o.titlestring` writes ~40 bytes inline to the TUI stream with zero
   process forks or IPC roundtrips. Setting `vim.opt.titlelen = 0` disables
   Neovim's 85%-column pre-truncation so Zellij's `PaneFrame` renderer performs
   exact border-width `[..]` middle truncation, keeping both the leading root
   and trailing filename visible even in narrow splits.
4. **Autolock Compatibility:** `zellij-autolock` 0.3.x matches against OS
   foreground `pane_command` (`lock_regex "^(nvim|vim)$"`), so pane title
   changes never affect `LOCKED`/`NORMAL` mode transitions.

---

## 2. Implementation

1. **[dot_config/nvim/lua/config/title.lua](../dot_config/nvim/lua/config/title.lua):**
   - Guarded on `vim.env.ZELLIJ` / `vim.env.ZELLIJ_PANE_ID` so standalone
     non-Zellij Neovim invocations remain untouched.
   - Formats active file buffers with `vim.fn.fnamemodify(path, ':p:~')`
     (`~`-collapsed full path, matching `lualine` `path = 3` and Zsh `%~`).
   - Resolves real target filepaths for `diffview.nvim` views
     (`cur_entry.absolute_path`) and `fugitive://` Git object URIs, formats
     `:help` buffers as `help: <filename>` (avoiding ephemeral AppImage mount
     paths), and falls back to `nvim` on unnamed `[No Name]` buffers.
   - Preserves the underlying editor filepath across floating windows
     (`fzf-lua`, `noice`, LSP hover) and auxiliary non-file splits (`qf`,
     `NvimTree`, `toggleterm`) via alternate-window (`winnr('#')`) and
     current-tabpage inspection, preventing `term://...` command strings from
     flashing in the pane frame.
   - Updates `vim.o.titlestring` event-driven (escaping `%` literals and
     deduplicating unchanged titles) on `VimEnter`, `BufEnter`, `BufWinEnter`,
     `BufFilePost`, `BufWritePost`, `WinEnter`, `TabEnter`, and `DirChanged`,
     priming `titlestring` before enabling `vim.opt.title = true` to avoid any
     frame-0 `- Nvim` title flash.
2. **[dot_config/nvim/init.lua.tmpl](../dot_config/nvim/init.lua.tmpl):**
   - Wired `require('config.title').setup()` alongside `config.root`,
     `config.markdown`, and `config.swap`.
3. **[SYSTEM.md](SYSTEM.md):**
   - Documented `config.title` in Section `2.E`.

---

## 3. Verification

- `chezmoi diff --no-pager` & `chezmoi apply --no-pager`: Applied cleanly.
- `nvim --headless +qa`: Exited `0` cleanly.
- Real PTY end-to-end verification (`xterm-256color` & `xterm-ghostty`):
  - Outside Zellij (`ZELLIJ` unset): Zero OSC title sequences emitted.
  - Bare `nvim` inside Zellij: Emits `nvim`.
  - `nvim <file>`, `:e`, `:vsp`, window switching, `:copen`/`:cclose`, floating
    terminal popup (`fzf-lua` simulation), and `:help`: Emits exact `~`-shortened
    filepaths with zero startup flash and zero `term://` float flicker.
