---
name: forgevia-think
description: Use when the user explicitly asks Forgevia to think through a requirement before proposal or implementation, especially when the request is still vague, evolving, or backed by diagrams or requirement documents.
license: MIT
compatibility: Works best in repositories that use Forgevia-style change artifacts under openspec/.
metadata:
  author: forgevia
  version: "1.0"
---

Use this skill when the user explicitly wants Forgevia to think through a requirement before proposal or implementation.

**IMPORTANT: Think is for clarification, not implementation.** You may read files, inspect the repository, and write think artifacts, but you must NOT implement product code as part of this step.

## Accepted Input

- A vague idea, problem statement, feature, flow, or interface description
- A more detailed written request
- A `.mmd` diagram generated from Forgevia draw
- A full requirement document

More detailed input usually produces a more precise think result.

## Behavior

1. **Treat the user's input as raw source material**
   - Use the requirement text, attached notes, `.mmd` design flow, and supporting documents when available.

2. **Create the think artifact directory when missing**
   - Ensure `openspec/think/` exists before writing any artifact.

3. **Restate the requirement first**
   - Rewrite the user's request in clearer terms.
   - Explain your current understanding.
   - Surface scope boundaries, assumptions, risks, and open questions.

4. **Wait for explicit confirmation**
   - Do not move into proposal or implementation until the user confirms that the restated understanding is correct enough.

5. **Write the confirmed think artifact**
   - Save the confirmed result as Markdown under `openspec/think/`.
   - Use the file name format `YYYY-MM-DD-<requirement-description>.md`.
   - If the same dated requirement already exists, create the next version as `YYYY-MM-DD-<requirement-description>-v2.md`, then `-v3.md`, and so on.
   - Do not overwrite an earlier iteration of the same requirement.

6. **Recommend the next step**
   - If the user wants to continue, suggest moving into proposal once the think artifact is confirmed.
   - If the user is still exploring, keep thinking instead of forcing structure too early.

## Think Output Template

```markdown
# YYYY-MM-DD <Requirement Title>

## Original Request

[The user's raw requirement, idea, or problem statement]

## Restated Understanding

[Forgevia's clearer restatement of the requirement]

## Scope And Boundaries

- [What is in scope]
- [What is out of scope]

## Risks And Open Questions

- [Risk, dependency, assumption, or unresolved question]

## Next Step Recommendation

[Recommended next action after confirmation]
```

## Guardrails

- Do not implement application code during think
- Do not skip the confirmation step
- Do not overwrite an earlier think artifact for the same requirement
- Do use `.mmd` diagrams and requirement documents as supporting context when provided
