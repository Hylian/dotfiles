# Promote `chez` Skill to Root `AGENTS.md` ٩(◕‿◕｡)۶

*Date: 2026-10-27*  
*Host: `shined` (Linux x86_64 Workstation)*

---

## 1. Context & Motivation

Previously, `chez` lived as a repo-local skill at `.agents/skills/chez/SKILL.md`
alongside `.agents/skills/chez/scripts/manage-forks.sh`. Because `.agents/` was
only discovered when working inside the chezmoi source tree—yet skills use
on-demand progressive disclosure—every session required manually prompting
`"activate chez"`, and jumping straight into a dotfiles task risked operating
without `chez`'s ground truth ([SYSTEM.md](SYSTEM.md)), relative-link privacy
guards, `.rgignore` discipline, or clean conventional commit rules.

Moving `chez` to a root [AGENTS.md](../AGENTS.md) makes the orientation and wake
file automatically active on turn 1 across agent harnesses whenever the active
workspace is the chezmoi repository, with zero token footprint elsewhere.

---

## 2. Changes

1. **Root [AGENTS.md](../AGENTS.md) (`git mv .agents/skills/chez/SKILL.md AGENTS.md`):**
   - Removed skill YAML frontmatter (`AGENTS.md` files are always-on workspace
     rules without frontmatter).
   - Reframed Operating Principle 2 from explicit skill activation to
     **Context Priming on Session Start** (priming host topology, upstream git
     pull, [SYSTEM.md](SYSTEM.md) + recent notes, `chezmoi status`/`diff`, and
     fork receipts on the first turn of a session).
   - Updated fork management references to `scripts/manage-forks.sh`.
2. **Top-Level [scripts/manage-forks.sh](../scripts/manage-forks.sh) (`git mv`):**
   - Promoted `.agents/skills/chez/scripts/manage-forks.sh` to
     [scripts/manage-forks.sh](../scripts/manage-forks.sh) and removed the empty
     `.agents/` directory hierarchy.
   - Updated `REPO_ROOT` resolution from hardcoded `${SCRIPT_DIR}/../../../..`
     to `git -C "$SCRIPT_DIR" rev-parse --show-toplevel` (with `${SCRIPT_DIR}/..`
     fallback).
3. **[.chezmoiignore](../.chezmoiignore) Guard:**
   - Added `AGENTS.md` and `scripts/` to [.chezmoiignore](../.chezmoiignore) so
     `chezmoi apply` never deploys `~/AGENTS.md` or `~/scripts/` into `$HOME`
     (which would otherwise cause agents in unrelated `$HOME` subdirectories to
     inherit `AGENTS.md` via ancestor directory traversal).
4. **Ground Truth ([SYSTEM.md](SYSTEM.md)):**
   - Updated references from the retired `.agents/skills/chez/` path to
     [AGENTS.md](../AGENTS.md) and [scripts/manage-forks.sh](../scripts/manage-forks.sh).

---

## 3. Verification

- `chezmoi status` & `chezmoi diff --no-pager`: Clean (0 changes; `AGENTS.md`
  and `scripts/` confirmed excluded from target deployment via
  `chezmoi managed`).
- `scripts/manage-forks.sh status` & `scripts/manage-forks.sh check`: Exits `0`;
  resolves repository root cleanly and reports `zellij` (`c11e9729`) and
  `zjstatus` (`f38e8e99`) `UP TO DATE`.
