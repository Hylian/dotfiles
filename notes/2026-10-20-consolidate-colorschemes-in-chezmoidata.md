# Consolidate Centralized Colorscheme Architecture in Chezmoidata ٩(◕‿◕｡)۶

**Date:** 2026-10-20  
**Context:** Centralizing theme resolution and palette tokens across all dotfiles into `[.chezmoidata.toml](../.chezmoidata.toml)`.

---

## 1. Problem & Motivation

Previously, theme and palette definitions across the dotfiles repository suffered from configuration drift and fragmentation:
1. **Ad-Hoc Branching:** Dotfiles relied on binary `{{ if ne .theme "dark" }}` branches scattered across `dot_zshrc.tmpl`, `widgets.tmpl`, `default.kdl.tmpl`, `config.kdl.tmpl`, `shared_config.tmpl`, `init.lua.tmpl`, `deadcolumn.lua.tmpl`, and `bat/config.tmpl`.
2. **Duplicated Palette Codes:** Terminal ANSI definitions, FZF option strings, zjstatus statusline ribbons, and diff backgrounds duplicated raw hex codes across multiple files without a single source of truth.
3. **Hardcoded Tool Outliers:** Desktop tools ([`dot_config/sway/config.tmpl`](../dot_config/sway/config.tmpl) and [`dot_config/dunst/dunstrc.tmpl`](../dot_config/dunst/dunstrc.tmpl)) and review tools ([`dot_config/tuicr/config.toml`](../dot_config/tuicr/config.toml)) hardcoded raw hex values or static themes with no connection to chezmoi's theme data.
4. **Ghostty Palette Typo:** In [`dot_config/ghostty/config.tmpl`](../dot_config/ghostty/config.tmpl), light mode assigned `palette = 16=#fdffe8`, omitting ANSI slot 15 entirely.
5. **No Per-Host or Dynamic Overrides:** Host-level themes or local workstation preferences required manual template edits rather than declarative precedence.

---

## 2. Architecture & Design

### A. Centralized Schema in `[.chezmoidata.toml](../.chezmoidata.toml)`
The root `[.chezmoidata.toml](../.chezmoidata.toml)` defines global defaults, per-host mappings, and rich, named colorscheme definitions (`everforest-light` and `everforest-dark`):

```toml
default_colorscheme = "everforest-light"

[host_colorschemes]
shined = "everforest-light"
eterna = "everforest-light"
shined-mac = "everforest-light"
baumkuchen = "everforest-light"
midnight-future = "everforest-light"

[colorschemes.everforest-light]
name = "everforest-light"
appearance = "light"
zellij_theme = "everforest-light"
delta_syntax_theme = "OneHalfLight"
bat_theme = "OneHalfLight"
tuicr_theme = "everforest-light"

[colorschemes.everforest-light.palette]
# Base backgrounds, foregrounds, ANSI 0-15 accents, tabs, diffs, and selection tokens...
```

### B. Standard Template Resolution Header
Consuming templates resolve the scheme name and palette at the top:
```gotemplate
{{- $csName := get . "colorscheme" | default (get .host_colorschemes .chezmoi.hostname) | default .default_colorscheme -}}
{{- $cs := get .colorschemes $csName -}}
{{- $p := $cs.palette -}}
```

**Resolution Precedence:**
1. Machine-local override in `~/.config/chezmoi/chezmoi.toml` (`[data] colorscheme = "..."`).
2. Per-host mapping in `[host_colorschemes]`.
3. Repository default (`default_colorscheme`).

---

## 3. Implementation Across Dotfiles

1. **Ghostty ([`dot_config/ghostty/config.tmpl`](../dot_config/ghostty/config.tmpl)):**
   - Replaced bifurcated light/dark block with unified mapping using `$p.bg0`, `$p.fg`, `$p.grey0`, `$p.red`, ..., `$p.br_white`.
   - Corrected bright white ANSI slot to `palette = 15={{ $p.br_white }}`.
2. **Zellij Multiplexer & Statusbar:**
   - [`dot_config/zellij/config.kdl.tmpl`](../dot_config/zellij/config.kdl.tmpl): Sets `theme "{{ $cs.zellij_theme }}"`.
   - [`dot_config/zellij/layouts/default.kdl.tmpl`](../dot_config/zellij/layouts/default.kdl.tmpl): Unified zjstatus layout format strings across modes, ribbons, and tabs using `$p`, eliminating over 45 lines of duplicate layout blocks.
3. **Neovim:**
   - [`dot_config/nvim/init.lua.tmpl`](../dot_config/nvim/init.lua.tmpl): Sets `vim.opt.background = '{{ $cs.appearance }}'`.
   - [`dot_config/nvim/lua/config/deadcolumn.lua.tmpl`](../dot_config/nvim/lua/config/deadcolumn.lua.tmpl): Sets `colorcode = '{{ $p.bg_bar }}'` and warning `colorcode = '{{ $p.bg_red }}'`.
4. **Zsh & Widgets:**
   - [`dot_zshrc.tmpl`](../dot_zshrc.tmpl): Sets `ZVM_VI_HIGHLIGHT_BACKGROUND="{{ $p.bg_visual }}"` and `ZVM_VI_HIGHLIGHT_FOREGROUND="{{ $p.fg }}"`.
   - Unified `$fzfColors` string generated in [`dot_zshrc.tmpl`](../dot_zshrc.tmpl) and [`dot_config/zsh/widgets.tmpl`](../dot_config/zsh/widgets.tmpl), giving dark mode full Everforest Dark FZF highlight coverage.
5. **Git Delta & Bat:**
   - [`dot_config/git/shared_config.tmpl`](../dot_config/git/shared_config.tmpl): Binds `syntax-theme = "{{ $cs.delta_syntax_theme }}"`, `dark = {{ eq $cs.appearance "dark" }}`, and maps diff background colors to `$p.diff_add`, `$p.diff_del`, etc.
   - [`dot_config/bat/config.tmpl`](../dot_config/bat/config.tmpl): Sets `--theme="{{ $cs.bat_theme }}"`.
6. **Tuicr:**
   - Converted to template via `git mv dot_config/tuicr/config.toml dot_config/tuicr/config.toml.tmpl`.
   - Dynamically binds `theme = "{{ $cs.tuicr_theme }}"` and `appearance = "{{ $cs.appearance }}"`.
7. **Window Manager & Notifications (Sway, Dunst):**
   - [`dot_config/sway/config.tmpl`](../dot_config/sway/config.tmpl): Window border/titlebar colors dynamically parameterized with `$p.moss`, `$p.green`, `$p.bg0`, `$p.fg`.
   - [`dot_config/dunst/dunstrc.tmpl`](../dot_config/dunst/dunstrc.tmpl): Notification backgrounds parameterized with `$p.bg0` and `$p.fg`.
8. **Madoromi Japanese Ink Palette Integration (8 Schemes):**
   - Added all 8 Madoromi flavours to `.chezmoidata.toml` (`haru-hiru`, `natsu-hiru`, `aki-hiru`, `fuyu-hiru`, `haru-yoru`, `natsu-yoru`, `aki-yoru`, `fuyu-yoru`) with complete Pilot Iroshizuku ink ramps, Oklab blends, diffs, search, and ANSI 0–15 tables.
   - Added explicit `ansi_black` and `ansi_white` to `everforest-light` and `everforest-dark` so Ghostty uses exact ANSI slot extremes without drift.
   - Added custom `themes` definition block to [`dot_config/zellij/config.kdl.tmpl`](../dot_config/zellij/config.kdl.tmpl) for non-Everforest themes.
   - Converted [`dot_config/nvim/lua/config/everforest.lua`](../dot_config/nvim/lua/config/everforest.lua) to [`dot_config/nvim/lua/config/everforest.lua.tmpl`](../dot_config/nvim/lua/config/everforest.lua.tmpl) with dynamic `colours_override = function(palette)` mapping `$p` into treesitter, tabby, lualine, and diffview highlights.
9. **Interactive Colorscheme Switcher & Truecolor Preview (`theme`):**
   - Added `~/.local/bin/theme` via [private_dot_local/bin/executable_theme](../private_dot_local/bin/executable_theme) deployed on Linux and macOS (whitelisted in [.chezmoiignore](../.chezmoiignore)).
   - Implemented strict dirty-worktree guard checking `git status --porcelain --untracked-files=no` outside of `.chezmoidata.toml`.
   - Added rich 24-bit Truecolor (`\e[38;2;R;G;Bm` / `\e[48;2;R;G;Bm`) preview rendering simulated Zellij statusbar, ANSI swatches, syntax highlighting, and git diff on full-width `bg0` canvas.
   - Added live terminal OSC 11/10/4 retheming, zsh wordcode recompilation, and automatic git commit & push.

---

## 4. Verification

1. **Stale Reference Check:**
   - `rg "\.theme\b"`: Confirmed 0 stale `.theme` references remaining across dotfiles.
2. **Chezmoi Diff Fidelity:**
   - `chezmoi diff`: Exactly matches expectations — only fixes Ghostty's `palette = 15=#fdffe8` typo and cleans up indentation in `.zshrc` and `widgets`. All other deployed files produced zero diff under `everforest-light`.
3. **Alternate Scheme Rendering:**
   - Simulated `everforest-dark` via `chezmoi execute-template --config-format toml -c <(echo '[data] colorscheme = "everforest-dark"')`: Verified proper dark background (`#1e2326`), dark zjstatus ribbon styling, dark Delta config (`OneHalfDark`), and dark FZF options.
   - Simulated `haru-hiru` and `fuyu-yoru`: Verified custom Zellij theme blocks, exact Madoromi ANSI 0–15 terminal colors, and Neovim `colours_override` palette tables.
4. **Shell Syntax:**
   - `zsh -n <(chezmoi execute-template < dot_zshrc.tmpl)`: Exit code 0.
   - `zsh -n <(chezmoi execute-template < dot_config/zsh/widgets.tmpl)`: Exit code 0.
5. **Application & Neovim Check:**
   - `chezmoi apply --no-pager`: Applied cleanly.
   - `nvim --headless +qa`: Clean startup and exit.
