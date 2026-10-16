# Add Neovim `:cppwd` Command to Yank Current Buffer Filepath (｡•̀ᴗ-)✧

**Date:** 2026-10-16  
**Context:** Neovim clipboard workflow (`dot_config/nvim/lua/keybindings.lua`).

## Summary

Added the `:cppwd` (and `:Cppwd`) command in [dot_config/nvim/lua/keybindings.lua](../dot_config/nvim/lua/keybindings.lua) to yank the full filepath of the current buffer (`vim.fn.expand('%:p')`) into the clipboard:

1. **User Command (`Cppwd`):**
   - Resolves `vim.fn.expand('%:p')` (warning if the current buffer is unnamed).
   - Writes the path to both the `+` register (which triggers `local_copy` in [dot_config/nvim/init.lua.tmpl](../dot_config/nvim/init.lua.tmpl), syncing to local display clipboard, `~/.cache/clipboard`, and OSC 52) and the `"` unnamed register.
   - Displays a confirmation toast via `vim.notify`.
2. **Lowercase Command Alias (`:cppwd`):**
   - Uses a command-line expression abbreviation (`cnoreabbrev <expr> cppwd`) scoped strictly to `getcmdtype() == ':'` and `getcmdline() =~# '^\s*cppwd$'` so typing `:cppwd` expands cleanly to `Cppwd` without affecting search patterns or arguments.
