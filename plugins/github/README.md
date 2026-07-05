# GitHub plugin

All Specs GitHub related skills, instructions, commands/prompts are located in this plugin.

## Installation

Claude: `claude plugin install github@specs`

## Skills

**create-pr**:  
Audit `.github/workflows/` to understand what CI will run, check the PR title format requirement,
run CI checks locally (via `ci-green-check` where available), then create the PR with the correct
title and body. Always invoke this instead of running `gh pr create` directly.

## MCP server

Installing this plugin also registers GitHub's official remote MCP server, giving Claude direct
tool access to GitHub (issues, PRs, checks, etc.). After installing, run `/mcp` and complete the
one-click OAuth sign-in to authenticate (a personal access token can be configured instead if
preferred).
