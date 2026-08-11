# Decouple Live Trackpad Scroll Acceleration from Inertial Coasting in Zellij

**Date:** 2026-08-11
**Host:** `shined` (Linux Wayland Workstation)
**Scope:** Dotfiles (`dot_config/zellij/config.kdl.tmpl`), `notes/SYSTEM.md`, personal fork `Hylian/zellij` (`hylian/latency`).

---

## 1. Context & Motivation

Trackpad scrolling in terminal environments requires precise motor feedback. Previously in Zellij:
- `scroll_acceleration_factor` controlled both live swipe velocity scaling and the post-gesture inertial fling momentum (friction-drained background queue).
- Disabling inertia by setting `scroll_acceleration_factor 1.0` also eliminated live swipe acceleration, requiring multiple long physical swipes to traverse tall scrollback buffers.
- The user requested decoupled behavior: **allow rapid continuous swipes to scale lines scrolled per event in real time (up to 3.5x), while stopping dead immediately when finger movement stops (zero post-gesture inertial coasting).**

---

## 2. Implementation Details

### A. Engine Architecture (`Hylian/zellij`)

1. **Option & Config Schema (`zellij-utils`):**
   - Added `scroll_inertia: Option<bool>` (default: `true`) to `Options` in `zellij-utils/src/input/options.rs`.
   - Added KDL parsing and serialization (`scroll_inertia true|false`) in `zellij-utils/src/kdl/mod.rs`.
   - Updated Protobuf IPC definitions in `client_server_contract/common_types.proto` (tag 49) and `assets/prost_ipc/client_server_contract.rs`.
   - Updated bidirectional conversions in `zellij-utils/src/ipc/protobuf_conversion.rs`.

2. **Server & Tab Dispatch (`zellij-server`):**
   - Propagated `scroll_inertia: bool` across `Screen`, `ScreenInstruction::Reconfigure`, and `Tab`.
   - In `zellij-server/src/tab/mouse_handler.rs` (`handle_scrollwheel_up` and `handle_scrollwheel_down`):
     - Calculates swipe event frequency: for gentle or starting gestures (`dt >= 100ms` or rate <= 35 Hz), `speed_scale` firmly locks to `1.0` (single line per event).
     - Ramps `speed_scale` smoothly up to `scroll_acceleration_factor` for sustained rapid continuous swipes.
     - When accelerated or multi-line batches occur (`int_lines > 1`), executes the first line immediately for zero latency, and buffers remaining lines in `pending_lines`.
     - Animates queued lines strictly **one line per 14ms frame** via `drain_smooth_scroll_step`.
     - When `!tab.scroll_inertia`: zero post-gesture coasting momentum (`queue.velocity = 0.0`), stopping dead as soon as buffered swipe lines drain.
     - Moving in opposing direction or slow grab halts and clears any active queue immediately.

### B. Verification & Benchmarking

- Verified full workspace test suite (`cargo test --workspace`): 384 utils tests, 217 tab integration tests, 204 screen tests all passing cleanly.
- Added unit tests:
  - `test_scroll_inertia_disabled_no_momentum_drain`: verifies zero coasting fling momentum when `scroll_inertia` is disabled.
  - `test_multi_line_scroll_animates_one_line_at_a_time`: verifies queued multi-line scrolls step strictly 1 line per frame.
- Built release binary and installed to `~/.local/bin/zellij`.
- Committed to `Hylian/zellij` repository (`hylian/latency`).

### C. Dotfiles Configuration (`chezmoi`)

Updated `dot_config/zellij/config.kdl.tmpl`:
```kdl
// Max acceleration multiplier for continuous trackpad/mouse wheel scrolling
// Default: 3.5 (1.0 to disable acceleration)
//
scroll_acceleration_factor 3.5

// Enable or disable inertial scrolling momentum after trackpad swipe
// Default: true
//
scroll_inertia false
```

Applied via `chezmoi apply` and verified with `zellij setup --check` (`[CONFIG FILE]: Well defined.`).
