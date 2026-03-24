#!/usr/bin/env bash
set -euo pipefail

export TZ="Asia/Ho_Chi_Minh"

WORKSPACE_ROOT="/home/ubuntu/.openclaw/workspace"
SKILL_DIR="$WORKSPACE_ROOT/skills/github-manager"
ENV_FILE="${ENV_FILE:-$SKILL_DIR/.env}"
BACKUP_LABEL_INPUT="${1:-}"
TMP_ASKPASS="/tmp/git-askpass.sh"

fail() {
  echo "[Lỗi] $1" >&2
  exit 1
}

cleanup() {
  rm -f "$TMP_ASKPASS"
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

REPO_PATH="${URL_SOURCE_BACKUP:-$WORKSPACE_ROOT}"
[[ -d "$REPO_PATH" ]] || fail "URL_SOURCE_BACKUP không tồn tại: $REPO_PATH"
[[ -d "$REPO_PATH/.git" ]] || fail "Thư mục source chưa phải git repo: $REPO_PATH"

DATE_DAY="$(date +%d)"
DATE_MONTH="$(date +%m)"
DATE_YEAR="$(date +%Y)"
TIME_HM="$(date +%H:%M)"
BACKUP_LABEL="${BACKUP_LABEL_INPUT:-${BACKUP_NAME:-Backup}}"
DEST_PATH="$WORKSPACE_ROOT/$BACKUP_LABEL/$DATE_DAY/$DATE_MONTH/$DATE_YEAR/$TIME_HM"

mkdir -p "$DEST_PATH"

# Copy toàn bộ source thật, loại các thứ không muốn lôi vào backup
rsync -a \
  --exclude='.git' \
  --exclude='.env' \
  --exclude='.openclaw' \
  --exclude='.gitignore' \
  --exclude="$BACKUP_LABEL" \
  "$WORKSPACE_ROOT/" "$DEST_PATH/"

cd "$REPO_PATH"

CURRENT_BRANCH="$(git branch --show-current || true)"
if [[ -z "$CURRENT_BRANCH" ]]; then
  CURRENT_BRANCH="main"
fi
if [[ "$CURRENT_BRANCH" != "main" ]]; then
  git branch -M main >/dev/null 2>&1 || true
fi

if ! git remote get-url origin >/dev/null 2>&1; then
  git remote add origin "$GITHUB_REPO_URL"
else
  git remote set-url origin "$GITHUB_REPO_URL"
fi

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
  git pull --rebase origin main >/dev/null 2>&1 || fail "Pull --rebase thất bại. Kiểm tra conflict rồi chạy lại."
fi

git add "$BACKUP_LABEL/$DATE_DAY/$DATE_MONTH/$DATE_YEAR/$TIME_HM"
git commit -m "backup $BACKUP_LABEL $DATE_DAY/$DATE_MONTH/$DATE_YEAR $TIME_HM" >/dev/null 2>&1 || true
git push -u origin main >/dev/null 2>&1 || fail "Push thất bại. Kiểm tra token, remote hoặc conflict."

echo "[OK] Backup thành công: $BACKUP_LABEL/$DATE_DAY/$DATE_MONTH/$DATE_YEAR/$TIME_HM"
