# 2026-07-17: Fix Zellij unfocused pane bell flash & [!] title ٩(◕‿◕｡)۶

## Problem
When switching between panes in Zellij, the unfocused pane would flash pink and display `[!]` in its title / frame.

## Root Cause
When terminal focus reporting was enabled via `printf '\e[?1004h'`, the terminal emulator sent a focus-in sequence (`\e[I`) to the new pane and a focus-out sequence (`\e[O`) to the pane being left.
Because only `zle-focus-in` was registered in Zsh, the old pane received unhandled raw `\e[O` input at the prompt. ZLE treated this as an unrecognized key event and emitted a terminal bell (`BEL`). Zellij captured the bell on the unfocused pane, marked it with a bell notification indicator `[!]`, and highlighted the frame pink.

## Fix
Defined a silent `zle-focus-out()` no-op widget in `.zshrc` and registered it via `zle -N zle-focus-out`.
ZLE now consumes the focus-out sequence cleanly without emitting a terminal bell.
