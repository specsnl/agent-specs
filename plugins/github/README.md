# GitHub plugin

All Specs GitHub related skills, instructions, commands/prompts are located in this plugin.

## Installation

Claude: `claude plugin install github@specs`

## Skills

**create-pr**:  
Audit `.github/workflows/` to understand what CI will run, check the PR title format requirement,
run CI checks locally (via `ci-green-check` where available), then create the PR with the correct
title and body. Always invoke this instead of running `gh pr create` directly.

**implement-issue**:  
Use when asked to read an issue and implement it (e.g. "read issue X and implement it"). Fetch the
issue (GitHub via a GitHub MCP or the `gh` CLI, or Linear via the Linear MCP), create a new branch,
implement the change with small, clearly-messaged commits, and stop before opening a PR — the PR is
only created when you explicitly ask (via the `create-pr` skill).
