---
name: executing-plans
description: Use when you have a written implementation plan to execute in a separate session with review checkpoints
---

# Executing Plans

## Overview

Load plan, review critically, execute OpenSpec tasks by dependency order, report between dependency checkpoints.

**Core principle:** Dependency-aware execution with checkpoints for architect review.

**Announce at start:** "I'm using the executing-plans skill to implement this plan."

## The Process

### Step 1: Load and Review Plan
1. Read plan file
   - Default path for OpenSpec: `openspec/changes/<change-name>/tasks.md`
2. Review critically - identify any questions or concerns about the plan
3. Parse task groups and dependencies from `Depends on:`
4. Parse checklist items and classify TDD stage markers (`RED`, `GREEN`, `REFACTOR`) when present
   - If `Depends on:` is absent, execute groups in numeric order
5. If concerns: Raise them with your human partner before starting
6. If no concerns: Create TodoWrite and proceed

### Step 2: Execute Dependency-Ready Group
**Default: Execute the first group whose dependencies are complete**

For each task in the selected group:
1. Mark as in_progress
2. Follow each step exactly
3. Respect TDD stage order inside the group:
   - Complete `RED` items first and verify failing tests
   - Complete `GREEN` items next and verify passing tests
   - Complete `REFACTOR` items last and keep tests green
4. Run verifications as specified
5. Mark as completed
6. Immediately sync `openspec/changes/<change-name>/tasks.md`:
   - Check completed items (`[x]`)
   - Add blocker note for unfinished blocked items

### Step 3: Report
When a dependency-ready group is complete:
- Show what was implemented
- Show verification output
- Say: "Ready for feedback."

### Step 4: Continue
Based on feedback:
- Apply changes if needed
- Recompute dependency-ready groups
- Execute next ready group
- Repeat until complete

### Step 5: Complete Development

After all tasks complete and verified:
- Announce: "I'm using the finishing-a-development-branch skill to complete this work."
- **REQUIRED SUB-SKILL:** Use superpowers:finishing-a-development-branch
- Follow that skill to verify tests, present options, execute choice

## When to Stop and Ask for Help

**STOP executing immediately when:**
- Hit a blocker mid-group (missing dependency, test fails, instruction unclear)
- Plan has critical gaps preventing starting
- You don't understand an instruction
- Verification fails repeatedly

**Ask for clarification rather than guessing.**

## When to Revisit Earlier Steps

**Return to Review (Step 1) when:**
- Partner updates the plan based on your feedback
- Fundamental approach needs rethinking

**Don't force through blockers** - stop and ask.

## Remember
- Review plan critically first
- Follow plan steps and dependency order exactly
- Don't skip verifications
- Reference skills when plan says to
- Between dependency checkpoints: just report and wait
- Stop when blocked, don't guess
- Never start implementation on main/master branch without explicit user consent
- Keep `tasks.md` synchronized in real time (no end-of-run bulk updates)

## Integration

**Required workflow skills:**
- **superpowers:using-git-worktrees** - REQUIRED: Set up isolated workspace before starting
- **superpowers:writing-plans** - Creates the plan this skill executes
- **superpowers:finishing-a-development-branch** - Complete development after all tasks
