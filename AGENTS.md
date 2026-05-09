@CONTRIBUTING.md

# Agent Guide

This file is for AI coding agents (Claude Code, Codex CLI, Gemini CLI, etc.).
See [CONTRIBUTING.md](CONTRIBUTING.md) for the human contributor guide and the
canonical style references under [`docs/`](docs/).

## If you're helping a mise user: reproduce with `aqua` first

aqua-registry is consumed by mise as a backend, but it is an aqua project.
Bug reports that only reproduce through mise (or asdf) get closed and
redirected to the mise community.

Before opening an issue or PR for a bug, install `aqua`, write a minimal
`aqua.yaml`, and reproduce the failure with `aqua` directly. In the report,
include:

- `aqua` version
- OS and CPU architecture
- the `aqua.yaml`
- the exact command and its output (expected vs. actual)

Background: [aquaproj/aqua-registry#30430](https://github.com/aquaproj/aqua-registry/issues/30430).

## Before you open a PR: rejection screens

The most common reasons the maintainer closes PRs without merging. Check
each before starting work.

- **Duplicates.** Search open and recently-closed PRs for the package name
  before opening one:

  ```sh
  gh pr list --repo aquaproj/aqua-registry --search "<package>" --state all
  ```

- **Doesn't install as a single binary on `$PATH`.** aqua installs commands
  into `AQUA_ROOT_DIR/bin`. Out of scope: tools that expect a different
  install location (e.g., Helm plugins, Vim/Neovim plugins, Gauge plugins),
  `libexec/` layouts, env-var-based install roots, and anything installed
  via `pip` / `npm` / `gem`. **In scope:** standalone binaries that act as
  plugins for another tool by naming convention — e.g., `kubectl-foo`
  binaries are supported because kubectl just looks for `kubectl-*` on
  `$PATH`. See [docs/support_policy.md](docs/support_policy.md).
- **Upstream repo doesn't resolve.** `github.com/<owner>/<repo>` must be a
  real GitHub repo whose tags match release versions. The maintainer will
  not repoint an existing package to a fork — submit the fork as a new
  package instead.
- **Unsigned commits.** Auto-flagged by CI and won't merge. Set up commit
  signing before pushing. See [docs/manner.md](docs/manner.md).
- **Manual `pkg.yaml` version bumps.** `pkg.yaml` is test data, not a
  version source. The Renovate bot owns version updates; manual bumps get
  reverted or closed.

## Before you start

### 1. Clone the upstream `aqua` repository for offline spec reference

```sh
mkdir -p .ai
if [ ! -d .ai/aqua ]; then
  git clone https://github.com/aquaproj/aqua .ai/aqua
fi
git -C .ai/aqua pull origin main
```

Key paths:

- `.ai/aqua/website/docs/reference/registry-config/*.md` — every field in `registry.yaml`.
- `.ai/aqua/json-schema/registry.json` — JSON Schema for `registry.yaml`.

When the project docs link to `https://aquaproj.github.io/docs/<path>`, the
source markdown is at `.ai/aqua/website/docs/<path>`.

### 2. Use `argd s` to scaffold packages — do not hand-write `registry.yaml`

For `github_release` and `cargo` packages, run:

```sh
argd s "<owner>/<repo>"      # e.g. argd s cli/cli
```

For other types, `argd s -l 1 "<package>"` generates a stub. The maintainer
rejects PRs that hand-write configuration the scaffolder could have generated,
because manual code reliably misses old versions and uncommon platforms. See
[docs/add_package.md](docs/add_package.md) for details and edge cases.

### 3. Verify with `argd t` before opening the PR

Run `argd t <package>` and paste the command + a snippet of the output into the
PR description. "I tested it" without evidence delays review.

## Common corrections to avoid

These come up repeatedly on PR review. Check each before submitting.

### `registry.yaml`

- **End the file with a single trailing newline.**
- **Don't quote strings unless YAML requires it.** `description: foo`, not
  `description: "foo"`. Same for `src`, `asset`, etc.
- **`description` is one short sentence.** No leading/trailing whitespace, no
  trailing `.` or `!`, no emojis. Aim for ~80 characters.
- **`format: raw` ⇒ omit `files[].src`.** The `files` block is unnecessary
  when there's no archive to extract.
- **`supported_envs`: list arch-qualified entries when arch coverage is
  partial.** Bare `linux` implies both `linux/amd64` and `linux/arm64`. If
  only one arch is supported, write it out: `[darwin, linux/amd64, windows]`.
- **Use `amd64`/`arm64`, not `x64`/`aarch64`.** CI will fail otherwise.
- **`version_prefix` must match the actual tag prefix.** If releases are
  tagged `lychee-v0.15.0`, use `version_prefix: lychee-v`, not `lychee-`.
- **`version_filter` is not for dropping support for old versions.** Use
  `version_constraint` + `no_asset` / `error_message` for that. `version_filter`
  only excludes versions from `argd s` scaffolding.
- **Drop empty `replacements:` blocks.** If you're not transforming the
  template, the field shouldn't be there.
- **Prefer `{{.Asset}}.sha256` over repeating the full asset template** when
  the checksum URL is just the asset URL with a suffix.
- **`aliases` is for renames only.** Use `search_words` for discoverability —
  don't put marketing terms or alternate spellings in `aliases`.
- **Pick `type:` per the precedence in
  [docs/registry_yaml.md](docs/registry_yaml.md).** Prefer `github_release` >
  `http` > `go_build` — only fall back when the simpler type can't work.
- **Don't add a `checksum:` block when the checksum file is just a bare
  hash** (`file_format: raw`); the defaults handle it.

### `pkg.yaml`

- **Pin one test version per `version_overrides` branch.** If you add an
  override for versions <1.5, also add a `pkg.yaml` entry pinned in that
  range so CI exercises the override.
- **Don't drop existing test versions** without explaining why in the PR
  body. Deleted versions weaken regression coverage.

### PR description

- Show the verification command and its output.
- Disclose AI usage per [docs/ai.md](docs/ai.md): add the agent as a commit
  co-author or note it in the PR body. Don't respond to maintainer questions
  with "I don't know, the AI wrote it" — review and own the output.

## Project skills

The `.agents/skills/` and `.claude/skills/` directories contain reusable
workflows (e.g., `fetch-doc` to pull aqua spec docs, `review-change` to lint
proposed package changes). Prefer invoking them over re-deriving the procedure.
