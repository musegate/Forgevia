## ADDED Requirements

### Requirement: Forgevia installs managed global assets for Codex
Forgevia SHALL provide an installation flow that verifies required prerequisites and installs Forgevia-managed files into the expected Codex global locations, with `~/.codex` as the primary managed root.

#### Scenario: Fresh Codex environment
- **WHEN** a user follows the Codex installation entrypoint in a machine where Forgevia-managed files are not yet present
- **THEN** Forgevia verifies prerequisite tools and creates the required managed file set under `~/.codex`

#### Scenario: Missing prerequisite detected
- **WHEN** the installation flow encounters a missing prerequisite required for Forgevia-managed workflow features
- **THEN** Forgevia reports the missing prerequisite and does not falsely report a successful install

### Requirement: Forgevia bootstraps project-local OpenSpec assets
Forgevia SHALL provide a project bootstrap flow that initializes OpenSpec non-interactively for the supported agent surfaces and then overlays any Forgevia-managed project-local assets required by the workflow.

#### Scenario: Project without OpenSpec initialization
- **WHEN** a user runs Forgevia bootstrap in a repository that has not been initialized for the supported agent surfaces
- **THEN** Forgevia initializes OpenSpec for those surfaces and installs the expected project-local assets

#### Scenario: Project already initialized
- **WHEN** a user runs Forgevia bootstrap in a repository that already has OpenSpec initialization
- **THEN** Forgevia preserves the valid existing structure and only applies the managed files that are missing or stale

### Requirement: Forgevia repairs managed installations
Forgevia SHALL provide a doctor or repair flow that can inspect managed targets, classify file state, and restore missing or stale Forgevia-managed files.

#### Scenario: Managed file missing
- **WHEN** a managed file defined by Forgevia is absent from its target location
- **THEN** the doctor flow reports the file as missing and can restore it from the repository-owned source

#### Scenario: Managed file changed locally
- **WHEN** a managed file exists at the target location but no longer matches the expected Forgevia-managed content
- **THEN** the doctor flow reports that the file has diverged and does not silently treat it as healthy
