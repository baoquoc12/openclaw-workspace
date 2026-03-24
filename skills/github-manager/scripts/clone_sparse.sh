#!/usr/bin/env bash
set -euo pipefail

REPO_URL="${1:-}"
TARGET_DIR="${2:-}"
PATH_IN_REPO="${3:-}"

if [[ -z "$REPO_URL" || -z "$TARGET_DIR" ]]; then
  echo "Usage: clone_sparse.sh <repo_url> <target_dir> [path_in_repo]" >&2
  exit 1
fi

# If path_in_repo is empty, do full clone
if [[ -z "$PATH_IN_REPO" ]]; then
  git clone "$REPO_URL" "$TARGET_DIR"
  exit 0
fi

git clone --filter=blob:none --sparse "$REPO_URL" "$TARGET_DIR"
cd "$TARGET_DIR"
git sparse-checkout set "$PATH_IN_REPO"
