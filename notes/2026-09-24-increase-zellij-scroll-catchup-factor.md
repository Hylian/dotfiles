# Increase Zellij Smooth-Scroll Queue Catch-Up Factor to 67%

**Date:** 2026-09-24  
**Context:** With `scroll_acceleration_factor 10.0` and `scroll_inertia false`
in [dot_config/zellij/config.kdl.tmpl](../dot_config/zellij/config.kdl.tmpl),
rapid trackpad swipes generated multi-line scroll steps faster than the
smooth-scroll animation queue drained them, making the viewport feel laggy and
behind the finger.

## Root Cause

1. **Capped & Un-Unified Immediate Step in `mouse_handler.rs`:**
   - When a scroll event arrived with `int_lines` (up to `10` lines per event at
     100Hz+ trackpad rates), `handle_scrollwheel_up` and
     `handle_scrollwheel_down` computed `immediate_lines` solely from the *old*
     `queue.pending_lines` (`0..=2 => 1, 3..=6 => 2, _ => 3`), capped it at `3`,
     and pushed `int_lines - immediate_lines` into `queue.pending_lines`.
   - Because 100–120Hz input events arrive every 8–10ms while
     `DrainSmoothScrollQueue` ticks every 14ms (~71Hz), each accelerated swipe
     event dumped up to 7 lines into `pending_lines` without ever flushing the
     lines already queued from prior events.
2. **Conservative 25% Background Drain Curve in `tab/mod.rs`:**
   - `drain_smooth_scroll_step` drained only `1` line for `1..=3`, `2` for
     `4..=7`, `3` for `8..=12`, `4` for `13..=18`, and `n / 4` (25%) for `19+`.
   - A 24-line backlog took 9 frames (~126ms) to finish draining after the swipe
     stopped.

## Fix (`Hylian/zellij` @ `4446cd09`)

1. **Merge & Drain ~67% Immediately on Incoming Scroll Events (`mouse_handler.rs`):**
   - `handle_scrollwheel_up` and `handle_scrollwheel_down` now add `int_lines`
     to `queue.pending_lines` *first*, then immediately step
     `((queue.pending_lines * 2 + 1) / 3)` (~67% of the combined queue).
   - Gentle 1–2 line scroll steps still step 1 line immediately and 1 line on
     the next 14ms frame (`(2 * 2 + 1) / 3 = 1`), preserving 1-line-at-a-time
     micro-smoothing at low speed.
   - When events arrive faster than 14ms, each incoming event immediately
     flushes 67% of the accumulated backlog plus new lines, clamping the
     steady-state queue depth to 1–3 lines.
2. **Increase Background Frame Catch-Up to 67% (`tab/mod.rs`):**
   - Updated `drain_smooth_scroll_step` to use the same
     `((queue.pending_lines * 2 + 1) / 3)` scaling (`3 -> 2`, `4 -> 3`,
     `10 -> 7`, `24 -> 16`), shrinking any multi-line spike by 3x per 14ms frame
     (`10 -> 3 -> 1 -> 0`).
