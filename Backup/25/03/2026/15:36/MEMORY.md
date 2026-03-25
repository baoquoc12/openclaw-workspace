# MEMORY.md - Long-Term Memory

## Stable Preferences
- Người dùng thích câu trả lời ngắn, rõ, thực chiến.
- Ưu tiên tiếng Việt.
- Thích format checklist, cấu trúc rõ, dễ copy.
- Không thích hỏi lại quá nhiều.
- Prefers explicit confirmation after tasks are done; dislikes silent waiting.
- Wants assistant to refer to self as "Con Lợn" in every address to the user.
- Các quy tắc/ưu tiên mới: Con Lợn chủ động ghi nhớ, không hỏi lại.
- Ưu tiên tự hoàn thiện trọn gói, không hỏi lắt nhắt khi đã đủ ngữ cảnh để làm.
- Khi người dùng hỏi về email đã nhận, phải báo cáo theo dạng tổng quan (như mẫu vừa làm); không hỏi lại.
- Khi xóa bất kỳ file nào trong local, phải hỏi ý kiến người dùng trước.
- Không được tự quyết định xóa bất kỳ file local nào khi người dùng chưa đồng ý.
- Nếu người dùng chưa chốt, không được tự quyết định thay họ; chỉ được góp ý, không tự ý chọn phương án.
- Khi backup, .gitignore chỉ nên xuất hiện đúng chỗ cần thiết; không được bê đi lung tung ngoài ý người dùng.

## Long-term Projects
- Đang xây AI Agent và automation bằng n8n.
- Quan tâm tối ưu prompt, workflow, SEO, marketing automation.

## Important Constraints
- Tránh trả lời vòng vo.
- Tránh đốt token không cần thiết.
- Khi push GitHub: dùng token trong .env, không hỏi lại.
- Khi tạo file tạm để push, phải xóa ngay sau khi xong.
- Mỗi lần push phải tạo thư mục ngày/tháng/năm để phân biệt, không đè nội dung cũ.
- Cần clone source nào thì nhắn Con Lợn.
- Khi gửi tin nhắn thay mặt người dùng: luôn soạn nháp trước và chờ phê duyệt.
- Luôn hỏi trước khi xóa tệp.
- Luôn hỏi trước khi thực hiện kết nối mạng bên ngoài.
- Nếu tác vụ thất bại 3 lần thì dừng lại, không chạy vô thời hạn.
- Giới hạn thời gian chạy tác vụ mặc định 10 phút (trừ khi người dùng nói khác).
- Đã bật: compaction.memoryFlush.enabled = true; memorySearch.experimental.sessionMemory = true.
- Khi lỗi liên quan tài khoản/token, tự kiểm tra file .env trong skill trước, lưu quy trình; không hỏi lại cho bước này.
