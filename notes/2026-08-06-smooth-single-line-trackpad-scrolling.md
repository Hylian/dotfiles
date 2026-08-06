# Smooth Single-Line Trackpad Scrolling Architecture

**Date:** 2026-08-06

## Context & Motivation
When scrolling in Zellij using the Apple Magic Trackpad or trackpads on macOS clients (`baumkuchen`) or Linux workstations (`shined`), multiple layers defaulted to 3-line scroll increments:
1. **Zellij Server Dispatch:** Hardcoded to `lines: 3` in `mouse_handler.rs` and in `screen.rs` (`ScreenInstruction::ScrollUpAt` / `ScrollDownAt`).
2. **Neovim Editor Dispatch:** Neovim defaults `mousescroll` to `ver:3,hor:6`, causing 3-line viewport jumps per wheel event inside Neovim buffers.

The goal: have every single trackpad scroll event animate strictly **one line at a time** across all layers (Zellij multiplexer scrollback, panes, and Neovim editor).

## Mechanism & Changes

### 1. Zellij Single-Line Mouse Scroll Event Handling (`Hylian/zellij`)
* **Files:**
  - `zellij-server/src/tab/mouse_handler.rs`: Changed `MouseAction::ScrollUp` and `MouseAction::ScrollDown` line counts from hardcoded `lines: 3` to `lines: 1`.
  - `zellij-server/src/screen.rs`: Changed `ScreenInstruction::ScrollUpAt` and `ScreenInstruction::ScrollDownAt` line counts from `3` to `1`.
* **Impact:**
  - Standard terminal panes scroll exactly 1 row per SGR mouse wheel event.
  - Alternate-screen faux scrolling emits single UP/DOWN arrow sequences per event.
  - Plugin panes receive discrete single-count scroll events.
* **Verification:** Integration tests pass. Binary compiled in release mode and installed to `~/.local/bin/zellij` and `~/.cargo/bin/zellij`.

### 2. Neovim Single-Line Mouse Scroll (`dot_config/nvim/init.lua.tmpl`)
* **File:** `dot_config/nvim/init.lua.tmpl`
* **Configuration:** `vim.opt.mousescroll = 'ver:1,hor:1'`.
* **Impact:** Eliminates Neovim's default 3-line vertical scroll jump (`ver:3`), ensuring mouse scroll events inside editor buffers advance exactly 1 line at a time.

### 3. Sway & Ghostty Layer Clarifications
* **Sway:** Sway manages continuous `wl_pointer.axis` events in pixels via `scroll_factor` (scaling libinput deltas). It does not impose 3-line step quantization.
* **Ghostty:** Emits 1 SGR scroll event per line-height delta threshold without artificial multi-event bursts.
