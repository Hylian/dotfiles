# Optimize Neovim Startup Time via Plugin Lazy-Loading ٩(◕‿◕｡)۶

*Date: 2026-07-31*

## Summary

1. **Deferred Non-Essential Plugin Loading:**
   - In [dot_config/nvim/init.lua.tmpl](../dot_config/nvim/init.lua.tmpl), removed 13 synchronous `require('config.<module>')` calls that were blocking initial startup.
   - Kept only the 6 core visual/editing essentials loading synchronously (`everforest`, `lualine`, `nvim-web-devicons`, `treesitter`, `lsp`, `tabby`) so buffers, syntax highlighting, and UI look perfect on frame 1.
2. **Configured `lazy.nvim` Triggers in `plugins/init.lua`:**
   - In [dot_config/nvim/lua/plugins/init.lua](../dot_config/nvim/lua/plugins/init.lua), added `event`, `cmd`, `keys`, and `config = function() ... end` handlers for deferred plugins:
     - `nvim-cmp` + `LuaSnip` + completion sources: `event = { "InsertEnter", "CmdlineEnter" }`
     - `telescope.nvim`: `cmd = "Telescope"`
     - `fzf-lua`, `codecompanion`, `focus`, `toggleterm`, `spider`, `grug-far`, `commentary`, `fugitive`, `maximizer`: `event = "VeryLazy"`, `cmd`, or `keys`
     - `indent-blankline`, `mini.diff`, `gitsigns`, `sleuth`, `cpp-modern`, `deadcolumn`: `event = { "BufReadPost", "BufNewFile" }`
     - `trim`: `event = "BufWritePre"`

## Benchmark & Verification

1. Executed `chezmoi diff` and `chezmoi apply` cleanly.
2. Benchmarked `nvim --headless --startuptime`:
   - Before: **`181.5ms`** (with `require('config.lazy')` taking ~131ms).
   - After: **`103.0ms`** (with `require('config.lazy')` taking ~63.8ms) — a **43.3% reduction** in startup latency.
3. Verified headless functionality (`nvim --headless "+:lua require('telescope')" +":q!"`, insert mode completion, and spider keybindings all execute cleanly).
