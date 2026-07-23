# Add Direct Chezmoi Source Navigation Alias ٩(◕‿◕｡)۶

*Date: 2026-07-22*

## Context

A shell launched through `chezmoi cd` keeps the outer chezmoi process rooted in the directory from which it was invoked. Zellij can therefore report that parent-process directory through `{focused_pane_cwd}`, causing the zjstatus Git branch command to poll outside the actual repository.

## Change

Added `czcd` to the managed Zsh aliases:

```zsh
alias czcd='builtin cd "$(chezmoi source-path)"'
```

This changes the current shell directly into the chezmoi source directory without creating a nested wrapper shell.

## Verification

Rendered aliases passed `zsh -n`, `chezmoi apply` completed cleanly, and an isolated Zsh invocation confirmed that running `czcd` from `/` changes `PWD` to the path returned by `chezmoi source-path`.
