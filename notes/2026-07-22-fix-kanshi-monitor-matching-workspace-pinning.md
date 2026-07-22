# Fix Kanshi Monitor Matching & Workspace Rearrange Paths ٩(◕‿◕｡)۶

*Date: 2026-07-22*

## Issue
On host `shined`, workspaces 1 through 3 were not pinning to the leftmost monitor (`Lenovo Group Limited LEN T27h-20 VNA702PC`), and subpixel layout settings were relying on transient DisplayPort output identifiers (`DP-3`, `DP-4`, `DP-2`).

## Root Cause
1. **Transient Output Identifiers:** The `worktriple-rotate` profile in `dot_config/kanshi/config.tmpl` matched outputs by port names (`DP-3`, `DP-4`, `DP-2`) instead of full EDID/description strings (`"Lenovo Group Limited LEN T27h-20 VNA702PC"`, `"XXX AAA Unknown"`, `"Lenovo Group Limited LEN T32p-20 VNA7645L"`). When port ordering shifted, output properties failed to match target displays.
2. **Missing `~/.local/bin/` Path Prefix in Command Chains:** In line 104 of `kanshi/config.tmpl`, the `exec` string chained three `rearrange_workspaces.sh` commands separated by semicolons. Only the first command was prefixed with `~/.local/bin/`. Subsequent commands (`rearrange_workspaces.sh ...`) failed with `command not found` under systemd's minimal PATH environment, preventing workspaces 1, 2, and 3 from being bound and moved to the leftmost display (`DP-3` / `LEN T27h-20`).

## Fix
1. **Full Description Output Identifiers:** Updated `profile worktriple-rotate` in `dot_config/kanshi/config.tmpl` to target outputs using full description strings:
   - Leftmost: `"Lenovo Group Limited LEN T27h-20 VNA702PC"` (mode `2560x1440@59.951Hz`, `transform 90`, `subpixel vrgb`)
   - Center: `"XXX AAA Unknown"` (mode `1920x1080@60.0Hz`, `subpixel bgr`)
   - Rightmost: `"Lenovo Group Limited LEN T32p-20 VNA7645L"` (mode `3840x2160@60.0Hz`, `transform 90`, `subpixel vrgb`)
2. **Fully Qualified Exec Paths:** Prefixed all three `rearrange_workspaces.sh` invocations in the kanshi exec chain with `~/.local/bin/rearrange_workspaces.sh` and updated Waybar restart target to `"Lenovo Group Limited LEN T27h-20 VNA702PC"`.
3. **Verified:** Applied via `chezmoi apply` and signaled kanshi with `SIGHUP`. Journal logs confirm all three workspace rearrangement calls executed successfully (`"success": true`) and workspaces 1–3 are bound to the leftmost Lenovo display.
