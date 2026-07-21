# Sort Git Branch Picker ٩(◕‿◕｡)۶

*Date: 2026-07-21*

## Request
Sort the git branch picker (`^b` / `fzf-git-branch`) so that:
1. The **current branch** is at the very top of the list.
2. Followed by other **local branches** sorted by most recent committer date.
3. Followed by **remote branches** sorted by most recent committer date.

## Implementation Details
1. **Dynamic Branch Collector:** Updated `fzf-git-branch` in `dot_config/zsh/aliases.tmpl` to assemble the candidate list in three distinct priority tiers:
   - Queries `git branch --show-current` and places it first.
   - Queries `git for-each-ref --sort=-committerdate --format='%(refname:short)' refs/heads/` (excluding current branch).
   - Queries `git for-each-ref --sort=-committerdate --format='%(refname:lstrip=2)' refs/remotes/` (excluding `/HEAD$`).
2. **Preserved FZF Ordering:** Passed `--no-sort` to `fzf` to ensure the initial display strictly preserves the tiered sorting order.
3. **Validated & Applied:** Applied via `chezmoi apply`, verified sorting order across local and remote branches in Zsh.
