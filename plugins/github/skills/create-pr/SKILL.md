---
name: create-pr
description: >
  Use this skill whenever creating a pull request. Audits .github/workflows/
  to understand what CI will run, checks the PR title format requirement,
  runs CI checks locally (via ci-green-check where available), then creates
  the PR with the correct title and body. Always invoke this instead of
  running gh pr create directly.
---

# Create Pull Request

Audit the repository's PR configuration, verify CI is green, then open the PR.

---

## Phase 1 — Audit PR requirements

Read the repository's PR configuration before touching git.

### 1a. Read all workflow files

```bash
find .github/workflows -name "*.yml" -o -name "*.yaml" | sort
```

For each workflow file, identify:
- Jobs triggered by `pull_request` events
- Any title validation steps (e.g. `pr-title-checker`, `action-semantic-pull-request`)
- Required status checks that must pass

### 1b. Check PR title format

Look for `.github/pr-title-checker-config.json` and read it to extract the allowed prefix pattern.

If not found, check for a workflow step that enforces title format and read its config.

### 1c. Check branch rules

Read `.github/rulesets/*.json` if present. Note:
- Required merge method (Specs projects use merge commits only — no squash/rebase)
- Required status checks

### 1d. Summarise before proceeding

Report:
- What CI jobs will run on this PR
- Required title format / prefix
- Any merge restrictions

---

## Phase 2 — Run CI checks locally

In Laravel/PHP projects: invoke the `ci-green-check` skill.

In other projects: run whatever checks are discovered in Phase 1 that can run locally.

**Do not proceed to Phase 3 if any check fails.**

---

## Phase 3 — Ensure branch and commits are ready

- Confirm the working tree is clean (`git status`)
- Confirm not on `main`/`master` — if so, create a branch first:
  ```bash
  git checkout -b kebab-case-description
  ```
  Use the Linear issue slug as the branch name if one was provided.
- Commit messages must be a **single subject line** — no body, no bullet points.
- Never add a `Co-Authored-By` trailer or mention Claude in any commit message.

---

## Phase 4 — Create the PR

```bash
git push -u origin HEAD
gh pr create --title "PREFIX: short description" --body "$(cat <<'EOF'
## Summary
- ...

## Test plan
- [ ] ...
EOF
)"
```

### Title rules

- Match the format discovered in Phase 1
- If a Linear issue number was provided: `PREFIX-543: description`
- If no issue number: `PREFIX-000: description`
- Never omit the colon and space after the prefix

### Body rules

- Keep it short — a few bullets, no paragraphs
- `## Summary`: 2–4 short bullets of what changed
- `## Test plan`: 1–3 checkbox bullets
- Never mention Claude, AI, or that the work was done in a Claude session

After creating: output the PR URL and the list of CI jobs that will run on it (from Phase 1).
