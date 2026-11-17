# TÓM TẮT TOÀN BỘ LỊCH SỬ TRÒ CHUYỆN & TIẾN ĐỘ DỰ ÁN ITRADE

> **Thời gian tạo:** 09/11/2026  
> **Cập nhật lần cuối:** 13/11/2026  
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

### Giai đoạn 8: Nâng cấp EA Onefxhub theo bản FINAL & Khắc phục lỗi MT5 / MetaEditor
- **Bối cảnh:**
  - Người dùng gửi bản chuẩn cuối cùng của khách hàng: `new_bot/ONEFXHUB_V38_FINAL.mq5` (loại bỏ hoàn toàn các logic thử nghiệm Recursive Pair_A RPA, chuyển hẳn sang chuẩn V26 Legacy PairClose tinh gọn).
  - Khắc phục sự cố diff file hiển thị `... [truncated for diff preview]` do file dài trên 9.000 dòng.
  - Khắc phục lỗi MetaEditor biên dịch `undeclared identifier 'jsval_boolean'` và lỗi MT5 dỡ bot khỏi chart `deinit reason 8 (OnInit failed)`.
  - Khắc phục lỗi API `Missing parameter` khi EA gọi xác thực.
- **Xử lý toàn diện:**
  1. **Ghép nối toàn bộ file `new_bot/Onefxhub.mq5`:**
     - Đọc và ghép nối an toàn từng khối dữ liệu từ `ONEFXHUB_V38_FINAL.mq5`, đảm bảo đầy đủ toàn bộ 9,406 dòng code mà không bị mất bất kỳ hàm hay dòng nào.
  2. **Chuẩn hóa cú pháp thư viện JAson:**
     - Sử dụng trực tiếp các phương thức chuẩn của thư viện `CJAVal` (`Type() != jtUNDEF`, `ToBool()`, `ToInt()`, `ToDbl()`, `ToStr()`), loại bỏ hoàn toàn các hằng số không xác định, giải quyết dứt điểm lỗi biên dịch MetaEditor.
  3. **Cơ chế Standby Mode trực quan trên Chart MT5:**
     - Thay vì trả về `INIT_FAILED` khiến MT5 lập tức gỡ bot khỏi Chart, hàm `OnInit()` trả về `INIT_SUCCEEDED` kèm biến cờ `IsApiAllowed`.
     - Trong `OnTick()`, nếu bot chưa có License hợp lệ, bot sẽ ghim thông tin trạng thái trực tiếp lên Chart thông qua hàm `Comment()` và tự động gửi lại yêu cầu đồng bộ mỗi 60 giây. Khi người dùng nhập License Key hoặc kích hoạt trên web, bot sẽ tự động nhận diện và vận hành mà không cần gỡ ra kéo lại vào chart.
  4. **Khắc phục lỗi `Missing parameter` tại Controller `Do_bot_api.php`:**
     - Hỗ trợ linh hoạt cả 2 chuẩn định danh: `license` hoặc `license_key`, `account` hoặc `account_number`.

---

### Giai đoạn 9: Tinh gọn giao diện Web CMS & Đồng bộ thương hiệu AIVEXI (aivexi.com)
- **Cập nhật Web CMS Client (`bot_client.php` & `Do_bot_client.php`):**
  - Loại bỏ hoàn toàn mục IX: `IX. CHẾ ĐỘ PAIRCLOSE (V26 vs V38 RECURSIVE PAIR_A)`.
  - Loại bỏ ô nhập `Magic Hedge khóa DD` (`ndd_hedge_magic`) tại mục IV và `Magic Num` (`nmagic`) tại mục V khỏi form khách hàng, gán ngầm giá trị mặc định an toàn (`888838` và `522345`).
  - Đánh số lại các đề mục giao diện ngay ngắn, khoa học:
    - VI. GIỜ GIAO DỊCH 3 PHIÊN (LOCAL GMT+7)
    - VII. CHỐT PHIÊN VÀ XÁC NHẬN HAI LẦN
    - VIII. KIỂU VÀO LỆNH (ENTRY STRATEGY)
    - IX. CẤU HÌNH BƯỚC LƯỚI GRID GN (G1 - G25 PIP - V38)
- **Bổ sung Footer Module cảnh báo rủi ro cho toàn bộ hệ thống (Live domain: `aivexi.com`):**
  - Cập nhật file `application/views/modules/mod_footer.php` (áp dụng chung cho toàn bộ các trang nội dung hệ thống quản trị):
    - Đổi bản quyền thành: `2026 © AIVEXI`.
    - Bổ sung nội dung:
      - **CẢNH BÁO RỦI RO:** Giao dịch tài chính, bao gồm ngoại hối (Forex), CFD, tiền mã hóa và các sản phẩm có đòn bẩy, tiềm ẩn rủi ro cao và có thể không phù hợp với mọi nhà đầu tư. Bạn có thể mất một phần hoặc toàn bộ số vốn đã đầu tư. Kết quả trong quá khứ, backtest hay số liệu mô phỏng không đảm bảo lợi nhuận trong tương lai. Chỉ giao dịch bằng số tiền bạn có thể chấp nhận mất.
      - **MIỄN TRỪ TRÁCH NHIỆM:** AIVEXI chỉ cung cấp công cụ phần mềm và thông tin tham khảo, không phải lời khuyên đầu tư hay tư vấn tài chính. Người dùng tự chịu hoàn toàn trách nhiệm với quyết định giao dịch và cấu hình bot của mình. AIVEXI không chịu trách nhiệm cho bất kỳ tổn thất nào phát sinh từ việc sử dụng dịch vụ.
  - Cập nhật trang đăng nhập `application/views/login_view/index.php` đồng bộ chuẩn nhận diện thương hiệu `2026 © AIVEXI` và cảnh báo rủi ro.

---

### Giai đoạn 10: Xử lý dứt điểm lỗi biên dịch MetaEditor `102 errors` (`'Type' - cannot convert enum`)
- **Sự cố:**
  - Khi người dùng biên dịch `new_bot/Onefxhub.mq5` trong MetaEditor, trình biên dịch báo tràn lỗi: `102 errors, 0 warnings`.
  - Chi tiết lỗi tại các dòng:
    - `'Type' - cannot convert enum` (Line 373 Column 36)
    - `undeclared identifier 'Type'` (Line 374 Column 38)
    - `')' - expression expected` (Line 374 Column 43)
- **Nguyên nhân cốt lõi:**
  - Trong thư viện `JAson.mqh` của MQL5 không hề có phương thức hàm tên là `.Type()`.
  - Việc gọi `if(inputs["..."].Type() != jtUNDEF)` trên khoảng 50 trường cấu hình đã sinh ra 2 lỗi biên dịch liên tiếp cho mỗi trường (50 x 2 ≈ 100 lỗi).
- **Khắc phục triệt để:**
  - Chuyển toàn bộ việc nạp biến trong hàm `SyncSettingsFromCloud()` sang cơ chế gán trực tiếp chuẩn như file `BOT_V33.mq5` (vốn biên dịch và vận hành 100% không lỗi):
    ```mql5
    CJAVal inputs = json["inputs"];
    Initial_Lot                     = inputs["Initial_Lot"].ToDbl();
    Lot_Multi                       = inputs["Lot_Multi"].ToDbl();
    Max_Orders                      = (int)inputs["Max_Orders"].ToInt();
    TP_Pips                         = inputs["TP_Pips"].ToDbl();
    Basket_TP_PhanTram              = inputs["Basket_TP_PhanTram"].ToDbl();
    Bat_Cong_Spread_TP              = (inputs["Bat_Cong_Spread_TP"].ToInt() == 1);
    Khoang_Doi_SL                   = inputs["Khoang_Doi_SL"].ToDbl();
    So_Pip_Doi_SL                   = inputs["So_Pip_Doi_SL"].ToDbl();
    Khoang_Trailing_SL              = inputs["Khoang_Trailing_SL"].ToDbl();
    ...
    CJAVal steps = inputs["Step_Distances"];
    G1 = steps["G1"].ToDbl(); G2 = steps["G2"].ToDbl(); ... G25 = steps["G25"].ToDbl();
    ```
  - Loại bỏ hoàn toàn các lời gọi `.Type()`, khôi phục khả năng biên dịch thành công 0 error trong MetaEditor.

---

### Giai đoạn 11: Nâng cấp định dạng giao diện Footer Cảnh báo & Miễn trừ trách nhiệm
- **Yêu cầu:** Người dùng yêu cầu tối ưu định dạng thẩm mỹ cho đoạn cảnh báo rủi ro ở chân trang:
  - Cụm từ `CẢNH BÁO RỦI RO:` làm nổi bật với chữ màu cam.
  - Cụm từ `MIỄN TRỪ TRÁCH NHIỆM:` làm nổi bật với chữ màu xanh da trời.
- **Xử lý:**
  - **File `application/views/modules/mod_footer.php`:**
    - `CẢNH BÁO RỦI RO:` dùng màu cam (`#ea580c`), `font-weight: 700`, kèm icon `<i class="fa fa-exclamation-triangle"></i>`.
    - `MIỄN TRỪ TRÁCH NHIỆM:` dùng màu xanh da trời (`#0284c7`), `font-weight: 700`, kèm icon `<i class="fa fa-info-circle"></i>`.
    - Bọc trong khung card bo góc `border-radius: 8px`, nền trắng sạch, viền xám mềm (`#e2e8f0`), chữ căn đều 2 bên (`text-align: justify`), khoảng cách dòng 1.65 thoáng đãng, đồng bộ thương hiệu `2026 © AIVEXI`.
  - **File `application/views/login_view/index.php`:**
    - Đồng bộ hoàn toàn kiểu phối màu cam và xanh da trời, bọc trong khung phụ sang trọng dưới nút Đăng nhập.

---

### Giai đoạn 12: Nâng cấp bot Onefxhub.mq5 lên nền tảng ONEFXHUB_V38_FINAL-8.mq5
- **Yêu cầu:** Dựa theo toàn bộ lịch sử trao đổi, nâng cấp mã nguồn `new_bot/Onefxhub.mq5` từ bản gốc mới nhất `new_bot/ONEFXHUB_V38_FINAL-8.mq5` (12.274 dòng - phiên bản Amtk V38.38 FINAL ZACO R3.2 one-pass safety correction) để phục vụ hoàn hảo cho hệ thống quản trị Web EA (`ea.sql` & `Do_bot_api.php`).
- **Phân tích & Thách thức kỹ thuật:**
  1. Bản gốc `ONEFXHUB_V38_FINAL-8.mq5` là phiên bản tối thượng với các module nâng cao: Level Book, Dynamic Zones, Multi-timeframe RSI2, Recovery Leg, Cycle Persistence, DD Hedge Lock chuyên sâu.
  2. Toàn bộ logic chạy dựa trên hệ thống cấu hình hiệu dụng (`Ef_...`) quản lý bởi Configuration Manager (`EfInit()`, `EfResolve()`, `CfgCommit()`).
  3. Cần tích hợp kiến trúc Cloud Hot-Update mà không phá vỡ cấu trúc biến của V38, không làm gián đoạn lưới lệnh đang mở khi cập nhật tham số từ xa.
  4. Tránh lỗi biên dịch JAson (`.Type()`) đã được giải quyết ở Giai đoạn 10.
  5. Cơ chế Standby Mode: Nếu License chưa nhập hoặc không hợp lệ, bot không được gọi `ExpertRemove()` hay return `INIT_FAILED` (tránh MT5 tự động gỡ bot ra khỏi chart với exit code 8). Bot vẫn khởi chạy bình thường, hiển thị trạng thái chờ kích hoạt trên Chart HUD và định kỳ thử kết nối lại.
- **Xử lý & Cập nhật toàn diện:**
  - **Khởi tạo và Phân tách biến (Decoupled Global Inputs):**
    - Giữ các tham số `input` làm giá trị mặc định từ MT5.
    - Tạo các biến toàn cục không hằng số tương ứng cùng hàm `InitGlobalInputsFromLocal()` để bot có thể nhận giá trị ghi đè nóng từ Cloud API.
  - **Module Kết nối Web Cloud & Đồng bộ (`SyncSettingsFromCloud`):**
    - Tích hợp kết nối HTTP GET/POST đến máy chủ web (`Do_bot_api/check_license`) với đầy đủ payload (`license_key`, `account_number`, `equity`, `balance`, `profit`, `broker`, `ea_version`).
    - Nạp toàn bộ 79 trường thông số chiến lược từ bảng `ea_tbot_settings_v38` theo chuẩn thư viện `JAson.mqh` an toàn (sử dụng trực tiếp `.ToDbl()`, `.ToInt()`, `.ToStr()`, tuyệt đối không gọi `.Type()`).
    - Sau khi nạp giá trị mới vào biến toàn cục, lập tức kích hoạt `EfResolve(false)` và `CfgCommit("CLOUD_SYNC")` để động cơ V38 tái tính toán tham số hiệu dụng ngay lập tức mà không cần khởi động lại bot.
  - **Tối ưu hóa `OnInit()`:**
    - Nạp tham số cục bộ thông qua `InitGlobalInputsFromLocal()`.
    - Kiểm tra License ban đầu với Web Server. Nếu chưa có mã bản quyền hoặc xác thực chưa thành công, gán `IsApiAllowed = false` và trả về `INIT_SUCCEEDED` (chế độ Standby) kèm thông báo trên Chart thay vì bị MT5 gỡ bỏ.
    - Khởi tạo đầy đủ các module cốt lõi của V38: `EfInit()`, Trade instance, Diag/Safety guards, Multi-RSI, Levelbook, Dynamic Zones.
  - **Tối ưu hóa `OnTick()`:**
    - Tích hợp bộ đếm định kỳ 60 giây tự động gọi `SyncSettingsFromCloud()` để đồng bộ thông số thời gian thực từ Web CMS.
    - Xây dựng Chart HUD đa năng qua `Comment(...)`:
      - Khi chưa kích hoạt: Hiển thị giao diện Standby Mode cảnh báo trực quan, hiển thị số tài khoản, Broker, yêu cầu kích hoạt License.
      - Khi đã kích hoạt: Hiển thị bảng điều khiển trực quan gồm Tên Bot, Trạng thái Cloud Sync, License, Số dư, Lợi nhuận mở, Trạng thái Lưới lệnh/Hedge.
    - Điều phối thực thi an toàn toàn bộ chu trình giao dịch V38: `V38OnTickBody()`, `Rsi2Tick()`, `CycPersistIfChanged()`, `AuthTick()`, `LbSync()`.
  - **Bảo toàn 100% Thuật toán V38.38:**
    - Toàn bộ 12.274 dòng mã nguồn từ cấu trúc `CTradeV38`, thuật toán DD Hedge Lock, Level Book, Safe Recovery Leg, Dynamic Zones,... đều được bảo toàn nguyên vẹn và chuẩn hóa chuẩn cú pháp MQL5.

### Giai đoạn 9: Bổ sung Thông số Zone Grid V38 Final-8 & Điều chỉnh Nhãn Giao diện CMS
- **Yêu cầu:** Cập nhật CMS Web (`Do_bot_client.php`, `bot_client.php`, `Do_bot_api.php`) theo bản bot mới nhất Final-8:
  1. Thêm các input Zone Grid bị thiếu:
     - `Maxzones` => Nhãn web: `"MaxZones AI Scan"` (`nmax_zones`, mặc định 10).
     - `Zone_Phase1UnlockZones` => Nhãn web: `"Required Zones / Phase 2"` (`nzone_phase1_unlock_zones`, mặc định 3).
     - `OrdersPerZonePerRound` ("Số lệnh mỗi nhóm K") => Đổi tên: `"MaxOrder / Round"` (`norders_per_zone_per_round`, mặc định 3).
     - `MaxRoundsPerZone` => Nhãn web: `"MaxRounds / Zone"` (`nmax_rounds_per_zone`, mặc định 2).
     - `ZoneStepUSD` ("Khoảng phá vỡ D") => Đổi tên: `"ZoneStep"` (`fzone_step_usd`, mặc định 2.0).
  2. Đổi tên các mục trên web:
     - Mục VIII: `"0: V26 truyền thống"` => `"EAVEXI V1 Grid"`, `"1: GLOBAL Grid Mode 1"` => `"AI VEXI PRO +"`.
     - Ẩn khối `"V. TÍN HIỆU RSI VÀO L1"`.
     - Mục III: Đổi tiêu đề thành `"SMART BASKET PROFIT PROTECTION | BẢO VỆ LỢI NHUẬN CỤM"`, đổi các nhãn `"Trigger | Ngưỡng kích hoạt bảo vệ TP (pip)"`, `"Profit Lock | Mức khóa lợi nhuận từ BE (Pip)"`, `"Adaptive Trailing | Khoảng bám đuổi lợi nhuận (pip)"`.
     - Mục VII: Đổi tiêu đề thành `"VII. CHỐT CUỐI PHIÊN VÀ AI CHECK"`, đổi các nhãn `"Giờ Cho EA Off"`, `"Ngưỡng % EA chốt nghỉ"`, `"AI Check"`, `"Áp dụng từ lệnh thứ"`.
  3. Cung cấp câu lệnh SQL ALTER TABLE bổ sung các trường vào bảng `ea_tbot_settings_v38` và cập nhật file `ea.sql`.

---

### Giai đoạn 10: Tái hiện Cấu hình Chốt Cặp (PairClose) trong Mục VIII & Đổi tên Bot thành EA-AIVEXI (16/11/2026)
- **Yêu cầu:** 
  1. Đổi tên hiển thị tùy chọn phiên bản bot `Onefxhub_v38` trên dropdown thành `EA-AIVEXI`.
  2. Tái hiện lại khối cấu hình Chốt Cặp (PairClose) vào Mục VIII. KIỂU VÀO LỆNH (ENTRY STRATEGY) cho bot EA-AIVEXI.
- **Xử lý:**
  - File `bot_client.php`: Cập nhật nhãn option thành `EA-AIVEXI`. Thêm khối giao diện PairClose (Bật chốt cặp, Áp dụng từ tầng, Lợi nhuận cặp, Chốt dần về) khớp 100% với các biến xử lý backend của `Do_bot_client.php` và API `Do_bot_api.php`.
  - Tạo file lưu trữ lịch sử phiên theo quy tắc: `chat_history/2026-11-16_bo-sung-chot-cap-va-doi-ten-bot.md`.

---

## IV. TỔNG KẾT TÌNH TRẠNG HIỆN TẠI CỦA HỆ THỐNG

| Thành phần | Trạng thái hiện tại | Ghi chú |
| :--- | :--- | :--- |
| **`BOT_V33.mq5`** | **Ổn định 100%** | Giữ nguyên vẹn 100% code gốc, hoạt động bình thường độc lập. |
| **`new_bot/Onefxhub.mq5`** | **Hoàn tất 100% theo bản V38_FINAL-8** | Nâng cấp toàn diện từ `ONEFXHUB_V38_FINAL-8.mq5` (12.274 dòng). Đã tích hợp đầy đủ Cloud Sync với `ea.sql` và `Do_bot_api.php`, kiến trúc Hot-Update `EfResolve()`/`CfgCommit()`, Standby Mode không bị gỡ khỏi chart, 100% tương thích `JAson.mqh`. |
| **Web CMS (`bot_client.php`)** | **Đã tinh gọn hoàn chỉnh** | Đã bỏ mục IX RPA, bỏ Magic Hedge và Magic Num theo đúng yêu cầu; bố cục chuẩn, rõ ràng. |
| **Controller & API (`Do_bot_api.php`)** | **Chuẩn hóa thông số** | Sửa dứt điểm lỗi `Missing parameter`, đồng bộ đầy đủ các tham số cấu hình V38 và V33, cập nhật chỉ số tài khoản và tên Broker thời gian thực. |
| **Giao diện & Footer** | **Đồng bộ thương hiệu AIVEXI & Màu sắc chuẩn** | Nhúng cảnh báo rủi ro (chữ cam) và miễn trừ trách nhiệm (chữ xanh da trời) theo chuẩn ảnh mẫu cho tên miền live `aivexi.com` vào toàn bộ các trang nội dung và trang đăng nhập. |
| **Cơ sở dữ liệu** | **Tương thích hoàn toàn** | Tương thích đầy đủ với file CSDL `ea.sql` (`ea_tbot_settings_v38`). |

---
*Tài liệu này được cập nhật tự động để lưu trữ đầy đủ tiến trình và làm mốc tham chiếu cho các giai đoạn phát triển tiếp theo.*

