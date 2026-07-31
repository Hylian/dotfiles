# Optimize Neovim Clipboard Sync & Config Cleanup ٩(◕‿◕｡)۶

*Date: 2026-07-31*

## Summary

1. **Removed Redundant `TextYankPost` Clipboard Hook:**
   - In [dot_config/nvim/init.lua.tmpl](../dot_config/nvim/init.lua.tmpl), removed the `TextYankPost` autocommand that double-executed clipboard sync on every yank.
   - Because `vim.opt.clipboard = 'unnamedplus'` and `vim.g.clipboard` overrides copy/paste for `+` and `*` registers, `local_copy()` is already invoked automatically whenever text is yanked or deleted to `+`.
   - Removing `TextYankPost` cuts subprocess spawning (`wl-copy`/`xclip`), disk I/O (`~/.cache/clipboard`), and OSC 52 TTY broadcasts in half on every yank while preserving 100% of headless SSH and universal clipboard behavior.
2. **Removed Dead Config Files:**
   - Removed unreferenced [dot_config/nvim/autocmd.lua](../dot_config/nvim/autocmd.lua) (dts indent rules live in `after/ftplugin/dts.vim`).
   - Removed unreferenced [dot_config/nvim/lua/tmux_copy.lua](../dot_config/nvim/lua/tmux_copy.lua).
3. **Fixed Keybinding Typo & Updated Deprecated API:**
   - In [dot_config/nvim/lua/keybindings.lua](../dot_config/nvim/lua/keybindings.lua), fixed a typo in `<C-S-p>` (`<>` -> `<CR>`).
   - In [dot_config/nvim/lua/config/treesitter.lua](../dot_config/nvim/lua/config/treesitter.lua), updated `vim.loop.fs_stat` to `(vim.uv or vim.loop).fs_stat` for Neovim 0.10+ compatibility in the 100KB filesize guard.

## Verification

1. `chezmoi diff` and `chezmoi apply` executed cleanly.
2. Verified `nvim --headless "+q"` exits 0 cleanly.
3. Benchmarked `time nvim --headless +":normal yy" +":q!"`: completed in **0.36s** with zero hangs or errors.
