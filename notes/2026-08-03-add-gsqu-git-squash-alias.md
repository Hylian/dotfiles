# Added `gsqu` Git Squash Alias (`git add -u && git commit --amend --no-edit`) (｡•̀ᴗ-)✧

*Date: 2026-08-03*

## Summary

Added a new alias `gsqu` to [dot_config/zsh/widgets.tmpl](../dot_config/zsh/widgets.tmpl) that performs the equivalent of `git add -u` in the current repository and immediately squashes the staged changes into the current `HEAD` commit without opening an editor or modifying the commit message.

```zsh
alias gsqu='git add -u && git commit --amend --no-edit'
```

## Behavior & Design

- **Tracked Files (`git add -u`):** Stages modifications and deletions for any files already tracked by Git in the current repository.
- **Untracked Files:** Because `git add -u` only updates index entries for tracked files, any untracked / newly created files not currently in the index are untouched and remain untracked.
- **Commit Amending (`git commit --amend --no-edit`):** Immediately amends the current `HEAD` commit with the staged changes while preserving the existing commit message and timestamp/author metadata.

## Verification

1. `chezmoi diff` and `chezmoi apply` completed cleanly.
2. Verified in interactive Zsh that `gsqu` is available and functional when sourcing [dot_config/zsh/widgets.tmpl](../dot_config/zsh/widgets.tmpl).
3. Verified in a temporary Git repository that `gsqu` correctly stages tracked file changes and amends `HEAD`, while leaving untracked files untouched.
