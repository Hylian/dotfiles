# Bind `gh` to Switch Between Header and Source File ٩(◕‿◕｡)۶

*Date: 2026-09-01*

## Motivation & Context

In C and C++ firmware development (e.g. Zephyr, MicroXR MCU), toggling between header and implementation files is a constant, high-frequency motion.
Previously:
1. `[` was bound to `:ClangdSwitchSourceHeader`, which in Neovim 0.11 / current `nvim-lspconfig` failed when the command name migrated to `:LspClangdSwitchSourceHeader` or when clangd wasn't attached.
2. `mini.diff`'s default configuration mapped `gh` to apply diff hunks on `BufReadPost`, intercepting the key sequence.

## Key Changes

1. **Unbind `gh` in `mini.diff` ([dot_config/nvim/lua/plugins/init.lua](../dot_config/nvim/lua/plugins/init.lua)):**
   - Configured `mini.diff` with `mappings = { apply = '', reset = '', textobject = '' }` to prevent it from overriding `gh` / `gH`.

2. **Unified Header/Source Toggle ([dot_config/nvim/lua/keybindings.lua](../dot_config/nvim/lua/keybindings.lua)):**
   - Implemented `switch_source_header`:
     - Queries `clangd` LSP via `textDocument/switchSourceHeader` directly.
     - Supports buffer commands `:LspClangdSwitchSourceHeader` and legacy `:ClangdSwitchSourceHeader`.
     - Smart filesystem fallback (`fallback_switch_source_header`): checks corresponding `.h` / `.hpp` / `.c` / `.cpp` / `.cc` in the current directory and sister `include/` / `inc/` / `src/` directories if LSP is unavailable or cannot resolve the pairing.
   - Bound to `gh` (alongside `gd`, `gD`, `gr`) and preserved `[` as an alias.

3. **Living Ground Truth ([notes/SYSTEM.md](SYSTEM.md)):**
   - Documented `gh` and `[` in the standard Neovim keybindings reference.

## Verification

1. Headless test verified `gh` and `[` switching from `.c` to `.h` and back.
2. Verified `mini.diff` initialization no longer overwrites `gh` upon opening files.
3. `chezmoi diff` and `chezmoi apply` applied cleanly.
4. `nvim --headless` executed cleanly with exit code 0.
