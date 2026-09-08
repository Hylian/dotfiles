# Recursive Current-Directory Git Commit & Diff Viewer (`gshow.`)

**Date:** 2026-09-08  
**Context:** Zsh CLI / fzf git workflow enhancement for localized commit inspection.

## Problem & Motivation

When working deep inside a specific component, module, or subdirectory of a large Git repository (e.g. `dot_config/zsh`, `vr/glasses/...`), running `gshow` displayed every commit across the entire repository. To find changes relevant to the active directory, an engineer had to manually search or scroll through commits that touched unrelated parts of the codebase.

Furthermore, `fzf-git-pick-commit` and `fzf-git-show` ignored directory paths passed as arguments because the existing filter check (`[ -f $@ ]`) only evaluated to true for regular files, skipping directories entirely.

## Solution

1. **Path-Aware Commit Filtering (`fzf-git-pick-commit`):**
   - Updated `fzf-git-pick-commit` in [dot_config/zsh/aliases.tmpl](../dot_config/zsh/aliases.tmpl) to accept optional path arguments (`$@`).
   - When path arguments are provided, it passes `-- "$@"` to `git log` to restrict commit history exclusively to commits modifying those paths.
   - Dynamically constructs `filter="-- ${(j: :)@}"` so that the fzf preview command (`git show --color=always $1 --pretty=full $filter | delta ...`) renders diffs scoped specifically to those paths.
   - When no arguments are provided, it retains the default behavior of displaying all commits across the repository with full commit diffs.

2. **Scoped Selection Display (`fzf-git-show` & `fzf-git-difftool`):**
   - Updated `fzf-git-show` to forward `"$@"` to `fzf-git-pick-commit` and append `-- "$@"` to the final `git show $=commit --pretty` invocation.
   - Uses `$=commit` word-splitting expansion to reliably support multi-commit selections (`fzf -m`).
   - Updated `fzf-git-difftool` and `fzf-git-difftool-to` to forward `"$@"` similarly.

3. **Current-Directory Variant (`gshow.`):**
   - Added `alias gshow.='fzf-git-show .'` in [dot_config/zsh/aliases.tmpl](../dot_config/zsh/aliases.tmpl).
   - Running `gshow.` instantly opens the interactive fzf picker listing only commits that touched files within the current directory subtree (recursively), renders live Delta syntax-highlighted diffs scoped to `.`, and opens the localized diff in `git show` upon pressing Enter.
   - Plain `gshow` continues to view all commits across the repository, but now also accepts optional path arguments (e.g. `gshow path/to/dir` or `gshow file.txt`).

## Verification

1. **Template Rendering & Syntax:**
   - Validated rendered aliases via `chezmoi cat ~/.config/zsh/aliases | zsh -n`.
   - Applied cleanly with `chezmoi apply ~/.config/zsh/aliases`.
   - Verified no drift via `chezmoi diff ~/.config/zsh/aliases`.
2. **Interactive Shell Verification:**
   - Verified `which gshow.` resolves to `fzf-git-show .`.
   - Tested execution from the repository root: `gshow.` scopes to repository root changes (`-- .`).
   - Tested execution from a subdirectory (`dot_config/zsh`): `gshow.` correctly filtered commit list to only commits touching `dot_config/zsh` and passed `-- .` to both preview delta and final `git show`.
   - Verified global `gshow` with no arguments remains unmodified.
