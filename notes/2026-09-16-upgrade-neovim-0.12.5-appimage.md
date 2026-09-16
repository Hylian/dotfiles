# Upgrade Neovim to v0.12.5 AppImage & Update Plugins

**Date:** 2026-09-16  
**Context:** Upgrade Neovim binary on Linux workstation `shined` from legacy 0.11.0 build to latest stable `v0.12.5` AppImage, install `tree-sitter-cli` binary, and sync plugins.

## Changes

1. **Neovim AppImage Upgrade:**
   - Downloaded latest stable `nvim-linux-x86_64.appimage` (`v0.12.5`) from GitHub releases.
   - Replaced `~/.local/bin/nvim` with the executable AppImage.
   - Verified `nvim --version`: `NVIM v0.12.5`, LuaJIT 2.1.1774638290.

2. **Tree-sitter CLI Installation:**
   - Downloaded `tree-sitter-linux-x64.gz` (`v0.27.0`) from GitHub releases and installed executable to `~/.local/bin/tree-sitter`.
   - Verified `tree-sitter --version`: `tree-sitter 0.27.0`.

3. **Plugin Sync & Parser Compilation:**
   - Ran `nvim --headless "+Lazy! sync" +qa` to sync plugins.
   - Updated `nvim-treesitter` to `main` branch.
   - Compiled treesitter parsers for `bash`, `c`, `lua`, `markdown`, `markdown_inline`, `query`, `regex`, `vim`, `vimdoc`.
   - Verified `:checkhealth nvim-treesitter`: All requirements OK (Neovim ABI 15, `tree-sitter-cli 0.27.0`, tar, curl).
   - Headless test opening markdown and Lua files passed with zero errors or warnings.

4. **Living Ground Truth ([SYSTEM.md](SYSTEM.md)):**
   - Updated editor section in `SYSTEM.md` to reflect Neovim 0.12.x parity across both Linux workstation and macOS clients.
