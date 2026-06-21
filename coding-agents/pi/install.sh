#!/usr/bin/env bash
set -euo pipefail

# Pi Subagents — multi-model delegation system
# Installs pi (if needed), sets up the subagent extension with thinkingLevel support,
# and symlinks agent definitions + skills into ~/.pi/agent/

HERE="$(cd "$(dirname "$0")" && pwd)"
PI_AGENT="${HOME}/.pi/agent"

echo "==> Installing pi subagents from: ${HERE}"

# -- Install pi -----------------------------------------------
if ! command -v pi &>/dev/null; then
    echo "==> Installing pi..."
    curl -fsSL https://pi.dev/install.sh | sh
fi

# -- Find pi's installed examples -----------------------------
PI_EXAMPLES=""
# npm global install
for candidate in \
    "$(npm root -g 2>/dev/null || true)/@earendil-works/pi-coding-agent/examples" \
    "$(dirname "$(which pi 2>/dev/null || echo /none)")/../lib/node_modules/@earendil-works/pi-coding-agent/examples" \
    /usr/local/lib/node_modules/@earendil-works/pi-coding-agent/examples; do
    if [ -d "${candidate}/extensions/subagent" ]; then
        PI_EXAMPLES="${candidate}"
        break
    fi
done

if [ -z "${PI_EXAMPLES}" ]; then
    echo "ERROR: Could not find pi's examples directory. Is pi installed?"
    exit 1
fi
echo "    pi examples: ${PI_EXAMPLES}"

# -- Symlink helper -------------------------------------------
link() {
    local src="$1" dst="$2"
    if [ -L "${dst}" ] && [ "$(readlink "${dst}")" = "${src}" ]; then
        return 0
    fi
    if [ -e "${dst}" ]; then
        rm -rf "${dst}"
    fi
    ln -s "${src}" "${dst}"
    echo "    ln  ${dst}"
}

# -- Subagent extension (patched for thinkingLevel) -----------
EXT_DIR="${PI_AGENT}/extensions/subagent"
mkdir -p "${EXT_DIR}"

# Copy stock extension as base, then patch
cp "${PI_EXAMPLES}/extensions/subagent/index.ts"  "${EXT_DIR}/index.ts"
cp "${PI_EXAMPLES}/extensions/subagent/agents.ts" "${EXT_DIR}/agents.ts"

# Patch index.ts: pass --thinking flag when agent specifies thinkingLevel
if ! grep -q 'thinkingLevel.*args.push.*--thinking' "${EXT_DIR}/index.ts"; then
    sed -i '/if (agent.tools && agent.tools.length > 0) args.push("--tools", agent.tools.join(","));/i\
\tif (agent.thinkingLevel) args.push("--thinking", agent.thinkingLevel);' "${EXT_DIR}/index.ts"
    echo "    patched index.ts (+thinkingLevel)"
fi

# Patch agents.ts: add thinkingLevel to interface + parse from frontmatter
if ! grep -q 'thinkingLevel?:' "${EXT_DIR}/agents.ts"; then
    sed -i '/description: string;/a\
\tthinkingLevel?: string;' "${EXT_DIR}/agents.ts"
    sed -i '/model: frontmatter.model,/a\
\t\t\tthinkingLevel: frontmatter.thinkingLevel || frontmatter.thinking,' "${EXT_DIR}/agents.ts"
    echo "    patched agents.ts (+thinkingLevel)"
fi

# -- Agents ---------------------------------------------------
mkdir -p "${PI_AGENT}/agents"
for agent in "${HERE}/agents/"*.md; do
    name="$(basename "${agent}")"
    link "${agent}" "${PI_AGENT}/agents/${name}"
done

# -- Skills ---------------------------------------------------
mkdir -p "${PI_AGENT}/skills/subagents"
link "${HERE}/skills/subagents/SKILL.md" "${PI_AGENT}/skills/subagents/SKILL.md"

# -- Keybindings -----------------------------------------------
link "${HERE}/keybindings.json" "${PI_AGENT}/keybindings.json"

echo ""
echo "Done. Restart pi or run /reload to pick up changes."
