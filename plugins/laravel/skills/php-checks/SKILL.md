---
name: php-checks
description: >
  Use this skill to prepare the environment and run the PHP/Laravel quality tools of a Specs project
  locally — Pint, PHP-CS-Fixer, PHP_CodeSniffer, PHPStan/Larastan, Pest/PHPUnit and the `npm:run:*`
  tasks — all through the Taskfile. It is the PHP/Laravel layer of the `ci-green-check` skill, which
  invokes it whenever a repository has a `composer.json`; that skill owns check discovery, the fix
  loop, and the final report. Also triggers directly when the user says "run pint", "run phpstan",
  "run the tests" or "run the composer checks" in a Laravel/PHP repository.
---

# PHP / Laravel checks

> **Prerequisite — Command execution rules apply.**
> The `executing-commands` skill governs how every command in this skill must be run.
> Never run `php`, `composer`, `npm`, `node`, `docker`, or `docker compose` directly on the host.
> Always use `task <task-name>`. If no task exists, use `task dc:run -- php <command>` as a fallback.
> When `task --list` shows a task with `*` (e.g. `task composer:run:*` or `task artisan:run:*`), the
> `*` is a placeholder — replace it with the composer script or artisan command name. Extra
> arguments go after `--` (e.g. `task composer:run:audit -- --strict`).
> Run `task --list` to discover available tasks before reaching for a raw command.

This skill is the stack-specific half of `ci-green-check`. That skill discovers which checks exist
(Taskfile + `.github/workflows`), drives the fix loop and writes the final report. This one provides
the environment setup and the exact commands.

Check that `task` is installed:

```bash
task --version 2>/dev/null || echo "task not installed"
```

If `task` is not installed, do not attempt to run commands directly. Stop and alert the user — `task`
is required. Ask the user to install it first (`brew install go-task/tap/go-task` on macOS).

Relevant task families to look for in `task --list`: `composer:run:*` (e.g. `composer:run:checkall`,
`composer:run:checktype`, `composer:run:test`), `artisan:run:*`, `npm:run:*`, and the plain
`test` / `lint` / `analyse` / `pint` / `stan` tasks.

---

## Step 1: Prepare the environment

### 1a. Use Taskfile setup if available

Run `task up` first to ensure services are running:

```bash
task up
```

If a setup/install/init task exists, run it after — it likely handles dependency installation, `.env`
setup, and migrations:

```bash
task setup    # or: task install / task init / task bootstrap
```

Check if the task succeeded (exit code 0). If it did, skip to Step 1b to verify the result. If no
setup task exists or it fails, do the steps below manually.

### 1b. Verify the environment manually

```bash
# Discover available tasks
task --list

# Check Composer dependencies are installed (file check only — no host commands)
[ -f vendor/autoload.php ] && echo "vendor: ok" || echo "vendor: MISSING — run a setup task"

# Check .env exists (file check only)
[ -f .env ] && echo ".env: ok" || echo ".env: MISSING — copy from .env.example"
```

If `vendor/` is missing, look for a setup task (`task setup`, `task composer:install`) and run it. If
no such task exists, use the fallback: `task dc:run -- php composer install`.

If `.env` is missing, copy `.env.example` to `.env` manually (file copy, not a host command), then
generate the application key: `task artisan:run:key:generate` or fallback
`task dc:run -- php artisan key:generate`.

---

## Step 2: Run the checks in order

### Runner prefix

Commands must always be run through the Taskfile. Use this strict order:

1. **Task (preferred):** `task <name>` — check `task --list` first
2. **Composer/artisan scripts:** `task composer:run:<script>` or `task artisan:run:<command>` — when
   `task --list` shows `task composer:run:*` or `task artisan:run:*`, the `*` is the script/command
   name to use
3. **Raw fallback:** `task dc:run -- php ./vendor/bin/<tool> [args]` — use only when no task exists

Never use `./vendor/bin/...`, `php`, `composer`, or `npm` directly on the host.

### Order of execution

Run in this priority order — stop and fix before moving to the next group. A failure goes to the fix
loop in `ci-green-check`.

If `task composer:run:checkall` exists, run it now — it covers all composer tools in one go. Skip
Steps 2a and 2b.

### 2a. Code style (fastest, fix automatically)

Always check `task --list` for available tasks first.

```bash
# Laravel Pint — preferred via task:
task composer:run:pint

# Laravel Pint — fallback:
task dc:run -- php ./vendor/bin/pint

# PHP-CS-Fixer — preferred via task:
task composer:run:fixstyle

# PHP-CS-Fixer — fallback:
task dc:run -- php ./vendor/bin/php-cs-fixer fix

# PHP_CodeSniffer — preferred via task:
task composer:run:checkstyle

# PHP_CodeSniffer — fallback:
task dc:run -- php ./vendor/bin/phpcs
task dc:run -- php ./vendor/bin/phpcbf   # if phpcs fails
```

If Pint or php-cs-fixer auto-fixes files: note which files changed, continue.

### 2b. Static analysis

```bash
# PHPStan / Larastan — preferred via task:
task composer:run:checktype

# PHPStan / Larastan — fallback:
task dc:run -- php ./vendor/bin/phpstan analyse
```

### 2c. Tests

```bash
# Run tests — preferred via task:
task composer:run:test
```

If no task exists, check which test runner is available: if `vendor/bin/pest` exists, use the Pest
fallback; otherwise use the PHPUnit fallback.

```bash
# Pest fallback:
task dc:run -- php ./vendor/bin/pest

# PHPUnit fallback:
task dc:run -- php ./vendor/bin/phpunit
```

### 2d. Other checks (if present)

```bash
# JS/TS lint — preferred via task:
task npm:run:lint

# JS/TS lint — fallback:
task dc:run -- php npm run lint

# JS/TS test — preferred via task:
task npm:run:test

# JS/TS test — fallback:
task dc:run -- php npm run test
```

---

## Step 3: Hand back

Report per tool what ran and what its result was, so `ci-green-check` can drive the fix loop and
produce the final ✅ / ⚠️ report. Do not declare the work done from here — that is `ci-green-check`'s
Step 6.
