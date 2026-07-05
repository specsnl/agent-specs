# Linear plugin

All Specs Linear related skills, instructions, commands/prompts are located in this plugin.

## Installation

Claude: `claude plugin install linear@specs`

## Skills

**linear-intake**:  
Convert raw client input (email, WhatsApp, verbal, or a Linear issue URL) into a properly structured
Linear issue in Specs style. Provide the raw text or a Linear issue URL and this skill drafts a
developer-ready ticket with IST/SOLL structure, acceptance criteria, and QA steps.

## MCP server

Installing this plugin also registers Linear's official remote MCP server, giving Claude direct
tool access to your Linear workspace (issues, projects, comments, etc.). After installing, run
`/mcp` and complete the OAuth sign-in to authenticate.
