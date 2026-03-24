# Forgevia For Codex

Forgevia bootstraps an opinionated Codex workflow around:

- OpenSpec
- superpowers
- requesting-code-review
- playwright-interactive

This repository is GitHub-first. The initial Codex path assumes:

- `openspec` is installed or can be installed globally with npm
- `superpowers` is installed from its upstream Codex install guide
- Forgevia ships and manages its own curated copies of the workflow files it wants to own
- `~/.codex` is the primary managed global target

Claude now has a separate install path documented in `INSTALL.claude.md`. That path installs the Forgevia Claude skill set, supporting OpenSpec skills and commands, plus selected Forgevia-managed overrides for installed Claude superpowers skills and OpenSpec overrides.

## Current Scope

This document defines the intended Codex installation flow for Forgevia.

The current first-pass source assumptions are:

- `openspec` comes from the upstream npm package
- `superpowers` comes from the upstream Codex install instructions
- `requesting-code-review` is treated as part of the installed superpowers skill set
- `playwright-interactive` currently comes from the maintainer's local `~/.codex/skills/playwright-interactive`

## Target State

After Forgevia is fully implemented for Codex, the installation flow should leave the machine in a state where:

- `openspec` is available on `PATH`
- required Codex workflow files exist under `~/.codex`
- Forgevia-managed skill files are installed from this repository's owned copies
- project bootstrap can initialize OpenSpec when missing

## Planned Install Flow

### 1. Preflight

Forgevia should verify:

- `node` and `npm` are available
- Codex is installed and using `~/.codex`
- whether `openspec` is already installed
- whether `superpowers` assets are already present
- whether Forgevia-managed assets already exist

### 2. Install OpenSpec

If `openspec` is missing, install it with:

```bash
npm install -g @fission-ai/openspec@latest
```

If it already exists, Forgevia should not reinstall blindly. It should detect the existing installation first and then decide whether to keep it or warn about drift.

### 3. Install Superpowers

If `superpowers` is missing for Codex, install it from the upstream guide:

The intended Codex instruction is:

> Fetch and follow instructions from https://raw.githubusercontent.com/obra/superpowers/refs/heads/main/.codex/INSTALL.md

Forgevia should detect whether this step has already been completed before asking the user to repeat it.

### 4. Install Forgevia-Managed Assets

Forgevia should install its owned Codex assets into `~/.codex`.

These assets will eventually include:

- `~/.codex/skills/forgevia`
- `~/.codex/skills/playwright-interactive`
- Forgevia-managed overrides for these superpowers skills:
  - `brainstorming`
  - `writing-plans`
  - `subagent-driven-development`
  - `requesting-code-review`
  - `executing-plans`

For the current first phase, the source of truth for the shipped Codex assets is now being imported into this repository from the maintainer's local `~/.codex` setup.

### 5. Verify Managed State

Forgevia should provide a doctor or verification step that reports:

- missing required tools
- missing managed files
- locally modified managed files
- unmanaged files in locations Forgevia expects to control

The current repository includes a minimal doctor entrypoint:

```bash
./scripts/doctor-codex.sh
```

### 6. Bootstrap A Project

For a target repository, Forgevia should later provide a project bootstrap flow that:

- checks whether OpenSpec is already initialized
- initializes OpenSpec for Codex when missing
- does not take ownership of project business files

The current repository now includes a minimal project bootstrap entrypoint:

```bash
./scripts/bootstrap-project.sh --tools codex /path/to/project
```

## Open Questions Before Automation

- Which exact files under `~/.codex` should Forgevia claim as managed in v1?
- Should Forgevia require upstream `superpowers` installation first forever, or eventually vendor and fully own those files too?
- Which local markers are sufficient to detect a valid superpowers install?
- How should Forgevia distinguish healthy managed files from user-customized ones in `~/.codex`?

## Working Assumptions

Until the installer scripts exist, Forgevia is being designed under these Codex assumptions:

- `openspec` is installed by npm
- `superpowers` is installed from upstream
- Forgevia explicitly ships overrides for five customized superpowers skills:
  - `brainstorming`
  - `writing-plans`
  - `subagent-driven-development`
  - `requesting-code-review`
  - `executing-plans`
- `requesting-code-review` is still operationally part of the superpowers install surface
- `playwright-interactive` is sourced from the maintainer's current `~/.codex` setup and is being vendored into this repo as a Forgevia-managed skill
- Forgevia itself is an explicit entry skill, not an auto-triggered replacement for all underlying skills
- Forgevia does not manage project source files; it only checks for and invokes OpenSpec initialization
