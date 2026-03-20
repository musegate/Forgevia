## Context

Forgevia is intended to productize an existing personal workflow built around OpenSpec, superpowers, requesting-code-review, and playwright-interactive. The workflow currently depends on a mix of global assets in `~/.codex` and project-local OpenSpec initialization, plus some customized skill content. The first release target is GitHub-only distribution, not npm packaging.

The repository must support at least two installation surfaces in the same codebase:

- Codex installation and runtime assets
- Claude installation and runtime assets

The user has explicitly chosen a distribution model that vendors the customized files into Forgevia and installs from those copies, rather than applying runtime patches to upstream repositories. The primary managed target for the first phase is `~/.codex`.

## Goals / Non-Goals

**Goals:**
- Make Forgevia the source of truth for the managed workflow assets it installs.
- Provide a reliable bootstrap path that checks prerequisites, copies managed files, and initializes OpenSpec for Codex and Claude in a target repository.
- Provide a repair path that can detect missing or stale managed files and restore them.
- Keep the initial product understandable: GitHub repo, install docs, manifests, assets, and a small set of deterministic scripts.
- Separate product orchestration logic from installation/repair logic so the workflow skill stays concise.

**Non-Goals:**
- Publishing Forgevia to npm in the first release.
- Hot-updating all runtime config without any restart requirements.
- Supporting every possible agent platform in v1.
- Automatically merging arbitrary user edits into managed files.
- Depending on upstream superpowers or OpenSpec repositories being reachable during every install or repair run.

## Decisions

### Decision: Vendor managed assets directly in Forgevia

Forgevia will store managed copies of the relevant customized files inside the repository and install from those copies.

Why:
- This is the simplest path to a stable "fetch and install" experience.
- Runtime patching against upstream repos is more fragile and harder to debug.
- It gives Forgevia a clear release artifact: the exact files that should exist on disk after installation.

Alternatives considered:
- Patch upstream installations at runtime. Rejected because upstream changes can break patch application and create opaque failure modes.
- Require users to manually clone several repos. Rejected because it weakens the "out of the box" goal.

### Decision: Split the product into installer, doctor, and workflow layers

Forgevia will use deterministic scripts for installation and verification, and reserve the top-level skill for orchestration guidance.

Why:
- Skills are better for runtime behavior than for large deterministic filesystem operations.
- Installation and repair need repeatable file operations, manifests, and clear failure output.
- This keeps the workflow skill short enough to remain discoverable and maintainable.

Alternatives considered:
- Put all logic in one large skill. Rejected because it would be too long, brittle, and poor at deterministic file management.

### Decision: Use a manifest-driven file ownership model

Forgevia will maintain a machine-readable manifest describing each managed file, its target path, target surface, and integrity metadata.

Why:
- The doctor flow needs to distinguish managed files from arbitrary user files.
- Version checks and stale-file detection become much easier with per-file metadata.
- This supports future Codex and Claude variants without changing the install model.

Alternatives considered:
- Infer ownership only from file paths. Rejected because users may already have files in those locations.
- Compare entire directory trees without metadata. Rejected because the output would be noisy and ambiguous.

### Decision: Support Codex and Claude from one repo, with separate install entry documents

Forgevia will keep one repository but provide distinct install documents and install targets per platform.

Why:
- The workflow brand stays unified.
- Shared assets and shared scripts can live together while platform-specific instructions stay isolated.
- The Codex path can ship first without blocking Claude support design.

Alternatives considered:
- Separate repositories per platform. Rejected because it duplicates shared assets and fragments maintenance.

### Decision: Project bootstrap initializes OpenSpec non-interactively

Forgevia bootstrap will initialize OpenSpec in the target project using the supported non-interactive tool configuration, then overlay Forgevia-managed project assets as needed.

Why:
- It leverages the upstream CLI for the official project skeleton.
- It reduces the amount of OpenSpec scaffolding Forgevia must maintain itself.
- It keeps initialization aligned with current CLI expectations.

Alternatives considered:
- Hand-create OpenSpec directories and commands. Rejected because it would drift from upstream behavior faster.

## Risks / Trade-offs

- [Upstream drift in vendored files] -> Track source provenance and refresh procedure in the repo so managed copies can be intentionally updated.
- [Users already have customized files in `~/.codex`] -> Doctor must classify file state and install should warn before overwriting unmanaged files.
- [Platform-specific config still needs restart] -> Installation docs must explicitly call out restart-required steps instead of pretending everything is live immediately.
- [Codex and Claude layouts diverge over time] -> Keep manifests and install targets separated by platform, even when files share a common source.
- [License or attribution concerns for vendored upstream content] -> Record source, license, and transformation notes for each imported asset before publishing.

## Migration Plan

1. Create the Forgevia repository structure, manifests, and initial OpenSpec product definition.
2. Import the first managed asset set from the current `~/.codex` workflow into repository-owned locations with provenance metadata.
3. Implement Codex-first install and doctor scripts targeting `~/.codex`.
4. Add project bootstrap logic that initializes OpenSpec for Codex and Claude and overlays Forgevia-managed project assets.
5. Add the Forgevia workflow skill and supporting references.
6. Add Claude installation assets and docs using the same manifest model.
7. Validate the flow in a clean workspace before public release.

Rollback strategy:
- Managed installs should be able to back up replaced files before overwrite.
- Doctor should be able to report what Forgevia currently owns so users can remove it manually if needed.

## Open Questions

- Which exact customized files from the current `~/.codex` setup belong in the first published asset bundle?
- Should Forgevia back up overwritten files automatically or only after explicit confirmation?
- How should Forgevia represent "managed but locally modified" state: hash mismatch only, or explicit sidecar metadata as well?
- Should Claude support ship fully in v1 or be scaffolded with placeholder install docs while Codex is the only fully implemented path?
