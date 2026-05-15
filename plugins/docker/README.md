# Docker plugin

All Specs Docker related skills, instructions, commands/prompts are located in this plugin.

## Installation

Claude: `claude plugin install docker@specs`  
Copilot: `copilot plugin install docker@specs`  

## Skills

**php-images**:  
General knowledge about Specsnl PHP Docker images: what they are, their repository structure and variants,
which PHP versions are maintained, and how to locate sibling images on GitHub and locally.

## Commands

**update-php-images**:  
Update Specsnl PHP images (the Dockerfile dependencies and tooling) in isolated commits

Claude: `/update-php-images`  
Copilot: `/docker:update-php-images`

**sync-sibling-php-repos**:  
Synchronize sibling PHP repositories by propagating relevant commits from the current repository.

Claude: `/sync-sibling-php-repos`  
Copilot: `/docker:sync-sibling-php-repos`
