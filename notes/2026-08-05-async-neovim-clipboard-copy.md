# Asynchronous Neovim Clipboard Copy via `vim.system` (｡•̀ᴗ-)✧

*Date: 2026-08-05*

## Symptom

When pressing single-character or inline deletion keys (`x`, `dw`, `dd`, `d$`, `cw`, `s`, etc.) in Neovim, there was a noticeable ~100ms UI freeze / delay before the editor processed the operation or became responsive to subsequent keystrokes.

## Mechanism

1. **`vim.opt.clipboard = 'unnamedplus'`:**
   Every deletion and cut operation in Vim/Neovim places deleted text into the unnamed register (`"`), which `unnamedplus` maps to the `+` clipboard register. This fires Neovim's `vim.g.clipboard.copy` callback on every delete or yank keystroke.
2. **Synchronous Subprocess Blocking:**
   In [dot_config/nvim/init.lua.tmpl](../dot_config/nvim/init.lua.tmpl), `local_copy()` executed the display clipboard command (`wl-copy` on Wayland) via `vim.fn.system(copy_cmd, lines)`.
3. **Wayland IPC & Fork Overhead:**
   `wl-copy` connects to the active Wayland compositor socket (`wayland-1`), registers a Wayland data source offer, and forks a daemon process. Synchronously awaiting completion of `vim.fn.system` blocked Neovim's main UI event loop for **~105 ms** per keystroke.

## Fix

In [dot_config/nvim/init.lua.tmpl](../dot_config/nvim/init.lua.tmpl), updated `local_copy()` to spawn the clipboard command non-blockingly using `vim.system()`:

```lua
local function local_copy(lines, regtype)
  if copy_cmd then
    local text = type(lines) == 'table' and table.concat(lines, '\n') or tostring(lines)
    vim.system(copy_cmd, { stdin = text, stdout = false, stderr = false })
  end
  write_clip_cache(lines)
  osc52.copy('+')(lines)
end
```

## Verification

1. `chezmoi diff` and `chezmoi apply ~/.config/nvim/init.lua` completed cleanly.
2. `nvim --headless "+q"` exited 0.
3. Benchmarked `setreg('+')`: latency dropped from **105.36 ms** down to **3.66 ms** (~35x faster, well below single-frame responsiveness).
4. Verified clipboard content delivery:
   - `~/.cache/clipboard` contains the copied text.
   - `wl-paste --no-newline` receives and emits the exact copied string.
