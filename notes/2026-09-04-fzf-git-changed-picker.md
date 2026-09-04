# Interactive Git Changed Files Picker with `<C-g>` Scope Cycling

**Date:** 2026-09-04
**Context:** Neovim / fzf-lua workflow enhancement for firmware & feature development.

## Problem & Motivation

When actively working on a feature, refactor, or firmware patch, an engineer's mental working set comprises:
1. Files touched in the most recent commit (`HEAD~1..HEAD`).
2. Files currently dirty in the working tree (staged or unstaged).
3. New untracked files (`??`).

Standard `fzf-lua` pickers separate these into disjoint tools:
* `fzf-lua.git_status()` only inspects the working tree and index (rendering empty immediately after a commit).
* `fzf-lua.git_diff()` inspects a specific commit or diff range, omitting unstaged worktree modifications and untracked files.
* `fzf-lua.files()` lists the entire repository (tens of thousands of files), losing the active focus context.

## Solution

Implemented `git_changed_picker(mode, opts)` in [dot_config/nvim/lua/keybindings.lua](../dot_config/nvim/lua/keybindings.lua) and bound it to `<leader>g` (`;g`) and `:GitChanged [both|worktree|head]`.

### Key Features & Design

1. **Three Interactive Scopes:**
   * **`both` (Default - Active Working Set):** Merges `HEAD` commit files and `git status` changes into a unified, deduplicated list.
   * **`worktree`:** Filters strictly to working tree changes (staged, unstaged, untracked).
   * **`head`:** Filters strictly to files touched in the latest commit (`HEAD~1..HEAD`, using `--root` fallback for initial commits).

2. **In-Picker `<C-g>` Scope Cycling:**
   * Maps `<C-g>` in the fzf action handler with `reuse = true`.
   * Pressing `<C-g>` transitions `All` ➔ `Worktree` ➔ `HEAD` ➔ `All` without closing the window, preserving the user's active query string across transitions.
   * Dynamically updates the window title and prompt to reflect the active scope (`Git Active (All)> `, `Git Working Tree> `, `Git HEAD Commit> `).

3. **Status Badges & Pixel-Perfect Alignment:**
   * Each entry is structured as `TAG <icon>\t<filepath>`:
     * `[HEAD]  ` — Committed in `HEAD` (clean in worktree, magenta)
     * `[H*]    ` — In `HEAD` commit and modified again in worktree (bold magenta)
     * `[STAGED]` — Staged in index (green)
     * `[MOD]   ` — Unstaged modification (yellow)
     * `[SM]    ` — Both staged and unstaged edits (bold yellow)
     * `[NEW]   ` — Untracked new file (cyan)
     * `[DEL]   ` — Deleted file (red)
   * The tab delimiter (`\t`) ensures file paths align cleanly into a column regardless of devicon or tag length.

4. **Delta Git Diff Previewer (`GitChangedPreviewer`):**
   * Subclasses `fzf-lua.previewer.fzf.base` to integrate with `fzf-lua`'s RPC-driven command preview mechanism, avoiding shell escaping issues while feeding directly into `delta`.
   * Automatically configures `delta --width=<COLUMNS> --<light|dark>` to match Neovim's `background` and the exact floating preview pane width.
   * Contextually generates diffs:
     * `[NEW]` (untracked): `git diff --color=always --no-index /dev/null -- <file>` to render full file content via delta with line numbers and syntax highlighting.
     * `[HEAD]`: `git diff --color=always HEAD~1 HEAD -- <file>` to render commit diff.
     * `[H*]` (HEAD + dirty): `git diff --color=always HEAD~1 -- <file>` to render cumulative changes across commit and worktree.
     * `[MOD]`, `[STAGED]`, `[SM]`, `[DEL]`: `git diff --color=always HEAD -- <file>` to render all uncommitted working tree and staged index changes.
   * Graceful fallback: falls back to `bat` or colored diff if `delta` is not installed.
   * Lazily initialized on picker invocation to ensure `keybindings.lua` can be required before `config.lazy` during Neovim startup.

5. **Seamless File Navigation Actions:**
   * Uses `_fmt = { from = function(x) return x:match("\t(.*)$") or x end }` so all standard `fzf-lua` file actions (`<CR>` to edit, `<C-v>` vsplit, `<C-s>` split, `<C-t>` tabedit) operate directly on the clean file path.

6. **Half-Page Preview Scrolling (`<C-d>` / `<C-u>`):**
   * Configured `preview-half-page-down` and `preview-half-page-up` for `<C-d>` and `<C-u>` across both `fzf` and `builtin` keymaps (in `config/fzf-lua.lua` globally and directly in `git_changed_picker`).
   * Displayed in the picker header hint (`<C-d>/<C-u>: Scroll Preview`).
