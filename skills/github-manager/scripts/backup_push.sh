#!/usr/bin/env bash
set -euo pipefail

export TZ="Asia/Ho_Chi_Minh"

SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_FILE="${ENV_FILE:-$SKILL_DIR/.env}"
BACKUP_LABEL_INPUT="${1:-}"
STASH_NAME="github-manager-auto-stash-$(date +%s)"
DID_STASH=0

fail() {
  echo "[Lỗi] $1" >&2
  exit 1
}

cleanup() {
  rm -f "${TMP_ASKPASS:-/tmp/git-askpass.sh}"
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

REPO_PATH="${URL_SOURCE_BACKUP:-}"
[[ -n "$REPO_PATH" ]] || fail "Thiếu URL_SOURCE_BACKUP trong .env"
[[ -d "$REPO_PATH" ]] || fail "URL_SOURCE_BACKUP không tồn tại: $REPO_PATH"
[[ -d "$REPO_PATH/.git" ]] || fail "Thư mục source chưa phải git repo: $REPO_PATH"

cd "$REPO_PATH"

# Nếu repo bẩn, stash tạm để pull không lỗi
if [[ -n "$(git status --porcelain)" ]]; then
  git stash push -u -m "$STASH_NAME" >/dev/null 2>&1 || fail "Không stash tạm được trước khi backup"
  DID_STASH=1
fi

DATE_DAY="$(date +%d)"
DATE_MONTH="$(date +%m)"
DATE_YEAR="$(date +%Y)"
DEFAULT_LABEL="Backup"
BACKUP_LABEL="${BACKUP_LABEL_INPUT:-${BACKUP_NAME:-$DEFAULT_LABEL}}"
DEST_PATH="$REPO_PATH/$BACKUP_LABEL/$DATE_DAY/$DATE_MONTH/$DATE_YEAR"

CURRENT_BRANCH="$(git branch --show-current || true)"
if [[ -z "$CURRENT_BRANCH" ]]; then
  CURRENT_BRANCH="main"
fi
if [[ "$CURRENT_BRANCH" != "main" ]]; then
  git branch -M main
fi

if ! git remote get-url origin >/dev/null 2>&1; then
  git remote add origin "$GITHUB_REPO_URL"
else
  git remote set-url origin "$GITHUB_REPO_URL"
fi

TMP_ASKPASS="/tmp/git-askpass.sh"
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

if git ls-remote --heads origin main >/dev/null 2>&1; then
  git pull --rebase origin main || fail "Pull --rebase thất bại. Kiểm tra conflict rồi chạy lại."
fi

mkdir -p "$DEST_PATH"

rsync -a --delete \
  --exclude='.git' \
  --exclude='.openclaw' \
  --exclude='.env' \
  --exclude="$BACKUP_LABEL" \
  "$REPO_PATH/" "$DEST_PATH/"

git add "$BACKUP_LABEL/$DATE_DAY/$DATE_MONTH/$DATE_YEAR"
git commit -m "backup $BACKUP_LABEL $DATE_DAY/$DATE_MONTH/$DATE_YEAR" >/dev/null 2>&1 || true
git push -u origin main || fail "Push thất bại. Kiểm tra token, remote hoặc conflict."

if [[ "$DID_STASH" -eq 1 ]]; then
  if git stash list | grep -q "$STASH_NAME"; then
    git stash pop >/dev/null 2>&1 || fail "Backup đã push xong nhưng khôi phục stash thất bại. Hãy kiểm tra git stash list"
  fi
fi

echo "[OK] Backup thành công: $BACKUP_LABEL/$DATE_DAY/$DATE_MONTH/$DATE_YEAR"
