## 1. Product Skeleton

- [ ] 1.1 Create the Forgevia repository skeleton for shared assets, platform-specific install docs, manifests, and scripts
- [ ] 1.2 Add a machine-readable manifest format for managed files, targets, and integrity metadata
- [ ] 1.3 Define provenance rules for vendored files copied from the current `~/.codex` setup

## 2. Codex Asset Bundle

- [ ] 2.1 Inventory the first-release Codex files under `~/.codex` that Forgevia must manage
- [ ] 2.2 Copy the approved Codex-managed files into repository-owned asset locations
- [ ] 2.3 Record install targets and expected state for each Codex-managed file in the manifest

## 3. Installer And Doctor

- [ ] 3.1 Implement a Codex-first install script that verifies prerequisites and installs Forgevia-managed files into `~/.codex`
- [ ] 3.2 Implement a doctor or repair script that detects missing, stale, and diverged managed files
- [ ] 3.3 Add backup or overwrite behavior for unmanaged or locally modified target files

## 4. Project Bootstrap

- [ ] 4.1 Implement project bootstrap that initializes OpenSpec non-interactively for Codex and Claude
- [ ] 4.2 Overlay Forgevia-managed project-local assets after OpenSpec initialization
- [ ] 4.3 Verify bootstrap behavior for both fresh and already-initialized repositories

## 5. Workflow Skill

- [ ] 5.1 Define the Forgevia top-level workflow skill and its supporting references
- [ ] 5.2 Encode the intended phase sequence for OpenSpec, plan execution, review, optional Playwright verification, and archive handoff
- [ ] 5.3 Add Codex-first documentation for when the workflow includes or skips Playwright verification

## 6. Claude Surface

- [ ] 6.1 Define the Claude-specific install targets and asset mapping in the manifest
- [ ] 6.2 Add `INSTALL.claude.md` and any Claude-specific managed files required for parity with the Codex flow
- [ ] 6.3 Validate that shared assets and platform-specific entrypoints remain clearly separated

## 7. Release Readiness

- [ ] 7.1 Test installation and repair in a clean Codex environment
- [ ] 7.2 Review licenses and attribution requirements for vendored upstream content
- [ ] 7.3 Publish the GitHub-first installation path and contributor guidance for refreshing managed assets
