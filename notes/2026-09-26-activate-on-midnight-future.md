# Activate Dotfiles and Forks on `midnight-future`

*Date: 2026-09-26*

- Upstream `main` was already current. The submodule worktrees were on local branch checkouts rather than the commits pinned by the parent repository; both had clean working trees. `manage-forks.sh sync` checked out the pins to build, and the original `hylian/latency` and `hylian/autorender` branch checkouts were restored afterward. The parent repository therefore still shows both submodules as modified, as it did before activation.
- Installed the fleet pins: Zellij `c85ff12c` (0.45.1) and zjstatus `f38e8e99`. Build receipts match both parent-repository pins; `manage-forks.sh check` passes. `sccache` is not installed on this host, so the builds ran without it.
- Reviewed and applied pending chezmoi changes to Cargo, Neovim, Zellij, and Zsh. `chezmoi verify`, Zsh syntax checking, headless Neovim startup and `signcolumn=yes`, a login shell with local Zellij first on `PATH`, and `zellij setup --check` all passed. The installed plugin is a WebAssembly module.
- Existing Zellij servers may retain an already loaded zjstatus plugin until restarted; the sync script pruned plugin caches without deleting session metadata or permissions.
