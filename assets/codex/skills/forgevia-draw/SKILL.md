---
name: forgevia-draw
description: Use when the user explicitly asks Forgevia to generate a Mermaid interaction sequence diagram from a named feature, flow, or interface description.
---

# Forgevia Draw

Use this skill when the user explicitly asks Forgevia to draw an interaction sequence for a feature, flow, or interface.

## Required Input

- A feature, flow, or interface description from the user.

## Behavior

- Route content generation to `mermaid-diagram-specialist`.
- Prefer a complete interaction-module sequence diagram.
- Write a timestamped `.mdd`.
- Render a matching `.svg`.
- Name outputs as `YYYYMMDD-HHMMSS-功能`.
