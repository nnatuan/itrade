//+------------------------------------------------------------------+
//|                                                  Onefxhub.mq5    |
//|                                  Copyright 2026, Freelance Trader|
//+------------------------------------------------------------------+
#property copyright "AMTK"
#property version   "38.38"
#property strict

#include <Trade\Trade.mqh>
#include <JAson.mqh>
// [FINAL STANDALONE] ===== BEGIN INLINED OFH38_TradeGate.mqh (HOTFIX SHA256 C4F9BF21446226BEEB34F20DE0260C9E937A79BE8572FCAA8154DE06395E3092) — included from Onefxhub_v38.38_RPA.mq5:L111 =====
// OFH38_TradeGate.mqh — V38: điểm nghẽn duy nhất của mọi yêu cầu giao dịch (Grid gốc qua `trade`, hedge khóa DD qua `ddlTrade`).
// CTrade::OrderSend là hàm ảo: Buy / Sell / PositionClose / PositionClosePartial / PositionModify / PositionCloseBy đều đi qua đây.
// Bản thường: chuyển thẳng cho CTrade (hành vi giống hệt CTrade của V26).
// Bản kiểm thử (#define OFH38_TEST): harness có thể trả lời thay broker (từ chối, khớp một phần, thiếu tiền, timeout...).
// R1: m_sends đếm số yêu cầu THỰC SỰ tới OrderSend. CTrade trả false TRƯỚC khi gửi (ví dụ ticket không còn) thì m_sends không đổi và
// ResultRetcode() vẫn là retcode CŨ của yêu cầu trước → lớp thực thi R1 chỉ đọc retcode khi m_sends tăng.
#ifndef OFH38_TRADEGATE_MQH
#define OFH38_TRADEGATE_MQH


class CTradeV38 : public CTrade
{
public:
   long m_sends;
   CTradeV38(void) : m_sends(0) {}
   ulong DeviationPoints(void) const { return m_deviation; }   // [SAFETY S04] read the current deviation (restored after a DD compression close on the shared object)
   virtual bool OrderSend(const MqlTradeRequest &request, MqlTradeResult &result)
   {
      m_sends++;
      return CTrade::OrderSend(request, result);
   }
};

#endif
// [FINAL STANDALONE] ===== END INLINED OFH38_TradeGate.mqh =====

//+------------------------------------------------------------------+
// ENUM CHO BOT V38
//+------------------------------------------------------------------+
// OWNER12 (Owner mục 1): HAI lựa chọn vào lệnh duy nhất (không có GLOBAL Grid Mode 2). Tên hiển thị = chú thích của từng giá trị.
enum OFH38_ENTRY_STRATEGY
{
   OFH38_ENTRY_V26    = 0,   // 0 = V26 truyền thống
   OFH38_ENTRY_GLOBAL = 1    // 1 = GLOBAL Grid Mode 1
};

// [DPMR R1] D01 / D02 (Owner 04/11/2026): HAI chế độ PairClose, khách chọn MỘT; chế độ chốt theo BasketCycleID (đổi giữa chu kỳ → áp dụng từ chu kỳ phẳng kế tiếp).
enum OFH38_PAIRCLOSE_MODE
{
   OFH38_PC_V26_LEGACY = 0,   // 0 = V26_LEGACY_PAIR_CLOSE (chốt cặp 2 lệnh mở muộn nhất của V26)
   OFH38_PC_V38_RPA    = 1    // 1 = V38_RECURSIVE_PAIR_A (Pair_A → Lk* → SubGridEpoch)
};

//+------------------------------------------------------------------+
// BỘ ĐIỀU KHIỂN BẢN QUYỀN VÀ ĐỒNG BỘ CLOUD CONTROL
//+------------------------------------------------------------------+
input string  _API           = "=== API CLOUD CONTROL ===";
input string  LicenseKey     = "";      // Nhập mã License Key từ Admin cấp
input string  ApiUrl         = "https://hethongso.com/itrade/index.php/do_bot_api/check_license";

// Biến trạng thái API
datetime LastApiSyncTime = 0;
bool     IsApiAllowed    = false;

input string  _Cap           = "=== VỐN / LOT ===";
input double  Inp_Initial_Lot    = 0.03;   // Lot lệnh 1 (L1) (V38: mặc định Owner xác nhận 0.03)
input double  Inp_Lot_Multi      = 1.50;   // Nhân lot mỗi lệnh lưới: L2 = L1 × hệ số, L3 = L1 × hệ số^2...
input int     Inp_Max_Orders     = 26;     // Số lệnh tối đa trong một cụm

input string  _TP            = "=== CHỐT LỜI LỆNH 1 ===";
input double  Inp_TP_Pips        = 10;     // TP riêng L1 (pip). 4000.00 → 4001.00 = 10 pip = 1 giá. Chỉ dùng khi chưa có L2
input double  Inp_Basket_TP_PhanTram = 0;  // %YP lệnh 1 | 0=tắt | >0: giá qua %YP thì khóa SL tại đó; chạm TP thì chốt lãi; quay đầu thì chốt tại %YP

input string  _Cum           = "=== T1/T2 CỤM LỆNH L2+ (pip, 1 giá = 10 pip) ===";
input bool    Inp_Bat_Cong_Spread_TP    = true;  // Cộng spread vào TP của L1 (không dùng cho T1/T2)
input double  Inp_Khoang_Doi_SL         = 25;    // T1 kích hoạt / T2 đi tiếp: Bid/Ask qua BE ± khoảng này (pip) (OWNER12: Owner 25)
input double  Inp_So_Pip_Doi_SL         = 15;    // T1: khóa toàn cụm tại BE ± mức này (pip), không cắt lệnh nào; phải < Khoang_Doi_SL (OWNER12: Owner 15)
input double  Inp_Khoang_Trailing_SL    = 10;    // T2: SL = giá hiện tại ± khoảng này, chỉ tiến không lùi (Owner 10)

input string  _DD            = "=== DD HEDGE LOCK (ngưỡng DD% do Owner nhập; lượt nghiên cứu OWNER12: TẮT) ===";
input bool    Inp_Bat_Cat_DD            = false;  // OWNER12: mặc định TẮT. Bật: khi |lỗ nổi| / số dư TK × 100 đạt Cat_DD_PhanTram → hedge cân NET (chức năng i)
input double  Inp_Cat_DD_PhanTram       = 0.0;    // Ngưỡng DD% do Owner nhập (0 = chưa đặt; bật DD mà <= 0 hoặc >= 100 → EA không khởi động). Không còn mặc định 30
input ulong   Inp_DDLock_HedgeMagic     = 888838; // Magic riêng cho lệnh hedge khóa DD (định danh, phải khác Magic)
// [INPUT CLEANUP R1] IC1: chức năng ii (nén DD) ẩn khỏi Inputs theo quyết định tạm thời của Owner 03/11/2026 — hằng nội bộ, cùng tên / kiểu / giá trị; mã nén GIỮ NGUYÊN, không chạy (false)
const bool    DDLock_EnableCompression = false; // Chức năng ii: sau khi khóa, đóng các cặp BUY / SELL đối ứng cùng lot (net giữ nguyên), ghi sổ kinh tế
const double  DDLock_CompressionKeepGrossPct = 100; // Chức năng ii: dừng đóng đối ứng khi gross còn <= N% gross lúc khóa (0 = đóng mọi cặp)
// OWNER12 (Owner mục 7 / 8): OwnerAck / thông số kỹ thuật của DD Hedge Lock → hằng nội bộ (không hiện cho khách), cùng giá trị đã kiểm của R1–PAIRA_LOOP.
// CẢNH BÁO: khi khóa xong, LOCKED_HOLD chưa có lối ra được Owner duyệt — DD bật có thể giữ cụm vô hạn (blocker B2). Lượt nghiên cứu này TẮT DD.
const int     DDLock_MaxAttempts    = 5;      // số lần gửi hedge thất bại trước LOCK_FAILED
const int     DDLock_RetryMinutes   = 5;      // LOCK_FAILED → thử khóa lại sau N phút
const int     DDLock_DeviationPoints = 30;    // trượt giá tối đa cho lệnh khóa / đóng đối ứng (point)
const bool    DDLock_OwnerAckResume = false;  // không còn trên giao diện (Owner: không đưa OwnerAck / HALT tự động vào giao diện khách)
const int     DDLock_CloseSlipPoints = 20;    // dự phòng trượt giá (point / lot) trong chi phí đóng ước tính của báo cáo nợ
const bool    DDLock_EpisodeLog     = true;   // ghi CSV từng đợt DD (Common\Files\OFH38\)

input string  _RSI           = "=== TÍN HIỆU RSI VÀO L1 ===";
input int     Inp_RSI_Period     = 5;             // [L1RSI R1] Chu kỳ RSI (mặc định Owner 5). Phải >= 2: 1 bị từ chối (CONFIG ERROR) vì iRSI MT5 chu kỳ 1 = 0.0 mọi nến → chỉ L1 BUY
input ENUM_TIMEFRAMES Inp_RSI_TF = PERIOD_M1;     // Khung RSI (thường M1)

input ulong   Inp_Magic          = 522345;        // Số magic để EA chỉ quản lý lệnh của chính nó

input string  _Time          = "=== GIỜ GIAO DỊCH: 3 PHIÊN (LOCAL GMT+7) ===";
input bool    Inp_UseTimeFilter  = true;   // true=chỉ giao dịch trong các phiên đang bật | false=24/7
input int     Inp_ServerGMT      = 3;      // Múi GMT của server broker (ví dụ GMT+3)
input int     Inp_LocalGMT       = 7;      // Múi GMT máy bạn (GMT+7)
input bool    Inp_Enable_Asia        = true;  // Phiên Á
input int     Inp_Asia_StartHour     = 5;     // Á bắt đầu (giờ local)
input int     Inp_Asia_StartMinute   = 0;     // Á bắt đầu (phút)
input int     Inp_Asia_EndHour       = 14;    // Á kết thúc (giờ local; ≤ giờ bắt đầu = sang ngày hôm sau)
input int     Inp_Asia_EndMinute     = 0;     // Á kết thúc (phút)
input bool    Inp_Enable_Europe      = true;  // Phiên Âu
input int     Inp_Europe_StartHour   = 14;    // Âu bắt đầu (giờ local)
input int     Inp_Europe_StartMinute = 0;     // Âu bắt đầu (phút)
input int     Inp_Europe_EndHour     = 23;    // Âu kết thúc (giờ local)
input int     Inp_Europe_EndMinute   = 0;     // Âu kết thúc (phút)
input bool    Inp_Enable_US          = true;  // Phiên Mỹ
input int     Inp_US_StartHour       = 19;    // Mỹ bắt đầu (giờ local)
input int     Inp_US_StartMinute     = 0;     // Mỹ bắt đầu (phút)
input int     Inp_US_EndHour         = 4;     // Mỹ kết thúc: 04:00 NGÀY HÔM SAU
input int     Inp_US_EndMinute       = 0;     // Mỹ kết thúc (phút)

input string  _Close         = "=== CHỐT PHIÊN VÀ XÁC NHẬN HAI LẦN (MinBeforeClose phút cuối cửa sổ liên tục) ===";
input int     Inp_MinBeforeClose = 60;     // Số phút trước giờ hết cửa sổ liên tục: không mở L1 mới, áp luật chốt phiên
input int     Inp_CloseProtect_MaxOrders = 8; // Chu kỳ CHƯA từng Progressive PairClose: ≤N vị thế → đóng hết + đối soát broker + nghỉ | >N → tiếp tục Grid của chiến lược đã chọn tới điều kiện thoát (SESSION_BASKET_RESCUE, không L1 mới)
input bool    Inp_CloseProtect_UsePairACycleLossPct = true; // Chu kỳ ĐÃ từng Progressive PairClose (mọi số vị thế): true = đóng hết + nghỉ khi lỗ kinh tế chu kỳ ≤ CloseProtect_PairACycleMaxLossPct % equity | false = chỉ đóng khi chu kỳ ≥ hòa vốn kinh tế (0 %)
input double  Inp_CloseProtect_PairACycleMaxLossPct = 0.3;  // N %: CycleEconomicPnL (đã chốt + nổi − chi phí còn lại) ≥ −N % × equity lúc kiểm → đóng hết + nghỉ; lỗ lớn hơn → tiếp tục quản lý / Rescue Grid, không L1 song song
input bool    Inp_Enable_DoubleConfirmation = true; // true = thuật toán xác nhận 2 lần của V26 từ ConfirmFromOrder | false = bỏ qua, trigger thường
input int     Inp_ConfirmFromOrder = 19;   // Từ lệnh thứ N trở đi: chạm trigger → rời → chạm lại mới được vào (OWNER12: Owner 19)

input string  _Step          = "=== BƯỚC LƯỚI: GN = khoảng từ L1 tới lệnh N+1 ===";
input double  Inp_G1  = 4;   input double  Inp_G2  = 4;   input double  Inp_G3  = 8;    // G1 dùng cho L2, G2 cho L3... (V38: mặc định Owner xác nhận; pip, 4 pip = 0.4 giá)
input double  Inp_G4  = 8;   input double  Inp_G5  = 12;  input double  Inp_G6  = 12;
input double  Inp_G7  = 16;  input double  Inp_G8  = 16;  input double  Inp_G9  = 20;
input double  Inp_G10 = 20;  input double  Inp_G11 = 24;  input double  Inp_G12 = 24;
input double  Inp_G13 = 28;  input double  Inp_G14 = 28;  input double  Inp_G15 = 32;
input double  Inp_G16 = 32;  input double  Inp_G17 = 36;  input double  Inp_G18 = 36;
input double  Inp_G19 = 40;  input double  Inp_G20 = 40;  input double  Inp_G21 = 44;
input double  Inp_G22 = 44;  input double  Inp_G23 = 48;  input double  Inp_G24 = 48;
input double  Inp_G25 = 52;    // Từ L26 trở đi dùng G25

input string  _Global        = "=== KIỂU VÀO LỆNH: 0 = V26 TRUYỀN THỐNG | 1 = GLOBAL GRID MODE 1 (chốt theo chu kỳ, đổi chỉ áp dụng từ chu kỳ phẳng kế tiếp) ===";
input OFH38_ENTRY_STRATEGY Inp_Entry_Strategy    = OFH38_ENTRY_V26; // 0 = V26 truyền thống | 1 = GLOBAL Grid Mode 1 (nhóm lệnh + phá biên nhóm). Giá trị khác 0 / 1 → EA không khởi động
input int     Inp_GlobalGrid_OrdersPerGroup      = 6;     // GLOBAL Mode 1: số lệnh mỗi nhóm K (2..Max_Orders; nhóm cuối có thể ngắn hơn, phần dư đúng 1 lệnh gộp vào nhóm trước). Level trong nhóm dùng GlobalGrid_LocalDistancesPips từ anchor nhóm. Mặc định NGHIÊN CỨU 6
input double  Inp_GlobalGrid_BreakoutDistanceUSD = 3.0;   // GLOBAL Mode 1: khoảng phá vỡ D tính bằng USD GIÁ XAU (KHÔNG phải pip như G1–G25): lệnh đầu nhóm mới đo từ VỊ THẾ ĐANG MỞ cùng chiều của nhóm trước — BUY cần Ask ≥ giá mở BUY cao nhất + D, SELL cần Bid ≤ giá mở SELL thấp nhất − D [NPD R1]. Mặc định NGHIÊN CỨU 3.00
input string  Inp_GlobalGrid_LocalDistancesPips  = "4,4,8,8,12,12,16,16,20,20,24,24,28,28,32,32,36,36,40,40,44,44,48,48,52";    // [INPUT CLEANUP R1] IC2 default (Owner 03/11/2026). [GLOBAL GEN] GLOBAL Mode 1: khoảng cách NỘI BỘ (pip) TỪ ANCHOR nhóm: phần tử j = khoảng cách TUYỆT ĐỐI tới local L(j+1), không cộng dồn; dùng cho MỌI nhóm (kể cả nhóm 0). Phân cách ',' HOẶC ';' (không trộn), thập phân '.', >= 0, đủ số phần tử EA in ở OnInit, tối đa 224 ký tự. Trống / thiếu / sai → GLOBAL không khởi động (không thay bằng G1–G25). V26 không đọc
input string  Inp_Enable_GlobalGridAIPro         = "NOT_USED"; // MIGRATION — giữ NOT_USED. Khóa bool cũ đã thay bằng Entry_Strategy: SET cũ còn khóa này (true / false) phải cùng nghĩa với Entry_Strategy, khác → EA không khởi động
const bool    GridLot_StrictBrokerLimits     = true;

input string  _PcMode        = "=== PAIRCLOSE — CHẾ ĐỘ (0 = V26 LEGACY PAIR CLOSE | 1 = V38 RECURSIVE PAIR_A; chốt theo chu kỳ; RESEARCH: chưa nghiệm thu, không Demo / Live) ===";
input OFH38_PAIRCLOSE_MODE Inp_PairClose_Mode = OFH38_PC_V38_RPA; // [DPMR R1] 0 = V26 Legacy PairClose | 1 = V38 Recursive Pair_A (mặc định). Giá trị khác 0 / 1 → EA không khởi động
input string  _PairClose     = "=== PAIRCLOSE MODE 0 — CHỐT CẶP 2 LỆNH CUỐI (V26 gốc; chỉ dùng khi PairClose_Mode = 0) ===";
input bool    Inp_PairClose_BatTat       = true;   // Bật/tắt chốt cặp (tắt khi đã vào T1)
input int     Inp_PairClose_TuLenh       = 12;     // Chỉ xét khi cụm đã có từ N lệnh
input double  Inp_PairClose_SoUSD        = 2.0;    // Chốt khi lãi lệnh kế cuối + lệnh cuối ≥ số $ này
input bool    Inp_PairClose_ChotDanVe    = true;   // true=một tick có thể chốt nhiều cặp liên tiếp

input string  _Rpa           = "=== PAIRCLOSE MODE 1 — RECURSIVE PAIR_A REBASE (Grid gốc → Lk* → tập con → Lk* ...; chỉ dùng khi PairClose_Mode = 1; RESEARCH: chưa nghiệm thu, không Demo / Live) ===";
input int     Inp_OriginalPairCloseStartOrder = 20;   // Grid gốc: PairClose chỉ được XÉT khi cấp Grid cao nhất đã mở >= N (13 / 15 / 20 / 25 ...); vẫn cần BE100 kinh tế + điều kiện thực thi
input int     Inp_RecursiveRebaseTargetLevel  = 15;   // k của Lk*: TargetLot = |tổng lot BUY − tổng lot SELL của L1..Lk Grid gốc| (lot engine gốc), chiều theo dấu

//--- BỘ BIẾN TOÀN CỤC CHẠY THỰC TẾ (ĐỒNG BỘ ĐỘNG QUA API HOẶC KHỞI TẠO TỪ INPUT KHI BACKTEST)
double                Initial_Lot;
double                Lot_Multi;
int                   Max_Orders;
double                TP_Pips;
double                Basket_TP_PhanTram;
bool                  Bat_Cong_Spread_TP;
double                Khoang_Doi_SL;
double                So_Pip_Doi_SL;
double                Khoang_Trailing_SL;
bool                  Bat_Cat_DD;
double                Cat_DD_PhanTram;
ulong                 DDLock_HedgeMagic;
int                   RSI_Period;
ENUM_TIMEFRAMES       RSI_TF;
ulong                 Magic;
bool                  UseTimeFilter;
int                   ServerGMT;
int                   LocalGMT;
bool                  Enable_Asia;
int                   Asia_StartHour;
int                   Asia_StartMinute;
int                   Asia_EndHour;
int                   Asia_EndMinute;
bool                  Enable_Europe;
int                   Europe_StartHour;
int                   Europe_StartMinute;
int                   Europe_EndHour;
int                   Europe_EndMinute;
bool                  Enable_US;
int                   US_StartHour;
int                   US_StartMinute;
int                   US_EndHour;
int                   US_EndMinute;
int                   MinBeforeClose;
int                   CloseProtect_MaxOrders;
bool                  CloseProtect_UsePairACycleLossPct;
double                CloseProtect_PairACycleMaxLossPct;
bool                  Enable_DoubleConfirmation;
int                   ConfirmFromOrder;
double                G1, G2, G3, G4, G5, G6, G7, G8, G9, G10,
                      G11, G12, G13, G14, G15, G16, G17, G18, G19, G20,
                      G21, G22, G23, G24, G25;
OFH38_ENTRY_STRATEGY  Entry_Strategy;
int                   GlobalGrid_OrdersPerGroup;
double                GlobalGrid_BreakoutDistanceUSD;
string                GlobalGrid_LocalDistancesPips;
string                Enable_GlobalGridAIPro;
OFH38_PAIRCLOSE_MODE  PairClose_Mode;
bool                  PairClose_BatTat;
int                   PairClose_TuLenh;
double                PairClose_SoUSD;
bool                  PairClose_ChotDanVe;
int                   OriginalPairCloseStartOrder;
int                   RecursiveRebaseTargetLevel;

void InitGlobalInputsFromLocal()
{
   Initial_Lot                   = Inp_Initial_Lot;
   Lot_Multi                     = Inp_Lot_Multi;
   Max_Orders                    = Inp_Max_Orders;
   TP_Pips                       = Inp_TP_Pips;
   Basket_TP_PhanTram            = Inp_Basket_TP_PhanTram;
   Bat_Cong_Spread_TP            = Inp_Bat_Cong_Spread_TP;
   Khoang_Doi_SL                 = Inp_Khoang_Doi_SL;
   So_Pip_Doi_SL                 = Inp_So_Pip_Doi_SL;
   Khoang_Trailing_SL            = Inp_Khoang_Trailing_SL;
   Bat_Cat_DD                    = Inp_Bat_Cat_DD;
   Cat_DD_PhanTram               = Inp_Cat_DD_PhanTram;
   DDLock_HedgeMagic             = Inp_DDLock_HedgeMagic;
   RSI_Period                    = Inp_RSI_Period;
   RSI_TF                        = Inp_RSI_TF;
   Magic                         = Inp_Magic;
   UseTimeFilter                 = Inp_UseTimeFilter;
   ServerGMT                     = Inp_ServerGMT;
   LocalGMT                      = Inp_LocalGMT;
   Enable_Asia                   = Inp_Enable_Asia;
   Asia_StartHour                = Inp_Asia_StartHour;
   Asia_StartMinute              = Inp_Asia_StartMinute;
   Asia_EndHour                  = Inp_Asia_EndHour;
   Asia_EndMinute                = Inp_Asia_EndMinute;
   Enable_Europe                 = Inp_Enable_Europe;
   Europe_StartHour              = Inp_Europe_StartHour;
   Europe_StartMinute            = Inp_Europe_StartMinute;
   Europe_EndHour                = Inp_Europe_EndHour;
   Europe_EndMinute              = Inp_Europe_EndMinute;
   Enable_US                     = Inp_Enable_US;
   US_StartHour                  = Inp_US_StartHour;
   US_StartMinute                = Inp_US_StartMinute;
   US_EndHour                    = Inp_US_EndHour;
   US_EndMinute                  = Inp_US_EndMinute;
   MinBeforeClose                = Inp_MinBeforeClose;
   CloseProtect_MaxOrders        = Inp_CloseProtect_MaxOrders;
   CloseProtect_UsePairACycleLossPct = Inp_CloseProtect_UsePairACycleLossPct;
   CloseProtect_PairACycleMaxLossPct = Inp_CloseProtect_PairACycleMaxLossPct;
   Enable_DoubleConfirmation     = Inp_Enable_DoubleConfirmation;
   ConfirmFromOrder              = Inp_ConfirmFromOrder;
   G1=Inp_G1;   G2=Inp_G2;   G3=Inp_G3;   G4=Inp_G4;   G5=Inp_G5;
   G6=Inp_G6;   G7=Inp_G7;   G8=Inp_G8;   G9=Inp_G9;   G10=Inp_G10;
   G11=Inp_G11; G12=Inp_G12; G13=Inp_G13; G14=Inp_G14; G15=Inp_G15;
   G16=Inp_G16; G17=Inp_G17; G18=Inp_G18; G19=Inp_G19; G20=Inp_G20;
   G21=Inp_G21; G22=Inp_G22; G23=Inp_G23; G24=Inp_G24; G25=Inp_G25;
   Entry_Strategy                = Inp_Entry_Strategy;
   GlobalGrid_OrdersPerGroup     = Inp_GlobalGrid_OrdersPerGroup;
   GlobalGrid_BreakoutDistanceUSD= Inp_GlobalGrid_BreakoutDistanceUSD;
   GlobalGrid_LocalDistancesPips = Inp_GlobalGrid_LocalDistancesPips;
   Enable_GlobalGridAIPro        = Inp_Enable_GlobalGridAIPro;
   PairClose_Mode                = Inp_PairClose_Mode;
   PairClose_BatTat              = Inp_PairClose_BatTat;
   PairClose_TuLenh              = Inp_PairClose_TuLenh;
   PairClose_SoUSD               = Inp_PairClose_SoUSD;
   PairClose_ChotDanVe           = Inp_PairClose_ChotDanVe;
   OriginalPairCloseStartOrder   = Inp_OriginalPairCloseStartOrder;
   RecursiveRebaseTargetLevel    = Inp_RecursiveRebaseTargetLevel;
}
// [INPUT CLEANUP R1] IC1: nhóm PairClose dùng chung ẩn khỏi Inputs (Owner 03/11/2026 mục 3) — hằng nội bộ, cùng tên / kiểu / giá trị; BE100 / chi phí / trượt / margin / stress / shadow giữ nguyên
const string  _PcShared      = "=== PAIRCLOSE — KINH TẾ / CỔNG RỦI RO DÙNG CHUNG (kế thừa cấu hình có sẵn) ===";
const double  PairA_SettleMinUSD             = 0.0;   // BE100: kinh tế CẢ BasketCycleID (đã chốt + nổi + swap − chi phí thoát dự kiến − dự phòng trượt) phải >= N USD
const double  PairA_CloseCostPerLotUSD       = 0.0;   // ước tính commission + phí THOÁT / lot (trước lệnh); thực tế lấy max(ước tính, commission + phí / lot đo được của deal vào); số thật từ deal
const int     PairA_SlipReservePoints        = 5;     // dự phòng trượt giá / lot đóng (point) trong ước tính trước lệnh
const double  PairA_PfStressUSD              = 20.0;  // cổng rủi ro: Lk* sau rebase, giá đi bất lợi N USD
const double  PairA_PfMaxStressLossPct       = 30.0;  // cổng rủi ro: lỗ ở kịch bản stress <= N % equity lúc quyết định (0 = tắt)
const double  PairA_PfMinMarginLevelPct      = 150.0; // cổng rủi ro: margin level ở MỌI bước của đường đóng (mô hình hiệu chỉnh theo ACCOUNT_MARGIN) >= N % (0 = tắt)
const bool    PairA_ShadowOnly               = false; // true = chỉ ghi nhật ký quyết định rebase (nghiên cứu), không gửi lệnh nào của PairClose

// [INPUT CLEANUP R1] IC1: chế độ thoát nghiên cứu ẩn khỏi Inputs (Owner 03/11/2026 mục 4) — hằng nội bộ, Exit_Mode = EXIT_LEGACY; công thức BE / T1 / T2 / trailing / thứ tự ưu tiên không đổi
const string  _Exit          = "=== THOÁT T1 / T2 — CHẾ ĐỘ (Owner P3; RESEARCH: chưa chứng minh tối ưu) ===";
enum OFH38_EXIT_MODE
{
   EXIT_LEGACY    = 0,   // 0 = như b9 (BE khối lượng khi chưa có PairClose)
   EXIT_T0_STATIC = 1,   // 1 = T0 25/15/10 trên BE KINH TẾ cả chu kỳ
   EXIT_T1_TREND  = 2,   // 2 = T1 Trend-Aware: hoãn kéo SL khi xu hướng mạnh
   EXIT_T2_HYBRID = 3    // 3 = T2 Hybrid: sàn lợi nhuận + khoảng kéo theo ATR / xu hướng
};
const OFH38_EXIT_MODE Exit_Mode       = EXIT_LEGACY; // chốt theo chu kỳ. 1..3 dùng CycleEconomicPnL (gồm P/L PairClose, hedge, phí) ở mọi chu kỳ
const ENUM_TIMEFRAMES ExitTrend_TF    = PERIOD_M5;   // khung chỉ báo xu hướng (nến đã đóng)
const int     ExitTrend_EmaFast        = 20;    // EMA nhanh
const int     ExitTrend_EmaSlow        = 50;    // EMA chậm
const int     ExitTrend_AtrPeriod      = 14;    // ATR
const double  ExitTrend_StrongScore    = 1.0;   // xu hướng MẠNH khi chiều net × (EMA nhanh − EMA chậm) / ATR >= N
const double  ExitHyb_FloorStartPips   = 50;    // T2 HYBRID: sàn lợi nhuận bật khi giá thuận lợi nhất cách BE >= N pip
const double  ExitHyb_FloorKeepPct     = 50;    // T2 HYBRID: sàn = BE + N % quãng (giá thuận lợi nhất − BE)
const double  ExitHyb_AtrMultWeak      = 1.0;   // T2 HYBRID: khoảng kéo = ATR × N khi xu hướng yếu
const double  ExitHyb_AtrMultStrong    = 2.0;   // T2 HYBRID: khoảng kéo = ATR × N khi xu hướng mạnh
const double  ExitHyb_TrailMinPips     = 10;    // T2 HYBRID: khoảng kéo tối thiểu (pip) — bằng T0 Khoang_Trailing_SL
const double  ExitHyb_TrailMaxPips     = 80;    // T2 HYBRID: khoảng kéo tối đa (pip)

// [INPUT CLEANUP R1] IC1: khôi phục lệnh đóng tay ẩn khỏi Inputs (Owner 03/11/2026 mục 5) — hằng nội bộ, cả hai = true; luật 1 vị thế gốc / MULTI_MANUAL_IGNORE / sổ cấp / T1-T2 trước khôi phục không đổi
// [MRR R1] M01 (Owner 03/11/2026 "REMOVE MANUAL REENTRY BEHAVIOR"): khôi phục lệnh đóng tay ĐÃ GỠ — ManualReentry_Enable = false: đóng tay không tạo bản ghi khôi phục,
// cấp đã đóng hết bị BỎ trong sổ cấp (không mở lại trong chu kỳ), Grid tiếp tục ở cấp kế đã chứng minh. ManualReentry_DoubleConfirm không còn đường chạy (không bản ghi nào ở trạng thái giá).
const string  _Manual        = "=== ĐÓNG TAY: KHÔNG VÀO LẠI (MRR R1) — cấp đã đóng hết bị bỏ trong sổ cấp, Grid tiếp tục ở cấp kế; bản ghi cũ đang bay chỉ được đối soát ===";
const bool    ManualReentry_Enable        = false; // [MRR R1] M01: false = không vào lại; Grid tiếp tục theo sổ cấp, không mở lại cấp đã đóng (trước MRR R1: true = vào lại MỘT vị thế gốc khi giá về entry cũ)
const bool    ManualReentry_DoubleConfirm = true;  // [MRR R1] không còn tác dụng (không bản ghi khôi phục mới); giữ để bản ghi cũ đọc được — trước: xác nhận 2 lần riêng của bản ghi

// OWNER12 (Owner mục 8): nhóm "THỰC THI VÀ LƯU TRẠNG THÁI" = thông số KỸ THUẬT, không phải giả thuyết P/L → hằng nội bộ (không hiện cho khách), cùng giá trị đã kiểm
// của R1–PAIRA_LOOP. Thuật toán an toàn broker (retcode + đọc lại, đang bay / backoff có trần, chống gửi trùng, khớp trễ, journal lưu bền) KHÔNG đổi; OnInit in giá trị.
const int     Exec_ConfirmMs         = 1000;  // broker đã nhận mà vị thế / SL-TP chưa đổi: chờ tối đa N ms rồi mới coi là chưa xong và gửi lại
const int     Exec_MaxAttempts       = 20;    // số lần gửi tối đa cho MỘT ticket (đóng / sửa cùng mức) trước STALLED
const int     Exec_StallRetryMinutes = 5;     // STALLED: thử lại loạt mới sau N phút
const bool    Exit_LogCsv            = true;  // CSV mỗi đợt thoát cụm (Common\Files\OFH38\EXIT_*.csv)
const bool    V26State_Persist       = true;  // lưu bền trạng thái chu kỳ V26 (T1/T2, xác nhận 2 lần, chờ vào lại, chân PairClose dở của bản cũ)
const bool    ManualPartial_FreezeGrid = true; // chốt tay MỘT PHẦN → không thêm level cho cụm đó nữa (chính sách R1)
const int     ManualReentry_ReconcileSec  = 30; // lệnh vào lại chưa thấy khớp: sau N giây chỉ CẢNH BÁO; không bao giờ gửi lại khi broker chưa có bằng chứng (R3-04)

// [INPUT CLEANUP R1] IC1: nhóm nghiên cứu ẩn khỏi Inputs (Owner 03/11/2026 mục 6) — hằng nội bộ (Recorder false, StopOnBankrupt true, RunTag ""); mã bộ ghi / stop-out giữ nguyên
const string  _Research      = "=== NGHIÊN CỨU — CHỈ CÓ TÁC DỤNG TRONG STRATEGY TESTER (Demo / Live: bỏ qua) ===";
const bool    Research_Recorder       = false; // tester: ghi equity / margin / lot mỗi phút + sự kiện (MQL5\Files của agent). Chỉ quan sát, không gửi / sửa / đóng lệnh
const bool    Research_StopOnBankrupt = true;  // tester + Research_Recorder: stop-out hoặc equity <= 0 → EXIT_CAUSE BANKRUPT, dừng lượt (TesterStop)
const string  Research_RunTag         = "";    // tên lượt trong file CSV

CTradeV38 trade;           // Đối tượng gửi lệnh MT5 (V38: CTrade qua điểm nghẽn OFH38_TradeGate — bản thường chuyển thẳng cho CTrade)
int      hRSI;             // Handle chỉ báo RSI
double   rsiVal[];         // Buffer đọc RSI nến đã đóng
double   PipSize;          // 1 pip XAU = 0.1 giá

int      OrderCount      = 0;   // Số lệnh đang mở của EA
double   FirstPrice      = 0;   // Giá vào L1 — mốc tính trigger G1..G25, không đổi trong cụm
int      FirstType       = -1;  // Chiều L1 (BUY/SELL) — các lệnh sau xen kẽ từ đây

ulong    LastSentOrder   = 0;   // Ticket lệnh vừa gửi, chống gửi trùng
datetime LastSentTime    = 0;
int      LastSentCount   = 0;   // Số lệnh kỳ vọng lúc vừa gửi
int      ConfirmWait     = 10;  // Giây chờ pending fill rồi mới gửi lại

bool     WaitNextSession = false; // true=đã đóng phiên, nghỉ tới giờ mở phiên sau
datetime WaitUntilTime   = 0;

int      DblConfirmNum   = 0;     // Đang xác nhận 2 lần cho lệnh số mấy
bool     DblConfirmHit1  = false; // Đã chạm trigger lần 1
bool     DblConfirmReady = false; // Đã rời trigger, chờ chạm lần 2

bool     hedgeTrailActive = false; // Đã T1: tắt grid, đang quản lý mức thoát cụm
double   hedgeBePrice     = 0;     // Mốc khóa T1 (BE ± So_Pip_Doi_SL) — T2 không được lùi dưới mốc này
double   hedgeExitPrice   = 0;     // Mức thoát hiện tại (khóa T1 hoặc đã kéo T2)
double   hedgeClusterBe   = 0;     // Giá hòa vốn khối lượng lúc khóa T1
double   hedgeT1Trigger   = 0;     // Mốc T2: BE ± Khoang_Doi_SL
double   hedgeLockMoney   = 0;     // (dự phòng) lãi khóa theo $
int      hedgeTrailDir    = 0;     // 1=Buy Net  -1=Sell Net

bool     basketModeLatched = false; // true khi cụm đã từng có L2+; giữ tới khi hết lệnh
bool     t1Locked          = false; // T1 đã khóa toàn cụm, tắt Grid, chưa cắt lệnh
int      t1Dir             = 0;     // Chiều net lúc T1: 1=BUY  -1=SELL
bool     t2Armed           = false; // T2 đang trailing, SL chỉ tiến không lùi
bool     t1OneSide         = false; // RPA V1-R2 (Owner D1): T1 này khóa Lk* ĐƠN của epoch tập con (một phía, chỉ SL của Lk*, không TP đối ứng) — cùng một máy trạng thái T1/T2
long     g_t1OneLocks=0, g_t1OneDefer=0, g_t1OneT2=0;   // RPA V1-R2 evidence counters of the one-side T1 / T2 (never steer a decision)
string   g_t1OneDeferWhy="";

// V38 R2: manualWait / manualWaitType / Entry / Lot / Side (MỘT lệnh chốt tay, bị ghi đè khi chốt tay lệnh thứ hai) đã thay bằng hàng chờ
// nhiều bản ghi độc lập g_mr[] (OFH38_ManualRecovery.mqh).
bool     skipGridThisTick  = false; // Cấm thêm lệnh lưới trong tick này (vừa T1 / vừa chốt)

bool     sessionRescue     = false; // V38: SESSION_BASKET_RESCUE — cụm > CloseProtect_MaxOrders lúc vào 60 phút cuối, xử lý tiếp sau giờ phiên

// [FINAL STANDALONE] ===== BEGIN INLINED OFH38_Exec.mqh (HOTFIX SHA256 E1F267AB5C36592101E6C083966788924679739C0F618687E03CD8D6FE771CE3) — included from Onefxhub_v38.38_RPA.mq5:L303 =====
// OFH38_Exec.mqh — V38 R1: lớp thực thi cho các thao tác V26 (sửa SL/TP, đóng vị thế) — thay BriefPause / TradeRetcodeOk của V26.
// Không Sleep(), không vòng chờ. Mỗi yêu cầu:
//   1. kiểm tra trước: ticket còn mở; SL/TP đã đúng (nửa tick size) → KHÔNG gửi; cùng yêu cầu đang chờ xác nhận / đang backoff → KHÔNG gửi;
//      SL/TP hiện tại trong vùng freeze, hoặc mức mới vi phạm stops level với tick hiện tại → KHÔNG gửi (server chắc chắn từ chối);
//   2. gửi đồng bộ (CTrade), phân loại retcode CỦA CHÍNH yêu cầu đó theo loại thao tác (OFH38_Exec_Core);
//   3. đọc lại vị thế ĐÚNG ticket: sửa → POSITION_SL / POSITION_TP phải bằng mức yêu cầu (nửa tick size); đóng → ticket không còn,
//      hoặc khối lượng còn lại = phần dư (khớp một phần ≠ đóng xong; PLACED ≠ đóng xong);
//   4. broker đã nhận nhưng chưa thấy thay đổi (DONE chưa cập nhật / PLACED / LOCKED / TIMEOUT) → "đang bay": không gửi lại cùng yêu cầu
//      trước Exec_ConfirmMs; hết cửa sổ mà vẫn không thấy → được gửi lại (có đếm lần); R3: nếu broker còn LỆNH ĐÓNG của vị thế đó đang làm việc
//      (ORDER_POSITION_ID) → vẫn chờ, không gửi lệnh đóng thứ hai;
//   5. thất bại → backoff có trần theo loại lỗi; tối đa Exec_MaxAttempts lần / ticket → STALLED (dừng gửi Exec_StallRetryMinutes phút).
// Thời gian: tester = giờ tick ảo (time_msc); chạy thật = GetTickCount64(). Thời gian thực (CPU) đo riêng bằng GetMicrosecondCount().
// OFH38_V26_TIMING (CHỈ bản kiểm thử parity): chèn lại Sleep(30) đúng chỗ V26 có BriefPause → chứng minh logic quyết định không đổi.
#ifndef OFH38_EXEC_MQH
#define OFH38_EXEC_MQH

// [FINAL STANDALONE] ===== BEGIN INLINED OFH38_Exec_Core.mqh (HOTFIX SHA256 36A168CAC5B5F812DC51CABEEA6EEC20518C2548C5E3D60F3A269745606CE3EB) — included from OFH38_Exec.mqh:L17 =====
// OFH38_Exec_Core.mqh — V38 R1: luật thực thi THUẦN (không gọi terminal) cho lớp thực thi lệnh — unit test trong OFH38_UnitTests.mq5.
// Phân loại retcode THEO TỪNG LOẠI THAO TÁC (mở / đóng / sửa SL-TP / close-by), lịch backoff có chặn, so khớp giá theo nửa tick size,
// luật stops / freeze của MT5 cho vị thế. Không có Sleep(), không có vòng lặp chờ.
#ifndef OFH38_EXEC_CORE_MQH
#define OFH38_EXEC_CORE_MQH

#define EX38_OP_OPEN     0
#define EX38_OP_CLOSE    1
#define EX38_OP_MODIFY   2
#define EX38_OP_CLOSEBY  3

#define EXC_DONE         0   // thực hiện đủ
#define EXC_PARTIAL      1   // khớp một phần (đóng: còn phần dư)
#define EXC_INFLIGHT     2   // đã nhận, chưa thấy kết quả (PLACED / LOCKED / CLOSE_ORDER_EXIST)
#define EXC_UNKNOWN      3   // không rõ kết quả (TIMEOUT): đối soát broker trước khi gửi lại
#define EXC_NOCHANGE     4   // sửa SL/TP: server báo mức đã đúng → đọc lại để xác nhận
#define EXC_RETRY_FAST   5   // requote / đổi giá / không có giá / giá sai / bị từ chối / lỗi xử lý → backoff ngắn
#define EXC_RETRY_SLOW   6   // quá nhiều yêu cầu / mất kết nối / bị đóng băng / thiếu tiền khi đóng / không gửi được → backoff dài
#define EXC_WAIT_MARKET  7   // đóng cửa / cấm giao dịch / tắt AutoTrading → chờ lâu
#define EXC_STOPS        8   // sửa SL/TP: invalid stops (giá đã đổi / quá sát) → sớm nhất tick sau
#define EXC_GONE         9   // vị thế đã đóng / không còn
#define EXC_FATAL       10   // bản thân yêu cầu sai (khối lượng, kiểu khớp, giới hạn...) → không gửi lại y nguyên

string Ex38ClassName(const int c)
{
   switch(c)
   {
      case EXC_DONE: return "DONE";             case EXC_PARTIAL: return "PARTIAL";     case EXC_INFLIGHT: return "IN_FLIGHT";
      case EXC_UNKNOWN: return "UNKNOWN";       case EXC_NOCHANGE: return "NO_CHANGE";  case EXC_RETRY_FAST: return "RETRY_FAST";
      case EXC_RETRY_SLOW: return "RETRY_SLOW"; case EXC_WAIT_MARKET: return "WAIT_MARKET"; case EXC_STOPS: return "INVALID_STOPS";
      case EXC_GONE: return "GONE";             case EXC_FATAL: return "FATAL";
   }
   return "?";
}

// rc = MqlTradeResult.retcode của CHÍNH yêu cầu vừa gửi (0 = không tới được server / không gửi)
int Ex38Classify(const int op, const uint rc)
{
   switch(rc)
   {
      case 10009: return EXC_DONE;                                                     // DONE
      case 10010: return EXC_PARTIAL;                                                  // DONE_PARTIAL
      case 10008: return EXC_INFLIGHT;                                                 // PLACED
      case 10028: return EXC_INFLIGHT;                                                 // LOCKED (đang xử lý)
      case 10039: return (op == EX38_OP_CLOSE || op == EX38_OP_CLOSEBY) ? EXC_INFLIGHT : EXC_FATAL;   // CLOSE_ORDER_EXIST
      case 10012: return EXC_UNKNOWN;                                                  // TIMEOUT
      case 10025: return (op == EX38_OP_MODIFY) ? EXC_NOCHANGE : EXC_FATAL;            // NO_CHANGES
      case 10004: case 10020: case 10021: case 10015:                                  // REQUOTE, PRICE_CHANGED, PRICE_OFF, INVALID_PRICE
      case 10006: case 10007: case 10011: case 10023: return EXC_RETRY_FAST;           // REJECT, CANCEL, ERROR, ORDER_CHANGED
      case 10024: case 10031: case 10029: return EXC_RETRY_SLOW;                       // TOO_MANY_REQUESTS, CONNECTION, FROZEN
      case 10018: case 10017: case 10026: case 10027: return EXC_WAIT_MARKET;          // MARKET_CLOSED, TRADE_DISABLED, SERVER/CLIENT_DISABLES_AT
      case 10016: return (op == EX38_OP_MODIFY) ? EXC_STOPS : EXC_FATAL;               // INVALID_STOPS
      case 10036: return (op == EX38_OP_OPEN) ? EXC_FATAL : EXC_GONE;                  // POSITION_CLOSED
      case 10019: return (op == EX38_OP_OPEN) ? EXC_FATAL : EXC_RETRY_SLOW;            // NO_MONEY (đóng một chân hedge có thể cần ký quỹ)
      case 10038: return (op == EX38_OP_CLOSE) ? EXC_RETRY_FAST : EXC_FATAL;           // INVALID_CLOSE_VOLUME (khối lượng cũ) → đọc lại, gửi lại
      case 10044: return (op == EX38_OP_OPEN) ? EXC_FATAL : EXC_RETRY_FAST;            // CLOSE_ONLY (đóng vẫn được)
      case 0:     return EXC_RETRY_SLOW;                                               // không gửi được (mất kết nối, terminal chặn)
   }
   return EXC_FATAL;                                                                   // INVALID, INVALID_VOLUME, INVALID_FILL, LIMIT_*, ...
}

// true = lần gửi này coi như chưa thực hiện, được phép gửi lại SAU backoff
bool Ex38IsRetryClass(const int c) { return c == EXC_RETRY_FAST || c == EXC_RETRY_SLOW || c == EXC_WAIT_MARKET || c == EXC_STOPS || c == EXC_FATAL; }

// backoff (ms) sau lần thất bại thứ `attempt` (1, 2, ...) — luôn có trần, không bao giờ 0 cho lớp thử lại (1 ms = tick sau)
// WAIT_MARKET: chỉ khi lịch phiên của symbol nói đang MỞ mà server vẫn trả "market closed / trade disabled" (đóng ngoài lịch) — lịch đóng thì
// không gửi gì (OFH38_Exec). Bắt đầu 1 s để thoát nhanh khi giao dịch mở lại, gấp đôi tới trần 60 s (benchmark R1: 30 s cố định làm thoát chậm 30 s).
long Ex38BackoffMs(const int cls, const int attempt)
{
   const int a = MathMax(1, MathMin(attempt, 7));
   switch(cls)
   {
      case EXC_RETRY_FAST:  return MathMin(250L * (1L << (a - 1)), 5000L);      // 250 ms .. 5 s
      case EXC_RETRY_SLOW:  return MathMin(1000L * (1L << (a - 1)), 30000L);    // 1 s .. 30 s
      case EXC_WAIT_MARKET: return MathMin(1000L * (1L << (a - 1)), 60000L);    // 1 s .. 60 s
      case EXC_STOPS:       return 1L;                                           // tick sau
      case EXC_FATAL:       return 60000L;
   }
   return 0L;
}

// dung sai so khớp giá = nửa tick size (broker làm tròn SL/TP theo lưới tick)
double Ex38PriceTol(const double tickSize, const double point) { return MathMax(tickSize, point) * 0.5 + point * 0.001; }
// 0 = không đặt; cả hai 0 → trùng; một bên 0 → khác
bool Ex38SamePrice(const double a, const double b, const double tol)
{
   if(a <= 0.0 && b <= 0.0) return true;
   if(a <= 0.0 || b <= 0.0) return false;
   return MathAbs(a - b) <= tol;
}

// luật MT5 cho vị thế: BUY (đóng ở Bid): Bid − SL ≥ stops, TP − Bid ≥ stops; SELL (đóng ở Ask): SL − Ask ≥ stops, Ask − TP ≥ stops.
// Dùng ≥ (dễ dãi nhất) để KHÔNG BAO GIỜ bỏ một yêu cầu server sẽ nhận; chỉ chặn yêu cầu chắc chắn bị từ chối với tick hiện tại.
bool Ex38StopsValid(const bool isBuy, const double sl, const double tp, const double bid, const double ask, const double stopsDist)
{
   if(stopsDist <= 0.0) return true;
   const double e = stopsDist * 1e-6;
   if(isBuy)
   {
      if(sl > 0.0 && bid - sl < stopsDist - e) return false;
      if(tp > 0.0 && tp - bid < stopsDist - e) return false;
      return true;
   }
   if(sl > 0.0 && sl - ask < stopsDist - e) return false;
   if(tp > 0.0 && ask - tp < stopsDist - e) return false;
   return true;
}
// freeze level: vị thế có SL/TP HIỆN TẠI nằm trong vùng freeze quanh giá thị trường thì không được sửa
bool Ex38Frozen(const bool isBuy, const double curSl, const double curTp, const double bid, const double ask, const double freezeDist)
{
   if(freezeDist <= 0.0) return false;
   if(isBuy)
   {
      if(curSl > 0.0 && bid - curSl <= freezeDist) return true;
      if(curTp > 0.0 && curTp - bid <= freezeDist) return true;
      return false;
   }
   if(curSl > 0.0 && curSl - ask <= freezeDist) return true;
   if(curTp > 0.0 && ask - curTp <= freezeDist) return true;
   return false;
}

#endif
// [FINAL STANDALONE] ===== END INLINED OFH38_Exec_Core.mqh =====
// [SAFETY CORE BEGIN] ===================================================================================================================================
// FINAL STANDALONE SAFETY CORRECTION (Owner 02/11/2026): PURE decision rules of the execution-safety fixes (no order, no EA global). The unit tests
// (tests/OFH38_SAFETY_UnitTests.mq5) compile the text of THIS block, extracted from this file, with the Exec / RPA / OWNER12 cores of this file.
// The only terminal calls of the block are the GlobalVariable helpers of the entry record (Saf38EntryRecSave / Saf38EntryRecLoad: persistence, never an order).

#define SAF_UNKNOWN_RESOLVE_SEC 300   // an entry request without a broker result is "not executed" only after N s with no working order, no deal, no position and the
                                      // terminal connected (same value and rule as RPA_UNKNOWN_RESOLVE_SEC of the RPA executor, TPC3)

// ---------------------------------------------------------------- S01 close request of the RPA executor (B01 / Atlas F03)
#define SAF_CR_ACCEPTED 0   // DONE / DONE_PARTIAL / PLACED: broker evidence (deal, live volume, order state) resolves it
#define SAF_CR_UNKNOWN  1   // no reliable result: reconcile only, never a second request before broker evidence
#define SAF_CR_REJECTED 2   // definite rejection, nothing executed: requested again from the live volume after a bounded backoff
// The HOTFIX RpaRcDefinite treated LOCKED (10028, request locked for processing) and CLOSE_ORDER_EXIST (10039, a close order already exists for the position) as
// definite rejections and re-sent the close on the next tick, while the execution layer (Ex38Classify) treats both as IN FLIGHT. Both are UNKNOWN here; every other
// code keeps its HOTFIX class (a code the HOTFIX did not list was already UNKNOWN).
int Saf38CloseRcClass(const uint rc)
{
   switch(rc)
   {
      case 10009: case 10010: case 10008: return SAF_CR_ACCEPTED;                       // DONE, DONE_PARTIAL, PLACED
      case 10006: case 10007: case 10013: case 10014: case 10015: case 10016:          // REJECT, CANCEL, INVALID, INVALID_VOLUME, INVALID_PRICE, INVALID_STOPS
      case 10017: case 10018: case 10019: case 10020: case 10021: case 10004:          // TRADE_DISABLED, MARKET_CLOSED, NO_MONEY, PRICE_CHANGED, PRICE_OFF, REQUOTE
      case 10030: case 10034: case 10036: case 10024: case 10029: case 10035:          // INVALID_FILL, LIMIT_VOLUME, POSITION_CLOSED, TOO_MANY_REQUESTS, FROZEN, INVALID_ORDER
         return SAF_CR_REJECTED;
   }
   return SAF_CR_UNKNOWN;   // 10028 LOCKED, 10039 CLOSE_ORDER_EXIST, 10012 TIMEOUT, 10031 CONNECTION, 10011 ERROR, 10023 ORDER_CHANGED, 0 (no answer), unlisted
}
// next close request of the executor after a definite rejection: not before the bounded backoff of the execution layer for that close class; an invalid request
// (FATAL) or a gone position keeps the HOTFIX pace (next tick): it cannot succeed later, so the RPA_MAX_ATTEMPTS HALT (HALTED: T1 / T2 protection) is not delayed
long Saf38CloseRetryAtMs(const long nowMs, const uint rc, const int attempt)
{
   const int c = Ex38Classify(EX38_OP_CLOSE, rc);
   if(c == EXC_FATAL || c == EXC_GONE) return nowMs;
   return nowMs + Ex38BackoffMs(c, attempt);
}
// a close order of a basket position working at the broker for longer than the resolve window while a rebase executes -> the rebase cannot be reconciled (HALT)
bool Saf38CowTimedOut(const long sinceMs, const long nowMs, const long resolveMs) { return sinceMs > 0 && nowMs - sinceMs >= resolveMs; }
// close volume of one request: positive and never above the live volume of the position (half volume step tolerance); false = re-plan from the broker, no request
bool Saf38CloseVolumeOk(const double vol, const double liveVol, const double step) { const double s = step > 0.0 ? step : 0.01; return vol > s * 0.5 && vol <= liveVol + s * 0.5; }
// the executor sends only when no position of the basket has a close order working at the broker (manual, broker or an earlier request: its fill changes the
// live volumes the next close is planned from) and the backoff of a definite rejection is over
bool Saf38RpaMaySend(const bool closeOrderWorking, const long nowMs, const long retryAtMs) { return !closeOrderWorking && nowMs >= retryAtMs; }

// ---------------------------------------------------------------- S02 / S03 entry request: L1 / grid / subgrid (TrySendOrder), DD hedge (B02 / Atlas F04)
#define SAF_OR_DONE      0   // DONE / DONE_PARTIAL: the position exists -> the V26 count guard (LastSent*) takes over
#define SAF_OR_PLACED    1   // accepted, the order works at the broker: never replaced while it works
#define SAF_OR_UNKNOWN   2   // ambiguous: no second entry before broker evidence
#define SAF_OR_REJECTED  3   // definite rejection, nothing executed: V26 behaviour (requested again on a later tick, e.g. "market closed" at the session start)
#define SAF_OR_THROTTLED 4   // TOO_MANY_REQUESTS: definite, requested again only after a backoff
#define SAF_OR_NOTSENT   5   // OrderSend was not reached (the request never left the terminal): nothing executed
int Saf38OpenRcClass(const bool sent, const uint rc)
{
   if(!sent) return SAF_OR_NOTSENT;
   switch(rc)
   {
      case 10009: case 10010: return SAF_OR_DONE;
      case 10008: return SAF_OR_PLACED;
      case 10024: return SAF_OR_THROTTLED;
      case 10004: case 10006: case 10007: case 10013: case 10014: case 10015: case 10016: case 10017: case 10018: case 10019: case 10020: case 10021: case 10022:
      case 10025: case 10026: case 10027: case 10029: case 10030: case 10032: case 10033: case 10034: case 10035: case 10036: case 10038: case 10039: case 10040:
      case 10041: case 10042: case 10043: case 10044: case 10045: case 10046:
         return SAF_OR_REJECTED;   // the server refused the request (requote / price / invalid / no money / market closed / disabled / limits / frozen / close only ...)
   }
   return SAF_OR_UNKNOWN;          // 10012 TIMEOUT, 10031 CONNECTION, 10011 ERROR, 10023 ORDER_CHANGED, 10028 LOCKED, 0 (sent, no retcode), unlisted
}
#define SAF_ER_WAIT     0   // no evidence yet: no second request
#define SAF_ER_EXECUTED 1   // filled: its position is listed (or already closed) -> never re-sent; the count / level guards take over
#define SAF_ER_NOTEXEC  2   // proven not executed: may be requested again
// broker evidence of ONE entry request without a reliable result (gathered by the caller from the terminal):
//   dealIn       an entry deal of the request (its order ticket; without a ticket: an entry deal of its magic on the symbol since the request, recovery tags excluded)
//   posListed    the position of the request (id = its order ticket, or the position of that deal) is listed now
//   posClosed    that position already has a closing deal
//   orderWorking the order of the request, or an order of its magic on the symbol, still works at the broker
//   histState    order history of the request: -1 no order ticket / not found, 0 filled (partly or fully), 1 cancelled / rejected / expired
//   elapsedMs    since the request (server tick time); resolveMs = SAF_UNKNOWN_RESOLVE_SEC x 1000; connected = terminal connected to the trade server
int Saf38EntryResolve(const bool dealIn, const bool posListed, const bool posClosed, const bool orderWorking, const int histState, const long elapsedMs, const long resolveMs,
                      const bool connected)
{
   if(dealIn || histState == 0) return (posListed || posClosed) ? SAF_ER_EXECUTED : SAF_ER_WAIT;   // filled: never re-sent (waits until its position is visible)
   if(posListed || posClosed) return SAF_ER_EXECUTED;                                               // its position is listed / already closed (entry deal not readable yet)
   if(orderWorking) return SAF_ER_WAIT;
   if(histState == 1) return SAF_ER_NOTEXEC;                                                        // cancelled / rejected / expired without a deal
   if(connected && elapsedMs >= resolveMs) return SAF_ER_NOTEXEC;                                   // no order, no deal, no position for the whole window
   return SAF_ER_WAIT;
}
string Saf38ErName(const int r) { return r == SAF_ER_WAIT ? "WAIT_BROKER_EVIDENCE" : (r == SAF_ER_EXECUTED ? "EXECUTED" : (r == SAF_ER_NOTEXEC ? "NOT_EXECUTED" : "?")); }
// a deal belongs to a request WITHOUT an order ticket only if it is newer than every entry deal of that magic seen right BEFORE the request (deal tickets of a trade
// server only grow: watermark wm) and not older than the window — an earlier fill (e.g. the previous grid level 0.6 s before) is never taken as this request's fill
bool Saf38DealIsOfRequest(const ulong dealTicket, const ulong wm, const long dealMsc, const long reqMsc) { return dealTicket > wm && dealMsc >= reqMsc - (long)SAF_UNKNOWN_RESOLVE_SEC * 1000; }
// the entry request record (one at a time: no further entry request while it exists): st 0 = none, 1 = UNKNOWN (sent, no reliable result),
// 2 = SENDING (written BEFORE the request; a record still SENDING at a restart = the EA stopped during the request -> treated as UNKNOWN)
struct Saf38EntryRec { int st; ulong ord; long msc; int cnt; uint rc; ulong mg; ulong wm; };
void Saf38EntryRecReset(Saf38EntryRec &r) { r.st = 0; r.ord = 0; r.msc = 0; r.cnt = 0; r.rc = 0; r.mg = 0; r.wm = 0; }
void Saf38EntryRecSave(const string ns, const Saf38EntryRec &r)
{
   GlobalVariablesDeleteAll(ns);
   if(r.st != 0)
   {
      GlobalVariableSet(ns + "st", r.st); GlobalVariableSet(ns + "o", (double)r.ord); GlobalVariableSet(ns + "m", (double)r.msc);
      GlobalVariableSet(ns + "c", r.cnt); GlobalVariableSet(ns + "r", (double)r.rc); GlobalVariableSet(ns + "g", (double)r.mg); GlobalVariableSet(ns + "w", (double)r.wm);
   }
   GlobalVariablesFlush();
}
bool Saf38EntryRecLoad(const string ns, Saf38EntryRec &r)
{
   Saf38EntryRecReset(r);
   if(!GlobalVariableCheck(ns + "st") || !GlobalVariableCheck(ns + "m") || !GlobalVariableCheck(ns + "g") || !GlobalVariableCheck(ns + "w")) return false;
   r.st = (int)GlobalVariableGet(ns + "st"); r.ord = (ulong)GlobalVariableGet(ns + "o"); r.msc = (long)GlobalVariableGet(ns + "m");
   r.cnt = (int)GlobalVariableGet(ns + "c"); r.rc = (uint)GlobalVariableGet(ns + "r"); r.mg = (ulong)GlobalVariableGet(ns + "g"); r.wm = (ulong)GlobalVariableGet(ns + "w");
   return (r.st == 1 || r.st == 2) && r.msc > 0;
}
// S03 a DD compression leg / close-by accepted without a broker result (vol0 = position volume before the request): never sent again before broker evidence —
// a close order of the position still works -> wait; the volume went down -> executed (the pair is re-planned from the live volumes); else not executed only
// after the resolve window, terminal connected (HOTFIX: re-sent after Exec_ConfirmMs = 1 s -> a late fill of a PARTIAL close over-closed the position)
int Saf38LegResolve(const double vol0, const double liveVol, const bool closeOrderWorking, const long elapsedMs, const long resolveMs, const bool connected, const double tol)
{
   if(closeOrderWorking) return SAF_ER_WAIT;
   if(liveVol < vol0 - tol) return SAF_ER_EXECUTED;
   if(connected && elapsedMs >= resolveMs) return SAF_ER_NOTEXEC;
   return SAF_ER_WAIT;
}

// ---------------------------------------------------------------- S05 recovery request gate (B06 / Atlas F02): the HOTFIX owners + a rebase / RPA request in flight
bool Saf38MrSendAllowed(const bool ddActive, const bool exitActive, const bool pairPending, const bool t1Lock, const bool trailActive, const bool rpaInFlight)
{
   return !(ddActive || exitActive || pairPending || t1Lock || trailActive || rpaInFlight);
}

// ---------------------------------------------------------------- S06 manual-recovery record at a restart + orphan guard (B07 / Atlas F12d)
#define SAF_MRR_RESTORE          0   // same cycle, re-entry on: restored as it was (HOTFIX)
#define SAF_MRR_CANCEL           1   // nothing in flight: cancelled, receipt kept (HOTFIX)
#define SAF_MRR_CANCEL_RECONCILE 2   // in flight, its cycle is over (or already CANCEL_RECONCILE): a fill is an orphan of a finished cycle (HOTFIX)
#define SAF_MRR_RECONCILE_ONLY   3   // in flight, SAME open cycle, re-entry switched off: never requested again, a fill is a position of the running basket
int Saf38MrRestoreAction(const bool sameCycle, const bool reentryOn, const bool inFlight, const bool alreadyCancelReconcile)
{
   if(sameCycle && reentryOn) return SAF_MRR_RESTORE;
   if(!inFlight) return SAF_MRR_CANCEL;
   if(alreadyCancelReconcile || !sameCycle) return SAF_MRR_CANCEL_RECONCILE;
   return SAF_MRR_RECONCILE_ONLY;
}
#define SAF_ORPH_NONE         0
#define SAF_ORPH_CLOSE_BASKET 1   // every open position of the EA is an orphan fill of a finished cycle: the basket exit closes them (HOTFIX behaviour)
#define SAF_ORPH_KEEP         2   // other positions of a running basket are open: the basket is never closed for an orphan record (the record -> RECONCILE_ONLY)
int Saf38OrphanAction(const int openPositions, const int orphanPositions)
{
   if(orphanPositions <= 0) return SAF_ORPH_NONE;
   return orphanPositions >= openPositions ? SAF_ORPH_CLOSE_BASKET : SAF_ORPH_KEEP;
}

// ---------------------------------------------------------------- S07 inputs OnInit did not check (B07 / Atlas F11): a wrong value no longer starts the EA
string Saf38InputsError(const ulong magic, const double initLot, const double multi, const double &g[], const int ng, const double tpPips, const int serverGmt, const int localGmt)
{
   if(magic == 0) return "Magic=0 (positions opened by hand carry magic 0: the EA would take them as its own basket)";
   if(!(initLot > 0.0)) return StringFormat("Initial_Lot=%.4f must be > 0", initLot);
   if(!(multi > 0.0)) return StringFormat("Lot_Multi=%.4f must be > 0", multi);
   for(int i = 0; i < ng; i++) if(!(g[i] >= 0.0)) return StringFormat("G%d=%.2f must be >= 0 pip", i + 1, g[i]);
   if(!(tpPips >= 0.0)) return StringFormat("TP_Pips=%.2f must be >= 0", tpPips);
   if(serverGmt < -12 || serverGmt > 14 || localGmt < -12 || localGmt > 14) return StringFormat("ServerGMT=%d / LocalGMT=%d must be in -12..14", serverGmt, localGmt);
   return "";
}

// ---------------------------------------------------------------- S08 records are written only by a run whose restore happened (B08 / Atlas F12a)
// OnDeinit(REASON_INITFAILED) follows a failed OnInit (no record was restored: memory holds defaults) and a run whose account was never known did not restore either:
// writing then would overwrite / delete the records of the open basket
bool Saf38MayPersist(const int deinitReason, const bool restorePending) { return deinitReason != REASON_INITFAILED && !restorePending; }

// ---------------------------------------------------------------- S09 GLOBAL frozen range rebuilt without tick history (B09 / Atlas F10): widened, never narrowed
void Saf38WidenRange(double &hi, double &lo, const double histHi, const double histLo)
{
   if(histHi > hi) hi = histHi;
   if(histLo > 0.0 && (lo <= 0.0 || histLo < lo)) lo = histLo;
}

// ---------------------------------------------------------------- S10 level book in a rebased cycle (B10 / Atlas F09)
// once a BasketCycleID had a rebase (epoch >= 1, a committed rebase, a HALT after a rebase: RpaHadAny), every position the level book does not hold and that is not a
// recovery re-entry is an RPA position (Lk* / additional order of an epoch, counted by RpaSyncSubgrid / the rebase executor) — never an unknown position of the
// ORIGINAL level book (HOTFIX: MrFreezeGrid at the first subgrid fill, at the next rebase or at a restart when the book was ON: the epoch never reached +12)
bool Saf38LbRpaOwned(const bool rpaRebasedCycle, const bool recoveryTag) { return rpaRebasedCycle && !recoveryTag; }

// ---------------------------------------------------------------- S11 rebase margin gate (B11 / Atlas F06): no broker margin per lot -> the gate cannot be evaluated
bool Saf38MarginModelOk(const bool gateOn, const double marginBuyPerLot, const double marginSellPerLot) { return !gateOn || (marginBuyPerLot > 0.0 && marginSellPerLot > 0.0); }

// ---------------------------------------------------------------- S12 (R1) two-side T1: declared only on broker-confirmed protection (B04, Owner 03/11/2026)
// The two-side T1 lock (ApplyClusterExit) puts the SAME exit level px on the whole basket: SL on every position of the net side, TP on every position of the other side.
// Protection is confirmed when the broker SHOWS every such level at px — or beyond it in the trail direction (the forward-only rule of MoveSideSl / MoveSideTp:
// net BUY >= px, net SELL <= px), tolerance half a tick. n = 0, netDir = 0 or px <= 0 -> not confirmed.
bool Saf38T1ProtectionOk(const int netDir, const double px, const double tol, const int n, const int &side[], const double &sl[], const double &tp[])
{
   if(netDir == 0 || !(px > 0.0) || n <= 0) return false;
   for(int i = 0; i < n; i++)
   {
      const double lv = (side[i] == netDir) ? sl[i] : tp[i];
      if(!(lv > 0.0)) return false;
      if(netDir > 0 ? (lv < px - tol) : (lv > px + tol)) return false;
   }
   return true;
}

// ---------------------------------------------------------------- S13 (R1) basket exit close: no second request before the earlier one is reconciled (B03 / Owner 03/11/2026)
#define SAF_CLR_WAIT 0   // the earlier close request of this position is not reconciled: no new request
#define SAF_CLR_SEND 1   // reconciled: a new close request for the LIVE volume of the position is allowed
// closeOrderWorking: a close order of the position works at the broker; dealSinceReq: a closing deal OF THIS REQUEST (its order ticket, or newer than the deals known
// before it when the reply had no order ticket) — executed, in part: the live volume is what remains; histState: order history of THIS request (-1 no trace / no order
// ticket, 0 filled or partly filled, 1 cancelled / rejected / expired); elapsedMs since the request; confirmMs = Exec_ConfirmMs; resolveMs = SAF_UNKNOWN_RESOLVE_SEC x
// 1000; connected = terminal connected to the trade server.
// Reconciled = a closing deal of the request, or its order cancelled / rejected / expired, or (no trace of it at all) resolveMs passed with no close order working while
// connected (the "not executed" evidence rule of an entry request, S03). FILLED in the history without a visible deal is EXECUTED: never a second request (the deal /
// position update follows). The path is reached only after a reply that was not a definite rejection (DONE / PARTIAL / IN FLIGHT / UNKNOWN / GONE) while the broker
// still lists the position, or after a close order of the position worked; a definite rejection keeps the bounded backoff of the HOTFIX.
// A close by position ticket can never close more than the live volume (hedging account): the rule removes the unreconciled duplicate request.
int Saf38CloseResendDecision(const bool closeOrderWorking, const bool dealSinceReq, const int histState, const long elapsedMs, const long confirmMs, const long resolveMs, const bool connected)
{
   if(elapsedMs < confirmMs) return SAF_CLR_WAIT;
   if(closeOrderWorking) return SAF_CLR_WAIT;
   if(dealSinceReq) return SAF_CLR_SEND;                                   // reconciled by the deal of this request: only the remaining live volume is requested
   if(histState == 1) return SAF_CLR_SEND;                                 // reconciled: cancelled / rejected / expired at the broker
   if(histState == 0) return SAF_CLR_WAIT;                                 // FILLED: executed — the deal / position update follows, never a second request
   if(elapsedMs < resolveMs || !connected) return SAF_CLR_WAIT;            // no trace yet / not connected: not reconciled
   return SAF_CLR_SEND;                                                    // resolveMs connected, no working order, no deal, no order: not executed
}
// [SAFETY CORE END] =====================================================================================================================================

// [SAFETY STATE] ===== globals + terminal glue of the safety rules (evidence collection, records, logs) — not part of the pure core =====
bool   g_safSendHeld = false;          // S02: TrySendOrder held this call (no request): no subgrid journal row for it
long   g_rpRetryAtMs = 0;              // S01: next RPA close request not before (bounded backoff after a definite rejection)
long   g_ddlInflightTickMsc = 0;       // S03: server tick time of the in-flight / unknown DD hedge request (0 = none)
ulong  g_ddlInflightWm = 0;            // S03: entry-deal watermark of the hedge magic taken right before that request
ulong  g_ddlLegTk = 0; long g_ddlLegMsc = 0; double g_ddlLegVol0 = 0.0;   // S03: DD compression leg / close-by accepted without a broker result
long   g_rpCowSinceMs = 0;             // S01: first tick of the current close-order-working wait of the rebase executor
bool   g_lbSyncAfterRpa = false;       // S10: the level book restored ON is synced after RpaRestore (RPA positions are known then)
Saf38EntryRec g_seRec;                 // S02: entry request without a reliable result (persisted in OFH38Q)
long   g_seNextMs = 0; int g_seThrottleN = 0;   // S02: TOO_MANY_REQUESTS backoff of the entry path
long   g_safHoldWorking = 0, g_safHoldUnknown = 0, g_safHoldThrottle = 0, g_safUnknownSet = 0, g_safExecuted = 0, g_safNotExec = 0, g_safPlacedWait = 0;
long   g_safRpaCowWait = 0, g_safRpaBackoffWait = 0, g_safRpaVolGuard = 0, g_safDdlWait = 0, g_safOrphanKeep = 0, g_safMrReconcileOnly = 0, g_safLbSubgrid = 0;
long   g_safMarginBlocked = 0, g_safMrGate = 0, g_safScanHalt = 0, g_safNoPersist = 0, g_safCowHalt = 0, g_safRebaseWaitEntry = 0;
long   g_safT1Pending = 0, g_safT1LateDeclared = 0, g_safExClWait = 0, g_safExClWorking = 0;   // R1: S12 / S13 evidence counters (T1 pending / close waits = tick evaluations)
long   g_safT1PendEp = 0, g_safT1PendCyc = 0, g_safExClFilledHold = 0;                          // R1: S12 pending episodes (cycles) / S13 FILLED-without-deal holds past the resolve time
string g_safOnce = "";
void   SafLogOnce(const string key, const string text) { const string k = "|" + key + "|"; if(StringFind(g_safOnce, k) >= 0) return; g_safOnce += k; if(StringLen(g_safOnce) > 6000) g_safOnce = k; Print(text); }
string SafEntryNs() { return OfhNs("OFH38Q", Magic); }
// a Magic order of the symbol working at the broker (0 = none)
ulong  SafWorkingMagicOrder()
{
   for(int k = OrdersTotal() - 1; k >= 0; k--)
   {
      const ulong t = OrderGetTicket(k);
      if(t != 0 && OrderGetString(ORDER_SYMBOL) == _Symbol && (ulong)OrderGetInteger(ORDER_MAGIC) == Magic) return t;
   }
   return 0;
}
// S02 / S03: highest entry-deal ticket of magic mg on the symbol right BEFORE a request (watermark: a deal of a request without an order ticket must be newer)
ulong  SafEntryWatermark(const ulong mg)
{
   ulong wm = 0;
   if(!HistorySelect(TimeCurrent() - SAF_UNKNOWN_RESOLVE_SEC - 60, TimeCurrent() + 60)) return 0;
   const int total = HistoryDealsTotal();
   for(int k = 0; k < total; k++)
   {
      const ulong d = HistoryDealGetTicket(k);
      if(d == 0 || d <= wm || HistoryDealGetString(d, DEAL_SYMBOL) != _Symbol || (ulong)HistoryDealGetInteger(d, DEAL_MAGIC) != mg) continue;
      const long en = HistoryDealGetInteger(d, DEAL_ENTRY);
      if(en == DEAL_ENTRY_IN || en == DEAL_ENTRY_INOUT) wm = d;
   }
   return wm;
}
// S02 / S03: broker evidence of one entry request (magic mg, order ord (0 = unknown), request at sinceMsc, watermark wm when ord = 0)
void SafEntryEvidence(const ulong mg, const ulong ord, const long sinceMsc, const ulong wm, bool &dealIn, bool &posListed, bool &posClosed, bool &working, int &hist)
{
   dealIn = false; posListed = false; posClosed = false; working = false; hist = -1;
   for(int k = OrdersTotal() - 1; k >= 0 && !working; k--)
   {
      const ulong t = OrderGetTicket(k);
      if(t != 0 && (t == ord || (OrderGetString(ORDER_SYMBOL) == _Symbol && (ulong)OrderGetInteger(ORDER_MAGIC) == mg))) working = true;
   }
   ulong pid = ord;   // the position opened by an order carries the order ticket as POSITION_IDENTIFIER
   if(ord != 0 && HistoryOrderSelect(ord))
   {
      const long os = HistoryOrderGetInteger(ord, ORDER_STATE);
      if(os == ORDER_STATE_FILLED || os == ORDER_STATE_PARTIAL) hist = 0;
      else if(os == ORDER_STATE_CANCELED || os == ORDER_STATE_REJECTED || os == ORDER_STATE_EXPIRED) hist = 1;
   }
   const long from = sinceMsc > 0 ? sinceMsc : 0;
   if(HistorySelect((datetime)(from / 1000) - 5, TimeCurrent() + 60))
   {
      const int total = HistoryDealsTotal();
      for(int k = 0; k < total && !dealIn; k++)
      {
         const ulong d = HistoryDealGetTicket(k);
         if(d == 0 || HistoryDealGetString(d, DEAL_SYMBOL) != _Symbol) continue;
         const long en = HistoryDealGetInteger(d, DEAL_ENTRY);
         if(en != DEAL_ENTRY_IN && en != DEAL_ENTRY_INOUT) continue;
         if(ord != 0) { if((ulong)HistoryDealGetInteger(d, DEAL_ORDER) != ord) continue; }
         else
         {
            if(from <= 0 || (ulong)HistoryDealGetInteger(d, DEAL_MAGIC) != mg || !Saf38DealIsOfRequest(d, wm, HistoryDealGetInteger(d, DEAL_TIME_MSC), from)) continue;
            if(StringFind(HistoryDealGetString(d, DEAL_COMMENT), "R2MR|") == 0) continue;   // a recovery re-entry is not this request
         }
         dealIn = true; pid = (ulong)HistoryDealGetInteger(d, DEAL_POSITION_ID);
      }
      if(pid != 0)
         for(int k = 0; k < total && !posClosed; k++)
         {
            const ulong d = HistoryDealGetTicket(k);
            if(d == 0 || (ulong)HistoryDealGetInteger(d, DEAL_POSITION_ID) != pid) continue;
            const long en = HistoryDealGetInteger(d, DEAL_ENTRY);
            if(en == DEAL_ENTRY_OUT || en == DEAL_ENTRY_OUT_BY) posClosed = true;
         }
   }
   if(pid != 0)
      for(int i = PositionsTotal() - 1; i >= 0 && !posListed; i--)
      {
         const ulong t = PositionGetTicket(i);
         if(t != 0 && PositionSelectByTicket(t) && (ulong)PositionGetInteger(POSITION_IDENTIFIER) == pid) posListed = true;
      }
}
// S02: intent written and flushed BEFORE the entry request (a stop of the terminal during OrderSend leaves a SENDING record: resolved by broker evidence at restart)
void SafEntryIntent(const int cnt)
{
   g_seRec.st = 2; g_seRec.ord = 0; g_seRec.msc = Ex38TickMsc(); g_seRec.cnt = cnt; g_seRec.rc = 0; g_seRec.mg = Magic; g_seRec.wm = SafEntryWatermark(Magic);
   const string ns = SafEntryNs(); Saf38EntryRecSave(ns, g_seRec); OfhIdStore(ns, Magic); GlobalVariablesFlush();
}
void SafEntryClear() { Saf38EntryRecReset(g_seRec); Saf38EntryRecSave(SafEntryNs(), g_seRec); }
// S02: an entry request had an ambiguous result -> the intent record becomes UNKNOWN (persisted) before anything else may be sent
void SafEntrySetUnknown(const int cnt, const ulong ord, const uint rc)
{
   if(g_seRec.st != 2) { g_seRec.msc = Ex38TickMsc(); g_seRec.wm = 0; }   // no intent record (cannot happen from TrySendOrder): the window starts now
   g_seRec.st = 1; g_seRec.ord = ord; g_seRec.cnt = cnt; g_seRec.rc = rc; g_seRec.mg = Magic; g_safUnknownSet++;
   const string ns = SafEntryNs(); Saf38EntryRecSave(ns, g_seRec); OfhIdStore(ns, Magic); GlobalVariablesFlush();
   PrintFormat("SAFETY ENTRY UNKNOWN | request for position #%d rc=%u (%s) order %I64u: the broker result is not known -> no further L1 / grid / subgrid request until broker evidence (deal newer than %I64u / order history) or %d s with no order, no deal, no position",
               cnt, rc, trade.ResultComment(), ord, g_seRec.wm, SAF_UNKNOWN_RESOLVE_SEC);
}
// S02: result of an entry send (TrySendOrder): UNKNOWN -> record kept as UNKNOWN; anything else -> intent cleared (DONE / PLACED: the V26 LastSent* guard and the
// working-order hold take over; definite rejection: V26 next tick; TOO_MANY_REQUESTS: bounded backoff)
void SafEntryAfterSend(const int cls, const int cnt)
{
   if(cls == SAF_OR_UNKNOWN) { SafEntrySetUnknown(cnt, trade.ResultOrder(), trade.ResultRetcode()); return; }
   SafEntryClear();
   if(cls == SAF_OR_DONE || cls == SAF_OR_PLACED) { g_seThrottleN = 0; return; }
   if(cls == SAF_OR_THROTTLED)
   {
      g_seThrottleN++; g_seNextMs = Ex38NowMs() + Ex38BackoffMs(EXC_RETRY_SLOW, g_seThrottleN);
      PrintFormat("SAFETY ENTRY THROTTLED | TOO_MANY_REQUESTS for position #%d -> next entry request after %I64d ms (attempt %d)", cnt, g_seNextMs - Ex38NowMs(), g_seThrottleN);
   }
}
// S02: true = no entry request now (a Magic order works at the broker / an entry request has no broker result / the TOO_MANY_REQUESTS backoff runs)
bool SafEntryHold()
{
   g_safSendHeld = false;
   const ulong wo = SafWorkingMagicOrder();
   if(wo != 0)
   {
      g_safHoldWorking++; g_safSendHeld = true;
      SafLogOnce("SEWORK_" + IntegerToString((long)wo), StringFormat("SAFETY ENTRY HOLD | Magic order %I64u still works at the broker (PLACED / not filled yet): no new L1 / grid / subgrid request and no replacement order until its result is known", wo));
      return true;
   }
   if(Ex38NowMs() < g_seNextMs) { g_safHoldThrottle++; g_safSendHeld = true; return true; }
   if(g_seRec.st == 0) return false;
   bool d, pl, pc, w; int h;
   SafEntryEvidence(g_seRec.mg, g_seRec.ord, g_seRec.msc, g_seRec.wm, d, pl, pc, w, h);
   const long el = Ex38TickMsc() - g_seRec.msc;
   const int r = Saf38EntryResolve(d, pl, pc, w, h, el, (long)SAF_UNKNOWN_RESOLVE_SEC * 1000, TerminalInfoInteger(TERMINAL_CONNECTED) != 0);
   if(r == SAF_ER_WAIT)
   {
      g_safHoldUnknown++; g_safSendHeld = true;
      SafLogOnce("SEUNK_" + IntegerToString(g_seRec.msc), StringFormat("SAFETY ENTRY HOLD | entry request for position #%d (order %I64u, rc %u) has no broker result: NO second request (deal %d, position listed %d / closed %d, order working %d, order history %d) - resolved by broker evidence or after %d s with no order, no deal, no position",
                                                                       g_seRec.cnt, g_seRec.ord, g_seRec.rc, d, pl, pc, w, h, SAF_UNKNOWN_RESOLVE_SEC));
      return true;
   }
   if(r == SAF_ER_EXECUTED) g_safExecuted++; else g_safNotExec++;
   PrintFormat("SAFETY ENTRY RESOLVED %s | entry request for position #%d (order %I64u, rc %u) after %I64d ms: deal %d, position listed %d / closed %d, order working %d, order history %d%s",
               Saf38ErName(r), g_seRec.cnt, g_seRec.ord, g_seRec.rc, el, d, pl, pc, w, h, r == SAF_ER_EXECUTED ? " - never re-sent; the position count / level book decides the next level" : " - may be requested again");
   SafEntryClear();
   return false;
}
// S02: restart — the entry request without a broker result recorded before the restart (identity of this account / server / symbol / Magic); a SENDING record =
// the EA stopped during the request -> UNKNOWN (broker evidence decides)
void SafEntryRestore()
{
   Saf38EntryRecReset(g_seRec); g_seNextMs = 0; g_seThrottleN = 0;
   const string ns = SafEntryNs();
   if(!GlobalVariableCheck(ns + "st")) return;
   if(OfhIdCheck(ns, Magic) != "" || !Saf38EntryRecLoad(ns, g_seRec) || g_seRec.mg != (ulong)(double)Magic)
   {
      PrintFormat("SAFETY ENTRY RECORD %s IGNORED | identity / content mismatch - cleared", ns);
      Saf38EntryRecReset(g_seRec); GlobalVariablesDeleteAll(ns); GlobalVariablesFlush();
      return;
   }
   const bool sending = (g_seRec.st == 2);
   g_seRec.st = 1; g_seRec.mg = Magic;
   PrintFormat("SAFETY ENTRY RESTORED | entry request for position #%d (order %I64u, rc %u, tick %I64d)%s had no broker result before the restart: no further entry request until broker evidence",
               g_seRec.cnt, g_seRec.ord, g_seRec.rc, g_seRec.msc, sending ? " was being SENT when the EA stopped" : "");
}
// S13 (R1): broker evidence of THE earlier close request of the position with identifier posId (POSITION_IDENTIFIER): order ord (0 = the reply carried no order
// ticket), request at reqMsc, dwm = highest closing-deal ticket of this position known BEFORE that request (replies / evidence of earlier requests). Only the evidence
// of this request counts: a closing deal of order ord (ord known) or a closing deal newer than dwm (ord unknown); the history state of order ord (ord unknown -> -1, no
// identity: another order of the position never stands in for it). po1 / po2 = order tickets of the two previous requests of this record: with ord unknown, their
// deals (e.g. the second deal of an earlier fill split over several deals) never count. dealSeen = highest matching deal ticket. The order state is read with
// HistoryOrderSelect (independent of the time window: an adopted working order may have been set up long before reqMsc).
void SafCloseEvidence(const ulong posId, const ulong ord, const long reqMsc, const ulong dwm, const ulong po1, const ulong po2, bool &dealSince, int &hist, ulong &dealSeen)
{
   dealSince = false; hist = -1; dealSeen = 0;
   if(reqMsc <= 0) return;
   if(HistorySelect((datetime)(reqMsc / 1000) - 5, TimeCurrent() + 60))
   {
      const int nd = HistoryDealsTotal();
      for(int k = 0; k < nd; k++)
      {
         const ulong d = HistoryDealGetTicket(k);
         if(d == 0 || (ulong)HistoryDealGetInteger(d, DEAL_POSITION_ID) != posId) continue;
         const long en = HistoryDealGetInteger(d, DEAL_ENTRY);
         if(en != DEAL_ENTRY_OUT && en != DEAL_ENTRY_OUT_BY && en != DEAL_ENTRY_INOUT) continue;
         const ulong dord = (ulong)HistoryDealGetInteger(d, DEAL_ORDER);
         if(ord != 0 ? (dord != ord) : (d <= dwm || HistoryDealGetInteger(d, DEAL_TIME_MSC) < reqMsc - 1000 || (po1 != 0 && dord == po1) || (po2 != 0 && dord == po2))) continue;
         dealSince = true; if(d > dealSeen) dealSeen = d;
      }
   }
   if(ord != 0 && HistoryOrderSelect(ord))
   {
      const long os = HistoryOrderGetInteger(ord, ORDER_STATE);
      if(os == ORDER_STATE_FILLED || os == ORDER_STATE_PARTIAL) hist = 0;
      else if(os == ORDER_STATE_CANCELED || os == ORDER_STATE_REJECTED || os == ORDER_STATE_EXPIRED) hist = 1;
   }
}
// R1: true the first time `key` is seen (same memory as SafLogOnce)
bool SafFirst(const string key) { const string k = "|" + key + "|"; if(StringFind(g_safOnce, k) >= 0) return false; g_safOnce += k; if(StringLen(g_safOnce) > 6000) g_safOnce = k; return true; }
// S13 (R1): ticket of an order closing the position posId that still works at the broker (0 = none)
ulong SafCloseOrderTicket(const ulong posId)
{
   for(int k = OrdersTotal() - 1; k >= 0; k--)
   {
      const ulong o = OrderGetTicket(k);
      if(o != 0 && OrderGetString(ORDER_SYMBOL) == _Symbol && (ulong)OrderGetInteger(ORDER_POSITION_ID) == posId) return o;
   }
   return 0;
}
void SafPrintCounters(const string when)
{
   PrintFormat("V38 SAFETY COUNTERS %s | entry: held (Magic order working) %I64d, held (no broker result) %I64d, held (throttle) %I64d, PLACED waits %I64d, unknown recorded %I64d, resolved executed %I64d / not executed %I64d | RPA: close-order-working waits %I64d, backoff waits %I64d, volume guard %I64d, close-order-working HALT %I64d, rebase waits for an entry result %I64d | DD hedge / leg evidence waits %I64d | MR: recovery gate %I64d, RECONCILE_ONLY at restart %I64d, orphan basket kept %I64d, history-scan RPA halts %I64d | level book RPA positions %I64d | margin gate blocked %I64d | records not written (no restore) %I64d | R1: T1 protection pending %I64d ticks in %I64d cycles, T1 declared late %I64d, exit close waits (not reconciled) %I64d, exit close waits (close order working) %I64d, exit close FILLED-without-deal holds %I64d | open entry record %s",
               when, g_safHoldWorking, g_safHoldUnknown, g_safHoldThrottle, g_safPlacedWait, g_safUnknownSet, g_safExecuted, g_safNotExec, g_safRpaCowWait, g_safRpaBackoffWait, g_safRpaVolGuard,
               g_safCowHalt, g_safRebaseWaitEntry, g_safDdlWait, g_safMrGate, g_safMrReconcileOnly, g_safOrphanKeep, g_safScanHalt, g_safLbSubgrid, g_safMarginBlocked, g_safNoPersist,
               g_safT1Pending, g_safT1PendEp, g_safT1LateDeclared, g_safExClWait, g_safExClWorking, g_safExClFilledHold,
               g_seRec.st == 0 ? "none" : StringFormat("#%d order %I64u rc %u tick %I64d", g_seRec.cnt, g_seRec.ord, g_seRec.rc, g_seRec.msc));
}
// [SAFETY STATE END] =====

#define EXM_CONFIRMED 0   // broker hiển thị đúng SL/TP yêu cầu
#define EXM_PENDING   1   // đã gửi / không rõ, chưa thấy trên broker — không gửi lại cùng mức trước khi hết cửa sổ xác nhận
#define EXM_FAILED    2   // chưa áp dụng — cùng mức chỉ gửi lại sau backoff (mức MỚI được gửi ngay)
#define EXM_GONE      3   // vị thế không còn

#define EXCL_CLOSED   0   // broker không còn vị thế
#define EXCL_PENDING  1   // broker đã nhận, chưa thấy đóng — không gửi lại trước khi hết cửa sổ xác nhận
#define EXCL_PARTIAL  2   // đóng một phần, còn phần dư (gửi tiếp phần dư)
#define EXCL_RETRY    3   // chưa thực hiện — gửi lại sau backoff
#define EXCL_STALLED  4   // hết số lần gửi — dừng tới Exec_StallRetryMinutes

// bằng chứng (in khi gỡ EA, harness đọc trực tiếp)
long g_exModReq = 0, g_exModConfirmed = 0, g_exModPending = 0, g_exModFail = 0, g_exModSkipSame = 0, g_exModSkipPending = 0, g_exModSkipBackoff = 0, g_exModSkipInvalid = 0;
long g_exClReq = 0, g_exClClosed = 0, g_exClPending = 0, g_exClPartial = 0, g_exClFail = 0, g_exClSkipPending = 0, g_exClSkipBackoff = 0, g_exClStalled = 0;
long g_exModTwiceTick = 0;   // cùng ticket bị sửa 2 lần trong cùng tick (xóa rồi đặt lại) — đo để báo cáo
long g_exLastModMsc = 0; ulong g_exLastModTicket = 0;

long g_exClSkipClosed = 0, g_exModSkipClosed = 0;   // không gửi vì lịch phiên giao dịch của symbol đang đóng
long g_exClWorkingWait = 0;                          // R3: lệnh đóng của vị thế còn đang làm việc trên broker → chờ, không gửi lệnh đóng thứ hai
// R3: an order closing `position` (ORDER_POSITION_ID) is still working at the broker
bool Ex38CloseOrderWorking(const ulong position)
{
   for(int k = OrdersTotal() - 1; k >= 0; k--)
   {
      const ulong o = OrderGetTicket(k);
      if(o != 0 && OrderGetString(ORDER_SYMBOL) == _Symbol && (ulong)OrderGetInteger(ORDER_POSITION_ID) == position) return true;
   }
   return false;
}
// khởi động lại khi còn lệnh đóng / hedge có thể đang bay (bộ nhớ "đang bay" không lưu bền): chờ Exec_ConfirmMs rồi mới gửi, broker quyết định
long g_exGraceUntil = 0;
void Ex38RestartGrace(const string why) { g_exGraceUntil = Ex38NowMs() + MathMax(1, Exec_ConfirmMs); PrintFormat("EXEC RESTART GRACE %d ms | %s: a request sent before the restart may still be in flight - no close / hedge before the broker positions are re-read", Exec_ConfirmMs, why); }

long Ex38TickMsc() { MqlTick t; if(SymbolInfoTick(_Symbol, t) && t.time_msc > 0) return t.time_msc; return (long)TimeCurrent() * 1000; }
// lịch phiên giao dịch của symbol (SymbolInfoSessionTrade, giờ server) đang mở? Symbol không có dữ liệu phiên → true (server quyết định).
// Đóng theo lịch → không gửi (server chắc chắn từ chối "market closed"); yêu cầu đầu tiên ở tick đầu tiên của phiên kế tiếp — V26 gửi lại mỗi tick
// (CloseBasket 12 vòng mỗi tick) và khớp ở cùng tick đầu phiên, R1 khớp ở cùng tick mà không có hàng loạt yêu cầu bị từ chối.
int g_exSessKnown = -1;
bool Ex38TradeSessionOpen()
{
   datetime f, t;
   if(g_exSessKnown < 0)
   {
      g_exSessKnown = 0;
      for(int d = 0; d < 7 && g_exSessKnown == 0; d++) if(SymbolInfoSessionTrade(_Symbol, (ENUM_DAY_OF_WEEK)d, 0, f, t)) g_exSessKnown = 1;
   }
   if(g_exSessKnown == 0) return true;
   MqlDateTime dt; TimeToStruct(TimeTradeServer(), dt);
   const int sec = dt.hour * 3600 + dt.min * 60 + dt.sec;
   for(int i = 0; i < 16; i++)
   {
      if(!SymbolInfoSessionTrade(_Symbol, (ENUM_DAY_OF_WEEK)dt.day_of_week, i, f, t)) break;
      if(sec >= (int)f && sec < (int)t) return true;
   }
   return false;
}
long Ex38NowMs()   { if((bool)MQLInfoInteger(MQL_TESTER)) return Ex38TickMsc(); return (long)GetTickCount64(); }
double Ex38Tol()   { return Ex38PriceTol(SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE), _Point); }
double Ex38Step()  { const double s = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP); return s > 0.0 ? s : 0.01; }
bool   Ex38RcOkV26(const uint rc) { return rc == TRADE_RETCODE_DONE || rc == TRADE_RETCODE_DONE_PARTIAL || rc == TRADE_RETCODE_PLACED; }

// ---------------------------------------------------------------- registry: sửa SL/TP đang chờ / đang backoff (theo ticket)
struct Ex38ModRec { ulong ticket; double sl, tp; int st; int attempts; long nextMs, deadlineMs; uint rc; bool unknown; bool closedSched; };
Ex38ModRec g_exMod[];
int  Ex38ModFind(const ulong t) { for(int i = 0; i < ArraySize(g_exMod); i++) if(g_exMod[i].ticket == t) return i; return -1; }
void Ex38ModDel(const int i) { const int n = ArraySize(g_exMod); if(i < 0 || i >= n) return; g_exMod[i] = g_exMod[n - 1]; ArrayResize(g_exMod, n - 1); }
int  Ex38ModPut(const ulong t, const double sl, const double tp)
{
   int i = Ex38ModFind(t);
   if(i < 0) { i = ArraySize(g_exMod); ArrayResize(g_exMod, i + 1); g_exMod[i].ticket = t; g_exMod[i].attempts = 0; }
   else if(!(Ex38SamePrice(g_exMod[i].sl, sl, Ex38Tol()) && Ex38SamePrice(g_exMod[i].tp, tp, Ex38Tol()))) g_exMod[i].attempts = 0;   // mức mới: đếm lại
   g_exMod[i].sl = sl; g_exMod[i].tp = tp; g_exMod[i].nextMs = 0; g_exMod[i].deadlineMs = 0; g_exMod[i].unknown = false; g_exMod[i].closedSched = false;
   return i;
}

// ---------------------------------------------------------------- registry: đóng vị thế đang chờ / đang backoff (theo ticket)
struct Ex38ClRec { ulong ticket; int st; int attempts; long nextMs, deadlineMs; uint rc; double vol0; bool closedSched; ulong ord; long reqMsc; ulong dwm; ulong known; ulong po1; ulong po2; };   // [SAFETY S13] identity of the last request: order / tick msc / closing deals known before it (dwm) / highest closing deal known (known) / orders of the two previous requests (po1, po2)
Ex38ClRec g_exCl[];
int  Ex38ClFind(const ulong t) { for(int i = 0; i < ArraySize(g_exCl); i++) if(g_exCl[i].ticket == t) return i; return -1; }
void Ex38ClDel(const int i) { const int n = ArraySize(g_exCl); if(i < 0 || i >= n) return; g_exCl[i] = g_exCl[n - 1]; ArrayResize(g_exCl, n - 1); }
int  Ex38ClState(const ulong t) { const int i = Ex38ClFind(t); return i < 0 ? -1 : g_exCl[i].st; }
void Ex38ResetRegistries() { ArrayResize(g_exMod, 0); ArrayResize(g_exCl, 0); }

// ---------------------------------------------------------------- sửa SL/TP một vị thế (thay ModifySlTpVerified của V26)
int Ex38Modify(CTradeV38 &t, const ulong ticket, double sl, double tp)
{
   if(ticket == 0 || !PositionSelectByTicket(ticket))
   {
      const int k = Ex38ModFind(ticket); if(k >= 0) Ex38ModDel(k);
      return EXM_GONE;
   }
   sl = sl > 0.0 ? PriceN(sl) : 0.0; tp = tp > 0.0 ? PriceN(tp) : 0.0;
   const double tol = Ex38Tol();
   const double curSl = PositionGetDouble(POSITION_SL), curTp = PositionGetDouble(POSITION_TP);
   const bool isBuy = (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY);
   int i = Ex38ModFind(ticket);
   const bool sameTarget = (i >= 0 && Ex38SamePrice(g_exMod[i].sl, sl, tol) && Ex38SamePrice(g_exMod[i].tp, tp, tol));
   // (B) đã đúng trên broker → không gửi
   if(Ex38SamePrice(curSl, sl, tol) && Ex38SamePrice(curTp, tp, tol))
   {
      if(sameTarget && g_exMod[i].st == EXM_PENDING) { g_exModConfirmed++; PrintFormat("EXEC MODIFY CONFIRMED ticket=%I64u sl=%.5f tp=%.5f (observed after rc=%u)", ticket, sl, tp, g_exMod[i].rc); }
      else g_exModSkipSame++;
      if(i >= 0) Ex38ModDel(i);
      return EXM_CONFIRMED;
   }
   const long now = Ex38NowMs();
   // (C) cùng mức đang chờ xác nhận / đang backoff → không gửi lại
   if(sameTarget && g_exMod[i].st == EXM_PENDING && now < g_exMod[i].deadlineMs) { g_exModSkipPending++; return EXM_PENDING; }
   // lịch phiên của symbol đang đóng → không gửi (chắc chắn "market closed"); gửi ở tick đầu phiên kế tiếp
   if(!Ex38TradeSessionOpen())
   {
      i = Ex38ModPut(ticket, sl, tp);
      g_exMod[i].st = EXM_FAILED; g_exMod[i].rc = TRADE_RETCODE_MARKET_CLOSED; g_exMod[i].closedSched = true; g_exMod[i].nextMs = now;
      g_exModSkipClosed++;
      return EXM_FAILED;
   }
   if(sameTarget && g_exMod[i].st == EXM_FAILED && now < g_exMod[i].nextMs && !g_exMod[i].closedSched) { g_exModSkipBackoff++; return EXM_FAILED; }
   // yêu cầu trước (mức khác) chưa rõ kết quả (TIMEOUT / PLACED / LOCKED) → không chồng thêm yêu cầu lên ticket này trước khi hết cửa sổ
   if(i >= 0 && !sameTarget && g_exMod[i].st == EXM_PENDING && g_exMod[i].unknown && now < g_exMod[i].deadlineMs) { g_exModSkipPending++; return EXM_PENDING; }
   if(sameTarget && g_exMod[i].attempts >= MathMax(1, Exec_MaxAttempts))
   {
      g_exMod[i].st = EXM_FAILED; g_exMod[i].attempts = 0; g_exMod[i].nextMs = now + (long)MathMax(1, Exec_StallRetryMinutes) * 60000;
      PrintFormat("EXEC MODIFY STALLED ticket=%I64u sl=%.5f tp=%.5f | %d attempts without the levels on the broker (last rc=%u) | next try in %d min", ticket, sl, tp, Exec_MaxAttempts, g_exMod[i].rc, Exec_StallRetryMinutes);
      return EXM_FAILED;
   }
   // kiểm tra trước với tick hiện tại: chỉ chặn yêu cầu server chắc chắn từ chối
   MqlTick tk;
   if(SymbolInfoTick(_Symbol, tk))
   {
      const double freeze = (double)SymbolInfoInteger(_Symbol, SYMBOL_TRADE_FREEZE_LEVEL) * _Point;
      const double stops  = (double)SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL) * _Point;
      const bool frozen = Ex38Frozen(isBuy, curSl, curTp, tk.bid, tk.ask, freeze);
      // stops level: only a level that CHANGES is checked (an unchanged level inside the stops distance is accepted by the server — V26 parity run P1)
      const double slChk = Ex38SamePrice(sl, curSl, tol) ? 0.0 : sl, tpChk = Ex38SamePrice(tp, curTp, tol) ? 0.0 : tp;
      if(frozen || !Ex38StopsValid(isBuy, slChk, tpChk, tk.bid, tk.ask, stops))
      {
         i = Ex38ModPut(ticket, sl, tp);
         g_exMod[i].st = EXM_FAILED; g_exMod[i].rc = frozen ? TRADE_RETCODE_FROZEN : TRADE_RETCODE_INVALID_STOPS;
         g_exMod[i].nextMs = now + Ex38BackoffMs(frozen ? EXC_RETRY_SLOW : EXC_STOPS, 1);
         g_exModSkipInvalid++;
         return EXM_FAILED;
      }
   }
   if(ticket == g_exLastModTicket && now == g_exLastModMsc) g_exModTwiceTick++;
   g_exLastModTicket = ticket; g_exLastModMsc = now;
   const long s0 = t.m_sends;
   const bool ok = t.PositionModify(ticket, sl, tp);
   const bool sent = (t.m_sends > s0);
   const uint rc = t.ResultRetcode();
   i = Ex38ModPut(ticket, sl, tp);
   if(sent) { g_exModReq++; g_exMod[i].attempts++; }
   g_exMod[i].rc = sent ? rc : 0;
   if(!PositionSelectByTicket(ticket)) { Ex38ModDel(i); return EXM_GONE; }
   const double gotSl = PositionGetDouble(POSITION_SL), gotTp = PositionGetDouble(POSITION_TP);
   const bool match = Ex38SamePrice(gotSl, sl, tol) && Ex38SamePrice(gotTp, tp, tol);
   const int cls = sent ? Ex38Classify(EX38_OP_MODIFY, rc) : EXC_RETRY_SLOW;
   // the required state is OBSERVED on the broker position (exact levels, half a tick) → confirmed, whatever the reply said (e.g. TIMEOUT after it executed)
   if(match)
   {
      g_exModConfirmed++; Ex38ModDel(i);
      return EXM_CONFIRMED;
   }
   if(cls == EXC_DONE || cls == EXC_NOCHANGE || cls == EXC_PARTIAL || cls == EXC_INFLIGHT || cls == EXC_UNKNOWN)
   {
      // broker đã nhận (hoặc không rõ) nhưng vị thế chưa hiện mức mới → chưa được báo MODIFY_CONFIRMED
      g_exModPending++;
      g_exMod[i].st = EXM_PENDING; g_exMod[i].unknown = (cls == EXC_UNKNOWN || cls == EXC_INFLIGHT);
      g_exMod[i].deadlineMs = now + MathMax(1, Exec_ConfirmMs);
      PrintFormat("EXEC MODIFY PENDING ticket=%I64u rc=%u %s | requested sl=%.5f tp=%.5f | broker shows sl=%.5f tp=%.5f | no resend for %d ms",
                  ticket, rc, Ex38ClassName(cls), sl, tp, gotSl, gotTp, Exec_ConfirmMs);
      return EXM_PENDING;
   }
   if(cls == EXC_GONE) { Ex38ModDel(i); return EXM_GONE; }
   g_exModFail++;
   g_exMod[i].st = EXM_FAILED; g_exMod[i].nextMs = now + Ex38BackoffMs(cls, g_exMod[i].attempts);
   PrintFormat("Modify fail ticket=%llu rc=%u %s sl=%.5f tp=%.5f | %s attempt %d, same levels not resent for %I64d ms",
               ticket, rc, sent ? t.ResultComment() : "not sent", sl, tp, Ex38ClassName(cls), g_exMod[i].attempts, g_exMod[i].nextMs - now);
   return EXM_FAILED;
}

// ---------------------------------------------------------------- đóng toàn bộ khối lượng HIỆN TẠI của một vị thế (thay ClosePositionVerified của V26)
int Ex38Close(CTradeV38 &t, const ulong ticket, const string who)
{
   if(ticket == 0) return EXCL_RETRY;
   int i = Ex38ClFind(ticket);
   if(!PositionSelectByTicket(ticket)) { if(i >= 0) Ex38ClDel(i); return EXCL_CLOSED; }
   const double vol = PositionGetDouble(POSITION_VOLUME);
   const ulong pid = (ulong)PositionGetInteger(POSITION_IDENTIFIER);   // [SAFETY S13] deals / orders carry the position IDENTIFIER (the ticket can change at a broker that re-opens positions)
   const long now = Ex38NowMs();
   if(i < 0) { i = ArraySize(g_exCl); ArrayResize(g_exCl, i + 1); g_exCl[i].ticket = ticket; g_exCl[i].st = EXCL_RETRY; g_exCl[i].attempts = 0; g_exCl[i].nextMs = 0; g_exCl[i].deadlineMs = 0; g_exCl[i].rc = 0; g_exCl[i].vol0 = vol; g_exCl[i].closedSched = false; g_exCl[i].ord = 0; g_exCl[i].reqMsc = 0; g_exCl[i].dwm = 0; g_exCl[i].known = 0; g_exCl[i].po1 = 0; g_exCl[i].po2 = 0; }   // [SAFETY S13] ord / reqMsc / dwm / known / po1 / po2
   if(now < g_exGraceUntil) { g_exClSkipPending++; return EXCL_PENDING; }
   if(g_exCl[i].st == EXCL_PENDING)
   {
      if(now < g_exCl[i].deadlineMs) { g_exClSkipPending++; return EXCL_PENDING; }
      // V38 R3 (R3-05): a close order of THIS position still works at the broker (accepted / PLACED, not filled yet) -> the old request is alive: no second close
      // [SAFETY S13] also matched by POSITION_IDENTIFIER (a broker that re-opens positions changes the ticket, not the identifier)
      if(Ex38CloseOrderWorking(ticket) || SafCloseOrderTicket(pid) != 0)
      {
         g_exCl[i].deadlineMs = now + MathMax(1, Exec_ConfirmMs); g_exClSkipPending++; g_exClWorkingWait++;
         if(g_exClWorkingWait == 1 || g_exClWorkingWait % 100 == 0) PrintFormat("EXEC CLOSE ticket=%I64u (%s) | a close order of this position is still working at the broker - waiting for it, no second close request", ticket, who);
         return EXCL_PENDING;
      }
      // [SAFETY S13] the earlier request is reconciled against the deal / order history before a new one (HOTFIX: resend after Exec_ConfirmMs on the absence of a
      // working order only — an order FILLED in the history whose deal / volume was not visible yet was requested a second time)
      bool dlS = false; int hsS = -1; ulong dSeen = 0;
      SafCloseEvidence(pid, g_exCl[i].ord, g_exCl[i].reqMsc, g_exCl[i].dwm, g_exCl[i].po1, g_exCl[i].po2, dlS, hsS, dSeen);
      if(dSeen > g_exCl[i].known) g_exCl[i].known = dSeen;
      const long elS = (g_exCl[i].reqMsc > 0) ? MathMax((long)MathMax(1, Exec_ConfirmMs), Ex38TickMsc() - g_exCl[i].reqMsc) : (long)SAF_UNKNOWN_RESOLVE_SEC * 1000;
      const bool conn = TerminalInfoInteger(TERMINAL_CONNECTED) != 0;
      if(Saf38CloseResendDecision(false, dlS, hsS, elS, MathMax(1, Exec_ConfirmMs), (long)SAF_UNKNOWN_RESOLVE_SEC * 1000, conn) == SAF_CLR_WAIT)
      {
         g_exCl[i].deadlineMs = now + MathMax(1, Exec_ConfirmMs); g_exClSkipPending++; g_safExClWait++;
         SafLogOnce(StringFormat("EXCLW_%I64u_%I64u", ticket, g_exCl[i].ord), StringFormat("EXEC CLOSE ticket=%I64u (%s) | the earlier close request (order %I64u, rc %u) is not reconciled yet (order history %s, no closing deal of it) and the position still shows %.2f lots: no second close request until its deal, a cancelled / rejected order, or (no trace) %d s connected without a working order (SAFETY S13)",
                                                                                            ticket, who, g_exCl[i].ord, g_exCl[i].rc, hsS == 0 ? "FILLED" : "no trace", vol, SAF_UNKNOWN_RESOLVE_SEC));
         if(hsS == 0 && elS >= (long)SAF_UNKNOWN_RESOLVE_SEC * 1000)
         {
            if(SafFirst(StringFormat("EXCLF_%I64u_%I64u", ticket, g_exCl[i].ord))) g_safExClFilledHold++;   // episodes (ticket, order)
            if(SafFirst(StringFormat("EXCLFR_%I64u_%I64u_%I64d", ticket, g_exCl[i].ord, elS / 900000)))     // first line + a reminder every 15 min while it lasts
               PrintFormat("EXEC CLOSE RECONCILE HOLD ticket=%I64u (%s) | order %I64u is FILLED in the history for %I64d s but no closing deal / volume change is visible: executed per the broker history - no second close request; the exit keeps the basket (no grid / no L1) - OWNER CHECK REQUIRED if it persists (SAFETY S13)",
                           ticket, who, g_exCl[i].ord, elS / 1000);
         }
         return EXCL_PENDING;
      }
      PrintFormat("EXEC CLOSE ticket=%I64u still open %d ms after rc=%u (%.2f lots) - not observed closed, no close order working at the broker, resend allowed | reconciled: deal since the request %d, order history %d (SAFETY S13)", ticket, Exec_ConfirmMs, g_exCl[i].rc, vol, dlS ? 1 : 0, hsS);
   }
   // lịch phiên của symbol đang đóng → không gửi (chắc chắn "market closed"); gửi ở tick đầu phiên kế tiếp
   if(!Ex38TradeSessionOpen())
   {
      if(g_exCl[i].st != EXCL_STALLED) { g_exCl[i].st = EXCL_RETRY; g_exCl[i].rc = TRADE_RETCODE_MARKET_CLOSED; g_exCl[i].closedSched = true; g_exCl[i].nextMs = now; }
      g_exClSkipClosed++;
      return g_exCl[i].st;
   }
   if(g_exCl[i].st == EXCL_STALLED)
   {
      if(now < g_exCl[i].nextMs) return EXCL_STALLED;
      g_exCl[i].attempts = 0;
   }
   else if(g_exCl[i].st == EXCL_RETRY && now < g_exCl[i].nextMs && !g_exCl[i].closedSched) { g_exClSkipBackoff++; return EXCL_RETRY; }
   if(g_exCl[i].attempts >= MathMax(1, Exec_MaxAttempts))
   {
      g_exCl[i].st = EXCL_STALLED; g_exCl[i].nextMs = now + (long)MathMax(1, Exec_StallRetryMinutes) * 60000; g_exClStalled++;
      PrintFormat("EXEC CLOSE STALLED ticket=%I64u (%s) | %d requests without closing it (last rc=%u) | next round in %d min - basket authority kept, no grid / no L1",
                  ticket, who, Exec_MaxAttempts, g_exCl[i].rc, Exec_StallRetryMinutes);
      return EXCL_STALLED;
   }
   // [SAFETY S13] no close request while ANY close order of this position works at the broker (also after a partial fill / a retry: the HOTFIX checked it only
   // in the PENDING state). That order becomes the request to reconcile (its ticket, the deals known before it).
   const ulong wo = SafCloseOrderTicket(pid);
   if(wo != 0)
   {
      g_exCl[i].st = EXCL_PENDING; g_exCl[i].deadlineMs = now + MathMax(1, Exec_ConfirmMs); g_exClSkipPending++; g_safExClWorking++;
      if(g_exCl[i].ord != 0 && g_exCl[i].ord != wo) { g_exCl[i].po2 = g_exCl[i].po1; g_exCl[i].po1 = g_exCl[i].ord; }
      g_exCl[i].ord = wo; g_exCl[i].reqMsc = Ex38TickMsc(); g_exCl[i].dwm = g_exCl[i].known;
      SafLogOnce("EXCLWK_" + IntegerToString((long)ticket), StringFormat("EXEC CLOSE ticket=%I64u (%s) | close order %I64u of this position works at the broker: no further close request until it is reconciled (SAFETY S13)", ticket, who, wo));
      return EXCL_PENDING;
   }
   const long s0 = t.m_sends;
   const bool ok = t.PositionClose(ticket);
   const bool sent = (t.m_sends > s0);
   const uint rc = t.ResultRetcode();
   if(sent)   // [SAFETY S13] request identity for the reconciliation: its order, its tick, the closing deals known before it
   {
      if(g_exCl[i].ord != 0) { g_exCl[i].po2 = g_exCl[i].po1; g_exCl[i].po1 = g_exCl[i].ord; }
      g_exClReq++; g_exCl[i].attempts++; g_exCl[i].ord = t.ResultOrder(); g_exCl[i].reqMsc = Ex38TickMsc(); g_exCl[i].dwm = g_exCl[i].known;
      if(t.ResultDeal() > g_exCl[i].known) g_exCl[i].known = t.ResultDeal();
   }
   g_exCl[i].rc = sent ? rc : 0; g_exCl[i].closedSched = false;
   const double filled = sent ? t.ResultVolume() : 0.0;
   if(!PositionSelectByTicket(ticket)) { g_exClClosed++; Ex38ClDel(i); return EXCL_CLOSED; }
   const double left = PositionGetDouble(POSITION_VOLUME);
   const int cls = sent ? Ex38Classify(EX38_OP_CLOSE, rc) : EXC_RETRY_SLOW;
   if((cls == EXC_DONE || cls == EXC_PARTIAL) && left < vol - Ex38Step() * 0.5)
   {
      g_exClPartial++;
      g_exCl[i].st = EXCL_PARTIAL; g_exCl[i].nextMs = now;
      PrintFormat("EXEC CLOSE PARTIAL ticket=%I64u (%s) | requested %.2f filled %.2f | residual %.2f still open | rc=%u - not a full close, residual is closed next",
                  ticket, who, vol, filled, left, rc);
      return EXCL_PARTIAL;
   }
   if(cls == EXC_DONE || cls == EXC_PARTIAL || cls == EXC_INFLIGHT || cls == EXC_UNKNOWN || cls == EXC_GONE)
   {
      g_exClPending++;
      g_exCl[i].st = EXCL_PENDING; g_exCl[i].deadlineMs = now + MathMax(1, Exec_ConfirmMs);
      PrintFormat("EXEC CLOSE PENDING ticket=%I64u (%s) rc=%u %s | requested %.2f reported %.2f | broker still shows %.2f lots - no resend for %d ms",
                  ticket, who, rc, Ex38ClassName(cls), vol, filled, left, Exec_ConfirmMs);
      return EXCL_PENDING;
   }
   g_exClFail++;
   g_exCl[i].st = EXCL_RETRY; g_exCl[i].nextMs = now + Ex38BackoffMs(cls, g_exCl[i].attempts);
   PrintFormat("Close fail ticket=%llu rc=%u %s | %s (%s) attempt %d/%d, next try in %I64d ms",
               ticket, rc, sent ? t.ResultComment() : "not sent", Ex38ClassName(cls), who, g_exCl[i].attempts, Exec_MaxAttempts, g_exCl[i].nextMs - now);
   return EXCL_RETRY;
}

void Ex38PrintCounters(const string when)
{
   PrintFormat("EXEC COUNTERS %s | modify: requests %I64d confirmed %I64d pending %I64d failed %I64d | not sent: already set %I64d, same pending %I64d, same in backoff %I64d, certain reject (stops/freeze) %I64d, trade session closed %I64d | same ticket twice in one tick %I64d",
               when, g_exModReq, g_exModConfirmed, g_exModPending, g_exModFail, g_exModSkipSame, g_exModSkipPending, g_exModSkipBackoff, g_exModSkipInvalid, g_exModSkipClosed, g_exModTwiceTick);
   PrintFormat("EXEC COUNTERS %s | close: requests %I64d closed %I64d pending %I64d partial %I64d failed %I64d stalled %I64d | not sent: pending %I64d (close order still working %I64d), backoff %I64d, trade session closed %I64d",
               when, g_exClReq, g_exClClosed, g_exClPending, g_exClPartial, g_exClFail, g_exClStalled, g_exClSkipPending, g_exClWorkingWait, g_exClSkipBackoff, g_exClSkipClosed);
}

#endif
// [FINAL STANDALONE] ===== END INLINED OFH38_Exec.mqh =====
// [FINAL STANDALONE] ===== BEGIN INLINED OFH38_Sessions.mqh (HOTFIX SHA256 18744BB613AEAA3F53D2C78203C2CA286404AFCD9FC977E63A828677858233F6) — included from Onefxhub_v38.38_RPA.mq5:L304 =====
// OFH38_Sessions.mqh — V38: 3 phiên giao dịch (Á / Âu / Mỹ) theo giờ LOCAL + SESSION_BASKET_RESCUE.
// Thay cửa sổ đơn StartHourLocal–EndHourLocal của V26. Giờ local = giờ server + (LocalGMT − ServerGMT) giờ (giữ cách đổi múi giờ của V26).
// Cửa sổ hợp lệ = HỢP các phiên đang bật (gộp chồng / liền nhau). 60 phút cuối = MinBeforeClose phút cuối của CỬA SỔ LIÊN TỤC.
// SESSION_BASKET_RESCUE: vào 60 phút cuối mà cụm có > CloseProtect_MaxOrders lệnh (và không chốt theo luật lãi của V26) → cụm được xử lý
// tiếp sau giờ phiên (Grid / GLOBAL / T1 / T2 / PairClose / vào lại sau chốt tay), không mở L1 mới. Hết khi cụm đóng hết thật, hoặc DD Lock
// nắm quyền. Lưu theo tài khoản + server + symbol + Magic, gắn với ticket lệnh sớm nhất của cụm (khởi động lại vẫn giữ đúng cụm).
// Dùng input và biến toàn cục của EA chính (include sau phần khai báo biến).
#ifndef OFH38_SESSIONS_MQH
#define OFH38_SESSIONS_MQH

// [FINAL STANDALONE] ===== BEGIN INLINED OFH38_Sessions_Core.mqh (HOTFIX SHA256 7CB3D4F5E8397CA5DE205C5D2FDB0129298761019E1C262970C451C78CEE245D) — included from OFH38_Sessions.mqh:L11 =====
// OFH38_Sessions_Core.mqh — V38: lịch 3 phiên giao dịch theo giờ LOCAL (logic thuần, không gọi lệnh, không dùng biến EA). Unit-test được.
// Quy ước (giữ đúng quy tắc ngày của V26):
//   * Mỗi phiên [start, end) thuộc NGÀY LOCAL mà nó bắt đầu; end <= start nghĩa là kết thúc sang ngày hôm sau (qua nửa đêm).
//   * Chỉ phiên bắt đầu Thứ Hai..Thứ Sáu (local) mới tồn tại — như V26: T6 05:00 → T7 04:00 vẫn cùng một phiên.
//   * start == end: phiên rỗng (V26 Start==End cũng không bao giờ giao dịch).
//   * Cửa sổ hợp lệ = HỢP của mọi phiên đang bật; phiên chồng nhau hoặc liền nhau (end == start kế) gộp thành 1 cửa sổ liên tục.
#ifndef OFH38_SESSIONS_CORE_MQH
#define OFH38_SESSIONS_CORE_MQH

struct Sess38Def { bool on; int start_min; int end_min; };   // phút trong ngày local (0..1439)

// Nửa đêm local của thời điểm t (t đã là giờ local).
datetime Sess38Midnight(const datetime t) { MqlDateTime d; TimeToStruct(t, d); return t - (datetime)(d.hour * 3600 + d.min * 60 + d.sec); }

// Dựng các cửa sổ đã gộp quanh tLocal: các ngày từ -3 tới +10 (đủ cho cuối tuần + phiên qua đêm). Trả về số cửa sổ.
int Sess38Build(const Sess38Def &s[], const int n, const datetime tLocal, datetime &ws[], datetime &we[])
{
   datetime st[], en[]; int k = 0;
   const datetime d0 = Sess38Midnight(tLocal);
   for(int d = -3; d <= 10; d++)
   {
      const datetime day = d0 + (datetime)(d * 86400);
      MqlDateTime md; TimeToStruct(day, md);
      if(md.day_of_week < 1 || md.day_of_week > 5) continue;          // chỉ phiên bắt đầu T2..T6
      for(int i = 0; i < n; i++)
      {
         if(!s[i].on || s[i].start_min == s[i].end_min) continue;
         const datetime a = day + (datetime)(s[i].start_min * 60);
         const datetime b = (s[i].end_min > s[i].start_min) ? day + (datetime)(s[i].end_min * 60) : day + (datetime)(86400 + s[i].end_min * 60);
         ArrayResize(st, k + 1); ArrayResize(en, k + 1); st[k] = a; en[k] = b; k++;
      }
   }
   // sắp theo giờ bắt đầu (ít phần tử: chèn trực tiếp)
   for(int i = 1; i < k; i++)
   {
      const datetime a = st[i], b = en[i]; int j = i - 1;
      while(j >= 0 && st[j] > a) { st[j + 1] = st[j]; en[j + 1] = en[j]; j--; }
      st[j + 1] = a; en[j + 1] = b;
   }
   ArrayResize(ws, 0); ArrayResize(we, 0); int m = 0;
   for(int i = 0; i < k; i++)
   {
      if(m > 0 && st[i] <= we[m - 1]) { if(en[i] > we[m - 1]) we[m - 1] = en[i]; continue; }   // chồng / liền nhau → gộp
      ArrayResize(ws, m + 1); ArrayResize(we, m + 1); ws[m] = st[i]; we[m] = en[i]; m++;
   }
   return m;
}

// Vị trí của tLocal: đang trong cửa sổ nào (inHours, winStart, winEnd) và giờ mở cửa sổ KẾ TIẾP (bắt đầu sau tLocal, sau cửa sổ hiện tại).
// nextOpen = 0 khi không có phiên nào bật.
void Sess38Locate(const datetime &ws[], const datetime &we[], const int m, const datetime tLocal,
                  bool &inHours, datetime &winStart, datetime &winEnd, datetime &nextOpen)
{
   inHours = false; winStart = 0; winEnd = 0; nextOpen = 0;
   for(int i = 0; i < m; i++)
   {
      if(ws[i] <= tLocal && tLocal < we[i]) { inHours = true; winStart = ws[i]; winEnd = we[i]; continue; }
      if(ws[i] > tLocal && nextOpen == 0) nextOpen = ws[i];
   }
}

// 60 phút cuối của cửa sổ liên tục: còn <= minBefore phút tới hết cửa sổ (cùng nghĩa với IsNearTradingEnd của V26 ở độ phân giải phút).
bool Sess38NearEnd(const bool inHours, const datetime winEnd, const datetime tLocal, const int minBefore)
{
   if(!inHours || winEnd <= 0) return false;
   return (tLocal >= winEnd - (datetime)(minBefore * 60));
}

bool Sess38Valid(const int h, const int mi) { return h >= 0 && h <= 23 && mi >= 0 && mi <= 59; }

#endif
// [FINAL STANDALONE] ===== END INLINED OFH38_Sessions_Core.mqh =====
// [FINAL STANDALONE] ===== BEGIN INLINED OFH38_Identity.mqh (HOTFIX SHA256 7E1A8055249B5AABC400DF2BD5E18D45F6DA4ECD8FDBEA3E30782DA3FA4FB35B) — included from OFH38_Sessions.mqh:L12 =====
// OFH38_Identity.mqh — V38 port of the V2B6 FINAL donor OFH_V2_Identity.mqh (SHA 2D5D37BC…), code unchanged.
// One persistence namespace per ACCOUNT LOGIN + TRADING SERVER + SYMBOL + MAGIC.
// Terminal global variables are shared by every chart, every EA and every account ever logged in on the same terminal, and a name is
// limited to 63 characters. Every persisted RSI6 V2 state (Smart Close exit intent, DD Recovery episode, Deep Grid pending level,
// Recovery trade memory, Shadow cycle) is therefore stored under "<module>_<id8>_" where id8 = FNV-1a 32 of "login|server|symbol|magic".
// The identity fields are also stored inside each record and compared again on restore (hash collision, copied terminal folder).
// Before the account is known (login 0 / empty server right after a terminal start) nothing is restored and nothing is traded:
// OnInit marks the restore as pending and the first tick with a known account performs it (g_ofhIdWait).
// Records of the pre-FINAL format (keys without account / server) are migrated only when the broker proves they belong to this
// account (one of their tickets is open here with this symbol and magic); otherwise they are left untouched and reported.
#ifndef OFH_V2_IDENTITY_MQH
#define OFH_V2_IDENTITY_MQH

bool g_ofhIdWait = false;   // persisted state not restored yet: the account identity was unknown at OnInit

uint OfhFnv32(const string s)
{
   uint h = (uint)2166136261;
   uchar b[]; const int n = StringToCharArray(s, b, 0, WHOLE_ARRAY, CP_UTF8) - 1;
   for(int i = 0; i < n; i++) { h ^= b[i]; h *= 16777619; }
   return h;
}
string OfhFnv8(const string s) { return StringFormat("%08x", OfhFnv32(s)); }

long   OfhLogin()  { return AccountInfoInteger(ACCOUNT_LOGIN); }
string OfhServer() { return AccountInfoString(ACCOUNT_SERVER); }
// the Strategy Tester always runs on its own account: never wait there
bool   OfhIdReady() { return (bool)MQLInfoInteger(MQL_TESTER) || (OfhLogin() > 0 && OfhServer() != ""); }
string OfhIdText(const ulong magic) { return StringFormat("%I64d|%s|%s|%I64u", OfhLogin(), OfhServer(), _Symbol, magic); }
// "<module>_<id8>_"  (module <= 6 characters keeps every key far below the 63-character limit)
string OfhNs(const string module, const ulong magic) { return module + "_" + OfhFnv8(OfhIdText(magic)) + "_"; }

// identity fields stored inside a record (prefix = the record's key prefix)
void OfhIdStore(const string prefix, const ulong magic)
{
   GlobalVariableSet(prefix + "idlogin", (double)OfhLogin());
   GlobalVariableSet(prefix + "idsrv", (double)OfhFnv32(OfhServer()));
   GlobalVariableSet(prefix + "idsym", (double)OfhFnv32(_Symbol));
   GlobalVariableSet(prefix + "idmagic", (double)magic);
}
// "" = the stored identity is this account / server / symbol / magic; otherwise the first field that differs
string OfhIdCheck(const string prefix, const ulong magic)
{
   if(!GlobalVariableCheck(prefix + "idlogin")) return "NO_IDENTITY_FIELDS";
   if((long)GlobalVariableGet(prefix + "idlogin") != OfhLogin()) return "LOGIN";
   if((uint)GlobalVariableGet(prefix + "idsrv") != OfhFnv32(OfhServer())) return "SERVER";
   if((uint)GlobalVariableGet(prefix + "idsym") != OfhFnv32(_Symbol)) return "SYMBOL";
   if((ulong)GlobalVariableGet(prefix + "idmagic") != magic) return "MAGIC";
   return "";
}

// true when a position with this ticket is open here on this symbol with one of the magics
bool OfhTicketIsOurs(const ulong t, const ulong m1, const ulong m2 = 0, const ulong m3 = 0)
{
   if(t == 0 || !PositionSelectByTicket(t) || PositionGetString(POSITION_SYMBOL) != _Symbol) return false;
   const ulong mg = (ulong)PositionGetInteger(POSITION_MAGIC);
   return mg == m1 || (m2 != 0 && mg == m2) || (m3 != 0 && mg == m3);
}
// true when this symbol has an open position of one of the magics
bool OfhAnyOpen(const ulong m1, const ulong m2 = 0, const ulong m3 = 0)
{
   for(int i = PositionsTotal() - 1; i >= 0; i--) if(OfhTicketIsOurs(PositionGetTicket(i), m1, m2, m3)) return true;
   return false;
}

// copy every global variable "<from>rest" to "<to>rest" and delete the source; returns the number moved
int OfhMoveVars(const string from, const string to)
{
   string names[]; int n = 0;
   for(int i = GlobalVariablesTotal() - 1; i >= 0; i--)
   {
      const string nm = GlobalVariableName(i);
      if(StringFind(nm, from) == 0) { ArrayResize(names, n + 1); names[n++] = nm; }
   }
   for(int i = 0; i < n; i++)
   {
      GlobalVariableSet(to + StringSubstr(names[i], StringLen(from)), GlobalVariableGet(names[i]));
      GlobalVariableDel(names[i]);
   }
   if(n > 0) GlobalVariablesFlush();
   return n;
}

#endif
// [FINAL STANDALONE] ===== END INLINED OFH38_Identity.mqh =====

Sess38Def g_sDef[3];
datetime  g_sWs[], g_sWe[];
int       g_sN       = 0;
long      g_sMinKey  = -1;   // phút local đã định vị
datetime  g_sDayKey  = -1;   // ngày local đã dựng cửa sổ
bool      g_sIn      = false;
datetime  g_sWinStart = 0, g_sWinEnd = 0, g_sNext = 0;

int      SessDiff()     { return (LocalGMT - ServerGMT) * 3600; }
datetime SessLocalNow() { return TimeCurrent() + (datetime)SessDiff(); }

void SessSetup()
{
   g_sDef[0].on = Enable_Asia;   g_sDef[0].start_min = Asia_StartHour * 60 + Asia_StartMinute;     g_sDef[0].end_min = Asia_EndHour * 60 + Asia_EndMinute;
   g_sDef[1].on = Enable_Europe; g_sDef[1].start_min = Europe_StartHour * 60 + Europe_StartMinute; g_sDef[1].end_min = Europe_EndHour * 60 + Europe_EndMinute;
   g_sDef[2].on = Enable_US;     g_sDef[2].start_min = US_StartHour * 60 + US_StartMinute;         g_sDef[2].end_min = US_EndHour * 60 + US_EndMinute;
   g_sMinKey = -1; g_sDayKey = -1; g_sN = 0;
}

// "" = hợp lệ; ngược lại là lý do
string SessInputsError()
{
   if(!Sess38Valid(Asia_StartHour, Asia_StartMinute) || !Sess38Valid(Asia_EndHour, Asia_EndMinute)) return "Asia hour 0..23 / minute 0..59";
   if(!Sess38Valid(Europe_StartHour, Europe_StartMinute) || !Sess38Valid(Europe_EndHour, Europe_EndMinute)) return "Europe hour 0..23 / minute 0..59";
   if(!Sess38Valid(US_StartHour, US_StartMinute) || !Sess38Valid(US_EndHour, US_EndMinute)) return "US hour 0..23 / minute 0..59";
   if(MinBeforeClose < 0) return "MinBeforeClose >= 0";
   return "";
}

string SessDescribe()
{
   string s = "";
   const string nm[3] = {"ASIA", "EUROPE", "US"};
   for(int i = 0; i < 3; i++)
   {
      const int a = g_sDef[i].start_min, b = g_sDef[i].end_min;
      s += StringFormat("%s%s %02d:%02d-%02d:%02d%s%s", i > 0 ? " | " : "", nm[i], a / 60, a % 60, b / 60, b % 60, b <= a && a != b ? "(+1d)" : "",
                        !g_sDef[i].on ? " OFF" : (a == b ? " EMPTY" : ""));
   }
   return s;
}

void SessUpdate()
{
   const datetime t = SessLocalNow();
   const long mk = (long)t / 60;
   if(mk == g_sMinKey) return;
   g_sMinKey = mk;
   const datetime day = Sess38Midnight(t);
   if(day != g_sDayKey) { g_sN = Sess38Build(g_sDef, 3, t, g_sWs, g_sWe); g_sDayKey = day; }
   Sess38Locate(g_sWs, g_sWe, g_sN, t, g_sIn, g_sWinStart, g_sWinEnd, g_sNext);
}

bool     SessInHours()        { SessUpdate(); return g_sIn; }
bool     SessNearEnd()        { SessUpdate(); return Sess38NearEnd(g_sIn, g_sWinEnd, SessLocalNow(), MinBeforeClose); }
datetime SessNextOpenLocal()  { SessUpdate(); return g_sNext; }
datetime SessWinEndLocal()    { SessUpdate(); return g_sWinEnd; }

// ---------------------------------------------------------------- SESSION_BASKET_RESCUE (lưu bền)
string SessNs() { return OfhNs("OFH38S", Magic); }

// Ticket lệnh mở sớm nhất của cụm (Magic, symbol) — dấu vân tay của cụm.
ulong SessBasketId()
{
   ulong id = 0; long tm = LONG_MAX;
   for(int i = 0; i < PositionsTotal(); i++)
   {
      const ulong t = PositionGetTicket(i);
      if(t == 0 || !PositionSelectByTicket(t) || !IsOursPos()) continue;
      const long pt = PositionGetInteger(POSITION_TIME_MSC);
      if(pt < tm || (pt == tm && t < id)) { tm = pt; id = t; }
   }
   return id;
}

void SetSessionRescue(const bool on, const string why)
{
   if(sessionRescue == on) return;
   sessionRescue = on;
   if(on)
   {
      const string ns = SessNs();
      GlobalVariableSet(ns + "rescue", 1.0);
      GlobalVariableSet(ns + "basket", (double)SessBasketId());
      GlobalVariableSet(ns + "since", (double)TimeCurrent());
      OfhIdStore(ns, Magic);
   }
   else GlobalVariablesDeleteAll(SessNs());
   GlobalVariablesFlush();
   PrintFormat("=== SESSION_BASKET_RESCUE %s | %s | positions=%d | local=%s | window end %s ===", on ? "ON" : "OFF", why, CountPositions(),
               TimeToString(SessLocalNow(), TIME_DATE | TIME_MINUTES), TimeToString(SessWinEndLocal(), TIME_DATE | TIME_MINUTES));
}

// V38 R2: chốt tay lệnh cũ nhất của cụm đổi "ticket lệnh sớm nhất" (dấu vân tay cụm) → bản ghi rescue theo cụm, không bị coi là cụm khác khi khởi động lại.
void SessRescueRefresh()
{
   if(!sessionRescue) return;
   GlobalVariableSet(SessNs() + "basket", (double)SessBasketId());
   GlobalVariablesFlush();
}

// Khởi động lại: true khi bản ghi rescue khớp tài khoản / server / symbol / Magic VÀ đúng cụm (ticket lệnh sớm nhất còn mở).
bool SessRescueLoad()
{
   const string ns = SessNs();
   if(!GlobalVariableCheck(ns + "rescue")) return false;
   const string idWhy = OfhIdCheck(ns, Magic);
   const ulong rec = (ulong)GlobalVariableGet(ns + "basket");
   const ulong now = SessBasketId();
   if(idWhy != "" || rec == 0 || rec != now)
   {
      PrintFormat("SESSION_BASKET_RESCUE record ignored | identity=%s basket rec=%I64u now=%I64u", idWhy == "" ? "ok" : idWhy, rec, now);
      GlobalVariablesDeleteAll(ns); GlobalVariablesFlush();
      return false;
   }
   return true;
}

#endif
// [FINAL STANDALONE] ===== END INLINED OFH38_Sessions.mqh =====
// [FINAL STANDALONE] ===== BEGIN INLINED OFH38_GlobalGrid.mqh (HOTFIX SHA256 9E7E2E7F7FB9CCA529F4CA2E816A5D92C58F9C1E8B7DA8ED024BF7E32E92D11B) — included from Onefxhub_v38.38_RPA.mq5:L305 =====
// OFH38_GlobalGrid.mqh — V38 GLOBAL Grid AI Pro (phần EA). Phép tính nhóm: OFH38_GlobalGrid_Core.mqh.
// Không thêm sổ level riêng: level = quy ước đếm lệnh của V26 (lệnh kế = số lệnh + 1; lot CalcLot, chiều GetNextType, Max_Orders giữ nguyên).
// Trạng thái riêng của GLOBAL chỉ là biên giá mỗi nhóm:
//   * anchor khớp (L1 hoặc lệnh phá vỡ) → ghi giá anchor; từ tick đó theo dõi GroupHigh = Ask cao nhất, GroupLow = Bid thấp nhất ĐÃ QUAN SÁT;
//   * lệnh cuối nhóm khớp (xác nhận: lệnh gửi thành công / số lệnh đạt cuối nhóm) → ĐÓNG BĂNG biên (gồm tick khớp); anchor kế dùng biên này;
//   * số lệnh giảm (PairClose, đóng ngoài EA): dưới cuối nhóm → nhóm MỞ LẠI (biên chạy tiếp từ lúc anchor khớp, đóng băng lại khi đủ lệnh);
//     dưới anchor → xóa nhóm. Đang chờ vào lại sau chốt tay thì giữ nguyên nhóm (lệnh vào lại thay đúng lệnh đã chốt).
//     V38 R2: "đang chờ" = còn bản ghi khôi phục chặn Grid (MrBlocksGrid, hàng chờ nhiều bản ghi) — anchor / biên đã đóng băng không đổi; lệnh vào
//     lại không gọi GgOnFill. g_ggRebuilt: lần khởi động này phải dựng lại nhóm từ lệnh đang mở (bằng chứng cấp sau khởi động lại, OFH38_ManualRecovery).
//     V38 R3: sau đóng tay, "số lệnh" của nhóm = số cấp của SỔ CẤP (OFH38_LevelBook: cấp kế − 1), không phải số ticket; dựng lại nhóm lấy vị thế GỐC của
//     cấp anchor / cấp cuối nhóm từ sổ — không còn (đã bỏ / chỉ còn vé vào lại) → khóa Grid (BLOCKER), không đoán anchor.
//   * lưu bền theo tài khoản + server + symbol + Magic, gắn với ticket lệnh sớm nhất của cụm + k + Max_Orders; khởi động lại: đọc bản ghi rồi
//     bù khoảng trống bằng lịch sử tick (CopyTicksRange, chỉ tick đã qua); không có bản ghi hợp lệ → dựng lại từ lệnh đang mở (thứ tự giờ vào)
//     + lịch sử tick. Lịch sử tick chưa đọc được → CHẶN anchor phá vỡ (level trong nhóm vẫn chạy), thử lại mỗi phút. [NPD R1: không còn chặn, xem ghi chú NPD R1 bên dưới]
//   * V38 PAIRA_LOOP (Owner 24/10/2026, A2 / B5 / D7): Mode 2 đã gỡ → số cấp = Max_Orders. Sau một rebase Progressive PairClose về Lk (cấp ảo k, vị thế cũ nhất
//     còn mở = cấp k, offset k − 1): nhóm g chứa cấp k được DỰNG LẠI từ Lk thật (GgOnRebase): k = cấp anchor → anchor = giá mở Lk; k giữa nhóm → anchor ảo =
//     giá mở Lk ∓ G(k) (cùng quy ước BUY phía trên / SELL phía dưới); nhóm 0 → FirstPrice ảo (đường trigger V26). Biên nhóm chạy từ tick rebase; k là cấp cuối nhóm
//     → nhóm đóng băng ngay tại tick rebase, anchor nhóm kế = phá biên ± D. Các nhóm dưới cấp k là lịch sử (vị thế đã đóng): KHÔNG dựng lại, không làm anchor.
//     Cấp k+1.. theo đúng nhóm K / anchor / G / chiều / lot của GLOBAL Mode 1. Bản ghi lưu bền gồm offset + giờ rebase.
//   * RECURSIVE PAIR_A REBASE V1 (Owner 31/10/2026 §8): cơ chế rebase PAIRA_LOOP ở trên (nhóm gốc chứa Lk) và mọi nhánh sổ BO (TPC2) đã GỠ. Trong SubGridEpoch e >= 1
//     của RPA, cấu trúc nhóm được TÁI LẬP THEO TẬP CON: cấp con s = 1 là Lk* (vị thế nền), s = j + 1 là lệnh mở thêm thứ j (cấp ảo L(k+j)*); nhóm 0 = s 1..K neo tại
//     VirtualEntryAnchor (GgOnRebase, biên chạy từ tick rebase); nhóm g >= 1 = phá biên nhóm trước ± D (BUY >= GroupHigh + D, SELL <= GroupLow − D) như GLOBAL Mode 1;
//     cấp trong nhóm = anchor nhóm ± G của CẤP ẢO (G(k+j−1), cùng quy ước V26); số cấp con tối đa = 1 + GridMaxOrders. Nhóm của epoch trước KHÔNG BAO GIỜ làm anchor.
//   * RPA V1-R1 (Owner 01/11/2026 PHASE 5): Lk* = L1 của MỘT GLOBAL Grid Mode 1 MỚI. "Cấp" của module trong epoch e >= 1 = CẤP LOCAL n (Lk* = 1, lệnh mở thêm j = j + 1);
//     cấp trong nhóm = anchor nhóm ± G(n − 1) của CẤP LOCAL (nhóm 0: VirtualEntryAnchor ± G1, G2, ... như Grid cha từ L1), KHÔNG dùng cấp hiển thị k + n − 1 (đã gỡ GgVlOff).
//     [GLOBAL GEN] (Owner 03/11/2026): hai luật "anchor ± G" ở trên ĐÃ THAY — mọi cấp nội bộ (nhóm 0 và nhóm >= 1, Grid gốc và tập con) = anchor của CHÍNH nhóm đó
//     ± GlobalGrid_LocalDistancesPips[localIndex − 1] pip, localIndex = cấp − cấp anchor của nhóm (GgTrigger). Cấp LOCAL n của tập con giữ nguyên.
//     Nhóm 0 neo tại DecisionMarketAnchor; biên nhóm 0 = Ask cao nhất / Bid thấp nhất QUAN SÁT TỪ TICK QUYẾT ĐỊNH (GgOnRebaseCommit ghi biên chờ từ tick cam kết, GgObserve
//     cập nhật mỗi tick trong lúc nén, lưu bền + bù khoảng trống bằng lịch sử tick khi khởi động lại); mất biên chờ → lịch sử tick từ tick quyết định, không đọc được →
//     KHÔNG giả lập high/low: anchor phá vỡ bị chặn tới khi GgRetryHistory đọc được lịch sử (g_ggHistOk) [NPD R1: không còn chặn]. Bố cục nhóm = Gg38* với số cấp tối đa 1 + GridMaxOrders.
//   * [NPD R1] (Owner HOTFIX 03/11/2026): anchor phá vỡ của nhóm g >= 1 KHÔNG còn đo từ biên GroupHigh / GroupLow quan sát (cũng không từ lệnh cuối / anchor nhóm trước):
//     mốc = các VỊ THẾ ĐANG MỞ của nhóm g − 1 CÙNG CHIỀU với lệnh mới — BUY: giá mở BUY cao nhất + D, SELL: giá mở SELL thấp nhất − D (GgNpdReference / Gg38Npd*).
//     Biên quan sát, đóng băng biên, lịch sử tick (g_ggHistOk, S09) ở trên vẫn chạy và lưu bền nhưng CHỈ để ghi log: không quyết định nào đọc chúng nữa.
#ifndef OFH38_GLOBALGRID_MQH
#define OFH38_GLOBALGRID_MQH

// [FINAL STANDALONE] ===== BEGIN INLINED OFH38_GlobalGrid_Core.mqh (HOTFIX SHA256 4207F313B63BEBAD516ED494A1E3A4E43FB9654B649E873CA442BAD863C859A5) — included from OFH38_GlobalGrid.mqh:L32 =====
// OFH38_GlobalGrid_Core.mqh — V38 GLOBAL Grid AI Pro: phép tính nhóm thuần (không gọi lệnh, không dùng biến EA). Unit-test được.
// Level n (1..Max_Orders) theo quy ước đếm lệnh của V26. k = GlobalGrid_OrdersPerGroup.
//   nhóm g (0-based) = L(g·k+1) … L(g·k+k); nhóm cuối kết thúc tại Max_Orders (có thể ngắn hơn).
//   Phần dư đúng 1 lệnh được GỘP vào nhóm trước (không có nhóm 1 lệnh) — đúng ví dụ Owner: 5/nhóm → … L16-L20, L21-L26;
//   4/nhóm → … L21-L24, L25-L26; 6/nhóm → … L19-L24, L25-L26 (cùng định nghĩa GROUPS3/4/5 của nghiên cứu GLOBAL).
//   L đầu nhóm = MỐC GIÁ (anchor) của nhóm. g = 0: anchor = L1 (FirstPrice; tập con RPA: DecisionMarketAnchor).
//   [GLOBAL GEN] Level trong nhóm (n > anchor): localIndex = n − anchor nhóm; trigger = giá anchor ± GlobalGrid_LocalDistancesPips[localIndex − 1] pip — MỌI nhóm,
//   kể cả nhóm 0 (trước GLOBAL GEN: nhóm 0 = trigger V26, nhóm >= 1 = anchor ± G(n−1) tuyệt đối gốc — đã thay theo chỉ thị Owner 03/11/2026).
//   Anchor nhóm g ≥ 1: chỉ khi nhóm g−1 đã hoàn tất: [NPD R1] BUY cần Ask ≥ giá mở BUY cao nhất của các vị thế ĐANG MỞ thuộc nhóm g−1 + D, SELL cần
//   Bid ≤ giá mở SELL thấp nhất của các vị thế đang mở thuộc nhóm g−1 − D (khối [NPD CORE]; trước NPD R1: GroupHigh + D / GroupLow − D của biên quan sát).
//   Chiều, lot, số lệnh tối đa, BE / T1 / T2: liên tục toàn cục như V26.
#ifndef OFH38_GLOBALGRID_CORE_MQH
#define OFH38_GLOBALGRID_CORE_MQH

#define GG38_MAXG 32

int  Gg38GroupCount(const int k, const int maxOrders)
{
   int n = (maxOrders + k - 1) / k;
   if(n > 1 && maxOrders % k == 1) n--;                         // a single remaining level joins the previous group
   return n;
}
int  Gg38GroupOf(const int level, const int k, const int maxOrders) { const int g = (level - 1) / k, n = Gg38GroupCount(k, maxOrders); return g < n ? g : n - 1; }
int  Gg38AnchorOf(const int g, const int k)                         { return g * k + 1; }
int  Gg38EndOf(const int g, const int k, const int maxOrders)       { return (g >= Gg38GroupCount(k, maxOrders) - 1) ? maxOrders : g * k + k; }
bool Gg38IsBreakoutAnchor(const int level, const int k, const int maxOrders)
{
   return level > 1 && (level - 1) % k == 0 && (level - 1) / k < Gg38GroupCount(k, maxOrders);
}
bool Gg38ConfigOk(const int k, const int maxOrders) { return k >= 2 && k <= maxOrders && Gg38GroupCount(k, maxOrders) <= GG38_MAXG; }

// Level trong nhóm: anchor ± khoảng dist (BUY phía trên, SELL phía dưới — cùng quy ước GetTrigger của V26 với FirstPrice). [GLOBAL GEN]: dist = phần tử localIndex của
// GlobalGrid_LocalDistancesPips × pip (Gg38LocalTrigger), không còn G(n−1).
double Gg38InternalTrigger(const double anchorPx, const bool isBuy, const double dist) { return isBuy ? anchorPx + dist : anchorPx - dist; }
// Anchor phá vỡ: BUY = mốc + D; SELL = mốc − D. [NPD R1] mốc = giá mở BUY cao nhất / SELL thấp nhất của vị thế đang mở cùng chiều thuộc nhóm trước (Gg38NpdTriggerPx
// gọi với groupHigh = groupLow = mốc); trước NPD R1: GroupHigh (Ask cao nhất) / GroupLow (Bid thấp nhất) quan sát.
double Gg38BreakoutTrigger(const bool isBuy, const double groupHigh, const double groupLow, const double d) { return isBuy ? groupHigh + d : groupLow - d; }

// [GLOBAL GEN CORE BEGIN] ---------------------------------------------------------------------------------------------------------------------------------------
// GLOBAL MODE 1 GENERALIZED (Owner 03/11/2026): pure rules, no terminal call, no EA variable. K / D / the internal distance list are CUSTOMER inputs: nothing here
// depends on a particular K, D or list (no branch per K). Levels are counted 1..levels (original grid: levels = Max_Orders; subgrid epoch: levels = 1 + Max_Orders,
// local level 1 = Lk*). Groups = Gg38GroupCount / Gg38GroupOf / Gg38AnchorOf / Gg38EndOf above (a remainder of exactly one level joins the previous group).
#define GG38_LD_MAX        64   // longest distance list kept (the largest requirement is Max_Orders <= 60 elements)
#define GG38_LD_OK          0
#define GG38_LD_EMPTY      -1   // the list has no element (empty / blanks only)
#define GG38_LD_FORMAT     -2   // an element is not a plain decimal number (digits, at most one '.'), or an element is empty (",," / separator at an end)
#define GG38_LD_NEGATIVE   -3   // an element is a negative number
#define GG38_LD_NOT_FINITE -4   // an element does not fit a double
#define GG38_LD_TOO_LONG   -5   // more than GG38_LD_MAX elements
#define GG38_LD_SHORT      -6   // fewer elements than the group structure needs
#define GG38_LD_TEXT_LONG  -7   // the list text is longer than GG38_LD_TEXT_MAX: it may have been cut by the terminal (see below)
#define GG38_LD_MIXED_SEP  -8   // both ',' and ';' used: "12,5;25" may be a decimal comma (12.5) -> ambiguous, refused (one separator per list)
// MT5 delivers a string input through a "name=value" line of at most 255 characters (measured in the Strategy Tester: 699 characters sent, 255 - len(name) - 1
// received, no error). For GlobalGrid_LocalDistancesPips (29 characters) a value of 225 characters may be the cut of a longer list, and a cut list can still read
// as valid ("...,48" -> "...,4"): a text of 225+ characters is refused (fail-closed), 224 is the longest accepted.
#define GG38_LD_TEXT_MAX  224

// size of group g in a structure of `levels` levels; local index of a level (0 = the group anchor = local L1, i >= 1 = local L(i+1) -> element i of the list)
int    Gg38GroupSize(const int g, const int k, const int levels) { return Gg38EndOf(g, k, levels) - Gg38AnchorOf(g, k) + 1; }
int    Gg38LocalIndex(const int level, const int k, const int levels) { return level - Gg38AnchorOf(Gg38GroupOf(level, k, levels), k); }
// largest internal position count (group size - 1) of one structure
int    Gg38MaxInternal(const int k, const int levels)
{
   int m = 0;
   const int n = Gg38GroupCount(k, levels);
   for(int g = 0; g < n; g++) { const int s = Gg38GroupSize(g, k, levels) - 1; if(s > m) m = s; }
   return m;
}
// elements of the list the EA needs: the original grid (Max_Orders levels) AND a subgrid epoch (Lk* + Max_Orders additional orders = 1 + Max_Orders local levels)
int    Gg38LdRequired(const int k, const int maxOrders) { const int a = Gg38MaxInternal(k, maxOrders), b = Gg38MaxInternal(k, maxOrders + 1); return a > b ? a : b; }

// one element: blanks around it, then digits with at most one '.' and at least one digit. A leading '-' before such a number = NEGATIVE; anything else = FORMAT.
int    Gg38LdParseOne(const string tok, double &v)
{
   v = 0.0;
   string t = tok;
   StringTrimLeft(t); StringTrimRight(t);
   const int n = StringLen(t);
   if(n == 0) return GG38_LD_FORMAT;
   const bool neg = (StringGetCharacter(t, 0) == '-');
   int digits = 0, dots = 0;
   for(int i = neg ? 1 : 0; i < n; i++)
   {
      const ushort c = StringGetCharacter(t, i);
      if(c >= '0' && c <= '9') digits++;
      else if(c == '.') dots++;
      else return GG38_LD_FORMAT;
   }
   if(digits == 0 || dots > 1) return GG38_LD_FORMAT;
   if(neg) return GG38_LD_NEGATIVE;
   v = StringToDouble(t);
   if(!MathIsValidNumber(v)) { v = 0.0; return GG38_LD_NOT_FINITE; }
   return GG38_LD_OK;
}
// the whole list: elements separated by ',' or by ';' (one kind per list). Returns the element count (>= 1) or a GG38_LD_* error (< 0); badPos = 1-based element of the error.
int    Gg38LdParse(const string s, double &out[], int &badPos)
{
   ArrayResize(out, 0); badPos = 0;
   if(StringLen(s) > GG38_LD_TEXT_MAX) return GG38_LD_TEXT_LONG;   // raw length (blanks included): what the terminal delivered
   string t = s;
   StringTrimLeft(t); StringTrimRight(t);
   const int len = StringLen(t);
   if(len == 0) return GG38_LD_EMPTY;
   if(StringFind(t, ",") >= 0 && StringFind(t, ";") >= 0) return GG38_LD_MIXED_SEP;
   int n = 0, from = 0;
   for(int i = 0; i <= len; i++)
   {
      const ushort c = (i < len) ? StringGetCharacter(t, i) : (ushort)',';
      if(c != ',' && c != ';') continue;
      if(n >= GG38_LD_MAX) { badPos = n + 1; ArrayResize(out, 0); return GG38_LD_TOO_LONG; }
      double v = 0.0;
      const int r = (i > from) ? Gg38LdParseOne(StringSubstr(t, from, i - from), v) : GG38_LD_FORMAT;
      if(r != GG38_LD_OK) { badPos = n + 1; ArrayResize(out, 0); return r; }
      ArrayResize(out, n + 1); out[n] = v; n++;
      from = i + 1;
   }
   return n;
}
// the parsed list serves a structure that needs `required` elements: the parse error, SHORT, or OK (extra elements are allowed and never used)
int    Gg38LdCheck(const int parsed, const int required) { if(parsed < 0) return parsed; if(parsed < required) return GG38_LD_SHORT; return GG38_LD_OK; }
string Gg38LdErrName(const int c)
{
   switch(c)
   {
      case GG38_LD_OK: return "OK";                 case GG38_LD_EMPTY: return "EMPTY_LIST";        case GG38_LD_FORMAT: return "FORMAT_ERROR";
      case GG38_LD_NEGATIVE: return "NEGATIVE_VALUE"; case GG38_LD_NOT_FINITE: return "NOT_FINITE";   case GG38_LD_TOO_LONG: return "TOO_MANY_ELEMENTS";
      case GG38_LD_SHORT: return "TOO_FEW_ELEMENTS"; case GG38_LD_TEXT_LONG: return "TEXT_LONGER_THAN_224_CHARACTERS_MAY_BE_CUT";
      case GG38_LD_MIXED_SEP: return "MIXED_SEPARATORS_USE_ONLY_COMMA_OR_ONLY_SEMICOLON";
   }
   return "?";
}
// internal level (localIndex >= 1) of ANY group, group 0 included: the group anchor +/- element localIndex of the list (pip) x pip size (BUY above, SELL below)
double Gg38LocalTrigger(const double anchorPx, const bool isBuy, const double ldPips, const double pip) { return Gg38InternalTrigger(anchorPx, isBuy, ldPips * pip); }
// G03 breakout anchor on the price grid: BUY = smallest price of the point grid >= GroupHigh + D, SELL = largest <= GroupLow - D. A quote on the grid meets
// Ask >= GroupHigh + D (Bid <= GroupLow - D) exactly when it is >= (<=) this price; 1e-6 point absorbs the binary representation of decimal prices.
double Gg38BreakoutGridPx(const bool isBuy, const double groupHigh, const double groupLow, const double d, const double point)
{
   const double x = Gg38BreakoutTrigger(isBuy, groupHigh, groupLow, d);
   if(point <= 0.0) return x;
   const double q = x / point;
   return (isBuy ? MathCeil(q - 1e-6) : MathFloor(q + 1e-6)) * point;
}
// two latched lists differ (count or one element)
bool   Gg38LdDiffers(const double &a[], const int na, const double &b[], const int nb)
{
   if(na != nb) return true;
   for(int i = 0; i < na; i++) if(MathAbs(a[i] - b[i]) > 1e-9 * MathMax(1.0, MathAbs(b[i]))) return true;
   return false;
}
// a number without trailing zeros (journal) and a list as text
string Gg38Num(const double v)
{
   string s = DoubleToString(v, 8);
   if(StringFind(s, ".") >= 0) { int e = StringLen(s); while(e > 0 && StringGetCharacter(s, e - 1) == '0') e--; if(e > 0 && StringGetCharacter(s, e - 1) == '.') e--; s = StringSubstr(s, 0, e); }
   return s;
}
string Gg38LdText(const double &a[], const int n) { string s = ""; for(int i = 0; i < n; i++) s += (i > 0 ? "," : "") + Gg38Num(a[i]); return s; }
// group layout of a structure as text: "L1-L8,L9-L16,..."
string Gg38LayoutText(const int k, const int levels)
{
   string s = "";
   const int n = Gg38GroupCount(k, levels);
   for(int g = 0; g < n; g++) s += StringFormat("%sL%d-L%d", g > 0 ? "," : "", Gg38AnchorOf(g, k), Gg38EndOf(g, k, levels));
   return s;
}
// [GLOBAL GEN CORE END] -----------------------------------------------------------------------------------------------------------------------------------------
// [NPD CORE BEGIN] ----------------------------------------------------------------------------------------------------------------------------------------------
// [NPD R1] NEAREST POSITION DISTANCE (Owner HOTFIX 03/11/2026): pure rule of a breakout anchor (first order of GLOBAL group g >= 1); no terminal call, no EA variable.
// Input = every open position of the basket with the level the grid gives it in the CURRENT structure: lv[i] (1..levels; < 1 or > levels = no provable level),
// side[i] (+1 BUY / -1 SELL = the broker position type), expSide[i] (the side the grid rule gives to level lv[i]), px[i] (open price = the real fill).
// Reference of a breakout anchor of side isBuy in group g = the open price of the position NEAREST to the new order among the open positions of group g - 1 on the
// SAME side: BUY = the highest open BUY price, SELL = the lowest open SELL price (the new BUY stays at least D above every open BUY of the previous group, the new SELL
// at least D below every open SELL). Nothing else is read (no observed range, no last order in time, no group anchor). A reference that cannot be proved returns a
// status < 0 and the anchor waits: there is no fallback.
#define GG38_NPD_OK          0
#define GG38_NPD_NO_REF     -1   // group g - 1 has no open position on the side of the new order
#define GG38_NPD_UNPROVEN   -2   // an open position has no provable level of the structure: it could belong to group g - 1
#define GG38_NPD_SIDE_BAD   -3   // an open position is on the other side than the rule of its level: the level map is not trusted
#define GG38_NPD_PRICE_BAD  -4   // an open price in the reference set is not a finite price > 0
#define GG38_NPD_BAD_GROUP  -5   // g is not a breakout group of the structure (g < 1 or beyond the last group)
#define GG38_NPD_MAP        -6   // (EA) the level map of the open positions could not be built (position not readable / subgrid record differs from the broker)
int    Gg38NpdReference(const int &lv[], const int &side[], const int &expSide[], const double &px[], const int n, const int g, const int k, const int levels,
                        const bool isBuy, double &ref, int &refIdx, int &sameSide)
{
   ref = 0.0; refIdx = -1; sameSide = 0;
   if(g < 1 || g >= Gg38GroupCount(k, levels)) return GG38_NPD_BAD_GROUP;
   for(int i = 0; i < n; i++)
   {
      if(lv[i] < 1 || lv[i] > levels) return GG38_NPD_UNPROVEN;
      if((side[i] != 1 && side[i] != -1) || side[i] != expSide[i]) return GG38_NPD_SIDE_BAD;
   }
   const int a = Gg38AnchorOf(g - 1, k), e = Gg38EndOf(g - 1, k, levels), want = isBuy ? 1 : -1;
   for(int i = 0; i < n; i++)
   {
      if(lv[i] < a || lv[i] > e || side[i] != want) continue;
      if(!MathIsValidNumber(px[i]) || px[i] <= 0.0) { ref = 0.0; refIdx = -1; sameSide = 0; return GG38_NPD_PRICE_BAD; }   // nothing partial is returned
      sameSide++;
      if(refIdx < 0 || (isBuy ? px[i] > ref : px[i] < ref)) { ref = px[i]; refIdx = i; }
   }
   return sameSide > 0 ? GG38_NPD_OK : GG38_NPD_NO_REF;
}
// trigger on the point grid: BUY = smallest grid price >= ref + D, SELL = largest grid price <= ref - D (the unchanged G03 rounding, groupHigh = groupLow = ref)
double Gg38NpdTriggerPx(const bool isBuy, const double ref, const double d, const double point) { return Gg38BreakoutGridPx(isBuy, ref, ref, d, point); }
// distance of a breakout anchor fill from its reference (BUY fill - ref, SELL ref - fill): >= D on the trigger, lower only after a slippage of the market order
double Gg38NpdDistance(const bool isBuy, const double ref, const double fillPx) { return isBuy ? fillPx - ref : ref - fillPx; }
string Gg38NpdName(const int c)
{
   switch(c)
   {
      case GG38_NPD_OK: return "OK";                                      case GG38_NPD_NO_REF: return "NO_SAME_SIDE_OPEN_POSITION_IN_PREVIOUS_GROUP";
      case GG38_NPD_UNPROVEN: return "OPEN_POSITION_LEVEL_UNPROVEN";      case GG38_NPD_SIDE_BAD: return "OPEN_POSITION_SIDE_DIFFERS_FROM_LEVEL_RULE";
      case GG38_NPD_PRICE_BAD: return "OPEN_PRICE_INVALID";              case GG38_NPD_BAD_GROUP: return "NOT_A_BREAKOUT_GROUP";
      case GG38_NPD_MAP: return "LEVEL_MAP_NOT_AVAILABLE";
   }
   return "?";
}
// [NPD CORE END] ------------------------------------------------------------------------------------------------------------------------------------------------

#endif
// [FINAL STANDALONE] ===== END INLINED OFH38_GlobalGrid_Core.mqh =====
// [FINAL STANDALONE] ===== BEGIN INLINED OFH38_ManualRecovery_Core.mqh (HOTFIX SHA256 50D499FC1F500F50662BE7FF70A94D3065859327220BF0359EF970B3D0785AB1) — included from OFH38_GlobalGrid.mqh:L33 =====
// OFH38_ManualRecovery_Core.mqh — V38 R2/R3: luật THUẦN của khôi phục lệnh đóng tay (không gọi terminal) — unit test trong OFH38_UnitTests.mq5.
// Máy trạng thái giá của MỘT bản ghi (xác nhận hai lần RIÊNG của bản ghi, không dùng DblConfirm* của Grid), khối lượng còn thiếu / đủ / vượt
// theo bước lot, nhãn đối soát. R3: một bản ghi / VỊ THẾ GỐC (POSITION_IDENTIFIER); các lần đóng một phần của cùng vị thế gộp vào bản ghi đó;
// khóa lưu bền = deal đóng tay đầu tiên. R3 FINAL: từ 2 vị thế gốc khác nhau trong CHU KỲ → không khôi phục vị thế nào, MULTI_MANUAL_IGNORE tới hết
// chu kỳ (Mr38CycleDecision; thay Mr38BatchDecision "đợt" của R3).
#ifndef OFH38_MANUALRECOVERY_CORE_MQH
#define OFH38_MANUALRECOVERY_CORE_MQH

// Vòng đời (chỉ thị Owner 22/10/2026): WAIT_PRICE -> CONFIRM_1 -> WAIT_RETURN -> READY -> REQUEST_IN_FLIGHT -> PARTIALLY_FILLED / RECONCILING
// -> FILLED_CONFIRMED -> REMOVE_PENDING. Từ chối / lỗi kết nối -> RETRY (backoff có trần) -> STALLED; DD Lock -> SUSPENDED; cụm phẳng /
// BASKET_EXITING -> CANCELLED (yêu cầu còn đang bay -> CANCEL_RECONCILE: đối soát fill thật trước).
// R3: đợt 2+ vị thế / T1-T2 nắm cụm khi yêu cầu còn đang bay -> RECONCILE_ONLY (không bao giờ gửi lại; fill tới đủ khối lượng đã đóng là vị thế
// thật của cụm). REQUEST_IN_FLIGHT chỉ rời trạng thái khi có BẰNG CHỨNG dứt khoát (Mr38Definitive) — hết cửa sổ đối soát không phải bằng chứng.
#define MR_WAIT_PRICE        1   // chờ giá rời entry (xác định phía) rồi về chạm entry (lần 1)
#define MR_CONFIRM_1         2   // đã chạm lần 1, chờ giá rời lại
#define MR_WAIT_RETURN       3   // đã rời sau lần 1, chờ chạm lần 2
#define MR_READY             4   // đủ xác nhận: gửi ở tick này
#define MR_IN_FLIGHT         5   // REQUEST_IN_FLIGHT: đã gửi, broker nhận / chưa rõ — không gửi lại trước cửa sổ xác nhận + đối soát lịch sử
#define MR_PARTIAL           6   // PARTIALLY_FILLED / RECONCILING: khớp một phần, còn thiếu — gửi phần còn thiếu khi giá vẫn ở phía về
#define MR_FILLED            7   // FILLED_CONFIRMED: lịch sử deal xác nhận đủ khối lượng
#define MR_REMOVE_PENDING    8   // gỡ khỏi hàng chờ + bộ nhớ lưu bền
#define MR_RETRY             9   // từ chối / lỗi: giữ bản ghi, gửi lại sau backoff khi giá vẫn ở phía về
#define MR_STALLED          10   // hết Exec_MaxAttempts: không gửi trong Exec_StallRetryMinutes
#define MR_SUSPENDED        11   // DD Lock nắm cụm: không gửi, không dùng giá quay lại để mở thêm
#define MR_CANCEL_RECONCILE 12   // cụm thoát / phẳng khi yêu cầu còn đang bay: đợi đối soát (fill trễ được đóng, không thành vị thế mồ côi)
#define MR_CANCELLED        13
#define MR_RECONCILE_ONLY   14   // R3: bỏ quyền gửi (2+ vị thế gốc / T1-T2) khi yêu cầu đang bay: chỉ đối soát, fill <= khối lượng đã đóng giữ trong cụm

// lý do khóa Grid của cụm (BLOCKER: chỉ số level không chứng minh được; T1 / T2 / PairClose / DD / thoát vẫn chạy)
#define MRF_REENTRY_OFF     1   // R2 (R3: không còn khóa — sổ cấp)
#define MRF_RECORD_CAP      2
#define MRF_DEAL_UNREADABLE 3
#define MRF_OUT_OF_ORDER    4   // R2 (R3: không còn khóa — sổ cấp theo dõi vị thế rời cụm)
#define MRF_OVERFILL        5
#define MRF_SIDE_MISMATCH   6
#define MRF_LEVEL_UNPROVEN  7
#define MRF_GLOBAL_UNPROVEN 8   // R3: nhóm GLOBAL phải dựng lại mà vị thế gốc ở cấp anchor / cuối nhóm không còn (đã bỏ / chỉ còn vé vào lại)

// R3 FINAL (chỉ thị Owner 23/10/2026, mục 2): quyết định khi có deal đóng tay, đếm theo CHU KỲ (R3 đếm theo "đợt chưa khôi phục": vị thế đã khôi phục
// xong không còn tính → vị thế thứ hai đóng sau đó lại được khôi phục; R3 FINAL: vị thế gốc khác nhau thứ hai trong CÙNG chu kỳ → không khôi phục).
// Vị thế gốc = POSITION_IDENTIFIER của lệnh L1 / Grid đã mở cấp đó; vé vào lại / vé thêm (đóng một phần rồi vào lại) đứng tên vị thế gốc của CẤP mình
// (sổ cấp) — đóng tay vé đó là đóng tay CÙNG vị thế gốc, không phải vị thế thứ hai.
//   multiIgnore            MULTI_MANUAL_IGNORE đã bật trong chu kỳ (>= 2 vị thế gốc khác nhau đã bị đóng tay)
//   sameOrigRecovering     vị thế gốc này đang có bản ghi còn quyền khôi phục (các lần đóng một phần của cùng vị thế gốc cộng dồn vào đó)
//   sameOrigReconcileOnly  bản ghi của vị thế gốc này chỉ còn đối soát (yêu cầu đang bay, đã mất quyền gửi)
//   sameOrigSeen           vị thế gốc này đã bị đóng tay trước đó trong chu kỳ
//   originalsSeen          số vị thế gốc KHÁC NHAU đã bị đóng tay trong chu kỳ, trước deal này
#define MRB_MERGE        1   // cùng vị thế gốc đang khôi phục: cộng khối lượng vào bản ghi đó (1 vị thế)
#define MRB_RECEIPT_ONLY 2   // MULTI_MANUAL_IGNORE đang bật / bản ghi của vị thế gốc này chỉ còn đối soát: chỉ ghi nhận, không khôi phục
#define MRB_CREATE       3   // vị thế gốc DUY NHẤT của chu kỳ: một bản ghi khôi phục
#define MRB_ABANDON      4   // vị thế gốc thứ 2 khác nhau trong chu kỳ: bật MULTI_MANUAL_IGNORE tới hết chu kỳ, không khôi phục vị thế nào
#define MRB_REENTRY_OFF  5   // Owner tắt khôi phục (ManualReentry_Enable=false): chỉ ghi nhận + bỏ cấp nếu đóng hết, không lệnh nào

int Mr38CycleDecision(const bool reentryOn, const bool multiIgnore, const bool sameOrigRecovering, const bool sameOrigReconcileOnly, const bool sameOrigSeen, const int originalsSeen)
{
   if(multiIgnore) return MRB_RECEIPT_ONLY;
   if(originalsSeen + (sameOrigSeen ? 0 : 1) >= 2) return MRB_ABANDON;
   if(!reentryOn) return MRB_REENTRY_OFF;
   if(sameOrigRecovering) return MRB_MERGE;
   if(sameOrigReconcileOnly) return MRB_RECEIPT_ONLY;
   return MRB_CREATE;
}
string Mr38DecisionName(const int a)
{
   switch(a)
   {
      case MRB_MERGE: return "MERGE_SAME_ORIGINAL"; case MRB_RECEIPT_ONLY: return "RECEIPT_ONLY"; case MRB_CREATE: return "CREATE_SINGLE_ORIGINAL";
      case MRB_ABANDON: return "MULTI_MANUAL_IGNORE"; case MRB_REENTRY_OFF: return "REENTRY_OFF";
   }
   return "?";
}

// R3-04: yêu cầu vào lại đang bay chỉ được coi là ĐÃ KẾT THÚC khi có bằng chứng dứt khoát:
//   lệnh còn làm việc trên broker -> chưa; mọi lệnh đã biết của yêu cầu nằm trong lịch sử (trạng thái cuối) VÀ yêu cầu gần nhất được phủ -> có;
//   trả lời DONE / DONE_PARTIAL kèm khối lượng tăng trong lịch sử deal -> có. Không thấy gì (TIMEOUT / PLACED / DONE ảo) -> KHÔNG (chờ an toàn, không gửi).
bool Mr38Definitive(const bool orderWorking, const int ordersSeen, const int ordersFinal, const bool lastRequestCovered, const bool doneReply, const bool fillIncreased)
{
   if(orderWorking) return false;
   if(doneReply && fillIncreased) return true;
   return ordersSeen > 0 && ordersFinal == ordersSeen && lastRequestCovered;
}

// R3-01: khối lượng thừa CẦN đóng của một bản ghi đã xong = (đã vào - được phép - đã đóng ĐƯỢC BROKER XÁC NHẬN), không quá phần nhãn còn mở,
// làm tròn theo bước lot; <= nửa bước = 0. Yêu cầu đóng đang chờ / TIMEOUT / PLACED không được trừ.
double Mr38SurplusToClose(const double filled, const double allowed, const double closedConfirmed, const double openTagged, const double step)
{
   const double s = step > 0.0 ? step : 0.01;
   double ex = filled - allowed - closedConfirmed;
   if(ex > openTagged) ex = openTagged;
   if(ex <= s * 0.5) return 0.0;
   return NormalizeDouble(MathRound(ex / s) * s, 8);
}

string Mr38StateName(const int s)
{
   switch(s)
   {
      case MR_WAIT_PRICE: return "WAIT_PRICE";       case MR_CONFIRM_1: return "CONFIRM_1";          case MR_WAIT_RETURN: return "WAIT_RETURN";
      case MR_READY: return "READY";                 case MR_IN_FLIGHT: return "REQUEST_IN_FLIGHT";  case MR_PARTIAL: return "PARTIALLY_FILLED";
      case MR_FILLED: return "FILLED_CONFIRMED";     case MR_REMOVE_PENDING: return "REMOVE_PENDING"; case MR_RETRY: return "RETRY_BACKOFF";
      case MR_STALLED: return "STALLED";             case MR_SUSPENDED: return "SUSPENDED";          case MR_CANCEL_RECONCILE: return "CANCEL_RECONCILE";
      case MR_CANCELLED: return "CANCELLED";          case MR_RECONCILE_ONLY: return "RECONCILE_ONLY";
   }
   return "?";
}
// đã kết thúc: không bao giờ sống lại (khởi động lại chỉ gỡ nốt)
bool Mr38Terminal(const int s)  { return s == MR_FILLED || s == MR_REMOVE_PENDING || s == MR_CANCELLED; }
// yêu cầu có thể đang được broker xử lý: chỉ đối soát, không gửi mới
bool Mr38InFlight(const int s)  { return s == MR_IN_FLIGHT || s == MR_CANCEL_RECONCILE || s == MR_RECONCILE_ONLY; }
// bản ghi còn quyền khôi phục trong chu kỳ: Grid chờ (như manualWait của V26); R3: T1/T2 không chờ bản ghi
bool Mr38BlocksGrid(const int s) { return !Mr38Terminal(s) && s != MR_SUSPENDED && s != MR_CANCEL_RECONCILE && s != MR_RECONCILE_ONLY; }   // R3: T1/T2 never wait for records
// trạng thái theo dõi giá (bước Mr38PriceStep)
bool Mr38PriceState(const int s) { return s == MR_WAIT_PRICE || s == MR_CONFIRM_1 || s == MR_WAIT_RETURN; }

// phía của giá so với entry: +1 trên entry + off, -1 dưới entry - off, 0 trong vùng (chưa rời)
int  Mr38Away(const double entry, const double px, const double off) { if(px > entry + off) return 1; if(px < entry - off) return -1; return 0; }
// giá đã về tới / xuyên entry từ phía `side` (như `back` của V26 TryFillManualReentry)
bool Mr38Touch(const int side, const double entry, const double px)
{
   if(side > 0) return px <= entry + 1e-12;
   if(side < 0) return px >= entry - 1e-12;
   return false;
}
// một bước giá của bản ghi. dbl=false: như V26 (rời -> về một lần -> READY). dbl=true: rời -> về (CONFIRM_1) -> rời -> về (READY).
// side được cập nhật tại chỗ. Chỉ các trạng thái giá đổi ở đây.
int Mr38PriceStep(const int st, int &side, const double entry, const double px, const double off, const bool dbl)
{
   if(st == MR_WAIT_PRICE)
   {
      if(side == 0) { side = Mr38Away(entry, px, off); return st; }
      if(!Mr38Touch(side, entry, px)) return st;
      return dbl ? MR_CONFIRM_1 : MR_READY;
   }
   if(st == MR_CONFIRM_1)
   {
      const int a = Mr38Away(entry, px, off);
      if(a == 0) return st;
      side = a;
      return MR_WAIT_RETURN;
   }
   if(st == MR_WAIT_RETURN) return Mr38Touch(side, entry, px) ? MR_READY : st;
   return st;
}

// khối lượng còn thiếu, làm tròn theo bước lot (target / filled đều trên lưới lot); <= nửa bước = đủ (0)
double Mr38Remaining(const double target, const double filled, const double step)
{
   const double s = step > 0.0 ? step : 0.01;
   const double rem = target - filled;
   if(rem <= s * 0.5) return 0.0;
   return NormalizeDouble(MathRound(rem / s) * s, 8);
}
bool Mr38Complete(const double target, const double filled, const double step) { const double s = step > 0.0 ? step : 0.01; return filled >= target - s * 0.5; }
bool Mr38Overfill(const double target, const double filled, const double step)  { const double s = step > 0.0 ? step : 0.01; return filled > target + s * 0.5; }

// nhãn comment của lệnh vào lại (đối soát khi mất retcode / order ticket sau sự cố): "R2MR|<deal>|" — dấu | cuối chống trùng tiền tố (123 vs 1234)
string Mr38Tag(const ulong deal) { return "R2MR|" + IntegerToString((long)deal) + "|"; }
bool   Mr38TagIs(const string comment, const ulong deal) { return StringFind(comment, Mr38Tag(deal)) == 0; }

#endif
// [FINAL STANDALONE] ===== END INLINED OFH38_ManualRecovery_Core.mqh =====

// [MRR CORE BEGIN] ===== MANUAL REENTRY REMOVAL R1: pure rules (no terminal call), exercised by the integration harness tests/OFH38_MRR_Sim_NEW.mq5 =====
// M02: a manual-close deal of a FINISHED cycle: the closed position does not belong to the running basket (not in its level book) and was opened before it.
// "Before" = its position id (= the ticket of its opening order; server tickets only grow) is below the order ticket of the first order of the running basket
// when that ticket is known (no clock involved); else (restart) its opening time is before the start of the running BasketCycleID. Flat now -> not this rule.
bool Mrr38FinishedCycleClose(const ulong posId, const ulong cycleFirstOrder, const long posOpenMsc, const long cycleStartMsc, const bool knownToBook, const int basketPositions)
{
   if(basketPositions <= 0 || knownToBook) return false;
   if(cycleFirstOrder > 0) return posId > 0 && posId < cycleFirstOrder;
   return posOpenMsc > 0 && cycleStartMsc > 0 && posOpenMsc < cycleStartMsc;
}
// M03: a manual-close deal whose magic is not the EA magic belongs to the basket when it is an exit deal (OUT / INOUT / OUT_BY) with a manual reason (CLIENT /
// MOBILE / WEB) of a position the EA opened (entry deal of the EA magic on this symbol): the closing order of the terminal may carry its own magic.
bool Mrr38ForeignMagicOwned(const bool manualReason, const bool exitEntry, const bool positionOpenedByEa) { return manualReason && exitEntry && positionOpenedByEa; }
// M04: a position found while no cycle of the EA runs (flat basket finalized, no own L1 since) is a LATE FILL of the finished cycle when
//   - its order was still WORKING at the broker (or was the entry request without a broker result) at the finalization (orderListedAtFin), or
//   - it never was a position of the finished basket (id above the highest position id seen at a tick end of that cycle, finMaxSeen) and its order belongs to
//     the finished cycle (id not above the highest order ticket of the EA known at the finalization, finWm; server tickets only grow): an order DONE before the
//     finalization whose position was not listed yet, or
//   - with an entry request whose order ticket was unknown at the finalization: its order was set up before the finalization.
// A position that already was a position of the finished basket (id <= finMaxSeen, e.g. the terminal listed no position for one tick) is NEVER a late fill, and
// an order of the EA sent after the finalization (id > finWm) is never one.
bool Mrr38LateFillOfFinished(const bool orderListedAtFin, const bool unknownRequestAtFin, const long orderSetupMsc, const long finMsc, const ulong posId, const ulong finMaxSeen, const ulong finWm)
{
   if(finMsc <= 0) return false;
   if(orderListedAtFin) return true;
   if(posId > 0 && posId <= finMaxSeen) return false;
   if(finWm > 0 && posId > 0 && posId <= finWm) return true;
   return unknownRequestAtFin && orderSetupMsc > 0 && orderSetupMsc < finMsc;
}
#define MRR_LATE_NONE   0   // no late fill (or the finished basket itself reappeared): a basket adopted as before, never closed by this rule
#define MRR_LATE_CLOSE  1   // every open position is a late fill of the finished cycle: closed at once, never a new L1
#define MRR_LATE_MIXED  2   // late fills next to other (new) positions: broker state inconsistent -> no grid level (BLOCKER), exits keep working
// reappeared = open positions that were positions of the finished basket: the "flat" was transient -> nothing is classified late (adopted, logged)
int Mrr38LateAction(const int open, const int late, const int reappeared) { if(reappeared > 0 || late <= 0) return MRR_LATE_NONE; return late >= open ? MRR_LATE_CLOSE : MRR_LATE_MIXED; }
// M05: the level of a manual close is abandoned in the level book only when the position was fully closed and no position of that level is open any more
bool Mrr38AbandonClosedLevel(const int level, const bool partialClose, const bool levelStillOpen) { return level > 0 && !partialClose && !levelStillOpen; }
// [MRR CORE END] =====

// [DPMR CORE BEGIN] ===== [DPMR R1] pure rules (no terminal call, no EA variable): PairClose mode of a cycle (D01) and the DD HALT release verdict (D04)
#define DPMR_PC_V26 0   // PairClose_Mode 0 = V26_LEGACY_PAIR_CLOSE
#define DPMR_PC_RPA 1   // PairClose_Mode 1 = V38_RECURSIVE_PAIR_A
bool Dpmr38ModeValid(const int m) { return m == DPMR_PC_V26 || m == DPMR_PC_RPA; }
// mode of the tick: the latched mode of the open cycle, else the input (no cycle yet)
int  Dpmr38EffectiveMode(const bool latched, const int latchedMode, const int inputMode) { return latched ? latchedMode : inputMode; }
// mode of a cycle restored from its latch record: the recorded mode; a record of an older build (no mode key) = RPA (the only PairClose of those builds)
int  Dpmr38RestoredMode(const bool recordHasMode, const int recordMode) { return (recordHasMode && Dpmr38ModeValid(recordMode)) ? recordMode : DPMR_PC_RPA; }
// an RPA trace of the cycle (rebase / epoch / halted keep leg) proves mode 1 whatever the latch says
int  Dpmr38ModeAfterRpaEvidence(const int latchedMode, const bool rpaHadAny) { return rpaHadAny ? DPMR_PC_RPA : latchedMode; }
// pending legacy PairClose legs of a restored cycle record are finished only in a mode-0 cycle (mode 1: cleared, MRR R1 behaviour)
bool Dpmr38KeepLegacyLegs(const int cycleMode) { return cycleMode == DPMR_PC_V26; }

#define DDR38_RELEASE           0   // Owner full manual close proven: DDL_HALT -> NORMAL
#define DDR38_WAIT_NOT_FLAT     1   // a position of Magic / DDLock_HedgeMagic is still listed
#define DDR38_WAIT_ORDERS       2   // an order of Magic / DDLock_HedgeMagic still works at the broker
#define DDR38_WAIT_INFLIGHT     3   // a hedge / compression / entry / recovery / exit / pair request has no broker result yet
#define DDR38_WAIT_HISTORY      4   // deal history not readable, or a position of the episode has no complete closing volume in it yet
#define DDR38_KEEP_STOPOUT      5   // a close of the episode was a broker stop-out
#define DDR38_KEEP_NOT_MANUAL   6   // a close of the episode was not manual (EA / SL / TP / other)
#define DDR38_KEEP_NO_EVIDENCE  7   // no close deal of the episode found
// classes of an exit deal of an episode position
#define DDR38_CLS_MANUAL  1
#define DDR38_CLS_STOPOUT 2
#define DDR38_CLS_OTHER   3
int  Ddr38ClassOf(const long reason)
{
   if(reason == DEAL_REASON_CLIENT || reason == DEAL_REASON_MOBILE || reason == DEAL_REASON_WEB) return DDR38_CLS_MANUAL;
   if(reason == DEAL_REASON_SO) return DDR38_CLS_STOPOUT;
   return DDR38_CLS_OTHER;
}
// an exit deal belongs to the DD episode when it is at / after the trigger second (a close in the trigger second counts: fail-closed)
bool Ddr38InEpisode(const long dealMsc, const long trigTime) { return trigTime > 0 && dealMsc >= trigTime * 1000; }
int  Ddr38Verdict(const bool flat, const bool ordersWorking, const bool inflight, const bool historyOk, const int nUnclosed, const int nManual, const int nStopOut, const int nOther)
{
   if(!flat) return DDR38_WAIT_NOT_FLAT;
   if(ordersWorking) return DDR38_WAIT_ORDERS;
   if(inflight) return DDR38_WAIT_INFLIGHT;
   if(!historyOk || nUnclosed > 0) return DDR38_WAIT_HISTORY;
   if(nStopOut > 0) return DDR38_KEEP_STOPOUT;
   if(nOther > 0) return DDR38_KEEP_NOT_MANUAL;
   if(nManual <= 0) return DDR38_KEEP_NO_EVIDENCE;
   return DDR38_RELEASE;
}
string Ddr38Name(const int v)
{
   switch(v)
   {
      case DDR38_RELEASE: return "RELEASE_OWNER_MANUAL_FULL_CLOSE";   case DDR38_WAIT_NOT_FLAT: return "WAIT_NOT_FLAT";   case DDR38_WAIT_ORDERS: return "WAIT_ORDER_WORKING";
      case DDR38_WAIT_INFLIGHT: return "WAIT_REQUEST_IN_FLIGHT";        case DDR38_WAIT_HISTORY: return "WAIT_HISTORY_NOT_PROVEN";
      case DDR38_KEEP_STOPOUT: return "KEEP_HALT_STOP_OUT";            case DDR38_KEEP_NOT_MANUAL: return "KEEP_HALT_NOT_MANUAL_CLOSE"; case DDR38_KEEP_NO_EVIDENCE: return "KEEP_HALT_NO_CLOSE_EVIDENCE";
   }
   return "?";
}
// [DPMR CORE END] =====
// [DPMR R1] D04 state: DD HALT release checks (log / throttle only; the verdict is recomputed from the broker and the deal history at every evaluation)
long   g_dpmrDdChecks = 0, g_dpmrDdReleases = 0, g_dpmrDdKept = 0;   // evidence counters (log only)
int    g_dpmrDdLastVerdict = -1; long g_dpmrDdLastMsc = 0, g_dpmrDdLastEp = 0;
long   g_dpmrPairs = 0, g_dpmrPairPend = 0;   // [DPMR R1] D02 / D03 legacy PairClose evidence counters (log only)

// [L1RSI CORE BEGIN] ===== [L1RSI R1] pure rules (no terminal call, no EA variable): RSI period domain (R02) and the L1 side of a closed-bar RSI value (R03)
#define L1RSI_PERIOD_MIN 2   // multi-level RSI: the MT5 native iRSI with period 1 returns 0.0 on every closed bar (no level between the extremes -> BUY-only L1)
bool   L1Rsi38PeriodValid(const int period) { return period >= L1RSI_PERIOD_MIN; }
// a closed-bar RSI value the L1 may use: a number in [0, 100] (EMPTY_VALUE / NaN / out of range -> no L1 on the tick); the test of V26 / DPMR R1, unchanged
bool   L1Rsi38ValueValid(const double rsi) { return MathIsValidNumber(rsi) && rsi >= 0.0 && rsi <= 100.0; }
// L1 side of a valid value: +1 BUY, -1 SELL, 0 none. The two expressions are the V26 / DPMR R1 text, unchanged (0..30 BUY, >30..50 SELL, >50..70 BUY, >70..100 SELL)
int    L1Rsi38Side(const double rsi)
{
   bool isBuy  = (rsi>=0 && rsi<=30) || (rsi>50 && rsi<=70);
   bool isSell = (rsi>30 && rsi<=50) || (rsi>70 && rsi<=100);
   if(isBuy && !isSell) return 1;
   if(isSell && !isBuy) return -1;
   return 0;
}
string L1Rsi38BandName(const double rsi)
{
   if(!L1Rsi38ValueValid(rsi)) return "invalid";
   if(rsi <= 30) return "0..30 BUY";
   if(rsi <= 50) return ">30..50 SELL";
   if(rsi <= 70) return ">50..70 BUY";
   return ">70..100 SELL";
}
// [L1RSI CORE END] =====

// [RSI2 CORE BEGIN] ===== [RSI SAFETY R2] pure rules (no terminal call, no EA variable): start decision with an invalid RSI_Period (S01), PROTECTIVE_ONLY action
// policy (S02, white list = fail-closed), protective phase (S03 / S04)
#define RSI2_INIT_NORMAL       0   // RSI_Period valid: normal start (L1RSI R1)
#define RSI2_INIT_REJECT       1   // RSI_Period < 2, broker state proven, flat for the EA, nothing to reconcile: OnInit refuses (CONFIG ERROR)
#define RSI2_INIT_PROTECTIVE   2   // RSI_Period < 2 and EA exposure / something to reconcile / broker state not proven: PROTECTIVE_ONLY
// brokerProven = account known + persisted state restored + terminal connected (the position / order lists are the broker's); pending = a request / record to
// reconcile, or records of an OPEN cycle found before the restore (a basket the EA believed open at its last stop)
int    Rsi2InitDecision(const bool periodValid, const bool brokerProven, const int eaPositions, const int hedgePositions, const int workingOrders, const bool pending)
{
   if(periodValid) return RSI2_INIT_NORMAL;
   if(!brokerProven) return RSI2_INIT_PROTECTIVE;   // ownership not established: no risk, nothing guessed, decided again on the ticks (phase)
   if(eaPositions > 0 || hedgePositions > 0 || workingOrders > 0 || pending) return RSI2_INIT_PROTECTIVE;
   return RSI2_INIT_REJECT;
}
// actions of the EA (S02)
#define RSI2_ACT_NEW_L1          1   // P5: new L1
#define RSI2_ACT_GRID_LEVEL      2   // P11: next level (V26 grid, GLOBAL group, RPA subgrid additional order)
#define RSI2_ACT_PAIR_DECISION   3   // PairClose_Mode 0: a NEW legacy pair (P3 B3 / P8)
#define RSI2_ACT_RPA_REBASE      4   // PairClose_Mode 1: a NEW rebase commit (new Lk* / SubGridEpoch)
#define RSI2_ACT_ENTRY_ORDER     5   // any Magic entry order (TrySendOrder backstop)
#define RSI2_ACT_MANUAL_REENTRY  6   // price-return re-entry of a manual close (removed by MRR R1)
#define RSI2_ACT_DD_HEDGE        10  // DD Hedge Lock: lock / compression / release (DDLock_HedgeMagic)
#define RSI2_ACT_T1T2            11  // T1 lock, T2 trailing, broker SL / TP
#define RSI2_ACT_EXIT_CLOSE      12  // basket exit, session close protect, L1 TP / %YP, late-fill / orphan close
#define RSI2_ACT_FINISH_PENDING  13  // a committed close: pending legacy PairClose leg, RPA rebase in progress (closes only)
#define RSI2_ACT_RECONCILE       14  // broker / deal-history reconciliation, cycle finalization, persisted records
// PROTECTIVE_ONLY runs ONLY the protective actions of the white list; anything else (listed above as blocked, or unknown) is refused
bool   Rsi2Allowed(const bool protectiveOnly, const int act)
{
   if(!protectiveOnly) return true;
   return act == RSI2_ACT_DD_HEDGE || act == RSI2_ACT_T1T2 || act == RSI2_ACT_EXIT_CLOSE || act == RSI2_ACT_FINISH_PENDING || act == RSI2_ACT_RECONCILE;
}
// protective phase (S03 / S04, log): RESTORE_PENDING -> MANAGING (positions / hedge) -> RECONCILING (flat, an order / request / record left) -> FLAT_BLOCKED
#define RSI2_PH_NORMAL           0
#define RSI2_PH_RESTORE_PENDING  1
#define RSI2_PH_MANAGING         2
#define RSI2_PH_RECONCILING      3
#define RSI2_PH_FLAT_BLOCKED     4
int    Rsi2Phase(const bool protectiveOnly, const bool accountKnown, const int eaPositions, const int hedgePositions, const int workingOrders, const bool pending)
{
   if(!protectiveOnly) return RSI2_PH_NORMAL;
   if(!accountKnown) return RSI2_PH_RESTORE_PENDING;
   if(eaPositions > 0 || hedgePositions > 0) return RSI2_PH_MANAGING;
   if(workingOrders > 0 || pending) return RSI2_PH_RECONCILING;
   return RSI2_PH_FLAT_BLOCKED;
}
string Rsi2PhaseName(const int p)
{
   switch(p)
   {
      case RSI2_PH_NORMAL: return "NORMAL";                   case RSI2_PH_RESTORE_PENDING: return "RESTORE_PENDING";   case RSI2_PH_MANAGING: return "MANAGING";
      case RSI2_PH_RECONCILING: return "RECONCILING";         case RSI2_PH_FLAT_BLOCKED: return "FLAT_BLOCKED";
   }
   return "?";
}
string Rsi2ActName(const int a)
{
   switch(a)
   {
      case RSI2_ACT_NEW_L1: return "NEW_L1";                  case RSI2_ACT_GRID_LEVEL: return "GRID_LEVEL";            case RSI2_ACT_PAIR_DECISION: return "NEW_PAIRCLOSE_PAIR";
      case RSI2_ACT_RPA_REBASE: return "NEW_RPA_REBASE";      case RSI2_ACT_ENTRY_ORDER: return "ENTRY_ORDER";          case RSI2_ACT_MANUAL_REENTRY: return "MANUAL_REENTRY";
      case RSI2_ACT_DD_HEDGE: return "DD_HEDGE";              case RSI2_ACT_T1T2: return "T1_T2";                       case RSI2_ACT_EXIT_CLOSE: return "EXIT_CLOSE";
      case RSI2_ACT_FINISH_PENDING: return "FINISH_PENDING";  case RSI2_ACT_RECONCILE: return "RECONCILE";
   }
   return "?";
}
// [RSI2 CORE END] =====
// [RSI SAFETY R2] state (log / evidence only except g_rsiProt, which is set once in OnInit from the input and never changed while the EA runs)
bool   g_rsiProt = false;                    // PROTECTIVE_ONLY (RSI_Period < 2 with EA exposure / something to reconcile / account not known at OnInit)
int    g_rsiPhase = RSI2_PH_NORMAL;
long   g_rsiBlk[8];                          // blocked attempts per action 1..6 (evidence)
string g_rsiBlkKeys = "";
long   g_rsiPhaseChanges = 0;

// [SU3 CORE BEGIN] ===== [STARTUP SAFETY R3] pure rule (no terminal call, no EA variable): may the restore run on the broker evidence of this moment (U01)
#define SU3_RESTORE_EXPOSURE   0   // EA / hedge positions listed and every recorded ticket listed or proven closed: restore now (the records belong to the basket)
#define SU3_RESTORE_FLAT       1   // flat for the EA PROVEN by the evidence: restore now (a proven-closed cycle may be cleaned up)
#define SU3_WAIT_IDENTITY      2   // account login / server unknown: the records cannot even be named
#define SU3_WAIT_CONNECTION    3   // terminal not connected
#define SU3_WAIT_ACCOUNT_SYNC  4   // the account lists no position / order but shows margin or floating P/L: the lists are not synchronised
#define SU3_WAIT_HISTORY_OPEN  5   // the deal history shows an EA / hedge position open that the list does not show
#define SU3_WAIT_RECORDED      6   // a ticket of the recorded open cycle is neither listed nor proven closed by its deals
#define SU3_WAIT_COVERAGE      7   // records of an open cycle without tickets: the history does not reach the cycle start yet
#define SU3_OWNER_REQUIRED     8   // records of an open cycle with no ticket and no cycle start: flatness cannot be proven, never guessed
int    Su3Verdict(const bool identityKnown, const bool connected, const int eaListed, const int hedgeListed, const bool accountListsEmpty, const bool accountShowsExposure,
                  const int historyOpenUnlisted, const bool openCycleRecords, const int recordedTickets, const int recordedListedOrClosed, const bool cycleStartKnown,
                  const bool historyCoversStart)
{
   if(!identityKnown) return SU3_WAIT_IDENTITY;
   if(!connected) return SU3_WAIT_CONNECTION;
   if(eaListed <= 0 && hedgeListed <= 0 && accountListsEmpty && accountShowsExposure) return SU3_WAIT_ACCOUNT_SYNC;
   if(historyOpenUnlisted > 0) return SU3_WAIT_HISTORY_OPEN;
   if(recordedTickets > 0 && recordedListedOrClosed < recordedTickets) return SU3_WAIT_RECORDED;
   if(eaListed > 0 || hedgeListed > 0) return SU3_RESTORE_EXPOSURE;
   if(openCycleRecords && recordedTickets <= 0)
   {
      if(!cycleStartKnown) return SU3_OWNER_REQUIRED;
      if(!historyCoversStart) return SU3_WAIT_COVERAGE;
   }
   return SU3_RESTORE_FLAT;
}
bool   Su3MayRestore(const int v) { return v == SU3_RESTORE_EXPOSURE || v == SU3_RESTORE_FLAT; }
string Su3Name(const int v)
{
   switch(v)
   {
      case SU3_RESTORE_EXPOSURE: return "RESTORE_EXPOSURE";     case SU3_RESTORE_FLAT: return "RESTORE_FLAT_PROVEN";      case SU3_WAIT_IDENTITY: return "WAIT_IDENTITY";
      case SU3_WAIT_CONNECTION: return "WAIT_CONNECTION";       case SU3_WAIT_ACCOUNT_SYNC: return "WAIT_ACCOUNT_SYNC";   case SU3_WAIT_HISTORY_OPEN: return "WAIT_HISTORY_OPEN";
      case SU3_WAIT_RECORDED: return "WAIT_RECORDED_POSITIONS"; case SU3_WAIT_COVERAGE: return "WAIT_HISTORY_COVERAGE"; case SU3_OWNER_REQUIRED: return "OWNER_REQUIRED";
   }
   return "?";
}
// [SU3 CORE END] =====
// [STARTUP SAFETY R3] state (log / evidence / throttle only)
int      g_su3Verdict = -1;
string   g_su3LastLog = "";
datetime g_su3LastEval = 0;
long     g_su3Evals = 0, g_su3Waits = 0, g_su3RestExp = 0, g_su3RestFlat = 0, g_su3Owner = 0;

// [MRR R1] state: last finalized cycle (M04, persisted OFH38Z), the wait for the new L1 after a cycle with a manual close / late fill (M06 log), evidence counters
long     g_mrrFinCyc = 0, g_mrrFinMsc = 0;   // finished BasketCycleID / tick msc of its finalization (flat basket)
#define  MRR_LATE_MAX 32
ulong    g_mrrLateOrd[MRR_LATE_MAX]; int g_mrrLateOrdN = 0;   // M04: orders of the EA still working (or the entry request without result) at the finalization
bool     g_mrrLateUnknown = false;           // M04: an entry request without a broker result and without an order ticket existed at the finalization
bool     g_mrrSeenPos = false;               // M04: a position of the running cycle was seen at the end of a tick (a cycle never seen is not finalized)
ulong    g_mrrMaxSeenId = 0;                 // M04: highest position id of the running cycle seen at the end of a tick
ulong    g_mrrFinMaxSeen = 0, g_mrrFinWm = 0; // M04: of the finalized cycle: highest position id seen / highest order ticket of the EA known at the finalization
ulong    g_mrrCycFirstOrd = 0;               // M02: order ticket of the first order of the running basket (its L1 / the lowest position id at adoption), 0 = unknown
bool     g_mrrAwaitL1 = false;               // a cycle with a manual close / late fill was finalized: "L1 BLOCKED | reason" lines until the new L1
int      g_mrrManualDeals = 0;               // manual-close deals of the running cycle (log)
bool     g_mrrFullManual = false;            // the last position of the running cycle was closed by hand (log)
bool     g_mrrLateClosed = false;            // the running "cycle" is a late fill being closed (log)
string   g_mrrL1Why = "";                    // last "L1 BLOCKED" reason printed
int      g_mrrRestLv[]; int g_mrrRestLvN = 0; // M05: levels of OLD same-cycle recovery records cancelled at a restart (abandoned once the level book is restored)
long     g_mrrStale = 0, g_mrrForeignMagic = 0, g_mrrLateFills = 0, g_mrrLateMixed = 0, g_mrrAbandoned = 0, g_mrrL1Blocks = 0, g_mrrFinalized = 0, g_mrrFullCloses = 0;

bool     g_ggOn[GG38_MAXG];                        // nhóm có anchor đang mở
double   g_ggAnchorPx[GG38_MAXG];
long     g_ggAnchorMsc[GG38_MAXG];
double   g_ggRunHi[GG38_MAXG], g_ggRunLo[GG38_MAXG]; // Ask cao nhất / Bid thấp nhất từ lúc anchor khớp
bool     g_ggFrozen[GG38_MAXG];
bool     g_ggFrzNoHist[GG38_MAXG];   // [SAFETY S09] frozen while the tick history was not readable (range from the quotes seen since the restart only)
double   g_ggFrzHi[GG38_MAXG], g_ggFrzLo[GG38_MAXG];
long     g_ggFrzMsc[GG38_MAXG];
long     g_ggLastMsc   = 0;      // tick cuối đã quan sát (khởi động lại bù từ đây)
bool     g_ggHistOk    = true;   // false: biên cần lịch sử tick chưa đọc được ([NPD R1] biên chỉ còn để ghi log: KHÔNG còn chặn anchor phá vỡ)
datetime g_ggHistRetry = 0;
datetime g_ggLastSave  = 0;
string   g_ggBlockKey  = "";
bool     g_ggPersisted = false;  // a record of this basket exists in the terminal global variables
bool     g_ggRebuilt   = false;  // R2: this restart rebuilt the groups from the open positions (no valid record)

long     g_ggRebaseMsc = 0;      // RPA: decision tick of the rebase group 0 of the epoch is anchored at (0 = no rebase in this cycle)
// R1: range of group 0 of the NEXT epoch, observed from the decision (commit) tick while the rebase executes (Ask max / Bid min)
bool     g_ggPendOn = false; long g_ggPendMsc = 0; double g_ggPendHi = 0.0, g_ggPendLo = 0.0;

// OWNER12 (Owner 25/10/2026 mục 1): kiểu vào lệnh / K / D = giá trị ĐÃ CHỐT của chu kỳ (OFH38_CycleLatch; chưa có chu kỳ → Input) — đổi Input giữa chu kỳ không
// chuyển nhầm chiến lược trên cụm đang mở (đổi có hiệu lực từ chu kỳ phẳng kế tiếp; khởi động lại với Input khác → Grid đóng băng như PAIRA_LOOP B8)
bool   GgOn()  { return O12GlobalLatched(); }
int    GgK()   { return O12LatchedK(); }
double GgD()   { return O12LatchedD(); }
// RPA: in a subgrid epoch every "level" of this module is a LOCAL level n (1 = Lk*, n = j + 1 = additional order j); the original grid (epoch 0) is unchanged (R3 FINAL)
bool   GgSub() { return RpaInSubgrid(); }
int    GgMax() { return GgSub() ? Max_Orders + 1 : Max_Orders; }   // subgrid: base Lk* + GridMaxOrders additional orders = local L1..L(1 + GridMaxOrders)
int    GgOff() { return GgSub() ? RpaEpoch() : 0; }                // identity of a persisted group record (epoch of the cycle)
// [GLOBAL GEN] G01 / G04: element i (1-based) of the cycle's LATCHED internal distance list (pip; < 0 = not configured). Replaces GgStep (= GetStep, V26 G1..G25):
// GLOBAL never reads G1..G25.
double GgLd(const int i) { return ClLdGet(i); }
int    GgLdN()           { return ClLdCount(); }
// group anchor price used by the internal levels of group g: group 0 = the L1 price (original grid, L1 rule) / the DecisionMarketAnchor (subgrid epoch, = the
// VirtualEntryAnchor GgOnRebase anchors group 0 at); group >= 1 = the fill price of its breakout anchor. 0 = not available.
double GgAnchorPrice(const int g)
{
   if(g == 0) return GgSub() ? RpaAnchor() : FirstPrice;
   return (g > 0 && g < GG38_MAXG && g_ggOn[g]) ? g_ggAnchorPx[g] : 0.0;
}
// journal text of the rule of level n of the current structure (observation only)
string GgRuleText(const int n, const bool isBuy)
{
   const int k = GgK(), lv = GgMax(), g = Gg38GroupOf(n, k, lv), li = Gg38LocalIndex(n, k, lv);
   if(Gg38IsBreakoutAnchor(n, k, lv)) return StringFormat("GLOBAL group %d ANCHOR (local index 0): %s of group %d %s D %s", g, isBuy ? "highest open BUY" : "lowest open SELL", g - 1, isBuy ? "+" : "-", Gg38Num(GgD()));   // [NPD R1]
   return StringFormat("GLOBAL group %d local index %d: anchor %.2f %s LD%d = %s pip", g, li, GgAnchorPrice(g), isBuy ? "+" : "-", li, li >= 1 ? Gg38Num(GgLd(li)) : "-");
}
bool   GgRebased() { return GgSub(); }
int    GgBaseGroup() { return 0; }
string GgNs()  { return OfhNs("OFH38G", Magic); }

void GgClearGroup(const int g)
{
   g_ggOn[g] = false; g_ggAnchorPx[g] = 0; g_ggAnchorMsc[g] = 0; g_ggRunHi[g] = 0; g_ggRunLo[g] = 0;
   g_ggFrozen[g] = false; g_ggFrzHi[g] = 0; g_ggFrzLo[g] = 0; g_ggFrzMsc[g] = 0;
   g_ggFrzNoHist[g] = false;   // [SAFETY S09]
}
void GgResetMemory()
{
   for(int g = 0; g < GG38_MAXG; g++) GgClearGroup(g);
   g_ggLastMsc = 0; g_ggHistOk = true; g_ggHistRetry = 0; g_ggBlockKey = ""; g_ggRebaseMsc = 0;
   g_ggPendOn = false; g_ggPendMsc = 0; g_ggPendHi = 0.0; g_ggPendLo = 0.0;
}
bool GgAny() { for(int g = 0; g < GG38_MAXG; g++) if(g_ggOn[g]) return true; return false; }

// ---------------------------------------------------------------- persistence
void GgSaveRun()
{
   const string ns = GgNs();
   for(int g = 0; g < GG38_MAXG; g++) if(g_ggOn[g]) { GlobalVariableSet(ns + "g" + IntegerToString(g) + "hi", g_ggRunHi[g]); GlobalVariableSet(ns + "g" + IntegerToString(g) + "lo", g_ggRunLo[g]); }
   if(g_ggPendOn) { GlobalVariableSet(ns + "phi", g_ggPendHi); GlobalVariableSet(ns + "plo", g_ggPendLo); }
   GlobalVariableSet(ns + "lastmsc", (double)g_ggLastMsc);
   g_ggLastSave = TimeCurrent();
}
void GgSaveAll()
{
   const string ns = GgNs();
   GlobalVariablesDeleteAll(ns);
   g_ggPersisted = GgAny() || g_ggPendOn;
   if(!g_ggPersisted) { GlobalVariablesFlush(); return; }
   if(g_ggPendOn) { GlobalVariableSet(ns + "pon", 1); GlobalVariableSet(ns + "pms", (double)g_ggPendMsc); }   // R1: range of the next epoch's group 0 since the decision tick
   GlobalVariableSet(ns + "basket", (double)GgBasketKey());   // = SessBasketId() in the original grid; the cycle id once the cycle had an RPA rebase
   GlobalVariableSet(ns + "k", GgK()); GlobalVariableSet(ns + "max", GgMax());
   GlobalVariableSet(ns + "off", GgOff()); GlobalVariableSet(ns + "rb", (double)g_ggRebaseMsc);   // PAIRA_LOOP
   OfhIdStore(ns, Magic);
   for(int g = 0; g < GG38_MAXG; g++)
   {
      if(!g_ggOn[g]) continue;
      const string p = ns + "g" + IntegerToString(g);
      GlobalVariableSet(p + "on", 1); GlobalVariableSet(p + "px", g_ggAnchorPx[g]); GlobalVariableSet(p + "msc", (double)g_ggAnchorMsc[g]);
      GlobalVariableSet(p + "frz", g_ggFrozen[g] ? 1 : 0); GlobalVariableSet(p + "fhi", g_ggFrzHi[g]); GlobalVariableSet(p + "flo", g_ggFrzLo[g]); GlobalVariableSet(p + "fmsc", (double)g_ggFrzMsc[g]);
   }
   GgSaveRun();
   GlobalVariablesFlush();
}
void GgClearPersist() { g_ggPersisted = false; if(GlobalVariablesDeleteAll(GgNs()) > 0) GlobalVariablesFlush(); }

// ---------------------------------------------------------------- tick history (only ticks that already happened)
// 1 = ticks found (hi / lo set), 0 = no tick in the range (nothing to add), -1 = history not readable
int GgHistRange3(const long fromMsc, const long toMsc, double &hi, double &lo)
{
   hi = 0.0; lo = 0.0;
   if(fromMsc <= 0 || toMsc < fromMsc) return 0;
   MqlTick t[];
   ResetLastError();
   const int n = CopyTicksRange(_Symbol, t, COPY_TICKS_INFO, (ulong)fromMsc, (ulong)toMsc);
   const int err = GetLastError();
   if(n < 0 || (n == 0 && err != 0)) { PrintFormat("GG HISTORY | CopyTicksRange %I64d..%I64d -> %d err=%d", fromMsc, toMsc, n, err); return -1; }
   for(int i = 0; i < n; i++)
   {
      if(t[i].ask > 0.0 && t[i].ask > hi) hi = t[i].ask;
      if(t[i].bid > 0.0 && (lo <= 0.0 || t[i].bid < lo)) lo = t[i].bid;
   }
   return (hi > 0.0 && lo > 0.0) ? 1 : 0;
}
// a full range (anchor fill .. t): must contain ticks
bool GgHistRange(const long fromMsc, const long toMsc, double &hi, double &lo) { return GgHistRange3(fromMsc, toMsc, hi, lo) == 1; }
long GgNowMsc() { MqlTick tk; if(SymbolInfoTick(_Symbol, tk) && tk.time_msc > 0) return tk.time_msc; return (long)TimeCurrent() * 1000; }

// positions of the basket in open-time order (V26 convention: the m-th oldest open position is level m)
int GgPositionsByTime(long &msc[], double &px[])
{
   ulong tk[]; int n = 0;
   for(int i = 0; i < PositionsTotal(); i++)
   {
      const ulong t = PositionGetTicket(i);
      if(t == 0 || !PositionSelectByTicket(t) || !IsOursPos()) continue;
      ArrayResize(tk, n + 1); ArrayResize(msc, n + 1); ArrayResize(px, n + 1);
      tk[n] = t; msc[n] = PositionGetInteger(POSITION_TIME_MSC); px[n] = PositionGetDouble(POSITION_PRICE_OPEN); n++;
   }
   for(int i = 1; i < n; i++)
   {
      const ulong a = tk[i]; const long b = msc[i]; const double c = px[i]; int j = i - 1;
      while(j >= 0 && (msc[j] > b || (msc[j] == b && tk[j] > a))) { tk[j + 1] = tk[j]; msc[j + 1] = msc[j]; px[j + 1] = px[j]; j--; }
      tk[j + 1] = a; msc[j + 1] = b; px[j + 1] = c;
   }
   return n;
}

// R3: open time + price of the ORIGINAL position of `level` — positions by open time while the level book is off (V26 rank), the level book once it is on
// (after a manual close the m-th oldest open position is no longer level m). false = that level has no original open position (abandoned / re-entry only).
bool GgLevelPos(const int level, double &px, long &msc)
{
   if(!GgSub() && LbOn()) return LbPosOfLevel(level, px, msc);
   long ms[]; double pp[]; const int n = GgPositionsByTime(ms, pp);
   const int r = level;   // V26 rank; RPA subgrid: Lk* is the oldest open position of the epoch (sublevel 1), the additional orders follow in fill order
   if(r < 1 || n < r) return false;
   px = pp[r - 1]; msc = ms[r - 1];
   return true;
}
// RPA: group 0 of a subgrid epoch is anchored at the VirtualEntryAnchor (= RpaAnchor() = the DecisionMarketAnchor since RPA V1-R1), never at a group of the previous epoch
bool GgVirtualAnchor(const int g, double &px)
{
   px = 0.0;
   if(!GgSub() || g != 0) return false;
   px = RpaAnchor();
   return px > 0.0;
}

// reconstruct group g from the open positions + tick history (restart without a valid record). levels = level count of the basket.
bool GgRebuildGroup(const int g, const int levels)
{
   const int k = GgK(), a = Gg38AnchorOf(g, k), e = Gg38EndOf(g, k, GgMax());
   if(levels < a) return false;
   double aPx = 0.0, ePx = 0.0; long aMsc = 0, eMsc = 0;
   const bool base = GgSub() && g == 0;   // RPA R1: group 0 of the subgrid epoch = DecisionMarketAnchor, range from the decision tick
   if(base)
   {
      if(!GgVirtualAnchor(g, aPx) || (g_ggRebaseMsc <= 0 && RpaDecMsc() <= 0)) { Print("GG REBUILD subgrid group 0: anchor / decision tick not available - group not rebuilt"); return false; }
      aMsc = g_ggRebaseMsc > 0 ? g_ggRebaseMsc : RpaDecMsc();
      if(levels >= e && !GgLevelPos(e, ePx, eMsc)) return false;
   }
   else if(!GgLevelPos(a, aPx, aMsc) || (levels >= e && !GgLevelPos(e, ePx, eMsc)))
   {
      if(LbOn()) MrFreezeGrid(MRF_GLOBAL_UNPROVEN, StringFormat("GLOBAL group %d (L%d-L%d) must be rebuilt but the original position of L%d is not open (closed by hand / re-entry ticket only)", g, a, e, GgLevelPos(a, aPx, aMsc) ? e : a));
      return false;
   }
   GgClearGroup(g);
   g_ggOn[g] = true;
   g_ggAnchorPx[g] = (g == 0 && !GgSub() && FirstPrice > 0.0) ? FirstPrice : aPx;
   g_ggAnchorMsc[g] = aMsc;
   double hi, lo;
   const long now = GgNowMsc();
   if(GgHistRange(g_ggAnchorMsc[g], now, hi, lo)) { g_ggRunHi[g] = hi; g_ggRunLo[g] = lo; }
   else { g_ggHistOk = false; MqlTick tk; if(SymbolInfoTick(_Symbol, tk)) { g_ggRunHi[g] = tk.ask; g_ggRunLo[g] = tk.bid; } }
   if(levels >= e)
   {
      if(GgHistRange(g_ggAnchorMsc[g], eMsc, hi, lo)) { g_ggFrzHi[g] = hi; g_ggFrzLo[g] = lo; g_ggFrozen[g] = true; g_ggFrzMsc[g] = eMsc; }
      else g_ggHistOk = false;
   }
   PrintFormat("GG REBUILD group %d (L%d-L%d) from open positions + tick history | anchor %.2f @%I64d | run hi %.2f lo %.2f | frozen %s hi %.2f lo %.2f | history %s",
               g, a, e, g_ggAnchorPx[g], g_ggAnchorMsc[g], g_ggRunHi[g], g_ggRunLo[g], g_ggFrozen[g] ? "yes" : "no", g_ggFrzHi[g], g_ggFrzLo[g], g_ggHistOk ? "ok" : "PENDING");
   return true;
}

// TPC2 (GL-R1, Owner 29/10/2026 §4.5): LOGICAL level count of the basket — the Balanced Offset level book (highest level ever opened) once the book is active;
// R3 level book / ticket count + rebase offset otherwise (b9). Never the open ticket count after a PairClose closed positions.
int GgLevelCount(const int total) { if(GgSub()) return RpaSubLevelCount(); return LbNextLevel(total) - 1; }
// RPA: a committed rebase owns the basket: the open positions are no longer levels by rank -> the persisted group state is kept as it is
bool GgPairAHoldsGroups() { return RpaHoldsGroups(); }
long g_ggR1Kept = 0, g_ggR1NoRebuild = 0;
// restart: history not available before → recompute every open group's ranges ([NPD R1] journal ranges only: breakout anchors no longer wait for this)
void GgRetryHistory()
{
   if(g_ggHistOk || TimeCurrent() < g_ggHistRetry) return;
   g_ggHistRetry = TimeCurrent() + 60;
   const int n = GgLevelCount(CountPositions());   // R3: level count (= positions while the level book is off); PAIRA_LOOP: + rebase offset; TPC2: logical level count
   const long now = GgNowMsc(); const int k = GgK();
   bool ok = true;
   for(int g = 0; g < GG38_MAXG && ok; g++)
   {
      if(!g_ggOn[g]) continue;
      double hi, lo;
      if(!GgHistRange(g_ggAnchorMsc[g], now, hi, lo)) { ok = false; break; }
      g_ggRunHi[g] = MathMax(g_ggRunHi[g], hi); g_ggRunLo[g] = (g_ggRunLo[g] > 0.0) ? MathMin(g_ggRunLo[g], lo) : lo;
      const int e = Gg38EndOf(g, k, GgMax());
      double ePx = 0.0; long eMsc = 0;
      // [SAFETY S09] a group FROZEN while the history was not readable (GgSync / GgFreeze froze it from the quotes seen since the restart: g_ggFrzNoHist) is widened from
      // the history of its window (anchor .. last level) before breakouts are allowed — never narrowed; a group frozen WITH history is not re-read (HOTFIX skipped
      // every frozen group: a too narrow range let a breakout fire early). [NPD R1] the breakout no longer reads this range: the widening keeps the journal range exact.
      if(n >= e && (!g_ggFrozen[g] || g_ggFrzNoHist[g]) && GgLevelPos(e, ePx, eMsc))
      {
         if(!GgHistRange(g_ggAnchorMsc[g], eMsc, hi, lo)) { ok = false; break; }
         if(!g_ggFrozen[g]) { g_ggFrzHi[g] = hi; g_ggFrzLo[g] = lo; g_ggFrozen[g] = true; g_ggFrzMsc[g] = eMsc; }
         else
         {
            const double h0 = g_ggFrzHi[g], l0 = g_ggFrzLo[g];
            Saf38WidenRange(g_ggFrzHi[g], g_ggFrzLo[g], hi, lo);
            PrintFormat("GG HISTORY | group %d frozen without tick history: range widened from the history: high %.2f -> %.2f, low %.2f -> %.2f (SAFETY S09)", g, h0, g_ggFrzHi[g], l0, g_ggFrzLo[g]);
         }
         g_ggFrzNoHist[g] = false;
      }
   }
   if(ok) { g_ggHistOk = true; Print("GG HISTORY OK | group ranges completed from tick history (journal only since NPD R1: the breakout anchor reads the open positions)"); GgSaveAll(); }   // [NPD R1] text
}

// ---------------------------------------------------------------- per tick
void GgObserve()
{
   if(!GgOn() || (!GgAny() && !g_ggPendOn)) return;
   MqlTick tk;
   if(!SymbolInfoTick(_Symbol, tk)) return;
   for(int g = 0; g < GG38_MAXG; g++)
   {
      if(!g_ggOn[g]) continue;
      if(tk.ask > g_ggRunHi[g]) g_ggRunHi[g] = tk.ask;
      if(tk.bid > 0.0 && (g_ggRunLo[g] <= 0.0 || tk.bid < g_ggRunLo[g])) g_ggRunLo[g] = tk.bid;
   }
   if(g_ggPendOn)   // R1: the next epoch's group-0 range keeps running from the decision tick while the rebase executes
   {
      if(tk.ask > g_ggPendHi) g_ggPendHi = tk.ask;
      if(tk.bid > 0.0 && (g_ggPendLo <= 0.0 || tk.bid < g_ggPendLo)) g_ggPendLo = tk.bid;
   }
   if(tk.time_msc > g_ggLastMsc) g_ggLastMsc = tk.time_msc;
   if(TimeCurrent() - g_ggLastSave >= 60) GgSaveRun();
   GgRetryHistory();
}

void GgFreeze(const int g, const string why)
{
   MqlTick tk; const bool have = SymbolInfoTick(_Symbol, tk);
   g_ggFrzHi[g] = have ? MathMax(g_ggRunHi[g], tk.ask) : g_ggRunHi[g];
   g_ggFrzLo[g] = have ? (g_ggRunLo[g] > 0.0 ? MathMin(g_ggRunLo[g], tk.bid) : tk.bid) : g_ggRunLo[g];
   g_ggFrzMsc[g] = have ? tk.time_msc : GgNowMsc();
   g_ggFrozen[g] = true;
   g_ggFrzNoHist[g] = !g_ggHistOk;   // [SAFETY S09] range built without the tick history -> widened by GgRetryHistory ([NPD R1] journal range only, the breakout reads the positions)
   const int k = GgK();
   // [NPD R1] the observed range is journal only: the next anchor is measured from the open positions of this group on its own side (GgTrigger -> GgNpdReference)
   PrintFormat("GG FROZEN group %d L%d-L%d | observed range (journal only, not used by the breakout since NPD R1) GroupHigh(max Ask)=%.2f GroupLow(min Bid)=%.2f since anchor %.2f @%I64d | next anchor: nearest open position of group %d on its side +/- D=%s (BUY: highest open BUY + D, SELL: lowest open SELL - D, on the price grid) | %s",
               g, Gg38AnchorOf(g, k), Gg38EndOf(g, k, GgMax()), g_ggFrzHi[g], g_ggFrzLo[g], g_ggAnchorPx[g], g_ggAnchorMsc[g], g, Gg38Num(GgD()), why);
}

// a grid / L1 order of `level` has a confirmed fill at fillPx (called right after TrySendOrder succeeded)
void GgOnFill(const int level, const double fillPx)
{
   if(!GgOn()) return;
   const int k = GgK(), g = Gg38GroupOf(level, k, GgMax());
   if(g < 0 || g >= GG38_MAXG) return;
   if(level == Gg38AnchorOf(g, k))
   {
      for(int j = g; j < GG38_MAXG; j++) GgClearGroup(j);
      MqlTick tk; const bool have = SymbolInfoTick(_Symbol, tk);
      g_ggOn[g] = true;
      g_ggAnchorPx[g] = fillPx;
      g_ggAnchorMsc[g] = have ? tk.time_msc : GgNowMsc();
      g_ggRunHi[g] = have ? tk.ask : fillPx; g_ggRunLo[g] = have ? tk.bid : fillPx;
      PrintFormat("GG ANCHOR group %d = L%d @%.2f (ask %.2f bid %.2f) | levels L%d-L%d from this anchor: local L2..L%d at LD1..LD%d of GlobalGrid_LocalDistancesPips", g, level, fillPx, g_ggRunHi[g], g_ggRunLo[g],
                  level, Gg38EndOf(g, k, GgMax()), Gg38GroupSize(g, k, GgMax()), Gg38GroupSize(g, k, GgMax()) - 1);   // [GLOBAL GEN] G01
      // [NPD R1] N03 log only: real distance of a breakout anchor fill from the reference it was triggered on (a market-order slippage may make it < D)
      if(g >= 1 && level == g_ggNpdLevel && g_ggNpdRef > 0.0)
      {
         const double dist = Gg38NpdDistance(g_ggNpdBuy, g_ggNpdRef, fillPx);
         PrintFormat("GG NPD ANCHOR FILL group %d L%d %s @%.2f | reference %.2f = %s | distance %.2f vs D %s: %s", g, level, g_ggNpdBuy ? "BUY" : "SELL", fillPx, g_ggNpdRef, g_ggNpdTxt,
                     dist, Gg38Num(GgD()), dist >= GgD() - 1e-6 ? "OK" : "BELOW D (slippage of the market order: logged only, nothing changed)");
      }
      g_ggNpdLevel = 0; g_ggNpdRef = 0.0; g_ggNpdTxt = "";
   }
   if(level == Gg38EndOf(g, k, GgMax()) && g_ggOn[g]) GgFreeze(g, StringFormat("last order L%d filled", level));
   GgSaveAll();
}

// once per tick before a grid decision: align the group state with the level count of the basket (V26: the broker position count;
// R3: the level book once the basket had a manual close — the caller passes next level - 1)
void GgSync(const int total)
{
   if(!GgOn()) return;
   if(total <= 0) { if(GgAny()) { GgResetMemory(); GgClearPersist(); } return; }
   const int k = GgK(), ng = Gg38GroupCount(k, GgMax()), g0 = GgBaseGroup();
   bool changed = false;
   for(int g = g0; g < ng; g++)   // PAIRA_LOOP: groups below the rebased level k are history (closed positions): never rebuilt / cleared / live
   {
      const int a = Gg38AnchorOf(g, k), e = Gg38EndOf(g, k, GgMax());
      if(total < a)
      {
         if(g_ggOn[g] && !MrBlocksGrid())
         {
            PrintFormat("GG GROUP %d CLEARED | anchor level L%d no longer open (positions=%d)", g, a, total);
            GgClearGroup(g); changed = true;
         }
         continue;
      }
      if(!g_ggOn[g]) { if(!GgRebuildGroup(g, total)) continue; changed = true; }
      if(total < e && g_ggFrozen[g] && !MrBlocksGrid())
      {
         g_ggFrozen[g] = false;
         PrintFormat("GG GROUP %d REOPENED | positions=%d < last level L%d (range keeps running from the anchor fill, frozen again when complete)", g, total, e);
         changed = true;
      }
      if(total >= e && !g_ggFrozen[g]) { GgFreeze(g, StringFormat("positions=%d reached L%d", total, e)); changed = true; }
   }
   if(changed) GgSaveAll();
}

// R1: a rebase was committed (decision snapshot taken): from this tick the range of the NEXT epoch's group 0 is observed (Ask max / Bid min since the decision tick).
// The groups of the running epoch are kept untouched while the rebase executes (RpaHoldsGroups).
void GgOnRebaseCommit()
{
   if(!GgOn()) return;
   g_ggPendOn = true; g_ggPendMsc = RpaDecMsc(); g_ggPendHi = RpaDecAsk(); g_ggPendLo = RpaDecBid();
   GgSaveAll();
}
// RPA (Owner 31/10/2026 §8, R1 PHASE 5): a reconciled rebase left ONE position Lk* = LOCAL L1 of a new GLOBAL Mode 1 grid. Every group of the previous epoch is cleared
// (history, never a live anchor); group 0 of the epoch = local L1..K anchored at the DecisionMarketAnchor, its range = Ask max / Bid min since the DECISION tick.
void GgOnRebase()
{
   if(!GgOn()) return;
   const bool pend = g_ggPendOn && g_ggPendMsc > 0 && g_ggPendMsc == RpaDecMsc();
   const double pHi = g_ggPendHi, pLo = g_ggPendLo;
   GgResetMemory();
   if(!GgSub()) { GgSaveAll(); return; }
   MqlTick tk; const bool have = SymbolInfoTick(_Symbol, tk);
   const long nowMsc = have ? tk.time_msc : GgNowMsc();
   g_ggRebaseMsc = RpaDecMsc() > 0 ? RpaDecMsc() : nowMsc;
   double ax = 0.0;
   if(!GgVirtualAnchor(0, ax))
   {
      R2Warn("GGREBASE_" + IntegerToString(g_ggRebaseMsc), "GG RPA EPOCH | the VirtualEntryAnchor is not available - no GLOBAL group live (levels wait)");
      GgSaveAll();
      return;
   }
   // range since the decision tick: the decision quote + every tick observed while the rebase executed (pending range); without it the tick history from the decision tick;
   // history not readable -> the real decision / current quotes only and breakout anchors BLOCKED until GgRetryHistory reads the history (no high / low is simulated)
   // [NPD R1] the range is journal only now: breakout anchors of the epoch read the open positions of the previous group and do not wait for the history
   double hi = RpaDecAsk(), lo = RpaDecBid(); string src = "";
   if(pend) { hi = MathMax(hi, pHi); lo = (pLo > 0.0) ? MathMin(lo, pLo) : lo; src = "observed tick by tick from the decision tick"; }
   else
   {
      double h2 = 0.0, l2 = 0.0;
      const int r = (RpaDecMsc() > 0) ? GgHistRange3(RpaDecMsc(), nowMsc, h2, l2) : -1;
      if(r == 1) { hi = MathMax(hi, h2); lo = MathMin(lo, l2); src = "tick history from the decision tick (pending range not available)"; }
      else { g_ggHistOk = false; src = "DECISION QUOTE ONLY: tick history from the decision tick not available (journal range only since NPD R1, GgRetryHistory completes it)"; }   // [NPD R1] text
   }
   if(have) { hi = MathMax(hi, tk.ask); lo = (tk.bid > 0.0) ? MathMin(lo, tk.bid) : lo; }
   g_ggOn[0] = true; g_ggAnchorPx[0] = ax; g_ggAnchorMsc[0] = g_ggRebaseMsc; g_ggRunHi[0] = hi; g_ggRunLo[0] = lo;
   if(have && tk.time_msc > g_ggLastMsc) g_ggLastMsc = tk.time_msc;
   const int K = GgK(), e = Gg38EndOf(0, K, GgMax());
   PrintFormat("GG RPA EPOCH %d | Lk* = local L1 of a NEW GLOBAL Mode 1 grid: group 0 = local L1-L%d (labels L%d*-L%d*) anchored at the DecisionMarketAnchor %.2f @%I64d (decision tick), local L2..L%d at LD1..LD%d of GlobalGrid_LocalDistancesPips from it | range %s: GroupHigh %.2f GroupLow %.2f | groups of the previous epoch are history | K=%d D=%s | %d groups for 1 + %d local levels",
               RpaEpoch(), e, RpaK(), RpaK() + e - 1, g_ggAnchorPx[0], g_ggAnchorMsc[0], e, e - 1, src, g_ggRunHi[0], g_ggRunLo[0], K, Gg38Num(GgD()), Gg38GroupCount(K, GgMax()), Max_Orders);   // [GLOBAL GEN] G01
   if(e <= 1) GgFreeze(0, "group 0 of the epoch holds only Lk*");
   GgSaveAll();
}

// [NPD R1] ------------------------------------------------------------------ breakout anchor reference = the real open positions of the previous group (N01 / N02)
double g_ggNpdRef = 0.0; int g_ggNpdLevel = 0; bool g_ggNpdBuy = false; string g_ggNpdTxt = "";   // reference of the breakout trigger of this tick (fill journal N03)
// level map of the EA's open positions in the CURRENT structure, from the rule the grid already uses (N02): original grid without a manual close = V26 rank by open
// time (GgPositionsByTime order: open time, then ticket); original grid after a manual close = the level book; subgrid epoch = the RPA record (Lk* = local L1, additional
// order j = local j + 1). Returns the position count (lv = 0: no provable level) or GG38_NPD_MAP when the map cannot be built (why = reason).
int GgNpdCollect(int &lv[], int &side[], int &expSide[], double &px[], ulong &id[], string &why)
{
   why = "";
   ArrayResize(lv, 0); ArrayResize(side, 0); ArrayResize(expSide, 0); ArrayResize(px, 0); ArrayResize(id, 0);
   ulong tk[]; long ms[]; int n = 0;
   for(int i = 0; i < PositionsTotal(); i++)
   {
      const ulong t = PositionGetTicket(i);
      if(t == 0 || !PositionSelectByTicket(t)) { why = StringFormat("position %d of the terminal list not readable (ticket %I64u)", i, t); return GG38_NPD_MAP; }
      if(!IsOursPos()) continue;
      ArrayResize(tk, n + 1); ArrayResize(ms, n + 1); ArrayResize(lv, n + 1); ArrayResize(side, n + 1); ArrayResize(expSide, n + 1); ArrayResize(px, n + 1); ArrayResize(id, n + 1);
      tk[n] = t; ms[n] = PositionGetInteger(POSITION_TIME_MSC); id[n] = (ulong)PositionGetInteger(POSITION_IDENTIFIER);
      side[n] = (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY) ? 1 : -1; px[n] = PositionGetDouble(POSITION_PRICE_OPEN); lv[n] = 0; expSide[n] = 0;
      n++;
   }
   if(GgSub())
   {
      if(RpaSubRecordN() != RpaSubAddCount()) { why = StringFormat("subgrid record holds %d additional order ids for %d counted additional orders", RpaSubRecordN(), RpaSubAddCount()); return GG38_NPD_MAP; }
      for(int i = 0; i < n; i++)
      {
         for(int loc = 1; loc <= RpaSubLevelCount(); loc++) if(RpaSubIdOfLocal(loc) != 0 && RpaSubIdOfLocal(loc) == id[i]) { lv[i] = loc; break; }
         if(lv[i] > 0) expSide[i] = (RpaLocalType(lv[i]) == POSITION_TYPE_BUY) ? 1 : -1;
      }
      return n;
   }
   if(LbOn())
   {
      for(int i = 0; i < n; i++) { lv[i] = LbLevelOfPos(id[i]); if(lv[i] > 0) expSide[i] = (GetNextType(lv[i]) == POSITION_TYPE_BUY) ? 1 : -1; }
      return n;
   }
   for(int i = 0; i < n; i++)
   {
      int r = 1;
      for(int j = 0; j < n; j++) if(j != i && (ms[j] < ms[i] || (ms[j] == ms[i] && tk[j] < tk[i]))) r++;
      lv[i] = r; expSide[i] = (GetNextType(r) == POSITION_TYPE_BUY) ? 1 : -1;
   }
   return n;
}
// reference of the breakout anchor of group g on side isBuy (N01): GG38_NPD_OK + ref, or the blocking status; txt = journal text (reference position / reason)
int GgNpdReference(const int g, const bool isBuy, double &ref, string &txt)
{
   ref = 0.0; txt = "";
   int lv[], sd[], ex[]; double px[]; ulong id[]; string why = "";
   const int k = GgK(), levels = GgMax();
   const int a = Gg38AnchorOf(g - 1, k), e = Gg38EndOf(g - 1, k, levels);
   const string src = GgSub() ? StringFormat("RPA epoch %d record (Lk* = local L1)", RpaEpoch()) : (LbOn() ? "level book" : "V26 rank by open time");
   const int n = GgNpdCollect(lv, sd, ex, px, id, why);
   if(n < 0) { txt = StringFormat("group %d (L%d-L%d), map %s: %s", g - 1, a, e, src, why); return n; }
   int ri = -1, cnt = 0;
   const int st = Gg38NpdReference(lv, sd, ex, px, n, g, k, levels, isBuy, ref, ri, cnt);
   if(st == GG38_NPD_OK)
   {
      txt = StringFormat("%s of group %d (L%d-L%d) = L%d #%I64u @%.2f, nearest of %d open %s position(s), map %s", isBuy ? "highest open BUY" : "lowest open SELL", g - 1, a, e,
                         lv[ri], id[ri], px[ri], cnt, isBuy ? "BUY" : "SELL", src);
      return st;
   }
   string list = "";
   for(int i = 0; i < n && StringLen(list) < 400; i++)
      list += StringFormat(" #%I64u %s L%d (rule %s) @%.2f", id[i], sd[i] > 0 ? "BUY" : "SELL", lv[i], ex[i] > 0 ? "BUY" : (ex[i] < 0 ? "SELL" : "?"), px[i]);
   txt = StringFormat("group %d (L%d-L%d), side %s, map %s, %d open position(s):%s", g - 1, a, e, isBuy ? "BUY" : "SELL", src, n, list == "" ? " none" : list);
   return st;
}

void GgBlockLog(const string key, const string text)
{
   if(key == g_ggBlockKey) return;
   g_ggBlockKey = key;
   Print(text);
}

// grid decision for nextNum: overwrite the V26 trigger with the GLOBAL one. false = this level may not be sent now.
bool GgTrigger(const int nextNum, const int nextType, double &trigger, string &tag)
{
   tag = "";
   if(!GgOn()) return true;
   const int k = GgK(), lv = GgMax(), g = Gg38GroupOf(nextNum, k, lv);
   const bool isBuy = (nextType == POSITION_TYPE_BUY);
   if(Gg38IsBreakoutAnchor(nextNum, k, lv))
   {
      const int p = g - 1;
      if(!g_ggOn[p] || !g_ggFrozen[p]) { GgBlockLog(StringFormat("NF%d_%d", nextNum, p), StringFormat("GG BLOCK L%d | group %d not complete / range not frozen", nextNum, p)); return false; }
      // [NPD R1] N01 / N02: reference = the open positions of group p on the side of the new order (highest BUY / lowest SELL open price). The observed range and its
      // tick history are not read (the former "range history not available" wait is gone with them); no reference -> no anchor, no fallback.
      double ref = 0.0; string rtx = "";
      const int st = GgNpdReference(g, isBuy, ref, rtx);
      if(st != GG38_NPD_OK)
      {
         GgBlockLog(StringFormat("NPD%d_%d_%d", nextNum, p, st), StringFormat("GG BLOCK L%d | NPD %s: %s -> the breakout anchor of group %d is NOT sent (no fallback to the last order, the anchor or GroupHigh / GroupLow); exits / T1 / T2 / PairClose / DD keep working",
                                                                       nextNum, Gg38NpdName(st), rtx, g));
         return false;
      }
      // [GLOBAL GEN] G03 rounding kept: exact on the price grid (BUY rounded up, SELL rounded down); the internal distance list plays no part here
      trigger = PriceN(Gg38NpdTriggerPx(isBuy, ref, GgD(), _Point));
      g_ggNpdLevel = nextNum; g_ggNpdRef = ref; g_ggNpdBuy = isBuy; g_ggNpdTxt = rtx;
      tag = StringFormat(" [GG ANCHOR group %d: %s %s NPD ref %.2f %s D %s -> %.2f | %s]", g, isBuy ? "ask" : "bid", isBuy ? ">=" : "<=", ref, isBuy ? "+" : "-", Gg38Num(GgD()), trigger, rtx);
      g_ggBlockKey = "";
      return true;
   }
   // [GLOBAL GEN] G01: EVERY internal level, group 0 included (no V26 trigger, no G1..G25): localIndex = level - anchor level of its group,
   // trigger = anchor price of THIS group +/- element localIndex of the latched distance list x pip
   const int li = Gg38LocalIndex(nextNum, k, lv);
   if(g > 0 && !g_ggOn[g]) { GgBlockLog(StringFormat("NA%d", g), StringFormat("GG BLOCK L%d | group %d has no anchor", nextNum, g)); return false; }
   const double ax = GgAnchorPrice(g);
   if(ax <= 0.0) { GgBlockLog(StringFormat("AX%d", g), StringFormat("GG BLOCK L%d | group %d anchor price not available", nextNum, g)); return false; }
   const double ld = (li >= 1) ? GgLd(li) : -1.0;
   if(ld < 0.0)
   {
      GgBlockLog(StringFormat("LD%d_%d", nextNum, li), StringFormat("GG BLOCK L%d | group %d local index %d has no distance (latched list holds %d elements) - nothing is sent, no G1..G25 fallback", nextNum, g, li, GgLdN()));
      return false;
   }
   trigger = PriceN(Gg38LocalTrigger(ax, isBuy, ld, PipSize));
   tag = StringFormat(" [GG group %d local L%d from anchor L%d @%.2f %s LD%d=%s pip]", g, li + 1, Gg38AnchorOf(g, k), ax, isBuy ? "+" : "-", li, Gg38Num(ld));
   g_ggBlockKey = "";
   return true;
}
// [GLOBAL GEN] trigger of LOCAL level n of a subgrid epoch for the RPA journal / D5 audit rows (observation only, the grid decision is GgTrigger): an internal level
// of group 0 = DecisionMarketAnchor +/- LD; a breakout anchor has no fixed price (0, the text says so)
double GgSubPreview(const int n, const bool isBuy, string &rule)
{
   rule = GgRuleText(n, isBuy);
   const int k = GgK(), lv = GgMax(), g = Gg38GroupOf(n, k, lv), li = Gg38LocalIndex(n, k, lv);
   if(Gg38IsBreakoutAnchor(n, k, lv) || g != 0 || li < 1) return 0.0;
   const double ld = GgLd(li), ax = GgAnchorPrice(0);
   if(ld < 0.0 || ax <= 0.0) return 0.0;
   return PriceN(Gg38LocalTrigger(ax, isBuy, ld, PipSize));
}

// restart: restore the persisted record of THIS basket (identity + basket ticket + k + Max_Orders), then fill the gap from tick history
void GgRestore()
{
   GgResetMemory();
   g_ggRebuilt = false;
   const string ns = GgNs();
   const int total = CountPositions();
   if(!GgOn() || total <= 0) { GgClearPersist(); return; }
   bool ok = GlobalVariableCheck(ns + "basket");
   string why = ok ? "" : "NO_RECORD";
   if(ok && OfhIdCheck(ns, Magic) != "") { ok = false; why = "IDENTITY"; }
   if(ok && (ulong)GlobalVariableGet(ns + "basket") != GgBasketKey()) { ok = false; why = "OTHER_BASKET"; }
   if(ok && ((int)GlobalVariableGet(ns + "k") != GgK() || (int)GlobalVariableGet(ns + "max") != GgMax())) { ok = false; why = "CONFIG_CHANGED"; }
   if(ok && (int)GlobalVariableGet(ns + "off") != GgOff()) { ok = false; why = "RPA_EPOCH_CHANGED"; }   // RPA: a group record of another epoch is history
   g_ggRebaseMsc = GgRebased() ? (long)GlobalVariableGet(ns + "rb") : 0;
   if(g_ggRebaseMsc <= 0 && GgRebased()) g_ggRebaseMsc = RpaDecMsc();   // RPA record (restored before GLOBAL): decision tick of the epoch
   // RPA: a committed rebase owns the basket -> the open tickets are not the levels: the persisted group state is kept EXACTLY (no sync by ticket count);
   // without a record nothing is rebuilt (no anchor guessed) - the grid is locked while the rebase runs and its completion rebuilds the groups (GgOnRebase)
   const bool paHolds = GgPairAHoldsGroups();
   if(ok)
   {
      for(int g = 0; g < GG38_MAXG; g++)
      {
         const string p = ns + "g" + IntegerToString(g);
         if(!GlobalVariableCheck(p + "on")) continue;
         g_ggOn[g] = true; g_ggAnchorPx[g] = GlobalVariableGet(p + "px"); g_ggAnchorMsc[g] = (long)GlobalVariableGet(p + "msc");
         g_ggRunHi[g] = GlobalVariableGet(p + "hi"); g_ggRunLo[g] = GlobalVariableGet(p + "lo");
         g_ggFrozen[g] = GlobalVariableGet(p + "frz") > 0.5; g_ggFrzHi[g] = GlobalVariableGet(p + "fhi"); g_ggFrzLo[g] = GlobalVariableGet(p + "flo");
         g_ggFrzMsc[g] = (long)GlobalVariableGet(p + "fmsc");
      }
      // R1: range of the next epoch's group 0 since the decision tick (a rebase is executing)
      if(GlobalVariableCheck(ns + "pon") && GlobalVariableCheck(ns + "phi") && GlobalVariableCheck(ns + "plo"))
      { g_ggPendOn = true; g_ggPendMsc = (long)GlobalVariableGet(ns + "pms"); g_ggPendHi = GlobalVariableGet(ns + "phi"); g_ggPendLo = GlobalVariableGet(ns + "plo"); }
      g_ggLastMsc = (long)GlobalVariableGet(ns + "lastmsc");
      const long now = GgNowMsc();
      double hi, lo;
      if(g_ggLastMsc > 0 && now > g_ggLastMsc)
      {
         const int r = GgHistRange3(g_ggLastMsc + 1, now, hi, lo);
         if(r == 1)
         {
            for(int g = 0; g < GG38_MAXG; g++) if(g_ggOn[g]) { g_ggRunHi[g] = MathMax(g_ggRunHi[g], hi); g_ggRunLo[g] = MathMin(g_ggRunLo[g], lo); }
            if(g_ggPendOn) { g_ggPendHi = MathMax(g_ggPendHi, hi); g_ggPendLo = MathMin(g_ggPendLo, lo); }
         }
         else if(r < 0)
         {
            g_ggHistOk = false;   // a gap that could not be read: the journal range waits for the history (GgRetryHistory); [NPD R1] breakout anchors no longer wait for it
            g_ggPendOn = false;   // R1: the pending range has a gap: dropped (GgOnRebase then reads the full history from the decision tick; [NPD R1] journal range only, breakouts are not blocked by it)
         }
      }
      PrintFormat("GG RESTORED | basket %I64u k=%d | gap %I64d ms filled from tick history: %s", GgBasketKey(), GgK(), now - g_ggLastMsc, g_ggHistOk ? "yes" : "PENDING");
   }
   else if(paHolds)
   {
      g_ggR1NoRebuild++;
      PrintFormat("GG RESTORE | no valid record (%s) while an RPA rebase owns the basket (state %s): the open positions are not the levels -> no group rebuilt, no anchor guessed (the grid stays locked; the rebase completion rebuilds the groups)",
                  why, RpaStateName(g_rpState));
      return;
   }
   else { g_ggRebuilt = true; PrintFormat("GG RESTORE | no valid record (%s) -> groups rebuilt from %s + tick history", why, GgSub() ? "the subgrid positions of the epoch (Lk* = sublevel 1) and the VirtualEntryAnchor" : "open positions"); }
   if(paHolds) { g_ggR1Kept++; PrintFormat("GG RESTORE | an RPA rebase owns the basket (state %s): persisted group state kept exactly, no sync by the open ticket count", RpaStateName(g_rpState)); }
   else GgSync(GgLevelCount(total));   // R3: level count of the basket (= positions while the level book is off); RPA subgrid: sublevel count 1 + additional orders
   GgSaveAll();
}
// identity of the basket of the GLOBAL record — the cycle id once the cycle had an RPA rebase (the oldest original position may be closed)
ulong GgBasketKey() { return RpaHadAny() ? (ulong)g_cycStartMsc : SessBasketId(); }

#endif
// [FINAL STANDALONE] ===== END INLINED OFH38_GlobalGrid.mqh =====
// [FINAL STANDALONE] ===== BEGIN INLINED OFH38_DDLock.mqh (HOTFIX SHA256 8136CDF0A9780B67750D991DE9FE71D1DDFC551B5ADE4F2D66224A54FCF8F8E1) — included from Onefxhub_v38.38_RPA.mq5:L306 =====
// OFH38_DDLock.mqh — V38 DD HEDGE LOCK: thay HÀNH ĐỘNG cắt DD của V26 (CloseBasket + reset). Cách đo DD của V26 giữ nguyên trong
// TryCutByAccountDd(): |lỗ nổi cụm| / số dư × 100 ≥ Cat_DD_PhanTram (Bat_Cat_DD bật).
// Port từ donor V2B6 FINAL OFH_V2F_Recovery.mqh (SHA 70BB9184…) — chỉ phần tương thích:
//   1. dừng Grid thường (OnTick: DD Lock nắm quyền, Grid / T1 / T2 / PairClose / đóng phiên / L1 mới không chạy);
//   2. đọc lại vị thế broker (cả Magic và DDLock_HedgeMagic) ở MỖI bước;
//   3-5. hedge đúng phần NET còn lại ngược chiều (hedge cũ được tính, gửi lại không trùng), theo bước lot / lot min / lot max của sàn,
//        chia lệnh nếu vượt lot max, OrderCheck trước (thiếu ký quỹ → chia đôi tới lot min);
//   6-8. đối soát sau mỗi lệnh; chỉ báo LOCK_CONFIRMED khi net ≈ 0 (< nửa bước lot hoặc phần dư < lot min);
//        bị từ chối / một phần / không xong sau DDLock_MaxAttempts → LOCK_FAILED (không bao giờ báo khóa đủ), thử lại sau DDLock_RetryMinutes;
//   9. khóa xác nhận → (bỏ SL/TP cũ để không phá khóa) → NÉN CÂN BẰNG của donor: mỗi nhóm đóng cùng khối lượng 1 BUY + 1 SELL, net giữ nguyên
//      (V38: đóng bằng close-by một lệnh khi sàn cho phép → net không lệch cả trong lúc thực hiện; không được thì 2 chân như donor);
//   10-11. nợ kinh tế của đợt: tham chiếu = số dư trước khi có cụm; lãi/lỗ đợt = đã chốt (lãi, swap, commission, phí) + nổi, của cả 2 magic,
//        từ lệnh đầu cụm; nợ = − lãi/lỗ đợt; chi phí đóng ước tính = commission + DDLock_CloseSlipPoints mỗi lot. Nén chỉ chuyển lỗ nổi
//        thành lỗ đã chốt — KHÔNG phải phục hồi; số lệnh giảm KHÔNG phải equity hồi phục;
//   12. lưu bền + đối soát khi khởi động lại (bản ghi theo tài khoản / server / symbol / Magic; lệnh hedge mồ côi → khóa lại an toàn).
// Không có: GoldEdge, Recovery Brain, lệnh Recovery, AI xu hướng / khối lượng, chính sách phục hồi chưa duyệt. Không tự mở khóa, không tự
// quay lại Grid: cụm khóa → LOCKED_HOLD (chờ Recovery được Owner duyệt sau này); cụm phẳng → HALT tới khi Owner xác nhận.
// V38 R1: bỏ BriefPause (Sleep 30 ms) sau lệnh hedge / chân nén / close-by. Hedge đã được broker nhận (DONE / một phần / PLACED / TIMEOUT)
// mà vị thế hedge chưa hiện → "đang bay": KHÔNG gửi hedge mới trước Exec_ConfirmMs (tránh hedge trùng → net lật chiều). Chân nén / close-by
// được nhận mà khối lượng chưa đổi → chờ xác nhận (không tính là thất bại, không gửi trùng); retcode theo loại thao tác (OFH38_Exec_Core).
// V38 R1 build 3 (lỗi V38-D2): lịch phiên giao dịch của symbol đang đóng (Ex38TradeSessionOpen) → KHÔNG gửi hedge / chân nén / close-by và
// KHÔNG mở nhóm nén mới, không tính là một lần thất bại; yêu cầu đầu tiên ở tick đầu phiên. Trước đó: DD kích hoạt bởi giá báo trước giờ mở phiên
// (01:00, phiên 01:02) → 5 lần "market closed" trong 51 s → LOCK_FAILED → hedge chỉ gửi lại sau DDLock_RetryMinutes (rổ hở ~4 phút đầu phiên).
// V38 R2: logic khóa / nén không đổi. Khi khóa kích hoạt: bản ghi khôi phục lệnh đóng tay của cụm → SUSPENDED (không gửi, giá quay lại không mở
// thêm); yêu cầu đang bay được đối soát (fill = vị thế của cụm, lần khóa kế tiếp tính từ vị thế broker). Thứ tự quyết định DD trong tick: OnTick
// (PairClose dở / đủ điều kiện trước, hòa vốn kinh tế chặn kích hoạt mới — OFH38_Precedence).
#ifndef OFH38_DDLOCK_MQH
#define OFH38_DDLOCK_MQH
// [DPMR R1] D04: DDL_HALT with the basket + hedge flat is released (-> NORMAL, cycle reset) only by a VERIFIED Owner full manual close (DpmrDdHaltReleaseCheck);
// a stop-out / EA / SL / TP / unproven close keeps the HALT. Lock / compression / LOCKED_HOLD logic unchanged.

// [FINAL STANDALONE] ===== BEGIN INLINED OFH38_DDLock_Core.mqh (HOTFIX SHA256 9F0ABC35F3BE7D8D1B114452CE94E9E20E061C1B127B84E1FEE7E94F2958F8B4) — included from OFH38_DDLock.mqh:L30 =====
// OFH38_DDLock_Core.mqh — V38 DD HEDGE LOCK: logic thuần (không gọi lệnh, không dùng biến EA). Unit-test được.
// Port từ donor V2B6 FINAL OFH_V2F_Recovery_Core.mqh (SHA AB3B4E46…): RcPlanLock, RcPos / RcPair / RcRemainderOk / RcPlanPair, RcFloorStep /
// RcRoundStep giữ NGUYÊN mã. Máy trạng thái: chỉ phần V38 được duyệt (khóa → nén cân bằng → giữ khóa → dừng chờ Owner);
// các trạng thái GoldEdge / Recovery của donor KHÔNG có ở V38 (AWAIT_GOLDEDGE → LOCKED_HOLD, PROTECTIVE_HALT → HALT).
#ifndef OFH38_DDLOCK_CORE_MQH
#define OFH38_DDLOCK_CORE_MQH

enum DDL_STATE
{
   DDL_NORMAL = 0,
   DDL_LOCK_PENDING = 1,
   DDL_LOCK_CONFIRMED = 2,
   DDL_LOCK_FAILED = 3,             // khóa chưa hoàn tất (từ chối / thiếu ký quỹ / hedge một phần): KHÔNG báo khóa đủ
   DDL_COMPRESSION_PENDING = 4,
   DDL_COMPRESSION_ACTIVE = 5,      // đúng một cặp đang đóng
   DDL_COMPRESSION_COMPLETE = 6,
   DDL_LOCKED_HOLD = 7,             // cụm khóa net-trung tính, chờ chính sách Recovery được Owner duyệt sau này (không tự mở khóa)
   DDL_HALT = 12                    // cụm phẳng sau đợt DD: không chu kỳ mới tới khi Owner xác nhận (DDLock_OwnerAckResume)
};

string DdlStateName(const int s)
{
   switch(s)
   {
      case DDL_NORMAL: return "NORMAL";
      case DDL_LOCK_PENDING: return "LOCK_PENDING";
      case DDL_LOCK_CONFIRMED: return "LOCK_CONFIRMED";
      case DDL_LOCK_FAILED: return "LOCK_FAILED";
      case DDL_COMPRESSION_PENDING: return "COMPRESSION_PENDING";
      case DDL_COMPRESSION_ACTIVE: return "COMPRESSION_ACTIVE";
      case DDL_COMPRESSION_COMPLETE: return "COMPRESSION_COMPLETE";
      case DDL_LOCKED_HOLD: return "LOCKED_HOLD";
      case DDL_HALT: return "HALT";
   }
   return "UNKNOWN";
}

// Bảng chuyển trạng thái tất định. Không có trong bảng = không hợp lệ.
bool DdlTransitionAllowed(const int from, const int to)
{
   switch(from)
   {
      case DDL_NORMAL:               return to == DDL_LOCK_PENDING;
      case DDL_LOCK_PENDING:         return to == DDL_LOCK_CONFIRMED || to == DDL_LOCK_FAILED || to == DDL_LOCKED_HOLD;
      case DDL_LOCK_FAILED:          return to == DDL_LOCK_PENDING || to == DDL_LOCK_CONFIRMED || to == DDL_LOCKED_HOLD;
      case DDL_LOCK_CONFIRMED:       return to == DDL_COMPRESSION_PENDING || to == DDL_COMPRESSION_COMPLETE || to == DDL_LOCK_PENDING || to == DDL_LOCKED_HOLD;
      case DDL_COMPRESSION_PENDING:  return to == DDL_COMPRESSION_ACTIVE || to == DDL_COMPRESSION_COMPLETE || to == DDL_LOCK_PENDING;
      case DDL_COMPRESSION_ACTIVE:   return to == DDL_COMPRESSION_PENDING || to == DDL_LOCK_PENDING;
      case DDL_COMPRESSION_COMPLETE: return to == DDL_LOCKED_HOLD;
      case DDL_LOCKED_HOLD:          return to == DDL_LOCK_PENDING || to == DDL_HALT;
      case DDL_HALT:                 return to == DDL_NORMAL || to == DDL_LOCK_PENDING;
   }
   return false;
}

// ---------------------------------------------------------------- donor code (unchanged)
double RcFloorStep(const double v, const double step) { const double s = step > 0.0 ? step : 0.01; return NormalizeDouble(MathFloor((v + 1e-9) / s) * s, 8); }
double RcRoundStep(const double v, const double step) { const double s = step > 0.0 ? step : 0.01; return NormalizeDouble(MathRound(v / s) * s, 8); }

struct RcLockPlan
{
   bool   neutral;      // no hedge needed (net zero, or residual below the broker minimum volume)
   int    dir;          // +1 BUY hedge, -1 SELL hedge
   double net;          // signed net BEFORE the hedge (BUY positive)
   double total;        // hedge volume required
   double chunk;        // volume of the next order (<= broker max)
   string reason;
};

// vb / vs = total BUY / SELL volume of BOTH magics (existing hedges count, so a retry never duplicates a hedge).
void RcPlanLock(const double vb, const double vs, const double step, const double vmin, const double vmax, RcLockPlan &p)
{
   p.net = NormalizeDouble(vb - vs, 8); p.dir = 0; p.total = 0.0; p.chunk = 0.0; p.neutral = false; p.reason = "";
   const double s = step > 0.0 ? step : 0.01;
   if(MathAbs(p.net) < s * 0.5) { p.neutral = true; p.reason = "NET_ZERO"; return; }
   const double need = RcRoundStep(MathAbs(p.net), s);
   if(need < vmin - 1e-9) { p.neutral = true; p.reason = "RESIDUAL_BELOW_MIN_VOLUME"; return; }
   p.dir = p.net > 0.0 ? -1 : 1;
   p.total = need;
   p.chunk = MathMin(need, vmax > 0.0 ? vmax : need);
   p.reason = "HEDGE_REQUIRED";
}

struct RcPos { ulong ticket; int dir; double vol; double pl; long time_msc; };

struct RcPair
{
   bool   found;
   ulong  buy_ticket, sell_ticket;
   double vol;                      // volume closed on EACH side
   double buy_vol, sell_vol;        // position volumes before
   double realized;                 // P/L realised by the group at current marks (profit + swap, pro rata)
   string reason;
};

bool RcRemainderOk(const double v_pos, const double v_close, const double vmin)
{
   const double r = NormalizeDouble(v_pos - v_close, 8);
   return (r < 1e-9) || (r >= vmin - 1e-9);
}

// max_close_each = the most volume that may be closed on EACH side (from the keep-gross target). The pair that removes the
// most gross volume wins (ties: oldest). Net exposure is unchanged by construction (equal BUY and SELL volume).
void RcPlanPair(const RcPos &p[], const int n, const double max_close_each, const double step, const double vmin, RcPair &o)
{
   o.found = false; o.buy_ticket = 0; o.sell_ticket = 0; o.vol = 0; o.buy_vol = 0; o.sell_vol = 0; o.realized = 0; o.reason = "NO_PAIR";
   const double cap = RcFloorStep(max_close_each, step);
   if(cap < vmin - 1e-9) { o.reason = "KEEP_TARGET_REACHED"; return; }
   bool anyB = false, anyS = false;
   long bestAge = 0;
   for(int i = 0; i < n; i++) { if(p[i].dir > 0) anyB = true; else anyS = true; }
   if(!anyB || !anyS) { o.reason = "ONE_SIDE_ONLY"; return; }
   for(int i = 0; i < n; i++)
   {
      if(p[i].dir <= 0) continue;
      for(int j = 0; j < n; j++)
      {
         if(p[j].dir >= 0) continue;
         double v = RcFloorStep(MathMin(MathMin(p[i].vol, p[j].vol), cap), step);
         if(!(RcRemainderOk(p[i].vol, v, vmin) && RcRemainderOk(p[j].vol, v, vmin)))
         {
            // brokers with vmin > step: leave exactly vmin on the larger leg
            const double alt = RcFloorStep(MathMin(p[i].vol, p[j].vol) - vmin, step);
            v = MathMin(alt, cap);
            if(!(RcRemainderOk(p[i].vol, v, vmin) && RcRemainderOk(p[j].vol, v, vmin))) continue;
         }
         if(v < vmin - 1e-9) continue;
         const long age = MathMin(p[i].time_msc, p[j].time_msc);
         if(!o.found || v > o.vol + 1e-9 || (MathAbs(v - o.vol) <= 1e-9 && age < bestAge))
         {
            o.found = true; o.buy_ticket = p[i].ticket; o.sell_ticket = p[j].ticket; o.vol = v;
            o.buy_vol = p[i].vol; o.sell_vol = p[j].vol; bestAge = age;
            o.realized = p[i].pl * (v / p[i].vol) + p[j].pl * (v / p[j].vol);
            o.reason = "PAIR";
         }
      }
   }
   if(!o.found) o.reason = "NO_VALID_PARTIAL_VOLUME";
}

#endif
// [FINAL STANDALONE] ===== END INLINED OFH38_DDLock_Core.mqh =====

CTradeV38 ddlTrade;   // lệnh hedge khóa / đóng nén phần hedge (magic DDLock_HedgeMagic)
int      g_ddlState = DDL_NORMAL;
// ảnh chụp lúc trigger (lưu bền)
long     g_ddlEpisode = 0;
datetime g_ddlTrigTime = 0;
double   g_ddlB0 = 0, g_ddlE0 = 0, g_ddlFloat0 = 0, g_ddlDD0 = 0, g_ddlThr0 = 0, g_ddlVB0 = 0, g_ddlVS0 = 0, g_ddlMargin0 = 0;
int      g_ddlN0 = 0;
double   g_ddlFirstPx0 = 0;
int      g_ddlFirstType0 = -1;
double   g_ddlRef = 0, g_ddlRealBefore = 0, g_ddlDebt0 = 0;
datetime g_ddlBasketStart = 0;
// khóa
bool     g_ddlHedgeSent = false, g_ddlAdopted = false;
int      g_ddlLockFails = 0, g_ddlLockFailEvents = 0;
datetime g_ddlNextTry = 0, g_ddlLastSend = 0, g_ddlLockFailedAt = 0, g_ddlLockTime = 0;
uint     g_ddlLastRc = 0;
double   g_ddlHedgeLots = 0, g_ddlNetBefore = 0, g_ddlNetAfter = 0, g_ddlGrossLock = 0;
// nén (cặp đang đóng — lưu bền)
double   g_ddlRealizedComp = 0;
int      g_ddlPairsDone = 0;
ulong    g_ddlPB = 0, g_ddlPS = 0;
double   g_ddlPV = 0, g_ddlPBBefore = 0, g_ddlPSBefore = 0, g_ddlPairPlanPL = 0, g_ddlPairBal0 = 0;
int      g_ddlPairFails = 0;
// R1: hedge đã được broker nhận nhưng chưa thấy trên vị thế (không gửi hedge mới khi còn đang bay)
ulong    g_ddlInflightOrder = 0;
long     g_ddlInflightMs = 0;
// theo dõi
double   g_ddlEqMin = 0, g_ddlMlMin = 0;
long     g_ddlAckEpisode = 0;   // đợt được Owner xác nhận (DDLock_OwnerAckResume=true lúc khởi tạo khi đợt đang HALT)
bool     g_ddlRowDone = false;
string   g_ddlOnce = "";

bool DdlActive() { return g_ddlState != DDL_NORMAL; }
void DdlLogOnce(const string key, const string text) { if(StringFind(g_ddlOnce, "|" + key + "|") >= 0) return; g_ddlOnce += "|" + key + "|"; Print(text); }
bool DdlMagic(const ulong mg) { return mg == Magic || mg == DDLock_HedgeMagic; }

// ---------------------------------------------------------------- persistence
string DdlNs() { return OfhNs("OFH38D", Magic); }
void   DdlSet(const string k, const double v) { GlobalVariableSet(DdlNs() + k, v); }
double DdlGet(const string k, const double d = 0.0) { const string key = DdlNs() + k; return GlobalVariableCheck(key) ? GlobalVariableGet(key) : d; }

void DdlPersist()
{
   DdlSet("state", g_ddlState); DdlSet("episode", (double)g_ddlEpisode); DdlSet("trigtime", (double)g_ddlTrigTime);
   DdlSet("b0", g_ddlB0); DdlSet("e0", g_ddlE0); DdlSet("float0", g_ddlFloat0); DdlSet("dd0", g_ddlDD0); DdlSet("thr0", g_ddlThr0);
   DdlSet("vb0", g_ddlVB0); DdlSet("vs0", g_ddlVS0); DdlSet("margin0", g_ddlMargin0); DdlSet("n0", g_ddlN0);
   DdlSet("firstpx0", g_ddlFirstPx0); DdlSet("firsttype0", g_ddlFirstType0);
   DdlSet("ref", g_ddlRef); DdlSet("realbefore", g_ddlRealBefore); DdlSet("debt0", g_ddlDebt0); DdlSet("bstart", (double)g_ddlBasketStart);
   DdlSet("hedgesent", g_ddlHedgeSent ? 1 : 0); DdlSet("adopted", g_ddlAdopted ? 1 : 0); DdlSet("lockfails", g_ddlLockFails); DdlSet("lockfailevents", g_ddlLockFailEvents);
   DdlSet("lockfailedat", (double)g_ddlLockFailedAt); DdlSet("locktime", (double)g_ddlLockTime);
   DdlSet("hedgelots", g_ddlHedgeLots); DdlSet("netbefore", g_ddlNetBefore); DdlSet("netafter", g_ddlNetAfter); DdlSet("grosslock", g_ddlGrossLock);
   DdlSet("realizedcomp", g_ddlRealizedComp); DdlSet("pairs", g_ddlPairsDone);
   DdlSet("pb", (double)g_ddlPB); DdlSet("ps", (double)g_ddlPS); DdlSet("pv", g_ddlPV); DdlSet("pbbefore", g_ddlPBBefore); DdlSet("psbefore", g_ddlPSBefore);
   DdlSet("pairplanpl", g_ddlPairPlanPL); DdlSet("pairbal0", g_ddlPairBal0); DdlSet("pairfails", g_ddlPairFails);
   DdlSet("eqmin", g_ddlEqMin); DdlSet("mlmin", g_ddlMlMin); DdlSet("rowdone", g_ddlRowDone ? 1 : 0);
   DdlSet("hedgemagic", (double)DDLock_HedgeMagic); OfhIdStore(DdlNs(), Magic);
   DdlSet("ifo", (double)g_ddlInflightOrder); DdlSet("ifm", (double)g_ddlInflightTickMsc); DdlSet("ifw", (double)g_ddlInflightWm);   // [SAFETY S03] hedge request without a broker result survives a restart
   DdlSet("lpt", (double)g_ddlLegTk); DdlSet("lpm", (double)g_ddlLegMsc); DdlSet("lpv", g_ddlLegVol0);                                 // [SAFETY S03] compression leg without a broker result
   static int s_state = -1; if(s_state != g_ddlState) { GlobalVariablesFlush(); s_state = g_ddlState; }   // a state change reaches the disk at once
}
void DdlClearPersist() { if(GlobalVariablesDeleteAll(DdlNs()) > 0) GlobalVariablesFlush(); }

// ---------------------------------------------------------------- broker inventory (re-read at every step)
struct DdlInv { int n_o, n_r; double vb_o, vs_o, vb_r, vs_r, pl_o, pl_r; };
void DdlInventory(DdlInv &v)
{
   v.n_o = v.n_r = 0; v.vb_o = v.vs_o = v.vb_r = v.vs_r = v.pl_o = v.pl_r = 0.0;
   for(int i = 0; i < PositionsTotal(); i++)
   {
      const ulong t = PositionGetTicket(i);
      if(t == 0 || !PositionSelectByTicket(t) || PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
      const ulong mg = (ulong)PositionGetInteger(POSITION_MAGIC);
      if(!DdlMagic(mg)) continue;
      const double vol = PositionGetDouble(POSITION_VOLUME), pl = PositionGetDouble(POSITION_PROFIT) + PositionGetDouble(POSITION_SWAP);
      const bool buy = PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY;
      if(mg == Magic) { v.n_o++; if(buy) v.vb_o += vol; else v.vs_o += vol; v.pl_o += pl; }
      else            { v.n_r++; if(buy) v.vb_r += vol; else v.vs_r += vol; v.pl_r += pl; }
   }
}
double DdlStep() { const double s = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP); return s > 0.0 ? s : 0.01; }
double DdlVMin() { const double m = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);  return m > 0.0 ? m : 0.01; }
double DdlVMax() { const double m = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);  return m > 0.0 ? m : 100.0; }
void   DdlPlanFromInv(const DdlInv &v, RcLockPlan &p) { RcPlanLock(v.vb_o + v.vb_r, v.vs_o + v.vs_r, DdlStep(), DdlVMin(), DdlVMax(), p); }
ENUM_ORDER_TYPE_FILLING DdlFilling()
{
   const long fm = SymbolInfoInteger(_Symbol, SYMBOL_FILLING_MODE);
   if((fm & SYMBOL_FILLING_FOK) == SYMBOL_FILLING_FOK) return ORDER_FILLING_FOK;
   if((fm & SYMBOL_FILLING_IOC) == SYMBOL_FILLING_IOC) return ORDER_FILLING_IOC;
   return ORDER_FILLING_RETURN;
}
bool DdlPendingHedgeOrders()
{
   for(int i = OrdersTotal() - 1; i >= 0; i--)
   {
      const ulong t = OrderGetTicket(i);
      if(t != 0 && OrderGetString(ORDER_SYMBOL) == _Symbol && (ulong)OrderGetInteger(ORDER_MAGIC) == DDLock_HedgeMagic) return true;
   }
   return false;
}
// R1: true while the last accepted hedge order is not visible as a position yet (and its confirm window is open) → no new hedge
bool DdlHedgeInflight()
{
   if(g_ddlInflightOrder == 0 && g_ddlInflightTickMsc <= 0) return false;   // [SAFETY S03] an UNKNOWN result has no order ticket: its tick time marks it
   if(g_ddlInflightOrder != 0)
      for(int i = PositionsTotal() - 1; i >= 0; i--)
      {
         const ulong t = PositionGetTicket(i);
         if(t == 0 || !PositionSelectByTicket(t) || PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
         if((ulong)PositionGetInteger(POSITION_IDENTIFIER) == g_ddlInflightOrder) { g_ddlInflightOrder = 0; g_ddlInflightTickMsc = 0; g_ddlInflightWm = 0; DdlPersist(); return false; }
      }
   // [SAFETY S03] HOTFIX gave up after Exec_ConfirmMs (1 s) and re-planned from the positions: a late fill doubled the hedge. Only broker evidence ends the wait now
   // (deal + position listed / closed, cancelled / rejected / expired order, or SAF_UNKNOWN_RESOLVE_SEC with no order, no deal, no position, terminal connected).
   bool d = false, pl = false, pc = false, w = false; int h = -1;
   SafEntryEvidence(DDLock_HedgeMagic, g_ddlInflightOrder, g_ddlInflightTickMsc, g_ddlInflightWm, d, pl, pc, w, h);
   const long el = g_ddlInflightTickMsc > 0 ? Ex38TickMsc() - g_ddlInflightTickMsc : (long)SAF_UNKNOWN_RESOLVE_SEC * 1000;
   const int r = Saf38EntryResolve(d, pl, pc, w, h, el, (long)SAF_UNKNOWN_RESOLVE_SEC * 1000, TerminalInfoInteger(TERMINAL_CONNECTED) != 0);
   if(r == SAF_ER_WAIT)
   {
      g_safDdlWait++;
      DdlLogOnce("HEDGEWAIT_" + IntegerToString(g_ddlInflightTickMsc) + "_" + IntegerToString((long)g_ddlInflightOrder),
                 StringFormat("DDL HEDGE %I64u (rc %u) has no broker result yet (deal %d, position listed %d / closed %d, order working %d, order history %d): no new hedge request", g_ddlInflightOrder, g_ddlLastRc, d, pl, pc, w, h));
      return true;
   }
   PrintFormat("DDL HEDGE %I64u %s by broker evidence (deal %d, position listed %d / closed %d, order working %d, order history %d, %I64d ms) - the lock is re-planned from the broker positions",
               g_ddlInflightOrder, Saf38ErName(r), d, pl, pc, w, h, el);
   g_ddlInflightOrder = 0; g_ddlInflightTickMsc = 0; g_ddlInflightWm = 0; DdlPersist();
   return false;
}

// ---------------------------------------------------------------- economic debt of the episode
double DdlRealisedSince(const datetime t0)
{
   double s = 0.0;
   if(t0 <= 0 || !HistorySelect(t0, TimeCurrent() + 60)) return 0.0;
   for(int i = 0; i < HistoryDealsTotal(); i++)
   {
      const ulong d = HistoryDealGetTicket(i);
      if(d == 0 || HistoryDealGetString(d, DEAL_SYMBOL) != _Symbol || !DdlMagic((ulong)HistoryDealGetInteger(d, DEAL_MAGIC))) continue;
      const double cost = HistoryDealGetDouble(d, DEAL_COMMISSION) + HistoryDealGetDouble(d, DEAL_FEE);
      const long en = HistoryDealGetInteger(d, DEAL_ENTRY);
      s += (en == DEAL_ENTRY_IN) ? cost : HistoryDealGetDouble(d, DEAL_PROFIT) + HistoryDealGetDouble(d, DEAL_SWAP) + cost;
   }
   return s;
}
// commission + fee and swap of both magics since t0 (cost breakdown for the report)
void DdlCostsSince(const datetime t0, double &comm, double &swap, double &profit)
{
   comm = 0.0; swap = 0.0; profit = 0.0;
   if(t0 <= 0 || !HistorySelect(t0, TimeCurrent() + 60)) return;
   for(int i = 0; i < HistoryDealsTotal(); i++)
   {
      const ulong d = HistoryDealGetTicket(i);
      if(d == 0 || HistoryDealGetString(d, DEAL_SYMBOL) != _Symbol || !DdlMagic((ulong)HistoryDealGetInteger(d, DEAL_MAGIC))) continue;
      comm += HistoryDealGetDouble(d, DEAL_COMMISSION) + HistoryDealGetDouble(d, DEAL_FEE);
      swap += HistoryDealGetDouble(d, DEAL_SWAP); profit += HistoryDealGetDouble(d, DEAL_PROFIT);
   }
}
double DdlFloating()
{
   double s = 0.0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      const ulong t = PositionGetTicket(i);
      if(t == 0 || !PositionSelectByTicket(t) || PositionGetString(POSITION_SYMBOL) != _Symbol || !DdlMagic((ulong)PositionGetInteger(POSITION_MAGIC))) continue;
      s += PositionGetDouble(POSITION_PROFIT) + PositionGetDouble(POSITION_SWAP);
   }
   return s;
}
string   g_ddlRealKey = ""; double g_ddlRealVal = 0.0; datetime g_ddlRealAt = 0;
double DdlRealised()
{
   const string key = StringFormat("%I64d|%.2f|%d", (long)g_ddlBasketStart, AccountInfoDouble(ACCOUNT_BALANCE), PositionsTotal());
   if(key == g_ddlRealKey && TimeCurrent() - g_ddlRealAt < 60) return g_ddlRealVal;
   g_ddlRealKey = key; g_ddlRealAt = TimeCurrent();
   g_ddlRealVal = DdlRealisedSince(g_ddlBasketStart);
   return g_ddlRealVal;
}
double DdlEpisodePL() { return g_ddlBasketStart > 0 ? DdlRealised() + DdlFloating() : 0.0; }
double DdlDebt()      { return -DdlEpisodePL(); }
double DdlOwnEquity() { return g_ddlRef + DdlEpisodePL(); }
// estimated cost of closing every open position of the episode now: close commission (entry commission pro rata) + slippage buffer
double DdlCloseCost()
{
   double c = 0.0, vol = 0.0;
   const double ts = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE), tv = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
   ulong tk[]; double vv[]; int n = 0;
   for(int i = 0; i < PositionsTotal(); i++)
   {
      const ulong t = PositionGetTicket(i);
      if(t == 0 || !PositionSelectByTicket(t) || PositionGetString(POSITION_SYMBOL) != _Symbol || !DdlMagic((ulong)PositionGetInteger(POSITION_MAGIC))) continue;
      ArrayResize(tk, n + 1); ArrayResize(vv, n + 1); tk[n] = t; vv[n] = PositionGetDouble(POSITION_VOLUME); vol += vv[n]; n++;
   }
   for(int i = 0; i < n; i++)
   {
      if(!HistorySelectByPosition(tk[i])) continue;
      for(int j = 0; j < HistoryDealsTotal(); j++)
      {
         const ulong d = HistoryDealGetTicket(j);
         if(d == 0 || HistoryDealGetInteger(d, DEAL_ENTRY) != DEAL_ENTRY_IN) continue;
         const double vin = HistoryDealGetDouble(d, DEAL_VOLUME);
         if(vin > 0.0) c += MathAbs(HistoryDealGetDouble(d, DEAL_COMMISSION) + HistoryDealGetDouble(d, DEAL_FEE)) * vv[i] / vin;
         break;
      }
   }
   if(ts > 0.0) c += MathMax(0, DDLock_CloseSlipPoints) * _Point / ts * tv * vol;
   return c;
}
datetime DdlBasketStartTime()
{
   datetime t = 0;
   for(int i = 0; i < PositionsTotal(); i++)
   {
      const ulong tk = PositionGetTicket(i);
      if(tk == 0 || !PositionSelectByTicket(tk) || !IsOursPos()) continue;
      const datetime pt = (datetime)PositionGetInteger(POSITION_TIME);
      if(t == 0 || pt < t) t = pt;
   }
   return t;
}

// ---------------------------------------------------------------- state machine
void DdlSetState(const int to, const string why)
{
   if(g_ddlState == to) return;
   int target = to;
   if(!DdlTransitionAllowed(g_ddlState, to))
   {
      PrintFormat("DDL ILLEGAL TRANSITION %s -> %s (%s) => LOCK_PENDING (re-lock from the broker positions)", DdlStateName(g_ddlState), DdlStateName(to), why);
      target = DDL_LOCK_PENDING;
   }
   DdlInv v; DdlInventory(v);
   PrintFormat("DDL STATE %s -> %s | %s | basket n=%d B=%.2f S=%.2f | hedge n=%d B=%.2f S=%.2f | net=%+.2f | bal=%.2f eq=%.2f margin=%.2f free=%.2f | debt=%.2f (reference %.2f)",
               DdlStateName(g_ddlState), DdlStateName(target), why, v.n_o, v.vb_o, v.vs_o, v.n_r, v.vb_r, v.vs_r, (v.vb_o + v.vb_r) - (v.vs_o + v.vs_r),
               AccountInfoDouble(ACCOUNT_BALANCE), AccountInfoDouble(ACCOUNT_EQUITY), AccountInfoDouble(ACCOUNT_MARGIN), AccountInfoDouble(ACCOUNT_MARGIN_FREE),
               DdlDebt(), g_ddlRef);
   g_ddlState = target;
   DdlPersist();
}

// ---------------------------------------------------------------- DD trigger (TryCutByAccountDd calls this instead of CloseBasket)
bool DdlActivate(const double pl, const double bal, const double pct)
{
   if(DdlActive()) return true;
   DdlInv v; DdlInventory(v);
   g_ddlEpisode = (long)TimeCurrent(); g_ddlTrigTime = TimeCurrent();
   g_ddlB0 = bal; g_ddlE0 = AccountInfoDouble(ACCOUNT_EQUITY); g_ddlFloat0 = pl; g_ddlDD0 = pct; g_ddlThr0 = Cat_DD_PhanTram;
   g_ddlVB0 = v.vb_o; g_ddlVS0 = v.vs_o; g_ddlN0 = v.n_o; g_ddlMargin0 = AccountInfoDouble(ACCOUNT_MARGIN);
   g_ddlFirstPx0 = FirstPrice; g_ddlFirstType0 = FirstType;
   g_ddlHedgeSent = false; g_ddlAdopted = false; g_ddlLockFails = 0; g_ddlLockFailEvents = 0; g_ddlNextTry = 0; g_ddlLastSend = 0; g_ddlLastRc = 0;
   g_ddlLockFailedAt = 0; g_ddlLockTime = 0; g_ddlHedgeLots = 0; g_ddlNetAfter = 0; g_ddlGrossLock = 0;
   g_ddlRealizedComp = 0; g_ddlPairsDone = 0; g_ddlPB = 0; g_ddlPS = 0; g_ddlPV = 0; g_ddlPairFails = 0; g_ddlOnce = ""; g_ddlRowDone = false;
   g_ddlInflightOrder = 0; g_ddlInflightMs = 0; g_ddlInflightTickMsc = 0; g_ddlInflightWm = 0; g_ddlLegTk = 0; g_ddlLegMsc = 0; g_ddlLegVol0 = 0.0;   // [SAFETY S03]
   g_ddlNetBefore = (v.vb_o + v.vb_r) - (v.vs_o + v.vs_r);
   // economic reference: balance before the basket existed (balance now - realised by the basket so far)
   g_ddlBasketStart = DdlBasketStartTime(); g_ddlRealKey = "";
   g_ddlRealBefore = DdlRealisedSince(g_ddlBasketStart);
   g_ddlRef = bal - g_ddlRealBefore;
   g_ddlDebt0 = DdlDebt(); g_ddlEqMin = DdlOwnEquity(); g_ddlMlMin = AccountInfoDouble(ACCOUNT_MARGIN) > 0.0 ? AccountInfoDouble(ACCOUNT_MARGIN_LEVEL) : 0.0;
   PrintFormat("=== DD TRIGGER (V26 measurement: |basket floating| / balance) | pl=%.2f / bal=%.2f = %.2f%% >= %.2f%% | basket n=%d BUY=%.2f SELL=%.2f net=%+.2f | FirstPx=%.2f | V26 CloseBasket REPLACED BY DD HEDGE LOCK ===",
               pl, bal, pct, Cat_DD_PhanTram, v.n_o, v.vb_o, v.vs_o, v.vb_o - v.vs_o, FirstPrice);
   PrintFormat("DDL SNAPSHOT | basket start %s | balance %.2f equity %.2f margin %.2f | realised by the basket before the trigger %.2f -> reference (balance before the basket) %.2f | episode debt %.2f",
               TimeToString(g_ddlBasketStart, TIME_DATE | TIME_SECONDS), bal, g_ddlE0, g_ddlMargin0, g_ddlRealBefore, g_ddlRef, g_ddlDebt0);
   if(sessionRescue) SetSessionRescue(false, "DD_LOCK_TAKES_AUTHORITY");
   g_ddlState = DDL_NORMAL;
   DdlSetState(DDL_LOCK_PENDING, "DD_TRIGGER");
   MrOnDdActivate();   // R2: manual-recovery records of the basket -> SUSPENDED (no request while the DD Lock owns the basket)
   return true;
}

// ---------------------------------------------------------------- lock
bool DdlSendHedge(const int dir, const double vol)
{
   const bool isBuy = dir > 0;
   // margin pre-check with the broker; halve the chunk down to the minimum volume if the full chunk does not pass
   MqlTradeRequest q; MqlTradeCheckResult c;
   double tryVol = vol;
   bool ok = false;
   while(tryVol >= DdlVMin() - 1e-9)
   {
      ZeroMemory(q); ZeroMemory(c);
      q.action = TRADE_ACTION_DEAL; q.symbol = _Symbol; q.volume = tryVol; q.magic = DDLock_HedgeMagic; q.deviation = DDLock_DeviationPoints;
      q.type = isBuy ? ORDER_TYPE_BUY : ORDER_TYPE_SELL; q.price = isBuy ? SymbolInfoDouble(_Symbol, SYMBOL_ASK) : SymbolInfoDouble(_Symbol, SYMBOL_BID);
      q.type_filling = DdlFilling();
      if(OrderCheck(q, c) && (c.retcode == 0 || c.retcode == TRADE_RETCODE_DONE)) { ok = true; break; }
      if(c.retcode != TRADE_RETCODE_NO_MONEY) break;
      tryVol = RcFloorStep(tryVol / 2.0, DdlStep());
   }
   if(!ok)
   {
      g_ddlLockFails++; g_ddlLastRc = c.retcode; g_ddlNextTry = TimeCurrent() + 5 * g_ddlLockFails;
      PrintFormat("DDL LOCK PRE-CHECK FAILED | %s %.2f rc=%u %s | attempt %d/%d", isBuy ? "BUY" : "SELL", vol, c.retcode, c.comment, g_ddlLockFails, DDLock_MaxAttempts);
      DdlPersist();
      return false;
   }
   ddlTrade.SetDeviationInPoints(DDLock_DeviationPoints);
   // [SAFETY S03] intent BEFORE the request (tick time + entry-deal watermark of the hedge magic, persisted): a late fill after a restart is found by evidence
   g_ddlInflightOrder = 0; g_ddlInflightTickMsc = Ex38TickMsc(); g_ddlInflightWm = SafEntryWatermark(DDLock_HedgeMagic); DdlPersist(); GlobalVariablesFlush();
   const long s0 = ddlTrade.m_sends;
   const bool sent = isBuy ? ddlTrade.Buy(tryVol, _Symbol, 0, 0, 0, "OFH38|DDLOCK") : ddlTrade.Sell(tryVol, _Symbol, 0, 0, 0, "OFH38|DDLOCK");
   const uint rc = (ddlTrade.m_sends > s0) ? ddlTrade.ResultRetcode() : 0;
   g_ddlLastRc = rc; g_ddlLastSend = TimeCurrent();
   if(Saf38OpenRcClass(ddlTrade.m_sends > s0, rc) == SAF_OR_UNKNOWN)   // R1: TIMEOUT — kết quả chưa biết: không tính thất bại, không gửi lại trước khi đối soát; [SAFETY S03] + CONNECTION / ERROR / ORDER_CHANGED / LOCKED / no retcode
   {
      g_ddlHedgeSent = true; g_ddlInflightOrder = ddlTrade.ResultOrder(); g_ddlInflightMs = Ex38NowMs();   // [SAFETY S03] tick time + watermark of the intent kept
      PrintFormat("DDL HEDGE OUTCOME UNKNOWN | %s %.2f rc=%u (timeout) | no new hedge for %d ms - the broker positions decide", isBuy ? "BUY" : "SELL", tryVol, rc, Exec_ConfirmMs);
      DdlPersist();
      return true;
   }
   if(sent && (rc == TRADE_RETCODE_DONE || rc == TRADE_RETCODE_DONE_PARTIAL || rc == TRADE_RETCODE_PLACED))
   {
      g_ddlHedgeSent = true;
      g_ddlInflightOrder = ddlTrade.ResultOrder(); g_ddlInflightMs = Ex38NowMs();   // R1: thay BriefPause — hedge mới chỉ sau khi hedge này hiện trên broker ([SAFETY S03] bằng chứng broker, tick time của ý định)
      DdlInv v; DdlInventory(v);
      PrintFormat("DDL HEDGE SENT | %s %.2f of %.2f @%.2f rc=%u filled=%.2f | reconcile: basket B=%.2f S=%.2f hedge B=%.2f S=%.2f -> net %+.2f",
                  isBuy ? "BUY" : "SELL", tryVol, vol, ddlTrade.ResultPrice(), rc, ddlTrade.ResultVolume(), v.vb_o, v.vs_o, v.vb_r, v.vs_r, (v.vb_o + v.vb_r) - (v.vs_o + v.vs_r));
      DdlPersist();
      return true;
   }
   g_ddlLockFails++; g_ddlNextTry = TimeCurrent() + 5 * g_ddlLockFails;
   g_ddlInflightOrder = 0; g_ddlInflightTickMsc = 0; g_ddlInflightWm = 0;   // [SAFETY S03] definite rejection / not sent: the intent is cleared
   PrintFormat("DDL LOCK SEND REJECTED | %s %.2f rc=%u %s | attempt %d/%d", isBuy ? "BUY" : "SELL", tryVol, rc, ddlTrade.ResultComment(), g_ddlLockFails, DDLock_MaxAttempts);
   DdlPersist();
   return false;
}

void DdlLockStep(const DdlInv &v)
{
   if((ENUM_ACCOUNT_MARGIN_MODE)AccountInfoInteger(ACCOUNT_MARGIN_MODE) != ACCOUNT_MARGIN_MODE_RETAIL_HEDGING)
   { g_ddlLockFailedAt = TimeCurrent(); g_ddlLockFailEvents++; DdlSetState(DDL_LOCK_FAILED, "NETTING_ACCOUNT_CANNOT_HEDGE"); return; }
   RcLockPlan p; DdlPlanFromInv(v, p);
   if(p.neutral)
   {
      DdlSetState(DDL_LOCK_CONFIRMED, StringFormat("NET_NEUTRAL(%s) net=%+.2f hedge_sent=%s", p.reason, p.net, g_ddlHedgeSent ? "yes" : "no (already neutral)"));
      return;
   }
   if(!Ex38TradeSessionOpen())   // R1 build 3 (V38-D2): certain "market closed" -> no hedge request, no attempt counted; first request on the first tick of the session
   {
      DdlLogOnce("LOCKWAIT_" + TimeToString(TimeCurrent(), TIME_DATE), StringFormat("DDL LOCK WAITS FOR THE TRADE SESSION | net=%+.2f | the trade schedule of %s is closed: no hedge request, no attempt counted - first request on the first tick of the session", p.net, _Symbol));
      return;
   }
   if(g_ddlLockFails >= DDLock_MaxAttempts)
   {
      g_ddlLockFailedAt = TimeCurrent(); g_ddlLockFailEvents++;
      DdlSetState(DDL_LOCK_FAILED, StringFormat("ATTEMPTS_EXHAUSTED last_rc=%u net=%+.2f (hedge %s)", g_ddlLastRc, p.net, g_ddlHedgeSent ? "PARTIAL" : "NONE"));
      return;
   }
   if(TimeCurrent() < g_ddlNextTry) return;
   // never duplicate: a hedge still in flight (pending order, or PLACED < ConfirmWait s ago) blocks a new send
   if(DdlPendingHedgeOrders()) return;
   if(DdlHedgeInflight()) return;   // R1: hedge accepted by the broker but not visible on the positions yet
   if(Ex38NowMs() < g_exGraceUntil) return;   // R1: restart with a hedge sent before it - re-read the broker first
   if(g_ddlLastSend > 0 && TimeCurrent() - g_ddlLastSend < ConfirmWait && g_ddlLastRc == TRADE_RETCODE_PLACED) return;
   PrintFormat("DDL LOCK PLAN | BUY=%.2f SELL=%.2f net=%+.2f -> hedge %s %.2f (this order %.2f; step %.2f min %.2f max %.2f)", v.vb_o + v.vb_r, v.vs_o + v.vs_r, p.net,
               p.dir > 0 ? "BUY" : "SELL", p.total, p.chunk, DdlStep(), DdlVMin(), DdlVMax());
   DdlSendHedge(p.dir, p.chunk);
}

// ---------------------------------------------------------------- original SL / TP: kept until the lock is confirmed, then removed
void DdlClearOriginalStops()
{
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      const ulong t = PositionGetTicket(i);
      if(t == 0 || !PositionSelectByTicket(t) || !IsOursPos()) continue;
      if(PositionGetDouble(POSITION_SL) > 0.0 || PositionGetDouble(POSITION_TP) > 0.0) ModifySlTpVerified(t, 0.0, 0.0);
   }
}
bool DdlOriginalStopsClear()
{
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      const ulong t = PositionGetTicket(i);
      if(t == 0 || !PositionSelectByTicket(t) || !IsOursPos()) continue;
      if(PositionGetDouble(POSITION_SL) > 0.0 || PositionGetDouble(POSITION_TP) > 0.0) return false;
   }
   return true;
}

// ---------------------------------------------------------------- balanced compression (donor planner; close-by execution when possible)
// R1: 1 = broker shows the volume closed | 0 = accepted (DONE / partial / in flight / timeout) but not observed yet → wait, no resend, not a failure
//     | -1 = not executed (retcode per operation) → donor failure count + backoff
int DdlCloseVolume(const ulong ticket, const double vol, const string why)
{
   if(!PositionSelectByTicket(ticket)) return -1;
   const ulong mg = (ulong)PositionGetInteger(POSITION_MAGIC);
   if(PositionGetString(POSITION_SYMBOL) != _Symbol || !DdlMagic(mg)) return -1;   // never another EA
   const double before = PositionGetDouble(POSITION_VOLUME);
   CTradeV38 *t = (mg == Magic) ? GetPointer(trade) : GetPointer(ddlTrade);
   const ulong dev0 = t.DeviationPoints();   // [SAFETY S04] the shared `trade` object keeps the deviation of the grid / L1 requests
   t.SetDeviationInPoints(DDLock_DeviationPoints);
   const long s0 = t.m_sends;
   const bool sent = (vol >= before - DdlStep() * 0.5) ? t.PositionClose(ticket) : t.PositionClosePartial(ticket, vol);
   t.SetDeviationInPoints(dev0);             // [SAFETY S04] restored (HOTFIX left 30 points on `trade` for every later grid / L1 order)
   const uint rc = (t.m_sends > s0) ? t.ResultRetcode() : 0;
   const double after = PositionSelectByTicket(ticket) ? PositionGetDouble(POSITION_VOLUME) : 0.0;
   const bool verified = after <= before - vol + DdlStep() * 0.5;
   const int cls = Ex38Classify(EX38_OP_CLOSE, rc);
   const int res = verified ? 1 : ((cls == EXC_DONE || cls == EXC_PARTIAL || cls == EXC_INFLIGHT || cls == EXC_UNKNOWN || cls == EXC_GONE) ? 0 : -1);
   PrintFormat("DDL COMPRESSION LEG %s | ticket %I64u close %.2f of %.2f -> %.2f left | rc=%u %s sent=%d verified=%d%s", why, ticket, vol, before, after, rc, Ex38ClassName(cls), sent ? 1 : 0, verified ? 1 : 0,
               res == 0 ? " | accepted, not observed yet: no resend before the confirm window" : "");
   return res;
}

void DdlCompressionPlan(const DdlInv &v)
{
   RcLockPlan p; DdlPlanFromInv(v, p);
   if(!p.neutral) { DdlSetState(DDL_LOCK_PENDING, StringFormat("NET_DRIFT net=%+.2f before compression", p.net)); return; }
   if(!DDLock_EnableCompression) { DdlSetState(DDL_COMPRESSION_COMPLETE, "COMPRESSION_DISABLED"); return; }
   if(!Ex38TradeSessionOpen())   // R1 build 3 (V38-D2): no new compression group while the trade schedule is closed
   {
      DdlLogOnce("GROUPWAIT_" + TimeToString(TimeCurrent(), TIME_DATE), StringFormat("DDL COMPRESSION WAITS FOR THE TRADE SESSION | the trade schedule of %s is closed: no new group before the session opens", _Symbol));
      return;
   }
   const double gross = v.vb_o + v.vb_r + v.vs_o + v.vs_r;
   const double keep = g_ddlGrossLock * MathMax(0.0, DDLock_CompressionKeepGrossPct) / 100.0;
   RcPos ps[]; int n = 0;
   for(int i = 0; i < PositionsTotal(); i++)
   {
      const ulong t = PositionGetTicket(i);
      if(t == 0 || !PositionSelectByTicket(t) || PositionGetString(POSITION_SYMBOL) != _Symbol || !DdlMagic((ulong)PositionGetInteger(POSITION_MAGIC))) continue;
      ArrayResize(ps, n + 1);
      ps[n].ticket = t; ps[n].dir = PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY ? 1 : -1; ps[n].vol = PositionGetDouble(POSITION_VOLUME);
      ps[n].pl = PositionGetDouble(POSITION_PROFIT) + PositionGetDouble(POSITION_SWAP); ps[n].time_msc = PositionGetInteger(POSITION_TIME_MSC);
      n++;
   }
   RcPair pr;
   RcPlanPair(ps, n, (gross - keep) / 2.0, DdlStep(), DdlVMin(), pr);
   if(!pr.found) { DdlSetState(DDL_COMPRESSION_COMPLETE, StringFormat("%s gross=%.2f keep=%.2f", pr.reason, gross, keep)); return; }
   const double vbAll = v.vb_o + v.vb_r, vsAll = v.vs_o + v.vs_r;
   PrintFormat("DDL COMPRESSION GROUP #%d | close BUY %I64u %.2f/%.2f + SELL %I64u %.2f/%.2f | planned realised P/L at marks %.2f | BUY %.2f->%.2f SELL %.2f->%.2f net %+.2f->%+.2f | gross %.2f->%.2f (keep %.2f) | equity impact ~0 at marks: the loss moves from floating to balance, the debt is unchanged",
               g_ddlPairsDone + 1, pr.buy_ticket, pr.vol, pr.buy_vol, pr.sell_ticket, pr.vol, pr.sell_vol, pr.realized,
               vbAll, vbAll - pr.vol, vsAll, vsAll - pr.vol, vbAll - vsAll, vbAll - vsAll, gross, gross - 2.0 * pr.vol, keep);
   g_ddlPB = pr.buy_ticket; g_ddlPS = pr.sell_ticket; g_ddlPV = pr.vol; g_ddlPBBefore = pr.buy_vol; g_ddlPSBefore = pr.sell_vol;
   g_ddlPairPlanPL = pr.realized; g_ddlPairBal0 = AccountInfoDouble(ACCOUNT_BALANCE); g_ddlPairFails = 0; g_ddlCloseByOff = false;
   DdlSetState(DDL_COMPRESSION_ACTIVE, StringFormat("GROUP_%d_STARTED", g_ddlPairsDone + 1));
}

// V38 (lệch có chủ đích so với donor, xem V38_DD_LOCK_VALIDATION.md): cặp có khối lượng = chân nhỏ hơn được đóng bằng MỘT lệnh close-by
// (BUY đóng bởi SELL) khi sàn cho phép → net không đổi ở mọi thời điểm. Không được (cặp đóng một phần / sàn không hỗ trợ / bị từ chối)
// → cách donor: chân BUY rồi chân SELL (giữa hai chân net lệch đúng 1 chân trong thời gian thực hiện).
bool g_ddlCloseByOff = false;   // close-by refused for the current pair -> donor two-leg path
bool DdlCloseByAllowed() { return (SymbolInfoInteger(_Symbol, SYMBOL_ORDER_MODE) & SYMBOL_ORDER_CLOSEBY) == SYMBOL_ORDER_CLOSEBY; }
// R1: 1 = both volumes reduced on the broker | 0 = accepted but not observed yet (no resend before the confirm window) | -1 = not executed
int DdlCloseBy(const ulong buyTk, const ulong sellTk, const double vol)
{
   if(!PositionSelectByTicket(buyTk)) return -1;
   CTradeV38 *t = ((ulong)PositionGetInteger(POSITION_MAGIC) == Magic) ? GetPointer(trade) : GetPointer(ddlTrade);
   const double vb0 = PositionGetDouble(POSITION_VOLUME), vs0 = PositionSelectByTicket(sellTk) ? PositionGetDouble(POSITION_VOLUME) : 0.0;
   const long s0 = t.m_sends;
   const bool sent = t.PositionCloseBy(buyTk, sellTk);
   const uint rc = (t.m_sends > s0) ? t.ResultRetcode() : 0;
   const double vb1 = PositionSelectByTicket(buyTk) ? PositionGetDouble(POSITION_VOLUME) : 0.0, vs1 = PositionSelectByTicket(sellTk) ? PositionGetDouble(POSITION_VOLUME) : 0.0;
   const bool verified = (vb0 - vb1 >= vol - DdlStep() * 0.5) && (vs0 - vs1 >= vol - DdlStep() * 0.5);
   const int cls = Ex38Classify(EX38_OP_CLOSEBY, rc);
   const int res = verified ? 1 : ((cls == EXC_DONE || cls == EXC_PARTIAL || cls == EXC_INFLIGHT || cls == EXC_UNKNOWN) ? 0 : -1);
   PrintFormat("DDL COMPRESSION CLOSE-BY | BUY %I64u %.2f->%.2f by SELL %I64u %.2f->%.2f | rc=%u %s sent=%d verified=%d (net unchanged at every moment)%s",
               buyTk, vb0, vb1, sellTk, vs0, vs1, rc, Ex38ClassName(cls), sent ? 1 : 0, verified ? 1 : 0, res == 0 ? " | accepted, not observed yet: wait" : "");
   return res;
}

// the one pending pair: close-by when possible, else BUY leg first, then SELL leg; verified by broker volumes (partial fills are completed)
void DdlPairStep()
{
   const double tol = DdlStep() * 0.5;
   const double vbNow = PositionSelectByTicket(g_ddlPB) ? PositionGetDouble(POSITION_VOLUME) : 0.0;
   const double vsNow = PositionSelectByTicket(g_ddlPS) ? PositionGetDouble(POSITION_VOLUME) : 0.0;
   const double bLeft = NormalizeDouble(g_ddlPV - (g_ddlPBBefore - vbNow), 8);
   const double sLeft = NormalizeDouble(g_ddlPV - (g_ddlPSBefore - vsNow), 8);
   const bool bDone = bLeft <= tol, sDone = sLeft <= tol;
   // [SAFETY S03] a leg / close-by accepted without a broker result: no further request on this pair before broker evidence (HOTFIX re-sent after 1 s: a late fill of
   // a PARTIAL close over-closed the position)
   if(g_ddlLegTk != 0)
   {
      const double liveLeg = PositionSelectByTicket(g_ddlLegTk) ? PositionGetDouble(POSITION_VOLUME) : 0.0;
      const int lr = Saf38LegResolve(g_ddlLegVol0, liveLeg, Ex38CloseOrderWorking(g_ddlLegTk), Ex38TickMsc() - g_ddlLegMsc, (long)SAF_UNKNOWN_RESOLVE_SEC * 1000, TerminalInfoInteger(TERMINAL_CONNECTED) != 0, tol);
      if(lr == SAF_ER_WAIT)
      {
         g_safDdlWait++;
         DdlLogOnce("LEGWAIT_" + IntegerToString((long)g_ddlLegTk) + "_" + IntegerToString(g_ddlLegMsc), StringFormat("DDL COMPRESSION LEG %I64u (%.2f lots before) has no broker result yet: no further request on this pair before broker evidence", g_ddlLegTk, g_ddlLegVol0));
         return;
      }
      PrintFormat("DDL COMPRESSION LEG %I64u %s by broker evidence (volume %.2f -> %.2f) - the pair is re-planned from the live volumes", g_ddlLegTk, Saf38ErName(lr), g_ddlLegVol0, liveLeg);
      g_ddlLegTk = 0; g_ddlLegMsc = 0; g_ddlLegVol0 = 0.0; DdlPersist();
   }
   if(!(bDone && sDone) && !Ex38TradeSessionOpen())   // R1 build 3 (V38-D2): a leg is never sent while the trade schedule is closed, and the wait is not a failure
   {
      DdlLogOnce("PAIRWAIT_" + TimeToString(TimeCurrent(), TIME_DATE), StringFormat("DDL COMPRESSION PAIR WAITS FOR THE TRADE SESSION | buyLeft=%.2f sellLeft=%.2f | the trade schedule of %s is closed: no leg request, no failure counted", bLeft, sLeft, _Symbol));
      return;
   }
   if(!bDone && !sDone && !g_ddlCloseByOff && vbNow > 0.0 && vsNow > 0.0 && MathAbs(vbNow - g_ddlPBBefore) < tol && MathAbs(vsNow - g_ddlPSBefore) < tol &&
      MathAbs(g_ddlPV - MathMin(vbNow, vsNow)) < tol && TimeCurrent() >= g_ddlNextTry)
   {
      if(!DdlCloseByAllowed())
      {
         g_ddlCloseByOff = true;
         DdlLogOnce("NOCLOSEBY", "DDL COMPRESSION | symbol has no SYMBOL_ORDER_CLOSEBY -> donor two-leg path (net differs by one leg while the two closes execute)");
      }
      else
      {
         const int cb = DdlCloseBy(g_ddlPB, g_ddlPS, g_ddlPV);
         if(cb > 0) { DdlPersist(); return; }   // resolved on the next tick (both legs done)
         if(cb == 0) { g_ddlNextTry = TimeCurrent() + MathMax(1, Exec_ConfirmMs / 1000); g_ddlLegTk = g_ddlPB; g_ddlLegMsc = Ex38TickMsc(); g_ddlLegVol0 = vbNow; DdlPersist(); return; }   // R1: accepted, wait for the broker ([SAFETY S03] evidence)
         g_ddlCloseByOff = true; PrintFormat("DDL COMPRESSION | close-by not completed -> donor two-leg path for this pair");
      }
   }
   if(bDone && sDone)
   {
      const double realized = AccountInfoDouble(ACCOUNT_BALANCE) - g_ddlPairBal0;
      g_ddlRealizedComp += realized; g_ddlPairsDone++;
      DdlInv w; DdlInventory(w);
      PrintFormat("DDL COMPRESSION GROUP #%d DONE | closed %.2f BUY + %.2f SELL | planned %.2f actual balance change (after costs) %.2f | equity %.2f | remaining BUY %.2f SELL %.2f net %+.2f | cumulative realised %.2f | episode debt %.2f (reference %.2f) - realising a loss is not a recovery",
                  g_ddlPairsDone, g_ddlPV, g_ddlPV, g_ddlPairPlanPL, realized, AccountInfoDouble(ACCOUNT_EQUITY), w.vb_o + w.vb_r, w.vs_o + w.vs_r,
                  (w.vb_o + w.vb_r) - (w.vs_o + w.vs_r), g_ddlRealizedComp, DdlDebt(), g_ddlRef);
      g_ddlPB = 0; g_ddlPS = 0; g_ddlPV = 0; g_ddlPairFails = 0;
      DdlSetState(DDL_COMPRESSION_PENDING, "GROUP_RESOLVED");
      return;
   }
   if(TimeCurrent() < g_ddlNextTry) return;
   if(Ex38NowMs() < g_exGraceUntil) return;   // R1: restart in the middle of a compression pair - re-read the broker first
   if(g_ddlPairFails >= DDLock_MaxAttempts)
   {
      // safe resolution: stop this pair, re-establish the lock from the actual positions
      g_ddlPB = 0; g_ddlPS = 0; g_ddlPV = 0; g_ddlPairFails = 0; g_ddlLockFails = 0;
      DdlSetState(DDL_LOCK_PENDING, StringFormat("PAIR_LEG_UNRESOLVED buyLeft=%.2f sellLeft=%.2f -> RELOCK", bLeft, sLeft));
      return;
   }
   int r;
   if(!bDone) r = (vbNow > 0.0) ? DdlCloseVolume(g_ddlPB, MathMin(bLeft, vbNow), "PAIR_BUY") : -1;
   else       r = (vsNow > 0.0) ? DdlCloseVolume(g_ddlPS, MathMin(sLeft, vsNow), "PAIR_SELL") : -1;
   if(r == 0)   // R1: accepted, not observed yet - no resend, not a failure ([SAFETY S03] until broker evidence, not only Exec_ConfirmMs)
   {
      g_ddlNextTry = TimeCurrent() + MathMax(1, Exec_ConfirmMs / 1000);
      g_ddlLegTk = !bDone ? g_ddlPB : g_ddlPS; g_ddlLegMsc = Ex38TickMsc(); g_ddlLegVol0 = !bDone ? vbNow : vsNow;
   }
   if(r < 0)
   {
      g_ddlPairFails++; g_ddlNextTry = TimeCurrent() + 5 * g_ddlPairFails;
      // a leg that vanished (closed outside this EA) cannot be completed: resolve through the lock at once
      if((!bDone && vbNow <= 0.0) || (bDone && vsNow <= 0.0)) g_ddlPairFails = DDLock_MaxAttempts;
      PrintFormat("DDL PAIR LEG NOT COMPLETED | buyLeft=%.2f sellLeft=%.2f fails=%d/%d", bLeft, sLeft, g_ddlPairFails, DDLock_MaxAttempts);
   }
   DdlPersist();
}

// ---------------------------------------------------------------- episode record
void DdlTrack()
{
   const double eq = DdlOwnEquity();
   if(eq < g_ddlEqMin || g_ddlEqMin == 0.0) g_ddlEqMin = eq;
   if(AccountInfoDouble(ACCOUNT_MARGIN) > 0.0) { const double ml = AccountInfoDouble(ACCOUNT_MARGIN_LEVEL); if(g_ddlMlMin <= 0.0 || ml < g_ddlMlMin) g_ddlMlMin = ml; }
}

void DdlEndEpisode(const string why, const bool stillOpen)
{
   if(g_ddlRowDone && !stillOpen) return;
   g_ddlRealKey = "";
   double comm, swap, prof; DdlCostsSince(g_ddlTrigTime, comm, swap, prof);
   const double debtEnd = DdlDebt(), eq = AccountInfoDouble(ACCOUNT_EQUITY), bal = AccountInfoDouble(ACCOUNT_BALANCE);
   PrintFormat("DDL EPISODE %s | %s | reference %.2f | debt at trigger %.2f -> now %.2f | since trigger: profit %.2f swap %.2f commission %.2f | compression %d groups realised %.2f | worst own equity %.2f | min margin level %.1f%% | lock attempts failed %d, LOCK_FAILED events %d",
               stillOpen ? "OPEN_AT_END" : "END", why, g_ddlRef, g_ddlDebt0, debtEnd, prof, swap, comm, g_ddlPairsDone, g_ddlRealizedComp, g_ddlEqMin, g_ddlMlMin, g_ddlLockFails, g_ddlLockFailEvents);
   if(!stillOpen) { g_ddlRowDone = true; DdlSet("rowdone", 1); }
   if(!DDLock_EpisodeLog) return;
   FolderCreate("OFH38", FILE_COMMON);
   const string f = "OFH38\\DDLOCK_EPISODES_" + _Symbol + "_" + IntegerToString((long)Magic) + ((bool)MQLInfoInteger(MQL_TESTER) ? "_TESTER" : "") + ".csv";
   const int h = FileOpen(f, FILE_READ | FILE_WRITE | FILE_TXT | FILE_ANSI | FILE_COMMON | FILE_SHARE_READ);
   if(h == INVALID_HANDLE) return;
   if(FileSize(h) == 0)
      FileWriteString(h, "episode,trigger_time,positions_at_trigger,dd_pct_at_trigger,balance_at_trigger,equity_at_trigger,floating_at_trigger,realised_before_trigger,reference,"
                         "debt_at_trigger,net_before_hedge,hedge_lots,net_after_lock,lock_confirmed_time,lock_send_failures,lock_failed_events,gross_lock,compression_groups,"
                         "compression_realised,profit_since_trigger,swap_since_trigger,commission_since_trigger,worst_own_equity,min_margin_level,end_time,end_state,end_reason,"
                         "end_balance,end_equity,remaining_debt,adopted\n");
   FileSeek(h, 0, SEEK_END);
   FileWriteString(h, StringFormat("%I64d,%s,%d,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%+.2f,%.2f,%+.2f,%s,%d,%d,%.2f,%d,%.2f,%.2f,%.2f,%.2f,%.2f,%.1f,%s,%s,%s,%.2f,%.2f,%.2f,%d\n",
                   g_ddlEpisode, TimeToString(g_ddlTrigTime, TIME_DATE | TIME_SECONDS), g_ddlN0, g_ddlDD0, g_ddlB0, g_ddlE0, g_ddlFloat0, g_ddlRealBefore, g_ddlRef,
                   g_ddlDebt0, g_ddlNetBefore, g_ddlHedgeLots, g_ddlNetAfter, g_ddlLockTime > 0 ? TimeToString(g_ddlLockTime, TIME_DATE | TIME_SECONDS) : "",
                   g_ddlLockFails, g_ddlLockFailEvents, g_ddlGrossLock, g_ddlPairsDone, g_ddlRealizedComp, prof, swap, comm, g_ddlEqMin, g_ddlMlMin,
                   TimeToString(TimeCurrent(), TIME_DATE | TIME_SECONDS), DdlStateName(g_ddlState), why, bal, eq, debtEnd, g_ddlAdopted ? 1 : 0));
   FileClose(h);
}

// ---------------------------------------------------------------- main loop while the DD Lock owns the account state
void DdlManage()
{
   if(!DdlActive()) return;
   DdlInv v; DdlInventory(v);
   const bool flat = (v.n_o == 0 && v.n_r == 0);
   RcLockPlan p; DdlPlanFromInv(v, p);
   DdlTrack();
   if(UseTimeFilter && IsNearTradingEnd())
      DdlLogOnce("SESSION_" + TimeToString(TimeCurrent(), TIME_DATE), StringFormat("DDL SESSION | final-window rule not applied: DD Lock state %s owns the basket", DdlStateName(g_ddlState)));
   switch(g_ddlState)
   {
      case DDL_LOCK_PENDING:
         if(flat) { DdlSetState(DDL_LOCKED_HOLD, "EXTERNAL_FLAT before the lock (debt still measured)"); return; }
         DdlLockStep(v);
         return;
      case DDL_LOCK_FAILED:
         if(flat) { DdlSetState(DDL_LOCKED_HOLD, "EXTERNAL_FLAT (debt still measured)"); return; }
         if(p.neutral) { DdlSetState(DDL_LOCK_CONFIRMED, "NET_FOUND_NEUTRAL"); return; }
         DdlLogOnce("LOCKFAILED_" + IntegerToString((long)g_ddlLockFailedAt), StringFormat("DDL LOCK_FAILED | basket NOT locked net=%+.2f last_rc=%u | no compression, no grid, no new L1 | retry every %d min",
                    p.net, g_ddlLastRc, DDLock_RetryMinutes));
         if(DDLock_RetryMinutes > 0 && TimeCurrent() >= g_ddlLockFailedAt + DDLock_RetryMinutes * 60) { g_ddlLockFails = 0; g_ddlNextTry = 0; DdlSetState(DDL_LOCK_PENDING, "RETRY_TIMER"); }
         return;
      case DDL_LOCK_CONFIRMED:
         if(!p.neutral) { DdlSetState(DDL_LOCK_PENDING, StringFormat("NET_DRIFT net=%+.2f", p.net)); return; }
         if(flat) { DdlSetState(DDL_LOCKED_HOLD, "EXTERNAL_FLAT (debt still measured)"); return; }
         if(g_ddlLockTime == 0)
         {
            g_ddlLockTime = TimeCurrent(); g_ddlNetAfter = p.net; g_ddlHedgeLots = v.vb_r + v.vs_r; g_ddlGrossLock = v.vb_o + v.vb_r + v.vs_o + v.vs_r;
            PrintFormat("DDL LOCK VERIFIED | net %+.2f -> %+.2f | hedge lots %.2f | gross %.2f | equity %.2f | episode debt %.2f (reference %.2f)", g_ddlNetBefore, p.net,
                        g_ddlHedgeLots, g_ddlGrossLock, AccountInfoDouble(ACCOUNT_EQUITY), DdlDebt(), g_ddlRef);
            DdlPersist();
         }
         if(!DdlOriginalStopsClear())   // only now remove the original SL / TP (a one-sided stop would break the lock)
         {
            if(TimeCurrent() < g_ddlNextTry) return;
            DdlClearOriginalStops();
            if(!DdlOriginalStopsClear()) { g_ddlNextTry = TimeCurrent() + 5; DdlLogOnce("STOPS_" + IntegerToString(g_ddlEpisode), "DDL LOCK_CONFIRMED | original SL/TP not removed yet - lock kept, compression waits (retry every 5 s)"); return; }
            Print("DDL LOCK_CONFIRMED | original SL/TP removed after the confirmed net-neutral lock");
         }
         DdlSetState(DDLock_EnableCompression ? DDL_COMPRESSION_PENDING : DDL_COMPRESSION_COMPLETE, "LOCK_CONFIRMED");
         return;
      case DDL_COMPRESSION_PENDING:
         if(flat) { DdlSetState(DDL_COMPRESSION_COMPLETE, "ALL_PAIRS_CLOSED_FLAT"); return; }
         DdlCompressionPlan(v);
         return;
      case DDL_COMPRESSION_ACTIVE:
         DdlPairStep();
         return;
      case DDL_COMPRESSION_COMPLETE:
      {
         double comm, swap, prof; DdlCostsSince(g_ddlTrigTime, comm, swap, prof);
         PrintFormat("DDL COMPRESSION COMPLETE | groups=%d realised %.2f | gross %.2f -> %.2f | equity %.2f | since trigger: swap %.2f commission %.2f | episode debt %.2f (%.2f%% of reference %.2f) remains - compression moves floating loss into the balance, it does not recover DD",
                     g_ddlPairsDone, g_ddlRealizedComp, g_ddlGrossLock, v.vb_o + v.vb_r + v.vs_o + v.vs_r, AccountInfoDouble(ACCOUNT_EQUITY), swap, comm,
                     DdlDebt(), g_ddlRef > 0.0 ? DdlDebt() / g_ddlRef * 100.0 : 0.0, g_ddlRef);
         DdlSetState(DDL_LOCKED_HOLD, "COMPRESSION_COMPLETE");
         return;
      }
      case DDL_LOCKED_HOLD:
         if(!flat && !p.neutral) { DdlSetState(DDL_LOCK_PENDING, StringFormat("NET_DRIFT net=%+.2f", p.net)); return; }
         if(flat)
         {
            DdlEndEpisode("FLAT_DEBT_UNRECOVERED", false);
            DdlSetState(DDL_HALT, StringFormat("basket flat, episode debt %.2f - no new cycle unless the flat basket is a verified Owner full manual close (DPMR R1 D04: basket + hedge closed by hand, no stop-out / EA / SL / TP close); otherwise OWNER_DECISION_REQUIRED", DdlDebt()));   // [SAFETY S04] text only; [DPMR R1] text
            ResetCycleState();   // the basket's cycle is over: V26 cycle fields, rescue flag and GLOBAL group state of the flat basket are cleared
            return;
         }
         DdlLogOnce("HOLD_" + TimeToString(TimeCurrent(), TIME_DATE), StringFormat("DDL LOCKED_HOLD | net %+.2f (locked) | basket n=%d hedge n=%d gross %.2f | floating %.2f | episode debt %.2f (reference %.2f) | close cost est. %.2f | awaiting owner-approved Recovery; no unlock, no grid, no new L1",
                    p.net, v.n_o, v.n_r, v.vb_o + v.vb_r + v.vs_o + v.vs_r, v.pl_o + v.pl_r, DdlDebt(), g_ddlRef, DdlCloseCost()));
         return;
      case DDL_HALT:
         if(!flat)
         {
            if(!p.neutral) { DdlSetState(DDL_LOCK_PENDING, StringFormat("POSITIONS_DURING_HALT net=%+.2f -> lock", p.net)); return; }
            DdlLogOnce("HALTPOS_" + TimeToString(TimeCurrent(), TIME_DATE), StringFormat("DDL HALT | net-neutral positions present (n=%d) - left untouched, no grid / no new L1", v.n_o + v.n_r));
            return;
         }
         if(g_ddlAckEpisode == g_ddlEpisode && g_ddlEpisode != 0)
         {
            PrintFormat("DDL OWNER ACK | episode %I64d acknowledged (DDLock_OwnerAckResume at init) | remaining debt %.2f stays in the episode log | normal trading resumes", g_ddlEpisode, DdlDebt());
            DdlSetState(DDL_NORMAL, "OWNER_ACK_RESUME");
            DdlClearPersist();
            g_ddlEpisode = 0; g_ddlPB = 0; g_ddlPS = 0; g_ddlOnce = "";
            ResetCycleState();
            return;
         }
         // [DPMR R1] D04: the Owner closed the whole basket AND its hedge by hand -> after broker-flat + reconciliation the HALT of this episode is released
         if(DpmrDdHaltReleaseCheck()) return;
         DdlLogOnce("HALT_" + TimeToString(TimeCurrent(), TIME_DATE), StringFormat("DDL HALT | episode %I64d debt %.2f unrecovered | flat | no new L1 / Grid: the only release is a verified Owner full manual close (DPMR R1 D04, last verdict %s); DDLock_OwnerAckResume = internal constant %s, not an input - OWNER_DECISION_REQUIRED (DD release policy)",
                    g_ddlEpisode, DdlDebt(), g_dpmrDdLastVerdict < 0 ? "not evaluated yet" : Ddr38Name(g_dpmrDdLastVerdict), DDLock_OwnerAckResume ? "true" : "false"));   // [SAFETY S04] the HOTFIX text named an input that does not exist; [DPMR R1] text
         return;
   }
}

// deals of Magic / DDLock_HedgeMagic while the DD Lock owns the basket (the V26 manual-close / T1-T2 / TP handlers do not run)
void DdlOnDeal(const ulong deal)
{
   if(!HistoryDealSelect(deal)) return;
   const long entry = HistoryDealGetInteger(deal, DEAL_ENTRY);
   if(entry != DEAL_ENTRY_OUT && entry != DEAL_ENTRY_INOUT) return;
   const long reason = HistoryDealGetInteger(deal, DEAL_REASON);
   if(reason == DEAL_REASON_CLIENT || reason == DEAL_REASON_MOBILE || reason == DEAL_REASON_WEB || reason == DEAL_REASON_SO || reason == DEAL_REASON_SL || reason == DEAL_REASON_TP)
      PrintFormat("DDL EXTERNAL DEAL | deal=%I64u magic=%I64u reason=%d vol=%.2f - next tick re-reads the broker (re-lock if the net drifted)",
                  deal, (ulong)HistoryDealGetInteger(deal, DEAL_MAGIC), (int)reason, HistoryDealGetDouble(deal, DEAL_VOLUME));
}

void DdlInitTrade()
{
   ddlTrade.SetExpertMagicNumber(DDLock_HedgeMagic);
   ddlTrade.SetAsyncMode(false);
   ddlTrade.SetDeviationInPoints(DDLock_DeviationPoints);
   ddlTrade.SetTypeFilling(DdlFilling());
}

// restart: restore the persisted episode; orphan hedge positions without a record -> LOCK_PENDING (safe re-lock, B0 := current balance, flagged ADOPTED)
void DdlRestore()
{
   g_ddlState = DDL_NORMAL;
   g_ddlInflightOrder = 0; g_ddlInflightMs = 0;   // R1: after a restart the broker positions decide (no in-flight memory survives)
   g_ddlInflightTickMsc = 0; g_ddlInflightWm = 0; g_ddlLegTk = 0; g_ddlLegMsc = 0; g_ddlLegVol0 = 0.0;   // [SAFETY S03] (re-init keeps globals): reloaded from the record below
   const string ns = DdlNs();
   int st = (int)DdlGet("state", DDL_NORMAL);
   bool mismatch = false;
   if(st != DDL_NORMAL && (OfhIdCheck(ns, Magic) != "" || (ulong)DdlGet("hedgemagic") != DDLock_HedgeMagic))
   {
      PrintFormat("DDL EPISODE RECORD %s IGNORED | identity / DDLock_HedgeMagic mismatch", ns);
      st = DDL_NORMAL; mismatch = true;
   }
   DdlInv v; DdlInventory(v);
   if(st != DDL_NORMAL)
   {
      g_ddlState = st; g_ddlEpisode = (long)DdlGet("episode"); g_ddlTrigTime = (datetime)DdlGet("trigtime");
      g_ddlB0 = DdlGet("b0"); g_ddlE0 = DdlGet("e0"); g_ddlFloat0 = DdlGet("float0"); g_ddlDD0 = DdlGet("dd0"); g_ddlThr0 = DdlGet("thr0");
      g_ddlVB0 = DdlGet("vb0"); g_ddlVS0 = DdlGet("vs0"); g_ddlMargin0 = DdlGet("margin0"); g_ddlN0 = (int)DdlGet("n0");
      g_ddlFirstPx0 = DdlGet("firstpx0"); g_ddlFirstType0 = (int)DdlGet("firsttype0", -1);
      g_ddlRef = DdlGet("ref"); g_ddlRealBefore = DdlGet("realbefore"); g_ddlDebt0 = DdlGet("debt0"); g_ddlBasketStart = (datetime)DdlGet("bstart");
      g_ddlHedgeSent = DdlGet("hedgesent") > 0.5; g_ddlAdopted = DdlGet("adopted") > 0.5; g_ddlLockFails = (int)DdlGet("lockfails"); g_ddlLockFailEvents = (int)DdlGet("lockfailevents");
      g_ddlLockFailedAt = (datetime)DdlGet("lockfailedat"); g_ddlLockTime = (datetime)DdlGet("locktime");
      g_ddlHedgeLots = DdlGet("hedgelots"); g_ddlNetBefore = DdlGet("netbefore"); g_ddlNetAfter = DdlGet("netafter"); g_ddlGrossLock = DdlGet("grosslock");
      g_ddlRealizedComp = DdlGet("realizedcomp"); g_ddlPairsDone = (int)DdlGet("pairs");
      g_ddlPB = (ulong)DdlGet("pb"); g_ddlPS = (ulong)DdlGet("ps"); g_ddlPV = DdlGet("pv"); g_ddlPBBefore = DdlGet("pbbefore"); g_ddlPSBefore = DdlGet("psbefore");
      g_ddlPairPlanPL = DdlGet("pairplanpl"); g_ddlPairBal0 = DdlGet("pairbal0"); g_ddlPairFails = (int)DdlGet("pairfails");
      g_ddlEqMin = DdlGet("eqmin"); g_ddlMlMin = DdlGet("mlmin"); g_ddlRowDone = DdlGet("rowdone") > 0.5;
      g_ddlNextTry = 0; g_ddlLastSend = 0; g_ddlOnce = ""; g_ddlRealKey = "";
      // [SAFETY S03] a hedge request sent before the restart without a broker result is resolved by broker evidence (HOTFIX: in-flight memory dropped at restart)
      g_ddlInflightOrder = (ulong)DdlGet("ifo"); g_ddlInflightTickMsc = (long)DdlGet("ifm"); g_ddlInflightWm = (ulong)DdlGet("ifw"); g_ddlInflightMs = Ex38NowMs();
      g_ddlLegTk = (ulong)DdlGet("lpt"); g_ddlLegMsc = (long)DdlGet("lpm"); g_ddlLegVol0 = DdlGet("lpv");
      if(g_ddlFirstPx0 > 0.0 && FirstPrice <= 0.0) { FirstPrice = g_ddlFirstPx0; FirstType = g_ddlFirstType0; }
      if(g_ddlState == DDL_HALT && DDLock_OwnerAckResume) g_ddlAckEpisode = g_ddlEpisode;   // explicit Owner acknowledgement seen at (re-)initialisation
      if(((g_ddlState == DDL_LOCK_PENDING || g_ddlState == DDL_LOCK_FAILED) && g_ddlHedgeSent) || g_ddlState == DDL_COMPRESSION_ACTIVE) Ex38RestartGrace("DD Lock " + DdlStateName(g_ddlState));
      PrintFormat("DDL RESTORED | state=%s episode %I64d DD0=%.2f%% pairs=%d pendingPair=%I64u/%I64u vol=%.2f | broker now: basket n=%d hedge n=%d net=%+.2f | reference %.2f debt %.2f | ack=%s",
                  DdlStateName(g_ddlState), g_ddlEpisode, g_ddlDD0, g_ddlPairsDone, g_ddlPB, g_ddlPS, g_ddlPV, v.n_o, v.n_r, (v.vb_o + v.vb_r) - (v.vs_o + v.vs_r),
                  g_ddlRef, DdlDebt(), g_ddlAckEpisode == g_ddlEpisode ? "OWNER_ACK" : "no");
   }
   else if(v.n_r > 0)
   {
      g_ddlEpisode = (long)TimeCurrent(); g_ddlTrigTime = TimeCurrent(); g_ddlB0 = AccountInfoDouble(ACCOUNT_BALANCE); g_ddlE0 = AccountInfoDouble(ACCOUNT_EQUITY);
      g_ddlFloat0 = v.pl_o + v.pl_r; g_ddlVB0 = v.vb_o; g_ddlVS0 = v.vs_o; g_ddlN0 = v.n_o; g_ddlAdopted = true; g_ddlFirstPx0 = FirstPrice; g_ddlFirstType0 = FirstType;
      g_ddlBasketStart = DdlBasketStartTime(); g_ddlRealBefore = DdlRealisedSince(g_ddlBasketStart); g_ddlRef = g_ddlB0 - g_ddlRealBefore; g_ddlDebt0 = DdlDebt();
      g_ddlNetBefore = (v.vb_o + v.vb_r) - (v.vs_o + v.vs_r);
      g_ddlState = DDL_NORMAL;
      DdlSetState(DDL_LOCK_PENDING, StringFormat("ORPHAN_HEDGE_POSITIONS n=%d (no valid record: B0 := current balance, flagged ADOPTED)", v.n_r));
   }
   else if(!mismatch) DdlClearPersist();
   if((ENUM_ACCOUNT_MARGIN_MODE)AccountInfoInteger(ACCOUNT_MARGIN_MODE) != ACCOUNT_MARGIN_MODE_RETAIL_HEDGING)
      Print("DDL WARNING: NETTING account - a DD trigger cannot be hedged and ends in LOCK_FAILED (no automatic close).");
}

#endif
// [FINAL STANDALONE] ===== END INLINED OFH38_DDLock.mqh =====
// [FINAL STANDALONE] ===== BEGIN INLINED OFH38_CycleState.mqh (HOTFIX SHA256 9F0E33DBB89E5A25997D51D42F36CEB1E7ACC9F2B940E4B1AD732FD981567CBA) — included from Onefxhub_v38.38_RPA.mq5:L307 =====
// OFH38_CycleState.mqh — V38 R1: lưu bền các biến chu kỳ mà V26 chỉ giữ trong bộ nhớ (khởi động lại EA → mất, xem V38_V26_INHERITED_DEFECTS):
//   FirstPrice / FirstType (V26 lấy lại từ lệnh mở sớm nhất — sai nếu L1 đã bị chốt tay rồi vào lại), basketModeLatched,
//   chống gửi trùng (LastSent*), chờ phiên sau (WaitNextSession / WaitUntilTime),
//   T1/T2 (t1Locked, t1Dir, t2Armed, hedgeTrailActive, hedge*) — V26 mất khóa T1 / trailing T2 → Grid / PairClose chạy lại trên cụm đang có SL/TP thoát,
//   xác nhận 2 lần (DblConfirm*) — V26 phải chạm → rời → chạm lại từ đầu,
//   chờ vào lại sau chốt tay (manualWait*) — V26 quên lệnh vừa chốt tay → Grid thêm level sai,
//   R1: chân PairClose đã quyết định nhưng chưa đóng (g_pairPend*), cờ chốt tay MỘT PHẦN (g_cycIndexShift), giờ khớp L1 của chu kỳ (lãi/lỗ kinh tế).
// Lưu khi có thay đổi (so sánh cuối mỗi OnTick / OnTradeTransaction), ghi đĩa ngay khi đổi giai đoạn. Khôi phục khi bản ghi đúng tài khoản /
// server / symbol / Magic VÀ thuộc cụm đang mở (ít nhất một ticket đã ghi vẫn còn mở; cụm phẳng: chỉ trạng thái chờ phiên). Không khớp → giữ
// cách khôi phục của V26 và ghi log. V26State_Persist=false → như V26.
// V38 R2: chờ vào lại sau chốt tay KHÔNG còn ở đây (manualWait đơn của V26 đã thay bằng hàng chờ nhiều bản ghi, OFH38_ManualRecovery — bản ghi
// riêng); thêm giờ bắt đầu của chân PairClose dở (cảnh báo kéo dài) và cờ "bản ghi chu kỳ đã khôi phục" (bằng chứng cấp sau khởi động lại).
// V38 R3: xác nhận 2 lần của Grid được kiểm với cấp kế của SỔ CẤP sau khi sổ được khôi phục (CycDblConfirmCheck).
// RPA V1-R2: + cờ t1OneSide (T1 / T2 đang giữ Lk* đơn của epoch tập con), khóa "t1s"; bản ghi cũ không có khóa = khóa hai phía.
#ifndef OFH38_CYCLESTATE_MQH
#define OFH38_CYCLESTATE_MQH

long     g_cycStartMsc   = 0;          // giờ khớp L1 của chu kỳ (msc)
ulong    g_pairPend1     = 0, g_pairPend2 = 0;
bool     g_cycIndexShift = false;
long     g_pairPendSinceMsc = 0;       // R2: giờ tick chân PairClose bắt đầu dở
bool     g_cycRestoredOk = false;      // R2: bản ghi chu kỳ của cụm đang mở đã được khôi phục ở lần khởi động này

struct CycSnap
{
   double   firstPrice; int firstType; bool latched;
   ulong    lastSentOrder; long lastSentTime; int lastSentCount;
   bool     waitNext; long waitUntil;
   int      dblNum; bool dblHit1; bool dblReady;
   bool     trailActive; double bePx; double exitPx; double clusterBe; double t1Trig; double lockMoney; int trailDir;
   bool     t1; int t1d; bool t2; bool t1one;
   long     startMsc; ulong pp1; ulong pp2; bool shift; long ppSince;
   int      n;
};
CycSnap g_cycLast;
bool    g_cycHave = false;
int     g_cycTkN  = -1;    // số ticket đã ghi lần trước

string CycNs() { return OfhNs("OFH38C", Magic); }

long CycStartMsc()
{
   if(g_cycStartMsc > 0) return g_cycStartMsc;
   long m = 0;
   for(int i = 0; i < PositionsTotal(); i++)
   {
      const ulong t = PositionGetTicket(i);
      if(t == 0 || !PositionSelectByTicket(t) || !IsOursPos()) continue;
      const long pt = PositionGetInteger(POSITION_TIME_MSC);
      if(m == 0 || pt < m) m = pt;
   }
   return m;
}

void CycTake(CycSnap &s)
{
   s.firstPrice = FirstPrice; s.firstType = FirstType; s.latched = basketModeLatched;
   s.lastSentOrder = LastSentOrder; s.lastSentTime = (long)LastSentTime; s.lastSentCount = LastSentCount;
   s.waitNext = WaitNextSession; s.waitUntil = (long)WaitUntilTime;
   s.dblNum = DblConfirmNum; s.dblHit1 = DblConfirmHit1; s.dblReady = DblConfirmReady;
   s.trailActive = hedgeTrailActive; s.bePx = hedgeBePrice; s.exitPx = hedgeExitPrice; s.clusterBe = hedgeClusterBe; s.t1Trig = hedgeT1Trigger; s.lockMoney = hedgeLockMoney; s.trailDir = hedgeTrailDir;
   s.t1 = t1Locked; s.t1d = t1Dir; s.t2 = t2Armed; s.t1one = t1OneSide;
   s.n = CountPositions();
   s.startMsc = (s.n > 0) ? CycStartMsc() : 0; s.pp1 = g_pairPend1; s.pp2 = g_pairPend2; s.shift = g_cycIndexShift; s.ppSince = g_pairPendSinceMsc;
}
// giai đoạn đổi → ghi đĩa ngay (giá thoát T2 đổi mỗi tick: chỉ giữ trong biến toàn cục của terminal)
bool CycStageDiff(const CycSnap &a, const CycSnap &b)
{
   return a.t1 != b.t1 || a.t2 != b.t2 || a.t1one != b.t1one || a.trailActive != b.trailActive || a.dblNum != b.dblNum || a.dblHit1 != b.dblHit1 || a.dblReady != b.dblReady ||
          a.waitNext != b.waitNext || a.pp1 != b.pp1 || a.pp2 != b.pp2 || a.shift != b.shift || a.n != b.n || a.latched != b.latched || a.lastSentCount != b.lastSentCount ||
          a.firstType != b.firstType || a.startMsc != b.startMsc;
}
bool CycSame(const CycSnap &a, const CycSnap &b)
{
   if(CycStageDiff(a, b)) return false;
   return a.firstPrice == b.firstPrice && a.lastSentOrder == b.lastSentOrder && a.lastSentTime == b.lastSentTime && a.waitUntil == b.waitUntil &&
          a.bePx == b.bePx && a.exitPx == b.exitPx && a.clusterBe == b.clusterBe && a.t1Trig == b.t1Trig && a.lockMoney == b.lockMoney && a.trailDir == b.trailDir &&
          a.t1d == b.t1d && a.ppSince == b.ppSince;
}
bool CycIsDefault(const CycSnap &s) { return s.n <= 0 && !s.waitNext && s.pp1 == 0 && s.pp2 == 0; }

void CycClearPersist() { g_cycTkN = -1; if(GlobalVariablesDeleteAll(CycNs()) > 0) GlobalVariablesFlush(); }

void CycPersistIfChanged()
{
   if(!V26State_Persist) return;
   if(DdlActive()) return;   // DD Lock nắm cụm: bản ghi chu kỳ không đổi (DD có bản ghi riêng)
   CycSnap s; CycTake(s);
   if(g_cycHave && CycSame(s, g_cycLast)) return;
   const bool stage = !g_cycHave || CycStageDiff(s, g_cycLast);
   g_cycLast = s; g_cycHave = true;
   if(CycIsDefault(s)) { CycClearPersist(); return; }
   const string ns = CycNs();
   GlobalVariableSet(ns + "fp", s.firstPrice); GlobalVariableSet(ns + "ft", s.firstType); GlobalVariableSet(ns + "lat", s.latched ? 1 : 0);
   GlobalVariableSet(ns + "lso", (double)s.lastSentOrder); GlobalVariableSet(ns + "lst", (double)s.lastSentTime); GlobalVariableSet(ns + "lsc", s.lastSentCount);
   GlobalVariableSet(ns + "wn", s.waitNext ? 1 : 0); GlobalVariableSet(ns + "wu", (double)s.waitUntil);
   GlobalVariableSet(ns + "dn", s.dblNum); GlobalVariableSet(ns + "dh", s.dblHit1 ? 1 : 0); GlobalVariableSet(ns + "dr", s.dblReady ? 1 : 0);
   GlobalVariableSet(ns + "ta", s.trailActive ? 1 : 0); GlobalVariableSet(ns + "be", s.bePx); GlobalVariableSet(ns + "ex", s.exitPx); GlobalVariableSet(ns + "cb", s.clusterBe);
   GlobalVariableSet(ns + "tt", s.t1Trig); GlobalVariableSet(ns + "lm", s.lockMoney); GlobalVariableSet(ns + "td", s.trailDir);
   GlobalVariableSet(ns + "t1", s.t1 ? 1 : 0); GlobalVariableSet(ns + "t1d", s.t1d); GlobalVariableSet(ns + "t2", s.t2 ? 1 : 0);
   GlobalVariableSet(ns + "t1s", s.t1one ? 1 : 0);   // RPA V1-R2: the T1 lock holds the lone Lk* (one side)
   GlobalVariableSet(ns + "st", (double)s.startMsc); GlobalVariableSet(ns + "pp1", (double)s.pp1); GlobalVariableSet(ns + "pp2", (double)s.pp2); GlobalVariableSet(ns + "sh", s.shift ? 1 : 0);
   GlobalVariableSet(ns + "pps", (double)s.ppSince);
   if(s.n != g_cycTkN)   // danh sách ticket của cụm (nhận diện cụm khi khởi động lại)
   {
      int k = 0;
      for(int i = 0; i < PositionsTotal() && k < 40; i++)
      {
         const ulong t = PositionGetTicket(i);
         if(t == 0 || !PositionSelectByTicket(t) || !IsOursPos()) continue;
         GlobalVariableSet(ns + "k" + IntegerToString(k), (double)t); k++;
      }
      GlobalVariableSet(ns + "nk", k);
      g_cycTkN = s.n;
   }
   GlobalVariableSet(ns + "n", s.n);
   OfhIdStore(ns, Magic);
   if(stage) GlobalVariablesFlush();
}

// khởi động lại (sau cách khôi phục của V26 trong RestoreState): ghi đè bằng bản ghi nếu bản ghi thuộc cụm đang mở
void CycRestore()
{
   g_cycHave = false; g_cycTkN = -1;
   g_cycStartMsc = 0; g_pairPend1 = 0; g_pairPend2 = 0; g_cycIndexShift = false; g_pairPendSinceMsc = 0; g_cycRestoredOk = false;
   if(!V26State_Persist) return;
   const string ns = CycNs();
   if(!GlobalVariableCheck(ns + "n")) { if(CountPositions() > 0) Print("V26 CYCLE STATE | no record for the open basket - V26 restore only (T1/T2, double confirmation, manual re-entry wait start empty)"); return; }
   const string idWhy = OfhIdCheck(ns, Magic);
   const int nNow = CountPositions(), nRec = (int)GlobalVariableGet(ns + "n");
   bool match = (idWhy == "");
   int still = 0;
   if(match)
   {
      if(nRec <= 0) match = (nNow <= 0);
      else
      {
         const int nk = (int)GlobalVariableGet(ns + "nk");
         for(int k = 0; k < nk; k++) if(OfhTicketIsOurs((ulong)GlobalVariableGet(ns + "k" + IntegerToString(k)), Magic)) still++;
         match = (still > 0);
      }
   }
   if(!match)
   {
      PrintFormat("V26 CYCLE STATE record ignored | identity=%s | recorded positions %d, now %d, recorded tickets still open %d - V26 restore only", idWhy == "" ? "ok" : idWhy, nRec, nNow, still);
      CycClearPersist();
      return;
   }
   FirstPrice = GlobalVariableGet(ns + "fp"); FirstType = (int)GlobalVariableGet(ns + "ft"); basketModeLatched = GlobalVariableGet(ns + "lat") > 0.5;
   LastSentOrder = (ulong)GlobalVariableGet(ns + "lso"); LastSentTime = (datetime)GlobalVariableGet(ns + "lst"); LastSentCount = (int)GlobalVariableGet(ns + "lsc");
   WaitNextSession = GlobalVariableGet(ns + "wn") > 0.5; WaitUntilTime = (datetime)GlobalVariableGet(ns + "wu");
   DblConfirmNum = (int)GlobalVariableGet(ns + "dn"); DblConfirmHit1 = GlobalVariableGet(ns + "dh") > 0.5; DblConfirmReady = GlobalVariableGet(ns + "dr") > 0.5;
   hedgeTrailActive = GlobalVariableGet(ns + "ta") > 0.5; hedgeBePrice = GlobalVariableGet(ns + "be"); hedgeExitPrice = GlobalVariableGet(ns + "ex"); hedgeClusterBe = GlobalVariableGet(ns + "cb");
   hedgeT1Trigger = GlobalVariableGet(ns + "tt"); hedgeLockMoney = GlobalVariableGet(ns + "lm"); hedgeTrailDir = (int)GlobalVariableGet(ns + "td");
   t1Locked = GlobalVariableGet(ns + "t1") > 0.5; t1Dir = (int)GlobalVariableGet(ns + "t1d"); t2Armed = GlobalVariableGet(ns + "t2") > 0.5;
   t1OneSide = GlobalVariableCheck(ns + "t1s") && GlobalVariableGet(ns + "t1s") > 0.5;   // RPA V1-R2 (absent in an older record = a two-side lock)
   g_cycStartMsc = (long)GlobalVariableGet(ns + "st"); g_pairPend1 = (ulong)GlobalVariableGet(ns + "pp1"); g_pairPend2 = (ulong)GlobalVariableGet(ns + "pp2");
   g_cycIndexShift = GlobalVariableGet(ns + "sh") > 0.5; g_pairPendSinceMsc = (long)GlobalVariableGet(ns + "pps");
   // trạng thái phải còn đúng với broker (R3: xác nhận 2 lần của Grid kiểm sau khi sổ cấp được khôi phục — CycDblConfirmCheck)
   if(g_pairPend1 != 0 && !OfhTicketIsOurs(g_pairPend1, Magic)) g_pairPend1 = 0;
   if(g_pairPend2 != 0 && !OfhTicketIsOurs(g_pairPend2, Magic)) g_pairPend2 = 0;
   if(g_pairPend1 == 0 && g_pairPend2 == 0) g_pairPendSinceMsc = 0;
   if(nNow <= 0) { FirstPrice = 0; FirstType = -1; basketModeLatched = false; t1Locked = false; t2Armed = false; hedgeTrailActive = false; t1OneSide = false; g_cycStartMsc = 0; }
   OrderCount = nNow;
   g_cycRestoredOk = (nNow > 0);
   if(g_pairPend1 != 0 || g_pairPend2 != 0) Ex38RestartGrace("PairClose leg pending");
   PrintFormat("V26 CYCLE STATE RESTORED | positions %d (recorded %d, %d recorded tickets open) | FirstPrice %.2f type %d latched %d | T1 %d dir %d T2 %d one-side %d exit %.5f floor %.5f | DblConfirm L%d hit1 %d ready %d | pending pair %I64u/%I64u since %I64d | partial-close shift %d | wait next session %d",
               nNow, nRec, still, FirstPrice, FirstType, basketModeLatched ? 1 : 0, t1Locked ? 1 : 0, t1Dir, t2Armed ? 1 : 0, t1OneSide ? 1 : 0, hedgeExitPrice, hedgeBePrice,
               DblConfirmNum, DblConfirmHit1 ? 1 : 0, DblConfirmReady ? 1 : 0, g_pairPend1, g_pairPend2, g_pairPendSinceMsc, g_cycIndexShift ? 1 : 0, WaitNextSession ? 1 : 0);
   CycTake(g_cycLast); g_cycHave = true;
}
// V38 R3: the Grid double confirmation in progress is kept only for the NEXT grid level (V26: positions + 1; level book once the basket had a manual close)
void CycDblConfirmCheck()
{
   if(DblConfirmNum == 0) return;
   // OWNER12 (sửa lỗi lộ ra khi ConfirmFromOrder = 19): cấp kế = cùng công thức với OnTick P11 (sổ cấp + offset cấp ảo của Progressive PairClose sau rebase);
   // PAIRA_LOOP gọi hàm này trước PaRestore và không cộng offset → khởi động lại trong Grid đã rebase làm mất tiến trình xác nhận 2 lần của cấp kế.
   const int want = RpaConfirmNextLevel(CountPositions());   // RPA: same formula as OnTick P11 (subgrid: virtual level L(k + additional + 1)*; original grid: level book)
   if(DblConfirmNum == want) return;
   PrintFormat("V26 CYCLE STATE | double confirmation of L%d dropped at restart: the next grid level is L%d", DblConfirmNum, want);
   DblConfirmNum = 0; DblConfirmHit1 = false; DblConfirmReady = false;
}

#endif
// [FINAL STANDALONE] ===== END INLINED OFH38_CycleState.mqh =====
// [FINAL STANDALONE] ===== BEGIN INLINED OFH38_LevelBook.mqh (HOTFIX SHA256 8E9B911551AAC96734AF735A0669E3367ED91BEF4A6346BEF23264FCB4AA23D3) — included from Onefxhub_v38.38_RPA.mq5:L308 =====
// OFH38_LevelBook.mqh — V38 R3: SỔ CẤP TỐI THIỂU của cụm (chỉ thị Owner R3 mục D / E, X09). Luật thuần: OFH38_LevelBook_Core.mqh.
// V26 / R2 lấy cấp Grid = số ticket còn mở + 1. Sau khi khách đóng tay (đóng hết, đóng một phần rồi vào lại thành ticket thêm, hoặc đợt 2+ vị thế không
// khôi phục) số ticket không còn bằng chỉ số cấp → R2 khóa Grid. R3 giữ cấp gốc của từng vị thế đang mở bằng SỰ KIỆN đã xác nhận:
//   * chưa có đóng tay trong chu kỳ: sổ = thứ hạng theo giờ mở (đúng quy ước đếm của V26), cấp kế = số lệnh + 1 → Grid y hệt V26 / R2 (parity);
//   * từ deal đóng tay đầu tiên của chu kỳ: sổ BẬT, cập nhật theo sự kiện — lệnh Grid đã gửi (order = POSITION_IDENTIFIER) → cấp đã gửi; lệnh vào lại
//     (nhãn R2MR|<deal>|) → cấp của bản ghi; vị thế rời cụm → khỏi sổ (giữ trong vòng "vừa rời" để tra cấp cho deal đóng tay xử lý muộn);
//     vị thế lạ (không chứng minh được cấp) → khóa Grid (BLOCKER). Cấp đã bỏ (đợt 2+ / ManualReentry_Enable=false, đóng hết) → không bao giờ mở lại
//     trong chu kỳ.
//   * cấp kế = cấp nhỏ nhất > max(cấp đang mở, cấp đang giữ chỗ của bản ghi khôi phục) và không phải cấp đã bỏ. Lot = CalcLot(cấp−1), chiều GetNextType(cấp),
//     trigger GetTrigger / GgTrigger(cấp), GLOBAL GgSync(cấp−1). PairClose giữ nguyên V26 (2 ticket mở muộn nhất); sổ theo dõi vị thế nào thực sự rời cụm.
// Lưu bền theo tài khoản / server / symbol / Magic + chu kỳ (giờ khớp L1); không phụ thuộc V26State_Persist. Khôi phục: đối chiếu với vị thế đang mở.
#ifndef OFH38_LEVELBOOK_MQH
#define OFH38_LEVELBOOK_MQH

// [FINAL STANDALONE] ===== BEGIN INLINED OFH38_LevelBook_Core.mqh (HOTFIX SHA256 31A8DAA2F89CC7000450B5C581017D83A9B26B0B66FDBC2040FDCFF6EBD5377E) — included from OFH38_LevelBook.mqh:L15 =====
// OFH38_LevelBook_Core.mqh — V38 R3: luật THUẦN của sổ cấp tối thiểu (không gọi terminal) — unit test trong OFH38_UnitTests.mq5.
// Cấp kế tiếp của Grid khi số ticket còn mở không còn bằng chỉ số cấp (đóng tay / vào lại / bỏ qua đợt 2+ vị thế):
//   cấp kế = cấp nhỏ nhất L > max(cấp các vị thế đang mở, cấp đang giữ chỗ của bản ghi khôi phục) mà L KHÔNG phải cấp đã bỏ (đóng tay, không khôi phục).
// Không có đóng tay trong chu kỳ: cấp = thứ hạng theo giờ mở (quy ước đếm lệnh của V26) → cấp kế = số lệnh + 1, đúng như V26.
#ifndef OFH38_LEVELBOOK_CORE_MQH
#define OFH38_LEVELBOOK_CORE_MQH

#define LB38_MAX   64     // vị thế trong sổ tối đa (Max_Orders + vé vào lại)
#define LB38_GRAVE 16     // vị thế vừa rời cụm (tra cấp cho deal đóng tay xử lý muộn)

bool Lb38In(const int &a[], const int n, const int v) { for(int i = 0; i < n; i++) if(a[i] == v) return true; return false; }

// cấp kế tiếp của Grid
int Lb38Next(const int &openLv[], const int nOpen, const int &resLv[], const int nRes, const int &abLv[], const int nAb)
{
   int top = 0;
   for(int i = 0; i < nOpen; i++) if(openLv[i] > top) top = openLv[i];
   for(int i = 0; i < nRes; i++)  if(resLv[i] > top) top = resLv[i];
   int L = top + 1;
   for(int guard = 0; guard <= LB38_MAX && Lb38In(abLv, nAb, L); guard++) L++;
   return L;
}

// thứ hạng theo giờ mở (msc; trùng giờ thì ticket nhỏ trước) → cấp 1..n (quy ước của V26)
void Lb38Rank(const long &msc[], const ulong &id[], const int n, int &lv[])
{
   ArrayResize(lv, n);
   for(int i = 0; i < n; i++)
   {
      int r = 1;
      for(int j = 0; j < n; j++) if(j != i && (msc[j] < msc[i] || (msc[j] == msc[i] && id[j] < id[i]))) r++;
      lv[i] = r;
   }
}

#endif
// [FINAL STANDALONE] ===== END INLINED OFH38_LevelBook_Core.mqh =====
// [FINAL STANDALONE] #include "OFH38_ManualRecovery_Core.mqh" — already inlined above; the original include guard made this include a no-op

#define LBK_GRID     0    // L1 / lệnh Grid (cấp đã gửi hoặc thứ hạng V26)
#define LBK_RECOVERY 1    // lệnh vào lại (vé thêm cùng cấp khi đóng một phần)
#define LBK_UNKNOWN  2    // không chứng minh được cấp → Grid khóa

ulong  g_lbId[]; int g_lbLv[]; int g_lbKind[]; int g_lbN = 0;
bool   g_lbOn = false;          // sổ điều khiển cấp Grid (đã có đóng tay trong chu kỳ)
long   g_lbCycle = 0;
int    g_lbAb[]; int g_lbAbN = 0;            // cấp đã bỏ (không mở lại trong chu kỳ)
ulong  g_lbGyId[LB38_GRAVE]; int g_lbGyLv[LB38_GRAVE]; int g_lbGyN = 0, g_lbGyNext = 0;
ulong  g_lbPendOrd = 0; int g_lbPendLv = 0; // lệnh Grid đã gửi, vị thế chưa thấy (PLACED)
int    g_lbSigN = -1; double g_lbSigSum = -1.0; ulong g_lbSigXor = 0;
// bằng chứng
long   g_lbActivations = 0, g_lbGridAssigned = 0, g_lbRecAssigned = 0, g_lbUnknownSeen = 0, g_lbRemoved = 0, g_lbAbandoned = 0, g_lbDiverged = 0;

string LbNs()    { return OfhNs("OFH38L", Magic); }
bool   LbOn()    { return g_lbOn; }
int    LbFind(const ulong id) { for(int i = 0; i < g_lbN; i++) if(g_lbId[i] == id) return i; return -1; }
string LbKindName(const int k) { return k == LBK_GRID ? "grid" : (k == LBK_RECOVERY ? "re-entry" : "UNKNOWN"); }

string LbText()
{
   string s = "";
   int lv[]; ArrayResize(lv, g_lbN); for(int i = 0; i < g_lbN; i++) lv[i] = g_lbLv[i] * 4 + g_lbKind[i];
   ArraySort(lv);
   for(int i = 0; i < g_lbN; i++) s += StringFormat("%sL%d%s", i > 0 ? " " : "", lv[i] / 4, (lv[i] % 4) == LBK_RECOVERY ? "r" : ((lv[i] % 4) == LBK_UNKNOWN ? "?" : ""));
   if(g_lbAbN > 0) { s += " | abandoned"; for(int i = 0; i < g_lbAbN; i++) s += " L" + IntegerToString(g_lbAb[i]); }
   return s;
}

// ---------------------------------------------------------------- persistence (one record per cycle)
void LbPersist()
{
   const string ns = LbNs();
   GlobalVariablesDeleteAll(ns);
   if(!g_lbOn) { GlobalVariablesFlush(); return; }
   GlobalVariableSet(ns + "cy", (double)g_lbCycle); GlobalVariableSet(ns + "n", g_lbN);
   for(int i = 0; i < g_lbN; i++)
   {
      GlobalVariableSet(ns + "i" + IntegerToString(i), (double)g_lbId[i]); GlobalVariableSet(ns + "l" + IntegerToString(i), g_lbLv[i]);
      GlobalVariableSet(ns + "k" + IntegerToString(i), g_lbKind[i]);
   }
   GlobalVariableSet(ns + "an", g_lbAbN);
   for(int i = 0; i < g_lbAbN; i++) GlobalVariableSet(ns + "a" + IntegerToString(i), g_lbAb[i]);
   GlobalVariableSet(ns + "po", (double)g_lbPendOrd); GlobalVariableSet(ns + "pl", g_lbPendLv);
   GlobalVariableSet(ns + "gn", g_lbGyN); GlobalVariableSet(ns + "gx", g_lbGyNext);   // recently left: a manual close processed after a restart still finds its level
   for(int i = 0; i < g_lbGyN; i++) { GlobalVariableSet(ns + "gi" + IntegerToString(i), (double)g_lbGyId[i]); GlobalVariableSet(ns + "gl" + IntegerToString(i), g_lbGyLv[i]); }
   OfhIdStore(ns, Magic);
   GlobalVariableSet(ns + "on", 1);   // written LAST: a record cut by a stop has no "on" → not trusted
   GlobalVariablesFlush();
}

// ---------------------------------------------------------------- entries
void LbAdd(const ulong id, const int lv, const int kind)
{
   if(g_lbN >= LB38_MAX) { MrFreezeGrid(MRF_LEVEL_UNPROVEN, StringFormat("level book full (%d positions)", g_lbN)); return; }
   ArrayResize(g_lbId, g_lbN + 1); ArrayResize(g_lbLv, g_lbN + 1); ArrayResize(g_lbKind, g_lbN + 1);
   g_lbId[g_lbN] = id; g_lbLv[g_lbN] = lv; g_lbKind[g_lbN] = kind; g_lbN++;
}
void LbDel(const int i)
{
   if(i < 0 || i >= g_lbN) return;
   g_lbGyId[g_lbGyNext] = g_lbId[i]; g_lbGyLv[g_lbGyNext] = g_lbLv[i]; g_lbGyNext = (g_lbGyNext + 1) % LB38_GRAVE; if(g_lbGyN < LB38_GRAVE) g_lbGyN++;
   g_lbId[i] = g_lbId[g_lbN - 1]; g_lbLv[i] = g_lbLv[g_lbN - 1]; g_lbKind[i] = g_lbKind[g_lbN - 1];
   g_lbN--; ArrayResize(g_lbId, g_lbN); ArrayResize(g_lbLv, g_lbN); ArrayResize(g_lbKind, g_lbN);
}
// cấp của vị thế (đang mở hoặc vừa rời cụm); 0 = không có trong sổ
int LbLevelOfPos(const ulong id)
{
   const int i = LbFind(id); if(i >= 0) return g_lbKind[i] == LBK_UNKNOWN ? 0 : g_lbLv[i];
   for(int k = 0; k < g_lbGyN; k++) if(g_lbGyId[k] == id) return g_lbGyLv[k];
   return 0;
}
bool LbIsAbandoned(const int lv) { return Lb38In(g_lbAb, g_lbAbN, lv); }
// the original (grid / L1) position of level lv is open
bool LbHasOriginal(const int lv) { for(int i = 0; i < g_lbN; i++) if(g_lbLv[i] == lv && g_lbKind[i] == LBK_GRID) return true; return false; }
void LbAbandonLevel(const int lv, const string why)
{
   if(lv <= 0 || LbIsAbandoned(lv)) return;
   ArrayResize(g_lbAb, g_lbAbN + 1); g_lbAb[g_lbAbN++] = lv; g_lbAbandoned++;
   PrintFormat("LEVEL BOOK | level L%d ABANDONED (%s): never re-opened by the grid in this cycle | %s", lv, why, LbText());
   LbPersist();
}
// the ORIGINAL open position of `lv` (a re-entry ticket has a later open time: the GLOBAL range history from it would be wrong): price + open time
bool LbPosOfLevel(const int lv, double &px, long &msc)
{
   for(int i = 0; i < g_lbN; i++)
   {
      if(g_lbLv[i] != lv || g_lbKind[i] != LBK_GRID) continue;
      for(int p = 0; p < PositionsTotal(); p++)
      {
         const ulong t = PositionGetTicket(p);
         if(t == 0 || !PositionSelectByTicket(t) || !IsOursPos() || (ulong)PositionGetInteger(POSITION_IDENTIFIER) != g_lbId[i]) continue;
         px = PositionGetDouble(POSITION_PRICE_OPEN); msc = PositionGetInteger(POSITION_TIME_MSC);
         return true;
      }
   }
   return false;
}

// ---------------------------------------------------------------- per tick: align with the broker positions
void LbSync()
{
   ulong id[]; long msc[]; string cm[]; int n = 0; double sum = 0.0; ulong x = 0;
   for(int p = 0; p < PositionsTotal(); p++)
   {
      const ulong t = PositionGetTicket(p);
      if(t == 0 || !PositionSelectByTicket(t) || !IsOursPos()) continue;
      ArrayResize(id, n + 1); ArrayResize(msc, n + 1); ArrayResize(cm, n + 1);
      id[n] = (ulong)PositionGetInteger(POSITION_IDENTIFIER); msc[n] = PositionGetInteger(POSITION_TIME_MSC); cm[n] = PositionGetString(POSITION_COMMENT);
      sum += (double)id[n]; x ^= id[n]; n++;
   }
   if(!g_lbOn)
   {
      // V26 convention: rank by open time (rebuilt only when the position set changes)
      if(n == g_lbSigN && sum == g_lbSigSum && x == g_lbSigXor) return;
      g_lbSigN = n; g_lbSigSum = sum; g_lbSigXor = x;
      int lv[]; Lb38Rank(msc, id, n, lv);
      g_lbN = 0; ArrayResize(g_lbId, 0); ArrayResize(g_lbLv, 0); ArrayResize(g_lbKind, 0);
      for(int i = 0; i < n; i++) LbAdd(id[i], lv[i], LBK_GRID);
      return;
   }
   bool changed = false;
   for(int i = g_lbN - 1; i >= 0; i--)
   {
      bool open = false; for(int k = 0; k < n && !open; k++) if(id[k] == g_lbId[i]) open = true;
      if(open) continue;
      PrintFormat("LEVEL BOOK | position %I64u (L%d %s) left the basket", g_lbId[i], g_lbLv[i], LbKindName(g_lbKind[i]));
      LbDel(i); g_lbRemoved++; changed = true;
   }
   for(int k = 0; k < n; k++)
   {
      if(LbFind(id[k]) >= 0) continue;
      // [SAFETY S10] in a BasketCycleID that had a rebase every position outside the book without a recovery tag is an RPA position (Lk* / additional order of an
      // epoch, counted by RpaSyncSubgrid / the rebase executor), not an unknown position of the original level book (HOTFIX: MrFreezeGrid after the first subgrid
      // fill, at the next rebase or at a restart when the book was ON — the epoch never reached +12)
      if(Saf38LbRpaOwned(RpaHadAny(), StringFind(cm[k], "R2MR") == 0))
      {
         if(StringFind(g_safOnce, "|LBSUB_" + IntegerToString((long)id[k]) + "|") < 0) g_safLbSubgrid++;
         SafLogOnce("LBSUB_" + IntegerToString((long)id[k]), StringFormat("LEVEL BOOK | position %I64u belongs to RPA (cycle %I64d with a rebase, %s epoch %d, no recovery tag): counted by RPA, not an original level", id[k], g_rpCyc, RpaStateName(g_rpState), g_rpEpoch));
         continue;
      }
      int lv = 0, kind = LBK_UNKNOWN; string src = "";
      if(g_lbPendOrd != 0 && id[k] == g_lbPendOrd && g_lbPendLv > 0) { lv = g_lbPendLv; kind = LBK_GRID; src = "grid order"; g_lbPendOrd = 0; g_lbPendLv = 0; g_lbGridAssigned++; }
      else if(StringFind(cm[k], "R2MR|") == 0) { lv = MrLevelOfTag((ulong)StringToInteger(StringSubstr(cm[k], 5))); if(lv > 0) { kind = LBK_RECOVERY; src = "re-entry tag"; g_lbRecAssigned++; } }
      // comment lost by the broker: the position id is the order ticket of a known re-entry request
      if(lv <= 0) { lv = MrLevelOfOrder(id[k]); if(lv > 0) { kind = LBK_RECOVERY; src = "re-entry order ticket (comment lost)"; g_lbRecAssigned++; } }
      if(lv <= 0)
      {
         lv = 0; kind = LBK_UNKNOWN; g_lbUnknownSeen++;
         MrFreezeGrid(MRF_LEVEL_UNPROVEN, StringFormat("position %I64u (comment '%s') appeared in the basket without a provable level (not a grid order of this EA, no re-entry tag)", id[k], cm[k]));
      }
      LbAdd(id[k], lv, kind); changed = true;
      PrintFormat("LEVEL BOOK | position %I64u -> %s (%s) | %s", id[k], lv > 0 ? "L" + IntegerToString(lv) : "level UNPROVEN", src == "" ? "unknown" : src, LbText());
   }
   if(changed) LbPersist();
}

// the first manual close of the cycle: the snapshot of the last tick (= V26 rank) becomes the level book of the basket
void LbActivate(const string why)
{
   if(g_lbOn) return;
   g_lbOn = true; g_lbCycle = MrCycleId(); g_lbActivations++;
   PrintFormat("LEVEL BOOK ON | %s | from now on the grid level of this basket comes from the book, not from the ticket count | %s", why, LbText());
   LbPersist();
}

// grid order sent for `lv` (its position id = the order ticket): assigned when the position is seen
void LbOnGridSend(const ulong order, const int lv)
{
   g_lbPendOrd = order; g_lbPendLv = lv;
   if(g_lbOn) LbSync();
}

// active recovery records: their levels stay reserved (a fill takes that level)
int LbReserved(int &res[]) { return MrReservedLevels(res); }

// next grid level (V26: total + 1 while the book is off)
int LbNextLevel(const int total)
{
   if(!g_lbOn) return total + 1;
   LbSync();
   int open[]; ArrayResize(open, g_lbN); int n = 0;
   for(int i = 0; i < g_lbN; i++) if(g_lbKind[i] != LBK_UNKNOWN) open[n++] = g_lbLv[i];
   int res[]; const int nr = LbReserved(res);
   const int next = Lb38Next(open, n, res, nr, g_lbAb, g_lbAbN);
   if(next != total + 1) g_lbDiverged++;
   return next;
}

// ---------------------------------------------------------------- cycle / restart
void LbOnCycleReset()
{
   const bool flat = (CountPositions() <= 0);
   g_lbOn = false; g_lbCycle = 0; g_lbN = 0; ArrayResize(g_lbId, 0); ArrayResize(g_lbLv, 0); ArrayResize(g_lbKind, 0);
   g_lbAbN = 0; ArrayResize(g_lbAb, 0); g_lbGyN = 0; g_lbGyNext = 0; g_lbPendOrd = 0; g_lbPendLv = 0;
   g_lbSigN = -1; g_lbSigSum = -1.0; g_lbSigXor = 0;
   if(flat && GlobalVariablesDeleteAll(LbNs()) > 0) GlobalVariablesFlush();
}

// after MrRestoreLoad (records / receipts give the levels of re-entry tickets), before the GLOBAL restore (GgSync uses the book level count)
void LbRestore()
{
   LbOnCycleReset();
   const string ns = LbNs();
   const int nPos = CountPositions();
   const long cyc = MrCycleId();
   if(nPos <= 0) { if(GlobalVariableCheck(ns + "cy")) { GlobalVariablesDeleteAll(ns); GlobalVariablesFlush(); } return; }
   bool ok = GlobalVariableCheck(ns + "on");
   string why = ok ? "" : (GlobalVariableCheck(ns + "cy") ? "INCOMPLETE" : "NO_RECORD");
   if(ok && OfhIdCheck(ns, Magic) != "") { ok = false; why = "IDENTITY"; }
   if(ok && (long)GlobalVariableGet(ns + "cy") != cyc) { ok = false; why = "OTHER_CYCLE"; }
   if(!ok)
   {
      if(why != "NO_RECORD") { GlobalVariablesDeleteAll(ns); GlobalVariablesFlush(); }
      LbSync();   // book off: V26 rank
      // positions of this cycle closed by hand while the EA was off (not processed yet) were part of the V26 rank: rank open + those together,
      // the closed ones go to the "recently left" ring (their manual close is processed right after by the restart history scan)
      ulong cid[]; long cms[]; const int nc = MrUnprocessedManualClosed(cid, cms);
      if(nc > 0)
      {
         ulong id[]; long msc[]; int n = 0;
         for(int p = 0; p < PositionsTotal(); p++)
         {
            const ulong t = PositionGetTicket(p);
            if(t == 0 || !PositionSelectByTicket(t) || !IsOursPos()) continue;
            ArrayResize(id, n + 1); ArrayResize(msc, n + 1); id[n] = (ulong)PositionGetInteger(POSITION_IDENTIFIER); msc[n] = PositionGetInteger(POSITION_TIME_MSC); n++;
         }
         const int nOpen = n;
         for(int k = 0; k < nc; k++) { ArrayResize(id, n + 1); ArrayResize(msc, n + 1); id[n] = cid[k]; msc[n] = cms[k]; n++; }
         int lv[]; Lb38Rank(msc, id, n, lv);
         g_lbN = 0; ArrayResize(g_lbId, 0); ArrayResize(g_lbLv, 0); ArrayResize(g_lbKind, 0);
         for(int i = 0; i < nOpen; i++) LbAdd(id[i], lv[i], LBK_GRID);
         for(int i = nOpen; i < n; i++) { g_lbGyId[g_lbGyNext] = id[i]; g_lbGyLv[g_lbGyNext] = lv[i]; g_lbGyNext = (g_lbGyNext + 1) % LB38_GRAVE; if(g_lbGyN < LB38_GRAVE) g_lbGyN++; }
         PrintFormat("LEVEL BOOK | restart: %d position(s) of this cycle closed by hand while the EA was off -> V26 rank over open + closed positions | %s", nc, LbText());
      }
      // manual-close activity of THIS cycle on record (recovery records / receipts / grid freeze) but no valid book → the ticket count is not provably the level
      if(MrCycleHadManualClose(cyc))
         MrFreezeGrid(MRF_LEVEL_UNPROVEN, StringFormat("restart: the level book of this basket is missing (%s) although it had manual closes - the open ticket count is not the level index", why));
      else PrintFormat("LEVEL BOOK | restart: %s -> V26 rank (no manual close in this cycle) | %s", why, LbText());
      return;
   }
   g_lbOn = true; g_lbCycle = cyc;
   const int n = (int)GlobalVariableGet(ns + "n");
   for(int i = 0; i < n; i++) LbAdd((ulong)GlobalVariableGet(ns + "i" + IntegerToString(i)), (int)GlobalVariableGet(ns + "l" + IntegerToString(i)), (int)GlobalVariableGet(ns + "k" + IntegerToString(i)));
   g_lbAbN = (int)GlobalVariableGet(ns + "an"); ArrayResize(g_lbAb, g_lbAbN);
   for(int i = 0; i < g_lbAbN; i++) g_lbAb[i] = (int)GlobalVariableGet(ns + "a" + IntegerToString(i));
   g_lbPendOrd = (ulong)GlobalVariableGet(ns + "po"); g_lbPendLv = (int)GlobalVariableGet(ns + "pl");
   g_lbGyN = MathMin(LB38_GRAVE, (int)GlobalVariableGet(ns + "gn")); g_lbGyNext = (int)GlobalVariableGet(ns + "gx") % LB38_GRAVE;
   for(int i = 0; i < g_lbGyN; i++) { g_lbGyId[i] = (ulong)GlobalVariableGet(ns + "gi" + IntegerToString(i)); g_lbGyLv[i] = (int)GlobalVariableGet(ns + "gl" + IntegerToString(i)); }
   PrintFormat("LEVEL BOOK RESTORED | cycle %I64d | %d recorded positions, %d open now | %s", cyc, n, nPos, LbText());
   bool unk = false; for(int i = 0; i < g_lbN; i++) if(g_lbKind[i] == LBK_UNKNOWN) unk = true;
   if(unk) MrFreezeGrid(MRF_LEVEL_UNPROVEN, "restart: the level book holds a position without a provable level");
   // positions closed while the EA was off -> "left" (graveyard: the history scan still finds their level); new ones -> pending grid order / tag / UNPROVEN
   // [SAFETY S10] synced right after RpaRestore (V38RestoreModules): the RPA positions of a rebased cycle are known only then (HOTFIX synced here: every subgrid
   // position of a rebased cycle froze the grid at each restart)
   g_lbSyncAfterRpa = true;
}

void LbPrintCounters(const string when)
{
   PrintFormat("LEVEL BOOK COUNTERS %s | on %d | activations %I64d | grid fills assigned %I64d | re-entry fills assigned %I64d | positions left %I64d | levels abandoned %I64d | unproven positions %I64d | grid decisions off the ticket count %I64d | %s",
               when, g_lbOn ? 1 : 0, g_lbActivations, g_lbGridAssigned, g_lbRecAssigned, g_lbRemoved, g_lbAbandoned, g_lbUnknownSeen, g_lbDiverged, LbText());
}

#endif
// [FINAL STANDALONE] ===== END INLINED OFH38_LevelBook.mqh =====
// [FINAL STANDALONE] ===== BEGIN INLINED OFH38_ManualRecovery.mqh (HOTFIX SHA256 B5EED466689BF4849846F705C1C91E87E51E18D2C82186ACC2A8EE3B253892FD) — included from Onefxhub_v38.38_RPA.mq5:L309 =====
// OFH38_ManualRecovery.mqh — V38 R2/R3: khôi phục lệnh đóng tay, thay `manualWait` đơn của V26
// (V26: một bộ biến chung bị ghi đè khi đóng tay lệnh thứ hai; vào lại bằng TrySendOrder(CountPositions()+1) = đếm lệnh, không phải cấp gốc;
// xóa nhớ ngay khi TrySendOrder trả true — kể cả khi broker chỉ PLACED / khớp một phần).
// R3 — CHÍNH SÁCH OWNER (thay R2 "mỗi deal một bản ghi, khôi phục hết"):
//   * ĐỢT = các vị thế gốc (POSITION_IDENTIFIER) bị khách đóng tay trong chu kỳ mà chưa khôi phục xong (bản ghi đang khôi phục + vị thế đã bỏ).
//     Đếm theo vị thế, không theo deal: đóng 2 lần một phần của cùng vị thế = 1 vị thế (gộp khối lượng vào bản ghi của nó).
//   * Đúng 1 vị thế: một bản ghi — chờ giá về vùng giá vào gốc, xác nhận HAI LẦN riêng của bản ghi, gửi đúng chiều + đúng khối lượng đã đóng
//     (không Lot_Multi / CalcLot, không TrySendOrder / LastSent*, không GgOnFill → anchor / biên GLOBAL không đổi). Cấp gốc từ sổ cấp (OFH38_LevelBook),
//     không dùng CountPositions()+1. Xóa CHỈ khi lịch sử deal cho thấy đủ lot; receipt (deal, giờ, khối lượng được phép, cấp) chống tạo lại, có trần.
//   * Đợt có >= 2 vị thế gốc (hoặc ManualReentry_Enable=false): KHÔNG khôi phục vị thế nào của đợt, không lệnh bù / hedge vì đóng tay. Bản ghi chưa gửi
//     → bỏ (SKIPPED_MULTI, có log); yêu cầu đang bay → RECONCILE_ONLY (không gửi lại, fill <= khối lượng đã đóng là vị thế thật của cụm, không bị đóng
//     theo suy đoán). Cấp của vị thế đã đóng hết → cấp đã bỏ trong sổ: Grid tiếp tục ở cấp kế đúng, không mở lại cấp đó. Đợt đã bỏ kéo dài tới hết chu kỳ.
//   * T1/T2 ưu tiên hơn khôi phục (R3-02): T1 không chờ bản ghi; khi T1/T2 nắm cụm không gửi yêu cầu mới (bản ghi chưa gửi → SKIPPED_T1, đang bay →
//     RECONCILE_ONLY: fill trễ là vị thế của cụm, thoát T1/T2 đóng nó).
//   * Khớp trễ (R3-04): REQUEST_IN_FLIGHT chỉ rời trạng thái khi có bằng chứng dứt khoát (lệnh trong lịch sử ở trạng thái cuối / DONE_PARTIAL có fill).
//     TIMEOUT / PLACED / DONE ảo không có lệnh nào → GIỮ AN TOÀN (không gửi lại, cảnh báo mỗi 60 s). Trước mỗi lần gửi: đối soát lịch sử lại.
//   * Lot thừa (R3-01): đã vào > được phép → đóng phần thừa (vị thế mang nhãn, mới nhất trước); chỉ tính "đã đóng" khi lịch sử có deal OUT của đúng lệnh
//     đóng / vị thế; một yêu cầu đóng thừa tại một thời điểm, chưa rõ kết quả thì không gửi yêu cầu thứ hai; không bao giờ đóng vị thế không mang nhãn.
// Cụm phẳng / BASKET_EXITING → CANCELLED (đang bay → CANCEL_RECONCILE: fill trễ được đóng, không thành L1 mới); DD Lock → SUSPENDED.
// R3 FINAL — CHỈ THỊ OWNER 23/10/2026 (mục 2, thay "đợt" của R3):
//   * Đếm theo CHU KỲ: tập vị thế gốc bị đóng tay trong chu kỳ (bộ nhận diện 2+ tối thiểu, lưu bền). Vị thế gốc = POSITION_IDENTIFIER của lệnh L1 / Grid
//     của cấp đó; vé vào lại / vé thêm của cấp đó đứng tên vị thế gốc ấy (sổ cấp: cùng cấp = cùng vị thế gốc).
//   * Chỉ 1 vị thế gốc trong chu kỳ (đóng hết / đóng nhiều lần từng phần, cộng dồn) → một bản ghi khôi phục như R3.
//   * Vị thế gốc KHÁC NHAU thứ 2 → MULTI_MANUAL_IGNORE tới hết chu kỳ (kể cả khi vị thế thứ nhất đã khôi phục xong): không khôi phục vị thế nào, không lệnh
//     bù / hedge; bản ghi chưa gửi → hủy (SKIPPED_MULTI), yêu cầu đang bay → RECONCILE_ONLY; cấp của vị thế gốc đã đóng hết mà chưa khôi phục → cấp đã bỏ.
//   * Đã xóa: bộ đếm "đợt" (MrBatchOthers: bản ghi đang khôi phục + danh sách vị thế đã bỏ g_mrAbPos), Mr38BatchDecision. Tối đa MỘT bản ghi còn quyền
//     khôi phục tại một thời điểm (kiểm tra bất biến khi tạo: vi phạm → coi như 2+, không khôi phục).
#ifndef OFH38_MANUALRECOVERY_MQH
#define OFH38_MANUALRECOVERY_MQH

// [FINAL STANDALONE] #include "OFH38_ManualRecovery_Core.mqh" — already inlined above; the original include guard made this include a no-op

#define MR38_MAX   64     // bản ghi hoạt động tối đa (vượt → khóa Grid cụm, BLOCKER)
#define MR38_RCPT  64     // receipt: deal đóng tay đã xử lý (vòng) — chống tạo lại cùng sự kiện từ lịch sử sau khởi động lại
#define MR38_ORD    8     // lệnh vào lại đã gửi tối đa / bản ghi (đối soát theo order ticket)
#define MR38_NOREC  8     // vị thế EA đang đóng (chân PairClose): đóng tay chúng không tạo bản ghi
#define MR38_ORIG  32     // R3 FINAL: vị thế gốc đã bị đóng tay trong chu kỳ (bộ nhận diện 2+; vượt → khóa Grid cụm, BLOCKER)

// lý do khóa Grid của cụm (MRF_*): OFH38_ManualRecovery_Core.mqh (dùng cả ở sổ cấp / GLOBAL)
string MrFreezeName(const int w)
{
   switch(w)
   {
      case MRF_REENTRY_OFF: return "MANUAL_CLOSE_WITH_REENTRY_OFF"; case MRF_RECORD_CAP: return "RECORD_CAP";     case MRF_DEAL_UNREADABLE: return "DEAL_UNREADABLE";
      case MRF_OUT_OF_ORDER: return "OUT_OF_ORDER_REMOVAL";         case MRF_OVERFILL: return "RECOVERY_OVERFILL"; case MRF_SIDE_MISMATCH: return "RECOVERY_SIDE_MISMATCH";
      case MRF_LEVEL_UNPROVEN: return "LEVEL_UNPROVEN";             case MRF_GLOBAL_UNPROVEN: return "GLOBAL_ANCHOR_UNPROVEN";
   }
   return "NONE";
}

struct Mr38Rec
{
   ulong  deal;          // deal đóng tay ĐẦU TIÊN của vị thế (khóa lưu bền + nhãn)
   ulong  posId;         // POSITION_IDENTIFIER vị thế bị đóng tay (R3 FINAL: vị thế gốc của nó = cùng id / cùng cấp — MrOrigFind)
   long   cycle;         // chu kỳ basket (msc khớp L1)
   int    type;          // POSITION_TYPE_BUY / SELL gốc = chiều vào lại
   double entry;         // giá mở gốc
   double target;        // khối lượng đóng tay (cần khôi phục) — R3: cộng dồn các lần đóng một phần của cùng vị thế
   double filled;        // đã khôi phục (đếm lại từ lịch sử deal mỗi lần đối soát)
   int    level;         // cấp gốc (sổ cấp), 0 = không chứng minh được (Grid khóa)
   bool   partial;       // vị thế gốc còn mở sau deal (đóng một phần)
   long   detectMsc;     // giờ tick phát hiện
   long   closeMsc;      // giờ deal đóng tay đầu tiên
   int    st;
   int    side;          // +1 giá ở trên entry, -1 dưới, 0 chưa rời
   int    attempts;
   long   nextMs;        // backoff (Ex38NowMs; không lưu bền)
   long   deadlineMs;    // cửa sổ đối soát (Ex38NowMs; không lưu bền — khởi động lại: grace + đối soát)
   double fillAtReq;     // khối lượng đã khôi phục lúc gửi yêu cầu gần nhất (không lưu bền)
   long   reqMsc;        // giờ tick (server) của yêu cầu đầu tiên — đối soát lịch sử từ đây (lưu bền)
   uint   lastRc;
   int    nOrd;
   ulong  ord[MR38_ORD];
   ulong  fillPos;       // POSITION_IDENTIFIER vị thế vào lại đầu tiên (bằng chứng)
   int    nDeals;        // R3: số deal đóng tay đã gộp vào bản ghi
   int    why;           // R3: RECONCILE_ONLY vì 1 = 2+ vị thế gốc (R3 FINAL: MULTI_MANUAL_IGNORE), 2 = T1/T2 nắm cụm
   ulong  lastOrd;       // R3: order ticket của yêu cầu GẦN NHẤT (0 = không biết: TIMEOUT)
   long   lastReqMsc;    // R3: giờ tick của yêu cầu gần nhất
   long   holdLogMs;     // R3: cảnh báo giữ an toàn gần nhất (không lưu bền)
   bool   holdCounted;   // R3: đã đếm lần giữ an toàn (không lưu bền)
};
Mr38Rec  g_mr[];
ulong    g_mrRcpt[MR38_RCPT]; long g_mrRcptMsc[MR38_RCPT]; double g_mrRcptTgt[MR38_RCPT];   // receipt: deal, time, volume the record was allowed to recover (0 = none)
double   g_mrRcptSur[MR38_RCPT];     // R3: surplus of that tag CONFIRMED closed by the broker (OUT deals of the surplus close order / position)
int      g_mrRcptLv[MR38_RCPT];      // R3: level of the record (a late fill of its tag gets this level in the book)
int      g_mrRcptN = 0, g_mrRcptNext = 0;
long     g_mrFloorMsc = 0;           // deal đóng tay trước mốc này không xét lại (chu kỳ trước / receipt đã cuộn)
long     g_mrMetaCycle = 0;          // chu kỳ của khóa Grid / receipt / mốc đang giữ (0 = chưa có)
bool     g_mrGridFreeze = false; int g_mrFreezeWhy = 0;
ulong    g_mrNoRec[MR38_NOREC]; int g_mrNoRecN = 0;
// R3 FINAL: bộ nhận diện 2+ (lưu bền theo chu kỳ) — vị thế gốc đã bị đóng tay trong chu kỳ (id + cấp) và chế độ MULTI_MANUAL_IGNORE (tới hết chu kỳ)
ulong    g_mrOrigPos[MR38_ORIG]; int g_mrOrigLv[MR38_ORIG]; int g_mrOrigN = 0;
bool     g_mrMulti = false;
int      g_mrLastCount = -1;
datetime g_mrLastScan = 0;
string   g_mrOnce = "";
// R3-01: ONE surplus close request at a time (any tag) until the broker shows its result
ulong    g_mrSpKey = 0, g_mrSpPos = 0, g_mrSpOrd = 0; double g_mrSpVol = 0.0; long g_mrSpMsc = 0; uint g_mrSpRc = 0; int g_mrSpAttempts = 0;
long     g_mrSpNextMs = 0, g_mrSpWarnMs = 0; bool g_mrSpFull = false;   // full = the request closes the WHOLE tagged position (a second full close cannot over-close)
bool     g_mrSurOutstanding = false;   // a surplus was detected and is not confirmed closed yet: re-checked every tick (not only at the 60 s scan)
// bằng chứng (in khi gỡ EA, harness đọc trực tiếp)
long     g_mrCreated = 0, g_mrRemovedFilled = 0, g_mrCancelled = 0, g_mrPartialFills = 0, g_mrReqs = 0, g_mrReqNotExec = 0, g_mrOverfills = 0,
         g_mrSuspends = 0, g_mrMaxActive = 0, g_mrScanFound = 0, g_mrIgnored = 0, g_mrOrphanCloses = 0, g_mrRestoredN = 0;
long     g_mrMerged = 0, g_mrSkipMulti = 0, g_mrSkipT1 = 0, g_mrMultiOn = 0, g_mrOrigSeen = 0, g_mrReceiptOnly = 0, g_mrRecOnlyResolved = 0,
         g_mrUnknownHolds = 0, g_mrSurDetected = 0, g_mrSurReqs = 0, g_mrSurUnknown = 0, g_mrSameOrigAgain = 0;
double   g_mrSurClosedConf = 0.0;

// reconciliation window of an accepted / unknown recovery request (R3-04: only a WARNING point — never a resend by itself)
long   MrWindowMs()           { return (long)MathMax(Exec_ConfirmMs, ManualReentry_ReconcileSec * 1000); }
string MrNs()                 { return OfhNs("OFH38M", Magic); }
string MrKey(const ulong d)   { return MrNs() + "r" + IntegerToString((long)d) + "_"; }
long   MrCycleId()            { return CycStartMsc(); }
int    MrFind(const ulong d)  { for(int i = 0; i < ArraySize(g_mr); i++) if(g_mr[i].deal == d) return i; return -1; }
int    MrPendingCount()       { return ArraySize(g_mr); }
bool   MrBlocksGrid()         { for(int i = 0; i < ArraySize(g_mr); i++) if(Mr38BlocksGrid(g_mr[i].st)) return true; return false; }
bool   MrInflightAny()        { for(int i = 0; i < ArraySize(g_mr); i++) if(Mr38InFlight(g_mr[i].st)) return true; return false; }
bool   MrAnyCancelReconcile() { for(int i = 0; i < ArraySize(g_mr); i++) if(g_mr[i].st == MR_CANCEL_RECONCILE) return true; return false; }
bool   MrRecovering(const int s) { return !Mr38Terminal(s) && s != MR_CANCEL_RECONCILE && s != MR_RECONCILE_ONLY; }
int    MrRecoveringCount()    { int n = 0; for(int i = 0; i < ArraySize(g_mr); i++) if(MrRecovering(g_mr[i].st)) n++; return n; }
bool   MrSurplusInFlight()    { return g_mrSpKey != 0; }   // R3 FINAL: a surplus close request is waiting for the broker's result (its ticket belongs to it)
// R3 FINAL: record of the SAME original (same position, or same proven level: re-entry / extra ticket of that level) that still has the right to
// recover / that is reconcile-only
int    MrFindOrigRec(const ulong p, const int lv, const bool recovering)
{
   for(int i = 0; i < ArraySize(g_mr); i++)
   {
      const bool same = (g_mr[i].posId == p) || (lv > 0 && g_mr[i].level == lv);
      if(same && (recovering ? MrRecovering(g_mr[i].st) : g_mr[i].st == MR_RECONCILE_ONLY)) return i;
   }
   return -1;
}
void   MrLogOnce(const string key, const string text) { if(StringFind(g_mrOnce, "|" + key + "|") >= 0) return; g_mrOnce += "|" + key + "|"; if(StringLen(g_mrOnce) > 4000) g_mrOnce = ""; Print(text); }
bool   Mr38IsManualReason(const long r) { return r == DEAL_REASON_CLIENT || r == DEAL_REASON_MOBILE || r == DEAL_REASON_WEB; }
long   Mr38DealReason(const ulong deal)
{
   return HistoryDealGetInteger(deal, DEAL_REASON);
}
bool   MrPersistOn()
{
   return true;
}
void MrFlush() { if(MrPersistOn()) GlobalVariablesFlush(); }

// ---------------------------------------------------------------- R3 FINAL: originals closed by hand in the CYCLE (minimal 2+ detector) / level book helpers
// the original a closed position stands for: the same position id, or the same proven level (a re-entry / extra ticket of that level); -1 = a new original
int MrOrigFind(const ulong p, const int lv) { for(int j = 0; j < g_mrOrigN; j++) if(g_mrOrigPos[j] == p || (lv > 0 && g_mrOrigLv[j] == lv)) return j; return -1; }
void MrOrigAdd(const ulong p, const int lv)
{
   if(p == 0 || MrOrigFind(p, lv) >= 0) return;
   if(g_mrOrigN < MR38_ORIG) { g_mrOrigPos[g_mrOrigN] = p; g_mrOrigLv[g_mrOrigN] = lv; g_mrOrigN++; g_mrOrigSeen++; }
   else { g_mrMulti = true; MrFreezeGrid(MRF_RECORD_CAP, StringFormat("%d original positions closed by hand in this basket", g_mrOrigN)); }   // full: 2+ anyway
}
string MrOrigText() { string s = ""; for(int j = 0; j < g_mrOrigN; j++) s += StringFormat("%s%I64u(L%d)", j > 0 ? "," : "", g_mrOrigPos[j], g_mrOrigLv[j]); return s == "" ? "-" : s; }
// levels kept reserved for the level book: every record that may still fill (recovering / reconcile-only / suspended)
int MrReservedLevels(int &res[])
{
   int n = 0; ArrayResize(res, 0);
   for(int i = 0; i < ArraySize(g_mr); i++)
   {
      if(Mr38Terminal(g_mr[i].st) || g_mr[i].st == MR_CANCEL_RECONCILE || g_mr[i].level <= 0) continue;
      ArrayResize(res, n + 1); res[n++] = g_mr[i].level;
   }
   return n;
}

// ---------------------------------------------------------------- persistence (one group of terminal variables per record: deleting one never touches another)
void MrSaveRec(const int i)
{
   if(!MrPersistOn()) return;
   const string k = MrKey(g_mr[i].deal);
   GlobalVariableSet(k + "p", (double)g_mr[i].posId);   GlobalVariableSet(k + "c", (double)g_mr[i].cycle);   GlobalVariableSet(k + "t", g_mr[i].type);
   GlobalVariableSet(k + "e", g_mr[i].entry);           GlobalVariableSet(k + "v", g_mr[i].target);          GlobalVariableSet(k + "f", g_mr[i].filled);
   GlobalVariableSet(k + "l", g_mr[i].level);           GlobalVariableSet(k + "a", g_mr[i].partial ? 1 : 0); GlobalVariableSet(k + "d", (double)g_mr[i].detectMsc);
   GlobalVariableSet(k + "x", (double)g_mr[i].closeMsc); GlobalVariableSet(k + "sd", g_mr[i].side);          GlobalVariableSet(k + "n", g_mr[i].attempts);
   GlobalVariableSet(k + "rq", (double)g_mr[i].reqMsc); GlobalVariableSet(k + "rc", g_mr[i].lastRc);         GlobalVariableSet(k + "no", g_mr[i].nOrd);
   for(int j = 0; j < g_mr[i].nOrd; j++) GlobalVariableSet(k + "o" + IntegerToString(j), (double)g_mr[i].ord[j]);
   GlobalVariableSet(k + "fp", (double)g_mr[i].fillPos);
   GlobalVariableSet(k + "nd", g_mr[i].nDeals); GlobalVariableSet(k + "wy", g_mr[i].why);
   GlobalVariableSet(k + "lo", (double)g_mr[i].lastOrd); GlobalVariableSet(k + "lr", (double)g_mr[i].lastReqMsc);
   GlobalVariableSet(k + "s", g_mr[i].st);   // ghi CUỐI: thiếu "s" = bản ghi chưa ghi xong → khởi động lại dựng lại từ deal đóng tay + đối soát comment
}
void MrDelRec(const ulong deal) { if(MrPersistOn()) GlobalVariablesDeleteAll(MrKey(deal)); }
void MrSaveMeta()
{
   if(!MrPersistOn()) return;
   const string ns = MrNs();
   GlobalVariableSet(ns + "cy", (double)g_mrMetaCycle); GlobalVariableSet(ns + "fz", g_mrGridFreeze ? 1 : 0); GlobalVariableSet(ns + "fw", g_mrFreezeWhy);
   GlobalVariableSet(ns + "fl", (double)g_mrFloorMsc);
   GlobalVariableSet(ns + "qn", g_mrRcptN); GlobalVariableSet(ns + "qx", g_mrRcptNext);
   for(int j = 0; j < g_mrRcptN; j++)
   {
      GlobalVariableSet(ns + "q" + IntegerToString(j), (double)g_mrRcpt[j]); GlobalVariableSet(ns + "m" + IntegerToString(j), (double)g_mrRcptMsc[j]);
      GlobalVariableSet(ns + "g" + IntegerToString(j), g_mrRcptTgt[j]); GlobalVariableSet(ns + "w" + IntegerToString(j), g_mrRcptSur[j]);
      GlobalVariableSet(ns + "h" + IntegerToString(j), g_mrRcptLv[j]);
   }
   GlobalVariableSet(ns + "un", g_mrNoRecN);
   for(int j = 0; j < g_mrNoRecN; j++) GlobalVariableSet(ns + "u" + IntegerToString(j), (double)g_mrNoRec[j]);
   GlobalVariableSet(ns + "xn", g_mrOrigN); GlobalVariableSet(ns + "xm", g_mrMulti ? 1 : 0);   // R3 FINAL: 2+ detector of the cycle
   for(int j = 0; j < g_mrOrigN; j++) { GlobalVariableSet(ns + "xp" + IntegerToString(j), (double)g_mrOrigPos[j]); GlobalVariableSet(ns + "xl" + IntegerToString(j), g_mrOrigLv[j]); }
   GlobalVariableSet(ns + "sk", (double)g_mrSpKey); GlobalVariableSet(ns + "sp", (double)g_mrSpPos); GlobalVariableSet(ns + "so", (double)g_mrSpOrd);
   GlobalVariableSet(ns + "sv", g_mrSpVol); GlobalVariableSet(ns + "sm", (double)g_mrSpMsc); GlobalVariableSet(ns + "sr", g_mrSpRc); GlobalVariableSet(ns + "sa", g_mrSpAttempts);
   GlobalVariableSet(ns + "sf", g_mrSpFull ? 1 : 0);
   OfhIdStore(ns, Magic);
}
// số biến toàn cục của hàng chờ (bằng chứng bộ nhớ lưu bền không phình)
int MrStoreVars() { const string ns = MrNs(); int n = 0; for(int i = GlobalVariablesTotal() - 1; i >= 0; i--) if(StringFind(GlobalVariableName(i), ns) == 0) n++; return n; }

// ---------------------------------------------------------------- receipts / no-recover list
bool MrReceipted(const ulong deal) { for(int j = 0; j < g_mrRcptN; j++) if(g_mrRcpt[j] == deal) return true; return false; }
int  MrReceiptIdx(const ulong deal) { for(int j = 0; j < g_mrRcptN; j++) if(g_mrRcpt[j] == deal) return j; return -1; }
void MrReceiptAdd(const ulong deal, const long dealMsc, const double allowed = 0.0, const int level = 0)
{
   if(deal == 0 || MrReceipted(deal)) return;
   if(g_mrRcptN < MR38_RCPT) { g_mrRcpt[g_mrRcptN] = deal; g_mrRcptMsc[g_mrRcptN] = dealMsc; g_mrRcptTgt[g_mrRcptN] = allowed; g_mrRcptSur[g_mrRcptN] = 0.0; g_mrRcptLv[g_mrRcptN] = level; g_mrRcptN++; g_mrRcptNext = g_mrRcptN % MR38_RCPT; return; }
   // vòng đầy: receipt cũ nhất rời vòng, mốc thời gian tiến tới deal đó (deal đóng tay cũ hơn không bao giờ được xét lại) — dung lượng có trần
   if(g_mrRcptMsc[g_mrRcptNext] + 1 > g_mrFloorMsc) g_mrFloorMsc = g_mrRcptMsc[g_mrRcptNext] + 1;
   g_mrRcpt[g_mrRcptNext] = deal; g_mrRcptMsc[g_mrRcptNext] = dealMsc; g_mrRcptTgt[g_mrRcptNext] = allowed; g_mrRcptSur[g_mrRcptNext] = 0.0; g_mrRcptLv[g_mrRcptNext] = level;
   g_mrRcptNext = (g_mrRcptNext + 1) % MR38_RCPT;
}
// level of a re-entry tag (active record, else its receipt) — the level book assigns re-entry tickets with it
int MrLevelOfTag(const ulong key)
{
   const int i = MrFind(key); if(i >= 0) return g_mr[i].level;
   const int j = MrReceiptIdx(key); return j >= 0 ? g_mrRcptLv[j] : 0;
}
// level of a re-entry fill whose comment the broker dropped: its position id is the order ticket of a request of an active record
int MrLevelOfOrder(const ulong posId)
{
   for(int i = 0; i < ArraySize(g_mr); i++) for(int j = 0; j < g_mr[i].nOrd; j++) if(g_mr[i].ord[j] == posId) return g_mr[i].level;
   return 0;
}
// manual-close activity of this cycle on record (restart without a valid level book)
bool MrCycleHadManualClose(const long cyc)
{
   if(cyc <= 0 || g_mrMetaCycle != cyc) return false;
   if(ArraySize(g_mr) > 0 || g_mrOrigN > 0 || g_mrMulti || g_mrGridFreeze) return true;
   for(int j = 0; j < g_mrRcptN; j++) if(g_mrRcptMsc[j] >= cyc) return true;
   return false;
}
bool MrNoRecover(const ulong posId) { for(int j = 0; j < g_mrNoRecN; j++) if(g_mrNoRec[j] == posId) return true; return false; }
void MrNoRecoverAdd(const ulong posId)
{
   if(posId == 0 || MrNoRecover(posId)) return;
   if(g_mrNoRecN < MR38_NOREC) g_mrNoRec[g_mrNoRecN++] = posId;
   else { for(int j = 1; j < MR38_NOREC; j++) g_mrNoRec[j - 1] = g_mrNoRec[j]; g_mrNoRec[MR38_NOREC - 1] = posId; }
   MrSaveMeta();
}

void MrFreezeGrid(const int why, const string text)
{
   if(g_mrGridFreeze) return;
   g_mrGridFreeze = true; g_mrFreezeWhy = why;
   if(g_mrMetaCycle == 0) g_mrMetaCycle = MrCycleId();
   PrintFormat("GRID FROZEN (BLOCKER) | %s | %s | no further grid level for this basket; exits / T1 / T2 / PairClose / DD keep working - Owner decision required",
               MrFreezeName(why), text);
   MrSaveMeta(); MrFlush();
}

// ---------------------------------------------------------------- broker evidence
// fills of a record from the broker history: entry deals of Magic / symbol whose order is one of the record's requests or whose comment is its tag
double MrFilledFromHistory(const int i, int &sideErr)
{
   sideErr = 0;
   const long from = (g_mr[i].reqMsc > 0 && g_mr[i].reqMsc < g_mr[i].closeMsc) ? g_mr[i].reqMsc : g_mr[i].closeMsc;
   if(!HistorySelect((datetime)(from / 1000) - 5, TimeCurrent() + 60)) return g_mr[i].filled;   // history not readable: keep the known value
   double v = 0.0;
   for(int k = HistoryDealsTotal() - 1; k >= 0; k--)
   {
      const ulong d = HistoryDealGetTicket(k);
      if(d == 0 || HistoryDealGetString(d, DEAL_SYMBOL) != _Symbol || (ulong)HistoryDealGetInteger(d, DEAL_MAGIC) != Magic) continue;
      if(HistoryDealGetInteger(d, DEAL_ENTRY) != DEAL_ENTRY_IN) continue;
      bool mine = Mr38TagIs(HistoryDealGetString(d, DEAL_COMMENT), g_mr[i].deal);
      const ulong o = (ulong)HistoryDealGetInteger(d, DEAL_ORDER);
      for(int j = 0; j < g_mr[i].nOrd && !mine; j++) if(g_mr[i].ord[j] == o) mine = true;
      if(!mine) continue;
      if((HistoryDealGetInteger(d, DEAL_TYPE) == DEAL_TYPE_BUY) != (g_mr[i].type == POSITION_TYPE_BUY)) { sideErr++; continue; }
      v += HistoryDealGetDouble(d, DEAL_VOLUME);
      if(g_mr[i].fillPos == 0) g_mr[i].fillPos = (ulong)HistoryDealGetInteger(d, DEAL_POSITION_ID);
   }
   return NormalizeDouble(v, 8);
}
// a working (not yet filled) order of the record: never resend while it exists
bool MrOrderWorking(const int i)
{
   for(int k = OrdersTotal() - 1; k >= 0; k--)
   {
      const ulong t = OrderGetTicket(k);
      if(t == 0 || OrderGetString(ORDER_SYMBOL) != _Symbol || (ulong)OrderGetInteger(ORDER_MAGIC) != Magic) continue;
      if(Mr38TagIs(OrderGetString(ORDER_COMMENT), g_mr[i].deal)) return true;
      for(int j = 0; j < g_mr[i].nOrd; j++) if(g_mr[i].ord[j] == t) return true;
   }
   return false;
}
// R3-04: orders of the record's requests in the broker HISTORY (final states). seen = orders found (history or working), final = in history,
// covered = the LATEST request is among them (its ticket in history, or a tagged history order placed at / after it when its ticket is unknown)
void MrRequestOrders(const int i, int &seen, int &fin, bool &covered)
{
   seen = 0; fin = 0; covered = false;
   const long from = (g_mr[i].reqMsc > 0) ? g_mr[i].reqMsc : g_mr[i].closeMsc;
   if(!HistorySelect((datetime)(from / 1000) - 5, TimeCurrent() + 60)) return;
   for(int k = HistoryOrdersTotal() - 1; k >= 0; k--)
   {
      const ulong o = HistoryOrderGetTicket(k);
      if(o == 0 || HistoryOrderGetString(o, ORDER_SYMBOL) != _Symbol || (ulong)HistoryOrderGetInteger(o, ORDER_MAGIC) != Magic) continue;
      bool mine = Mr38TagIs(HistoryOrderGetString(o, ORDER_COMMENT), g_mr[i].deal);
      for(int j = 0; j < g_mr[i].nOrd && !mine; j++) if(g_mr[i].ord[j] == o) mine = true;
      if(!mine) continue;
      seen++; fin++;
      if(g_mr[i].lastOrd > 0 ? o == g_mr[i].lastOrd : HistoryOrderGetInteger(o, ORDER_TIME_SETUP_MSC) >= g_mr[i].lastReqMsc - 1000) covered = true;
   }
   for(int k = OrdersTotal() - 1; k >= 0; k--)
   {
      const ulong t = OrderGetTicket(k);
      if(t == 0 || OrderGetString(ORDER_SYMBOL) != _Symbol || (ulong)OrderGetInteger(ORDER_MAGIC) != Magic) continue;
      bool mine = Mr38TagIs(OrderGetString(ORDER_COMMENT), g_mr[i].deal);
      for(int j = 0; j < g_mr[i].nOrd && !mine; j++) if(g_mr[i].ord[j] == t) mine = true;
      if(mine) seen++;
   }
}
// open position carrying the tag of record i (an orphan check for a cancelled cycle)
ulong MrTaggedOpen(const ulong deal)
{
   for(int k = PositionsTotal() - 1; k >= 0; k--)
   {
      const ulong t = PositionGetTicket(k);
      if(t == 0 || !PositionSelectByTicket(t) || !IsOursPos()) continue;
      if(Mr38TagIs(PositionGetString(POSITION_COMMENT), deal)) return t;
   }
   return 0;
}
bool MrAnyTaggedOpen()
{
   for(int k = PositionsTotal() - 1; k >= 0; k--)
   {
      const ulong t = PositionGetTicket(k);
      if(t == 0 || !PositionSelectByTicket(t) || !IsOursPos()) continue;
      if(StringFind(PositionGetString(POSITION_COMMENT), "R2MR|") == 0) return true;
   }
   return false;
}

// ---------------------------------------------------------------- R3-01: surplus of a FINISHED record (a duplicate / late fill above the allowed volume)
// Detected = filled(tag) - allowed - closed CONFIRMED. Requested ≠ closed: only OUT deals of the surplus close order (or, ticket unknown, of that position
// after the request) count. One surplus close at a time; rejected → backoff; unknown result → wait + warning, no second request — except a FULL close of
// the tagged position that still shows its whole volume after the confirmation window with no close order working (a second full close cannot over-close).
// Only tagged positions are ever closed as surplus.
void MrSurplusLedgerClear() { g_mrSpKey = 0; g_mrSpPos = 0; g_mrSpOrd = 0; g_mrSpVol = 0.0; g_mrSpMsc = 0; g_mrSpRc = 0; g_mrSpWarnMs = 0; g_mrSpFull = false; }
// the tagged position of the surplus request: open volume (0 = gone)
double MrSurplusPosVolume() { for(int k = PositionsTotal() - 1; k >= 0; k--) { const ulong t = PositionGetTicket(k); if(t != 0 && PositionSelectByTicket(t) && IsOursPos() && (ulong)PositionGetInteger(POSITION_IDENTIFIER) == g_mrSpPos) return PositionGetDouble(POSITION_VOLUME); } return 0.0; }
// the surplus close request in flight against the broker history. true = resolved (confirmed, or definitively not executed)
bool MrSurplusResolve()
{
   if(g_mrSpKey == 0) return true;
   const int j = MrReceiptIdx(g_mrSpKey);
   if(!HistorySelect((datetime)(g_mrSpMsc / 1000) - 5, TimeCurrent() + 60)) return false;   // history not readable: nothing is assumed
   double out = 0.0;
   for(int k = HistoryDealsTotal() - 1; k >= 0; k--)
   {
      const ulong d = HistoryDealGetTicket(k);
      if(d == 0 || HistoryDealGetString(d, DEAL_SYMBOL) != _Symbol || (ulong)HistoryDealGetInteger(d, DEAL_MAGIC) != Magic) continue;
      const long en = HistoryDealGetInteger(d, DEAL_ENTRY);
      if(en != DEAL_ENTRY_OUT && en != DEAL_ENTRY_OUT_BY) continue;
      if((ulong)HistoryDealGetInteger(d, DEAL_POSITION_ID) != g_mrSpPos) continue;
      if(g_mrSpOrd > 0 ? (ulong)HistoryDealGetInteger(d, DEAL_ORDER) != g_mrSpOrd : HistoryDealGetInteger(d, DEAL_TIME_MSC) < g_mrSpMsc - 1000) continue;
      out += HistoryDealGetDouble(d, DEAL_VOLUME);
   }
   const long now = Ex38NowMs();
   if(out > 0.0)
   {
      if(j >= 0) g_mrRcptSur[j] += out;
      g_mrSurClosedConf += out;
      PrintFormat("MR SURPLUS CLOSE CONFIRMED | tag of deal %I64u position %I64u: %.2f closed by the broker (requested %.2f, order %I64u) | surplus closed so far %.2f",
                  g_mrSpKey, g_mrSpPos, out, g_mrSpVol, g_mrSpOrd, j >= 0 ? g_mrRcptSur[j] : out);
      MrSurplusLedgerClear(); g_mrSpAttempts = 0; MrSaveMeta(); MrFlush();
      return true;
   }
   // a close order of that position still works at the broker → wait (never a second close)
   for(int k = OrdersTotal() - 1; k >= 0; k--)
   {
      const ulong t = OrderGetTicket(k);
      if(t == 0 || OrderGetString(ORDER_SYMBOL) != _Symbol) continue;
      if(t == g_mrSpOrd || (ulong)OrderGetInteger(ORDER_POSITION_ID) == g_mrSpPos) return false;
   }
   const int cls = Ex38Classify(EX38_OP_CLOSE, g_mrSpRc);
   const bool orderFinal = (g_mrSpOrd > 0 && HistoryOrderSelect(g_mrSpOrd));
   // a FULL close of the tagged position whose result is unknown: the position is still open with its whole volume after the confirmation window and no
   // close order works -> it was not executed (a later execution of it would find the position gone: a second full close cannot over-close)
   const bool fullStill = g_mrSpFull && Ex38TickMsc() - g_mrSpMsc >= MathMax(1, Exec_ConfirmMs) && MrSurplusPosVolume() >= g_mrSpVol - Ex38Step() * 0.5;
   if(Ex38IsRetryClass(cls) || orderFinal || fullStill)
   {
      PrintFormat("MR SURPLUS CLOSE NOT EXECUTED | tag of deal %I64u position %I64u %.2f | rc=%u %s%s -> nothing counted as closed, retry after backoff",
                  g_mrSpKey, g_mrSpPos, g_mrSpVol, g_mrSpRc, Ex38ClassName(cls), orderFinal ? " (order final in the history without a deal)" : (fullStill ? " (full close: the position is still open with its whole volume after the confirmation window, no close order works)" : ""));
      g_mrSpNextMs = now + Ex38BackoffMs(Ex38IsRetryClass(cls) ? cls : EXC_RETRY_SLOW, MathMax(1, g_mrSpAttempts));
      MrSurplusLedgerClear(); MrSaveMeta(); MrFlush();
      return true;
   }
   // unknown (TIMEOUT / PLACED / DONE without a deal): safe hold, a warning every 60 s
   if(g_mrSpWarnMs == 0 || now - g_mrSpWarnMs >= 60000)
   {
      if(g_mrSpWarnMs == 0) g_mrSurUnknown++;
      g_mrSpWarnMs = now;
      R2Warn("MRSUR_" + IntegerToString((long)g_mrSpKey), StringFormat("R3 WARNING MR SURPLUS CLOSE UNKNOWN | tag of deal %I64u position %I64u %.2f | rc=%u, no deal / order in the broker history yet -> NOT counted as closed, no second close request",
                                                                     g_mrSpKey, g_mrSpPos, g_mrSpVol, g_mrSpRc));
   }
   return false;
}
void MrSurplusCheck(const ulong key, const string why)
{
   if(key == 0 || MrFind(key) >= 0 || DdlActive() || ExActive()) return;
   if(!MrSurplusResolve()) return;   // one surplus close at a time
   const int j = MrReceiptIdx(key); if(j < 0) return;
   const double step = Ex38Step();
   if(!HistorySelect((datetime)(g_mrRcptMsc[j] / 1000) - 5, TimeCurrent() + 60)) return;
   double filled = 0.0;
   for(int k = HistoryDealsTotal() - 1; k >= 0; k--)
   {
      const ulong d = HistoryDealGetTicket(k);
      if(d == 0 || HistoryDealGetString(d, DEAL_SYMBOL) != _Symbol || (ulong)HistoryDealGetInteger(d, DEAL_MAGIC) != Magic || HistoryDealGetInteger(d, DEAL_ENTRY) != DEAL_ENTRY_IN) continue;
      if(Mr38TagIs(HistoryDealGetString(d, DEAL_COMMENT), key)) filled += HistoryDealGetDouble(d, DEAL_VOLUME);
   }
   // open positions of that tag, newest first (only these may be closed as surplus)
   ulong tk[]; long tm[]; double tv[]; int n = 0; double openTagged = 0.0;
   for(int k = PositionsTotal() - 1; k >= 0; k--)
   {
      const ulong t = PositionGetTicket(k);
      if(t == 0 || !PositionSelectByTicket(t) || !IsOursPos() || !Mr38TagIs(PositionGetString(POSITION_COMMENT), key)) continue;
      ArrayResize(tk, n + 1); ArrayResize(tm, n + 1); ArrayResize(tv, n + 1); tk[n] = t; tm[n] = PositionGetInteger(POSITION_TIME_MSC); tv[n] = PositionGetDouble(POSITION_VOLUME);
      openTagged += tv[n]; n++;
   }
   const double toClose = Mr38SurplusToClose(filled, g_mrRcptTgt[j], g_mrRcptSur[j], openTagged, step);
   if(toClose <= 0.0) return;
   g_mrSurOutstanding = true;
   for(int a = 1; a < n; a++) { const ulong x = tk[a]; const long y = tm[a]; const double z = tv[a]; int b = a - 1; while(b >= 0 && tm[b] < y) { tk[b + 1] = tk[b]; tm[b + 1] = tm[b]; tv[b + 1] = tv[b]; b--; } tk[b + 1] = x; tm[b + 1] = y; tv[b + 1] = z; }
   g_mrSurDetected++; g_mrOverfills++;
   MrFreezeGrid(MRF_OVERFILL, StringFormat("late duplicate fill of the recovery of deal %I64u (%.2f above the allowed volume) - surplus closed", key, filled - g_mrRcptTgt[j]));
   const long now = Ex38NowMs();
   PrintFormat("MR SURPLUS (%s) | tag of deal %I64u: detected %.2f = recovered %.2f - allowed %.2f (%s) - closed confirmed %.2f | open tagged %.2f in %d position(s) | %s",
               why, key, toClose, filled, g_mrRcptTgt[j], g_mrRcptTgt[j] > 0.0 ? "record FILLED" : "record CANCELLED", g_mrRcptSur[j], openTagged, n,
               (now < g_mrSpNextMs || now < g_exGraceUntil) ? "close request after backoff" : (!Ex38TradeSessionOpen() ? "trade session closed: request at the next session" : "one close request now (newest tagged position)"));
   if(now < g_mrSpNextMs || now < g_exGraceUntil || !Ex38TradeSessionOpen() || n == 0) return;
   const ulong t = tk[0];
   if(!PositionSelectByTicket(t)) return;
   const ulong pid = (ulong)PositionGetInteger(POSITION_IDENTIFIER);
   const double v = tv[0];
   const double vol = (v <= toClose + step * 0.5) ? v : toClose;
   g_mrSpKey = key; g_mrSpPos = pid; g_mrSpVol = vol; g_mrSpMsc = Ex38TickMsc(); g_mrSpOrd = 0; g_mrSpRc = 0; g_mrSpWarnMs = 0; g_mrSpAttempts++;
   g_mrSpFull = (vol >= v - step * 0.5);
   MrSaveMeta(); MrFlush();   // intent before the request
   const long s0 = trade.m_sends;
   if(vol >= v - step * 0.5) trade.PositionClose(t); else trade.PositionClosePartial(t, vol);
   const bool sent = (trade.m_sends > s0);
   g_mrSpRc = sent ? trade.ResultRetcode() : 0; g_mrSpOrd = sent ? trade.ResultOrder() : 0;
   if(sent) g_mrSurReqs++;
   PrintFormat("MR SURPLUS CLOSE REQUEST | ticket %I64u (tag of deal %I64u) %.2f of %.2f | rc=%u %s order %I64u | requested, NOT counted as closed until the broker history shows the deal",
               t, key, vol, v, g_mrSpRc, Ex38ClassName(sent ? Ex38Classify(EX38_OP_CLOSE, g_mrSpRc) : EXC_RETRY_SLOW), g_mrSpOrd);
   MrSaveMeta(); MrFlush();
   MrSurplusResolve();
}
// every open position carrying the tag of a record that is no longer active (periodic / count drop / restart): surplus check
void MrSurplusScan(const string why)
{
   if(DdlActive() || ExActive()) return;
   g_mrSurOutstanding = (g_mrSpKey != 0);   // set again below by every tag that still has a surplus to close
   MrSurplusResolve();
   ulong keys[]; int n = 0;
   for(int k = PositionsTotal() - 1; k >= 0; k--)
   {
      const ulong t = PositionGetTicket(k);
      if(t == 0 || !PositionSelectByTicket(t) || !IsOursPos()) continue;
      const string c = PositionGetString(POSITION_COMMENT);
      if(StringFind(c, "R2MR|") != 0) continue;
      const ulong key = (ulong)StringToInteger(StringSubstr(c, 5));
      if(key == 0 || MrFind(key) >= 0) continue;
      bool have = false; for(int a = 0; a < n; a++) if(keys[a] == key) have = true;
      if(!have) { ArrayResize(keys, n + 1); keys[n++] = key; }
   }
   for(int a = 0; a < n; a++) MrSurplusCheck(keys[a], why);
}

// ---------------------------------------------------------------- remove (only this record; RAM + persistent store; receipt kept)
void MrRemove(const int i, const int finalSt, const double allowed, const string why)
{
   const ulong deal = g_mr[i].deal; const long cm = g_mr[i].closeMsc;
   const int before = ArraySize(g_mr);
   PrintFormat("MR %s deal %I64u -> REMOVE_PENDING | %s %.2f of %.2f recovered | record deleted from the queue and the persistent store, other records untouched | pending %d -> %d | %s",
               Mr38StateName(finalSt), deal, g_mr[i].type == POSITION_TYPE_BUY ? "BUY" : "SELL", g_mr[i].filled, g_mr[i].target, before, before - 1, why);
   MrDelRec(deal);
   MrReceiptAdd(deal, cm, allowed, g_mr[i].level);
   g_mr[i] = g_mr[before - 1]; ArrayResize(g_mr, before - 1);
   if(finalSt == MR_CANCELLED) g_mrCancelled++;
   MrSaveMeta(); MrFlush();
}

// FILLED_CONFIRMED: the broker history shows the full volume back (right side, right magic / symbol, this cycle)
void MrComplete(const int i, const string why)
{
   g_mr[i].st = MR_FILLED;
   PrintFormat("MR FILLED_CONFIRMED deal %I64u | %s %.2f of %.2f at original entry %.2f | recovered position %I64u | level %s (the re-entry keeps this level in the level book; ticket count %d) | %s",
               g_mr[i].deal, g_mr[i].type == POSITION_TYPE_BUY ? "BUY" : "SELL", g_mr[i].filled, g_mr[i].target, g_mr[i].entry, g_mr[i].fillPos,
               g_mr[i].level > 0 ? "L" + IntegerToString(g_mr[i].level) : "unknown", CountPositions(), why);
   g_mrRemovedFilled++;
   LbSync();   // the re-entry position(s) get the record's level while the record (tag + order tickets) still exists
   const ulong key = g_mr[i].deal; const bool over = Mr38Overfill(g_mr[i].target, g_mr[i].filled, Ex38Step());
   MrRemove(i, MR_FILLED, g_mr[i].target, why);
   if(over) MrSurplusCheck(key, "OVERFILL_AT_COMPLETION");   // two fills counted at once: the volume above the closed one is closed
   if(GgAny()) GgSaveAll();   // GLOBAL record identity = earliest open ticket: refresh it (anchor / ranges themselves unchanged)
   LbSync();
}

// reconcile record i with the broker history (idempotent; may complete and remove it)
void MrReconcile(const int i, const string why)
{
   const double step = Ex38Step();
   int sideErr = 0;
   const double f = MrFilledFromHistory(i, sideErr);
   bool changed = false;
   if(sideErr > 0) MrFreezeGrid(MRF_SIDE_MISMATCH, StringFormat("deal %I64u: %d tagged fill(s) on the wrong side", g_mr[i].deal, sideErr));
   if(f > g_mr[i].filled + 1e-9)
   {
      PrintFormat("MR FILL deal %I64u | recovered %.2f -> %.2f of %.2f (broker history, %s)", g_mr[i].deal, g_mr[i].filled, f, g_mr[i].target, why);
      if(!Mr38Complete(g_mr[i].target, f, step)) g_mrPartialFills++;
      g_mr[i].filled = f; changed = true;
   }
   if(Mr38Overfill(g_mr[i].target, g_mr[i].filled, step))
   {
      g_mrOverfills++;
      MrFreezeGrid(MRF_OVERFILL, StringFormat("deal %I64u recovered %.2f > %.2f closed", g_mr[i].deal, g_mr[i].filled, g_mr[i].target));
   }
   const long now = Ex38NowMs();
   if(g_mr[i].st == MR_CANCEL_RECONCILE)
   {
      // cancelled while a request was in flight (cycle over / exit): removed only when no order works, the window is over and no fill of it is open any
      // more — a later fill of its tag is a surplus (receipt allows 0) and closed (R3-01)
      if(MrOrderWorking(i) || now < g_mr[i].deadlineMs || MrTaggedOpen(g_mr[i].deal) != 0) { if(changed) { MrSaveRec(i); MrFlush(); } return; }
      MrRemove(i, MR_CANCELLED, g_mr[i].filled, "CANCEL_RECONCILED (request window over, no open fill)");
      return;
   }
   if(g_mr[i].st == MR_RECONCILE_ONLY)
   {
      // R3: never sent again; every fill up to the closed volume stays a real position of the basket at the original level (receipt allows the target)
      int seen = 0, fin = 0; bool cov = false; MrRequestOrders(i, seen, fin, cov);
      const int cls = Ex38Classify(EX38_OP_OPEN, g_mr[i].lastRc);
      const bool def = Mr38Definitive(MrOrderWorking(i), seen, fin, cov, cls == EXC_DONE || cls == EXC_PARTIAL, g_mr[i].filled > g_mr[i].fillAtReq + 1e-9);
      if(Mr38Complete(g_mr[i].target, g_mr[i].filled, step) || (!MrOrderWorking(i) && (def || now >= g_mr[i].deadlineMs)))
      {
         g_mrRecOnlyResolved++;
         LbSync();   // its fill(s) get the record's level while the record (tag + order tickets) still exists
         const int rlv = g_mr[i].level; const bool rpart = g_mr[i].partial; const bool rcyc = (g_mr[i].cycle == MrCycleId() && CountPositions() > 0);   // [MRR R1] M05: level of THIS basket only
         MrRemove(i, MR_CANCELLED, g_mr[i].target, StringFormat("RECONCILE_ONLY resolved (%s): %.2f of %.2f filled is kept in the basket at L%d, no further request; a later fill of its tag up to %.2f is kept, above it closed",
                                                             Mr38Complete(g_mr[i].target, g_mr[i].filled, step) ? "full fill" : (def ? "request final at the broker" : "window over"),
                                                             g_mr[i].filled, g_mr[i].target, g_mr[i].level, g_mr[i].target));
         // [MRR R1] M05: re-entry removed - the level of a fully closed original whose old request left no open position is abandoned (never re-opened by the grid)
         if(!ManualReentry_Enable && rcyc) MrrAbandonClosedLevel(rlv, rpart, "old recovery request resolved without an open fill (MRR R1: no re-entry)");
         return;
      }
      if(changed) { MrSaveRec(i); MrFlush(); }
      return;
   }
   if(Mr38Complete(g_mr[i].target, g_mr[i].filled, step)) { MrComplete(i, why); return; }
   if(g_mr[i].st == MR_IN_FLIGHT)
   {
      if(MrOrderWorking(i)) { if(changed) { MrSaveRec(i); MrFlush(); } return; }   // a working order of the record: never resend
      const int cls = Ex38Classify(EX38_OP_OPEN, g_mr[i].lastRc);
      int seen = 0, fin = 0; bool cov = false; MrRequestOrders(i, seen, fin, cov);
      const bool definitive = Mr38Definitive(false, seen, fin, cov, cls == EXC_DONE || cls == EXC_PARTIAL, g_mr[i].filled > g_mr[i].fillAtReq + 1e-9);
      if(!definitive)
      {
         // R3-04: the reconciliation window is NOT evidence that the broker dropped the request -> safe hold, no resend, warning every 60 s
         if(now >= g_mr[i].deadlineMs && (g_mr[i].holdLogMs == 0 || now - g_mr[i].holdLogMs >= 60000))
         {
            if(!g_mr[i].holdCounted) { g_mr[i].holdCounted = true; g_mrUnknownHolds++; }
            g_mr[i].holdLogMs = now;
            R2Warn("MRHOLD_" + IntegerToString((long)g_mr[i].deal), StringFormat("R3 WARNING MR UNKNOWN_HOLD deal %I64u | request rc=%u %s, %I64d ms ago | broker history: %d order(s) of it, none final for the latest request, recovered %.2f of %.2f | NO resend without definitive evidence (grid of this basket keeps waiting) - Owner: check the terminal's Trade / History; the record is %sr%I64u_*",
                                                                                 g_mr[i].deal, g_mr[i].lastRc, Ex38ClassName(cls), now - (g_mr[i].deadlineMs - MrWindowMs()), seen, g_mr[i].filled, g_mr[i].target, MrNs(), g_mr[i].deal));
         }
         if(changed) { MrSaveRec(i); MrFlush(); }
         return;
      }
      // the request is definitively over without completing the record: the rest is sent when the price is still back at the entry (bounded attempts)
      g_mr[i].st = DdlActive() ? MR_SUSPENDED : (g_mr[i].filled > 0.0 ? MR_PARTIAL : MR_RETRY);
      g_mr[i].nextMs = now;
      PrintFormat("MR REQUEST OVER deal %I64u | rc=%u %s | broker history: %d order(s), final %d, latest covered %d | recovered %.2f of %.2f, no working order -> %s",
                  g_mr[i].deal, g_mr[i].lastRc, Ex38ClassName(cls), seen, fin, cov ? 1 : 0, g_mr[i].filled, g_mr[i].target, Mr38StateName(g_mr[i].st));
      changed = true;
   }
   if(changed) { MrSaveRec(i); MrFlush(); }
}
void MrReconcileAll()
{
   const int n = ArraySize(g_mr); if(n == 0) return;
   ulong keys[]; ArrayResize(keys, n); for(int k = 0; k < n; k++) keys[k] = g_mr[k].deal;
   for(int k = 0; k < n; k++) { const int i = MrFind(keys[k]); if(i >= 0 && (Mr38InFlight(g_mr[i].st) || g_mr[i].st == MR_PARTIAL)) MrReconcile(i, "RECONCILE"); }
}

// ---------------------------------------------------------------- request (one per record per call; never through TrySendOrder / LastSent*)
void MrSend(const int i0)
{
   // R3-04: the broker history decides before EVERY request (a late fill of an earlier request completes the record here, nothing is sent)
   const ulong key = g_mr[i0].deal;
   MrReconcile(i0, "PRE_SEND");
   const int i = MrFind(key); if(i < 0 || !MrRecovering(g_mr[i].st) || g_mr[i].st == MR_IN_FLIGHT || g_mr[i].st == MR_SUSPENDED) return;
   const double step = Ex38Step();
   const double vol = Mr38Remaining(g_mr[i].target, g_mr[i].filled, step);
   if(vol <= 0.0) { MrReconcile(i, "NOTHING_LEFT"); return; }
   if(!Ex38TradeSessionOpen())
   {
      MrLogOnce("SESS_" + IntegerToString((long)g_mr[i].deal) + "_" + TimeToString(TimeCurrent(), TIME_DATE), StringFormat("MR WAITS FOR THE TRADE SESSION deal %I64u | the trade schedule of %s is closed: no request, no attempt counted", g_mr[i].deal, _Symbol));
      return;
   }
   const long now = Ex38NowMs();
   if(now < g_exGraceUntil) return;
   if(g_mr[i].attempts >= MathMax(1, Exec_MaxAttempts))
   {
      g_mr[i].st = MR_STALLED; g_mr[i].attempts = 0; g_mr[i].nextMs = now + (long)MathMax(1, Exec_StallRetryMinutes) * 60000;
      PrintFormat("MR STALLED deal %I64u | %d requests rejected by the broker (last rc=%u) | next round in %d min - record kept, grid stays waiting", g_mr[i].deal, Exec_MaxAttempts, g_mr[i].lastRc, Exec_StallRetryMinutes);
      MrSaveRec(i); MrFlush();
      return;
   }
   const bool isBuy = (g_mr[i].type == POSITION_TYPE_BUY);
   const string tag = Mr38Tag(g_mr[i].deal);
   // intent BEFORE the request: a crash between OrderSend and the next write leaves REQUEST_IN_FLIGHT + the tag → the restart reconciles, never resends blindly
   g_mr[i].st = MR_IN_FLIGHT; g_mr[i].attempts++; g_mr[i].fillAtReq = g_mr[i].filled; g_mr[i].deadlineMs = now + MrWindowMs();
   g_mr[i].lastReqMsc = Ex38TickMsc(); g_mr[i].lastOrd = 0; g_mr[i].holdLogMs = 0;
   if(g_mr[i].reqMsc == 0) g_mr[i].reqMsc = g_mr[i].lastReqMsc;
   MrSaveRec(i); MrFlush();
   const long s0 = trade.m_sends;
   if(isBuy) trade.Buy(vol, _Symbol, 0.0, 0.0, 0.0, tag); else trade.Sell(vol, _Symbol, 0.0, 0.0, 0.0, tag);
   const bool sent = (trade.m_sends > s0);
   const uint rc = sent ? trade.ResultRetcode() : 0;
   const ulong ord = sent ? trade.ResultOrder() : 0;
   if(sent) g_mrReqs++;
   g_mr[i].lastRc = rc; g_mr[i].lastOrd = ord;
   if(ord > 0)
   {
      bool have = false; for(int j = 0; j < g_mr[i].nOrd; j++) if(g_mr[i].ord[j] == ord) have = true;
      if(!have && g_mr[i].nOrd < MR38_ORD) g_mr[i].ord[g_mr[i].nOrd++] = ord;
   }
   const int cls = sent ? Ex38Classify(EX38_OP_OPEN, rc) : EXC_RETRY_SLOW;
   PrintFormat("MR REQUEST deal %I64u | %s %.2f (closed %.2f, recovered %.2f) back at entry %.2f | L%d | rc=%u %s order %I64u | attempt %d",
               g_mr[i].deal, isBuy ? "BUY" : "SELL", vol, g_mr[i].target, g_mr[i].filled, g_mr[i].entry, g_mr[i].level, rc, Ex38ClassName(cls), ord, g_mr[i].attempts);
   if(cls == EXC_DONE || cls == EXC_PARTIAL || cls == EXC_INFLIGHT || cls == EXC_UNKNOWN)
   {
      MrReconcile(i, "AFTER_REQUEST");   // accepted / unknown: only the broker history completes (and removes) the record
      return;
   }
   g_mrReqNotExec++;
   g_mr[i].st = MR_RETRY; g_mr[i].nextMs = now + Ex38BackoffMs(cls, g_mr[i].attempts);
   PrintFormat("MR REQUEST NOT EXECUTED deal %I64u | rc=%u %s (definitive: the broker rejected it) | record kept, next try after %I64d ms when the price is still back at the entry (attempt %d/%d)",
               g_mr[i].deal, rc, Ex38ClassName(cls), g_mr[i].nextMs - now, g_mr[i].attempts, Exec_MaxAttempts);
   MrSaveRec(i); MrFlush();
}

// price state of every record + requests (GRID authority, inside the V26 re-entry window: in hours or SESSION_BASKET_RESCUE).
// R3: never while T1/T2, the DD Lock, an exit or a pending PairClose leg owns the basket.
void MrPumpSend()
{
   const int n = ArraySize(g_mr); if(n == 0) return;
   if(!ManualReentry_Enable) return;   // [MRR R1] M01: no price-return re-entry and no recovery request of any record (old records are only reconciled: MrReconcileAll)
   // [SAFETY S05] + a committed RPA rebase / an RPA request without a broker result: the executor owns the basket, no recovery request on top of it (fail-closed)
   if(!Saf38MrSendAllowed(DdlActive(), ExActive(), PairPendingAny(), t1Locked, hedgeTrailActive, RpaInFlight()))
   {
      if(RpaInFlight() && !(DdlActive() || ExActive() || PairPendingAny() || t1Locked || hedgeTrailActive))
      {
         g_safMrGate++;
         MrLogOnce("MRRPA_" + IntegerToString(g_rpCyc) + "_" + IntegerToString(g_rpReqN), StringFormat("MR WAITS | RPA %s with %d request(s) without a broker result owns the basket: no recovery request until it is reconciled", RpaStateName(g_rpState), RpaUnresolved()));
      }
      return;
   }
   const double off = ManualLeaveDist();
   ulong keys[]; ArrayResize(keys, n); for(int k = 0; k < n; k++) keys[k] = g_mr[k].deal;
   for(int k = 0; k < n; k++)
   {
      const int i = MrFind(keys[k]); if(i < 0) continue;
      const double px = ManualMarkPx(g_mr[i].type);
      const int st0 = g_mr[i].st;
      if(Mr38PriceState(st0))
      {
         int side = g_mr[i].side;
         const int st1 = Mr38PriceStep(st0, side, g_mr[i].entry, px, off, ManualReentry_DoubleConfirm);
         if(st1 == st0 && side == g_mr[i].side) continue;
         g_mr[i].side = side; g_mr[i].st = st1;
         if(st1 != st0) PrintFormat("MR %s -> %s deal %I64u | %s entry %.2f mark %.2f side %+d", Mr38StateName(st0), Mr38StateName(st1), g_mr[i].deal,
                                    g_mr[i].type == POSITION_TYPE_BUY ? "BUY" : "SELL", g_mr[i].entry, px, side);
         MrSaveRec(i); if(st1 != st0) MrFlush();
         if(st1 == MR_READY) MrSend(i);
         continue;
      }
      if(st0 == MR_READY)   // READY restored after a restart: only while the price is still back at the entry
      {
         if(Mr38Touch(g_mr[i].side, g_mr[i].entry, px)) MrSend(i);
         else { g_mr[i].st = MR_WAIT_RETURN; PrintFormat("MR READY -> WAIT_RETURN deal %I64u | price %.2f no longer back at %.2f", g_mr[i].deal, px, g_mr[i].entry); MrSaveRec(i); MrFlush(); }
         continue;
      }
      if(st0 == MR_STALLED)
      {
         if(Ex38NowMs() < g_mr[i].nextMs) continue;
         g_mr[i].st = MR_RETRY; g_mr[i].attempts = 0; MrSaveRec(i); MrFlush();
      }
      if((g_mr[i].st == MR_RETRY || g_mr[i].st == MR_PARTIAL) && Ex38NowMs() >= g_mr[i].nextMs && Mr38Touch(g_mr[i].side, g_mr[i].entry, px)) MrSend(i);
   }
}

// ---------------------------------------------------------------- R3 FINAL: MULTI_MANUAL_IGNORE (a 2nd different original position closed by hand in the cycle)
// Until the cycle ends: no recovery of ANY original, no compensating order / hedge. A record not sent yet -> cancelled (SKIPPED_MULTI); a request in flight
// -> RECONCILE_ONLY (never sent again, its fill up to the closed volume stays a real position of the basket). The level of an original fully closed and not
// recovered is abandoned in the level book (the grid continues at the next proven level, never re-opens it).
string MrMultiSweep()
{
   string done = "";
   const int n = ArraySize(g_mr);
   ulong keys[]; ArrayResize(keys, n); for(int k = 0; k < n; k++) keys[k] = g_mr[k].deal;
   for(int k = 0; k < n; k++)
   {
      const int i = MrFind(keys[k]); if(i < 0 || !MrRecovering(g_mr[i].st)) continue;
      if(!g_mr[i].partial) LbAbandonLevel(g_mr[i].level, StringFormat("position %I64u closed by hand, MULTI_MANUAL_IGNORE", g_mr[i].posId));
      done += StringFormat(" | record of position %I64u L%d %s", g_mr[i].posId, g_mr[i].level, Mr38StateName(g_mr[i].st));
      if(g_mr[i].st == MR_IN_FLIGHT)
      {
         g_mr[i].st = MR_RECONCILE_ONLY; g_mr[i].why = 1;
         if(g_mr[i].deadlineMs < Ex38NowMs()) g_mr[i].deadlineMs = Ex38NowMs() + MrWindowMs();
         PrintFormat("MR RECONCILE_ONLY deal %I64u | its request is in flight when MULTI_MANUAL_IGNORE starts: never sent again, a fill up to %.2f stays a real position of the basket at L%d (not closed by guess)",
                     g_mr[i].deal, g_mr[i].target, g_mr[i].level);
         MrSaveRec(i);
      }
      else
      {
         g_mrSkipMulti++;
         MrRemove(i, MR_CANCELLED, g_mr[i].filled, StringFormat("SKIPPED_MULTI: Owner rule - a 2nd original position closed by hand in this cycle -> no recovery of any; %.2f already recovered stays in the basket", g_mr[i].filled));
      }
   }
   return done;
}
void MrEnterMulti(const ulong deal, const long closeMsc, const ulong posId, const int level, const bool partial, const double vol, const string src)
{
   const bool first = !g_mrMulti;
   g_mrMulti = true; if(first) g_mrMultiOn++;
   const string done = MrMultiSweep();
   // the new close
   if(!partial) LbAbandonLevel(level, StringFormat("position %I64u closed by hand, MULTI_MANUAL_IGNORE", posId));
   MrReceiptAdd(deal, closeMsc, 0.0, level);
   g_mrReceiptOnly++;
   PrintFormat("MR MULTI_MANUAL_IGNORE %s | deal %I64u (%s) position %I64u %.2f%s L%s | originals closed by hand in this cycle %d [%s]%s -> NO recovery of any of them until the cycle ends, no compensating order; the open positions keep T1 / T2 / PairClose / DD / session / grid (level book: next grid level L%d)",
               first ? "ON" : "(already on)", deal, src, posId, vol, partial ? " PARTIAL" : "", level > 0 ? IntegerToString(level) : "?", g_mrOrigN, MrOrigText(), done, LbNextLevel(CountPositions()));
   MrSaveMeta(); MrFlush();
   if(GgAny()) GgSaveAll();
   SessRescueRefresh();
}

// ---------------------------------------------------------------- manual close → one new record / merge / abandon
long MrOpenMsc(const ulong posId)
{
   if(PositionSelectByTicket(posId) && (ulong)PositionGetInteger(POSITION_IDENTIFIER) == posId) return PositionGetInteger(POSITION_TIME_MSC);
   for(int i = 0; i < PositionsTotal(); i++)
   {
      const ulong t = PositionGetTicket(i);
      if(t != 0 && PositionSelectByTicket(t) && (ulong)PositionGetInteger(POSITION_IDENTIFIER) == posId) return PositionGetInteger(POSITION_TIME_MSC);
   }
   if(!HistorySelectByPosition(posId)) return 0;
   for(int k = 0; k < HistoryDealsTotal(); k++)
   {
      const ulong d = HistoryDealGetTicket(k);
      const long en = HistoryDealGetInteger(d, DEAL_ENTRY);
      if(en == DEAL_ENTRY_IN || en == DEAL_ENTRY_INOUT) return HistoryDealGetInteger(d, DEAL_TIME_MSC);
   }
   return 0;
}

// a manual close deal (OnTradeTransaction or the history scan): never overwrites another record
void MrOnManualClose(const ulong deal, const string src)
{
   if(deal == 0 || MrFind(deal) >= 0 || MrReceipted(deal)) { g_mrIgnored++; return; }
   if(!HistoryDealSelect(deal)) { const datetime now = TimeCurrent(); HistorySelect(now - 30 * 86400, now + 60); }
   if(!HistoryDealSelect(deal)) { MrFreezeGrid(MRF_DEAL_UNREADABLE, StringFormat("manual close deal %I64u (%s) not readable", deal, src)); return; }
   const long closeMsc = HistoryDealGetInteger(deal, DEAL_TIME_MSC);
   const ulong posId = (ulong)HistoryDealGetInteger(deal, DEAL_POSITION_ID);
   const double vol = HistoryDealGetDouble(deal, DEAL_VOLUME);
   const int nNow = CountPositions();
   if(closeMsc < g_mrFloorMsc) { g_mrIgnored++; return; }
   if(g_mrMetaCycle == 0 && nNow > 0) g_mrMetaCycle = MrCycleId();
   const bool mrrThisCycle = (nNow > 0 || g_cycStartMsc > 0) && !(g_mrrCycFirstOrd > 0 && posId < g_mrrCycFirstOrd);   // [MRR R1] M06: not a deal of an earlier (finalized) cycle
   if(mrrThisCycle) g_mrrManualDeals++;   // [MRR R1] M06 log: deals of the running (not yet finalized) cycle only
   if(nNow <= 0)
   {
      // [MRR R1] M06: one concise line per flat basket whose cycle is not finalized yet (every deal is still recorded: receipt)
      if(!g_mrrFullManual && mrrThisCycle) { g_mrrFullManual = true; g_mrrFullCloses++; PrintFormat("FULL MANUAL BASKET CLOSE | deal %I64u (%s) position %I64u | broker positions of the EA: 0 | no re-entry (MRR R1) | the cycle is finalized on the next tick, then a new L1 when session / RSI / volume / margin allow", deal, src, posId); }
      MrReceiptAdd(deal, closeMsc); MrSaveMeta(); MrFlush();
      return;
   }
   if(MrNoRecover(posId))
   {
      PrintFormat("MR MANUAL CLOSE deal %I64u (%s) | position %I64u is a PairClose leg the EA was closing -> counted as that close, no recovery", deal, src, posId);
      MrReceiptAdd(deal, closeMsc); MrSaveMeta(); MrFlush();
      return;
   }
   int posType = -1; double openPx = 0.0, v2 = 0.0;
   if(!GetClosedDealOpenInfo(deal, posType, openPx, v2))
   {
      MrFreezeGrid(MRF_DEAL_UNREADABLE, StringFormat("manual close deal %I64u (%s): original entry not readable", deal, src));
      MrReceiptAdd(deal, closeMsc); MrSaveMeta(); MrFlush();
      return;
   }
   double left = 0.0;
   const bool partial = PositionOpenById(posId, left) && left > 0.0;
   // R3: the level book steers the grid of this basket from its first manual close (the snapshot of the last tick = V26 rank before this close)
   LbActivate(StringFormat("manual close deal %I64u of position %I64u", deal, posId));
   const int level = LbLevelOfPos(posId);
   if(level <= 0) MrFreezeGrid(MRF_LEVEL_UNPROVEN, StringFormat("manual close deal %I64u: position %I64u is not in the level book", deal, posId));
   // V38 R1 (kept, Owner input): a PARTIAL close re-enters the closed volume as an EXTRA ticket at the same level; the level book proves the level,
   // ManualPartial_FreezeGrid=true keeps the R1 policy (no further grid level for this basket)
   if(partial && !g_cycIndexShift)
   {
      g_cycIndexShift = true;
      PrintFormat("=== MANUAL PARTIAL CLOSE | position %I64u (L%d): %.2f closed, %.2f still open | %s ===",   // [MRR R1] text: no re-entry ticket any more
                  posId, level, vol, left, ManualPartial_FreezeGrid ? "ManualPartial_FreezeGrid=true: GRID FROZEN for this basket (R1 policy; exits / T1 / T2 / PairClose / DD keep working)" : "ManualPartial_FreezeGrid=false: the grid continues at the level-book level");
   }
   const string side = posType == POSITION_TYPE_BUY ? "BUY" : "SELL";
   // R3 FINAL (Owner 23/10/2026, item 2): the ORIGINAL this close stands for (same id, or a re-entry / extra ticket of the same proven level), counted per CYCLE
   const int oj = MrOrigFind(posId, level);
   const int ri = MrFindOrigRec(posId, level, true);
   // [MRR R1] M01: re-entry removed -> every manual close of the running basket is REENTRY_OFF (receipt, level abandoned when fully closed); the R3 FINAL decision
   // (one original recovered / MULTI_MANUAL_IGNORE) only while ManualReentry_Enable
   int act = ManualReentry_Enable ? Mr38CycleDecision(ManualReentry_Enable, g_mrMulti, ri >= 0, MrFindOrigRec(posId, level, false) >= 0, oj >= 0, g_mrOrigN) : MRB_REENTRY_OFF;
   // invariant: at most ONE record with the right to recover. A recovering record of ANOTHER original here means the detector lost an original
   // (it cannot happen by the rule) -> fail-safe: this is the 2nd original, no recovery of any
   if(act == MRB_CREATE && MrRecoveringCount() > 0)
   {
      PrintFormat("MR INVARIANT | deal %I64u position %I64u L%d: another original still has a recovery record although the cycle counts %d original(s) [%s] -> treated as the 2nd original (MULTI_MANUAL_IGNORE)",
                  deal, posId, level, g_mrOrigN, MrOrigText());
      act = MRB_ABANDON;
   }
   if(oj >= 0) g_mrSameOrigAgain++;
   MrOrigAdd(posId, level);
   if(ManualReentry_Enable)   // [MRR R1] M06: the recovery decision line only while re-entry exists (the REENTRY_OFF branch prints one concise line)
      PrintFormat("MR MANUAL CLOSE deal %I64u (%s) | position %I64u %s %.2f%s L%s | original %s | originals closed by hand in this cycle %d [%s] | multi %s -> %s",
                  deal, src, posId, side, vol, partial ? " PARTIAL" : "", level > 0 ? IntegerToString(level) : "?", oj >= 0 ? StringFormat("ALREADY SEEN (%I64u)", g_mrOrigPos[oj]) : "NEW",
                  g_mrOrigN, MrOrigText(), g_mrMulti ? "ON" : "off", Mr38DecisionName(act));
   if(act == MRB_ABANDON)
   {
      MrEnterMulti(deal, closeMsc, posId, level, partial, vol, src);
      return;
   }
   // R3-02: T1 / T2 own the basket -> no recovery
   if(t1Locked || hedgeTrailActive)
   {
      if(!partial) LbAbandonLevel(level, "closed by hand while T1/T2 own the basket");
      MrReceiptAdd(deal, closeMsc, 0.0, level); g_mrReceiptOnly++;
      PrintFormat("MANUAL CLOSE | deal %I64u (%s) position %I64u %s %.2f%s L%d | T1/T2 own the basket: they keep managing the %d open position(s) | no re-entry", deal, src, posId, side, vol, partial ? " PARTIAL" : "", level, nNow);   // [MRR R1] M06
      MrSaveMeta(); MrFlush();
      return;
   }
   if(act == MRB_MERGE)
   {
      // the same original position closed by hand again (another part / its re-entry ticket): ONE original — its record recovers the sum
      const double t0 = g_mr[ri].target;
      g_mr[ri].target = NormalizeDouble(g_mr[ri].target + vol, 8); g_mr[ri].nDeals++; if(g_mr[ri].posId == posId) g_mr[ri].partial = partial; g_mrMerged++;
      MrReceiptAdd(deal, closeMsc, 0.0, level);
      PrintFormat("MR MERGED deal %I64u (%s) into the record of deal %I64u | same original (position %I64u, L%d) %s: %.2f more closed by hand -> target %.2f -> %.2f (%d deals, still ONE original of the cycle) | state %s",
                  deal, src, g_mr[ri].deal, g_mr[ri].posId, level, side, vol, t0, g_mr[ri].target, g_mr[ri].nDeals, Mr38StateName(g_mr[ri].st));
      MrSaveRec(ri); MrSaveMeta(); MrFlush();
      skipGridThisTick = true;
      return;
   }
   if(act == MRB_RECEIPT_ONLY || act == MRB_REENTRY_OFF)
   {
      MrReceiptAdd(deal, closeMsc, 0.0, level); g_mrReceiptOnly++;
      if(!partial) LbAbandonLevel(level, act == MRB_REENTRY_OFF ? "closed by hand, no re-entry (MRR R1)" : (g_mrMulti ? "closed by hand during MULTI_MANUAL_IGNORE" : "closed by hand, its record is reconcile-only"));
      // [MRR R1] M06: one concise line per manual close of the running basket
      PrintFormat("MANUAL CLOSE | deal %I64u (%s) position %I64u %s %.2f%s L%d | %s | basket keeps %d open position(s), level book next level never re-opens a closed level",
                  deal, src, posId, side, vol, partial ? " PARTIAL" : "", level,
                  act == MRB_REENTRY_OFF ? (partial ? "no re-entry, level kept by the open part" : "no re-entry, level abandoned") : (g_mrMulti ? "MULTI_MANUAL_IGNORE" : "its original's request is reconcile-only"), nNow);
      MrSaveMeta(); MrFlush();
      if(GgAny()) GgSaveAll();
      SessRescueRefresh();
      return;
   }
   if(ArraySize(g_mr) >= MR38_MAX)
   {
      MrFreezeGrid(MRF_RECORD_CAP, StringFormat("%d recovery records pending, deal %I64u not recorded", ArraySize(g_mr), deal));
      MrReceiptAdd(deal, closeMsc, 0.0, level); MrSaveMeta(); MrFlush();
      return;
   }
   const int i = ArraySize(g_mr); ArrayResize(g_mr, i + 1);
   ZeroMemory(g_mr[i]);
   g_mr[i].deal = deal; g_mr[i].posId = posId; g_mr[i].cycle = MrCycleId(); g_mr[i].type = posType; g_mr[i].entry = PriceN(openPx);
   g_mr[i].target = NormalizeDouble(vol, 8); g_mr[i].filled = 0.0; g_mr[i].level = level; g_mr[i].partial = partial; g_mr[i].nDeals = 1;
   g_mr[i].detectMsc = Ex38TickMsc(); g_mr[i].closeMsc = closeMsc; g_mr[i].st = MR_WAIT_PRICE;
   g_mr[i].side = Mr38Away(g_mr[i].entry, ManualMarkPx(posType), ManualLeaveDist());
   g_mrCreated++; if(ArraySize(g_mr) > g_mrMaxActive) g_mrMaxActive = ArraySize(g_mr);
   PrintFormat("MR CREATED deal %I64u (%s) | position %I64u %s %.2f closed by hand%s @ original entry %.2f | level %s (level book) | cycle %I64d | side %+d | %s | the ONLY original position closed by hand in this cycle -> recovery | pending %d -> %d",
               deal, src, posId, side, vol, partial ? StringFormat(" (PARTIAL, %.2f still open)", left) : "", g_mr[i].entry,
               level > 0 ? "L" + IntegerToString(level) : "not proven", g_mr[i].cycle, g_mr[i].side, ManualReentry_DoubleConfirm ? "double confirmation" : "single return (V26)", i, i + 1);
   MrSaveRec(i); MrSaveMeta(); MrFlush();
   if(StringFind(src, "RESTORE") == 0) MrReconcile(i, "CREATED_AT_RESTORE");   // a request before the crash may have filled: the tag decides
   if(GgAny()) GgSaveAll();
   SessRescueRefresh();
   skipGridThisTick = true;
}
// a recovery fill reported by OnTradeTransaction: reconcile that record now (the history decides; a lost event is caught by MrReconcileAll)
void MrOnEntryDeal(const ulong deal)
{
   if(!HistoryDealSelect(deal)) return;
   const string c = HistoryDealGetString(deal, DEAL_COMMENT);
   const ulong o = (ulong)HistoryDealGetInteger(deal, DEAL_ORDER);
   for(int i = 0; i < ArraySize(g_mr); i++)
   {
      bool mine = Mr38TagIs(c, g_mr[i].deal);
      for(int j = 0; j < g_mr[i].nOrd && !mine; j++) if(g_mr[i].ord[j] == o) mine = true;
      if(mine) { MrReconcile(i, "EVENT"); return; }
   }
   // the tag of a record that is no longer active (late duplicate fill): surplus check now
   if(StringFind(c, "R2MR|") == 0) MrSurplusCheck((ulong)StringToInteger(StringSubstr(c, 5)), "EVENT");
}

// manual closes not seen by OnTradeTransaction (lost event, EA off): the deal history of this cycle (receipts / floor: never twice)
void MrScanHistory(const string why)
{
   g_mrLastScan = TimeCurrent();
   if(CountPositions() <= 0) return;
   MrSurplusScan(why);
   const long cyc = MrCycleId(); if(cyc <= 0) return;
   const long from = MathMax(cyc, g_mrFloorMsc);
   if(!HistorySelect((datetime)(from / 1000), TimeCurrent() + 60)) return;
   ulong cand[]; int m = 0;
   ulong fdeal[], fpos[]; int nf = 0;   // [MRR R1] M03: manual-close deals with another magic (ownership checked after this loop: it replaces the history cache)
   for(int k = 0; k < HistoryDealsTotal(); k++)
   {
      const ulong d = HistoryDealGetTicket(k);
      if(d == 0 || HistoryDealGetString(d, DEAL_SYMBOL) != _Symbol) continue;
      const bool ownMagic = ((ulong)HistoryDealGetInteger(d, DEAL_MAGIC) == Magic);
      const long en = HistoryDealGetInteger(d, DEAL_ENTRY);
      if(en != DEAL_ENTRY_OUT && en != DEAL_ENTRY_INOUT && en != DEAL_ENTRY_OUT_BY) continue;   // [MRR R1] M03: + manual "Close By" (only manual reasons are kept below)
      if(HistoryDealGetInteger(d, DEAL_TIME_MSC) < from) continue;
      if(!Mr38IsManualReason(Mr38DealReason(d))) continue;
      if(MrFind(d) >= 0 || MrReceipted(d)) continue;
      if(!ownMagic) { ArrayResize(fdeal, nf + 1); ArrayResize(fpos, nf + 1); fdeal[nf] = d; fpos[nf] = (ulong)HistoryDealGetInteger(d, DEAL_POSITION_ID); nf++; continue; }
      ArrayResize(cand, m + 1); cand[m++] = d;
   }
   for(int a = 0; a < nf; a++) if(MrrPosOpenedByEa(fpos[a])) { ArrayResize(cand, m + 1); cand[m++] = fdeal[a]; g_mrrForeignMagic++; }   // [MRR R1] M03
   for(int k = 0; k < m; k++)
   {
      if(MrrStaleCloseOfFinishedCycle(cand[k], "HISTORY_SCAN_" + why)) continue;   // [MRR R1] M02: a deal of a finished cycle never touches the running basket
      g_mrScanFound++;
      PrintFormat("MR HISTORY SCAN (%s) | manual close deal %I64u was not processed by OnTradeTransaction -> processed now", why, cand[k]);
      // [SAFETY S05] same handlers as the event path (V38OnManualClose): a manual close in a rebase / subgrid epoch HALTs RPA (fail-closed) — the HOTFIX scan skipped it
      const int rs0 = g_rpState;
      RpaOnManualClose(cand[k]);
      if(rs0 != g_rpState) g_safScanHalt++;
      MrOnManualClose(cand[k], "HISTORY_SCAN_" + why);
   }
}
// R3 (restart, level book off): positions of this cycle FULLY closed by hand that are not processed yet (id + open time) — part of the V26 rank
int MrUnprocessedManualClosed(ulong &pid[], long &msc[])
{
   ArrayResize(pid, 0); ArrayResize(msc, 0);
   const long cyc = MrCycleId(); if(cyc <= 0) return 0;
   const long from = MathMax(cyc, g_mrFloorMsc);
   if(!HistorySelect((datetime)(from / 1000), TimeCurrent() + 60)) return 0;
   ulong cand[]; int m = 0;
   ulong fpos[]; int nf = 0;   // [MRR R1] M03: positions of manual-close deals with another magic (ownership checked after this loop: it replaces the history cache)
   for(int k = 0; k < HistoryDealsTotal(); k++)
   {
      const ulong d = HistoryDealGetTicket(k);
      if(d == 0 || HistoryDealGetString(d, DEAL_SYMBOL) != _Symbol) continue;
      const bool ownMagic = ((ulong)HistoryDealGetInteger(d, DEAL_MAGIC) == Magic);
      const long en = HistoryDealGetInteger(d, DEAL_ENTRY);
      if((en != DEAL_ENTRY_OUT && en != DEAL_ENTRY_INOUT && en != DEAL_ENTRY_OUT_BY) || HistoryDealGetInteger(d, DEAL_TIME_MSC) < from) continue;   // [MRR R1] M03: + manual "Close By"
      if(!Mr38IsManualReason(Mr38DealReason(d)) || MrFind(d) >= 0 || MrReceipted(d)) continue;
      const ulong p = (ulong)HistoryDealGetInteger(d, DEAL_POSITION_ID);
      double left = 0.0; if(PositionOpenById(p, left)) continue;   // partial: the position is still open (already ranked)
      if(!ownMagic) { bool hf = false; for(int a = 0; a < nf; a++) if(fpos[a] == p) hf = true; if(!hf) { ArrayResize(fpos, nf + 1); fpos[nf++] = p; } continue; }
      bool have = false; for(int a = 0; a < m; a++) if(cand[a] == p) have = true;
      if(!have) { ArrayResize(cand, m + 1); cand[m++] = p; }
   }
   for(int a = 0; a < nf; a++)   // [MRR R1] M03
   {
      bool have = false; for(int b = 0; b < m; b++) if(cand[b] == fpos[a]) have = true;
      if(!have && MrrPosOpenedByEa(fpos[a])) { ArrayResize(cand, m + 1); cand[m++] = fpos[a]; }
   }
   int n = 0;
   for(int a = 0; a < m; a++)
   {
      const long om = MrOpenMsc(cand[a]); if(om <= 0) continue;
      ArrayResize(pid, n + 1); ArrayResize(msc, n + 1); pid[n] = cand[a]; msc[n] = om; n++;
   }
   return n;
}
void MrScanIfNeeded(const int total)
{
   if(total <= 0) return;
   if(g_mrSurOutstanding && !DdlActive() && !ExActive()) MrSurplusScan("RETRY");   // R3-01: an open surplus is followed every tick (result / backoff), not only every 60 s
   if(g_mrLastCount >= 0 && total < g_mrLastCount) MrScanHistory("COUNT_DROP");
   else if(TimeCurrent() - g_mrLastScan >= 60) MrScanHistory("PERIODIC");
}

// ---------------------------------------------------------------- authority changes
void MrOnExitCommit()
{
   const int n = ArraySize(g_mr); if(n == 0) return;
   ulong keys[]; ArrayResize(keys, n); for(int k = 0; k < n; k++) keys[k] = g_mr[k].deal;
   for(int k = 0; k < n; k++)
   {
      const int i = MrFind(keys[k]); if(i < 0) continue;
      if(Mr38InFlight(g_mr[i].st))
      {
         g_mr[i].st = MR_CANCEL_RECONCILE; if(g_mr[i].deadlineMs < Ex38NowMs()) g_mr[i].deadlineMs = Ex38NowMs() + MrWindowMs();
         PrintFormat("MR CANCEL_RECONCILE deal %I64u | BASKET_EXITING committed while its request is in flight: a late fill is closed with the basket", g_mr[i].deal);
         MrSaveRec(i); MrFlush();
      }
      else MrRemove(i, MR_CANCELLED, g_mr[i].filled, "BASKET_EXITING committed: no recovery of a basket that exits");
   }
}
// R3-02: T1 / T2 own the basket — exit protection before any recovery. Records not sent yet are dropped; a request in flight is only reconciled
// (its fill is a position of the basket: T1 / T2 put the exit level on it, the exit closes it).
void MrOnT1Priority()
{
   const int n = ArraySize(g_mr); if(n == 0) return;
   ulong keys[]; ArrayResize(keys, n); for(int k = 0; k < n; k++) keys[k] = g_mr[k].deal;
   for(int k = 0; k < n; k++)
   {
      const int i = MrFind(keys[k]); if(i < 0 || !MrRecovering(g_mr[i].st) || g_mr[i].st == MR_SUSPENDED) continue;
      if(g_mr[i].st == MR_IN_FLIGHT)
      {
         g_mr[i].st = MR_RECONCILE_ONLY; g_mr[i].why = 2;
         if(g_mr[i].deadlineMs < Ex38NowMs()) g_mr[i].deadlineMs = Ex38NowMs() + MrWindowMs();
         PrintFormat("MR RECONCILE_ONLY deal %I64u | T1/T2 own the basket while its request is in flight: no further request; a fill is a position of the basket and leaves with the T1/T2 exit", g_mr[i].deal);
         MrSaveRec(i); MrFlush();
      }
      else
      {
         g_mrSkipT1++;
         MrRemove(i, MR_CANCELLED, g_mr[i].filled, StringFormat("SKIPPED_T1: T1/T2 own the basket (exit protection first, R3-02) - %s record not sent", Mr38StateName(g_mr[i].st)));
      }
   }
}
void MrOnDdActivate()
{
   for(int i = 0; i < ArraySize(g_mr); i++)
   {
      if(Mr38Terminal(g_mr[i].st) || Mr38InFlight(g_mr[i].st) || g_mr[i].st == MR_SUSPENDED) continue;
      PrintFormat("MR SUSPENDED deal %I64u (%s) | the DD Lock owns the basket: no recovery request, a price return does not open anything", g_mr[i].deal, Mr38StateName(g_mr[i].st));
      g_mr[i].st = MR_SUSPENDED; g_mrSuspends++;
      MrSaveRec(i);
   }
   MrFlush();
}
// ResetCycleState: basket flat → every record of the finished cycle is cancelled (in flight → CANCEL_RECONCILE); open positions (restore) → memory only
void MrOnCycleReset()
{
   if(CountPositions() > 0)
   {
      ArrayResize(g_mr, 0); g_mrGridFreeze = false; g_mrFreezeWhy = 0; g_mrNoRecN = 0; g_mrRcptN = 0; g_mrRcptNext = 0; g_mrMetaCycle = 0; g_mrOrigN = 0; g_mrMulti = false;
      MrSurplusLedgerClear(); g_mrSpAttempts = 0; g_mrSpNextMs = 0; g_mrSurOutstanding = false;
      return;
   }
   if(ArraySize(g_mr) == 0 && g_mrMetaCycle == 0 && !g_mrGridFreeze && g_mrNoRecN == 0 && g_mrOrigN == 0 && !g_mrMulti && g_mrSpKey == 0) return;
   if(g_mrMulti || g_mrOrigN > 0) PrintFormat("MR CYCLE END | originals closed by hand %d [%s] | MULTI_MANUAL_IGNORE %s -> cleared for the next cycle", g_mrOrigN, MrOrigText(), g_mrMulti ? "was ON" : "off");
   const int n = ArraySize(g_mr);
   ulong keys[]; ArrayResize(keys, n); for(int k = 0; k < n; k++) keys[k] = g_mr[k].deal;
   for(int k = 0; k < n; k++)
   {
      const int i = MrFind(keys[k]); if(i < 0) continue;
      if(Mr38InFlight(g_mr[i].st))
      {
         if(g_mr[i].st != MR_CANCEL_RECONCILE) PrintFormat("MR CANCEL_RECONCILE deal %I64u | basket flat while its request is in flight: no new L1 until it is reconciled", g_mr[i].deal);
         g_mr[i].st = MR_CANCEL_RECONCILE; MrSaveRec(i);
      }
      else MrRemove(i, MR_CANCELLED, g_mr[i].filled, "BASKET_FLAT: the cycle ended, no recovery order of the old cycle");
   }
   // receipts stay (bounded ring, across cycles): a very late fill of a finished cycle is still recognised and closed (MrSurplusCheck)
   g_mrGridFreeze = false; g_mrFreezeWhy = 0; g_mrNoRecN = 0; g_mrMetaCycle = 0; g_mrOrigN = 0; g_mrMulti = false;
   MrSurplusLedgerClear(); g_mrSpAttempts = 0; g_mrSpNextMs = 0; g_mrSurOutstanding = false;   // flat: no tagged position left to close
   g_mrFloorMsc = MathMax(g_mrFloorMsc, Ex38TickMsc());
   if(ArraySize(g_mr) == 0) { if(MrPersistOn()) GlobalVariablesDeleteAll(MrNs()); MrSaveMeta(); }
   else MrSaveMeta();
   MrFlush();
}
// a fill of a CANCEL_RECONCILE record (its cycle ended) is closed at once; never adopted as a new basket. true = an exit was committed.
bool MrOrphanGuard()
{
   if(!MrAnyCancelReconcile()) return false;
   MrReconcileAll();
   for(int i = 0; i < ArraySize(g_mr); i++)
   {
      if(g_mr[i].st != MR_CANCEL_RECONCILE) continue;
      const ulong t = MrTaggedOpen(g_mr[i].deal);
      if(t == 0) continue;
      // [SAFETY S06] the basket exit closes EVERY position of the EA: only when every open position is an orphan fill of a CANCEL_RECONCILE record (the cycle of the
      // record is over). Other positions of a running basket (cycle id changed by a lost record, ...) -> the basket is never closed for it: RECONCILE_ONLY
      int orphans = 0, open = 0;
      for(int k = PositionsTotal() - 1; k >= 0; k--)
      {
         const ulong pt = PositionGetTicket(k);
         if(pt == 0 || !PositionSelectByTicket(pt) || !IsOursPos()) continue;
         open++;
         const string pc = PositionGetString(POSITION_COMMENT);
         for(int j = 0; j < ArraySize(g_mr); j++) if(g_mr[j].st == MR_CANCEL_RECONCILE && Mr38TagIs(pc, g_mr[j].deal)) { orphans++; break; }
      }
      if(Saf38OrphanAction(open, orphans) == SAF_ORPH_KEEP)
      {
         g_safOrphanKeep++;
         g_mr[i].st = MR_RECONCILE_ONLY; MrSaveRec(i); MrFlush();
         PrintFormat("MR ORPHAN FILL KEPT (SAFETY) | position %I64u = recovery request of deal %I64u, but %d other position(s) of a running basket are open -> the basket is NOT closed; the record becomes RECONCILE_ONLY (its fill is a position of the basket, managed by T1 / T2 / exit)", t, g_mr[i].deal, open - orphans);
         continue;
      }
      g_mrOrphanCloses++;
      PrintFormat("MR ORPHAN FILL | position %I64u = recovery request of deal %I64u that filled after its cycle ended -> closed now (never a new L1)", t, g_mr[i].deal);
      ExCommitOrphanClose();
      return true;
   }
   return false;
}

// ---------------------------------------------------------------- restart
// step 1 (before the level book and the GLOBAL restore): records + cycle meta from the terminal variables
void MrRestoreLoad()
{
   ArrayResize(g_mr, 0); g_mrRcptN = 0; g_mrRcptNext = 0; g_mrFloorMsc = 0; g_mrMetaCycle = 0; g_mrGridFreeze = false; g_mrFreezeWhy = 0;
   g_mrrRestLvN = 0; ArrayResize(g_mrrRestLv, 0);   // [MRR R1] M05
   g_mrNoRecN = 0; g_mrOrigN = 0; g_mrMulti = false; g_mrLastCount = -1; g_mrLastScan = 0; g_mrOnce = ""; g_mrRestoredN = 0;
   MrSurplusLedgerClear(); g_mrSpAttempts = 0; g_mrSpNextMs = 0; g_mrSurOutstanding = false;
   const string ns = MrNs();
   ulong keys[]; int nk = 0; bool any = false;
   for(int i = GlobalVariablesTotal() - 1; i >= 0; i--)
   {
      const string nm = GlobalVariableName(i);
      if(StringFind(nm, ns) != 0) continue;
      any = true;
      if(StringFind(nm, ns + "r") != 0) continue;
      const string rest = StringSubstr(nm, StringLen(ns) + 1);
      const int us = StringFind(rest, "_"); if(us <= 0) continue;
      const ulong d = (ulong)StringToInteger(StringSubstr(rest, 0, us));
      bool have = false; for(int k = 0; k < nk; k++) if(keys[k] == d) { have = true; break; }
      if(!have) { ArrayResize(keys, nk + 1); keys[nk++] = d; }
   }
   if(!any) return;
   const string idWhy = OfhIdCheck(ns, Magic);
   if(idWhy != "") { PrintFormat("MR RECORDS %s IGNORED | identity mismatch (%s) - cleared", ns, idWhy); GlobalVariablesDeleteAll(ns); GlobalVariablesFlush(); return; }
   const long cyc = MrCycleId(); const int nPos = CountPositions();
   const bool sameMeta = (cyc > 0 && nPos > 0 && (long)GlobalVariableGet(ns + "cy") == cyc);
   // receipts: always (bounded ring across cycles); grid freeze / PairClose legs / originals of the cycle + MULTI_MANUAL_IGNORE / surplus close in flight:
   // only for the same cycle
   g_mrRcptN = MathMin(MR38_RCPT, (int)GlobalVariableGet(ns + "qn")); g_mrRcptNext = (int)GlobalVariableGet(ns + "qx") % MR38_RCPT;
   for(int j = 0; j < g_mrRcptN; j++)
   {
      g_mrRcpt[j] = (ulong)GlobalVariableGet(ns + "q" + IntegerToString(j)); g_mrRcptMsc[j] = (long)GlobalVariableGet(ns + "m" + IntegerToString(j));
      g_mrRcptTgt[j] = GlobalVariableGet(ns + "g" + IntegerToString(j)); g_mrRcptSur[j] = GlobalVariableGet(ns + "w" + IntegerToString(j));
      g_mrRcptLv[j] = (int)GlobalVariableGet(ns + "h" + IntegerToString(j));
   }
   g_mrFloorMsc = (long)GlobalVariableGet(ns + "fl");
   if(sameMeta)
   {
      g_mrGridFreeze = GlobalVariableGet(ns + "fz") > 0.5; g_mrFreezeWhy = (int)GlobalVariableGet(ns + "fw");
      g_mrNoRecN = MathMin(MR38_NOREC, (int)GlobalVariableGet(ns + "un"));
      for(int j = 0; j < g_mrNoRecN; j++) g_mrNoRec[j] = (ulong)GlobalVariableGet(ns + "u" + IntegerToString(j));
      g_mrOrigN = MathMin(MR38_ORIG, (int)GlobalVariableGet(ns + "xn")); g_mrMulti = GlobalVariableGet(ns + "xm") > 0.5;
      for(int j = 0; j < g_mrOrigN; j++) { g_mrOrigPos[j] = (ulong)GlobalVariableGet(ns + "xp" + IntegerToString(j)); g_mrOrigLv[j] = (int)GlobalVariableGet(ns + "xl" + IntegerToString(j)); }
      g_mrSpKey = (ulong)GlobalVariableGet(ns + "sk"); g_mrSpPos = (ulong)GlobalVariableGet(ns + "sp"); g_mrSpOrd = (ulong)GlobalVariableGet(ns + "so");
      g_mrSpVol = GlobalVariableGet(ns + "sv"); g_mrSpMsc = (long)GlobalVariableGet(ns + "sm"); g_mrSpRc = (uint)GlobalVariableGet(ns + "sr"); g_mrSpAttempts = (int)GlobalVariableGet(ns + "sa");
      g_mrSpFull = GlobalVariableGet(ns + "sf") > 0.5;
   }
   else g_mrFloorMsc = MathMax(g_mrFloorMsc, cyc);
   g_mrMetaCycle = (cyc > 0 && nPos > 0) ? cyc : 0;
   int cancelled = 0, incomplete = 0;
   for(int k = 0; k < nk; k++)
   {
      const string key = MrKey(keys[k]);
      if(!GlobalVariableCheck(key + "s")) { incomplete++; GlobalVariablesDeleteAll(key); PrintFormat("MR RECORD deal %I64u INCOMPLETE (written partly before a stop) -> rebuilt from its manual close deal", keys[k]); continue; }
      Mr38Rec r; ZeroMemory(r);
      r.deal = keys[k]; r.posId = (ulong)GlobalVariableGet(key + "p"); r.cycle = (long)GlobalVariableGet(key + "c"); r.type = (int)GlobalVariableGet(key + "t");
      r.entry = GlobalVariableGet(key + "e"); r.target = GlobalVariableGet(key + "v"); r.filled = GlobalVariableGet(key + "f"); r.level = (int)GlobalVariableGet(key + "l");
      r.partial = GlobalVariableGet(key + "a") > 0.5; r.detectMsc = (long)GlobalVariableGet(key + "d"); r.closeMsc = (long)GlobalVariableGet(key + "x");
      r.side = (int)GlobalVariableGet(key + "sd"); r.attempts = (int)GlobalVariableGet(key + "n"); r.reqMsc = (long)GlobalVariableGet(key + "rq");
      r.lastRc = (uint)GlobalVariableGet(key + "rc"); r.nOrd = MathMin(MR38_ORD, (int)GlobalVariableGet(key + "no"));
      for(int j = 0; j < r.nOrd; j++) r.ord[j] = (ulong)GlobalVariableGet(key + "o" + IntegerToString(j));
      r.fillPos = (ulong)GlobalVariableGet(key + "fp"); r.st = (int)GlobalVariableGet(key + "s");
      r.nDeals = (int)GlobalVariableGet(key + "nd"); r.why = (int)GlobalVariableGet(key + "wy");
      r.lastOrd = (ulong)GlobalVariableGet(key + "lo"); r.lastReqMsc = (long)GlobalVariableGet(key + "lr");
      r.fillAtReq = r.filled; r.nextMs = 0; r.deadlineMs = Ex38NowMs() + MrWindowMs();
      if(Mr38Terminal(r.st))   // FILLED_CONFIRMED / REMOVE_PENDING / CANCELLED: never revived, the removal is finished now
      {
         PrintFormat("MR RECORD deal %I64u was %s before the stop -> removal finished, not revived", r.deal, Mr38StateName(r.st));
         GlobalVariablesDeleteAll(key); MrReceiptAdd(r.deal, r.closeMsc, r.st == MR_FILLED ? r.target : r.filled, r.level); continue;
      }
      const bool sameCycle = (r.cycle == cyc && nPos > 0);
      // [SAFETY S06] re-entry switched off with a request in flight in the SAME open cycle -> RECONCILE_ONLY (never asked again, a fill stays a position of the running
      // basket). HOTFIX: CANCEL_RECONCILE -> MrOrphanGuard closed the WHOLE running basket when that request filled.
      const int sra = Saf38MrRestoreAction(sameCycle, ManualReentry_Enable, Mr38InFlight(r.st), r.st == MR_CANCEL_RECONCILE);
      if(sra == SAF_MRR_RECONCILE_ONLY)
      {
         r.st = MR_RECONCILE_ONLY; r.why = 3;
         g_exGraceUntil = MathMax(g_exGraceUntil, Ex38NowMs() + MathMax(1, Exec_ConfirmMs));
         const int i = ArraySize(g_mr); ArrayResize(g_mr, i + 1); g_mr[i] = r; MrSaveRec(i);
         g_mrRestoredN++; g_safMrReconcileOnly++;
         PrintFormat("MR RECORD deal %I64u (cycle %I64d) had a request in flight and ManualReentry_Enable=false now -> RECONCILE_ONLY (no further request; a fill is a position of the running basket, never closed as an orphan)", r.deal, r.cycle);
         continue;
      }
      if(!sameCycle || !ManualReentry_Enable)
      {
         if(Mr38InFlight(r.st))
         {
            r.st = MR_CANCEL_RECONCILE;
            const int i = ArraySize(g_mr); ArrayResize(g_mr, i + 1); g_mr[i] = r; MrSaveRec(i);
            PrintFormat("MR RECORD deal %I64u (cycle %I64d, now %I64d) had a request in flight -> CANCEL_RECONCILE (a late fill is closed, never a new L1)", r.deal, r.cycle, cyc);
            continue;
         }
         PrintFormat("MR RECORD deal %I64u CANCELLED at restart | %s", r.deal, !ManualReentry_Enable ? "ManualReentry_Enable=false" : StringFormat("its cycle %I64d is over (now %I64d, positions %d)", r.cycle, cyc, nPos));
         GlobalVariablesDeleteAll(key); MrReceiptAdd(r.deal, r.closeMsc, r.filled, r.level); g_mrCancelled++; cancelled++;
         // [MRR R1] M05: an OLD record of the OPEN cycle is dropped (no re-entry): its level is abandoned once the level book is restored (MrRestoreFinish)
         if(sameCycle && !r.partial && r.level > 0) { ArrayResize(g_mrrRestLv, g_mrrRestLvN + 1); g_mrrRestLv[g_mrrRestLvN++] = r.level; }
         continue;
      }
      if(r.st == MR_IN_FLIGHT || r.st == MR_READY || r.st == MR_RETRY || r.st == MR_PARTIAL || r.st == MR_RECONCILE_ONLY) g_exGraceUntil = MathMax(g_exGraceUntil, Ex38NowMs() + MathMax(1, Exec_ConfirmMs));
      const int i = ArraySize(g_mr); ArrayResize(g_mr, i + 1); g_mr[i] = r;
      g_mrRestoredN++;
   }
   if(ArraySize(g_mr) > g_mrMaxActive) g_mrMaxActive = ArraySize(g_mr);
   // R3 FINAL: the 2+ detector stays consistent with the restored records (an original with a record of this cycle is an original closed by hand)
   for(int i = 0; i < ArraySize(g_mr); i++) if(g_mr[i].cycle == cyc && g_mr[i].st != MR_CANCEL_RECONCILE) MrOrigAdd(g_mr[i].posId, g_mr[i].level);
   if(g_mrOrigN >= 2 && !g_mrMulti) { g_mrMulti = true; g_mrMultiOn++; PrintFormat("MR RESTORE | %d originals closed by hand in this cycle [%s] -> MULTI_MANUAL_IGNORE", g_mrOrigN, MrOrigText()); }
   // records whose state write was cut: rebuilt from the deal (if still of this cycle), fills reconciled by the tag
   if(incomplete > 0 && sameMeta)
   {
      for(int k = 0; k < nk; k++)
         if(MrFind(keys[k]) < 0 && !MrReceipted(keys[k]) && !GlobalVariableCheck(MrKey(keys[k]) + "s")) MrOnManualClose(keys[k], "RESTORE_INCOMPLETE");
   }
   PrintFormat("MR RESTORE LOAD | records %d restored (%d cancelled, %d incomplete) | receipts %d floor %I64d | originals closed by hand %d [%s] MULTI_MANUAL_IGNORE %s | surplus close in flight %I64u | grid freeze %s | cycle %I64d",
               ArraySize(g_mr), cancelled, incomplete, g_mrRcptN, g_mrFloorMsc, g_mrOrigN, MrOrigText(), g_mrMulti ? "ON" : "off", g_mrSpKey, g_mrGridFreeze ? MrFreezeName(g_mrFreezeWhy) : "no", cyc);
   MrSaveMeta(); GlobalVariablesFlush();
}
// step 2 (after the DD / exit restore): authority, broker reconciliation, missed manual closes, level proof
void MrRestoreFinish()
{
   if(ArraySize(g_mr) > 0 && g_exGraceUntil > Ex38NowMs()) Ex38RestartGrace("manual recovery record(s) restored");
   if(DdlActive()) MrOnDdActivate();
   else if(ExActive()) MrOnExitCommit();
   else if(t1Locked || hedgeTrailActive) MrOnT1Priority();
   else if(g_mrMulti && MrRecoveringCount() > 0) PrintFormat("MR RESTORE | MULTI_MANUAL_IGNORE of this cycle:%s", MrMultiSweep());   // R3 FINAL: no recovery right survives the 2+ rule
   // every restored record against the broker history: fills during the stop or before a crash complete (and remove) it, never resent
   const int n = ArraySize(g_mr);
   ulong keys[]; ArrayResize(keys, n); for(int k = 0; k < n; k++) keys[k] = g_mr[k].deal;
   for(int k = 0; k < n; k++) { const int i = MrFind(keys[k]); if(i >= 0) MrReconcile(i, "RESTORE"); }
   // [MRR R1] M05: levels of OLD records of the open cycle dropped at this restart (the level book is restored now)
   for(int k = 0; k < g_mrrRestLvN; k++) MrrAbandonClosedLevel(g_mrrRestLv[k], false, "closed by hand before the restart, its old recovery record is dropped (MRR R1: no re-entry)");
   g_mrrRestLvN = 0; ArrayResize(g_mrrRestLv, 0);
   if(!DdlActive() && !ExActive() && CountPositions() > 0) MrScanHistory("RESTART");
   // R3: the level book gives every level; FirstPrice (trigger origin) after a restart without the V26 cycle record comes from the earliest open position —
   // wrong when L1 was closed by hand -> the grid of this basket cannot be proven
   if(CountPositions() > 0 && LbOn() && !g_cycRestoredOk && !LbHasOriginal(1))
      MrFreezeGrid(MRF_LEVEL_UNPROVEN, "restart without the V26 cycle record: FirstPrice cannot be proven (L1 closed by hand)");
   g_mrLastCount = CountPositions();
   PrintFormat("MR RESTORED | pending records %d (blocking grid %d, in flight %d) | originals closed by hand %d MULTI_MANUAL_IGNORE %s | grid freeze %s | store variables %d | level book %s",
               ArraySize(g_mr), MrBlocksGrid() ? 1 : 0, MrInflightAny() ? 1 : 0, g_mrOrigN, g_mrMulti ? "ON" : "off", g_mrGridFreeze ? MrFreezeName(g_mrFreezeWhy) : "no", MrStoreVars(), LbText());
}

void MrPrintCounters(const string when)
{
   PrintFormat("MR COUNTERS %s | created %I64d | removed after confirmed fill %I64d | cancelled %I64d | partial fills %I64d | requests %I64d (not executed %I64d) | over-fills %I64d | suspended %I64d | max pending %I64d | history-scan found %I64d | ignored duplicates %I64d | orphan closes %I64d | pending now %d | store variables %d",
               when, g_mrCreated, g_mrRemovedFilled, g_mrCancelled, g_mrPartialFills, g_mrReqs, g_mrReqNotExec, g_mrOverfills, g_mrSuspends, g_mrMaxActive, g_mrScanFound, g_mrIgnored, g_mrOrphanCloses,
               ArraySize(g_mr), MrStoreVars());
   PrintFormat("MR R3 COUNTERS %s | merged deals of the same original %I64d | MULTI_MANUAL_IGNORE switched on %I64d (originals counted %I64d, same original closed again %I64d, skipped records %I64d, receipt-only closes %I64d) | skipped for T1/T2 %I64d | reconcile-only resolved %I64d | unknown holds %I64d | surplus detected %I64d, close requests %I64d, closed confirmed %.2f lots, unknown results %I64d",
               when, g_mrMerged, g_mrMultiOn, g_mrOrigSeen, g_mrSameOrigAgain, g_mrSkipMulti, g_mrReceiptOnly, g_mrSkipT1, g_mrRecOnlyResolved, g_mrUnknownHolds, g_mrSurDetected, g_mrSurReqs, g_mrSurClosedConf, g_mrSurUnknown);
}

#endif
// [FINAL STANDALONE] ===== END INLINED OFH38_ManualRecovery.mqh =====

// [MRR R1] ===== MANUAL REENTRY REMOVAL R1 - terminal glue of the [MRR CORE] rules (manual-close ownership, finished-cycle events, cycle finalization, late fills,
// "L1 BLOCKED" diagnostics). Persisted state: namespace OFH38Z (the last finalized cycle while no new L1 has started), identity-checked like every other record.
string MrrNs() { return OfhNs("OFH38Z", Magic); }
// M03: the position was opened by this EA (an entry deal of Magic on this symbol). Replaces the history cache (HistorySelectByPosition).
bool MrrPosOpenedByEa(const ulong posId)
{
   if(posId == 0 || !HistorySelectByPosition(posId)) return false;
   for(int k = 0; k < HistoryDealsTotal(); k++)
   {
      const ulong d = HistoryDealGetTicket(k);
      if(d == 0) continue;
      const long en = HistoryDealGetInteger(d, DEAL_ENTRY);
      if((en == DEAL_ENTRY_IN || en == DEAL_ENTRY_INOUT) && (ulong)HistoryDealGetInteger(d, DEAL_MAGIC) == Magic && HistoryDealGetString(d, DEAL_SYMBOL) == _Symbol) return true;
   }
   return false;
}
// M03: a manual-close deal of an EA position whose closing order carried another magic. The deal is selected again before returning.
bool MrrForeignMagicManualClose(const ulong deal)
{
   if(!HistoryDealSelect(deal)) return false;
   const long en = HistoryDealGetInteger(deal, DEAL_ENTRY);
   const bool manual = Mr38IsManualReason(HistoryDealGetInteger(deal, DEAL_REASON));
   const bool exitEntry = (en == DEAL_ENTRY_OUT || en == DEAL_ENTRY_INOUT || en == DEAL_ENTRY_OUT_BY);
   if(!manual || !exitEntry) return false;
   const bool own = MrrPosOpenedByEa((ulong)HistoryDealGetInteger(deal, DEAL_POSITION_ID));
   HistoryDealSelect(deal);
   if(!Mrr38ForeignMagicOwned(manual, exitEntry, own)) return false;
   g_mrrForeignMagic++;
   return true;
}
// M02: a manual-close deal of a FINISHED cycle processed while another basket runs -> recorded only (receipt), nothing of the running basket changes. true = handled.
bool MrrStaleCloseOfFinishedCycle(const ulong deal, const string src)
{
   if(deal == 0 || MrFind(deal) >= 0 || MrReceipted(deal)) return false;   // MrOnManualClose counts the duplicate
   const int nNow = CountPositions();
   if(nNow <= 0) return false;
   if(!HistoryDealSelect(deal)) return false;
   const ulong posId = (ulong)HistoryDealGetInteger(deal, DEAL_POSITION_ID);
   const long closeMsc = HistoryDealGetInteger(deal, DEAL_TIME_MSC);
   const long om = MrOpenMsc(posId);
   const long cyc = MrCycleId();
   const bool finished = Mrr38FinishedCycleClose(posId, g_mrrCycFirstOrd, om, cyc, LbLevelOfPos(posId) > 0, nNow);
   HistoryDealSelect(deal);
   if(!finished) return false;
   MrReceiptAdd(deal, closeMsc); MrSaveMeta(); MrFlush();
   g_mrrStale++;
   PrintFormat("MANUAL CLOSE OF A FINISHED CYCLE | deal %I64u (%s) position %I64u (%s) does not belong to the running BasketCycleID %I64d and is not in its level book: the event was processed after that cycle was finalized -> recorded only (no level book / grid freeze / record for the running basket)",
               deal, src, posId, g_mrrCycFirstOrd > 0 ? StringFormat("ticket below the first order %I64u of the running basket", g_mrrCycFirstOrd) : StringFormat("opened %I64d, before the running cycle", om), cyc);
   return true;
}
// M05: abandon the level of a fully closed original when no position of that level is open any more (level book ON)
void MrrAbandonClosedLevel(const int lv, const bool partialClose, const string why)
{
   if(!LbOn() || LbIsAbandoned(lv)) return;
   bool open = false;
   for(int i = 0; i < g_lbN; i++) if(g_lbLv[i] == lv && g_lbKind[i] != LBK_UNKNOWN) open = true;
   if(!Mrr38AbandonClosedLevel(lv, partialClose, open)) return;
   g_mrrAbandoned++;
   LbAbandonLevel(lv, why);
}
void MrrClearFinished() { g_mrrFinCyc = 0; g_mrrFinMsc = 0; g_mrrLateOrdN = 0; g_mrrLateUnknown = false; g_mrrFinMaxSeen = 0; g_mrrFinWm = 0; g_mrrAwaitL1 = false; g_mrrL1Why = ""; }
void MrrPersist()
{
   const string ns = MrrNs();
   GlobalVariablesDeleteAll(ns);
   if(g_mrrFinMsc > 0)
   {
      GlobalVariableSet(ns + "fc", (double)g_mrrFinCyc); GlobalVariableSet(ns + "fm", (double)g_mrrFinMsc);
      GlobalVariableSet(ns + "aw", g_mrrAwaitL1 ? 1 : 0); GlobalVariableSet(ns + "lu", g_mrrLateUnknown ? 1 : 0); GlobalVariableSet(ns + "ln", g_mrrLateOrdN);
      GlobalVariableSet(ns + "ms", (double)g_mrrFinMaxSeen); GlobalVariableSet(ns + "fw", (double)g_mrrFinWm);
      for(int k = 0; k < g_mrrLateOrdN; k++) GlobalVariableSet(ns + "l" + IntegerToString(k), (double)g_mrrLateOrd[k]);
      OfhIdStore(ns, Magic);
   }
   GlobalVariablesFlush();
}
void MrrRestore()
{
   MrrClearFinished(); g_mrrManualDeals = 0; g_mrrFullManual = false; g_mrrLateClosed = false; g_mrrSeenPos = false; g_mrrCycFirstOrd = 0; g_mrrMaxSeenId = 0;
   const string ns = MrrNs();
   if(!GlobalVariableCheck(ns + "fm")) return;
   const string idWhy = OfhIdCheck(ns, Magic);
   if(idWhy != "") { PrintFormat("MRR RECORD %s IGNORED | identity mismatch (%s) - cleared", ns, idWhy); GlobalVariablesDeleteAll(ns); GlobalVariablesFlush(); return; }
   // a running basket whose cycle record was restored (CycRestore) is not a late fill: the finished cycle is over
   if(CountPositions() > 0 && g_cycStartMsc > 0)
   {
      PrintFormat("MRR RESTORE | finalized BasketCycleID %I64d is over: the open basket has its own cycle record (%I64d) - record cleared", (long)GlobalVariableGet(ns + "fc"), g_cycStartMsc);
      GlobalVariablesDeleteAll(ns); GlobalVariablesFlush();
      return;
   }
   g_mrrFinCyc = (long)GlobalVariableGet(ns + "fc"); g_mrrFinMsc = (long)GlobalVariableGet(ns + "fm"); g_mrrAwaitL1 = GlobalVariableGet(ns + "aw") > 0.5;
   g_mrrLateUnknown = GlobalVariableGet(ns + "lu") > 0.5; g_mrrLateOrdN = MathMin(MRR_LATE_MAX, (int)GlobalVariableGet(ns + "ln"));
   g_mrrFinMaxSeen = (ulong)GlobalVariableGet(ns + "ms"); g_mrrFinWm = (ulong)GlobalVariableGet(ns + "fw");
   for(int k = 0; k < g_mrrLateOrdN; k++) g_mrrLateOrd[k] = (ulong)GlobalVariableGet(ns + "l" + IntegerToString(k));
   PrintFormat("MRR RESTORE | finalized BasketCycleID %I64d (flat at %I64d, %d order(s) of it still working then%s), no new L1 since | EA positions now %d: %s", g_mrrFinCyc, g_mrrFinMsc, g_mrrLateOrdN,
               g_mrrLateUnknown ? ", an entry request without result" : "", CountPositions(), CountPositions() > 0 ? "checked against the late-fill rule on the first tick" : "a new L1 when eligible");
}
// M04: highest order ticket of the EA (Magic, symbol) known now: working orders + order history since the start of the cycle (an order DONE before the
// finalization whose position was not listed yet has a ticket at or below it; an order sent after the finalization is above it)
ulong MrrOrderWatermark(const long cycMsc)
{
   ulong wm = 0;
   for(int k = OrdersTotal() - 1; k >= 0; k--)
   {
      const ulong t = OrderGetTicket(k);
      if(t != 0 && OrderGetString(ORDER_SYMBOL) == _Symbol && (ulong)OrderGetInteger(ORDER_MAGIC) == Magic && t > wm) wm = t;
   }
   if(cycMsc > 0 && HistorySelect((datetime)(cycMsc / 1000) - 60, TimeCurrent() + 60))
      for(int k = HistoryOrdersTotal() - 1; k >= 0; k--)
      {
         const ulong o = HistoryOrderGetTicket(k);
         if(o != 0 && HistoryOrderGetString(o, ORDER_SYMBOL) == _Symbol && (ulong)HistoryOrderGetInteger(o, ORDER_MAGIC) == Magic && o > wm) wm = o;
      }
   return wm;
}
// M04: positions of the running cycle seen at the end of a tick (OnTick): flag + highest position id
void MrrNoteSeen()
{
   for(int i = 0; i < PositionsTotal(); i++)
   {
      const ulong t = PositionGetTicket(i);
      if(t == 0 || !PositionSelectByTicket(t) || !IsOursPos()) continue;
      g_mrrSeenPos = true;
      const ulong id = (ulong)PositionGetInteger(POSITION_IDENTIFIER);
      if(id > g_mrrMaxSeenId) g_mrrMaxSeenId = id;
   }
}
// M04: the orders of the EA (Magic, symbol) still working at the broker now + the entry request without a broker result: a later fill of one of them is a late fill
void MrrCollectLateOrders()
{
   g_mrrLateOrdN = 0; g_mrrLateUnknown = false;
   for(int k = OrdersTotal() - 1; k >= 0 && g_mrrLateOrdN < MRR_LATE_MAX; k--)
   {
      const ulong t = OrderGetTicket(k);
      if(t != 0 && OrderGetString(ORDER_SYMBOL) == _Symbol && (ulong)OrderGetInteger(ORDER_MAGIC) == Magic) g_mrrLateOrd[g_mrrLateOrdN++] = t;
   }
   if(g_seRec.st != 0)
   {
      if(g_seRec.ord == 0) g_mrrLateUnknown = true;
      else
      {
         bool have = false; for(int k = 0; k < g_mrrLateOrdN; k++) if(g_mrrLateOrd[k] == g_seRec.ord) have = true;
         if(!have && g_mrrLateOrdN < MRR_LATE_MAX) g_mrrLateOrd[g_mrrLateOrdN++] = g_seRec.ord;
      }
   }
}
bool MrrInLateSet(const ulong ord) { for(int k = 0; k < g_mrrLateOrdN; k++) if(g_mrrLateOrd[k] == ord) return true; return false; }
// M04 / M06: the flat basket of the running cycle is finalized (ResetCycleState, broker flat, a position of the cycle was seen). Logged for cycles with a manual
// close / a closed late fill.
void MrrOnCycleFinalized()
{
   g_mrrFinCyc = g_cycStartMsc; g_mrrFinMsc = Ex38TickMsc(); g_mrrFinalized++;
   MrrCollectLateOrders();
   g_mrrFinMaxSeen = g_mrrMaxSeenId; g_mrrFinWm = MrrOrderWatermark(g_cycStartMsc);
   g_mrrSeenPos = false; g_mrrCycFirstOrd = 0; g_mrrMaxSeenId = 0;
   const bool notable = (g_mrrManualDeals > 0 || g_mrrLateClosed);
   g_mrrAwaitL1 = notable; g_mrrL1Why = "";
   MrrPersist();
   if(notable)
   {
      int fl = 0;
      for(int i = 0; i < ArraySize(g_mr); i++) if(Mr38InFlight(g_mr[i].st)) fl++;
      PrintFormat("CYCLE FINALIZED | BasketCycleID %I64d | %s | broker: EA positions 0, EA orders working %d, entry request without broker result %s, old recovery requests in flight %d | grid / GLOBAL / Lk* / PairClose / T1-T2 / manual state reset by their cycle contracts | a later fill of one of those orders is closed, never a new L1",
                  g_mrrFinCyc, g_mrrLateClosed ? "late fill of the finished cycle closed" : StringFormat("%d manual-close deal(s)%s", g_mrrManualDeals, g_mrrFullManual ? ", FULL MANUAL BASKET CLOSE" : ""),
                  g_mrrLateOrdN, g_seRec.st == 0 ? "none" : "YES", fl);
   }
   g_mrrManualDeals = 0; g_mrrFullManual = false; g_mrrLateClosed = false;
}
// a new L1 of the EA was sent on a flat tick: the finished cycle is over; the running basket starts with this order
void MrrOnNewL1(const ulong order)
{
   if(g_mrrAwaitL1) PrintFormat("L1 RESUMED | new BasketCycleID after the finished cycle %I64d (last block reason %s)", g_mrrFinCyc, g_mrrL1Why == "" ? "none" : g_mrrL1Why);
   const bool had = (g_mrrFinMsc > 0);
   MrrClearFinished(); g_mrrLateClosed = false; g_mrrSeenPos = false; g_mrrCycFirstOrd = order; g_mrrMaxSeenId = 0;
   if(had) MrrPersist();
}
// M06 log only: the reason that keeps the new L1 back after a cycle with a manual close / late fill (printed when it changes)
void MrrL1Blocked(const string why, const string detail)
{
   if(!g_mrrAwaitL1 || why == g_mrrL1Why) return;
   g_mrrL1Why = why; g_mrrL1Blocks++;
   PrintFormat("L1 BLOCKED | %s | finished BasketCycleID %I64d | %s", why, g_mrrFinCyc, detail);
}
void MrrPrintCounters(const string when)
{
   PrintFormat("MRR COUNTERS %s | full manual basket closes %I64d | cycles finalized %I64d | manual closes of a finished cycle ignored %I64d | manual closes with another deal magic adopted %I64d | late fills closed %I64d, inconsistent %I64d | levels abandoned (old records) %I64d | L1 BLOCKED lines %I64d | open finalized cycle %I64d",
               when, g_mrrFullCloses, g_mrrFinalized, g_mrrStale, g_mrrForeignMagic, g_mrrLateFills, g_mrrLateMixed, g_mrrAbandoned, g_mrrL1Blocks, g_mrrFinCyc);
}
// [FINAL STANDALONE] ===== BEGIN INLINED OFH38_Precedence.mqh (HOTFIX SHA256 05B33D9682BA13674C779A130AB92DB842EEB0C202A385943048A546D29BE021) — included from Onefxhub_v38.38_RPA.mq5:L310 =====
// OFH38_Precedence.mqh — V38 R2: quyền nắm cụm (đúng MỘT cơ chế tại một thời điểm: DD_LOCK > BASKET_EXITING > PAIR_CLOSE_PENDING > GRID_WAITING),
// thứ tự PairClose / DD trong cùng tick (Owner B2 / B3), hòa vốn KINH TẾ của chu kỳ chặn DD mới (Owner B5), cảnh báo PairClose kéo dài (B4),
// OWNER_REQUIRED khi bản ghi khởi động lại xung đột mà broker không chứng minh được bên nào (E.2). Luật thuần: OFH38_Precedence_Core.mqh.
// Không đổi cách đo DD của V26 (|lỗ nổi cụm| / số dư × 100), không đổi điểm kích hoạt Entry / Grid / T1 / T2 / PairClose, lot ladder.
// R3 FINAL (Owner 23/10/2026, mục 1): T1/T2 ưu tiên hơn DD% — DD Lock MỚI chỉ ở ORIGINAL_GRID_DRAWDOWN (Prio38DdState); DD Lock đã có trước khi T1
// đủ điều kiện được GIỮ (không tự tháo hedge), BLOCKER ghi một lần mỗi đợt (Prio38DdHoldsT1Watch); PairClose không quyết định cặp mới khi một
// yêu cầu đóng lot thừa còn đang bay (một module / một ticket).
#ifndef OFH38_PRECEDENCE_MQH
#define OFH38_PRECEDENCE_MQH

// [FINAL STANDALONE] ===== BEGIN INLINED OFH38_Precedence_Core.mqh (HOTFIX SHA256 A862713C9A238226C536A013DC6BBC5AB48B524EA4113CB19692ADF840623DB9) — included from OFH38_Precedence.mqh:L11 =====
// OFH38_Precedence_Core.mqh — V38 R2: luật THUẦN về quyền nắm cụm (một cơ chế tại một thời điểm) và hòa vốn kinh tế của chu kỳ —
// unit test trong OFH38_UnitTests.mq5. Không gọi terminal.
#ifndef OFH38_PRECEDENCE_CORE_MQH
#define OFH38_PRECEDENCE_CORE_MQH

#define AUTH_GRID            0   // chu kỳ V26 thường: Grid / T1 / T2 / quyết định PairClose / khôi phục lệnh đóng tay
#define AUTH_PAIR_PENDING    1   // chân PairClose đã quyết định còn mở: đóng nốt TRƯỚC DD / Grid / L1 / khôi phục
#define AUTH_BASKET_EXITING  2   // đợt thoát cụm đã cam kết: đóng tới khi broker phẳng
#define AUTH_DD_LOCK         3   // DD Hedge Lock nắm cụm
#define AUTH_OWNER_REQUIRED  4   // bản ghi xung đột, broker không chứng minh được bên nào: không gửi yêu cầu nào, chờ Owner
#define AUTH_FLAT            5   // không có vị thế

string Auth38Name(const int a)
{
   switch(a)
   {
      case AUTH_GRID: return "GRID_WAITING";             case AUTH_PAIR_PENDING: return "PAIR_CLOSE_PENDING"; case AUTH_BASKET_EXITING: return "BASKET_EXITING";
      case AUTH_DD_LOCK: return "DD_LOCK";               case AUTH_OWNER_REQUIRED: return "OWNER_REQUIRED";   case AUTH_FLAT: return "FLAT";
   }
   return "?";
}

// Khởi động lại (chỉ thị E.2): đúng MỘT cơ chế có quyền theo trạng thái giao dịch thật.
//   ddRec      bản ghi DD hợp lệ (danh tính + Magic hedge)        ddUnproven  DD còn LOCK_PENDING / LOCK_FAILED và broker KHÔNG có lệnh hedge
//   hedgeOpen  broker có vị thế DDLock_HedgeMagic                  exRec       bản ghi BASKET_EXITING hợp lệ có ticket còn mở
//   pairPend   chân PairClose đã quyết định còn mở                 flat        không có vị thế Magic / hedge
// Xung đột không xác định: BASKET_EXITING và DD cùng nhận cụm mà broker không có lệnh hedge nào chứng minh DD -> OWNER_REQUIRED.
int Auth38Resolve(const bool flat, const bool ddRec, const bool ddUnproven, const bool hedgeOpen, const bool exRec, const bool pairPend)
{
   if(exRec && ddRec && ddUnproven && !hedgeOpen) return AUTH_OWNER_REQUIRED;
   if(ddRec || hedgeOpen) return AUTH_DD_LOCK;
   if(exRec) return AUTH_BASKET_EXITING;
   if(flat) return AUTH_FLAT;
   if(pairPend) return AUTH_PAIR_PENDING;
   return AUTH_GRID;
}

// Owner B5: lợi nhuận KINH TẾ của chu kỳ (đã chốt từ lúc khớp L1: lãi + swap + commission + phí của mọi deal; + nổi + swap các lệnh mở) >= 0
// -> không kích hoạt DD MỚI. Chỉ so tiền: không chia cho net.
bool Econ38BlocksDd(const double econ) { return econ >= 0.0; }
// Giá hòa vốn kinh tế của chu kỳ (chỉ để ghi log): net BUY tính từ Bid, net SELL tính từ Ask; |net| < eps -> 0 (không xác định: chỉ dùng tiền,
// không chia cho net ~ 0). dPL / dPrice = net × tickValue / tickSize.
double Econ38BePrice(const double econ, const double net, const double bid, const double ask, const double tickValue, const double tickSize, const double eps)
{
   if(MathAbs(net) < eps || tickValue <= 0.0 || tickSize <= 0.0) return 0.0;
   const double mark = net > 0.0 ? bid : ask;
   return mark - econ * tickSize / (tickValue * net);
}

// R3 FINAL (chỉ thị Owner 23/10/2026, mục 1): T1/T2 ƯU TIÊN HƠN DD%. Khi DD đạt ngưỡng (cách đo V26), trạng thái của cụm quyết định ai có quyền;
// DD Lock MỚI chỉ được khởi tạo ở ORIGINAL_GRID_DRAWDOWN. Thứ tự = thứ tự Owner liệt kê (trạng thái đầu tiên đúng thắng):
//   BROKER_RECONCILE            kết quả broker chưa rõ: ân hạn sau khởi động lại (yêu cầu trước khi tắt có thể đang bay) / lệnh chờ Magic còn làm việc
//   EXIT_COMMITTED              đợt thoát cả cụm đã cam kết (BASKET_EXITING) — gồm thoát T1/T2 đã chạm mức / một phía đã đóng
//   T1_T2_ELIGIBLE_OR_LATCHED   T1 đã khóa / T2 đang kéo / điều kiện T1 đúng NGAY tick này (giá qua BE ± Khoang_Doi_SL theo chiều net)
//   PAIR_CLOSE_PENDING          chân PairClose đã quyết định còn mở (R2 B2)
//   MANUAL_RECOVERY_IN_FLIGHT   yêu cầu khôi phục lệnh đóng tay đang chờ broker (REQUEST_IN_FLIGHT / RECONCILE_ONLY / CANCEL_RECONCILE)
//   SURPLUS_CLOSE_PENDING       lot thừa đã phát hiện chưa được broker xác nhận đóng / yêu cầu đóng thừa đang bay
//   ORIGINAL_GRID_DRAWDOWN      >= 2 vị thế Grid gốc, lỗ nổi, chu kỳ dưới hòa vốn kinh tế (R2 B5), không trạng thái nào ở trên → DD Lock được khởi tạo
//   OTHER                       < 2 vị thế / không lỗ nổi / chu kỳ đã hòa vốn kinh tế → không DD mới
// Không có ngưỡng % hồi phục nào (70 %..99 %): "đã về vùng BE" = điều kiện T1 của V26 hoặc hòa vốn kinh tế R2 B5 — không thêm Input.
#define PRIO_BROKER_RECONCILE           1
#define PRIO_EXIT_COMMITTED             2
#define PRIO_T1T2                       3
#define PRIO_PAIR_CLOSE_PENDING         4
#define PRIO_MANUAL_RECOVERY_IN_FLIGHT  5
#define PRIO_SURPLUS_CLOSE_PENDING      6
#define PRIO_ORIGINAL_GRID_DRAWDOWN     7
#define PRIO_OTHER                      8
#define PRIO_PAIRA_OWNED                9   // PAIRA_LOOP (Owner B6): Progressive PairClose đã nắm cụm (cam kết nén / PAIR_A / Grid đã rebase) → không DD Lock mới
#define PRIO_N                         10

string Prio38Name(const int s)
{
   switch(s)
   {
      case PRIO_BROKER_RECONCILE: return "BROKER_RECONCILE";                   case PRIO_EXIT_COMMITTED: return "EXIT_COMMITTED";
      case PRIO_T1T2: return "T1_T2_ELIGIBLE_OR_LATCHED";                      case PRIO_PAIR_CLOSE_PENDING: return "PAIR_CLOSE_PENDING";
      case PRIO_MANUAL_RECOVERY_IN_FLIGHT: return "MANUAL_RECOVERY_IN_FLIGHT"; case PRIO_SURPLUS_CLOSE_PENDING: return "SURPLUS_CLOSE_PENDING";
      case PRIO_ORIGINAL_GRID_DRAWDOWN: return "ORIGINAL_GRID_DRAWDOWN";       case PRIO_OTHER: return "OTHER";
      case PRIO_PAIRA_OWNED: return "PROGRESSIVE_PAIRCLOSE_OWNS";
   }
   return "?";
}
int Prio38Resolve(const bool brokerUnknown, const bool exitCommitted, const bool t1Latched, const bool t1Eligible, const bool pairPending,
                  const bool mrInFlight, const bool surplusPending, const int gridPositions, const bool floatingLoss, const bool econBelowBe)
{
   if(brokerUnknown) return PRIO_BROKER_RECONCILE;
   if(exitCommitted) return PRIO_EXIT_COMMITTED;
   if(t1Latched || t1Eligible) return PRIO_T1T2;
   if(pairPending) return PRIO_PAIR_CLOSE_PENDING;
   if(mrInFlight) return PRIO_MANUAL_RECOVERY_IN_FLIGHT;
   if(surplusPending) return PRIO_SURPLUS_CLOSE_PENDING;
   if(gridPositions >= 2 && floatingLoss && econBelowBe) return PRIO_ORIGINAL_GRID_DRAWDOWN;
   return PRIO_OTHER;
}
// a NEW DD lock may start only here
bool Prio38DdMayStart(const int s) { return s == PRIO_ORIGINAL_GRID_DRAWDOWN; }
// PAIRA_LOOP (Owner B6): DD Lock mới CHỈ trong Grid gốc trước khi Progressive PairClose nắm quyền. Cụm đã từng nén trong chu kỳ (HadAnyProgressivePairClose) hoặc
// đang do PairA nắm (nén / PAIR_A / trung hòa / HALTED) → ORIGINAL_GRID_DRAWDOWN đổi thành PRIO_PAIRA_OWNED (không DD mới). Các trạng thái ưu tiên hơn giữ nguyên.
int Prio38PairAGate(const int prio, const bool pairaOwnsOrHad) { return (prio == PRIO_ORIGINAL_GRID_DRAWDOWN && pairaOwnsOrHad) ? PRIO_PAIRA_OWNED : prio; }

#endif
// [FINAL STANDALONE] ===== END INLINED OFH38_Precedence_Core.mqh =====

int    g_authLast = -1;
bool   g_authOwnerReq = false; string g_authOwnerWhy = "";
long   g_pairWarnMsc = 0, g_r2DdLogPair = 0, g_r2DdLogEcon = 0, g_r2OwnerLogMsc = 0;
string g_r2Alerted = "";
// bằng chứng
long   g_r2DdDefPair = 0, g_r2DdDefEcon = 0, g_r2PairFirst = 0, g_r2T1DefPair = 0, g_r2PairMerged = 0, g_r2OwnerReqTicks = 0, g_r2PairWarnings = 0;
// hòa vốn kinh tế: bộ đệm phần đã chốt (đổi khi số dư / số vị thế / chu kỳ đổi, tối đa 60 s)
string g_r2EconKey = ""; double g_r2EconReal = 0.0; datetime g_r2EconAt = 0;

bool PairPendingAny() { return g_pairPend1 != 0 || g_pairPend2 != 0; }

// cảnh báo: luôn in; Alert() một lần mỗi khóa khi chạy thật (tester: chỉ log)
void R2Warn(const string key, const string text)
{
   Print(text);
   if((bool)MQLInfoInteger(MQL_TESTER) || StringFind(g_r2Alerted, "|" + key + "|") >= 0) return;
   g_r2Alerted += "|" + key + "|"; if(StringLen(g_r2Alerted) > 2000) g_r2Alerted = "|" + key + "|";
   Alert(text);
}

// phần ĐÃ CHỐT của chu kỳ: deal Magic / symbol từ lúc khớp L1 thuộc các VỊ THẾ MỞ TRONG CHU KỲ (deal vào lệnh >= mốc): deal vào = commission + phí,
// deal ra = lãi + swap + commission + phí. Deal của chu kỳ trước trùng mili-giây với mốc không bị tính (ExRealisedSince của R1 chỉ dùng cho log thoát).
double R2RealisedCycle(const long startMsc)
{
   if(startMsc <= 0 || !HistorySelect((datetime)(startMsc / 1000) - 1, TimeCurrent() + 60)) return 0.0;
   ulong ids[]; int n = 0;
   const int total = HistoryDealsTotal();
   for(int k = 0; k < total; k++)
   {
      const ulong d = HistoryDealGetTicket(k);
      if(d == 0 || HistoryDealGetString(d, DEAL_SYMBOL) != _Symbol || (ulong)HistoryDealGetInteger(d, DEAL_MAGIC) != Magic) continue;
      const long en = HistoryDealGetInteger(d, DEAL_ENTRY);
      if((en != DEAL_ENTRY_IN && en != DEAL_ENTRY_INOUT) || HistoryDealGetInteger(d, DEAL_TIME_MSC) < startMsc) continue;
      ArrayResize(ids, n + 1); ids[n++] = (ulong)HistoryDealGetInteger(d, DEAL_POSITION_ID);
   }
   double s = 0.0;
   for(int k = 0; k < total; k++)
   {
      const ulong d = HistoryDealGetTicket(k);
      if(d == 0 || HistoryDealGetString(d, DEAL_SYMBOL) != _Symbol || (ulong)HistoryDealGetInteger(d, DEAL_MAGIC) != Magic || HistoryDealGetInteger(d, DEAL_TIME_MSC) < startMsc) continue;
      const ulong pid = (ulong)HistoryDealGetInteger(d, DEAL_POSITION_ID);
      bool mine = false; for(int a = 0; a < n && !mine; a++) if(ids[a] == pid) mine = true;
      if(!mine) continue;
      const double cost = HistoryDealGetDouble(d, DEAL_COMMISSION) + HistoryDealGetDouble(d, DEAL_FEE);
      s += (HistoryDealGetInteger(d, DEAL_ENTRY) == DEAL_ENTRY_IN) ? cost : HistoryDealGetDouble(d, DEAL_PROFIT) + HistoryDealGetDouble(d, DEAL_SWAP) + cost;
   }
   return s;
}
// lợi nhuận KINH TẾ của chu kỳ = phần đã chốt của chu kỳ + nổi + swap các lệnh đang mở
double R2CycleEconomic(double &realised, double &floating)
{
   floating = BasketProfit();
   const long st = CycStartMsc();
   const string k = StringFormat("%I64d|%.2f|%d", st, AccountInfoDouble(ACCOUNT_BALANCE), PositionsTotal());
   if(k != g_r2EconKey || TimeCurrent() - g_r2EconAt >= 60) { g_r2EconReal = R2RealisedCycle(st); g_r2EconKey = k; g_r2EconAt = TimeCurrent(); }
   realised = g_r2EconReal;
   return realised + floating;
}

// DD đạt ngưỡng mà KHÔNG kích hoạt khóa: 1 = chân PairClose còn dở (B2), 2 = chu kỳ đã hòa vốn kinh tế (B5). Log tối đa mỗi 60 s / loại.
void R2DdDeferred(const int why, const double pct, const double econ, const double re, const double fl)
{
   const long now = Ex38TickMsc();
   if(why == 1)
   {
      g_r2DdDefPair++;
      if(now - g_r2DdLogPair < 60000) return;
      g_r2DdLogPair = now;
      PrintFormat("R2 DD DEFERRED (B2) | DD %.2f%% >= %.2f%% while PairClose leg(s) %I64u/%I64u are pending for %I64d ms -> the pair is finished first, no DD Lock meanwhile (deferred ticks %I64d)",
                  pct, Cat_DD_PhanTram, g_pairPend1, g_pairPend2, g_pairPendSinceMsc > 0 ? now - g_pairPendSinceMsc : 0, g_r2DdDefPair);
      return;
   }
   g_r2DdDefEcon++;
   if(now - g_r2DdLogEcon < 60000) return;
   g_r2DdLogEcon = now;
   double vB = 0.0, vS = 0.0, sB = 0.0, sS = 0.0; BasketVolumeSums(vB, vS, sB, sS);
   const double net = vB - vS, minV = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   const double be = Econ38BePrice(econ, net, SymbolInfoDouble(_Symbol, SYMBOL_BID), SymbolInfoDouble(_Symbol, SYMBOL_ASK),
                                   SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE), SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE), (minV > 0.0 ? minV : 0.01) * 0.5);
   PrintFormat("R2 DD NOT ACTIVATED (B5) | DD %.2f%% >= %.2f%% (V26 measurement) but the CYCLE is economically at / above break-even: realised since L1 %.2f + floating %.2f = %.2f >= 0 | net %+.2f economic BE %s | no new DD Lock (deferred ticks %I64d)",
               pct, Cat_DD_PhanTram, re, fl, econ, net, be > 0.0 ? StringFormat("%.2f (%s)", be, net > 0 ? "Bid" : "Ask") : "n/a (net ~ 0: money P/L only)", g_r2DdDefEcon);
}

// OWNER12 (Owner 25/10/2026 mục 4): PairQualifiesNow (cặp PairClose V26 đủ điều kiện cùng tick DD) đã GỠ cùng PairClose V26.
// [DPMR R1] D03: khôi phục (bản V38 R3 FINAL) cho PairClose_Mode 0 — luật R2 B3 (DD đạt ngưỡng + cặp đủ điều kiện cùng tick → cặp trước). Mode 1: luôn false.
// cặp 2 lệnh cuối đủ điều kiện PairClose NGAY tick này (cùng điều kiện của RunPairCloseIfNeeded, không gửi gì)
bool PairQualifiesNow(const int total)
{
   if(PcMode()!=DPMR_PC_V26) return false;   // [DPMR R1] D01
   if(!basketModeLatched || !PairClose_BatTat || hedgeTrailActive || total < PairClose_TuLenh || PairClose_SoUSD <= 0) return false;
   if(MrSurplusInFlight()) return false;   // R3 FINAL: a surplus close request owns its ticket until the broker shows the result
   ulong a = 0, b = 0;
   return GetTwoLatestTickets(a, b) && CheckPairClose(a, b, PairClose_SoUSD);
}

// ---------------------------------------------------------------- R3 FINAL: T1/T2 before DD% (Owner 2026-10-23, item 1)
long g_prBlocked[PRIO_N];   // ticks with the DD threshold reached and NO new DD lock, per owning state (evidence; never steers a decision)
long g_prLogMsc[PRIO_N];
long g_prStarted = 0, g_prT1WhileDd = 0, g_prPairWaitSur = 0, g_prDdEpLogged = 0, g_prL1WaitOrder = 0;
int  g_prLast = 0;          // state decided on the latest DD-threshold tick (0 = none yet)

// a Magic order still working at the broker (grid / L1 PLACED, recovery order): its fill would change the basket a lock is planned on
bool Prio38OrderWorking()
{
   for(int k = OrdersTotal() - 1; k >= 0; k--)
   {
      const ulong t = OrderGetTicket(k);
      if(t != 0 && OrderGetString(ORDER_SYMBOL) == _Symbol && (ulong)OrderGetInteger(ORDER_MAGIC) == Magic) return true;
   }
   return false;
}
// original grid positions of the basket: book off = every position (V26 rank); book on = distinct proven levels (a re-entry / extra ticket is the
// level of its original) + positions without a provable level (counted, so an unproven basket keeps its DD protection)
int Prio38GridPositions()
{
   if(!LbOn()) return CountPositions();
   LbSync();
   int lv[]; int n = 0, unk = 0;
   for(int i = 0; i < g_lbN; i++)
   {
      if(g_lbKind[i] == LBK_UNKNOWN || g_lbLv[i] <= 0) { unk++; continue; }
      bool have = false; for(int k = 0; k < n; k++) if(lv[k] == g_lbLv[i]) have = true;
      if(!have) { ArrayResize(lv, n + 1); lv[n++] = g_lbLv[i]; }
   }
   return n + unk;
}
// state of the basket for a NEW DD lock on this tick (TryCutByAccountDd: after the V26 threshold and the R1 "T1/T2 exit under way" check)
int Prio38DdState(const double pl, const double econ, bool &t1Elig)
{
   int nd = 0; double lp = 0.0;
   t1Elig = (basketModeLatched || CountPositions() >= 2) && T1EligibleNow(nd, lp);
   const bool unknown = (Ex38NowMs() < g_exGraceUntil) || Prio38OrderWorking();
   const bool surplus = MrSurplusInFlight() || g_mrSurOutstanding;
   // RPA (Owner 31/10/2026): a committed rebase / its unresolved request = a pending pair decision (serialized: no new DD Lock on top of it)
   const int r = Prio38Resolve(unknown, ExActive(), t1Locked || t2Armed || hedgeTrailActive, t1Elig, PairPendingAny() || RpaInFlight(), MrInflightAny(), surplus,
                               Prio38GridPositions(), pl < 0.0, !Econ38BlocksDd(econ));
   // PAIRA_LOOP (Owner B6) kept for RPA: a new DD Lock only in the ORIGINAL grid (epoch 0), never after a rebase of the cycle (subgrid epochs)
   return Prio38PairAGate(r, RpaBlocksNewDd());
}
// DD threshold reached, no new DD lock: count + log (every 60 s per state)
void Prio38DdBlocked(const int s, const double pct, const bool t1Elig)
{
   g_prLast = s;
   if(s < 0 || s >= PRIO_N) return;
   g_prBlocked[s]++;
   const long now = Ex38TickMsc();
   if(g_prLogMsc[s] > 0 && now - g_prLogMsc[s] < 60000) return;
   g_prLogMsc[s] = now;
   PrintFormat("R3F DD NOT STARTED | DD %.2f%% >= %.2f%% (V26 measurement) but %s owns the basket -> no new DD Lock (Owner: T1/T2 before DD%%) | positions %d (grid levels %d) | T1 latched %d eligible %d | pair %I64u/%I64u | recovery in flight %d | surplus close %s | restart grace %d | ticks blocked by this state %I64d",
               pct, Cat_DD_PhanTram, Prio38Name(s), CountPositions(), Prio38GridPositions(), (t1Locked || t2Armed || hedgeTrailActive) ? 1 : 0, t1Elig ? 1 : 0, g_pairPend1, g_pairPend2,
               MrInflightAny() ? 1 : 0, MrSurplusInFlight() ? "in flight" : (g_mrSurOutstanding ? "outstanding" : "none"), Ex38NowMs() < g_exGraceUntil ? 1 : 0, g_prBlocked[s]);
}
// item 1.5: a DD lock that started BEFORE T1/T2 were eligible is kept (no automatic unwind of its hedge) - BLOCKER once per episode
void Prio38DdHoldsT1Watch()
{
   if(!DdlActive() || g_prDdEpLogged == g_ddlEpisode || CountPositions() < 2) return;
   int nd = 0; double lp = 0.0;
   if(!T1EligibleNow(nd, lp)) return;
   g_prDdEpLogged = g_ddlEpisode; g_prT1WhileDd++;
   R2Warn("PRDDT1_" + IntegerToString(g_ddlEpisode),
          StringFormat("R3F BLOCKER DD_LOCK_BEFORE_T1 | the DD lock of episode %I64d (%s) started before T1/T2 were eligible; the original basket now meets the T1 condition (net %s, T1 lock %.2f) -> the DD lock and its hedge are KEPT: no approved rule to unwind a DD hedge (Owner decision, research GoldEdge V2)",
                       g_ddlEpisode, DdlStateName(g_ddlState), nd > 0 ? "BUY" : "SELL", lp));
}
void Prio38PrintCounters(const string when)
{
   string s = "";
   for(int k = 1; k < PRIO_N; k++) if(k != PRIO_ORIGINAL_GRID_DRAWDOWN) s += StringFormat(" %s %I64d |", Prio38Name(k), g_prBlocked[k]);
   PrintFormat("R3F PRIORITY COUNTERS %s | DD threshold ticks without a new DD lock, by owning state:%s DD locks started (ORIGINAL_GRID_DRAWDOWN) %I64d | DD lock kept while T1 became eligible (BLOCKER) %I64d | PairClose decisions held by a surplus close in flight %I64d | new L1 held by a working Magic order %I64d",
               when, s, g_prStarted, g_prT1WhileDd, g_prPairWaitSur, g_prL1WaitOrder);
}

// chân PairClose dở lâu: cảnh báo mỗi 60 s (không đóng băng im lặng); yêu cầu vẫn có trần (backoff, Exec_MaxAttempts rồi STALLED)
void PairPendingWarn()
{
   if(!PairPendingAny()) return;
   const long now = Ex38TickMsc();
   if(g_pairPendSinceMsc <= 0) g_pairPendSinceMsc = now;
   const long dur = now - g_pairPendSinceMsc;
   if(dur < 60000 || now - g_pairWarnMsc < 60000) return;
   g_pairWarnMsc = now; g_r2PairWarnings++;
   string legs = "";
   ulong lg[2]; lg[0] = g_pairPend2; lg[1] = g_pairPend1;
   for(int k = 0; k < 2; k++)
   {
      if(lg[k] == 0) continue;
      const int i = Ex38ClFind(lg[k]);
      legs += StringFormat(" | leg %I64u %s last rc=%u attempts %d", lg[k], i < 0 ? "-" : (g_exCl[i].st == EXCL_STALLED ? "STALLED" : (g_exCl[i].st == EXCL_PENDING ? "IN_FLIGHT" : "RETRY")),
                           i < 0 ? 0 : g_exCl[i].rc, i < 0 ? 0 : g_exCl[i].attempts);
   }
   double pl = 0.0, bal = 0.0, pct = 0.0; const bool dd = DdThresholdReached(pl, bal, pct);
   R2Warn("PAIRPEND_" + IntegerToString(g_pairPendSinceMsc),
          StringFormat("R2 WARNING PAIR CLOSE PENDING %I64d s%s | DD %.2f%%%s | no grid / L1 / manual recovery / DD Lock until the pair is resolved; requests bounded (backoff, %d attempts then STALLED %d min)",
                       dur / 1000, legs, pct, dd ? " >= threshold (DD deferred, B2)" : "", Exec_MaxAttempts, Exec_StallRetryMinutes));
}

int AuthCurrent()
{
   if(g_authOwnerReq) return AUTH_OWNER_REQUIRED;
   if(DdlActive()) return AUTH_DD_LOCK;
   if(ExActive()) return AUTH_BASKET_EXITING;
   if(CountPositions() <= 0) return AUTH_FLAT;
   if(PairPendingAny()) return AUTH_PAIR_PENDING;
   return AUTH_GRID;
}
// log every change of the owning mechanism (GRID <-> FLAT, the normal cycle, is not logged)
void AuthTick()
{
   const int a = AuthCurrent();
   if(a == g_authLast) return;
   if(g_authLast >= 0 && !((a == AUTH_GRID && g_authLast == AUTH_FLAT) || (a == AUTH_FLAT && g_authLast == AUTH_GRID)))
      PrintFormat("R2 AUTHORITY %s -> %s | positions %d | DD %s | exit %s | pair %I64u/%I64u | manual recovery records %d (blocking grid %d) | grid freeze %s",
                  Auth38Name(g_authLast), Auth38Name(a), CountPositions(), DdlStateName(g_ddlState), ExActive() ? "EXITING" : "idle", g_pairPend1, g_pairPend2,
                  MrPendingCount(), MrBlocksGrid() ? 1 : 0, g_mrGridFreeze ? MrFreezeName(g_mrFreezeWhy) : ((g_cycIndexShift && ManualPartial_FreezeGrid) ? "PARTIAL_CLOSE_INDEX_SHIFT" : "no"));
   g_authLast = a;
}
// OWNER_REQUIRED: no request of any kind until the Owner removes the wrong record and re-initialises the EA
void AuthOwnerRequiredTick()
{
   g_r2OwnerReqTicks++;
   const long now = Ex38TickMsc();
   if(now - g_r2OwnerLogMsc < 60000) return;
   g_r2OwnerLogMsc = now;
   R2Warn("OWNERREQ", StringFormat("R2 OWNER_REQUIRED | %s | no grid / L1 / recovery / close / hedge request - Terminal > Global Variables: delete the record the Owner rejects (prefix %s = exit, %s = DD lock), then re-initialise the EA",
                                   g_authOwnerWhy, ExNs(), DdlNs()));
}
// restart: one mechanism by the real trading state (consistency report; the modules restored themselves before)
void R2AuthAfterRestore()
{
   DdlInv v; DdlInventory(v);
   const bool flat = (v.n_o == 0 && v.n_r == 0);
   const bool ddUnproven = DdlActive() && (g_ddlState == DDL_LOCK_PENDING || g_ddlState == DDL_LOCK_FAILED);
   const int want = Auth38Resolve(flat, DdlActive(), ddUnproven, v.n_r > 0, ExActive() || g_authOwnerReq, PairPendingAny());
   const int now = AuthCurrent();
   PrintFormat("R2 AUTHORITY AFTER RESTART = %s | evidence: DD record %s, hedge positions %d, basket positions %d | exit record %s | PairClose legs %I64u/%I64u | manual recovery records %d (in flight %d) | grid freeze %s%s",
               Auth38Name(now), DdlStateName(g_ddlState), v.n_r, v.n_o, ExActive() ? "ACTIVE" : (g_authOwnerReq ? "CONFLICT" : "none"), g_pairPend1, g_pairPend2,
               MrPendingCount(), MrInflightAny() ? 1 : 0, g_mrGridFreeze ? MrFreezeName(g_mrFreezeWhy) : "no", want == now ? "" : StringFormat(" | RESOLVER %s DIFFERS", Auth38Name(want)));
   if(want != now && want == AUTH_OWNER_REQUIRED && !g_authOwnerReq) { g_authOwnerReq = true; g_authOwnerWhy = "restart resolver: exit and DD records both claim the basket, no hedge position proves the DD lock"; }
   g_authLast = AuthCurrent();
}

void R2PrintCounters(const string when)
{
   PrintFormat("R2 PRECEDENCE COUNTERS %s | DD deferred while a PairClose leg is pending %I64d ticks | DD not activated (cycle economically >= BE) %I64d ticks | pair decided before DD (same tick) %I64d | T1 deferred while a pair leg is pending %I64d | pair legs merged into a basket exit %I64d | pending-pair warnings %I64d | OWNER_REQUIRED ticks %I64d",
               when, g_r2DdDefPair, g_r2DdDefEcon, g_r2PairFirst, g_r2T1DefPair, g_r2PairMerged, g_r2PairWarnings, g_r2OwnerReqTicks);
}

#endif
// [FINAL STANDALONE] ===== END INLINED OFH38_Precedence.mqh =====
// [FINAL STANDALONE] ===== BEGIN INLINED OFH38_BasketExit.mqh (HOTFIX SHA256 A7AB1CC65B9BED701BAF7F908D859AA1B0054AD44CC87C0D93FA81A98145A497) — included from Onefxhub_v38.38_RPA.mq5:L311 =====
// OFH38_BasketExit.mqh — V38 R1: trạng thái BASKET_EXITING cho cơ chế thoát cụm CÓ SẴN của V26:
//   T1/T2 chạm mức thoát (ManageTrailing), SL/TP T1/T2 của broker (OnTradeTransaction), TP L1 khi còn lệnh, đóng phiên (≤N; >N đang lãi).
// Luật kinh tế V26 KHÔNG đổi: cùng điểm kích hoạt, cùng lệnh đóng (toàn bộ khối lượng từng vị thế, cùng thứ tự V26 — chỉ số cao → thấp).
// Khác V26 ở phần THỰC THI (chỉ thị Owner §7):
//   * đã quyết định thoát → đóng tới khi broker KHÔNG CÒN vị thế nào của cụm (V26 chỉ thử lại khi điều kiện vẫn đúng ở tick sau; giá quay lại
//     hoặc hết 60 phút cuối thì V26 bỏ dở cụm đã đóng một phần);
//   * trong lúc thoát: không thêm Grid, không PairClose, không T1/T2 mới, không L1 mới, không reset chu kỳ trước khi phẳng thật;
//     deal SL/TP / chốt tay của broker chỉ được ghi nhận (không kích hoạt xử lý V26 khác);
//   * mỗi ticket qua Ex38Close: kết quả theo retcode + đọc lại broker, khớp một phần → đóng tiếp phần dư, đang bay → không gửi trùng,
//     lỗi → backoff có trần, hết lượt → STALLED (vẫn giữ quyền thoát, thử lại sau Exec_StallRetryMinutes);
//   * lưu bền ý định thoát (tài khoản / server / symbol / Magic) → khởi động lại tiếp tục đóng; cụm đã phẳng lúc EA tắt → hoàn tất bản ghi;
//   * ghi lãi/lỗ kinh tế của CHU KỲ lúc có tín hiệu (đã chốt từ L1 + nổi) và sau mọi lệnh khớp thật (đã chốt), độ trễ theo giờ tick tester
//     và thời gian CPU thực (tách bạch), số yêu cầu / bị từ chối, |net| lớn nhất trong lúc thoát. Log "EXIT DONE" + CSV.
// DD Lock nắm quyền trước (OnTick kiểm DD Lock trước): đã thoát thì DD không kích hoạt; đang khóa DD thì không có tín hiệu thoát V26.
// V38 R2: cam kết thoát khi chân PairClose còn dở → gộp vào đợt thoát (một quyền đóng, cùng trạng thái đóng theo ticket: không gửi trùng);
// bản ghi khôi phục lệnh đóng tay của cụm → CANCELLED (yêu cầu đang bay → CANCEL_RECONCILE, cụm chỉ hoàn tất khi đã đối soát xong: không vị thế
// mồ côi); khởi động lại khi bản ghi thoát và bản ghi DD cùng nhận cụm mà broker không có lệnh hedge → OWNER_REQUIRED (không chọn bừa).
#ifndef OFH38_BASKETEXIT_MQH
#define OFH38_BASKETEXIT_MQH

#define EXR_T1_HIT          1
#define EXR_T2_HIT          2
#define EXR_T1T2_BROKER     3
#define EXR_L1_TP_EXTRA     4
#define EXR_SESSION_LE_N    5
#define EXR_SESSION_PROFIT  6
#define EXR_OTHER           7
#define EXR_MR_ORPHAN       8   // R2: lệnh vào lại của chu kỳ đã kết thúc khớp trễ → đóng ngay
#define EXR_SESSION_PAIRA   9   // PAIRA_LOOP (Owner B7): chu kỳ đã có Progressive PairClose, lỗ kinh tế <= PairA_SessionMaxLossPct % Equity → đóng hết + nghỉ
#define EXR_LRP_FLATTEN    10   // TPC3: emergency flatten of the last-resort protection — TEST BUILD ONLY (research of its impact; the product never sends it)
#define EXR_T4_BE100_FLAT  11   // TPC4: P0 BE100 FLAT — the whole basket closed when the cycle economic after exit costs >= T4_BeMinUSD at depth T4_Depth (control of P1..P5)
#define EXR_LATE_FILL      12   // [MRR R1] M04: a fill of an order of a FINISHED (finalized, flat) cycle appeared with no other position -> closed at once, never a new L1

#define EXP_NONE            0
#define EXP_WAIT_NEXT_SESSION 1
#define EXP_SKIP_GRID       2

#define EXS_IDLE            0
#define EXS_EXITING         1

string ExReasonName(const int r)
{
   switch(r)
   {
      case EXR_T1_HIT: return "T1_EXIT_HIT"; case EXR_T2_HIT: return "T2_EXIT_HIT"; case EXR_T1T2_BROKER: return "T1T2_BROKER_SLTP";
      case EXR_L1_TP_EXTRA: return "L1_TP_WITH_EXTRA_POSITIONS"; case EXR_SESSION_LE_N: return "SESSION_CLOSE_LE_N"; case EXR_SESSION_PROFIT: return "SESSION_CLOSE_PROFIT_GT_N";
      case EXR_MR_ORPHAN: return "MR_ORPHAN_FILL"; case EXR_SESSION_PAIRA: return "SESSION_CLOSE_PAIRA_LOSS_WITHIN_LIMIT";
      case EXR_LRP_FLATTEN: return "LRP_EMERGENCY_FLATTEN_TEST_ONLY";
      case EXR_T4_BE100_FLAT: return "T4_P0_BE100_FLAT";
      case EXR_LATE_FILL: return "LATE_FILL_OF_FINISHED_CYCLE";   // [MRR R1] M04
   }
   return "OTHER";
}

int      g_exState = EXS_IDLE, g_exReason = 0, g_exPost = EXP_NONE;
long     g_exSigMsc = 0, g_exStartMsc = 0, g_exFirstReqMsc = 0, g_exLastDealMsc = 0;
datetime g_exSigTime = 0;
ulong    g_exSigUs = 0, g_exCpuUs = 0;
double   g_exFloat0 = 0, g_exReal0 = 0, g_exBid0 = 0, g_exAsk0 = 0, g_exNet0 = 0, g_exGross0 = 0, g_exMaxAbsNet = 0;
int      g_exN0 = 0, g_exReq = 0, g_exNotExec = 0, g_exPumps = 0, g_exDeals = 0, g_exLate = 0;
bool     g_exRestored = false, g_exStallLogged = false;
ulong    g_exTk[];

bool   ExActive() { return g_exState != EXS_IDLE; }
string ExNs()     { return OfhNs("OFH38X", Magic); }

// ---------------------------------------------------------------- economic P/L of the cycle (deals of Magic on this symbol since the L1 fill)
// lastOutMsc = latest closing deal of Magic at / after sinceMsc (the last fill of an exit; 0 = none)
double ExRealisedSince(const long startMsc, long &lastOutMsc, const long sinceMsc = 0)
{
   lastOutMsc = 0;
   if(startMsc <= 0) return 0.0;
   const datetime t0 = (datetime)(startMsc / 1000);
   if(!HistorySelect(t0, TimeCurrent() + 60)) return 0.0;
   double s = 0.0;
   for(int i = 0; i < HistoryDealsTotal(); i++)
   {
      const ulong d = HistoryDealGetTicket(i);
      if(d == 0 || HistoryDealGetString(d, DEAL_SYMBOL) != _Symbol || (ulong)HistoryDealGetInteger(d, DEAL_MAGIC) != Magic) continue;
      const long dm = HistoryDealGetInteger(d, DEAL_TIME_MSC);
      if(dm < startMsc) continue;
      const double cost = HistoryDealGetDouble(d, DEAL_COMMISSION) + HistoryDealGetDouble(d, DEAL_FEE);
      const bool in = (HistoryDealGetInteger(d, DEAL_ENTRY) == DEAL_ENTRY_IN);
      s += in ? cost : HistoryDealGetDouble(d, DEAL_PROFIT) + HistoryDealGetDouble(d, DEAL_SWAP) + cost;
      if(!in && sinceMsc > 0 && dm >= sinceMsc && dm > lastOutMsc) lastOutMsc = dm;
   }
   return s;
}
double ExNetNow(double &gross)
{
   double b = 0.0, s = 0.0;
   for(int i = 0; i < PositionsTotal(); i++)
   {
      const ulong t = PositionGetTicket(i);
      if(t == 0 || !PositionSelectByTicket(t) || !IsOursPos()) continue;
      if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY) b += PositionGetDouble(POSITION_VOLUME); else s += PositionGetDouble(POSITION_VOLUME);
   }
   gross = b + s;
   return b - s;
}
bool ExKnown(const ulong t) { for(int i = 0; i < ArraySize(g_exTk); i++) if(g_exTk[i] == t) return true; return false; }

// ---------------------------------------------------------------- persistence
void ExPersist()
{
   const string ns = ExNs();
   GlobalVariableSet(ns + "state", g_exState); GlobalVariableSet(ns + "reason", g_exReason); GlobalVariableSet(ns + "post", g_exPost);
   GlobalVariableSet(ns + "sigmsc", (double)g_exSigMsc); GlobalVariableSet(ns + "sigtime", (double)g_exSigTime); GlobalVariableSet(ns + "startmsc", (double)g_exStartMsc);
   GlobalVariableSet(ns + "float0", g_exFloat0); GlobalVariableSet(ns + "real0", g_exReal0); GlobalVariableSet(ns + "bid0", g_exBid0); GlobalVariableSet(ns + "ask0", g_exAsk0);
   GlobalVariableSet(ns + "net0", g_exNet0); GlobalVariableSet(ns + "gross0", g_exGross0); GlobalVariableSet(ns + "n0", g_exN0);
   GlobalVariableSet(ns + "req", g_exReq); GlobalVariableSet(ns + "notexec", g_exNotExec); GlobalVariableSet(ns + "firstreq", (double)g_exFirstReqMsc);
   GlobalVariableSet(ns + "maxnet", g_exMaxAbsNet);
   const int n = ArraySize(g_exTk);
   GlobalVariableSet(ns + "ntk", n);
   for(int i = 0; i < n; i++) GlobalVariableSet(ns + "t" + IntegerToString(i), (double)g_exTk[i]);
   OfhIdStore(ns, Magic);
}
void ExClearPersist() { if(GlobalVariablesDeleteAll(ExNs()) > 0) GlobalVariablesFlush(); }

// ---------------------------------------------------------------- commit / pump / complete
void ExCommit(const int reason, const int post)
{
   g_exState = EXS_EXITING; g_exReason = reason; g_exPost = post; g_exRestored = false; g_exStallLogged = false;
   MqlTick tk; const bool have = SymbolInfoTick(_Symbol, tk);
   g_exSigMsc = (have && tk.time_msc > 0) ? tk.time_msc : (long)TimeCurrent() * 1000; g_exSigTime = TimeCurrent(); g_exSigUs = GetMicrosecondCount();
   g_exBid0 = have ? tk.bid : 0.0; g_exAsk0 = have ? tk.ask : 0.0;
   g_exStartMsc = CycStartMsc();
   long lo; g_exFloat0 = BasketProfit(); g_exReal0 = ExRealisedSince(g_exStartMsc, lo);
   g_exNet0 = ExNetNow(g_exGross0); g_exMaxAbsNet = MathAbs(g_exNet0);
   g_exReq = 0; g_exNotExec = 0; g_exPumps = 0; g_exDeals = 0; g_exLate = 0; g_exFirstReqMsc = 0; g_exLastDealMsc = 0; g_exCpuUs = 0;
   ArrayResize(g_exTk, 0);
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      const ulong t = PositionGetTicket(i);
      if(t == 0 || !PositionSelectByTicket(t) || !IsOursPos()) continue;
      const int n = ArraySize(g_exTk); ArrayResize(g_exTk, n + 1); g_exTk[n] = t;
   }
   g_exN0 = ArraySize(g_exTk);
   PrintFormat("=== BASKET_EXITING | %s | positions %d net %+.2f gross %.2f | bid %.2f ask %.2f | cycle P/L at signal %.2f (realised %.2f + floating %.2f) | no grid / PairClose / L1 until the broker shows the basket flat ===",
               ExReasonName(reason), g_exN0, g_exNet0, g_exGross0, g_exBid0, g_exAsk0, g_exReal0 + g_exFloat0, g_exReal0, g_exFloat0);
   // R2 (Owner B6): PairClose leg(s) still open → merged into this exit: one close authority, the same per-ticket close state (Ex38Close registry)
   if(g_pairPend1 != 0 || g_pairPend2 != 0)
   {
      g_r2PairMerged++;
      PrintFormat("BASKET_EXITING | PairClose leg(s) %I64u/%I64u still pending -> merged into the basket exit (one close authority, in-flight closes are not re-sent)", g_pairPend1, g_pairPend2);
      g_pairPend1 = 0; g_pairPend2 = 0; g_pairPendSinceMsc = 0;
   }
   MrOnExitCommit();   // R2: recovery records of an exiting basket are cancelled (in flight -> reconciled first)
   ExPersist(); GlobalVariablesFlush();
}
// R2: a recovery request of a finished cycle filled late (basket flat): close it at once as its own exit
void ExCommitOrphanClose() { CloseBasketR(EXR_MR_ORPHAN, EXP_NONE); }

void ExComplete()
{
   const long tm = Ex38TickMsc();
   long lastOut = 0;
   const double realF = ExRealisedSince(g_exStartMsc, lastOut, g_exSigMsc);
   if(lastOut > g_exLastDealMsc) g_exLastDealMsc = lastOut;   // the fills of the flat tick are in the history before their trade events arrive
   const double plSig = g_exReal0 + g_exFloat0;
   PrintFormat("EXIT DONE | %s%s | positions at signal %d (late fills %d) | requests %d (not executed %d) in %d pumps | tester time after signal: first request %s, last deal %s, flat +%I64d ms | real CPU in exit calls %I64u us | cycle P/L at signal %.2f -> realised %.2f (erosion %+.2f) | max |net| during exit %.2f",
               ExReasonName(g_exReason), g_exRestored ? " (resumed after restart)" : "", g_exN0, g_exLate, g_exReq, g_exNotExec, g_exPumps,
               g_exFirstReqMsc > 0 ? StringFormat("+%I64d ms", g_exFirstReqMsc - g_exSigMsc) : "-", g_exLastDealMsc > 0 ? StringFormat("+%I64d ms", g_exLastDealMsc - g_exSigMsc) : "-",
               tm - g_exSigMsc, g_exCpuUs, plSig, realF, realF - plSig, g_exMaxAbsNet);
   if(Exit_LogCsv) ExCsv(tm, realF, plSig);
   ExClearPersist();
   const int post = g_exPost;
   g_exState = EXS_IDLE; g_exReason = 0; g_exPost = EXP_NONE; ArrayResize(g_exTk, 0);
   ResetCycleState();
   if(post == EXP_WAIT_NEXT_SESSION) NghiDenPhienSau();
   if(post == EXP_SKIP_GRID) skipGridThisTick = true;
}

// close every open position of the basket (V26 order: index high -> low). Rounds 2-3 of one pump only for residuals of partial fills.
void ExPump()
{
   if(g_exState == EXS_IDLE) return;
   const ulong us0 = GetMicrosecondCount();
   g_exPumps++;
   for(int round = 0; round < 3; round++)
   {
      bool any = false, again = false;
      for(int i = PositionsTotal() - 1; i >= 0; i--)
      {
         const ulong t = PositionGetTicket(i);
         if(t == 0 || !PositionSelectByTicket(t) || !IsOursPos()) continue;
         any = true;
         if(!ExKnown(t)) { const int n = ArraySize(g_exTk); ArrayResize(g_exTk, n + 1); g_exTk[n] = t; g_exLate++; PrintFormat("BASKET_EXITING | position %I64u appeared after the signal (late fill) - closed with the basket", t); }
         if(round > 0 && Ex38ClState(t) != EXCL_PARTIAL) continue;
         const long s0 = trade.m_sends;
         const int r = Ex38Close(trade, t, "EXIT " + ExReasonName(g_exReason));
         if(trade.m_sends > s0)
         {
            g_exReq++;
            if(g_exFirstReqMsc == 0) g_exFirstReqMsc = Ex38TickMsc();
            if(r == EXCL_RETRY) g_exNotExec++;
         }
         if(r == EXCL_PARTIAL) again = true;
         if(r == EXCL_STALLED && !g_exStallLogged) { g_exStallLogged = true; PrintFormat("BASKET_EXITING STALLED | %s | ticket %I64u could not be closed after %d requests - exit authority kept (no grid / no L1), next round in %d min", ExReasonName(g_exReason), t, Exec_MaxAttempts, Exec_StallRetryMinutes); }
      }
      if(!any || !again) break;
   }
   double g; const double net = ExNetNow(g);
   if(MathAbs(net) > g_exMaxAbsNet) g_exMaxAbsNet = MathAbs(net);
   g_exCpuUs += GetMicrosecondCount() - us0;
   if(CountPositions() <= 0)
   {
      // R2: a recovery request still in flight could fill after the cycle ends -> the exit completes only once it is reconciled (no orphan position)
      if(MrInflightAny()) MrReconcileAll();
      if(MrInflightAny()) { MrLogOnce("EXWAIT_" + IntegerToString(g_exSigMsc), "BASKET_EXITING | broker flat, waiting for the reconciliation of a recovery request in flight (a late fill is closed with the basket)"); ExPersist(); return; }
      ExComplete();
   }
   else ExPersist();
}

// a deal of Magic while the exit owns the basket (broker SL/TP, our close, manual close): recorded only
void ExOnDeal(const ulong deal)
{
   g_exDeals++;
   const long dm = HistoryDealGetInteger(deal, DEAL_TIME_MSC);
   if(dm > g_exLastDealMsc) g_exLastDealMsc = dm;
}

// V26 call sites: CloseBasket() → commit the exit (once) and pump it now. true = the broker shows the basket flat.
bool CloseBasketR(const int reason, const int post)
{
   if(g_exState == EXS_IDLE)
   {
      RrGrid("EXIT_START", CountPositions(), 0, 0.0, 0.0, 0.0, ExReasonName(reason));   // LPGD recorder (tester only)
      if(CountPositions() <= 0) return true;
      ExCommit(reason, post);
   }
   else if(post != EXP_NONE && g_exPost == EXP_NONE) g_exPost = post;
   ExPump();
   return (CountPositions() <= 0);
}

void ExCsv(const long tm, const double realF, const double plSig)
{
   FolderCreate("OFH38", FILE_COMMON);
   const string f = "OFH38\\EXIT_" + _Symbol + "_" + IntegerToString((long)Magic) + ((bool)MQLInfoInteger(MQL_TESTER) ? "_TESTER" : "") + ".csv";
   const int h = FileOpen(f, FILE_READ | FILE_WRITE | FILE_TXT | FILE_ANSI | FILE_COMMON | FILE_SHARE_READ);
   if(h == INVALID_HANDLE) return;
   if(FileSize(h) == 0)
      FileWriteString(h, "signal_time,signal_msc,reason,restarted,positions_at_signal,late_fills,net_at_signal,gross_at_signal,bid,ask,realised_before,floating_at_signal,"
                         "cycle_pl_at_signal,first_request_ms,last_deal_ms,flat_ms,real_cpu_us,requests,not_executed,pumps,max_abs_net,realised_final,erosion\n");
   FileSeek(h, 0, SEEK_END);
   FileWriteString(h, StringFormat("%s,%I64d,%s,%d,%d,%d,%+.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%I64d,%I64d,%I64d,%I64u,%d,%d,%d,%.2f,%.2f,%+.2f\n",
                   TimeToString(g_exSigTime, TIME_DATE | TIME_SECONDS), g_exSigMsc, ExReasonName(g_exReason), g_exRestored ? 1 : 0, g_exN0, g_exLate, g_exNet0, g_exGross0,
                   g_exBid0, g_exAsk0, g_exReal0, g_exFloat0, plSig, g_exFirstReqMsc > 0 ? g_exFirstReqMsc - g_exSigMsc : -1, g_exLastDealMsc > 0 ? g_exLastDealMsc - g_exSigMsc : -1,
                   tm - g_exSigMsc, g_exCpuUs, g_exReq, g_exNotExec, g_exPumps, g_exMaxAbsNet, realF, realF - plSig));
   FileClose(h);
}

// restart: an exit that was committed before the restart continues (or completes when the broker already shows the basket flat)
void ExRestore()
{
   g_exState = EXS_IDLE;
   const string ns = ExNs();
   if(!GlobalVariableCheck(ns + "state")) return;
   const string idWhy = OfhIdCheck(ns, Magic);
   if(idWhy != "") { PrintFormat("EXIT RECORD %s IGNORED | identity mismatch (%s)", ns, idWhy); return; }
   if(DdlActive())
   {
      // R2 (E.2): both records claim the basket. A hedge position / a lock beyond LOCK_PENDING proves the DD lock -> DD keeps it (R1). Neither proven
      // (exit tickets open, DD still LOCK_PENDING / LOCK_FAILED, no hedge position) -> OWNER_REQUIRED: no request until the Owner removes one record.
      const int nt = (int)GlobalVariableGet(ns + "ntk"); int open = 0;
      for(int i = 0; i < nt; i++) if(OfhTicketIsOurs((ulong)GlobalVariableGet(ns + "t" + IntegerToString(i)), Magic)) open++;
      DdlInv v; DdlInventory(v);
      if(open > 0 && v.n_r == 0 && (g_ddlState == DDL_LOCK_PENDING || g_ddlState == DDL_LOCK_FAILED))
      {
         g_authOwnerReq = true;
         g_authOwnerWhy = StringFormat("exit record (%s, %d tickets open) and DD record (%s, no hedge position) both claim the basket", ExReasonName((int)GlobalVariableGet(ns + "reason")), open, DdlStateName(g_ddlState));
         PrintFormat("EXIT RECORD CONFLICT | %s -> OWNER_REQUIRED (both records kept)", g_authOwnerWhy);
         return;
      }
      Print("EXIT RECORD IGNORED | the DD Lock owns the basket"); ExClearPersist(); return;
   }
   g_exState = (int)GlobalVariableGet(ns + "state"); g_exReason = (int)GlobalVariableGet(ns + "reason"); g_exPost = (int)GlobalVariableGet(ns + "post");
   g_exSigMsc = (long)GlobalVariableGet(ns + "sigmsc"); g_exSigTime = (datetime)GlobalVariableGet(ns + "sigtime"); g_exStartMsc = (long)GlobalVariableGet(ns + "startmsc");
   g_exFloat0 = GlobalVariableGet(ns + "float0"); g_exReal0 = GlobalVariableGet(ns + "real0"); g_exBid0 = GlobalVariableGet(ns + "bid0"); g_exAsk0 = GlobalVariableGet(ns + "ask0");
   g_exNet0 = GlobalVariableGet(ns + "net0"); g_exGross0 = GlobalVariableGet(ns + "gross0"); g_exN0 = (int)GlobalVariableGet(ns + "n0");
   g_exReq = (int)GlobalVariableGet(ns + "req"); g_exNotExec = (int)GlobalVariableGet(ns + "notexec"); g_exFirstReqMsc = (long)GlobalVariableGet(ns + "firstreq");
   g_exMaxAbsNet = GlobalVariableGet(ns + "maxnet");
   const int n = (int)GlobalVariableGet(ns + "ntk");
   ArrayResize(g_exTk, MathMax(0, n));
   for(int i = 0; i < n; i++) g_exTk[i] = (ulong)GlobalVariableGet(ns + "t" + IntegerToString(i));
   g_exPumps = 0; g_exDeals = 0; g_exLate = 0; g_exLastDealMsc = 0; g_exCpuUs = 0; g_exSigUs = GetMicrosecondCount(); g_exRestored = true; g_exStallLogged = false;
   if(g_exState == EXS_IDLE) { ExClearPersist(); return; }
   // the record must belong to the open basket: positions open but none of the recorded tickets → that exit already finished, the open positions
   // are another basket → never close them under the old exit decision (record cleared, nothing reset)
   int recOpen = 0;
   for(int i = 0; i < n; i++) if(OfhTicketIsOurs(g_exTk[i], Magic)) recOpen++;
   if(CountPositions() > 0 && recOpen == 0)
   {
      PrintFormat("EXIT RECORD STALE | %s committed %s: none of its %d tickets is open, the %d open positions are another basket - record cleared, nothing closed",
                  ExReasonName(g_exReason), TimeToString(g_exSigTime, TIME_DATE | TIME_SECONDS), n, CountPositions());
      g_exState = EXS_IDLE; ArrayResize(g_exTk, 0); ExClearPersist();
      return;
   }
   PrintFormat("EXIT RESTORED | %s committed %s | positions now %d of %d at the signal | the exit continues until the broker shows the basket flat",
               ExReasonName(g_exReason), TimeToString(g_exSigTime, TIME_DATE | TIME_SECONDS), CountPositions(), g_exN0);
   if(CountPositions() <= 0 && !MrInflightAny()) ExComplete();
   else Ex38RestartGrace("BASKET_EXITING resumed");
}

#endif
// [FINAL STANDALONE] ===== END INLINED OFH38_BasketExit.mqh =====
// [MRR R1] M04 late-fill guard (after OFH38_BasketExit: it commits a basket exit with EXR_LATE_FILL)
// M04: positions found while no cycle of the EA runs after a finalized cycle. true = they are closed on this tick (the caller returns).
bool MrrLateFillGuard()
{
   if(g_mrrFinMsc <= 0) return false;
   ulong pid[]; int np = 0;
   for(int i = 0; i < PositionsTotal(); i++)
   {
      const ulong t = PositionGetTicket(i);
      if(t == 0 || !PositionSelectByTicket(t) || !IsOursPos()) continue;
      ArrayResize(pid, np + 1); pid[np++] = (ulong)PositionGetInteger(POSITION_IDENTIFIER);
   }
   int late = 0, older = 0; string ids = "", olds = ""; ulong minId = 0;
   for(int k = 0; k < np; k++)
   {
      long setup = 0;
      if(HistoryOrderSelect(pid[k])) setup = HistoryOrderGetInteger(pid[k], ORDER_TIME_SETUP_MSC);
      if(minId == 0 || pid[k] < minId) minId = pid[k];
      if(pid[k] <= g_mrrFinMaxSeen) { older++; olds += StringFormat("%s%I64u", olds == "" ? "" : ", ", pid[k]); }   // a position of the finished basket reappeared
      if(Mrr38LateFillOfFinished(MrrInLateSet(pid[k]), g_mrrLateUnknown, setup, g_mrrFinMsc, pid[k], g_mrrFinMaxSeen, g_mrrFinWm)) { late++; ids += StringFormat("%s%I64u (order set up %I64d)", ids == "" ? "" : ", ", pid[k], setup); }
   }
   const int act = Mrr38LateAction(np, late, older);
   if(act == MRR_LATE_CLOSE)
   {
      g_mrrLateFills++; g_mrrLateClosed = true; g_mrrAwaitL1 = true;
      PrintFormat("UNEXPECTED LATE FILL | %d position(s) of order(s) still working when the BasketCycleID %I64d was finalized (flat at %I64d): %s -> closed now (BASKET_EXITING %s), never adopted as a new L1",
                  late, g_mrrFinCyc, g_mrrFinMsc, ids, ExReasonName(EXR_LATE_FILL));
      CloseBasketR(EXR_LATE_FILL, EXP_NONE);
      return true;
   }
   if(act == MRR_LATE_MIXED)
   {
      g_mrrLateMixed++;
      PrintFormat("BROKER STATE INCONSISTENCY | %d of %d open position(s) are late fills of the finished BasketCycleID %I64d (%s) next to other position(s) -> no grid level for this basket (BLOCKER), exits / T1 / T2 / session keep working",
                  late, np, g_mrrFinCyc, ids);
      MrFreezeGrid(MRF_LEVEL_UNPROVEN, StringFormat("late fill(s) of the finished BasketCycleID %I64d next to other positions: %s", g_mrrFinCyc, ids));
   }
   else if(older > 0)   // log only: positions of the finished basket reappeared (the terminal listed no position for a tick): the flat was transient, adopted as before
      PrintFormat("BROKER STATE INCONSISTENCY | %d position(s) of the finalized BasketCycleID %I64d reappeared without an L1 of the EA (%s; %d open now, %d would match the late-fill rule): the flat was transient -> adopted as the basket (as before), nothing closed by the late-fill rule",
                  older, g_mrrFinCyc, olds, np, late);
   // a new basket (or the inconsistent one above) runs now: the finished cycle is over
   MrrClearFinished(); g_mrrCycFirstOrd = minId;
   MrrPersist();
   return false;
}

// [FINAL STANDALONE] ===== BEGIN INLINED OFH38_CycleLatch.mqh (HOTFIX SHA256 259834478070A2413D82618543D58DB02283FFBE3812AF1A8A8FA0DF3F6B4C5F) — included from Onefxhub_v38.38_RPA.mq5:L312 =====
// OFH38_CycleLatch.mqh — V38 PAIRA_LOOP (Owner 24/10/2026, B8): cấu hình của MỘT BasketCycleID được chốt (latch) khi chu kỳ bắt đầu (tick đầu tiên có vị thế
// sau khi L1 RSI khớp) và lưu bền theo chu kỳ (namespace OFH38K). Khởi động lại khi cụm còn lệnh mà Input khác bản ghi: bản ghi KHÔNG mất, chu kỳ tiếp tục theo giá trị
// đã chốt, KHÔNG nhận quyết định mới (không thêm cấp Grid, không rebase mới), cảnh báo CONFIG_CHANGED_MIDCYCLE; T1 / T2 / DD / phiên / đối soát vẫn chạy.
// Thay đổi chỉ áp dụng từ BasketCycleID kế tiếp. Không chốt theo chu kỳ (như R3 FINAL): G1..G25, khoảng T1 / T2 (pip), phiên, DD.
// RECURSIVE PAIR_A REBASE V1 (Owner 31/10/2026): các trường của bộ điều khiển PairClose cũ (PairA / PPA80 / PPA80-S / TWO-PAIRCLOSE / TPC2 BO / TPC3 / TPC4) đã GỠ
// cùng các module đó; thay bằng trường của RPA (OriginalPairCloseStartOrder, RecursiveRebaseTargetLevel) + kinh tế / cổng rủi ro dùng chung + chiến lược / lot ladder.
#ifndef OFH38_CYCLELATCH_MQH
#define OFH38_CYCLELATCH_MQH

// [FINAL STANDALONE] ===== BEGIN INLINED OFH38_Owner12_Core.mqh (HOTFIX SHA256 CFB61807B21D1E3CAF6633386D079FEB00D092D4307DE37E823BCB45867A63EC) — included from OFH38_CycleLatch.mqh:L10 =====
// OFH38_Owner12_Core.mqh — V38 OWNER12 (chỉ thị Owner 25/10/2026): các phép quyết định THUẦN (không đọc broker / Input), có unit test (OFH38_UnitTests.mq5, mục O12).
//   Mục 1: kiểu vào lệnh chỉ 0 = V26 truyền thống / 1 = GLOBAL Grid Mode 1; khóa migration cho SET cũ còn khóa bool Enable_GlobalGridAIPro.
//   Mục 2: miền Input T1 / T2 (pip) và điều kiện giá T1 (cùng phép tính với T1EligibleNow của EA).
//   Mục 3: quyết định cuối phiên — (a) chu kỳ CHƯA từng Progressive PairClose: <= CloseProtect_MaxOrders vị thế → đóng hết + nghỉ, > N → tiếp tục (rescue);
//          (b) ĐÃ từng: lỗ kinh tế <= CloseProtect_PairACycleMaxLossPct % equity → đóng hết + nghỉ, lớn hơn → tiếp tục, không L1 song song;
//          (c) yêu cầu broker đang bay → đối soát trước, chưa quyết định.
//   Mục 5: trần dải hồi phục cố định nội bộ 99 %.
#ifndef OFH38_OWNER12_CORE_MQH
#define OFH38_OWNER12_CORE_MQH

#define O12_ENTRY_V26      0
#define O12_ENTRY_GLOBAL   1
#define O12_BAND_MAX_PCT   99.0   // mục 5: không còn Input PairA_RecoveryBandMaxPct công khai

// ---------------------------------------------------------------- mục 1
bool O12EntryValid(const int v) { return v == O12_ENTRY_V26 || v == O12_ENTRY_GLOBAL; }
string O12EntryName(const int v) { return v == O12_ENTRY_V26 ? "0 = V26 truyen thong" : (v == O12_ENTRY_GLOBAL ? "1 = GLOBAL Grid Mode 1" : StringFormat("%d = INVALID", v)); }
// giá trị của khóa cũ Enable_GlobalGridAIPro trong SET (Input string, phần trước '|' nếu SET có dạng tối ưu "true||false||0||true||N"):
// -1 = không dùng ("NOT_USED" = mặc định, "" , "-", "none"), 0 = false / 0, 1 = true / 1, -2 = không đọc được.
// Mặc định là chuỗi KHÔNG RỖNG "NOT_USED": Strategy Tester bỏ qua một Input string rỗng trong [TesterInputs] và lấy giá trị đã lưu trong profile của tester
// (đo 25/10/2026: một lượt sau lượt thử migration nhận lại 'true' / 'yes') — SET luôn ghi rõ NOT_USED thì profile không thể chen vào.
int O12LegacyGlobal(const string raw)
{
   string s = raw;
   const int bar = StringFind(s, "|");
   if(bar >= 0) s = StringSubstr(s, 0, bar);
   StringTrimLeft(s); StringTrimRight(s); StringToLower(s);
   if(s == "" || s == "not_used" || s == "-" || s == "none") return -1;
   if(s == "true" || s == "1") return 1;
   if(s == "false" || s == "0") return 0;
   return -2;
}
#define O12M_OK          0   // khóa cũ trống: Entry_Strategy quyết định
#define O12M_CONSISTENT  1   // khóa cũ có, cùng nghĩa với Entry_Strategy: chạy, cảnh báo xóa khóa cũ
#define O12M_CONFLICT   -1   // khóa cũ khác Entry_Strategy: KHÔNG khởi động (SET cũ chưa đặt Entry_Strategy → không âm thầm chạy V26)
#define O12M_UNREADABLE -2   // khóa cũ không phải true / false / 0 / 1: KHÔNG khởi động
#define O12M_BADENTRY   -3   // Entry_Strategy ngoài 0 / 1: KHÔNG khởi động
int O12MigrationCheck(const int entry, const string legacyRaw)
{
   if(!O12EntryValid(entry)) return O12M_BADENTRY;
   const int lg = O12LegacyGlobal(legacyRaw);
   if(lg == -1) return O12M_OK;
   if(lg == -2) return O12M_UNREADABLE;
   return (lg == entry) ? O12M_CONSISTENT : O12M_CONFLICT;
}
string O12MigrationName(const int c)
{
   switch(c)
   {
      case O12M_OK: return "OK"; case O12M_CONSISTENT: return "LEGACY_KEY_CONSISTENT"; case O12M_CONFLICT: return "LEGACY_KEY_CONFLICT";
      case O12M_UNREADABLE: return "LEGACY_KEY_UNREADABLE"; case O12M_BADENTRY: return "ENTRY_NOT_0_OR_1";
   }
   return "?";
}

// ---------------------------------------------------------------- mục 2 (đơn vị pip của EA: XAU 1 pip = 0.1 giá)
double O12PipToPrice(const double pips, const double pipSize) { return pips * pipSize; }
// T1 kích hoạt khi giá qua BE ± Khoang_Doi_SL, khóa tại BE ± So_Pip_Doi_SL (phải nằm GIỮA BE và mức kích hoạt), T2 kéo SL cách giá Khoang_Trailing_SL
bool O12T1T2Valid(const double doiSlPip, const double lockPip, const double trailPip)
{
   return doiSlPip > 0.0 && lockPip >= 0.0 && lockPip < doiSlPip && trailPip > 0.0;
}
// điều kiện giá T1 (cùng phép tính với T1EligibleNow): netDir 1 = Buy Net (xem Bid), -1 = Sell Net (xem Ask); lockPx = BE ± khóa
bool O12T1Eligible(const int netDir, const double be, const double bid, const double ask, const double trigDist, const double lockDist, double &lockPx)
{
   lockPx = 0.0;
   if(netDir == 0 || be <= 0.0) return false;
   if(netDir > 0) { if(bid + 1e-12 < be + trigDist) return false; lockPx = be + lockDist; return true; }
   if(ask - 1e-12 > be - trigDist) return false;
   lockPx = be - lockDist; return true;
}

// ---------------------------------------------------------------- mục 3 (quyết định ở cửa sổ đóng phiên = MinBeforeClose phút cuối)
#define O12S_NONE          0   // ngoài cửa sổ đóng phiên / cụm phẳng
#define O12S_CLOSE_LE_N    1   // (a) chưa từng PairClose, <= N vị thế → đóng hết + nghỉ
#define O12S_RESCUE        2   // (a) chưa từng PairClose, > N (hoặc đã rescue) → tiếp tục Grid của chiến lược tới điều kiện thoát
#define O12S_CLOSE_PAIRA   3   // (b) đã từng PairClose, lỗ kinh tế <= ngưỡng → đóng hết + nghỉ
#define O12S_RESCUE_PAIRA  4   // (b) đã từng PairClose, lỗ lớn hơn → tiếp tục quản lý, không L1 song song
#define O12S_DEFER         5   // (c) yêu cầu PairA / chân đóng / thoát đang bay → đối soát trước, tick sau quyết định
// ngưỡng hiệu lực: tắt CloseProtect_UsePairACycleLossPct → 0 % (chỉ đóng khi chu kỳ >= hòa vốn kinh tế)
double O12SessionPctEff(const bool useLossPct, const double maxLossPct) { return useLossPct ? MathMax(0.0, maxLossPct) : 0.0; }
int O12SessionDecision(const bool nearEnd, const bool inFlight, const bool hadPairA, const int total, const int maxOrders, const bool inRescue,
                       const double econ, const double equity, const double pctEff)
{
   if(total <= 0 || !nearEnd) return O12S_NONE;
   if(inFlight) return O12S_DEFER;
   if(hadPairA) return (econ >= -MathMax(0.0, pctEff) / 100.0 * MathMax(0.0, equity) - 1e-9) ? O12S_CLOSE_PAIRA : O12S_RESCUE_PAIRA;
   if(!inRescue && total <= maxOrders) return O12S_CLOSE_LE_N;
   return O12S_RESCUE;
}
string O12SessionName(const int d)
{
   switch(d)
   {
      case O12S_NONE: return "NONE"; case O12S_CLOSE_LE_N: return "CLOSE_LE_N_REST"; case O12S_RESCUE: return "RESCUE_CONTINUE";
      case O12S_CLOSE_PAIRA: return "PAIRA_CLOSE_REST"; case O12S_RESCUE_PAIRA: return "PAIRA_RESCUE_CONTINUE"; case O12S_DEFER: return "DEFER_RECONCILE";
   }
   return "?";
}

// ---------------------------------------------------------------- mục 5
bool O12BandMinValid(const double minPct) { return minPct > 0.0 && minPct <= O12_BAND_MAX_PCT; }

// ---------------------------------------------------------------- mục 6: config hash của tham số nghiên cứu (FNV-1a 32 bit trên chuỗi giá trị)
uint O12Fnv1a(const string s)
{
   uint h = 2166136261;
   const int n = StringLen(s);
   for(int i = 0; i < n; i++) { h ^= (uint)StringGetCharacter(s, i); h *= 16777619; }
   return h;
}

#endif
// [FINAL STANDALONE] ===== END INLINED OFH38_Owner12_Core.mqh =====

#define CL_RPA_START    0   // OriginalPairCloseStartOrder
#define CL_RPA_K        1   // RecursiveRebaseTargetLevel
#define CL_GG_ON        2   // Entry_Strategy (1 = GLOBAL Grid Mode 1)
#define CL_GG_K         3
#define CL_GG_D         4
#define CL_MAXORD       5   // Max_Orders = GridMaxOrders = SubGridMaxAdditionalOrders
#define CL_INITLOT      6
#define CL_MULTI        7
#define CL_SESS         8   // CloseProtect_PairACycleLossPct (effective)
#define CL_SET_MIN      9   // PairA_SettleMinUSD: BE100 minimum of the whole cycle after projected exit cost
#define CL_COST        10   // PairA_CloseCostPerLotUSD
#define CL_SLIP        11   // PairA_SlipReservePoints
#define CL_PF_STRESS   12   // PairA_PfStressUSD
#define CL_PF_LOSS     13   // PairA_PfMaxStressLossPct
#define CL_PF_ML       14   // PairA_PfMinMarginLevelPct
#define CL_SHADOW      15   // PairA_ShadowOnly
#define CL_EXIT_MODE   16
#define CL_EXIT_TF     17
#define CL_EXIT_EF     18
#define CL_EXIT_ES     19
#define CL_EXIT_ATR    20
#define CL_EXIT_STRONG 21
#define CL_EXIT_FSTART 22
#define CL_EXIT_FKEEP  23
#define CL_EXIT_MW     24
#define CL_EXIT_MS     25
#define CL_EXIT_TMIN   26
#define CL_EXIT_TMAX   27
#define CL38_N         28

double g_clIn[CL38_N];             // Input hiện tại (đọc ở OnInit)
double g_cl[CL38_N];               // giá trị đã chốt của chu kỳ đang mở
bool   g_clHave = false;
long   g_clCycle = 0;
bool   g_clFrozen = false;          // Input khác bản ghi của chu kỳ đang mở → không lệnh mới tới hết chu kỳ
string g_clFrozenWhy = "";
long   g_clFrozenTicks = 0, g_clLatched = 0, g_clMismatch = 0;
// [GLOBAL GEN] G04: GLOBAL internal distance list of the cycle (pip) — only the elements the group structure needs (Gg38LdRequired of K / Max_Orders), only when GLOBAL
// is the entry strategy (V26: count 0, the input is never read). Persisted with the cycle record: "ldv" = 2 (layout with a list), "ldn" = count, "ld<i>" = element i + 1.
double g_clLdIn[GG38_LD_MAX]; int g_clLdInN = 0;   // current input
double g_clLd[GG38_LD_MAX];   int g_clLdN = 0;     // latched for the open cycle
long   g_clLdLegacy = 0;                           // GLOBAL cycles of an older build (no list in the record) frozen at a restart
// [DPMR R1] D01: PairClose_Mode of the cycle, latched with the cycle configuration (record keys "pcv" = 1 layout with the mode, "pcm" = mode)
int    g_clPcModeIn = DPMR_PC_RPA;                 // current input
int    g_clPcMode   = DPMR_PC_RPA;                 // latched for the open cycle
long   g_clPcOldRec = 0, g_clPcRpaEvidence = 0;    // restores: records of an older build (no mode key -> mode 1) / mode-0 latches overruled by an RPA trace of the cycle
int    PcMode() { return Dpmr38EffectiveMode(g_clHave, g_clPcMode, g_clPcModeIn); }
string PcModeName(const int m) { return m == DPMR_PC_V26 ? "0 V26_LEGACY_PAIR_CLOSE" : (m == DPMR_PC_RPA ? "1 V38_RECURSIVE_PAIR_A" : StringFormat("%d INVALID", m)); }
int    ClLdCount() { return g_clHave ? g_clLdN : g_clLdInN; }
double ClLdGet(const int i) { const int n = ClLdCount(); if(i < 1 || i > n) return -1.0; return g_clHave ? g_clLd[i - 1] : g_clLdIn[i - 1]; }
void   ClLdLatchInputs() { g_clLdN = g_clLdInN; for(int i = 0; i < g_clLdInN; i++) g_clLd[i] = g_clLdIn[i]; }

string Cl38FieldName(const int i)
{
   const string nm[CL38_N] = {"OriginalPairCloseStartOrder", "RecursiveRebaseTargetLevel", "Entry_Strategy", "GlobalGrid_OrdersPerGroup", "GlobalGrid_BreakoutDistanceUSD",
                              "Max_Orders", "Initial_Lot", "Lot_Multi", "CloseProtect_PairACycleLossPct(effective)", "PairA_SettleMinUSD", "PairA_CloseCostPerLotUSD",
                              "PairA_SlipReservePoints", "PairA_PfStressUSD", "PairA_PfMaxStressLossPct", "PairA_PfMinMarginLevelPct", "PairA_ShadowOnly",
                              "Exit_Mode", "ExitTrend_TF", "ExitTrend_EmaFast", "ExitTrend_EmaSlow", "ExitTrend_AtrPeriod", "ExitTrend_StrongScore", "ExitHyb_FloorStartPips",
                              "ExitHyb_FloorKeepPct", "ExitHyb_AtrMultWeak", "ExitHyb_AtrMultStrong", "ExitHyb_TrailMinPips", "ExitHyb_TrailMaxPips"};
   return (i >= 0 && i < CL38_N) ? nm[i] : "?";
}
void ClReadInputs()
{
   const bool gl = (Entry_Strategy == OFH38_ENTRY_GLOBAL);
   g_clIn[CL_RPA_START] = OriginalPairCloseStartOrder;       g_clIn[CL_RPA_K] = RecursiveRebaseTargetLevel;
   g_clIn[CL_GG_ON] = gl ? 1 : 0;                            g_clIn[CL_GG_K] = GlobalGrid_OrdersPerGroup;   g_clIn[CL_GG_D] = GlobalGrid_BreakoutDistanceUSD;
   g_clIn[CL_MAXORD] = Max_Orders;                           g_clIn[CL_INITLOT] = Initial_Lot;              g_clIn[CL_MULTI] = Lot_Multi;
   // OWNER12: ngưỡng lỗ phiên của chu kỳ đã có PairClose = CloseProtect_UsePairACycleLossPct ? CloseProtect_PairACycleMaxLossPct : 0 (giá trị hiệu lực được chốt)
   g_clIn[CL_SESS] = O12SessionPctEff(CloseProtect_UsePairACycleLossPct, CloseProtect_PairACycleMaxLossPct);
   g_clIn[CL_SET_MIN] = PairA_SettleMinUSD;                  g_clIn[CL_COST] = PairA_CloseCostPerLotUSD;    g_clIn[CL_SLIP] = PairA_SlipReservePoints;
   g_clIn[CL_PF_STRESS] = PairA_PfStressUSD;                 g_clIn[CL_PF_LOSS] = PairA_PfMaxStressLossPct; g_clIn[CL_PF_ML] = PairA_PfMinMarginLevelPct;
   g_clIn[CL_SHADOW] = PairA_ShadowOnly ? 1 : 0;
   g_clIn[CL_EXIT_MODE] = (int)Exit_Mode;                    g_clIn[CL_EXIT_TF] = (int)ExitTrend_TF;
   g_clIn[CL_EXIT_EF] = ExitTrend_EmaFast;                   g_clIn[CL_EXIT_ES] = ExitTrend_EmaSlow;      g_clIn[CL_EXIT_ATR] = ExitTrend_AtrPeriod;
   g_clIn[CL_EXIT_STRONG] = ExitTrend_StrongScore;           g_clIn[CL_EXIT_FSTART] = ExitHyb_FloorStartPips;   g_clIn[CL_EXIT_FKEEP] = ExitHyb_FloorKeepPct;
   g_clIn[CL_EXIT_MW] = ExitHyb_AtrMultWeak;                 g_clIn[CL_EXIT_MS] = ExitHyb_AtrMultStrong;
   g_clIn[CL_EXIT_TMIN] = ExitHyb_TrailMinPips;              g_clIn[CL_EXIT_TMAX] = ExitHyb_TrailMaxPips;
   g_clPcModeIn = (int)PairClose_Mode;   // [DPMR R1] D01
   // [GLOBAL GEN] G04: the elements of GlobalGrid_LocalDistancesPips the structure needs (OnInit refused a GLOBAL configuration whose list is invalid / too short)
   g_clLdInN = 0;
   if(gl)
   {
      double ld[]; int bad = 0;
      const int n = Gg38LdParse(GlobalGrid_LocalDistancesPips, ld, bad), req = Gg38LdRequired(GlobalGrid_OrdersPerGroup, Max_Orders);
      if(Gg38LdCheck(n, req) == GG38_LD_OK && req <= GG38_LD_MAX) { for(int i = 0; i < req; i++) g_clLdIn[i] = ld[i]; g_clLdInN = req; }
   }
}
// giá trị của chu kỳ đang mở (đã chốt) — chưa chốt (chưa có cụm) → Input hiện tại
double ClGet(const int i) { return g_clHave ? g_cl[i] : g_clIn[i]; }
string ClNs() { return OfhNs("OFH38K", Magic); }   // AUDIT P7-A 28/10/2026: không trùng namespace sổ cấp (OFH38L)
// first field whose latched value differs from the input (-1 = none)
int Cl38Diff(const double &a[], const double &b[], const int n)
{
   for(int i = 0; i < n; i++) if(MathAbs(a[i] - b[i]) > 1e-9 * MathMax(1.0, MathAbs(b[i]))) return i;
   return -1;
}

void ClWrite()
{
   const string ns = ClNs();
   GlobalVariablesDeleteAll(ns);
   GlobalVariableSet(ns + "cyc", (double)g_clCycle);
   GlobalVariableSet(ns + "nf", CL38_N);
   for(int i = 0; i < CL38_N; i++) GlobalVariableSet(ns + "f" + IntegerToString(i), g_cl[i]);
   GlobalVariableSet(ns + "ldv", 2); GlobalVariableSet(ns + "ldn", g_clLdN);   // [GLOBAL GEN] G04
   for(int i = 0; i < g_clLdN; i++) GlobalVariableSet(ns + "ld" + IntegerToString(i), g_clLd[i]);
   GlobalVariableSet(ns + "pcv", 1); GlobalVariableSet(ns + "pcm", g_clPcMode);   // [DPMR R1] D01: PairClose mode of the cycle
   OfhIdStore(ns, Magic);
   GlobalVariablesFlush();
}
void ClClearRecord() { if(GlobalVariablesDeleteAll(ClNs()) > 0) GlobalVariablesFlush(); }

// mỗi tick có cụm: chu kỳ mới → chốt Input hiện tại (một lần / chu kỳ)
void ClTick(const int total)
{
   if(total <= 0 || g_cycStartMsc <= 0 || (g_clHave && g_clCycle == g_cycStartMsc)) return;
   for(int i = 0; i < CL38_N; i++) g_cl[i] = g_clIn[i];
   ClLdLatchInputs();   // [GLOBAL GEN] G04
   g_clPcMode = g_clPcModeIn;   // [DPMR R1] D01: the PairClose mode of the new BasketCycleID
   g_clHave = true; g_clCycle = g_cycStartMsc; g_clFrozen = false; g_clFrozenWhy = ""; g_clLatched++;
   ClWrite();
   PrintFormat("PAIRCLOSE MODE | BasketCycleID %I64d latched: %s (until the basket is flat)", g_clCycle, PcModeName(g_clPcMode));   // [DPMR R1] D05 log
}
void ClOnCycleReset()
{
   g_clHave = false; g_clCycle = 0; g_clFrozen = false; g_clFrozenWhy = ""; g_clLdN = 0;
   if(CountPositions() <= 0) ClClearRecord();
}
// khởi động lại có cụm đang mở (sau CycRestore: g_cycStartMsc đã biết)
void ClRestore()
{
   g_clHave = false; g_clCycle = 0; g_clFrozen = false; g_clFrozenWhy = ""; g_clLdN = 0;
   const int n = CountPositions();
   const string ns = ClNs();
   if(n <= 0) { ClClearRecord(); return; }
   const long cyc = g_cycStartMsc > 0 ? g_cycStartMsc : CycStartMsc();
   // a record of an older build (other field layout) is not this cycle's configuration of this build
   const bool have = GlobalVariableCheck(ns + "cyc") && OfhIdCheck(ns, Magic) == "" && (long)GlobalVariableGet(ns + "cyc") == cyc && cyc > 0 &&
                     (int)GlobalVariableGet(ns + "nf") == CL38_N;
   if(!have)
   {
      // cụm của bản trước / bản ghi mất: không có bằng chứng cấu hình khác → chốt Input hiện tại cho chu kỳ này (cảnh báo)
      for(int i = 0; i < CL38_N; i++) g_cl[i] = g_clIn[i];
      ClLdLatchInputs();   // [GLOBAL GEN] G04
      g_clPcMode = g_clPcModeIn;   // [DPMR R1] D01 (an RPA trace of the cycle overrules it after RpaRestore: DpmrModeAfterRestore)
      g_clHave = true; g_clCycle = cyc; g_clLatched++;
      ClWrite();
      R2Warn("CLNOREC", StringFormat("CYCLE LATCH | open basket (%d positions, cycle %I64d) has no configuration record of this cycle (this build): the current inputs are latched now (basket of an older build / record lost)", n, cyc));
      return;
   }
   for(int i = 0; i < CL38_N; i++) g_cl[i] = GlobalVariableGet(ns + "f" + IntegerToString(i));
   g_clHave = true; g_clCycle = cyc;
   // [GLOBAL GEN] G04: the latched internal distance list. A record without the list layout ("ldv" 2) was written by an older build: for a GLOBAL cycle that build
   // used G1..G25 inside the groups -> the distance rule of the open cycle is not the rule of this build: new levels frozen until the next cycle (fail-closed)
   const bool ldRec = GlobalVariableCheck(ns + "ldv") && (int)GlobalVariableGet(ns + "ldv") == 2 && GlobalVariableCheck(ns + "ldn");
   const bool glLatched = g_cl[CL_GG_ON] > 0.5;
   bool ldBad = false;
   if(ldRec)
   {
      const int m = (int)GlobalVariableGet(ns + "ldn");
      if(m < 0 || m > GG38_LD_MAX) ldBad = true;
      else
      {
         for(int i = 0; i < m && !ldBad; i++)
         {
            if(!GlobalVariableCheck(ns + "ld" + IntegerToString(i))) { ldBad = true; break; }
            const double v = GlobalVariableGet(ns + "ld" + IntegerToString(i));
            if(!MathIsValidNumber(v) || v < 0.0) { ldBad = true; break; }   // a damaged element is never used (the GLOBAL cycle freezes below)
            g_clLd[i] = v;
         }
         g_clLdN = ldBad ? 0 : m;
      }
   }
   const bool legacyGl = !ldRec && glLatched;
   const bool badGl    = ldBad && glLatched;
   const bool ldDiff   = ldRec && !ldBad && Gg38LdDiffers(g_clLdIn, g_clLdInN, g_clLd, g_clLdN);
   // [DPMR R1] D01: the PairClose mode of the cycle; a record of an older build has no mode key = mode 1 (the only PairClose of those builds)
   const bool pcRec = GlobalVariableCheck(ns + "pcv") && (int)GlobalVariableGet(ns + "pcv") == 1 && GlobalVariableCheck(ns + "pcm");
   g_clPcMode = Dpmr38RestoredMode(pcRec, pcRec ? (int)GlobalVariableGet(ns + "pcm") : DPMR_PC_RPA);
   if(!pcRec) g_clPcOldRec++;
   const bool pcDiff = (g_clPcMode != g_clPcModeIn);
   if(Cl38Diff(g_clIn, g_cl, CL38_N) < 0 && !ldDiff && !legacyGl && !badGl && !pcDiff) return;
   g_clFrozen = true; g_clMismatch++;
   if(legacyGl) g_clLdLegacy++;
   string diff = "";
   for(int i = 0; i < CL38_N; i++) if(MathAbs(g_clIn[i] - g_cl[i]) > 1e-9 * MathMax(1.0, MathAbs(g_cl[i]))) diff += StringFormat(" %s %g->%g", Cl38FieldName(i), g_cl[i], g_clIn[i]);
   if(ldDiff)   diff += StringFormat(" GlobalGrid_LocalDistancesPips(effective) [%s]->[%s]", Gg38LdText(g_clLd, g_clLdN), Gg38LdText(g_clLdIn, g_clLdInN));
   if(legacyGl) diff += " GLOBAL_DISTANCE_RULE_OF_AN_OLDER_BUILD (the record has no internal distance list: that build placed the internal levels with G1..G25)";
   if(badGl)    diff += " GLOBAL_DISTANCE_LIST_RECORD_INCOMPLETE";
   if(pcDiff)   diff += StringFormat(" PairClose_Mode %d->%d%s (the cycle keeps PairClose mode %s)", g_clPcMode, g_clPcModeIn, pcRec ? "" : " (record of an older build: mode 1)", PcModeName(g_clPcMode));   // [DPMR R1] D01
   g_clFrozenWhy = "CONFIG_CHANGED_MIDCYCLE:" + diff;
   R2Warn("CLCHANGED_" + IntegerToString(cyc), StringFormat("CONFIG_CHANGED_MIDCYCLE | cycle %I64d (%d positions) was latched with other inputs:%s -> the cycle keeps its LATCHED configuration, NO new order (no grid level, no new rebase); a committed rebase and in-flight broker requests are reconciled; T1 / T2 / DD / session keep working; the new inputs apply from the next BasketCycleID",
                                                                 cyc, n, diff));
}
// [DPMR R1] D01: after RpaRestore - a cycle with an RPA trace (rebase / epoch / halted keep leg) ran PairClose mode 1: a mode-0 latch of it (lost / foreign record and a
// mode-0 input) is overruled, and a mode-0 input then freezes new levels of that cycle exactly like any other mid-cycle input change (B8)
void DpmrModeAfterRestore(const bool rpaTrace)
{
   if(!g_clHave) return;
   const int m = Dpmr38ModeAfterRpaEvidence(g_clPcMode, rpaTrace);
   if(m == g_clPcMode) return;
   g_clPcRpaEvidence++;
   R2Warn("PCMODERPA_" + IntegerToString(g_clCycle), StringFormat("PAIRCLOSE MODE | restart: cycle %I64d was latched %s but its RPA record shows a rebase / epoch -> the cycle keeps PairClose mode %s", g_clCycle, PcModeName(g_clPcMode), PcModeName(m)));
   g_clPcMode = m;
   ClWrite();
   if(g_clPcModeIn != m && !g_clFrozen)
   {
      g_clFrozen = true; g_clMismatch++;
      g_clFrozenWhy = StringFormat("CONFIG_CHANGED_MIDCYCLE: PairClose_Mode %d->%d (the cycle keeps PairClose mode %s: RPA trace)", m, g_clPcModeIn, PcModeName(m));
   }
}
void ClFrozenTick()
{
   g_clFrozenTicks++;
   static long s_log = 0;
   if(s_log == g_cycStartMsc) return;
   s_log = g_cycStartMsc;
   PrintFormat("GRID FROZEN | %s - no further level for this basket (exits / T1 / T2 / DD / session keep working)", g_clFrozenWhy);
}
string ClText()
{
   string s = ""; for(int i = 0; i < CL38_N; i++) s += StringFormat("%s%g", i > 0 ? "," : "", ClGet(i));
   if(ClLdCount() > 0) s += ",LD[" + (g_clHave ? Gg38LdText(g_clLd, g_clLdN) : Gg38LdText(g_clLdIn, g_clLdInN)) + "]";   // [GLOBAL GEN] G04 (V26: no list, text unchanged)
   return s;
}
void ClPrintCounters(const string when)
{
   PrintFormat("CYCLE LATCH COUNTERS %s | cycles latched %I64d | mid-cycle input changes detected %I64d | frozen grid ticks %I64d | now %s", when, g_clLatched, g_clMismatch, g_clFrozenTicks,
               g_clFrozen ? g_clFrozenWhy : (g_clHave ? "latched" : "no cycle"));
}

#endif
// [FINAL STANDALONE] ===== END INLINED OFH38_CycleLatch.mqh =====
// [FINAL STANDALONE] ===== BEGIN INLINED OFH38_GridLot.mqh (HOTFIX SHA256 FF12DC5BDC3384632A83140C02618981F6A8A74B3921E643C3E7D6E6D1584CA4) — included from Onefxhub_v38.38_RPA.mq5:L313 =====
// OFH38_GridLot.mqh — V38 PAIRA_LOOP: kiểm lot / margin trước khi gửi lệnh Grid (phần EA). Phép tính: OFH38_GridLot_Core.mqh.
// Thay OFH38_LotMode.mqh của PAIRA_M2: GLOBAL Grid lot Mode 2 ĐÃ GỠ (Owner 24/10/2026, B1 / D1) — lot của cấp n = lot ladder cấp n như V26 / R3 FINAL.
// Bản ghi chế độ lot theo chu kỳ của PAIRA_M2 được thay bằng bản ghi cấu hình chu kỳ (OFH38_CycleLatch.mqh, Owner B8).
// GridLot_StrictBrokerLimits = true (Owner: không âm thầm thay lot): lot ladder > SYMBOL_VOLUME_MAX → LOT_LADDER_CAP_BLOCKER (không gửi, không kẹp),
// < VOLUME_MIN → LOT_BELOW_MIN_BLOCKER, vượt VOLUME_LIMIT một chiều → VOLUME_LIMIT_BLOCKER; OrderCheck báo thiếu margin (NO_MONEY) → MARGIN_INSUFFICIENT
// (không gửi lệnh chắc chắn bị từ chối mỗi tick). Mỗi loại log một lần / cấp / chu kỳ. false = CalcLot của R3 FINAL (kẹp min / max im lặng).
#ifndef OFH38_GRIDLOT_MQH
#define OFH38_GRIDLOT_MQH

// [FINAL STANDALONE] ===== BEGIN INLINED OFH38_GridLot_Core.mqh (HOTFIX SHA256 0C2128C6D8433E9B59CA5B06F2A4CB6B022CC50DDEE531F2FE5E8990DB5966E2) — included from OFH38_GridLot.mqh:L10 =====
// OFH38_GridLot_Core.mqh — V38 PAIRA_LOOP: lot ladder + kiểm lot trước khi gửi lệnh Grid (phép tính thuần, không gọi lệnh, không dùng biến EA). Unit-test được.
// Quyết định Owner 24/10/2026 (ONEFXHUB_V38_PAIRA_FULL_OWNER_UPDATE_20261024, B1 / D1): GLOBAL Grid lot Mode 2 bị GỠ khỏi nhánh phát triển (không còn Input,
// enum hay đường mã mở lệnh theo LotLadderIndex; bản PAIRA_M2 đóng băng giữ làm đối chứng). Lot của cấp n luôn = lot ladder cấp n (= CalcLot(n − 1) của V26).
// Chỉ giữ phần kiểm broker của PAIRA_M2 (GridLot_StrictBrokerLimits): không kẹp lot im lặng; không đổi parity khi giới hạn không chạm.
#ifndef OFH38_GRIDLOT_CORE_MQH
#define OFH38_GRIDLOT_CORE_MQH

// lot lý thuyết của cấp idx (1-based) theo lot ladder gốc, làm tròn LÊN theo bước (cùng quy tắc CalcLot), CHƯA kẹp min / max broker
double Gl38LadderLot(const double initLot, const double multi, const int idx, const double step)
{
   double lot = initLot * MathPow(multi, idx - 1);
   const double st = step > 0.0 ? step : 0.01;
   lot = MathCeil(lot / st) * st;
   return NormalizeDouble(lot, 2);
}

// kết quả kiểm lot trước khi gửi: 0 = gửi được, 1 = lớn hơn VOLUME_MAX (LOT_LADDER_CAP_BLOCKER), 2 = nhỏ hơn VOLUME_MIN, 3 = vượt VOLUME_LIMIT một chiều
#define GL38_LOT_OK        0
#define GL38_LOT_ABOVE_MAX 1
#define GL38_LOT_BELOW_MIN 2
#define GL38_LOT_LIMIT     3
int Gl38LotCheck(const double lot, const double minL, const double maxL, const double limit, const double sideOpen)
{
   const double eps = 1e-9;
   if(maxL > 0.0 && lot > maxL + eps) return GL38_LOT_ABOVE_MAX;
   if(minL > 0.0 && lot < minL - eps) return GL38_LOT_BELOW_MIN;
   if(limit > 0.0 && sideOpen + lot > limit + eps) return GL38_LOT_LIMIT;
   return GL38_LOT_OK;
}
string Gl38LotCheckName(const int c)
{
   switch(c)
   {
      case GL38_LOT_OK:        return "OK";
      case GL38_LOT_ABOVE_MAX: return "LOT_LADDER_CAP_BLOCKER";
      case GL38_LOT_BELOW_MIN: return "LOT_BELOW_MIN_BLOCKER";
      case GL38_LOT_LIMIT:     return "VOLUME_LIMIT_BLOCKER";
   }
   return "UNKNOWN";
}

#endif
// [FINAL STANDALONE] ===== END INLINED OFH38_GridLot_Core.mqh =====

string g_glLogKeys = "";
long   g_glCapBlocks = 0, g_glMinBlocks = 0, g_glLimitBlocks = 0, g_glMarginBlocks = 0;

void GlLogOnce(const string key, const string text)
{
   const string k = "|" + key + "|";
   if(StringFind(g_glLogKeys, k) >= 0) return;
   g_glLogKeys += k; if(StringLen(g_glLogKeys) > 4000) g_glLogKeys = k;
   R2Warn(key, text);
}

// lot của cấp n = CalcLot(n − 1) (V26 / R3 FINAL)
double GlGridLot(const int level) { return CalcLot(level - 1); }

// lot ladder đúng (chưa kẹp) + kiểm broker / margin. false = KHÔNG gửi cấp này ở tick này (lý do log một lần / cấp / chu kỳ).
bool GlGridSendable(const int level, const double lot, const bool isBuy)
{
   if(!GridLot_StrictBrokerLimits) return true;
   const double step = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP), minL = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN), maxL = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   const double limit = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_LIMIT);
   const double ladder = Gl38LadderLot(Initial_Lot, Lot_Multi, level, step);
   double vB = 0.0, vS = 0.0, sB = 0.0, sS = 0.0; BasketVolumeSums(vB, vS, sB, sS);
   const int c = Gl38LotCheck(ladder, minL, maxL, limit, isBuy ? vB : vS);
   const string cyc = IntegerToString(g_cycStartMsc);
   if(c != GL38_LOT_OK)
   {
      if(c == GL38_LOT_ABOVE_MAX) g_glCapBlocks++; else if(c == GL38_LOT_BELOW_MIN) g_glMinBlocks++; else g_glLimitBlocks++;
      GlLogOnce(StringFormat("GLCAP_%s_%d", cyc, level),
                StringFormat("%s | L%d needs %.2f lots = %.4g x %.2f^%d rounded up to step %.2f | broker min %.2f max %.2f limit %.2f, %s side open %.2f -> NOT SENT (no silent lot change; this basket cannot take its ladder lot at this level)",
                             Gl38LotCheckName(c), level, ladder, Initial_Lot, Lot_Multi, level - 1, step, minL, maxL, limit, isBuy ? "BUY" : "SELL", isBuy ? vB : vS));
      return false;
   }
   MqlTradeRequest q; MqlTradeCheckResult r; ZeroMemory(q); ZeroMemory(r);
   q.action = TRADE_ACTION_DEAL; q.symbol = _Symbol; q.volume = lot; q.type = isBuy ? ORDER_TYPE_BUY : ORDER_TYPE_SELL;
   q.price = isBuy ? SymbolInfoDouble(_Symbol, SYMBOL_ASK) : SymbolInfoDouble(_Symbol, SYMBOL_BID); q.magic = Magic;
   const long fm = SymbolInfoInteger(_Symbol, SYMBOL_FILLING_MODE);
   q.type_filling = ((fm & SYMBOL_FILLING_FOK) != 0) ? ORDER_FILLING_FOK : (((fm & SYMBOL_FILLING_IOC) != 0) ? ORDER_FILLING_IOC : ORDER_FILLING_RETURN); q.deviation = 10;
   if(!OrderCheck(q, r) && r.retcode == TRADE_RETCODE_NO_MONEY)
   {
      g_glMarginBlocks++;
      GlLogOnce(StringFormat("GLMARGIN_%s_%d", cyc, level),
                StringFormat("MARGIN_INSUFFICIENT | L%d %s %.2f lots: broker check NO_MONEY, margin needed %.2f, free margin after %.2f, equity %.2f -> NOT SENT (no order that the broker must reject; checked again every tick)",
                             level, isBuy ? "BUY" : "SELL", lot, r.margin, r.margin_free, AccountInfoDouble(ACCOUNT_EQUITY)));
      return false;
   }
   return true;
}
// RPA subgrid (Owner 31/10/2026 §3): the ACTUAL subgrid lot (TargetLot x 1.20^j, not the original ladder) against the broker limits + margin; "" = sendable,
// otherwise the BLOCKED reason (no silent clamp: the caller does not send and journals the reason)
string GlSubLotBlocked(const double lot, const bool isBuy)
{
   const double minL = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN), limit = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_LIMIT);
   double maxL = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   double vB = 0.0, vS = 0.0, sB = 0.0, sS = 0.0; BasketVolumeSums(vB, vS, sB, sS);
   const int c = Gl38LotCheck(lot, minL, maxL, limit, isBuy ? vB : vS);
   if(c != GL38_LOT_OK)
   {
      if(c == GL38_LOT_ABOVE_MAX) g_glCapBlocks++; else if(c == GL38_LOT_BELOW_MIN) g_glMinBlocks++; else g_glLimitBlocks++;
      return StringFormat("%s (broker min %.2f max %.2f limit %.2f, %s side open %.2f)", Gl38LotCheckName(c), minL, maxL, limit, isBuy ? "BUY" : "SELL", isBuy ? vB : vS);
   }
   MqlTradeRequest q; MqlTradeCheckResult r; ZeroMemory(q); ZeroMemory(r);
   q.action = TRADE_ACTION_DEAL; q.symbol = _Symbol; q.volume = lot; q.type = isBuy ? ORDER_TYPE_BUY : ORDER_TYPE_SELL;
   q.price = isBuy ? SymbolInfoDouble(_Symbol, SYMBOL_ASK) : SymbolInfoDouble(_Symbol, SYMBOL_BID); q.magic = Magic;
   const long fm = SymbolInfoInteger(_Symbol, SYMBOL_FILLING_MODE);
   q.type_filling = ((fm & SYMBOL_FILLING_FOK) != 0) ? ORDER_FILLING_FOK : (((fm & SYMBOL_FILLING_IOC) != 0) ? ORDER_FILLING_IOC : ORDER_FILLING_RETURN); q.deviation = 10;
   if(!OrderCheck(q, r) && r.retcode == TRADE_RETCODE_NO_MONEY)
   {
      g_glMarginBlocks++;
      return StringFormat("MARGIN_INSUFFICIENT (broker check NO_MONEY: margin needed %.2f, free margin after %.2f, equity %.2f)", r.margin, r.margin_free, AccountInfoDouble(ACCOUNT_EQUITY));
   }
   return "";
}

void GlPrintCounters(const string when)
{
   PrintFormat("GRIDLOT COUNTERS %s | strict broker limits %s | blocked: above VOLUME_MAX %I64d below min %I64d volume limit %I64d margin %I64d",
               when, GridLot_StrictBrokerLimits ? "ON" : "OFF", g_glCapBlocks, g_glMinBlocks, g_glLimitBlocks, g_glMarginBlocks);
}

#endif
// [FINAL STANDALONE] ===== END INLINED OFH38_GridLot.mqh =====
// [FINAL STANDALONE] ===== BEGIN INLINED OFH38_Rpa.mqh (HOTFIX SHA256 6305C5905F94E57956AF8F99B3F5542C93E2F10BABE658FF4F4A690E07BC3703) — included from Onefxhub_v38.38_RPA.mq5:L314 =====
// OFH38_Rpa.mqh — ONEFXHUB V38.38 RECURSIVE PAIR_A REBASE V1 (Owner 31/10/2026, 00_owner_prompt/): the ONLY PairClose controller of this branch.
//   RECURSIVE PAIR_A -> Lk* -> SUBGRID -> RECURSIVE PAIR_A inside one BasketCycleID; FLAT -> next BasketCycleID from the original L1 (V26 / GLOBAL Mode 1).
// Pure math: OFH38_Rpa_Core.mqh. States (per BasketCycleID, persisted at every change, namespace OFH38R):
//   ORIGINAL  epoch 0 = the original grid of the selected strategy (V26 / GLOBAL Mode 1), untouched. PairClose is considered once the highest original level
//             ever opened >= OriginalPairCloseStartOrder (latched with the cycle).
//   REBASING  a rebase plan is committed: the executor owns the basket (no grid, no L1, T1 / T2 / session / new DD wait for the broker evidence) until the
//             broker shows EXACTLY one position = the TargetSide Pair_A leg reduced to TargetLot. Every next close is recomputed from the LIVE broker positions
//             (a late fill / restart never replays a stale list); one request at a time; a request without a broker result is never resent
//             (UNKNOWN_HOLD, reconcile only; "not executed" only with broker evidence after RPA_UNKNOWN_RESOLVE_SEC).
//   SUBGRID   epoch e >= 1: base Lk* (TargetLot, TargetSide) + additional orders L(k+1)*.. of the selected strategy from the VirtualEntryAnchor (= economic BE of the
//             whole BasketCycleID at the rebase, recomputed from the broker after the execution), lot TargetLot x 1.20^j. PairClose of the epoch only after
//             12 additional orders FILLED (broker-confirmed position ids, never the open ticket count); at most GridMaxOrders additional orders.
//   HALTED    fail-closed (lost keep leg, deficit, reconciliation mismatch, repeated rejection, manual close in an RPA epoch, journal lost, ...): no rebase,
//             no grid level; T1 / T2 / session / DD / manual recovery / reconciliation keep working. HOTFIX (Owner 02/11/2026): this includes the one-side T1 / T2 of
//             the lone Lk* when the record and the broker are reconciled (RpaT1OneSideHalted); a lost record / unresolved request / conflict -> no lock, reason journalled.
// F23 (TPC4, inherited TPC3 BO ledger): the rebase ledger is RECOMPUTED from the broker deal history (positions of the cycle, deals since the commit) at every
// reconciliation, never collected incrementally from in-memory events -> a late fill across a restart is counted once, never refused, never lost.
// RPA V1-R1 (Owner 01/11/2026): TRUE L1 SUBGRID RESET. Lk* is L1 of a new grid: every trading rule of an epoch uses the LOCAL level n (Lk* = 1, additional j = j + 1):
//   trigger VirtualEntryAnchor +/- G(n - 1) (local L2 = G1), side odd = TargetSide, double confirmation n >= ConfirmFromOrder (identity epoch x 1000 + n), GLOBAL group of n.
//   DisplayVirtualLevel k + n - 1 = label only (journal, comments "RPA|S|e|n<local>|L<display>"). VirtualEntryAnchor = DecisionMarketAnchor: the Bid / Ask of the commit tick
//   (V26 L1 price rule: BUY Ask, SELL Bid), persisted with the whole decision snapshot BEFORE the first close request; REBASE_COMPLETE takes the persisted value or HALTs
//   (DECISION_SNAPSHOT_MISSING / MISMATCH) — never the mathematical BE, never the retained ticket's open price, never a later quote. The post-execution economic BE is
//   computed separately (accounting / journal only).
// RPA V1-R2 (Owner 01/11/2026, D1 / D5): RpaT1OneSide() = the only case where the shared T1 / T2 of the EA may hold ONE side (the lone Lk* of a reconciled epoch);
//   EPOCH_TRANSITION (one row per reconciled epoch, written once at REBASE_COMPLETE) carries the missing anchor-drift fields (completion tick Bid / Ask, signed / absolute
//   deviation in price and money, rebase elapsed ms, local L2 trigger status) — no new logger, no per-tick row; T1 / T2 events of a rebased cycle are journalled once each.
#ifndef OFH38_RPA_MQH
#define OFH38_RPA_MQH

// [FINAL STANDALONE] ===== BEGIN INLINED OFH38_Rpa_Core.mqh (HOTFIX SHA256 B4A62C8E330B655BC92F2AC4B7A3B424D5F6137736B1A24162725B0FAC4BC3D3) — included from OFH38_Rpa.mqh:L30 =====
// OFH38_Rpa_Core.mqh — ONEFXHUB V38.38 RECURSIVE PAIR_A REBASE V1 (Owner 31/10/2026, 00_owner_prompt/): PURE functions (no order, no EA global) — unit tested in
// tests/OFH38_RPA_UnitTests.mq5. The EA part (state machine, execution, reconciliation, persistence) is OFH38_Rpa.mqh.
//   §2 TargetLot  = |SUM BUY lots - SUM SELL lots| of the ORIGINAL ladder L1..Lk of the cycle (lot of level n = the EA lot engine CalcLot(n - 1): Initial_Lot x Lot_Multi^(n-1)
//                   rounded UP to the volume step, clamped to the broker min / max), sides alternate from the L1 side. Never the lot of Lk alone, never 50 % of the live net.
//   §3 SubGridLot(j) = round_to_step(TargetLot x 1.20^j), j = 0 the base Lk*, j = 1.. the additional orders (SUBGRID_MULTILOT is a code constant, not an input).
//   §4 PairClose of a subgrid epoch is considered only after SUBGRID_PAIRCLOSE_AFTER_ADDITIONAL_ORDERS = 12 additional orders FILLED (code constant, no input; +10 does not exist).
//   §5 additional orders of a subgrid epoch <= GridMaxOrders (= Max_Orders of the original grid; the base Lk* is not counted).
//   §6 Pair_A = largest BUY + largest SELL of the live grid positions of the epoch; plan = keep the Pair_A leg on TargetSide reduced to TargetLot, close everything else.
// RPA V1-R1 (Owner 01/11/2026, 00_owner_prompt/RPA_V1_R1_OWNER_MASTER_DIRECTIVE.md) — TRUE L1 SUBGRID RESET:
//   k (RecursiveRebaseTargetLevel) is ONLY the lot template (TargetLot / TargetSide) and the audit label Lk*. In trading terms Lk* is L1 of a NEW grid:
//   LocalGridLevel n = 1, 2, 3, ... (Lk* = local 1, additional order j = local j + 1); DisplayVirtualLevel = k + n - 1 is a label (journal / mapping / comments) only.
//   Every trading rule of a subgrid epoch uses the LOCAL level: grid step G(n - 1) (local L2 = G1, L3 = G2, ...), side (odd = TargetSide), double confirmation
//   (n >= ConfirmFromOrder), GLOBAL group (group 0 = local 1..K), lot TargetLot x 1.20^(n - 1), max local level 1 + GridMaxOrders, PairClose after 12 additional fills.
//   VirtualEntryAnchor = DecisionMarketAnchor = the market quote of the decision (commit) tick on the V26 L1 price rule (BUY = Ask, SELL = Bid), persisted before the
//   first close request; never the mathematical BE, never the open price of the retained ticket, never a quote of a later tick.
// RPA V1-R2 (Owner 01/11/2026): Rpa38T1OneSideAllowed — when the shared T1 / T2 may hold the lone Lk* (one side).
#ifndef OFH38_RPA_CORE_MQH
#define OFH38_RPA_CORE_MQH

#define SUBGRID_MULTILOT                          1.20
#define SUBGRID_PAIRCLOSE_AFTER_ADDITIONAL_ORDERS 12

// subgrid epoch: eligibility of the PairClose (BE evaluation) and of a new additional order (fixtures §12)
#define RPA_EL_NOT_ELIGIBLE 0   // additional < 12
#define RPA_EL_ELIGIBLE     1   // additional == 12  -> ELIGIBLE_FOR_BE_EVALUATION
#define RPA_EL_STILL        2   // 12 < additional < max -> STILL_ELIGIBLE
#define RPA_EL_MAX_REACHED  3   // additional == max (no further order; BE evaluation if additional >= 12)
#define RPA_EL_FORBIDDEN    4   // additional > max (must never happen: the EA halts)

string Rpa38ElName(const int c)
{
   switch(c)
   {
      case RPA_EL_NOT_ELIGIBLE: return "NOT_ELIGIBLE";
      case RPA_EL_ELIGIBLE:     return "ELIGIBLE_FOR_BE_EVALUATION";
      case RPA_EL_STILL:        return "STILL_ELIGIBLE";
      case RPA_EL_MAX_REACHED:  return "MAX_REACHED";
      case RPA_EL_FORBIDDEN:    return "FORBIDDEN";
   }
   return "?";
}
int Rpa38SubState(const int additional, const int maxAdditional)
{
   if(additional > maxAdditional) return RPA_EL_FORBIDDEN;
   if(additional == maxAdditional) return RPA_EL_MAX_REACHED;
   if(additional < SUBGRID_PAIRCLOSE_AFTER_ADDITIONAL_ORDERS) return RPA_EL_NOT_ELIGIBLE;
   if(additional == SUBGRID_PAIRCLOSE_AFTER_ADDITIONAL_ORDERS) return RPA_EL_ELIGIBLE;
   return RPA_EL_STILL;
}
// the PairClose of the epoch may be evaluated (BE100 + gates still required)
bool Rpa38SubBeEligible(const int additional, const int maxAdditional) { return additional >= SUBGRID_PAIRCLOSE_AFTER_ADDITIONAL_ORDERS && additional <= maxAdditional; }
// one more additional order may be opened (never because the PairClose became eligible: only the grid trigger opens a level)
bool Rpa38SubMayOpen(const int additional, const int maxAdditional) { return additional >= 0 && additional < maxAdditional; }
// original grid (epoch 0): the PairClose may be evaluated once the highest level ever opened reaches OriginalPairCloseStartOrder
bool Rpa38OrigEligible(const int levels, const int startOrder) { return levels >= startOrder; }

// ---------------------------------------------------------------- lots
// lot of ORIGINAL level n (1-based) with the EA lot engine: exactly CalcLot(n - 1) of the EA (ceil to the step, NormalizeDouble 2, clamp min / max)
double Rpa38EngineLot(const double initLot, const double multi, const int n, const double step, const double minL, const double maxL)
{
   double lot = initLot * MathPow(multi, n - 1);
   const double st = step > 0.0 ? step : 0.01;
   lot = MathCeil(lot / st) * st;
   lot = NormalizeDouble(lot, 2);
   if(maxL > 0.0) lot = MathMin(maxL, lot);
   if(minL > 0.0) lot = MathMax(minL, lot);
   return lot;
}
double Rpa38RoundStep(const double v, const double step) { const double st = step > 0.0 ? step : 0.01; return NormalizeDouble(MathRound(v / st) * st, 2); }

#define RPA_TPL_OK            0
#define RPA_TPL_NET_ZERO      1   // BASE BUY == BASE SELL -> no TargetSide: BLOCKED
#define RPA_TPL_BELOW_MIN     2   // TargetLot < SYMBOL_VOLUME_MIN: BLOCKED
#define RPA_TPL_ABOVE_MAX     3   // TargetLot > SYMBOL_VOLUME_MAX: BLOCKED
#define RPA_TPL_BAD_LEVEL     4   // k < 1
string Rpa38TplName(const int c)
{
   switch(c)
   {
      case RPA_TPL_OK: return "OK";
      case RPA_TPL_NET_ZERO: return "TARGET_NET_ZERO_BLOCKED";
      case RPA_TPL_BELOW_MIN: return "TARGET_BELOW_VOLUME_MIN_BLOCKED";
      case RPA_TPL_ABOVE_MAX: return "TARGET_ABOVE_VOLUME_MAX_BLOCKED";
      case RPA_TPL_BAD_LEVEL: return "TARGET_LEVEL_INVALID";
   }
   return "?";
}
// §2: template of the cycle. l1Buy = side of the original L1 (odd levels on the L1 side). side: +1 BUY, -1 SELL, 0 none.
int Rpa38Template(const double initLot, const double multi, const int k, const bool l1Buy, const double step, const double minL, const double maxL,
                  double &baseBuy, double &baseSell, double &target, int &side)
{
   baseBuy = 0.0; baseSell = 0.0; target = 0.0; side = 0;
   if(k < 1) return RPA_TPL_BAD_LEVEL;
   for(int n = 1; n <= k; n++)
   {
      const double lot = Rpa38EngineLot(initLot, multi, n, step, minL, maxL);
      const bool isBuy = (n % 2 == 1) ? l1Buy : !l1Buy;
      if(isBuy) baseBuy += lot; else baseSell += lot;
   }
   baseBuy = NormalizeDouble(baseBuy, 2); baseSell = NormalizeDouble(baseSell, 2);
   const double st = step > 0.0 ? step : 0.01, net = baseBuy - baseSell;
   target = Rpa38RoundStep(MathAbs(net), st);
   side = (net > st * 0.5) ? 1 : (net < -st * 0.5 ? -1 : 0);
   if(side == 0) { target = 0.0; return RPA_TPL_NET_ZERO; }
   if(minL > 0.0 && target < minL - 1e-9) return RPA_TPL_BELOW_MIN;
   if(maxL > 0.0 && target > maxL + 1e-9) return RPA_TPL_ABOVE_MAX;
   return RPA_TPL_OK;
}
// §3: lot of subgrid order j (j = 0 = the base Lk*), rounded to the NEAREST volume step (raw value kept by the caller for the rounding report)
//     R1 §6.2: local level n has j = n - 1 -> NormalizeVolume(TargetLot x 1.20^(n - 1)); never the display level, never the parent Lot_Multi
double Rpa38SubRaw(const double target, const int j) { return target * MathPow(SUBGRID_MULTILOT, j); }
double Rpa38SubLot(const double target, const int j, const double step) { return Rpa38RoundStep(Rpa38SubRaw(target, j), step); }

// ---------------------------------------------------------------- R1 §1.2: three independent level variables
// TargetTemplateLevel k | LocalGridLevel n (1 = Lk*, the base) | DisplayVirtualLevel k + n - 1 (label only)
int  Rpa38LocalOfJ(const int j) { return j + 1; }                                      // additional order j -> local level
int  Rpa38JOfLocal(const int n) { return n - 1; }
int  Rpa38DisplayLevel(const int k, const int n) { return k + n - 1; }                 // L15* = local 1, L16* = local 2, L33* = local 19 (k 15)
// side of local level n: odd = TargetSide (local 1 = Lk*), even = opposite (the V26 GetNextType rule of a grid whose L1 is on TargetSide)
int  Rpa38LocalSide(const int n, const int targetSide) { return (n % 2 == 1) ? targetSide : -targetSide; }
// grid step index of local level n: the parent GetStep(n) rule = G(n - 1), G25 for every level above L26 (local 1 = the anchor, no step)
int  Rpa38StepIndex(const int n) { if(n <= 1) return 0; return MathMin(n - 1, 25); }
// R1 §4: double confirmation of local level n (never the display level)
bool Rpa38ConfirmRequired(const bool enable, const int n, const int confirmFrom) { return enable && n >= confirmFrom; }
// identity of the grid double confirmation of local level n in subgrid epoch e (>= 1): a confirmation of one epoch never carries into another epoch,
// never collides with an original-grid level (epoch 0 keeps the level itself, 1..Max_Orders)
int  Rpa38DcId(const int epoch, const int n) { return epoch >= 1 ? epoch * 1000 + n : n; }
int  Rpa38DcLocal(const int id) { return id >= 1000 ? id % 1000 : id; }
int  Rpa38DcEpoch(const int id) { return id >= 1000 ? id / 1000 : 0; }
// V26 trigger of a grid level from its first price: BUY above (first + step), SELL below (first - step) — GetTrigger of V26 with the anchor as FirstPrice
double Rpa38LocalTrigger(const double anchor, const bool isBuy, const double stepPrice) { return isBuy ? anchor + stepPrice : anchor - stepPrice; }


// ---------------------------------------------------------------- R1 §2: BE-tick anchor
// L1 price rule of V26 on the decision snapshot: a BUY first price is quoted at Ask, a SELL first price at Bid (FirstPrice = the market fill price)
double Rpa38DecisionAnchor(const int side, const double bid, const double ask) { return side > 0 ? ask : (side < 0 ? bid : 0.0); }
#define RPA_ANC_OK            0
#define RPA_ANC_NO_SNAPSHOT   1   // no persisted decision snapshot (or invalid quote) -> fail-closed, never guessed from the current price
#define RPA_ANC_MISMATCH      2   // the snapshot does not belong to this commit (cycle / epoch / commit tick / side / target differ) -> fail-closed
string Rpa38AncName(const int c) { return c == RPA_ANC_OK ? "OK" : (c == RPA_ANC_NO_SNAPSHOT ? "DECISION_SNAPSHOT_MISSING" : (c == RPA_ANC_MISMATCH ? "DECISION_SNAPSHOT_MISMATCH" : "?")); }
// VirtualEntryAnchor of the new epoch = DecisionMarketAnchor of the committed rebase. decisionBe / postBe / keepOpen are accounting values reported beside it and are
// NEVER returned (Owner T5: anchor 4000.00 with decision BE 3998.00, post-execution BE 3986.00, retained ticket open 4008.00 -> 4000.00).
double Rpa38EpochAnchor(const bool snapPresent, const double decAnchor, const double decBid, const double decAsk, const long decMsc, const long commitMsc,
                        const long decCyc, const long cyc, const int decEpoch, const int epoch, const int decSide, const int side, const double decTarget, const double target,
                        const double decisionBe, const double postBe, const double keepOpen, int &code)
{
   code = RPA_ANC_OK;
   if(!snapPresent || decAnchor <= 0.0 || decBid <= 0.0 || decAsk <= 0.0 || decAsk < decBid || decMsc <= 0) { code = RPA_ANC_NO_SNAPSHOT; return 0.0; }
   if(decMsc != commitMsc || decCyc != cyc || decEpoch != epoch || decSide != side || MathAbs(decTarget - target) > 1e-6 ||
      MathAbs(decAnchor - Rpa38DecisionAnchor(decSide, decBid, decAsk)) > 1e-6) { code = RPA_ANC_MISMATCH; return 0.0; }
   return decAnchor;
}

// ---------------------------------------------------------------- Pair_A and the rebase plan
// largest BUY / largest SELL by lot (tie: the larger position id = opened later = the higher level, LPGD rule); -1 = no position on that side
void Rpa38PairA(const int n, const double &vol[], const int &side[], const ulong &id[], int &iBuy, int &iSell)
{
   iBuy = -1; iSell = -1;
   for(int i = 0; i < n; i++)
   {
      if(side[i] > 0) { if(iBuy < 0 || vol[i] > vol[iBuy] + 1e-9 || (MathAbs(vol[i] - vol[iBuy]) <= 1e-9 && id[i] > id[iBuy])) iBuy = i; }
      else if(side[i] < 0) { if(iSell < 0 || vol[i] > vol[iSell] + 1e-9 || (MathAbs(vol[i] - vol[iSell]) <= 1e-9 && id[i] > id[iSell])) iSell = i; }
   }
}

#define RPA_PLAN_OK              0
#define RPA_PLAN_NO_TARGET_LEG   1   // NO_FEASIBLE_REBASE: Pair_A has no leg on TargetSide
#define RPA_PLAN_LEG_TOO_SMALL   2   // NO_FEASIBLE_REBASE: the TargetSide Pair_A leg is smaller than TargetLot
#define RPA_PLAN_EMPTY           3
#define RPA_PLAN_ALREADY         4   // one position on TargetSide already equal to TargetLot (nothing to do)
string Rpa38PlanName(const int c)
{
   switch(c)
   {
      case RPA_PLAN_OK: return "OK";
      case RPA_PLAN_NO_TARGET_LEG: return "NO_FEASIBLE_REBASE:NO_PAIR_A_LEG_ON_TARGET_SIDE";
      case RPA_PLAN_LEG_TOO_SMALL: return "NO_FEASIBLE_REBASE:PAIR_A_LEG_SMALLER_THAN_TARGET";
      case RPA_PLAN_EMPTY: return "EMPTY_BASKET";
      case RPA_PLAN_ALREADY: return "ALREADY_SINGLE_TARGET";
   }
   return "?";
}
// next close of a rebase from the CURRENT positions (recomputed at every step from the broker, so a late fill / restart never replays a stale list):
// item = index of a position to close in full, or `keep` with closeVol = keep excess (partial close). Order rule (§6.5 "chênh lệch net tạm thời"):
// the LARGEST item whose close keeps the running |net| (BUY - SELL) <= band (band = max(|net at the commit|, TargetLot): the exposure never grows above the larger of
// the start / end exposure), so the big opposite legs cancel each other early; when no item keeps the band, the item with the smallest |net| after it (least
// excursion; tie: smaller item). Returns the item index (-1 = nothing left), closeVol = volume of that close.
int Rpa38NextClose(const int n, const double &vol[], const int &side[], const int keep, const double target, const int tSide, const double step, const double band, double &closeVol)
{
   closeVol = 0.0;
   const double eps = (step > 0.0 ? step : 0.01) * 0.5;
   double N = 0.0;
   for(int i = 0; i < n; i++) N += side[i] * vol[i];
   const double excess = (keep >= 0) ? vol[keep] - target : 0.0;
   int best = -1; double bestV = 0.0, bestAbs = 0.0; bool bestIn = false;
   for(int i = 0; i < n; i++)
   {
      const double v = (i == keep) ? excess : vol[i];
      if(v <= eps) continue;
      const double na = MathAbs(N - side[i] * v);
      const bool in = na <= band + eps;
      bool take = false;
      if(best < 0) take = true;
      else if(in && !bestIn) take = true;
      else if(in && bestIn) take = v > bestV + 1e-9 || (MathAbs(v - bestV) <= 1e-9 && na < bestAbs - 1e-9);   // largest inside the band
      else if(!in && !bestIn) take = na < bestAbs - 1e-9 || (MathAbs(na - bestAbs) <= 1e-9 && v < bestV - 1e-9);   // least excursion
      if(take) { best = i; bestV = v; bestAbs = na; bestIn = in; }
   }
   if(best >= 0) closeVol = NormalizeDouble(bestV, 2);
   return best;
}
// §6 plan + preflight path: keep leg, every close in order, max |net| along the path. A copy of the volumes is consumed by Rpa38NextClose step by step.
int Rpa38Plan(const int n, const double &vol[], const int &side[], const ulong &id[], const double target, const int tSide, const double step,
              int &keep, int &ord[], double &cvol[], int &steps, double &maxAbsNet, double &netStart, double &netEnd)
{
   keep = -1; steps = 0; maxAbsNet = 0.0; netStart = 0.0; netEnd = 0.0;
   ArrayResize(ord, 0); ArrayResize(cvol, 0);
   if(n <= 0) return RPA_PLAN_EMPTY;
   const double eps = (step > 0.0 ? step : 0.01) * 0.5;
   int iB = -1, iS = -1; Rpa38PairA(n, vol, side, id, iB, iS);
   keep = (tSide > 0) ? iB : iS;
   if(keep < 0) return RPA_PLAN_NO_TARGET_LEG;
   if(vol[keep] < target - eps) return RPA_PLAN_LEG_TOO_SMALL;
   double v[]; ArrayResize(v, n);
   for(int i = 0; i < n; i++) { v[i] = vol[i]; netStart += side[i] * vol[i]; }
   if(n == 1 && MathAbs(vol[keep] - target) <= eps) { netEnd = netStart; maxAbsNet = MathAbs(netStart); return RPA_PLAN_ALREADY; }
   double N = netStart; maxAbsNet = MathAbs(N);
   const double band = MathMax(MathAbs(netStart), target);
   for(int guard = 0; guard < 2 * n + 2; guard++)
   {
      double cv = 0.0;
      const int it = Rpa38NextClose(n, v, side, keep, target, tSide, step, band, cv);
      if(it < 0) break;
      ArrayResize(ord, steps + 1); ArrayResize(cvol, steps + 1); ord[steps] = it; cvol[steps] = cv; steps++;
      v[it] = (it == keep) ? target : 0.0;
      N -= side[it] * cv;
      if(MathAbs(N) > maxAbsNet) maxAbsNet = MathAbs(N);
   }
   netEnd = N;
   return RPA_PLAN_OK;
}

// ---------------------------------------------------------------- margin model (hedging account) for the preflight path
// mB / mS = margin of 1 lot BUY / SELL (OrderCalcMargin), hedgedShare = SYMBOL_MARGIN_HEDGED / contract size, useLeg = SYMBOL_MARGIN_HEDGED_USE_LEG
double Rpa38Margin(const double vB, const double vS, const double mB, const double mS, const double hedgedShare, const bool useLeg)
{
   if(useLeg) return MathMax(vB * mB, vS * mS);
   const double h = MathMin(vB, vS);
   const double un = (vB > vS) ? (vB - vS) * mB : (vS - vB) * mS;
   return un + h * 0.5 * (mB + mS) * hedgedShare;
}

// ---------------------------------------------------------------- economics
// economic P/L of the cycle if it were closed now: realised (closed deals of the cycle, commission / fee / swap) + floating (incl. swap) - projected exit
// cost of the open gross volume (commission + fee per lot + slippage reserve per lot)
double Rpa38EconAfterExit(const double realised, const double floating, const double gross, const double costPerLot) { return realised + floating - gross * MathMax(0.0, costPerLot); }
// R2 D1 (Owner 01/11/2026): the shared T1 / T2 may hold a basket of ONE side only for the lone Lk* of a reconciled subgrid epoch: SUBGRID epoch >= 1, no rebase request
// without a broker result, exactly one open position of the EA and it is the base Lk*, basket latched (it was latched before the rebase)
bool   Rpa38T1OneSideAllowed(const bool subgridEpoch, const int unresolved, const int positions, const bool onlyBase, const bool latched)
{
   return subgridEpoch && unresolved == 0 && positions == 1 && onlyBase && latched;
}
// HOTFIX HALTED T1/T2 (Owner 02/11/2026): HALTED blocks risk expansion (grid level, rebase, new epoch, hedge), NOT the protection of the lone Lk*. In a HALTED cycle the
// SAME shared T1 / T2 (same economic BE, same distances, same lock / trail / exit code) may hold the lone Lk* only when the record and the broker are reconciled:
//   the RPA record of the cycle is trusted (not lost: JOURNAL_LOST = epoch / Lk* identity / rebase ledger unknown -> nothing is guessed), no rebase request without a broker
//   result (INFLIGHT / UNKNOWN_HOLD), no conflicting broker transaction (Magic order working, recovery request in flight, PairClose leg pending), exactly one position of
//   the EA and it is the Lk* the record names (Rpa38IsRecordLk), basket latched. Anything else: no lock, no request, the existing SL is kept, the reason is journalled.
#define RPA_T1H_OK          0
#define RPA_T1H_LEDGER      1
#define RPA_T1H_UNRESOLVED  2
#define RPA_T1H_CONFLICT    3
#define RPA_T1H_POSITIONS   4
#define RPA_T1H_NOT_LK      5
#define RPA_T1H_LATCH       6
int    Rpa38T1HaltedGate(const bool ledgerTrusted, const int unresolved, const bool conflict, const int positions, const bool isLk, const bool latched)
{
   if(!ledgerTrusted) return RPA_T1H_LEDGER;
   if(unresolved > 0) return RPA_T1H_UNRESOLVED;
   if(conflict) return RPA_T1H_CONFLICT;
   if(positions != 1) return RPA_T1H_POSITIONS;
   if(!isLk) return RPA_T1H_NOT_LK;
   if(!latched) return RPA_T1H_LATCH;
   return RPA_T1H_OK;
}
string Rpa38T1HName(const int c)
{
   switch(c)
   {
      case RPA_T1H_OK: return "RECONCILED";
      case RPA_T1H_LEDGER: return "LEDGER_NOT_TRUSTED";
      case RPA_T1H_UNRESOLVED: return "UNKNOWN_HOLD_OR_INFLIGHT";
      case RPA_T1H_CONFLICT: return "CONFLICTING_BROKER_TRANSACTION";
      case RPA_T1H_POSITIONS: return "NOT_EXACTLY_ONE_POSITION";
      case RPA_T1H_NOT_LK: return "SINGLE_POSITION_NOT_THE_RECORDED_LK";
      case RPA_T1H_LATCH: return "BASKET_NOT_LATCHED";
   }
   return "?";
}
// the single position is the Lk* the record names: the base Lk* of the latest reconciled epoch at its base lot, or the keep leg of the committed rebase at TargetLot
// (the broker shows exactly the REBASE_COMPLETE shape); TargetSide in both cases. No volume / id is inferred: an other id, side or volume is not the Lk*.
bool   Rpa38IsRecordLk(const ulong id, const int side, const double vol, const int epoch, const ulong baseId, const double baseLot, const ulong keepId, const double target,
                       const int targetSide, const double step)
{
   const double eps = (step > 0.0 ? step : 0.01) * 0.5;
   if(id == 0 || side == 0 || side != targetSide) return false;
   if(epoch >= 1 && baseId != 0 && id == baseId && baseLot > 0.0 && MathAbs(vol - baseLot) < eps) return true;
   if(keepId != 0 && id == keepId && target > 0.0 && MathAbs(vol - target) < eps) return true;
   return false;
}
// session rule of a cycle with a rebase (OWNER12 B7 / O12): close + rest when econ >= -pct % x equity
bool   Rpa38SessionMayClose(const double econ, const double equity, const double pct) { return econ >= -MathMax(0.0, pct) / 100.0 * equity - 1e-9; }

#endif
// [FINAL STANDALONE] ===== END INLINED OFH38_Rpa_Core.mqh =====

#define RPA_ST_IDLE      0
#define RPA_ST_ORIGINAL  1
#define RPA_ST_REBASING  2
#define RPA_ST_SUBGRID   3
#define RPA_ST_HALTED    4

#define RPA_RQ_INFLIGHT  1   // accepted / sent: waiting for the broker evidence (deal, volume change)
#define RPA_RQ_UNKNOWN   2   // no broker answer (timeout / connection): reconcile only, never resent
#define RPA_RQ_DONE      3   // broker evidence of the close (deal or volume)
#define RPA_RQ_FAILED    4   // definite rejection (no deal)
#define RPA_RQ_NOTEXEC   5   // unknown / working order resolved as not executed by broker evidence

#define RPA_H_NONE          0
#define RPA_H_KEEP_LOST     1
#define RPA_H_DEFICIT       2
#define RPA_H_RECONCILE     3
#define RPA_H_REJECTED      4
#define RPA_H_MANUAL        5
#define RPA_H_JOURNAL_LOST  6
#define RPA_H_FORBIDDEN     7
#define RPA_H_BASE_LOST     8
#define RPA_H_SUB_LOT       9
#define RPA_H_SNAPSHOT     10   // R1: the persisted decision snapshot of the rebase is missing / does not belong to the commit -> no anchor guessed
// TEST BUILD ONLY negative-control ids RPA_MUT_* (Owner R1 T8): OFH38_TradeGate.mqh (#ifdef OFH38_TEST)

const int RPA_UNKNOWN_RESOLVE_SEC = 300;   // unknown request: "not executed" only after N s with no deal, no working order, volume unchanged (TPC3 value)
const int RPA_MAX_ATTEMPTS        = 5;     // definite rejections of the close of ONE position before HALT
const int RPA_DEVIATION_POINTS    = 30;
const int RPA_MAX_IDS             = 128;

struct RpaReq { ulong pos; double vol; double vol0; long msc; ulong order; ulong deal; int st; uint rc; int attempt; double filled; };

int    g_rpState = RPA_ST_IDLE;
long   g_rpCyc = 0;
int    g_rpEpoch = 0, g_rpK = 0, g_rpL1Side = 0, g_rpSide = 0, g_rpTplCode = RPA_TPL_OK;
double g_rpTplBuy = 0.0, g_rpTplSell = 0.0, g_rpTarget = 0.0;
double g_rpAnchor = 0.0; ulong g_rpBaseId = 0; double g_rpBasePx = 0.0, g_rpBaseLot = 0.0; long g_rpEpochMsc = 0;
int    g_rpAdd = 0, g_rpHiVl = 0, g_rpRebases = 0;
ulong  g_rpSubId[]; int g_rpSubN = 0;
ulong  g_rpKeepId = 0; long g_rpCommitMsc = 0;
double g_rpEcon0 = 0.0, g_rpBe0 = 0.0, g_rpReal0 = 0.0, g_rpNet0 = 0.0, g_rpGross0 = 0.0, g_rpMaxNet0 = 0.0, g_rpMl0 = 0.0, g_rpCostLot = 0.0;
int    g_rpN0 = 0;
RpaReq g_rpReq[]; int g_rpReqN = 0;
int    g_rpHalt = RPA_H_NONE; string g_rpHaltWhy = "";
bool   g_rpEl12 = false, g_rpElMax = false;   // journal flags of the epoch (persisted)
// R1 §2.2 decision snapshot of the committed rebase (persisted before the first close request; kept for the epoch it created, overwritten at the next commit)
double g_rpDecBid = 0.0, g_rpDecAsk = 0.0, g_rpDecAnchor = 0.0, g_rpDecTarget = 0.0, g_rpPostBe = 0.0;
long   g_rpDecMsc = 0, g_rpDecCyc = 0; int g_rpDecSpread = 0, g_rpDecDigits = 0, g_rpDecEpoch = -1, g_rpDecSide = 0;
bool   g_rpSnapPresent = false;   // RpaLoad: every snapshot key of the record exists
double g_rpCommLot = -1.0; long g_rpCommKey = -1;   // measured commission / lot of the cycle (cache)
// evidence counters (run totals; never steer a decision)
long   g_rpcCommits = 0, g_rpcCompletes = 0, g_rpcNoFeasible = 0, g_rpcRiskBlocked = 0, g_rpcShadow = 0, g_rpcT1First = 0, g_rpcWaitBroker = 0;
long   g_rpcReq = 0, g_rpcReqDone = 0, g_rpcReqFail = 0, g_rpcUnknown = 0, g_rpcNotExec = 0, g_rpcHalts = 0, g_rpcSubFills = 0, g_rpcEligible = 0;
long   g_rpcMax = 0, g_rpcLotBlocked = 0, g_rpcCycles = 0, g_rpcRestores = 0, g_rpcPartialFill = 0, g_rpcTplBlocked = 0, g_rpcSubSends = 0;
string g_rpLogKeys = "";
int    g_rpFile = INVALID_HANDLE;

string RpaNs() { return OfhNs("OFH38R", Magic); }
string RpaStateName(const int s)
{
   switch(s)
   {
      case RPA_ST_IDLE: return "IDLE";
      case RPA_ST_ORIGINAL: return "ORIGINAL";
      case RPA_ST_REBASING: return "REBASING";
      case RPA_ST_SUBGRID: return "SUBGRID";
      case RPA_ST_HALTED: return "HALTED";
   }
   return "?";
}
string RpaHaltName(const int h)
{
   switch(h)
   {
      case RPA_H_NONE: return "NONE";
      case RPA_H_KEEP_LOST: return "KEEP_LEG_LOST";
      case RPA_H_DEFICIT: return "TARGET_DEFICIT_NO_REOPEN";
      case RPA_H_RECONCILE: return "RECONCILIATION_MISMATCH";
      case RPA_H_REJECTED: return "CLOSE_REJECTED_REPEATEDLY";
      case RPA_H_MANUAL: return "MANUAL_CLOSE_IN_RPA_EPOCH";
      case RPA_H_JOURNAL_LOST: return "JOURNAL_LOST_WITH_RPA_EVIDENCE";
      case RPA_H_FORBIDDEN: return "SUBGRID_ORDERS_ABOVE_MAX";
      case RPA_H_BASE_LOST: return "BASE_POSITION_LOST";
      case RPA_H_SUB_LOT: return "SUBGRID_LOT_MISMATCH";
      case RPA_H_SNAPSHOT: return "DECISION_SNAPSHOT_NOT_TRUSTED";
   }
   return "?";
}
string RpaRqName(const int s)
{
   switch(s)
   {
      case RPA_RQ_INFLIGHT: return "INFLIGHT";
      case RPA_RQ_UNKNOWN: return "UNKNOWN_HOLD";
      case RPA_RQ_DONE: return "DONE";
      case RPA_RQ_FAILED: return "FAILED";
      case RPA_RQ_NOTEXEC: return "NOT_EXECUTED";
   }
   return "?";
}
void RpaLogOnce(const string key, const string text)
{
   const string k = "|" + key + "|";
   if(StringFind(g_rpLogKeys, k) >= 0) return;
   g_rpLogKeys += k; if(StringLen(g_rpLogKeys) > 6000) g_rpLogKeys = k;
   Print(text);
}

// ---------------------------------------------------------------- read-only accessors used by the EA / GLOBAL / CycleState / Precedence
bool   RpaCycleOk()     { return g_rpCyc != 0 && g_rpCyc == g_cycStartMsc; }
bool   RpaInSubgrid()   { return RpaCycleOk() && g_rpState == RPA_ST_SUBGRID && g_rpEpoch >= 1; }
int    RpaEpoch()       { return RpaCycleOk() ? g_rpEpoch : 0; }
int    RpaK()           { return g_rpK; }
double RpaAnchor()      { return g_rpAnchor; }
long   RpaEpochMsc()    { return g_rpEpochMsc; }
int    RpaSubLevelCount() { return 1 + g_rpAdd; }            // LOCAL level count of the epoch (Lk* = local 1) for the GLOBAL group structure of the epoch
// [NPD R1] read-only: position id of LOCAL level n of the epoch (1 = Lk* base, j + 1 = additional order j in fill order; 0 = not in the record) and the record sizes
ulong  RpaSubIdOfLocal(const int n) { if(n == 1) return g_rpBaseId; const int j = Rpa38JOfLocal(n); return (j >= 1 && j <= g_rpSubN) ? g_rpSubId[j - 1] : 0; }
int    RpaSubRecordN()  { return g_rpSubN; }
int    RpaSubAddCount() { return g_rpAdd; }
int    RpaNextJ()       { return g_rpAdd + 1; }               // next additional order j
int    RpaNextLocal()   { return Rpa38LocalOfJ(g_rpAdd + 1); } // R1: next LOCAL grid level n = j + 1 (trading rules)
int    RpaNextDisplay() { return Rpa38DisplayLevel(g_rpK, RpaNextLocal()); }   // label L(k + n - 1)* only (journal / comment / mapping)
long   RpaDecMsc()      { return g_rpDecMsc; }
double RpaDecBid()      { return g_rpDecBid; }
double RpaDecAsk()      { return g_rpDecAsk; }
// a rebase happened / is running in this cycle: session rule on the economic P/L, T1 / T2 on the economic BE, no NEW DD lock
bool   RpaHadAny()      { return RpaCycleOk() && (g_rpEpoch >= 1 || g_rpState == RPA_ST_REBASING || g_rpRebases > 0 || (g_rpState == RPA_ST_HALTED && g_rpKeepId != 0)); }
int    RpaUnresolved()  { int u = 0; for(int i = 0; i < g_rpReqN; i++) if(g_rpReq[i].st == RPA_RQ_INFLIGHT || g_rpReq[i].st == RPA_RQ_UNKNOWN) u++; return u; }
// the executor owns the basket: T1 / T2 lock, session close and a new DD lock wait (one mechanism at a time, R2 precedence)
bool   RpaInFlight()
{
   return RpaCycleOk() && (g_rpState == RPA_ST_REBASING || RpaUnresolved() > 0);
}
bool   RpaBlocksNewDd() { return RpaHadAny(); }
bool   RpaOwnsGrid()
{
   return RpaCycleOk() && (g_rpState == RPA_ST_REBASING || g_rpState == RPA_ST_HALTED);
}
bool   RpaHoldsGroups() { return RpaCycleOk() && g_rpState == RPA_ST_REBASING; }
// HOTFIX HALTED T1/T2 (Owner 02/11/2026): the lone Lk* of a HALTED cycle stays in the shared T1 / T2 when the record and the broker are reconciled (Rpa38T1HaltedGate);
// otherwise nothing is sent, the existing SL is kept and the reason is journalled ONCE per cycle and reason (T1_HALTED_BLOCKED). Evaluated only for a ONE-side basket
// (T1EligibleNow / T1BePrice / LockEntireCluster ask only then); a two-side basket keeps the unchanged V26 / R2 T1 path in every RPA state.
long   g_rpT1hAllowed = 0, g_rpT1hBlocked = 0; int g_rpT1hLast = -1;
void   RpaT1HaltedBlocked(const int c, const int n, const ulong id, const int side, const double vol)
{
   g_rpT1hBlocked++; g_rpT1hLast = c;
   const string key = StringFormat("T1H_%I64d_%d", g_rpCyc, c);
   if(StringFind(g_rpLogKeys, "|" + key + "|") >= 0) return;
   const string txt = StringFormat("T1 HALTED NOT ARMED (%s) | RPA HALTED %s, cycle %I64d epoch %d | broker: %d position(s) of the EA%s | record: base %I64u %.2f, keep %I64u, TargetLot %.2f %s | unresolved requests %d -> no T1 lock, no request; the existing SL / TP is kept; the shared T1 / T2 is used again once the record and the broker are reconciled",
                                  Rpa38T1HName(c), RpaHaltName(g_rpHalt), g_rpCyc, g_rpEpoch, n, n == 1 ? StringFormat(" (%I64u %s %.2f)", id, side > 0 ? "BUY" : "SELL", vol) : "",
                                  g_rpBaseId, g_rpBaseLot, g_rpKeepId, g_rpTarget, g_rpSide > 0 ? "BUY" : "SELL", RpaUnresolved());
   RpaLogOnce(key, txt);
   RpaEv("T1_HALTED_BLOCKED", txt);
}
// lock rows / prints: a note only for a HALTED cycle (SUBGRID rows keep the R2 text)
string RpaHaltedLockNote() { return (RpaCycleOk() && g_rpState == RPA_ST_HALTED) ? StringFormat(" | RPA HALTED (%s): record and broker reconciled, the shared T1 / T2 holds the basket (no grid, no rebase, no new epoch)", RpaHaltName(g_rpHalt)) : ""; }
bool   RpaT1OneSideHalted()
{
   int n = 0, side = 0; ulong id = 0; double vol = 0.0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      const ulong t = PositionGetTicket(i);
      if(t == 0 || !PositionSelectByTicket(t) || !IsOursPos()) continue;
      n++; id = (ulong)PositionGetInteger(POSITION_IDENTIFIER); vol = PositionGetDouble(POSITION_VOLUME);
      side = PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY ? 1 : -1;
   }
   bool trusted = (g_rpHalt != RPA_H_JOURNAL_LOST);
   int  unresolved = RpaUnresolved();
   const bool conflict = Prio38OrderWorking() || MrInflightAny() || MrSurplusInFlight() || PairPendingAny();
   const bool isLk = (n == 1) && Rpa38IsRecordLk(id, side, vol, g_rpEpoch, g_rpBaseId, g_rpBaseLot, g_rpKeepId, g_rpTarget, g_rpSide, Ex38Step());
   const int c = Rpa38T1HaltedGate(trusted, unresolved, conflict, n, isLk, basketModeLatched);
   if(c != RPA_T1H_OK) { RpaT1HaltedBlocked(c, n, id, side, vol); return false; }
   g_rpT1hAllowed++;
   return true;
}
// R2 D1: the broker shows exactly one position of the EA and it is the base Lk* of the current epoch (reconciled SUBGRID, no rebase request without a broker result)
// HOTFIX: + the lone Lk* of a reconciled HALTED cycle (RpaT1OneSideHalted); REBASING / IDLE / ORIGINAL never
bool   RpaT1OneSide()
{
   if(g_rpState == RPA_ST_HALTED && RpaCycleOk()) return RpaT1OneSideHalted();
   if(!RpaInSubgrid() || g_rpBaseId == 0) return false;
   int n = 0; bool base = false;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      const ulong t = PositionGetTicket(i);
      if(t == 0 || !PositionSelectByTicket(t) || !IsOursPos()) continue;
      n++; if((ulong)PositionGetInteger(POSITION_IDENTIFIER) == g_rpBaseId) base = true;
   }
   return Rpa38T1OneSideAllowed(true, RpaUnresolved(), n, base, basketModeLatched);
}
// identity of the grid double confirmation for the restart check (same value OnTick P11 passes to CheckDoubleConfirm): subgrid = epoch x 1000 + next LOCAL level
int    RpaConfirmNextLevel(const int total) { return RpaInSubgrid() ? Rpa38DcId(g_rpEpoch, RpaNextLocal()) : LbNextLevel(total); }
int    RpaLocalType(const int n) { return Rpa38LocalSide(n, g_rpSide) > 0 ? POSITION_TYPE_BUY : POSITION_TYPE_SELL; }
// R1 §3: grid step of LOCAL level n = the parent GetStep(n) = G(n - 1) (local L2 = G1, L3 = G2, G25 above L26) — GetStep itself is not changed
double RpaLocalStep(const int n)
{
   return GetStep(n);
}
// V26 trigger of local level n: VirtualEntryAnchor +/- G(n - 1) (BUY above, SELL below — GetTrigger of V26 with the anchor as FirstPrice and the type as FirstType)
double RpaLocalTrigger(const int n, const int type) { return NormalizeDouble(Rpa38LocalTrigger(g_rpAnchor, type == POSITION_TYPE_BUY, RpaLocalStep(n)), _Digits); }
double RpaSubLot(const int j) { return Rpa38SubLot(g_rpTarget, j, Ex38Step()); }

double RpaMarginPerLot() { double m = 0.0; if(!OrderCalcMargin(ORDER_TYPE_BUY, _Symbol, 1.0, SymbolInfoDouble(_Symbol, SYMBOL_ASK), m)) m = 0.0; return m; }
double RpaPointValue() { const double ts = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE), tv = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE); return (ts > 0.0) ? tv / ts : 100.0; }
// measured commission + fee per lot of the cycle's entry deals (the exit is assumed to cost the same per lot); cached by deal count
double RpaMeasuredCommLot()
{
   if(g_cycStartMsc <= 0 || !HistorySelect((datetime)(g_cycStartMsc / 1000) - 1, TimeCurrent() + 60)) return MathMax(0.0, g_rpCommLot);
   const int total = HistoryDealsTotal();
   if(g_rpCommKey == total && g_rpCommLot >= 0.0) return g_rpCommLot;
   double c = 0.0, v = 0.0;
   for(int k = 0; k < total; k++)
   {
      const ulong d = HistoryDealGetTicket(k);
      if(d == 0 || HistoryDealGetString(d, DEAL_SYMBOL) != _Symbol || (ulong)HistoryDealGetInteger(d, DEAL_MAGIC) != Magic) continue;
      if(HistoryDealGetInteger(d, DEAL_ENTRY) != DEAL_ENTRY_IN || HistoryDealGetInteger(d, DEAL_TIME_MSC) < g_cycStartMsc) continue;
      c += HistoryDealGetDouble(d, DEAL_COMMISSION) + HistoryDealGetDouble(d, DEAL_FEE); v += HistoryDealGetDouble(d, DEAL_VOLUME);
   }
   g_rpCommKey = total; g_rpCommLot = (v > 0.0) ? MathMax(0.0, -c / v) : 0.0;
   return g_rpCommLot;
}
// projected exit cost / lot: max(Owner estimate PairA_CloseCostPerLotUSD, measured entry commission + fee / lot) + slippage reserve (points x point value / lot)
double RpaCostPerLot() { return MathMax(MathMax(0.0, ClGet(CL_COST)), RpaMeasuredCommLot()) + MathMax(0.0, ClGet(CL_SLIP)) * _Point * RpaPointValue(); }
// economic P/L of the whole BasketCycleID if it were closed now (realised + floating + swap - projected exit cost of the open gross)
double RpaEconNow(double &re, double &fl, double &net, double &gross, const bool fresh)
{
   if(fresh) { g_r2EconKey = ""; }
   R2CycleEconomic(re, fl);
   double vB = 0.0, vS = 0.0, sB = 0.0, sS = 0.0; BasketVolumeSums(vB, vS, sB, sS);
   net = vB - vS; gross = vB + vS;
   return Rpa38EconAfterExit(re, fl, gross, RpaCostPerLot());
}
double RpaBePrice(const double econ, const double net)
{
   const double minV = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   const double be = Econ38BePrice(econ, net, SymbolInfoDouble(_Symbol, SYMBOL_BID), SymbolInfoDouble(_Symbol, SYMBOL_ASK),
                                   SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE), SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE), (minV > 0.0 ? minV : 0.01) * 0.5);
   return be > 0.0 ? PriceN(be) : 0.0;
}
// T1 / T2 price of a cycle with a rebase (PAIRA_LOOP B7 rule kept): economic BE of the whole BasketCycleID
double RpaEconBePrice() { double re, fl, net, gross; const double e = RpaEconNow(re, fl, net, gross, false); return RpaBePrice(e, net); }
// session end of a cycle with a rebase (OWNER12 rule kept): close + rest when the economic P/L >= -pct % x equity
bool RpaSessionMayClose(double &econ, double &equity)
{
   double re, fl, net, gross; econ = RpaEconNow(re, fl, net, gross, false);
   equity = AccountInfoDouble(ACCOUNT_EQUITY);
   return Rpa38SessionMayClose(econ, equity, ClGet(CL_SESS));
}

// ---------------------------------------------------------------- journal (tester: <Research_RunTag>_RPA.csv in MQL5\Files; every row also printed as "RPA|...")
void RpaFileOpen()
{
   if(g_rpFile != INVALID_HANDLE || !(bool)MQLInfoInteger(MQL_TESTER) || Research_RunTag == "") return;
   const string fn = Research_RunTag + "_RPA.csv";
   g_rpFile = FileOpen(fn, FILE_READ | FILE_WRITE | FILE_TXT | FILE_ANSI | FILE_SHARE_READ);
   if(g_rpFile == INVALID_HANDLE) return;
   if(FileSize(g_rpFile) == 0)
      FileWriteString(g_rpFile, "time,msc,cycle,epoch,event,state,k,target,side,anchor,dec_bid,dec_ask,dec_anchor,dec_msc,base_id,base_px,base_lot,add,local,display,step,confirm,j,lot,price,trigger,positions,buy,sell,net,gross,realised,floating,econ,be,margin,equity,free_margin,req_pos,req_vol,req_order,req_deal,rc,detail\n");
   FileSeek(g_rpFile, 0, SEEK_END);
}
void RpaFileClose() { if(g_rpFile != INVALID_HANDLE) { FileClose(g_rpFile); g_rpFile = INVALID_HANDLE; } }
// R1: every candidate / fill row carries LocalGridLevel, DisplayVirtualLevel, StepIndex (G of the local level) and ConfirmRequired (local level vs ConfirmFromOrder)
void RpaRow(const string ev, const int local, const int j, const double lot, const double px, const double trig, const ulong rqPos, const double rqVol, const ulong rqOrd, const ulong rqDeal, const uint rc, const string detail)
{
   double re = 0.0, fl = 0.0, net = 0.0, gross = 0.0, econ = 0.0, be = 0.0;
   double vB = 0.0, vS = 0.0, sB = 0.0, sS = 0.0; BasketVolumeSums(vB, vS, sB, sS);
   const int n = CountPositions();
   if(g_cycStartMsc > 0) { econ = RpaEconNow(re, fl, net, gross, false); be = RpaBePrice(econ, net); }
   string d = detail; StringReplace(d, ",", ";"); StringReplace(d, "\"", "'");
   // [GLOBAL GEN] column "step": V26 = index of the G step of the local level (unchanged); GLOBAL = the element of GlobalGrid_LocalDistancesPips used (local index
   // in its group; 0 = group anchor / breakout anchor)
   const int disp = local > 0 ? Rpa38DisplayLevel(g_rpK, local) : 0, stp = local > 0 ? (GgOn() ? Gg38LocalIndex(local, GgK(), GgMax()) : Rpa38StepIndex(local)) : 0;
   const string cf = local > 1 ? (Rpa38ConfirmRequired(Enable_DoubleConfirmation, local, ConfirmFromOrder) ? "Y" : "N") : "-";
   const string ln = StringFormat("%s,%I64d,%I64d,%d,%s,%s,%d,%.2f,%s,%.2f,%.2f,%.2f,%.2f,%I64d,%I64u,%.2f,%.2f,%d,%d,%d,%d,%s,%d,%.2f,%.2f,%.2f,%d,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%I64u,%.2f,%I64u,%I64u,%u,%s",
                                  TimeToString(TimeCurrent(), TIME_DATE | TIME_SECONDS), Ex38TickMsc(), g_rpCyc, g_rpEpoch, ev, RpaStateName(g_rpState), g_rpK, g_rpTarget,
                                  g_rpSide > 0 ? "BUY" : (g_rpSide < 0 ? "SELL" : "-"), g_rpAnchor, g_rpDecBid, g_rpDecAsk, g_rpDecAnchor, g_rpDecMsc, g_rpBaseId, g_rpBasePx, g_rpBaseLot, g_rpAdd,
                                  local, disp, stp, cf, j, lot, px, trig, n, vB, vS, vB - vS, vB + vS,
                                  re, fl, econ, be, AccountInfoDouble(ACCOUNT_MARGIN), AccountInfoDouble(ACCOUNT_EQUITY), AccountInfoDouble(ACCOUNT_MARGIN_FREE), rqPos, rqVol, rqOrd, rqDeal, rc, d);
   PrintFormat("RPA|%s", ln);
   RpaFileOpen();
   if(g_rpFile != INVALID_HANDLE) { FileWriteString(g_rpFile, ln + "\n"); FileFlush(g_rpFile); }
}
void RpaEv(const string ev, const string detail) { RpaRow(ev, 0, 0, 0.0, 0.0, 0.0, 0, 0.0, 0, 0, 0, detail); }

// ---------------------------------------------------------------- persistence
void RpaResetMemory()
{
   g_rpState = RPA_ST_IDLE; g_rpCyc = 0; g_rpEpoch = 0; g_rpK = 0; g_rpL1Side = 0; g_rpSide = 0; g_rpTplCode = RPA_TPL_OK;
   g_rpTplBuy = 0.0; g_rpTplSell = 0.0; g_rpTarget = 0.0; g_rpAnchor = 0.0; g_rpBaseId = 0; g_rpBasePx = 0.0; g_rpBaseLot = 0.0; g_rpEpochMsc = 0;
   g_rpAdd = 0; g_rpHiVl = 0; g_rpRebases = 0; ArrayResize(g_rpSubId, 0); g_rpSubN = 0;
   g_rpKeepId = 0; g_rpCommitMsc = 0; g_rpEcon0 = 0.0; g_rpBe0 = 0.0; g_rpReal0 = 0.0; g_rpNet0 = 0.0; g_rpGross0 = 0.0; g_rpMaxNet0 = 0.0; g_rpMl0 = 0.0; g_rpCostLot = 0.0; g_rpN0 = 0;
   ArrayResize(g_rpReq, 0); g_rpReqN = 0; g_rpHalt = RPA_H_NONE; g_rpHaltWhy = ""; g_rpEl12 = false; g_rpElMax = false; g_rpCommLot = -1.0; g_rpCommKey = -1;
   g_rpDecBid = 0.0; g_rpDecAsk = 0.0; g_rpDecAnchor = 0.0; g_rpDecTarget = 0.0; g_rpPostBe = 0.0; g_rpDecMsc = 0; g_rpDecCyc = 0; g_rpDecSpread = 0; g_rpDecDigits = 0;
   g_rpDecEpoch = -1; g_rpDecSide = 0; g_rpSnapPresent = false;
   g_rpRetryAtMs = 0; g_rpCowSinceMs = 0;   // [SAFETY S01]
}
void RpaClearRecord() { if(GlobalVariablesDeleteAll(RpaNs()) > 0) GlobalVariablesFlush(); }
void RpaSave()
{
   const string ns = RpaNs();
   GlobalVariablesDeleteAll(ns);
   if(g_rpState == RPA_ST_IDLE || g_rpCyc == 0) { GlobalVariablesFlush(); return; }
   GlobalVariableSet(ns + "cyc", (double)g_rpCyc); GlobalVariableSet(ns + "st", g_rpState); GlobalVariableSet(ns + "ep", g_rpEpoch); GlobalVariableSet(ns + "k", g_rpK);
   GlobalVariableSet(ns + "l1", g_rpL1Side); GlobalVariableSet(ns + "ts", g_rpSide); GlobalVariableSet(ns + "tc", g_rpTplCode);
   GlobalVariableSet(ns + "tb", g_rpTplBuy); GlobalVariableSet(ns + "tsl", g_rpTplSell); GlobalVariableSet(ns + "tl", g_rpTarget);
   GlobalVariableSet(ns + "ax", g_rpAnchor); GlobalVariableSet(ns + "bid", (double)g_rpBaseId); GlobalVariableSet(ns + "bpx", g_rpBasePx); GlobalVariableSet(ns + "blot", g_rpBaseLot);
   GlobalVariableSet(ns + "esm", (double)g_rpEpochMsc); GlobalVariableSet(ns + "add", g_rpAdd); GlobalVariableSet(ns + "hiv", g_rpHiVl); GlobalVariableSet(ns + "rb", g_rpRebases);
   GlobalVariableSet(ns + "kid", (double)g_rpKeepId); GlobalVariableSet(ns + "cm", (double)g_rpCommitMsc); GlobalVariableSet(ns + "e0", g_rpEcon0); GlobalVariableSet(ns + "be0", g_rpBe0);
   GlobalVariableSet(ns + "r0", g_rpReal0); GlobalVariableSet(ns + "nt0", g_rpNet0); GlobalVariableSet(ns + "g0", g_rpGross0); GlobalVariableSet(ns + "n0", g_rpN0);
   GlobalVariableSet(ns + "mx0", g_rpMaxNet0); GlobalVariableSet(ns + "ml0", g_rpMl0); GlobalVariableSet(ns + "cl0", g_rpCostLot);
   GlobalVariableSet(ns + "hc", g_rpHalt); GlobalVariableSet(ns + "e12", g_rpEl12 ? 1 : 0); GlobalVariableSet(ns + "emx", g_rpElMax ? 1 : 0);
   // R1 decision snapshot (only once a rebase was committed in this cycle)
   if(g_rpDecMsc > 0)
   {
      GlobalVariableSet(ns + "dbi", g_rpDecBid); GlobalVariableSet(ns + "das", g_rpDecAsk); GlobalVariableSet(ns + "dax", g_rpDecAnchor); GlobalVariableSet(ns + "dms", (double)g_rpDecMsc);
      GlobalVariableSet(ns + "dsp", g_rpDecSpread); GlobalVariableSet(ns + "ddg", g_rpDecDigits); GlobalVariableSet(ns + "dcy", (double)g_rpDecCyc); GlobalVariableSet(ns + "dep", g_rpDecEpoch);
      GlobalVariableSet(ns + "dsd", g_rpDecSide); GlobalVariableSet(ns + "dtl", g_rpDecTarget); GlobalVariableSet(ns + "pbe", g_rpPostBe);
   }
   GlobalVariableSet(ns + "ns", g_rpSubN);
   for(int i = 0; i < g_rpSubN; i++) GlobalVariableSet(ns + "s" + IntegerToString(i), (double)g_rpSubId[i]);
   GlobalVariableSet(ns + "nq", g_rpReqN);
   for(int i = 0; i < g_rpReqN; i++)
   {
      const string p = ns + "q" + IntegerToString(i);
      GlobalVariableSet(p + "p", (double)g_rpReq[i].pos); GlobalVariableSet(p + "v", g_rpReq[i].vol); GlobalVariableSet(p + "w", g_rpReq[i].vol0);
      GlobalVariableSet(p + "m", (double)g_rpReq[i].msc); GlobalVariableSet(p + "o", (double)g_rpReq[i].order); GlobalVariableSet(p + "d", (double)g_rpReq[i].deal);
      GlobalVariableSet(p + "s", g_rpReq[i].st); GlobalVariableSet(p + "r", (double)g_rpReq[i].rc); GlobalVariableSet(p + "a", g_rpReq[i].attempt); GlobalVariableSet(p + "f", g_rpReq[i].filled);
   }
   OfhIdStore(ns, Magic);
   GlobalVariablesFlush();
}
bool RpaLoad(const string ns)
{
   g_rpCyc = (long)GlobalVariableGet(ns + "cyc"); g_rpState = (int)GlobalVariableGet(ns + "st"); g_rpEpoch = (int)GlobalVariableGet(ns + "ep"); g_rpK = (int)GlobalVariableGet(ns + "k");
   g_rpL1Side = (int)GlobalVariableGet(ns + "l1"); g_rpSide = (int)GlobalVariableGet(ns + "ts"); g_rpTplCode = (int)GlobalVariableGet(ns + "tc");
   g_rpTplBuy = GlobalVariableGet(ns + "tb"); g_rpTplSell = GlobalVariableGet(ns + "tsl"); g_rpTarget = GlobalVariableGet(ns + "tl");
   g_rpAnchor = GlobalVariableGet(ns + "ax"); g_rpBaseId = (ulong)GlobalVariableGet(ns + "bid"); g_rpBasePx = GlobalVariableGet(ns + "bpx"); g_rpBaseLot = GlobalVariableGet(ns + "blot");
   g_rpEpochMsc = (long)GlobalVariableGet(ns + "esm"); g_rpAdd = (int)GlobalVariableGet(ns + "add"); g_rpHiVl = (int)GlobalVariableGet(ns + "hiv"); g_rpRebases = (int)GlobalVariableGet(ns + "rb");
   g_rpKeepId = (ulong)GlobalVariableGet(ns + "kid"); g_rpCommitMsc = (long)GlobalVariableGet(ns + "cm"); g_rpEcon0 = GlobalVariableGet(ns + "e0"); g_rpBe0 = GlobalVariableGet(ns + "be0");
   g_rpReal0 = GlobalVariableGet(ns + "r0"); g_rpNet0 = GlobalVariableGet(ns + "nt0"); g_rpGross0 = GlobalVariableGet(ns + "g0"); g_rpN0 = (int)GlobalVariableGet(ns + "n0");
   g_rpMaxNet0 = GlobalVariableGet(ns + "mx0"); g_rpMl0 = GlobalVariableGet(ns + "ml0"); g_rpCostLot = GlobalVariableGet(ns + "cl0");
   g_rpHalt = (int)GlobalVariableGet(ns + "hc"); g_rpEl12 = GlobalVariableGet(ns + "e12") > 0.5; g_rpElMax = GlobalVariableGet(ns + "emx") > 0.5;
   // R1 decision snapshot: every key must exist (a partial / missing snapshot is never completed from the current price)
   const string sk[11] = {"dbi", "das", "dax", "dms", "dsp", "ddg", "dcy", "dep", "dsd", "dtl", "pbe"};
   g_rpSnapPresent = true;
   for(int i = 0; i < 11; i++) if(!GlobalVariableCheck(ns + sk[i])) g_rpSnapPresent = false;
   if(g_rpSnapPresent)
   {
      g_rpDecBid = GlobalVariableGet(ns + "dbi"); g_rpDecAsk = GlobalVariableGet(ns + "das"); g_rpDecAnchor = GlobalVariableGet(ns + "dax"); g_rpDecMsc = (long)GlobalVariableGet(ns + "dms");
      g_rpDecSpread = (int)GlobalVariableGet(ns + "dsp"); g_rpDecDigits = (int)GlobalVariableGet(ns + "ddg"); g_rpDecCyc = (long)GlobalVariableGet(ns + "dcy"); g_rpDecEpoch = (int)GlobalVariableGet(ns + "dep");
      g_rpDecSide = (int)GlobalVariableGet(ns + "dsd"); g_rpDecTarget = GlobalVariableGet(ns + "dtl"); g_rpPostBe = GlobalVariableGet(ns + "pbe");
   }
   g_rpSubN = (int)GlobalVariableGet(ns + "ns"); if(g_rpSubN < 0 || g_rpSubN > RPA_MAX_IDS) return false;
   ArrayResize(g_rpSubId, g_rpSubN);
   for(int i = 0; i < g_rpSubN; i++) { if(!GlobalVariableCheck(ns + "s" + IntegerToString(i))) return false; g_rpSubId[i] = (ulong)GlobalVariableGet(ns + "s" + IntegerToString(i)); }
   g_rpReqN = (int)GlobalVariableGet(ns + "nq"); if(g_rpReqN < 0 || g_rpReqN > RPA_MAX_IDS) return false;
   ArrayResize(g_rpReq, g_rpReqN);
   for(int i = 0; i < g_rpReqN; i++)
   {
      const string p = ns + "q" + IntegerToString(i);
      if(!GlobalVariableCheck(p + "p")) return false;
      g_rpReq[i].pos = (ulong)GlobalVariableGet(p + "p"); g_rpReq[i].vol = GlobalVariableGet(p + "v"); g_rpReq[i].vol0 = GlobalVariableGet(p + "w");
      g_rpReq[i].msc = (long)GlobalVariableGet(p + "m"); g_rpReq[i].order = (ulong)GlobalVariableGet(p + "o"); g_rpReq[i].deal = (ulong)GlobalVariableGet(p + "d");
      g_rpReq[i].st = (int)GlobalVariableGet(p + "s"); g_rpReq[i].rc = (uint)GlobalVariableGet(p + "r"); g_rpReq[i].attempt = (int)GlobalVariableGet(p + "a"); g_rpReq[i].filled = GlobalVariableGet(p + "f");
   }
   return g_rpState >= RPA_ST_ORIGINAL && g_rpState <= RPA_ST_HALTED && g_rpCyc > 0;
}
// a deal of this cycle carries the RPA tag (rebase close "RPA|R|e" / subgrid order "RPA|S|e|Lv"): the cycle had a rebase
bool RpaHistoryEvidence(const long cyc, string &what)
{
   what = "";
   if(cyc <= 0 || !HistorySelect((datetime)(cyc / 1000) - 1, TimeCurrent() + 60)) return false;
   const int total = HistoryDealsTotal();
   for(int k = 0; k < total; k++)
   {
      const ulong d = HistoryDealGetTicket(k);
      if(d == 0 || HistoryDealGetString(d, DEAL_SYMBOL) != _Symbol || (ulong)HistoryDealGetInteger(d, DEAL_MAGIC) != Magic) continue;
      if(HistoryDealGetInteger(d, DEAL_TIME_MSC) < cyc) continue;
      const string c = HistoryDealGetString(d, DEAL_COMMENT);
      if(StringFind(c, "RPA|") == 0) { what = StringFormat("deal %I64u '%s'", d, c); return true; }
   }
   return false;
}

// ---------------------------------------------------------------- cycle start: template of the BasketCycleID (§2), latched with the cycle
void RpaComputeTemplate()
{
   const double st = Ex38Step(), mn = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN), mx = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   g_rpTplCode = Rpa38Template(ClGet(CL_INITLOT), ClGet(CL_MULTI), g_rpK, g_rpL1Side > 0, st, mn, mx, g_rpTplBuy, g_rpTplSell, g_rpTarget, g_rpSide);
}
void RpaStartCycle(const long cyc, const string why)
{
   RpaResetMemory();
   g_rpCyc = cyc; g_rpState = RPA_ST_ORIGINAL; g_rpEpoch = 0; g_rpEpochMsc = cyc;
   g_rpK = (int)ClGet(CL_RPA_K);
   int ft = FirstType; double fp = 0.0;
   if(ft != POSITION_TYPE_BUY && ft != POSITION_TYPE_SELL) GetFirstPosition(fp, ft);
   g_rpL1Side = (ft == POSITION_TYPE_SELL) ? -1 : 1;
   RpaComputeTemplate();
   g_rpcCycles++;
   RpaSave();
   RpaEv("CYCLE_START", StringFormat("%s | L1 %s | template L1..L%d BUY %.2f SELL %.2f -> Lk* = %s %.2f (%s) | OriginalPairCloseStartOrder %.0f | GridMaxOrders %.0f | SUBGRID_MULTILOT %.2f | PairClose after +%d",
                                    why, g_rpL1Side > 0 ? "BUY" : "SELL", g_rpK, g_rpTplBuy, g_rpTplSell, g_rpSide > 0 ? "BUY" : (g_rpSide < 0 ? "SELL" : "NONE"), g_rpTarget, Rpa38TplName(g_rpTplCode),
                                    ClGet(CL_RPA_START), ClGet(CL_MAXORD), SUBGRID_MULTILOT, SUBGRID_PAIRCLOSE_AFTER_ADDITIONAL_ORDERS));
   if(g_rpTplCode != RPA_TPL_OK) { g_rpcTplBlocked++; R2Warn("RPATPL_" + IntegerToString(cyc), StringFormat("RPA BLOCKED | %s: TargetLot of L%d* cannot be traded (BUY %.2f SELL %.2f) - no rebase in this cycle (no arbitrary position is created); the grid / T1 / T2 / session keep working", Rpa38TplName(g_rpTplCode), g_rpK, g_rpTplBuy, g_rpTplSell)); }
}
void RpaEnsureCycle(const int total)
{
   if(total <= 0 || g_cycStartMsc <= 0) return;
   if(g_rpState != RPA_ST_IDLE && g_rpCyc == g_cycStartMsc) return;
   RpaStartCycle(g_cycStartMsc, g_rpState == RPA_ST_IDLE ? "new BasketCycleID" : StringFormat("cycle id changed %I64d -> %I64d", g_rpCyc, g_cycStartMsc));
}
int RpaE0Levels(const int total) { return LbNextLevel(total) - 1; }

// ---------------------------------------------------------------- halt
void RpaHalt(const int code, const string why)
{
   if(g_rpState == RPA_ST_HALTED) return;
   const int was = g_rpState;
   g_rpState = RPA_ST_HALTED; g_rpHalt = code; g_rpHaltWhy = why; g_rpcHalts++;
   RpaSave();
   R2Warn("RPAHALT_" + IntegerToString(g_rpCyc) + "_" + IntegerToString(code), StringFormat("RPA HALT %s | cycle %I64d epoch %d (was %s) | %s -> fail-closed: no rebase, no grid level until the cycle is flat; T1 / T2 / session / DD / reconciliation keep working",
                                                                                          RpaHaltName(code), g_rpCyc, g_rpEpoch, RpaStateName(was), why));
   RpaEv("HALT", RpaHaltName(code) + " | " + why);
}

// ---------------------------------------------------------------- live positions of the EA (magic + symbol)
int RpaCollect(ulong &tk[], ulong &id[], double &vol[], int &side[], double &px[], long &msc[], string &cmt[])
{
   int n = 0;
   ArrayResize(tk, 0); ArrayResize(id, 0); ArrayResize(vol, 0); ArrayResize(side, 0); ArrayResize(px, 0); ArrayResize(msc, 0); ArrayResize(cmt, 0);
   for(int i = 0; i < PositionsTotal(); i++)
   {
      const ulong t = PositionGetTicket(i);
      if(t == 0 || !PositionSelectByTicket(t) || !IsOursPos()) continue;
      ArrayResize(tk, n + 1); ArrayResize(id, n + 1); ArrayResize(vol, n + 1); ArrayResize(side, n + 1); ArrayResize(px, n + 1); ArrayResize(msc, n + 1); ArrayResize(cmt, n + 1);
      tk[n] = t; id[n] = (ulong)PositionGetInteger(POSITION_IDENTIFIER); vol[n] = PositionGetDouble(POSITION_VOLUME);
      side[n] = PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY ? 1 : -1; px[n] = PositionGetDouble(POSITION_PRICE_OPEN);
      msc[n] = PositionGetInteger(POSITION_TIME_MSC); cmt[n] = PositionGetString(POSITION_COMMENT); n++;
   }
   return n;
}
double RpaLiveVol(const ulong posId) { double v = 0.0; PositionOpenById(posId, v); return v; }
bool   RpaSubHas(const ulong id) { for(int i = 0; i < g_rpSubN; i++) if(g_rpSubId[i] == id) return true; return false; }

// ---------------------------------------------------------------- subgrid: broker-confirmed additional orders of the epoch (§4 / §5)
void RpaSyncSubgrid()
{
   if(g_rpState != RPA_ST_SUBGRID) return;
   ulong tk[], id[]; double vol[], px[]; int side[]; long msc[]; string cmt[];
   const int n = RpaCollect(tk, id, vol, side, px, msc, cmt);
   bool baseOpen = false;
   for(int i = 0; i < n; i++) if(id[i] == g_rpBaseId) baseOpen = true;
   if(!baseOpen) { RpaHalt(RPA_H_BASE_LOST, StringFormat("base Lk* position %I64u (L%d*, %.2f lots) is no longer open outside a basket exit (manual / broker close)", g_rpBaseId, g_rpK, g_rpBaseLot)); return; }
   // new ids in open-time order (j follows the broker fill order)
   for(int pass = 0; pass < n; pass++)
   {
      int pick = -1;
      for(int i = 0; i < n; i++)
      {
         if(id[i] == g_rpBaseId || RpaSubHas(id[i]) || msc[i] < g_rpEpochMsc || StringFind(cmt[i], "R2MR") == 0) continue;
         if(pick < 0 || msc[i] < msc[pick] || (msc[i] == msc[pick] && id[i] < id[pick])) pick = i;
      }
      if(pick < 0) break;
      ArrayResize(g_rpSubId, g_rpSubN + 1); g_rpSubId[g_rpSubN++] = id[pick];
      g_rpAdd++; g_rpcSubFills++;
      const int loc = Rpa38LocalOfJ(g_rpAdd), vl = Rpa38DisplayLevel(g_rpK, loc);   // R1: local level (trading) / display label
      if(vl > g_rpHiVl) g_rpHiVl = vl;
      const double exp = RpaSubLot(g_rpAdd), st = Ex38Step();
      const int expSide = Rpa38LocalSide(loc, g_rpSide);
      RpaRow("SUB_FILL", loc, g_rpAdd, vol[pick], px[pick], 0.0, id[pick], vol[pick], 0, 0, 0,
             StringFormat("additional #%d = local L%d (label L%d*) %s %.2f (expected %s %.2f = %.2f x %.2f^%d raw %.4f) | %s | %s | SubGridAdditionalOpenedCount %d / SubGridMaxAdditionalOrders %.0f | HighestEverOpenedVirtualLevel L%d*",
                          g_rpAdd, loc, vl, side[pick] > 0 ? "BUY" : "SELL", vol[pick], expSide > 0 ? "BUY" : "SELL", exp, g_rpTarget, SUBGRID_MULTILOT, g_rpAdd, Rpa38SubRaw(g_rpTarget, g_rpAdd),
                          GgOn() ? GgRuleText(loc, expSide > 0) : StringFormat("step G%d", Rpa38StepIndex(loc)),   // [GLOBAL GEN] GLOBAL: group / local index / LD, never a V26 G
                          Rpa38ElName(Rpa38SubState(g_rpAdd, (int)ClGet(CL_MAXORD))), g_rpAdd, ClGet(CL_MAXORD), g_rpHiVl));
      if(MathAbs(vol[pick] - exp) >= st * 0.5 || side[pick] != expSide)
      {
         RpaHalt(RPA_H_SUB_LOT, StringFormat("additional #%d position %I64u is %s %.2f, the subgrid rule needs %s %.2f", g_rpAdd, id[pick], side[pick] > 0 ? "BUY" : "SELL", vol[pick], expSide > 0 ? "BUY" : "SELL", exp));
         return;
      }
      const int sc = Rpa38SubState(g_rpAdd, (int)ClGet(CL_MAXORD));
      if(sc == RPA_EL_FORBIDDEN) { RpaHalt(RPA_H_FORBIDDEN, StringFormat("SubGridAdditionalOpenedCount %d > SubGridMaxAdditionalOrders %.0f", g_rpAdd, ClGet(CL_MAXORD))); return; }
      if(!g_rpEl12 && Rpa38SubBeEligible(g_rpAdd, (int)ClGet(CL_MAXORD))) { g_rpEl12 = true; g_rpcEligible++; RpaEv("SUB_ELIGIBLE", StringFormat("additional %d (local L%d, label L%d*) -> %s: PairClose of epoch %d may be evaluated (BE100 + T1/T2 + reconciliation + risk gates still required)", g_rpAdd, loc, vl, Rpa38ElName(sc), g_rpEpoch)); }
      if(!g_rpElMax && sc == RPA_EL_MAX_REACHED) { g_rpElMax = true; g_rpcMax++; RpaEv("SUB_MAX_REACHED", StringFormat("additional %d = SubGridMaxAdditionalOrders %.0f (local L%d, label L%d*): no further subgrid order in epoch %d", g_rpAdd, ClGet(CL_MAXORD), loc, vl, g_rpEpoch)); }
      RpaSave();
   }
}
// grid step of OnTick sent a subgrid order (fill is counted from the broker positions by RpaSyncSubgrid)
void RpaOnGridSend(const int local, const int j, const double lot, const bool isBuy, const double trigger, const bool needConfirm, const bool ok)
{
   if(g_safSendHeld) return;   // [SAFETY S02] TrySendOrder held (no request was sent): no journal row per tick
   g_rpcSubSends++;
   RpaRow(ok ? "SUB_SEND_DONE" : "SUB_SEND_NOT_FILLED", local, j, lot, ok ? trade.ResultPrice() : 0.0, trigger, 0, lot, trade.ResultOrder(), trade.ResultDeal(), trade.ResultRetcode(),
          StringFormat("local L%d (label L%d*) %s %.2f trigger %.2f = %s | double confirmation %s (local L%d vs ConfirmFromOrder %d)",
                       local, Rpa38DisplayLevel(g_rpK, local), isBuy ? "BUY" : "SELL", lot, trigger,
                       GgOn() ? GgRuleText(local, isBuy)   // [GLOBAL GEN] GLOBAL: group anchor +/- LD (or breakout), never a V26 G
                              : StringFormat("anchor %.2f %s G%d (%.0f pip)", g_rpAnchor, isBuy ? "+" : "-", Rpa38StepIndex(local), RpaLocalStep(local) / PipSize),
                       needConfirm ? "REQUIRED" : "no", local, ConfirmFromOrder));
}
void RpaMaxLog(const int local)
{
   RpaLogOnce(StringFormat("RPAMAX_%I64d_%d", g_rpCyc, g_rpEpoch), StringFormat("RPA SUBGRID MAX_REACHED | epoch %d: %d additional orders = GridMaxOrders %.0f -> next local L%d (label L%d*) not sent (no lowering, no lot change); exits / T1 / T2 / PairClose evaluation keep working",
                                                                               g_rpEpoch, g_rpAdd, ClGet(CL_MAXORD), local, Rpa38DisplayLevel(g_rpK, local)));
}
void RpaLotBlockedLog(const int local, const int j, const double lot, const string why)
{
   g_rpcLotBlocked++;
   const string key = StringFormat("RPALOT_%I64d_%d_%d", g_rpCyc, g_rpEpoch, local);
   if(StringFind(g_rpLogKeys, "|" + key + "|") >= 0) return;
   RpaLogOnce(key, StringFormat("RPA SUBGRID BLOCKED | local L%d (label L%d*) j=%d lot %.2f = %.2f x 1.20^%d: %s -> NOT SENT (no silent clamp)", local, Rpa38DisplayLevel(g_rpK, local), j, lot, g_rpTarget, j, why));
   RpaRow("SUB_BLOCKED", local, j, lot, 0.0, 0.0, 0, lot, 0, 0, 0, why);
}

// ---------------------------------------------------------------- rebase decision (§6), called on the P8 slot of OnTick (after T1 / T2 / DD / exit / session)
bool RpaTryRebase(const int total)
{
   if(g_rpState != RPA_ST_ORIGINAL && g_rpState != RPA_ST_SUBGRID) return false;
   const int maxAdd = (int)ClGet(CL_MAXORD);
   if(g_rpEpoch == 0) { if(!Rpa38OrigEligible(RpaE0Levels(total), (int)ClGet(CL_RPA_START))) return false; }
   else if(!Rpa38SubBeEligible(g_rpAdd, maxAdd)) return false;
   if(g_clFrozen) return false;                                     // inputs changed mid-cycle: no new decision (latched cycle keeps exits only)
   if(g_rpTplCode != RPA_TPL_OK) return false;                       // TargetLot invalid for the broker: BLOCKED (logged at the cycle start)
   double re = 0.0, fl = 0.0, net = 0.0, gross = 0.0;
   const double econ = RpaEconNow(re, fl, net, gross, false);
   if(econ < ClGet(CL_SET_MIN)) return false;                      // not at BE100 of the whole BasketCycleID
   const string ekey = StringFormat("%I64d_%d", g_rpCyc, g_rpEpoch);
   // broker state must be proven: no manual-recovery request / working order / restart grace
   if(MrBlocksGrid() || Prio38OrderWorking() || Ex38NowMs() < g_exGraceUntil || g_seRec.st != 0)   // [SAFETY S02] + an entry request without a broker result
   {
      g_rpcWaitBroker++; if(g_seRec.st != 0) g_safRebaseWaitEntry++;
      RpaLogOnce("RPAWAIT_" + ekey, StringFormat("RPA WAIT | cycle %I64d epoch %d at BE100 (economic %.2f) but the broker state is not proven (recovery queue / working order / restart grace) - no rebase on this tick", g_rpCyc, g_rpEpoch, econ));
      return false;
   }
   int nd = 0; double lp = 0.0;
   if(T1EligibleNow(nd, lp)) { g_rpcT1First++; RpaLogOnce("RPAT1_" + ekey + "_" + IntegerToString(total), StringFormat("RPA T1 FIRST | cycle %I64d epoch %d: T1 is eligible on this tick -> T1 / T2 take the basket (Owner: T1/T2 first)", g_rpCyc, g_rpEpoch)); return false; }
   // Pair_A + plan from the live broker positions
   ulong tk[], id[]; double vol[], px[]; int side[]; long msc[]; string cmt[];
   const int n = RpaCollect(tk, id, vol, side, px, msc, cmt);
   const double st = Ex38Step();
   int keep = -1, ord[], steps = 0; double cv[], maxNet = 0.0, n0 = 0.0, n1 = 0.0;
   const int pc = Rpa38Plan(n, vol, side, id, g_rpTarget, g_rpSide, st, keep, ord, cv, steps, maxNet, n0, n1);
   int iB = -1, iS = -1; Rpa38PairA(n, vol, side, id, iB, iS);
   const string pa = StringFormat("Pair_A BUY %s SELL %s", iB >= 0 ? StringFormat("%I64u %.2f", id[iB], vol[iB]) : "none", iS >= 0 ? StringFormat("%I64u %.2f", id[iS], vol[iS]) : "none");
   if(pc != RPA_PLAN_OK)
   {
      if(pc == RPA_PLAN_NO_TARGET_LEG || pc == RPA_PLAN_LEG_TOO_SMALL)
      {
         const string key = StringFormat("RPANF_%s_%d_%.2f_%.2f", ekey, n, iB >= 0 ? vol[iB] : 0.0, iS >= 0 ? vol[iS] : 0.0);
         if(StringFind(g_rpLogKeys, "|" + key + "|") < 0)
         {
            g_rpcNoFeasible++;
            RpaLogOnce(key, StringFormat("RPA NO_FEASIBLE_REBASE | cycle %I64d epoch %d at BE100 (economic %.2f): %s | TargetLot %s %.2f | %s -> no rebase, no other structure, no volume added",
                                         g_rpCyc, g_rpEpoch, econ, pa, g_rpSide > 0 ? "BUY" : "SELL", g_rpTarget, Rpa38PlanName(pc)));
            RpaEv("NO_FEASIBLE_REBASE", Rpa38PlanName(pc) + " | " + pa);
         }
      }
      return false;
   }
   // preflight: margin level at every step of the path (broker-calibrated model), stress of the single position after the rebase
   double mB = 0.0, mS = 0.0;
   const double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID), ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   if(!OrderCalcMargin(ORDER_TYPE_BUY, _Symbol, 1.0, ask, mB)) mB = 0.0;
   if(!OrderCalcMargin(ORDER_TYPE_SELL, _Symbol, 1.0, bid, mS)) mS = 0.0;
   // [SAFETY S11] the margin gate is ON but the broker gave no margin per lot: the model would be 0 and the gate could never block (HOTFIX fail-open) -> no rebase now
   if(!Saf38MarginModelOk(ClGet(CL_PF_ML) > 0.0, mB, mS))
   {
      const string key = StringFormat("RPAMRG_%s_%d", ekey, n);
      if(StringFind(g_rpLogKeys, "|" + key + "|") < 0) { g_rpcRiskBlocked++; g_safMarginBlocked++; RpaLogOnce(key, StringFormat("RPA RISK_BLOCKED (SAFETY) | cycle %I64d epoch %d: OrderCalcMargin gave no margin per lot (BUY %.2f SELL %.2f) - the margin gate (%.0f%%) cannot be evaluated -> no rebase", g_rpCyc, g_rpEpoch, mB, mS, ClGet(CL_PF_ML))); RpaEv("RISK_BLOCKED", "margin model unavailable | " + pa); }
      return false;
   }
   const double cs = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_CONTRACT_SIZE), hm = SymbolInfoDouble(_Symbol, SYMBOL_MARGIN_HEDGED);
   const double share = (cs > 0.0 && hm >= 0.0) ? hm / cs : 1.0;
   const bool useLeg = SymbolInfoInteger(_Symbol, SYMBOL_MARGIN_HEDGED_USE_LEG) != 0;
   double vB = 0.0, vS = 0.0; for(int i = 0; i < n; i++) { if(side[i] > 0) vB += vol[i]; else vS += vol[i]; }
   const double mNowModel = Rpa38Margin(vB, vS, mB, mS, share, useLeg), mNowAcc = AccountInfoDouble(ACCOUNT_MARGIN);
   const double cal = (mNowModel > 0.0 && mNowAcc > 0.0) ? mNowAcc / mNowModel : 1.0;
   const double eq0 = AccountInfoDouble(ACCOUNT_EQUITY), cost = RpaCostPerLot();
   double minMl = 1e12, eq = eq0, b = vB, s = vS;
   for(int k = 0; k < steps; k++)
   {
      if(side[ord[k]] > 0) b -= cv[k]; else s -= cv[k];
      eq -= cv[k] * cost;
      const double m = Rpa38Margin(MathMax(0.0, b), MathMax(0.0, s), mB, mS, share, useLeg) * cal;
      if(m > 0.0) minMl = MathMin(minMl, eq / m * 100.0);
   }
   const double stressLoss = g_rpTarget * MathMax(0.0, ClGet(CL_PF_STRESS)) * RpaPointValue();
   string risk = "";
   if(ClGet(CL_PF_ML) > 0.0 && minMl < ClGet(CL_PF_ML)) risk = StringFormat("margin level %.0f%% < %.0f%% on the closing path", minMl, ClGet(CL_PF_ML));
   else if(ClGet(CL_PF_LOSS) > 0.0 && stressLoss > ClGet(CL_PF_LOSS) / 100.0 * eq0) risk = StringFormat("stress %.0f USD on Lk* %.2f = loss %.2f > %.1f%% x equity %.2f", ClGet(CL_PF_STRESS), g_rpTarget, stressLoss, ClGet(CL_PF_LOSS), eq0);
   if(risk != "")
   {
      const string key = StringFormat("RPARISK_%s_%d", ekey, n);
      if(StringFind(g_rpLogKeys, "|" + key + "|") < 0) { g_rpcRiskBlocked++; RpaLogOnce(key, StringFormat("RPA RISK_BLOCKED | cycle %I64d epoch %d: %s -> no rebase", g_rpCyc, g_rpEpoch, risk)); RpaEv("RISK_BLOCKED", risk + " | " + pa); }
      return false;
   }
   string plan = "";
   for(int k = 0; k < steps; k++) plan += StringFormat("%s%I64u:%s:%.2f%s", k > 0 ? " " : "", id[ord[k]], side[ord[k]] > 0 ? "B" : "S", cv[k], ord[k] == keep ? "(reduce keep)" : "");
   if(ClGet(CL_SHADOW) > 0.5)
   {
      const string key = "RPASH_" + ekey;
      if(StringFind(g_rpLogKeys, "|" + key + "|") < 0) { g_rpcShadow++; RpaLogOnce(key, "RPA SHADOW_REBASE (PairA_ShadowOnly) | " + plan); RpaEv("SHADOW_REBASE", pa + " | keep " + IntegerToString((long)id[keep]) + " | " + plan); }
      return false;
   }
   // R1 §2: decision snapshot of THIS tick (all gates passed): the quote that becomes the DecisionMarketAnchor; an invalid quote -> no commit on this tick
   MqlTick dtk;
   if(!SymbolInfoTick(_Symbol, dtk) || dtk.bid <= 0.0 || dtk.ask <= 0.0 || dtk.ask < dtk.bid)
   {
      g_rpcWaitBroker++;
      RpaLogOnce("RPASNAP_" + ekey, StringFormat("RPA WAIT | cycle %I64d epoch %d at BE100: no valid market quote on the decision tick - no commit (the decision snapshot cannot be taken)", g_rpCyc, g_rpEpoch));
      return false;
   }
   // COMMIT: the plan AND the decision snapshot are written before the first request (a restart resumes the plan from the live broker positions and the snapshot from the record)
   g_rpKeepId = id[keep]; g_rpCommitMsc = Ex38TickMsc();
   g_rpEcon0 = RpaEconNow(re, fl, net, gross, true); g_rpReal0 = re; g_rpNet0 = net; g_rpGross0 = gross; g_rpN0 = n; g_rpBe0 = RpaBePrice(g_rpEcon0, net);
   g_rpMaxNet0 = maxNet; g_rpMl0 = minMl; g_rpCostLot = cost;
   g_rpDecBid = dtk.bid; g_rpDecAsk = dtk.ask; g_rpDecMsc = g_rpCommitMsc; g_rpDecCyc = g_rpCyc; g_rpDecEpoch = g_rpEpoch; g_rpDecSide = g_rpSide; g_rpDecTarget = g_rpTarget;
   g_rpDecSpread = (int)MathRound((dtk.ask - dtk.bid) / _Point); g_rpDecDigits = _Digits; g_rpPostBe = 0.0;
   g_rpDecAnchor = PriceN(Rpa38DecisionAnchor(g_rpSide, dtk.bid, dtk.ask));
   ArrayResize(g_rpReq, 0); g_rpReqN = 0;
   g_rpState = RPA_ST_REBASING; g_rpcCommits++;
   RpaSave();
   RpaEv("REBASE_COMMIT", StringFormat("epoch %d -> %d | %s | keep %I64u %s %.2f -> %.2f | %d positions BUY %.2f SELL %.2f net %+.2f gross %.2f | BE100 economic %.2f (realised %.2f floating %.2f exit cost %.2f/lot) BE %.2f | path max |net| %.2f, min margin level %.0f%% (model x%.4f), stress loss %.2f | plan %s",
                                       g_rpEpoch, g_rpEpoch + 1, pa, id[keep], side[keep] > 0 ? "BUY" : "SELL", vol[keep], g_rpTarget, n, vB, vS, n0, vB + vS, g_rpEcon0, re, fl, cost, g_rpBe0, maxNet,
                                       minMl >= 1e11 ? 0.0 : minMl, cal, stressLoss, plan));
   RpaEv("DECISION_SNAPSHOT", StringFormat("%s digits %d | BasketCycleID %I64d SubGridEpoch %d -> %d | tick %I64d Bid %.2f Ask %.2f spread %d points | TargetSide %s TargetLot %.2f | DecisionMarketAnchor %.2f (%s on the V26 L1 price rule) | DecisionEconomicPnL %.2f DecisionEconomicBE %.2f (accounting only, NOT the anchor)",
                                           _Symbol, g_rpDecDigits, g_rpDecCyc, g_rpDecEpoch, g_rpDecEpoch + 1, g_rpDecMsc, g_rpDecBid, g_rpDecAsk, g_rpDecSpread, g_rpDecSide > 0 ? "BUY" : "SELL", g_rpDecTarget,
                                           g_rpDecAnchor, g_rpDecSide > 0 ? "Ask" : "Bid", g_rpEcon0, g_rpBe0));
   GgOnRebaseCommit();   // GLOBAL Mode 1: the range of group 0 of the next epoch is observed from this decision tick
   for(int k = 0; k < steps; k++)
      RpaRow("PLAN_STEP", 0, k + 1, cv[k], px[ord[k]], 0.0, id[ord[k]], cv[k], 0, 0, 0, StringFormat("step %d/%d %s %s %.2f of %.2f", k + 1, steps, ord[k] == keep ? "REDUCE_KEEP" : "CLOSE", side[ord[k]] > 0 ? "BUY" : "SELL", cv[k], vol[ord[k]]));
   RpaPump();
   return true;
}

// ---------------------------------------------------------------- executor: one close request at a time, broker-proven before the next
// [SAFETY S01] definite rejection = Saf38CloseRcClass (SAFETY CORE): the HOTFIX list WITHOUT LOCKED (10028) and CLOSE_ORDER_EXIST (10039) — both mean the broker already
// holds a request / close order for the position: UNKNOWN_HOLD (reconcile from the deal history / live volume / order state), never a second close on the next tick.
bool RpaRcDefinite(const uint rc)
{
   return Saf38CloseRcClass(rc) == SAF_CR_REJECTED;
}
// broker evidence of request i: deals of its position since the request, the live volume, the order state; true = resolved (no longer in flight)
bool RpaResolveOne(const int i)
{
   if(g_rpReq[i].st != RPA_RQ_INFLIGHT && g_rpReq[i].st != RPA_RQ_UNKNOWN) return true;
   const double eps = Ex38Step() * 0.5;
   double dv = 0.0; ulong last = 0;
   if(HistorySelect((datetime)(g_rpReq[i].msc / 1000) - 5, TimeCurrent() + 60))
   {
      const int total = HistoryDealsTotal();
      for(int k = 0; k < total; k++)
      {
         const ulong d = HistoryDealGetTicket(k);
         if(d == 0 || HistoryDealGetString(d, DEAL_SYMBOL) != _Symbol) continue;
         if((ulong)HistoryDealGetInteger(d, DEAL_POSITION_ID) != g_rpReq[i].pos) continue;
         const long en = HistoryDealGetInteger(d, DEAL_ENTRY);
         if(en != DEAL_ENTRY_OUT && en != DEAL_ENTRY_OUT_BY && en != DEAL_ENTRY_INOUT) continue;
         if(HistoryDealGetInteger(d, DEAL_TIME_MSC) < g_rpReq[i].msc - 1000) continue;
         if(g_rpReq[i].order != 0 && (ulong)HistoryDealGetInteger(d, DEAL_ORDER) != g_rpReq[i].order) continue;
         dv += HistoryDealGetDouble(d, DEAL_VOLUME); last = d;
      }
   }
   const double live = RpaLiveVol(g_rpReq[i].pos);
   const double byVol = g_rpReq[i].vol0 - live;
   const int was = g_rpReq[i].st;
   if(dv > eps || byVol > eps)
   {
      g_rpReq[i].st = RPA_RQ_DONE; g_rpReq[i].filled = MathMax(dv, byVol); if(last != 0) g_rpReq[i].deal = last;
      g_rpcReqDone++;
      if(g_rpReq[i].filled < g_rpReq[i].vol - eps) g_rpcPartialFill++;
      RpaRow("REQUEST_DONE", 0, 0, g_rpReq[i].filled, last != 0 && HistoryDealSelect(last) ? HistoryDealGetDouble(last, DEAL_PRICE) : 0.0, 0.0, g_rpReq[i].pos, g_rpReq[i].vol, g_rpReq[i].order, g_rpReq[i].deal, g_rpReq[i].rc,
             StringFormat("%s -> DONE by broker %s: filled %.2f of %.2f (live volume %.2f, before %.2f)%s", RpaRqName(was), dv > eps ? "deal" : "volume", g_rpReq[i].filled, g_rpReq[i].vol, live, g_rpReq[i].vol0,
                          g_rpReq[i].filled < g_rpReq[i].vol - eps ? " PARTIAL: the remainder is planned again from the live volume" : ""));
      return true;
   }
   if(g_rpReq[i].order != 0)
   {
      if(OrderSelect(g_rpReq[i].order)) return false;   // still working at the broker
      if(HistoryOrderSelect(g_rpReq[i].order))
      {
         const long os = HistoryOrderGetInteger(g_rpReq[i].order, ORDER_STATE);
         if(os == ORDER_STATE_CANCELED || os == ORDER_STATE_REJECTED || os == ORDER_STATE_EXPIRED)
         {
            g_rpReq[i].st = RPA_RQ_NOTEXEC; g_rpcNotExec++;
            RpaRow("REQUEST_NOT_EXECUTED", 0, 0, 0.0, 0.0, 0.0, g_rpReq[i].pos, g_rpReq[i].vol, g_rpReq[i].order, 0, g_rpReq[i].rc, StringFormat("order %I64u state %d, no deal, live volume %.2f", g_rpReq[i].order, (int)os, live));
            return true;
         }
      }
   }
   // no deal, volume unchanged, order not proven: "not executed" only after the resolve window with no working order of the position
   if(Ex38TickMsc() - g_rpReq[i].msc >= (long)RPA_UNKNOWN_RESOLVE_SEC * 1000 && !Ex38CloseOrderWorking(g_rpReq[i].pos) && TerminalInfoInteger(TERMINAL_CONNECTED) != 0)
   {
      g_rpReq[i].st = RPA_RQ_NOTEXEC; g_rpcNotExec++;
      RpaRow("REQUEST_NOT_EXECUTED", 0, 0, 0.0, 0.0, 0.0, g_rpReq[i].pos, g_rpReq[i].vol, g_rpReq[i].order, 0, g_rpReq[i].rc,
             StringFormat("%s for %I64d ms: no deal of position %I64u since the request, no working order, live volume %.2f unchanged -> NOT EXECUTED (broker evidence; the next close is planned from the live volume)",
                          RpaRqName(was), Ex38TickMsc() - g_rpReq[i].msc, g_rpReq[i].pos, live));
      return true;
   }
   return false;
}
bool RpaResolveAll()
{
   bool changed = false, all = true;
   for(int i = 0; i < g_rpReqN; i++)
   {
      if(g_rpReq[i].st != RPA_RQ_INFLIGHT && g_rpReq[i].st != RPA_RQ_UNKNOWN) continue;
      if(RpaResolveOne(i)) changed = true;
      else
      {
         all = false; g_rpcWaitBroker++;
         RpaLogOnce(StringFormat("RPAHOLD_%I64d_%d", g_rpCyc, i), StringFormat("RPA %s | request #%d close %.2f of position %I64u (order %I64u, rc %u) has no broker result yet -> NO_RESEND_RECONCILE_ONLY (no second request)",
                                                                             RpaRqName(g_rpReq[i].st), i, g_rpReq[i].vol, g_rpReq[i].pos, g_rpReq[i].order, g_rpReq[i].rc));
      }
   }
   if(changed) RpaSave();
   return all;
}
int RpaReqAttempts(const ulong pos) { int a = 0; for(int i = 0; i < g_rpReqN; i++) if(g_rpReq[i].pos == pos && (g_rpReq[i].st == RPA_RQ_FAILED || g_rpReq[i].st == RPA_RQ_NOTEXEC)) a++; return a; }
// close `vol` of position `ticket` (id posId, side, live volume vol0); returns the request state
int RpaSend(const ulong ticket, const ulong posId, const int side, const double vol, const double vol0)
{
   const int att = RpaReqAttempts(posId) + 1;
   if(att > RPA_MAX_ATTEMPTS) { RpaHalt(RPA_H_REJECTED, StringFormat("close of position %I64u rejected %d times", posId, att - 1)); return RPA_RQ_FAILED; }
   if(g_rpReqN >= RPA_MAX_IDS) { RpaHalt(RPA_H_REJECTED, "request journal full"); return RPA_RQ_FAILED; }
   // [SAFETY S01] never a close above the live volume of the position (re-read now): otherwise no request, the next close is planned again from the broker
   const double liveNow = PositionSelectByTicket(ticket) ? PositionGetDouble(POSITION_VOLUME) : 0.0;
   if(!Saf38CloseVolumeOk(vol, liveNow, Ex38Step()))
   {
      g_safRpaVolGuard++;
      RpaLogOnce(StringFormat("RPAVOL_%I64d_%I64u_%.2f", g_rpCyc, posId, liveNow), StringFormat("RPA SAFETY | close %.2f of position %I64u but the broker shows %.2f lots -> no request, re-planned from the live volume", vol, posId, liveNow));
      return 0;
   }
   MqlTradeRequest q; MqlTradeResult r; ZeroMemory(q); ZeroMemory(r);
   q.action = TRADE_ACTION_DEAL; q.symbol = _Symbol; q.position = ticket; q.volume = NormalizeDouble(vol, 2); q.magic = Magic;
   q.type = side > 0 ? ORDER_TYPE_SELL : ORDER_TYPE_BUY;
   q.price = side > 0 ? SymbolInfoDouble(_Symbol, SYMBOL_BID) : SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   q.deviation = RPA_DEVIATION_POINTS;
   const long fm = SymbolInfoInteger(_Symbol, SYMBOL_FILLING_MODE);
   q.type_filling = ((fm & SYMBOL_FILLING_FOK) != 0) ? ORDER_FILLING_FOK : (((fm & SYMBOL_FILLING_IOC) != 0) ? ORDER_FILLING_IOC : ORDER_FILLING_RETURN);
   q.comment = StringFormat("RPA|R|%d", g_rpEpoch + 1);
   // intent first (a crash between the record and the request leaves an INFLIGHT record that the broker history resolves)
   const int i = g_rpReqN; ArrayResize(g_rpReq, i + 1); g_rpReqN++;
   g_rpReq[i].pos = posId; g_rpReq[i].vol = q.volume; g_rpReq[i].vol0 = vol0; g_rpReq[i].msc = Ex38TickMsc(); g_rpReq[i].order = 0; g_rpReq[i].deal = 0;
   g_rpReq[i].st = RPA_RQ_INFLIGHT; g_rpReq[i].rc = 0; g_rpReq[i].attempt = att; g_rpReq[i].filled = 0.0;
   RpaSave();
   const long s0 = trade.m_sends;
   trade.OrderSend(q, r);
   g_rpcReq++;
   const uint rc = (trade.m_sends > s0) ? r.retcode : 0;
   g_rpReq[i].rc = rc; g_rpReq[i].order = r.order; g_rpReq[i].deal = r.deal;
   if(rc == TRADE_RETCODE_DONE || rc == TRADE_RETCODE_DONE_PARTIAL || rc == TRADE_RETCODE_PLACED) g_rpReq[i].st = RPA_RQ_INFLIGHT;
   else if(RpaRcDefinite(rc)) { g_rpReq[i].st = RPA_RQ_FAILED; g_rpcReqFail++; g_rpRetryAtMs = Saf38CloseRetryAtMs(Ex38NowMs(), rc, att); }   // [SAFETY S01] bounded backoff
   else { g_rpReq[i].st = RPA_RQ_UNKNOWN; g_rpcUnknown++; }   // [SAFETY S01] incl. LOCKED / CLOSE_ORDER_EXIST: reconcile only
   RpaRow("REQUEST", 0, att, q.volume, q.price, 0.0, posId, q.volume, r.order, r.deal, rc,
          StringFormat("close %s %.2f of %.2f (ticket %I64u) attempt %d -> rc %u %s", side > 0 ? "BUY" : "SELL", q.volume, vol0, ticket, att, rc, RpaRqName(g_rpReq[i].st)));
   if(g_rpReq[i].st == RPA_RQ_INFLIGHT) RpaResolveOne(i);
   RpaSave();
   return g_rpReq[i].st;
}

// ---------------------------------------------------------------- reconciliation + epoch transition (§6.7 / §7 / §9)
// ledger of the rebase from the broker history (F23 fix: recomputed, deduplicated by deal ticket, independent of in-memory events)
void RpaLedger(double &cB, double &cS, double &pl, int &deals, string &txt)
{
   cB = 0.0; cS = 0.0; pl = 0.0; deals = 0; txt = "";
   if(g_rpCommitMsc <= 0 || !HistorySelect((datetime)(g_rpCommitMsc / 1000) - 5, TimeCurrent() + 60)) return;
   // collect first, journal after the loop (a journal row reads the deal history itself and would invalidate this selection)
   ulong dd[], dp[], dor[]; double dv[], dpx[], dpr[], dsw[], dcm[], dfe[]; bool dclB[]; string dc[];
   const int total = HistoryDealsTotal();
   for(int k = 0; k < total; k++)
   {
      const ulong d = HistoryDealGetTicket(k);
      if(d == 0 || HistoryDealGetString(d, DEAL_SYMBOL) != _Symbol || (ulong)HistoryDealGetInteger(d, DEAL_MAGIC) != Magic) continue;
      if(HistoryDealGetInteger(d, DEAL_TIME_MSC) < g_rpCommitMsc - 1000) continue;
      const long en = HistoryDealGetInteger(d, DEAL_ENTRY);
      if(en != DEAL_ENTRY_OUT && en != DEAL_ENTRY_OUT_BY && en != DEAL_ENTRY_INOUT) continue;
      const ulong pid = (ulong)HistoryDealGetInteger(d, DEAL_POSITION_ID);
      if(StringFind(HistoryDealGetString(d, DEAL_COMMENT), "RPA|R|") != 0) { bool req = false; for(int i = 0; i < g_rpReqN; i++) if(g_rpReq[i].pos == pid) req = true; if(!req) continue; }
      bool dup = false; for(int a = 0; a < deals; a++) if(dd[a] == d) dup = true;
      if(dup) continue;
      ArrayResize(dd, deals + 1); ArrayResize(dp, deals + 1); ArrayResize(dor, deals + 1); ArrayResize(dv, deals + 1); ArrayResize(dpx, deals + 1); ArrayResize(dpr, deals + 1);
      ArrayResize(dsw, deals + 1); ArrayResize(dcm, deals + 1); ArrayResize(dfe, deals + 1); ArrayResize(dclB, deals + 1); ArrayResize(dc, deals + 1);
      dd[deals] = d; dp[deals] = pid; dor[deals] = (ulong)HistoryDealGetInteger(d, DEAL_ORDER); dv[deals] = HistoryDealGetDouble(d, DEAL_VOLUME); dpx[deals] = HistoryDealGetDouble(d, DEAL_PRICE);
      dpr[deals] = HistoryDealGetDouble(d, DEAL_PROFIT); dsw[deals] = HistoryDealGetDouble(d, DEAL_SWAP); dcm[deals] = HistoryDealGetDouble(d, DEAL_COMMISSION); dfe[deals] = HistoryDealGetDouble(d, DEAL_FEE);
      dclB[deals] = HistoryDealGetInteger(d, DEAL_TYPE) == DEAL_TYPE_SELL;   // a SELL deal closes a BUY position
      dc[deals] = HistoryDealGetString(d, DEAL_COMMENT);
      deals++;
   }
   for(int a = 0; a < deals; a++)
   {
      if(dclB[a]) cB += dv[a]; else cS += dv[a];
      const double p = dpr[a] + dsw[a] + dcm[a] + dfe[a];
      pl += p;
      RpaRow("LEDGER_DEAL", 0, a + 1, dv[a], dpx[a], 0.0, dp[a], dv[a], dor[a], dd[a], 0,
             StringFormat("closes %s %.2f | profit %.2f swap %.2f commission %.2f fee %.2f = %.2f | '%s'", dclB[a] ? "BUY" : "SELL", dv[a], dpr[a], dsw[a], dcm[a], dfe[a], p, dc[a]));
   }
   txt = StringFormat("%d deals, closed BUY %.2f SELL %.2f, realised %.2f", deals, cB, cS, pl);
}
void RpaComplete()
{
   ulong tk[], id[]; double vol[], px[]; int side[]; long msc[]; string cmt[];
   const int n = RpaCollect(tk, id, vol, side, px, msc, cmt);
   const double eps = Ex38Step() * 0.5;
   if(n != 1 || id[0] != g_rpKeepId || side[0] != g_rpSide || MathAbs(vol[0] - g_rpTarget) >= eps)
   {
      string s = ""; for(int i = 0; i < n; i++) s += StringFormat(" %I64u %s %.2f", id[i], side[i] > 0 ? "BUY" : "SELL", vol[i]);
      RpaHalt(RPA_H_RECONCILE, StringFormat("after the plan the broker shows %d position(s):%s - REBASE_COMPLETE needs exactly ONE position %I64u %s %.2f", n, s, g_rpKeepId, g_rpSide > 0 ? "BUY" : "SELL", g_rpTarget));
      return;
   }
   double cB = 0.0, cS = 0.0, lpl = 0.0; int ld = 0; string ltxt = "";
   RpaLedger(cB, cS, lpl, ld, ltxt);
   double re = 0.0, fl = 0.0, net = 0.0, gross = 0.0;
   const double econ = RpaEconNow(re, fl, net, gross, true);
   const double postBe = RpaBePrice(econ, net);   // R1: post-execution economic BE = accounting / journal only, NEVER the anchor
   // R1 §2: VirtualEntryAnchor = the persisted DecisionMarketAnchor of THIS commit; a missing / foreign snapshot -> fail-closed (no anchor from the current price)
   int ac = RPA_ANC_OK;
   double anchor = Rpa38EpochAnchor(g_rpSnapPresent || g_rpDecMsc > 0, g_rpDecAnchor, g_rpDecBid, g_rpDecAsk, g_rpDecMsc, g_rpCommitMsc, g_rpDecCyc, g_rpCyc, g_rpDecEpoch, g_rpEpoch,
                                    g_rpDecSide, g_rpSide, g_rpDecTarget, g_rpTarget, g_rpBe0, postBe, px[0], ac);
   if(ac != RPA_ANC_OK || anchor <= 0.0)
   {
      RpaHalt(RPA_H_SNAPSHOT, StringFormat("%s: decision snapshot (present %d, anchor %.2f bid %.2f ask %.2f tick %I64d cycle %I64d epoch %d side %d target %.2f) vs commit (tick %I64d cycle %I64d epoch %d side %d target %.2f) - the single position %I64u is kept, no subgrid level, no anchor guessed from the current price | D5 ANCHOR_DRIFT_AUDIT status BLOCKED (no anchor, no drift)",
                                         Rpa38AncName(ac), g_rpSnapPresent || g_rpDecMsc > 0 ? 1 : 0, g_rpDecAnchor, g_rpDecBid, g_rpDecAsk, g_rpDecMsc, g_rpDecCyc, g_rpDecEpoch, g_rpDecSide, g_rpDecTarget,
                                         g_rpCommitMsc, g_rpCyc, g_rpEpoch, g_rpSide, g_rpTarget, id[0]));
      return;
   }
   const int was = g_rpEpoch;
   g_rpEpoch++; g_rpRebases++; g_rpcCompletes++;
   g_rpAnchor = anchor; g_rpPostBe = postBe;
   g_rpBaseId = id[0]; g_rpBasePx = px[0]; g_rpBaseLot = vol[0]; g_rpEpochMsc = Ex38TickMsc();
   g_rpAdd = 0; g_rpHiVl = g_rpK; ArrayResize(g_rpSubId, 0); g_rpSubN = 0; g_rpEl12 = false; g_rpElMax = false;
   g_rpState = RPA_ST_SUBGRID;
   // R1 §4 / §7: the grid memory of the cycle belongs to the previous epoch / the original levels: the next level is LOCAL L2 of the new epoch (no stale send guard,
   // no double confirmation carried over — the confirmation identity of this epoch is epoch x 1000 + local level)
   LastSentOrder = 0; LastSentTime = 0; LastSentCount = 0; DblConfirmNum = 0; DblConfirmHit1 = false; DblConfirmReady = false;
   const double bidNow = SymbolInfoDouble(_Symbol, SYMBOL_BID), askNow = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   const double mkNow = g_rpSide > 0 ? askNow : bidNow;
   RpaEv("REBASE_COMPLETE", StringFormat("RECONCILED: exactly one position %I64u %s %.2f = TargetLot (open %.2f) | ledger %s | economic before %.2f (BE %.2f, realised %.2f) after %.2f (realised %.2f floating %.2f) | margin %.2f equity %.2f free %.2f",
                                         id[0], side[0] > 0 ? "BUY" : "SELL", vol[0], px[0], ltxt, g_rpEcon0, g_rpBe0, g_rpReal0, econ, re, fl,
                                         AccountInfoDouble(ACCOUNT_MARGIN), AccountInfoDouble(ACCOUNT_EQUITY), AccountInfoDouble(ACCOUNT_MARGIN_FREE)));
   const int t2 = RpaLocalType(2), t3 = RpaLocalType(3);
   // R2 D5 (Option B, Owner 01/11/2026): the missing anchor-drift fields ride on THIS row (once per reconciled epoch) — observation only, nothing below reads them
   const long compMsc = Ex38TickMsc();
   // [GLOBAL GEN] GLOBAL: local L2 / L3 previews follow the GLOBAL rule of the epoch (group 0 = DecisionMarketAnchor +/- LD, or a breakout anchor), never a V26 G
   string ru2 = "G1", ru3 = "G2";
   const double trig2 = GgOn() ? GgSubPreview(2, t2 == POSITION_TYPE_BUY, ru2) : RpaLocalTrigger(2, t2);
   const double trig3 = GgOn() ? GgSubPreview(3, t3 == POSITION_TYPE_BUY, ru3) : RpaLocalTrigger(3, t3);
   const double drift = mkNow - g_rpAnchor;
   const bool l2Hit = (t2 == POSITION_TYPE_BUY) ? (askNow >= trig2) : (bidNow <= trig2);
   const string d5 = StringFormat("D5 ANCHOR_DRIFT_AUDIT %s: completion tick %I64d Bid %.2f Ask %.2f -> CompletionMarketReference %.2f (%s) | AnchorDeviationUSD %+.2f (abs %.2f) per unit = %+.2f USD on %.2f lots | RebaseElapsedMs %I64d (decision tick %I64d) | local L2 %s trigger %.2f %s | status SUCCESS",
                                  _Symbol, compMsc, bidNow, askNow, mkNow, g_rpSide > 0 ? "Ask" : "Bid", drift, MathAbs(drift), drift * g_rpTarget * RpaPointValue(), g_rpTarget,
                                  compMsc - g_rpDecMsc, g_rpDecMsc, t2 == POSITION_TYPE_BUY ? "BUY" : "SELL", trig2,
                                  l2Hit ? "HIT_AT_COMPLETION (evaluated by the grid on the next tick)" : StringFormat("WAITING (%s %.2f, %.2f away)", t2 == POSITION_TYPE_BUY ? "Ask" : "Bid", t2 == POSITION_TYPE_BUY ? askNow : bidNow, MathAbs((t2 == POSITION_TYPE_BUY ? askNow : bidNow) - trig2)));
   RpaEv("EPOCH_TRANSITION", StringFormat("BasketCycleID %I64d SubGridEpoch %d -> %d | Lk* = L%d* = LOCAL L1 of a new grid: %s %.2f position %I64u open %.2f | VirtualEntryAnchor %.2f = DecisionMarketAnchor (tick %I64d Bid %.2f Ask %.2f) | NOT anchor: DecisionEconomicBE %.2f, PostExecutionEconomicBE %.2f, retained open %.2f | market now %.2f (drift %+.2f) | cumulative realised %.2f | next local L2 (L%d*) %s %.2f trigger %.2f (%s) | local L3 (L%d*) %s trigger %.2f (%s) | confirmation from local L%d | %s",
                                          g_rpCyc, was, g_rpEpoch, g_rpK, g_rpSide > 0 ? "BUY" : "SELL", g_rpBaseLot, g_rpBaseId, g_rpBasePx, g_rpAnchor, g_rpDecMsc, g_rpDecBid, g_rpDecAsk, g_rpBe0, postBe, px[0],
                                          mkNow, drift, re, Rpa38DisplayLevel(g_rpK, 2), t2 == POSITION_TYPE_BUY ? "BUY" : "SELL", RpaSubLot(1), trig2, ru2,
                                          Rpa38DisplayLevel(g_rpK, 3), t3 == POSITION_TYPE_BUY ? "BUY" : "SELL", trig3, ru3, ConfirmFromOrder, d5));
   g_rpKeepId = 0;
   RpaSave();
   SessRescueRefresh();   // H10 (b3): SESSION_BASKET_RESCUE is keyed by the oldest open ticket, which is now Lk* — refresh it or a restart drops the rescue
   GgOnRebase();   // GLOBAL Mode 1: group 0 of the epoch = local L1..K anchored at the DecisionMarketAnchor, range from the decision tick (no group of the previous epoch)
}
void RpaPump()
{
   const double eps = Ex38Step() * 0.5;
   for(int guard = 0; guard < 2 * RPA_MAX_IDS; guard++)
   {
      if(g_rpState != RPA_ST_REBASING) return;
      SessRescueRefresh();                                  // the oldest ticket of the basket (SESSION_BASKET_RESCUE fingerprint) changes while the rebase closes positions
      if(!RpaResolveAll()) return;                         // a request without a broker result: wait (never a second request)
      ulong tk[], id[]; double vol[], px[]; int side[]; long msc[]; string cmt[];
      const int n = RpaCollect(tk, id, vol, side, px, msc, cmt);
      int keep = -1; for(int i = 0; i < n; i++) if(id[i] == g_rpKeepId) keep = i;
      if(keep < 0) { RpaHalt(RPA_H_KEEP_LOST, StringFormat("keep leg %I64u is no longer open during the rebase", g_rpKeepId)); return; }
      if(vol[keep] < g_rpTarget - eps) { RpaHalt(RPA_H_DEFICIT, StringFormat("keep leg %I64u is %.2f < TargetLot %.2f (over-closed): no position is opened to refill it", g_rpKeepId, vol[keep], g_rpTarget)); return; }
      double cv = 0.0;
      const int it = Rpa38NextClose(n, vol, side, keep, g_rpTarget, g_rpSide, Ex38Step(), MathMax(MathAbs(g_rpNet0), g_rpTarget), cv);   // band = max(|net at the commit|, TargetLot)
      if(it < 0) { RpaComplete(); return; }
      if(!Ex38TradeSessionOpen()) { RpaLogOnce("RPAMKT_" + IntegerToString(g_rpCyc), "RPA REBASE WAITS | trading session of the symbol is closed - no request"); return; }
      // [SAFETY S01] a close order of a basket position still works at the broker (manual / broker / earlier request) or the backoff of a rejection runs -> no request
      bool cow = false; ulong cowId = 0;
      for(int k = 0; k < n && !cow; k++) if(Ex38CloseOrderWorking(id[k])) { cow = true; cowId = id[k]; }
      if(!cow) g_rpCowSinceMs = 0;
      else if(g_rpCowSinceMs == 0) g_rpCowSinceMs = Ex38TickMsc();
      else if(Saf38CowTimedOut(g_rpCowSinceMs, Ex38TickMsc(), (long)RPA_UNKNOWN_RESOLVE_SEC * 1000))   // bounded wait: fail-closed HALT (HALTED keeps T1 / T2 / session)
      {
         g_safCowHalt++;
         RpaHalt(RPA_H_RECONCILE, StringFormat("a close order of position %I64u has been working at the broker for more than %d s while the rebase executes - the plan cannot be reconciled (SAFETY)", cowId, RPA_UNKNOWN_RESOLVE_SEC));
         return;
      }
      if(!Saf38RpaMaySend(cow, Ex38NowMs(), g_rpRetryAtMs))
      {
         g_rpcWaitBroker++; if(cow) g_safRpaCowWait++; else g_safRpaBackoffWait++;
         RpaLogOnce(StringFormat("RPASAFE_%I64d_%d_%d", g_rpCyc, g_rpReqN, cow ? 1 : 0), cow ? StringFormat("RPA SAFETY WAIT | a close order of position %I64u still works at the broker -> no new close request (its fill changes the plan)", cowId)
                                                                                               : StringFormat("RPA SAFETY WAIT | close request rejected by the broker -> next request after the backoff (%I64d ms)", g_rpRetryAtMs - Ex38NowMs()));
         return;
      }
      const int r = RpaSend(tk[it], id[it], side[it], cv, vol[it]);
      if(r != RPA_RQ_DONE) return;                        // in flight / unknown / failed: next tick
   }
}

// ---------------------------------------------------------------- tick entry (P8 slot of OnTick: after DD / exit / T1-T2 ownership / session)
bool RpaTick(const int total)
{
   if(total <= 0) return false;
   RpaEnsureCycle(total);
   if(!RpaCycleOk()) return false;
   if(g_rpState == RPA_ST_HALTED)
   {
      RpaResolveAll();
      return true;
   }
   if(g_rpState == RPA_ST_REBASING) { RpaPump(); return true; }
   if(g_rpState == RPA_ST_SUBGRID) RpaSyncSubgrid();
   if(g_rpState == RPA_ST_HALTED) return true;
   return RpaTryRebase(total);
}
// manual close in an RPA epoch / during a rebase: fail-closed (the deal itself is handled by the R3 FINAL manual recovery rules)
void RpaOnManualClose(const ulong deal)
{
   if(!RpaCycleOk() || !(g_rpState == RPA_ST_REBASING || g_rpEpoch >= 1)) return;
   RpaHalt(RPA_H_MANUAL, StringFormat("manual close deal %I64u in %s epoch %d", deal, RpaStateName(g_rpState), g_rpEpoch));
}
void RpaOnCycleReset()
{
   if(CountPositions() <= 0)
   {
      if(g_rpState != RPA_ST_IDLE && g_rpCyc != 0)
         RpaEv("CYCLE_CLOSED", StringFormat("BasketCycleID %I64d FLAT (no position / pending / in-flight request of the cycle) | epochs %d, rebases %d, final state %s%s | the next entry is BasketCycleID new, SubGridEpoch 0, original L1",
                                            g_rpCyc, g_rpEpoch, g_rpRebases, RpaStateName(g_rpState), g_rpState == RPA_ST_HALTED ? " (" + RpaHaltName(g_rpHalt) + ")" : ""));
      RpaClearRecord();
   }
   RpaResetMemory();
}
// restart: the record of THIS cycle (identity + BasketCycleID); no record + RPA evidence in the deal history -> HALT (the open positions are not original levels)
void RpaRestore()
{
   RpaResetMemory(); g_rpcRestores++;
   const int n = CountPositions();
   const string ns = RpaNs();
   if(n <= 0) { RpaClearRecord(); return; }
   const long cyc = g_cycStartMsc > 0 ? g_cycStartMsc : CycStartMsc();
   bool have = GlobalVariableCheck(ns + "cyc") && OfhIdCheck(ns, Magic) == "" && (long)GlobalVariableGet(ns + "cyc") == cyc && cyc > 0;
   if(have && !RpaLoad(ns)) { have = false; RpaResetMemory(); }
   if(!have)
   {
      string ev = "";
      if(RpaHistoryEvidence(cyc, ev))
      {
         g_rpCyc = cyc; g_rpK = (int)ClGet(CL_RPA_K); g_rpState = RPA_ST_ORIGINAL; g_rpRebases = 1;   // a rebase happened: economic BE for T1 / T2, no new DD lock
         RpaHalt(RPA_H_JOURNAL_LOST, StringFormat("no RPA record of cycle %I64d but the deal history shows %s: the open positions are not original levels (no level / lot / anchor is guessed)", cyc, ev));
         return;
      }
      // no record, no RPA deal in the cycle: original grid of this cycle — the cycle (template from the L1 side) is started on the next tick by RpaEnsureCycle,
      // exactly as without a restart (e.g. a restart on the tick of the L1 fill, before the first RPA tick of the cycle)
      PrintFormat("RPA RESTORE | open basket (%d positions, cycle %I64d) has no RPA record and no RPA deal in its history: original grid (epoch 0), the cycle starts on the next tick", n, cyc);
      return;
   }
   // R1 §2.2: the decision snapshot must come back exactly with the record (rebase running: the snapshot of THIS commit; subgrid: the snapshot that created the epoch,
   // VirtualEntryAnchor == DecisionMarketAnchor). Missing / foreign -> fail-closed, never re-derived from the current price.
   if(g_rpState == RPA_ST_REBASING || g_rpState == RPA_ST_SUBGRID)
   {
      const bool okSnap = g_rpSnapPresent && g_rpDecCyc == g_rpCyc && g_rpDecAnchor > 0.0 &&
                          (g_rpState == RPA_ST_REBASING ? (g_rpDecMsc == g_rpCommitMsc && g_rpDecEpoch == g_rpEpoch)
                                                        : (g_rpDecEpoch == g_rpEpoch - 1 && MathAbs(g_rpDecAnchor - g_rpAnchor) < 1e-6));
      if(!okSnap)
      {
         const bool wasReb = (g_rpState == RPA_ST_REBASING);
         if(wasReb || RpaUnresolved() > 0) Ex38RestartGrace("RPA rebase in progress");
         RpaHalt(RPA_H_SNAPSHOT, StringFormat("restart: the RPA record of cycle %I64d (%s epoch %d) has %s - no anchor is re-derived from the current price",
                                              g_rpCyc, wasReb ? "REBASING" : "SUBGRID", g_rpEpoch, g_rpSnapPresent ? StringFormat("a decision snapshot that does not belong to it (tick %I64d cycle %I64d epoch %d anchor %.2f vs record anchor %.2f commit %I64d)", g_rpDecMsc, g_rpDecCyc, g_rpDecEpoch, g_rpDecAnchor, g_rpAnchor, g_rpCommitMsc) : "no decision snapshot"));
         return;
      }
   }
   if(g_rpState == RPA_ST_REBASING || RpaUnresolved() > 0) Ex38RestartGrace("RPA rebase in progress");
   PrintFormat("RPA RESTORED | cycle %I64d state %s epoch %d | Lk* L%d %s %.2f (template BUY %.2f SELL %.2f) | anchor %.2f base %I64u | additional %d (ids %d) highest L%d* | rebases %d | requests %d (unresolved %d) | halt %s",
               g_rpCyc, RpaStateName(g_rpState), g_rpEpoch, g_rpK, g_rpSide > 0 ? "BUY" : "SELL", g_rpTarget, g_rpTplBuy, g_rpTplSell, g_rpAnchor, g_rpBaseId, g_rpAdd, g_rpSubN, g_rpHiVl, g_rpRebases,
               g_rpReqN, RpaUnresolved(), RpaHaltName(g_rpHalt));
   RpaEv("RESTORED", StringFormat("state %s epoch %d additional %d requests %d unresolved %d", RpaStateName(g_rpState), g_rpEpoch, g_rpAdd, g_rpReqN, RpaUnresolved()));
}
string RpaText()
{
   string s = StringFormat(" | RPA %s cyc=%I64d ep=%d k=%d tl=%.2f ts=%d ax=%.2f base=%I64u/%.2f/%.2f esm=%I64d add=%d hiv=%d rb=%d keep=%I64u cm=%I64d halt=%d dec=%I64d/%.2f/%.2f/%.2f/%I64d/%d/%d/%.2f pbe=%.2f subs=[",
                           RpaStateName(g_rpState), g_rpCyc, g_rpEpoch, g_rpK, g_rpTarget, g_rpSide, g_rpAnchor, g_rpBaseId, g_rpBasePx, g_rpBaseLot, g_rpEpochMsc, g_rpAdd, g_rpHiVl, g_rpRebases, g_rpKeepId, g_rpCommitMsc, g_rpHalt,
                           g_rpDecMsc, g_rpDecBid, g_rpDecAsk, g_rpDecAnchor, g_rpDecCyc, g_rpDecEpoch, g_rpDecSide, g_rpDecTarget, g_rpPostBe);
   for(int i = 0; i < g_rpSubN; i++) s += StringFormat("%s%I64u", i > 0 ? "," : "", g_rpSubId[i]);
   s += "] req=[";
   for(int i = 0; i < g_rpReqN; i++) s += StringFormat("%s%I64u:%.2f:%s", i > 0 ? "," : "", g_rpReq[i].pos, g_rpReq[i].vol, RpaRqName(g_rpReq[i].st));
   return s + "]";
}
void RpaPrintCounters(const string when)
{
   PrintFormat("RPA COUNTERS %s | cycles %I64d restores %I64d | commits %I64d completes %I64d | no feasible %I64d risk blocked %I64d shadow %I64d T1 first %I64d broker waits %I64d | requests %I64d done %I64d failed %I64d unknown %I64d not executed %I64d partial fills %I64d | halts %I64d | subgrid sends %I64d fills %I64d eligible(+12) %I64d max reached %I64d lot blocked %I64d | template blocked %I64d | now %s",
               when, g_rpcCycles, g_rpcRestores, g_rpcCommits, g_rpcCompletes, g_rpcNoFeasible, g_rpcRiskBlocked, g_rpcShadow, g_rpcT1First, g_rpcWaitBroker, g_rpcReq, g_rpcReqDone, g_rpcReqFail,
               g_rpcUnknown, g_rpcNotExec, g_rpcPartialFill, g_rpcHalts, g_rpcSubSends, g_rpcSubFills, g_rpcEligible, g_rpcMax, g_rpcLotBlocked, g_rpcTplBlocked, RpaText());
   PrintFormat("RPA R2 T1 ONE-SIDE COUNTERS %s | locks of the lone Lk* %I64d | not locked (protection not confirmed / SL too close) %I64d, last reason %s | T2 activations of one-side locks %I64d",
               when, g_t1OneLocks, g_t1OneDefer, g_t1OneDeferWhy == "" ? "-" : g_t1OneDeferWhy, g_t1OneT2);
   PrintFormat("RPA HOTFIX T1 HALTED COUNTERS %s | one-side evaluations in a HALTED cycle: reconciled %I64d, blocked %I64d (last reason %s) | halts %I64d",
               when, g_rpT1hAllowed, g_rpT1hBlocked, g_rpT1hLast < 0 ? "-" : Rpa38T1HName(g_rpT1hLast), g_rpcHalts);
}

#endif
// [FINAL STANDALONE] ===== END INLINED OFH38_Rpa.mqh =====
// [FINAL STANDALONE] ===== BEGIN INLINED OFH38_ExitTrend.mqh (HOTFIX SHA256 71732E2362A9C8F44E7CE560D80D1506A3C3DA532FDE5DA5F26FEC8550D1B354) — included from Onefxhub_v38.38_RPA.mq5:L315 =====
// OFH38_ExitTrend.mqh — V38 TWO-PAIRCLOSE P3: chế độ thoát T1 / T2 (phần EA). Luật thuần: OFH38_ExitTrend_Core.mqh. Exit_Mode chốt theo chu kỳ (CL_EXIT_MODE).
// Exit_Mode 0 = LEGACY (b9, parity). 1..3 dùng BE KINH TẾ của cả BasketCycleID (PaEconBePrice: R2CycleEconomic + nổi + swap − chi phí đóng ước tính) cho MỌI chu kỳ:
// sau Progressive PairClose / rebase về Lk, BE là BE của cả chu kỳ (gồm P/L PairClose, hedge, phí), không phải BE cục bộ của vị thế Lk.
// Chỉ báo xu hướng: EMA nhanh / chậm + ATR của ExitTrend_TF, nến đã đóng (shift 1). Đọc không được → coi như xu hướng yếu (T0), đếm lỗi.
// MFE (giá thuận lợi nhất từ lúc T1 khóa) lưu bền (namespace OFH38T) để khởi động lại không mất sàn lợi nhuận của T2 HYBRID.
#ifndef OFH38_EXITTREND_MQH
#define OFH38_EXITTREND_MQH

// [FINAL STANDALONE] ===== BEGIN INLINED OFH38_ExitTrend_Core.mqh (HOTFIX SHA256 0A7B403E11DDBA554DB7A92E36EC23EF424686C43EA5B59F641C57E59C171F8C) — included from OFH38_ExitTrend.mqh:L9 =====
// OFH38_ExitTrend_Core.mqh — V38 TWO-PAIRCLOSE P3 (Owner 28/10/2026): luật THUẦN của các chế độ thoát T1 / T2. Unit test được.
//   0 LEGACY  : như b9 — BE khối lượng V26 khi chu kỳ chưa có Progressive PairClose, BE kinh tế khi đã có (parity).
//   1 T0      : baseline Owner 25 / 15 / 10 pip, nhưng BE = BE KINH TẾ của cả chu kỳ (CycleEconomicPnL: đã chốt — PairClose / hedge / phí — + nổi + swap − chi phí đóng
//               ước tính) ở MỌI chu kỳ. T1 khóa BE ± So_Pip_Doi_SL khi giá qua BE ± Khoang_Doi_SL; T2 kéo SL cách giá Khoang_Trailing_SL, chỉ tiến.
//   2 T1 TREND: như T0, nhưng khi xu hướng theo chiều net MẠNH (điểm xu hướng >= ngưỡng) thì HOÃN kéo SL (giữ mức đang có); xu hướng yếu → kéo như T0.
//   3 T2 HYBRID: như T0 cho T1; T2 = max(sàn lợi nhuận, giá − khoảng thích ứng): sàn = BE + FloorKeep % × (MFE − BE) khi MFE − BE >= FloorStart;
//               khoảng = kẹp(ATR × hệ số (mạnh / yếu), Min, Max). Chỉ tiến.
// Điểm xu hướng = chiều net × (EMA nhanh − EMA chậm) / ATR trên nến ĐÃ ĐÓNG của khung ExitTrend_TF (không nhìn trước). Không dùng tín hiệu GoldEdge (Owner P3).
// Tất cả là THAM SỐ NGHIÊN CỨU, chưa chứng minh tối ưu.
#ifndef OFH38_EXITTREND_CORE_MQH
#define OFH38_EXITTREND_CORE_MQH

#define EXIT38_LEGACY    0
#define EXIT38_T0        1
#define EXIT38_T1_TREND  2
#define EXIT38_T2_HYBRID 3

string Exit38Name(const int m)
{
   switch(m)
   {
      case EXIT38_LEGACY: return "LEGACY_B9";
      case EXIT38_T0: return "T0_STATIC_ECON";
      case EXIT38_T1_TREND: return "T1_TREND_AWARE";
      case EXIT38_T2_HYBRID: return "T2_HYBRID";
   }
   return "?";
}
// điểm xu hướng theo chiều net (dir = +1 BUY net, −1 SELL net); atr <= 0 → 0 (coi như yếu)
double Exit38TrendScore(const int dir, const double emaFast, const double emaSlow, const double atr)
{
   if(atr <= 0.0 || dir == 0) return 0.0;
   return dir * (emaFast - emaSlow) / atr;
}
bool Exit38Strong(const double score, const double strongScore) { return strongScore > 0.0 && score >= strongScore - 1e-12; }
double Exit38Clamp(const double x, const double lo, const double hi) { return MathMax(lo, MathMin(hi, x)); }
// mức thoát mong muốn của T2 (giá). dir > 0: SL dưới giá (tiến = lên); dir < 0: SL trên giá (tiến = xuống). curExit = mức thoát đang có (khóa T1 hoặc lần kéo trước).
// Trả về mức mới đã "chỉ tiến" so với curExit. floorOn / floorPx / dist: thông tin nhật ký.
double Exit38Want(const int mode, const int dir, const double price, const double be, const double lockSl, const double curExit, const double trailT0,
                  const bool strong, const double mfe, const double floorStart, const double floorKeepPct, const double atr, const double multWeak, const double multStrong,
                  const double minDist, const double maxDist, bool &floorOn, double &floorPx, double &dist)
{
   floorOn = false; floorPx = 0.0; dist = trailT0;
   if(dir == 0) return curExit;
   double want = curExit;
   if(mode == EXIT38_T1_TREND && strong) return curExit;   // hoãn kéo SL khi xu hướng mạnh
   if(mode == EXIT38_T2_HYBRID)
   {
      dist = Exit38Clamp(atr * (strong ? multStrong : multWeak), minDist, maxDist);
      const double mfeDist = dir > 0 ? mfe - be : be - mfe;
      if(mfeDist >= floorStart - 1e-12 && floorStart > 0.0)
      {
         floorOn = true;
         floorPx = dir > 0 ? be + floorKeepPct / 100.0 * mfeDist : be - floorKeepPct / 100.0 * mfeDist;
      }
   }
   if(dir > 0)
   {
      double w = MathMax(price - dist, lockSl);
      if(floorOn) w = MathMax(w, floorPx);
      want = MathMax(w, curExit);
   }
   else
   {
      double w = MathMin(price + dist, lockSl);
      if(floorOn) w = MathMin(w, floorPx);
      want = MathMin(w, curExit);
   }
   return want;
}

#endif
// [FINAL STANDALONE] ===== END INLINED OFH38_ExitTrend_Core.mqh =====

int    g_exEmaF = INVALID_HANDLE, g_exEmaS = INVALID_HANDLE, g_exAtr = INVALID_HANDLE;
double g_exMfe = 0.0; long g_exMfeCycle = 0; double g_exMfeSaved = 0.0;
long   g_exStrongTicks = 0, g_exWeakTicks = 0, g_exDelayed = 0, g_exFloorTicks = 0, g_exIndFail = 0, g_exTrailMoves = 0;
bool   g_exFloorWasOn = false;

int    ExitMode() { return (int)ClGet(CL_EXIT_MODE); }
bool   ExitEconBe() { return ExitMode() >= EXIT38_T0; }
string ExitNs() { return OfhNs("OFH38T", Magic); }
void ExitInit()
{
   const ENUM_TIMEFRAMES tf = (ENUM_TIMEFRAMES)(int)ClGet(CL_EXIT_TF);
   if(g_exEmaF != INVALID_HANDLE) { IndicatorRelease(g_exEmaF); IndicatorRelease(g_exEmaS); IndicatorRelease(g_exAtr); g_exEmaF = g_exEmaS = g_exAtr = INVALID_HANDLE; }
   if(ExitMode() < EXIT38_T1_TREND && Exit_Mode < EXIT_T1_TREND) return;   // LEGACY / T0 read no indicator (the tester run of those modes is unchanged)
   g_exEmaF = iMA(_Symbol, tf, MathMax(1, (int)ClGet(CL_EXIT_EF)), 0, MODE_EMA, PRICE_CLOSE);
   g_exEmaS = iMA(_Symbol, tf, MathMax(1, (int)ClGet(CL_EXIT_ES)), 0, MODE_EMA, PRICE_CLOSE);
   g_exAtr  = iATR(_Symbol, tf, MathMax(1, (int)ClGet(CL_EXIT_ATR)));
}
void ExitRelease() { if(g_exEmaF != INVALID_HANDLE) { IndicatorRelease(g_exEmaF); IndicatorRelease(g_exEmaS); IndicatorRelease(g_exAtr); g_exEmaF = g_exEmaS = g_exAtr = INVALID_HANDLE; } }
// trend score in the net direction on the last CLOSED bar; false = indicator not readable (treated as weak)
bool ExitTrendNow(const int dir, double &score, double &atr)
{
   score = 0.0; atr = 0.0;
   if(g_exEmaF == INVALID_HANDLE || g_exEmaS == INVALID_HANDLE || g_exAtr == INVALID_HANDLE) { g_exIndFail++; return false; }
   double f[1], s[1], a[1];
   if(CopyBuffer(g_exEmaF, 0, 1, 1, f) != 1 || CopyBuffer(g_exEmaS, 0, 1, 1, s) != 1 || CopyBuffer(g_exAtr, 0, 1, 1, a) != 1) { g_exIndFail++; return false; }
   atr = a[0];
   score = Exit38TrendScore(dir, f[0], s[0], a[0]);
   return true;
}
void ExitMfePersist() { GlobalVariableSet(ExitNs() + "mfe", g_exMfe); GlobalVariableSet(ExitNs() + "cyc", (double)g_cycStartMsc); OfhIdStore(ExitNs(), Magic); GlobalVariablesFlush(); g_exMfeSaved = g_exMfe; }
void ExitMfeUpdate(const int dir, const MqlTick &tk)
{
   if(g_exMfeCycle != g_cycStartMsc)
   {
      g_exMfeCycle = g_cycStartMsc; g_exMfe = 0.0; g_exFloorWasOn = false;
      if(GlobalVariableCheck(ExitNs() + "mfe") && OfhIdCheck(ExitNs(), Magic) == "" && (long)GlobalVariableGet(ExitNs() + "cyc") == g_cycStartMsc) g_exMfe = GlobalVariableGet(ExitNs() + "mfe");
   }
   const double px = dir > 0 ? tk.bid : tk.ask;
   if(g_exMfe <= 0.0 || (dir > 0 && px > g_exMfe) || (dir < 0 && px < g_exMfe)) g_exMfe = px;
   if(MathAbs(g_exMfe - g_exMfeSaved) >= PipSize - 1e-12) ExitMfePersist();
}
void ExitOnCycleReset()
{
   g_exMfe = 0.0; g_exMfeCycle = 0; g_exMfeSaved = 0.0; g_exFloorWasOn = false;
   if(CountPositions() <= 0 && GlobalVariablesDeleteAll(ExitNs()) > 0) GlobalVariablesFlush();
}
// T2 of modes 2 / 3 (mode 0 / 1 keep the original V26 T2 code in ManageTrailing). Returns true when the exit level was moved / kept this tick.
bool ExitTrailModes(const int trailDir, const MqlTick &tick, const double floorSl)
{
   const int mode = ExitMode();
   if(mode == EXIT38_T2_HYBRID) ExitMfeUpdate(trailDir, tick);
   double score = 0.0, atr = 0.0;
   const bool have = ExitTrendNow(trailDir, score, atr);
   const bool strong = have && Exit38Strong(score, ClGet(CL_EXIT_STRONG));
   if(strong) g_exStrongTicks++; else g_exWeakTicks++;
   const double px = trailDir > 0 ? tick.bid : tick.ask;
   const double floorStart = ClGet(CL_EXIT_FSTART) * PipSize;
   bool floorOn = false; double floorPx = 0.0, dist = 0.0;
   // T2 starts when the price went on past BE ± Khoang_Doi_SL (as T0) — or, in HYBRID, once the profit floor is active
   const bool beyond = hedgeT1Trigger <= 0.0 || (trailDir > 0 ? tick.bid > hedgeT1Trigger + 1e-12 : tick.ask < hedgeT1Trigger - 1e-12);
   const double want = Exit38Want(mode, trailDir, px, hedgeClusterBe, floorSl, hedgeExitPrice, DistTrail(), strong, g_exMfe, floorStart, ClGet(CL_EXIT_FKEEP),
                                  have ? atr : 0.0, ClGet(CL_EXIT_MW), ClGet(CL_EXIT_MS), ClGet(CL_EXIT_TMIN) * PipSize, ClGet(CL_EXIT_TMAX) * PipSize, floorOn, floorPx, dist);
   if(floorOn) { g_exFloorTicks++; if(!g_exFloorWasOn) { g_exFloorWasOn = true; RrGrid("T2_FLOOR_ON", CountPositions(), trailDir, 0.0, floorPx, g_exMfe, StringFormat("mfe %.2f be %.2f", g_exMfe, hedgeClusterBe)); } }
   if(!beyond && !floorOn) return false;
   if(mode == EXIT38_T1_TREND && strong) { g_exDelayed++; return true; }   // trailing delayed while the trend is strong (exit level kept)
   const double w = PriceN(want);
   if(w <= 0.0) return false;
   if(!t2Armed)
   {
      t2Armed = true;
      if(t1Locked)   // [SAFETY S12] T1 not declared yet: the T2 declaration follows the T1 declaration (T2DeclareDeferred); the trailing itself starts now (HOTFIX)
      PrintFormat("RSI6: T2 trail ON %s (%s) | SL %.5f | lock %.5f | trend score %.2f (%s) dist %.2f%s", trailDir > 0 ? "BUY" : "SELL", Exit38Name(mode), w, floorSl, score, strong ? "strong" : "weak", dist,
                  floorOn ? StringFormat(" | profit floor %.5f (MFE %.2f)", floorPx, g_exMfe) : "");
      RrGrid("T2_ON", CountPositions(), trailDir, 0.0, w, floorSl, Exit38Name(mode));
      if(t1OneSide) g_t1OneT2++;
      if(RpaHadAny() && t1Locked) RpaEv("T2_ON", StringFormat("%s trail SL %.2f (%s), never below the T1 lock %.2f | %s", trailDir > 0 ? "BUY" : "SELL", w, Exit38Name(mode), floorSl, t1OneSide ? "one-side lock of the lone Lk*" : "two-side lock"));   // RPA V1-R2 journal (event) [SAFETY S12] t1Locked
   }
   if(MathAbs(w - hedgeExitPrice) > _Point * 0.5) g_exTrailMoves++;
   hedgeExitPrice = w;
   ApplyClusterExit(trailDir, w);
   return true;
}
string ExitCountersText()
{
   return StringFormat("mode %s | trend strong ticks %I64d weak %I64d | trailing delayed %I64d | profit floor ticks %I64d | trail moves %I64d | indicator read failures %I64d",
                       Exit38Name(ExitMode()), g_exStrongTicks, g_exWeakTicks, g_exDelayed, g_exFloorTicks, g_exTrailMoves, g_exIndFail);
}

#endif
// [FINAL STANDALONE] ===== END INLINED OFH38_ExitTrend.mqh =====
// [FINAL STANDALONE] #include "OFH38_Owner12_Core.mqh" — already inlined above; the original include guard made this include a no-op
// [FINAL STANDALONE] ===== BEGIN INLINED OFH38_ResearchRec.mqh (HOTFIX SHA256 F9C6837E87DB329B54F2CB09643BA291CECE2F6725A38BB9A4CB36BDDB36F907) — included from Onefxhub_v38.38_RPA.mq5:L317 =====
// OFH38_ResearchRec.mqh — V38 OWNER12 (chỉ thị Owner 25/10/2026, mục 11 / 12): bộ ghi nghiên cứu CHỈ CHẠY TRONG STRATEGY TESTER (MQL_TESTER) và chỉ khi
// Research_Recorder = true. Nó KHÔNG gửi / sửa / đóng lệnh và không đổi quyết định nào của EA; trên Demo / Live nó không làm gì.
//   <tag>_M1.csv  mỗi phút (theo giờ server): equity mở / thấp / cao / cuối (mark-to-market mỗi tick), balance, lỗ / lãi nổi, margin max, margin level min (chỉ khi
//                 margin > 0), số vị thế max, lot BUY / SELL cuối phút, gross max, |net| max, spread max, số tick.
//   <tag>_EVT.csv sự kiện: START, BANKRUPT (deal stop-out của broker / tester hoặc equity <= 0 = EXIT_CAUSE), FORCED_END (chỉ khi còn vị thế lúc OnDeinit; đo 25/10/2026:
//                 Strategy Tester đóng vị thế còn mở TRƯỚC OnDeinit, nên đóng cưỡng bức cuối dữ liệu được đọc từ deal "end of test" của HTML), END (lý do dừng).
// Research_StopOnBankrupt = true: ở BANKRUPT gọi TesterStop() — lượt dừng theo lỗi, equity âm không được giữ lại như một kết quả hợp lệ.
// File nằm trong MQL5\Files của agent tester (công cụ run_owner12.py chép ra cạnh log / HTML).
#ifndef OFH38_RESEARCHREC_MQH
#define OFH38_RESEARCHREC_MQH

// LPGD (26/10/2026): <tag>_PA.csv  snapshot PairA (cặp khóa, C(t), preflight, danh sách vị thế) — OFH38_PairA PaRecRow / PaRecEvent;
//                    <tag>_GRID.csv L1 / lệnh Grid (cấp, chiều, lot, giá, trigger, nhóm GLOBAL) / T1 / T2 / thoát / cụm phẳng — dòng thời gian sự kiện GLOBAL D;
//                    _M1.csv thêm Bid mở / cao / thấp / cuối, Ask cao / thấp của phút (giá tick tester thấy) — dữ liệu đường giá cho phân tích offline.
bool   g_rrOn = false;
int    g_rrMinH = INVALID_HANDLE, g_rrEvtH = INVALID_HANDLE, g_rrPaH = INVALID_HANDLE, g_rrGridH = INVALID_HANDLE;
long   g_rrMinute = -1;
double g_rrEqO = 0.0, g_rrEqL = 0.0, g_rrEqH = 0.0, g_rrEqC = 0.0, g_rrBal = 0.0, g_rrFl = 0.0, g_rrMgMax = 0.0, g_rrMlMin = 0.0;
double g_rrBuy = 0.0, g_rrSell = 0.0, g_rrGrossMax = 0.0, g_rrNetMax = 0.0, g_rrSprMax = 0.0;
double g_rrBO = 0.0, g_rrBH = 0.0, g_rrBL = 0.0, g_rrBC = 0.0, g_rrAH = 0.0, g_rrAL = 0.0;
int    g_rrPosMax = 0; long g_rrTicks = 0;
bool   g_rrBankrupt = false; string g_rrCause = "END_OF_DATA";
double g_rrEqPeak = 0.0, g_rrDdMaxPct = 0.0;

string RrTag() { return Research_RunTag != "" ? Research_RunTag : "OFH38R"; }
void RrEvent(const string kind, const string detail)
{
   if(!g_rrOn || g_rrEvtH == INVALID_HANDLE) return;
   FileWriteString(g_rrEvtH, StringFormat("%s,%s,%.2f,%.2f,%d,\"%s\"\n", TimeToString(TimeCurrent(), TIME_DATE | TIME_SECONDS), kind,
                                          AccountInfoDouble(ACCOUNT_BALANCE), AccountInfoDouble(ACCOUNT_EQUITY), PositionsTotal(), detail));
   FileFlush(g_rrEvtH);
}
void RrInit()
{
   g_rrOn = (bool)MQLInfoInteger(MQL_TESTER) && Research_Recorder;
   if(!g_rrOn) return;
   g_rrMinH = FileOpen(RrTag() + "_M1.csv", FILE_WRITE | FILE_TXT | FILE_ANSI);
   g_rrEvtH = FileOpen(RrTag() + "_EVT.csv", FILE_WRITE | FILE_TXT | FILE_ANSI);
   g_rrPaH = FileOpen(RrTag() + "_PA.csv", FILE_WRITE | FILE_TXT | FILE_ANSI);
   g_rrGridH = FileOpen(RrTag() + "_GRID.csv", FILE_WRITE | FILE_TXT | FILE_ANSI);
   if(g_rrMinH == INVALID_HANDLE || g_rrEvtH == INVALID_HANDLE || g_rrPaH == INVALID_HANDLE || g_rrGridH == INVALID_HANDLE) { PrintFormat("RESEARCH RECORDER | cannot open the CSV files (%d) - recorder OFF", GetLastError()); g_rrOn = false; return; }
   FileWriteString(g_rrMinH, "minute,eq_open,eq_min,eq_max,eq_close,balance,floating,margin_max,margin_level_min,positions_max,buy_lots,sell_lots,gross_max,net_abs_max,spread_max,ticks,bid_open,bid_high,bid_low,bid_close,ask_high,ask_low\n");
   FileWriteString(g_rrEvtH, "time,event,balance,equity,positions,detail\n");
   FileWriteString(g_rrPaH, "event,time,msc,cycle,iter,seg,bin,pct,econ,emin,realised,floating,bid,ask,equity,balance,margin,margin_per_lot,positions,buy_id,sell_id,buy_lv,sell_lv,comp_pl,comp_lots,t1_eligible,"
                            "lk_level,lk_lot,pf_ok,pf_keep,pf_nh,pf_pct,pf_first,pf_step,pf_tp,pf_dist0,pf_maxdist,pf_pstar0,pf_lossw_pct,pf_mlw_pct,pf_fail,pf_evals,h0b_st,h0b_pstar,h0b_dist,h0s_st,h0s_pstar,h0s_dist,detail,positions_blob\n");
   FileWriteString(g_rrGridH, "time,msc,event,cycle,level,side,lot,price,trigger,tag,bid,ask,positions,buy_lots,sell_lots,equity,balance,floating,margin\n");
   g_rrEqPeak = AccountInfoDouble(ACCOUNT_EQUITY);
   RrEvent("START", StringFormat("tag %s | stop on bankrupt %s | deposit %.2f", RrTag(), Research_StopOnBankrupt ? "yes" : "no", AccountInfoDouble(ACCOUNT_BALANCE)));
   PrintFormat("RESEARCH RECORDER ON (tester only, observe only) | tag %s | files %s_M1.csv / %s_EVT.csv | stop on bankrupt %s", RrTag(), RrTag(), RrTag(), Research_StopOnBankrupt ? "yes" : "no");
}
void RrFlushMinute()
{
   if(g_rrMinute < 0 || g_rrMinH == INVALID_HANDLE) return;
   FileWriteString(g_rrMinH, StringFormat("%s,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%d,%.2f,%.2f,%.2f,%.2f,%.2f,%I64d,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f\n", TimeToString((datetime)(g_rrMinute * 60), TIME_DATE | TIME_MINUTES),
                                          g_rrEqO, g_rrEqL, g_rrEqH, g_rrEqC, g_rrBal, g_rrFl, g_rrMgMax, g_rrMlMin, g_rrPosMax, g_rrBuy, g_rrSell, g_rrGrossMax, g_rrNetMax, g_rrSprMax, g_rrTicks,
                                          g_rrBO, g_rrBH, g_rrBL, g_rrBC, g_rrAH, g_rrAL));
}
bool RrPaOn() { return g_rrOn && g_rrPaH != INVALID_HANDLE; }
void RrPaWrite(const string line) { if(RrPaOn()) FileWriteString(g_rrPaH, line + "\n"); }
// one grid / exit event of the basket (tester + recorder only)
void RrGrid(const string kind, const int level, const int side, const double lot, const double price, const double trigger, const string tag)
{
   if(!g_rrOn || g_rrGridH == INVALID_HANDLE) return;
   double b = 0.0, s = 0.0; int n = 0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      const ulong t = PositionGetTicket(i);
      if(t == 0 || !PositionSelectByTicket(t) || PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
      n++;
      if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY) b += PositionGetDouble(POSITION_VOLUME); else s += PositionGetDouble(POSITION_VOLUME);
   }
   string tg = tag; StringReplace(tg, ",", ";"); StringReplace(tg, "\"", "'");
   MqlTick tk; SymbolInfoTick(_Symbol, tk);
   FileWriteString(g_rrGridH, StringFormat("%s,%I64d,%s,%I64d,%d,%s,%.2f,%.2f,%.2f,\"%s\",%.2f,%.2f,%d,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f\n", TimeToString(TimeCurrent(), TIME_DATE | TIME_SECONDS), tk.time_msc, kind,
                                           g_cycStartMsc, level, side > 0 ? "BUY" : (side < 0 ? "SELL" : "-"), lot, price, trigger, tg, tk.bid, tk.ask, n, b, s, AccountInfoDouble(ACCOUNT_EQUITY),
                                           AccountInfoDouble(ACCOUNT_BALANCE), AccountInfoDouble(ACCOUNT_EQUITY) - AccountInfoDouble(ACCOUNT_BALANCE), AccountInfoDouble(ACCOUNT_MARGIN)));
}
void RrBankrupt(const string cause, const string detail)
{
   if(g_rrBankrupt) return;
   g_rrBankrupt = true; g_rrCause = cause;
   RrEvent("BANKRUPT", cause + " | " + detail);
   PrintFormat("RESEARCH EXIT_CAUSE BANKRUPT %s | %s | balance %.2f equity %.2f positions %d%s", cause, detail, AccountInfoDouble(ACCOUNT_BALANCE), AccountInfoDouble(ACCOUNT_EQUITY), PositionsTotal(),
               Research_StopOnBankrupt ? " | TesterStop: the pass ends here (negative equity is not a valid result)" : "");
   if(Research_StopOnBankrupt) TesterStop();
}
// cuối mỗi tick (sau mọi quyết định của EA)
void RrTick()
{
   if(!g_rrOn) return;
   const double eq = AccountInfoDouble(ACCOUNT_EQUITY), bal = AccountInfoDouble(ACCOUNT_BALANCE), mg = AccountInfoDouble(ACCOUNT_MARGIN);
   double b = 0.0, s = 0.0; int n = 0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      const ulong t = PositionGetTicket(i);
      if(t == 0 || !PositionSelectByTicket(t) || PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
      n++;
      if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY) b += PositionGetDouble(POSITION_VOLUME); else s += PositionGetDouble(POSITION_VOLUME);
   }
   MqlTick tk; const double spr = SymbolInfoTick(_Symbol, tk) ? tk.ask - tk.bid : 0.0;
   const long m = (long)(TimeCurrent() / 60);
   if(m != g_rrMinute)
   {
      RrFlushMinute();
      g_rrMinute = m; g_rrEqO = eq; g_rrEqL = eq; g_rrEqH = eq; g_rrMgMax = 0.0; g_rrMlMin = 0.0; g_rrPosMax = 0; g_rrGrossMax = 0.0; g_rrNetMax = 0.0; g_rrSprMax = 0.0; g_rrTicks = 0;
      g_rrBO = tk.bid; g_rrBH = tk.bid; g_rrBL = tk.bid; g_rrAH = tk.ask; g_rrAL = tk.ask;
   }
   g_rrTicks++;
   g_rrBC = tk.bid; if(tk.bid > g_rrBH) g_rrBH = tk.bid; if(tk.bid < g_rrBL) g_rrBL = tk.bid; if(tk.ask > g_rrAH) g_rrAH = tk.ask; if(tk.ask < g_rrAL) g_rrAL = tk.ask;
   g_rrEqC = eq; g_rrBal = bal; g_rrFl = eq - bal; g_rrBuy = b; g_rrSell = s;
   if(eq < g_rrEqL) g_rrEqL = eq;
   if(eq > g_rrEqH) g_rrEqH = eq;
   if(mg > g_rrMgMax) g_rrMgMax = mg;
   if(mg > 0.0) { const double ml = eq / mg * 100.0; if(g_rrMlMin <= 0.0 || ml < g_rrMlMin) g_rrMlMin = ml; }
   if(n > g_rrPosMax) g_rrPosMax = n;
   if(b + s > g_rrGrossMax) g_rrGrossMax = b + s;
   if(MathAbs(b - s) > g_rrNetMax) g_rrNetMax = MathAbs(b - s);
   if(spr > g_rrSprMax) g_rrSprMax = spr;
   if(eq > g_rrEqPeak) g_rrEqPeak = eq;
   if(g_rrEqPeak > 0.0) { const double dd = (g_rrEqPeak - eq) / g_rrEqPeak * 100.0; if(dd > g_rrDdMaxPct) g_rrDdMaxPct = dd; }
   if(eq <= 0.0) RrBankrupt("EQUITY_LE_0", StringFormat("equity %.2f <= 0 (DD %.2f%% from the peak %.2f)", eq, g_rrDdMaxPct, g_rrEqPeak));
}
// deal của tester / broker: stop-out = mất tài khoản
void RrTrade(const MqlTradeTransaction &trans)
{
   if(!g_rrOn || g_rrBankrupt || trans.type != TRADE_TRANSACTION_DEAL_ADD || trans.deal == 0) return;
   if(!HistoryDealSelect(trans.deal)) return;
   if(HistoryDealGetInteger(trans.deal, DEAL_REASON) != DEAL_REASON_SO) return;
   RrBankrupt("STOP_OUT", StringFormat("deal %I64u position %I64u %.2f lots closed by STOP OUT (margin level <= stop-out level)", trans.deal,
                                       (ulong)HistoryDealGetInteger(trans.deal, DEAL_POSITION_ID), HistoryDealGetDouble(trans.deal, DEAL_VOLUME)));
}
void RrDeinit(const int reason)
{

   if(!g_rrOn) return;
   RrFlushMinute();
   double b = 0.0, s = 0.0; int n = 0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      const ulong t = PositionGetTicket(i);
      if(t == 0 || !PositionSelectByTicket(t) || PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
      n++;
      if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY) b += PositionGetDouble(POSITION_VOLUME); else s += PositionGetDouble(POSITION_VOLUME);
   }
   if(n > 0) RrEvent("FORCED_END", StringFormat("%d positions open at the end of the data (BUY %.2f SELL %.2f, floating %.2f): the tester closes them at the last price with spread - FORCED_END_OF_DAY_DIAGNOSTIC for a one-day pass",
                                                n, b, s, AccountInfoDouble(ACCOUNT_EQUITY) - AccountInfoDouble(ACCOUNT_BALANCE)));
   RrEvent("END", StringFormat("cause %s | deinit reason %d | equity DD max %.2f%% (tick, from the running peak)", g_rrCause, reason, g_rrDdMaxPct));
   PrintFormat("RESEARCH RECORDER END | cause %s | positions open %d | equity DD max %.2f%% (tick)", g_rrCause, n, g_rrDdMaxPct);
   FileClose(g_rrMinH); FileClose(g_rrEvtH); FileClose(g_rrPaH); FileClose(g_rrGridH);
   g_rrMinH = INVALID_HANDLE; g_rrEvtH = INVALID_HANDLE; g_rrPaH = INVALID_HANDLE; g_rrGridH = INVALID_HANDLE;
}

#endif
// [FINAL STANDALONE] ===== END INLINED OFH38_ResearchRec.mqh =====

// OWNER12: kiểu vào lệnh ĐÃ CHỐT của chu kỳ (Input khi chưa có chu kỳ) — GgOn() của OFH38_GlobalGrid đọc qua đây
bool   O12GlobalLatched() { return ClGet(CL_GG_ON) > 0.5; }
int    O12LatchedK()      { return (int)ClGet(CL_GG_K); }
double O12LatchedD()      { return ClGet(CL_GG_D); }
long g_o12MaxOrdCycles = 0, g_o12SessDefer = 0; long g_o12MaxOrdCycle = 0;

// [INPUT CLEANUP R1] IC3: startup diagnostics — LOG ONLY (no decision reads it). Printed before any configuration check so that a refused start also shows the
// environment: terminal build, tester / visual mode, symbol specification (suffix such as ".c" included), pip rule, volume limits, account margin mode, entry strategy.
void Ic38StartupDiag()
{
   const ENUM_ACCOUNT_MARGIN_MODE mm=(ENUM_ACCOUNT_MARGIN_MODE)AccountInfoInteger(ACCOUNT_MARGIN_MODE);
   PrintFormat("V38 STARTUP DIAG | program %s | terminal build %d | tester %s, visual %s, optimization %s | symbol %s: digits %d, point %g, tick size %g, tick value %g, contract %g, spread %d points | pip %g price (rule: XAU / GOLD in the symbol name -> 0.1, else 5 / 3 digits -> 10 points, else 1 point) | volume min %g step %g max %g | symbol trade mode %d | account margin mode %s, trade mode %d, currency %s, leverage 1:%d | entry strategy %d (%s) | GLOBAL K %d, D %g, list %d characters",
               MQLInfoString(MQL_PROGRAM_NAME), (int)TerminalInfoInteger(TERMINAL_BUILD), (bool)MQLInfoInteger(MQL_TESTER)?"yes":"no", (bool)MQLInfoInteger(MQL_VISUAL_MODE)?"yes":"no",
               (bool)MQLInfoInteger(MQL_OPTIMIZATION)?"yes":"no", _Symbol, _Digits, _Point, SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_SIZE), SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_VALUE),
               SymbolInfoDouble(_Symbol,SYMBOL_TRADE_CONTRACT_SIZE), (int)SymbolInfoInteger(_Symbol,SYMBOL_SPREAD), PipSize, SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MIN),
               SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_STEP), SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MAX), (int)SymbolInfoInteger(_Symbol,SYMBOL_TRADE_MODE), EnumToString(mm),
               (int)AccountInfoInteger(ACCOUNT_TRADE_MODE), AccountInfoString(ACCOUNT_CURRENCY), (int)AccountInfoInteger(ACCOUNT_LEVERAGE), (int)Entry_Strategy, O12EntryName((int)Entry_Strategy),
               GlobalGrid_OrdersPerGroup, GlobalGrid_BreakoutDistanceUSD, StringLen(GlobalGrid_LocalDistancesPips));
   if(mm!=ACCOUNT_MARGIN_MODE_RETAIL_HEDGING)
      PrintFormat("V38 STARTUP DIAG WARNING | account margin mode %s is not RETAIL_HEDGING: this EA keeps BUY and SELL positions of one symbol at the same time and was verified on hedging accounts only (log only, nothing is changed)", EnumToString(mm));
}

// [RSI SAFETY R2] ===== terminal glue of [RSI2 CORE] (S01..S04): broker / restored-state evidence, PROTECTIVE_ONLY logs, RPA tick without a NEW rebase
// EA exposure on the symbol: positions of Magic, positions of DDLock_HedgeMagic, working orders of either magic
void Rsi2Exposure(int &eaPos, int &hedgePos, int &orders)
{
   eaPos = CountPositions(); hedgePos = 0; orders = 0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      const ulong t = PositionGetTicket(i);
      if(t == 0 || PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
      if((ulong)PositionGetInteger(POSITION_MAGIC) == DDLock_HedgeMagic) hedgePos++;
   }
   for(int k = OrdersTotal() - 1; k >= 0; k--)
   {
      const ulong t = OrderGetTicket(k);
      if(t == 0 || OrderGetString(ORDER_SYMBOL) != _Symbol) continue;
      const ulong mg = (ulong)OrderGetInteger(ORDER_MAGIC);
      if(mg == Magic || mg == DDLock_HedgeMagic) orders++;
   }
}
// what the restored state still has to reconcile / own (read only): "" = nothing
string Rsi2PendingText()
{
   string w = "";
   if(g_seRec.st != 0) w += StringFormat("entry request without a broker result (L%d order %I64u); ", g_seRec.cnt, g_seRec.ord);
   if(MrPendingCount() > 0) w += StringFormat("%d manual-recovery record(s) to reconcile; ", MrPendingCount());
   if(MrSurplusInFlight()) w += "surplus close request in flight; ";
   if(DdlActive()) w += "DD lock state " + DdlStateName(g_ddlState) + "; ";
   if(ExActive()) w += "basket exit in progress; ";
   if(PairPendingAny()) w += StringFormat("pending legacy PairClose leg(s) %I64u / %I64u; ", g_pairPend1, g_pairPend2);
   if(g_rpState == RPA_ST_REBASING) w += "RPA rebase committed (closes in progress); ";
   if(g_authOwnerReq) w += "OWNER_REQUIRED: " + g_authOwnerWhy + "; ";
   return w;
}
// S01: persisted records of an OPEN cycle of this EA identity, read BEFORE RestoreState (which clears them when the broker list is empty): cycle state, cycle latch,
// level book, RPA, GLOBAL groups, basket exit, session rescue, exit trend. "" = none (read only; identity unknown -> "" and the decision is PROTECTIVE anyway)
string Rsi2OpenCycleRecords()
{
   if(!OfhIdReady()) return "";
   string ns[8], nm[8]; int cnt[8]; ArrayInitialize(cnt, 0);
   ns[0] = CycNs(); nm[0] = "cycle state";   ns[1] = ClNs();  nm[1] = "cycle latch";   ns[2] = LbNs();   nm[2] = "level book";   ns[3] = RpaNs();   nm[3] = "RPA";
   ns[4] = GgNs();  nm[4] = "GLOBAL groups"; ns[5] = ExNs();  nm[5] = "basket exit";   ns[6] = SessNs(); nm[6] = "session rescue"; ns[7] = ExitNs(); nm[7] = "exit trend";
   for(int i = GlobalVariablesTotal() - 1; i >= 0; i--)
   {
      const string g = GlobalVariableName(i);
      for(int k = 0; k < 8; k++) if(StringFind(g, ns[k]) == 0) { cnt[k]++; break; }
   }
   string w = "";
   for(int k = 0; k < 8; k++) if(cnt[k] > 0) w += StringFormat("%s %s (%d keys); ", nm[k], ns[k], cnt[k]);
   return w;
}
// S01: OnInit after RestoreState() with RSI_Period < 2 -> RSI2_INIT_REJECT (CONFIG ERROR, refused) or RSI2_INIT_PROTECTIVE (g_rsiProt = true)
int Rsi2InitInvalidRsi(const string openRecBeforeRestore)
{
   const bool restored = !v38RestorePending;   // the restore ran (account known); otherwise it waits for the first tick with an account
   const bool connected = (bool)MQLInfoInteger(MQL_TESTER) || TerminalInfoInteger(TERMINAL_CONNECTED) != 0;   // the position / order lists are the broker's
   int eaPos = 0, hedgePos = 0, wo = 0;
   if(restored) Rsi2Exposure(eaPos, hedgePos, wo);
   string pend = restored ? Rsi2PendingText() : "";
   if(restored && (g_mrrLateOrdN > 0 || g_mrrLateUnknown)) pend += StringFormat("late-fill watch of the finalized cycle (%d order(s)%s); ", g_mrrLateOrdN, g_mrrLateUnknown ? " + an entry without result" : "");
   if(openRecBeforeRestore != "") pend += "records of an OPEN cycle at the last stop: " + openRecBeforeRestore;
   const int dec = Rsi2InitDecision(false, restored && connected, eaPos, hedgePos, wo, pend != "");
   if(dec == RSI2_INIT_REJECT)
   {
      PrintFormat("V38 CONFIG ERROR: RSI_Period must >= 2 (RSI_Period=%d) | the L1 signal is a multi-level RSI (MT5 iRSI period 1 = 0.0 on every closed bar -> BUY-only L1) | account flat for the EA (proven: account known, restored, connected): Magic %I64u / hedge %I64u positions 0, working orders 0, nothing to reconcile, no record of an open cycle -> the EA is not started (no RSI handle, never replaced by 5, no L1)",
                  RSI_Period, Magic, DDLock_HedgeMagic);
      return dec;
   }
   g_rsiProt = true;
   PrintFormat("V38 CONFIG ERROR: RSI_Period must >= 2 (RSI_Period=%d) -> PROTECTIVE_ONLY | %s | EA positions %d, hedge positions %d, working orders %d | to reconcile: %s | no RSI handle, never replaced by 5 | BLOCKED: new L1, grid level (V26 / GLOBAL group / RPA subgrid), new PairClose pair / RPA rebase, any Magic entry order, manual re-entry | RUNS: restore + reconciliation, DD Hedge Lock, T1 / T2 + broker SL / TP, exits / session close, committed closes | flat -> old cycle finalized, stays blocked until the Owner sets RSI_Period >= 2",
               RSI_Period, !restored ? "account not known yet: restore on the first tick with an account (ownership not guessed)" : (connected ? "account known, state restored, connected" : "account known, state restored, terminal NOT connected: the broker lists are not proven"),
               eaPos, hedgePos, wo, pend == "" ? "none" : pend);
   return dec;
}
// S04 log: blocked action, once per action and BasketCycleID (counter every time)
void Rsi2Blocked(const int act, const string detail)
{
   g_rsiBlk[(act >= 1 && act <= 6) ? act : 0]++;
   const string key = StringFormat("|%d_%I64d|", act, g_cycStartMsc);
   if(StringFind(g_rsiBlkKeys, key) >= 0) return;
   if(StringLen(g_rsiBlkKeys) > 4000) g_rsiBlkKeys = "";
   g_rsiBlkKeys += key;
   PrintFormat("PROTECTIVE_ONLY BLOCKED | %s | %s | RSI_Period=%d < 2 (CONFIG ERROR): no new exposure / structure until the Owner sets RSI_Period >= 2 (the EA re-initialises and restores)", Rsi2ActName(act), detail, RSI_Period);
}
// S03 / S04: phase of PROTECTIVE_ONLY, logged at every change (end of OnInit / every tick); nothing when RSI_Period >= 2
void Rsi2Tick()
{
   if(!g_rsiProt) return;
   const bool known = !v38RestorePending;
   int eaPos = 0, hedgePos = 0, wo = 0;
   if(known) Rsi2Exposure(eaPos, hedgePos, wo);
   const string pend = known ? Rsi2PendingText() : "";
   const int ph = Rsi2Phase(true, known, eaPos, hedgePos, wo, pend != "");
   if(ph == g_rsiPhase) return;
   g_rsiPhaseChanges++;
   PrintFormat("PROTECTIVE_ONLY STATE | %s -> %s | EA positions %d, hedge positions %d, working orders %d | to reconcile: %s | %s",
               Rsi2PhaseName(g_rsiPhase), Rsi2PhaseName(ph), eaPos, hedgePos, wo, pend == "" ? "none" : pend,
               ph == RSI2_PH_FLAT_BLOCKED ? StringFormat("old BasketCycleID finalized, nothing in flight: NO new L1 while RSI_Period=%d < 2 (Owner: set RSI_Period >= 2)", RSI_Period)
               : (ph == RSI2_PH_MANAGING ? "protective management only (DD / T1 / T2 / exits / reconciliation), no new exposure"
               : (ph == RSI2_PH_RECONCILING ? "flat for the EA, waiting for the broker results / records above (no new request)" : "account not known: nothing decided, nothing sent")));
   g_rsiPhase = ph;
}
void Rsi2PrintCounters(const string when)
{
   if(!g_rsiProt) return;
   PrintFormat("RSI SAFETY R2 COUNTERS %s | PROTECTIVE_ONLY (RSI_Period=%d) | phase %s, changes %I64d | ticks where the gate stopped: new L1 %I64d, grid level %I64d, new pair %I64d, new rebase %I64d | entry backstop (must stay 0) %I64d",
               when, RSI_Period, Rsi2PhaseName(g_rsiPhase), g_rsiPhaseChanges, g_rsiBlk[RSI2_ACT_NEW_L1], g_rsiBlk[RSI2_ACT_GRID_LEVEL], g_rsiBlk[RSI2_ACT_PAIR_DECISION], g_rsiBlk[RSI2_ACT_RPA_REBASE], g_rsiBlk[RSI2_ACT_ENTRY_ORDER]);
}
// S02 (PairClose_Mode 1 in PROTECTIVE_ONLY): RpaTick WITHOUT its last step RpaTryRebase - a committed rebase is finished (closes only) and a HALTED cycle reconciled
// exactly as RpaTick does; no NEW rebase (new Lk* / SubGridEpoch). Text = RpaTick except the last line (checked by tools\static_rsi2.py).
bool Rsi2RpaTickNoRebase(const int total)
{
   if(total <= 0) return false;
   RpaEnsureCycle(total);
   if(!RpaCycleOk()) return false;
   if(g_rpState == RPA_ST_HALTED)
   {
      RpaResolveAll();
      return true;
   }
   if(g_rpState == RPA_ST_REBASING) { RpaPump(); return true; }
   if(g_rpState == RPA_ST_SUBGRID) RpaSyncSubgrid();
   if(g_rpState == RPA_ST_HALTED) return true;
   if(g_rpState == RPA_ST_ORIGINAL || g_rpState == RPA_ST_SUBGRID) Rsi2Blocked(RSI2_ACT_RPA_REBASE, StringFormat("RPA cycle %I64d epoch %d %s: no NEW rebase is evaluated", g_rpCyc, g_rpEpoch, RpaStateName(g_rpState)));
   return false;
}

// [STARTUP SAFETY R3] ===== terminal glue of [SU3 CORE] (U01 / U02). Read only: no request, no persisted record written or deleted.
// deal-history evidence: positions opened on _Symbol by Magic / DDLock_HedgeMagic (IN deal) whose closing volume (OUT / OUT_BY / INOUT of the same position id,
// any deal magic: a terminal close of an EA position may carry magic 0) is incomplete = OPEN by the history; the latest such IN deal (coverage of a cycle start)
struct Su3Hist { bool ok; int deals; int openIds; int openUnlisted; ulong unlisted[8]; long latestOurInMsc; };
bool Su3PosListed(const ulong posId)
{
   for(int i = PositionsTotal() - 1; i >= 0; i--) { const ulong t = PositionGetTicket(i); if(t != 0 && (ulong)PositionGetInteger(POSITION_IDENTIFIER) == posId) return true; }
   return false;
}
void Su3HistoryScan(Su3Hist &h)
{
   h.ok = false; h.deals = 0; h.openIds = 0; h.openUnlisted = 0; h.latestOurInMsc = 0;
   if(!HistorySelect(0, D'2100.01.01')) return;   // the whole history (no dependence on the server time of a terminal that is still synchronising)
   h.ok = true; h.deals = HistoryDealsTotal();
   const double eps = Ex38Step() * 0.5;
   ulong id[]; double vol[]; int n = 0;   // open set: few ids at any time (the open positions of the EA), deals in time order
   for(int i = 0; i < h.deals; i++)
   {
      const ulong d = HistoryDealGetTicket(i);   // ticket of the selected list (no HistoryDealSelect inside the scan, MRR R1 M07)
      if(d == 0 || HistoryDealGetString(d, DEAL_SYMBOL) != _Symbol) continue;
      const long entry = HistoryDealGetInteger(d, DEAL_ENTRY);
      const ulong pid = (ulong)HistoryDealGetInteger(d, DEAL_POSITION_ID);
      const double v = HistoryDealGetDouble(d, DEAL_VOLUME);
      if(entry == DEAL_ENTRY_IN)
      {
         const ulong mg = (ulong)HistoryDealGetInteger(d, DEAL_MAGIC);
         if(mg != Magic && mg != DDLock_HedgeMagic) continue;
         const long ms = HistoryDealGetInteger(d, DEAL_TIME_MSC); if(ms > h.latestOurInMsc) h.latestOurInMsc = ms;
         int k = -1; for(int j = 0; j < n; j++) if(id[j] == pid) { k = j; break; }
         if(k < 0) { ArrayResize(id, n + 1, 64); ArrayResize(vol, n + 1, 64); id[n] = pid; vol[n] = 0.0; k = n; n++; }
         vol[k] += v;
      }
      else if(entry == DEAL_ENTRY_OUT || entry == DEAL_ENTRY_OUT_BY || entry == DEAL_ENTRY_INOUT)
      {
         for(int j = 0; j < n; j++)
            if(id[j] == pid) { vol[j] -= v; if(vol[j] <= eps) { id[j] = id[n - 1]; vol[j] = vol[n - 1]; n--; ArrayResize(id, n, 64); ArrayResize(vol, n, 64); } break; }
      }
   }
   h.openIds = n;
   for(int j = 0; j < n; j++) if(!Su3PosListed(id[j])) { if(h.openUnlisted < 8) h.unlisted[h.openUnlisted] = id[j]; h.openUnlisted++; }
}
// records of an OPEN cycle of this identity (before any restore): CycleState with positions (n / st, tickets k*), cycle latch, level book, RPA, GLOBAL groups, basket
// exit, session rescue, exit trend; the cycle start (CycleState st, else latch / level book / RPA cycle id)
struct Su3Rec { bool any; string names; long cycStart; int nk; ulong tk[40]; };
void Su3Records(Su3Rec &r)
{
   r.any = false; r.names = ""; r.cycStart = 0; r.nk = 0;
   const string c = CycNs();
   if(GlobalVariableCheck(c + "n") && (GlobalVariableGet(c + "n") >= 1.0 || GlobalVariableGet(c + "st") > 0.0))
   {
      r.any = true; r.cycStart = (long)GlobalVariableGet(c + "st");
      r.nk = (int)MathMin(40.0, MathMax(0.0, GlobalVariableGet(c + "nk")));
      for(int k = 0; k < r.nk; k++) r.tk[k] = (ulong)GlobalVariableGet(c + "k" + IntegerToString(k));
      r.names += StringFormat("cycle state %s (%d positions, %d tickets, start %I64d); ", c, (int)GlobalVariableGet(c + "n"), r.nk, r.cycStart);
   }
   string ns[7], nm[7]; int cnt[7]; ArrayInitialize(cnt, 0);
   ns[0] = ClNs();  nm[0] = "cycle latch";   ns[1] = LbNs(); nm[1] = "level book"; ns[2] = RpaNs();  nm[2] = "RPA";            ns[3] = GgNs(); nm[3] = "GLOBAL groups";
   ns[4] = ExNs();  nm[4] = "basket exit";   ns[5] = SessNs(); nm[5] = "session rescue"; ns[6] = ExitNs(); nm[6] = "exit trend";
   for(int i = GlobalVariablesTotal() - 1; i >= 0; i--)
   {
      const string g = GlobalVariableName(i);
      for(int k = 0; k < 7; k++) if(StringFind(g, ns[k]) == 0) { cnt[k]++; break; }
   }
   for(int k = 0; k < 7; k++) if(cnt[k] > 0) { r.any = true; r.names += StringFormat("%s %s (%d keys); ", nm[k], ns[k], cnt[k]); }
   if(r.cycStart <= 0 && cnt[0] > 0 && GlobalVariableCheck(ns[0] + "cyc")) r.cycStart = (long)GlobalVariableGet(ns[0] + "cyc");
   if(r.cycStart <= 0 && cnt[1] > 0 && GlobalVariableCheck(ns[1] + "cy"))  r.cycStart = (long)GlobalVariableGet(ns[1] + "cy");
   if(r.cycStart <= 0 && cnt[2] > 0 && GlobalVariableCheck(ns[2] + "cyc")) r.cycStart = (long)GlobalVariableGet(ns[2] + "cyc");
}
// every recorded ticket: listed (an open position of Magic on _Symbol) or proven closed by its own deals (IN volume > 0, closing volume >= IN volume)
int Su3RecordedProven(const Su3Rec &r, string &unknown)
{
   unknown = ""; int ok = 0;
   const double eps = Ex38Step() * 0.5;
   for(int k = 0; k < r.nk; k++)
   {
      const ulong t = r.tk[k];
      if(OfhTicketIsOurs(t, Magic)) { ok++; continue; }
      double vin = 0.0, vout = 0.0;
      if(t != 0 && HistorySelectByPosition(t))
         for(int i = HistoryDealsTotal() - 1; i >= 0; i--)
         {
            const ulong d = HistoryDealGetTicket(i); if(d == 0) continue;
            const long e = HistoryDealGetInteger(d, DEAL_ENTRY);
            if(e == DEAL_ENTRY_IN) vin += HistoryDealGetDouble(d, DEAL_VOLUME);
            else if(e == DEAL_ENTRY_OUT || e == DEAL_ENTRY_OUT_BY || e == DEAL_ENTRY_INOUT) vout += HistoryDealGetDouble(d, DEAL_VOLUME);
         }
      if(vin > 0.0 && vout >= vin - eps) ok++;
      else unknown += StringFormat("%I64u(in %.2f out %.2f) ", t, vin, vout);
   }
   return ok;
}
// U01: the verdict of this moment (U02: logged when the evidence changes)
int Su3Evaluate(const string where)
{
   g_su3Evals++;
   const bool idOk = OfhIdReady();
   const bool conn = (bool)MQLInfoInteger(MQL_TESTER) || TerminalInfoInteger(TERMINAL_CONNECTED) != 0;
   int eaPos = 0, hedgePos = 0, wo = 0;
   Rsi2Exposure(eaPos, hedgePos, wo);
   const bool listsEmpty = (PositionsTotal() == 0 && OrdersTotal() == 0);
   const double margin = AccountInfoDouble(ACCOUNT_MARGIN);
   const double floating = AccountInfoDouble(ACCOUNT_EQUITY) - AccountInfoDouble(ACCOUNT_BALANCE) - AccountInfoDouble(ACCOUNT_CREDIT);
   const bool acctExp = (margin > 0.0 || MathAbs(floating) > 0.005);
   Su3Hist h; h.ok = false; h.deals = 0; h.openIds = 0; h.openUnlisted = 0; h.latestOurInMsc = 0;
   Su3Rec r; r.any = false; r.names = ""; r.cycStart = 0; r.nk = 0;
   int proven = 0; string unk = "";
   if(idOk && conn) { Su3HistoryScan(h); Su3Records(r); proven = Su3RecordedProven(r, unk); }
   const bool covers = (r.cycStart > 0 && h.latestOurInMsc >= r.cycStart - 60000);   // the IN deal of the cycle's L1 is in the history
   const int v = Su3Verdict(idOk, conn, eaPos, hedgePos, listsEmpty, acctExp, h.openUnlisted, r.any, r.nk, proven, r.cycStart > 0, covers);
   string ul = ""; for(int i = 0; i < MathMin(h.openUnlisted, 8); i++) ul += StringFormat("%I64u ", h.unlisted[i]);
   const string ev = StringFormat("identity %s | connected %d | EA positions %d, hedge %d, EA orders %d | account positions %d orders %d margin %.2f floating %.2f | history %s: %d deals, EA / hedge positions open %d, open but NOT listed %d [%s] | open-cycle records: %s | recorded tickets %d: listed or proven closed %d%s",
                                 idOk ? OfhIdText(Magic) : "UNKNOWN", conn ? 1 : 0, eaPos, hedgePos, wo, PositionsTotal(), OrdersTotal(), margin, floating, h.ok ? "read" : "NOT read", h.deals, h.openIds,
                                 h.openUnlisted, ul, r.any ? r.names : "none", r.nk, proven, unk == "" ? "" : " | NOT proven: " + unk);
   if(v != g_su3Verdict || ev != g_su3LastLog)
   {
      PrintFormat("STARTUP SYNC | %s (%s) | %s | %s", Su3Name(v), where, ev,
                  Su3MayRestore(v) ? "-> the normal restore runs now" : (v == SU3_OWNER_REQUIRED ? "-> OWNER_REQUIRED: records of an open cycle cannot be checked; RESTORE_PENDING kept (no reset, no record deleted, no L1 / grid) until the Owner resolves it" : "-> RESTORE_PENDING: no reset, no record deleted or written, no L1 / grid / decision; evaluated again on the next tick / deal"));
      g_su3LastLog = ev;
   }
   g_su3Verdict = v;
   if(v == SU3_OWNER_REQUIRED) g_su3Owner++; else if(!Su3MayRestore(v)) g_su3Waits++;
   return v;
}
// U01: the deferred restore. true = restored (or nothing pending). The NORMAL restore (RestoreState) runs only on a proven verdict; otherwise v38RestorePending stays.
bool Su3TryRestore(const string where, const bool force)
{
   if(!v38RestorePending) return true;
   if(!force && TimeCurrent() == g_su3LastEval) return false;   // throttle of the history scan (not a proof): at most once per server second, and on every deal
   g_su3LastEval = TimeCurrent();
   const int v = Su3Evaluate(where);
   if(!Su3MayRestore(v)) return false;
   RestoreState();
   if(v38RestorePending) return false;                           // identity lost meanwhile (V38RestoreModules deferred again)
   if(v == SU3_RESTORE_EXPOSURE) g_su3RestExp++; else g_su3RestFlat++;
   if(where != "INIT") ExitInit();                               // exit-trend handles from the restored cycle latch (OnInit calls ExitInit itself)
   PrintFormat("STARTUP SYNC RESTORED | %s (%s) | EA positions %d | BasketCycleID %I64d | the persisted state is restored by the normal restore", Su3Name(v), where, CountPositions(), g_cycStartMsc);
   return true;
}
void Su3PrintCounters(const string when)
{
   PrintFormat("STARTUP SAFETY R3 COUNTERS %s | evaluations %I64d | waits %I64d | OWNER_REQUIRED %I64d | restored with exposure %I64d, flat proven %I64d | last verdict %s | restore pending %d",
               when, g_su3Evals, g_su3Waits, g_su3Owner, g_su3RestExp, g_su3RestFlat, g_su3Verdict < 0 ? "-" : Su3Name(g_su3Verdict), v38RestorePending ? 1 : 0);
}

//+------------------------------------------------------------------+
// Khởi tạo EA: gắn magic, tính pip XAU, tạo RSI, khôi phục cụm nếu chart còn lệnh.


bool SyncSettingsFromCloud();

//+------------------------------------------------------------------+
// Khởi tạo EA: gắn magic, tính pip XAU, tạo RSI, khôi phục cụm nếu chart còn lệnh.
int OnInit()
{
   InitGlobalInputsFromLocal();
   IsApiAllowed = SyncSettingsFromCloud();
   if(!IsApiAllowed)
   {
      Print("API CLOUD WARNING: License check failed or bot disabled. Bot is in standby mode.");
   }

   trade.SetExpertMagicNumber(Magic);
   trade.SetAsyncMode(false);
   PipSize = GetPipSize();
   Ic38StartupDiag();   // [INPUT CLEANUP R1] IC3: log only
   // [RSI SAFETY R2] S01: RSI_Period < 2 (L1RSI R1 R02 refused here, also with an open basket) -> NO iRSI handle and no refusal HERE: the decision needs the restored
   // state + the broker and is taken right after RestoreState() below (refused when flat / PROTECTIVE_ONLY with exposure); the period is never replaced by a default.
   // Globals survive a re-initialisation after an input change (MT5): the mode is set again on every OnInit.
   const bool rsiPeriodOk=L1Rsi38PeriodValid(RSI_Period);
   g_rsiProt=false; g_rsiPhase=RSI2_PH_NORMAL; g_rsiBlkKeys=""; ArrayInitialize(g_rsiBlk, 0); g_rsiPhaseChanges=0;
   hRSI=INVALID_HANDLE;
   if(rsiPeriodOk)
   {
      ResetLastError();    // [INPUT CLEANUP R1] IC3: the error code printed for a failed RSI handle is the one of iRSI (no decision reads _LastError here)
      hRSI    = iRSI(_Symbol, RSI_TF, RSI_Period, PRICE_CLOSE);
      if(hRSI == INVALID_HANDLE) { const int rsiErr=GetLastError(); PrintFormat("V38 CONFIG ERROR | RSI init failed: iRSI(%s, %s, %d) error %d - the EA is not started", _Symbol, EnumToString(RSI_TF), RSI_Period, rsiErr); return INIT_FAILED; }   // [INPUT CLEANUP R1] IC3: + error code
      ArraySetAsSeries(rsiVal, true);
   }
   const string sessErr=SessInputsError();
   if(sessErr!="")
   {
      PrintFormat("V38 CONFIG ERROR | sessions: %s", sessErr);
      return INIT_PARAMETERS_INCORRECT;
   }
   // [SAFETY S07] inputs the HOTFIX OnInit did not check (Atlas F11); OnDeinit(REASON_INITFAILED) writes no record (S08), so an open basket keeps its records
   {
      double gs[25];
      gs[0]=G1;   gs[1]=G2;   gs[2]=G3;   gs[3]=G4;   gs[4]=G5;   gs[5]=G6;   gs[6]=G7;   gs[7]=G8;   gs[8]=G9;   gs[9]=G10;
      gs[10]=G11; gs[11]=G12; gs[12]=G13; gs[13]=G14; gs[14]=G15; gs[15]=G16; gs[16]=G17; gs[17]=G18; gs[18]=G19; gs[19]=G20;
      gs[20]=G21; gs[21]=G22; gs[22]=G23; gs[23]=G24; gs[24]=G25;
      const string safErr=Saf38InputsError(Magic, Initial_Lot, Lot_Multi, gs, 25, TP_Pips, ServerGMT, LocalGMT);
      if(safErr!="")
      {
         PrintFormat("V38 CONFIG ERROR | %s - the EA is not started (SAFETY S07); the records of an open basket are kept untouched", safErr);
         return INIT_PARAMETERS_INCORRECT;
      }
   }
   // OWNER12 (Owner mục 1): kiểu vào lệnh chỉ 0 / 1; SET cũ còn khóa bool Enable_GlobalGridAIPro → phải cùng nghĩa, khác / không đọc được → không khởi động
   const int o12mig=O12MigrationCheck((int)Entry_Strategy, Enable_GlobalGridAIPro);
   if(o12mig<0)
   {
      PrintFormat("V38 CONFIG ERROR | Entry_Strategy=%d (%s) | legacy key Enable_GlobalGridAIPro='%s' | %s - the EA is not started (0 = V26 traditional, 1 = GLOBAL Grid Mode 1 only; an old SET must set Entry_Strategy explicitly and drop the bool key)",
                  (int)Entry_Strategy, O12EntryName((int)Entry_Strategy), Enable_GlobalGridAIPro, O12MigrationName(o12mig));
      return INIT_PARAMETERS_INCORRECT;
   }
   if(o12mig==O12M_CONSISTENT)
      PrintFormat("V38 MIGRATION | legacy key Enable_GlobalGridAIPro='%s' agrees with Entry_Strategy=%s - remove the old key from the SET", Enable_GlobalGridAIPro, O12EntryName((int)Entry_Strategy));
   // [DPMR R1] D01: PairClose mode 0 / 1 only (fail closed: no default replaces a wrong value)
   if(!Dpmr38ModeValid((int)PairClose_Mode))
   {
      PrintFormat("V38 CONFIG ERROR | PairClose_Mode=%d must be 0 (V26_LEGACY_PAIR_CLOSE) or 1 (V38_RECURSIVE_PAIR_A) - the EA is not started", (int)PairClose_Mode);
      return INIT_PARAMETERS_INCORRECT;
   }
   // OWNER12 (Owner mục 2): T1 kích hoạt BE ± Khoang_Doi_SL, khóa BE ± So_Pip_Doi_SL (phải nằm giữa BE và mức kích hoạt), T2 cách giá Khoang_Trailing_SL (pip)
   if(!O12T1T2Valid(Khoang_Doi_SL, So_Pip_Doi_SL, Khoang_Trailing_SL) || ConfirmFromOrder<2)
   {
      PrintFormat("V38 CONFIG ERROR | T1/T2: Khoang_Doi_SL=%.1f > 0, 0 <= So_Pip_Doi_SL=%.1f < Khoang_Doi_SL, Khoang_Trailing_SL=%.1f > 0 (pip) | ConfirmFromOrder=%d >= 2", Khoang_Doi_SL, So_Pip_Doi_SL, Khoang_Trailing_SL, ConfirmFromOrder);
      return INIT_PARAMETERS_INCORRECT;
   }
   // OWNER12 (Owner mục 3): ngưỡng lỗ kinh tế chu kỳ đã có PairClose
   if(CloseProtect_MaxOrders<0 || CloseProtect_PairACycleMaxLossPct<0.0 || CloseProtect_PairACycleMaxLossPct>=100.0)
   {
      PrintFormat("V38 CONFIG ERROR | session close: CloseProtect_MaxOrders=%d >= 0, CloseProtect_PairACycleMaxLossPct=%.3f in [0, 100)", CloseProtect_MaxOrders, CloseProtect_PairACycleMaxLossPct);
      return INIT_PARAMETERS_INCORRECT;
   }
   // OWNER12 (Owner mục 7): DD bật thì ngưỡng phải do Owner nhập (không mặc định 30)
   if(Bat_Cat_DD && (Cat_DD_PhanTram<=0.0 || Cat_DD_PhanTram>=100.0))
   {
      PrintFormat("V38 CONFIG ERROR | DD Hedge Lock ON needs an Owner threshold: Cat_DD_PhanTram=%.2f must be in (0, 100) - there is no implicit 30%%", Cat_DD_PhanTram);
      return INIT_PARAMETERS_INCORRECT;
   }
   if(Entry_Strategy==OFH38_ENTRY_GLOBAL && (!Gg38ConfigOk(GlobalGrid_OrdersPerGroup, Max_Orders) || GlobalGrid_BreakoutDistanceUSD<0.0 || !MathIsValidNumber(GlobalGrid_BreakoutDistanceUSD)))
   {
      PrintFormat("V38 CONFIG ERROR | GLOBAL Grid: GlobalGrid_OrdersPerGroup=%d must be 2..Max_Orders=%d, GlobalGrid_BreakoutDistanceUSD=%s must be a finite number >= 0",
                  GlobalGrid_OrdersPerGroup, Max_Orders, Gg38Num(GlobalGrid_BreakoutDistanceUSD));
      return INIT_PARAMETERS_INCORRECT;
   }
   if(Max_Orders<1 || Max_Orders>LB38_MAX-4)
   {
      PrintFormat("V38 CONFIG ERROR | Max_Orders=%d must be 1..%d", Max_Orders, LB38_MAX-4);
      return INIT_PARAMETERS_INCORRECT;
   }
   // [GLOBAL GEN] G02: GLOBAL internal distance list — checked only when GLOBAL is the entry strategy (V26 never reads it). Fail closed: no G1..G25 fallback, no default.
   if(Entry_Strategy==OFH38_ENTRY_GLOBAL)
   {
      double ld[]; int bad=0;
      const int n=Gg38LdParse(GlobalGrid_LocalDistancesPips, ld, bad);
      const int req=Gg38LdRequired(GlobalGrid_OrdersPerGroup, Max_Orders);
      const int c=Gg38LdCheck(n, req);
      if(c!=GG38_LD_OK || req>GG38_LD_MAX)
      {
         PrintFormat("V38 CONFIG ERROR | GLOBAL Grid: GlobalGrid_LocalDistancesPips='%s' (%d characters) -> %s%s | K=%d Max_Orders=%d need at least %d distances (largest group: original grid %d internal positions, subgrid epoch %d) | format: numbers >= 0 in pip, '.' decimal, separated by ',' or by ';' (not both), at most %d characters - the EA is not started (no fallback to G1..G25)",
                     GlobalGrid_LocalDistancesPips, StringLen(GlobalGrid_LocalDistancesPips), Gg38LdErrName(c), c==GG38_LD_SHORT?StringFormat(" (%d given)", n):(bad>0?StringFormat(" (element %d)", bad):""), GlobalGrid_OrdersPerGroup, Max_Orders, req,
                     Gg38MaxInternal(GlobalGrid_OrdersPerGroup, Max_Orders), Gg38MaxInternal(GlobalGrid_OrdersPerGroup, Max_Orders+1), GG38_LD_TEXT_MAX);
         return INIT_PARAMETERS_INCORRECT;
      }
   }
   // RECURSIVE PAIR_A REBASE V1 (Owner 31/10/2026 §1 / §2): domain checks fail closed (the EA does not start on a wrong value, nothing is replaced by a default)
   {
      string rpErr="";
      if(OriginalPairCloseStartOrder<2 || OriginalPairCloseStartOrder>Max_Orders) rpErr=StringFormat("OriginalPairCloseStartOrder=%d must be 2..Max_Orders=%d", OriginalPairCloseStartOrder, Max_Orders);
      else if(RecursiveRebaseTargetLevel<1 || RecursiveRebaseTargetLevel>Max_Orders) rpErr=StringFormat("RecursiveRebaseTargetLevel=%d must be 1..Max_Orders=%d (a level of the original template)", RecursiveRebaseTargetLevel, Max_Orders);
      else if(PairA_PfStressUSD<0 || PairA_PfMaxStressLossPct<0 || PairA_PfMaxStressLossPct>100 || PairA_PfMinMarginLevelPct<0) rpErr="risk gates: PairA_PfStressUSD / PairA_PfMinMarginLevelPct >= 0, PairA_PfMaxStressLossPct in [0, 100]";
      else if(PairA_CloseCostPerLotUSD<0 || PairA_SlipReservePoints<0) rpErr="cost / slippage reserve must be >= 0";
      if(rpErr!="")
      {
         PrintFormat("V38 CONFIG ERROR | RECURSIVE PAIR_A REBASE: %s - the EA is not started on a wrong configuration", rpErr);
         return INIT_PARAMETERS_INCORRECT;
      }
      // CONFIG FEASIBILITY (reported; enforced per cycle): TargetLot of Lk* for an L1 BUY / SELL, subgrid ladder j = 0..GridMaxOrders against the broker limits
      const double st=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_STEP), mn=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MIN), mx=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MAX);
      double bb=0.0, bs=0.0, tl=0.0; int sd=0;
      const int tc=Rpa38Template(Initial_Lot, Lot_Multi, RecursiveRebaseTargetLevel, true, st, mn, mx, bb, bs, tl, sd);
      int jMax=-1; for(int j=0; j<=Max_Orders; j++) { const double l=Rpa38SubLot(tl, j, st); if(mx>0.0 && l>mx+1e-9) break; jMax=j; }
      PrintFormat("V38 RPA CONFIG FEASIBILITY | L1 BUY: L1..L%d BUY %.2f SELL %.2f -> Lk* = %s %.2f (%s); L1 SELL: mirror | subgrid lot = %.2f x %.2f^j (nearest step %.2f): j=1 %.2f, j=12 %.2f, j=%d %.2f | broker max %.2f -> j <= %d within VOLUME_MAX (%s) | OriginalPairCloseStartOrder %d | GridMaxOrders %d | PairClose after +%d",
                  RecursiveRebaseTargetLevel, bb, bs, sd>0?"BUY":(sd<0?"SELL":"NONE"), tl, Rpa38TplName(tc), tl, SUBGRID_MULTILOT, st, Rpa38SubLot(tl,1,st), Rpa38SubLot(tl,12,st), Max_Orders, Rpa38SubLot(tl,Max_Orders,st),
                  mx, jMax, jMax>=Max_Orders?"every additional order fits":"deeper additional orders are BLOCKED (no silent clamp)", OriginalPairCloseStartOrder, Max_Orders, SUBGRID_PAIRCLOSE_AFTER_ADDITIONAL_ORDERS);
      PrintFormat("V38 RPA R1 LOCAL GRID | Lk* = L%d* = LOCAL L1 of a new grid (k = lot template + label only) | local L2 (L%d*) step G1 = %.0f pip, L3 (L%d*) G2 = %.0f pip, L4 (L%d*) G3 = %.0f pip | double confirmation from local L%d (label L%d*) %s | PairClose of an epoch from local L%d (+%d) | last local level L%d (label L%d*) | anchor = decision-tick Bid / Ask (V26 L1 price rule)%s",
                  RecursiveRebaseTargetLevel, Rpa38DisplayLevel(RecursiveRebaseTargetLevel,2), GetStep(2)/PipSize, Rpa38DisplayLevel(RecursiveRebaseTargetLevel,3), GetStep(3)/PipSize, Rpa38DisplayLevel(RecursiveRebaseTargetLevel,4), GetStep(4)/PipSize,
                  ConfirmFromOrder, Rpa38DisplayLevel(RecursiveRebaseTargetLevel,ConfirmFromOrder), Enable_DoubleConfirmation?"ON":"OFF", 1+SUBGRID_PAIRCLOSE_AFTER_ADDITIONAL_ORDERS, SUBGRID_PAIRCLOSE_AFTER_ADDITIONAL_ORDERS,
                  1+Max_Orders, Rpa38DisplayLevel(RecursiveRebaseTargetLevel,1+Max_Orders),
                  Entry_Strategy==OFH38_ENTRY_GLOBAL?" | [GLOBAL GEN] GLOBAL Mode 1 selected: these G steps are NOT used, the subgrid follows the GLOBAL groups / GlobalGrid_LocalDistancesPips (see V38 GLOBAL GEN)":"");
      PrintFormat("V38 RPA R2 SHARED T1/T2 | one T1 / T2 for the original grid and every subgrid epoch: the lone Lk* of a reconciled epoch enters the SAME T1 (economic BE of the whole BasketCycleID +/- %.0f pip trigger, lock +/- %.0f pip = SL of the Lk* confirmed by the broker, no TP side) and T2 (trail %.0f pip) | original grid: L1 TP_Pips / %%YP and the two-side T1 / T2 unchanged | GLOBAL last group may be shorter than K, never above Max_Orders (subgrid last local L%d)",
                  Khoang_Doi_SL, So_Pip_Doi_SL, Khoang_Trailing_SL, 1+Max_Orders);
   }
   // P3: exit mode inputs
   if(Exit_Mode<EXIT_LEGACY || Exit_Mode>EXIT_T2_HYBRID || ExitTrend_EmaFast<1 || ExitTrend_EmaSlow<1 || ExitTrend_AtrPeriod<1 || ExitTrend_StrongScore<0.0 ||
      ExitHyb_FloorStartPips<0.0 || ExitHyb_FloorKeepPct<0.0 || ExitHyb_FloorKeepPct>100.0 || ExitHyb_AtrMultWeak<0.0 || ExitHyb_AtrMultStrong<0.0 ||
      ExitHyb_TrailMinPips<=0.0 || ExitHyb_TrailMaxPips<ExitHyb_TrailMinPips)
   {
      PrintFormat("V38 CONFIG ERROR | exit mode: Exit_Mode=%d (0..3), EMA / ATR periods >= 1, StrongScore >= 0, FloorKeepPct 0..100, ATR multipliers >= 0, 0 < TrailMin <= TrailMax", (int)Exit_Mode);
      return INIT_PARAMETERS_INCORRECT;
   }
   if(DDLock_HedgeMagic==Magic || DDLock_HedgeMagic==0 || DDLock_MaxAttempts<1 || DDLock_CompressionKeepGrossPct<0.0 || DDLock_CompressionKeepGrossPct>100.0)
   {
      PrintFormat("V38 CONFIG ERROR | DD Lock: DDLock_HedgeMagic=%I64u must differ from Magic=%I64u and be > 0 | DDLock_MaxAttempts=%d >= 1 | DDLock_CompressionKeepGrossPct=%.1f in 0..100",
                  DDLock_HedgeMagic, Magic, DDLock_MaxAttempts, DDLock_CompressionKeepGrossPct);
      return INIT_PARAMETERS_INCORRECT;
   }
   DdlInitTrade();
   SessSetup();
   ClReadInputs();   // PAIRA_LOOP: Input hiện tại (so với cấu hình đã chốt của chu kỳ đang mở khi khôi phục)
   const string rsiOpenRec = rsiPeriodOk ? "" : Rsi2OpenCycleRecords();   // [RSI SAFETY R2] S01: read BEFORE RestoreState (it clears them on an empty broker list)
   // [STARTUP SAFETY R3] U01: RestoreState() only on a PROVEN broker state; otherwise the restore stays pending (records kept, nothing reset / decided / sent)
   v38RestorePending=true;
   Su3TryRestore("INIT", true);
   // [RSI SAFETY R2] S01: RSI_Period < 2 -> decided on the RESTORED state + the broker (the restore above is the normal one: an open basket is never abandoned)
   if(!rsiPeriodOk && Rsi2InitInvalidRsi(rsiOpenRec)!=RSI2_INIT_PROTECTIVE) return INIT_PARAMETERS_INCORRECT;   // proven flat + nothing to reconcile: refused (OnDeinit writes no record, S08)
   ExitInit();       // TWO-PAIRCLOSE P3: chỉ báo xu hướng của chế độ thoát (giá trị đã chốt của chu kỳ đang mở, hoặc Input)
   RrInit();         // OWNER12: bộ ghi nghiên cứu (chỉ Strategy Tester + Research_Recorder)
   PrintFormat("Onefxhub v38.38 RECURSIVE PAIR_A REBASE V1-R2 + HOTFIX HALTED T1/T2 (base RPA V1-R2 5F761CAB: shared T1/T2 incl. the lone Lk* also in a reconciled HALTED cycle, true L1 subgrid reset, BE-tick anchor; old PairClose controllers removed) Init | pip=%.5f (1 gia=10 pip) | RSI=%s(%d) | L1 TP_Pips=%.0f YP=%.0f%% | T1 trigger BE +/- %.0f pip = %.2f price | T1 lock BE +/- %.0f pip = %.2f | T2 trail %.0f pip = %.2f | spread added to the L1 TP %s | CatDD=%s | TimeFilter=%s | %s GMT+%d (server GMT+%d) | ConfirmFrom=L%d | legacy PairClose = PairClose_Mode 0 (DPMR R1, see the next line)",
               PipSize, EnumToString(RSI_TF), RSI_Period, TP_Pips, Basket_TP_PhanTram,
               Khoang_Doi_SL, O12PipToPrice(Khoang_Doi_SL, PipSize), So_Pip_Doi_SL, O12PipToPrice(So_Pip_Doi_SL, PipSize), Khoang_Trailing_SL, O12PipToPrice(Khoang_Trailing_SL, PipSize),
               Bat_Cong_Spread_TP?"yes":"no",
               Bat_Cat_DD?StringFormat("%.2f%%", Cat_DD_PhanTram):"OFF",
               UseTimeFilter?"ON":"OFF(24/7)",
               SessDescribe(), LocalGMT, ServerGMT,
               ConfirmFromOrder);
   // [DPMR R1] D05 log: the PairClose mode in force (the line above keeps the RPA / MRR R1 text)
   PrintFormat("V38 DPMR R1 | DUAL PAIRCLOSE: PairClose_Mode input %s | open cycle %s | mode 0 = V26 PairClose (2 positions opened last, profit + swap >= %.2f USD, from %d positions, %s, %s) through the V38 execution layer, no Lk* / rebase | mode 1 = Recursive Pair_A (MRR R1 behaviour) | the two never run in one cycle | DD HALT after a DD Hedge Lock: released only by a verified Owner full manual close (broker flat, no working order / request in flight, every close of the episode manual; stop-out / EA / SL / TP close keeps the HALT)",
               PcModeName((int)PairClose_Mode), g_clHave ? StringFormat("latched %s%s", PcModeName(g_clPcMode), g_clFrozen ? " (FROZEN: " + g_clFrozenWhy + ")" : "") : "none (the next L1 latches the input)",
               PairClose_SoUSD, PairClose_TuLenh, PairClose_BatTat ? "ON" : "OFF", PairClose_ChotDanVe ? "several pairs per tick (ChotDanVe)" : "one pair per tick");
   if(UseTimeFilter && !Enable_Asia && !Enable_Europe && !Enable_US)
      Print("CANH BAO V38: UseTimeFilter=true nhung ca 3 phien deu TAT — khong bao gio mo L1 moi.");
   PrintFormat("V38 OWNER12 | entry strategy %s (latched per cycle: %s) | GLOBAL K=%d D=%.2f USD price (%d groups) | DoubleConfirm=%s from L%d | close window %d min: cycle without PairClose <=%d positions close + rest, >%d continue (rescue) | cycle with PairClose: %s | legacy bool CloseProtect_CloseProfitAboveMax REMOVED",
               O12EntryName((int)Entry_Strategy), g_clHave?(O12GlobalLatched()?"GLOBAL Grid Mode 1":"V26 traditional"):"no cycle", GlobalGrid_OrdersPerGroup, GlobalGrid_BreakoutDistanceUSD,
               Gg38GroupCount(MathMax(GlobalGrid_OrdersPerGroup,1), Max_Orders), Enable_DoubleConfirmation?"ON":"OFF", ConfirmFromOrder,
               MinBeforeClose, CloseProtect_MaxOrders, CloseProtect_MaxOrders,
               CloseProtect_UsePairACycleLossPct?StringFormat("close + rest when the economic P/L >= -%.3f%% x equity, else continue", CloseProtect_PairACycleMaxLossPct):"close + rest only at economic break-even or better (0%), else continue");
   // [GLOBAL GEN] G01 / G02 / G04: the GLOBAL rule in force (latched cycle, else the inputs)
   if(O12GlobalLatched())
   {
      const int gk=GgK();
      double cur[]; ArrayResize(cur, GgLdN()); for(int i=0; i<GgLdN(); i++) cur[i]=GgLd(i+1);
      PrintFormat("V38 GLOBAL GEN | GLOBAL Mode 1 (%s) | K=%d D=%s USD price | internal distances (pip, ABSOLUTE from each group anchor = local L1) LD1..LD%d = [%s] (input '%s', %d characters) | structure needs %d (original grid: largest group %d internal positions, subgrid epoch %d) | original L1..L%d groups %s | subgrid local L1..L%d groups %s | internal level: group anchor +/- LD[localIndex] x %.2f (PriceN) | breakout anchor [NPD R1]: BUY Ask >= highest open BUY of the previous group + D, SELL Bid <= lowest open SELL of the previous group - D on the price grid (point %g) | G1..G25 are NOT used by GLOBAL | cycle latch %s, older-build GLOBAL cycles frozen at restart %I64d",
                  g_clHave?"latched cycle":"inputs", gk, Gg38Num(GgD()), GgLdN(), Gg38LdText(cur, GgLdN()), GlobalGrid_LocalDistancesPips, StringLen(GlobalGrid_LocalDistancesPips), Gg38LdRequired(gk, Max_Orders),
                  Gg38MaxInternal(gk, Max_Orders), Gg38MaxInternal(gk, Max_Orders+1), Max_Orders, Gg38LayoutText(gk, Max_Orders), Max_Orders+1, Gg38LayoutText(gk, Max_Orders+1), PipSize, _Point,
                  g_clFrozen?g_clFrozenWhy:(g_clHave?"latched":"no cycle"), g_clLdLegacy);
   }
   else Print("V38 GLOBAL GEN | entry strategy V26 traditional: GlobalGrid_LocalDistancesPips is not read (not validated, not latched); G1..G25 / GetStep / GetTrigger unchanged");
   const string o12res=ClText();   // every latched field of the cycle (RPA inputs + shared economics / risk gates + strategy / ladder + exit mode)
   PrintFormat("V38 OWNER12 RESEARCH CONFIG | PairClose / exit research parameters (not Owner-approved values) %s | config hash %08X | internal constants: Exec confirm %d ms / %d attempts / stall %d min, exit CSV %s, V26 state persist %s, partial close freezes grid %s, strict lot check %s, re-entry reconcile %d s, DD attempts %d retry %d min deviation %d slip %d, OwnerAck %s",
               o12res, O12Fnv1a(o12res), Exec_ConfirmMs, Exec_MaxAttempts, Exec_StallRetryMinutes, Exit_LogCsv?"on":"off", V26State_Persist?"on":"off",
               ManualPartial_FreezeGrid?"on":"off", GridLot_StrictBrokerLimits?"on":"off", ManualReentry_ReconcileSec, DDLock_MaxAttempts, DDLock_RetryMinutes, DDLock_DeviationPoints, DDLock_CloseSlipPoints,
               DDLock_OwnerAckResume?"on":"off (not in the UI)");
   PrintFormat("V38 | DD action=%s at %.1f%% (V26 measurement) | HedgeMagic=%I64u | compression=%s keep %.1f%% gross | state=%s",
               Bat_Cat_DD?"HEDGE LOCK":"OFF", Cat_DD_PhanTram, DDLock_HedgeMagic, DDLock_EnableCompression?"ON":"OFF",
               DDLock_CompressionKeepGrossPct, DdlStateName(g_ddlState));
   PrintFormat("V38 R1 | execution: no Sleep, retcode per operation + broker read-back | confirm window %d ms | %d attempts per ticket then STALLED %d min | stops %d freeze %d points | V26 cycle state persist=%s | manual partial close freezes grid=%s | exit state=%s",
               Exec_ConfirmMs, Exec_MaxAttempts, Exec_StallRetryMinutes, (int)SymbolInfoInteger(_Symbol,SYMBOL_TRADE_STOPS_LEVEL), (int)SymbolInfoInteger(_Symbol,SYMBOL_TRADE_FREEZE_LEVEL),
               V26State_Persist?"ON":"OFF", ManualPartial_FreezeGrid?"ON":"OFF", ExActive()?"BASKET_EXITING":"IDLE");
   PrintFormat("V38 R2 | authority %s | precedence: pending (legacy) PairClose leg before DD / grid / L1 / recovery, cycle economically >= BE blocks a NEW DD Lock | manual re-entry %s | old recovery records pending %d (reconcile only) | grid freeze %s",   // [MRR R1] text
               Auth38Name(AuthCurrent()), ManualReentry_Enable?"ON":"REMOVED (MRR R1: a manual close is never re-entered)",
               MrPendingCount(), g_mrGridFreeze?MrFreezeName(g_mrFreezeWhy):"no");
   PrintFormat("V38 MRR R1 | manual close: no re-entry; a fully closed level is abandoned in the level book (never re-opened in the cycle), the grid continues at the next proven level | a manual close deal with another magic counts when its position was opened by the EA | an event of a finished cycle never touches the running basket | full manual close -> cycle finalized, new L1 on the next eligible tick (session / RSI / volume / margin unchanged) | a late fill of a finalized cycle is closed, never a new L1 | level book %s | partial close freezes grid=%s",   // [MRR R1] text
               LbOn()?"ON ("+LbText()+")":"off (no manual close in this basket: grid level = positions + 1 as V26)", ManualPartial_FreezeGrid?"ON (R1 policy)":"OFF (level book)");
   PrintFormat("V38 R3 FINAL | T1/T2 before DD%%: a NEW DD Lock only in ORIGINAL_GRID_DRAWDOWN (>= 2 grid positions, floating loss, cycle below economic BE, no T1/T2 latched or eligible on the tick, no pending PairClose leg / recovery in flight / surplus close / unknown broker result) | a DD Lock that started before T1 is kept (no automatic unwind)");   // [MRR R1] text: the R3 FINAL recovery rule is removed
   PrintFormat("V38 RPA | RECURSIVE PAIR_A REBASE V1 = the PairClose controller of PairClose_Mode 1 [DPMR R1] | entry strategy %s | latched per cycle: %s | Max_Orders = GridMaxOrders %d | strict broker lot / margin check %s (symbol: min %.2f step %.2f max %.2f limit %.2f, contract %.0f) | ladder L%d = %.2f lots | cycle latch %s | RPA state %s epoch %d",
               Entry_Strategy==OFH38_ENTRY_GLOBAL?StringFormat("GLOBAL Grid Mode 1 (K=%d, D=%.2f)", GlobalGrid_OrdersPerGroup, GlobalGrid_BreakoutDistanceUSD):"V26 traditional", g_clHave?"yes":"no cycle", Max_Orders, GridLot_StrictBrokerLimits?"ON":"OFF",
               SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MIN), SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_STEP), SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MAX), SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_LIMIT),
               SymbolInfoDouble(_Symbol,SYMBOL_TRADE_CONTRACT_SIZE), Max_Orders, Gl38LadderLot(Initial_Lot, Lot_Multi, Max_Orders, SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_STEP)),
               g_clFrozen?g_clFrozenWhy:(g_clHave?"latched":"no cycle"), RpaStateName(g_rpState), g_rpEpoch);
   PrintFormat("V38 RPA | start: original grid highest level >= L%.0f | Lk* = L%.0f* (TargetLot from the original template L1..Lk, lot engine CalcLot) | subgrid MultiLot %.2f (constant) | PairClose of an epoch after %d additional FILLED orders (constant) | additional orders <= %.0f | BE100 economic >= %.2f USD after exit cost (estimate %.2f USD/lot, slip %.0f points) | gates: margin level >= %.0f%% on the path, stress %.0f USD <= %.1f%% equity | shadow %s | unknown result: reconcile only, not executed after %d s of broker evidence | session loss limit %.3f%% effective",
               ClGet(CL_RPA_START), ClGet(CL_RPA_K), SUBGRID_MULTILOT, SUBGRID_PAIRCLOSE_AFTER_ADDITIONAL_ORDERS, ClGet(CL_MAXORD), ClGet(CL_SET_MIN), ClGet(CL_COST), ClGet(CL_SLIP), ClGet(CL_PF_ML), ClGet(CL_PF_STRESS),
               ClGet(CL_PF_LOSS), ClGet(CL_SHADOW)>0.5?"ON (log only)":"OFF", RPA_UNKNOWN_RESOLVE_SEC, O12SessionPctEff(CloseProtect_UsePairACycleLossPct, CloseProtect_PairACycleMaxLossPct));
   PrintFormat("V38 TWO-PAIRCLOSE P3 | exit mode %s | trend: %s EMA %.0f / %.0f ATR %.0f strong >= %.2f | hybrid floor from %.0f pip keeps %.0f%% of the MFE, ATR x %.2f weak / x %.2f strong, trail %.0f..%.0f pip | symbol margin: hedged %.2f, margin / lot %.2f",
               Exit38Name(ExitMode()), EnumToString((ENUM_TIMEFRAMES)(int)ClGet(CL_EXIT_TF)), ClGet(CL_EXIT_EF), ClGet(CL_EXIT_ES), ClGet(CL_EXIT_ATR), ClGet(CL_EXIT_STRONG), ClGet(CL_EXIT_FSTART), ClGet(CL_EXIT_FKEEP),
               ClGet(CL_EXIT_MW), ClGet(CL_EXIT_MS), ClGet(CL_EXIT_TMIN), ClGet(CL_EXIT_TMAX), SymbolInfoDouble(_Symbol,SYMBOL_MARGIN_HEDGED), RpaMarginPerLot());

   // [L1RSI R1] R02: the RSI_Period<2 warning is replaced by the refusal at the top of OnInit. R04 log only:
   if(!g_rsiProt)   // [RSI SAFETY R2] S04: PROTECTIVE_ONLY prints its own line (Rsi2InitInvalidRsi) and its first phase below
   PrintFormat("V38 L1RSI R1 | L1 signal: native iRSI(%s, %s, %d, PRICE_CLOSE), last CLOSED bar (shift 1), multi-level 0..100 | 0..30 BUY, >30..50 SELL, >50..70 BUY, >70..100 SELL | RSI_Period >= %d (1 refused, never replaced) | L1 on the first eligible tick after the basket is flat (no wait for a new bar)",
               _Symbol, EnumToString(RSI_TF), RSI_Period, L1RSI_PERIOD_MIN);
   Rsi2Tick();   // [RSI SAFETY R2] S04: first PROTECTIVE_ONLY phase (log only; nothing when RSI_Period >= 2)
   PrintFormat("V38 SAFETY | FINAL STANDALONE SAFETY CORRECTION (base FINAL STANDALONE 950521CF): RPA close LOCKED / CLOSE_ORDER_EXIST = UNKNOWN (no second request), close-order-working wait + bounded backoff + live-volume guard | entry: no request while a Magic order works or an entry request has no broker result (resolved by broker evidence or %d s) | DD hedge: broker evidence | records written only after a restore | R1: two-side T1 declared only when the broker shows every protective level (S12), basket exit: no second close request before the earlier one is reconciled (S13) | open entry record %s",
               SAF_UNKNOWN_RESOLVE_SEC, g_seRec.st==0?"none":StringFormat("#%d order %I64u", g_seRec.cnt, g_seRec.ord));

   return INIT_SUCCEEDED;
}

// Gỡ handle RSI khi gỡ EA khỏi chart. V38: lưu trạng thái DD Lock / biên nhóm GLOBAL đang chạy.
void OnDeinit(const int reason)
{
   Comment("");
   // [SAFETY S08] OnDeinit(REASON_INITFAILED) follows a failed OnInit (no record restored) and a run whose account was never known did not restore either: the memory
   // holds defaults -> writing would overwrite / delete the records of the open basket (HOTFIX: CycPersistIfChanged wrote an empty T1/T2 state here)
   if(!Saf38MayPersist(reason, v38RestorePending))
   {
      g_safNoPersist++;
      PrintFormat("V38 SAFETY | deinit reason %d before the records were restored (%s): no record written, the persisted state of the basket is kept", reason, reason==REASON_INITFAILED?"OnInit failed":"account not known yet");
      if(reason==REASON_INITFAILED)   // [INPUT CLEANUP R1] IC3: log only
         Print("V38 STARTUP REFUSED | the EA did not start: the reason is the 'V38 CONFIG ERROR' line printed just before | Strategy Tester then ends the pass with 'tester stopped because OnInit reports incorrect input parameters' (a failed RSI handle: 'OnInit failed') | visual mode: these lines are in the Journal of the visual tester window and in the agent log, the terminal Journal only shows the agent connecting and closing");
      ExitRelease(); RpaFileClose();   // handles only (no record)
      if(hRSI!=INVALID_HANDLE) IndicatorRelease(hRSI);
      Su3PrintCounters("DEINIT");      // [STARTUP SAFETY R3] U02 (log only): a restore still pending keeps every record as it was
      return;
   }
   if(DdlActive())
   {
      DdlPersist();
      if((bool)MQLInfoInteger(MQL_TESTER) && reason!=REASON_PARAMETERS && reason!=REASON_CHARTCHANGE && reason!=REASON_RECOMPILE)
         DdlEndEpisode("TEST_END", true);
   }
   if(GgAny() || g_ggPendOn) GgSaveAll();   // R1: + the next epoch's group-0 range observed since the decision tick
   // V38 R1: ý định thoát cụm + trạng thái chu kỳ V26 xuống đĩa trước khi gỡ EA
   if(ExActive()) ExPersist();
   CycPersistIfChanged();
   GlobalVariablesFlush();
   Ex38PrintCounters("DEINIT");
   MrPrintCounters("DEINIT");    // V38 R2: hàng chờ khôi phục đã lưu bền từng thay đổi (không cần ghi thêm)
   MrrPrintCounters("DEINIT");   // [MRR R1] evidence counters (log only)
   DpmrPrintCounters("DEINIT");  // [DPMR R1] evidence counters (log only)
   R2PrintCounters("DEINIT");
   LbPrintCounters("DEINIT");    // V38 R3: sổ cấp lưu bền mỗi lần đổi
   Prio38PrintCounters("DEINIT");   // V38 R3 FINAL: DD không khởi tạo theo trạng thái nắm cụm (bằng chứng)
   GlPrintCounters("DEINIT");       // PAIRA_LOOP
   ClPrintCounters("DEINIT");       // PAIRA_LOOP
   RpaPrintCounters("DEINIT");      // RPA (state persisted at every change)
   SafPrintCounters("DEINIT");      // [SAFETY] evidence counters of the safety correction
   PrintFormat("TPC EXIT COUNTERS DEINIT | %s", ExitCountersText());
   ExitRelease();
   PrintFormat("V38 OWNER12 COUNTERS DEINIT | cycles that reached Max_Orders %d (grid level skipped at the cap) %I64d | session decisions deferred for an in-flight request %I64d | DD Lock episodes started %I64d (DD %s)",
               Max_Orders, g_o12MaxOrdCycles, g_o12SessDefer, g_prStarted, Bat_Cat_DD?"ON":"OFF");
   RpaFileClose();                  // RPA journal (tester CSV)
   RrDeinit(reason);               // OWNER12: bộ ghi nghiên cứu (chỉ tester)
   Rsi2PrintCounters("DEINIT");     // [RSI SAFETY R2] S04 (log only; nothing when RSI_Period >= 2)
   Su3PrintCounters("DEINIT");      // [STARTUP SAFETY R3] U02 (log only)
   if(hRSI!=INVALID_HANDLE) IndicatorRelease(hRSI);   // [RSI SAFETY R2] S01: PROTECTIVE_ONLY has no RSI handle
}

//+------------------------------------------------------------------+
// Đổi giờ server sang giờ local (GMT+7) — dùng cho lọc phiên.
int GetLocalHour()
{
   datetime now = TimeCurrent();
   MqlDateTime dt; TimeToStruct(now, dt);
   int lh = dt.hour + (LocalGMT - ServerGMT);
   if(lh >= 24) lh -= 24;
   if(lh < 0)   lh += 24;
   return lh;
}

// Phút hiện tại theo đồng hồ local (đi cùng GetLocalHour).
int GetLocalMinute()
{
   datetime now = TimeCurrent();
   MqlDateTime dt; TimeToStruct(now, dt);
   return dt.min;
}

// Thứ trong tuần theo giờ local — để cấm cuối tuần / phiên qua đêm thứ Sáu.
ENUM_DAY_OF_WEEK GetLocalDayOfWeek()
{
   int diff_hours = LocalGMT - ServerGMT;
   datetime now_local = TimeCurrent() + (datetime)(diff_hours * 3600);
   MqlDateTime dt; TimeToStruct(now_local, dt);
   return (ENUM_DAY_OF_WEEK)dt.day_of_week;
}

// Đúng khi là thứ Bảy hoặc Chủ nhật (lịch).
bool IsCalendarWeekendDay(const ENUM_DAY_OF_WEEK dow)
{
   return (dow == SATURDAY || dow == SUNDAY);
}

// V38: đang trong HỢP các phiên đang bật (Á / Âu / Mỹ, phiên bắt đầu T2..T6 local; qua đêm thuộc ngày bắt đầu — như V26).
bool IsInTradingHours()
{
   if(!UseTimeFilter) return true;
   return SessInHours();
}

// V38: còn ≤ MinBeforeClose phút tới hết CỬA SỔ LIÊN TỤC (phiên chồng / liền nhau đã gộp) — không mở L1 / bảo vệ đóng phiên.
bool IsNearTradingEnd()
{
   if(!UseTimeFilter) return false;
   return SessNearEnd();
}

// V38: giờ server mở cửa sổ kế tiếp (đầu cửa sổ liên tục kế, nhảy qua cuối tuần).
datetime CalcNextOpenTime()
{
   const datetime open_local=SessNextOpenLocal();
   PrintFormat("CalcNextOpenTime: mo lai %s (local)", open_local>0?TimeToString(open_local, TIME_DATE|TIME_MINUTES):"(khong co phien nao bat)");
   if(open_local<=0) return D'2099.12.31';
   return open_local - (datetime)SessDiff();
}

// Đánh dấu nghỉ: OnTick sẽ return tới khi tới giờ mở phiên mới.
void NghiDenPhienSau()
{
   WaitNextSession = true;
   WaitUntilTime   = CalcNextOpenTime();
   PrintFormat("=== Cho den phien moi: %s (server) ===",
               TimeToString(WaitUntilTime, TIME_DATE|TIME_MINUTES));
}

//+------------------------------------------------------------------+
// Khoảng lưới G1..G25 đổi sang giá. order_num=2 dùng G1, =3 dùng G2...
double GetStep(int order_num)
{
   int n = order_num - 1;
   double p;
   switch(n)
   {
      case 1:  p=G1;  break; case 2:  p=G2;  break; case 3:  p=G3;  break;
      case 4:  p=G4;  break; case 5:  p=G5;  break; case 6:  p=G6;  break;
      case 7:  p=G7;  break; case 8:  p=G8;  break; case 9:  p=G9;  break;
      case 10: p=G10; break; case 11: p=G11; break; case 12: p=G12; break;
      case 13: p=G13; break; case 14: p=G14; break; case 15: p=G15; break;
      case 16: p=G16; break; case 17: p=G17; break; case 18: p=G18; break;
      case 19: p=G19; break; case 20: p=G20; break; case 21: p=G21; break;
      case 22: p=G22; break; case 23: p=G23; break; case 24: p=G24; break;
      default: p=G25; break;
   }
   return p * PipSize;
}

// Chiều lệnh tiếp theo: Lẻ cùng L1, chẵn ngược L1 (BUY-SELL-BUY-SELL...).
int GetNextType(int order_num)
{
   bool opposite = (order_num % 2 == 0);
   if(FirstType == POSITION_TYPE_BUY)
      return opposite ? POSITION_TYPE_SELL : POSITION_TYPE_BUY;
   else
      return opposite ? POSITION_TYPE_BUY  : POSITION_TYPE_SELL;
}

// Giá kích hoạt lệnh N: FirstPrice + G (BUY) hoặc FirstPrice − G (SELL).
double GetTrigger(int next_type, int order_num)
{
   double dist = GetStep(order_num);
   return next_type == POSITION_TYPE_BUY
          ? NormalizeDouble(FirstPrice + dist, _Digits)
          : NormalizeDouble(FirstPrice - dist, _Digits);
}
// [GLOBAL GEN] journal text of the grid step of level n in the fill line: V26 = the unchanged "G<n-1>=<pip>pip"; GLOBAL = group / local index / LD element (no G)
string GridStepText(const int n)
{
   if(!GgOn()) return StringFormat("G%d=%.0fpip", n-1, GetStep(n)/PipSize);
   const int k=GgK(), lv=GgMax();
   if(Gg38IsBreakoutAnchor(n, k, lv)) return StringFormat("GLOBAL g%d ANCHOR D=%s", Gg38GroupOf(n, k, lv), Gg38Num(GgD()));
   const int li=Gg38LocalIndex(n, k, lv);
   return StringFormat("GLOBAL g%d local L%d LD%d=%spip", Gg38GroupOf(n, k, lv), li+1, li, li>=1?Gg38Num(GgLd(li)):"-");
}

// Đếm lệnh đang mở của EA (đúng symbol + magic).
int CountPositions()
{
   int count = 0;
   for(int i = 0; i < PositionsTotal(); i++)
   {
      ulong t = PositionGetTicket(i);
      if(!t) continue;
      if((ulong)PositionGetInteger(POSITION_MAGIC) != Magic) continue;
      if(PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
      count++;
   }
   return count;
}

// Đúng khi ticket vẫn còn trên thị trường (chống gửi trùng).
bool OrderStillOpen(ulong order_ticket)
{
   if(order_ticket == 0) return false;
   for(int i = 0; i < PositionsTotal(); i++)
   {
      ulong t = PositionGetTicket(i);
      if(!t) continue;
      if((ulong)PositionGetInteger(POSITION_MAGIC) != Magic) continue;
      if(PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
      if((ulong)PositionGetInteger(POSITION_IDENTIFIER) == order_ticket) return true;
   }
   return false;
}

// Đúng khi lệnh pending chưa khớp — chờ ConfirmWait giây rồi mới gửi lại.
bool OrderIsPending(ulong order_ticket)
{
   if(order_ticket==0) return false;
   if(!OrderSelect(order_ticket)) return false;
   if(OrderGetString(ORDER_SYMBOL)!=_Symbol) return false;
   if((ulong)OrderGetInteger(ORDER_MAGIC)!=Magic) return false;
   return true;
}

// Lấy giá vào và chiều của lệnh mở sớm nhất — khôi phục FirstPrice khi restart.
void GetFirstPosition(double &price, int &type)
{
   datetime first_time = D'2099.12.31';
   price = 0; type = -1;
   for(int i = 0; i < PositionsTotal(); i++)
   {
      ulong t = PositionGetTicket(i);
      if(!t) continue;
      if((ulong)PositionGetInteger(POSITION_MAGIC) != Magic) continue;
      if(PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
      datetime pt = (datetime)PositionGetInteger(POSITION_TIME);
      if(pt < first_time)
      {
         first_time = pt;
         price = PositionGetDouble(POSITION_PRICE_OPEN);
         type  = (int)PositionGetInteger(POSITION_TYPE);
      }
   }
}

// Xóa hết trạng thái một vòng: lưới, T1/T2, chốt tay. Gọi khi cụm đã đóng hết.
void ResetCycleState()
{
   if(g_cycStartMsc>0 && CountPositions()<=0) RrGrid("FLAT", 0, 0, 0.0, 0.0, 0.0, "");   // LPGD recorder (tester only): the basket of the cycle is flat
   if(g_cycStartMsc>0 && g_mrrSeenPos && CountPositions()<=0) MrrOnCycleFinalized();   // [MRR R1] M04 / M06: a flat cycle whose positions were seen is finalized (late-fill rule until the EA's new L1; log for a manual / late-fill cycle)
   OrderCount    = 0;
   FirstPrice    = 0;
   FirstType     = -1;
   LastSentOrder = 0;
   LastSentTime  = 0;
   LastSentCount = 0;
   DblConfirmNum = 0;
   DblConfirmHit1  = false;
   DblConfirmReady = false;
   basketModeLatched = false;
   hedgeTrailActive  = false;
   hedgeBePrice      = 0;
   hedgeExitPrice    = 0;
   hedgeClusterBe    = 0;
   hedgeT1Trigger    = 0;
   hedgeLockMoney    = 0;
   hedgeTrailDir     = 0;
   t1Locked          = false;
   t1Dir             = 0;
   t2Armed           = false;
   t1OneSide         = false;
   skipGridThisTick  = false;
   MrOnCycleReset();   // V38 R2: cụm phẳng → mọi bản ghi khôi phục của chu kỳ cũ CANCELLED (đang bay → đối soát trước); còn lệnh (khởi động lại) → chỉ xóa RAM
   LbOnCycleReset();   // V38 R3: sổ cấp của chu kỳ cũ (cụm phẳng → xóa bản ghi lưu bền; khởi động lại → đọc lại ngay sau)
   RpaOnCycleReset();  // RPA §9: cụm phẳng thật → BasketCycleID CLOSED (nhật ký), xóa bản ghi; khởi động lại còn lệnh → chỉ xóa RAM, RpaRestore đọc lại
   ClOnCycleReset();   // PAIRA_LOOP: cấu hình chốt của chu kỳ cũ (cụm phẳng → xóa; chu kỳ mới chốt Input mới)
   ExitOnCycleReset(); // TWO-PAIRCLOSE P3: MFE của T2 HYBRID (cụm phẳng → xóa bản ghi)
   // V38: cụm đã đóng hết → hết SESSION_BASKET_RESCUE và biên nhóm GLOBAL (xóa bản ghi lưu bền).
   // Khi RestoreState gọi lúc còn lệnh: chỉ xóa trong bộ nhớ, bản ghi được đọc lại ngay sau (V38RestoreModules).
   if(sessionRescue)
   {
      if(CountPositions()<=0) SetSessionRescue(false, "BASKET_FINISHED");
      else sessionRescue=false;
   }
   if(GgAny() || g_ggPersisted)
   {
      GgResetMemory();
      if(CountPositions()<=0) GgClearPersist();
   }
   // V38 R1: chu kỳ mới → không còn chân PairClose dở, cờ chốt tay một phần, giờ L1 cũ; registry lệnh đang chờ của cụm cũ bỏ đi
   g_pairPend1=0; g_pairPend2=0; g_cycIndexShift=false; g_cycStartMsc=0; g_pairPendSinceMsc=0;
   Ex38ResetRegistries();
}

// [DPMR R1] D04 ---------------------------------------------------------------- DD HALT release after an Owner FULL MANUAL close (basket + hedge) (state: after [DPMR CORE END])
// evidence of the closes of the DD episode in the deal history: the positions of Magic / DDLock_HedgeMagic opened since the basket start (entry deal of either magic),
// their exit deals of ANY deal magic (the closing order of the terminal may carry its own magic, M03) at / after the DD trigger second, classified by DEAL_REASON.
// false = the evidence cannot be read (no trigger time / no history / no entry deal).
bool DpmrDdCloseEvidence(int &nPos, int &nUnclosed, int &nManual, int &nStopOut, int &nOther, string &txt)
{
   nPos = 0; nUnclosed = 0; nManual = 0; nStopOut = 0; nOther = 0; txt = "";
   if(g_ddlTrigTime <= 0) { txt = "the episode record has no trigger time"; return false; }
   const datetime from = (g_ddlBasketStart > 0 && g_ddlBasketStart <= g_ddlTrigTime) ? g_ddlBasketStart - 60 : g_ddlTrigTime - 7 * 86400;
   if(!HistorySelect(from, TimeCurrent() + 60)) { txt = "HistorySelect failed"; return false; }
   const int total = HistoryDealsTotal();
   ulong id[]; double vin[], vout[];
   for(int k = 0; k < total; k++)
   {
      const ulong d = HistoryDealGetTicket(k);
      if(d == 0 || HistoryDealGetString(d, DEAL_SYMBOL) != _Symbol || !DdlMagic((ulong)HistoryDealGetInteger(d, DEAL_MAGIC))) continue;
      if(HistoryDealGetInteger(d, DEAL_ENTRY) != DEAL_ENTRY_IN) continue;
      const ulong pid = (ulong)HistoryDealGetInteger(d, DEAL_POSITION_ID);
      int i = -1; for(int a = 0; a < nPos; a++) if(id[a] == pid) { i = a; break; }
      if(i < 0) { ArrayResize(id, nPos + 1); ArrayResize(vin, nPos + 1); ArrayResize(vout, nPos + 1); id[nPos] = pid; vin[nPos] = 0.0; vout[nPos] = 0.0; i = nPos++; }
      vin[i] += HistoryDealGetDouble(d, DEAL_VOLUME);
   }
   if(nPos <= 0) { txt = "no entry deal of Magic / DDLock_HedgeMagic in the history window"; return false; }
   string why = "";
   for(int k = 0; k < total; k++)
   {
      const ulong d = HistoryDealGetTicket(k);
      if(d == 0 || HistoryDealGetString(d, DEAL_SYMBOL) != _Symbol) continue;
      const long en = HistoryDealGetInteger(d, DEAL_ENTRY);
      if(en != DEAL_ENTRY_OUT && en != DEAL_ENTRY_OUT_BY && en != DEAL_ENTRY_INOUT) continue;
      const ulong pid = (ulong)HistoryDealGetInteger(d, DEAL_POSITION_ID);
      int i = -1; for(int a = 0; a < nPos; a++) if(id[a] == pid) { i = a; break; }
      if(i < 0) continue;
      vout[i] += HistoryDealGetDouble(d, DEAL_VOLUME);
      if(!Ddr38InEpisode(HistoryDealGetInteger(d, DEAL_TIME_MSC), (long)g_ddlTrigTime)) continue;
      const long rs = HistoryDealGetInteger(d, DEAL_REASON);
      const int c = Ddr38ClassOf(rs);
      if(c == DDR38_CLS_MANUAL) nManual++;
      else if(c == DDR38_CLS_STOPOUT) { nStopOut++; if(StringLen(why) < 300) why += StringFormat(" stop-out deal %I64u position %I64u;", d, pid); }
      else { nOther++; if(StringLen(why) < 300) why += StringFormat(" deal %I64u position %I64u reason %I64d;", d, pid, rs); }
   }
   for(int a = 0; a < nPos; a++) if(vout[a] < vin[a] - 1e-6) { nUnclosed++; if(StringLen(why) < 300) why += StringFormat(" position %I64u closed %.2f of %.2f;", id[a], vout[a], vin[a]); }
   txt = StringFormat("episode %I64d trigger %s | %d position(s) of Magic / DDLock_HedgeMagic since %s | exit deals since the trigger: manual %d, stop-out %d, other %d | positions not fully closed %d%s",
                      g_ddlEpisode, TimeToString(g_ddlTrigTime, TIME_DATE | TIME_SECONDS), nPos, TimeToString(from, TIME_DATE | TIME_SECONDS), nManual, nStopOut, nOther, nUnclosed, why == "" ? "" : " |" + why);
   return true;
}
// called by DdlManage in DDL_HALT with the basket + hedge flat; true = released (DDL_NORMAL, cycle reset). At most one evaluation per 5 s per episode (history scan);
// one log line per verdict change. Not released: the HALT stays exactly as before (OWNER_DECISION_REQUIRED).
bool DpmrDdHaltReleaseCheck()
{
   if(g_ddlState != DDL_HALT) return false;
   const long now = Ex38TickMsc();
   if(g_dpmrDdLastEp == g_ddlEpisode && g_dpmrDdLastMsc > 0 && now - g_dpmrDdLastMsc < 5000) return false;
   g_dpmrDdLastMsc = now; g_dpmrDdLastEp = g_ddlEpisode; g_dpmrDdChecks++;
   DdlInv v; DdlInventory(v);
   const bool flat = (v.n_o == 0 && v.n_r == 0);
   const bool orders = Prio38OrderWorking() || DdlPendingHedgeOrders();
   const bool inflight = DdlHedgeInflight() || g_ddlLegTk != 0 || g_seRec.st != 0 || ExActive() || MrAnyCancelReconcile() || MrInflightAny() || PairPendingAny();
   int nPos = 0, nUn = 0, nMan = 0, nSo = 0, nOth = 0; string ev = "";
   const bool hist = (flat && !orders && !inflight) ? DpmrDdCloseEvidence(nPos, nUn, nMan, nSo, nOth, ev) : false;
   const int vd = Ddr38Verdict(flat, orders, inflight, hist, nUn, nMan, nSo, nOth);
   if(vd != g_dpmrDdLastVerdict)
   {
      g_dpmrDdLastVerdict = vd;
      PrintFormat("DD HALT RELEASE CHECK | %s | broker: basket n=%d hedge n=%d | Magic / hedge order working %d | request without broker result %d | %s", Ddr38Name(vd), v.n_o, v.n_r, orders ? 1 : 0, inflight ? 1 : 0,
                  ev == "" ? "deal history not read (an earlier condition holds)" : ev);
      if(vd >= DDR38_KEEP_STOPOUT) g_dpmrDdKept++;
   }
   if(vd != DDR38_RELEASE) return false;
   g_dpmrDdReleases++;
   PrintFormat("DD HALT RELEASED | OWNER MANUAL FULL CLOSE verified (basket + hedge flat, no working order, no request without a broker result, every close of the episode manual) | episode %I64d, debt %.2f stays in the episode log | cycle reset: grid / GLOBAL / PairClose / Lk* / T1-T2 / manual-close state of the old cycle cleared | new L1 on the next eligible tick (session / RSI / volume / margin unchanged)",
               g_ddlEpisode, DdlDebt());
   DdlEndEpisode("OWNER_MANUAL_FULL_CLOSE", false);
   DdlSetState(DDL_NORMAL, "OWNER_MANUAL_FULL_CLOSE_VERIFIED");
   DdlClearPersist();
   g_ddlEpisode = 0; g_ddlPB = 0; g_ddlPS = 0; g_ddlOnce = "";
   g_dpmrDdLastVerdict = -1; g_dpmrDdLastMsc = 0; g_dpmrDdLastEp = 0;
   ResetCycleState();
   return true;
}
void DpmrPrintCounters(const string when)
{
   PrintFormat("DPMR COUNTERS %s | PairClose mode: input %s, cycle %s | legacy pairs decided %I64d, pairs left pending %I64d | cycle records of an older build (mode 1) %I64d, mode-0 latches overruled by an RPA trace %I64d | DD HALT release checks %I64d, released %I64d, kept (stop-out / not manual / no evidence) %I64d",
               when, PcModeName(g_clPcModeIn), g_clHave ? PcModeName(g_clPcMode) : "none", g_dpmrPairs, g_dpmrPairPend, g_clPcOldRec, g_clPcRpaEvidence, g_dpmrDdChecks, g_dpmrDdReleases, g_dpmrDdKept);
}

// Khi gắn lại EA: nếu chart còn lệnh thì lấy lại FirstPrice; ≥2 lệnh thì coi như đã latch.
void RestoreState()
{
   ResetCycleState();
   OrderCount = CountPositions();
   if(OrderCount > 0)
   {
      GetFirstPosition(FirstPrice, FirstType);
      if(OrderCount >= 2) basketModeLatched = true;
   }
   V38RestoreModules();
}

// V38: khôi phục trạng thái lưu bền của các module mới (cần biết tài khoản / server; chưa biết thì để tick đầu tiên có tài khoản làm).
bool v38RestorePending = false;
void V38RestoreModules()
{
   if(!OfhIdReady())
   {
      v38RestorePending=true;
      Print("V38 RESTORE PENDING | account login / server not known yet: restored on the first tick with an account");
      return;
   }
   v38RestorePending=false;
   g_authOwnerReq=false; g_authOwnerWhy="";
   SafEntryRestore();   // [SAFETY S02] entry request without a broker result recorded before the restart (no further entry until broker evidence)
   CycRestore();   // V38 R1: trạng thái chu kỳ V26 (ghi đè cách khôi phục của V26 khi bản ghi thuộc cụm đang mở)
   if(CountPositions()>0 && SessRescueLoad()) SetSessionRescue(true, "RESTORED_AFTER_RESTART");
   else if(CountPositions()<=0 && GlobalVariableCheck(SessNs()+"rescue")) { GlobalVariablesDeleteAll(SessNs()); GlobalVariablesFlush(); }
   DdlRestore();
   if(DdlActive() && sessionRescue) SetSessionRescue(false, "DD_LOCK_TAKES_AUTHORITY");
   MrRestoreLoad();   // V38 R2: hàng chờ khôi phục lệnh đóng tay TRƯỚC GLOBAL (còn bản ghi chờ → nhóm / biên đã đóng băng giữ nguyên)
   MrrRestore();      // [MRR R1] M04: the finalized cycle still waiting for the EA's new L1 (late-fill rule)
   LbRestore();       // V38 R3: sổ cấp (sau bản ghi khôi phục: cấp của vé vào lại; trước GLOBAL: GgSync dùng số cấp)
   ClRestore();       // PAIRA_LOOP: cấu hình chốt của chu kỳ đang mở (Input khác bản ghi → giữ cấu hình chốt, không lệnh mới tới hết chu kỳ)
   // [DPMR R1] D01: the decision on pending legacy PairClose legs moved below (after RpaRestore: the PairClose mode of the cycle is final only then)
   RpaRestore();      // RPA: trạng thái của BasketCycleID đang mở (epoch / Lk* / anchor / lệnh mở thêm / rebase đang chạy); TRƯỚC xác nhận 2 lần và GLOBAL (cấp ảo, nhóm của epoch)
   if(g_lbSyncAfterRpa) { g_lbSyncAfterRpa = false; LbSync(); }   // [SAFETY S10] the restored level book is synced once the RPA record is known (deferred from LbRestore)
   // RPA V1-R2 (Owner §3 F): a cycle with a rebase was latched before its first rebase. Without the cycle record (V26 restore: one open position = "not latched") the lone
   // Lk* would be treated as an original L1 (TP_Pips / %YP on Lk*) — it is the same latched BasketCycleID: T1 / T2 / grid of the epoch, never the L1 take-profit.
   // [SAFETY S08] the cycle record may be missing (g_cycStartMsc = 0 until the first tick): RpaHadAny() would compare the RPA record with 0 and leave the lone Lk*
   // unlatched (L1 TP_Pips / %YP on Lk*). The effective BasketCycleID (= what the first tick sets: oldest open position) is used for this decision only.
   bool rpaHadAnyEff=RpaHadAny();
   if(!rpaHadAnyEff && g_cycStartMsc<=0 && g_rpCyc!=0 && g_rpCyc==CycStartMsc())
      rpaHadAnyEff=(g_rpEpoch>=1 || g_rpState==RPA_ST_REBASING || g_rpRebases>0 || (g_rpState==RPA_ST_HALTED && g_rpKeepId!=0));
   DpmrModeAfterRestore(rpaHadAnyEff);   // [DPMR R1] D01: an RPA trace of the open cycle = mode 1 whatever its latch says
   // RPA §10: chân PairClose dở của PairClose V26 CŨ (bản ghi chu kỳ của một bản trước) không còn được thực thi — không có bộ điều khiển cũ trong runtime
   // [DPMR R1] D02: ... except in a PairClose_Mode 0 cycle: its pending legs are finished first by PairPendingPump (R3 FINAL rule)
   if((g_pairPend1!=0 || g_pairPend2!=0) && !Dpmr38KeepLegacyLegs(PcMode()))
   {
      R2Warn("LEGACYPAIR", StringFormat("LEGACY_PAIR_PENDING_IGNORED | the cycle record holds pending legacy PairClose legs %I64u / %I64u but the cycle runs PairClose mode %s: record cleared, the positions are kept and managed by RPA / T1 / T2 / session", g_pairPend1, g_pairPend2, PcModeName(PcMode())));   // [DPMR R1] text
      g_pairPend1=0; g_pairPend2=0; g_pairPendSinceMsc=0;
   }
   else if(g_pairPend1!=0 || g_pairPend2!=0)
      PrintFormat("PAIRCLOSE MODE | restart: PairClose_Mode 0 cycle with pending legacy PairClose leg(s) %I64u / %I64u -> finished first (no new pair / grid level / L1 / DD Lock meanwhile)", g_pairPend1, g_pairPend2);   // [DPMR R1] D05 log
   if(CountPositions()>0 && rpaHadAnyEff && !basketModeLatched)
   {
      basketModeLatched=true;
      PrintFormat("RPA R2 RESTORE | cycle %I64d epoch %d (%s): %d open position(s) without a latched cycle record -> latched (the Lk* of a rebased cycle is never an original L1)", g_rpCyc, g_rpEpoch, RpaStateName(g_rpState), CountPositions());
   }
   CycDblConfirmCheck();   // V38 R3: xác nhận 2 lần của Grid chỉ giữ khi đúng cấp kế (RPA: cấp ảo của tập con)
   GgRestore();
   ExRestore();    // V38 R1: đợt thoát cụm đã quyết định trước khi khởi động lại → tiếp tục đóng (R2: xung đột với DD không chứng minh được → OWNER_REQUIRED)
   MrRestoreFinish(); // V38 R2: theo quyền (DD → SUSPENDED, thoát → hủy), đối soát lịch sử deal, đóng tay bị lỡ khi EA tắt, bằng chứng cấp
   R2AuthAfterRestore();
}

// Lot lệnh thứ (order_index+1): Initial × Lot_Multi^index, làm tròn theo bước lot sàn.
double CalcLot(int order_index)
{
   double lot = Initial_Lot * MathPow(Lot_Multi, order_index);
   double step = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   double minL = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   double maxL = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   lot = MathCeil(lot / step) * step;
   lot = NormalizeDouble(lot, 2);
   return MathMax(minL, MathMin(maxL, lot));
}

// Tổng lãi/lỗ nổi + swap của cả cụm (dùng DD% và đóng phiên).
double BasketProfit()
{
   double profit = 0;
   for(int i = 0; i < PositionsTotal(); i++)
   {
      ulong t = PositionGetTicket(i);
      if(!t) continue;
      if((ulong)PositionGetInteger(POSITION_MAGIC) != Magic) continue;
      if(PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
      profit += PositionGetDouble(POSITION_PROFIT) + PositionGetDouble(POSITION_SWAP);
   }
   return profit;
}

// V38 R1: BriefPause() (Sleep 30 ms sau mỗi lệnh) và TradeRetcodeOk() (đọc retcode CŨ khi CTrade không gửi, coi PLACED / khớp một phần là xong)
// của V26 đã bỏ. Kết quả từng yêu cầu: OFH38_Exec.mqh (retcode theo loại thao tác + đọc lại broker theo ticket + đang bay / backoff có trần).

// Đóng một vị thế rồi kiểm tra đã biến mất; false = chưa đóng xong (đang bay / phần dư / chờ backoff), tick sau thử lại.
bool ClosePositionVerified(const ulong ticket)
{
   if(ticket==0) return false;
   return (Ex38Close(trade, ticket, "V26") == EXCL_CLOSED);
}

// Đóng hết lệnh của EA trên symbol này. V38 R1: quyết định thoát → BASKET_EXITING (OFH38_BasketExit.mqh) đóng tới khi broker phẳng thật.
bool CloseBasket()
{
   return CloseBasketR(EXR_OTHER, EXP_NONE);
}

// OWNER12 (Owner mục 4): GetTwoLatestTickets / CheckPairClose / CloseTwoLatest (quyết định PairClose 2 lệnh cuối của V26) đã GỠ. Chân dở của một quyết định
// PairClose do bản cũ ghi lại (g_pairPend1 / g_pairPend2, lưu bền trong CycleState) vẫn được PairPendingPump đóng nốt ở đầu tick.
// [DPMR R1] D02: KHÔI PHỤC cho PairClose_Mode = 0. GetTwoLatestTickets / CheckPairClose = nguyên văn V26 (RSI6_v38.26 SHA 770483AC); CloseTwoLatest = bản V38 R3 FINAL
// (lớp thực thi V38, chân chưa đóng xong = cặp DỞ lưu bền, đóng nốt trước mọi quyết định khác). Bộ đếm: khối trạng thái sau [DPMR CORE END].

// Lấy 2 lệnh mở muộn nhất (theo giờ vào) — cặp chốt Pair Close.
bool GetTwoLatestTickets(ulong &t1, ulong &t2)
{
   struct PosInfo { ulong ticket; long time_msc; };
   PosInfo arr[];
   int cnt = 0;
   for(int i = 0; i < PositionsTotal(); i++)
   {
      ulong t = PositionGetTicket(i);
      if(!t) continue;
      if(!PositionSelectByTicket(t)) continue;
      if((ulong)PositionGetInteger(POSITION_MAGIC) != Magic) continue;
      if(PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
      ArrayResize(arr, cnt+1);
      arr[cnt].ticket   = t;
      arr[cnt].time_msc = PositionGetInteger(POSITION_TIME_MSC);
      cnt++;
   }
   if(cnt < 2) return false;
   for(int i = 0; i < cnt-1; i++)
      for(int j = i+1; j < cnt; j++)
         if(arr[j].time_msc < arr[i].time_msc)
         {
            PosInfo tmp = arr[i]; arr[i]=arr[j]; arr[j]=tmp;
         }
   t1 = arr[cnt-2].ticket;
   t2 = arr[cnt-1].ticket;
   return true;
}

// Đúng khi lãi nổi 2 lệnh cuối cộng lại ≥ soUSD.
bool CheckPairClose(ulong t1, ulong t2, double soUSD)
{
   double profit1=0, profit2=0;
   bool f1=false, f2=false;
   for(int i=0;i<PositionsTotal();i++)
   {
      ulong t = PositionGetTicket(i);
      if(!t) continue;
      if(!PositionSelectByTicket(t)) continue;
      if((ulong)PositionGetInteger(POSITION_MAGIC) != Magic) continue;
      if(PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
      ulong id = (ulong)PositionGetInteger(POSITION_TICKET);
      if(id == t1) { profit1 = PositionGetDouble(POSITION_PROFIT) + PositionGetDouble(POSITION_SWAP); f1=true; }
      if(id == t2) { profit2 = PositionGetDouble(POSITION_PROFIT) + PositionGetDouble(POSITION_SWAP); f2=true; }
   }
   if(!f1 || !f2) return false;
   return ((profit1 + profit2) >= soUSD);
}

// Đóng đúng 2 lệnh Pair Close (lệnh mới trước, lệnh cũ sau).
void CloseTwoLatest(ulong t1, ulong t2)
{
   // V38 R2: vị thế EA đang đóng — chốt tay chúng (kể cả khi OnTradeTransaction bị mất) không tạo bản ghi khôi phục
   if(PositionSelectByTicket(t2)) MrNoRecoverAdd((ulong)PositionGetInteger(POSITION_IDENTIFIER));
   if(PositionSelectByTicket(t1)) MrNoRecoverAdd((ulong)PositionGetInteger(POSITION_IDENTIFIER));
   ClosePositionVerified(t2);
   ClosePositionVerified(t1);
   // V38 R1: chân nào chưa đóng xong (từ chối / đang bay / phần dư) → giữ làm cặp DỞ, đóng nốt trước mọi quyết định cặp mới / level mới
   const bool o2=OfhTicketIsOurs(t2, Magic), o1=OfhTicketIsOurs(t1, Magic);
   if(o1 || o2)
   {
      g_pairPend1=o1?t1:0; g_pairPend2=o2?t2:0;
      g_pairPendSinceMsc=Ex38TickMsc();   // V38 R2: cảnh báo khi dở lâu, DD chờ (B2)
      g_dpmrPairPend++;
      PrintFormat("=== PAIR CLOSE PENDING | leg(s) not closed yet: %I64u%s %I64u%s | finished before any new pair / grid level / L1 / manual recovery / DD Lock (R2) ===",
                  t1, o1?" open":" closed", t2, o2?" open":" closed");
   }
   // V38 R3: after a recovery the two latest by open time may be a re-entry ticket + the top level — the level book follows what really left
   // the basket (no out-of-order grid freeze of R2 any more)
   int real = CountPositions();
   OrderCount = real;
   LastSentOrder=0; LastSentTime=0; LastSentCount=0;
   DblConfirmNum=0; DblConfirmHit1=false; DblConfirmReady=false;
}

// Chốt cặp 2 lệnh cuối khi tổng lãi ≥ PairClose_SoUSD (chỉ trước T1, cụm đã latch).
// [DPMR R1] = bản V38 R3 FINAL (V26 + lớp thực thi V38); chỉ khi chế độ đã chốt của chu kỳ = 0. Thứ tự với T1 = V26: T1/T2 đã khóa → không chốt cặp (P7);
// cùng tick, cặp đủ điều kiện được chốt TRƯỚC rồi P9 mới xét T1 trên phần còn lại (đối chiếu V26 gốc PV1: V26 chốt 2 cặp liên tiếp rồi T1).
void RunPairCloseIfNeeded(int &total)
{
   if(PcMode()!=DPMR_PC_V26) return;   // [DPMR R1] D01: mode 1 never decides a legacy pair
   // V38 R1: chân của một quyết định PairClose trước còn mở → đóng nốt trước (backoff có trần, không gửi trùng);
   // chưa xong → không quyết định cặp mới, không thêm level trong tick này.
   // V38 R2: việc đóng nốt chạy ở ĐẦU tick (PairPendingPump trong V38OnTickBody, trước DD / T1-T2 / Grid / L1 / khôi phục); T1 mới chờ cặp xong (B6).
   if(PairPendingAny()) { skipGridThisTick=true; return; }
   if(!basketModeLatched) return;
   if(!PairClose_BatTat) return;
   if(hedgeTrailActive) return;
   if(total<PairClose_TuLenh) return;
   // V38 R3 FINAL: một yêu cầu đóng lot thừa còn chờ broker → ticket đó thuộc module lot thừa; không quyết định cặp mới tới khi broker trả kết quả
   if(MrSurplusInFlight()) { g_prPairWaitSur++; return; }

   int cur=total;
   while(cur>=PairClose_TuLenh)
   {
      ulong tk1=0, tk2=0;
      if(!GetTwoLatestTickets(tk1, tk2)) break;
      if(PairClose_SoUSD>0 && CheckPairClose(tk1, tk2, PairClose_SoUSD))
      {
         PrintFormat("=== PAIR CLOSE | cap L%d+L%d | tong_profit >= $%.2f%s ===",
                     cur-1, cur, PairClose_SoUSD,
                     PairClose_ChotDanVe?" | CHOT DAN":"");
         g_dpmrPairs++;
         CloseTwoLatest(tk1, tk2);
         if(g_pairPend1!=0 || g_pairPend2!=0) { skipGridThisTick=true; break; }   // V38 R1: cặp dở → dừng vòng, đóng nốt ở tick sau
         const int before=cur;
         cur=CountPositions();
         if(!PairClose_ChotDanVe) break;
         // V38 SỬA LỖI V26 (cần Owner duyệt): sàn không đóng được cặp (Market closed / từ chối) → số lệnh không giảm →
         // V26 lặp vô hạn trong cùng tick. Dừng vòng này, tick sau thử lại (như khi PairClose_ChotDanVe=false). Khi đóng được: y hệt V26.
         if(cur>=before)
         {
            PrintFormat("=== PAIR CLOSE | san chua dong duoc cap (positions %d -> %d) | dung vong, tick sau thu lai ===", before, cur);
            break;
         }
      }
      else break;
   }
   total=CountPositions();
   OrderCount=total;
}

// V38 R1: đóng nốt chân của cặp PairClose đã quyết định (lệnh mới trước, lệnh cũ sau — như CloseTwoLatest)
// V38 R2: gọi ở ĐẦU tick (quyền PAIR_CLOSE_PENDING); còn dở → không Grid / L1 / khôi phục / DD Lock trong tick, cảnh báo mỗi 60 s khi dở lâu
// [DPMR R1] D02: bản V38 R3 FINAL (PairClose_Mode 0; mode 1 không bao giờ có chân dở — xóa khi khôi phục như MRR R1)
void PairPendingPump()
{
   if(g_pairPend2!=0 && ClosePositionVerified(g_pairPend2)) g_pairPend2=0;
   if(g_pairPend1!=0 && ClosePositionVerified(g_pairPend1)) g_pairPend1=0;
   if(g_pairPend1==0 && g_pairPend2==0)
   {
      PrintFormat("=== PAIR CLOSE COMPLETED | pending leg(s) closed%s | positions=%d ===",
                  g_pairPendSinceMsc>0?StringFormat(" after %I64d ms", Ex38TickMsc()-g_pairPendSinceMsc):"", CountPositions());
      LastSentOrder=0; LastSentTime=0; LastSentCount=0;
      DblConfirmNum=0; DblConfirmHit1=false; DblConfirmReady=false;
      g_pairPendSinceMsc=0;
      return;
   }
   skipGridThisTick=true;
   PairPendingWarn();
}

// Gửi market BUY/SELL. Chặn trùng nếu lệnh kỳ vọng đã fill hoặc pending chưa timeout.
// RPA: cmt = nhãn lệnh mở thêm của tập con ("RPA|S|epoch|Lv"); Grid gốc / L1 gửi "" như V26 (CTrade::Buy(lot, symbol) = cùng yêu cầu)
bool TrySendOrder(bool is_buy, double lot, int expected_count, const string cmt="")
{
   // [RSI SAFETY R2] S02 backstop: PROTECTIVE_ONLY sends no Magic entry order (the P5 / P11 gates stop earlier; this counter must stay 0)
   if(!Rsi2Allowed(g_rsiProt, RSI2_ACT_ENTRY_ORDER)) { Rsi2Blocked(RSI2_ACT_ENTRY_ORDER, StringFormat("L%d %s %.2f '%s' refused by the backstop", expected_count, is_buy ? "BUY" : "SELL", lot, cmt)); return false; }
   // [SAFETY S02] no entry while a Magic order works at the broker or an earlier entry request has no broker result (persisted, restart-safe)
   if(SafEntryHold()) return false;
   if(LastSentCount == expected_count)
   {
      if(LastSentOrder > 0 && OrderStillOpen(LastSentOrder)) return false;
      int real = CountPositions();
      if(real >= expected_count)
      {
         PrintFormat("Guard: real=%d >= expected=%d, skip", real, expected_count);
         return false;
      }
      if(OrderIsPending(LastSentOrder))
      {
         // [SAFETY S02] the order still works at the broker: it is never replaced (HOTFIX: after ConfirmWait the order was forgotten and a second order was sent)
         g_safPlacedWait++;
         return false;
      }
      else
      {
         // [SAFETY S02] the order left the working list and its position is not listed: broker evidence decides (a fill whose position is not listed yet is never
         // sent twice; HOTFIX reset the guard here and the next tick sent the same level again)
         bool d = false, pl = false, pc = false, w = false; int h = -1;
         SafEntryEvidence(Magic, LastSentOrder, (long)LastSentTime * 1000, 0, d, pl, pc, w, h);
         const int ev = Saf38EntryResolve(d, pl, pc, w, h, ((long)TimeCurrent() - (long)LastSentTime) * 1000, (long)SAF_UNKNOWN_RESOLVE_SEC * 1000, TerminalInfoInteger(TERMINAL_CONNECTED) != 0);
         if(ev == SAF_ER_WAIT)
         {
            g_safPlacedWait++;
            SafLogOnce("SEPL_" + IntegerToString((long)LastSentOrder), StringFormat("SAFETY ENTRY HOLD | L%d order %I64u left the working list, its position is not listed yet (deal %d, closed %d, order history %d): no second request", expected_count, LastSentOrder, d, pc, h));
            return false;
         }
         if(ev == SAF_ER_NOTEXEC) PrintFormat("SAFETY | L%d order %I64u NOT executed by broker evidence (order history %d, no deal) - may be sent again", expected_count, LastSentOrder, h);
         else PrintFormat("Guard: L%d da fill roi dong (SL/TP/cover) — khong timeout-retry", expected_count);
         LastSentOrder=0;
         LastSentTime=0;
         LastSentCount=0;
         return false;
      }
   }

   int real_now = CountPositions();
   if(real_now >= expected_count)
   {
      PrintFormat("Pre-check: real=%d >= expected=%d, skip", real_now, expected_count);
      LastSentCount = expected_count;
      return false;
   }

   SafEntryIntent(expected_count);  // [SAFETY S02] intent + entry-deal watermark written and flushed BEFORE the request (restart during OrderSend)
   const long s0 = trade.m_sends;   // [SAFETY S02] did the request reach OrderSend (ResultRetcode is stale otherwise)
   bool ok = is_buy ? trade.Buy(lot, _Symbol, 0.0, 0.0, 0.0, cmt) : trade.Sell(lot, _Symbol, 0.0, 0.0, 0.0, cmt);
   const bool reached = (trade.m_sends > s0);
   const int ocl = Saf38OpenRcClass(reached, reached ? trade.ResultRetcode() : 0);
   if(!ok) { PrintFormat("Send failed: %s", trade.ResultComment()); SafEntryAfterSend(ocl, expected_count); return false; }   // [SAFETY S02] UNKNOWN -> record

   uint rc = trade.ResultRetcode();
   if(rc == TRADE_RETCODE_DONE || rc == TRADE_RETCODE_DONE_PARTIAL)
   {
      LastSentOrder = trade.ResultOrder();
      LastSentTime  = TimeCurrent();
      LastSentCount = expected_count;
      SafEntryAfterSend(ocl, expected_count);
      PrintFormat("Sent OK order=%llu rc=%d lot=%.2f", LastSentOrder, rc, lot);
      return true;
   }
   else if(rc == TRADE_RETCODE_PLACED)
   {
      LastSentOrder = trade.ResultOrder();
      LastSentTime  = TimeCurrent();
      LastSentCount = expected_count;
      SafEntryAfterSend(ocl, expected_count);
      PrintFormat("Placed order=%llu, waiting...", LastSentOrder);
      return false;
   }
   else
   {
      PrintFormat("%s err rc=%d: %s", is_buy?"BUY":"SELL", rc, trade.ResultComment());
      SafEntryAfterSend(ocl, expected_count);   // [SAFETY S02] UNKNOWN -> record before anything else may be sent
      return false;
   }
}

// Xác nhận 2 lần từ ConfirmFromOrder: chạm trigger → rời khỏi → chạm lại mới được vào lệnh.
bool CheckDoubleConfirm(int next_num, int next_type, double trigger)
{
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);

   if(DblConfirmNum != next_num)
   {
      DblConfirmNum=next_num; DblConfirmHit1=false; DblConfirmReady=false;
      PrintFormat("DblConfirm START #%d | ConfirmFromOrder=%d | trigger=%.2f",
                  next_num, ConfirmFromOrder, trigger);
   }

   bool hit;
   if(next_type == POSITION_TYPE_BUY)
      hit = NormalizeDouble(ask, _Digits) >= trigger;
   else
      hit = NormalizeDouble(bid, _Digits) <= trigger;

   if(!DblConfirmHit1)
   {
      if(hit)
      {
         DblConfirmHit1  = true;
         DblConfirmReady = false;
         PrintFormat("DblConfirm 1/2 #%d | cham trigger=%.2f %s=%.2f | cho gia roi ra...",
                     next_num, trigger,
                     next_type==POSITION_TYPE_BUY?"ask":"bid",
                     next_type==POSITION_TYPE_BUY?ask:bid);
      }
      return false;
   }

   if(!DblConfirmReady)
   {
      if(!hit)
      {
         DblConfirmReady = true;
         PrintFormat("DblConfirm READY #%d | gia roi khoi trigger=%.2f | cho cham lai...",
                     next_num, trigger);
      }
      return false;
   }

   if(!hit) return false;

   PrintFormat("DblConfirm 2/2 PASS #%d | trigger=%.2f %s=%.2f -> DAT LENH",
               next_num, trigger,
               next_type==POSITION_TYPE_BUY?"ask":"bid",
               next_type==POSITION_TYPE_BUY?ask:bid);
   DblConfirmNum=0; DblConfirmHit1=false; DblConfirmReady=false;
   return true;
}

//+------------------------------------------------------------------+
// KHỐI T1/T2 VÀ L1
// L1: chỉ TP_Pips + %YP. Chạm TP hoặc SL %YP → chốt L1 → vào L1 mới ngay (không đợi nến RSI mới).
// L2+: xóa TP và SL %YP của L1, chuyển sang T1/T2 theo BE cả cụm.
// Chốt hết cụm → reset → L1 mới ngay.
// Chỉ 2 trạng thái net (Lot_Multi để lot 2 phía không bằng nhau):
//   Buy Net  = tổng lot BUY > tổng lot SELL → chờ giá LÊN.
//   Sell Net = tổng lot SELL > tổng lot BUY → chờ giá XUỐNG.
// T1: Bid/Ask qua BE ± Khoang_Doi_SL → đặt mức thoát cả cụm tại BE ± So_Pip_Doi_SL,
//     không cắt lệnh nào, tắt Grid. Phía lot lớn đặt SL; phía lot nhỏ đặt TP cùng giá
//     (không đặt SL phía lỗ — giá đã qua BE+khóa sẽ cắt ngay).
// Giá quay đầu: giữ khóa. Chạm mức khóa → chốt hết cụm, reset, L1 mới.
// T2: chỉ khi giá ĐI TIẾP (Bid > mốc / Ask < mốc) → SL = giá ± Khoang_Trailing_SL,
//     không lùi dưới mốc khóa, chỉ tiến. Chạm SL → chốt hết, reset, L1 mới.
//+------------------------------------------------------------------+
// Lệnh đang chọn có phải của EA này không (đúng symbol + magic).
bool IsOursPos()
{
   return PositionGetString(POSITION_SYMBOL)==_Symbol &&
          (ulong)PositionGetInteger(POSITION_MAGIC)==Magic;
}

// Làm tròn giá theo số chữ số thập phân của symbol.
double PriceN(const double v) { return NormalizeDouble(v,_Digits); }

// Spread hiện tại (Ask − Bid), tối thiểu 1 point.
double SpreadNow()
{
   MqlTick tick;
   if(!SymbolInfoTick(_Symbol,tick)) return _Point;
   return MathMax(tick.ask-tick.bid,_Point);
}

// Khoảng tối thiểu sàn cho phép đặt SL/TP (stops + freeze + 1 point).
double BrokerMinPending()
{
   const double stops=(double)SymbolInfoInteger(_Symbol,SYMBOL_TRADE_STOPS_LEVEL)*_Point;
   const double freeze=(double)SymbolInfoInteger(_Symbol,SYMBOL_TRADE_FREEZE_LEVEL)*_Point;
   return MathMax(stops,freeze)+_Point;
}

// Đổi pip sang giá. XAU: 1 pip = 0.1; 10 pip = 1 giá.
double ToPrice(const double pips)
{
   return pips*PipSize;
}

// Khoảng TP L1 (pip → giá), có thể cộng spread nếu Bat_Cong_Spread_TP.
double DistTP()
{
   double d=ToPrice(TP_Pips);
   if(Bat_Cong_Spread_TP) d+=SpreadNow();
   return MathMax(d,BrokerMinPending());
}

// Khoảng T2: SL cách giá hiện tại bao nhiêu (giá).
double DistTrail()
{
   return ToPrice(MathMax(Khoang_Trailing_SL,0.0));
}

// Khoảng kích hoạt T1 / mốc T2 tính từ BE (giá).
double DistDoiGia()
{
   return ToPrice(MathMax(Khoang_Doi_SL,0.0));
}

// Khoảng khóa T1 tính từ BE (giá).
double DistLockPip()
{
   return ToPrice(MathMax(So_Pip_Doi_SL,0.0));
}

// Kẹp SL cho hợp lệ với giá thị trường (BUY dưới Bid, SELL trên Ask, đủ stops).
double ClampSl(const int dir,const double wantSl)
{
   MqlTick tick;
   if(!SymbolInfoTick(_Symbol,tick)) return 0.0;
   const double minOff=MathMax(BrokerMinPending(),SpreadNow()+_Point);
   if(dir>0)
   {
      const double maxSl=PriceN(tick.bid-minOff);
      if(maxSl<=0.0) return 0.0;
      if(wantSl<=0.0 || wantSl>maxSl+1e-12) return maxSl;
      return PriceN(wantSl);
   }
   const double minSl=PriceN(tick.ask+minOff);
   if(wantSl<=0.0 || wantSl<minSl-1e-12) return minSl;
   return PriceN(wantSl);
}

// Đúng khi SL quá sát/xuyên giá — đặt vào sẽ bị khớp ngay, chưa khóa được.
bool SlHitsMarketNow(const int dir, const double sl)
{
   MqlTick tick;
   if(!SymbolInfoTick(_Symbol,tick) || sl<=0.0) return true;
   const double off=MathMax(BrokerMinPending(), SpreadNow()+_Point)+SpreadNow();
   if(dir>0) return (sl+1e-12 >= tick.bid-off);
   return (sl-1e-12 <= tick.ask+off);
}

// Đếm số lệnh một phía: dir>0 = BUY, dir<0 = SELL.
int CountSide(const int dir)
{
   int n=0;
   for(int i=PositionsTotal()-1;i>=0;i--)
   {
      const ulong ticket=PositionGetTicket(i);
      if(ticket==0 || !PositionSelectByTicket(ticket) || !IsOursPos()) continue;
      const long pt=PositionGetInteger(POSITION_TYPE);
      if(dir>0 && pt!=POSITION_TYPE_BUY) continue;
      if(dir<0 && pt!=POSITION_TYPE_SELL) continue;
      n++;
   }
   return n;
}

// Đúng khi phía đó đã có ít nhất một lệnh gắn SL.
bool SideHasSl(const int dir)
{
   for(int i=PositionsTotal()-1;i>=0;i--)
   {
      const ulong ticket=PositionGetTicket(i);
      if(ticket==0 || !PositionSelectByTicket(ticket) || !IsOursPos()) continue;
      const long pt=PositionGetInteger(POSITION_TYPE);
      if(dir>0 && pt!=POSITION_TYPE_BUY) continue;
      if(dir<0 && pt!=POSITION_TYPE_SELL) continue;
      if(PositionGetDouble(POSITION_SL)>0.0) return true;
   }
   return false;
}

// Ước lãi/lỗ một phía nếu đóng hết tại closePx (kèm swap).
double BasketProfitAt(const int dir,const double closePx)
{
   if(closePx<=0.0) return -1.0e12;
   double s=0.0;
   for(int i=PositionsTotal()-1;i>=0;i--)
   {
      const ulong ticket=PositionGetTicket(i);
      if(ticket==0 || !PositionSelectByTicket(ticket) || !IsOursPos()) continue;
      const long pt=PositionGetInteger(POSITION_TYPE);
      if(dir>0 && pt!=POSITION_TYPE_BUY) continue;
      if(dir<0 && pt!=POSITION_TYPE_SELL) continue;
      double pr=0.0;
      const ENUM_ORDER_TYPE t=dir>0?ORDER_TYPE_BUY:ORDER_TYPE_SELL;
      if(!OrderCalcProfit(t,_Symbol,PositionGetDouble(POSITION_VOLUME),
                          PositionGetDouble(POSITION_PRICE_OPEN),closePx,pr))
         return -1.0e12;
      s+=pr+PositionGetDouble(POSITION_SWAP);
   }
   return s;
}

// Giá vào thấp nhất của một phía (phục vụ tính SL cũ).
double MinOpenSide(const int dir)
{
   double m=0.0;
   bool any=false;
   for(int i=PositionsTotal()-1;i>=0;i--)
   {
      const ulong ticket=PositionGetTicket(i);
      if(ticket==0 || !PositionSelectByTicket(ticket) || !IsOursPos()) continue;
      const long pt=PositionGetInteger(POSITION_TYPE);
      if(dir>0 && pt!=POSITION_TYPE_BUY) continue;
      if(dir<0 && pt!=POSITION_TYPE_SELL) continue;
      const double px=PositionGetDouble(POSITION_PRICE_OPEN);
      if(!any || px<m) { m=px; any=true; }
   }
   return any?m:0.0;
}

// Giá vào cao nhất của một phía (phục vụ tính SL cũ).
double MaxOpenSide(const int dir)
{
   double m=0.0;
   bool any=false;
   for(int i=PositionsTotal()-1;i>=0;i--)
   {
      const ulong ticket=PositionGetTicket(i);
      if(ticket==0 || !PositionSelectByTicket(ticket) || !IsOursPos()) continue;
      const long pt=PositionGetInteger(POSITION_TYPE);
      if(dir>0 && pt!=POSITION_TYPE_BUY) continue;
      if(dir<0 && pt!=POSITION_TYPE_SELL) continue;
      const double px=PositionGetDouble(POSITION_PRICE_OPEN);
      if(!any || px>m) { m=px; any=true; }
   }
   return any?m:0.0;
}

// Cộng lot và (lot × giá vào) từng phía — nguồn tính net và BE.
bool BasketVolumeSums(double &vBuy,double &vSell,double &sumBuy,double &sumSell)
{
   vBuy=vSell=sumBuy=sumSell=0.0;
   for(int i=PositionsTotal()-1;i>=0;i--)
   {
      const ulong ticket=PositionGetTicket(i);
      if(ticket==0 || !PositionSelectByTicket(ticket) || !IsOursPos()) continue;
      const double vol=PositionGetDouble(POSITION_VOLUME);
      const double px=PositionGetDouble(POSITION_PRICE_OPEN);
      if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY)
      {
         vBuy+=vol;
         sumBuy+=vol*px;
      }

      else
      {
         vSell+=vol;
         sumSell+=vol*px;
      }
   }
   return (vBuy>0.0 || vSell>0.0);
}

// Chiều net theo LOT: 1=Buy Net, -1=Sell Net, 0=lot hai phía gần bằng (không T1).
int BasketNetDir()
{
   double vBuy=0.0,vSell=0.0,sumBuy=0.0,sumSell=0.0;
   if(!BasketVolumeSums(vBuy,vSell,sumBuy,sumSell)) return 0;
   const double minV=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MIN);
   const double eps=(minV>0.0?minV:0.01)*0.5;
   if(vBuy>vSell+eps) return 1;
   if(vSell>vBuy+eps) return -1;
   return 0;
}

// Giá hòa vốn khối lượng cả cụm: (sumBuy − sumSell) / (lotB − lotS). Thiếu một phía hoặc net≈0 → 0.
double BasketBreakevenPrice()
{
   double vBuy=0.0,vSell=0.0,sumBuy=0.0,sumSell=0.0;
   if(!BasketVolumeSums(vBuy,vSell,sumBuy,sumSell)) return 0.0;
   if(vBuy<=0.0 || vSell<=0.0) return 0.0;
   const double net=vBuy-vSell;
   const double minV=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MIN);
   const double eps=(minV>0.0?minV:0.01)*0.5;
   if(MathAbs(net)<eps) return 0.0;
   return PriceN((sumBuy-sumSell)/net);
}

// PAIRA_LOOP (Owner B7): giá BE dùng cho T1 / T2. Chu kỳ CHƯA có Progressive PairClose → BE khối lượng của V26 (không đổi, parity R3 FINAL); ĐÃ có → BE KINH TẾ
// của cả BasketCycleID (đã chốt: nén / hedge / trung hòa / phí + nổi + swap − chi phí đóng ước tính), để T1 / T2 không khóa "lời" khi chu kỳ vẫn lỗ.
// TWO-PAIRCLOSE P3: Exit_Mode 1..3 (T0 / T1 Trend / T2 Hybrid) → BE KINH TẾ của cả BasketCycleID ở MỌI chu kỳ (CycleEconomicPnL gồm P/L PairClose, hedge, phí), không phải BE cục bộ.
// RPA V1-R2 (Owner D1 / §3 B): THE shared T1 / T2 may hold a basket of ONE side in exactly one case — the lone Lk* of a reconciled subgrid epoch (RpaT1OneSide:
// SUBGRID, epoch >= 1, no rebase request without a broker result, the broker shows exactly one position = the base Lk*, latched). Same BE (economic BE of the whole
// BasketCycleID), same distances, same lock / trail / exit code; every other basket keeps the V26 two-side prerequisite (original grid unchanged).
// HOTFIX HALTED T1/T2 (Owner 02/11/2026): the same case in a HALTED cycle whose record and broker are reconciled (RpaT1OneSide -> RpaT1OneSideHalted).
bool T1OneSideOk()
{
   return RpaT1OneSide();
}
double T1BePrice()
{
   if(!RpaHadAny() && !ExitEconBe()) return BasketBreakevenPrice();   // RPA: a cycle with a rebase uses the economic BE of the whole BasketCycleID (B7 rule kept)
   double vBuy=0.0,vSell=0.0,sumBuy=0.0,sumSell=0.0;
   if(!BasketVolumeSums(vBuy,vSell,sumBuy,sumSell)) return 0.0;
   const bool one=(vBuy<=0.0 || vSell<=0.0);
   if(one && !T1OneSideOk()) return 0.0;   // two sides needed, except the lone Lk* of a reconciled epoch (R2 D1)
   const double minV=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MIN);
   if(MathAbs(vBuy-vSell)<(minV>0.0?minV:0.01)*0.5) return 0.0;
   return RpaEconBePrice();   // realised deals + floating + swap - projected exit cost of the whole BasketCycleID (one side or two sides: the same formula)
}

// SL tốt nhất đang có trên một phía (BUY lấy SL cao nhất, SELL lấy SL thấp nhất).
double SideBestSl(const int dir)
{
   double sl=0.0;
   bool any=false;
   for(int i=PositionsTotal()-1;i>=0;i--)
   {
      const ulong ticket=PositionGetTicket(i);
      if(ticket==0 || !PositionSelectByTicket(ticket) || !IsOursPos()) continue;
      const long pt=PositionGetInteger(POSITION_TYPE);
      if(dir>0 && pt!=POSITION_TYPE_BUY) continue;
      if(dir<0 && pt!=POSITION_TYPE_SELL) continue;
      const double cur=PositionGetDouble(POSITION_SL);
      if(cur<=0.0) continue;
      if(!any) { sl=cur; any=true; continue; }
      if(dir>0 && cur>sl) sl=cur;
      if(dir<0 && cur<sl) sl=cur;
   }
   return any?sl:0.0;
}

// (Dự phòng, T1 mới không gọi) Tìm SL một phía sao cho lãi ≥ minMoney.
double CoverSl(const int dir,const double minMoney)
{
   if(CountSide(dir)<=0) return 0.0;
   const double tight=ClampSl(dir,0.0);
   if(tight<=0.0) return 0.0;
   if(BasketProfitAt(dir,tight)+1e-8<minMoney) return 0.0;

   if(dir>0)
   {
      double lo=MinOpenSide(dir);
      if(lo<=0.0 || lo>tight) lo=tight;
      if(BasketProfitAt(dir,lo)+1e-8>=minMoney)
         return ClampSl(dir,lo);
      double a=lo,b=tight;
      for(int k=0;k<24;k++)
      {
         const double mid=PriceN(0.5*(a+b));
         if(BasketProfitAt(dir,mid)+1e-8>=minMoney) b=mid;
         else a=mid;
      }
      const double sl=ClampSl(dir,b);
      if(BasketProfitAt(dir,sl)+1e-8<minMoney) return 0.0;
      return sl;
   }

   double hi=MaxOpenSide(dir);
   if(hi<=0.0 || hi<tight) hi=tight;
   if(BasketProfitAt(dir,hi)+1e-8>=minMoney)
      return ClampSl(dir,hi);
   double a=tight,b=hi;
   for(int k=0;k<24;k++)
   {
      const double mid=PriceN(0.5*(a+b));
      if(BasketProfitAt(dir,mid)+1e-8>=minMoney) a=mid;
      else b=mid;
   }
   const double sl=ClampSl(dir,a);
   if(BasketProfitAt(dir,sl)+1e-8<minMoney) return 0.0;
   return sl;
}

// Sửa SL/TP một lệnh rồi đọc lại xem sàn đã nhận đúng chưa.
// V38 R1: true CHỈ KHI broker hiển thị đúng cả SL và TP yêu cầu (nửa tick size) — V26 coi "SL yêu cầu > 0 và SL thực > 0" là đủ.
// SL/TP đã đúng → không gửi; cùng mức đang chờ xác nhận / backoff → không gửi lại; stops / freeze chắc chắn bị từ chối → không gửi (OFH38_Exec).
bool ModifySlTpVerified(const ulong ticket,const double sl,const double tp)
{
   return (Ex38Modify(trade, ticket, sl, tp) == EXM_CONFIRMED);
}

// Xóa hết TP một phía (khi latch L2, hoặc khi gắn SL T1 cho phía lot lớn).
void ClearTpOnPositions(const int dir)
{
   for(int i=PositionsTotal()-1;i>=0;i--)
   {
      const ulong ticket=PositionGetTicket(i);
      if(ticket==0 || !PositionSelectByTicket(ticket) || !IsOursPos()) continue;
      const long pt=PositionGetInteger(POSITION_TYPE);
      if(dir>0 && pt!=POSITION_TYPE_BUY) continue;
      if(dir<0 && pt!=POSITION_TYPE_SELL) continue;
      const double sl=PositionGetDouble(POSITION_SL);
      const double tp=PositionGetDouble(POSITION_TP);
      if(tp<=0.0) continue;
      ModifySlTpVerified(ticket,sl,0.0);
   }
}

// Xóa hết SL một phía (latch xóa %YP; T1 xóa SL phía lot nhỏ để khỏi cắt nhầm).
void ClearSlOnPositions(const int dir)
{
   for(int i=PositionsTotal()-1;i>=0;i--)
   {
      const ulong ticket=PositionGetTicket(i);
      if(ticket==0 || !PositionSelectByTicket(ticket) || !IsOursPos()) continue;
      const long pt=PositionGetInteger(POSITION_TYPE);
      if(dir>0 && pt!=POSITION_TYPE_BUY) continue;
      if(dir<0 && pt!=POSITION_TYPE_SELL) continue;
      const double sl=PositionGetDouble(POSITION_SL);
      const double tp=PositionGetDouble(POSITION_TP);
      if(sl<=0.0) continue;
      ModifySlTpVerified(ticket,0.0,tp);
   }
}

// Đúng khi mọi lệnh phía đó đều đã có SL.
bool SideAllHaveSl(const int dir)
{
   int n=0;
   for(int i=PositionsTotal()-1;i>=0;i--)
   {
      const ulong ticket=PositionGetTicket(i);
      if(ticket==0 || !PositionSelectByTicket(ticket) || !IsOursPos()) continue;
      const long pt=PositionGetInteger(POSITION_TYPE);
      if(dir>0 && pt!=POSITION_TYPE_BUY) continue;
      if(dir<0 && pt!=POSITION_TYPE_SELL) continue;
      if(PositionGetDouble(POSITION_SL)<=0.0) return false;
      n++;
   }
   return (n>0);
}

// Có L2+: đánh dấu cụm, xóa TP và SL %YP của L1 — từ đây chỉ còn T1/T2 / Pair Close / grid.
void LatchBasketMode()
{
   if(basketModeLatched) return;
   basketModeLatched=true;
   ClearTpOnPositions(1);
   ClearTpOnPositions(-1);
   if(!hedgeTrailActive)
   {
      ClearSlOnPositions(1);
      ClearSlOnPositions(-1);
   }
   Print("RSI6: L2+ latch — xoa TP va SL %YP cua L1, sang TP cum");
}

// Gắn/cập nhật TP_Pips lên L1 (chỉ khi chưa latch, còn đúng 1 lệnh).
void EnsureTpOnSide(const int dir)
{
   if(basketModeLatched) return;
   if(hedgeTrailActive || t1Locked) return;
   if(TP_Pips<=0.0) return;
   const double dTp=DistTP();
   for(int i=PositionsTotal()-1;i>=0;i--)
   {
      const ulong ticket=PositionGetTicket(i);
      if(ticket==0 || !PositionSelectByTicket(ticket) || !IsOursPos()) continue;
      const long pt=PositionGetInteger(POSITION_TYPE);
      if(dir>0 && pt!=POSITION_TYPE_BUY) continue;
      if(dir<0 && pt!=POSITION_TYPE_SELL) continue;
      const double entry=PositionGetDouble(POSITION_PRICE_OPEN);
      const double curSl=PositionGetDouble(POSITION_SL);
      const double curTp=PositionGetDouble(POSITION_TP);
      const double tp=PriceN(dir>0?entry+dTp:entry-dTp);
      if(curTp>0.0 && MathAbs(curTp-tp)<_Point*0.5) continue;
      ModifySlTpVerified(ticket,curSl,tp);
   }
}

// Nếu chỉ còn L1 thì gắn lại TP (sau khi restore / lệnh lẻ).
void RestoreTpIfOneSide()
{
   if(basketModeLatched) return;
   if(hedgeTrailActive || t1Locked) return;
   if(CountPositions()!=1) return;
   const int nb=CountSide(1);
   const int ns=CountSide(-1);
   if(nb>0 && ns>0) return;
   if(nb>0 && ns<=0) EnsureTpOnSide(1);
   else if(ns>0 && nb<=0) EnsureTpOnSide(-1);
}

// L1 %YP: giá qua mốc thì kéo SL lên đó, giữ TP. Quay đầu chạm SL = chốt tại %YP.
void TryL1YpLock()
{
   if(basketModeLatched) return;
   if(hedgeTrailActive || t1Locked) return;
   if(CountPositions()!=1) return;
   if(Basket_TP_PhanTram<=0.0 || TP_Pips<=0.0) return;
   const double yp=ToPrice(TP_Pips*Basket_TP_PhanTram/100.0);
   if(yp<=0.0) return;
   MqlTick tick;
   if(!SymbolInfoTick(_Symbol,tick)) return;
   for(int i=PositionsTotal()-1;i>=0;i--)
   {
      const ulong ticket=PositionGetTicket(i);
      if(ticket==0 || !PositionSelectByTicket(ticket) || !IsOursPos()) continue;
      const long pt=PositionGetInteger(POSITION_TYPE);
      const double entry=PositionGetDouble(POSITION_PRICE_OPEN);
      const double curSl=PositionGetDouble(POSITION_SL);
      const double curTp=PositionGetDouble(POSITION_TP);
      if(pt==POSITION_TYPE_BUY)
      {
         const double ypPx=PriceN(entry+yp);
         if(tick.bid+1e-12<ypPx) continue;
         const double sl=ClampSl(1,ypPx);
         if(sl<=0.0) continue;
         if(curSl>0.0 && sl<=curSl+1e-12) continue;
         ModifySlTpVerified(ticket,sl,curTp);
      }
      else
      {
         const double ypPx=PriceN(entry-yp);
         if(tick.ask-1e-12>ypPx) continue;
         const double sl=ClampSl(-1,ypPx);
         if(sl<=0.0) continue;
         if(curSl>0.0 && sl>=curSl-1e-12) continue;
         ModifySlTpVerified(ticket,sl,curTp);
      }
      break;
   }
}

// Đẩy SL một phía tới newSl; chỉ tiến (BUY lên, SELL xuống), bỏ qua nếu xuyên giá.
void MoveSideSl(const int dir,const double newSl)
{
   MqlTick tick;
   if(!SymbolInfoTick(_Symbol,tick)) return;
   const double minOff=MathMax(BrokerMinPending(),SpreadNow()+_Point);
   const double px=ClampSl(dir,newSl);
   if(px<=0.0) return;
   if(SlHitsMarketNow(dir,px)) return;
   for(int i=PositionsTotal()-1;i>=0;i--)
   {
      const ulong ticket=PositionGetTicket(i);
      if(ticket==0 || !PositionSelectByTicket(ticket) || !IsOursPos()) continue;
      const long pt=PositionGetInteger(POSITION_TYPE);
      if(dir>0 && pt!=POSITION_TYPE_BUY) continue;
      if(dir<0 && pt!=POSITION_TYPE_SELL) continue;
      const double cur=PositionGetDouble(POSITION_SL);
      const double tp=hedgeTrailActive?0.0:PositionGetDouble(POSITION_TP);
      if(pt==POSITION_TYPE_BUY)
      {
         if(px>tick.bid-minOff+1e-8) continue;
         if(cur>0.0 && px<=cur+1e-8) continue;
      }
      else
      {
         if(px<tick.ask+minOff-1e-8) continue;
         if(cur>0.0 && px>=cur-1e-8) continue;
      }
      ModifySlTpVerified(ticket,px,tp);
   }
}

// Đặt TP một phía (phía lot nhỏ) cùng mức thoát cụm; chỉ tiến theo chiều T2, xóa SL phía này.
void MoveSideTp(const int dir,const double newTp)
{
   MqlTick tick;
   if(!SymbolInfoTick(_Symbol,tick)) return;
   const double minOff=MathMax(BrokerMinPending(),SpreadNow()+_Point);
   const double px=PriceN(newTp);
   if(px<=0.0) return;
   for(int i=PositionsTotal()-1;i>=0;i--)
   {
      const ulong ticket=PositionGetTicket(i);
      if(ticket==0 || !PositionSelectByTicket(ticket) || !IsOursPos()) continue;
      const long pt=PositionGetInteger(POSITION_TYPE);
      if(dir>0 && pt!=POSITION_TYPE_BUY) continue;
      if(dir<0 && pt!=POSITION_TYPE_SELL) continue;
      const double curTp=PositionGetDouble(POSITION_TP);
      if(pt==POSITION_TYPE_BUY)
      {
         if(px<tick.ask+minOff-1e-8) continue;
         if(curTp>0.0 && px>=curTp-1e-8) continue;
      }
      else
      {
         if(px>tick.bid-minOff+1e-8) continue;
         if(curTp>0.0 && px<=curTp+1e-8) continue;
      }
      ModifySlTpVerified(ticket,0.0,px);
   }
}

// Gắn cùng một mức thoát cho cả cụm: SL phía lot lớn, TP phía lot nhỏ.
void ApplyClusterExit(const int netDir,const double exitPx)
{
   const double px=PriceN(exitPx);
   if(px<=0.0 || netDir==0) return;
   ClearTpOnPositions(netDir);
   if(!SlHitsMarketNow(netDir,px))
      MoveSideSl(netDir,px);
   ClearSlOnPositions(-netDir);
   MoveSideTp(-netDir,px);
}

// Đúng khi giá đã chạm mức thoát: Buy Net xem Bid, Sell Net xem Ask.
bool ClusterExitHit(const int dir,const double exitPx)
{
   if(dir==0 || exitPx<=0.0) return false;
   MqlTick tick;
   if(!SymbolInfoTick(_Symbol,tick)) return false;
   if(dir>0) return (tick.bid<=exitPx+1e-12);
   return (tick.ask>=exitPx-1e-12);
}

// Đóng hết lệnh một phía (dự phòng; T1 hiện tại không cắt lệnh).
bool CloseSide(const int dir)
{
   for(int round=0; round<12; round++)
   {
      bool any=false;
      for(int i=PositionsTotal()-1;i>=0;i--)
      {
         const ulong ticket=PositionGetTicket(i);
         if(ticket==0 || !PositionSelectByTicket(ticket) || !IsOursPos()) continue;
         const long pt=PositionGetInteger(POSITION_TYPE);
         if(dir>0 && pt!=POSITION_TYPE_BUY) continue;
         if(dir<0 && pt!=POSITION_TYPE_SELL) continue;
         any=true;
         ClosePositionVerified(ticket);
      }
      if(!any) return true;
   }
   return (CountSide(dir)<=0);
}

// RPA V1-R2 (Owner §3 D): the lone Lk* is protected ONLY by the SL of that position (no opposite leg, no TP). T1 is declared only when the broker SHOWS that SL
// (Ex38Modify confirmed); otherwise no T1_LOCKED: the reason is logged once per cycle / epoch / reason and the next tick tries again (same level: no resend while
// pending, backoff after a rejection — OFH38_Exec).
void T1OneSideDefer(const int netDir,const double be,const double sl,const string why)
{
   g_t1OneDefer++; g_t1OneDeferWhy=why;
   const string key=StringFormat("T1ONE_%I64d_%d_%s", g_rpCyc, g_rpEpoch, why);
   if(StringFind(g_rpLogKeys, "|"+key+"|")>=0) return;
   MqlTick tk; SymbolInfoTick(_Symbol, tk);
   const string txt=StringFormat("T1 ONE-SIDE NOT LOCKED (%s) | lone Lk* %s %.2f of cycle %I64d epoch %d | economic BE %.2f, lock %.2f | Bid %.2f Ask %.2f, stops %d freeze %d points, spread %.2f -> no T1_LOCKED, no phantom TP; retried on the next tick",
                                 why, netDir>0?"BUY":"SELL", netDir>0?SumSideVol(1):SumSideVol(-1), g_rpCyc, g_rpEpoch, be, sl, tk.bid, tk.ask,
                                 (int)SymbolInfoInteger(_Symbol,SYMBOL_TRADE_STOPS_LEVEL), (int)SymbolInfoInteger(_Symbol,SYMBOL_TRADE_FREEZE_LEVEL), tk.ask-tk.bid);
   RpaLogOnce(key, txt);
   RpaEv("T1_ONE_SIDE_DEFERRED", txt);
}
double SumSideVol(const int dir)
{
   double v=0.0;
   for(int i=PositionsTotal()-1;i>=0;i--)
   {
      const ulong ticket=PositionGetTicket(i);
      if(ticket==0 || !PositionSelectByTicket(ticket) || !IsOursPos()) continue;
      const long pt=PositionGetInteger(POSITION_TYPE);
      if((dir>0 && pt==POSITION_TYPE_BUY) || (dir<0 && pt==POSITION_TYPE_SELL)) v+=PositionGetDouble(POSITION_VOLUME);
   }
   return v;
}
bool T1OneSideProtect(const int netDir,const double be,const double sl)
{
   ulong tk=0; int n=0;
   for(int i=PositionsTotal()-1;i>=0;i--)
   {
      const ulong ticket=PositionGetTicket(i);
      if(ticket==0 || !PositionSelectByTicket(ticket) || !IsOursPos()) continue;
      n++;
      const long pt=PositionGetInteger(POSITION_TYPE);
      if((netDir>0 && pt==POSITION_TYPE_BUY) || (netDir<0 && pt==POSITION_TYPE_SELL)) tk=ticket;
   }
   if(n!=1 || tk==0) { T1OneSideDefer(netDir, be, sl, "NOT_EXACTLY_ONE_POSITION"); return false; }
   const int r=Ex38Modify(trade, tk, sl, 0.0);   // SL = the T1 lock on the Lk*, TP none (no opposite leg)
   if(r==EXM_CONFIRMED) return true;
   T1OneSideDefer(netDir, be, sl, r==EXM_PENDING?"PROTECTION_PENDING_AT_BROKER":(r==EXM_GONE?"POSITION_GONE":"PROTECTION_NOT_ACCEPTED"));
   return false;
}

// T1: khóa mức thoát cả cụm tại lockSl, tắt Grid, không đóng lệnh nào.
// RPA V1-R2: the SAME function locks the lone Lk* of a reconciled epoch (one side: SL of the Lk*, no TP side) — confirmed protection first (T1OneSideProtect).
bool LockEntireCluster(const int netDir,const double lockSl)
{
   const bool one=(CountSide(1)<=0 || CountSide(-1)<=0);
   if(netDir==0 || (one && (!T1OneSideOk() || CountSide(netDir)<=0))) return false;
   const double sl=PriceN(lockSl);
   const double be=T1BePrice();   // PAIRA_LOOP: = BasketBreakevenPrice() khi chu kỳ chưa có Progressive PairClose (V26); BE kinh tế khi đã có (B7)
   if(sl<=0.0 || be<=0.0) return false;
   if(SlHitsMarketNow(netDir,sl))
   {
      if(one) { T1OneSideDefer(netDir, be, sl, "SL_TOO_CLOSE_TO_MARKET"); return false; }
      PrintFormat("RSI6: T1 SL %.5f sat/xuyen gia — chua khoa, cho khoang an toan", sl);
      return false;
   }
   if(one && !T1OneSideProtect(netDir, be, sl)) return false;

   hedgeBePrice=sl;
   hedgeExitPrice=sl;
   hedgeClusterBe=be;
   hedgeT1Trigger=PriceN(netDir>0?be+DistDoiGia():be-DistDoiGia());
   hedgeLockMoney=0.0;
   hedgeTrailDir=netDir;
   t1Dir=netDir;
   t1Locked=one;   // [SAFETY S12] one side: the SL of the Lk* is already broker-confirmed (T1OneSideProtect); two sides: declared below only once the broker shows every level
   t2Armed=false;
   t1OneSide=one;
   skipGridThisTick=true;
   hedgeTrailActive=true;   // the basket is owned and protected from now on (no grid, EA exit level, levels re-applied every tick) — unchanged

   if(one)
   {
      T1DeclareLines(true);
      ApplyClusterExit(netDir,sl);
      return true;
   }
   // [SAFETY S12] two sides: protection FIRST, then T1 is declared only when the broker shows the SL of the net side and the TP of the other side at the lock
   // (HOTFIX declared T1 — t1Locked, "RSI6: T1" line, T1_LOCK row — before sending a single modify)
   ApplyClusterExit(netDir,sl);
   T1DeclareIfConfirmed();
   return true;
}
// [SAFETY S12] the T1 declaration lines (text of the HOTFIX, unchanged): "RSI6: T1 ..." + the RPA T1_LOCK / T1_LOCK_ONE_SIDE journal row of a rebased cycle
void T1DeclareLines(const bool one)
{
   const int netDir=t1Dir; const double sl=hedgeBePrice;
   double vBuy=0.0,vSell=0.0,sumBuy=0.0,sumSell=0.0;
   BasketVolumeSums(vBuy,vSell,sumBuy,sumSell);
   if(!one)
      PrintFormat("RSI6: T1 %s Net | lotB=%.2f lotS=%.2f | BE %.5f | khoa toan cum %.5f (SL ben +, TP ben - cung gia) | dung Grid, KHONG cat | moc T2 %.5f",
                  netDir>0?"Buy":"Sell", vBuy, vSell, hedgeClusterBe, sl, hedgeT1Trigger);
   else
   {
      g_t1OneLocks++;
      PrintFormat("RSI6: T1 %s Net ONE SIDE (lone Lk* of epoch %d) | lotB=%.2f lotS=%.2f | economic BE of the BasketCycleID %.5f | lock = SL of the Lk* %.5f (broker confirmed), no TP side | grid stopped, nothing closed | T2 from %.5f%s",
                  netDir>0?"Buy":"Sell", RpaEpoch(), vBuy, vSell, hedgeClusterBe, sl, hedgeT1Trigger, RpaHaltedLockNote());
   }
   if(RpaHadAny())   // RPA journal: one row per T1 lock of a cycle with a rebase (event, never per tick)
   {
      double re=0.0, fl=0.0, nt=0.0, gr=0.0; const double econ=RpaEconNow(re, fl, nt, gr, false);
      RpaEv(one?"T1_LOCK_ONE_SIDE":"T1_LOCK", StringFormat("%s net %+.2f (BUY %.2f SELL %.2f) | economic BE %.2f = realised %.2f + floating %.2f - exit cost -> economic now %.2f | lock %.2f (BE %s %.0f pip) | T2 from %.2f (BE %s %.0f pip) | %s%s",
                                                   netDir>0?"BUY":"SELL", vBuy-vSell, vBuy, vSell, hedgeClusterBe, re, fl, econ, sl, netDir>0?"+":"-", So_Pip_Doi_SL, hedgeT1Trigger, netDir>0?"+":"-", Khoang_Doi_SL,
                                                   one?"ONE SIDE: SL of the Lk* confirmed by the broker, no opposite TP":"two sides: SL of the net side, TP of the other side at the same price", RpaHaltedLockNote()));
   }
}
// [SAFETY S12] a two-side lock owns and MANAGES the basket exactly as the HOTFIX (no grid, EA exit level, T2 trailing, exits) but T1 is not declared yet.
// (t2Armed may be true: T2 management started on the price while the declaration waited — its line / row are written after the T1 declaration)
bool T1AckPending() { return hedgeTrailActive && !t1Locked && !t1OneSide && t1Dir != 0 && hedgeBePrice > 0.0; }
// [SAFETY S12] T2 started while T1 waited for the broker: the T2 declaration (line + RPA T2_ON row) follows the T1 declaration (current trail level)
void T2DeclareDeferred()
{
   const int dir=t1Dir;
   if(ExitMode()>=EXIT38_T1_TREND)
      PrintFormat("RSI6: T2 trail ON %s (%s) | SL %.5f | lock %.5f | declared after the broker confirmed the T1 lock (SAFETY S12)", dir>0?"BUY":"SELL", Exit38Name(ExitMode()), hedgeExitPrice, hedgeBePrice);
   else
      PrintFormat("RSI6: T2 trail ON %s | SL=gia ± %.0f pip, khong lui duoi khoa %.5f | declared after the broker confirmed the T1 lock (SAFETY S12)", dir>0?"BUY":"SELL", Khoang_Trailing_SL, hedgeBePrice);
   if(RpaHadAny()) RpaEv("T2_ON", StringFormat("%s trail SL %.2f, never below the T1 lock %.2f | two-side lock | declared after the broker confirmed the T1 lock (SAFETY S12)", dir>0?"BUY":"SELL", hedgeExitPrice, hedgeBePrice));
}
// [SAFETY S12] declare the two-side T1 once the broker shows every protective level at (or forward of) the T1 lock; true = T1 declared (now or before)

bool T1DeclareIfConfirmed()
{
   if(t1Locked) return true;
   if(!T1AckPending()) return false;
   int n=0; int sd[]; double ps[], pt[];
   for(int i=PositionsTotal()-1;i>=0;i--)
   {
      const ulong tk=PositionGetTicket(i);
      if(tk==0 || !PositionSelectByTicket(tk) || !IsOursPos()) continue;
      ArrayResize(sd,n+1); ArrayResize(ps,n+1); ArrayResize(pt,n+1);
      sd[n]=PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY?1:-1; ps[n]=PositionGetDouble(POSITION_SL); pt[n]=PositionGetDouble(POSITION_TP); n++;
   }
   if(!Saf38T1ProtectionOk(t1Dir, hedgeBePrice, Ex38Tol(), n, sd, ps, pt))
   {
      g_safT1Pending++;   // tick evaluations
      if(g_safT1PendCyc!=g_cycStartMsc) { g_safT1PendCyc=g_cycStartMsc; g_safT1PendEp++; }
      SafLogOnce(StringFormat("T1ACK_%I64d", g_cycStartMsc), StringFormat("SAFETY T1 PROTECTION PENDING | two-side lock %s at %.5f: the broker does not show every protective level yet (SL of the net side, TP of the other side) -> T1 NOT declared (no 'RSI6: T1' line, no T1_LOCK row, t1Locked false); the basket is owned and managed as before (no grid, EA exit level, T2 trailing, exits), levels re-applied every tick",
                                                                             t1Dir>0?"BUY":"SELL", hedgeBePrice));
      return false;
   }
   t1Locked=true;
   T1DeclareLines(false);
   if(t2Armed) T2DeclareDeferred();
   return true;
}

// V38 R3 FINAL: điều kiện giá T1 của V26 trên tick hiện tại — còn 2 phía, có net, Bid ≥ BE + Khoang_Doi_SL (Buy Net) / Ask ≤ BE − Khoang_Doi_SL
// (Sell Net); lockPx = mức khóa T1 (BE ± So_Pip_Doi_SL). Không gửi gì. TryHedge và cổng ưu tiên DD (Prio38DdState) dùng CHUNG hàm này.
// RPA V1-R2 (D1): "còn 2 phía" — trừ Lk* đơn của epoch tập con đã đối soát (T1OneSideOk); cùng BE kinh tế, cùng khoảng cách, cùng phép so Bid / Ask.
bool T1EligibleNow(int &netDir, double &lockPx)
{
   netDir=0; lockPx=0.0;
   if((CountSide(1)<=0 || CountSide(-1)<=0) && !T1OneSideOk()) return false;

   netDir=BasketNetDir();
   const double be=T1BePrice();   // PAIRA_LOOP: V26 BE khối lượng; BE kinh tế cả chu kỳ khi đã có Progressive PairClose (B7)
   if(netDir==0 || be<=0.0) return false;

   MqlTick tick;
   if(!SymbolInfoTick(_Symbol,tick)) return false;
   const double distDoi=DistDoiGia();
   const double distLock=DistLockPip();
   if(netDir>0)
   {
      if(tick.bid+1e-12<be+distDoi) return false;
      lockPx=PriceN(be+distLock);
   }
   else
   {
      if(tick.ask-1e-12>be-distDoi) return false;
      lockPx=PriceN(be-distLock);
   }
   return true;
}

// Điều kiện T1: đã latch, còn 2 phía, có net, giá qua BE ± Khoang_Doi_SL → LockEntireCluster.
bool TryHedge()
{
   if(!basketModeLatched) return false;
   if(hedgeTrailActive || t1Locked) return false;
   // V38 R3 (R3-02): T1 KHÔNG chờ bản ghi khôi phục lệnh đóng tay (V26 / R2: manualWait hoãn T1) — bảo vệ / chốt lời trước, khôi phục sau
   if(PairPendingAny() || RpaInFlight())   // V38 R2 (Owner B6): chân PairClose còn dở → hoàn tất rồi mới xét T1 (không sửa SL/TP trên ticket đang đóng); RPA: rebase đang thực thi / yêu cầu chưa có kết quả broker cũng vậy
   {
      g_r2T1DefPair++;
      return false;
   }
   int netDir=0; double lockPx=0.0;
   if(!T1EligibleNow(netDir, lockPx)) return false;
   const bool locked=LockEntireCluster(netDir, lockPx);
   // RPA V1-R2: T1 eligible on the lone Lk* but its protection is not confirmed yet -> T1 keeps this tick (no grid level opened on top of the pending lock)
   if(!locked && (CountSide(1)<=0 || CountSide(-1)<=0)) skipGridThisTick=true;
   if(locked) RrGrid("T1_LOCK", CountPositions(), netDir, 0.0, lockPx, hedgeT1Trigger, "");   // LPGD recorder (tester only)
   if(locked) MrOnT1Priority();   // V38 R3: T1 nắm cụm → không gửi yêu cầu khôi phục mới (bản ghi chưa gửi bỏ, đang bay chỉ đối soát)
   return locked;
}

// Mỗi tick sau T1: nếu giá chạm mức thoát thì chốt hết; nếu đi tiếp qua mốc thì T2 kéo SL, không lùi.
void ManageTrailing()
{
   if(!hedgeTrailActive && !t1Locked) return;
   if(CountPositions()<=0) return;

   MqlTick tick;
   if(!SymbolInfoTick(_Symbol,tick)) return;
   int trailDir=t1Dir!=0?t1Dir:hedgeTrailDir;
   if(trailDir==0) trailDir=BasketNetDir();
   if(trailDir==0) return;

   double floorSl=hedgeBePrice;
   if(floorSl<=0.0) return;
   if(hedgeExitPrice<=0.0) hedgeExitPrice=floorSl;

   if(ClusterExitHit(trailDir,hedgeExitPrice))
   {
      const bool undecl=T1AckPending();   // [SAFETY S12] the exit level of an undeclared lock: same exit, the text says that T1 / T2 was never declared
      PrintFormat("RSI6: %s — gia cham muc thoat %.5f, chot het cum%s",
                  t2Armed?"T2":"T1", hedgeExitPrice, undecl?" | T1/T2 CHUA khai bao: broker chua hien du SL/TP (SAFETY S12) - dong theo muc thoat cua EA":"");
      RrGrid("EXIT_HIT", CountPositions(), trailDir, 0.0, hedgeExitPrice, 0.0, t2Armed?"T2":"T1");   // LPGD recorder (tester only)
      if(RpaHadAny()) RpaEv(t2Armed?"T2_EXIT_HIT":"T1_EXIT_HIT", StringFormat("%s exit level %.2f reached (Bid %.2f Ask %.2f) | %s | BASKET_EXITING closes the basket, the cycle resets only when the broker is FLAT",
                                                                         trailDir>0?"BUY":"SELL", hedgeExitPrice, tick.bid, tick.ask, t1OneSide?"one-side lock of the lone Lk*":(undecl?"two-side lock NOT declared (broker protection pending, SAFETY S12)":"two-side lock")));
      CloseBasketR(t2Armed?EXR_T2_HIT:EXR_T1_HIT, EXP_NONE);   // V38 R1: BASKET_EXITING
      return;
   }

   ApplyClusterExit(trailDir,hedgeExitPrice);

   // [SAFETY S12] a two-side lock not yet declared: T1 is declared as soon as the broker shows every protective level. The management below (T2 / trend trailing,
   // exit level) runs EXACTLY as the HOTFIX whether or not T1 is declared yet — only the declarations (T1 / T2 lines, T1_LOCK / T2_ON rows) wait.
   if(T1AckPending() && T1DeclareIfConfirmed()) g_safT1LateDeclared++;

   // TWO-PAIRCLOSE P3: T1 Trend-Aware / T2 Hybrid (OFH38_ExitTrend). LEGACY / T0: mã T2 của V26 dưới đây, không đổi.
   if(ExitMode()>=EXIT38_T1_TREND) { ExitTrailModes(trailDir, tick, floorSl); return; }

   // T2 chỉ khi giá đi tiếp. Quay đầu: giữ khóa, không kéo SL lùi.
   if(hedgeT1Trigger>0.0)
   {
      if(trailDir>0 && tick.bid<=hedgeT1Trigger+1e-12) return;
      if(trailDir<0 && tick.ask>=hedgeT1Trigger-1e-12) return;
   }

   const double dist=DistTrail();
   double want;
   if(trailDir>0)
      want=MathMax(PriceN(tick.bid-dist),floorSl);
   else
      want=MathMin(PriceN(tick.ask+dist),floorSl);
   if(want<=0.0) return;
   if(trailDir>0) want=MathMax(want,hedgeExitPrice);
   else want=MathMin(want,hedgeExitPrice);

   if(!t2Armed)
   {
      t2Armed=true;
      if(t1Locked)   // [SAFETY S12] T1 not declared yet: the T2 declaration follows the T1 declaration (T2DeclareDeferred); the trailing itself starts now (HOTFIX)
      PrintFormat("RSI6: T2 trail ON %s | SL=gia ± %.0f pip, khong lui duoi khoa %.5f",
                  trailDir>0?"BUY":"SELL", Khoang_Trailing_SL, floorSl);
      RrGrid("T2_ON", CountPositions(), trailDir, 0.0, want, floorSl, "");   // LPGD recorder (tester only)
      if(t1OneSide) g_t1OneT2++;
      if(RpaHadAny() && t1Locked) RpaEv("T2_ON", StringFormat("%s trail SL %.2f = price %s %.0f pip, never below the T1 lock %.2f | %s", trailDir>0?"BUY":"SELL", want, trailDir>0?"-":"+", Khoang_Trailing_SL, floorSl, t1OneSide?"one-side lock of the lone Lk*":"two-side lock"));   // [SAFETY S12] t1Locked
   }
   hedgeExitPrice=want;
   ApplyClusterExit(trailDir,want);
}

// (Dự phòng) Nếu mất cờ T2 nhưng còn SL một phía thì bật lại quản lý trailing.
void ReconcileTrailFromPositions()
{
   if(hedgeTrailActive) return;
   if(!basketModeLatched) return;
   // V38 R3 (R3-02): không chờ hàng chờ khôi phục (V26: manualWait) — T2 ưu tiên hơn khôi phục
   if(!t2Armed) return; // Chỉ nhận lại khi đã từng T2, không nhầm SL khóa T1 là trailing
   const int nb=CountSide(1);
   const int ns=CountSide(-1);
   if(nb>0 && ns<=0 && SideHasSl(1))
   {
      hedgeTrailDir=1;
      hedgeTrailActive=true;
      hedgeBePrice=SideBestSl(1);
      hedgeLockMoney=MathMax(0.01,BasketProfitAt(1,hedgeBePrice>0.0?hedgeBePrice:0.0));
      Print("RSI6: RECONCILE doi SL ON tu SL con lai phia BUY");
   }
   else if(ns>0 && nb<=0 && SideHasSl(-1))
   {
      hedgeTrailDir=-1;
      hedgeTrailActive=true;
      hedgeBePrice=SideBestSl(-1);
      hedgeLockMoney=MathMax(0.01,BasketProfitAt(-1,hedgeBePrice>0.0?hedgeBePrice:0.0));
      Print("RSI6: RECONCILE doi SL ON tu SL con lai phia SELL");
   }
}

//+------------------------------------------------------------------+
// DD%: |lỗ nổi| / số dư tài khoản × 100 (cách đo của V26, giữ nguyên từng dòng).
// V38: đạt mức → DD HEDGE LOCK (OFH38_DDLock.mqh): khóa net bằng hedge ngược chiều → nén cân bằng → giữ khóa / dừng chờ Owner.
// Không còn CloseBasket + L1 mới tự động.
//+------------------------------------------------------------------+
// V38 R2: phép đo của V26 tách riêng (các dòng giữ nguyên) để thứ tự PairClose / DD trong tick dùng chung một phép đo.
bool DdThresholdReached(double &pl, double &bal, double &pct)
{
   pl=0.0; bal=0.0; pct=0.0;
   if(!Bat_Cat_DD || Cat_DD_PhanTram<=0.0) return false;
   if(CountPositions()<=0) return false;
   bal=AccountInfoDouble(ACCOUNT_BALANCE);
   if(bal<=0.0) return false;
   pl=BasketProfit();
   if(pl>=0.0) return false;
   const double lossMoney=MathMax(0.0,-pl);
   pct=(lossMoney/bal)*100.0;
   return !(pct+1e-8<Cat_DD_PhanTram);
}
bool TryCutByAccountDd()
{
   double pl=0.0, bal=0.0, pct=0.0;
   if(!DdThresholdReached(pl, bal, pct)) return false;
   // V38 R1 SỬA LỖI V38 Gate 0–6 (harness R1 DDL_NO_OVER_HEDGE): cụm T1/T2 đã chạm mức thoát (hoặc broker đã đóng hết MỘT phía bằng SL/TP thoát)
   // đang THOÁT, không phải DD: phía còn lại chỉ "lỗ" vì phía lãi vừa chốt. Lệnh thoát của V26 đóng nốt (V26: cắt DD cũng đóng hết).
   // Trước đây DD Lock hedge phía còn lại → broker đóng nốt phía đó bằng TP → còn lại cặp hedge vô nghĩa (giữ mãi khi nén tắt).
   if(t1Locked || t2Armed || hedgeTrailActive)
   {
      int dir=(t1Dir!=0)?t1Dir:hedgeTrailDir;
      if(dir==0) dir=BasketNetDir();
      const bool hit=(dir!=0 && hedgeExitPrice>0.0 && ClusterExitHit(dir,hedgeExitPrice));
      // RPA V1-R2: a one-side lock (lone Lk*) never had a second side — "one side already closed" means its own side is gone, not the missing opposite side
      const bool sideGone=t1OneSide ? (dir==0 || CountSide(dir)<=0) : (CountSide(1)<=0 || CountSide(-1)<=0);
      if(hit || sideGone)
      {
         PrintFormat("DD CHECK | %.2f%% >= %.2f%% but the T1/T2 exit is under way (exit %.5f hit=%d, one side already closed=%d) -> the basket is closed by its exit, not hedged",
                     pct, Cat_DD_PhanTram, hedgeExitPrice, hit?1:0, sideGone?1:0);
         CloseBasketR(t2Armed?EXR_T2_HIT:EXR_T1_HIT, EXP_NONE);
         return true;
      }
   }
   // V38 R2 (Owner B5): CHU KỲ đã hòa vốn KINH TẾ (đã chốt từ L1 + nổi + swap + commission / phí >= 0) → không kích hoạt DD mới. Chỉ so tiền.
   double re=0.0, fl=0.0;
   const double econ=R2CycleEconomic(re, fl);
   // V38 R3 FINAL (Owner 23/10/2026, mục 1): T1/T2 ƯU TIÊN HƠN DD% — DD Lock MỚI chỉ khi cụm ở ORIGINAL_GRID_DRAWDOWN (OFH38_Precedence_Core: kết quả broker
   // chưa rõ / thoát đã cam kết / T1-T2 đã khóa hoặc đủ điều kiện NGAY tick này / PairClose dở / khôi phục đang bay / lot thừa đang đóng → không DD mới).
   // V38 R2 (Owner B2 / B4 / B5) giữ log + bộ đếm: chân PairClose dở → đóng nốt cặp trước; chu kỳ đã hòa vốn kinh tế → không DD mới.
   bool t1Elig=false;
   const int prio=Prio38DdState(pl, econ, t1Elig);
   if(prio==PRIO_PAIR_CLOSE_PENDING) R2DdDeferred(1, pct, 0.0, 0.0, 0.0);
   else if(prio==PRIO_OTHER && Econ38BlocksDd(econ)) R2DdDeferred(2, pct, econ, re, fl);
   if(!Prio38DdMayStart(prio)) { Prio38DdBlocked(prio, pct, t1Elig); return false; }
   g_prLast=prio; g_prStarted++;
   return DdlActivate(pl, bal, pct);
}

// 60 phút cuối cửa sổ: ≤N lệnh đóng hết + chờ; >N và lãi (CloseProtect_CloseProfitAboveMax, luật V26, xét mọi tick trong 60 phút cuối) đóng + chờ;
// >N còn lại → V38 SESSION_BASKET_RESCUE (cụm xử lý tiếp sau giờ phiên). Cụm đã RESCUE không bị áp lại luật ≤N (kể cả khi PairClose làm ≤N).
// OWNER12 (Owner 25/10/2026 mục 3, nhóm CHỐT PHIÊN): quyết định = O12SessionDecision (thuần, unit test bảng (d)):
//   (a) chu kỳ CHƯA từng Progressive PairClose: <= CloseProtect_MaxOrders vị thế → đóng hết + đối soát broker (BASKET_EXITING) + nghỉ; > N → SESSION_BASKET_RESCUE: tiếp tục
//       Grid của chiến lược đã chọn sau giờ phiên tới điều kiện thoát (T1 / T2 / ...), không L1 mới; KHÔNG đóng chỉ vì cụm dương ít (bool cũ đã gỡ);
//   (b) ĐÃ từng (cờ HadAnyProgressivePairClose lưu bền qua khởi động lại / rebase / các vòng): mọi số vị thế — CycleEconomicPnL (đã chốt + nổi + swap + phí
//       − chi phí đóng ước tính, sổ deal khử trùng) >= −pct % × equity lúc kiểm → đóng hết + nghỉ; lỗ lớn hơn → tiếp tục quản lý / Rescue Grid, không L1 song song;
//       pct = giá trị ĐÃ CHỐT của chu kỳ = CloseProtect_UsePairACycleLossPct ? CloseProtect_PairACycleMaxLossPct : 0;
//   (c) yêu cầu PairA (nén / trung hòa / hedge) hoặc chân đóng dở đang bay → đối soát trước, không đóng chồng (BASKET_EXITING đã nắm cụm thì không tới đây).
bool TrySessionCloseProtect(const int total)
{
   if(total<=0) return false;
   const bool nearEnd=IsNearTradingEnd();
   if(!nearEnd) return false;
   const bool inFlight=RpaInFlight() || PairPendingAny();   // RPA: a committed rebase / unresolved request is reconciled first (no close on top of it)
   const bool had=RpaHadAny();                               // RPA: a cycle with a rebase = "cycle with PairClose" (economic P/L rule)
   double econ=0.0, eq=AccountInfoDouble(ACCOUNT_EQUITY);
   if(had && !inFlight) RpaSessionMayClose(econ, eq);
   const double pct=ClGet(CL_SESS);
   const int dec=O12SessionDecision(nearEnd, inFlight, had, total, CloseProtect_MaxOrders, sessionRescue, econ, eq, pct);
   switch(dec)
   {
      case O12S_DEFER:
         g_o12SessDefer++;
         return false;
      case O12S_CLOSE_PAIRA:
         PrintFormat("=== CLOSE WINDOW | RPA cycle (epoch %d, %d positions) | economic P/L %.2f >= -%.3f%% x equity %.2f = %.2f | CAT HET + WAIT NEXT SESSION ===",
                     RpaEpoch(), total, econ, pct, eq, -pct/100.0*eq);
         CloseBasketR(EXR_SESSION_PAIRA, EXP_WAIT_NEXT_SESSION);
         return true;
      case O12S_RESCUE_PAIRA:
         if(!sessionRescue) SetSessionRescue(true, StringFormat("CLOSE WINDOW PAIRA cycle (%d positions): economic loss %.2f < -%.3f%% x equity %.2f = %.2f -> keep managing (rescue), no parallel L1", total, econ, pct, eq, -pct/100.0*eq));
         return false;
      case O12S_CLOSE_LE_N:
         PrintFormat("=== CLOSE WINDOW | total=%d <= %d (no Progressive PairClose in this cycle) | CAT HET + WAIT NEXT SESSION ===", total, CloseProtect_MaxOrders);
         // V38 R1: BASKET_EXITING — khi broker phẳng thật: ResetCycleState + chờ phiên sau (như V26), kể cả khi xong sau 60 phút cuối
         CloseBasketR(EXR_SESSION_LE_N, EXP_WAIT_NEXT_SESSION);
         return true;
      case O12S_RESCUE:
         if(!sessionRescue) SetSessionRescue(true, StringFormat("CLOSE WINDOW total=%d > %d (no Progressive PairClose in this cycle) floating=$%.2f -> the grid of the selected strategy continues to an exit", total, CloseProtect_MaxOrders, BasketProfit()));
         return false;
   }
   return false;
}

// RPA (Owner 31/10/2026 §10): PairPendingPump (đóng nốt chân PairClose V26 cũ do bản cũ ghi lại) ĐÃ GỠ khỏi runtime — xem REMOVED_LEGACY_PAIRCLOSE_PATHS.md.
// [DPMR R1] D02: PairPendingPump có lại cho PairClose_Mode 0 (định nghĩa cạnh CloseTwoLatest).

// Khoảng giá phải đi khỏi entry cũ (ít nhất 1 pip hoặc spread) trước khi được về vào lại.
double ManualLeaveDist()
{
   return MathMax(SpreadNow()+_Point, ToPrice(1.0));
}

// Giá so với entry khi chờ vào lại: BUY dùng Ask, SELL dùng Bid.
double ManualMarkPx(const int posType)
{
   if(posType==POSITION_TYPE_BUY) return SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   return SymbolInfoDouble(_Symbol, SYMBOL_BID);
}

// Đọc deal chốt tay: chiều, giá vào cũ, lot — để chờ giá về entry rồi vào lại.
// [MRR R1] M07: HistoryDealSelect() REPLACES the deal list of the program by that single deal (MT5): calling it inside the scan of the HistorySelect list ended the
// scan at the newest deal, so a manual close that is not the newest deal of the window (several closes processed together / a close processed after a new fill)
// was "not readable" -> GRID FROZEN DEAL_UNREADABLE, and the newest one took its CLOSE price as the original entry. The deal is read from the list, the fallback
// price is read while the deal is selected, and the deal is selected again for the caller.
bool GetClosedDealOpenInfo(const ulong deal,int &posType,double &openPx,double &vol)
{
   vol=HistoryDealGetDouble(deal,DEAL_VOLUME);
   const long dtype=HistoryDealGetInteger(deal,DEAL_TYPE);
   posType=(dtype==DEAL_TYPE_SELL)?POSITION_TYPE_BUY:POSITION_TYPE_SELL;
   const ulong posId=(ulong)HistoryDealGetInteger(deal,DEAL_POSITION_ID);
   const double closePx=HistoryDealGetDouble(deal,DEAL_PRICE);   // [MRR R1] M07: read while the deal is selected
   openPx=0.0;
   const datetime tClose=(datetime)HistoryDealGetInteger(deal,DEAL_TIME);
   HistorySelect(tClose-30*86400, tClose+60);
   const int n=HistoryDealsTotal();
   for(int i=n-1;i>=0;i--)
   {
      const ulong d=HistoryDealGetTicket(i);
      if(d==0) continue;   // [MRR R1] M07: no HistoryDealSelect inside the scan (it would replace the list)
      if((ulong)HistoryDealGetInteger(d,DEAL_POSITION_ID)!=posId) continue;
      const long en=HistoryDealGetInteger(d,DEAL_ENTRY);
      if(en!=DEAL_ENTRY_IN && en!=DEAL_ENTRY_INOUT) continue;
      openPx=HistoryDealGetDouble(d,DEAL_PRICE);
      if(openPx>0.0) break;
   }
   if(openPx<=0.0)
      openPx=closePx;
   HistoryDealSelect(deal);   // [MRR R1] M07: the caller reads the deal again
   return (openPx>0.0 && vol>0.0);
}

// V38 R2: ArmManualWait / TryFillManualReentry / HandleManualClose của V26 (một bản ghi chung, vào lại bằng TrySendOrder(CountPositions()+1),
// xóa nhớ ngay khi TrySendOrder trả true) đã thay bằng hàng chờ OFH38_ManualRecovery: MrOnManualClose (một bản ghi / deal đóng tay),
// MrPumpSend (xác nhận riêng từng bản ghi, gửi đúng khối lượng còn thiếu), MrReconcile (xóa chỉ sau khi lịch sử deal xác nhận đủ lot).

// V38 R1: chốt tay. Một PHẦN (vị thế vẫn còn) → V26 vào lại phần đã chốt thành lệnh THÊM: đếm lệnh +1 → chỉ số level (V26 và nhóm GLOBAL)
// lệch một level, lot / bước của level kế tiếp sai. ManualPartial_FreezeGrid: không thêm level cho cụm này nữa (thoát / T1 / T2 / PairClose / DD
// vẫn chạy); cờ lưu bền theo cụm. Không có sổ level riêng. R2: phát hiện ở MrOnManualClose (trước khi tạo bản ghi).
bool PositionOpenById(const ulong posId, double &vol)
{
   vol=0.0;
   if(posId==0) return false;
   for(int i=0;i<PositionsTotal();i++)
   {
      const ulong t=PositionGetTicket(i);
      if(t==0 || !PositionSelectByTicket(t) || !IsOursPos()) continue;
      if((ulong)PositionGetInteger(POSITION_IDENTIFIER)==posId) { vol=PositionGetDouble(POSITION_VOLUME); return true; }
   }
   return false;
}
void V38OnManualClose(const ulong deal)
{
   if(MrrStaleCloseOfFinishedCycle(deal, "EVENT")) return;   // [MRR R1] M02: an event of a FINISHED cycle processed after a new basket started: recorded only
   RpaOnManualClose(deal);           // RPA: đóng tay trong rebase / SubGridEpoch → RPA HALT (fail-closed), deal xử lý như R3 FINAL
   MrOnManualClose(deal, "EVENT");   // V38 R2: một bản ghi độc lập (đóng một phần → cờ lệch chỉ số như R1), không ghi đè bản ghi khác
}

// Bắt deal đóng: chốt tay → chờ vào lại; SL/TP T1/T2 → chốt nốt cụm; TP L1 lẻ → đóng phần còn.
// V38 R1: phần thân giữ nguyên tên gọi cũ (V38OnTradeTransactionBody); sau đó lưu bền trạng thái chu kỳ nếu có thay đổi.
void OnTradeTransaction(const MqlTradeTransaction &trans,
                        const MqlTradeRequest &request,
                        const MqlTradeResult &result)
{
   RrTrade(trans);   // OWNER12: bộ ghi nghiên cứu (chỉ tester) — deal stop-out = BANKRUPT
   // [SAFETY S08] a deal event before the persisted state is restored (account not known at OnInit): restore first (as the first tick does); still not possible ->
   // the deal is only recorded (the history scan / restore reconciles it) and no record is written from the unrestored memory
   // [STARTUP SAFETY R3] U01: the pending restore runs only on a PROVEN broker state (evaluated on every deal event); not proven -> the deal is reconciled by the restore later
   if(v38RestorePending && !Su3TryRestore("DEAL", trans.type==TRADE_TRANSACTION_DEAL_ADD))
   {
      if(trans.type==TRADE_TRANSACTION_DEAL_ADD) PrintFormat("V38 SAFETY | deal %I64u before the restore (%s): recorded only, reconciled after the restore", trans.deal, g_su3Verdict < 0 ? "account not known" : Su3Name(g_su3Verdict));
      return;
   }
   V38OnTradeTransactionBody(trans, request, result);
   CycPersistIfChanged();
}
void V38OnTradeTransactionBody(const MqlTradeTransaction &trans,
                               const MqlTradeRequest &request,
                               const MqlTradeResult &result)
{
   if(trans.type!=TRADE_TRANSACTION_DEAL_ADD) return;
   if(request.symbol!="" && request.symbol!=_Symbol) return;
   ulong deal=trans.deal;
   if(deal==0) deal=result.deal;
   if(deal==0) return;
   if(!HistoryDealSelect(deal))
   {
      datetime now=TimeCurrent();
      HistorySelect(now-86400, now+60);
      if(!HistoryDealSelect(deal)) return;
   }
   if(HistoryDealGetString(deal, DEAL_SYMBOL)!=_Symbol) return;
   // V38 R2: OWNER_REQUIRED (bản ghi xung đột sau khởi động lại) → chỉ ghi nhận, không xử lý gì
   if(g_authOwnerReq) { PrintFormat("R2 OWNER_REQUIRED | deal %I64u recorded only", deal); return; }
   const long entry=HistoryDealGetInteger(deal, DEAL_ENTRY);
   // V38: DD Lock đang nắm cụm → chỉ ghi nhận deal (Magic / DDLock_HedgeMagic); xử lý chốt tay / T1-T2 / TP của V26 không chạy (sẽ phá khóa)
   if(DdlActive())
   {
      const ulong dealMagic=(ulong)HistoryDealGetInteger(deal, DEAL_MAGIC);
      if(dealMagic==Magic || dealMagic==DDLock_HedgeMagic) DdlOnDeal(deal);
      if(dealMagic==Magic && entry==DEAL_ENTRY_IN) MrOnEntryDeal(deal);   // R2: fill of a recovery request sent before the lock (reconciled, part of the basket)
      return;
   }
   // [MRR R1] M03: a manual close from the terminal may carry the magic of its own closing order: the deal belongs to the basket when its position was opened by the EA
   if((ulong)HistoryDealGetInteger(deal, DEAL_MAGIC)!=Magic && !MrrForeignMagicManualClose(deal)) return;
   // V38 R1: BASKET_EXITING nắm cụm → deal (SL/TP broker, lệnh đóng của EA, chốt tay) chỉ được ghi nhận; không kích hoạt xử lý V26 nào khác
   if(ExActive())
   {
      ExOnDeal(deal);
      if(entry==DEAL_ENTRY_IN) MrOnEntryDeal(deal);   // R2: late recovery fill → reconciled; ExPump closes the position with the basket
      return;
   }

   if(entry==DEAL_ENTRY_IN) { MrOnEntryDeal(deal); return; }   // R2: recovery fill → that record is reconciled now (the history decides)
   if(entry!=DEAL_ENTRY_OUT && entry!=DEAL_ENTRY_INOUT && !(entry==DEAL_ENTRY_OUT_BY && Mr38IsManualReason(Mr38DealReason(deal)))) return;   // [MRR R1] M03: + a manual "Close By" (OUT_BY, manual reason only)

   const long reason=Mr38DealReason(deal);   // R2: = DEAL_REASON (bản kiểm thử: harness đánh dấu deal "đóng tay")
   if(reason==DEAL_REASON_CLIENT || reason==DEAL_REASON_MOBILE || reason==DEAL_REASON_WEB)
   {
      V38OnManualClose(deal);
      return;
   }
   // R3: a broker SL / TP / stop-out removing a position no longer freezes the grid after a recovery — the level book drops exactly that position
   if((reason==DEAL_REASON_SL || reason==DEAL_REASON_SO || reason==DEAL_REASON_TP) &&
      (t1Locked || t2Armed || hedgeTrailActive) && CountPositions()>0)
   {
      Print("RSI6: T1/T2 — dính muc thoat, chot het cum con lai");
      CloseBasketR(EXR_T1T2_BROKER, EXP_NONE);   // V38 R1: BASKET_EXITING
      return;
   }
   if(reason==DEAL_REASON_TP && CountPositions()>0)
   {
      if(basketModeLatched)
      {
         Print("RSI6: TP le sau latch — xoa TP con lai, KHONG dump ca cum");
         ClearTpOnPositions(1);
         ClearTpOnPositions(-1);
         return;
      }
      Print("RSI6: TP le khi van con position — dong nốt cu, quay ve L1 nen hien tai");
      CloseBasketR(EXR_L1_TP_EXTRA, EXP_SKIP_GRID);   // V38 R1: BASKET_EXITING
      skipGridThisTick=true;
      return;
   }
}

//+------------------------------------------------------------------+
// Mỗi tick: phiên → DD → đóng phiên → L1 mới nếu hết lệnh → latch → T1/T2 → Pair Close → grid.
// V38 R1: OnTick = phần thân (V38OnTickBody) + lưu bền trạng thái chu kỳ V26 khi có thay đổi.

void OnTick()
{
   if(TimeCurrent() - LastApiSyncTime >= 60)
   {
      LastApiSyncTime = TimeCurrent();
      IsApiAllowed = SyncSettingsFromCloud();
   }
   if(!IsApiAllowed)
   {
      Comment(StringFormat("\n=========================================\n" +
                           " [ONEFXHUB CLOUD] CHƯA KÍCH HOẠT LICENSE!\n" +
                           " - Trạng thái: %s\n" +
                           " - Hướng dẫn: Nhấn F7 để nhập LicenseKey trong mục Inputs.\n" +
                           " - Tự động thử lại sau: %d giây...\n" +
                           "=========================================",
                           (LicenseKey == "" ? "Chưa nhập LicenseKey" : "License không hợp lệ hoặc Bot bị tạm dừng"),
                           (int)MathMax(0, 60 - (TimeCurrent() - LastApiSyncTime))));
      return;
   }
   Comment("");

   V38OnTickBody();
   Rsi2Tick();   // [RSI SAFETY R2] S04: PROTECTIVE_ONLY phase log (nothing when RSI_Period >= 2)
   if(!v38RestorePending) CycPersistIfChanged();   // [SAFETY S08] never from an unrestored memory (account still not known on this tick)
   AuthTick();                         // V38 R2: log mỗi lần cơ chế nắm cụm đổi
   g_mrLastCount = CountPositions();   // V38 R2: số vị thế cuối tick (phát hiện đóng tay bị lỡ event ở tick sau)
   if(g_mrLastCount > 0) MrrNoteSeen();   // [MRR R1] M04: positions of the running cycle seen (only such a cycle is finalized when flat; their ids are never late fills)
   if(!v38RestorePending) LbSync();    // V38 R3: sổ cấp = vị thế cuối tick (deal đóng tay xử lý ở tick sau vẫn tra được cấp gốc)
   RrTick();                           // OWNER12: bộ ghi nghiên cứu (chỉ tester, sau mọi quyết định của tick)
}

void V38OnTickBody()
{
   skipGridThisTick=false;
   // V38 — khôi phục trạng thái lưu bền còn chờ (tài khoản chưa biết lúc OnInit): chưa xong thì không quyết định gì
   // [STARTUP SAFETY R3] U01: the pending restore runs only on a PROVEN broker state (identity alone is no proof of synchronised lists); not proven -> nothing on this tick
   if(v38RestorePending && !Su3TryRestore("TICK", false)) return;
   // P1 — Đếm lệnh đang mở
   int total=CountPositions();
   OrderCount=total;
   const bool mrrAdopt=(total>0 && g_cycStartMsc<=0);   // [MRR R1] M04: positions found while no cycle of the EA runs (late-fill rule after the reconciliation steps)
   if(total>0 && g_cycStartMsc<=0) g_cycStartMsc=CycStartMsc();   // V38 R2: ID chu kỳ cố định (bản ghi khôi phục, lãi/lỗ kinh tế chu kỳ)
   ClTick(total);   // PAIRA_LOOP: chốt cấu hình của chu kỳ (một lần / chu kỳ, Owner B8)
   // V38 GLOBAL — quan sát Ask/Bid của tick này cho biên các nhóm đang mở (mọi tick, kể cả khi Grid không chạy)
   GgObserve();

   // V38 R2 (E.2) — OWNER_REQUIRED: bản ghi khởi động lại xung đột, broker không chứng minh được bên nào → không gửi yêu cầu nào
   if(g_authOwnerReq)
   {
      AuthOwnerRequiredTick();
      if(total<=0) MrrL1Blocked("OWNER_REQUIRED", g_authOwnerWhy);   // [MRR R1] M06 log
      return;
   }

   // V38 DD HEDGE LOCK — đang khóa / nén / giữ khóa / dừng: Grid, T1/T2, PairClose, đóng phiên, L1 mới KHÔNG tác động lên cụm
   if(DdlActive())
   {
      MrReconcileAll();   // R2: chỉ đối soát yêu cầu khôi phục đang bay (bản ghi khác SUSPENDED)
      DdlManage();
      Prio38DdHoldsT1Watch();   // V38 R3 FINAL (mục 1.5): DD khớp TRƯỚC khi T1 đủ điều kiện → giữ khóa, không tự tháo hedge; BLOCKER một lần / đợt
      if(DdlActive() && CountPositions()<=0) MrrL1Blocked("DD_LOCK_" + DdlStateName(g_ddlState), "the DD lock owns the account state (a flat basket after a DD lock is HALT until a verified Owner full manual close releases it - DPMR R1 D04 - or the Owner decides)");   // [MRR R1] M06 log; [DPMR R1] text
      return;
   }

   // V38 R1 BASKET_EXITING — đợt thoát đã quyết định nắm cụm tới khi broker phẳng thật: không Grid, không PairClose, không L1 trong tick này
   if(ExActive())
   {
      MrReconcileAll();   // R2: yêu cầu khôi phục đang bay lúc cam kết thoát → đối soát (fill trễ = vị thế của cụm, được đóng)
      ExPump();
      if(ExActive() && g_mrrAwaitL1) MrrL1Blocked("BASKET_EXITING", StringFormat("%s: EA positions %d, waiting until the broker shows the basket flat and every request is reconciled", ExReasonName(g_exReason), CountPositions()));   // [MRR R1] M06 log
      return;
   }

   // V38 R2 — đóng tay bị lỡ OnTradeTransaction (số vị thế giảm / mỗi 60 s) + đối soát yêu cầu khôi phục đang bay;
   // fill trễ của chu kỳ đã kết thúc → đóng ngay (không thành L1 mới)
   MrScanIfNeeded(total);
   MrReconcileAll();
   if(MrOrphanGuard()) return;
   total=CountPositions();
   OrderCount=total;
   // [MRR R1] M04: positions that appeared after the finalized cycle without an L1 of the EA: a late fill of the finished cycle is closed, never adopted as a new L1
   if(mrrAdopt && total>0 && MrrLateFillGuard()) return;
   // RPA (Owner 31/10/2026 §10): PairPendingPump (chân của PairClose V26 cũ) và PaOrphanGuard (hedge PairA) KHÔNG còn trong runtime — RPA không bao giờ mở vị thế
   // để nén; bản ghi chân dở của bản cũ bị xóa khi khôi phục (V38RestoreModules, cảnh báo LEGACY_PAIR_PENDING_IGNORED).
   // [DPMR R1] D02: PairClose_Mode 0 — V38 R2 (Owner B2 / B4 / B6) PAIR_CLOSE_PENDING: cặp đã quyết định được đóng nốt TRƯỚC DD, T1/T2, đóng phiên, Grid, L1
   // (bản R3 FINAL). Mode 1 không có chân dở (không quyết định cặp; bản ghi của bản cũ bị xóa khi khôi phục) → khối này không chạy.
   if(PairPendingAny())
   {
      PairPendingPump();
      total=CountPositions();
      OrderCount=total;
      if(total<=0)
      {
         ResetCycleState();
         return;
      }
   }

   // P2 — Đang nghỉ chờ phiên sau thì không làm gì
   if(WaitNextSession)
   {
      if(TimeCurrent()>=WaitUntilTime && IsInTradingHours())
      {
         WaitNextSession=false;
         PrintFormat("=== Bot hoat dong tro lai | Local=%02d:%02d GMT+%d | %s ===",
                     GetLocalHour(), GetLocalMinute(), LocalGMT,
                     EnumToString(GetLocalDayOfWeek()));
      }
      else { if(total<=0) MrrL1Blocked("WAIT_NEXT_SESSION", StringFormat("session close rest until %s (server)", TimeToString(WaitUntilTime, TIME_DATE|TIME_MINUTES))); return; }   // [MRR R1] M06 log
   }

   const bool in_hours=IsInTradingHours();
   const bool near_end=IsNearTradingEnd();

   // P3 — Cắt cụm nếu lỗ nổi / số dư ≥ Cat_DD_PhanTram
   // V38 R3 FINAL: DD Lock MỚI chỉ ở ORIGINAL_GRID_DRAWDOWN — T1/T2 đã khóa hoặc đủ điều kiện ở tick này thắng DD (TryHedge ở P9 khóa T1 cùng tick)
   if(total>0)
   {
      // [DPMR R1] D03 (PairClose_Mode 0, bản V38 R3 FINAL): V38 R2 (Owner B3): DD đạt ngưỡng VÀ một cặp PairClose đủ điều kiện trong cùng tick → cặp (quyền đóng PAIR)
      // được quyết định và gửi TRƯỚC, DD quyết định sau trên phần còn lại (hoặc chờ khi còn chân dở). Mode 1: PairQualifiesNow luôn false → thứ tự MRR R1.
      double pl0=0.0, bal0=0.0, pct0=0.0;
      if(PcMode()==DPMR_PC_V26 && Rsi2Allowed(g_rsiProt, RSI2_ACT_PAIR_DECISION) && !PairPendingAny() && DdThresholdReached(pl0, bal0, pct0) && PairQualifiesNow(total))   // [RSI SAFETY R2] S02: no NEW pair in PROTECTIVE_ONLY (DD decides alone)
      {
         g_r2PairFirst++;
         PrintFormat("R2 PRECEDENCE (B3) | DD %.2f%% >= %.2f%% and PairClose L%d+L%d qualifies on the same tick -> the pair is decided first, DD decides on the remaining basket",
                     pct0, Cat_DD_PhanTram, total-1, total);
         RunPairCloseIfNeeded(total);
         if(total<=0)
         {
            ResetCycleState();
            return;
         }
      }
      if(TryCutByAccountDd()) return;
      total=CountPositions();
      OrderCount=total;
      if(total<=0)
      {
         ResetCycleState();
         return;
      }
   }

   // P4 — 60 phút cuối phiên: đóng cụm nhỏ / cụm lãi, cụm lớn còn lỗ thì giữ
   if(TrySessionCloseProtect(total)) return;
   total=CountPositions();
   OrderCount=total;

   // P5 — Hết lệnh: xóa nhớ chốt tay, vào L1 mới theo RSI nến đã đóng (không đợi nến mới)
   // RPA §9: BasketCycleID cũ CLOSED khi FLAT thật (ResetCycleState → RpaOnCycleReset); L1 kế = BasketCycleID mới, SubGridEpoch 0, L1 gốc của V26 / GLOBAL Mode 1
   if(total<=0)
   {
      ResetCycleState();
      // V38 R2: yêu cầu khôi phục của chu kỳ vừa kết thúc còn đang bay → chưa mở L1 (fill trễ của nó sẽ bị coi là L1 mới) — đối soát trước
      if(MrAnyCancelReconcile())
      {
         MrLogOnce("L1WAIT_" + TimeToString(TimeCurrent(), TIME_DATE|TIME_MINUTES), "MR | no new L1: a recovery request of the finished cycle is still being reconciled");
         MrrL1Blocked("RECONCILIATION_PENDING", "an old recovery request of the finished cycle is reconciled first (a late fill of it is closed, never a new L1)");   // [MRR R1] M06 log
         return;
      }
      // V38 R3 FINAL (test I): một lệnh Magic của symbol còn làm việc trên broker (PLACED / chờ khớp) có thể khớp và thành vị thế của chu kỳ mới → chưa mở L1
      if(Prio38OrderWorking())
      {
         g_prL1WaitOrder++;
         MrLogOnce("L1WAITORD_" + TimeToString(TimeCurrent(), TIME_DATE|TIME_MINUTES), "R3F | no new L1: a Magic order of the symbol is still working at the broker (it may fill) - waiting for its result");
         MrrL1Blocked("MAGIC_ORDER_WORKING", "an order of the EA still works at the broker: its result first (a fill of it after the finalization is closed, never a new L1)");   // [MRR R1] M06 log
         return;
      }
      // [RSI SAFETY R2] S02 / S03: PROTECTIVE_ONLY - the old BasketCycleID is finalized (ResetCycleState) and the requests above are reconciled first; then NO new L1
      if(!Rsi2Allowed(g_rsiProt, RSI2_ACT_NEW_L1))
      {
         Rsi2Blocked(RSI2_ACT_NEW_L1, "basket flat, old BasketCycleID finalized, nothing in flight");
         MrrL1Blocked("CONFIG_RSI_PERIOD_PROTECTIVE_ONLY", StringFormat("RSI_Period=%d < 2: no new L1 until the Owner sets RSI_Period >= 2 (never replaced by 5)", RSI_Period));   // [MRR R1] M06 log
         return;
      }
      if(!in_hours || near_end)
      {
         static datetime last_log=0;
         if(TimeCurrent()-last_log>300)
         {
            PrintFormat("No L1 | local=%02d:%02d | in_hours=%s near_end=%s",
                        GetLocalHour(), GetLocalMinute(),
                        in_hours?"Y":"N", near_end?"Y":"N");
            last_log=TimeCurrent();
         }
         MrrL1Blocked(!in_hours ? "OUT_OF_SESSION" : "NEAR_SESSION_END", StringFormat("local %02d:%02d (Session Manager unchanged)", GetLocalHour(), GetLocalMinute()));   // [MRR R1] M06 log
         return;
      }

      if(CopyBuffer(hRSI,0,1,1,rsiVal)<=0) { MrrL1Blocked("RSI_UNAVAILABLE", StringFormat("CopyBuffer of the RSI handle failed (error %d)", GetLastError())); return; }   // [MRR R1] M06 log
      double rsi=rsiVal[0];
      if(!L1Rsi38ValueValid(rsi)) { MrrL1Blocked("RSI_INVALID", "RSI value outside 0..100"); return; }   // [MRR R1] M06 log; [L1RSI R1] R03: same test, [L1RSI CORE]

      const int rsiSide=L1Rsi38Side(rsi);   // [L1RSI R1] R03: the V26 mapping, text moved verbatim to [L1RSI CORE]
      bool isBuy  = (rsiSide>0);
      bool isSell = (rsiSide<0);
      if(!isBuy && !isSell) return;

      double lot=CalcLot(0);
      if(!GlGridSendable(1, lot, isBuy)) { MrrL1Blocked("VOLUME_OR_MARGIN", StringFormat("L1 lot %.2f outside the broker limits / not enough margin (blocker logged by the lot check)", lot)); return; }   // PAIRA_M2: lot ngoài giới hạn broker / thiếu margin → không gửi lệnh chắc chắn bị từ chối mỗi tick
      if(!TrySendOrder(isBuy, lot, 1)) { MrrL1Blocked(g_safSendHeld ? "ENTRY_HOLD_BROKER_EVIDENCE" : "L1_REQUEST_NOT_DONE", g_safSendHeld ? "an entry request without a broker result / a working order of the EA: no second request (SAFETY S02)" : "the L1 request was not executed (retcode logged above); tried again on the next eligible tick"); return; }   // [MRR R1] M06 log

      FirstPrice=trade.ResultPrice();
      if(FirstPrice==0) FirstPrice=isBuy?SymbolInfoDouble(_Symbol, SYMBOL_ASK)
                                         :SymbolInfoDouble(_Symbol, SYMBOL_BID);
      FirstType=isBuy?POSITION_TYPE_BUY:POSITION_TYPE_SELL;
      OrderCount=1;
      basketModeLatched=false;
      g_cycStartMsc=Ex38TickMsc();   // V38 R1: lãi/lỗ kinh tế của chu kỳ tính từ lúc khớp L1
      MrrOnNewL1(trade.ResultOrder());   // [MRR R1] M04: the finished cycle is over (its late-fill rule ends with the EA's own new L1); M02: first order of the new basket
      GgOnFill(1, FirstPrice);   // V38 GLOBAL: nhóm 0 neo tại L1
      RrGrid("L1", 1, isBuy?1:-1, lot, FirstPrice, 0.0, StringFormat("RSI %.1f", rsi));   // LPGD recorder (tester only)
      PrintFormat("=== L1 %s @ %.2f lot=%.2f RSI=%.1f | local=%02d:%02d ===",
                  isBuy?"BUY":"SELL", FirstPrice, lot, rsi,
                  GetLocalHour(), GetLocalMinute());
      // [L1RSI R1] R04 log only (after the order: the L1 request is not delayed): the closed bar the value belongs to, and whether the indicator covered the series
      PrintFormat("L1 RSI SIGNAL | iRSI(%s, %s, %d, PRICE_CLOSE) shift 1 = last closed bar %s | RSI %.2f -> %s (%s) | bars calculated %d / series %d",
                  _Symbol, EnumToString(RSI_TF), RSI_Period, TimeToString(iTime(_Symbol, RSI_TF, 1), TIME_DATE|TIME_MINUTES), rsi, isBuy?"BUY":"SELL", L1Rsi38BandName(rsi),
                  BarsCalculated(hRSI), Bars(_Symbol, RSI_TF));
      return;
   }

   if(FirstPrice==0)
   {
      GetFirstPosition(FirstPrice, FirstType);
      if(FirstPrice==0) return;
   }

   // P6 — Từ 2 lệnh: latch, xóa TP/%YP của L1
   if(total>=2)
      LatchBasketMode();

   // P7 — Đã T1/T2: chỉ quản lý mức thoát, không grid / không Pair Close
   ReconcileTrailFromPositions();
   if(hedgeTrailActive || t1Locked)
   {
      // V38 R3 (R3-02): T1/T2 nắm cụm → không gửi yêu cầu khôi phục mới. Yêu cầu đang bay chỉ được đối soát (MrReconcileAll ở đầu tick).
      MrOnT1Priority();
      ManageTrailing();
      total=CountPositions();
      OrderCount=total;
      if(total<=0)
      {
         ResetCycleState();
         return;
      }
      return;
   }

   // P8 — RECURSIVE PAIR_A REBASE V1 (Owner 31/10/2026): bộ điều khiển PairClose DUY NHẤT (trước T1 trên tick; T1 đủ điều kiện cùng tick → T1 thắng, RpaTryRebase).
   // true = RPA nắm cụm ở tick này (rebase đang thực thi / vừa đối soát / HALTED) → không thêm cấp Grid.
   // [DPMR R1] D01: the latched PairClose mode of the cycle selects ONE controller: 0 = V26 Legacy PairClose (P8 of V26 / R3 FINAL; RPA is never called -> stays IDLE),
   // 1 = RPA exactly as MRR R1 (RunPairCloseIfNeeded is never called)
   bool paOwns=false;
   // [RSI SAFETY R2] S02: PROTECTIVE_ONLY - no NEW legacy pair (mode 0; a pending leg was finished above by PairPendingPump) and no NEW rebase (mode 1; a committed
   // rebase is finished / a HALTED cycle reconciled by Rsi2RpaTickNoRebase). RSI_Period >= 2: Rsi2Allowed = true, the DPMR R1 dispatch unchanged
   if(PcMode()==DPMR_PC_V26) { if(Rsi2Allowed(g_rsiProt, RSI2_ACT_PAIR_DECISION)) RunPairCloseIfNeeded(total); else if(PairQualifiesNow(total)) Rsi2Blocked(RSI2_ACT_PAIR_DECISION, StringFormat("legacy pair L%d+L%d qualifies: not closed (no new structure)", total-1, total)); }
   else paOwns=Rsi2Allowed(g_rsiProt, RSI2_ACT_RPA_REBASE) ? RpaTick(total) : Rsi2RpaTickNoRebase(total);
   total=CountPositions();
   OrderCount=total;
   if(total<=0)
   {
      ResetCycleState();
      return;
   }

   // P9 — Thử T1 (khóa cả cụm, không cắt)
   if(basketModeLatched)
   {
      TryHedge();
      total=CountPositions();
      OrderCount=total;
      if(hedgeTrailActive || t1Locked) return;
      if(total<=0)
      {
         ResetCycleState();
         return;
      }
      if(skipGridThisTick) return;
   }

   // P10 — Chỉ L1 thật: gắn TP_Pips và khóa %YP
   if(!basketModeLatched && total==1)
   {
      RestoreTpIfOneSide();
      TryL1YpLock();
   }

   // P11 — Vào lệnh lưới tiếp theo khi giá chạm trigger (tắt nếu đã T1 / chốt tay / ngoài giờ)
   // V38: cụm SESSION_BASKET_RESCUE vẫn được thêm level tiếp theo sau giờ phiên (không phải L1 mới).
   if(hedgeTrailActive || t1Locked) return;
   if(skipGridThisTick) return;
   // V38 R2: còn bản ghi khôi phục chặn Grid → chỉ xử lý hàng chờ (mỗi bản ghi xác nhận riêng, gửi đúng khối lượng còn thiếu); không thêm level
   if(MrBlocksGrid())
   {
      if(!in_hours && !sessionRescue) return;
      MrPumpSend();
      return;
   }
   // V38 R1: cụm đã có chốt tay MỘT PHẦN → chỉ số level đếm lệnh của V26 không còn đúng → không thêm level (không lặp level, không tăng lot sai)
   if(g_cycIndexShift && ManualPartial_FreezeGrid)
   {
      static long s_frzLog=0;
      if(g_cycStartMsc!=s_frzLog) { s_frzLog=g_cycStartMsc; PrintFormat("GRID FROZEN | manual partial close in this basket (positions=%d): no further level, exits keep working", total); }
      return;
   }
   // V38 R2: chỉ số level không chứng minh được sau chốt tay / khôi phục (BLOCKER đã log khi khóa) → không thêm level, thoát / T1 / T2 / PairClose / DD vẫn chạy
   if(g_mrGridFreeze) return;
   // RPA: rebase đang thực thi / HALTED → không thêm cấp
   if(paOwns || RpaOwnsGrid()) return;
   // PAIRA_LOOP (B8): Input đổi giữa chu kỳ (khác cấu hình đã chốt) → không thêm cấp tới hết chu kỳ
   if(g_clFrozen) { ClFrozenTick(); return; }
   // [RSI SAFETY R2] S02: PROTECTIVE_ONLY - no next level (V26 grid, GLOBAL group, RPA subgrid additional order); exits / T1 / T2 / DD above keep working
   if(!Rsi2Allowed(g_rsiProt, RSI2_ACT_GRID_LEVEL)) { Rsi2Blocked(RSI2_ACT_GRID_LEVEL, StringFormat("%d positions, %s", total, RpaInSubgrid() ? "RPA subgrid" : (O12GlobalLatched() ? "GLOBAL grid" : "V26 grid"))); return; }
   // RPA §5 / §8: SubGridEpoch >= 1 → cấp kế là lệnh mở thêm L(k+j)* của tập con (lot TargetLot × 1.20^j, trigger từ VirtualEntryAnchor, tối đa GridMaxOrders lệnh mở thêm);
   // epoch 0 → Grid gốc của V26 / GLOBAL Mode 1 y hệt R3 FINAL (cấp kế = sổ cấp = số lệnh + 1 khi không có đóng tay; trần Max_Orders vị thế)
   const bool sub=RpaInSubgrid();
   if(!sub && total>=Max_Orders)
   {
      // OWNER12 (mục 11): đếm chu kỳ chạm trần Max_Orders (cấp kế không được gửi) — chỉ ghi nhận, không đổi hành vi
      if(g_o12MaxOrdCycle!=g_cycStartMsc)
      {
         g_o12MaxOrdCycle=g_cycStartMsc; g_o12MaxOrdCycles++;
         PrintFormat("GRID AT MAX_ORDERS | %d open positions = Max_Orders %d: no further grid level in this basket (exits / T1 / T2 / PairClose / session keep working)", total, Max_Orders);
      }
      return;
   }
   if(!in_hours && !sessionRescue) return;

   int    nextNum=0, nextType=0, subJ=0, dispNum=0;
   double trigger=0.0, lot=0.0;
   if(sub)
   {
      // RPA V1-R1: Lk* = L1 của Grid mới — nextNum = CẤP LOCAL n (= j + 1) cho MỌI luật giao dịch bên dưới (G, chiều, xác nhận 2 lần, nhóm GLOBAL); dispNum = nhãn L(k+n−1)*
      subJ   =RpaNextJ();
      nextNum=RpaNextLocal();
      dispNum=RpaNextDisplay();
      const int maxAddT = (int)ClGet(CL_MAXORD);
      if(!Rpa38SubMayOpen(subJ-1, maxAddT))   // MAX_REACHED: không hạ cấp, không đổi lot, không mở vì đủ điều kiện PairClose (R2 D4: local L(1 + Max_Orders) là lệnh cuối, không bao giờ vượt)
      {
         RpaMaxLog(nextNum);
         return;
      }
      nextType=RpaLocalType(nextNum);
      trigger =RpaLocalTrigger(nextNum, nextType);   // V26: VirtualEntryAnchor ± G(n − 1): local L2 = G1, L3 = G2 (GetTrigger của Grid cha với anchor = FirstPrice); GLOBAL: GgTrigger bên dưới thay hẳn
      lot     =RpaSubLot(subJ);                      // TargetLot × 1,20^(n − 1)
   }
   else
   {
      // V38 R3: cấp kế từ SỔ CẤP (= total+1 khi cụm chưa có đóng tay → y hệt V26 / R2): sau đóng tay / vào lại / bỏ đợt 2+ vị thế, số ticket không còn là chỉ số cấp.
      nextNum =LbNextLevel(total);
      if(nextNum<=0) return;
      if(nextNum>Max_Orders) return;   // sổ cấp sau đóng tay: không hạ cấp / đổi lot / nâng Max_Orders
      nextType=GetNextType(nextNum);
      trigger =GetTrigger(nextType, nextNum);
      lot     =GlGridLot(nextNum);
      dispNum =nextNum;
   }
   double bid      = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double ask      = SymbolInfoDouble(_Symbol, SYMBOL_ASK);

   // V38 GLOBAL Grid AI Pro: ứng viên trigger lấy từ GLOBAL (anchor nhóm ± khoảng nội bộ, hoặc phá biên nhóm trước ± D); nhóm chưa sẵn sàng → không gửi.
   // RPA V1-R1 tập con: GLOBAL làm việc trên CẤP LOCAL n (n 1 = Lk*) — như GLOBAL Grid cha từ L1 (OFH38_GlobalGrid)
   // [GLOBAL GEN]: khoảng nội bộ = GlobalGrid_LocalDistancesPips[localIndex − 1] từ anchor của CHÍNH nhóm (nhóm 0 cũng vậy), không còn G(n − 1); V26: GgTrigger không đổi gì
   string ggTag="";
   const int ggLevel = nextNum;
   GgSync(ggLevel-1);
   if(g_mrGridFreeze) return;   // R3: a GLOBAL group that cannot be rebuilt from the level book froze the grid
   if(!GgTrigger(ggLevel, nextType, trigger, ggTag))
   {
      return;
   }
   const string rpTag = sub ? StringFormat(" [RPA epoch %d local L%d = label L%d* | j=%d %.2f = %.2f x 1.20^%d]", RpaEpoch(), nextNum, dispNum, subJ, lot, g_rpTarget, subJ) : "";
   const string cmt   = sub ? StringFormat("RPA|S|%d|n%d|L%d", RpaEpoch(), nextNum, dispNum) : "";

   // V38: xác nhận 2 lần chỉ khi Enable_DoubleConfirmation; áp lên trigger ứng viên ở trên (GLOBAL hoặc V26), không thêm điều kiện nào khác
   // RPA V1-R1 (Owner PHASE 4): need_confirm = Enable_DoubleConfirmation && LocalGridLevel >= ConfirmFromOrder (không bao giờ cấp hiển thị); định danh xác nhận = epoch × 1000 + n
   int  cfLevel=nextNum;
   bool need_confirm=(Enable_DoubleConfirmation && cfLevel>=ConfirmFromOrder);
   const int dcId = sub ? Rpa38DcId(RpaEpoch(), nextNum) : nextNum;

   if(nextType==POSITION_TYPE_BUY)
   {
      bool can_send=need_confirm
                    ? CheckDoubleConfirm(dcId, nextType, trigger)
                    : (NormalizeDouble(ask, _Digits)>=trigger);
      if(can_send)
      {
         if(sub) { const string why=GlSubLotBlocked(lot, true); if(why!="") { can_send=false; RpaLotBlockedLog(nextNum, subJ, lot, why); } }   // RPA §3: lot ngoài giới hạn broker / thiếu margin → BLOCKED, không kẹp
         else if(!GlGridSendable(nextNum, lot, true)) can_send=false;   // PAIRA_M2: lot ladder ngoài giới hạn broker / thiếu margin → không gửi (blocker log)
      }
      if(can_send)
      {
         const bool okB=TrySendOrder(true, lot, total+1, cmt);
         if(!sub && LastSentOrder!=0 && LastSentCount==total+1) LbOnGridSend(LastSentOrder, nextNum);   // R3: the position of this order is level nextNum (DONE or PLACED)
         if(sub) RpaOnGridSend(nextNum, subJ, lot, true, trigger, need_confirm, okB);   // RPA: lệnh mở thêm chỉ được đếm khi broker có vị thế (RpaSyncSubgrid)
         if(okB)
         {
            GgOnFill(ggLevel, trade.ResultPrice()>0.0?trade.ResultPrice():ask);
            OrderCount=total+1;
            if(nextNum>=2) LatchBasketMode();
            PrintFormat("BUY #%d lot=%.2f %s trigger=%.2f ask=%.2f%s%s%s",
                        nextNum, lot, GridStepText(nextNum),
                        trigger, ask, need_confirm?" [DBL-CONFIRMED]":"", ggTag, rpTag);
            RrGrid("FILL", nextNum, 1, lot, trade.ResultPrice()>0.0?trade.ResultPrice():ask, trigger, ggTag+(need_confirm?" DBL":"")+rpTag);   // LPGD recorder (tester only)
         }
      }
   }
   else
   {
      bool can_send=need_confirm
                    ? CheckDoubleConfirm(dcId, nextType, trigger)
                    : (NormalizeDouble(bid, _Digits)<=trigger);
      if(can_send)
      {
         if(sub) { const string why=GlSubLotBlocked(lot, false); if(why!="") { can_send=false; RpaLotBlockedLog(nextNum, subJ, lot, why); } }   // RPA §3: như BUY
         else if(!GlGridSendable(nextNum, lot, false)) can_send=false;   // PAIRA_M2: như BUY
      }
      if(can_send)
      {
         const bool okS=TrySendOrder(false, lot, total+1, cmt);
         if(!sub && LastSentOrder!=0 && LastSentCount==total+1) LbOnGridSend(LastSentOrder, nextNum);   // R3 (as BUY)
         if(sub) RpaOnGridSend(nextNum, subJ, lot, false, trigger, need_confirm, okS);
         if(okS)
         {
            GgOnFill(ggLevel, trade.ResultPrice()>0.0?trade.ResultPrice():bid);
            OrderCount=total+1;
            if(nextNum>=2) LatchBasketMode();
            PrintFormat("SELL #%d lot=%.2f %s trigger=%.2f bid=%.2f%s%s%s",
                        nextNum, lot, GridStepText(nextNum),
                        trigger, bid, need_confirm?" [DBL-CONFIRMED]":"", ggTag, rpTag);
            RrGrid("FILL", nextNum, -1, lot, trade.ResultPrice()>0.0?trade.ResultPrice():bid, trigger, ggTag+(need_confirm?" DBL":"")+rpTag);   // LPGD recorder (tester only)
         }
      }
   }
}

// 1 pip trên XAU/GOLD = 0.1 giá; cặp 5/3 số lẻ = 10 point; còn lại = 1 point.
double GetPipSize()
{
   string sym = _Symbol; StringToUpper(sym);
   if(StringFind(sym,"XAU")>=0 || StringFind(sym,"GOLD")>=0) return 0.1;
   int d = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
   if(d==5 || d==3) return SymbolInfoDouble(_Symbol, SYMBOL_POINT)*10.0;
   return SymbolInfoDouble(_Symbol, SYMBOL_POINT);
}


//+------------------------------------------------------------------+
//| CLOUD API SYNC SUPPORT FUNCTIONS                                 |
//+------------------------------------------------------------------+
ENUM_TIMEFRAMES StringToTimeframe(string tf_str)
{
   StringToUpper(tf_str);
   StringTrimLeft(tf_str);
   StringTrimRight(tf_str);
   if(tf_str == "M1" || tf_str == "PERIOD_M1") return PERIOD_M1;
   if(tf_str == "M5" || tf_str == "PERIOD_M5") return PERIOD_M5;
   if(tf_str == "M15" || tf_str == "PERIOD_M15") return PERIOD_M15;
   if(tf_str == "M30" || tf_str == "PERIOD_M30") return PERIOD_M30;
   if(tf_str == "H1" || tf_str == "PERIOD_H1") return PERIOD_H1;
   if(tf_str == "H4" || tf_str == "PERIOD_H4") return PERIOD_H4;
   if(tf_str == "D1" || tf_str == "PERIOD_D1") return PERIOD_D1;
   if(tf_str == "W1" || tf_str == "PERIOD_W1") return PERIOD_W1;
   if(tf_str == "MN1" || tf_str == "PERIOD_MN1") return PERIOD_MN1;
   return PERIOD_M1;
}

//+------------------------------------------------------------------+
//| Đồng bộ cài đặt từ Cloud Server qua WebRequest                   |
//+------------------------------------------------------------------+
bool SyncSettingsFromCloud()
{
   if(LicenseKey == "")
   {
      Print("API CLOUD WARNING: LicenseKey is empty. Please enter your LicenseKey in EA Inputs.");
      return false;
   }

   string account  = IntegerToString(AccountInfoInteger(ACCOUNT_LOGIN));
   double balance  = AccountInfoDouble(ACCOUNT_BALANCE);
   double equity   = AccountInfoDouble(ACCOUNT_EQUITY);
   double profit   = AccountInfoDouble(ACCOUNT_PROFIT);
   string broker   = AccountInfoString(ACCOUNT_COMPANY);
   
   double drawdown = 0.0;
   if(balance > 0) drawdown = ((balance - equity) / balance) * 100.0;

   // URL gửi đầy đủ license, account và dữ liệu tài chính thời gian thực về Cloud Dashboard
   string url = StringFormat("%s?license=%s&account=%s&balance=%.2f&equity=%.2f&drawdown=%.2f&profit=%.2f&broker=%s&symbol=%s",
                             ApiUrl, LicenseKey, account, balance, equity, drawdown, profit, broker, _Symbol);

   ResetLastError();
   int timeout = 5000;
   string headers;
   char post[], result[];
   int res = WebRequest("GET", url, NULL, NULL, timeout, post, 0, result, headers);

   if(res == -1)
   {
      int err = GetLastError();
      PrintFormat("API CLOUD ERROR: WebRequest failed! Error code: %d. Check Tools -> Options -> Expert Advisors -> Allow WebRequest for URL: %s", err, ApiUrl);
      return (IsApiAllowed); // Giữ nguyên trạng thái nếu đã từng sync thành công
   }

   if(res != 200)
   {
      PrintFormat("API CLOUD ERROR: Server returned HTTP %d", res);
      return (IsApiAllowed);
   }

   string response = CharArrayToString(result, 0, WHOLE_ARRAY, CP_UTF8);
   CJAVal json;
   if(!json.Deserialize(response))
   {
      Print("API CLOUD ERROR: JSON parse failed! Response: ", response);
      return (IsApiAllowed);
   }

   string status = json["status"].ToStr();
   if(status == "invalid")
   {
      Print("API CLOUD: License check rejected! Account or License Key incorrect!");
      return false;
   }
   if(status == "expired")
   {
      Print("API CLOUD: License check rejected! License Key has EXPIRED!");
      return false;
   }
   if(status != "success")
   {
      PrintFormat("API CLOUD: License check rejected! Message: %s", json["message"].ToStr());
      return false;
   }

   // Kiểm tra trạng thái hoạt động của bot
   int isActive = 1;
   if(json["bot_active"].m_type != 0)
      isActive = (int)json["bot_active"].ToInt();
   else if(json["data"]["is_active"].m_type != 0)
      isActive = (int)json["data"]["is_active"].ToInt();

   if(isActive != 1)
   {
      Print("API CLOUD: Bot is PAUSED/deactivated remotely by Admin in Web Dashboard!");
      return false;
   }

   // Lấy mảng inputs từ API trả về
   CJAVal inputs = json["inputs"];
   if(inputs.m_type == 0 && json["data"]["inputs"].m_type != 0)
      inputs = json["data"]["inputs"];
   if(inputs["Initial_Lot"].ToDbl() > 0.0) Initial_Lot = inputs["Initial_Lot"].ToDbl();
   if(inputs["Lot_Multi"].ToDbl() > 0.0) Lot_Multi = inputs["Lot_Multi"].ToDbl();
   if(inputs["Max_Orders"].ToInt() > 0) Max_Orders = (int)inputs["Max_Orders"].ToInt();
   if(inputs["TP_Pips"].ToDbl() > 0.0) TP_Pips = inputs["TP_Pips"].ToDbl();
   if(inputs["Basket_TP_PhanTram"].ToDbl() >= 0.0) Basket_TP_PhanTram = inputs["Basket_TP_PhanTram"].ToDbl();
   Bat_Cong_Spread_TP = (inputs["Bat_Cong_Spread_TP"].ToBool() || inputs["Bat_Cong_Spread_TP"].ToInt() == 1);

   if(inputs["Khoang_Doi_SL"].ToDbl() > 0.0) Khoang_Doi_SL = inputs["Khoang_Doi_SL"].ToDbl();
   if(inputs["So_Pip_Doi_SL"].ToDbl() >= 0.0) So_Pip_Doi_SL = inputs["So_Pip_Doi_SL"].ToDbl();
   if(inputs["Khoang_Trailing_SL"].ToDbl() > 0.0) Khoang_Trailing_SL = inputs["Khoang_Trailing_SL"].ToDbl();

   Bat_Cat_DD = (inputs["Bat_Cat_DD"].ToBool() || inputs["Bat_Cat_DD"].ToInt() == 1);
   if(inputs["Cat_DD_PhanTram"].ToDbl() > 0.0) Cat_DD_PhanTram = inputs["Cat_DD_PhanTram"].ToDbl();
   if(inputs["DDLock_HedgeMagic"].ToInt() > 0) DDLock_HedgeMagic = (ulong)inputs["DDLock_HedgeMagic"].ToInt();

   if(inputs["RSI_Period"].ToInt() >= 2) RSI_Period = (int)inputs["RSI_Period"].ToInt();
   if(inputs["RSI_TF"].ToStr() != "") RSI_TF = StringToTimeframe(inputs["RSI_TF"].ToStr());
   if(inputs["Magic"].ToInt() > 0) Magic = (ulong)inputs["Magic"].ToInt();

   UseTimeFilter = (inputs["UseTimeFilter"].ToBool() || inputs["UseTimeFilter"].ToInt() == 1);
   if(inputs["ServerGMT"].ToInt() >= -12) ServerGMT = (int)inputs["ServerGMT"].ToInt();
   if(inputs["LocalGMT"].ToInt() >= -12) LocalGMT = (int)inputs["LocalGMT"].ToInt();

   Enable_Asia = (inputs["Enable_Asia"].ToBool() || inputs["Enable_Asia"].ToInt() == 1);
   if(inputs["Asia_StartHour"].ToInt() >= 0) Asia_StartHour = (int)inputs["Asia_StartHour"].ToInt();
   if(inputs["Asia_StartMinute"].ToInt() >= 0) Asia_StartMinute = (int)inputs["Asia_StartMinute"].ToInt();
   if(inputs["Asia_EndHour"].ToInt() >= 0) Asia_EndHour = (int)inputs["Asia_EndHour"].ToInt();
   if(inputs["Asia_EndMinute"].ToInt() >= 0) Asia_EndMinute = (int)inputs["Asia_EndMinute"].ToInt();

   Enable_Europe = (inputs["Enable_Europe"].ToBool() || inputs["Enable_Europe"].ToInt() == 1);
   if(inputs["Europe_StartHour"].ToInt() >= 0) Europe_StartHour = (int)inputs["Europe_StartHour"].ToInt();
   if(inputs["Europe_StartMinute"].ToInt() >= 0) Europe_StartMinute = (int)inputs["Europe_StartMinute"].ToInt();
   if(inputs["Europe_EndHour"].ToInt() >= 0) Europe_EndHour = (int)inputs["Europe_EndHour"].ToInt();
   if(inputs["Europe_EndMinute"].ToInt() >= 0) Europe_EndMinute = (int)inputs["Europe_EndMinute"].ToInt();

   Enable_US = (inputs["Enable_US"].ToBool() || inputs["Enable_US"].ToInt() == 1);
   if(inputs["US_StartHour"].ToInt() >= 0) US_StartHour = (int)inputs["US_StartHour"].ToInt();
   if(inputs["US_StartMinute"].ToInt() >= 0) US_StartMinute = (int)inputs["US_StartMinute"].ToInt();
   if(inputs["US_EndHour"].ToInt() >= 0) US_EndHour = (int)inputs["US_EndHour"].ToInt();
   if(inputs["US_EndMinute"].ToInt() >= 0) US_EndMinute = (int)inputs["US_EndMinute"].ToInt();

   if(inputs["MinBeforeClose"].ToInt() >= 0) MinBeforeClose = (int)inputs["MinBeforeClose"].ToInt();
   if(inputs["CloseProtect_MaxOrders"].ToInt() >= 0) CloseProtect_MaxOrders = (int)inputs["CloseProtect_MaxOrders"].ToInt();

   CloseProtect_UsePairACycleLossPct = (inputs["CloseProtect_UsePairACycleLossPct"].ToBool() || inputs["CloseProtect_UsePairACycleLossPct"].ToInt() == 1);
   if(inputs["CloseProtect_PairACycleMaxLossPct"].ToDbl() >= 0.0) CloseProtect_PairACycleMaxLossPct = inputs["CloseProtect_PairACycleMaxLossPct"].ToDbl();

   Enable_DoubleConfirmation = (inputs["Enable_DoubleConfirmation"].ToBool() || inputs["Enable_DoubleConfirmation"].ToInt() == 1);
   if(inputs["ConfirmFromOrder"].ToInt() >= 2) ConfirmFromOrder = (int)inputs["ConfirmFromOrder"].ToInt();

   if(inputs["Entry_Strategy"].ToInt() >= 0) Entry_Strategy = (OFH38_ENTRY_STRATEGY)(int)inputs["Entry_Strategy"].ToInt();
   if(inputs["GlobalGrid_OrdersPerGroup"].ToInt() > 0) GlobalGrid_OrdersPerGroup = (int)inputs["GlobalGrid_OrdersPerGroup"].ToInt();
   if(inputs["GlobalGrid_BreakoutDistanceUSD"].ToDbl() >= 0.0) GlobalGrid_BreakoutDistanceUSD = inputs["GlobalGrid_BreakoutDistanceUSD"].ToDbl();
   if(inputs["GlobalGrid_LocalDistancesPips"].ToStr() != "") GlobalGrid_LocalDistancesPips = inputs["GlobalGrid_LocalDistancesPips"].ToStr();

   if(inputs["PairClose_Mode"].ToInt() >= 0) PairClose_Mode = (OFH38_PAIRCLOSE_MODE)(int)inputs["PairClose_Mode"].ToInt();
   if(inputs["OriginalPairCloseStartOrder"].ToInt() >= 2) OriginalPairCloseStartOrder = (int)inputs["OriginalPairCloseStartOrder"].ToInt();
   if(inputs["RecursiveRebaseTargetLevel"].ToInt() >= 1) RecursiveRebaseTargetLevel = (int)inputs["RecursiveRebaseTargetLevel"].ToInt();

   // Step distances G1..G25
   CJAVal steps = inputs["Step_Distances"];
   if(steps["G1"].ToDbl() > 0) G1 = steps["G1"].ToDbl();
   if(steps["G2"].ToDbl() > 0) G2 = steps["G2"].ToDbl();
   if(steps["G3"].ToDbl() > 0) G3 = steps["G3"].ToDbl();
   if(steps["G4"].ToDbl() > 0) G4 = steps["G4"].ToDbl();
   if(steps["G5"].ToDbl() > 0) G5 = steps["G5"].ToDbl();
   if(steps["G6"].ToDbl() > 0) G6 = steps["G6"].ToDbl();
   if(steps["G7"].ToDbl() > 0) G7 = steps["G7"].ToDbl();
   if(steps["G8"].ToDbl() > 0) G8 = steps["G8"].ToDbl();
   if(steps["G9"].ToDbl() > 0) G9 = steps["G9"].ToDbl();
   if(steps["G10"].ToDbl() > 0) G10 = steps["G10"].ToDbl();
   if(steps["G11"].ToDbl() > 0) G11 = steps["G11"].ToDbl();
   if(steps["G12"].ToDbl() > 0) G12 = steps["G12"].ToDbl();
   if(steps["G13"].ToDbl() > 0) G13 = steps["G13"].ToDbl();
   if(steps["G14"].ToDbl() > 0) G14 = steps["G14"].ToDbl();
   if(steps["G15"].ToDbl() > 0) G15 = steps["G15"].ToDbl();
   if(steps["G16"].ToDbl() > 0) G16 = steps["G16"].ToDbl();
   if(steps["G17"].ToDbl() > 0) G17 = steps["G17"].ToDbl();
   if(steps["G18"].ToDbl() > 0) G18 = steps["G18"].ToDbl();
   if(steps["G19"].ToDbl() > 0) G19 = steps["G19"].ToDbl();
   if(steps["G20"].ToDbl() > 0) G20 = steps["G20"].ToDbl();
   if(steps["G21"].ToDbl() > 0) G21 = steps["G21"].ToDbl();
   if(steps["G22"].ToDbl() > 0) G22 = steps["G22"].ToDbl();
   if(steps["G23"].ToDbl() > 0) G23 = steps["G23"].ToDbl();
   if(steps["G24"].ToDbl() > 0) G24 = steps["G24"].ToDbl();
   if(steps["G25"].ToDbl() > 0) G25 = steps["G25"].ToDbl();

   Print("API CLOUD SUCCESS: Cloud parameters synced perfectly!");
   return true;
}
