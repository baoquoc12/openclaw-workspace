#!/usr/bin/env bash
set -euo pipefail

SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_FILE="${ENV_FILE:-$SKILL_DIR/.env}"

if [[ -f "$ENV_FILE" ]]; then
  set -a
  # shellcheck disable=SC1090
  source "$ENV_FILE"
  set +a
else
  echo "Missing .env at $ENV_FILE" >&2
  exit 1
fi

: "${GITHUB_TOKEN:?Missing GITHUB_TOKEN in .env}"
: "${GITHUB_USERNAME:?Missing GITHUB_USERNAME in .env}"
: "${GITHUB_REPO_URL:?Missing GITHUB_REPO_URL in .env}"

REPO_PATH="${URL_SOURCE_BACKUP:-$(pwd)}"
BACKUP_ROOT="${BACKUP_NAME:-Backup}"

DATE_DAY="$(date +%d)"
DATE_MONTH="$(date +%m)"
DATE_YEAR="$(date +%Y)"
DEST_PATH="$REPO_PATH/$BACKUP_ROOT/$DATE_DAY/$DATE_MONTH/$DATE_YEAR"

mkdir -p "$DEST_PATH"

# Copy source excluding sensitive/loop folders
rsync -a --delete \
  --exclude='.git' \
  --exclude='.openclaw' \
  --exclude='.env' \
  --exclude="$BACKUP_ROOT" \
  "$REPO_PATH/" "$DEST_PATH/"

cd "$REPO_PATH"

# Ensure remote
if ! git remote get-url origin >/dev/null 2>&1; then
  git remote add origin "$GITHUB_REPO_URL"
else
  git remote set-url origin "$GITHUB_REPO_URL"
fi

# Add + commit
git add "$BACKUP_ROOT/$DATE_DAY/$DATE_MONTH/$DATE_YEAR"

git commit -m "backup $DATE_DAY/$DATE_MONTH/$DATE_YEAR" || true

tmp_askpass="/tmp/git-askpass.sh"
cat > "$tmp_askpass" <<'EOF'
#!/bin/sh
case "$1" in
*Username*) echo "$GITHUB_USERNAME";;
*Password*) echo "$GITHUB_TOKEN";;
*) echo "";;
esac
EOF
chmod +x "$tmp_askpass"
trap 'rm -f "$tmp_askpass"' EXIT

GIT_ASKPASS="$tmp_askpass" DISPLAY=1 git push -u origin main || \
GIT_ASKPASS="$tmp_askpass" DISPLAY=1 git push -u origin master
