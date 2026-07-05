# specsnl/agent-specs

Specs's Claude Code (marketplace) plugins.

## Installation instructions:

Claude: `claude plugin marketplace add specsnl/agent-specs`

The marketplace namespace is `specs`. So after adding this marketplace you will be able to install specific plugins using:

- `claude plugin install <plugin>@specs`.

## Plugins

| Plugin Name   | Description                                                     |
|---------------|-----------------------------------------------------------------|
| laravel@specs | A Specs Laravel specific plugin                                 |
| docker@specs  | A Specs Docker specific plugin                                  |
| linear@specs  | A Specs plugin for creating Linear issues from raw client input |
| github@specs  | A GitHub-specific plugin for Specs                              |

## Recommended tools

- **[crit](https://crit.md)** (`crit@specs`) — Review and comment on plans, code diffs, and frontend elements, then send feedback directly to your agent. Requires the `crit` CLI binary to be installed separately:
  - macOS: `brew install crit`
  - See [crit.md](https://crit.md) for other installation methods (Go, Nix, Windows).

## Tasks

Check out the complete list using `task --list`.
