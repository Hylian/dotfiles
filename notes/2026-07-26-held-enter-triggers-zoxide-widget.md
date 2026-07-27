# A Held Enter Key Was Opening the Zoxide Picker (｡•̀ᴗ-)✧

*Date: 2026-07-26*

## Symptom

Hold Enter at the zsh prompt and the `^j` zoxide picker opens, repeatedly, accepting a
result each time and walking the shell off to some other directory. Rachel's report came
with a precise and very useful qualifier: **not at shell startup, only after a `cd`**.

That qualifier looks like a clue about `chpwd`. It is actually a clue about *timing*, and
following it as a `chpwd` clue would have led nowhere.

## Mechanism

Enter transmits **CR** (`0x0D`). `^J` is **LF** (`0x0A`). They are different bytes, so the
first question is who converts one into the other.

Not zellij. With the pane tty in raw mode, 40 held Enters delivered 40 CRs and zero LFs.

It is the **line discipline**. Between `accept-line` and the next ZLE read, the pane tty is
in **cooked mode with `ICRNL`**, and `ICRNL` translates CR to LF *as the byte is enqueued* —
not when it is read. Any Enter that autorepeats into that window is stored in the input
queue as `0x0A`. ZLE reads it later, sees `^J`, and dispatches
`bindkey -M viins '^j' zoxide-fzf`. fzf then consumes the Enters still queued behind it and
accepts whatever is under the cursor.

Confirmed directly, cooked mode, 10 held Enters:

| tty setting | `head -c 5` received |
|---|---|
| `stty icrnl` | `\n\n\n\n\n` |
| `stty -icrnl` | *(nothing — canonical mode has no line terminator)* |

So `^J` arriving at ZLE does not mean "Rachel pressed Ctrl-J". It means "Enter was pressed
while the shell was between prompts". The two are byte-identical and cannot be told apart.

This is precisely why zsh ships **both** `^M` and `^J` bound to `accept-line`. Binding `^j`
to anything else is a latent bug on every host, not a quirk of this one.

## Why "only after `cd`"

Nothing about `cd` is special. The race is always live; `cd` only widens the window, because
`chpwd` forks `git rev-parse` for `_zellij_track_git_dirty_cache` plus two zellij CLI
clients. Measured in a live session, 40 held Enters at a 30 ms repeat:

| condition | misfires |
|---|---|
| all hooks disabled | 1 / 40 |
| **no `cd` at all**, one `sleep 0.05` in `precmd` | 21 / 40 |

The second row is the proof: the bug reproduces with zero directory changes. The window is
the variable, and the hooks are just what happens to widen it here.

## Fix

`zoxide-fzf` moves to `^o` (zsh's `accept-line-and-down-history`, dead weight in this
config), and `^j` is bound back to `accept-line` explicitly in all three keymaps. The
explicit rebind matters: re-sourcing
[dot_config/zsh/widgets.tmpl](../dot_config/zsh/widgets.tmpl) in a running shell would
otherwise leave the stale binding in place. `^k` (`zoxide-fzf-curdir`) is untouched — no
control key other than `^j` has a CR relationship, so the rest of the widget set is safe.

Separately, and correct regardless of this bug, both hook-spawned zellij clients in
[dot_zshrc.tmpl](../dot_zshrc.tmpl) now redirect `</dev/null`. They were inheriting the
pane tty as stdin, and `zellij pipe` is a streaming client that reads stdin —
[executable_git-status.sh](../dot_config/zellij/widgets/executable_git-status.sh) already
carried the redirect for exactly this reason. It narrows the window; it does not fix the
race, and was not committed as though it did.

## Rejected

* **`stty -icrnl` globally.** Kills cooked-mode line entry outright — `head` received
  nothing at all, because NL is the canonical line delimiter. Every `cat`, shell `read`,
  and password prompt would hang on Enter.
* **A guard widget that decides whether `^J` was "really" Ctrl-J.** The bytes are identical;
  there is nothing to test. A key that is sometimes Enter and sometimes a picker is worse
  than either.

## Verification

1. Reproduced in a live zellij session before the fix: tab name walked `tmp` → `chezmoi`
   under held Enter, and a probe widget swapped onto `zoxide-fzf` logged `$KEYS` as a
   literal LF with an empty `LBUFFER`.
2. After the fix, 60 held Enters against a *deliberately* worse window (`cd` **and** an
   extra `sleep 0.05` in `precmd`): **0 misfires**.
3. `^o` dispatches to the widget; fzf opens, the picker renders, selecting an entry lands
   the shell in the chosen directory.
4. Enter accepts lines normally throughout, including inside the widened window.
5. `zsh -n` clean on both rendered files; `chezmoi apply` clean.
6. Benchmark sessions deleted, no leftover zellij processes, probe files removed.

## Follow-up

* `shined` carries the same config and the same latent bug; it picks up the fix on its next
  `chezmoi apply`.
