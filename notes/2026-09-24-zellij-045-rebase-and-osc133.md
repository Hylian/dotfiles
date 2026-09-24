# Rebase Zellij onto v0.45.1 and Integrate OSC 133 Prompt Navigation & Output Copy

*Date: 2026-09-24*

## Context & Problem

Upstream Zellij `0.45.0` / `0.45.1` landed native OSC 133 shell integration (`\e]133;A` prompt start, `\e]133;B` input start, `\e]133;C` command output start, `\e]133;D;<exit_code>` command end) along with new actions:
- `ScrollToPreviousPrompt` / `ScrollToNextPrompt` (jump between shell prompts in scrollback)
- `SelectCommandAtScrollPosition` (select command output nearest top of viewport)
- `CopyLastCommandOutput` (copy the output of the last finished command to the clipboard with a brief highlight flash)

We needed to:
1. Rebase our custom `Hylian/zellij` fork (`hylian/latency`) onto `v0.45.1`.
2. Emit proper OSC 133 sequences in `~/.zshrc` (`dot_zshrc.tmpl`) alongside Starship and `zsh-vi-mode`.
3. Replace our legacy regex-based `jump_prompt` (`<C-k>` / `<C-j>`) in Neovim (`dot_config/nvim/lua/keybindings.lua`) with Zellij's native OSC 133 prompt navigation (`ScrollToPreviousPrompt` / `ScrollToNextPrompt`), and bind prompt navigation in Zellij `Scroll`/`Search` mode.
4. Bind `CopyLastCommandOutput` to `Alt + y` across both Zellij (`dot_config/zellij/config.kdl.tmpl`) and Neovim (`dot_config/nvim/lua/keybindings.lua`).

## Root Cause & Architecture Analysis

1. **Rebase of `hylian/latency` onto `v0.45.1`:**
   - Two commits from our 0.44.3 stack were upstreamed or superseded in `0.45.x`: `d296b7e79` (`fix: prevent horizontal auto-scroll timer leak on click`) was merged upstream as `6b967baac`, and `cf1d0d3c4` (`fix(pty): optimized get_cmds_by_ppid on linux via /proc`) was superseded by upstream `c632605c3` (`get_foreground_cmds` via `tcgetpgrp` + `/proc/<pid>/cmdline`).
   - Upstream `v0.45.1` reserved protobuf field numbers `48, 49, 50` and allocated `51..59, 67..69` in `common_types.proto`. We renumbered our `scroll_acceleration_factor` and `scroll_inertia` options to protobuf tags `70` and `71`.
2. **Enhancements to Upstream OSC 133 Handling in `Hylian/zellij`:**
   - **Multi-Line Prompt Navigation (`zellij-server/src/panes/grid.rs`):** Starship (`add_newline = true`) emits a leading newline after `133;A` (prompt start) and places `133;B` (input start) on the next row after `❯ `. When `previous_prompt_line_delta` scrolls `133;A` to `line = 0`, `133;B` sits on `line = 1`. Upstream's `next_prompt_line_delta` scanned `1..=last_line` for any `Prompt | Input` marker, which stopped at `line = 1` (`133;B` of the *same* prompt). We updated `next_prompt_line_delta` to track whether `line = 0` has an unclosed `Prompt` marker and skip its matching `Input` marker on subsequent lines. We also deduplicated same-kind markers per row in `add_osc133_marker` so `zle reset-prompt` (`zsh-vi-mode` mode switches) updates column positions in place rather than accumulating duplicate markers.
   - **Automatic Scroll Mode Sync (`zellij-server/src/screen.rs`):** Added `sync_scroll_mode_if_scroll_changed(client_id, was_scrolled)` to `ScreenInstruction::ScrollToPreviousPrompt` and `ScreenInstruction::ScrollToNextPrompt` so jumping up to a prompt automatically enters `Scroll` mode and jumping back down to the active prompt returns to `Normal` mode.
   - **CLI Action Exposure (`zellij-utils/src/cli.rs` & `actions.rs`):** Exposed `scroll-to-previous-prompt`, `scroll-to-next-prompt`, `select-command-at-scroll-position`, and `copy-last-command-output` in `CliAction` so Neovim (`zellij action ...`) can invoke them directly.
3. **Zsh OSC 133 Emission (`dot_zshrc.tmpl`):**
   - Wrapped Starship's `PROMPT` with zero-width `%{\e]133;A\a%}` and `%{\e]133;B\a%}`.
   - Added `_zsh_osc133_preexec` (`printf '\e]133;C\a'`) and `_zsh_osc133_precmd` (`printf '\e]133;D;%d\a' "$ret"`, placed at the head of `precmd_functions` and ending with `return $ret` so `prompt_starship_precmd` receives the exact `$?` exit code).

## Changes Made

- **`software/zellij`** (`hylian/latency` onto `v0.45.1`):
  - Rebased latency, dynamic tab CWD naming, and smooth scroll commits onto `v0.45.1`.
  - Added `feat(osc133): expose CLI actions, sync scroll mode, and support multi-line prompts`.
- **[dot_zshrc.tmpl](../dot_zshrc.tmpl)**:
  - Added `_zsh_osc133_precmd`, `_zsh_osc133_preexec`, and `PROMPT` `133;A`/`133;B` wrapping.
- **[dot_config/zellij/config.kdl.tmpl](../dot_config/zellij/config.kdl.tmpl)**:
  - Bound `Alt + y` to `CopyLastCommandOutput; SwitchToMode "normal";` and `Alt + Up` / `Alt + Down` to `ScrollToPreviousPrompt;` / `ScrollToNextPrompt;` in `shared_except "locked"`.
  - Bound `Ctrl + k` / `[` / `Alt + Up` to `ScrollToPreviousPrompt;`, `Ctrl + j` / `]` / `Alt + Down` to `ScrollToNextPrompt;`, `m` to `SelectCommandAtScrollPosition;`, and `c` / `Alt + y` to `CopyLastCommandOutput; SwitchToMode "normal";` in `shared_among "scroll" "search"`.
- **[dot_config/nvim/lua/keybindings.lua](../dot_config/nvim/lua/keybindings.lua)**:
  - Removed legacy `jump_prompt` function and its `<C-k>` / `<C-j>` mappings (since prompt jumping and command output copying now happen directly in Zellij terminal panes).
