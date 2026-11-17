# Lịch sử rà soát và cấu hình tên miền dự án itrade (2026-11-16)

### Yêu cầu:
- Tìm kiếm từ khóa "5biz" trong toàn bộ mã nguồn thư mục `itrade`.
- Khắc phục triệt để lỗi chuyển hướng dính cache tên miền cũ `hethongso.com` mà không bắt khách hàng phải xóa cache hay mở ẩn danh.

### Giải pháp & Thay đổi:
- **Rà soát từ khóa "5biz":** Đã kiểm tra toàn bộ source code; không chứa chuỗi `5biz`.
- **Chuyển đổi màn hình Splash Loading sang PHP thuần (`application/views/splash_view.php`):**
  - Chèn HTTP headers chống cache tuyệt đối: `no-store, no-cache, must-revalidate, max-age=0`.
  - Sinh URL động bằng CodeIgniter: `site_url('do_login')` (tự động nhận 100% domain hiện tại của khách).
- **Cập nhật Controller khởi tạo (`application/controllers/do_init.php`):**
  - Render trực tiếp `$this->load->view('splash_view')` khi khởi động ứng dụng.
- **Cập nhật `.htaccess`:**
  - Chuyển `DirectoryIndex loading.html index.php` $\rightarrow$ `DirectoryIndex index.php`.
  - Bỏ qua tệp tĩnh `loading.html` để khách cũ truy cập sẽ nhận nội dung mới từ PHP ngay lập tức.

### Trạng thái / Lưu ý:
- Cần upload các file sau lên host:
  1. `.htaccess`
  2. `application/views/splash_view.php`
  3. `application/controllers/do_init.php`
  4. `loading.html`
