## ADDED Requirements

### Requirement: Forgevia ships repository-owned managed assets
Forgevia SHALL treat the GitHub repository as the source of truth for the managed skills, templates, commands, manifests, and install documents that it distributes.

#### Scenario: User installs from GitHub-only distribution
- **WHEN** a user follows the published Forgevia installation instructions from the repository
- **THEN** all installed Forgevia-managed files come from assets committed to the Forgevia repository

### Requirement: Forgevia records ownership and provenance for managed files
Forgevia SHALL maintain machine-readable metadata for each managed asset, including its source role, installation target, and enough integrity information for doctor or repair flows to classify file state.

#### Scenario: Doctor inspects a managed asset
- **WHEN** Forgevia inspects a target file that belongs to its managed set
- **THEN** Forgevia can determine whether the file is healthy, missing, stale, or locally modified based on its recorded metadata

### Requirement: Forgevia separates shared assets from platform-specific entrypoints
Forgevia SHALL support one repository with shared managed assets and separate platform-specific install entrypoints for Codex and Claude.

#### Scenario: Platform-specific install docs
- **WHEN** a user opens the installation documentation for Codex or Claude
- **THEN** the user sees the correct platform-specific installation path without needing a separate Forgevia repository
