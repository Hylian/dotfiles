# 2026-07-17: chez Skill Workflow Refinements ٩(◕‿◕｡)۶

## Overview
Refined `SKILL.md` to incorporate session learnings and codify the standardized developer workflow loop.

## Key Updates
1. **Topology & Host Profiles:** Added explicit context for the primary development stack: Linux workstations accessed locally or remotely from macOS clients via Ghostty terminal over SSH + Zellij multiplexer.
2. **4-Step Modification Lifecycle:** Formalized the operational loop for all configuration modifications:
   - *Edit & Validate:* Modify dotfiles/templates and run headless/diff checks.
   - *Apply:* Run `chezmoi apply`.
   - *Document:* Record problem, root cause, and fix in timestamped notes (`notes/YYYY-MM-DD-*.md`).
   - *Commit:* Clean, conventional git commit for easy rollbacks (no remote push).
