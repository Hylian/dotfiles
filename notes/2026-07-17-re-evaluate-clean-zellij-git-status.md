# 2026-07-17: Re-evaluate and Clean Up Zellij Git Status Architecture ٩(◕‿◕｡)۶

## Issues Encountered
1. **Pink flash & [!] bell alert:** Sending raw terminal focus escape sequences (`\e[?1004h`) caused ZLE or sub-processes on focus loss to receive unhandled escape codes, triggering terminal bells (`BEL`).
2. **Cursor flicker & Antigen lock contention:** Terminal focus events and aggressive Zsh hooks during shell startup raced with Antigen plugin initialization, resulting in "Antigen: another process is running" lock warnings and terminal cursor redraw flicker.

## Clean Resolution
- **Removed all raw terminal focus reporting escape codes (`\e[?1004h`) and `zle-focus-*` hooks** from `.zshrc`.
- **Rely on clean Zsh prompt hooks (`chpwd` & `precmd`):** Hooked `zellij_status_update` to `chpwd` (directory changes) and `precmd` (command completion), executed as silent disowned background jobs (`&!`).
- **Rely on Zellij WASM native interval & CWD tracking:** Maintained the 1s interval and 1ms optimized git command (`git branch --show-current` with `-uno --ignore-submodules=dirty`) in `default.kdl.tmpl`.

## Result
Zero terminal escape artifacts, zero pink flash / bell alerts, zero cursor flicker, zero Antigen lock conflicts, and fast, seamless status bar updates.
