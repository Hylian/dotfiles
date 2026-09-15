# Automated Software Fork Fleet Sync & Per-Machine Build Receipts

**Date:** 2026-09-15  
**Context:** Enable the `chez` skill to automatically track, build, and install custom software forks (`zellij`, `zjstatus`) across machines when changes are made on another host, using git submodules as the canonical version pointer and per-machine JSON receipts.

## Architecture

1. **Canonical Version via Git Submodules ([.gitmodules](../.gitmodules)):**
   - Both maintained forks are tracked under `software/` in `Hylian/dotfiles`:
     - `software/zellij` -> `git@github.com:Hylian/zellij.git` (branch `hylian/latency`)
     - `software/zjstatus` -> `git@github.com:Hylian/zjstatus.git` (branch `hylian/autorender`)
   - The git commit SHA pinned in the parent dotfiles repository defines the fleet-wide canonical version.
   - `software/` is excluded from chezmoi target deployment via [.chezmoiignore](../.chezmoiignore).

2. **Per-Machine Build Receipts (`~/.local/state/builds/<fork>.json`):**
   - Decouples machine build state from the git working tree, eliminating dirty git states or machine-specific tracking files in dotfiles.
   - Each receipt stores:
     - `name`: Fork identifier
     - `commit`: Installed git commit SHA
     - `target`: Installation path (`~/.local/bin/zellij`, `~/.config/zellij/plugins/zjstatus.wasm`)
     - `built_at`: ISO 8601 build timestamp
     - `hostname`, `os`, `arch`: System runtime metadata

3. **Fleet Management Script ([manage-forks.sh](../.agents/skills/chez/scripts/manage-forks.sh)):**
   - `status`: Compares submodule commits against local machine receipts and binary existence.
   - `check`: Fast non-zero exit if any installed binary is missing or behind submodule HEAD.
   - `build <fork>`: Compiles and installs the specified fork, handling macOS-specific fresh inode requirements (`codesign -s - --force`) and zjstatus plugin cache pruning.
   - `sync`: Updates submodules and builds any fork where the installed receipt does not match the pinned submodule commit.
   - `record <fork> [commit]`: Seeds receipts for existing builds.

4. **Autonomous Skill Integration ([SKILL.md](../.agents/skills/chez/SKILL.md)):**
   - Integrated into Context Priming on Activation: `chez` checks `manage-forks.sh check`.
   - If modifications were made on a different machine and pulled down, `chez` automatically runs `manage-forks.sh sync`, updates the receipt, and reports the upgrade.
   - When modifying a fork locally, `chez` builds locally, records the receipt, and advances the submodule pointer in dotfiles.

## Verification

- Added `software/zjstatus` submodule (`8a038754`).
- Seeded receipts on `midnight-future` (`~/.local/state/builds/{zellij,zjstatus}.json`).
- Verified `manage-forks.sh status` reports both forks `UP TO DATE`.
- Verified `manage-forks.sh check` exits 0.
- Verified `chezmoi diff` and `chezmoi status` are completely clean.
