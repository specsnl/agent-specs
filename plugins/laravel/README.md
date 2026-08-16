# Laravel plugin

All Specs Laravel related skills, instructions, commands/prompts are located in this plugin.

## Installation

Claude: `claude plugin install laravel@specs`

## Skills

**executing-commands**:  
REQUIRED: Execute this skill before running ANY project commands (composer, npm, php, docker, etc.).
This ensures all commands run safely through the Taskfile. Do not run docker compose, npm, php,
or composer directly on the host.

**php-checks**:  
Prepare the environment (`task up`) and run the PHP/Laravel quality tools locally through the
Taskfile — `task checkall`, or the individual `composer:script:*` tools (PHP_CodeSniffer,
PHPStan/Larastan, PHPUnit, Rector), the dependency audits and the markdown linter. This is the
PHP/Laravel layer of the `ci-green-check` skill in the `github` plugin, which owns check discovery,
the fix loop, and the final report.

**fix-translations**:  
Find, fix, or translate source-language values in the Laravel translation files (`lang/<locale>/*.php`
and `lang/<locale>.json`). Scans them for untranslated values, translates them to the target
language, fixes errors and typos, commits the changes, and opens a PR — preserving `|` plural
syntax, `:placeholder` tokens, Blade fragments, and array/JSON keys.

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
