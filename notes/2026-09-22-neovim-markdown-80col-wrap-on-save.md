# Neovim Markdown 80-Column Auto-Wrap on Save

**Date:** 2026-09-22  
**Context:** Automatically wrap/reflow Markdown prose and list items to `<= 80`
characters when saving (`.md`, `.markdown`) in Neovim without breaking code
blocks, tables, frontmatter, or inline Markdown links.

## Architecture & Implementation

1. **Zero-Dependency Structural Markdown Wrapper
   ([dot_config/nvim/lua/config/markdown.lua](../dot_config/nvim/lua/config/markdown.lua)):**
   - **Hook & Command:** Registered on `BufWritePre` for `*.md` and
     `*.markdown` buffers via `require('config.markdown').setup()` in
     [dot_config/nvim/init.lua.tmpl](../dot_config/nvim/init.lua.tmpl), alongside
     an interactive `:MarkdownWrap` command and `vim.g.markdown_wrap_on_save` /
     `vim.b.markdown_wrap_on_save` bypass flags.
   - **Width Measurement (`vim.api.nvim_strwidth`):** Uses
     `vim.api.nvim_strwidth` rather than `vim.fn.strdisplaywidth` so that active
     window `linebreak` and `wrap` settings do not artificially pad column
     counts near the right edge of 80-column windows.
   - **Protected Structural Blocks:** Passes YAML frontmatter (`---`), fenced
     code blocks (`` ``` `` and `~~~`), indented code blocks, ATX/Setext
     headings, Markdown tables (`| ... |`), link reference definitions
     (`[id]: url`), HTML tags/comments, and hard line breaks (`\` or two
     trailing spaces) through completely untouched.
   - **List & Blockquote Hanging Indentation:** Parses unordered (`-`, `*`,
     `+`), ordered (`1.`, `1)`), and task (`- [ ]`, `- [x]`) list items at any
     nesting depth (and inside blockquotes `> `), computing the exact hanging
     continuation prefix (`cont_prefix`) so continuation lines align cleanly
     under the start of the list item text.
   - **Paragraph & List Reflow Semantics:** Combines all adjacent continuation
     lines within a prose paragraph, blockquote, or list item and reflows them
     to the 80-column break (`<= 80` columns), so both overlong lines (`> 80`
     chars) and edited/shortened adjacent lines (`< 80` chars) join and wrap
     smoothly while respecting blank lines, `**Key:**` metadata boundaries, and
     explicit hard breaks (`\` or `  `).
   - **Atomic Span Tokenization:** Treats inline code spans (`` `...` ``) and
     inline Markdown links/images (`[label](url)`) as single atomic tokens
     whenever they fit within a continuation line (`<= 80 - #cont_prefix`),
     ensuring links and inline code wrap cleanly before the opening bracket/tick
     rather than splitting mid-span.

## Verification

- Applied via `chezmoi apply`.
- Verified with `nvim --headless` across frontmatter, headings, metadata keys,
  prose with inline links/code, nested numbered/task lists, tables, and fenced
  code blocks, confirming all wrapped prose/list lines are strictly `<= 80`
  columns and `BufWritePre` writes the formatted result on `:w`.
