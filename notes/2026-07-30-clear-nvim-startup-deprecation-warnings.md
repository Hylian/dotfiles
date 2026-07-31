# Clearing the Neovim Startup Deprecation Warnings ＾▽＾

*Date: 2026-07-30*

Rachel hit an error message on every `nvim` start. Two separate deprecation warnings, both
ours, both trivially fixable at the source:

```
vim.lsp.set_log_level() is deprecated. Run ":checkhealth vim.deprecated" for more information
`adapters.<adapter_name>` and `adapters.opts` is deprecated, use `adapters.http.<adapter_name>` and `adapters.http.opts` instead.
Feature will be removed in CodeCompanion v18.0.0
```

## 1. `vim.lsp.set_log_level()`

`lsp.lua` silences LSP logging to keep the log file and memory bounded over multi-day
sessions (see [2026-07-20-fix-nvim-clangd-multi-day-lag.md](2026-07-20-fix-nvim-clangd-multi-day-lag.md)).
The runtime names its own replacement and a removal version:

```
runtime/lua/vim/lsp.lua:1572: vim.deprecate('vim.lsp.set_log_level()', 'vim.lsp.log.set_level()', '0.13')
```

So [dot_config/nvim/lua/config/lsp.lua](../dot_config/nvim/lua/config/lsp.lua) now calls
`vim.lsp.log.set_level(vim.log.levels.WARN)`. The string form (`"warn"`) is still accepted by
the new API, but the level constant is the documented spelling. Verified:
`require("vim.lsp.log").get_level()` → `3`, equal to `vim.log.levels.WARN`.

## 2. CodeCompanion `adapters`

CodeCompanion grew ACP adapters alongside the HTTP ones, so the flat `adapters` table split
into `adapters.http.*` / `adapters.acp.*`. `codecompanion/init.lua` walks any key that is not
`http`/`acp`, warns, and **auto-migrates it** — which is why everything kept working. Removal
lands in v18.0.0.

[dot_config/nvim/lua/config/codecompanion.lua](../dot_config/nvim/lua/config/codecompanion.lua)
now nests both adapter factories under `adapters.http`. Nothing else changed:
`require("codecompanion.adapters").extend(...)` is unchanged API, and
`strategies.chat.adapter = "anthropic"` still resolves by bare name.

Verified after apply:

| check | result |
| --- | --- |
| `c.adapters.http.anthropic` / `.gemini` | `function`, `function` |
| `adapters.resolve(...)` | `anthropic`, `claude-3-opus-latest` |
| `strategies.chat.adapter` | `anthropic` |

## Result

`nvim --headless +qa` is silent, exit 0. `chezmoi diff` clean.
