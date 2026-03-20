## ADDED Requirements

### Requirement: Forgevia provides a top-level workflow entrypoint
Forgevia SHALL provide a workflow entrypoint that guides supported agents through the intended development sequence instead of requiring the user to remember each underlying skill manually.

#### Scenario: New development request
- **WHEN** a user starts a new implementation request in an environment where Forgevia has been installed
- **THEN** the Forgevia workflow entrypoint can route the session through the expected planning and implementation sequence

### Requirement: Forgevia composes the intended workflow phases
The Forgevia workflow SHALL define the expected phase order for the managed workflow, including OpenSpec exploration or proposal, plan or execution phase, code review checkpoints, optional Playwright-based web verification, and archive handoff.

#### Scenario: Backend-only change
- **WHEN** the user is working on a change that does not require browser validation
- **THEN** the managed workflow omits the Playwright verification phase without losing the remaining review and archive phases

#### Scenario: Web-facing change
- **WHEN** the user is working on a change that affects web behavior
- **THEN** the managed workflow includes Playwright-based verification before final archive handoff

### Requirement: Forgevia supports multiple agent surfaces from one repository
Forgevia SHALL keep a single product definition while allowing agent-specific installation surfaces and workflow references for Codex and Claude.

#### Scenario: Codex installation
- **WHEN** a user installs Forgevia for Codex
- **THEN** the workflow references the Codex-specific managed locations and assets

#### Scenario: Claude installation
- **WHEN** a user installs Forgevia for Claude
- **THEN** the workflow references the Claude-specific managed locations and assets while preserving the same Forgevia product identity
