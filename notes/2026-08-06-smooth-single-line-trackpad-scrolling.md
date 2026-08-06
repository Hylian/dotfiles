# Smooth Single-Line Trackpad Scrolling Architecture

**Date:** 2026-08-06

## Context & Motivation
When scrolling in Zellij using the Apple Magic Trackpad or trackpads on macOS clients (`baumkuchen`) or Linux workstations (`shined`), gestures generate streams of SGR mouse events. Slow, precise movements emit 1–3 events, while fast flings emit dozens of events in rapid succession.

The requirements:
1. **Zero-Latency Response:** Slow, precise finger movements scroll strictly **1 line per event** with **0ms latency** on touch.
2. **Dynamic Logarithmic Scaling:** The lines scrolled per frame scale with the number of queued events ($\propto \ln(Q)$), providing organic velocity during large swipes.
3. **Hard 200ms Maximum Completion Deadline:** Any volume of accumulated scroll input (even 50–100+ lines from an aggressive trackpad fling) is guaranteed to completely resolve and come to rest within **at most 200ms**.

## Mechanism & Implementation

### 1. Dynamic Logarithmic Pacing & Time-Budgeted Drainage (`Hylian/zellij`)
* **Files:**
  - `zellij-server/src/tab/mod.rs`:
    - `SmoothScrollQueue` struct records `pending_steps: isize`, `last_position: Position`, `last_step_time: Instant`, `drain_start_time: Instant`, and `is_draining: bool`.
    - In `drain_smooth_scroll_step`: Computes the remaining time window $T_{\text{remaining}} = \max(0, 200\text{ms} - (t - t_{\text{start}}))$ and remaining frame budget $F_{\text{remaining}} = \lceil T_{\text{remaining}} / 14\text{ms} \rceil$.
    - Step size for each frame is calculated as:
      $$\text{lines\_this\_frame} = \min\left(Q, \max\left(1, \left\lceil \frac{Q}{F_{\text{remaining}}} \right\rceil, \text{round}\left(1 + 1.8 \cdot \ln\left(\frac{Q}{2}\right)\right)\right)\right)$$
    - When $Q \le 3$: Drains strictly 1 line per frame (14ms per line).
    - When $Q$ is large: Ramps initial velocity logarithmically, decelerates smoothly, and guarantees $100\%$ drainage at $t = 200\text{ms}$.
  - `zellij-server/src/tab/mouse_handler.rs`:
    - `execute_scroll_step_up` and `execute_scroll_step_down` accept `lines: usize` to execute multi-line viewport updates and SGR sequences in a single unified frame render.
    - `handle_scrollwheel_up` and `handle_scrollwheel_down` stamp `drain_start_time = now` upon entering the drain state and allow deep burst queuing (up to 500 lines).
* **Impact:**
  - Small swipes: 1 line per frame.
  - Large flings: Rapid logarithmic deceleration that naturally stops within 200ms without abrupt clipping or sluggish overshoot.

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
  - Scales Wayland/GTK pixel deltas into high-resolution discrete mouse wheel events inside Ghostty without altering system-wide trackpad sensitivity in GUI applications like Chrome.

### 3. Neovim Single-Line Mouse Scroll (`dot_config/nvim/init.lua.tmpl`)
* **Configuration:** `vim.opt.mousescroll = 'ver:1,hor:1'`.
* **Impact:** Ensures Neovim editor buffers step 1 line at a time rather than jumping 3 lines.
