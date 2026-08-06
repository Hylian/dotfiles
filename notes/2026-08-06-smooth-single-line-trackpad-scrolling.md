# Smooth Single-Line Trackpad Scrolling Architecture

**Date:** 2026-08-06

## Context & Motivation
When scrolling in Zellij using the Apple Magic Trackpad on macOS clients (\`baumkuchen\`) connected over Ghostty and SSH, scroll events caused viewport jumps of multiple lines at a time (hardcoded to 3 lines in Zellij, or perceived as 4 lines), creating choppy visual jumps rather than fluid single-line viewport motion.

The goal: maintain the exact same physical trackpad gesture sensitivity (finger travel distance per page scrolled), but have all scroll events animate strictly **one line at a time**.

## Mechanism & Changes

### 1. Zellij Single-Line Mouse Scroll Event Handling (\`Hylian/zellij\`)
* **File:** \`zellij-server/src/tab/mouse_handler.rs\`
* **Change:** Changed \`MouseAction::ScrollUp\` and \`MouseAction::ScrollDown\` line counts from hardcoded \`lines: 3\` to \`lines: 1\`.
* **Impact:**
  - Standard terminal panes scroll exactly 1 row per SGR mouse wheel event.
  - Alternate-screen faux scrolling emits single UP/DOWN arrow sequences per event.
  - Plugin panes receive discrete single-count scroll events.
* **Verification:** Integration tests (\`test_scroll_wheel_up_scrolls_pane\` and \`test_scroll_wheel_down_scrolls_pane\`) verify clean 1-line viewport shifts per event. Binary compiled in release mode and installed to \`~/.local/bin/zellij\`.

### 2. Ghostty Trackpad Multiplier Scaling (\`dot_config/ghostty/config.tmpl\`)
* **File:** \`dot_config/ghostty/config.tmpl\`
* **Configuration:**
  \`\`\`ini
  {{ if eq .chezmoi.os "darwin" -}}
  mouse-scroll-multiplier = precision:4,discrete:3
  {{- end }}
  \`\`\`
* **Impact:**
  - \`precision:4\`: Scales macOS trackpad precision scrolling deltas to generate 4x higher-frequency SGR mouse wheel events during continuous gestures.
  - Combined with Zellij's 1-line event processing, \`4 events * 1 line = 4 lines\`, matching the user's natural finger travel sensitivity while rendering every intermediate 1-line step for silky smooth scrolling animations.
  - \`discrete:3\`: Preserves standard 3-line scroll increments for physical notched mouse wheels.
