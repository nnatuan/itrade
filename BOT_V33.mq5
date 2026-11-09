//+------------------------------------------------------------------+
//+                                                      RSI6_v33.mq5|
//|                                  Copyright 2026, Freelance Trader|
//+------------------------------------------------------------------+
#property copyright "AMC"
#property version   "33.0"
#property strict

// ĐÓNG GÓI THẲNG THƯ VIỆN VÀO TRONG 1 FILE EX5 DUY NHẤT
#include <Trade\Trade.mqh>

// 1. Nhúng file từ thư mục Include gốc của MQL5 làm tài nguyên
#resource "\\Include\\JAson.mqh"

// 2. Dùng 2 lần "..\\" để lùi 2 cấp thư mục ra ngoài MQL5
#include "..\\..\\Include\\JAson.mqh"

input string  _API           = "=== API CLOUD CONTROL ===";
input string  LicenseKey     = "";      // Nhập mã License Key từ Admin cấp
input string  ApiUrl         = "https://hethongso.com/itrade/index.php/do_bot_api/check_license";

input string  _Cap           = "=== CAPITAL ===";
input double  Initial_Lot    = 0.01;
input double  Lot_Multi      = 1.5;
input int     Max_Orders     = 26;

input string  _TP            = "=== TARGET PROFIT ===";
input int     TP_Mode        = 0;      // 0 = theo Pip | 1 = theo USD
input double  TP_Pips        = 10;     // Chi dung khi TP_Mode=0
input double  TP_USD         = 50.0;   // Chi dung khi TP_Mode=1 (USD)

input string  _RSI           = "=== RSI SIGNAL ===";
input int     RSI_Period     = 14;
input ENUM_TIMEFRAMES RSI_TF = PERIOD_M1;

input ulong   Magic          = 522345;

input string  _Time          = "=== TRADING TIME (LOCAL GMT+7) ===";
input bool    UseTimeFilter  = true;   // true=khung gio | false=24/7
input int     ServerGMT      = 3;      // GMT broker server (VD: GMT+3)
input int     LocalGMT       = 7;      // GMT local cua ban (GMT+7)
input int     StartHourLocal = 6;      // Bat dau: 06:00 GMT+7
input int     EndHourLocal   = 4;      // Ket thuc: 04:00 GMT+7 NGAY HOM SAU
input bool    Session_Asia   = true;   // Sydney - Tokyo (Phien A: 05:00 - 14:00)
input bool    Session_London = true;   // London (Phien Au: 14:00 - 23:00)
input bool    Session_NY     = true;   // New York (Phien My: 19:00 - 04:00)
input string  Time_Start_1   = "";     // Khung gio 1 Bat dau (HH:mm)
input string  Time_End_1     = "";     // Khung gio 1 Ket thuc (HH:mm)
input string  Time_Start_2   = "";     // Khung gio 2 Bat dau (HH:mm)
input string  Time_End_2     = "";     // Khung gio 2 Ket thuc (HH:mm)
input string  Time_Start_3   = "";     // Khung gio 3 Bat dau (HH:mm)
input string  Time_End_3     = "";     // Khung gio 3 Ket thuc (HH:mm)

input string  _Close         = "=== MARKET CLOSE PROTECTION ===";
input int     MinBeforeClose = 60;     // Phut truoc EndHour: giu basket, khong mo L1/them lenh
input int     CloseProtect_MaxOrders = 8; // <=N lenh: dong ngay | >N lenh: giu basket cho co loi roi dong
input bool    AllowGridNearEnd = false;   // true = cho phep nhoi lenh tiep khi >8 lenh de keo TP | false = ngat nhoi lenh

input string  _Confirm       = "=== DOUBLE CONFIRM (tu L10 tro di) ===";
input int     ConfirmFromOrder = 10;   // Tu lenh thu N tro di can xac nhan 2 lan

input string  _PairClose     = "=== PAIR CLOSE (chot cap 2 lenh cuoi) ===";
input bool    PairClose_BatTat       = false;  // Bat/tat chuc nang
input int     PairClose_TuLenh       = 9;      // Bat dau tu lenh thu N tro di
input double  PairClose_SoUSD        = 2.0;    // Chot khi profit(LN-1) + profit(LN) >= SoUSD ($)
input bool    PairClose_ChotDanVe    = false;  // true=chot lien tiep nhieu cap trong 1 tick (chot dan ve)

input string  _BasketPct          = "=== BASKET TP % FILTER ===";
input double  Basket_TP_PhanTram  = 0;  // 0=tat | >0: chot khi profit vuot X%_TP, keo ve duoi X%_TP, roi tang lai >= X%_TP

input string  _Step          = "=== STEP: GN = khoang cach tu L1 den lenh N+1 ===";
input double  G1  = 10;  input double  G2  = 20;  input double  G3  = 30;
input double  G4  = 40;  input double  G5  = 50;  input double  G6  = 60;
input double  G7  = 70;  input double  G8  = 80;  input double  G9  = 90;
input double  G10 = 100; input double  G11 = 110; input double  G12 = 120;
input double  G13 = 130; input double  G14 = 140; input double  G15 = 150;
input double  G16 = 160; input double  G17 = 170; input double  G18 = 180;
input double  G19 = 190; input double  G20 = 200; input double  G21 = 210;
input double  G22 = 220; input double  G23 = 230; input double  G24 = 240;
input double  G25 = 250;

//--- BỘ BIẾN TOÀN CỤC ĐỘNG ĐỂ NHẬN DỮ LIỆU TỪ WEB
double     In_Initial_Lot;
double     In_Lot_Multi;
int        In_Max_Orders;
int        In_TP_Mode;
double     In_TP_Pips;
double     In_TP_USD;
ulong      In_Magic;
bool       In_UseTimeFilter;
bool       In_Session_Asia;
bool       In_Session_London;
bool       In_Session_NY;
string     In_Time_Start_1;
string     In_Time_End_1;
string     In_Time_Start_2;
string     In_Time_End_2;
string     In_Time_Start_3;
string     In_Time_End_3;
int        In_StartHourLocal;
int        In_EndHourLocal;
int        In_MinBeforeClose;
bool       In_AllowGridNearEnd;
int        In_ConfirmFromOrder;
bool       In_PairClose_BatTat;
int        In_PairClose_TuLenh;
double     In_PairClose_SoUSD;
bool       In_PairClose_ChotDanVe;
double     In_Basket_TP_PhanTram;
double     In_G1, In_G2, In_G3, In_G4, In_G5, In_G6, In_G7, In_G8, In_G9, In_G10, 
           In_G11, In_G12, In_G13, In_G14, In_G15, In_G16, In_G17, In_G18, In_G19, In_G20, 
           In_G21, In_G22, In_G23, In_G24, In_G25;

CTrade   trade;
int      hRSI;
double   rsiVal[];
double   PipSize;

int      OrderCount      = 0;
double   FirstPrice      = 0;
int      FirstType       = -1;

// Anti-spam: ticket-based guard
ulong    LastSentOrder   = 0;
datetime LastSentTime    = 0;
int      LastSentCount   = 0;
int      ConfirmWait     = 10;

// Session wait
bool     WaitNextSession = false;
datetime WaitUntilTime   = 0;

// Close protection state
bool     CloseProtect_WaitProfit = false;

// Trailing TP state (basket % confirm)
int      TP_TrailState   = 0;

// Double-confirm state cho lenh tu ConfirmFromOrder tro di
int      DblConfirmNum   = 0;      
bool     DblConfirmHit1  = false;  
bool     DblConfirmReady = false;  

// Biến đếm thời gian cập nhật API (Mặc định 60 giây)
datetime LastApiSyncTime = 0;
bool     IsApiAllowed    = false;

//+------------------------------------------------------------------+
int OnInit()
{
   In_Initial_Lot = Initial_Lot; In_Lot_Multi = Lot_Multi; In_Max_Orders = Max_Orders;
   In_TP_Mode = TP_Mode; In_TP_Pips = TP_Pips; In_TP_USD = TP_USD; In_Magic = Magic;
   In_UseTimeFilter = UseTimeFilter; In_StartHourLocal = StartHourLocal; In_EndHourLocal = EndHourLocal;
   In_Session_Asia = Session_Asia; In_Session_London = Session_London; In_Session_NY = Session_NY;
   In_Time_Start_1 = Time_Start_1; In_Time_End_1 = Time_End_1;
   In_Time_Start_2 = Time_Start_2; In_Time_End_2 = Time_End_2;
   In_Time_Start_3 = Time_Start_3; In_Time_End_3 = Time_End_3;
   In_MinBeforeClose = MinBeforeClose; In_AllowGridNearEnd = AllowGridNearEnd;
   In_ConfirmFromOrder = ConfirmFromOrder;
   In_PairClose_BatTat = PairClose_BatTat; In_PairClose_TuLenh = PairClose_TuLenh;
   In_PairClose_SoUSD = PairClose_SoUSD; In_PairClose_ChotDanVe = PairClose_ChotDanVe;
   In_Basket_TP_PhanTram = Basket_TP_PhanTram;
   In_G1=G1; In_G2=G2; In_G3=G3; In_G4=G4; In_G5=G5; In_G6=G6; In_G7=G7; In_G8=G8; In_G9=G9; In_G10=G10;
   In_G11=G11; In_G12=G12; In_G13=G13; In_G14=G14; In_G15=G15; In_G16=G16; In_G17=G17; In_G18=G18; In_G19=G19; In_G20=G20;
   In_G21=G21; In_G22=G22; In_G23=G23; In_G24=G24; In_G25=G25;

   IsApiAllowed = SyncSettingsFromCloud();
   
   trade.SetExpertMagicNumber(In_Magic);
   trade.SetAsyncMode(false);
   PipSize = GetPipSize();
   hRSI    = iRSI(_Symbol, RSI_TF, RSI_Period, PRICE_CLOSE);
   if(hRSI == INVALID_HANDLE) { Print("RSI init failed"); return INIT_FAILED; }
   ArraySetAsSeries(rsiVal, true);
   RestoreState();
   
   PrintFormat("v33 Cloud Init | pip=%.5f | RSI=%s(%d) | TP=%s | TimeFilter=%s | %02d:00-%02d:00 GMT+%d | ConfirmFrom=L%d | CloseProtectMaxOrders=%d | AllowGridNearEnd=%s",
               PipSize, EnumToString(RSI_TF), RSI_Period,
               In_TP_Mode==0?StringFormat("%.0fPip",In_TP_Pips):StringFormat("$%.2f",In_TP_USD),
               In_UseTimeFilter?"ON":"OFF(24/7)",
               In_StartHourLocal, In_EndHourLocal, LocalGMT,
               In_ConfirmFromOrder, CloseProtect_MaxOrders,
               In_AllowGridNearEnd?"YES":"NO");
   return INIT_SUCCEEDED;
}

void OnDeinit(const int reason) { IndicatorRelease(hRSI); }

//+------------------------------------------------------------------+
int GetLocalHour()
{
   datetime now = TimeCurrent();
   MqlDateTime dt; TimeToStruct(now, dt);
   int lh = dt.hour + (LocalGMT - ServerGMT);
   if(lh >= 24) lh -= 24;
   if(lh < 0)   lh += 24;
   return lh;
}

int GetLocalMinute()
{
   datetime now = TimeCurrent();
   MqlDateTime dt; TimeToStruct(now, dt);
   return dt.min;
}

ENUM_DAY_OF_WEEK GetLocalDayOfWeek()
{
   int diff_hours = LocalGMT - ServerGMT;
   datetime now_local = TimeCurrent() + (datetime)(diff_hours * 3600);
   MqlDateTime dt; TimeToStruct(now_local, dt);
   return (ENUM_DAY_OF_WEEK)dt.day_of_week;
}

bool IsWeekend()
{
   if(!In_UseTimeFilter) return false;
   ENUM_DAY_OF_WEEK dow = GetLocalDayOfWeek();
   return (dow == SATURDAY || dow == SUNDAY);
}

//+------------------------------------------------------------------+
// BỘ HÀM XỬ LÝ THỜI GIAN GIAO DỊCH (PHIÊN BOT & KHUNG GIỜ TRADE HOUR)
//+------------------------------------------------------------------+
int ParseTimeToMinutes(string time_str)
{
   StringTrimLeft(time_str);
   StringTrimRight(time_str);
   if(StringLen(time_str) < 3) return -1;
   
   string parts[];
   int count = StringSplit(time_str, ':', parts);
   if(count < 2) return -1;
   
   int h = (int)StringToInteger(parts[0]);
   int m = (int)StringToInteger(parts[1]);
   if(h < 0 || h > 23 || m < 0 || m > 59) return -1;
   return h * 60 + m;
}

bool IsMinuteInRange(int cur_min, int start_min, int end_min)
{
   if(start_min < 0 || end_min < 0) return false;
   if(start_min == end_min) return false;
   
   if(start_min < end_min)
      return (cur_min >= start_min && cur_min < end_min);
   else
      return (cur_min >= start_min || cur_min < end_min);
}

bool CheckMinuteInAnyTradingWindow(int cur_min)
{
   if(!In_UseTimeFilter) return true;

   // 1. Kiểm tra 3 phiên giao dịch chuẩn (Bot Session)
   if(In_Session_Asia   && IsMinuteInRange(cur_min, 5 * 60, 14 * 60)) return true;
   if(In_Session_London && IsMinuteInRange(cur_min, 14 * 60, 23 * 60)) return true;
   if(In_Session_NY     && IsMinuteInRange(cur_min, 19 * 60, 4 * 60)) return true;

   // 2. Kiểm tra 3 khung giờ Trade Hour tùy chọn
   int s1 = ParseTimeToMinutes(In_Time_Start_1);
   int e1 = ParseTimeToMinutes(In_Time_End_1);
   if(s1 >= 0 && e1 >= 0 && IsMinuteInRange(cur_min, s1, e1)) return true;

   int s2 = ParseTimeToMinutes(In_Time_Start_2);
   int e2 = ParseTimeToMinutes(In_Time_End_2);
   if(s2 >= 0 && e2 >= 0 && IsMinuteInRange(cur_min, s2, e2)) return true;

   int s3 = ParseTimeToMinutes(In_Time_Start_3);
   int e3 = ParseTimeToMinutes(In_Time_End_3);
   if(s3 >= 0 && e3 >= 0 && IsMinuteInRange(cur_min, s3, e3)) return true;

   // 3. Fallback cho tài khoản cũ nếu không chọn phiên nào và không nhập khung giờ nào
   if(!In_Session_Asia && !In_Session_London && !In_Session_NY &&
      (s1 < 0 || e1 < 0) && (s2 < 0 || e2 < 0) && (s3 < 0 || e3 < 0))
   {
      if(In_StartHourLocal != In_EndHourLocal)
         return IsMinuteInRange(cur_min, In_StartHourLocal * 60, In_EndHourLocal * 60);
   }

   return false;
}

bool IsInTradingHours()
{
   if(!In_UseTimeFilter) return true;
   if(IsWeekend()) return false;

   int lh = GetLocalHour();
   int lm = GetLocalMinute();
   return CheckMinuteInAnyTradingWindow(lh * 60 + lm);
}

/* bool Old_Unused_Hours()
{
   return false;
}

// RemovedBlock1 
{
   // unused
   else
   // unused
}

bool IsNearTradingEnd()
{
   if(!In_UseTimeFilter) return false;
   if(IsWeekend()) return false;

   int lh = GetLocalHour();
   int lm = GetLocalMinute();
   return CheckMinuteInAnyTradingWindow(lh * 60 + lm);
}

/* bool Old_Unused_Hours()
{
   int lm = GetLocalMinute();
   int now_mins = lh * 60 + lm;
   int end_mins = In_EndHourLocal * 60;

   int diff_mins;
   if(In_StartHourLocal > In_EndHourLocal && lh >= In_StartHourLocal)
   {
      diff_mins = (1440 - now_mins) + end_mins;
   }
   else
   {
      diff_mins = end_mins - now_mins;
   }
//
   }

   return false;
}

*/

//--- HÀM BẢO VỆ SÁT PHIÊN ĐÓNG CỬA
bool IsNearTradingEnd()
{
   if(!In_UseTimeFilter) return false;
   if(IsWeekend()) return false;
   if(In_MinBeforeClose <= 0) return false;

   int lh = GetLocalHour();
   int lm = GetLocalMinute();
   int cur_min = lh * 60 + lm;

   if(!CheckMinuteInAnyTradingWindow(cur_min)) return false;

   int future_min = (cur_min + In_MinBeforeClose) % 1440;
   return !CheckMinuteInAnyTradingWindow(future_min);
}

//--- HÀM TÍNH THỜI GIAN MỞ CỬA PHIÊN TIẾP THEO
datetime CalcNextOpenTime()
{
   int diff_hours = LocalGMT - ServerGMT;
   datetime now_local = TimeCurrent() + (datetime)(diff_hours * 3600);
   datetime check_local = now_local + 60;
   check_local = check_local - (check_local % 60);

   for(int m = 0; m < 7 * 1440; m++)
   {
      MqlDateTime dt;
      TimeToStruct(check_local, dt);
      ENUM_DAY_OF_WEEK dow = (ENUM_DAY_OF_WEEK)dt.day_of_week;
      if(dow != SATURDAY && dow != SUNDAY)
      {
         int cur_min = dt.hour * 60 + dt.min;
         if(CheckMinuteInAnyTradingWindow(cur_min))
         {
            PrintFormat("CalcNextOpenTime: mo lai %s (local)", TimeToString(check_local, TIME_DATE|TIME_MINUTES));
            return check_local - (datetime)(diff_hours * 3600);
         }
      }
      check_local += 60;
   }
   return TimeCurrent() + 3600;
}

/* OldUnusedCode
{
}

datetime CalcNextOpenTime()
{
   int diff_hours = LocalGMT - ServerGMT;
   datetime now_local = TimeCurrent() + (datetime)(diff_hours * 3600);
   MqlDateTime dt; TimeToStruct(now_local, dt);
   datetime midnight_local = now_local - (datetime)(dt.hour*3600 + dt.min*60 + dt.sec);

   datetime open_today_local = midnight_local + (datetime)(In_StartHourLocal * 3600);
   if(now_local < open_today_local)
   {
      MqlDateTime tdt; TimeToStruct(open_today_local, tdt);
      ENUM_DAY_OF_WEEK tdow = (ENUM_DAY_OF_WEEK)tdt.day_of_week;
      datetime target_local = open_today_local;
      if(tdow == SATURDAY) target_local += 2*86400;
      if(tdow == SUNDAY)   target_local += 1*86400;
      PrintFormat("CalcNextOpenTime: mo lai %s (local)", TimeToString(target_local, TIME_DATE|TIME_MINUTES));
      return target_local - (datetime)(diff_hours * 3600);
   }

   datetime next_local = midnight_local + 86400;
   MqlDateTime ndt; TimeToStruct(next_local, ndt);
   ENUM_DAY_OF_WEEK ndow = (ENUM_DAY_OF_WEEK)ndt.day_of_week;
   if(ndow == SATURDAY) next_local += 2*86400;
   if(ndow == SUNDAY)   next_local += 1*86400;

   datetime open_local = next_local + (datetime)(In_StartHourLocal * 3600);
   PrintFormat("CalcNextOpenTime: mo lai %s (local)", TimeToString(open_local, TIME_DATE|TIME_MINUTES));
   return open_local - (datetime)(diff_hours * 3600);
}

}

*/

double GetStep(int order_num)
{
   int n = order_num - 1;
   double p;
   switch(n)
   {
      case 1:  p=In_G1;  break; case 2:  p=In_G2;  break; case 3:  p=In_G3;  break;
      case 4:  p=In_G4;  break; case 5:  p=In_G5;  break; case 6:  p=In_G6;  break;
      case 7:  p=In_G7;  break; case 8:  p=In_G8;  break; case 9:  p=In_G9;  break;
      case 10: p=In_G10; break; case 11: p=In_G11; break; case 12: p=In_G12; break;
      case 13: p=In_G13; break; case 14: p=In_G14; break; case 15: p=In_G15; break;
      case 16: p=In_G16; break; case 17: p=In_G17; break; case 18: p=In_G18; break;
      case 19: p=In_G19; break; case 20: p=In_G20; break; case 21: p=In_G21; break;
      case 22: p=In_G22; break; case 23: p=In_G23; break; case 24: p=In_G24; break;
      default: p=In_G25; break;
   }
   return p * PipSize;
}

int GetNextType(int order_num)
{
   bool opposite = (order_num % 2 == 0);
   if(FirstType == POSITION_TYPE_BUY)
      return opposite ? POSITION_TYPE_SELL : POSITION_TYPE_BUY;
   else
      return opposite ? POSITION_TYPE_BUY  : POSITION_TYPE_SELL;
}

double GetTrigger(int next_type, int order_num)
{
   double dist = GetStep(order_num);
   return next_type == POSITION_TYPE_BUY
          ? NormalizeDouble(FirstPrice + dist, _Digits)
          : NormalizeDouble(FirstPrice - dist, _Digits);
}

int CountPositions()
{
   int count = 0;
   for(int i = 0; i < PositionsTotal(); i++)
   {
      ulong t = PositionGetTicket(i);
      if(!t) continue;
      if((ulong)PositionGetInteger(POSITION_MAGIC) != In_Magic) continue;
      if(PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
      count++;
   }
   return count;
}

bool OrderStillOpen(ulong order_ticket)
{
   if(order_ticket == 0) return false;
   for(int i = 0; i < PositionsTotal(); i++)
   {
      ulong t = PositionGetTicket(i);
      if(!t) continue;
      if((ulong)PositionGetInteger(POSITION_MAGIC) != In_Magic) continue;
      if(PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
      if((ulong)PositionGetInteger(POSITION_IDENTIFIER) == order_ticket) return true;
   }
   return false;
}

void GetFirstPosition(double &price, int &type)
{
   datetime first_time = D'2099.12.31';
   price = 0; type = -1;
   for(int i = 0; i < PositionsTotal(); i++)
   {
      ulong t = PositionGetTicket(i);
      if(!t) continue;
      if((ulong)PositionGetInteger(POSITION_MAGIC) != In_Magic) continue;
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

void RestoreState()
{
   OrderCount = CountPositions();
   if(OrderCount > 0) GetFirstPosition(FirstPrice, FirstType);
   else { FirstPrice=0; FirstType=-1; }
   LastSentOrder=0; LastSentTime=0; LastSentCount=0;
   DblConfirmNum=0; DblConfirmHit1=false; DblConfirmReady=false;
   CloseProtect_WaitProfit=false;
}

double CalcLot(int order_index)
{
   double lot  = In_Initial_Lot * MathPow(In_Lot_Multi, order_index);
   double step = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   double minL = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   double maxL = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   lot = MathCeil(lot / step) * step;
   lot = NormalizeDouble(lot, 2);
   return MathMax(minL, MathMin(maxL, lot));
}

double BasketProfit()
{
   double profit = 0;
   for(int i = 0; i < PositionsTotal(); i++)
   {
      ulong t = PositionGetTicket(i);
      if(!t) continue;
      if((ulong)PositionGetInteger(POSITION_MAGIC) != In_Magic) continue;
      if(PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
      profit += PositionGetDouble(POSITION_PROFIT) + PositionGetDouble(POSITION_SWAP);
   }
   return profit;
}

double CalcTargetUSD()
{
   if(In_TP_Mode == 1) return In_TP_USD;

   double buyLot=0, sellLot=0;
   for(int i = 0; i < PositionsTotal(); i++)
   {
      ulong t = PositionGetTicket(i);
      if(!t) continue;
      if((ulong)PositionGetInteger(POSITION_MAGIC) != In_Magic) continue;
      if(PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
      if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY) buyLot+=PositionGetDouble(POSITION_VOLUME);
      else sellLot+=PositionGetDouble(POSITION_VOLUME);
   }
   double netLot = MathAbs(buyLot - sellLot);
   if(netLot < SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN)) netLot = MathMax(buyLot, sellLot);
   double tickVal  = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
   double tickSize = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
   return netLot * (In_TP_Pips * PipSize / tickSize) * tickVal;
}

void CloseBasket()
{
   for(int i = PositionsTotal()-1; i >= 0; i--)
   {
      ulong t = PositionGetTicket(i);
      if(!t) continue;
      if((ulong)PositionGetInteger(POSITION_MAGIC) != In_Magic) continue;
      if(PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
      trade.PositionClose(t);
   }
   OrderCount=0; FirstPrice=0; FirstType=-1;
   LastSentOrder=0; LastSentTime=0; LastSentCount=0;
   DblConfirmNum=0; DblConfirmHit1=false; DblConfirmReady=false;
   TP_TrailState=0;
   CloseProtect_WaitProfit=false;
}

bool GetTwoLatestTickets(ulong &t1, ulong &t2)
{
   struct PosInfo { ulong ticket; datetime time; };
   PosInfo arr[];
   int cnt = 0;
   for(int i = 0; i < PositionsTotal(); i++)
   {
      ulong t = PositionGetTicket(i);
      if(!t) continue;
      if((ulong)PositionGetInteger(POSITION_MAGIC) != In_Magic) continue;
      if(PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
      ArrayResize(arr, cnt+1);
      arr[cnt].ticket = t;
      arr[cnt].time   = (datetime)PositionGetInteger(POSITION_TIME);
      cnt++;
   }
   if(cnt < 2) return false;
   for(int i = 0; i < cnt-1; i++)
      for(int j = i+1; j < cnt; j++)
         if(arr[j].time < arr[i].time)
         {
            PosInfo tmp = arr[i]; arr[i]=arr[j]; arr[j]=tmp;
         }
   t1 = arr[cnt-2].ticket; 
   t2 = arr[cnt-1].ticket; 
   return true;
}

double CalcTwoProfitUSD(ulong t1, ulong t2)
{
   double p = 0;
   ulong ts[2]; ts[0]=t1; ts[1]=t2;
   for(int k=0;k<2;k++)
   {
      for(int i=0;i<PositionsTotal();i++)
      {
         ulong t = PositionGetTicket(i);
         if(!t) continue;
         if((ulong)PositionGetInteger(POSITION_IDENTIFIER) != ts[k]) continue;
         p += PositionGetDouble(POSITION_PROFIT) + PositionGetDouble(POSITION_SWAP);
         break;
      }
   }
   return p;
}

bool CheckPairClose(ulong t1, ulong t2, double soUSD)
{
   double profit1=0, profit2=0;
   for(int i=0;i<PositionsTotal();i++)
   {
      ulong t = PositionGetTicket(i);
      if(!t) continue;
      ulong id = (ulong)PositionGetInteger(POSITION_IDENTIFIER);
      if(id == t1) profit1 = PositionGetDouble(POSITION_PROFIT) + PositionGetDouble(POSITION_SWAP);
      if(id == t2) profit2 = PositionGetDouble(POSITION_PROFIT) + PositionGetDouble(POSITION_SWAP);
   }
   double total = profit1 + profit2;
   return (total >= soUSD);
}

void CloseTwoLatest(ulong t1, ulong t2)
{
   trade.PositionClose(t2);
   trade.PositionClose(t1);
   int real = CountPositions();
   OrderCount = real;
   if(real == 0) { FirstPrice=0; FirstType=-1; }
   LastSentOrder=0; LastSentTime=0; LastSentCount=real;
   DblConfirmNum=0; DblConfirmHit1=false; DblConfirmReady=false;
}

bool TrySendOrder(bool is_buy, double lot, int expected_count)
{
   if(LastSentCount == expected_count)
   {
      if(LastSentOrder > 0 && OrderStillOpen(LastSentOrder)) return false;
      int real = CountPositions();
      if(real >= expected_count)
      {
         PrintFormat("Guard: real=%d >= expected=%d, skip", real, expected_count);
         return false;
      }
      if(TimeCurrent() - LastSentTime < ConfirmWait) return false;
      PrintFormat("Timeout %ds, retry #%d", ConfirmWait, expected_count);
      LastSentOrder = 0;
   }

   int real_now = CountPositions();
   if(real_now >= expected_count)
   {
      PrintFormat("Pre-check: real=%d >= expected=%d, skip", real_now, expected_count);
      LastSentCount = expected_count;
      return false;
   }

   bool ok = is_buy ? trade.Buy(lot, _Symbol) : trade.Sell(lot, _Symbol);
   if(!ok) { PrintFormat("Send failed: %s", trade.ResultComment()); return false; }

   uint rc = trade.ResultRetcode();
   if(rc == TRADE_RETCODE_DONE || rc == TRADE_RETCODE_DONE_PARTIAL)
   {
      LastSentOrder = trade.ResultOrder();
      LastSentTime  = TimeCurrent();
      LastSentCount = expected_count;
      PrintFormat("Sent OK order=%llu rc=%d lot=%.2f", LastSentOrder, rc, lot);
      return true;
   }
   else if(rc == TRADE_RETCODE_PLACED)
   {
      LastSentOrder = trade.ResultOrder();
      LastSentTime  = TimeCurrent();
      LastSentCount = expected_count;
      PrintFormat("Placed order=%llu, waiting...", LastSentOrder);
      return false;
   }
   else
   {
      PrintFormat("%s err rc=%d: %s", is_buy?"BUY":"SELL", rc, trade.ResultComment());
      return false;
   }
}

//+------------------------------------------------------------------+
// DOUBLE CONFIRM v33: Kiểm tra ở MỌI TICK
//+------------------------------------------------------------------+
bool CheckDoubleConfirm(int next_num, int next_type, double trigger)
{
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);

   if(DblConfirmNum != next_num)
   {
      DblConfirmNum=next_num; DblConfirmHit1=false; DblConfirmReady=false;
      PrintFormat("DblConfirm START #%d | ConfirmFromOrder=%d | trigger=%.2f",
                  next_num, In_ConfirmFromOrder, trigger);
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
// XỬ LÝ 60 PHÚT CUỐI PHIÊN (MARKET CLOSE PROTECTION) v33
//+------------------------------------------------------------------+
void XuLy60PhutCuoiPhien(int total)
{
   if(!IsNearTradingEnd()) return;
   if(total <= 0) return;

   // TRƯỜNG HỢP 1: TỔNG SỐ LỆNH <= 8 -> ĐÓNG TẤT CẢ TỰ ĐỘNG ĐỂ NGHỈ PHIÊN
   if(total <= CloseProtect_MaxOrders)
   {
      PrintFormat("=== 60 PHUT CUOI PHIEN | total=%d <= %d | DONG TAT CA NGAY ===",
                  total, CloseProtect_MaxOrders);
      CloseBasket();
      WaitNextSession = true;
      WaitUntilTime   = CalcNextOpenTime();
      PrintFormat("=== Cho den phien moi: %s (server) ===",
                  TimeToString(WaitUntilTime, TIME_DATE|TIME_MINUTES));
      return;
   }

   // TRƯỜNG HỢP 2: TỔNG SỐ LỆNH > 8 (GỒNG LƯỚI SÂU)
   double profit = BasketProfit();

   // Kịch bản A: Giỏ lệnh có lãi -> Tất toán cắt sạch nghỉ phiên
   if(profit > 0)
   {
      PrintFormat("=== 60 PHUT CUOI PHIEN | total=%d > %d | profit=$%.2f > 0 | DONG CA BASKET ===",
                  total, CloseProtect_MaxOrders, profit);
      CloseBasket();
      WaitNextSession = true;
      WaitUntilTime   = CalcNextOpenTime();
      PrintFormat("=== Cho den phien moi: %s (server) ===",
                  TimeToString(WaitUntilTime, TIME_DATE|TIME_MINUTES));
      return;
   }

   // Kịch bản B: Theo lựa chọn từ Web (In_AllowGridNearEnd)
   if(In_AllowGridNearEnd)
   {
      CloseProtect_WaitProfit = false;
      static datetime last_log_allow = 0;
      if(TimeCurrent() - last_log_allow > 300)
      {
         PrintFormat("=== 60 PHUT CUOI PHIEN | total=%d > %d | profit=$%.2f <= 0 | CHO PHEP NHOI LENH TIEP ĐỂ KEO TP ===",
                     total, CloseProtect_MaxOrders, profit);
         last_log_allow = TimeCurrent();
      }
   }
   else
   {
      CloseProtect_WaitProfit = true;
      static datetime last_log2 = 0;
      if(TimeCurrent() - last_log2 > 300)
      {
         PrintFormat("=== 60 PHUT CUOI PHIEN | total=%d > %d | profit=$%.2f <= 0 | GIU, KHONG MO THEM, CHO CO LOI ===",
                     total, CloseProtect_MaxOrders, profit);
         last_log2 = TimeCurrent();
      }
   }
}

//+------------------------------------------------------------------+
void OnTick()
{
   // 1. CHU KỲ KIỂM TRA ĐỒNG BỘ API (Định kỳ 60 giây)
   if(TimeCurrent() - LastApiSyncTime >= 60) {
      IsApiAllowed = SyncSettingsFromCloud();
      LastApiSyncTime = TimeCurrent();
   }

   if(!IsApiAllowed) {
      return; 
   }

   if(WaitNextSession)
   {
      if(TimeCurrent() >= WaitUntilTime && IsInTradingHours())
      {
         WaitNextSession = false;
         CloseProtect_WaitProfit = false;
         PrintFormat("=== Bot hoat dong tro lai | Local=%02d:%02d GMT+%d | %s ===",
                     GetLocalHour(), GetLocalMinute(), LocalGMT,
                     EnumToString(GetLocalDayOfWeek()));
      }
      else return;
   }

   if(IsWeekend()) return;

   bool in_hours = IsInTradingHours();
   bool near_end = IsNearTradingEnd();

   int total = CountPositions();
   OrderCount = total;

   if(!near_end && CloseProtect_WaitProfit)
      CloseProtect_WaitProfit = false;

   // ── MARKET CLOSE PROTECTION (60 phut cuoi phien) ──
   XuLy60PhutCuoiPhien(total);
   if(WaitNextSession) return;

   // ── KHÔNG MỞ LỆNH MỚI NẾU HẾT GIỜ HOẶC ĐANG SÁT PHIÊN KHÔNG CÓ LỆNH ──
   if(total == 0)
   {
      FirstPrice=0; FirstType=-1;

      if(!in_hours || near_end)
      {
         static datetime last_log = 0;
         if(TimeCurrent() - last_log > 300)
         {
            PrintFormat("No L1 | local=%02d:%02d | in_hours=%s near_end=%s",
                        GetLocalHour(), GetLocalMinute(),
                        in_hours?"Y":"N", near_end?"Y":"N");
            last_log = TimeCurrent();
         }
         return;
      }

      if(CopyBuffer(hRSI, 0, 1, 1, rsiVal) <= 0) return;
      double rsi = rsiVal[0];
      bool isBuy  = (rsi >= 0 && rsi <= 30) || (rsi > 50 && rsi <= 70);
      bool isSell = (rsi > 30 && rsi <= 50) || (rsi > 70 && rsi <= 100);
      if(!isBuy && !isSell) return;

      double lot = CalcLot(0);
      if(!TrySendOrder(isBuy, lot, 1)) return;

      TP_TrailState = 0;
      FirstPrice = trade.ResultPrice();
      if(FirstPrice == 0) FirstPrice = isBuy ? SymbolInfoDouble(_Symbol, SYMBOL_ASK)
                                             : SymbolInfoDouble(_Symbol, SYMBOL_BID);
      FirstType  = isBuy ? POSITION_TYPE_BUY : POSITION_TYPE_SELL;
      OrderCount = 1;
      PrintFormat("=== L1 %s @ %.2f lot=%.2f RSI=%.1f | local=%02d:%02d ===",
                  isBuy?"BUY":"SELL", FirstPrice, lot, rsi,
                  GetLocalHour(), GetLocalMinute());
      return;
   }

   if(FirstPrice == 0)
   {
      GetFirstPosition(FirstPrice, FirstType);
      if(FirstPrice == 0) return;
   }

   // ── PAIR CLOSE ──────────────────────────
   if(In_PairClose_BatTat && total >= In_PairClose_TuLenh)
   {
      bool da_chot = false;
      int  cur     = CountPositions();

      while(cur >= In_PairClose_TuLenh)
      {
         ulong tk1=0, tk2=0;
         if(!GetTwoLatestTickets(tk1, tk2)) break;

         if(In_PairClose_SoUSD > 0 && CheckPairClose(tk1, tk2, In_PairClose_SoUSD))
         {
            PrintFormat("=== PAIR CLOSE | cap L%d+L%d | tong_profit >= $%.2f%s ===",
                        cur-1, cur, In_PairClose_SoUSD,
                        In_PairClose_ChotDanVe?" | CHOT DAN":"");
            CloseTwoLatest(tk1, tk2);
            cur     = CountPositions();
            da_chot = true;

            if(!In_PairClose_ChotDanVe) break; 
         }
         else break; 
      }

      if(da_chot) return;
   }

   // ── BASKET TP ──
   {
      double profit    = BasketProfit();
      double targetUSD = CalcTargetUSD();            
      double pctUSD    = (In_Basket_TP_PhanTram > 0)
                         ? targetUSD * In_Basket_TP_PhanTram / 100.0
                         : 0;                        

      bool should_close = false;
      string close_reason = "";

      if(targetUSD > 0 && profit >= targetUSD)
      {
         should_close = true;
         close_reason = StringFormat("[A] profit=$%.2f >= target=$%.2f", profit, targetUSD);
         TP_TrailState = 0;
      }
      else if(pctUSD > 0)
      {
         if(TP_TrailState == 0)
         {
            if(profit >= pctUSD)
            {
               TP_TrailState = 1;
               PrintFormat("=== BASKET TRAIL state=1 | profit=$%.2f vuot nguong=$%.2f (%.0f%%) | cho keo ve ===",
                           profit, pctUSD, In_Basket_TP_PhanTram);
            }
         }
         else if(TP_TrailState == 1)
         {
            if(profit < pctUSD)
            {
               TP_TrailState = 2;
               PrintFormat("=== BASKET TRAIL state=2 | profit=$%.2f keo ve < $%.2f | cho bounce len ===",
                           profit, pctUSD);
            }
         }
         else if(TP_TrailState == 2)
         {
            if(profit >= pctUSD)
            {
               should_close = true;
               close_reason = StringFormat("[B] trail confirm | profit=$%.2f >= nguong=$%.2f (%.0f%%)",
                                           profit, pctUSD, In_Basket_TP_PhanTram);
               TP_TrailState = 0;
            }
         }
      }

      if(should_close)
      {
         bool near_close = IsNearTradingEnd() || !IsInTradingHours();
         PrintFormat("=== BASKET TP %s | near_end=%s | dong %d lenh ===",
                     close_reason, near_close?"YES":"NO", total);
         CloseBasket();
         if(near_close)
         {
            WaitNextSession = true;
            WaitUntilTime   = CalcNextOpenTime();
            PrintFormat("=== Cho den phien moi: %s (server) ===",
                        TimeToString(WaitUntilTime, TIME_DATE|TIME_MINUTES));
         }
         return;
      }
   }

   // ── SỬA ĐỔI QUAN TRỌNG TẠI ĐÂY: KHÔNG CHẶN NHỒI NẾU ĐƯỢC PHÉP ──
   if(!in_hours) return;
   if(near_end && (!In_AllowGridNearEnd || CloseProtect_WaitProfit)) return;
   if(total >= In_Max_Orders) return;

   int    nextNum  = total + 1;
   int    nextType = GetNextType(nextNum);
   double trigger  = GetTrigger(nextType, nextNum);
   double lot      = CalcLot(total);
   double bid      = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double ask      = SymbolInfoDouble(_Symbol, SYMBOL_ASK);

   bool need_confirm = (nextNum >= In_ConfirmFromOrder);

   if(nextType == POSITION_TYPE_BUY)
   {
      bool can_send = need_confirm
                      ? CheckDoubleConfirm(nextNum, nextType, trigger)
                      : (NormalizeDouble(ask, _Digits) >= trigger);

      if(can_send)
      {
         if(TrySendOrder(true, lot, nextNum))
         {
            OrderCount = nextNum;
            PrintFormat("BUY #%d lot=%.2f G%d=%.0fpip trigger=%.2f ask=%.2f%s",
                        nextNum, lot, nextNum-1, GetStep(nextNum)/PipSize,
                        trigger, ask, need_confirm?" [DBL-CONFIRMED]":"");
         }
      }
   }
   else
   {
      bool can_send = need_confirm
                      ? CheckDoubleConfirm(nextNum, nextType, trigger)
                      : (NormalizeDouble(bid, _Digits) <= trigger);

      if(can_send)
      {
         if(TrySendOrder(false, lot, nextNum))
         {
            OrderCount = nextNum;
            PrintFormat("SELL #%d lot=%.2f G%d=%.0fpip trigger=%.2f bid=%.2f%s",
                        nextNum, lot, nextNum-1, GetStep(nextNum)/PipSize,
                        trigger, bid, need_confirm?" [DBL-CONFIRMED]":"");
         }
      }
   }
}

//+------------------------------------------------------------------+
double GetPipSize()
{
   string sym = _Symbol; StringToUpper(sym);
   if(StringFind(sym,"XAU")>=0 || StringFind(sym,"GOLD")>=0) return 0.1;
   int d = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
   if(d==5 || d==3) return SymbolInfoDouble(_Symbol, SYMBOL_POINT)*10.0;
   return SymbolInfoDouble(_Symbol, SYMBOL_POINT);
}

//+------------------------------------------------------------------+
// MODULE KẾT NỐI API ĐỒNG BỘ CẤU HÌNH TỪ EA HUB
//+------------------------------------------------------------------+
bool SyncSettingsFromCloud()
{
   if(LicenseKey == "") {
      Print("API ERROR: License Key is empty. Bot stopped.");
      return false;
   }

   string account  = IntegerToString(AccountInfoInteger(ACCOUNT_LOGIN));
   double balance  = AccountInfoDouble(ACCOUNT_BALANCE);
   double equity   = AccountInfoDouble(ACCOUNT_EQUITY);
   double profit   = AccountInfoDouble(ACCOUNT_PROFIT);
   string broker   = AccountInfoString(ACCOUNT_COMPANY);
   
   double drawdown = 0.0;
   if(balance > 0) drawdown = ((balance - equity) / balance) * 100.0;

   string request_url = StringFormat("%s?license=%s&account=%s&balance=%.2f&equity=%.2f&drawdown=%.2f&profit=%.2f&broker=%s",
                                     ApiUrl, LicenseKey, account, balance, equity, drawdown, profit, broker);

   char post[], result[];
   string headers;
   int res_code = WebRequest("GET", request_url, NULL, NULL, 5000, post, 0, result, headers);

   if(res_code != 200) {
      PrintFormat("API ERROR: WebRequest failed! Code: %d. Check DLL allowance.", res_code);
      return false;
   }

   string json_text = CharArrayToString(result);
   
   CJAVal json;
   if(!json.Deserialize(json_text)) {
      Print("API ERROR: Invalid JSON format from server.");
      return false;
   }

   string status = json["status"].ToStr();
   if(status == "invalid") {
      Print("API ERROR: Account or License Key incorrect!"); return false;
   }
   if(status == "expired") {
      Print("API ERROR: License Key has EXPIRED!"); return false;
   }

   if(status == "success") {
      int bot_active = (int)json["bot_active"].ToInt();
      if(bot_active == 0) {
         Print("API WARNING: Bot is PAUSED remotely by Admin.");
         return false;
      }

      CJAVal inputs = json["inputs"];
      
      In_Initial_Lot        = inputs["Initial_Lot"].ToDbl();
      In_Lot_Multi          = inputs["Lot_Multi"].ToDbl();
      In_Max_Orders         = (int)inputs["Max_Orders"].ToInt();
      In_TP_Mode            = (int)inputs["TP_Mode"].ToInt();
      In_TP_Pips            = inputs["TP_Pips"].ToDbl();
      In_TP_USD             = inputs["TP_USD"].ToDbl();
      
      In_Magic              = (ulong)inputs["Magic_Num"].ToInt();
      In_UseTimeFilter      = (inputs["UseTimeFilter"].ToInt() == 1);
      In_Session_Asia       = (inputs["Session_Asia"].ToInt() == 1);
      In_Session_London     = (inputs["Session_London"].ToInt() == 1);
      In_Session_NY         = (inputs["Session_NY"].ToInt() == 1);
      In_Time_Start_1       = inputs["Time_Start_1"].ToStr();
      In_Time_End_1         = inputs["Time_End_1"].ToStr();
      In_Time_Start_2       = inputs["Time_Start_2"].ToStr();
      In_Time_End_2         = inputs["Time_End_2"].ToStr();
      In_Time_Start_3       = inputs["Time_Start_3"].ToStr();
      In_Time_End_3         = inputs["Time_End_3"].ToStr();
      In_StartHourLocal     = (int)inputs["StartHourLocal"].ToInt();
      In_EndHourLocal       = (int)inputs["EndHourLocal"].ToInt();
      In_MinBeforeClose     = (int)inputs["MinBeforeClose"].ToInt();
      
      In_AllowGridNearEnd   = (inputs["AllowGridNearEnd"].ToInt() == 1);
      
      In_ConfirmFromOrder   = (int)inputs["ConfirmFromOrder"].ToInt();
      
      In_PairClose_BatTat    = (inputs["PairClose_BatTat"].ToInt() == 1);
      In_PairClose_TuLenh    = (int)inputs["PairClose_TuLenh"].ToInt();
      In_PairClose_SoUSD     = inputs["PairClose_SoUSD"].ToDbl();
      In_PairClose_ChotDanVe = (inputs["PairClose_ChotDanVe"].ToInt() == 1);
      In_Basket_TP_PhanTram  = inputs["Basket_TP_PhanTram"].ToDbl();

      CJAVal steps = inputs["Step_Distances"];
      In_G1 = steps["G1"].ToDbl();   In_G2 = steps["G2"].ToDbl();   In_G3 = steps["G3"].ToDbl();
      In_G4 = steps["G4"].ToDbl();   In_G5 = steps["G5"].ToDbl();   In_G6 = steps["G6"].ToDbl();
      In_G7 = steps["G7"].ToDbl();   In_G8 = steps["G8"].ToDbl();   In_G9 = steps["G9"].ToDbl();
      In_G10 = steps["G10"].ToDbl(); In_G11 = steps["G11"].ToDbl(); In_G12 = steps["G12"].ToDbl();
      In_G13 = steps["G13"].ToDbl(); In_G14 = steps["G14"].ToDbl(); In_G15 = steps["G15"].ToDbl();
      In_G16 = steps["G16"].ToDbl(); In_G17 = steps["G17"].ToDbl(); In_G18 = steps["G18"].ToDbl();
      In_G19 = steps["G19"].ToDbl(); In_G20 = steps["G20"].ToDbl(); In_G21 = steps["G21"].ToDbl();
      In_G22 = steps["G22"].ToDbl(); In_G23 = steps["G23"].ToDbl(); In_G24 = steps["G24"].ToDbl();
      In_G25 = steps["G25"].ToDbl();

      Print("API SUCCESS: Cloud parameters synced perfectly!");
      return true;
   }

   return false;
}