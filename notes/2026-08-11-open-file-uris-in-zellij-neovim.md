# Opening `file://` URIs in Neovim Inside the Current Zellij Tab ٩(◕‿◕｡)۶

*Date: 2026-08-11*

## Motivation & Workflow

In Ghostty with `link-url = true`, clicking `file://` URIs (such as code references in terminal output, agent chats, or markdown files) previously routed to standard system defaults or external editors.

We wanted clicking any `file://` link inside Ghostty to automatically open the referenced file in Neovim in a new pane within the currently active Zellij tab, preserving line numbers (e.g. `file:///path/to/file#L123-L145` or `:123`).

## Architecture & Integration

1. **URI Handler (`~/.local/bin/zellij-edit`):**
   - Managed via `private_dot_local/bin/executable_zellij-edit`.
   - Parses `file://` URLs, stripping hostnames (`file://localhost/...`, `file://shined/...`), percent-decoding paths (`%20` -> spaces), and extracting line numbers from URL fragments (`#L123`, `#L123-L145`, `#123`) or path suffixes (`:123`, `:123:45`).
   - Discovers the active Zellij session (preferring `(current)` or `$ZELLIJ_SESSION_NAME`).
   - Invokes `zellij --session <session> action edit [-l <line>] [--cwd <parent_dir>] <path>`.
   - Falls back gracefully to spawning Ghostty + Neovim if no active Zellij session is found.

2. **Desktop Entry (`~/.local/share/applications/zellij-edit.desktop`):**
   - Managed via `private_dot_local/private_share/applications/zellij-edit.desktop`.
   - Registers `MimeType=x-scheme-handler/file;text/plain;` and passes `%u` to `zellij-edit` with standard user bin directories ensured in `PATH`.

3. **MIME Association (`~/.config/mimeapps.list`):**
   - Managed via `dot_config/mimeapps.list` (Linux-only in `.chezmoiignore`).
   - Configures `x-scheme-handler/file=zellij-edit.desktop` and `text/plain=zellij-edit.desktop` under `[Default Applications]` and `[Added Associations]`.

4. **Desktop Database Hook (`run_onchange_after_30-update-desktop-database.sh.tmpl`):**
   - Updates `~/.local/share/applications` desktop database on Linux whenever application desktop entries change.

## Verification

- `gio mime x-scheme-handler/file` confirms `zellij-edit.desktop` is registered as default handler.
- Verified URI parsing across percent-encoded spaces, fragment ranges (`#L123-L145`), single line fragments (`#L42`), colon notation (`:42`), and plain paths.
- End-to-end test via `gio open "file:///tmp/test_file.txt#L3"` confirmed immediate new pane creation in the current Zellij tab in Neovim.
