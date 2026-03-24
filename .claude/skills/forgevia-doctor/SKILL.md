---
name: forgevia-doctor
description: Use when the user explicitly asks Forgevia to inspect the Claude environment for missing or drifted Forgevia-managed assets.
---

# Forgevia Doctor

Use this skill when the user explicitly wants a health check for the Forgevia-managed Claude environment.

## Behavior

- Run the Forgevia doctor flow.
- Report `OK`, `MISS`, and `DRIFT` states clearly.
- Do not modify files in this mode.
