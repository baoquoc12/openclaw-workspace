#!/usr/bin/env bash
set -euo pipefail

export TZ="Asia/Ho_Chi_Minh"

WORKSPACE_ROOT="/home/ubuntu/.openclaw/workspace"
SKILL_DIR="$WORKSPACE_ROOT/skills/github-manager"
ENV_FILE="${ENV_FILE:-$SKILL_DIR/.env}"
BACKUP_LABEL_INPUT="${1:-}"
TMP_ASKPASS="/tmp/git-askpass.sh"
WORKTREE_DIR="/tmp/github-manager-worktree-$$"
SNAPSHOT_DIR="/tmp/github-manager-snapshot-$$"

fail() {
  echo "[Lỗi] $1" >&2
  exit 1
}

cleanup() {
  rm -f "$TMP_ASKPASS"
  rm -rf "$SNAPSHOT_DIR"
  if [[ -d "$WORKTREE_DIR" ]]; then
    git -C "$WORKSPACE_ROOT" worktree remove --force "$WORKTREE_DIR" >/dev/null 2>&1 || true
    rm -rf "$WORKTREE_DIR"
  fi
}
trap cleanup EXIT

if [[ ! -f "$ENV_FILE" ]]; then
  fail "Không thấy file .env tại $ENV_FILE. Hãy chạy: cp .env.example .env rồi điền thông tin."
fi

set -a
# shellcheck disable=SC1090
source "$ENV_FILE"
set +a

[[ -n "${GITHUB_TOKEN:-}" ]] || fail "Thiếu GITHUB_TOKEN trong .env"
[[ -n "${GITHUB_USERNAME:-}" ]] || fail "Thiếu GITHUB_USERNAME trong .env"
[[ -n "${GITHUB_REPO_URL:-}" ]] || fail "Thiếu GITHUB_REPO_URL trong .env"
[[ -d "$WORKSPACE_ROOT/.git" ]] || fail "Không thấy git repo tại $WORKSPACE_ROOT"

DATE_DAY="$(date +%d)"
DATE_MONTH="$(date +%m)"
DATE_YEAR="$(date +%Y)"
TIME_HM="$(date +%H:%M)"
BACKUP_LABEL="${BACKUP_LABEL_INPUT:-${BACKUP_NAME:-Backup}}"
REL_BACKUP_PATH="$BACKUP_LABEL/$DATE_DAY/$DATE_MONTH/$DATE_YEAR/$TIME_HM"

cat > "$TMP_ASKPASS" <<'EOF'
#!/bin/sh
case "$1" in
*Username*) echo "$GITHUB_USERNAME";;
*Password*) echo "$GITHUB_TOKEN";;
*) echo "";;
esac
EOF
chmod +x "$TMP_ASKPASS"
export GIT_ASKPASS="$TMP_ASKPASS"
export DISPLAY=1

if ! git -C "$WORKSPACE_ROOT" remote get-url origin >/dev/null 2>&1; then
  git -C "$WORKSPACE_ROOT" remote add origin "$GITHUB_REPO_URL"
else
  git -C "$WORKSPACE_ROOT" remote set-url origin "$GITHUB_REPO_URL"
fi

git -C "$WORKSPACE_ROOT" fetch origin main >/dev/null 2>&1 || true
git -C "$WORKSPACE_ROOT" worktree add --force "$WORKTREE_DIR" origin/main >/dev/null 2>&1 || \
  git -C "$WORKSPACE_ROOT" worktree add --force "$WORKTREE_DIR" -b main-temp >/dev/null 2>&1

mkdir -p "$SNAPSHOT_DIR"
rsync -a \
  --exclude='.git' \
  --exclude='.env' \
  --exclude='.openclaw' \
  --exclude='.gitignore' \
  --exclude='Backup' \
  --exclude='client_secret*.json' \
  --exclude='.env' \
  "$WORKSPACE_ROOT/" "$SNAPSHOT_DIR/"

mkdir -p "$WORKTREE_DIR/$REL_BACKUP_PATH"
rsync -a "$SNAPSHOT_DIR/" "$WORKTREE_DIR/$REL_BACKUP_PATH/"

cd "$WORKTREE_DIR"
git add "$REL_BACKUP_PATH"
git commit -m "backup $REL_BACKUP_PATH" >/dev/null 2>&1 || true
git push -u origin HEAD:main >/dev/null 2>&1 || fail "Push thất bại. Kiểm tra token hoặc remote."

echo "[OK] Backup thành công: $REL_BACKUP_PATH"
