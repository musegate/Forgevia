---
name: forgevia-propose
description: Use when the user explicitly asks Forgevia to turn a requirement description or a specified file into a new OpenSpec change proposal.
---

# Forgevia Propose

Use this skill when the user explicitly wants Forgevia to produce a new OpenSpec change from a requirement description or a specified file.

## Accepted Input

- A direct user description of the change to build.
- A specified file path whose contents should be treated as the requirement source.
- Both, where the file is primary and the user prompt adds clarification.

## Behavior

- Route the requirement source into `openspec-propose`.
- Allow the change name to come from the user when explicitly provided.
- Otherwise derive an appropriate kebab-case change name from the requirement source.
- Treat the provided file as requirement input, not as implementation output.
- Stop and clarify if the file does not exist or the requirement source is too incomplete to produce a meaningful change.
