# Smooth Single-Line Trackpad Scrolling Architecture

**Date:** 2026-08-06

## Context & Motivation
When scrolling in Zellij using the Apple Magic Trackpad or trackpads on macOS clients (`baumkuchen`) or Linux workstations (`shined`), multiple layers defaulted to 3-line scroll increments:
1. **Zellij Server Dispatch:** Hardcoded to `lines: 3` in `mouse_handler.rs` and in `screen.rs` (`ScreenInstruction::ScrollUpAt` / `ScrollDownAt`).
2. **Ghostty Linux GTK/Wayland Event Rate:** GTK4 reports trackpad scroll deltas in high-resolution pixels (~30-40px per gesture notch), which with Ghostty's default multiplier produces bursts of ~3 SGR wheel events per notch.
3. **Neovim Editor Dispatch:** Neovim defaults `mousescroll` to `ver:3,hor:6`, causing 3-line viewport jumps per wheel event inside Neovim buffers.

The goal: have every single trackpad scroll event animate strictly **one line at a time** across all layers (Zellij multiplexer scrollback, panes, and Neovim editor), while allowing terminal-scoped sensitivity tuning without multi-line jumping or affecting high-precision GUI apps like Chrome.

## Mechanism & Changes

### 1. Zellij Frame-by-Frame Multi-Line Smooth Scroll Animation (`Hylian/zellij`)
* **Files:**
  - `zellij-server/src/background_jobs.rs`: Added `BackgroundJob::SmoothScrollSteps { client_id, point, direction, remaining_steps }` to asynchronously dispatch remaining scroll steps at ~14ms intervals (~70fps).
  - `zellij-server/src/screen.rs`: Added `ScreenInstruction::SmoothScrollStep(ClientId, Position, isize)` to execute single-line scroll steps and render individual frames.
  - `zellij-server/src/tab/mouse_handler.rs`: Separated single-line execution (`execute_scroll_step_up` / `execute_scroll_step_down`) from event dispatch (`handle_scrollwheel_up` / `handle_scrollwheel_down`).
  - `zellij-server/src/tab/mod.rs`: Added `step_smooth_scroll` dispatch method on `Tab`.
  - `zellij-utils/src/errors.rs`: Added `ScreenContext::SmoothScrollStep` and `BackgroundJobContext::SmoothScrollSteps`.
* **Impact:**
  - When a 3-line scroll event arrives, step 1 executes **immediately** (0ms latency, frame 0).
  - Steps 2 and 3 are scheduled across subsequent frames (+14ms and +28ms), rendering strictly **1 line per frame**.
  - No scroll distance is lost or capped, and multi-line jumps are eliminated. The viewport smoothly cascades line by line into place.
* **Verification:** Integration tests pass. Binary compiled in release mode with LTO and installed to `~/.local/bin/zellij` and `~/.cargo/bin/zellij`.

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
  - Adjusting `mouse-scroll-multiplier` scales the rate/frequency of SGR mouse events specifically inside Ghostty without modifying system-wide Sway or Wayland trackpad settings.
  - Chrome, browsers, and other GUI applications continue to receive untouched native Wayland high-precision pixel scrolling deltas.
  - Combined with Zellij's frame-by-frame smooth scroll animation, high sensitivity yields responsive finger travel while animating every single line sequentially.

### 3. Neovim Single-Line Mouse Scroll (`dot_config/nvim/init.lua.tmpl`)
* **File:** `dot_config/nvim/init.lua.tmpl`
* **Configuration:** `vim.opt.mousescroll = 'ver:1,hor:1'`.
* **Impact:** Eliminates Neovim's default 3-line vertical scroll jump (`ver:3`), ensuring mouse scroll events inside editor buffers advance exactly 1 line at a time.
