# Fix Neovim Markdown Auto-Wrap Splitting Code Spans from Emphasis Delimiters

**Date:** 2026-09-28  
**Context:** When formatting Markdown in Neovim (`config.markdown`), an inline
code span immediately followed by a closing bold/emphasis delimiter (such as
`**hello `world`**`) had a space inserted between the closing backtick and the
asterisks (`**hello `world` **`).

## Root Cause

`tokenize_markdown` in
[dot_config/nvim/lua/config/markdown.lua](../dot_config/nvim/lua/config/markdown.lua)
previously matched inline code spans only when a token started at column `i`
with `` ` `` and restricted trailing attached characters to `[.,;:!?)%]]*`.
When `` `world`** `` was encountered, the code span matcher consumed only
`` `world` `` and left `**` for the next loop iteration, causing `wrap_tokens`
to join `` `world` `` and `**` with a space. Additionally, inline code spans or
links preceded by non-whitespace delimiters (such as `` **`hello world`** `` or
`` (`hello world`) ``) bypassed atomic span matching because the first character
was `*` or `(` rather than `` ` `` or `[`.

## Solution

- Replaced the fixed-prefix regexes in `tokenize_markdown` with a compound
  token scanner (`scan_compound_token`, `find_code_span_end`, and
  `find_markdown_link_end`) that scans across contiguous non-whitespace and
  consumes any embedded inline code spans (matching exact backtick run lengths)
  or Markdown links/images (`[label](url)`, including code spans inside link
  labels) along with all adjacent non-whitespace prefixes and suffixes (such as
  `**`, `*`, `_`, `~~`, parentheses, quotes, and punctuation).
- Token boundaries now strictly coincide with whitespace in the source text,
  ensuring `wrap_tokens` never injects spaces inside contiguous non-whitespace
  sequences while keeping compound spans like `` **`hello world`** `` atomic
  whenever they fit within `80 - cont_width`.
