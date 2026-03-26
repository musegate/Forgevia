<div align="center">

# Forgevia

### A workflow bundle for Codex, Claude, and agent coding delivery

[English](README.md) | [中文](README_ZH.md)

</div>

Forge your agent workflow into steel.

Forgevia is an opinionated workflow bundle for agent coding.

## Install For Codex

Tell Codex:

```text
Fetch and follow instructions from https://raw.githubusercontent.com/musegate/Forgevia/refs/heads/main/INSTALL.codex.md
```

## Install For Claude

Tell Claude:

```text
Fetch and follow instructions from https://raw.githubusercontent.com/musegate/Forgevia/refs/heads/main/INSTALL.claude.md
```

## Skills

- `forgevia`: General entry for the Forgevia workflow.
- `forgevia-init`: Prepare the current project for the Forgevia workflow.
- `forgevia-think`: Clarify and shape a requirement before implementation.
- `forgevia-propose`: Turn a requirement description or file into a new change proposal.
- `forgevia-implement`: Implement one named active change with a structured workflow.
- `forgevia-tasks`: List unfinished tasks across active changes.
- `forgevia-review`: Run a focused review checkpoint for current work.
- `forgevia-verify-web`: Verify web-facing behavior in a browser.
- `forgevia-draw`: Generate interaction sequence diagrams for a feature, flow, or interface.
- `forgevia-archive`: Archive one completed active change.
- `forgevia-doctor`: Inspect whether the Forgevia environment is healthy.
- `forgevia-repair`: Repair missing or drifted Forgevia-managed assets.

## How it works

### Full workflow

`forgevia` is the top-level entry. You tell Forgevia which action to run, and it keeps the work on one consistent path from idea to completion.

1. `Forgevia init`
   Use this when starting in a new repository. It checks whether the project is ready for the Forgevia workflow and creates the required project-side workflow files only when they are missing. If the repository should work from both Codex and Claude, initialize the project with `codex,claude`.
2. `Forgevia doctor`
   Use this to inspect the global environment. It reports whether the installed Forgevia assets are healthy, missing, or out of sync.
3. `Forgevia repair`
   Use this when `doctor` finds problems. It restores missing or drifted Forgevia-managed files so the workflow can run consistently again.
4. `Forgevia draw`
   Use this when the team needs a visual design aid before implementation. It can generate sequence diagrams, UML-style diagrams, and swimlane diagrams for a specific feature, interface, or flow. The generated `.mmd` file can be used as reference input for the later thinking and planning steps, and Forgevia also renders an SVG vector diagram that can be opened in Chrome and used as a visual reference during development. When a feature, interface, or flow changes, update the design diagram, `.mmd`, and SVG promptly so the visual design stays aligned with implementation.
5. `Forgevia think`
   Use this before building to clarify the request. You can start with a rough idea, provide a more detailed description, attach the `.mmd` flow produced by `draw`, or supply a full requirements document. In general, the more concrete the input is, the more precise the resulting analysis and direction will be. Forgevia first restates the request and its understanding, waits for your confirmation, and then writes the result to a Markdown file under `openspec/think/`; filenames start with the current date, and repeated iterations of the same requirement continue as `v2`, `v3`, and so on.
6. `Forgevia propose`
   Use this to generate a new change from a requirement or an input file. You can feed in the result you are happy with after `think`, or skip that step and provide a request that you already consider complete and ready. That choice is up to you. The output is a named implementation unit with clear scope, documentation, and executable task breakdown.
7. `Forgevia tasks`
   Use this when you want a read-only view of unfinished work. It lists pending tasks across active changes and helps decide what to do next.
8. `Forgevia implement <change>`
   Use this to execute one named active change. It drives development through a structured task flow, keeps progress aligned with the change definition, and expects disciplined test-first execution rather than ad-hoc coding.
9. `Forgevia review`
   Use this at review checkpoints. It requests a focused review of the current work, preferably against a clear commit range, and reports findings in strict severity order so the highest-risk issues are handled first.
10. `Forgevia verify-web`
   Use this when the change affects web pages, browser behavior, UI interaction, or visual output. It validates the user-facing result in a real browser before completion.
11. `Forgevia archive <change>`
   Use this after implementation, review, and verification are complete. It closes the finished change, syncs its final documentation, and keeps the project history clean.

### Simple workflow

`draw -> think -> propose -> implement -> review -> verify-web (if needed) -> archive`

Forgevia turns requirement shaping, structured implementation, review, validation, and closure into one consistent delivery workflow.
