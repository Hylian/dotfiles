# Add Zellij Fork as Git Submodule in Dotfiles Repo

**Date:** 2026-09-15  
**Context:** Track the custom Zellij fork (`Hylian/zellij`, branch `hylian/latency`) directly within the dotfiles repository as a git submodule in `software/zellij`.

## Changes

1. **Ignore `software/` from Chezmoi Deployment ([.chezmoiignore](../.chezmoiignore)):**
   - Added `software/` to `.chezmoiignore` so chezmoi does not treat the `software` directory or its submodule contents as files to deploy to `$HOME/software`.
2. **Git Submodule Initialization ([.gitmodules](../.gitmodules)):**
   - Added `git@github.com:Hylian/zellij.git` as a git submodule at `software/zellij`, tracking branch `hylian/latency`.
3. **Living Ground Truth Update ([SYSTEM.md](SYSTEM.md)):**
   - Updated `notes/SYSTEM.md` to reflect that Zellij source is tracked in `software/zellij` within the dotfiles repository.

## Verification

- Verified `git -C software/zellij status -sb` is on `hylian/latency` and clean.
- Verified `chezmoi diff` produces no changes.
- Verified `chezmoi status` is clean.
- Verified `chezmoi apply` succeeds without error.
