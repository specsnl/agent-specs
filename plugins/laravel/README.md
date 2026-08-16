# Laravel plugin

All Specs Laravel related skills, instructions, commands/prompts are located in this plugin.

## Installation

Claude: `claude plugin install laravel@specs`

## Skills

**executing-commands**:  
REQUIRED: Execute this skill before running ANY project commands (composer, npm, php, docker, etc.).
This ensures all commands run safely through the Taskfile. Do not run docker compose, npm, php,
or composer directly on the host.

**ci-green-check**:  
After every code change, discover and run all CI checks found in `.github/` locally before finishing.
Reads `.github/workflows` to find all checks, runs everything that can be run locally (tests, linters,
static analysis), attempts to auto-fix failures, and reports checks that require cloud/secrets.

**fix-translations**:  
Find, fix, or translate source-language values in translation files. Scans all translation files
for untranslated values, translates them to the target language, fixes errors and typos, commits
the changes, and opens a PR.

**e2e-filament-multitenant**:  
Write, expand, or structure Playwright end-to-end tests for a Laravel + Filament
(Spatie-permission) application, especially multi-tenant apps with several panels/roles. Covers the
per-role storageState auth model, shared helpers, a per-role coverage matrix (CRUD / state-machine
workflows / permission boundaries / tenant isolation), a deterministic test-data strategy, the CI
job recipe, and Filament-specific selector conventions.

## Commands

**update-project**:  
Update dependencies of Specs projects based on Laravel using isolated commits.

Claude: `/update-project`
