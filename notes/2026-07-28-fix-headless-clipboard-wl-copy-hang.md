# Un-guarded `wl-copy` / `wl-paste` Caused Neovim Deletes (`dw`, `cw`) to Hang over Headless SSH ٩(◕‿◕｡)۶

*Date: 2026-07-28*

## Symptom

When SSH'd into the Linux host (`shined`) without an active display session, performing delete/change operations (`dw`, `cw`, `dd`, `c`, `d`) inside Neovim caused the editor to hang indefinitely until `^C` was pressed.

## Mechanism

1. `vim.opt.clipboard = 'unnamedplus'` registers all delete operations (`d`, `c`, `x`, etc.) as writes to the `+` register.
2. In [dot_config/nvim/init.lua.tmpl](../dot_config/nvim/init.lua.tmpl), `get_copy_cmd()` and `get_paste_cmd()` had fallback clauses that checked `if vim.fn.executable('wl-copy') == 1` or `xclip` **without verifying if `WAYLAND_DISPLAY` or `DISPLAY` were set**.
3. Over an SSH connection without X11 or Wayland forwarding, `wl-copy` and `wl-paste` are installed binaries on `/usr/bin`, but executing `wl-copy` without `WAYLAND_DISPLAY` set blocks indefinitely waiting to open a socket to a Wayland compositor (exiting only on timeout or `SIGINT`).
4. Neovim's `vim.fn.system({'wl-copy'}, lines)` called inside `local_copy()` blocked synchronously, causing Neovim to freeze on every `dw` / `cw`.
5. A matching latent issue existed in `zsh_clipboard_copy` and `zsh_clipboard_paste` inside [dot_zshrc.tmpl](../dot_zshrc.tmpl).

## Fix

1. **Neovim ([dot_config/nvim/init.lua.tmpl](../dot_config/nvim/init.lua.tmpl)):** Removed un-guarded fallbacks to `wl-copy`/`xclip` in `get_copy_cmd()` and `get_paste_cmd()`. GUI display tools are now queried strictly when `WAYLAND_DISPLAY` or `DISPLAY` are non-empty string environment variables. Headless SSH sessions fall back cleanly to `~/.cache/clipboard` writing and ANSI OSC 52 TTY sequences.
2. **Zsh ([dot_zshrc.tmpl](../dot_zshrc.tmpl)):** Removed un-guarded `elif` branches for `wl-copy`/`xclip`/`wl-paste` in `zsh_clipboard_copy` and `zsh_clipboard_paste`.

## Verification

1. `chezmoi diff` and `chezmoi apply` completed cleanly.
2. `nvim --headless "+q"` exited 0.
3. Tested `time nvim --headless +":normal dw" +":q!"`: completed in **0.19s** with zero hangs or blocking.
