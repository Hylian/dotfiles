# Align Zsh gshow Delta Preview with Git Config Styling ٩(◕‿◕｡)۶

**Date:** 2026-10-19  
**Context:** Zsh CLI / git-delta styling harmonization in `gshow` / `fzf-git-pick-commit`.

## Problem & Motivation

The `gshow` alias (and `gshow.`, `^n` / `git-pick-fzf`, `gdiff`, `gdiffto`) uses `fzf-git-pick-commit` to display an interactive commit picker with a live Delta diff preview.

Previously, `fzf-git-pick-commit` invoked `delta` with `--no-gitconfig`:
```zsh
delta --light --syntax-theme=OneHalfLight --true-color always -n --no-gitconfig
```
Because `--no-gitconfig` was passed:
1. **Suppressed Git Config Settings:** Delta explicitly ignored the shared configuration in `~/.config/git/shared_config` (and machine-local `~/.gitconfig`), bypassing `navigate = true` (which adds `•` navigation markers to hunk headers), theme definitions, and custom line number formatting (`line-numbers-left-format = "{nm} "`, `line-numbers-right-format = " {np} "`).
2. **Forced Default Line Numbers:** Passing `-n` together with `--no-gitconfig` forced Delta's default line number rendering (`    ⋮  1 │` with pipes and ellipsis) and default fallback dark-green styling over the preview window, diverging visually from `git show` and the rest of the terminal git toolchain.
3. **Hardcoded Pre-Colored Stream:** Running `git show --color=always` before piping to Delta injected raw ANSI color escapes, overriding Delta's commit styling rules.

## Solution

1. **Remove `--no-gitconfig` & Strip Raw Git Colors:**
   - In [dot_config/zsh/aliases.tmpl](../dot_config/zsh/aliases.tmpl), updated `fzf-git-pick-commit`'s preview command:
     ```zsh
     --preview "f() { set -- \$(echo -- \$@ | grep -o '[a-f0-9]\{7\}'); [ \$# -eq 0 ] || git show \$1 --pretty=full $filter | delta --paging=never --width \"\${FZF_PREVIEW_COLUMNS:-\${COLUMNS:-80}}\"; }; f {}"
     ```
   - Running `delta --paging=never` allows Delta to load `~/.config/git/shared_config` directly, inheriting the active `.theme` syntax theme (`OneHalfLight` or `TwoDark`), navigation markers (`navigate = true`), and any custom Git delta styling options.
   - Piped clean `git show $1 --pretty=full $filter` without `--color=always` so Delta handles commit header and diff decorations natively.

2. **Adaptive Preview Width (`--width`):**
   - Passed `--width "${FZF_PREVIEW_COLUMNS:-${COLUMNS:-80}}"` to ensure Delta formats divider lines and hunk headers to the exact pixel/column boundary of the 85% fzf preview pane, eliminating horizontal divider wrapping.

3. **Beneficiaries:**
   - `gshow` and `gshow.`, as well as `fzf-git-difftool` (`gdiff`), `fzf-git-difftool-to` (`gdiffto`), and the `^n` / `git-pick-fzf` widget, automatically inherit unified git-delta styling.

## Verification

1. **Syntax & Compilation:**
   - Validated template diff via `chezmoi diff ~/.config/zsh/aliases`.
   - Verified shell syntax via `zsh -n <(chezmoi execute-template < dot_config/zsh/aliases.tmpl)`.
   - Applied cleanly to `~/.config/zsh/aliases` via `chezmoi apply --no-pager ~/.config/zsh/aliases`.
   - Recompiled wordcode bundle via `zcompile ~/.config/zsh/aliases`.
   - Verified Neovim cleanly via `nvim --headless +qa`.
2. **Functional & Output Check:**
   - Tested interactive fzf preview function with recent commit (`112911a`): confirmed navigation bullet (`•`), clean soft cream/OneHalfLight diff highlighting, and 90-column divider formatting under `COLUMNS=90`.
   - Tested scoped path filtering (`gshow notes/SYSTEM.md` / `gshow.`): verified diff output correctly scopes to specified file path.
