# Lịch sử xử lý: Bổ sung chốt cặp và đổi tên Bot EA thành EA-AIVEXI
- **Ngày:** 2026-11-16

### 1. Yêu cầu:
- Bổ sung lại cấu hình Chốt Cặp (Pair Close) cho Bot V38 vào Mục VIII. KIỂU VÀO LỆNH (ENTRY STRATEGY).
- Đổi tên hiển thị của option Bot `Onefxhub_v38` từ `Onefxhub V38.38 (RPA + Global Grid + T1/T2 + DD Lock)` thành `EA-AIVEXI`.

### 2. Giải pháp & Thay đổi:
- File `application/views/bot_client_view/bot_client.php`:
  - Đổi nhãn option dropdown thành `EA-AIVEXI` (vẫn giữ nguyên `value="Onefxhub_v38"` để tương thích toàn bộ CSDL và API).
  - Bổ sung khối giao diện "CHỨC NĂNG CHỐT CẶP (PAIRCLOSE - THU HỒI VỐN LỆNH CUỐI)" vào Mục VIII của V38 gồm: Bật chốt cặp, Áp dụng từ tầng, Lợi nhuận cặp ($), Chốt dần về.
  - Sử dụng các input name chuẩn `v38_cbof_cpair_close_bat_tat`, `v38_txt_npair_close_tu_lenh`, `v38_txt_fpair_close_so_usd`, `v38_cbof_cpair_close_chot_dan_ve` đã được controller `Do_bot_client.php` hỗ trợ đầy đủ.

### 3. Trạng thái / Lưu ý:
- Đã hoàn tất và kiểm tra đồng bộ với backend controller `Do_bot_client.php` và API `Do_bot_api.php`.
- Không cần thay đổi cấu trúc bảng CSDL vì các trường chốt cặp (`cpair_close_bat_tat`, `npair_close_tu_lenh`, `fpair_close_so_usd`, `cpair_close_chot_dan_ve`) đã có sẵn trong bảng `ea_tbot_settings_v38`.
