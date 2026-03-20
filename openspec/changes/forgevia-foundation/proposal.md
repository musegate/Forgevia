## Why

Forgevia needs a reproducible way to bootstrap and run an opinionated agent-development workflow across repositories without asking each user to hand-assemble OpenSpec, custom skills, code review, and Playwright pieces. The first release should make the Codex path stable and repeatable while keeping Claude support in the same repository.

## What Changes

- Create a GitHub-only distribution model that ships Forgevia-managed copies of the required workflow files instead of patching upstream installations at runtime.
- Define an installation/bootstrap flow that verifies required local capabilities, installs Forgevia-owned files into `~/.codex`, and initializes project-local OpenSpec assets for Codex and Claude.
- Define a doctor/repair flow that can detect missing, stale, or non-Forgevia-managed files and restore them to the expected state.
- Define a top-level workflow skill that orchestrates the intended sequence: OpenSpec discovery/proposal, plan execution, code review, optional Playwright-driven web verification, and archive handoff.
- Establish repository structure, manifests, and asset ownership rules so customized files copied from `~/.codex` can be versioned and shipped from Forgevia.

## Capabilities

### New Capabilities
- `environment-bootstrap`: Verify prerequisites and install Forgevia-managed assets into the correct global and project-local locations, with `~/.codex` as the primary target.
- `workflow-orchestration`: Provide a Forgevia entry workflow that routes Codex and Claude users through the intended OpenSpec, superpowers, review, and Playwright sequence.
- `distribution-bundle`: Package vendored skills, templates, install documents, and file metadata so GitHub is the single source of truth for installation and repair.

### Modified Capabilities

None.

## Impact

- New GitHub repository structure for installation docs, manifests, scripts, and vendored assets.
- New project-level OpenSpec design artifacts and future implementation tasks.
- User global directories such as `~/.codex` and, later, Claude-specific install targets.
- Workflow behavior for Codex and Claude sessions that adopt Forgevia-managed skills and commands.
