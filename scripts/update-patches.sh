#!/usr/bin/env bash
# Regenerates patches/ from the material-chat branch of the local clone.
# Usage: scripts/update-patches.sh [upstream tag] [clone path]
# Example after a conflict:
#   cd E:/waenhancer && git fetch origin --tags && git rebase <new tag>   (resolve, build, test)
#   E:/waenhancer-material/scripts/update-patches.sh <new tag>
#   git -C E:/waenhancer-material add -A && git -C E:/waenhancer-material commit -m "..." && git -C E:/waenhancer-material push
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
BASE="${1:-$(cat "$REPO_DIR/UPSTREAM_BASE")}"
SRC="${2:-/e/waenhancer}"

git -C "$SRC" rev-parse --verify --quiet "$BASE^{commit}" >/dev/null \
  || { echo "Tag $BASE not found in $SRC (git fetch origin --tags?)"; exit 1; }
git -C "$SRC" merge-base --is-ancestor "$BASE" material-chat \
  || { echo "material-chat is not based on $BASE: rebase it first"; exit 1; }

rm -f "$REPO_DIR"/patches/*.patch
git -C "$SRC" format-patch -q --no-signature -o "$REPO_DIR/patches" "$BASE..material-chat"
echo "$BASE" > "$REPO_DIR/UPSTREAM_BASE"
ls "$REPO_DIR/patches"
