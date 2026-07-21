# Fix Neovim Treesitter Markdown Parser & Compatibility ٩(◕‿◕｡)۶

*Date: 2026-07-21*

## Issue
Opening markdown files triggered a Lua runtime error:
`No parser for language "markdown"` from `render-markdown.nvim` attempting to attach Treesitter queries when parsers were missing or when `nvim-treesitter` defaulted to the upstream `main` rewrite.

## Fix Details
1. **Branch Pinning in Lazy.nvim:** Pinned `nvim-treesitter/nvim-treesitter` to `branch = 'master'` with `lazy = false` in `dot_config/nvim/lua/plugins/init.lua` to maintain full stability with Neovim 0.11 and downstream plugins (`render-markdown.nvim`, `nvim-treesitter-context`, `codecompanion.nvim`).
2. **Configured `nvim-treesitter.configs`:** Updated `dot_config/nvim/lua/config/treesitter.lua` to invoke `nvim-treesitter.configs.setup` with `ensure_installed` (`c`, `lua`, `vim`, `vimdoc`, `query`, `markdown`, `markdown_inline`) and `auto_install = true`.
3. **Buffer Size Guard:** Preserved the 100 KB buffer size limit to prevent syntax highlighting lag on oversized files.
4. **Validation:** Applied changes via `chezmoi apply`, verified headless buffer reads across `.md`, `.lua`, `.c`, and `.sh` files with 0 errors.
