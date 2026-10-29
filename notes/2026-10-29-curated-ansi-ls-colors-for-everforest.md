# Curated ANSI LS_COLORS for Everforest Light and fd Alignment

*Date: 2026-10-29*

## Context & Problem

When running `fd` on terminal outputs, file listings appeared glaringly bright and discordant with the Everforest Light theme.

Upon inspection:
1. **Unset `$LS_COLORS`:** During our Zsh startup optimization pass, `export DISABLE_LS_COLORS="true"` was added to [dot_zshrc.tmpl](../dot_zshrc.tmpl) to prevent Oh-My-Zsh / Antigen from running `dircolors` and parsing completion color maps on every shell boot (~40ms overhead saved). This left `$LS_COLORS` empty/unset.
2. **`fd` / `lscolors` 256-Color Fallback:** `fd` relies on the `lscolors` Rust crate. When `$LS_COLORS` is unset, `lscolors` defaults to an internal hardcoded color table built from fixed 8-bit ANSI 256-color indices (e.g. `\x1b[38;5;81m` neon cyan for directories, `\x1b[1;38;5;203m` neon salmon red for executables, `\x1b[38;5;48m` neon spring green for scripts).
3. **Terminal Palette Isolation:** In [dot_config/ghostty/config.tmpl](../dot_config/ghostty/config.tmpl), Ghostty maps colorscheme palettes (Everforest Light/Dark, Madoromi) exclusively across the standard 16 ANSI colors (`palette = 0..15`). Indices 16–255 are the fixed standard xterm color cube and are not remapped. Raw 256-color codes completely bypass terminal themes.
4. **Low Contrast on Light Backgrounds:** High-luminance pastel and neon indices (chosen for dark backgrounds) have almost zero contrast against Everforest Light's `#fffbef` warm cream background, causing washed-out, eye-straining text.
5. **Dark-Background Inverted Artifacts in Stock Dircolors:** Stock GNU `dircolors` defaults to inverted background blocks (e.g. `40` black background for orphaned links, `42` green background for other-writable directories like `/tmp`), which render as harsh, opaque blocks on light paper backgrounds.

## Solution

We added a curated, static ANSI `$LS_COLORS` and BSD `$LSCOLORS` export in [dot_zshrc.tmpl](../dot_zshrc.tmpl):

1. **Standard 16 ANSI Codes (`31`–`36`, `90`):**
   - Directories: `di=01;34` (bold blue -> Everforest sky slate blue `#3a94c5`)
   - Symlinks: `ln=01;36` (bold cyan -> Everforest seafoam aqua `#35a77c`)
   - Executables: `ex=01;32` (bold green -> Everforest moss green `#8da101`)
   - Orphaned / missing links: `or=01;31` / `mi=01;31` (bold red -> Everforest coral red `#f85552`)
   - Archives / packages: `*.tar`, `*.zip`, `*.gz`, `*.zst`, `*.deb`, etc. = `01;31` (bold red)
   - Images & Video: `*.png`, `*.jpg`, `*.svg`, `*.mp4`, `*.mkv`, etc. = `01;35` (bold purple -> `#df69ba`)
   - Audio: `*.mp3`, `*.flac`, `*.wav`, etc. = `36` (cyan)
   - Documents: `*.pdf` = `31`
   - Backups & dirty files: `*~`, `*.bak`, `*.tmp`, `*.swp` = `00;90` (muted grey -> `#a6b0a0`)
   - Regular code & text files: uncolored, naturally inheriting the crisp default charcoal foreground (`#5c6a72`).
2. **Eliminated Background Highlight Rectangles:**
   - Stripped all `40` (black background) and `42`/`43`/`44` background colorings on directories (`tw=01;34`, `ow=01;34`, `st=01;34`), device nodes (`bd=01;33`, `cd=01;33`), and orphaned symlinks (`or=01;31`), ensuring seamless rendering on light themes.
3. **Automatic Colorscheme Reactivity:**
   - Because standard ANSI 16 indices are used, `fd`, `ls`, and `tree` automatically inherit whichever palette Ghostty is currently running — whether Everforest Light, Everforest Dark, or any seasonal Madoromi theme switched via `theme`.
4. **Zero Overhead:**
   - Plain string export at Zsh initialization with zero subprocess forks or disk reads (< 1µs, preserving our ~80ms shell startup latency).
