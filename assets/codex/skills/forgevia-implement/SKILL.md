---
name: forgevia-implement
description: Use when the user explicitly asks Forgevia to implement one named, active OpenSpec change using superpowers with a TDD workflow.
---

# Forgevia Implement

Use this skill only when the user explicitly names a change to implement.

## Required Input

- An explicit active change name or change directory.

## Behavior

- Verify the change exists under `openspec/changes/`.
- Verify the change is not archived.
- Verify the change has `tasks.md`.
- Use superpowers to complete the development for the named change.
- Require an explicit `superpowers:test-driven-development` execution path throughout the implementation.
- Do not treat TDD as implicit or optional when implementing the change.
- Use review checkpoints at dependency-ready task groups.

Do not guess the change from conversation context.
