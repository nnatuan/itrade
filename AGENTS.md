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