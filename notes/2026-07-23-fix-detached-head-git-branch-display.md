# Fix Detached HEAD Commit SHA Display in zjstatus ٩(◕‿◕｡)۶

*Date: 2026-07-23*

## Problem

When in detached HEAD state, `git branch --show-current` returns an empty string `""` with exit code `0`. Because the exit code was 0, `git branch --show-current || git rev-parse --short HEAD` did not trigger the fallback `git rev-parse`, leaving `$b` empty and causing `zjstatus` to display nothing.

## Fix

Updated `command_git_branch_command` in `dot_config/zellij/layouts/default.kdl.tmpl`:
```sh
sh -c 'b=$(git branch --show-current 2>/dev/null); [ -z "$b" ] && b=$(git rev-parse --short HEAD 2>/dev/null); [ -n "$b" ] && { [ -n "$(git status --porcelain=v1 -uno --ignore-submodules=dirty 2>/dev/null)" ] && echo "$b ●" || echo "$b"; }'
```

Checking `[ -z "$b" ]` explicitly catches the empty string returned by `git branch --show-current` in detached HEAD state, causing `b` to fall back to `git rev-parse --short HEAD`.

## Verification

1. Verified in detached HEAD (`git checkout --detach HEAD`): prints short commit SHA (`552bd29`).
2. Verified on branch (`git checkout main`): prints branch name (`main`).
3. Applied via `chezmoi apply`.
