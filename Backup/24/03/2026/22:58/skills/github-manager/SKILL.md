---
name: github-manager
description: Backup the entire /home/ubuntu/.openclaw/workspace into a date-stamped folder inside Backup/, push using token from a local .env via an isolated snapshot flow, then remove the local backup copy after success. Use for GitHub backup/push workflows, full workspace backups, token-based HTTPS auth, date-based backup folders, or clone guidance.
---

# GitHub Manager (Backup & Clone)

## Quy tắc bắt buộc
- Dùng token trong `.env` của skill, không hỏi lại.
- Khi backup: luôn hỏi người dùng tên thư mục backup muốn đặt là gì.
- Nếu người dùng không muốn đặt tên riêng, dùng mặc định `Backup`.
- Format backup: `TênBackup/dd/mm/yyyy/HH:MM` theo giờ Việt Nam.
- Backup lấy toàn bộ source trong `/home/ubuntu/.openclaw/workspace`.
- Chỉ loại trừ: `.git`, `.env`, `.openclaw`, `.gitignore`, và chính `Backup/`.
- Chỉ tạo dữ liệu backup bên trong `Backup/...`, không tạo thêm file/folder ở root repo ngoài ý người dùng.
- Không lệ thuộc trạng thái working tree hiện tại.
- Không dùng stash/restore/pull-rebase kiểu cũ.
- Tạo file tạm để push thì xóa ngay sau khi xong.
- Khi clone, mặc định ưu tiên thư mục đích là `/home/ubuntu/.openclaw/workspace/skills`.
- Chỉ clone sang chỗ khác nếu user yêu cầu rõ.

## File cấu hình
### `.env.example`
```bash
cp .env.example .env
```
Sau đó điền:
```env
GITHUB_TOKEN=
GITHUB_USERNAME=
GITHUB_REPO_URL=
BACKUP_NAME=Backup
```

## Backup
Chạy:
```bash
bash scripts/backup_push.sh [ten_thu_muc_backup]
```

## Clone
Chạy:
```bash
bash scripts/clone_sparse.sh <repo_url> <target_dir> [path_in_repo]
```
