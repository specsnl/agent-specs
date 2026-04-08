---
name: update-project
description: Update dependencies of Specs projects based on Laravel using isolated commits.
---

# Goal

Perform a full dependency update of the project.

All commands MUST be executed via `task`. Never run composer, npm, node, or php directly on the host.

If any step fails, STOP immediately and report the error.

## Phase 1 --- Repository Safety Checks

1. Ensure the working (git) tree is clean:
    - No staged changes
    - No unstaged changes
    - No untracked files
    - If not clean: Abort immediately
        - Inform the user to commit or stash changes
2. Synchronize with remote: `git fetch --prune`
3. Prepare branch `vendor-updates`:
    - If branch does not exist → create from `origin/main`
    - If branch exists:
        - If fully merged into `main` → delete locally and recreate from `origin/main`.
        - If behind on `main` and has NO unique commits → reset `vendor-updates` to `origin/main`.
        - If it contains unique commits → abort and notify user.
4. Make sure that there is an `auth.json` file in the project root with correct credentials for private repositories if
the composer.json file contains a repositories section with private repositories like filament.
If not, abort and inform the user to create it. Suggest to the user to run `task setup:auth`.
5. Check if the branch does not already exist on the remote. If it does, abort and inform the user to either delete the
remote branch.

Always branch from latest `origin/main`.

## Phase 2 --- Environment Preparation

1. Start project: `task up`.
2. Ensure environment is refreshed. This makes sure all dependencies are installed according to their respective lock.
files. It will also rebuild the frontend assets. Run the command: `task refresh`.

Abort if any command fails.

## Phase 3 --- Backend Dependencies

1. Update Composer dependencies: `task composer:update` (This task must internally run `composer update -W` inside the
PHP container).
2. Run full backend checks: `task checkall`. If any check fails, try to fix the issues. If you cannot fix the issues,
abort and report the errors.
    - If there are any style issues try and run `task composer:run:fixstyle` to automatically fix them. If that does not
    work try to fix style issues manually If you cannot fix the style issues, abort and report the errors.
    - If there are any PHPStan issues, try to fix them. Do not fix PHPStan issues by adding them to the PHPStan baseline
    file or by adding annotations like `@phpstan-ignore`. If you cannot fix the PHPStan issues, abort and report the
    errors.
    - If there are any PHPUnit test failures, try to fix them. Do not fix test failures by skipping tests. If you cannot
    fix the test failures, abort and report the errors.
3. Check git status for all changed or newly tracked files resulting from the update (including files modified by
post-update scripts such as AGENTS.md, skill files, or published assets). Stage all relevant changes and commit.
Commit message: chore(deps): Updated Composer dependencies.
4. If there are no changes, skip the commit step and move on to the next phase.

Abort on any failure.

## Phase 4 --- NPM package manager version

1. Update NPM package manager version: `task npm:corepack:update`.
2. Commit separately if there are any changes. Commit message: `chore(npm): Updated NPM package manager version`.
3. If there are no changes, skip the commit step and move on to the next phase.

Abort on any failure.

## Phase 5 --- Frontend Dependencies

1. Update NPM dependencies: `task npm:update`.
2. Build assets: `task npm:run:build`.
3. Commit separately if there are any changes. Commit message: `chore(deps): Updated NPM dependencies`.
4. If there are no changes, skip the commit step and move on to the next phase.

Abort on any failure.

## Phase 6 --- Docker Image Updates

1. Scan the following files for pinned Docker image references:
    - `compose.yml`
    - `php/Dockerfile`
    - `nginx/Dockerfile`
    - `.github/workflows/*.yml` (e.g. service images like `mysql:`)
2. For each image found, check for a newer version:
    - For images hosted on `ghcr.io/*`: use the GitHub Releases API to find the latest release tag for that
    repository.
    - For Docker Hub images (`mysql`, `redis`, `axllent/mailpit`, etc.): check Docker Hub for the latest stable tag
    matching the current flavour (e.g. `8.0-bookworm`, `7-bookworm`).
3. Update any outdated image references in-place across all scanned files.
4. After updating, rebuild the local Docker images: `task dc:build`.
5. Reset the environment to make sure it is using the latest images: `task reset`.
6. Run full backend checks: `task checkall`.
7. Check `git status` for all changed files. Commit separately if there are any changes.
Commit message: `chore(deps): Updated Docker image versions`.
8. If there are no changes, skip the commit step and move on to the next phase.

Abort on any failure.

## Phase 7 --- GitHub Actions Updates

1. Scan the following files for pinned `uses:` action references:
    - `.github/workflows/*.yml`
    - `.github/actions/**/*.yml`
2. For each external action (e.g. actions/checkout@v6, shivammathur/setup-php@v2), use the GitHub Releases API to find
the latest release tag. Check every action individually — do not assume that a major-version tag (e.g. @v6) is already
current. A newer major version may exist.
3. Update any outdated action versions in-place across all scanned files.
4. Check `git status` for all changed files. Commit separately if there are any changes.
Commit message: `chore(deps): Updated GitHub Actions versions`.
5. If there are no changes, skip the commit step and move on to the next phase.

Abort on any failure.

## Phase 8 --- Final Checks

1. Run the following audit commands and create a summary of the results. Suggest to the user to fix any of the issues
that are found:
    1. Run `task composer:do:audit`.
    2. Run `task npm:do:audit`.
2. Run `task composer:do:outdated -- --direct --major-only` to check for any major updates that are available for direct
dependencies. If there are any, create a summary and suggest to the user to update those as well.

------------------------------------------------------------------------

## Final State

Abort if there are no changes after all update steps, and inform the user that dependencies are already up to date.

- There could be up to 5 commits on the `vendor-updates` branch:
    1. Composer updates
    2. NPM package manager version update
    3. NPM dependency updates
    4. Docker image version updates
    5. GitHub Actions version updates
- Branch: `vendor-updates`
- Based on latest `origin/main`.
- The working tree should be clean.
- Push the branch to the remote and create a pull request for review and merging targeting `origin/main`. The title
should be prefixed. Check the file `.github/pr-title-checker-config.json` for what the required prefix should be. For
example, it could be `KLIN-000: Update dependencies`.
- Add a Pull Request description that explains the changes and any relevant details about the updates. Stick to the
commit messages, but remove the "chore" prefix. For example:

```md
Updated backend and frontend dependencies:

- Updated Composer dependencies
- Updated NPM package manager version
- Updated NPM dependencies
```
