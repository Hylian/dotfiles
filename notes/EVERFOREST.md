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
2. **10 Available Colorschemes:**
   - **Everforest (2):**
     - `everforest-light`: Hard warm cream contrast (`#fffbef`), charcoal body (`#5c6a72`), moss green accent (`#8da101`), `OneHalfLight` syntax highlighting.
     - `everforest-dark`: Hard dark background (`#1e2326`), warm cream text (`#d3c6aa`), sage green accent (`#a7c080`), `OneHalfDark` syntax highlighting.
   - **Madoromi Seasonal Japanese Ink Palettes (8):**
     - `haru-hiru` (Spring Light): Tinted paper wash (`#f6eff8`), ink text (`#584a5c`), neutral ink *kiri-same* (lilac/mauve grey).
     - `natsu-hiru` (Summer Light): Tinted paper wash (`#e9f4f8`), ink text (`#3b545e`), neutral ink *fukagawa-nezu* (ocean sage/teal grey).
     - `aki-hiru` (Autumn Light): Tinted paper wash (`#f8f0e9`), ink text (`#5d4c3c`), neutral ink *yama-guri* (warm sepia/chestnut grey).
     - `fuyu-hiru` (Winter Light): Tinted paper wash (`#f0f1f8`), ink text (`#4a4e63`), neutral ink *fuyu-syogun* (slate blue cool grey).
     - `haru-yoru` (Spring Dark): Deep wash (`#241c26`), soft parchment text (`#e1d1e7`), *kiri-same* neutrals with bright seasonal blooms.
     - `natsu-yoru` (Summer Dark): Deep wash (`#132227`), soft parchment text (`#c0dde8`), *fukagawa-nezu* neutrals with vivid aqua & pink accents.
     - `aki-yoru` (Autumn Dark): Deep wash (`#271d14`), soft parchment text (`#e8d3c1`), *yama-guri* warm neutrals with gold & crimson accents.
     - `fuyu-yoru` (Winter Dark): Deep wash (`#1c1e2a`), soft parchment text (`#d2d6eb`), *fuyu-syogun* slate neutrals with cool indigo & violet accents.
3. **Template Contract & Tool Adapters:**
   - Consuming templates resolve `$csName`, `$cs`, and `$p = $cs.palette`.
   - **Ghostty (`dot_config/ghostty/config.tmpl`):** Directly maps ANSI 0–15 (`ansi_black`, `red`..`purple`, `ansi_white`, `br_black`..`br_white`), selection (`sel_fg`, `sel_bg`), and backgrounds.
   - **Zellij (`dot_config/zellij/config.kdl.tmpl`):** Emits custom `themes { <theme> { ... } }` blocks for Madoromi palettes so Zellij natively displays custom colors.
   - **Neovim (`dot_config/nvim/lua/config/everforest.lua.tmpl`):** Maps `$p` colors through `colours_override = function(palette)` (`bg0`..`bg5`, `bg_visual`, `bg_red`, `bg_green`, `bg_blue`, `bg_yellow`, `fg`, accents, and diffs) so treesitter, diagnostics, lualine, tabby, and diffview adapt seamlessly.

---

## 6. Madoromi Canonical Color Tokens Matrix

All 8 Madoromi palettes are derived from physical measurements of **Pilot Iroshizuku** fountain pen inks modeled in Oklab:

| Token Role | haru-hiru | natsu-hiru | aki-hiru | fuyu-hiru | haru-yoru | natsu-yoru | aki-yoru | fuyu-yoru |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **bg0** (`kami`) | `#f6eff8` | `#e9f4f8` | `#f8f0e9` | `#f0f1f8` | `#241c26` | `#132227` | `#271d14` | `#1c1e2a` |
| **bg_bar** | `#f6eff8` | `#e9f4f8` | `#f8f0e9` | `#f0f1f8` | `#1c151f` | `#0e1a1f` | `#20160e` | `#151722` |
| **bg1** | `#ece5ef` | `#ddeaf0` | `#f0e6dd` | `#e5e7f3` | `#392e3c` | `#23363d` | `#3d3024` | `#2f3241` |
| **bg2** (`nijimi0`) | `#d9ccdd` | `#bed6df` | `#dfcebf` | `#ccd0e4` | `#392e3c` | `#23363d` | `#3d3024` | `#2f3241` |
| **bg_visual** | `#d9ccdd` | `#bed6df` | `#dfcebf` | `#ccd0e4` | `#392e3c` | `#23363d` | `#3d3024` | `#2f3241` |
| **fg** (`sumi`) | `#584a5c` | `#3b545e` | `#5d4c3c` | `#4a4e63` | `#e1d1e7` | `#c0dde8` | `#e8d3c1` | `#d2d6eb` |
| **grey0** (`kasure2`) | `#877b8c` | `#6f848d` | `#8d7d6f` | `#7b7f91` | `#9f93a4` | `#869da5` | `#a59587` | `#9397aa` |
| **grey1** (`kasure1`) | `#998d9e` | `#80969f` | `#9f8f81` | `#8d91a4` | `#8a7e8f` | `#728790` | `#908072` | `#7e8294` |
| **grey2** (`kasure0`) | `#a99cad` | `#8fa6ae` | `#ae9e90` | `#9ca0b3` | `#756a7a` | `#5d737b` | `#7b6c5e` | `#6a6e7f` |
| **red** (`beni`) | `#ce2700` | `#b53753` | `#a43b3b` | `#bb355a` | `#ff8b79` | `#ff8c9f` | `#ff8672` | `#ff8799` |
| **orange** (`kaki`) | `#fd5217` | `#ff5735` | `#ff5635` | `#ff5635` | `#ffbb74` | `#ffb66d` | `#ff9b8f` | `#ff9b8f` |
| **yellow** (`yamabuki`)| `#bda343` | `#e3940b` | `#e3940b` | `#e3940b` | `#ffc849` | `#eec307` | `#ffae1e` | `#ecba09` |
| **green** (`wakaba`) | `#5e8933` | `#00915c` | `#7e8418` | `#618c32` | `#c1dd4a` | `#b9d740` | `#bac105` | `#aece34` |
| **moss** / **aqua** (`tokiwa`) | `#009162` | `#028e7f` | `#008b57` | `#028e7f` | `#7bd6b6` | `#6cd2cc` | `#58c59f` | `#5eccc5` |
| **blue** (`ai`) | `#1955bf` | `#526ccb` | `#384dad` | `#4a63c3` | `#6eadff` | `#4ab8ff` | `#7f9bea` | `#829eeb` |
| **purple** (`botan`) | `#b25d9d` | `#b0599b` | `#a1488d` | `#a74f93` | `#fe8dc0` | `#f894d8` | `#f68fd6` | `#d18bb7` |
| **sel_bg** (`nijimi2`)| `#b8acbd` | `#9fb5be` | `#beae9f` | `#acb0c3` | `#615665` | `#4a5f66` | `#66584b` | `#565a6b` |
| **sel_fg** (`sumi`) | `#584a5c` | `#3b545e` | `#5d4c3c` | `#4a4e63` | `#e1d1e7` | `#c0dde8` | `#e8d3c1` | `#d2d6eb` |
| **diff_add** | `#d9ddd5` | `#c7e2db` | `#e1dcc6` | `#d5dfd5` | `#3c3b32` | `#2d3f31` | `#3e371b` | `#323b33` |
| **diff_del** | `#f4cfd0` | `#e5d3d9` | `#eccfc8` | `#ebd1da` | `#462f35` | `#3b343b` | `#492e23` | `#41303c` |

---

## 7. Interactive Colorscheme Switcher (`theme`)

A native executable CLI and interactive `fzf` picker is deployed to `~/.local/bin/theme` via [private_dot_local/bin/executable_theme](../private_dot_local/bin/executable_theme):

1. **Commands:**
   - `theme`: Launches interactive `fzf` picker showing all 10 available themes with the current host's active theme marked `* (active)`.
   - `theme <name>`: Direct non-interactive activation of any named theme.
   - `theme --list`: Prints all 10 available theme names.
   - `theme --current`: Prints the currently active theme name for the host.
   - `theme --preview <name>`: Renders the 24-bit Truecolor showcase directly to the terminal.
2. **24-bit Truecolor Preview Window:**
   - Evaluated in `fzf` via `--preview "theme --preview {1}" --preview-window="right:68%:wrap"`.
   - Renders a complete full-width canvas on the target theme's `bg0`, showcasing:
     - Theme metadata, appearance, and syntax highlighter ports.
     - Simulated Zellij statusbar (`zjstatus`) with mode, active/inactive tabs, and host ribbons.
     - ANSI 0–7 and Bright ANSI 8–15 color blocks with hex codes.
     - Surfaces and semantic accent chips (`bg0..bg4`, `fg`, `grey0..2`, `red`..`purple`).
     - Real syntax-highlighted code sample on `bg0`.
     - Git Delta diff preview with `diff_add` / `diff_del` and word emphases.
3. **Safety & Automation Workflow:**
   - **Safety Guard:** Scans `git status --porcelain --untracked-files=no` in chezmoi's source directory and aborts immediately if any files other than `.chezmoidata.toml` are modified or staged.
   - **Atomic Chezmoi Application:** Updates `[host_colorschemes.<hostname>]` in `.chezmoidata.toml` and runs `chezmoi apply --no-pager`.
   - **Dynamic Terminal Retheming:** Emits live OSC 11 (`bg0`), OSC 10 (`fg`), OSC 12 (`cursor`), and OSC 4 (`ansi 0..15`) sequences to `/dev/tty` so running terminal emulators (e.g. Ghostty) refresh colors in real time.
   - **Git Commit & Push:** Commits `.chezmoidata.toml` (`chore(theme): set <host> colorscheme to <theme>`) and pushes to `origin main` using cached or forwarded SSH agent credentials.
