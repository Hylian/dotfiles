# Enforce Relative File Links in chez Skill ٩(◕‿◕｡)۶

*Date: 2026-07-23*

## Context
When linking to files in `notes/` or dotfile templates (e.g. `[dot_config/...](...)`), absolute file URLs (`file:///...`) introduce machine-specific workstation paths into public repository content.

## Change
Added Operating Principle 8 to `.agents/skills/chez/SKILL.md`:
- Mandates relative markdown links for all cross-references across notes and configuration templates (e.g. `[dot_config/...](../dot_config/...)` or `[EVERFOREST.md](EVERFOREST.md)`).
- Strictly prohibits absolute file system paths or `file:///` URIs that contain work/machine paths.
