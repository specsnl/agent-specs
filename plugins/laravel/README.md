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

## Commands

**update-project**:  
Update dependencies of Specs projects based on Laravel using isolated commits.

Claude: `/update-project`  
Copilot: `/laravel:update-project`
