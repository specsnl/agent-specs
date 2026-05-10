# Laravel plugin

All Specs Laravel related skills, instructions, commands/prompts are located in this plugin.

## Installation

Claude: `claude plugin install laravel@specs`  
Copilot: `copilot plugin install laravel@specs`  

## Skills

**executing-commands**:  
REQUIRED: Execute this skill before running ANY project commands (composer, npm, php, docker, etc.).
This ensures all commands run safely through the Taskfile. Do not run docker compose, npm, php,
or composer directly on the host.

**ci-green-check**:  
After every code change, discover and run all CI checks found in `.github/` locally before finishing.
Reads `.github/workflows` to find all checks, runs everything that can be run locally (tests, linters,
static analysis), attempts to auto-fix failures, and reports checks that require cloud/secrets.

**autofix-markdown-tables**:  
Automatically detect and fix misaligned markdown tables across all `.md` files in the project.
Runs `markdown-table-formatter` via Docker and rewrites tables in-place. Always review the diff
afterwards to confirm only whitespace/padding changed — no content should be altered.

## Commands

**update-project**:  
Update dependencies of Specs projects based on Laravel using isolated commits.

Claude: `/update-project`  
Copilot: `/laravel:update-project`
