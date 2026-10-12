# Zellij Fork Audit, Bugfixes, Refactors, and Upstream Split (｡•̀ᴗ-)✧

*Date: 2026-10-12*

## Context
Audited all changes in `software/zellij` (`Hylian/zellij`, branch `hylian/latency` on top of upstream `v0.45.1` / `efd8fd5a`) to fix subtle bugs, clean up rebase regressions, refactor duplicated code, and reorganize the branch so that upstream-appropriate commits sit cleanly at the base of the branch ahead of fork-specific UX customizations.

## Bugfixes, Improvements, and Refactors Applied

### 1. Linux `/proc` Fast Path in `get_foreground_cmds` (`os_input_output.rs`)
- **Bug Fixed:** While `get_cwd` and `get_cwds` used the fast `/proc/<pid>/cwd` and `/proc/<pid>/cmdline` readers on Linux, `get_foreground_cmds` unconditionally instantiated `sysinfo::System::new()` and refreshed the entire process table on every poll tick.
- **Fix:** Updated `get_foreground_cmds` to try `get_process_cmd(fg_pid)` (`/proc/<pid>/cmdline`) on Linux first before falling back to `sysinfo`.

### 2. `close_fds_fast` `c_uint` Flags & Deterministic Unit Test (`os_input_output_unix.rs`)
- **Improvement:** Passed `0 as libc::c_uint` for the `flags` argument to `libc::syscall(libc::SYS_close_range, ...)` to match the C ABI signature (`unsigned int flags`) on 64-bit targets.
- **Test Fix:** Replaced `benchmark_close_fds_fast` (which called `close_fds_fast(3)` inside the multi-threaded `cargo test` harness, closing open descriptors >= 3 across concurrent test threads) with `close_fds_fast_closes_high_fds` using `fcntl(0, F_DUPFD, 1024)` and `close_fds_fast(high_fd as usize)`.

### 3. OSC 133 Multi-Line Prompt Navigation & In-Place Redraws (`panes/grid.rs`)
- **Same-Row Multi-Command Deduplication:** Scoped `Row::add_osc133_marker` `Prompt`/`Input` deduplication to markers after the last `Output`/`End` boundary on the row so `cmd1; cmd2` on a single physical row preserves both prompts' markers, and cleared stale `Input` markers when `Prompt` (`133;A`) is re-emitted during an in-place prompt redraw before command execution.
- **In-Place Prompt Redraw Overwrite Protection:** Added `Osc133Marker::overwrite_protected` (`column < self.width()`) consumed on the first character overwrite in `Row::override_character`. Previously, when a shell redrew a prompt in place via `\r\x1b]133;A\x07[venv] $ ` without clearing the line first, printing `[` at column 0 saw `replacing_blank == false` and deleted the newly emitted `133;A` marker at column 0.
- **Multi-Line Prompt Navigation (`previous_prompt_line_delta` & `next_prompt_line_delta`):** Multi-line prompts (Starship, Powerlevel10k, etc.) often emit `133;A` on line 1 and `133;P` (or a second `133;A`) on line 2. Updated `previous_prompt_line_delta` to walk across contiguous prompt continuation lines to the top line of each logical prompt block, and updated `next_prompt_line_delta` to skip subsequent `Prompt` markers while `in_open_prompt` until `Input`/`Output`/`End` closes the prompt block.

### 4. `Pty::resolve_terminal_cwd` Consolidation (`pty.rs`)
- Extracted `Pty::resolve_terminal_cwd(terminal_id)` to centralize the 3-tier lookup (`os_input.get_cwd(pid)` -> `terminal_cwds` -> `initial_terminal_cwds`) across `fill_cwd`, `fill_cwd_from_pane_id`, `spawn_terminals_for_layout`, `fill_plugin_cwd`, and `get_pane_cwd`.

### 5. Tab Naming & `UndoRenameTab` Preservation (`screen.rs`)
- Guarded `canonicalize()` in `format_dir_name` behind `if dir.file_name() == home_path.file_name()` so non-`$HOME` directories never incur filesystem `realpath()` syscalls.
- Stopped overwriting `tab.prev_name` with the new name in `ScreenInstruction::RenameTab` and `ScreenInstruction::RenameTabWithId` so `UndoRenameTab` properly restores the previous name.

### 6. Smooth Scroll Mode Sync & Handler Unification (`screen.rs`, `tab/mod.rs`, `tab/mouse_handler.rs`)
- Added `sync_scroll_mode_if_scroll_changed` to `ScreenInstruction::DrainSmoothScrollQueue` so inertial/queued scroll steps that reach the bottom of scrollback automatically return the client from `Scroll` mode to `Normal` mode.
- Unified `handle_scrollwheel_up` and `handle_scrollwheel_down` into a single `handle_scrollwheel(tab, point, lines, dir, client_id)` implementation, removed unused `SmoothScrollQueue::last_step_time`, and tracked `was_already_draining` so opposing-direction or slow-grab resets update `queue.is_draining` immediately while avoiding duplicate background drain timers.
- Repaired all post-0.45.1 rebase unit test call-site mismatches and updated KDL/setup/tab insta snapshots across `zellij-utils` and `zellij-server`.

## Branch Organization (`hylian/latency` on `v0.45.1`)

### Upstream-Ready Commits (Base of Branch)
1. `de2c2add` — `perf(server): read process cwd and cmdline from /proc directly on Linux`
2. `e8e660cd` — `perf(server): use close_range syscall in pre_exec for O(1) post-fork fd cleanup`
3. `7500eacf` — `fix(grid): default parameter-less CSI K and CSI J erase sequences to 0`
4. `55ddb6bd` — `fix(pty): preserve initial CwdChanged event after capture_initial_cwd`
5. `85b98270` — `fix(osc133): support multi-line prompts, in-place redraws, and CLI actions`

### Fork-Specific UX Commits (Top of Branch)
6. `43cb67d1` — `feat(tabs): dynamically name new tab after active pane working directory`
7. `ac0c3596` — `feat(scroll): add smooth scrolling with configurable acceleration and inertia`
