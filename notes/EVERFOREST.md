# Canonical Everforest Light Palette & Repo Specification ٩(◕‿◕｡)۶

*Living documentation for the Everforest Light color scheme across the dotfiles repository.*

---

## 1. Overview & Philosophy

**Everforest** (created by [Sainnhe Park](https://github.com/sainnhe/everforest)) is a comfortable, warm, green-based color scheme designed for natural readability and reduced eye strain. 

In this repository, **Everforest Light** serves as the primary day theme across our entire environment (terminal, shell, editor, multiplexer, and window manager). The environment is tuned around a crisp **"hard/warm cream"** contrast variant (`#fffbef` background with `#5c6a72` charcoal forest text), accented by lush moss greens, sky blues, and warm ochre tones.

---

## 2. Canonical Color Palette

### A. Foreground & Background Bases

| Role | Canonical Hex | RGB | Description / Usage |
| :--- | :--- | :--- | :--- |
| **Default Background (`bg0` Hard)** | `#fffbef` | `255, 251, 239` | Primary terminal & editor window background (warm cream) |
| **Base Background (`bg0` Medium)** | `#efebd4` | `239, 235, 212` | Muted background for borders, inactive tabs, and UI elements |
| **Soft Background (`bg0` Soft)** | `#e5dfc5` | `229, 223, 197` | Deepest light contrast background |
| **Visual Selection (`bg_visual`)** | `#e5e8c5` | `229, 232, 197` | Vi mode visual selections (`zvm`), text highlights |
| **Subtle Highlight (`bg1` / `bg+`)** | `#f3f5d9` | `243, 245, 217` | FZF active row background, cursor line background |
| **Default Foreground (`fg`)** | `#5c6a72` | `92, 106, 114` | Primary body text, identifiers, and prompt foreground (charcoal) |
| **Muted Foreground (`grey0`)** | `#829181` | `130, 145, 129` | Inactive tabs, comments, line numbers, line borders |
| **Light Muted Grey (`grey1`)** | `#a6b0a0` | `166, 176, 160` | Subtle secondary text, inactive tab headers |

---

### B. Core Accent Palette

| Accent | Canonical Hex | RGB | Semantic Role / Repository Usage |
| :--- | :--- | :--- | :--- |
| **Green** | `#8da101` | `141, 161, 1` | Primary brand accent: Sway focused border, Zellij NORMAL mode badge, Neovim active tab, FZF border |
| **Red** | `#f85552` | `248, 85, 82` | Errors, warnings, Zellij LOCKED mode badge, FZF search matches & pointers |
| **Orange** | `#f57d26` | `245, 125, 38` | Constants, numbers, warnings, git status indicators |
| **Yellow** | `#dfa000` | `223, 160, 0` | Golden ochre: FZF headers, search match highlights, special keywords |
| **Blue** | `#3a94c5` | `58, 148, 197` | Sky slate blue: Zellij session name badge, Starship git branch / git state |
| **Aqua / Cyan** | `#35a77c` | `53, 167, 124` | Seafoam aqua: Starship git branch symbol, FZF info banner |
| **Purple / Magenta** | `#df69ba` | `223, 105, 186` | Blossom purple: Zellij git branch ribbon, special keywords |

---

## 3. Terminal ANSI 16-Color Palette Mapping

Mapped directly into [dot_config/ghostty/config.tmpl](../dot_config/ghostty/config.tmpl#L16-L39):

| ANSI Index | ANSI Slot Name | Hex Code | Visual Tone |
| :---: | :--- | :--- | :--- |
| **0** | Black (Muted Grey) | `#829181` | Charcoal Forest Grey |
| **1** | Red | `#f85552` | Warm Coral Red |
| **2** | Green | `#8da101` | Lush Moss Green |
| **3** | Yellow | `#dfa000` | Golden Ochre |
| **4** | Blue | `#3a94c5` | Sky Slate Blue |
| **5** | Magenta | `#df69ba` | Blossom Purple |
| **6** | Cyan | `#35a77c` | Seafoam Aqua |
| **7** | White | `#f3f5d9` | Light Cream |
| **8** | Bright Black | `#a6b0a0` | Muted Sage Grey |
| **9** | Bright Red | `#fa8987` | Soft Salmon Red |
| **10** | Bright Green | `#bbd411` | Lime Green |
| **11** | Bright Yellow | `#f2cd6d` | Warm Butter Yellow |
| **12** | Bright Blue | `#8fcff2` | Pastel Sky Blue |
| **13** | Bright Magenta | `#f7c1e6` | Soft Pink Purple |
| **14** | Bright Cyan | `#85e6c1` | Mint Aqua |
| **15** | Bright White | `#fdffe8` | Crisp High-Light Background |

---

## 4. Repository Synthesis & Tool Integrations

All tools consume the centralized colorscheme architecture defined in [`.chezmoidata.toml`](../.chezmoidata.toml). Templates resolve the active scheme and palette at the header:
```gotemplate
{{- $csName := get . "colorscheme" | default (get .host_colorschemes .chezmoi.hostname) | default .default_colorscheme -}}
{{- $cs := get .colorschemes $csName -}}
{{- $p := $cs.palette -}}
```

### A. Ghostty Terminal Emulator
* **File:** [dot_config/ghostty/config.tmpl](../dot_config/ghostty/config.tmpl)
* **Background:** `{{ trimPrefix "#" $p.bg0 }}` (`fffbef` warm cream)
* **Foreground:** `{{ trimPrefix "#" $p.fg }}` (`5c6a72` charcoal text)
* **Palette:** Directly mapped 16-color ANSI palette (`0..15`) using `$p.grey0`, `$p.red`, `$p.green`, ..., `$p.br_white`.
* **Selection:** Foreground `{{ trimPrefix "#" ($p.sel_fg | upper) }}` (`D3C6AA`), Background `{{ trimPrefix "#" ($p.sel_bg | upper) }}` (`1E2326`) for high-contrast terminal drag select.

### B. Neovim 0.11
* **File:** [dot_config/nvim/init.lua.tmpl](../dot_config/nvim/init.lua.tmpl) and [dot_config/nvim/lua/config/deadcolumn.lua.tmpl](../dot_config/nvim/lua/config/deadcolumn.lua.tmpl)
* **Appearance:** Dynamically sets `vim.opt.background = '{{ $cs.appearance }}'`.
* **Deadcolumn:** Blend color mapped to `$p.bg_bar` (`#fffbef`), warning blend mapped to `$p.bg_red` (`#fceced`).
* **Plugin & Config:** `neanias/everforest-nvim` loaded in [dot_config/nvim/lua/config/everforest.lua](../dot_config/nvim/lua/config/everforest.lua).
* **Settings:** `background = "hard"`, `ui_contrast = "medium"`, `transparent_background_level = 2`.
* **Tabline:** `TabLineCurrent` set to `#8da101` (Green), inactive tab titles `#5c6a72`.

### C. Zellij Multiplexer & ZJStatus
* **Configuration:** [dot_config/zellij/config.kdl.tmpl](../dot_config/zellij/config.kdl.tmpl) sets `theme "{{ $cs.zellij_theme }}"`.
* **Layouts & ZJStatus:** [dot_config/zellij/layouts/default.kdl.tmpl](../dot_config/zellij/layouts/default.kdl.tmpl) renders a unified statusline driven by `$p`:
  - Mode Badges (`NORMAL`, `RESIZE`, `PANE`, `TAB`, `SCROLL`, `SEARCH`): `$p.green` badge (`#8DA101`) with `$p.fg_reverse` (`#F2EFDF`) text.
  - `LOCKED`: `$p.red` badge (`#F85552`).
  - Statusline Ribbons: Git branch (`$p.purple` `#DF69BA`), Session (`$p.blue` `#3A94C5`), Hostname (`$p.green` `#8DA101`) over `$p.bg_bar` (`#FFFBEF`).
  - Tabs: Inactive tab pill `$p.bg1` (`#F8F5E4`) with `$p.grey2` (`#BEC5B2`) text; active tab pill `$p.tab_active_bg` (`#FCECED`) with `$p.tab_active_fg` (`#5C6A72`) text.

### D. Zsh, FZF, ZVM & CLI
* **Zsh Vi Mode (`zvm`):** [dot_zshrc.tmpl](../dot_zshrc.tmpl) sets `ZVM_VI_HIGHLIGHT_BACKGROUND="{{ $p.bg_visual }}"` (`#e5e8c5`) and `ZVM_VI_HIGHLIGHT_FOREGROUND="{{ $p.fg }}"` (`#5c6a72`) with `extra_style="bold"`.
* **FZF Options:** Unified `$fzfColors` string in [dot_zshrc.tmpl](../dot_zshrc.tmpl) and [dot_config/zsh/widgets.tmpl](../dot_config/zsh/widgets.tmpl) parameterized with `$p.bg2`, `$p.fg`, `$p.green`, `$p.red`, `$p.yellow`, `$p.aqua`, `$p.bg0`, `$p.br_red`.
* **Git Delta:** [dot_config/git/shared_config.tmpl](../dot_config/git/shared_config.tmpl) dynamically binds `[delta]` `syntax-theme = "{{ $cs.delta_syntax_theme }}"`, `dark = {{ eq $cs.appearance "dark" }}`, and maps diff background colors to `$p.diff_add`, `$p.diff_add_emph`, `$p.diff_del`, `$p.diff_del_emph`.
* **Bat:** [dot_config/bat/config.tmpl](../dot_config/bat/config.tmpl) sets `--theme="{{ $cs.bat_theme }}"`.
* **Tuicr:** [dot_config/tuicr/config.toml.tmpl](../dot_config/tuicr/config.toml.tmpl) sets `theme = "{{ $cs.tuicr_theme }}"` and `appearance = "{{ $cs.appearance }}"`.

### E. Window Management & Desktop (Sway, Dunst)
* **Sway ([dot_config/sway/config.tmpl](../dot_config/sway/config.tmpl)):** Window borders parameterized with `{{ $p.moss }}c0`, `{{ $p.green }}c0`, `{{ $p.bg0 }}`, and `{{ $p.fg }}`.
* **Dunst ([dot_config/dunst/dunstrc.tmpl](../dot_config/dunst/dunstrc.tmpl)):** Notification background `{{ $p.bg0 }}a0`, foreground `{{ $p.fg }}f0`.

---

## 5. Centralized Colorscheme Architecture

Defined centrally in [`.chezmoidata.toml`](../.chezmoidata.toml):

1. **Hierarchy & Precedence:**
   - Local override: `~/.config/chezmoi/chezmoi.toml` (`[data] colorscheme = "..."`)
   - Host mapping: `.chezmoidata.toml` `[host_colorschemes.<hostname>]`
   - Global default: `.chezmoidata.toml` `default_colorscheme = "everforest-light"`
2. **First-Class Schemes:**
   - `everforest-light`: Hard warm cream contrast (`#fffbef`), charcoal body (`#5c6a72`), moss green accent (`#8da101`), `OneHalfLight` syntax highlighting.
   - `everforest-dark`: Hard dark background (`#1e2326`), warm cream text (`#d3c6aa`), sage green accent (`#a7c080`), `OneHalfDark` syntax highlighting.
3. **Template Contract:**
   Consuming templates resolve `$csName`, `$cs`, and `$p = $cs.palette`. Individual dotfiles do not maintain independent branching or duplicated color constants.
