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
     - When `!tab.scroll_inertia`:
       - Calculates instantaneous speed per 14ms frame: `instantaneous_speed = (lines * 14.0) / (dt.max(4))`.
       - Computes dynamic speed scaling: `speed_scale = (instantaneous_speed / 0.25).clamp(1.0, tab.scroll_acceleration_factor)`.
       - Accumulates fractional lines: `lines_to_step = (lines * speed_scale) + fractional_step`.
       - Executes immediate scroll steps directly for integer lines.
       - Suppresses background momentum and velocity queuing (`queue.velocity = 0.0; queue.is_draining = false`).

### B. Verification & Benchmarking

- Verified full workspace test suite (`cargo test --workspace`): 384 utils tests, 216 tab integration tests, 204 screen tests all passing cleanly.
- Added dedicated unit test `test_scroll_inertia_disabled_no_momentum_drain` verifying zero momentum drain dispatch when `scroll_inertia` is disabled.
- Built release binary and installed to `~/.local/bin/zellij`.
- Committed to `Hylian/zellij` repository (commit `6609a5ef`).

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
