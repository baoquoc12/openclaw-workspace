---
name: github-manager
description: Backup the entire /home/ubuntu/.openclaw/workspace into a date-stamped folder inside the repo, push using token from a local .env, and guide/perform clone workflows for skills or other repo content. Use for GitHub backup/push workflows, full workspace backups, token-based HTTPS auth, date-based backup folders, or clone guidance.
---

# GitHub Manager (Backup & Clone)

## Quy tắc bắt buộc
- Dùng token trong `.env` của skill, **không hỏi lại**.
- Khi backup: **luôn hỏi người dùng tên thư mục backup muốn đặt là gì**.
- Nếu người dùng không muốn đặt tên riêng, dùng mặc định **`Backup`**.
- Format backup phải là: `TênBackup/dd/mm/yyyy/HH:MM` theo **giờ Việt Nam**.
- Backup phải lấy **toàn bộ source trong `/home/ubuntu/.openclaw/workspace`**.
- Chỉ loại trừ: `.git`, `.env`, `.openclaw`, `.gitignore`, và chính thư mục backup đang tạo.
- Tạo file tạm để push thì **xóa ngay** sau khi xong.
- Hướng dẫn bằng **tiếng Việt** rõ ràng.
- Trước khi push, script sẽ tự **pull --rebase** để giảm lỗi lệch commit.
- Cố định dùng nhánh **main**.
- Khi clone, mặc định gợi ý và ưu tiên thư mục đích là: `/home/ubuntu/.openclaw/workspace/skills`
- Chỉ clone sang chỗ khác nếu user yêu cầu rõ.

## File cấu hình
### 1) `.env.example`
File này **được push lên GitHub** để người dùng nhìn vào và tự điền.

Cách dùng sau khi tải về:
```bash
cp .env.example .env
```
Sau đó mở `.env` và điền dữ liệu thật.

### 2) `.env`
- Dùng ở local.
- **Không commit** lên GitHub.
- Chứa secret thật.

## Cấu hình mẫu
Ví dụ `.env.example`:
```env
GITHUB_TOKEN=
GITHUB_USERNAME=
GITHUB_REPO_URL=
URL_SOURCE_BACKUP=/home/ubuntu/.openclaw/workspace
BACKUP_NAME=Backup
```

## Nhiệm vụ chính
### 1) Backup (lệnh “backup”)
- Hỏi người dùng: **muốn đặt tên backup là gì?**
- Nếu user không đặt, dùng `Backup`.
- Tạo thư mục theo cấu trúc: `TênBackup/dd/mm/yyyy/HH:MM` theo **giờ Việt Nam**.
- Copy **toàn bộ source trong `/home/ubuntu/.openclaw/workspace`** vào thư mục đó.
- Loại trừ: `.git`, `.env`, `.openclaw`, `.gitignore`, và chính thư mục backup đang tạo.
- Tự `pull --rebase`, rồi `git add`, `commit`, `push`.
- Nếu lỗi, báo tiếng Việt ngắn gọn.

Dùng script:
```bash
bash scripts/backup_push.sh [ten_thu_muc_backup]
```

### 2) Clone (lệnh “clone <link>”)
- Nếu user nói **clone + link**, mặc định hiểu là clone về: `/home/ubuntu/.openclaw/workspace/skills`
- Chỉ đổi chỗ clone nếu user yêu cầu rõ đường dẫn khác.
- Nếu user muốn chỉ lấy 1 folder trong repo, dùng sparse checkout.
- Nếu không, clone full repo.

Dùng script:
```bash
bash scripts/clone_sparse.sh <repo_url> <target_dir> [path_in_repo]
```

## Khi user yêu cầu
- “backup” → hỏi tên thư mục backup, rồi chạy backup + push.
- “clone <link>” → mặc định clone vào `/home/ubuntu/.openclaw/workspace/skills`.
- Nếu user muốn chỉ lấy 1 folder → dùng sparse checkout.

## Lưu ý an toàn
- Không ghi token vào file khác ngoài `.env` trong thư mục skill.
- Không commit `.env`.
