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

### 1. Select the OpenSpec entrypoint

Choose the correct OpenSpec entry:

- idea exploration -> `openspec-explore`
- new work with enough clarity -> `openspec-propose`
- existing change implementation -> apply flow plus plan execution
- finished change -> archive flow

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

## Boundaries

- Forgevia orchestrates; it does not manually duplicate every underlying skill body.
- Forgevia should keep the user on one coherent workflow, not invent side workflows.
- If a lower-level skill is clearly the right direct tool for the current step, Forgevia should say so and use it.
