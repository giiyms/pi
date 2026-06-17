#!/usr/bin/env bash
# Verify caveman token optimization files exist and contain expected markers.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

MANIFEST="$ROOT/scripts/caveman-overlay.manifest"
FAIL=0

check_file() {
	local path="$1"
	if [[ ! -f "$path" ]]; then
		echo "MISSING: $path"
		FAIL=1
	fi
}

check_marker() {
	local path="$1"
	local marker="$2"
	if [[ -f "$path" ]] && ! grep -q "$marker" "$path"; then
		echo "MARKER MISSING in $path: expected '$marker'"
		FAIL=1
	fi
}

while IFS= read -r line; do
	[[ -z "$line" || "$line" =~ ^# ]] && continue
	check_file "$line"
done < "$MANIFEST"

check_marker packages/coding-agent/src/core/cave-tool-compression.ts "ReadDeduplicationCache"
check_marker packages/coding-agent/src/core/cave-structured-compression.ts "compressStructuredOutput"
check_marker packages/coding-agent/src/core/agent-session.ts "getCaveModeSessionState"
check_marker packages/coding-agent/src/core/settings-manager.ts "getCaveModeEnabled"
check_marker packages/coding-agent/src/core/system-prompt.ts "buildCaveModePrompt"

if [[ "$FAIL" -ne 0 ]]; then
	echo ""
	echo "Caveman overlay verification FAILED."
	echo "To port fresh token optimizations from caveman-code:"
	echo "  ./scripts/port-caveman-tokens.sh"
	exit 1
fi

echo "Caveman overlay verification passed."