# Add `Y` Whole-Line Yank for `zsh-vi-mode` (`zvm`) ٩(◕‿◕｡)۶

*Date: 2026-08-05*

## Summary

In `zsh-vi-mode` (`zvm`), lowercase `y` in visual mode yanks only the exact characterwise selection boundaries. Pressing uppercase `Y` was unmapped by default.

Added `zvm_visual_yank_whole_line` and `zvm_yank_whole_line` custom widgets to [dot_zshrc.tmpl](../dot_zshrc.tmpl) and bound them to `Y` in both `visual` and `vicmd` keymaps:

1. **Visual Mode `Y` (`zvm_visual_yank_whole_line`):**
   Calls `zvm_yank $ZVM_MODE_VISUAL_LINE`, which expands any partial visual selection to cover the entire line boundaries (from the beginning of the first selected line to the end of the last selected line) with a trailing newline, copying to `CUTBUFFER`, writing `~/.cache/clipboard`, and broadcasting OSC 52.
2. **Normal Mode `Y` (`zvm_yank_whole_line`):**
   Yanks the entire current line (from line start to line end) with a trailing newline, matching standard Vim `Y` / `yy` behavior.

## Implementation

```zsh
zvm_visual_yank_whole_line() {
  zvm_yank $ZVM_MODE_VISUAL_LINE
  zvm_exit_visual_mode true
}

zvm_yank_whole_line() {
  local bpos=$CURSOR epos=$CURSOR
  for ((bpos=$bpos-1; $bpos>=0; bpos--)); do
    if [[ "${BUFFER:$bpos:1}" == $'\n' ]]; then
      bpos=$((bpos+1))
      break
    fi
  done
  (( bpos < 0 )) && bpos=0

  for ((epos=$epos; $epos<$#BUFFER; epos++)); do
    if [[ "${BUFFER:$epos:1}" == $'\n' ]]; then
      break
    fi
  done

  CUTBUFFER="${BUFFER:$bpos:$((epos-bpos))}"$'\n'
  zvm_clipboard_copy_buffer
}

zvm_define_widget zvm_visual_yank_whole_line
zvm_define_widget zvm_yank_whole_line

zvm_after_init_commands+=(
  "zvm_bindkey visual 'Y' zvm_visual_yank_whole_line"
  "zvm_bindkey vicmd 'Y' zvm_yank_whole_line"
)
```

## Verification

1. `chezmoi diff ~/.zshrc` and `chezmoi apply ~/.zshrc` completed cleanly.
2. Verified in interactive Zsh:
   - Partial visual selection across multiple lines yanked with `Y` expands to full line boundaries with trailing newline.
   - Normal mode `Y` on any line yanks the full line.
   - Pastes back seamlessly with `p` / `P` into Zsh and Neovim.
