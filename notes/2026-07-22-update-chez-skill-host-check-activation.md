# Update chez Skill to Check Active Host on Activation ٩(◕‿◕｡)۶

*Date: 2026-07-22*

## Change
Updated operating principle 2 in `.agents/skills/chez/SKILL.md` to explicitly require checking the current running machine/host (OS, hostname, workstation vs client) alongside inspecting `notes/SYSTEM.md` and recent timestamped notes upon activation.

## Purpose
Ensures `chez` immediately grounds working memory in the active machine topology (e.g. macOS client vs Linux workstation `shined` / `eterna`) before executing dotfile updates or system diagnoses.
