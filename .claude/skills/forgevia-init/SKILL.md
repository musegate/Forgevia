---
name: forgevia-init
description: Use when the user explicitly asks Forgevia to initialize OpenSpec in the current project or verify whether the current project is ready for the Forgevia workflow.
---

# Forgevia Init

Use this skill when the user explicitly wants Forgevia to initialize the current project.

## Behavior

- Check whether `openspec` is installed and available.
- Check whether the current project already has OpenSpec initialization.
- If missing, invoke Forgevia's project bootstrap flow to run `openspec init`.
- When preparing a repository for the Claude Forgevia path, prefer initializing with `--tools codex,claude` so the project can be used consistently from both Forgevia clients.
- Do not modify project source files beyond OpenSpec's own initialization behavior.
