---
name: fix-translations
description: |
    Use this skill to find, fix, or translate source-language values in translation files. Scans all translation files for untranslated values, translates them to the target language, fixes errors and typos, commits the changes, and opens a PR.
---

# Fix {{TARGET_LANGUAGE}} Translations — {{REPOSITORY}}

Scan all {{TARGET_LANGUAGE}} translation files for values still in the source language, translate them, fix errors and typos, commit the changes, and open a PR.

## Fixed context

- **Repository**: `{{REPOSITORY}}`
- **Translation files**: {{TRANSLATION_FILES_INLINE}}
- **PR title format**: `{{PR_TITLE_PREFIX}}: <short description>`

---

## Workflow

Execute these phases in order.

### Phase 1 — Scan for untranslated values

Read every file matching {{TRANSLATION_FILES_SCAN}}. For each file, identify values that are still in the source language. A value needs translation if it:

- Uses source-language words as the primary language (e.g. "Save", "Cancel", "Overview")
- Contains a full source-language sentence or phrase
- Is a mix of {{TARGET_LANGUAGE}} and the source language
- Contains a typo that is clearly not {{TARGET_LANGUAGE}}

Do **not** flag:
- Keys (array keys are in the source language by convention)
- Technical/universal strings like email addresses, URLs, currency symbols
- Values that are intentionally the same in both languages (e.g. `'Logo'`, `'URL'`)
- Placeholder variables like `:count`, `:name`

### Phase 2 — Translate and fix

For each identified value, produce the correct {{TARGET_LANGUAGE}} translation. Apply these rules:

- Translate naturally — not word-for-word. Use the tone of the surrounding context.
- {{FORMALITY_NOTE}}
- Plural forms using Laravel's `|` syntax must be preserved: `'{1}in :count day|[2,*]in :count days'` → translate each segment, keep the `|` syntax intact.
- Fix typos
- Fix wrong translations
- Fix mixed-language values

Edit each file directly using precise string replacements. Do not reformat or reorder any surrounding code.

### Phase 3 — Commit

Stage all modified translation files by name (never `git add -A`). Commit with a message that describes what changed:

```
Translate remaining source-language strings in {{TARGET_LANGUAGE}} translation files

Fixes untranslated labels, placeholders, and messages across <N> files:
<comma-separated list of changed files>.
```

### Phase 4 — Create PR

Push the branch and create a PR with `gh pr create`.

**PR title format** (required — CI will fail without it):
```
{{PR_TITLE_PREFIX}}: Translate remaining source-language strings in {{TARGET_LANGUAGE}} translation files
```

- If the user provided a Linear issue number, use it: e.g. `{{PR_TITLE_EXAMPLE}}`
- If no issue number was provided, use: `{{PR_TITLE_PREFIX_ZERO}}`

**PR body** must include:
- A summary of what was changed (table with file → changes)
- A test plan checklist

---

## Rules

- **Never use `git add -A` or `git add .`** — stage only the translation files that were actually modified.
- **Never skip the colon in the PR title** — the format is `{{PR_TITLE_PREFIX}}:` (with colon and space).
- **Do not reformat files** — only change the specific string values that need translating.
- **Do not translate keys** — only values (right-hand side of `=>`) are ever changed.
- **Verify each translation** — if a value's correct translation is unclear, use surrounding context (file name, key name, neighbouring keys) to infer intent before translating.
