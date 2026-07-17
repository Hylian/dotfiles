# 2026-07-17: Establish Living Ground Truth (SYSTEM.md) ٩(◕‿◕｡)۶

## Purpose
Created a single, authoritative living document `notes/SYSTEM.md` that captures the exact current architecture, host/client topology, keybindings, and preferences.

## Structure & Maintenance Strategy
- **`notes/SYSTEM.md`:** Ground-truth current state. Read on startup by `chez` for instant 0-latency recall. Re-updated and pruned whenever new system details, quirks, or user preferences are learned.
- **`notes/YYYY-MM-DD-*.md`:** Temporal changelog/decision logs capturing *why* specific fixes or experiments were conducted on given days.
- **`SKILL.md` Update:** Updated skill operating principles to codify the continuous maintenance of `notes/SYSTEM.md`.
