# 2026-07-17: Ensure Git Commits Exclude LLM Harness Tags ٩(◕‿◕｡)۶

## Policy & Requirement
Git commit messages in this repository must remain clean, standard conventional commits and strictly exclude any LLM harness-specific tags, trailers, or metadata (such as `TAG=agy`, `CONV=...`, `BUG=...`, or LLM footers).

## Actions
1. **Skill Definition Updated:** Updated `SKILL.md` (Modification Lifecycle Step 4) to explicitly mandate clean conventional commits free from any harness tags.
2. **Behavioral Spec Updated:** Updated `notes/chez_orientation_spec.md` under Version Control Hygiene.
3. **History Cleanup:** Amended prior commit to remove LLM harness tags from commit history.
