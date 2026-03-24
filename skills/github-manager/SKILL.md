---
name: github-manager
description: Backup source code to GitHub with date-stamped folders, push using token from a local .env, and guide/perform selective clone (sparse checkout) when the user asks to clone a repo or a specific folder. Use for GitHub backup/push workflows, token-based HTTPS auth, date-based backups, or clone guidance.
---

# GitHub Manager (Backup & Clone)

## Quy tắc bắt buộc
- Dùng token trong `.env` của skill, **không hỏi lại**.
- Khi backup: **luôn hỏi người dùng tên thư mục backup muốn đặt là gì**.
- Nếu người dùng không muốn đặt tên riêng, dùng mặc định **`Backup/dd/mm/yyyy`** theo **giờ Việt Nam**.
- Tạo file tạm để push thì **xóa ngay** sau khi xong.
- Hướng dẫn bằng **tiếng Việt** rõ ràng.
- Trước khi push, script sẽ tự **pull --rebase** để giảm lỗi lệch commit.
- Nếu repo local đang có thay đổi chưa commit, script sẽ **tự stash tạm**, backup xong rồi **khôi phục lại stash**.
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
```
# GitHub token (dạng HTTPS token)
GITHUB_TOKEN=

# GitHub username
GITHUB_USERNAME=

# Link repo GitHub dạng HTTPS
GITHUB_REPO_URL=

# Đường dẫn thư mục muốn backup
URL_SOURCE_BACKUP=

# Tên thư mục backup mặc định
BACKUP_NAME=Backup
```

## Nhiệm vụ chính
### 1) Backup (lệnh “backup”)
- Hỏi người dùng: **muốn đặt tên backup là gì?**
- Nếu user không đặt, dùng `Backup`.
- Tạo thư mục theo cấu trúc: `TênBackup/dd/mm/yyyy` theo **giờ Việt Nam**.
- Nếu repo đang bẩn, tự stash tạm.
- Tự `pull --rebase`, rồi copy source, `git add`, `commit`, `push`.
- Sau khi push xong, tự khôi phục stash nếu có.
- Nếu lỗi, báo tiếng Việt ngắn gọn.

Dùng script:
```bash
bash scripts/backup_push.sh [ten_thu_muc_backup]
```

### 2) Clone (lệnh “clone <link>”)
- Nếu user nói **clone + link**, mặc định hiểu là clone về: `/home/ubuntu/.openclaw/workspace/skills`
- Hỏi/gợi ý user: **mặc định Con Lợn sẽ clone về `/home/ubuntu/.openclaw/workspace/skills`, nếu muốn đổi chỗ thì nói rõ đường dẫn**.
- Nếu user không nói gì thêm, clone vào thư mục mặc định đó.
- Nếu user muốn chỉ lấy 1 folder trong repo, dùng sparse checkout.
- Nếu không, clone full repo.

Dùng script:
```bash
bash scripts/clone_sparse.sh <repo_url> <target_dir> [path_in_repo]
```

## Khi user yêu cầu
- “backup” → hỏi tên thư mục backup, rồi chạy backup + push.
- “clone <link>” → gợi ý mặc định clone vào `/home/ubuntu/.openclaw/workspace/skills`; chỉ hỏi thêm nếu user muốn đổi.
- Nếu user muốn chỉ lấy 1 folder → dùng sparse checkout.

## Lưu ý an toàn
- Không ghi token vào file khác ngoài `.env` trong thư mục skill.
- Không commit `.env`.
- Nếu `pull --rebase` báo conflict, dừng và báo user xử lý conflict.
- Nếu `stash pop` lỗi, báo user kiểm tra `git stash list`.
