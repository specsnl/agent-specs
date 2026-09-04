---
name: code-comments
description: >
  Use this skill whenever writing or changing code in any language — implementing a feature, fixing a
  bug, refactoring, or scaffolding a file — to decide whether a comment is warranted at all before
  writing one. The default is no comment. Also triggers when the user says "too many comments", "stop
  adding comments", "this is too verbose", "should this be documented?", "add a docblock", "clean up
  the comments", or reviews a diff full of narration. Covers the short allowlist of warranted
  comments, the ban list (restating the code, duplicating one rationale across sites, section
  banners, redundant docblocks, diff/session narration, commented-out code), style rules, and a
  pre-finish sweep of the diff.
---

# Code comments

## The default: write no comment

Code plus good naming is the primary form of explanation. A comment is an exception that must earn
its place by carrying information a competent reader **cannot recover from the code itself**.

If you are about to write a comment, the burden is on the comment. Do not write one unless it falls
under *Warranted* below.

## Match the surrounding file first

Local convention beats this skill's defaults, always. If the file — or its neighbours — documents
every public method, keep documenting them in the same shape. This skill is never a reason to strip
comments from a heavily-documented codebase, nor to introduce a documentation style the repo does
not use.

## Scope

This governs the comments **you write**. It is not a mandate to delete existing comments in files
you happen to touch, and it is not a docs-generation skill. The one exception: if you change code
such that an adjacent comment becomes wrong, update or delete that comment — a false comment is
worse than none.

## Warranted

Write a comment only when it is one of these:

- **Why, not what.** A non-obvious decision, tradeoff, or constraint.

  ```php
  // Cast: the upstream API returns numeric strings for these fields.
  $total = (int) $payload['total'];
  ```

- **A workaround and its cause**, ideally with a link — an upstream bug, a vendor quirk, a spec
  deviation.

  ```ts
  // Safari fires resize before layout settles; see https://bugs.webkit.org/show_bug.cgi?id=170595
  requestAnimationFrame(measure);
  ```

- **Non-obvious consequences.** Ordering that matters, a lock that must be held, a side effect a
  caller would not expect.

  ```go
  // Must run before Close(): the flush path reads the connection.
  w.Flush()
  ```

- **Genuinely subtle algorithms or math**, or a regex that is not self-evident.
- **Public API contracts**, where the language's ecosystem expects them and the file already has
  them.
- **`TODO`/`FIXME` only when the user asked for it or agreed to defer the work.** Never a self-issued
  note about something you skipped — either do it or tell the user in your response.

## Forbidden

### Restating the line below it

```php
// Get the user
$user = $this->users->find($id);   // ✗

$user = $this->users->find($id);   // ✓
```

### The same rationale at every site it touches

State a shared "why" once, at the definition that owns it, and cross-reference it from the rest.

```go
// Records carry the row values themselves, so JSON emits 12 rather than "12".
type TableData struct { /* ... */ }

// WriteTable marshals Records so a number stays a number rather than the
// display string the table renders.                          ✗ same reason again
// WriteTable emits one JSON object per row. See TableData.    ✓
func (w *JSONWriter) WriteTable(data TableData)
```

Rewording a duplicated rationale later is N edits, and N chances to leave a stale copy behind.
Near-duplicates count: four helpers that each explain why a `(nil, nil)` return has to be checked
want one explanation and three pointers to it.

### Section banners

```js
// ===== Helpers =====   ✗
```

Unless the file already uses them. If a file needs banners to be navigable, split the file.

### Docblocks that only repeat the signature

```php
/**
 * @param string $name The name
 * @return User The user
 */
public function findByName(string $name): User   // ✗
```

```php
/**
 * @throws UserNotFound
 */
public function findByName(string $name): User   // ✓
```

Add a docblock only for what the types cannot carry: `@throws`, array shapes, generics, units,
ranges, nullability the signature does not express.

### Diff or session narration

**This is the most common failure — treat it as the hardest rule.** Never write a comment that
refers to what changed, the previous implementation, or your own reasoning.

```php
// Changed from array_map to foreach for clarity   ✗
// NOTE: this is the new behaviour                 ✗
// removed the old permission check                ✗
// as requested, now sorts by date                 ✗
```

That information is real and worth recording — in the **commit message or PR description**, where it
belongs. In the code it is permanent noise: the next reader has no idea what "old" or "new" means.

### Commented-out code

Delete it. Git remembers.

```py
# result = legacy_calculate(x)   ✗
result = calculate(x)
```

### Comments compensating for a bad name

```php
$d = 86400;   // seconds in a day   ✗

$secondsPerDay = 86400;             // ✓
```

Rename instead.

## Style, when a comment is warranted

- Present tense, describing the code as it is.
- No attribution, no dates, no ticket-as-only-content (`// ABC-123` alone says nothing).
- Above the code, not trailing — trailing is acceptable only for a very short note on a short line.
- One line where possible.
- Never repeat what the line next to it already says.
- A name that already carries the contract (`mustLoadConfig`, `tryParse`, `assertValid`) does not
  need it restated — document only what the name cannot say.

## The self-check

Before writing any comment, apply this test:

> **Could a competent reader recover this from the code alone?**

If yes, delete it.

Then, **before you finish**: re-read the comments you added in the diff (`git diff`) and drop every
one that only describes the change, restates the code, or narrates your session. This sweep catches
what the moment-of-writing check misses.

## Language notes

- **PHP** — types cover most of it. Docblocks only for array shapes (`array<string, Foo>`),
  generics, and `@throws`.
- **TS/JS** — JSDoc `@param`/`@returns` is redundant with the type system. Comment behaviour and
  constraints, not signatures.
- **Go** — doc comments on exported identifiers are idiomatic; follow the standard `// Name ...`
  form and say what the caller needs, not what the body does.
- **Shell / YAML / config** — a comment is warranted more often here: the syntax is opaque, values
  are magic, and there are no types or names to carry meaning.
