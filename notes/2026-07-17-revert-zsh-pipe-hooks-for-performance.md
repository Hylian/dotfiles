# 2026-07-17: Restore Zsh Shell Startup Speed & Decouple from Zellij IPC ٩(◕‿◕｡)۶

## Reflection & Architectural Verdict
**Hooking Zsh shell prompts/events into Zellij status bar pipes was an anti-pattern.**

### Why shell-to-multiplexer IPC hooks hurt:
1. **Shell Initialization & Prompt Latency:** Spawning `command zellij pipe` from shell hooks (`precmd`, `chpwd`) invokes the full Zellij CLI binary, connects to a UNIX domain socket, and sends IPC serialization payloads. Doing this on prompt redraws and shell startup noticeably degrades Zsh responsiveness.
2. **Process Contention:** In rapid subshell execution or Antigen plugin initialization, forking background IPC jobs creates race conditions and lock file contention.
3. **Violation of Separation of Concerns:** `zjstatus` is a standalone WASM plugin running within Zellij's own process space. It is designed to autonomously poll and track CWD without the shell micromanaging it.

## The Clean Solution
1. **Completely removed `zellij_status_update` from `.zshrc`:** Restored Zsh to its native, lightning-fast startup and prompt speed.
2. **Kept layout-native optimizations in `default.kdl.tmpl`:**
   - 1-second native interval timer.
   - Ultra-fast 1ms git branch check (`git branch --show-current` + `-uno --ignore-submodules=dirty`).

## Outcome
Blisteringly fast Zsh startup and prompt rendering with zero shell-level IPC overhead, while Zellij maintains smooth, autonomous 1s status updates.
