# Inherit Active Pane Working Directory on Zellij New Tab (`Alt+n`)

**Date:** 2026-09-08  
**Context:** Zellij multiplexer tab navigation and layout behavior.

## Problem & Observation

When pressing `Alt+n` in Zellij from an active terminal pane in a subdirectory (e.g. `sidecar/...` or `dot_config/zsh`), the newly spawned tab consistently opened in `$HOME` (`~`) instead of inheriting the active pane's current working directory.

Interestingly, `Alt+s` (`NewPane`) correctly opened a new pane in the current working directory, and `<A-n>` inside Neovim also opened in Neovim's working directory because Neovim explicitly dispatched `zellij action new-tab --cwd <dir>`.

## Root Cause Analysis

1. **Zellij Server CWD Resolution:**
   - In Zellij's server implementation (`zellij-server/src/pty.rs`), `Pty::spawn_terminals_for_layout` handles `NewTab` requests.
   - When a tab layout or tab does *not* specify an explicit `cwd` (`cwd` is `None`), `pty.fill_cwd(&mut default_shell, client_id)` dynamically reads the focused pane's child PID (`self.active_panes.get(&client_id)`) and inspects `/proc/<pid>/cwd` (or OS input) to spawn the new tab's shell in that exact directory.
2. **Layout-Level CWD Override:**
   - In [dot_config/zellij/layouts/default.kdl.tmpl](../dot_config/zellij/layouts/default.kdl.tmpl), the layout root was declared as:
     ```kdl
     layout {
         cwd "~"
         default_tab_template { ... }
     }
     ```
   - In `zellij-utils/src/kdl/kdl_layout_parser.rs`, the layout parser saw `global_cwd = Some("~")` and applied `add_cwd_to_layout` to `default_tab_tiled_panes_template`.
   - As a result, every new tab created with `Alt+n` (`Action::NewTab`) inherited `Some("~")` from the template, completely overriding the server's dynamic focused-pane CWD detection.

## Solution

1. **Remove Layout-Level `cwd "~"`:**
   - Removed `cwd "~"` from the root `layout { ... }` block in [dot_config/zellij/layouts/default.kdl.tmpl](../dot_config/zellij/layouts/default.kdl.tmpl).
   - Without the forced global override, `default_tab_template` leaves `cwd` unconstrained (`None`).
   - When `Alt+n` is triggered, Zellij server automatically invokes `fill_cwd` to discover the active pane's runtime working directory, spawning the new tab's shell in the exact same directory as the focused pane.
2. **Documented & Validated:**
   - Validated configuration syntax via `zellij setup --check`.
   - Applied cleanly to `~/.config/zellij/layouts/default.kdl` via `chezmoi apply`.
   - Documented in [notes/SYSTEM.md](SYSTEM.md).
