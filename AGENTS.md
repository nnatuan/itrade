# Workspace Rules

## Quy tắc bắt buộc
1. **Tuyệt đối không dùng terminal / command line:** Không chạy bất kỳ lệnh `cmd`, `powershell`, `bash`, `git`, `php`, `npm` hay bất kỳ câu lệnh hệ thống nào thông qua công cụ terminal (`run_command`).
2. **Đọc và thao tác file:** Sử dụng các công cụ workspace (`view_file`, `list_dir`, `grep_search`, `replace_file_content`, `write_to_file`,...) để xem, tìm kiếm và chỉnh sửa file.
3. **Tuyệt đối không đọc thư mục `.git`:** 
   - Không được đọc, duyệt hoặc phân tích bất kỳ file nào nằm trong thư mục `.git` (bao gồm `.git/config`, `.git/HEAD`, `.git/index`,...).
   - Bỏ qua toàn bộ các thư mục ẩn bắt đầu bằng dấu chấm (`.git`, `.vscode`, `.idea`).
4. **Xử lý liên kết thư mục (mklink / junction):** 
   - Coi thư mục hiện tại đang mở là thư mục gốc (root) duy nhất của workspace.
   - Không giải mã (resolve) ngược đường dẫn thực tế hay truy vết ra các thư mục cha bên ngoài workspace.
   - Các Subagent (như Codebase Researcher) chỉ được tìm kiếm trực tiếp trong các file mã nguồn của dự án (PHP, JS, CSS, HTML, SQL).
5. **Quy tắc cấu trúc Database & Migration:**
   - Tuyệt đối không viết code kiểm tra sự tồn tại của bảng hoặc cột (`table_exists`, `field_exists`, `SHOW TABLES`, `SHOW COLUMNS`...) lồng bên trong các hàm nghiệp vụ, controller hay model trước khi thực thi `INSERT`/`UPDATE`.
   - Nếu cần tạo bảng mới, bổ sung trường hoặc thay đổi cấu trúc dữ liệu: Luôn xuất mã SQL thuần (`CREATE TABLE`, `ALTER TABLE`...) trực tiếp trong phản hồi để người dùng chủ động chạy query thủ công, giữ code backend gọn gàng và tối ưu hiệu năng.
6. **Ghi nhận lịch sử xử lý theo phiên (Context Handover):**
   - Mỗi phiên trò chuyện (conversation) mới sẽ tạo một file Markdown riêng biệt trong thư mục `chat_history/` tại thư mục gốc của workspace (tự động tạo thư mục nếu chưa có).
   - **Quy tắc đặt tên file:** `YYYY-MM-DD_ten-chu-de-ngan-gon.md` (ví dụ: `2026-11-16_chuyen-hardcode-sang-csdl.md`).
   - **Nguyên tắc viết ngắn gọn (Cực kỳ quan trọng):**
     - Chỉ tóm tắt **ý chính bằng các gạch đầu dòng súc tích**, tuyệt đối không viết dài dòng.
     - **Không chép mã nguồn dài hoặc toàn bộ câu lệnh `INSERT` / `UPDATE` dữ liệu** vào file lịch sử (nếu có thay đổi cấu trúc bảng, chỉ ghi ngắn gọn tên bảng/cột đã thêm hoặc tham chiếu tới file `.sql` như `csdl.sql`).
   - Mỗi lượt cập nhật trong file chỉ gồm 3 mục ngắn:
     - **Yêu cầu:** Mục tiêu cần làm.
     - **Giải pháp & Thay đổi:** Danh sách file đã sửa và ý chính cách xử lý.
     - **Trạng thái / Lưu ý:** Việc đã xong hoặc việc cần làm tiếp khi chuyển máy.