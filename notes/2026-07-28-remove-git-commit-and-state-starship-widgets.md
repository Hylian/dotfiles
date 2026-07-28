# Removed Git Commit and Git State Widgets from Starship Config ٩(◕‿◕｡)۶

*Date: 2026-07-28*

## Summary

Removed `$git_commit` and `$git_state` from the right prompt format and removed their respective module configurations in Starship configuration ([dot_config/starship.toml](../dot_config/starship.toml)).

## Rationale

The status bar and prompt already track environment git state, and removing the commit hash and git state widgets declutters the prompt's right-hand layout.

## Verification

1. Executed `chezmoi diff` and `chezmoi apply` cleanly.
2. Verified `~/.config/starship.toml` has `$git_commit` and `$git_state` widgets removed.
