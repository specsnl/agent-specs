# agent-specs

This repo is a Claude Code plugin marketplace. Each plugin under `plugins/<name>/`
bundles some combination of skills, commands, MCP servers, hooks, and agents.

## Keep plugin READMEs in sync

Every plugin's `README.md` must accurately list all the elements the plugin
currently contains — skills, commands, MCP servers, hooks, agents, or anything
else it ships. Whenever you add, remove, or rename any of these inside a
plugin (e.g. a new skill directory under `plugins/<name>/skills/`, a new
command under `plugins/<name>/commands/`, a hook, an MCP server, an agent),
update that plugin's `README.md` in the same change so it never drifts from
what's actually in the plugin directory.

## Keep the root README in sync

The root `README.md` plugins table must list every plugin declared in
`.claude-plugin/marketplace.json`. Whenever a plugin is added, removed, or
renamed in the marketplace manifest, update the root `README.md` table to
match.

## Formatting tables

After editing any markdown table in this repo, use the
`laravel:autofix-markdown-tables` skill to keep columns properly padded and
aligned.
