# Code plugin

Cross-language code authoring conventions — the rules that apply whatever the stack is. Language- or
framework-specific guidance lives in its own plugin.

## Installation

Claude: `claude plugin install code@specs`

## Skills

**code-comments**:  
Decide whether a comment is warranted *before* writing one, in any language. The default is no
comment: code and naming explain themselves, and a comment must carry information the code cannot.
Covers the short allowlist (why-not-what, workarounds, non-obvious consequences, subtle algorithms,
public API contracts, agreed TODOs), the ban list (restating the code, section banners, redundant
docblocks, diff/session narration, commented-out code, comments compensating for a bad name), style
rules, and a pre-finish sweep of the diff. Local convention in the file always wins.

**autofix-markdown-tables**:  
Automatically detect and fix misaligned markdown tables across all `.md` files in the project.
Runs `markdown-table-formatter` via Docker and rewrites tables in-place. Always review the diff
afterwards to confirm only whitespace/padding changed — no content should be altered.
