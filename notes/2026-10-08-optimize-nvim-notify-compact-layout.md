# Optimize Neovim Notification Layout & Readability (`nvim-notify`)

**Date:** 2026-10-08  
**Context:** Neovim UI / notification stack optimization.

## Problem & Motivation

Previously, [dot_config/nvim/lua/config/notify.lua](../dot_config/nvim/lua/config/notify.lua) used `render = "minimal"`, `minimum_width = 15`, and the default `top_down = true`. This caused several UX issues:
- **Tiny & Illegible:** `minimum_width = 15` allowed notifications with short messages to shrink to a narrow 15-character sliver in the upper-right corner.
- **Stripped Metadata:** `minimal` omitted borders, icons, and titles entirely, turning notifications into unformatted floating text blocks.
- **Awkward Position:** `top_down = true` placed notifications in the top-right corner far away from natural eye focus at the bottom statusline, while cascading downwards over buffer headers and tablines.

## Solution

Updated [dot_config/nvim/lua/config/notify.lua](../dot_config/nvim/lua/config/notify.lua) with a balanced compact layout:
1. **Bottom-Right Upward Stacking (`top_down = false`):** Anchors notifications directly above the statusline (`lualine`) where eyes naturally rest, stacking upwards so new notifications arrive at the bottom and older notices expire cleanly.
2. **Compact Render Style (`render = "compact"`):** Uses rounded borders and an inline header (`Icon | Title: Message`), presenting structured information without the vertical overhead of multi-line separators.
3. **Generous Minimum Width (`minimum_width = 45`):** Ensures every notification card has sufficient horizontal breathing room so headers and short messages never wrap into 2-word slivers.
4. **Bounded Dimensions:** Sets `max_width` to 75 columns (capped at 60% terminal columns) and `max_height` to 8 lines (capped at 30% terminal rows) to prevent massive compiler traces or LSP errors from filling the viewport.
5. **Theme Blending (`background_colour = "NormalFloat"`):** Blends opacity transitions seamlessly against Everforest Light's warm floating background (`#f2efdf`).
6. **Fade Animation & 3s Timeout:** Uses `stages = "fade"` for smooth in-place appearance without jarring horizontal slide-in effects, auto-dismissing after 3000ms.

## Verification

1. **Syntax & Rendering:**
   - Validated diff via `chezmoi diff`.
   - Applied cleanly via `chezmoi apply --no-pager`.
   - Tested headless Neovim startup (`nvim --headless +qa`).
2. **Interactive Notification Test:**
   - Dispatched info, warning, and error notifications with titles to verify clean loading and rendering.
   - Verified `;nd` (`<leader>nd`) dismisses active popups and `;nh` (`<leader>nh`) opens history cleanly.
