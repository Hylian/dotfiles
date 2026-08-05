# Fix `zsh-vi-mode` (`zvm`) Double Paste (`p`) Bug ٩(◕‿◕｡)۶

*Date: 2026-08-05*

## Symptom

When yanking text in Neovim and then switching to Zsh to paste via `p` in normal mode (`zvm`), the yanked text was pasted twice consecutively into the command buffer.

## Mechanism

1. `zsh-vi-mode` uses `ZVM_CLIPBOARD_PASTE_CMD='zsh_clipboard_paste'` to retrieve pasteboard content.
2. In [dot_zshrc.tmpl](../dot_zshrc.tmpl), `zsh_clipboard_paste()` queried the active display tool (`wl-paste -n` under Wayland, `xclip` under X11, `pbpaste` on macOS) inside an `if/elif` block.
3. However, the file cache fallback `if [[ -f "$clip_file" ]]; then cat "$clip_file"; fi` was placed immediately after the `if/elif` chain without an `else` or `elif` guard.
4. When a display server was present, `zsh_clipboard_paste` printed the output from the display tool directly to standard output AND then printed the output from `~/.cache/clipboard` to standard output.
5. `zvm_clipboard_get` captured the combined stdout, resulting in the pasted string containing duplicate content.

## Fix

In [dot_zshrc.tmpl](../dot_zshrc.tmpl), updated `zsh_clipboard_paste()` to capture display server output and only fall back to `~/.cache/clipboard` when display output is empty or unavailable:

```zsh
zsh_clipboard_paste() {
  local out clip_file="${XDG_CACHE_HOME:-$HOME/.cache}/clipboard"
  if [[ -n "$WAYLAND_DISPLAY" ]] && (( $+commands[wl-paste] )); then
    out=$(wl-paste -n 2>/dev/null)
  elif [[ -n "$DISPLAY" ]] && (( $+commands[xclip] )); then
    xclip -selection clipboard -o 2>/dev/null
  elif [[ -n "$DISPLAY" ]] && (( $+commands[xsel] )); then
    xsel --clipboard -o 2>/dev/null
  elif [[ "$OSTYPE" == "darwin"* ]] && (( $+commands[pbpaste] )); then
    pbpaste 2>/dev/null
  fi
  if [[ -n "$out" ]]; then
    printf "%s" "$out"
  elif [[ -f "$clip_file" ]]; then
    cat "$clip_file" 2>/dev/null
  fi
  return 0
}
```

## Verification

1. `chezmoi diff ~/.zshrc` and `chezmoi apply ~/.zshrc` applied cleanly.
2. Tested `zsh_clipboard_paste` under both Wayland and headless environments: emitted exactly one copy of the clipboard buffer.
3. Verified interactive Zsh `p` paste operation pastes a single instance of the yanked line.
