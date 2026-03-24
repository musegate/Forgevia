---
name: brainstorming
description: "You MUST use this before any creative work - creating features, building components, adding functionality, or modifying behavior. Explores user intent, requirements and design before implementation."
---

# Brainstorming Ideas Into OpenSpec Designs

## Overview

Turn ideas into executable OpenSpec change artifacts through collaborative exploration.

**Announce at start:** "I'm using the brainstorming skill to explore requirements and produce OpenSpec artifacts."

This skill does discovery and design, not code implementation.

## Output Location (Required)

All outputs must live under:
- `openspec/changes/<change-name>/`

Never write design artifacts to `docs/plans/`.

## Required Artifact Set

For each brainstormed change, ensure this structure exists:
- `.openspec.yaml` (change metadata; created by OpenSpec CLI)
- `proposal.md` (requirement source + motivation + scope)
- `design.md` (technical design)
- `specs/<capability>/spec.md` (one per capability)
- `specs/<capability>/test-plan.md` (one per capability)

## The Process

### 1) Establish change context

1. Determine change name in kebab-case.
2. If change does not exist, create it:
   - `openspec new change "<change-name>"`
3. Verify directory exists: `openspec/changes/<change-name>/`
4. Treat `.openspec.yaml` as metadata source of truth. Do not handcraft invalid schema fields.

### 2) Discover requirements (conversation)

- Ask one question at a time.
- Prefer multiple-choice when it reduces ambiguity.
- Clarify purpose, constraints, success criteria, and non-goals.
- Propose 2-3 approaches with explicit trade-offs and a recommendation.

### 3) Identify capabilities explicitly

Extract capabilities from validated requirements before writing specs:
- Split into `new capabilities` and `modified capabilities`.
- Use kebab-case capability names.
- If multiple capabilities exist, create separate folders/files for each capability.

Example:
- `specs/user-auth/spec.md`
- `specs/user-auth/test-plan.md`
- `specs/session-hardening/spec.md`
- `specs/session-hardening/test-plan.md`

### 4) Write artifacts in this order

1. `proposal.md`
- Capture requirement sources (user pain, incident, policy, roadmap, etc.).
- Explain why now and intended impact.
- List all capabilities.

2. `design.md`
- Architecture, components, data flow, error handling, rollout strategy.
- Explicit decisions and trade-offs.

3. `specs/<capability>/spec.md` (for each capability)
- Requirements and scenarios.
- Scope boundaries and behavior constraints.

4. `specs/<capability>/test-plan.md` (for each capability)
- Unit/integration/e2e strategy.
- Key cases and acceptance checks.
- Failure-path coverage.

### 5) Build double-link traceability (required)

Use wiki-style links everywhere:
- `[[file.md#section]]`

Minimum linkage:
- In `spec.md`, each requirement section links to relevant design/test sections.
- In `test-plan.md`, each test group links back to requirement sections.
- Add placeholders for task backlinks that `writing-plans` will fill.

Recommended sections per spec/test-plan:
- `## Traceability`
- `### Forward Links`
- `### Back Links`

### 6) Validate and hand off

- Run: `openspec status --change "<change-name>"`
- Summarize capabilities produced and open questions.
- If moving to planning, hand off to `superpowers:writing-plans` to generate unified `tasks.md`.

## Key Principles

- One question at a time
- Separate capabilities cleanly
- Keep specs behavior-focused (not implementation details)
- Enforce double-link traceability
- Keep artifacts in OpenSpec change directory only
