# Vertical FZF Split for Git Show Commit Picker (`gshow`)

**Date:** 2026-10-06  
**Context:** Zsh CLI / fzf git workflow enhancement for commit history and diff inspection.

## Problem & Motivation

Previously, `fzf-git-pick-commit` in [dot_config/zsh/aliases.tmpl](../dot_config/zsh/aliases.tmpl) used a horizontal split (`--preview-window=right:65%`). While this gave the Delta preview 65% of the terminal width, it constrained the commit picker list to the left 35%. Because commit log entries carry the commit hash, author name, subject message, and relative timestamp, the narrow 35% column frequently truncated or wrapped commit subjects. Concurrently, side-by-side or wide unified diffs in the preview pane were restricted to 65% width.

## Solution

1. **Vertical FZF Split (`--preview-window=down:85%`):**
   - Updated `fzf-git-pick-commit` in [dot_config/zsh/aliases.tmpl](../dot_config/zsh/aliases.tmpl) to specify `--preview-window=down:85%`.
   - The commit picker is positioned in the top 15% with `--reverse`, keeping the prompt at line 1 and displaying the latest matching commits across the entire terminal width without truncation.
   - The Delta diff preview occupies the bottom 85% below the commit picker, providing full-width rendering for commit diffs.

2. **Preview Scrolling Keybindings:**
   - Bound `ctrl-e` and `down` to `preview-down` for scrolling the preview window down line-by-line.
   - Bound `ctrl-y` and `up` to `preview-up` for scrolling the preview window up line-by-line.
   - Preserved `ctrl-u`/`ctrl-d` and `pgup`/`pgdn` for half-page preview scrolling, while commit selection list navigation remains accessible via `ctrl-j`/`ctrl-k` and `ctrl-n`/`ctrl-p`.

3. **Beneficiaries:**
   - `gshow` and `gshow.`, as well as `fzf-git-difftool` (`gdiff`), `fzf-git-difftool-to` (`gdiffto`), and the `^n` / `git-pick-fzf` widget, inherit this layout when picking commits.

## Verification

1. **Template & Syntax Verification:**
   - Validated template diff via `chezmoi diff`.
   - Applied cleanly via `chezmoi apply`.
   - Compiled `.zwc` wordcode via `zsh -c "zcompile ~/.config/zsh/aliases"`.
   - Verified headless Neovim cleanly (`nvim --headless +qa`).
2. **Layout & Functional Check:**
   - Tested `fzf` preview layout with `--preview-window=down:85% --filter="..."` to confirm clean exit.
   - Verified `git status` and working tree cleanliness.
