---
name: executing-commands
description: Rules for executing commands inside the project.
---

# Repository Execution Rules

## Execution Model

All project commands MUST be executed via the Taskfile. Agents MUST NOT call Docker Compose commands directly.

Never run directly on the host (outside `task`):

- php
- npm
- node
- composer
- docker compose
- docker

Always use:

```shell
task <task-name>
```

To list all available tasks, use:

```shell
task --list
```

If a task does not exist:

1. Inspect the [Taskfile](./Taskfile.yml).
2. Prefer creating or extending a task.
3. As a temporary fallback, use `task dc:run -- php <command>` unless another service is explicitly required. This still executes via the Taskfile.

## Container Context

The default execution service is `php`.

All standard development commands run inside the Docker Compose service `php`.

Only use another service if:

- the user explicitly instructs it, or
- the command explicitly references that service.

If a command fails because services are not running, run:

```shell
task up
```

Then retry the original command.

To check if services are running, use:

```shell
task ps
```

## Examples

Run tests:

```shell
task test
```

Install dependencies:

```shell
task composer:install
```

Run npm:

```shell
task dc:run -- php npm install
```
