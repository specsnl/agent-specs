# GitHub plugin

All Specs GitHub related skills, instructions, commands/prompts are located in this plugin.

## Installation

Claude: `claude plugin install github@specs`  
Copilot: `copilot plugin install github@specs`  

## Skills

**create-pr**:  
Audit `.github/workflows/` to understand what CI will run, check the PR title format requirement,
run CI checks locally (via `ci-green-check` where available), then create the PR with the correct
title and body. Always invoke this instead of running `gh pr create` directly.
