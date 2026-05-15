---
description: Synchronize sibling PHP repositories by propagating relevant commits from the current repository
name: sync-sibling-php-repos
---

See skill @../skills/php-images/SKILL.md for general information about the PHP images, their repository structure, and
how to find sibling images.

# Goal

Propagate relevant changes from the current PHP image repository to all sibling repositories. Each sibling receives
its own branch, commit history, and pull request that mirrors the original — adjusted where necessary for PHP version
differences.

This command must be run from a PHP image repository on a feature branch that has an open pull request. If you are in
the `php85` repository with updates on a branch, run this command to propagate the applicable changes to `php84` and
`php83`.

If any step fails, STOP immediately and report the error.

## Phase 1 --- Safety Checks

1. Confirm the current branch is **not** `main`. If it is, abort and instruct the user to switch to the feature
   branch first.
2. Ensure the working tree is clean:
    - No staged changes
    - No unstaged changes
    - No untracked files
    - If not clean: abort and instruct the user to commit or stash all changes first.

## Phase 2 --- Context Gathering

1. Identify the current repository name (e.g., `php85`) and the active branch name — this branch name will be
   reused in every sibling.
2. List all commits on the current branch that are not yet on `main`:
   `git log main..HEAD --oneline`
   For each commit, also retrieve its full diff: `git show <sha>`.
3. Find the open pull request for the current branch. Record its **title** and **description** — these will be
   reused verbatim when creating sibling PRs.
4. Locate the sibling repositories using the PHP images skill. Check locally first (sibling directories alongside
   the current repository). Confirm each sibling by verifying its git remote URL or README. Record the local path
   of every sibling that exists.

## Phase 3 --- Change Analysis

For every commit identified in Phase 2, decide whether it applies to each sibling and what adjustments are needed:

- **Applies as-is**: the change is version-agnostic (e.g., a tooling update that supports all PHP versions).
- **Applies with adjustments**: the change is relevant but version strings must be adapted (e.g., a base image
  bump from `php:8.5.x` must become `php:8.4.x` in `php84`).
- **Does not apply**: the change is specific to the source PHP version and cannot or should not be ported (e.g., a
  new dependency that only supports PHP 8.5).

Document the per-sibling plan before proceeding: which commits apply, what adjustments are needed, and in what
order they should be applied (preserve the original commit order).

## Phase 4 --- Sibling Synchronization

Repeat the following steps for each sibling, working through them one sibling at a time:

1. `cd` into the sibling directory.
2. Ensure the working tree is clean. If not, abort.
3. Checkout `main`: `git checkout main`
4. Synchronize with remote: `git fetch --prune && git pull`
5. Create a new branch using the same name as the source branch:
   `git checkout -b <branch-name>`
6. Apply the relevant changes identified in Phase 3. **Do not use `git cherry-pick`** — manually replicate each
   change so that PHP version strings and any other version-specific values are correctly adapted for this sibling.
   Apply the changes in the original commit order.
7. After applying the changes for each logical commit, verify the result looks correct. Then commit with the exact
   same commit message as the corresponding commit in the source repository.
8. Push the branch: `git push -u origin <branch-name>`
9. Create a pull request from `<branch-name>` to `main` using the same title and description as the original pull
   request.

------------------------------------------------------------------------

## Final State

After processing all siblings, provide a summary table listing:

| Sibling repository | Branch created   | Pull request URL | Skipped commits (reason)  |
|--------------------|------------------|------------------|---------------------------|
| `php84`            | `<branch-name>`  | `<PR URL>`       | e.g., none                |
| `php83`            | `<branch-name>`  | `<PR URL>`       | e.g., `abc1234` (PHP 8.5+ only) |
