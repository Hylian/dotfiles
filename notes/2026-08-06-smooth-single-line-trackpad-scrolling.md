# Smooth Single-Line Trackpad Scrolling Architecture

**Date:** 2026-08-06

## Context & Motivation
When scrolling in Zellij using the Apple Magic Trackpad or trackpads on macOS clients (`baumkuchen`) or Linux workstations (`shined`) connected over Ghostty, incoming mouse wheel events caused viewport jumps of multiple lines at a time because Zellij had hardcoded `lines: 3` in its mouse event dispatch handler.

The goal: have every single trackpad scroll event animate strictly **one line at a time** (`lines: 1`) without artificial multipliers, giving smooth, fluid single-row viewport stepping.

## Mechanism & Changes

### 1. Zellij Single-Line Mouse Scroll Event Handling (`Hylian/zellij`)
* **File:** `zellij-server/src/tab/mouse_handler.rs`
* **Change:** Changed `MouseAction::ScrollUp` and `MouseAction::ScrollDown` line counts from hardcoded `lines: 3` to `lines: 1`.
* **Impact:**
  - Standard terminal panes scroll exactly 1 row per SGR mouse wheel event.
  - Alternate-screen faux scrolling emits single UP/DOWN arrow sequences per event.
  - Plugin panes receive discrete single-count scroll events.
* **Verification:** Integration tests (`test_scroll_wheel_up_scrolls_pane` and `test_scroll_wheel_down_scrolls_pane`) verify clean 1-line viewport shifts per event. Binary compiled in release mode and installed to `~/.local/bin/zellij`.

### 2. Ghostty Native 1:1 Event Reporting (`dot_config/ghostty/config.tmpl`)
* **Ghostty Configuration:** Standard 1:1 event reporting without artificial multipliers (no `mouse-scroll-multiplier`), ensuring Ghostty emits discrete single-tick SGR events as the trackpad scrolls rather than multi-event bursts.
* **Combined Result:** Each trackpad scroll tick translates to exactly 1 SGR wheel event, which Zellij renders as exactly 1 line of viewport movement.
