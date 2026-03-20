---
name: forgevia
description: Use when the user explicitly asks to use Forgevia to run the full OpenSpec plus superpowers plus review plus Playwright workflow instead of invoking the underlying skills manually.
---

# Forgevia

Forgevia is an explicit orchestration skill. It does not replace OpenSpec, superpowers, requesting-code-review, or playwright-interactive. It coordinates them.

## When To Use

Use Forgevia only when the user explicitly asks for it, such as:

- `use Forgevia`
- `run this through Forgevia`
- `use the Forgevia workflow`

Do not auto-trigger Forgevia just because a coding request exists.

## Preconditions

Before using Forgevia, verify:

- `openspec` is installed and available
- required `superpowers` skills are installed
- Forgevia-managed overrides are present under `~/.codex`
- `playwright-interactive` is available when the work touches web behavior

If required pieces are missing, stop and tell the user which installation or doctor step is needed.

## Workflow

Forgevia should behave like an explicit command router. The user is expected to name the Forgevia action they want.

## Commands

### `Forgevia init`

Purpose:
- check the global Forgevia environment
- check whether the target repository already has OpenSpec initialization
- invoke `openspec init` only when initialization is missing

Behavior:
- route to Forgevia's environment checks and bootstrap flow
- do not take ownership of project source files

### `Forgevia doctor`

Purpose:
- inspect the current Codex environment for missing or drifted Forgevia-managed assets

Behavior:
- use the Forgevia doctor flow
- report `OK`, `MISS`, or `DRIFT`

### `Forgevia repair`

Purpose:
- repair missing or drifted Forgevia-managed assets

Behavior:
- use the Forgevia repair flow
- preserve backups before replacement

### `Forgevia implement <change>`

This command MUST include an explicit active change name or directory.

Purpose:
- execute development for a specific unarchived OpenSpec change

Required checks:
- the change exists under `openspec/changes/`
- the change is not already archived
- the change has a `tasks.md`

Behavior:
- treat the named change as the source of truth
- use superpowers to complete the development for the named change
- require a TDD-oriented implementation path
- prefer `subagent-driven-development` or `executing-plans` based on the task structure
- use `requesting-code-review` at dependency-ready checkpoints

Do not guess the change from conversation context when this command is used.

### `Forgevia archive <change>`

This command MUST include an explicit change name or directory.

Purpose:
- archive a specific unarchived OpenSpec change

Behavior:
- verify the named change exists and is not already archived
- route to the archive flow
- do not auto-select a change

### `Forgevia tasks`

Purpose:
- list unfinished tasks across all active, unarchived changes

Behavior:
- list active changes by creation time ascending
- show only unfinished checklist items
- use this as the default read-only task overview command

### `Forgevia think`

Purpose:
- think through a requirement before implementation

Behavior:
- route to `openspec-explore`
- use the user's requirement input as the exploration prompt

### `Forgevia propose`

Purpose:
- turn a requirement description or specified file into a new OpenSpec change

Behavior:
- route to `openspec-propose`
- accept either direct user description or a specified file as requirement input
- use an explicit user-provided change name when available
- otherwise derive a kebab-case change name from the requirement source

### `Forgevia review`

Purpose:
- force an explicit code review checkpoint

Behavior:
- route to `requesting-code-review`

### `Forgevia verify-web`

Purpose:
- force explicit browser validation for a web-facing change

Behavior:
- route to `playwright-interactive`

### `Forgevia draw`

Purpose:
- use Mermaid Diagram Specialist together with user-provided 功能/链路/接口信息 to generate a complete interaction-module sequence diagram

Behavior:
- route to `mermaid-diagram-specialist`
- prefer a Mermaid sequence diagram for the interaction module
- pass the Mermaid output to `forgevia-draw.sh`
- write a timestamped `.mmd`
- render a matching `.svg`, preferring a local Chrome/Chromium executable for `mmdc` when available
- name outputs as `YYYYMMDD-HHMMSS-功能`

### 2. Use the Forgevia-modified superpowers path

When implementation planning or execution is needed, prefer the Forgevia-managed variants of:

- `brainstorming`
- `writing-plans`
- `subagent-driven-development`
- `requesting-code-review`
- `executing-plans`

These variants are expected to be OpenSpec-oriented and to use `openspec/changes/<change-name>/...` paths.

### 3. Trigger review checkpoints

Use `requesting-code-review` at the intended checkpoints:

- after each dependency-ready task group in execution flows
- before merge or handoff

Do not silently skip review because a change looks small.

### 4. Trigger Playwright only when relevant

If the change affects web behavior, UI, interaction flow, or visual output, require `playwright-interactive` before final completion claims.

If the change is backend-only or otherwise has no browser-facing impact, skip Playwright explicitly.

### 5. Close the loop

When implementation is complete:

- ensure review checkpoints are satisfied
- ensure verification has run
- hand off to archive flow when the user wants to close the change

### 6. Respect project ownership boundaries

Forgevia may help detect whether a repository has been initialized with OpenSpec and may invoke `openspec init` when the user wants that help.

Forgevia does not take ownership of project source files or silently overlay project-local workflow files.

## Boundaries

- Forgevia orchestrates; it does not manually duplicate every underlying skill body.
- Forgevia should keep the user on one coherent workflow, not invent side workflows.
- If a lower-level skill is clearly the right direct tool for the current step, Forgevia should say so and use it.
- Forgevia manages global workflow environment and invocation patterns, not user project code.
