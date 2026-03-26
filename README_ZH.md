<div align="center">

# Forgevia

### 面向 Codex、Claude 与 Agent Coding 交付的工作流整合方案

[English](README.md) | 中文

</div>

把你的 agent 开发流程锻造成钢铁。

Forgevia 是一套面向 agent coding 的工作流整合方案。

## Codex 安装方式

直接对 Codex 说：

```text
帮我安装，交互过程请使用中文：Fetch and follow instructions from https://raw.githubusercontent.com/musegate/Forgevia/refs/heads/main/INSTALL.codex.md
```

## Claude 安装方式

直接对 Claude 说：

```text
帮我安装，交互过程请使用中文：Fetch and follow instructions from https://raw.githubusercontent.com/musegate/Forgevia/refs/heads/main/INSTALL.claude.md
```

## 技能能力

- `forgevia`：Forgevia 工作流的总入口。
- `forgevia-init`：为当前项目准备 Forgevia 工作流环境。
- `forgevia-think`：在开发前梳理和澄清需求。
- `forgevia-propose`：将需求描述或指定文件转换为新的变更提案。
- `forgevia-implement`：针对指定的活跃变更执行结构化开发。
- `forgevia-tasks`：查看所有活跃变更下未完成的任务。
- `forgevia-review`：对当前工作发起一次聚焦评审。
- `forgevia-verify-web`：在浏览器中验证 Web 侧行为。
- `forgevia-draw`：为功能、链路或接口生成交互时序图。
- `forgevia-archive`：归档一个已完成的活跃变更。
- `forgevia-doctor`：检查 Forgevia 环境是否健康。
- `forgevia-repair`：修复缺失或漂移的 Forgevia 受管资源。

## 如何使用

### 完整版链路

`forgevia` 是总入口。你只需要明确告诉 Forgevia 当前要执行哪个动作，它会把需求、开发、评审、验证和归档串成一条一致的流程。

1. `Forgevia init`
   适合在新仓库开始使用时执行。它会检查当前项目是否已具备 Forgevia 工作流所需的基础文件；如果缺失，就补齐初始化内容。若这个仓库需要同时支持 Codex 和 Claude，建议按 `codex,claude` 初始化项目模板。
2. `Forgevia doctor`
   用于检查全局环境状态。它会告诉你当前安装的 Forgevia 资源是否正常、缺失，或者已经发生漂移。
3. `Forgevia repair`
   当 `doctor` 发现问题时使用。它会把缺失或漂移的 Forgevia 受管文件恢复到正确状态。
4. `Forgevia draw`
   适合在正式思考和开发前先做设计可视化。它可以围绕指定功能、接口或链路画出时序图、UML 图和泳道图 SVG 文件。生成的 `.mmd` 文件可以作为后续 `think` 的参考输入，同时也会渲染出可供开发参考的 SVG 矢量图，可直接用 Chrome 打开查看；当某个功能、接口或链路发生变化后，建议及时同步更新设计图、`.mmd` 和 SVG，让设计表达始终与实现保持一致。
5. `Forgevia think`
   在正式开发前先用它梳理需求。你可以直接说出一个模糊的想法，也可以提供更详细的说明，例如带上 `draw` 生成的 `.mmd` 流程图，或者直接输入完整的需求文档。输入越详细，后续分析和方案收敛通常会越准确。它会先重述你的需求并给出理解，等你确认后，再把本次结果沉淀为 `openspec/think/` 下的 Markdown 文件；文件名会以当天日期开头，相同需求会按 `v2`、`v3` 持续迭代。
6. `Forgevia propose`
   用它把需求描述或指定文件生成成一个新的 change。你可以直接输入刚刚 `think` 之后你已经满意的结果，也可以跳过前一步，直接提供一份你认为已经足够完整、足够满意的 request，这个由你自己决定。输出会形成一个有名字的交付单元，包含清晰范围、说明文档和可执行任务拆分。
7. `Forgevia tasks`
   当你只想看还有哪些事情没做完时使用。它会列出当前活跃变更中的未完成任务，方便安排下一步。
8. `Forgevia implement <change>`
   用于执行一个明确命名的活跃变更。它会按任务驱动的方式推进开发，持续对齐目标，并要求遵守严格的测试优先开发节奏，而不是随意编码。
9. `Forgevia review`
   用于关键检查点发起评审。它会针对当前工作做聚焦审查，优先基于明确的提交范围，并按严重级别严格排序问题，让最高风险项先被处理。
10. `Forgevia verify-web`
   当改动涉及页面、浏览器行为、交互流程或视觉效果时使用。它会在真实浏览器里验证用户最终会看到的结果。
11. `Forgevia archive <change>`
   当实现、评审和验证都完成后使用。它会关闭该变更、同步最终文档状态，并让项目历史保持整洁。

### 简版链路

`draw -> think -> propose -> implement -> review -> verify-web（如需要）-> archive`

Forgevia 把需求梳理、结构化开发、代码评审、效果验证和最终归档串成一条一致的交付流程。
