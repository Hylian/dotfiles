# Prune Obsolete Wasm Autorender Commits from Zellij Fork (`hylian/latency`) ٩(◕‿◕｡)۶

*Date: 2026-07-31*

## Summary

1. **Pruned Obsolete Server-Side Autorender Commits:**
   - Reviewed the commit history across local checkouts `~/software/zellij` (`hylian/latency`) and `~/software/zjstatus` (`hylian/autorender`).
   - Confirmed that with `zjstatus` commit `3b74a48` (`fix(command): render when a command result changes`), `zjstatus` properly sets `should_render = true` whenever its command output (`exit_code`, `stdout`, `stderr`) changes.
   - Rebased `hylian/latency` in `~/software/zellij` (`git rebase --onto d715f638 cee898f1 hylian/latency`) to drop two obsolete server-layer autorender commits:
     - `1f44ddb2` (`fix(plugins): render a plugin when its command result arrives`)
     - `cee898f1` (`expose ZELLIJ_PLUGIN_AUTORENDER to plugin-spawned commands`)
2. **Current `hylian/latency` Kernel Latency Stack:**
   - `4ec7c373`: `read process cwd and cmdline from /proc directly on Linux`
   - `d715f638`: `use close_range syscall in pre_exec for O(1) post-fork fd cleanup`
   - `cf1d0d3c`: `fix(pty): optimized get_cmds_by_ppid on linux via /proc to avoid spanning ps synchronously`
   - `hylian/latency` now strictly contains pure OS/PTY performance optimizations, while Wasm plugins (`zjstatus`) manage their own render scheduling.

## Verification

1. Rebased `hylian/latency` cleanly onto `v0.44.3` + OS latency commits.
2. Verified compilation of `zellij-server` with `cargo check -p zellij-server`: completed with zero errors (`Finished dev profile in 47.04s`).
3. Confirmed commit log order and clean working tree in `~/software/zellij`.
