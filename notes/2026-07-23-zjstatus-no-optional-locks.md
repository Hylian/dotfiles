# Protect Background Git Status with --no-optional-locks (｡•̀ᴗ-)✧

*Date: 2026-07-23*

## Context & Diagnosis
- Background Git polling scripts (such as Zellij's `zjstatus` plugin or Zsh `precmd` reruns) can race with interactive Git operations or editor processes if they attempt optional index lock acquisition or stat cache updates.
- Under system configs with `core.splitIndex=true` or `core.untrackedCache=true`, background index locking can crash with C assertion failures (`BUG: unpack-trees.c:791`) and leave orphaned zero-byte `.git/index.lock` files, emptying `.git/index`.

## Fixes Applied
1. **Added `--no-optional-locks` to `zjstatus` layout template (`dot_config/zellij/layouts/default.kdl.tmpl`):**
   ```kdl
   command_git_branch_command "sh -c 'b=$(git --no-optional-locks symbolic-ref --short HEAD 2>/dev/null || git --no-optional-locks rev-parse --short HEAD 2>/dev/null); [ -n \"$b\" ] && { git --no-optional-locks diff-index --quiet HEAD -- 2>/dev/null && echo \"$b\" || echo \"$b ●\"; }'"
   ```
2. **Disabled `core.splitIndex` and `core.untrackedCache` in local repo config:**
   - Prevents split index file sync mismatches between `.git/index` and `.git/sharedindex.*`.
