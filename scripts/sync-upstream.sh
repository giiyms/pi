#!/usr/bin/env bash
# Sync earendil-works/pi upstream into this fork.
#
# Usage:
#   ./scripts/sync-upstream.sh              # merge upstream/main into current branch
#   ./scripts/sync-upstream.sh --rebase     # rebase current branch onto upstream/main
#   ./scripts/sync-upstream.sh --check      # show commits behind/ahead of upstream
#
# After a merge with conflicts, resolve them then run:
#   ./scripts/verify-caveman-overlay.sh
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

UPSTREAM_REMOTE="${UPSTREAM_REMOTE:-upstream}"
UPSTREAM_BRANCH="${UPSTREAM_BRANCH:-main}"
CAVEMAN_REMOTE="${CAVEMAN_REMOTE:-caveman}"

ensure_remotes() {
	if ! git remote get-url "$UPSTREAM_REMOTE" >/dev/null 2>&1; then
		git remote add "$UPSTREAM_REMOTE" https://github.com/earendil-works/pi.git
	fi
	if ! git remote get-url "$CAVEMAN_REMOTE" >/dev/null 2>&1; then
		git remote add "$CAVEMAN_REMOTE" https://github.com/JuliusBrussee/caveman-code.git
	fi
}

ensure_remotes
git fetch "$UPSTREAM_REMOTE" "$UPSTREAM_BRANCH"
git fetch "$CAVEMAN_REMOTE" main 2>/dev/null || true

if [[ "${1:-}" == "--check" ]]; then
	echo "=== vs $UPSTREAM_REMOTE/$UPSTREAM_BRANCH ==="
	git log --oneline HEAD.."$UPSTREAM_REMOTE/$UPSTREAM_BRANCH" | head -20 || true
	echo "--- behind: $(git rev-list --count HEAD.."$UPSTREAM_REMOTE/$UPSTREAM_BRANCH" 2>/dev/null || echo 0) commits"
	echo "--- ahead:  $(git rev-list --count "$UPSTREAM_REMOTE/$UPSTREAM_BRANCH"..HEAD 2>/dev/null || echo 0) commits"
	exit 0
fi

if [[ "${1:-}" == "--rebase" ]]; then
	echo "Rebasing onto $UPSTREAM_REMOTE/$UPSTREAM_BRANCH ..."
	git rebase "$UPSTREAM_REMOTE/$UPSTREAM_BRANCH"
else
	echo "Merging $UPSTREAM_REMOTE/$UPSTREAM_BRANCH ..."
	git merge --no-edit "$UPSTREAM_REMOTE/$UPSTREAM_BRANCH" || {
		echo ""
		echo "Merge conflicts detected. After resolving:"
		echo "  git add <resolved-files>"
		echo "  git commit"
		echo "  ./scripts/verify-caveman-overlay.sh"
		exit 1
	}
fi

echo ""
echo "Upstream sync complete. Verifying caveman overlay ..."
"$ROOT/scripts/verify-caveman-overlay.sh"