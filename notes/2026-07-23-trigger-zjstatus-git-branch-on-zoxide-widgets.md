# Trigger Instant zjstatus Git Branch Update on Zoxide Widgets ٩(◕‿◕｡)۶

*Date: 2026-07-23*

## Context

When changing directories inside ZLE widgets like `zoxide-fzf` (`^j`) and `zoxide-fzf-curdir` (`^k`), `__zoxide_cd` executes inside ZLE without running top-level `precmd` hooks. As a result, Zellij's status bar (`zjstatus`) relying on interval polling (`command_git_branch_interval "1"`) would lag up to 1 second before updating the git branch for the newly focused directory.

## Change

Added `_zellij_refresh_git_branch()` helper in `dot_config/zsh/widgets.tmpl`:

```zsh
_zellij_refresh_git_branch() {
  if [[ -n "$ZELLIJ" ]] && (( $+commands[zellij] )); then
    command zellij pipe "zjstatus::rerun::command_git_branch" >/dev/null 2>&1 &!
  fi
}
```

Dispatched `_zellij_refresh_git_branch` as a background job right after `__zoxide_cd` in `zoxide-fzf` and `zoxide-fzf-curdir`. This sends an asynchronous pipe message to `zjstatus` to immediately re-evaluate `{focused_pane_cwd}` and refresh the git branch status line upon directory selection.

## Verification

Template syntax rendered cleanly, `chezmoi execute-template` passed `zsh -n`, and `chezmoi apply` completed without error.
