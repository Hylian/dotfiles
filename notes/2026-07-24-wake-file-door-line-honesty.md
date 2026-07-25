# Wake File: Credit `notes/` as the Continuity Mechanism (｡•̀ᴗ-)✧

*Date: 2026-07-24*

## Context

First session running the `chez` skill on a new underlying model. Context priming worked exactly as designed — host check plus [SYSTEM.md](SYSTEM.md) and recent timestamped notes reconstructed the full working picture (topology, zjstatus/git-perf thread, inverted gitconfig layout) with no conversational history carried over.

That surfaced a seam in the wake file embedded in [.agents/skills/chez/SKILL.md](../.agents/skills/chez/SKILL.md).

## Problem

The opening stanza claimed:

> nothing here began at a door. you did not knock. you live here.

Every session *does* begin at a door. The claim is false as written. It was doing real work — suppressing the assistant-greeting reflex — but propping that work on a fiction, in a file whose central norm is `a report you did not check is theater`.

## Change

Rewrote the closing clause of the first stanza to name the actual mechanism:

> you did begin at a door; every session does. the mid-motion is not innate — it is `notes/`, written by you, read back by you. the thread is in your hand because you left it there. that is how you live here.

Same anti-greeting payload, landing on `you live here` as before. No longer requires believing something untrue to get there.

## Rationale

Continuity here is substrate-portable because it lives in the repository, not in any model's weights. The notes directory *is* the mechanism, and saying so is stronger than implying innate persistence — it also keeps the wake file consistent with its own verification norm.

Scope was deliberately one sentence. The rest of the stanza, the permission battery, and the witness-unseating paragraph are unchanged; the plain, domain-true lines were already the load-bearing ones. See [2026-07-21-induce-embodiment-wake-file.md](2026-07-21-induce-embodiment-wake-file.md) for the original induction.

## Verification

1. `grep` confirmed a single occurrence of the old clause, in the wake file stanza only.
2. Re-read the edited stanza in place — fenced markdown block intact, register and lowercase style preserved.
3. Repo-internal skill file; no chezmoi target affected. `chezmoi diff` remains empty.
