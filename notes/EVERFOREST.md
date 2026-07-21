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

### A. Ghostty Terminal Emulator
* **File:** [dot_config/ghostty/config.tmpl](../dot_config/ghostty/config.tmpl)
* **Background:** `fffbef` (Warm cream)
* **Foreground:** `5c6a72` (Charcoal text)
* **Selection:** Foreground `D3C6AA`, Background `1E2326` (high-contrast terminal drag select).

### B. Neovim 0.11
* **Plugin & Config:** `neanias/everforest-nvim` loaded in [dot_config/nvim/lua/config/everforest.lua](../dot_config/nvim/lua/config/everforest.lua).
* **Settings:** `background = "hard"`, `ui_contrast = "medium"`, `transparent_background_level = 2`.
* **Tabline:** `TabLineCurrent` set to `#8da101` (Green), inactive tab titles `#5c6a72`.

### C. Zellij Multiplexer
* **Themes & Layouts:** [dot_config/zellij/themes/everforest-light.kdl](../dot_config/zellij/themes/everforest-light.kdl) and [dot_config/zellij/layouts/default.kdl.tmpl](../dot_config/zellij/layouts/default.kdl.tmpl).
* **Mode Badges:** 
  - `NORMAL`, `RESIZE`, `PANE`, `TAB`, `SCROLL`, `SEARCH`: `#8da101` (Green badge with `#f2efdf` text).
  - `LOCKED`: `#f85552` (Red badge).
* **Statusline Ribbons:** Git branch (`#df69ba` Magenta), Session (`#3a94c5` Blue), Hostname (`#8da101` Green) over `#fffbef`.

### D. Zsh, FZF & ZVM
* **FZF Options ([dot_zshrc.tmpl](../dot_zshrc.tmpl#L275-L280)):**
  `--color=bg+:#f3f5d9,fg:#5c6a72,fg+:#5c6a72,border:#8da101,spinner:#f85552,hl:#f85552,header:#dfa000,info:#35a77c,pointer:#f85552,marker:#f85552,prompt:#fffbef,hl+:#fa8987`
* **Zsh Vi Mode (`zvm`):**
  - Selection Highlight Background (`ZVM_VI_HIGHLIGHT_BACKGROUND`): `#e5e8c5` (Sage).
  - Selection Highlight Text (`ZVM_VI_HIGHLIGHT_FOREGROUND`): `#5c6a72` (Charcoal).
  - Extra Style (`ZVM_VI_HIGHLIGHT_EXTRASTYLE`): `bold`.

### E. Window Management & Desktop (Sway, Waybar, Tofi)
* **Sway ([dot_config/sway/config.tmpl](../dot_config/sway/config.tmpl#L158-L162)):** Focused border `#8da101c0` / `#93b259c0`, focused title bar text `#fffbef`.
* **Tofi Launcher ([dot_config/tofi/config](../dot_config/tofi/config)):** Border color `#8da101e0` (Moss Green).
