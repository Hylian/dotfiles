# Opening `file://` URIs in Neovim Inside the Current Zellij Tab ٩(◕‿◕｡)۶

*Date: 2026-08-11*

## Motivation & Workflow

In Ghostty with `link-url = true`, clicking `file://` URIs (such as code references in terminal output, agent chats, or markdown files) previously routed to standard system defaults or external editors like GVim.

We wanted clicking any `file://` link inside Ghostty to automatically open the referenced file in Neovim in a new pane within the currently active Zellij tab, preserving line numbers (e.g. `file:///path/to/file#L123-L145` or `:123`).

## Architecture & Integration

1. **URI Handler (`~/.local/bin/zellij-edit`):**
   - Managed via `private_dot_local/bin/executable_zellij-edit`.
   - Parses `file://` URLs, stripping hostnames (`file://localhost/...`, `file://shined/...`), percent-decoding paths (`%20` -> spaces), and extracting line numbers from URL fragments (`#L123`, `#L123-L145`, `#123`) or path suffixes (`:123`, `:123:45`).
   - Discovers the active Zellij session (preferring `(current)` or `$ZELLIJ_SESSION_NAME`).
   - Invokes `zellij --session <session> action edit [-l <line>] [--cwd <parent_dir>] <path>`.
   - Falls back gracefully to spawning Ghostty + Neovim if no active Zellij session is found.

2. **Desktop Entry (`~/.local/share/applications/zellij-edit.desktop`):**
   - Managed via `private_dot_local/private_share/applications/zellij-edit.desktop.tmpl`.
   - Uses an absolute rendered path `Exec={{ .chezmoi.homeDir }}/.local/bin/zellij-edit %u`. This is critical: GUI applications spawned by Wayland/Sway compositors do not inherit the user's interactive shell `PATH` (missing `~/.local/bin`). Using a bare binary name causes `xdg-open`'s `command -v` check to fail and fall back down the system MIME chain to `/usr/bin/gvim`.
   - Registers `MimeType` covering `x-scheme-handler/file`, `text/plain`, and all common source code MIME types.

3. **MIME Association (`~/.config/mimeapps.list`):**
   - Managed via `dot_config/mimeapps.list` (Linux-only in `.chezmoiignore`).
   - Configures `x-scheme-handler/file=zellij-edit.desktop` as well as all specific text and source code MIME types (`text/x-c++src`, `text/x-c`, `text/x-python`, `text/x-rust`, `text/markdown`, etc.) under `[Default Applications]` and `[Added Associations]`, since XDG resolvers query the file's specific MIME type when the file exists on disk.

4. **Desktop Database & Portal Hook (`run_onchange_after_30-update-desktop-database.sh.tmpl`):**
   - Runs `update-desktop-database` and `update-mime-database` on `~/.local/share`.
   - Restarts `xdg-desktop-portal` user units (`xdg-desktop-portal`, `xdg-desktop-portal-gtk`, `xdg-desktop-portal-wlr`) to flush long-lived in-memory MIME caches.

## Verification

- `gio mime x-scheme-handler/file` and `xdg-mime query default text/x-c++src` confirm `zellij-edit.desktop` is registered as the default handler.
- Tested URI parsing across percent-encoded spaces, fragment ranges (`#L123-L145`), single line fragments (`#L42`), colon notation (`:42`), and plain paths.
- End-to-end verified via Ctrl+clicking `file://` links inside Ghostty running in an active Zellij session, seamlessly opening the target file in Neovim in a new tiled pane at the specified line number.
