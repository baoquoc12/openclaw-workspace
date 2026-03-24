---
name: github-manager
description: Backup source code to GitHub with date-stamped folders, push using token from a local .env, and guide/perform selective clone (sparse checkout) when the user asks to clone a repo or a specific folder. Use for GitHub backup/push workflows, token-based HTTPS auth, date-based backups, or clone guidance.
---

# GitHub Manager (Backup & Clone)

## Quy tắc bắt buộc
- Dùng token trong `.env` của skill, **không hỏi lại**.
- Khi backup: **hỏi người dùng tên thư mục backup**. Nếu người dùng không muốn đặt, dùng mặc định **`Backup/dd/mm/yyyy`**.
- Tạo file tạm để push thì **xóa ngay** sau khi xong.
- Hướng dẫn bằng **tiếng Việt** rõ ràng.

## Cấu hình `.env` (đặt trong thư mục skill)
Đường dẫn: `skills/github-manager/.env`

Ví dụ:
```
GITHUB_TOKEN=ghp_xxx
GITHUB_USERNAME=baoquoc12
GITHUB_REPO_URL=https://github.com/baoquoc12/openclaw-workspace.git
URL_SOURCE_BACKUP=/home/ubuntu/.openclaw/workspace
BACKUP_NAME=Backup
```

- `URL_SOURCE_BACKUP`: đường dẫn thư mục muốn backup.
- `BACKUP_NAME`: tên thư mục gốc chứa backup (mặc định `Backup`).

## Nhiệm vụ chính
### 1) Backup (lệnh “backup”)
- Hỏi tên thư mục backup (nếu user muốn đặt). Nếu không, dùng `Backup`.
- Tạo thư mục ngày/tháng/năm dưới `BACKUP_NAME`.
- Copy toàn bộ source (trừ `.env`, `.openclaw`, `.git`, và `BACKUP_NAME`).
- `git add` thư mục backup, commit, push.

Dùng script:
```
bash scripts/backup_push.sh
```

### 2) Clone (lệnh “clone <link>”)
- Nếu user nói **clone + link**, hỏi họ muốn đặt **đường dẫn thư mục đích**.
- Sau khi có đường dẫn, dùng sparse checkout để lấy 1 thư mục (nếu user chỉ định), hoặc clone full nếu user muốn.

Dùng script:
```
bash scripts/clone_sparse.sh <repo_url> <target_dir> [path_in_repo]
```

## Khi user yêu cầu
- “backup” → hỏi tên thư mục backup, rồi chạy backup + push.
- “clone <link>” → hỏi đường dẫn đích, rồi clone.
- Nếu user muốn chỉ lấy 1 folder → dùng sparse checkout.

## Lưu ý an toàn
- Không ghi token vào file khác ngoài `.env` trong thư mục skill.
- Không commit `.env`.
