# Installed Zellij and zjstatus Custom Builds on Linux Workstation ٩(◕‿◕｡)۶

*Date: 2026-07-27*

## Summary

Built and installed the custom `zellij` and `zjstatus` forks directly on the Linux workstation (`shined`).

## Components & Paths

1. **`zjstatus` Plugin:**
   - **Source:** `~/software/zjstatus` (`hylian/autorender`)
   - **Target:** `wasm32-wasip1` release build
   - **Installed To:** `~/.config/zellij/plugins/zjstatus.wasm` (3.9 MB)

2. **`zellij` Binary:**
   - **Source:** `~/software/zellij` (`hylian/latency`)
   - **Prerequisite Tools:** `protoc` (v27.3 installed to `~/.local/bin/protoc`) and `mandown` (`v1.1.0` installed via cargo)
   - **Installed To:** `~/.local/bin/zellij` (49 MB, version `0.44.3`)

3. **Chezmoi Template Fix:**
   - Updated `run_onchange_after_20-zjstatus-plugin-permissions.sh.tmpl` to use chezmoi's `env` template function safely.
