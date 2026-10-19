# Add Native Zellij Keyboard Link Hints for Remote SSH File Opening

*Date: 2026-10-19*

## Context & Problem

On local Linux (`shined`), clicking a `file://` URI or file path in Ghostty
dispatches to `~/.local/bin/zellij-edit` via GIO/XDG `x-scheme-handler/file` and
opens the file (at its optional line number) in Neovim in a new tiled Zellij
split in the current tab. However, when SSHing into `shined` from a macOS client
running Ghostty (`shined-mac`, `baumkuchen`, `midnight-future`), Ghostty's
client-side link handler executes on macOS where remote workstation paths do not
exist and where the remote Zellij server is not directly reachable via local
XDG handlers.

We needed a keyboard-driven link hint workflow in our `Hylian/zellij` fork
(`software/zellij`, branch `hylian/latency`) that works identically over SSH and
locally, across both normal and scrollback (`Scroll`/`Search`) modes, and when
focused inside Neovim (`zellij-autolock` `Locked` mode).

## Architecture & Implementation

1. **Action & IPC Wiring (`zellij-utils`):**
   - Added `Action::LinkHints` (`LinkHints` in KDL config,
     `zellij action link-hints` in `CliAction`, `ProtobufAction::LinkHints` tag
     `86` in `plugin_api/action.proto`, and `common_types::Action::LinkHints`
     tag `152` in `client_server_contract/common_types.proto`).
2. **Viewport File Candidate Discovery (`zellij-server/src/panes/grid.rs`):**
   - `Grid::collect_link_hint_candidates` groups wrapped physical viewport rows
     (`Row::is_canonical`) into logical lines so paths and URLs that soft-wrap
     across terminal columns are reconstructed and matched seamlessly.
   - Extracts both **OSC 8 hyperlinks** (`\e]8;;file://...\e\`, grouping
     contiguous characters sharing the same `LinkAnchor::Start(id)`) via
     `LinkHandler::get_uri` and **plain-text file tokens** (`file://...`,
     `/abs/path:line:col`, `~/path#L123`, `./rel/path(45)`, `a/...`/`b/...` git
     diff headers, and `rg -n` `path:line:col:content` output).
   - Verifies each candidate on the Zellij server host against the focused
     pane's runtime working directory (`Grid::current_cwd`, updated by OSC 7 and
     `/proc/<pid>/cwd`, plus up to 6 ancestor directories and stripped `a/`/`b/`
     git diff prefixes) so only real, existing files on the remote workstation
     receive hint badges.
3. **Prefix-Free Home-Row Hint Badges & `RESET_STYLES` Rendering (`grid.rs`):**
   - `generate_hint_labels` assigns 1- or 2-character prefix-free labels from
     the home-row alphabet (`asdfghjklqwertyuiopzxcvbnm`) ordered bottom-to-top
     (most recent output closest to the prompt gets the shortest single-letter
     badges).
   - During `Grid::render`, active link hints are overlaid onto a cloned
     `Vec<TerminalCharacter>` per viewport row without mutating the underlying
     terminal buffer. Both badge cells and link span cells start from
     `RESET_STYLES` so ANSI attributes do not leak from preceding cells, and row
     style transitions normalize `None` to `Some(AnsiCode::Reset)` whenever the
     previous character carried link-hint styling.
4. **Mode-Agnostic Key Interception (`route.rs`, `screen.rs`, `tab/mod.rs`):**
   - `Server::link_hints_clients` (`Arc<Mutex<HashSet<ClientId>>>`) tracks
     clients with active link hints in the focused pane.
   - When `route_action` receives `Action::Key` for a client in
     `link_hints_clients`, it routes directly to
     `ScreenInstruction::LinkHintKey` instead of parsing default mode
     keybindings or forwarding keystrokes to the PTY or Wasm plugins. This
     keeps `Scroll`/`Search` scrollback position intact (no `ClearScroll`) and
     works even if the pane was in `Locked` mode.
   - Typing badge characters filters matching hints live (updating the pane
     frame title indicator `HINTS: <prefix> (N)`); `Backspace` pops the last
     character; `Esc` or any non-matching key cancels cleanly; and completing a
     badge dispatches `PtyInstruction::SpawnTerminal` with
     `CommandToRun::new_with_payload(OpenFilePayload)` and
     `NewPanePlacement::Tiled` to open the file at its target line number in
     Neovim (`$EDITOR` / `scrollback_editor`) in a new tiled Zellij split.

## Changes Made

- **`software/zellij`** (`hylian/latency` commit `c11e9729`):
  - Added `Action::LinkHints`, viewport file & OSC 8 candidate extraction,
    prefix-free hint generation, `RESET_STYLES` overlay rendering, and tiled
    editor split spawning.
- **[dot_config/zellij/config.kdl.tmpl](../dot_config/zellij/config.kdl.tmpl)**:
  - Bound `Alt + o` (`bind "Alt o" { LinkHints; }`) in `shared_except "locked"`.
  - Bound `f` and `Alt + o` (`bind "f" "Alt o" { LinkHints; }`) in
    `shared_among "scroll" "search"`.
- **[dot_config/nvim/lua/keybindings.lua](../dot_config/nvim/lua/keybindings.lua)**:
  - Mapped `<A-o>` across `{'n', 'i', 'v', 't'}` to `zellij('link-hints')` so
    `Alt + o` triggers Zellij link hints even when Neovim has `zellij-autolock`
    engaged (such as inside `:terminal` or floating buffers).
