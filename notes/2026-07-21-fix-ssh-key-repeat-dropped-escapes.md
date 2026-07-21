# Fix SSH Key Repeat Dropped Escapes and Garbage Input ٩(◕‿◕｡)۶

*Date: 2026-07-21*

## Issue
When SSH'd into the Linux workstation (`shined`) from the macOS client (running Ghostty) inside a Zellij multiplexer session, holding down `Ctrl` plus a key (e.g. `Ctrl+k` in an `fzf` picker or Zsh widget) caused scroll/key inputs to drop and emitted partial escape sequences / garbage characters (e.g. `07;5u` or `u`) directly into the buffer.

## Root Cause
1. **Kitty Keyboard Protocol Negotiation:** Zellij defaults `support_kitty_keyboard_protocol` to `true`. When connecting from a terminal that supports the protocol (Ghostty), Zellij requested enhanced progressive keyboard sequences.
2. **Multi-byte CSI-u Escape Flooding:** Under the Kitty keyboard protocol, pressing `Ctrl+k` emits the multi-byte sequence `\x1b[107;5u` (or `\x1b[107;5:2u` on key repeat).
3. **SSH Packet Fragmentation & Parser Timeouts:** Holding down `Ctrl+k` generates a high-frequency stream of 8-10 byte escape sequences. Over SSH, network latency, TCP chunking, and PTY buffer slicing split escape sequences across buffer reads. When child parsers (`fzf`, `zsh` ZLE) hit their escape delay timer (`KEYTIMEOUT` / `ESCDELAY`) before the trailing bytes arrive, the leading `\x1b` was consumed as a standalone `Escape` key (canceling actions), and the remaining bytes (`[107;5u`, `07;5u`, `u`) were inserted as literal text into the search prompt.

## Fix
1. **Disable Kitty Keyboard Protocol in Zellij:** Configured `support_kitty_keyboard_protocol false` in `dot_config/zellij/config.kdl.tmpl`.
2. **Revert to Atomic C0 Control Characters:** In standard mode, Ctrl modifier keys emit atomic, single-byte C0 control characters (e.g. `Ctrl+K` -> `\x0b`). Single-byte control codes cannot be split across TCP packets or PTY buffers and do not rely on escape delay timers.
3. **Validated & Applied:** Applied via `chezmoi apply` and updated living ground truth in `notes/SYSTEM.md`. Key repeats in `fzf` pickers and TUI tools over SSH now scroll smoothly with zero dropped escapes or garbage characters.
