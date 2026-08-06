# Smooth Single-Line Trackpad Scrolling Architecture

**Date:** 2026-08-06

## Context & Motivation
When scrolling in Zellij using the Apple Magic Trackpad or trackpads on macOS clients (`baumkuchen`) or Linux workstations (`shined`), high-velocity gestures or libinput acceleration emit clusters of single-line SGR mouse events in rapid succession (e.g. 3–5 events in under 5ms). Because terminal multiplexers receive these in the same socket batch, unpaced event processing causes multi-line viewport jumps in a single rendered display frame.

The goal: queue incoming scroll events and pace them frame-by-frame (~70fps) so that any burst of scroll events (such as 3 events from a trackpad swipe) smoothly animates strictly **one line per frame**, with zero dropped lines and zero latency on the initial event.

## Mechanism & Changes

### 1. Zellij Frame-Paced Smooth Scroll Animation Queue (`Hylian/zellij`)
* **Files:**
  - `zellij-server/src/tab/mod.rs`: Added `SmoothScrollQueue` struct (`pending_steps`, `last_position`, `last_step_time`, `is_draining`) per client on `Tab`. Added `drain_smooth_scroll_step` method.
  - `zellij-server/src/tab/mouse_handler.rs`: In `handle_scrollwheel_up` and `handle_scrollwheel_down`, if the queue is idle and `>= 14ms` elapsed, execute Step 1 immediately (0ms touch latency). Otherwise, enqueue subsequent steps into `pending_steps` (capped to 25 to prevent overshoot) and start the drain loop.
  - `zellij-server/src/background_jobs.rs`: Added `BackgroundJob::DrainSmoothScrollQueue { client_id }` with a 14ms async timer tick.
  - `zellij-server/src/screen.rs`: Added `ScreenInstruction::DrainSmoothScrollQueue(ClientId)` to pop 1 pending step, scroll 1 line, render the frame, and reschedule if additional steps remain.
  - `zellij-utils/src/errors.rs`: Added `ScreenContext::DrainSmoothScrollQueue` and `BackgroundJobContext::DrainSmoothScrollQueue`.
* **Impact:**
  - When Ghostty sends 3 scroll events in 2ms:
    - **Event 1 (t=0ms):** Executes immediately, renders Frame 0 (+1 line).
    - **Events 2 & 3 (t=1-2ms):** Enqueued into `pending_steps`.
    - **Frame 1 (+14ms):** Drains step 2, renders Frame 1 (+1 line).
    - **Frame 2 (+28ms):** Drains step 3, renders Frame 2 (+1 line).
  - Slow scrolling retains 0ms instantaneous response.
  - Fast gestures glide with silky smooth 70fps cascading animation strictly one row per display frame.
* **Verification:** Unit and integration tests pass cleanly. Release binary built with LTO and installed to `~/.local/bin/zellij` and `~/.cargo/bin/zellij`.

### 2. Ghostty Scoped Sensitivity Tuning (`dot_config/ghostty/config.tmpl`)
* **Configuration:**
  ```ini
  {{ if eq .chezmoi.os "darwin" -}}
  mouse-scroll-multiplier = precision:0.75,discrete:1
  {{- else -}}
  mouse-scroll-multiplier = 0.75
  {{- end }}
  ```
* **Impact:**
  - Adjusting `mouse-scroll-multiplier` scales the frequency of SGR mouse events inside Ghostty without modifying system-wide Sway or Wayland trackpad settings.
  - Chrome, browsers, and GUI applications retain native Wayland continuous pixel scrolling deltas.
  - Paired with Zellij's frame-paced queue, high multiplier produces rich event streams that animate continuously across frames.

### 3. Neovim Single-Line Mouse Scroll (`dot_config/nvim/init.lua.tmpl`)
* **File:** `dot_config/nvim/init.lua.tmpl`
* **Configuration:** `vim.opt.mousescroll = 'ver:1,hor:1'`.
* **Impact:** Eliminates Neovim's default 3-line vertical jump, ensuring mouse scroll events inside editor buffers step 1 line at a time.
