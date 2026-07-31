# Removing CodeCompanion From the Neovim Config ٩(◕‿◕｡)۶

*Date: 2026-07-30*

Rachel doesn't use CodeCompanion, so it comes out entirely rather than being kept on a
deprecation drip (see [2026-07-30-clear-nvim-startup-deprecation-warnings.md](2026-07-30-clear-nvim-startup-deprecation-warnings.md),
whose second half this supersedes).

## What came out

| file | change |
| --- | --- |
| [dot_config/nvim/lua/config/codecompanion.lua](../dot_config/nvim/lua/config/codecompanion.lua) | deleted (setup, anthropic/gemini adapters, `cab cc`) |
| [dot_config/nvim/init.lua.tmpl](../dot_config/nvim/init.lua.tmpl) | dropped `require('config.codecompanion')` |
| [dot_config/nvim/lua/plugins/init.lua](../dot_config/nvim/lua/plugins/init.lua) | dropped the `olimorris/codecompanion.nvim` spec |
| [dot_config/nvim/lua/config/lualine.lua](../dot_config/nvim/lua/config/lualine.lua) | dropped the braille spinner component and its `lualine_x` slot |
| [dot_config/nvim/lua/config/telescope.lua](../dot_config/nvim/lua/config/telescope.lua) | dropped the `codecompanion` picker theme |
| [dot_config/nvim/lua/keybindings.lua](../dot_config/nvim/lua/keybindings.lua) | dropped three commented-out `CodeCompanionChat` maps |

The spinner was a whole `lualine.component` subclass whose only job was watching the
`CodeCompanionRequest*` `User` autocmds — 47 lines, plus the `CodeCompanionHooks` augroup,
all dead the moment the plugin left.

## What deliberately stayed

* **`render-markdown.nvim`** — its `ft` list was `{ "markdown", "codecompanion" }`; only the
  second entry was dropped. It still renders real markdown buffers.
* **`mini.diff`** — it was CodeCompanion's `display.diff.provider`, but it is also the visible
  diff gutter: [gitsigns.lua](../dot_config/nvim/lua/config/gitsigns.lua) runs with
  `signcolumn = false` (`numhl` only), so mini.diff owns the sign column. Removing it would
  have silently taken the gutter with it.
* **`plenary.nvim`** — was listed as a CodeCompanion dependency but telescope requires it
  independently, so lazy keeps it.

## Verification

`chezmoi apply`, then removed the stale rendered `~/.config/nvim/lua/config/codecompanion.lua`
(chezmoi does not delete targets for sources that vanish) and ran `Lazy! sync`, which cleaned
the plugin directory.

* `nvim --headless +qa` → silent, exit 0.
* No `codecompanion` match anywhere under `~/.config/nvim` or `~/.local/share/nvim/lazy`.
* `require("lualine").statusline(true)` renders `NORMAL │ [No Name] │  main │ 0% │ 0:0` —
  branch and diff segments intact, no gap where the spinner sat.
* `require("telescope")` and `require("mini.diff")` both load.
