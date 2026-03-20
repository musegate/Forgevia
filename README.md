# Forgevia

Forge your agent workflow into steel.

Forgevia is a GitHub-first workflow bundle for agent-driven development. It combines:

- OpenSpec
- superpowers
- requesting-code-review
- playwright-interactive

Forgevia currently supports Codex only. Claude is not supported yet and will be added later.

The current first release path is Codex-first. Forgevia installs and manages a curated set of files under `~/.codex`, including:

- a top-level `forgevia` skill
- `playwright-interactive`
- Forgevia-managed overrides for selected superpowers skills

## Current Codex Scope

Forgevia currently assumes:

- `openspec` comes from `npm install -g @fission-ai/openspec@latest`
- `superpowers` is installed from upstream first
- Forgevia then directly overlays its managed customizations into `~/.codex`
- Forgevia does not own project business files; it only helps invoke `openspec init` when needed

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

6. When a repository has not been initialized for OpenSpec yet:

```bash
./scripts/bootstrap-project.sh --tools codex /path/to/project
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
- a project bootstrap entrypoint that only runs `openspec init` when needed

Claude support is planned for a later phase in the same repository, but it is not implemented yet.

---

# Forgevia

把你的 agent 开发流程锻造成钢铁。

Forgevia 是一个以 GitHub 为中心的 agent 开发工作流整合项目，目前聚焦于 Codex，整合了以下能力：

- OpenSpec
- superpowers
- requesting-code-review
- playwright-interactive

当前版本只支持 Codex，暂不支持 Claude，Claude 支持会在后续版本补上。

Forgevia 当前会在 `~/.codex` 下安装和管理一组受控文件，包括：

- 顶层 `forgevia` skill
- `playwright-interactive`
- 一组由 Forgevia 接管的 superpowers 定制 skill

## 当前 Codex 范围

Forgevia 当前的工作方式是：

- `openspec` 通过 `npm install -g @fission-ai/openspec@latest` 安装
- `superpowers` 先按上游方式安装
- Forgevia 再把自己接管的定制内容直接覆盖到 `~/.codex`
- Forgevia 不接管项目业务文件，只在需要时帮助执行 `openspec init`

## 当前接管的 Superpowers 定制项

Forgevia 当前维护了这些定制过的 superpowers skill：

- `brainstorming`
- `writing-plans`
- `subagent-driven-development`
- `requesting-code-review`
- `executing-plans`

这些定制项都围绕 OpenSpec 工作流做了适配，路径约定统一到 `openspec/changes/<change-name>/...`。

## Codex 快速开始

1. 如果还没安装 OpenSpec：

```bash
npm install -g @fission-ai/openspec@latest
```

2. 先安装上游 superpowers：

按这个入口执行：
[superpowers Codex INSTALL](https://raw.githubusercontent.com/obra/superpowers/refs/heads/main/.codex/INSTALL.md)

3. 运行 Forgevia 安装器：

```bash
./scripts/install-codex.sh
```

4. 检查当前受管状态：

```bash
./scripts/doctor-codex.sh
```

5. 在 Codex 里显式调用 Forgevia：

```text
use Forgevia
```

6. 如果某个项目还没有初始化 OpenSpec：

```bash
./scripts/bootstrap-project.sh --tools codex /path/to/project
```

## 关键文件

- Codex 安装说明：[INSTALL.codex.md](INSTALL.codex.md)
- Codex 清单：[manifests/codex.json](manifests/codex.json)
- Forgevia 主 skill：[assets/codex/skills/forgevia/SKILL.md](assets/codex/skills/forgevia/SKILL.md)

## 当前状态

这个仓库还在持续搭建中，目前已经具备：

- vendored 的 Codex 资产
- 机器可读的 Codex manifest
- 最小可用的 Codex installer
- 最小可用的 Codex doctor
- 只负责调用 `openspec init` 的项目 bootstrap 入口

Claude 支持会在后续版本补齐，目前不要把它当成已支持能力使用。
