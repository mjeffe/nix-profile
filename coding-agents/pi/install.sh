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

# -- Subagent extension (forked from pi examples, patched for thinkingLevel) ----------
EXT_DIR="${PI_AGENT}/extensions/subagent"
mkdir -p "${EXT_DIR}"
link "${HERE}/extensions/subagent/index.ts"  "${EXT_DIR}/index.ts"
link "${HERE}/extensions/subagent/agents.ts" "${EXT_DIR}/agents.ts"

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
