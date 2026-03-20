/**
 * Serialize config to YAML string with default localized project context.
 *
 * @param config - Partial config object (schema required, context optional)
 * @returns YAML string ready to write to file
 */
export function serializeConfig(config) {
    const defaultContext = '语言：中文（简体）\n所有产出物必须用简体中文撰写。';
    const lines = [];
    // Schema (required)
    lines.push(`schema: ${config.schema}`);
    const context = config.context ?? defaultContext;
    if (context.length > 0) {
        lines.push('context: |');
        for (const line of context.split('\n')) {
            lines.push(`  ${line}`);
        }
    }
    return lines.join('\n') + '\n';
}
//# sourceMappingURL=config-prompts.js.map
