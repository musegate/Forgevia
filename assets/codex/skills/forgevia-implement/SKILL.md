---
name: forgevia-implement
description: Use when the user explicitly asks Forgevia to implement one named, active OpenSpec change using the Forgevia-modified superpowers workflow.
---

# Forgevia Implement

Use this skill only when the user explicitly names a change to implement.

## Required Input

- An explicit active change name or change directory.

## Behavior

- Verify the change exists under `openspec/changes/`.
- Verify the change is not archived.
- Verify the change has `tasks.md`.
- Route implementation through the Forgevia-modified superpowers path.
- Require TDD-oriented execution.
- Use review checkpoints at dependency-ready task groups.
- Require `playwright-interactive` before completion when the work affects web behavior.

Do not guess the change from conversation context.
