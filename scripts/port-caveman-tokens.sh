#!/usr/bin/env bash
# Copy caveman TOKEN OPTIMIZATION sources only from the caveman remote into this fork.
# Explicitly excludes: mom, web-ui, serve/SSH, MCP, goal-loop, repomap, memory, RTK, ML compression.
# Use after upstream merges that overwrite overlay files, or to refresh from caveman-code.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

CAVEMAN_REMOTE="${CAVEMAN_REMOTE:-caveman}"
CAVEMAN_REF="${CAVEMAN_REF:-$CAVEMAN_REMOTE/main}"

if ! git remote get-url "$CAVEMAN_REMOTE" >/dev/null 2>&1; then
	git remote add "$CAVEMAN_REMOTE" https://github.com/JuliusBrussee/caveman-code.git
fi

git fetch "$CAVEMAN_REMOTE" main

copy_file() {
	local src="$1"
	local dest="$2"
	mkdir -p "$(dirname "$dest")"
	git show "$CAVEMAN_REF:$src" > "$dest"
	echo "ported $dest"
}

# Standalone modules — copy verbatim (package names differ; integration is in overlay files)
copy_file packages/coding-agent/src/core/cave-tool-compression.ts \
	packages/coding-agent/src/core/cave-tool-compression.ts
copy_file packages/coding-agent/src/core/cave-structured-compression.ts \
	packages/coding-agent/src/core/cave-structured-compression.ts
copy_file packages/coding-agent/test/cave-mode.test.ts \
	packages/coding-agent/test/cave-mode.test.ts
copy_file packages/coding-agent/skills/caveman-compress/SKILL.md \
	packages/coding-agent/skills/caveman-compress/SKILL.md

echo ""
echo "Standalone caveman files ported."
echo "Integration files (agent-session, settings-manager, system-prompt, interactive-mode)"
echo "must be merged manually or re-applied from your fork's caveman-tokens commit."
echo "Run ./scripts/verify-caveman-overlay.sh to check."