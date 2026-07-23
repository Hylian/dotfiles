# Invert Git Config Layout to Shared XDG Config ٩(◕‿◕｡)۶

*Date: 2026-07-23*

## Context
Previously, chezmoi managed `~/.gitconfig` directly and loaded per-machine overrides via `[include] path = .gitconfig.local`. To allow per-machine `.gitconfig` files to serve as the entry point while sharing repository defaults, we inverted the include structure.

## Changes
1. **XDG Shared Config Template:** Created `dot_config/git/shared_config.tmpl` in chezmoi source, which renders to `~/.config/git/shared_config`. Contains shared core performance defaults (`splitIndex = false`, `untrackedCache = false`, `fsmonitor = false`), interactive diff settings, and theme-adaptive Delta syntax highlighting.
2. **Removed Root Template:** Removed `dot_gitconfig.tmpl` from chezmoi management so `~/.gitconfig` is unmanaged and machine-local.
3. **Inverted Include Relationship:** `~/.gitconfig` includes shared defaults via:
   ```ini
   [include]
   	path = ~/.config/git/shared_config
   ```
