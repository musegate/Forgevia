# Forgevia For Claude

Forgevia currently supports an initial Claude installation path focused on:

- `forgevia-think`
- Forgevia-managed overrides for selected installed Claude superpowers skills:
  - `brainstorming`
  - `writing-plans`
  - `subagent-driven-development`
  - `requesting-code-review`
  - `executing-plans`

This path installs Forgevia-managed Claude skills into `~/.claude` and overlays selected skill overrides into the installed Claude superpowers plugin.

## Current Scope

The current first-pass Claude implementation installs:

- `~/.claude/skills/forgevia-think`
- selected overrides into the installed Claude superpowers plugin

Current behavior of `forgevia-think`:

- accepts rough ideas, detailed requests, `.mmd` diagrams, or requirement documents
- restates the requirement and waits for user confirmation
- writes confirmed think artifacts to `openspec/think/`
- versions repeated iterations with `-v2`, `-v3`, and so on

Current behavior of the Claude superpowers overrides:

- binds brainstorming and planning to `openspec/changes/<change>/...`
- keeps execution aligned to `openspec/changes/<change>/tasks.md`
- keeps code review aligned to explicit commit ranges and `P0`/`P1`/`P2` ordering

## Install

Tell Claude:

```text
Install the Claude superpowers plugin first. Then clone https://github.com/Cooooooody/Forgevia and run bash scripts/install-claude.sh from the repository root.
```

Or run it directly yourself:

```bash
git clone https://github.com/Cooooooody/Forgevia.git
cd Forgevia
bash scripts/install-claude.sh
```

## Target State

After installation:

- `~/.claude/skills/forgevia-think/SKILL.md` exists
- selected Claude superpowers skill files are replaced with Forgevia-managed copies
- Claude can discover and use the Forgevia think workflow globally

## Notes

- This is a Claude-specific install path and does not modify `~/.codex`
- This installer expects the Claude superpowers plugin to already be installed
