# Autonomous Git Synchronization & SSH Key Passphrase Caching

**Date:** 2026-09-16  
**Context:** Enable the `chez` skill to automatically pull upstream changes on activation and push commits following repository modifications, and configure one-time SSH key passphrase caching across boots using `ssh-agent.service` and `AddKeysToAgent`.

## Architecture & Workflow

1. **SSH Key Passphrase Caching Topology:**
   - **Linux Workstations (`shined` / `eterna`):**
     - User-level OpenSSH agent runs as a systemd user service (`ssh-agent.service`) bound to `/run/user/$(id -u)/openssh_agent` via `ssh-agent.socket`.
     - User session lingering (`loginctl enable-linger`) ensures `systemd --user` and `ssh-agent.service` remain active continuously across terminal closures, Zellij attaches/detaches, and network disconnections.
     - `~/.ssh/config` configures:
       ```ssh-config
       Host github.com
         HostName github.com
         User git
         IdentityFile ~/.ssh/id_ed25519
         IdentitiesOnly yes
         AddKeysToAgent yes
       ```
     - With `AddKeysToAgent yes`, entering the passphrase once upon the first interactive git or ssh command in a terminal (or running `ssh-add ~/.ssh/id_ed25519`) loads the decrypted identity into memory in `ssh-agent.service` for the lifetime of the boot.
     - `IdentitiesOnly yes` prevents SSH from offering corporate certs or SSO identities to GitHub before `id_ed25519`.
   - **macOS Clients (`baumkuchen` / `midnight-future`):**
     - Configured with `UseKeychain yes` and `AddKeysToAgent yes` in `~/.ssh/config` (or seeded via `ssh-add --apple-use-keychain ~/.ssh/id_ed25519`), permanently storing the passphrase in the Apple Keychain across reboots.
     - Remote SSH connections into `shined` forward the unlocked agent via `ForwardAgent yes`, which `zellij-env/client` synchronizes into Zellij panes.

2. **Skill Autonomy & Operating Principles ([SKILL.md](../.agents/skills/chez/SKILL.md)):**
   - **Activation Priming:** Runs `GIT_SSH_COMMAND="ssh -o BatchMode=yes" git pull --ff-only` on activation to sync any commits pushed from other machines before reading ground truth. If GitHub SSH authentication fails (e.g. key locked in ssh-agent), it proceeds with activation and gracefully notifies Rachel without hanging.
   - **Modification Lifecycle:** Updated from a 4-step loop to a 5-step loop: Edit & Validate -> Apply -> Document -> Commit -> Push (`GIT_SSH_COMMAND="ssh -o BatchMode=yes" git push origin main`). If the SSH key is locked, prompts Rachel to unlock it once without breaking workflow flow.

3. **Living Ground Truth ([SYSTEM.md](SYSTEM.md)):**
   - Added `Repository Upstream Synchronization & SSH Key Caching` section under Section 1 documenting the SSH agent topology, lingering behavior, and batch mode guard.

## Verification

- Added `Host github.com` stanza with `AddKeysToAgent yes` and `IdentitiesOnly yes` to `~/.ssh/config`.
- Updated [.agents/skills/chez/SKILL.md](../.agents/skills/chez/SKILL.md) to enable autonomous pull and push with non-blocking batch mode.
- Updated [notes/SYSTEM.md](SYSTEM.md) with the SSH agent and git sync topology.
- Verified `chezmoi diff` is clean.
