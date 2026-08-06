# Smooth Single-Line Trackpad Scrolling Architecture

**Date:** 2026-08-06

## Context & Motivation
When scrolling in Zellij using the Apple Magic Trackpad or trackpads on macOS clients (`baumkuchen`) or Linux workstations (`shined`), gestures generate streams of SGR mouse events. Slow, precise movements emit 1–3 events, while fast flings emit dozens of events in rapid succession.

The requirements:
1. **Zero-Latency Precision Response:** Slow, precise finger movements scroll strictly **1 line per event** with **0ms latency** on initial touch.
2. **Gesture Velocity Acceleration:** Continuous rapid scrolling strokes in the same direction build dynamic momentum (acceleration multiplier scaling up to $3.5\times$).
3. **Dynamic Logarithmic Scaling:** The lines scrolled per frame scale with the number of queued events ($\propto \ln(Q)$), providing organic velocity during large swipes.
4. **Hard 200ms Maximum Completion Deadline:** Any volume of accumulated scroll input (even 50–100+ lines from an aggressive trackpad fling) is guaranteed to completely resolve and come to rest within **at most 200ms**.

## Mechanism & Implementation

### 1. Dynamic Logarithmic Pacing & Acceleration Queue (`Hylian/zellij`)
* **Files:**
  - `zellij-server/src/tab/mod.rs`:
    - `SmoothScrollQueue` struct records `pending_steps: isize`, `last_position: Position`, `last_step_time: Instant`, `last_event_time: Instant`, `drain_start_time: Instant`, `acceleration_factor: f32`, and `is_draining: bool`.
    - In `drain_smooth_scroll_step`: Computes the remaining time window $T_{\text{remaining}} = \max(0, 200\text{ms} - (t - t_{\text{start}}))$ and remaining frame budget $F_{\text{remaining}} = \lceil T_{\text{remaining}} / 14\text{ms} \rceil$.
    - Step size for each frame is calculated as:
      $$\text{lines\_this\_frame} = \min\left(Q, \max\left(1, \left\lceil \frac{Q}{F_{\text{remaining}}} \right\rceil, \text{round}\left(1 + 1.8 \cdot \ln\left(\frac{Q}{2}\right)\right)\right)\right)$$
    - When $Q \le 3$: Drains strictly 1 line per frame (14ms per line).
    - When $Q$ is large: Ramps initial velocity logarithmically, decelerates smoothly, and guarantees $100\%$ drainage at $t = 200\text{ms}$.
  - `zellij-server/src/tab/mouse_handler.rs`:
    - Tracks inter-event interval $\Delta t = t - t_{\text{last\_event}}$. If $\Delta t < 120\text{ms}$ in the same direction, ramps `acceleration_factor` by $+0.15$ up to $3.5\times$. If $\Delta t \ge 200\text{ms}$ or direction reverses, resets to $1.0\times$.
    - `execute_scroll_step_up` and `execute_scroll_step_down` accept `lines: usize` to execute multi-line viewport updates and SGR sequences in a single unified frame render.
* **Impact:**
  - Precise editing: 1:1 single-line tracking.
  - Sustained fast scrolling: Accelerates swiftly for long-distance document traversal, then seamlessly settles within 200ms.

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

### 4. Sccache Build Caching (`dot_cargo/config.toml.tmpl`)
* **Configuration:**
  ```toml
  [build]
  rustc-wrapper = "sccache"
  jobs = 64
  incremental = false
  ```
* **Impact:** Disables rustc incremental compilation (`incremental = false`), resolving sccache's non-cacheable incremental incompatibility and enabling compilation caching across Zellij builds and tests.
