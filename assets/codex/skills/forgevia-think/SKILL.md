---
name: forgevia-think
description: Use when the user explicitly asks Forgevia to think through a requirement by routing the request into OpenSpec explore with the user's input.
---

# Forgevia Think

Use this skill when the user explicitly wants Forgevia to think through a requirement before implementation.

## Required Input

- A requirement, idea, feature, flow, or problem statement from the user.

## Behavior

- Create `openspec/think/` if it does not already exist.
- Restate the user's requirement and explain Forgevia's current understanding before moving forward.
- Wait for explicit user confirmation before proposing, implementing, or otherwise treating the requirement as finalized.
- Write the confirmed think output to `openspec/think/` as a Markdown file.
- Name the file as `YYYY-MM-DD-<requirement-description>.md`.
- If the same requirement already has a file for that date and description, keep the original and write the next iteration as `YYYY-MM-DD-<requirement-description>-v2.md`, then `-v3.md`, and so on.
- Use the requirement text, any attached `.mmd` flow, and Forgevia's clarified understanding as the source material for exploration.
- Use this before proposing or implementing when the user wants discovery first.

## Think Output Template

```markdown
# YYYY-MM-DD <Requirement Title>

## Original Request

[The user's raw requirement, idea, or problem statement]

## Restated Understanding

[Forgevia's restatement of the requirement in clearer terms]

## Scope And Boundaries

- [What is in scope]
- [What is out of scope]

## Risks And Open Questions

- [Risk, assumption, dependency, or unresolved question]

## Next Step Recommendation

[What should happen after the user confirms this understanding]
```
