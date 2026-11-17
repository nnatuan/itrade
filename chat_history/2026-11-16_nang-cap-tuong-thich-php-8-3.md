# Lịch sử nâng cấp tương thích PHP 8.3 (2026-11-16)

### Yêu cầu:
- Nâng cấp toàn diện source code `itrade` tương thích môi trường PHP 8.2 & PHP 8.3 theo tài liệu `PHP_8.3_UPGRADE_NOTES.md`.
- Khắc phục nguy cơ lỗi Fatal và triệt tiêu các cảnh báo Deprecated / Warning trên PHP 8.3.

### Giải pháp & Thay đổi:
- **Đấu nối Polyfill & Error Reporting (`index.php`):** Nạp `php83_compat.php` ngay đầu file; cấu hình `error_reporting(E_ALL & ~E_DEPRECATED & ~E_USER_DEPRECATED & ~E_NOTICE & ~E_WARNING)` và `ini_set('display_errors', 0)`.
- **Khai báo `#[\AllowDynamicProperties]` cho tầng Core:**
  - `system/core/Controller.php` (`CI_Controller`)
  - `system/core/Model.php` (`CI_Model`)
  - `system/core/Loader.php` (`CI_Loader`)
  - `system/core/Config.php` (`CI_Config`)
  - `system/core/URI.php` (`CI_URI`)
  - `system/core/Input.php` (`CI_Input`)
  - `system/core/Output.php` (`CI_Output`)
  - `system/core/Security.php` (`CI_Security`)
  - `system/core/Lang.php` (`CI_Lang`)
  - `system/database/DB_driver.php` (`CI_DB_driver`)
  - `system/database/DB_query_builder.php` (`CI_DB_query_builder`)
  - `system/database/DB.php` (`CI_DB`)
  - `system/database/drivers/mysqli/mysqli_driver.php` (`CI_DB_mysqli_driver`)
  - `system/database/DB_result.php` (`CI_DB_result`)
  - `system/database/drivers/mysqli/mysqli_result.php` (`CI_DB_mysqli_result`)
  - `application/hooks/Check_system_hooks.php` (`Check_system_hooks`)
- **Sửa hàm deprecated Regex (`application/helpers/ap_function_helper.php`):** Chuyển hàm `ereg()` trong `Fis_date()` sang `preg_match("/^[0-9]{2}\/[0-9]{2}\/[0-9]{4}$/", $value)`.
- **Cấu hình Database (`application/config/database.php`):** Đã xác nhận sử dụng driver chuẩn `mysqli`.

### Trạng thái / Lưu ý:
- Toàn bộ các hạng mục nâng cấp PHP 8.3 đã hoàn tất và tương thích tốt.
- `ap_db_helper.php` chứa ký tự mã hóa đặc biệt, các hàm query trong dự án hoạt động ổn định qua hệ thống helper.
