# Forgevia

Forge your agent workflow into steel.

Forgevia is a GitHub-first workflow bundle for agent-driven development. It combines:

- OpenSpec
- superpowers
- requesting-code-review
- playwright-interactive

The current first release path is Codex-first. Forgevia installs and manages a curated set of files under `~/.codex`, including:

- a top-level `forgevia` skill
- `playwright-interactive`
- Forgevia-managed overrides for selected superpowers skills

## Current Codex Scope

Forgevia currently assumes:

- `openspec` comes from `npm install -g @fission-ai/openspec@latest`
- `superpowers` is installed from upstream first
- Forgevia then directly overlays its managed customizations into `~/.codex`

## Managed Superpowers Overrides

Forgevia currently owns customized copies of:

- `brainstorming`
- `writing-plans`
- `subagent-driven-development`
- `requesting-code-review`
- `executing-plans`

These are customized for an OpenSpec-oriented workflow rooted in `openspec/changes/<change-name>/...`.

## Codex Quick Start

1. Install OpenSpec if needed:

```bash
npm install -g @fission-ai/openspec@latest
```

2. Install upstream superpowers for Codex:

Fetch and follow instructions from [superpowers Codex INSTALL](https://raw.githubusercontent.com/obra/superpowers/refs/heads/main/.codex/INSTALL.md)

3. Run the Forgevia installer:

```bash
./scripts/install-codex.sh
```

4. Check the managed state:

```bash
./scripts/doctor-codex.sh
```

5. In Codex, explicitly invoke Forgevia when you want the full orchestrated workflow:

```text
use Forgevia
```

## Key Files

- Codex install guide: [INSTALL.codex.md](INSTALL.codex.md)
- Codex manifest: [manifests/codex.json](manifests/codex.json)
- Forgevia skill: [assets/codex/skills/forgevia/SKILL.md](assets/codex/skills/forgevia/SKILL.md)

## Status

This repository is still being assembled. The current state provides:

- vendored Codex assets
- a machine-readable Codex manifest
- a minimal Codex installer
- a minimal Codex doctor

Claude support is planned as a parallel install surface in the same repository.
