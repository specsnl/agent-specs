---
name: ci-green-check
description: >
  Use this skill after every code change in a repository to discover and run all CI checks locally before finishing work. Triggers automatically after completing any code edit, bug fix, refactor, or feature implementation in a Laravel/PHP repository. Also triggers when the user says "run the checks", "make sure everything is green", "verify the build", or "are the tests passing?". This skill reads .github/workflows to discover what checks exist, runs everything that can be run locally (tests, linters, static analysis), attempts to auto-fix any failures, and reports checks that require cloud/secrets so the user is aware. Never consider a task done until all locally runnable checks pass.
---
 
# CI Green Check — Laravel/PHP
 
After every code change, discover and run all CI checks found in `.github/` and get them green before finishing.
 
---
 
## Step 1: Discover checks
 
### 1a. Check for a Taskfile first
 
```bash
ls Taskfile.yml Taskfile.yaml taskfile.yml taskfile.yaml 2>/dev/null
```
 
If a Taskfile exists, read it fully and extract:
- **Setup tasks**: anything that installs dependencies, copies `.env`, runs migrations, seeds — common names: `setup`, `install`, `init`, `bootstrap`
- **Check tasks**: anything that runs tests or linters — common names: `test`, `lint`, `analyse`, `check`, `ci`, `pint`, `stan`
- **Utility tasks**: `key`, `migrate`, `seed`, etc. — useful during environment setup
List all discovered tasks with their description. **Prefer Task commands over raw vendor/bin calls** when an equivalent Task exists — they often handle the right flags and order automatically.
 
Check that `task` is installed:
```bash
task --version 2>/dev/null || echo "task not installed"
```
 
If `task` is not installed but a Taskfile is present, fall back to running the underlying commands directly from the Taskfile's task definitions.
 
### 1b. Scan GitHub workflows
 
```bash
find .github/workflows -name "*.yml" -o -name "*.yaml" 2>/dev/null | head -20
```
 
For each workflow file found, read it and extract:
- **Test jobs**: PHPUnit, Pest, feature tests, unit tests
- **Static analysis**: PHPStan, Larastan, Psalm
- **Code style**: Laravel Pint, PHP-CS-Fixer, PHP_CodeSniffer
- **Other linters**: Blade linters, JS/TS checks, ESLint
- **Skippable jobs**: jobs that use secrets, deploy steps, cloud runners (SonarCloud, Codecov uploads, etc.)
Cross-reference workflow steps against Taskfile tasks — if a workflow step runs `task test`, that maps to the Task you already found.
 
Group everything into two lists:
1. ✅ **Runnable locally** — document the exact command to run (Task command preferred, raw command as fallback)
2. ⚠️ **Requires cloud/secrets** — note name and why it's skipped
---
 
## Step 2: Check environment
 
Before running, verify the environment is ready.
 
### 2a. Use Taskfile setup if available
 
If a setup/install/init task was found in Step 1, run it first — it likely handles everything below automatically:
 
```bash
task setup    # or: task install / task init / task bootstrap
```
 
Check if the task succeeded (exit code 0). If it did, skip to Step 2b to verify the result. If no setup task exists or it fails, do the steps below manually.
 
### 2b. Verify environment manually
 
```bash
# Check PHP
php --version
 
# Check Composer dependencies are installed
[ -f vendor/autoload.php ] && echo "vendor: ok" || echo "vendor: MISSING — run composer install"
 
# Check .env exists
[ -f .env ] && echo ".env: ok" || echo ".env: MISSING — copy from .env.example"
 
# Check if running in Laravel Sail or local PHP
[ -f ./vendor/bin/sail ] && echo "Sail available" || echo "Running local PHP"
```
 
If `vendor/` is missing, run `composer install` first.
If `.env` is missing, copy `.env.example` to `.env` and run `php artisan key:generate`.
 
### 2c. Determine runner prefix
 
- **Task**: use `task <name>` when a Taskfile task covers the check
- **Sail**: `./vendor/bin/sail` (use when Docker is running and `APP_SERVICE` is set)
- **Local**: `php`, `./vendor/bin/...` directly
---
 
## Step 3: Run checks in order
 
Run in this priority order — stop and fix before moving to the next group.
 
### 3a. Code style (fastest, fix automatically)
 
```bash
# Laravel Pint (auto-fixes)
./vendor/bin/pint
 
# PHP-CS-Fixer (auto-fixes)
./vendor/bin/php-cs-fixer fix
 
# PHP_CodeSniffer (report only — fix with phpcbf)
./vendor/bin/phpcs
./vendor/bin/phpcbf   # if phpcs fails
```
 
If Pint or php-cs-fixer auto-fixes files: note which files changed, continue.
 
### 3b. Static analysis
 
```bash
# PHPStan / Larastan
./vendor/bin/phpstan analyse
 
# Psalm
./vendor/bin/psalm
```
 
If static analysis fails → go to **Step 4 (Fix loop)**.
 
### 3c. Tests
 
Detect the test runner:
 
```bash
# Pest (preferred if available)
[ -f ./vendor/bin/pest ] && ./vendor/bin/pest || ./vendor/bin/phpunit
```
 
Common useful flags:
```bash
# Run with coverage (only if xdebug/pcov available)
./vendor/bin/pest --coverage
 
# Stop on first failure to focus
./vendor/bin/pest --stop-on-failure
 
# Run only the tests related to recently changed files
./vendor/bin/pest --dirty   # Pest only
```
 
If tests fail → go to **Step 4 (Fix loop)**.
 
### 3d. Other checks (if present)
 
```bash
# JS/TS (if package.json has test/lint scripts)
npm run lint
npm run test
 
# Blade linting (if configured)
./vendor/bin/blade-formatter --check resources/
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
 
---
 
## Common issues and fixes
 
| Error | Likely cause | Fix |
|---|---|---|
| `Class not found` in tests | Missing `composer dump-autoload` | Run `composer dump-autoload` |
| DB errors in tests | Test DB not set up | Check `phpunit.xml` for in-memory SQLite or run migrations |
| PHPStan "not enough types" | Missing `@param`/`@return` or wrong types | Add type hints or docblocks |
| `Call to undefined method` on mock | Wrong mock setup | Review mock expectations |
| Pest `--dirty` finds no tests | Not a git repo or no tracked changes | Fall back to `./vendor/bin/pest` |
| `vendor/bin/sail: not found` | Sail not installed | Use local PHP directly |
| Port conflict with Sail | Another service on port 80/3306 | `./vendor/bin/sail down` first |
 
---
 
## Notes
 
- **Never skip a failing check** — fix it or escalate to the user with a clear explanation of why it can't be fixed automatically.
- **Auto-fixes (Pint, phpcbf) are always safe to run** — they only touch formatting.
- **Prefer `--stop-on-failure`** when running Pest to focus on one issue at a time.
- **SQLite in-memory** is the default test DB for most Specs projects — check `phpunit.xml` or `phpunit.xml.dist`.
- If a test requires a real DB and none is configured, flag it to the user rather than guessing.
