# Forgevia For Claude

Forgevia supports a Claude installation path that mirrors the Forgevia skill layout used on Codex while staying compatible with Claude's skill and plugin structure.

The Claude installer manages:

- Forgevia and OpenSpec support skills under `~/.claude/skills`
- the `opsx` command set under `~/.claude/commands`
- the full Forgevia Claude skill set
- Forgevia-managed overrides for selected installed Claude superpowers skills:
  - `brainstorming`
  - `writing-plans`
  - `test-driven-development`
  - `subagent-driven-development`
  - `requesting-code-review`
  - `executing-plans`

This path installs Forgevia-managed Claude skills and commands into `~/.claude` and overlays selected skill overrides into the installed Claude superpowers plugin.

## Prerequisites

- `openspec` must be available on `PATH`
- the Claude superpowers plugin must already be installed

If `openspec` is missing, either install it yourself with `npm install -g @fission-ai/openspec@latest` or let the installer do it with `--install-openspec`. Without `openspec`, the installer will still apply Claude skills and superpowers overrides, but it will skip the Forgevia-managed OpenSpec overrides.

In Claude Code, register the marketplace first:

```text
/plugin marketplace add obra/superpowers-marketplace
```

Then install the plugin from this marketplace:

```text
/plugin install superpowers@superpowers-marketplace
```

When Claude Code prompts for the install scope, choose `user`.

## Current Scope

The current Claude implementation installs:

- OpenSpec support skills:
  - `openspec-explore`
  - `openspec-propose`
  - `openspec-apply-change`
  - `openspec-archive-change`
- Forgevia skills:
  - `forgevia`
  - `forgevia-init`
  - `forgevia-doctor`
  - `forgevia-repair`
  - `forgevia-think`
  - `forgevia-propose`
  - `forgevia-implement`
  - `forgevia-tasks`
  - `forgevia-review`
  - `forgevia-verify-web`
  - `forgevia-draw`
  - `forgevia-archive`
- Helper skills required by the Forgevia flow:
  - `mermaid-diagram-specialist`
  - `playwright-interactive`
- `~/.claude/commands/opsx`
- selected overrides into the installed Claude superpowers plugin

Current behavior of the Claude Forgevia layer:

- keeps the same Forgevia command surface as Codex
- routes proposal, implementation, review, verification, drawing, and archive requests through the same Forgevia skill boundaries
- keeps `forgevia-think` on the same artifact, confirmation, and versioning rules
- installs the support skills those Forgevia commands depend on

Current behavior of the Claude superpowers overrides:

- binds brainstorming and planning to `openspec/changes/<change>/...`
- keeps `test-driven-development` aligned with the Forgevia-managed TDD skill text
- keeps execution aligned to `openspec/changes/<change>/tasks.md`
- keeps code review aligned to explicit commit ranges and `P0`/`P1`/`P2` ordering

## Install

Tell Claude:

```text
Install openspec and the Claude superpowers plugin first. Then clone https://github.com/Cooooooody/Forgevia and run bash scripts/install-claude.sh from the repository root.
```

Or run it directly yourself:

```bash
git clone https://github.com/Cooooooody/Forgevia.git
cd Forgevia
bash scripts/install-claude.sh
```

If you also want the installer to bootstrap `openspec` when missing, use:

```bash
bash scripts/install-claude.sh --install-openspec
```

## Target State

After installation:

- the Forgevia and OpenSpec support skill directories exist under `~/.claude/skills/`
- `~/.claude/commands/opsx` exists
- selected Claude superpowers skill files are replaced with Forgevia-managed copies
- Claude can discover and use the Forgevia command set globally
- project bootstrap can initialize OpenSpec with `--tools codex,claude` when the repository should support both Forgevia clients

## Notes

- This is a Claude-specific install path and does not modify `~/.codex`
- This installer expects the Claude superpowers plugin to already be installed
