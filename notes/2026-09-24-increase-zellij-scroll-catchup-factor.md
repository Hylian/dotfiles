# Increase Zellij Smooth-Scroll Queue Catch-Up Factor to 67% & Fix Initial CWD Resolution

**Date:** 2026-09-24  
**Context:**
1. With `scroll_acceleration_factor 10.0` and `scroll_inertia false` in
   [dot_config/zellij/config.kdl.tmpl](../dot_config/zellij/config.kdl.tmpl),
   rapid trackpad swipes generated multi-line scroll steps faster than the
   smooth-scroll animation queue drained them, making the viewport feel laggy.
2. Auditing our custom commit stacks in `Hylian/zellij` (`hylian/latency`) and
   `Hylian/zjstatus` (`hylian/autorender`) revealed the root cause of the
   long-standing "Git branch is blank until the first `cd`" boot bug as well as
   cross-directory cache bleed in `/tmp/zjstatus-cmd-cache.<name>`.

## 1. Smooth-Scroll 67% Catch-Up (`Hylian/zellij` @ `4446cd09`)

### Root Cause
1. **Capped & Un-Unified Immediate Step in `mouse_handler.rs`:**
   - When a scroll event arrived with `int_lines` (up to `10` lines per event at
     100Hz+ trackpad rates), `handle_scrollwheel_up` and
     `handle_scrollwheel_down` computed `immediate_lines` solely from the *old*
     `queue.pending_lines` (`0..=2 => 1, 3..=6 => 2, _ => 3`), capped it at `3`,
     and pushed `int_lines - immediate_lines` into `queue.pending_lines`.
   - Because 100–120Hz input events arrive every 8–10ms while
     `DrainSmoothScrollQueue` ticks every 14ms (~71Hz), each accelerated swipe
     event dumped up to 7 lines into `pending_lines` without flushing lines
     already queued from prior events.
2. **Conservative 25% Background Drain Curve in `tab/mod.rs`:**
   - `drain_smooth_scroll_step` drained only `1..=4` lines or `n / 4` (25%),
     taking ~9 frames (~126ms) to clear a 24-line backlog.

### Fix
- Merged `int_lines` into `queue.pending_lines` *before* stepping in
  `mouse_handler.rs` and updated both `mouse_handler.rs` and
  `drain_smooth_scroll_step` (`tab/mod.rs`) to drain
  `((queue.pending_lines * 2 + 1) / 3)` (~67%) per step.
- Gentle `1..=2` line scroll steps still step 1 line immediately and 1 line on
  the next 14ms frame (`(2 * 2 + 1) / 3 = 1`), while backlogs (`3+` lines) drain
  67% immediately on every input event and frame tick (`3 -> 2`, `4 -> 3`,
  `10 -> 7`, `24 -> 16`).

---

## 2. Initial Session/Tab CWD Resolution & CWD-Guarded Cache (`Hylian/zellij` @ `09c11194`, `Hylian/zjstatus` @ `f38e8e99`)

### Root Cause
1. **`Pty::capture_initial_cwd` Suppressed the First `Event::CwdChanged` (`zellij-server/src/pty.rs`):**
   - `capture_initial_cwd` inserted the fork-time CWD directly into
     `self.terminal_cwds` without emitting `Event::CwdChanged` (before plugins
     had loaded).
   - When Zsh finished booting (~80ms later) and emitted `_zellij_osc7_cwd`
     (`notify_cwd_from_osc7`) or when `update_and_report_cwds` polled the pane,
     `self.terminal_cwds.get(&terminal_id) != Some(&path)` evaluated to `false`
     — suppressing `Event::CwdChanged` until the user manually ran `cd`.
2. **`Event::TabUpdate` & Early Return in `zjstatus` (`src/bin/zjstatus.rs`):**
   - `Event::PaneUpdate` often arrives before `Event::TabUpdate` at session boot
     while `self.state.tabs` is empty (`active_tab == None`), and
     `Event::TabUpdate` never called `self.update_focused_pane()`.
   - Additionally, `if new_id == self.state.focused_pane_id { return; }`
     returned early forever if frame-0 `get_pane_cwd` failed while
     `focused_pane_cwd` was still `None`.
3. **Unscoped `/tmp/zjstatus-cmd-cache.<name>` (`src/widgets/command.rs`):**
   - `CommandWidget::process()` read `/tmp/zjstatus-cmd-cache.<name>` on every
     render whenever `state.command_results.get(name)` was `None`, without
     checking whether the cached result came from the same `cwd` for
     `follow_focus_cwd` widgets.

### Fix
- **`Hylian/zellij` (`09c11194`):** Stored fork-time initial CWDs in
  `initial_terminal_cwds` (used as fallback by `GetPaneCwd`, `fill_cwd`, and
  `spawn_terminals_for_layout`) while leaving `terminal_cwds` for CWDs reported
  to plugins, so the first `_zellij_osc7_cwd` (`notify_cwd_from_osc7`) or poll
  always emits `Event::CwdChanged`. Also updated `Pty::get_pane_cwd` to use
  `os_input.get_cwd` with fallback to `terminal_cwds` and
  `initial_terminal_cwds`.
- **`Hylian/zjstatus` (`f38e8e99`):** Called `self.update_focused_pane()` in
  `Event::TabUpdate`, `Event::CwdChanged` (when `focused_pane_id` is `None`),
  `Event::Timer`, and `pipe()`, and guarded the early return with
  `self.state.focused_pane_cwd.is_some()`. Prefixed
  `/tmp/zjstatus-cmd-cache.<name>` with `cwd:<path>\n`, cached the file read in
  memory per `CommandWidget`, and restricted `follow_focus_cwd` cache hits to
  matching `focused_pane_cwd`.
