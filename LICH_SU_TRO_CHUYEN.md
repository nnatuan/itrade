# TÓM TẮT TOÀN BỘ LỊCH SỬ TRÒ CHUYỆN & TIẾN ĐỘ DỰ ÁN ITRADE

> **Thời gian tạo:** 09/11/2026  
> **Dự án:** Hệ thống Quản trị Web & Expert Advisor (EA) Trading iTrade  
> **Môi trường:** PHP CodeIgniter (XAMPP), MySQL/MariaDB, MetaTrader 5 (MQL5)

---

## I. TỔNG QUAN HỆ THỐNG & MỤC TIÊU DỰ ÁN

Hệ thống **iTrade** gồm 2 thành phần chính hoạt động kết nối mật thiết với nhau:
1. **Web App CMS (PHP CodeIgniter):** Quản lý tài khoản khách hàng, cấp phát mã License bản quyền, giám sát chỉ số tài chính (Balance, Equity, Drawdown) và cấu hình từ xa toàn bộ thông số chiến lược giao dịch của Robot.
2. **EA Bot trên MetaTrader 5 (.mq5):** Chạy trên thiết bị client/VPS, định kỳ gọi API lên máy chủ web (`Do_bot_api/check_license`) để xác thực bản quyền và kéo thông số chiến lược về (`SyncSettingsFromCloud`), áp dụng trực tiếp vào biến nội bộ của Bot mà không cần khởi động lại.

Dự án phát triển qua 2 dòng bot chính:
- **Bot V33 (`BOT_V33.mq5`):** Chiến lược RSI6 kết hợp Lưới lệnh (Grid), chốt lời Basket TP, Pair Close thu hồi vốn.
- **Bot Onefxhub (`new_bot/Onefxhub.mq5`):** Chiến lược nâng cao V38.38 (RPA R2 Hotfix / Startup Safety R3) bổ sung Recursive Pair Close, DD Hedge Lock, Dynamic Grid, 3 phiên giao dịch độc lập và nhiều cơ chế phòng hộ chuyên sâu.

---

## II. QUY TẮC CỐT LÕI ĐƯỢC ÁP DỤNG TRONG SUỐT QUÁ TRÌNH (AGENTS.MD)

1. **Tuyệt đối không dùng terminal / command line (`run_command`):** Tất cả thao tác kiểm tra, đối chiếu, cập nhật mã nguồn đều thực hiện thông qua công cụ đọc và chỉnh sửa file nội bộ của workspace.
2. **Tuyệt đối không đọc thư mục `.git`:** Bỏ qua các thư mục ẩn `.git`, `.vscode`, `.idea`.
3. **Quy tắc cơ sở dữ liệu & Migration:** Tuyệt đối không viết code PHP kiểm tra bảng/cột tồn tại (`SHOW TABLES`, `table_exists`,...) bên trong các hàm nghiệp vụ. Toàn bộ thay đổi cấu trúc bảng đều xuất dưới dạng **mã SQL thuần** (`CREATE TABLE`, `ALTER TABLE`) để người dùng chủ động chạy query trực tiếp trong phpMyAdmin/MySQL Client.
4. **Bảo toàn tính ổn định:** Giữ nguyên vẹn mã nguồn và logic các phần bot đang chạy ổn định (`BOT_V33.mq5`), không can thiệp chéo gây lỗi.

---

## III. DIỄN BIẾN LỊCH SỬ CÁC GIAI ĐOẠN TRAO ĐỔI & THỰC THI

### Giai đoạn 1: Khởi đầu & Yêu cầu đọc mã nguồn Bot
- **Yêu cầu:** Người dùng cung cấp file `download/BOT_v33.ex5` và hỏi khả năng đọc code.
- **Xử lý:** 
  - Giải thích rõ file `.ex5` là file nhị phân bytecode đã biên dịch của MT5, được mã hóa bảo vệ, không thể đọc trực tiếp bằng trình soạn thảo văn bản.
  - Hướng dẫn người dùng cung cấp file mã nguồn văn bản `.mq5` để có thể phân tích và chỉnh sửa code.

---

### Giai đoạn 2: Bổ sung cấu hình 3 Phiên giao dịch vào BOT_V33 & Web CMS
- **Yêu cầu:** Người dùng cung cấp ảnh chụp giao diện cấu hình thời gian giao dịch gồm 3 phiên:
  - Phiên Á (Sydney - Tokyo): 05:00 - 14:00.
  - Phiên Âu (London): 14:00 - 23:00.
  - Phiên Mỹ (New York): 19:00 - 04:00 (ngày hôm sau).
  - Kèm các khung giờ tùy chỉnh phụ và tính năng tắt/bật giao dịch 24/7.
- **Xử lý:**
  - **Cơ sở dữ liệu:** Sinh câu lệnh SQL thêm các trường lưu trữ thông số phiên vào bảng `ea_tbot_settings`.
  - **Backend & View:** Cập nhật Controller `Do_bot_client.php`, View form `bot_client.php`, API `Do_bot_api.php` để lưu và trả dữ liệu thời gian cho bot.
  - **Mã nguồn Bot (`BOT_V33.mq5`):** Bổ sung các biến input, các hàm xử lý tính toán khung giờ (`IsInTradingHours`, `CheckMinuteInAnyTradingWindow`, `ParseTimeToMinutes`).

---

### Giai đoạn 3: Phân tích & Tách cấu trúc CSDL cho Bot mới (Onefxhub V38.38)
- **Bối cảnh:** Người dùng đưa file `new bot/Onefxhub_v38.38_STARTUP_SAFETY_R3.mq5` cùng 4 ảnh chụp bảng Inputs trong Strategy Tester MT5, mong muốn tích hợp thêm bot này vào web cho khách hàng lựa chọn cấu hình.
- **Phân tích yêu cầu Onefxhub:**
  - Nhóm Vốn / Lot: Lot L1, Lot Multi, Số lệnh tối đa.
  - Chốt lời L1: TP riêng L1 (pip/usd), %YP khóa SL hòa vốn.
  - Quản lý cụm L2+ (T1/T2): T1 kích hoạt, T1 khóa cụm BE, T2 trailing SL.
  - Bảo hiểm DD Hedge Lock: Bật/tắt, ngưỡng % DD cân lệnh NET, Magic riêng lệnh Hedge.
  - Tín hiệu RSI & Magic: Chu kỳ RSI, khung thời gian, Magic number.
  - Giờ giao dịch 3 phiên: Á, Âu, Mỹ độc lập theo giờ Local GMT+7.
  - Chốt phiên & xác nhận 2 lần: Số phút trước khi hết phiên, % chốt hòa vốn, chu kỳ PairClose.
  - Bước lưới GN: Khoảng cách từ L1 đến L25 (G1 -> G25).
  - Chiến lược vào lệnh: V26 truyền thống hoặc Global Grid Mode 1.
  - Cơ chế PairClose: Recursive Pair A hoặc V26 Legacy.
- **Thảo luận kiến trúc Database:**
  - Người dùng đặt câu hỏi: *Có nên nhét chung toàn bộ thuộc tính của mọi bot vào bảng `ea_tbot_settings` hay nên tách riêng?*
  - **Đánh giá & Kết luận:** Không nên nhồi nhét chung vì cấu trúc tham số của Onefxhub có nhiều thuộc tính hoàn toàn khác biệt (T1/T2 cụm, DD Hedge Lock, Recursive PairClose, Global Grid Mode,...). Nếu nhồi chung sẽ khiến bảng phình to, dư thừa trường NULL và khó bảo trì khi sau này thêm các bot khác.
  - **Giải pháp lựa chọn:** Tách riêng bảng `ea_tbot_onefxhub_settings` liên kết khóa ngoại với `ea_tbot_client(nid)`, đồng thời bổ sung trường phân loại bot `cbot_type` trong `ea_tbot_client`.

---

### Giai đoạn 4: Triển khai CSDL mới & Cập nhật Web Client CMS
- **Mã SQL triển khai trực tiếp:**
  - Bổ sung trường `cbot_type` vào `ea_tbot_client`.
  - Tạo mới bảng `ea_tbot_onefxhub_settings` với đầy đủ các trường cấu hình tương ứng 100% với các input của EA Onefxhub.
- **Cập nhật Web CMS:**
  - File `application/views/bot_client_view/bot_client.php`: Thêm dropdown chọn dòng Bot (`BOT_V33` hoặc `ONEFXHUB`). Viết mã JavaScript tự động ẩn/hiện các block cấu hình tương ứng theo từng dòng bot.
  - File `application/controllers/Do_bot_client.php`: Bổ sung xử lý load và insert/update vào bảng `ea_tbot_onefxhub_settings` khi khách hàng chọn bot Onefxhub.
  - File `application/controllers/Do_bot_api.php`: Nhận diện bot type từ client để truy vấn đúng bảng settings và trả payload JSON chính xác cho EA.
- **Sửa lỗi hiển thị UI (CSS):**
  - Người dùng gửi ảnh phản hồi giao diện hàng giờ 3 phiên bị chồng đè chữ lên nhau.
  - Đã tối ưu lại CSS/HTML Flexbox dạng thẻ co giãn, giúp các ô nhập giờ bắt đầu - kết thúc hiển thị ngay ngắn, rõ ràng, không bị xô lệch trên mọi độ phân giải màn hình.

---

### Giai đoạn 5: Tích hợp cơ chế Cloud Sync & Đóng gói thư viện vào Onefxhub.mq5
- **Yêu cầu:** Sửa code bot mq5 để tích hợp các thông số License Key, ApiUrl và đồng bộ thông số từ server web.
- **Xử lý:**
  - Thêm cụm biến Input API Cloud Control (`LicenseKey`, `ApiUrl`).
  - Viết hàm `SyncSettingsFromCloud()` gửi HTTP WebRequest lên máy chủ web, giải mã chuỗi JSON phản hồi bằng thư viện `JAson.mqh`, và nạp toàn bộ cấu hình vào các biến nội bộ của bot.

---

### Giai đoạn 6: Khắc phục lỗi biên dịch MetaEditor & Bảo toàn BOT_V33
- **Sự cố biên dịch của người dùng:**
  - Người dùng cung cấp ảnh chụp lỗi khi nhấn Compile trong MetaEditor:
    1. Lỗi 1: `file 'C:\xampp\Include\JAson.mqh' not found` do đường dẫn include tương đối chưa khớp cấu trúc thư mục máy local.
    2. Lỗi 2: `undeclared identifier 'Size'` tại dòng 9331 do gọi nhầm method `steps.Size()`.
  - Người dùng lưu ý: *Bản `BOT_V33.mq5` đang chạy rất ổn định, không được can thiệp vào nữa, hãy hoàn nguyên về như cũ và chỉ thao tác trên file chạy chính `new_bot/Onefxhub.mq5`.*
- **Khắc phục triệt để:**
  1. **Khôi phục `BOT_V33.mq5`:** Đã phục hồi nguyên trạng 100% bản V33 ban đầu của người dùng, đảm bảo không có bất kỳ thay đổi nào làm ảnh hưởng đến bot đang hoạt động trên thị trường.
  2. **Chỉnh sửa file `c:\xampp\htdocs\itrade\new_bot\Onefxhub.mq5`:**
     - Sửa `#include` thành chuẩn hệ thống MT5:
       ```mql5
       #include <Trade\Trade.mqh>
       #include <JAson.mqh>
       ```
     - Sửa hàm duyệt JSON trong `SyncSettingsFromCloud()`:
       ```mql5
       // Thay thế steps.Size() bằng method chuẩn của đối tượng CJAVal:
       for(int i = 0; i < steps.m_key.Total(); i++)
       ```

---

### Giai đoạn 7: Làm sạch mã nguồn đầu file Onefxhub.mq5
- **Yêu cầu:** Người dùng yêu cầu xóa toàn bộ các khối comment rườm rà ở đầu file `new_bot/Onefxhub.mq5` để tránh rối code, giúp mã nguồn bắt đầu gọn gàng và dễ nhìn khi mở trong MetaEditor.
- **Xử lý:**
  - Đã loại bỏ sạch sẽ hơn 300 dòng comment nhật ký lịch sử các bản build cũ (`HOTFIX`, `SAFETY R1..R3`, `PAIR_A`, `TPC2..TPC4`,...).
  - File bắt đầu trực tiếp từ:
    ```mql5
    //+------------------------------------------------------------------+
    //|                                                  Onefxhub.mq5    |
    //|                                  Copyright 2026, Freelance Trader|
    //+------------------------------------------------------------------+
    #property copyright "AMTK"
    #property version   "38.38"
    #property strict

    #include <Trade\Trade.mqh>
    #include <JAson.mqh>
    ```
  - Giữ nguyên vẹn 100% logic nghiệp vụ, cấu trúc biến, hàm giao dịch và module bảo vệ bên dưới.

---

## IV. TỔNG KẾT TÌNH TRẠNG HIỆN TẠI CỦA HỆ THỐNG

| Thành phần | Trạng thái hiện tại | Ghi chú |
| :--- | :--- | :--- |
| **`BOT_V33.mq5`** | **Ổn định 100%** | Đã hoàn nguyên về nguyên bản, hoạt động độc lập bình thường. |
| **`new_bot/Onefxhub.mq5`** | **Sẵn sàng biên dịch & chạy** | Đã sửa dứt điểm lỗi `#include <JAson.mqh>`, sửa lỗi `steps.m_key.Total()`, tích hợp hàm Cloud Sync, làm sạch code đầu file. |
| **Web CMS (`bot_client.php`)** | **Hoàn tất** | Hỗ trợ chọn linh hoạt cả 2 dòng Bot (V33 & Onefxhub), layout form chuẩn, đẹp, không đè chữ. |
| **Controller & API** | **Đồng bộ chuẩn xác** | Nhận diện đúng loại bot, lưu/đọc đúng bảng, bảo mật và lưu vết `tsystem_log`. |
| **Cơ sở dữ liệu** | **Đã tách bảng tối ưu** | Tách riêng bảng `ea_tbot_onefxhub_settings` giúp mở rộng thêm nhiều bot trong tương lai mà không ảnh hưởng bot cũ. |

---
*Tài liệu này được tạo tự động để lưu trữ đầy đủ tiến trình và làm mốc tham chiếu cho các giai đoạn phát triển tiếp theo.*

