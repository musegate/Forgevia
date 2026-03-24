---
name: forgevia-repair
description: Use when the user explicitly asks Forgevia to repair missing or drifted Forgevia-managed assets in the Claude environment.
---

# Forgevia Repair

Use this skill when the user explicitly wants Forgevia to repair the managed Claude environment.

## Behavior

- Run the Forgevia doctor flow with repair enabled.
- Repair `MISS` and `DRIFT` states from Forgevia-owned copies.
- Preserve backups before replacement.
