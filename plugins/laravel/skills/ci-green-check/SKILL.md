---
name: ci-green-check
description: >
  Use this skill after every code change in a repository to discover and run all CI checks locally before finishing work. Triggers automatically after completing any code edit, bug fix, refactor, or feature implementation in a Laravel/PHP repository. Also triggers when the user says "run the checks", "make sure everything is green", "verify the build", or "are the tests passing?". This skill reads .github/workflows to discover what checks exist, runs everything that can be run locally (tests, linters, static analysis), attempts to auto-fix any failures, and reports checks that require cloud/secrets so the user is aware. Never consider a task done until all locally runnable checks pass.
---
 
# CI Green Check — Laravel/PHP

> **Prerequisite — Command execution rules apply.**
> The `executing-commands` skill governs how every command in this skill must be run.
> Never run `php`, `composer`, `npm`, `node`, `docker`, or `docker compose` directly on the host.
> Always use `task <task-name>`. If no task exists, use `task dc:run -- php <command>` as a fallback.
> When `task --list` shows a task with `*` (e.g. `task composer:run:*` or `task artisan:run:*`), the `*` is a placeholder — replace it with the composer script or artisan command name. Extra arguments go after `--` (e.g. `task composer:run:audit -- --strict`).
> Run `task --list` to discover available tasks before reaching for a raw command.
 
After every code change, discover and run all CI checks found in `.github/` and get them green before finishing.
 
---
 
## Step 1: Discover checks
 
### 1a. Check for a Taskfile first
 
```bash
ls Taskfile.yml Taskfile.yaml taskfile.yml taskfile.yaml 2>/dev/null
```
 
If a Taskfile exists, read it fully and extract:
- **Setup tasks**: anything that installs dependencies, copies `.env`, runs migrations, seeds — common names: `setup`, `install`, `init`, `bootstrap`
- **Check tasks**: anything that runs tests or linters — common names: `test`, `lint`, `analyse`, `check`, `ci`, `pint`, `stan`; also look for the `composer:run:*` task family (e.g. `composer:run:checkall`, `composer:run:checktype`, `composer:run:test`) — these are the preferred way to run individual tools
- **Utility tasks**: `key`, `migrate`, `seed`, etc. — useful during environment setup
List all discovered tasks with their description. **Prefer Task commands over raw vendor/bin calls** when an equivalent Task exists — they often handle the right flags and order automatically.
 
Check that `task` is installed:
```bash
task --version 2>/dev/null || echo "task not installed"
```
 
If `task` is not installed, do not attempt to run commands directly. Stop and alert the user — `task` is required. Ask the user to install it first (`brew install go-task/tap/go-task` on macOS).
 
### 1b. Scan GitHub workflows
 
```bash
find .github/workflows -name "*.yml" -o -name "*.yaml" 2>/dev/null | head -20
```
 
For each workflow file found, read it and extract:
- **Test jobs**: PHPUnit, Pest, feature tests, unit tests
- **Static analysis**: PHPStan, Larastan
- **Code style**: Laravel Pint, PHP-CS-Fixer, PHP_CodeSniffer
- **Other linters**: JS/TS checks, ESLint
- **Skippable jobs**: jobs that use secrets, deploy steps, cloud runners (SonarCloud, Codecov uploads, etc.)
Cross-reference workflow steps against Taskfile tasks — if a workflow step runs `task test`, that maps to the Task you already found.
 
Group everything into two lists:
1. ✅ **Runnable locally** — document the exact command to run (Task command preferred, raw command as fallback)
2. ⚠️ **Requires cloud/secrets** — note name and why it's skipped
---
 
## Step 2: Check environment
 
Before running, verify the environment is ready.
 
### 2a. Use Taskfile setup if available
 
Run `task up` first to ensure services are running:
 
```bash
task up
```
 
If a setup/install/init task was found in Step 1, run it after — it likely handles dependency installation, `.env` setup, and migrations:
 
```bash
task setup    # or: task install / task init / task bootstrap
```
 
Check if the task succeeded (exit code 0). If it did, skip to Step 2b to verify the result. If no setup task exists or it fails, do the steps below manually.
 
### 2b. Verify environment manually
 
```bash
# Discover available tasks
task --list

# Check Composer dependencies are installed (file check only — no host commands)
[ -f vendor/autoload.php ] && echo "vendor: ok" || echo "vendor: MISSING — run a setup task"
 
# Check .env exists (file check only)
[ -f .env ] && echo ".env: ok" || echo ".env: MISSING — copy from .env.example"
```
 
If `vendor/` is missing, look for a setup task (`task setup`, `task composer:install`) and run it. If no such task exists, use the fallback: `task dc:run -- php composer install`.

If `.env` is missing, copy `.env.example` to `.env` manually (file copy, not a host command), then generate the application key: `task artisan:run:key:generate` or fallback `task dc:run -- php artisan key:generate`.
 
---
 
## Step 3: Run checks in order

### Runner prefix

Commands must always be run through the Taskfile. Use this strict order:

1. **Task (preferred):** `task <name>` — check `task --list` first
2. **Composer/artisan scripts:** `task composer:run:<script>` or `task artisan:run:<command>` — when `task --list` shows `task composer:run:*` or `task artisan:run:*`, the `*` is the script/command name to use
3. **Raw fallback:** `task dc:run -- php ./vendor/bin/<tool> [args]` — use only when no task exists

Never use `./vendor/bin/...`, `php`, `composer`, or `npm` directly on the host.

### Order of execution
 
Run in this priority order — stop and fix before moving to the next group.

If `task composer:run:checkall` was found in Step 1, run it now — it covers all composer tools in one go. Skip Steps 3a and 3b.
 
### 3a. Code style (fastest, fix automatically)
 
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
 
### 3b. Static analysis
 
```bash
# PHPStan / Larastan — preferred via task:
task composer:run:checktype

# PHPStan / Larastan — fallback:
task dc:run -- php ./vendor/bin/phpstan analyse
```
 
If static analysis fails → go to **Step 4 (Fix loop)**.
 
### 3c. Tests
 
```bash
# Run tests — preferred via task:
task composer:run:test
```

If no task exists, check which test runner is available: if `vendor/bin/pest` exists, use the Pest fallback; otherwise use the PHPUnit fallback.

```bash
# Pest fallback:
task dc:run -- php ./vendor/bin/pest

# PHPUnit fallback:
task dc:run -- php ./vendor/bin/phpunit
```
 
If tests fail → go to **Step 4 (Fix loop)**.
 
### 3d. Other checks (if present)
 
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
 
## Step 4: Fix loop
 
When a check fails:
 
1. **Read the error output carefully** — identify the exact file, line, and type of failure.
2. **Classify the failure**:
   - Type error / wrong return type → fix the code
   - Missing import / undefined class → add `use` statement or fix namespace
   - Test assertion failed → fix the code logic (not the test, unless the test is clearly wrong)
   - Undefined variable / null safety → fix the code
   - Style issue that wasn't auto-fixed → fix manually
3. **Apply the fix** — edit the relevant file(s).
4. **Re-run only the failing check** to verify the fix.
5. **If the fix causes a new failure** elsewhere, fix that too.
6. Repeat until the check is green, then continue to the next check.
**Never "fix" a test by weakening its assertions** unless the test was testing the wrong thing and you can explain why.
 
---
 
## Step 5: Report skipped checks
 
After all local checks pass, report checks that were skipped:
 
```
⚠️  The following CI checks cannot be run locally and will be verified in CI:
- [job name]: requires secret `SONAR_TOKEN` (SonarCloud scan)
- [job name]: deploys to production (deploy step)
- [job name]: uploads coverage to Codecov
```
 
---
 
## Step 6: Done
 
When all locally runnable checks are green, confirm:
 
```
✅ All local checks passed:
- Pint: clean (N files reformatted)
- PHPStan: no errors
- Pest: N tests, N assertions — all green
 
⚠️ N cloud-only checks skipped (see above).
 
Ready to commit / push.
```
