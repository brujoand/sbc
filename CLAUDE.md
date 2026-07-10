# sbc

Simple Bash Cogs — a loader for reusable bash helpers ("cogs"). Declares repos
(local paths or git URLs), materializes them under `~/.config/sbc/repos`, and
sources the files you name.

## Hard rules

- **Never push to `main`/`master`.** Feature branch + PR, always. Open the PR,
  report the URL, stop — **only the human merges.**
- **Conventional Commits** (`feat:`, `fix:`, `chore:`, …). Never hand-bump a version.
- **`pre-commit` is the gate.** Run `pre-commit run --files <changed>` before
  declaring a change done, and report the result.
- **`mise` provisions the toolchain** (`mise install`). New worktrees need `mise trust`.
- Plan every non-trivial task. If the plan fails, restart planning.

## Workflow

Default branch is `master`. CI installs shellcheck and bats, then runs
`pre-commit run --all-files`, `bin/run_tests`, and `scripts/test_docker.sh`.

## Architecture

`sbc.bash` is the entrypoint. Under `src/`:

- `main.bash` — dispatch
- `repo.bash` — resolve and materialize cog repos into `~/.config/sbc/repos`
- `cog.bash` — load individual cogs
- `configure.bash`, `interact.bash` — settings and the `sbc` subcommands
- `cogs/` — the bundled helpers (`library.sh`, `log.sh`, `utils.sh`, `sbc.bash`)

Beyond loading, sbc provides helpers to list every file the current shell would
source, find where a function or alias was defined, and give aliases
auto-completion.

Tests in `test/` mirror the source: `cog.bats`, `repo.bats`, `sbc_cog.bats`,
`stdlib.bats`.

## Commands

```bash
mise install
bin/run_tests                    # = bats test/
bats test/cog.bats               # single file
bats -f "<pattern>" test/        # single case
scripts/test_docker.sh           # install test in a container
pre-commit run --files <changed files>
```

## Gotchas

- **`bats` must be on PATH** or `bin/run_tests` cannot run (`apt-get install
  bats`, as CI does). A local `bats-tests` pre-commit hook runs the full suite on
  every commit, so a missing `bats` blocks committing.
- `bin/install` writes `SBC_PATH` and a source line into `~/.bashrc`.
- shellcheck runs with `-e SC1091 -e SC2034`; shfmt with `-w -s -i 2`.
- Personal, untracked notes belong in `CLAUDE.local.md`, which is gitignored.
