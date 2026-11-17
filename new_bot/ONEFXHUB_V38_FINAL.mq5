#property copyright "AMTK"
#property version   "38.38"
#property strict

#include <Trade\Trade.mqh>
#ifndef OFH38_TRADEGATE_MQH
#define OFH38_TRADEGATE_MQH

class CTradeV38 : public CTrade
{
public:
   long m_sends;
   CTradeV38(void) : m_sends(0) {}
   ulong DeviationPoints(void) const { return m_deviation; }
   virtual bool OrderSend(const MqlTradeRequest &request, MqlTradeResult &result)
   {
      m_sends++;
      return CTrade::OrderSend(request, result);
   }
};

#endif

input string  _Cap           = "=== VỐN / LOT ===";
input double  Initial_Lot    = 0.03;
input double  Lot_Multi      = 1.50;
input int     Max_Orders     = 26;

input string  _TP            = "=== CHỐT LỜI LỆNH 1 ===";
input double  TP_Pips        = 10;
input double  Basket_TP_PhanTram = 0;

input string  _Cum           = "=== T1/T2 CỤM LỆNH L2+ (pip, 1 giá = 10 pip) ===";
input bool    Bat_Cong_Spread_TP    = true;
input double  Khoang_Doi_SL         = 25;
input double  So_Pip_Doi_SL         = 15;
input double  Khoang_Trailing_SL    = 10;

input string  _DD            = "=== DD HEDGE LOCK (ngưỡng DD% do Owner nhập; lượt nghiên cứu OWNER12: TẮT) ===";
input bool    Bat_Cat_DD            = false;
input double  Cat_DD_PhanTram       = 0.0;
input ulong   DDLock_HedgeMagic     = 888838;
const bool    DDLock_EnableCompression = false;
const double  DDLock_CompressionKeepGrossPct = 100;
const int     DDLock_MaxAttempts    = 5;
const int     DDLock_RetryMinutes   = 5;
const int     DDLock_DeviationPoints = 30;
const bool    DDLock_OwnerAckResume = false;
const int     DDLock_CloseSlipPoints = 20;
const bool    DDLock_EpisodeLog     = true;

const int     RSI_Period     = 5;
const ENUM_TIMEFRAMES RSI_TF = PERIOD_M1;

input ulong   Magic          = 522345;

input string  _Time          = "=== GIỜ GIAO DỊCH: 3 PHIÊN (LOCAL GMT+7) ===";
input bool    UseTimeFilter  = true;
input int     ServerGMT      = 3;
input int     LocalGMT       = 7;
input bool    Enable_Asia        = true;
input int     Asia_StartHour     = 5;
input int     Asia_StartMinute   = 0;
input int     Asia_EndHour       = 14;
input int     Asia_EndMinute     = 0;
input bool    Enable_Europe      = true;
input int     Europe_StartHour   = 14;
input int     Europe_StartMinute = 0;
input int     Europe_EndHour     = 23;
input int     Europe_EndMinute   = 0;
input bool    Enable_US          = true;
input int     US_StartHour       = 19;
input int     US_StartMinute     = 0;
input int     US_EndHour         = 4;
input int     US_EndMinute       = 0;

input string  _Close         = "=== CHỐT PHIÊN VÀ XÁC NHẬN HAI LẦN (MinBeforeClose phút cuối cửa sổ liên tục) ===";
input int     MinBeforeClose = 60;
input int     CloseProtect_MaxOrders = 8;
input bool    CloseProtect_ApplyCycleLossRule = true;
input double  CloseProtect_CycleMaxLossPct    = 0.30;
input bool    Enable_DoubleConfirmation = true;
input int     ConfirmFromOrder = 19;

input string  _Step          = "=== BƯỚC LƯỚI: GN = khoảng từ L1 tới lệnh N+1 ===";
input double  G1  = 4;   input double  G2  = 4;   input double  G3  = 8;
input double  G4  = 8;   input double  G5  = 12;  input double  G6  = 12;
input double  G7  = 16;  input double  G8  = 16;  input double  G9  = 20;
input double  G10 = 20;  input double  G11 = 24;  input double  G12 = 24;
input double  G13 = 28;  input double  G14 = 28;  input double  G15 = 32;
input double  G16 = 32;  input double  G17 = 36;  input double  G18 = 36;
input double  G19 = 40;  input double  G20 = 40;  input double  G21 = 44;
input double  G22 = 44;  input double  G23 = 48;  input double  G24 = 48;
input double  G25 = 52;

enum OFH38_ENTRY_STRATEGY
{
   OFH38_ENTRY_V26    = 0,
   OFH38_ENTRY_GLOBAL = 1
};
input string  _Global        = "=== KIỂU VÀO LỆNH: 0 = V26 TRUYỀN THỐNG | 1 = GLOBAL GRID MODE 1 (chốt theo chu kỳ, đổi chỉ áp dụng từ chu kỳ phẳng kế tiếp) ===";
input OFH38_ENTRY_STRATEGY Entry_Strategy    = OFH38_ENTRY_V26;
input int     GlobalGrid_OrdersPerGroup      = 6;
input double  GlobalGrid_BreakoutDistanceUSD = 3.0;
input string  GlobalGrid_LocalDistancesPips  = "4,4,8,8,12,12,16,16,20,20,24,24,28,28,32,32,36,36,40,40,44,44,48,48,52";
input string  Enable_GlobalGridAIPro         = "NOT_USED";
const bool    GridLot_StrictBrokerLimits     = true;

enum OFH38_DZ_POLICY
{
   DZ_POLICY_FRM = 0,
   DZ_POLICY_FRT = 1,
   DZ_POLICY_MR  = 2
};
enum OFH38_DZ_GAPX
{
   DZ_GAPX_FILL  = 0,
   DZ_GAPX_CLAMP = 1
};
input string  _DynZone                       = "=== QUẢN LÝ VÙNG (DYNAMIC ZONE) — ỨNG VIÊN, CHƯA OWNER DUYỆT ===";
input bool    EnableDynamicZone              = false;
input int     MaxZones                       = 10;
input int     Zone_Phase1UnlockZones         = 3;
input double  ZoneStepUSD                    = 2.0;
input int     OrdersPerZonePerRound          = 3;
input int     MaxRoundsPerZone               = 2;
const OFH38_DZ_POLICY DynamicZone_ResearchPolicy     = DZ_POLICY_FRM;
const OFH38_DZ_GAPX   DynamicZone_ResearchGapExtrema = DZ_GAPX_FILL;

input string  _PairClose     = "=== PAIRCLOSE V26 — CHỐT CẶP 2 LỆNH MỞ MUỘN NHẤT (bộ PairClose DUY NHẤT của R7) ===";
input bool    PairClose_BatTat       = true;
input int     PairClose_TuLenh       = 12;
input double  PairClose_SoUSD        = 2.0;
input bool    PairClose_ChotDanVe    = true;

const double  Exit_CloseCostPerLotUSD        = 0.0;
const int     Exit_SlipReservePoints         = 5;
enum OFH38_EXIT_MODE
{
   EXIT_LEGACY    = 0,
   EXIT_T0_STATIC = 1,
   EXIT_T1_TREND  = 2,
   EXIT_T2_HYBRID = 3
};
const OFH38_EXIT_MODE Exit_Mode       = EXIT_LEGACY;
const ENUM_TIMEFRAMES ExitTrend_TF    = PERIOD_M5;
const int     ExitTrend_EmaFast        = 20;
const int     ExitTrend_EmaSlow        = 50;
const int     ExitTrend_AtrPeriod      = 14;
const double  ExitTrend_StrongScore    = 1.0;
const double  ExitHyb_FloorStartPips   = 50;
const double  ExitHyb_FloorKeepPct     = 50;
const double  ExitHyb_AtrMultWeak      = 1.0;
const double  ExitHyb_AtrMultStrong    = 2.0;
const double  ExitHyb_TrailMinPips     = 10;
const double  ExitHyb_TrailMaxPips     = 80;

const bool    ManualReentry_Enable        = false;
const bool    ManualReentry_DoubleConfirm = true;

const int     Exec_ConfirmMs         = 1000;
const int     Exec_MaxAttempts       = 20;
const int     Exec_StallRetryMinutes = 5;
const bool    Exit_LogCsv            = true;
const bool    V26State_Persist       = true;
const bool    ManualPartial_FreezeGrid = true;
const int     ManualReentry_ReconcileSec  = 30;

CTradeV38 trade;
int      hRSI;
double   rsiVal[];
double   PipSize;

int      OrderCount      = 0;
double   FirstPrice      = 0;
int      FirstType       = -1;

ulong    LastSentOrder   = 0;
datetime LastSentTime    = 0;
int      LastSentCount   = 0;
int      ConfirmWait     = 10;

bool     WaitNextSession = false;
datetime WaitUntilTime   = 0;

int      DblConfirmNum   = 0;
bool     DblConfirmHit1  = false;
bool     DblConfirmReady = false;

bool     hedgeTrailActive = false;
double   hedgeBePrice     = 0;
double   hedgeExitPrice   = 0;
double   hedgeClusterBe   = 0;
double   hedgeT1Trigger   = 0;
double   hedgeLockMoney   = 0;
int      hedgeTrailDir    = 0;

bool     basketModeLatched = false;
bool     t1Locked          = false;
int      t1Dir             = 0;
bool     t2Armed           = false;

bool     skipGridThisTick  = false;

bool     sessionRescue     = false;

#ifndef OFH38_EXEC_MQH
#define OFH38_EXEC_MQH

#ifndef OFH38_EXEC_CORE_MQH
#define OFH38_EXEC_CORE_MQH

#define EX38_OP_OPEN     0
#define EX38_OP_CLOSE    1
#define EX38_OP_MODIFY   2
#define EX38_OP_CLOSEBY  3

#define EXC_DONE         0
#define EXC_PARTIAL      1
#define EXC_INFLIGHT     2
#define EXC_UNKNOWN      3
#define EXC_NOCHANGE     4
#define EXC_RETRY_FAST   5
#define EXC_RETRY_SLOW   6
#define EXC_WAIT_MARKET  7
#define EXC_STOPS        8
#define EXC_GONE         9
#define EXC_FATAL       10

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

int Ex38Classify(const int op, const uint rc)
{
   switch(rc)
   {
      case 10009: return EXC_DONE;
      case 10010: return EXC_PARTIAL;
      case 10008: return EXC_INFLIGHT;
      case 10028: return EXC_INFLIGHT;
      case 10039: return (op == EX38_OP_CLOSE || op == EX38_OP_CLOSEBY) ? EXC_INFLIGHT : EXC_FATAL;
      case 10012: return EXC_UNKNOWN;
      case 10025: return (op == EX38_OP_MODIFY) ? EXC_NOCHANGE : EXC_FATAL;
      case 10004: case 10020: case 10021: case 10015:
      case 10006: case 10007: case 10011: case 10023: return EXC_RETRY_FAST;
      case 10024: case 10031: case 10029: return EXC_RETRY_SLOW;
      case 10018: case 10017: case 10026: case 10027: return EXC_WAIT_MARKET;
      case 10016: return (op == EX38_OP_MODIFY) ? EXC_STOPS : EXC_FATAL;
      case 10036: return (op == EX38_OP_OPEN) ? EXC_FATAL : EXC_GONE;
      case 10019: return (op == EX38_OP_OPEN) ? EXC_FATAL : EXC_RETRY_SLOW;
      case 10038: return (op == EX38_OP_CLOSE) ? EXC_RETRY_FAST : EXC_FATAL;
      case 10044: return (op == EX38_OP_OPEN) ? EXC_FATAL : EXC_RETRY_FAST;
      case 0:     return EXC_RETRY_SLOW;
   }
   return EXC_FATAL;
}

bool Ex38IsRetryClass(const int c) { return c == EXC_RETRY_FAST || c == EXC_RETRY_SLOW || c == EXC_WAIT_MARKET || c == EXC_STOPS || c == EXC_FATAL; }

long Ex38BackoffMs(const int cls, const int attempt)
{
   const int a = MathMax(1, MathMin(attempt, 7));
   switch(cls)
   {
      case EXC_RETRY_FAST:  return MathMin(250L * (1L << (a - 1)), 5000L);
      case EXC_RETRY_SLOW:  return MathMin(1000L * (1L << (a - 1)), 30000L);
      case EXC_WAIT_MARKET: return MathMin(1000L * (1L << (a - 1)), 60000L);
      case EXC_STOPS:       return 1L;
      case EXC_FATAL:       return 60000L;
   }
   return 0L;
}

double Ex38PriceTol(const double tickSize, const double point) { return MathMax(tickSize, point) * 0.5 + point * 0.001; }
bool Ex38SamePrice(const double a, const double b, const double tol)
{
   if(a <= 0.0 && b <= 0.0) return true;
   if(a <= 0.0 || b <= 0.0) return false;
   return MathAbs(a - b) <= tol;
}

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

#define SAF_UNKNOWN_RESOLVE_SEC 300

#define SAF_OR_DONE      0
#define SAF_OR_PLACED    1
#define SAF_OR_UNKNOWN   2
#define SAF_OR_REJECTED  3
#define SAF_OR_THROTTLED 4
#define SAF_OR_NOTSENT   5
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
         return SAF_OR_REJECTED;
   }
   return SAF_OR_UNKNOWN;
}
#define SAF_ER_WAIT     0
#define SAF_ER_EXECUTED 1
#define SAF_ER_NOTEXEC  2
int Saf38EntryResolve(const bool dealIn, const bool posListed, const bool posClosed, const bool orderWorking, const int histState, const long elapsedMs, const long resolveMs,
                      const bool connected)
{
   if(dealIn || histState == 0) return (posListed || posClosed) ? SAF_ER_EXECUTED : SAF_ER_WAIT;
   if(posListed || posClosed) return SAF_ER_EXECUTED;
   if(orderWorking) return SAF_ER_WAIT;
   if(histState == 1) return SAF_ER_NOTEXEC;
   if(connected && elapsedMs >= resolveMs) return SAF_ER_NOTEXEC;
   return SAF_ER_WAIT;
}
string Saf38ErName(const int r) { return r == SAF_ER_WAIT ? "WAIT_BROKER_EVIDENCE" : (r == SAF_ER_EXECUTED ? "EXECUTED" : (r == SAF_ER_NOTEXEC ? "NOT_EXECUTED" : "?")); }
bool Saf38DealIsOfRequest(const ulong dealTicket, const ulong wm, const long dealMsc, const long reqMsc) { return dealTicket > wm && dealMsc >= reqMsc - (long)SAF_UNKNOWN_RESOLVE_SEC * 1000; }
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
int Saf38LegResolve(const double vol0, const double liveVol, const bool closeOrderWorking, const long elapsedMs, const long resolveMs, const bool connected, const double tol)
{
   if(closeOrderWorking) return SAF_ER_WAIT;
   if(liveVol < vol0 - tol) return SAF_ER_EXECUTED;
   if(connected && elapsedMs >= resolveMs) return SAF_ER_NOTEXEC;
   return SAF_ER_WAIT;
}

bool Saf38MrSendAllowed(const bool ddActive, const bool exitActive, const bool pairPending, const bool t1Lock, const bool trailActive)
{
   return !(ddActive || exitActive || pairPending || t1Lock || trailActive);
}

#define SAF_MRR_RESTORE          0
#define SAF_MRR_CANCEL           1
#define SAF_MRR_CANCEL_RECONCILE 2
#define SAF_MRR_RECONCILE_ONLY   3
int Saf38MrRestoreAction(const bool sameCycle, const bool reentryOn, const bool inFlight, const bool alreadyCancelReconcile)
{
   if(sameCycle && reentryOn) return SAF_MRR_RESTORE;
   if(!inFlight) return SAF_MRR_CANCEL;
   if(alreadyCancelReconcile || !sameCycle) return SAF_MRR_CANCEL_RECONCILE;
   return SAF_MRR_RECONCILE_ONLY;
}
#define SAF_ORPH_NONE         0
#define SAF_ORPH_CLOSE_BASKET 1
#define SAF_ORPH_KEEP         2
int Saf38OrphanAction(const int openPositions, const int orphanPositions)
{
   if(orphanPositions <= 0) return SAF_ORPH_NONE;
   return orphanPositions >= openPositions ? SAF_ORPH_CLOSE_BASKET : SAF_ORPH_KEEP;
}

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

bool Saf38MayPersist(const int deinitReason, const bool restorePending) { return deinitReason != REASON_INITFAILED && !restorePending; }

void Saf38WidenRange(double &hi, double &lo, const double histHi, const double histLo)
{
   if(histHi > hi) hi = histHi;
   if(histLo > 0.0 && (lo <= 0.0 || histLo < lo)) lo = histLo;
}

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

#define SAF_CLR_WAIT 0
#define SAF_CLR_SEND 1
int Saf38CloseResendDecision(const bool closeOrderWorking, const bool dealSinceReq, const int histState, const long elapsedMs, const long confirmMs, const long resolveMs, const bool connected)
{
   if(elapsedMs < confirmMs) return SAF_CLR_WAIT;
   if(closeOrderWorking) return SAF_CLR_WAIT;
   if(dealSinceReq) return SAF_CLR_SEND;
   if(histState == 1) return SAF_CLR_SEND;
   if(histState == 0) return SAF_CLR_WAIT;
   if(elapsedMs < resolveMs || !connected) return SAF_CLR_WAIT;
   return SAF_CLR_SEND;
}

bool   g_safSendHeld = false;
long   g_ddlInflightTickMsc = 0;
ulong  g_ddlInflightWm = 0;
ulong  g_ddlLegTk = 0; long g_ddlLegMsc = 0; double g_ddlLegVol0 = 0.0;
bool   g_lbSyncDeferred = false;
Saf38EntryRec g_seRec;
long   g_seNextMs = 0; int g_seThrottleN = 0;
long   g_safHoldWorking = 0, g_safHoldUnknown = 0, g_safHoldThrottle = 0, g_safUnknownSet = 0, g_safExecuted = 0, g_safNotExec = 0, g_safPlacedWait = 0;
long   g_safDdlWait = 0, g_safOrphanKeep = 0, g_safMrReconcileOnly = 0;
long   g_safNoPersist = 0;
long   g_safT1Pending = 0, g_safT1LateDeclared = 0, g_safExClWait = 0, g_safExClWorking = 0;
long   g_safT1PendEp = 0, g_safT1PendCyc = 0, g_safExClFilledHold = 0;
string g_safOnce = "";
void   SafLogOnce(const string key, const string text) { const string k = "|" + key + "|"; if(StringFind(g_safOnce, k) >= 0) return; g_safOnce += k; if(StringLen(g_safOnce) > 6000) g_safOnce = k; Print(text); }
string SafEntryNs() { return OfhNs("OFH38Q", Magic); }
ulong  SafWorkingMagicOrder()
{
   for(int k = OrdersTotal() - 1; k >= 0; k--)
   {
      const ulong t = OrderGetTicket(k);
      if(t != 0 && OrderGetString(ORDER_SYMBOL) == _Symbol && (ulong)OrderGetInteger(ORDER_MAGIC) == Magic) return t;
   }
   return 0;
}
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
void SafEntryEvidence(const ulong mg, const ulong ord, const long sinceMsc, const ulong wm, bool &dealIn, bool &posListed, bool &posClosed, bool &working, int &hist)
{
   dealIn = false; posListed = false; posClosed = false; working = false; hist = -1;
   for(int k = OrdersTotal() - 1; k >= 0 && !working; k--)
   {
      const ulong t = OrderGetTicket(k);
      if(t != 0 && (t == ord || (OrderGetString(ORDER_SYMBOL) == _Symbol && (ulong)OrderGetInteger(ORDER_MAGIC) == mg))) working = true;
   }
   ulong pid = ord;
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
            if(StringFind(HistoryDealGetString(d, DEAL_COMMENT), "R2MR|") == 0) continue;
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
void SafEntryIntent(const int cnt)
{
   g_seRec.st = 2; g_seRec.ord = 0; g_seRec.msc = Ex38TickMsc(); g_seRec.cnt = cnt; g_seRec.rc = 0; g_seRec.mg = Magic; g_seRec.wm = SafEntryWatermark(Magic);
   const string ns = SafEntryNs(); Saf38EntryRecSave(ns, g_seRec); OfhIdStore(ns, Magic); GlobalVariablesFlush();
}
void SafEntryClear() { Saf38EntryRecReset(g_seRec); Saf38EntryRecSave(SafEntryNs(), g_seRec); }
void SafEntrySetUnknown(const int cnt, const ulong ord, const uint rc)
{
   if(g_seRec.st != 2) { g_seRec.msc = Ex38TickMsc(); g_seRec.wm = 0; }
   g_seRec.st = 1; g_seRec.ord = ord; g_seRec.cnt = cnt; g_seRec.rc = rc; g_seRec.mg = Magic; g_safUnknownSet++;
   const string ns = SafEntryNs(); Saf38EntryRecSave(ns, g_seRec); OfhIdStore(ns, Magic); GlobalVariablesFlush();
   PrintFormat("SAFETY ENTRY UNKNOWN | request for position #%d rc=%u (%s) order %I64u: the broker result is not known -> no further L1 / grid request until broker evidence (deal newer than %I64u / order history) or %d s with no order, no deal, no position",
               cnt, rc, trade.ResultComment(), ord, g_seRec.wm, SAF_UNKNOWN_RESOLVE_SEC);
}
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
bool SafEntryHold()
{
   g_safSendHeld = false;
   const ulong wo = SafWorkingMagicOrder();
   if(wo != 0)
   {
      g_safHoldWorking++; g_safSendHeld = true;
      SafLogOnce("SEWORK_" + IntegerToString((long)wo), StringFormat("SAFETY ENTRY HOLD | Magic order %I64u still works at the broker (PLACED / not filled yet): no new L1 / grid request and no replacement order until its result is known", wo));
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
bool SafFirst(const string key) { const string k = "|" + key + "|"; if(StringFind(g_safOnce, k) >= 0) return false; g_safOnce += k; if(StringLen(g_safOnce) > 6000) g_safOnce = k; return true; }
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
   PrintFormat("V38 SAFETY COUNTERS %s | entry: held (Magic order working) %I64d, held (no broker result) %I64d, held (throttle) %I64d, PLACED waits %I64d, unknown recorded %I64d, resolved executed %I64d / not executed %I64d | DD hedge / leg evidence waits %I64d | MR: RECONCILE_ONLY at restart %I64d, orphan basket kept %I64d | records not written (no restore) %I64d | R1: T1 protection pending %I64d ticks in %I64d cycles, T1 declared late %I64d, exit close waits (not reconciled) %I64d, exit close waits (close order working) %I64d, exit close FILLED-without-deal holds %I64d | open entry record %s",
               when, g_safHoldWorking, g_safHoldUnknown, g_safHoldThrottle, g_safPlacedWait, g_safUnknownSet, g_safExecuted, g_safNotExec,
               g_safDdlWait, g_safMrReconcileOnly, g_safOrphanKeep, g_safNoPersist,
               g_safT1Pending, g_safT1PendEp, g_safT1LateDeclared, g_safExClWait, g_safExClWorking, g_safExClFilledHold,
               g_seRec.st == 0 ? "none" : StringFormat("#%d order %I64u rc %u tick %I64d", g_seRec.cnt, g_seRec.ord, g_seRec.rc, g_seRec.msc));
}

#define EXM_CONFIRMED 0
#define EXM_PENDING   1
#define EXM_FAILED    2
#define EXM_GONE      3

#define EXCL_CLOSED   0
#define EXCL_PENDING  1
#define EXCL_PARTIAL  2
#define EXCL_RETRY    3
#define EXCL_STALLED  4

long g_exModReq = 0, g_exModConfirmed = 0, g_exModPending = 0, g_exModFail = 0, g_exModSkipSame = 0, g_exModSkipPending = 0, g_exModSkipBackoff = 0, g_exModSkipInvalid = 0;
long g_exClReq = 0, g_exClClosed = 0, g_exClPending = 0, g_exClPartial = 0, g_exClFail = 0, g_exClSkipPending = 0, g_exClSkipBackoff = 0, g_exClStalled = 0;
long g_exModTwiceTick = 0;
long g_exLastModMsc = 0; ulong g_exLastModTicket = 0;

long g_exClSkipClosed = 0, g_exModSkipClosed = 0;
long g_exClWorkingWait = 0;
bool Ex38CloseOrderWorking(const ulong position)
{
   for(int k = OrdersTotal() - 1; k >= 0; k--)
   {
      const ulong o = OrderGetTicket(k);
      if(o != 0 && OrderGetString(ORDER_SYMBOL) == _Symbol && (ulong)OrderGetInteger(ORDER_POSITION_ID) == position) return true;
   }
   return false;
}
long g_exGraceUntil = 0;
void Ex38RestartGrace(const string why) { g_exGraceUntil = Ex38NowMs() + MathMax(1, Exec_ConfirmMs); PrintFormat("EXEC RESTART GRACE %d ms | %s: a request sent before the restart may still be in flight - no close / hedge before the broker positions are re-read", Exec_ConfirmMs, why); }

long Ex38TickMsc() { MqlTick t; if(SymbolInfoTick(_Symbol, t) && t.time_msc > 0) return t.time_msc; return (long)TimeCurrent() * 1000; }
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

struct Ex38ModRec { ulong ticket; double sl, tp; int st; int attempts; long nextMs, deadlineMs; uint rc; bool unknown; bool closedSched; };
Ex38ModRec g_exMod[];
int  Ex38ModFind(const ulong t) { for(int i = 0; i < ArraySize(g_exMod); i++) if(g_exMod[i].ticket == t) return i; return -1; }
void Ex38ModDel(const int i) { const int n = ArraySize(g_exMod); if(i < 0 || i >= n) return; g_exMod[i] = g_exMod[n - 1]; ArrayResize(g_exMod, n - 1); }
int  Ex38ModPut(const ulong t, const double sl, const double tp)
{
   int i = Ex38ModFind(t);
   if(i < 0) { i = ArraySize(g_exMod); ArrayResize(g_exMod, i + 1); g_exMod[i].ticket = t; g_exMod[i].attempts = 0; }
   else if(!(Ex38SamePrice(g_exMod[i].sl, sl, Ex38Tol()) && Ex38SamePrice(g_exMod[i].tp, tp, Ex38Tol()))) g_exMod[i].attempts = 0;
   g_exMod[i].sl = sl; g_exMod[i].tp = tp; g_exMod[i].nextMs = 0; g_exMod[i].deadlineMs = 0; g_exMod[i].unknown = false; g_exMod[i].closedSched = false;
   return i;
}

struct Ex38ClRec { ulong ticket; int st; int attempts; long nextMs, deadlineMs; uint rc; double vol0; bool closedSched; ulong ord; long reqMsc; ulong dwm; ulong known; ulong po1; ulong po2; };
Ex38ClRec g_exCl[];
int  Ex38ClFind(const ulong t) { for(int i = 0; i < ArraySize(g_exCl); i++) if(g_exCl[i].ticket == t) return i; return -1; }
void Ex38ClDel(const int i) { const int n = ArraySize(g_exCl); if(i < 0 || i >= n) return; g_exCl[i] = g_exCl[n - 1]; ArrayResize(g_exCl, n - 1); }
int  Ex38ClState(const ulong t) { const int i = Ex38ClFind(t); return i < 0 ? -1 : g_exCl[i].st; }
void Ex38ResetRegistries() { ArrayResize(g_exMod, 0); ArrayResize(g_exCl, 0); }

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
   if(Ex38SamePrice(curSl, sl, tol) && Ex38SamePrice(curTp, tp, tol))
   {
      if(sameTarget && g_exMod[i].st == EXM_PENDING) { g_exModConfirmed++; PrintFormat("EXEC MODIFY CONFIRMED ticket=%I64u sl=%.5f tp=%.5f (observed after rc=%u)", ticket, sl, tp, g_exMod[i].rc); }
      else g_exModSkipSame++;
      if(i >= 0) Ex38ModDel(i);
      return EXM_CONFIRMED;
   }
   const long now = Ex38NowMs();
   if(sameTarget && g_exMod[i].st == EXM_PENDING && now < g_exMod[i].deadlineMs) { g_exModSkipPending++; return EXM_PENDING; }
   if(!Ex38TradeSessionOpen())
   {
      i = Ex38ModPut(ticket, sl, tp);
      g_exMod[i].st = EXM_FAILED; g_exMod[i].rc = TRADE_RETCODE_MARKET_CLOSED; g_exMod[i].closedSched = true; g_exMod[i].nextMs = now;
      g_exModSkipClosed++;
      return EXM_FAILED;
   }
   if(sameTarget && g_exMod[i].st == EXM_FAILED && now < g_exMod[i].nextMs && !g_exMod[i].closedSched) { g_exModSkipBackoff++; return EXM_FAILED; }
   if(i >= 0 && !sameTarget && g_exMod[i].st == EXM_PENDING && g_exMod[i].unknown && now < g_exMod[i].deadlineMs) { g_exModSkipPending++; return EXM_PENDING; }
   if(sameTarget && g_exMod[i].attempts >= MathMax(1, Exec_MaxAttempts))
   {
      g_exMod[i].st = EXM_FAILED; g_exMod[i].attempts = 0; g_exMod[i].nextMs = now + (long)MathMax(1, Exec_StallRetryMinutes) * 60000;
      PrintFormat("EXEC MODIFY STALLED ticket=%I64u sl=%.5f tp=%.5f | %d attempts without the levels on the broker (last rc=%u) | next try in %d min", ticket, sl, tp, Exec_MaxAttempts, g_exMod[i].rc, Exec_StallRetryMinutes);
      return EXM_FAILED;
   }
   MqlTick tk;
   if(SymbolInfoTick(_Symbol, tk))
   {
      const double freeze = (double)SymbolInfoInteger(_Symbol, SYMBOL_TRADE_FREEZE_LEVEL) * _Point;
      const double stops  = (double)SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL) * _Point;
      const bool frozen = Ex38Frozen(isBuy, curSl, curTp, tk.bid, tk.ask, freeze);
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
   if(match)
   {
      g_exModConfirmed++; Ex38ModDel(i);
      return EXM_CONFIRMED;
   }
   if(cls == EXC_DONE || cls == EXC_NOCHANGE || cls == EXC_PARTIAL || cls == EXC_INFLIGHT || cls == EXC_UNKNOWN)
   {
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

int Ex38Close(CTradeV38 &t, const ulong ticket, const string who)
{
   if(ticket == 0) return EXCL_RETRY;
   int i = Ex38ClFind(ticket);
   if(!PositionSelectByTicket(ticket)) { if(i >= 0) Ex38ClDel(i); return EXCL_CLOSED; }
   const double vol = PositionGetDouble(POSITION_VOLUME);
   const ulong pid = (ulong)PositionGetInteger(POSITION_IDENTIFIER);
   const long now = Ex38NowMs();
   if(i < 0) { i = ArraySize(g_exCl); ArrayResize(g_exCl, i + 1); g_exCl[i].ticket = ticket; g_exCl[i].st = EXCL_RETRY; g_exCl[i].attempts = 0; g_exCl[i].nextMs = 0; g_exCl[i].deadlineMs = 0; g_exCl[i].rc = 0; g_exCl[i].vol0 = vol; g_exCl[i].closedSched = false; g_exCl[i].ord = 0; g_exCl[i].reqMsc = 0; g_exCl[i].dwm = 0; g_exCl[i].known = 0; g_exCl[i].po1 = 0; g_exCl[i].po2 = 0; }
   if(now < g_exGraceUntil) { g_exClSkipPending++; return EXCL_PENDING; }
   if(g_exCl[i].st == EXCL_PENDING)
   {
      if(now < g_exCl[i].deadlineMs) { g_exClSkipPending++; return EXCL_PENDING; }
      if(Ex38CloseOrderWorking(ticket) || SafCloseOrderTicket(pid) != 0)
      {
         g_exCl[i].deadlineMs = now + MathMax(1, Exec_ConfirmMs); g_exClSkipPending++; g_exClWorkingWait++;
         if(g_exClWorkingWait == 1 || g_exClWorkingWait % 100 == 0) PrintFormat("EXEC CLOSE ticket=%I64u (%s) | a close order of this position is still working at the broker - waiting for it, no second close request", ticket, who);
         return EXCL_PENDING;
      }
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
            if(SafFirst(StringFormat("EXCLF_%I64u_%I64u", ticket, g_exCl[i].ord))) g_safExClFilledHold++;
            if(SafFirst(StringFormat("EXCLFR_%I64u_%I64u_%I64d", ticket, g_exCl[i].ord, elS / 900000)))
               PrintFormat("EXEC CLOSE RECONCILE HOLD ticket=%I64u (%s) | order %I64u is FILLED in the history for %I64d s but no closing deal / volume change is visible: executed per the broker history - no second close request; the exit keeps the basket (no grid / no L1) - OWNER CHECK REQUIRED if it persists (SAFETY S13)",
                           ticket, who, g_exCl[i].ord, elS / 1000);
         }
         return EXCL_PENDING;
      }
      PrintFormat("EXEC CLOSE ticket=%I64u still open %d ms after rc=%u (%.2f lots) - not observed closed, no close order working at the broker, resend allowed | reconciled: deal since the request %d, order history %d (SAFETY S13)", ticket, Exec_ConfirmMs, g_exCl[i].rc, vol, dlS ? 1 : 0, hsS);
   }
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
   if(sent)
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
#ifndef OFH38_SESSIONS_MQH
#define OFH38_SESSIONS_MQH

#ifndef OFH38_SESSIONS_CORE_MQH
#define OFH38_SESSIONS_CORE_MQH

struct Sess38Def { bool on; int start_min; int end_min; };

datetime Sess38Midnight(const datetime t) { MqlDateTime d; TimeToStruct(t, d); return t - (datetime)(d.hour * 3600 + d.min * 60 + d.sec); }

int Sess38Build(const Sess38Def &s[], const int n, const datetime tLocal, datetime &ws[], datetime &we[])
{
   datetime st[], en[]; int k = 0;
   const datetime d0 = Sess38Midnight(tLocal);
   for(int d = -3; d <= 10; d++)
   {
      const datetime day = d0 + (datetime)(d * 86400);
      MqlDateTime md; TimeToStruct(day, md);
      if(md.day_of_week < 1 || md.day_of_week > 5) continue;
      for(int i = 0; i < n; i++)
      {
         if(!s[i].on || s[i].start_min == s[i].end_min) continue;
         const datetime a = day + (datetime)(s[i].start_min * 60);
         const datetime b = (s[i].end_min > s[i].start_min) ? day + (datetime)(s[i].end_min * 60) : day + (datetime)(86400 + s[i].end_min * 60);
         ArrayResize(st, k + 1); ArrayResize(en, k + 1); st[k] = a; en[k] = b; k++;
      }
   }
   for(int i = 1; i < k; i++)
   {
      const datetime a = st[i], b = en[i]; int j = i - 1;
      while(j >= 0 && st[j] > a) { st[j + 1] = st[j]; en[j + 1] = en[j]; j--; }
      st[j + 1] = a; en[j + 1] = b;
   }
   ArrayResize(ws, 0); ArrayResize(we, 0); int m = 0;
   for(int i = 0; i < k; i++)
   {
      if(m > 0 && st[i] <= we[m - 1]) { if(en[i] > we[m - 1]) we[m - 1] = en[i]; continue; }
      ArrayResize(ws, m + 1); ArrayResize(we, m + 1); ws[m] = st[i]; we[m] = en[i]; m++;
   }
   return m;
}

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

bool Sess38NearEnd(const bool inHours, const datetime winEnd, const datetime tLocal, const int minBefore)
{
   if(!inHours || winEnd <= 0) return false;
   return (tLocal >= winEnd - (datetime)(minBefore * 60));
}

bool Sess38Valid(const int h, const int mi) { return h >= 0 && h <= 23 && mi >= 0 && mi <= 59; }

#endif
#ifndef OFH_V2_IDENTITY_MQH
#define OFH_V2_IDENTITY_MQH

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
bool   OfhIdReady() { return (bool)MQLInfoInteger(MQL_TESTER) || (OfhLogin() > 0 && OfhServer() != ""); }
string OfhIdText(const ulong magic) { return StringFormat("%I64d|%s|%s|%I64u", OfhLogin(), OfhServer(), _Symbol, magic); }
string OfhNs(const string module, const ulong magic) { return module + "_" + OfhFnv8(OfhIdText(magic)) + "_"; }

void OfhIdStore(const string prefix, const ulong magic)
{
   GlobalVariableSet(prefix + "idlogin", (double)OfhLogin());
   GlobalVariableSet(prefix + "idsrv", (double)OfhFnv32(OfhServer()));
   GlobalVariableSet(prefix + "idsym", (double)OfhFnv32(_Symbol));
   GlobalVariableSet(prefix + "idmagic", (double)magic);
}
string OfhIdCheck(const string prefix, const ulong magic)
{
   if(!GlobalVariableCheck(prefix + "idlogin")) return "NO_IDENTITY_FIELDS";
   if((long)GlobalVariableGet(prefix + "idlogin") != OfhLogin()) return "LOGIN";
   if((uint)GlobalVariableGet(prefix + "idsrv") != OfhFnv32(OfhServer())) return "SERVER";
   if((uint)GlobalVariableGet(prefix + "idsym") != OfhFnv32(_Symbol)) return "SYMBOL";
   if((ulong)GlobalVariableGet(prefix + "idmagic") != magic) return "MAGIC";
   return "";
}

bool OfhTicketIsOurs(const ulong t, const ulong m1, const ulong m2 = 0, const ulong m3 = 0)
{
   if(t == 0 || !PositionSelectByTicket(t) || PositionGetString(POSITION_SYMBOL) != _Symbol) return false;
   const ulong mg = (ulong)PositionGetInteger(POSITION_MAGIC);
   return mg == m1 || (m2 != 0 && mg == m2) || (m3 != 0 && mg == m3);
}

#endif

Sess38Def g_sDef[3];
datetime  g_sWs[], g_sWe[];
int       g_sN       = 0;
long      g_sMinKey  = -1;
datetime  g_sDayKey  = -1;
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

string SessNs() { return OfhNs("OFH38S", Magic); }

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

void SessRescueRefresh()
{
   if(!sessionRescue) return;
   GlobalVariableSet(SessNs() + "basket", (double)SessBasketId());
   GlobalVariablesFlush();
}

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
#ifndef OFH38_GLOBALGRID_MQH
#define OFH38_GLOBALGRID_MQH

#ifndef OFH38_GLOBALGRID_CORE_MQH
#define OFH38_GLOBALGRID_CORE_MQH

#define GG38_MAXG 32

int  Gg38GroupCount(const int k, const int maxOrders)
{
   int n = (maxOrders + k - 1) / k;
   if(n > 1 && maxOrders % k == 1) n--;
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

double Gg38InternalTrigger(const double anchorPx, const bool isBuy, const double dist) { return isBuy ? anchorPx + dist : anchorPx - dist; }
double Gg38BreakoutTrigger(const bool isBuy, const double groupHigh, const double groupLow, const double d) { return isBuy ? groupHigh + d : groupLow - d; }

#define GG38_LD_MAX        64
#define GG38_LD_OK          0
#define GG38_LD_EMPTY      -1
#define GG38_LD_FORMAT     -2
#define GG38_LD_NEGATIVE   -3
#define GG38_LD_NOT_FINITE -4
#define GG38_LD_TOO_LONG   -5
#define GG38_LD_SHORT      -6
#define GG38_LD_TEXT_LONG  -7
#define GG38_LD_MIXED_SEP  -8
#define GG38_LD_TEXT_MAX  224

int    Gg38GroupSize(const int g, const int k, const int levels) { return Gg38EndOf(g, k, levels) - Gg38AnchorOf(g, k) + 1; }
int    Gg38LocalIndex(const int level, const int k, const int levels) { return level - Gg38AnchorOf(Gg38GroupOf(level, k, levels), k); }
int    Gg38MaxInternal(const int k, const int levels)
{
   int m = 0;
   const int n = Gg38GroupCount(k, levels);
   for(int g = 0; g < n; g++) { const int s = Gg38GroupSize(g, k, levels) - 1; if(s > m) m = s; }
   return m;
}
int    Gg38LdRequired(const int k, const int maxOrders) { const int a = Gg38MaxInternal(k, maxOrders), b = Gg38MaxInternal(k, maxOrders + 1); return a > b ? a : b; }

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
int    Gg38LdParse(const string s, double &out[], int &badPos)
{
   ArrayResize(out, 0); badPos = 0;
   if(StringLen(s) > GG38_LD_TEXT_MAX) return GG38_LD_TEXT_LONG;
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
double Gg38LocalTrigger(const double anchorPx, const bool isBuy, const double ldPips, const double pip) { return Gg38InternalTrigger(anchorPx, isBuy, ldPips * pip); }
double Gg38BreakoutGridPx(const bool isBuy, const double groupHigh, const double groupLow, const double d, const double point)
{
   const double x = Gg38BreakoutTrigger(isBuy, groupHigh, groupLow, d);
   if(point <= 0.0) return x;
   const double q = x / point;
   return (isBuy ? MathCeil(q - 1e-6) : MathFloor(q + 1e-6)) * point;
}
bool   Gg38LdDiffers(const double &a[], const int na, const double &b[], const int nb)
{
   if(na != nb) return true;
   for(int i = 0; i < na; i++) if(MathAbs(a[i] - b[i]) > 1e-9 * MathMax(1.0, MathAbs(b[i]))) return true;
   return false;
}
string Gg38Num(const double v)
{
   string s = DoubleToString(v, 8);
   if(StringFind(s, ".") >= 0) { int e = StringLen(s); while(e > 0 && StringGetCharacter(s, e - 1) == '0') e--; if(e > 0 && StringGetCharacter(s, e - 1) == '.') e--; s = StringSubstr(s, 0, e); }
   return s;
}
string Gg38LdText(const double &a[], const int n) { string s = ""; for(int i = 0; i < n; i++) s += (i > 0 ? "," : "") + Gg38Num(a[i]); return s; }
string Gg38LayoutText(const int k, const int levels)
{
   string s = "";
   const int n = Gg38GroupCount(k, levels);
   for(int g = 0; g < n; g++) s += StringFormat("%sL%d-L%d", g > 0 ? "," : "", Gg38AnchorOf(g, k), Gg38EndOf(g, k, levels));
   return s;
}
#define GG38_NPD_OK          0
#define GG38_NPD_NO_REF     -1
#define GG38_NPD_UNPROVEN   -2
#define GG38_NPD_SIDE_BAD   -3
#define GG38_NPD_PRICE_BAD  -4
#define GG38_NPD_BAD_GROUP  -5
#define GG38_NPD_MAP        -6
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
      if(!MathIsValidNumber(px[i]) || px[i] <= 0.0) { ref = 0.0; refIdx = -1; sameSide = 0; return GG38_NPD_PRICE_BAD; }
      sameSide++;
      if(refIdx < 0 || (isBuy ? px[i] > ref : px[i] < ref)) { ref = px[i]; refIdx = i; }
   }
   return sameSide > 0 ? GG38_NPD_OK : GG38_NPD_NO_REF;
}
double Gg38NpdTriggerPx(const bool isBuy, const double ref, const double d, const double point) { return Gg38BreakoutGridPx(isBuy, ref, ref, d, point); }
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

#endif
#ifndef OFH38_MANUALRECOVERY_CORE_MQH
#define OFH38_MANUALRECOVERY_CORE_MQH

#define MR_WAIT_PRICE        1
#define MR_CONFIRM_1         2
#define MR_WAIT_RETURN       3
#define MR_READY             4
#define MR_IN_FLIGHT         5
#define MR_PARTIAL           6
#define MR_FILLED            7
#define MR_REMOVE_PENDING    8
#define MR_RETRY             9
#define MR_STALLED          10
#define MR_SUSPENDED        11
#define MR_CANCEL_RECONCILE 12
#define MR_CANCELLED        13
#define MR_RECONCILE_ONLY   14

#define MRF_REENTRY_OFF     1
#define MRF_RECORD_CAP      2
#define MRF_DEAL_UNREADABLE 3
#define MRF_OUT_OF_ORDER    4
#define MRF_OVERFILL        5
#define MRF_SIDE_MISMATCH   6
#define MRF_LEVEL_UNPROVEN  7
#define MRF_GLOBAL_UNPROVEN 8

#define MRB_MERGE        1
#define MRB_RECEIPT_ONLY 2
#define MRB_CREATE       3
#define MRB_ABANDON      4
#define MRB_REENTRY_OFF  5

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

bool Mr38Definitive(const bool orderWorking, const int ordersSeen, const int ordersFinal, const bool lastRequestCovered, const bool doneReply, const bool fillIncreased)
{
   if(orderWorking) return false;
   if(doneReply && fillIncreased) return true;
   return ordersSeen > 0 && ordersFinal == ordersSeen && lastRequestCovered;
}

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
bool Mr38Terminal(const int s)  { return s == MR_FILLED || s == MR_REMOVE_PENDING || s == MR_CANCELLED; }
bool Mr38InFlight(const int s)  { return s == MR_IN_FLIGHT || s == MR_CANCEL_RECONCILE || s == MR_RECONCILE_ONLY; }
bool Mr38BlocksGrid(const int s) { return !Mr38Terminal(s) && s != MR_SUSPENDED && s != MR_CANCEL_RECONCILE && s != MR_RECONCILE_ONLY; }
bool Mr38PriceState(const int s) { return s == MR_WAIT_PRICE || s == MR_CONFIRM_1 || s == MR_WAIT_RETURN; }

int  Mr38Away(const double entry, const double px, const double off) { if(px > entry + off) return 1; if(px < entry - off) return -1; return 0; }
bool Mr38Touch(const int side, const double entry, const double px)
{
   if(side > 0) return px <= entry + 1e-12;
   if(side < 0) return px >= entry - 1e-12;
   return false;
}
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

double Mr38Remaining(const double target, const double filled, const double step)
{
   const double s = step > 0.0 ? step : 0.01;
   const double rem = target - filled;
   if(rem <= s * 0.5) return 0.0;
   return NormalizeDouble(MathRound(rem / s) * s, 8);
}
bool Mr38Complete(const double target, const double filled, const double step) { const double s = step > 0.0 ? step : 0.01; return filled >= target - s * 0.5; }
bool Mr38Overfill(const double target, const double filled, const double step)  { const double s = step > 0.0 ? step : 0.01; return filled > target + s * 0.5; }

string Mr38Tag(const ulong deal) { return "R2MR|" + IntegerToString((long)deal) + "|"; }
bool   Mr38TagIs(const string comment, const ulong deal) { return StringFind(comment, Mr38Tag(deal)) == 0; }

#endif

bool Mrr38FinishedCycleClose(const ulong posId, const ulong cycleFirstOrder, const long posOpenMsc, const long cycleStartMsc, const bool knownToBook, const int basketPositions)
{
   if(basketPositions <= 0 || knownToBook) return false;
   if(cycleFirstOrder > 0) return posId > 0 && posId < cycleFirstOrder;
   return posOpenMsc > 0 && cycleStartMsc > 0 && posOpenMsc < cycleStartMsc;
}
int Mrr38TpCycleOwner(const ulong posId, const ulong cycleFirstOrder, const bool knownToBook)
{
   if(posId == 0) return 0;
   if(cycleFirstOrder > 0) return posId < cycleFirstOrder ? -1 : 1;
   return knownToBook ? 1 : 0;
}
bool Mrr38ForeignMagicOwned(const bool manualReason, const bool exitEntry, const bool positionOpenedByEa) { return manualReason && exitEntry && positionOpenedByEa; }
bool Mrr38LateFillOfFinished(const bool orderListedAtFin, const bool unknownRequestAtFin, const long orderSetupMsc, const long finMsc, const ulong posId, const ulong finMaxSeen, const ulong finWm)
{
   if(finMsc <= 0) return false;
   if(orderListedAtFin) return true;
   if(posId > 0 && posId <= finMaxSeen) return false;
   if(finWm > 0 && posId > 0 && posId <= finWm) return true;
   return unknownRequestAtFin && orderSetupMsc > 0 && orderSetupMsc < finMsc;
}
#define MRR_LATE_NONE   0
#define MRR_LATE_CLOSE  1
#define MRR_LATE_MIXED  2
int Mrr38LateAction(const int open, const int late, const int reappeared) { if(reappeared > 0 || late <= 0) return MRR_LATE_NONE; return late >= open ? MRR_LATE_CLOSE : MRR_LATE_MIXED; }
bool Mrr38AbandonClosedLevel(const int level, const bool partialClose, const bool levelStillOpen) { return level > 0 && !partialClose && !levelStillOpen; }

#define R7MIG_NONE     0
#define R7MIG_HISTORY  1
#define R7MIG_BLOCKED  2
int    R7MigrationVerdict(const bool rpaRecord, const bool latchRpaMode, const bool latchOlderBuild, const bool t1OneSideLock, const bool subgridGroupRecord,
                          const int rpaTaggedPositions, const int eaPositions, const int hedgePositions, const int workingOrders)
{
   const bool trace = rpaRecord || latchRpaMode || latchOlderBuild || t1OneSideLock || subgridGroupRecord || rpaTaggedPositions > 0;
   if(!trace) return R7MIG_NONE;
   if(eaPositions > 0 || hedgePositions > 0 || workingOrders > 0) return R7MIG_BLOCKED;
   return R7MIG_HISTORY;
}
string R7MigName(const int v) { return v == R7MIG_NONE ? "NONE" : (v == R7MIG_HISTORY ? "R6_RPA_HISTORY_ONLY" : (v == R7MIG_BLOCKED ? "MIGRATION_BLOCKED" : "?")); }

#define DDR38_RELEASE           0
#define DDR38_WAIT_NOT_FLAT     1
#define DDR38_WAIT_ORDERS       2
#define DDR38_WAIT_INFLIGHT     3
#define DDR38_WAIT_HISTORY      4
#define DDR38_KEEP_STOPOUT      5
#define DDR38_KEEP_NOT_MANUAL   6
#define DDR38_KEEP_NO_EVIDENCE  7
#define DDR38_CLS_MANUAL  1
#define DDR38_CLS_STOPOUT 2
#define DDR38_CLS_OTHER   3
int  Ddr38ClassOf(const long reason)
{
   if(reason == DEAL_REASON_CLIENT || reason == DEAL_REASON_MOBILE || reason == DEAL_REASON_WEB) return DDR38_CLS_MANUAL;
   if(reason == DEAL_REASON_SO) return DDR38_CLS_STOPOUT;
   return DDR38_CLS_OTHER;
}
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
long   g_dpmrDdChecks = 0, g_dpmrDdReleases = 0, g_dpmrDdKept = 0;
int    g_dpmrDdLastVerdict = -1; long g_dpmrDdLastMsc = 0, g_dpmrDdLastEp = 0;
long   g_dpmrPairs = 0, g_dpmrPairPend = 0;

#define L1RSI_PERIOD_MIN 2
bool   L1Rsi38PeriodValid(const int period) { return period >= L1RSI_PERIOD_MIN; }
bool   L1Rsi38ValueValid(const double rsi) { return MathIsValidNumber(rsi) && rsi >= 0.0 && rsi <= 100.0; }
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

#define RSI2_INIT_NORMAL       0
#define RSI2_INIT_REJECT       1
#define RSI2_INIT_PROTECTIVE   2
int    Rsi2InitDecision(const bool periodValid, const bool brokerProven, const int eaPositions, const int hedgePositions, const int workingOrders, const bool pending)
{
   if(periodValid) return RSI2_INIT_NORMAL;
   if(!brokerProven) return RSI2_INIT_PROTECTIVE;
   if(eaPositions > 0 || hedgePositions > 0 || workingOrders > 0 || pending) return RSI2_INIT_PROTECTIVE;
   return RSI2_INIT_REJECT;
}
#define RSI2_ACT_NEW_L1          1
#define RSI2_ACT_GRID_LEVEL      2
#define RSI2_ACT_PAIR_DECISION   3
#define RSI2_ACT_ENTRY_ORDER     5
#define RSI2_ACT_MANUAL_REENTRY  6
#define RSI2_ACT_DD_HEDGE        10
#define RSI2_ACT_T1T2            11
#define RSI2_ACT_EXIT_CLOSE      12
#define RSI2_ACT_FINISH_PENDING  13
#define RSI2_ACT_RECONCILE       14
bool   Rsi2Allowed(const bool protectiveOnly, const int act)
{
   if(!protectiveOnly) return true;
   return act == RSI2_ACT_DD_HEDGE || act == RSI2_ACT_T1T2 || act == RSI2_ACT_EXIT_CLOSE || act == RSI2_ACT_FINISH_PENDING || act == RSI2_ACT_RECONCILE;
}
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
      case RSI2_ACT_ENTRY_ORDER: return "ENTRY_ORDER";          case RSI2_ACT_MANUAL_REENTRY: return "MANUAL_REENTRY";
      case RSI2_ACT_DD_HEDGE: return "DD_HEDGE";              case RSI2_ACT_T1T2: return "T1_T2";                       case RSI2_ACT_EXIT_CLOSE: return "EXIT_CLOSE";
      case RSI2_ACT_FINISH_PENDING: return "FINISH_PENDING";  case RSI2_ACT_RECONCILE: return "RECONCILE";
   }
   return "?";
}
bool   g_rsiProt = false;
int    g_rsiPhase = RSI2_PH_NORMAL;
long   g_rsiBlk[8];
string g_rsiBlkKeys = "";
long   g_rsiPhaseChanges = 0;

#define SU3_RESTORE_EXPOSURE   0
#define SU3_RESTORE_FLAT       1
#define SU3_WAIT_IDENTITY      2
#define SU3_WAIT_CONNECTION    3
#define SU3_WAIT_ACCOUNT_SYNC  4
#define SU3_WAIT_HISTORY_OPEN  5
#define SU3_WAIT_RECORDED      6
#define SU3_WAIT_COVERAGE      7
#define SU3_OWNER_REQUIRED     8
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
int      g_su3Verdict = -1;
string   g_su3LastLog = "";
datetime g_su3LastEval = 0;
long     g_su3Evals = 0, g_su3Waits = 0, g_su3RestExp = 0, g_su3RestFlat = 0, g_su3Owner = 0;

long     g_mrrFinCyc = 0, g_mrrFinMsc = 0;
#define  MRR_LATE_MAX 32
ulong    g_mrrLateOrd[MRR_LATE_MAX]; int g_mrrLateOrdN = 0;
bool     g_mrrLateUnknown = false;
bool     g_mrrSeenPos = false;
ulong    g_mrrMaxSeenId = 0;
ulong    g_mrrFinMaxSeen = 0, g_mrrFinWm = 0;
ulong    g_mrrCycFirstOrd = 0;
bool     g_mrrAwaitL1 = false;
int      g_mrrManualDeals = 0;
bool     g_mrrFullManual = false;
bool     g_mrrLateClosed = false;
string   g_mrrL1Why = "";
int      g_mrrRestLv[]; int g_mrrRestLvN = 0;
long     g_mrrStale = 0, g_mrrForeignMagic = 0, g_mrrLateFills = 0, g_mrrLateMixed = 0, g_mrrAbandoned = 0, g_mrrL1Blocks = 0, g_mrrFinalized = 0, g_mrrFullCloses = 0;

bool     g_ggOn[GG38_MAXG];
double   g_ggAnchorPx[GG38_MAXG];
long     g_ggAnchorMsc[GG38_MAXG];
double   g_ggRunHi[GG38_MAXG], g_ggRunLo[GG38_MAXG];
bool     g_ggFrozen[GG38_MAXG];
bool     g_ggFrzNoHist[GG38_MAXG];
double   g_ggFrzHi[GG38_MAXG], g_ggFrzLo[GG38_MAXG];
long     g_ggFrzMsc[GG38_MAXG];
long     g_ggLastMsc   = 0;
bool     g_ggHistOk    = true;
datetime g_ggHistRetry = 0;
datetime g_ggLastSave  = 0;
string   g_ggBlockKey  = "";
bool     g_ggPersisted = false;
bool     g_ggRebuilt   = false;

bool   GgOn()  { return O12GlobalLatched(); }
int    GgK()   { return O12LatchedK(); }
double GgD()   { return O12LatchedD(); }
int    GgMax() { return Max_Orders; }
double GgLd(const int i) { return ClLdGet(i); }
int    GgLdN()           { return ClLdCount(); }
double GgAnchorPrice(const int g)
{
   if(g == 0) return FirstPrice;
   return (g > 0 && g < GG38_MAXG && g_ggOn[g]) ? g_ggAnchorPx[g] : 0.0;
}
int    GgBaseGroup() { return 0; }
string GgNs()  { return OfhNs("OFH38G", Magic); }

void GgClearGroup(const int g)
{
   g_ggOn[g] = false; g_ggAnchorPx[g] = 0; g_ggAnchorMsc[g] = 0; g_ggRunHi[g] = 0; g_ggRunLo[g] = 0;
   g_ggFrozen[g] = false; g_ggFrzHi[g] = 0; g_ggFrzLo[g] = 0; g_ggFrzMsc[g] = 0;
   g_ggFrzNoHist[g] = false;
}
void GgResetMemory()
{
   for(int g = 0; g < GG38_MAXG; g++) GgClearGroup(g);
   g_ggLastMsc = 0; g_ggHistOk = true; g_ggHistRetry = 0; g_ggBlockKey = "";
}
bool GgAny() { for(int g = 0; g < GG38_MAXG; g++) if(g_ggOn[g]) return true; return false; }

void GgSaveRun()
{
   const string ns = GgNs();
   for(int g = 0; g < GG38_MAXG; g++) if(g_ggOn[g]) { GlobalVariableSet(ns + "g" + IntegerToString(g) + "hi", g_ggRunHi[g]); GlobalVariableSet(ns + "g" + IntegerToString(g) + "lo", g_ggRunLo[g]); }
   GlobalVariableSet(ns + "lastmsc", (double)g_ggLastMsc);
   g_ggLastSave = TimeCurrent();
}
void GgSaveAll()
{
   const string ns = GgNs();
   GlobalVariablesDeleteAll(ns);
   g_ggPersisted = GgAny();
   if(!g_ggPersisted) { GlobalVariablesFlush(); return; }
   GlobalVariableSet(ns + "basket", (double)GgBasketKey());
   GlobalVariableSet(ns + "k", GgK()); GlobalVariableSet(ns + "max", GgMax());
   GlobalVariableSet(ns + "off", 0); GlobalVariableSet(ns + "rb", 0);
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
bool GgHistRange(const long fromMsc, const long toMsc, double &hi, double &lo) { return GgHistRange3(fromMsc, toMsc, hi, lo) == 1; }
long GgNowMsc() { MqlTick tk; if(SymbolInfoTick(_Symbol, tk) && tk.time_msc > 0) return tk.time_msc; return (long)TimeCurrent() * 1000; }

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

bool GgLevelPos(const int level, double &px, long &msc)
{
   if(LbOn()) return LbPosOfLevel(level, px, msc);
   long ms[]; double pp[]; const int n = GgPositionsByTime(ms, pp);
   const int r = level;
   if(r < 1 || n < r) return false;
   px = pp[r - 1]; msc = ms[r - 1];
   return true;
}

bool GgRebuildGroup(const int g, const int levels)
{
   const int k = GgK(), a = Gg38AnchorOf(g, k), e = Gg38EndOf(g, k, GgMax());
   if(levels < a) return false;
   double aPx = 0.0, ePx = 0.0; long aMsc = 0, eMsc = 0;
   if(!GgLevelPos(a, aPx, aMsc) || (levels >= e && !GgLevelPos(e, ePx, eMsc)))
   {
      if(LbOn()) MrFreezeGrid(MRF_GLOBAL_UNPROVEN, StringFormat("GLOBAL group %d (L%d-L%d) must be rebuilt but the original position of L%d is not open (closed by hand / re-entry ticket only)", g, a, e, GgLevelPos(a, aPx, aMsc) ? e : a));
      return false;
   }
   GgClearGroup(g);
   g_ggOn[g] = true;
   g_ggAnchorPx[g] = (g == 0 && FirstPrice > 0.0) ? FirstPrice : aPx;
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

int GgLevelCount(const int total) { return LbNextLevel(total) - 1; }
void GgRetryHistory()
{
   if(g_ggHistOk || TimeCurrent() < g_ggHistRetry) return;
   g_ggHistRetry = TimeCurrent() + 60;
   const int n = GgLevelCount(CountPositions());
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
   if(ok) { g_ggHistOk = true; Print("GG HISTORY OK | group ranges completed from tick history (journal only since NPD R1: the breakout anchor reads the open positions)"); GgSaveAll(); }
}

void GgObserve()
{
   if(!GgOn() || !GgAny()) return;
   MqlTick tk;
   if(!SymbolInfoTick(_Symbol, tk)) return;
   for(int g = 0; g < GG38_MAXG; g++)
   {
      if(!g_ggOn[g]) continue;
      if(tk.ask > g_ggRunHi[g]) g_ggRunHi[g] = tk.ask;
      if(tk.bid > 0.0 && (g_ggRunLo[g] <= 0.0 || tk.bid < g_ggRunLo[g])) g_ggRunLo[g] = tk.bid;
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
   g_ggFrzNoHist[g] = !g_ggHistOk;
   const int k = GgK();
   PrintFormat("GG FROZEN group %d L%d-L%d | observed range (journal only, not used by the breakout since NPD R1) GroupHigh(max Ask)=%.2f GroupLow(min Bid)=%.2f since anchor %.2f @%I64d | next anchor: nearest open position of group %d on its side +/- D=%s (BUY: highest open BUY + D, SELL: lowest open SELL - D, on the price grid) | %s",
               g, Gg38AnchorOf(g, k), Gg38EndOf(g, k, GgMax()), g_ggFrzHi[g], g_ggFrzLo[g], g_ggAnchorPx[g], g_ggAnchorMsc[g], g, Gg38Num(GgD()), why);
}

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
                  level, Gg38EndOf(g, k, GgMax()), Gg38GroupSize(g, k, GgMax()), Gg38GroupSize(g, k, GgMax()) - 1);
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

void GgSync(const int total)
{
   if(!GgOn()) return;
   if(total <= 0) { if(GgAny()) { GgResetMemory(); GgClearPersist(); } return; }
   const int k = GgK(), ng = Gg38GroupCount(k, GgMax()), g0 = GgBaseGroup();
   bool changed = false;
   for(int g = g0; g < ng; g++)
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

double g_ggNpdRef = 0.0; int g_ggNpdLevel = 0; bool g_ggNpdBuy = false; string g_ggNpdTxt = "";
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
int GgNpdReference(const int g, const bool isBuy, double &ref, string &txt)
{
   ref = 0.0; txt = "";
   int lv[], sd[], ex[]; double px[]; ulong id[]; string why = "";
   const int k = GgK(), levels = GgMax();
   const int a = Gg38AnchorOf(g - 1, k), e = Gg38EndOf(g - 1, k, levels);
   const string src = LbOn() ? "level book" : "V26 rank by open time";
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
      double ref = 0.0; string rtx = "";
      const int st = GgNpdReference(g, isBuy, ref, rtx);
      if(st != GG38_NPD_OK)
      {
         GgBlockLog(StringFormat("NPD%d_%d_%d", nextNum, p, st), StringFormat("GG BLOCK L%d | NPD %s: %s -> the breakout anchor of group %d is NOT sent (no fallback to the last order, the anchor or GroupHigh / GroupLow); exits / T1 / T2 / PairClose / DD keep working",
                                                                       nextNum, Gg38NpdName(st), rtx, g));
         return false;
      }
      trigger = PriceN(Gg38NpdTriggerPx(isBuy, ref, GgD(), _Point));
      g_ggNpdLevel = nextNum; g_ggNpdRef = ref; g_ggNpdBuy = isBuy; g_ggNpdTxt = rtx;
      tag = StringFormat(" [GG ANCHOR group %d: %s %s NPD ref %.2f %s D %s -> %.2f | %s]", g, isBuy ? "ask" : "bid", isBuy ? ">=" : "<=", ref, isBuy ? "+" : "-", Gg38Num(GgD()), trigger, rtx);
      g_ggBlockKey = "";
      return true;
   }
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
   if(ok && (int)GlobalVariableGet(ns + "off") != 0) { ok = false; why = "SUBGRID_EPOCH_RECORD"; }
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
      g_ggLastMsc = (long)GlobalVariableGet(ns + "lastmsc");
      const long now = GgNowMsc();
      double hi, lo;
      if(g_ggLastMsc > 0 && now > g_ggLastMsc)
      {
         const int r = GgHistRange3(g_ggLastMsc + 1, now, hi, lo);
         if(r == 1)
         {
            for(int g = 0; g < GG38_MAXG; g++) if(g_ggOn[g]) { g_ggRunHi[g] = MathMax(g_ggRunHi[g], hi); g_ggRunLo[g] = MathMin(g_ggRunLo[g], lo); }
         }
         else if(r < 0)
         {
            g_ggHistOk = false;
         }
      }
      PrintFormat("GG RESTORED | basket %I64u k=%d | gap %I64d ms filled from tick history: %s", GgBasketKey(), GgK(), now - g_ggLastMsc, g_ggHistOk ? "yes" : "PENDING");
   }
   else { g_ggRebuilt = true; PrintFormat("GG RESTORE | no valid record (%s) -> groups rebuilt from %s + tick history", why, "open positions"); }
   GgSync(GgLevelCount(total));
   GgSaveAll();
}
ulong GgBasketKey() { return SessBasketId(); }

#endif
#ifndef OFH38_DDLOCK_MQH
#define OFH38_DDLOCK_MQH

#ifndef OFH38_DDLOCK_CORE_MQH
#define OFH38_DDLOCK_CORE_MQH

enum DDL_STATE
{
   DDL_NORMAL = 0,
   DDL_LOCK_PENDING = 1,
   DDL_LOCK_CONFIRMED = 2,
   DDL_LOCK_FAILED = 3,
   DDL_COMPRESSION_PENDING = 4,
   DDL_COMPRESSION_ACTIVE = 5,
   DDL_COMPRESSION_COMPLETE = 6,
   DDL_LOCKED_HOLD = 7,
   DDL_HALT = 12
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

double RcFloorStep(const double v, const double step) { const double s = step > 0.0 ? step : 0.01; return NormalizeDouble(MathFloor((v + 1e-9) / s) * s, 8); }
double RcRoundStep(const double v, const double step) { const double s = step > 0.0 ? step : 0.01; return NormalizeDouble(MathRound(v / s) * s, 8); }

struct RcLockPlan
{
   bool   neutral;
   int    dir;
   double net;
   double total;
   double chunk;
   string reason;
};

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
   double vol;
   double buy_vol, sell_vol;
   double realized;
   string reason;
};

bool RcRemainderOk(const double v_pos, const double v_close, const double vmin)
{
   const double r = NormalizeDouble(v_pos - v_close, 8);
   return (r < 1e-9) || (r >= vmin - 1e-9);
}

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

CTradeV38 ddlTrade;
int      g_ddlState = DDL_NORMAL;
long     g_ddlEpisode = 0;
datetime g_ddlTrigTime = 0;
double   g_ddlB0 = 0, g_ddlE0 = 0, g_ddlFloat0 = 0, g_ddlDD0 = 0, g_ddlThr0 = 0, g_ddlVB0 = 0, g_ddlVS0 = 0, g_ddlMargin0 = 0;
int      g_ddlN0 = 0;
double   g_ddlFirstPx0 = 0;
int      g_ddlFirstType0 = -1;
double   g_ddlRef = 0, g_ddlRealBefore = 0, g_ddlDebt0 = 0;
datetime g_ddlBasketStart = 0;
bool     g_ddlHedgeSent = false, g_ddlAdopted = false;
int      g_ddlLockFails = 0, g_ddlLockFailEvents = 0;
datetime g_ddlNextTry = 0, g_ddlLastSend = 0, g_ddlLockFailedAt = 0, g_ddlLockTime = 0;
uint     g_ddlLastRc = 0;
double   g_ddlHedgeLots = 0, g_ddlNetBefore = 0, g_ddlNetAfter = 0, g_ddlGrossLock = 0;
double   g_ddlRealizedComp = 0;
int      g_ddlPairsDone = 0;
ulong    g_ddlPB = 0, g_ddlPS = 0;
double   g_ddlPV = 0, g_ddlPBBefore = 0, g_ddlPSBefore = 0, g_ddlPairPlanPL = 0, g_ddlPairBal0 = 0;
int      g_ddlPairFails = 0;
ulong    g_ddlInflightOrder = 0;
long     g_ddlInflightMs = 0;
double   g_ddlEqMin = 0, g_ddlMlMin = 0;
long     g_ddlAckEpisode = 0;
bool     g_ddlRowDone = false;
string   g_ddlOnce = "";

bool DdlActive() { return g_ddlState != DDL_NORMAL; }
void DdlLogOnce(const string key, const string text) { if(StringFind(g_ddlOnce, "|" + key + "|") >= 0) return; g_ddlOnce += "|" + key + "|"; Print(text); }
bool DdlMagic(const ulong mg) { return mg == Magic || mg == DDLock_HedgeMagic; }

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
   DdlSet("ifo", (double)g_ddlInflightOrder); DdlSet("ifm", (double)g_ddlInflightTickMsc); DdlSet("ifw", (double)g_ddlInflightWm);
   DdlSet("lpt", (double)g_ddlLegTk); DdlSet("lpm", (double)g_ddlLegMsc); DdlSet("lpv", g_ddlLegVol0);
   static int s_state = -1; if(s_state != g_ddlState) { GlobalVariablesFlush(); s_state = g_ddlState; }
}
void DdlClearPersist() { if(GlobalVariablesDeleteAll(DdlNs()) > 0) GlobalVariablesFlush(); }

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
bool DdlHedgeInflight()
{
   if(g_ddlInflightOrder == 0 && g_ddlInflightTickMsc <= 0) return false;
   if(g_ddlInflightOrder != 0)
      for(int i = PositionsTotal() - 1; i >= 0; i--)
      {
         const ulong t = PositionGetTicket(i);
         if(t == 0 || !PositionSelectByTicket(t) || PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
         if((ulong)PositionGetInteger(POSITION_IDENTIFIER) == g_ddlInflightOrder) { g_ddlInflightOrder = 0; g_ddlInflightTickMsc = 0; g_ddlInflightWm = 0; DdlPersist(); return false; }
      }
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
   g_ddlInflightOrder = 0; g_ddlInflightMs = 0; g_ddlInflightTickMsc = 0; g_ddlInflightWm = 0; g_ddlLegTk = 0; g_ddlLegMsc = 0; g_ddlLegVol0 = 0.0;
   g_ddlNetBefore = (v.vb_o + v.vb_r) - (v.vs_o + v.vs_r);
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
   MrOnDdActivate();
   return true;
}

bool DdlSendHedge(const int dir, const double vol)
{
   const bool isBuy = dir > 0;
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
   g_ddlInflightOrder = 0; g_ddlInflightTickMsc = Ex38TickMsc(); g_ddlInflightWm = SafEntryWatermark(DDLock_HedgeMagic); DdlPersist(); GlobalVariablesFlush();
   const long s0 = ddlTrade.m_sends;
   const bool sent = isBuy ? ddlTrade.Buy(tryVol, _Symbol, 0, 0, 0, "OFH38|DDLOCK") : ddlTrade.Sell(tryVol, _Symbol, 0, 0, 0, "OFH38|DDLOCK");
   const uint rc = (ddlTrade.m_sends > s0) ? ddlTrade.ResultRetcode() : 0;
   g_ddlLastRc = rc; g_ddlLastSend = TimeCurrent();
   if(Saf38OpenRcClass(ddlTrade.m_sends > s0, rc) == SAF_OR_UNKNOWN)
   {
      g_ddlHedgeSent = true; g_ddlInflightOrder = ddlTrade.ResultOrder(); g_ddlInflightMs = Ex38NowMs();
      PrintFormat("DDL HEDGE OUTCOME UNKNOWN | %s %.2f rc=%u (timeout) | no new hedge for %d ms - the broker positions decide", isBuy ? "BUY" : "SELL", tryVol, rc, Exec_ConfirmMs);
      DdlPersist();
      return true;
   }
   if(sent && (rc == TRADE_RETCODE_DONE || rc == TRADE_RETCODE_DONE_PARTIAL || rc == TRADE_RETCODE_PLACED))
   {
      g_ddlHedgeSent = true;
      g_ddlInflightOrder = ddlTrade.ResultOrder(); g_ddlInflightMs = Ex38NowMs();
      DdlInv v; DdlInventory(v);
      PrintFormat("DDL HEDGE SENT | %s %.2f of %.2f @%.2f rc=%u filled=%.2f | reconcile: basket B=%.2f S=%.2f hedge B=%.2f S=%.2f -> net %+.2f",
                  isBuy ? "BUY" : "SELL", tryVol, vol, ddlTrade.ResultPrice(), rc, ddlTrade.ResultVolume(), v.vb_o, v.vs_o, v.vb_r, v.vs_r, (v.vb_o + v.vb_r) - (v.vs_o + v.vs_r));
      DdlPersist();
      return true;
   }
   g_ddlLockFails++; g_ddlNextTry = TimeCurrent() + 5 * g_ddlLockFails;
   g_ddlInflightOrder = 0; g_ddlInflightTickMsc = 0; g_ddlInflightWm = 0;
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
   if(!Ex38TradeSessionOpen())
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
   if(DdlPendingHedgeOrders()) return;
   if(DdlHedgeInflight()) return;
   if(Ex38NowMs() < g_exGraceUntil) return;
   if(g_ddlLastSend > 0 && TimeCurrent() - g_ddlLastSend < ConfirmWait && g_ddlLastRc == TRADE_RETCODE_PLACED) return;
   PrintFormat("DDL LOCK PLAN | BUY=%.2f SELL=%.2f net=%+.2f -> hedge %s %.2f (this order %.2f; step %.2f min %.2f max %.2f)", v.vb_o + v.vb_r, v.vs_o + v.vs_r, p.net,
               p.dir > 0 ? "BUY" : "SELL", p.total, p.chunk, DdlStep(), DdlVMin(), DdlVMax());
   DdlSendHedge(p.dir, p.chunk);
}

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

int DdlCloseVolume(const ulong ticket, const double vol, const string why)
{
   if(!PositionSelectByTicket(ticket)) return -1;
   const ulong mg = (ulong)PositionGetInteger(POSITION_MAGIC);
   if(PositionGetString(POSITION_SYMBOL) != _Symbol || !DdlMagic(mg)) return -1;
   const double before = PositionGetDouble(POSITION_VOLUME);
   CTradeV38 *t = (mg == Magic) ? GetPointer(trade) : GetPointer(ddlTrade);
   const ulong dev0 = t.DeviationPoints();
   t.SetDeviationInPoints(DDLock_DeviationPoints);
   const long s0 = t.m_sends;
   const bool sent = (vol >= before - DdlStep() * 0.5) ? t.PositionClose(ticket) : t.PositionClosePartial(ticket, vol);
   t.SetDeviationInPoints(dev0);
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
   if(!Ex38TradeSessionOpen())
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

bool g_ddlCloseByOff = false;
bool DdlCloseByAllowed() { return (SymbolInfoInteger(_Symbol, SYMBOL_ORDER_MODE) & SYMBOL_ORDER_CLOSEBY) == SYMBOL_ORDER_CLOSEBY; }
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

void DdlPairStep()
{
   const double tol = DdlStep() * 0.5;
   const double vbNow = PositionSelectByTicket(g_ddlPB) ? PositionGetDouble(POSITION_VOLUME) : 0.0;
   const double vsNow = PositionSelectByTicket(g_ddlPS) ? PositionGetDouble(POSITION_VOLUME) : 0.0;
   const double bLeft = NormalizeDouble(g_ddlPV - (g_ddlPBBefore - vbNow), 8);
   const double sLeft = NormalizeDouble(g_ddlPV - (g_ddlPSBefore - vsNow), 8);
   const bool bDone = bLeft <= tol, sDone = sLeft <= tol;
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
   if(!(bDone && sDone) && !Ex38TradeSessionOpen())
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
         if(cb > 0) { DdlPersist(); return; }
         if(cb == 0) { g_ddlNextTry = TimeCurrent() + MathMax(1, Exec_ConfirmMs / 1000); g_ddlLegTk = g_ddlPB; g_ddlLegMsc = Ex38TickMsc(); g_ddlLegVol0 = vbNow; DdlPersist(); return; }
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
   if(Ex38NowMs() < g_exGraceUntil) return;
   if(g_ddlPairFails >= DDLock_MaxAttempts)
   {
      g_ddlPB = 0; g_ddlPS = 0; g_ddlPV = 0; g_ddlPairFails = 0; g_ddlLockFails = 0;
      DdlSetState(DDL_LOCK_PENDING, StringFormat("PAIR_LEG_UNRESOLVED buyLeft=%.2f sellLeft=%.2f -> RELOCK", bLeft, sLeft));
      return;
   }
   int r;
   if(!bDone) r = (vbNow > 0.0) ? DdlCloseVolume(g_ddlPB, MathMin(bLeft, vbNow), "PAIR_BUY") : -1;
   else       r = (vsNow > 0.0) ? DdlCloseVolume(g_ddlPS, MathMin(sLeft, vsNow), "PAIR_SELL") : -1;
   if(r == 0)
   {
      g_ddlNextTry = TimeCurrent() + MathMax(1, Exec_ConfirmMs / 1000);
      g_ddlLegTk = !bDone ? g_ddlPB : g_ddlPS; g_ddlLegMsc = Ex38TickMsc(); g_ddlLegVol0 = !bDone ? vbNow : vsNow;
   }
   if(r < 0)
   {
      g_ddlPairFails++; g_ddlNextTry = TimeCurrent() + 5 * g_ddlPairFails;
      if((!bDone && vbNow <= 0.0) || (bDone && vsNow <= 0.0)) g_ddlPairFails = DDLock_MaxAttempts;
      PrintFormat("DDL PAIR LEG NOT COMPLETED | buyLeft=%.2f sellLeft=%.2f fails=%d/%d", bLeft, sLeft, g_ddlPairFails, DDLock_MaxAttempts);
   }
   DdlPersist();
}

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
         if(!DdlOriginalStopsClear())
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
            DdlSetState(DDL_HALT, StringFormat("basket flat, episode debt %.2f - no new cycle unless the flat basket is a verified Owner full manual close (DPMR R1 D04: basket + hedge closed by hand, no stop-out / EA / SL / TP close); otherwise OWNER_DECISION_REQUIRED", DdlDebt()));
            ResetCycleState();
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
         if(DpmrDdHaltReleaseCheck()) return;
         DdlLogOnce("HALT_" + TimeToString(TimeCurrent(), TIME_DATE), StringFormat("DDL HALT | episode %I64d debt %.2f unrecovered | flat | no new L1 / Grid: the only release is a verified Owner full manual close (DPMR R1 D04, last verdict %s); DDLock_OwnerAckResume = internal constant %s, not an input - OWNER_DECISION_REQUIRED (DD release policy)",
                    g_ddlEpisode, DdlDebt(), g_dpmrDdLastVerdict < 0 ? "not evaluated yet" : Ddr38Name(g_dpmrDdLastVerdict), DDLock_OwnerAckResume ? "true" : "false"));
         return;
   }
}

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

void DdlRestore()
{
   g_ddlState = DDL_NORMAL;
   g_ddlInflightOrder = 0; g_ddlInflightMs = 0;
   g_ddlInflightTickMsc = 0; g_ddlInflightWm = 0; g_ddlLegTk = 0; g_ddlLegMsc = 0; g_ddlLegVol0 = 0.0;
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
      g_ddlInflightOrder = (ulong)DdlGet("ifo"); g_ddlInflightTickMsc = (long)DdlGet("ifm"); g_ddlInflightWm = (ulong)DdlGet("ifw"); g_ddlInflightMs = Ex38NowMs();
      g_ddlLegTk = (ulong)DdlGet("lpt"); g_ddlLegMsc = (long)DdlGet("lpm"); g_ddlLegVol0 = DdlGet("lpv");
      if(g_ddlFirstPx0 > 0.0 && FirstPrice <= 0.0) { FirstPrice = g_ddlFirstPx0; FirstType = g_ddlFirstType0; }
      if(g_ddlState == DDL_HALT && DDLock_OwnerAckResume) g_ddlAckEpisode = g_ddlEpisode;
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
#ifndef OFH38_CYCLESTATE_MQH
#define OFH38_CYCLESTATE_MQH

long     g_cycStartMsc   = 0;
ulong    g_pairPend1     = 0, g_pairPend2 = 0;
bool     g_cycIndexShift = false;
long     g_pairPendSinceMsc = 0;
bool     g_cycRestoredOk = false;

struct CycSnap
{
   double   firstPrice; int firstType; bool latched;
   ulong    lastSentOrder; long lastSentTime; int lastSentCount;
   bool     waitNext; long waitUntil;
   int      dblNum; bool dblHit1; bool dblReady;
   bool     trailActive; double bePx; double exitPx; double clusterBe; double t1Trig; double lockMoney; int trailDir;
   bool     t1; int t1d; bool t2;
   long     startMsc; ulong pp1; ulong pp2; bool shift; long ppSince;
   int      n;
};
CycSnap g_cycLast;
bool    g_cycHave = false;
int     g_cycTkN  = -1;

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
   s.t1 = t1Locked; s.t1d = t1Dir; s.t2 = t2Armed;
   s.n = CountPositions();
   s.startMsc = (s.n > 0) ? CycStartMsc() : 0; s.pp1 = g_pairPend1; s.pp2 = g_pairPend2; s.shift = g_cycIndexShift; s.ppSince = g_pairPendSinceMsc;
}
bool CycStageDiff(const CycSnap &a, const CycSnap &b)
{
   return a.t1 != b.t1 || a.t2 != b.t2 || a.trailActive != b.trailActive || a.dblNum != b.dblNum || a.dblHit1 != b.dblHit1 || a.dblReady != b.dblReady ||
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
   if(DdlActive()) return;
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
   GlobalVariableSet(ns + "st", (double)s.startMsc); GlobalVariableSet(ns + "pp1", (double)s.pp1); GlobalVariableSet(ns + "pp2", (double)s.pp2); GlobalVariableSet(ns + "sh", s.shift ? 1 : 0);
   GlobalVariableSet(ns + "pps", (double)s.ppSince);
   if(s.n != g_cycTkN)
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
   g_cycStartMsc = (long)GlobalVariableGet(ns + "st"); g_pairPend1 = (ulong)GlobalVariableGet(ns + "pp1"); g_pairPend2 = (ulong)GlobalVariableGet(ns + "pp2");
   g_cycIndexShift = GlobalVariableGet(ns + "sh") > 0.5; g_pairPendSinceMsc = (long)GlobalVariableGet(ns + "pps");
   if(g_pairPend1 != 0 && !OfhTicketIsOurs(g_pairPend1, Magic)) g_pairPend1 = 0;
   if(g_pairPend2 != 0 && !OfhTicketIsOurs(g_pairPend2, Magic)) g_pairPend2 = 0;
   if(g_pairPend1 == 0 && g_pairPend2 == 0) g_pairPendSinceMsc = 0;
   if(nNow <= 0) { FirstPrice = 0; FirstType = -1; basketModeLatched = false; t1Locked = false; t2Armed = false; hedgeTrailActive = false; g_cycStartMsc = 0; }
   OrderCount = nNow;
   g_cycRestoredOk = (nNow > 0);
   if(g_pairPend1 != 0 || g_pairPend2 != 0) Ex38RestartGrace("PairClose leg pending");
   PrintFormat("V26 CYCLE STATE RESTORED | positions %d (recorded %d, %d recorded tickets open) | FirstPrice %.2f type %d latched %d | T1 %d dir %d T2 %d exit %.5f floor %.5f | DblConfirm L%d hit1 %d ready %d | pending pair %I64u/%I64u since %I64d | partial-close shift %d | wait next session %d",
               nNow, nRec, still, FirstPrice, FirstType, basketModeLatched ? 1 : 0, t1Locked ? 1 : 0, t1Dir, t2Armed ? 1 : 0, hedgeExitPrice, hedgeBePrice,
               DblConfirmNum, DblConfirmHit1 ? 1 : 0, DblConfirmReady ? 1 : 0, g_pairPend1, g_pairPend2, g_pairPendSinceMsc, g_cycIndexShift ? 1 : 0, WaitNextSession ? 1 : 0);
   CycTake(g_cycLast); g_cycHave = true;
}
void CycDblConfirmCheck()
{
   if(DblConfirmNum == 0) return;
   const int want = LbNextLevel(CountPositions());
   if(DblConfirmNum == want) return;
   PrintFormat("V26 CYCLE STATE | double confirmation of L%d dropped at restart: the next grid level is L%d", DblConfirmNum, want);
   DblConfirmNum = 0; DblConfirmHit1 = false; DblConfirmReady = false;
}

#endif
#ifndef OFH38_LEVELBOOK_MQH
#define OFH38_LEVELBOOK_MQH

#ifndef OFH38_LEVELBOOK_CORE_MQH
#define OFH38_LEVELBOOK_CORE_MQH

#define LB38_MAX   64
#define LB38_GRAVE 16

bool Lb38In(const int &a[], const int n, const int v) { for(int i = 0; i < n; i++) if(a[i] == v) return true; return false; }

int Lb38Next(const int &openLv[], const int nOpen, const int &resLv[], const int nRes, const int &abLv[], const int nAb)
{
   int top = 0;
   for(int i = 0; i < nOpen; i++) if(openLv[i] > top) top = openLv[i];
   for(int i = 0; i < nRes; i++)  if(resLv[i] > top) top = resLv[i];
   int L = top + 1;
   for(int guard = 0; guard <= LB38_MAX && Lb38In(abLv, nAb, L); guard++) L++;
   return L;
}

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

#define LBK_GRID     0
#define LBK_RECOVERY 1
#define LBK_UNKNOWN  2

ulong  g_lbId[]; int g_lbLv[]; int g_lbKind[]; int g_lbN = 0;
bool   g_lbOn = false;
long   g_lbCycle = 0;
int    g_lbAb[]; int g_lbAbN = 0;
ulong  g_lbGyId[LB38_GRAVE]; int g_lbGyLv[LB38_GRAVE]; int g_lbGyN = 0, g_lbGyNext = 0;
ulong  g_lbPendOrd = 0; int g_lbPendLv = 0;
int    g_lbSigN = -1; double g_lbSigSum = -1.0; ulong g_lbSigXor = 0;
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
   GlobalVariableSet(ns + "gn", g_lbGyN); GlobalVariableSet(ns + "gx", g_lbGyNext);
   for(int i = 0; i < g_lbGyN; i++) { GlobalVariableSet(ns + "gi" + IntegerToString(i), (double)g_lbGyId[i]); GlobalVariableSet(ns + "gl" + IntegerToString(i), g_lbGyLv[i]); }
   OfhIdStore(ns, Magic);
   GlobalVariableSet(ns + "on", 1);
   GlobalVariablesFlush();
}

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
int LbLevelOfPos(const ulong id)
{
   const int i = LbFind(id); if(i >= 0) return g_lbKind[i] == LBK_UNKNOWN ? 0 : g_lbLv[i];
   for(int k = 0; k < g_lbGyN; k++) if(g_lbGyId[k] == id) return g_lbGyLv[k];
   return 0;
}
bool LbIsAbandoned(const int lv) { return Lb38In(g_lbAb, g_lbAbN, lv); }
bool LbHasOriginal(const int lv) { for(int i = 0; i < g_lbN; i++) if(g_lbLv[i] == lv && g_lbKind[i] == LBK_GRID) return true; return false; }
void LbAbandonLevel(const int lv, const string why)
{
   if(lv <= 0 || LbIsAbandoned(lv)) return;
   ArrayResize(g_lbAb, g_lbAbN + 1); g_lbAb[g_lbAbN++] = lv; g_lbAbandoned++;
   PrintFormat("LEVEL BOOK | level L%d ABANDONED (%s): never re-opened by the grid in this cycle | %s", lv, why, LbText());
   LbPersist();
}
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
      int lv = 0, kind = LBK_UNKNOWN; string src = "";
      if(g_lbPendOrd != 0 && id[k] == g_lbPendOrd && g_lbPendLv > 0) { lv = g_lbPendLv; kind = LBK_GRID; src = "grid order"; g_lbPendOrd = 0; g_lbPendLv = 0; g_lbGridAssigned++; }
      else if(StringFind(cm[k], "R2MR|") == 0) { lv = MrLevelOfTag((ulong)StringToInteger(StringSubstr(cm[k], 5))); if(lv > 0) { kind = LBK_RECOVERY; src = "re-entry tag"; g_lbRecAssigned++; } }
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

void LbActivate(const string why)
{
   if(g_lbOn) return;
   g_lbOn = true; g_lbCycle = MrCycleId(); g_lbActivations++;
   PrintFormat("LEVEL BOOK ON | %s | from now on the grid level of this basket comes from the book, not from the ticket count | %s", why, LbText());
   LbPersist();
}

void LbOnGridSend(const ulong order, const int lv)
{
   g_lbPendOrd = order; g_lbPendLv = lv;
   if(g_lbOn) LbSync();
}

int LbReserved(int &res[]) { return MrReservedLevels(res); }

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

void LbOnCycleReset()
{
   const bool flat = (CountPositions() <= 0);
   g_lbOn = false; g_lbCycle = 0; g_lbN = 0; ArrayResize(g_lbId, 0); ArrayResize(g_lbLv, 0); ArrayResize(g_lbKind, 0);
   g_lbAbN = 0; ArrayResize(g_lbAb, 0); g_lbGyN = 0; g_lbGyNext = 0; g_lbPendOrd = 0; g_lbPendLv = 0;
   g_lbSigN = -1; g_lbSigSum = -1.0; g_lbSigXor = 0;
   if(flat && GlobalVariablesDeleteAll(LbNs()) > 0) GlobalVariablesFlush();
}

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
      LbSync();
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
   g_lbSyncDeferred = true;
}

void LbPrintCounters(const string when)
{
   PrintFormat("LEVEL BOOK COUNTERS %s | on %d | activations %I64d | grid fills assigned %I64d | re-entry fills assigned %I64d | positions left %I64d | levels abandoned %I64d | unproven positions %I64d | grid decisions off the ticket count %I64d | %s",
               when, g_lbOn ? 1 : 0, g_lbActivations, g_lbGridAssigned, g_lbRecAssigned, g_lbRemoved, g_lbAbandoned, g_lbUnknownSeen, g_lbDiverged, LbText());
}

#endif
#ifndef OFH38_MANUALRECOVERY_MQH
#define OFH38_MANUALRECOVERY_MQH

#define MR38_MAX   64
#define MR38_RCPT  64
#define MR38_ORD    8
#define MR38_NOREC  8
#define MR38_ORIG  32

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
   ulong  deal;
   ulong  posId;
   long   cycle;
   int    type;
   double entry;
   double target;
   double filled;
   int    level;
   bool   partial;
   long   detectMsc;
   long   closeMsc;
   int    st;
   int    side;
   int    attempts;
   long   nextMs;
   long   deadlineMs;
   double fillAtReq;
   long   reqMsc;
   uint   lastRc;
   int    nOrd;
   ulong  ord[MR38_ORD];
   ulong  fillPos;
   int    nDeals;
   int    why;
   ulong  lastOrd;
   long   lastReqMsc;
   long   holdLogMs;
   bool   holdCounted;
};
Mr38Rec  g_mr[];
ulong    g_mrRcpt[MR38_RCPT]; long g_mrRcptMsc[MR38_RCPT]; double g_mrRcptTgt[MR38_RCPT];
double   g_mrRcptSur[MR38_RCPT];
int      g_mrRcptLv[MR38_RCPT];
int      g_mrRcptN = 0, g_mrRcptNext = 0;
long     g_mrFloorMsc = 0;
long     g_mrMetaCycle = 0;
bool     g_mrGridFreeze = false; int g_mrFreezeWhy = 0;
ulong    g_mrNoRec[MR38_NOREC]; int g_mrNoRecN = 0;
ulong    g_mrOrigPos[MR38_ORIG]; int g_mrOrigLv[MR38_ORIG]; int g_mrOrigN = 0;
bool     g_mrMulti = false;
int      g_mrLastCount = -1;
datetime g_mrLastScan = 0;
string   g_mrOnce = "";
ulong    g_mrSpKey = 0, g_mrSpPos = 0, g_mrSpOrd = 0; double g_mrSpVol = 0.0; long g_mrSpMsc = 0; uint g_mrSpRc = 0; int g_mrSpAttempts = 0;
long     g_mrSpNextMs = 0, g_mrSpWarnMs = 0; bool g_mrSpFull = false;
bool     g_mrSurOutstanding = false;
long     g_mrCreated = 0, g_mrRemovedFilled = 0, g_mrCancelled = 0, g_mrPartialFills = 0, g_mrReqs = 0, g_mrReqNotExec = 0, g_mrOverfills = 0,
         g_mrSuspends = 0, g_mrMaxActive = 0, g_mrScanFound = 0, g_mrIgnored = 0, g_mrOrphanCloses = 0, g_mrRestoredN = 0;
long     g_mrMerged = 0, g_mrSkipMulti = 0, g_mrSkipT1 = 0, g_mrMultiOn = 0, g_mrOrigSeen = 0, g_mrReceiptOnly = 0, g_mrRecOnlyResolved = 0,
         g_mrUnknownHolds = 0, g_mrSurDetected = 0, g_mrSurReqs = 0, g_mrSurUnknown = 0, g_mrSameOrigAgain = 0;
double   g_mrSurClosedConf = 0.0;

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
bool   MrSurplusInFlight()    { return g_mrSpKey != 0; }
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

int MrOrigFind(const ulong p, const int lv) { for(int j = 0; j < g_mrOrigN; j++) if(g_mrOrigPos[j] == p || (lv > 0 && g_mrOrigLv[j] == lv)) return j; return -1; }
void MrOrigAdd(const ulong p, const int lv)
{
   if(p == 0 || MrOrigFind(p, lv) >= 0) return;
   if(g_mrOrigN < MR38_ORIG) { g_mrOrigPos[g_mrOrigN] = p; g_mrOrigLv[g_mrOrigN] = lv; g_mrOrigN++; g_mrOrigSeen++; }
   else { g_mrMulti = true; MrFreezeGrid(MRF_RECORD_CAP, StringFormat("%d original positions closed by hand in this basket", g_mrOrigN)); }
}
string MrOrigText() { string s = ""; for(int j = 0; j < g_mrOrigN; j++) s += StringFormat("%s%I64u(L%d)", j > 0 ? "," : "", g_mrOrigPos[j], g_mrOrigLv[j]); return s == "" ? "-" : s; }
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
   GlobalVariableSet(k + "s", g_mr[i].st);
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
   GlobalVariableSet(ns + "xn", g_mrOrigN); GlobalVariableSet(ns + "xm", g_mrMulti ? 1 : 0);
   for(int j = 0; j < g_mrOrigN; j++) { GlobalVariableSet(ns + "xp" + IntegerToString(j), (double)g_mrOrigPos[j]); GlobalVariableSet(ns + "xl" + IntegerToString(j), g_mrOrigLv[j]); }
   GlobalVariableSet(ns + "sk", (double)g_mrSpKey); GlobalVariableSet(ns + "sp", (double)g_mrSpPos); GlobalVariableSet(ns + "so", (double)g_mrSpOrd);
   GlobalVariableSet(ns + "sv", g_mrSpVol); GlobalVariableSet(ns + "sm", (double)g_mrSpMsc); GlobalVariableSet(ns + "sr", g_mrSpRc); GlobalVariableSet(ns + "sa", g_mrSpAttempts);
   GlobalVariableSet(ns + "sf", g_mrSpFull ? 1 : 0);
   OfhIdStore(ns, Magic);
}
int MrStoreVars() { const string ns = MrNs(); int n = 0; for(int i = GlobalVariablesTotal() - 1; i >= 0; i--) if(StringFind(GlobalVariableName(i), ns) == 0) n++; return n; }

bool MrReceipted(const ulong deal) { for(int j = 0; j < g_mrRcptN; j++) if(g_mrRcpt[j] == deal) return true; return false; }
int  MrReceiptIdx(const ulong deal) { for(int j = 0; j < g_mrRcptN; j++) if(g_mrRcpt[j] == deal) return j; return -1; }
void MrReceiptAdd(const ulong deal, const long dealMsc, const double allowed = 0.0, const int level = 0)
{
   if(deal == 0 || MrReceipted(deal)) return;
   if(g_mrRcptN < MR38_RCPT) { g_mrRcpt[g_mrRcptN] = deal; g_mrRcptMsc[g_mrRcptN] = dealMsc; g_mrRcptTgt[g_mrRcptN] = allowed; g_mrRcptSur[g_mrRcptN] = 0.0; g_mrRcptLv[g_mrRcptN] = level; g_mrRcptN++; g_mrRcptNext = g_mrRcptN % MR38_RCPT; return; }
   if(g_mrRcptMsc[g_mrRcptNext] + 1 > g_mrFloorMsc) g_mrFloorMsc = g_mrRcptMsc[g_mrRcptNext] + 1;
   g_mrRcpt[g_mrRcptNext] = deal; g_mrRcptMsc[g_mrRcptNext] = dealMsc; g_mrRcptTgt[g_mrRcptNext] = allowed; g_mrRcptSur[g_mrRcptNext] = 0.0; g_mrRcptLv[g_mrRcptNext] = level;
   g_mrRcptNext = (g_mrRcptNext + 1) % MR38_RCPT;
}
int MrLevelOfTag(const ulong key)
{
   const int i = MrFind(key); if(i >= 0) return g_mr[i].level;
   const int j = MrReceiptIdx(key); return j >= 0 ? g_mrRcptLv[j] : 0;
}
int MrLevelOfOrder(const ulong posId)
{
   for(int i = 0; i < ArraySize(g_mr); i++) for(int j = 0; j < g_mr[i].nOrd; j++) if(g_mr[i].ord[j] == posId) return g_mr[i].level;
   return 0;
}
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

double MrFilledFromHistory(const int i, int &sideErr)
{
   sideErr = 0;
   const long from = (g_mr[i].reqMsc > 0 && g_mr[i].reqMsc < g_mr[i].closeMsc) ? g_mr[i].reqMsc : g_mr[i].closeMsc;
   if(!HistorySelect((datetime)(from / 1000) - 5, TimeCurrent() + 60)) return g_mr[i].filled;
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

void MrSurplusLedgerClear() { g_mrSpKey = 0; g_mrSpPos = 0; g_mrSpOrd = 0; g_mrSpVol = 0.0; g_mrSpMsc = 0; g_mrSpRc = 0; g_mrSpWarnMs = 0; g_mrSpFull = false; }
double MrSurplusPosVolume() { for(int k = PositionsTotal() - 1; k >= 0; k--) { const ulong t = PositionGetTicket(k); if(t != 0 && PositionSelectByTicket(t) && IsOursPos() && (ulong)PositionGetInteger(POSITION_IDENTIFIER) == g_mrSpPos) return PositionGetDouble(POSITION_VOLUME); } return 0.0; }
bool MrSurplusResolve()
{
   if(g_mrSpKey == 0) return true;
   const int j = MrReceiptIdx(g_mrSpKey);
   if(!HistorySelect((datetime)(g_mrSpMsc / 1000) - 5, TimeCurrent() + 60)) return false;
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
   for(int k = OrdersTotal() - 1; k >= 0; k--)
   {
      const ulong t = OrderGetTicket(k);
      if(t == 0 || OrderGetString(ORDER_SYMBOL) != _Symbol) continue;
      if(t == g_mrSpOrd || (ulong)OrderGetInteger(ORDER_POSITION_ID) == g_mrSpPos) return false;
   }
   const int cls = Ex38Classify(EX38_OP_CLOSE, g_mrSpRc);
   const bool orderFinal = (g_mrSpOrd > 0 && HistoryOrderSelect(g_mrSpOrd));
   const bool fullStill = g_mrSpFull && Ex38TickMsc() - g_mrSpMsc >= MathMax(1, Exec_ConfirmMs) && MrSurplusPosVolume() >= g_mrSpVol - Ex38Step() * 0.5;
   if(Ex38IsRetryClass(cls) || orderFinal || fullStill)
   {
      PrintFormat("MR SURPLUS CLOSE NOT EXECUTED | tag of deal %I64u position %I64u %.2f | rc=%u %s%s -> nothing counted as closed, retry after backoff",
                  g_mrSpKey, g_mrSpPos, g_mrSpVol, g_mrSpRc, Ex38ClassName(cls), orderFinal ? " (order final in the history without a deal)" : (fullStill ? " (full close: the position is still open with its whole volume after the confirmation window, no close order works)" : ""));
      g_mrSpNextMs = now + Ex38BackoffMs(Ex38IsRetryClass(cls) ? cls : EXC_RETRY_SLOW, MathMax(1, g_mrSpAttempts));
      MrSurplusLedgerClear(); MrSaveMeta(); MrFlush();
      return true;
   }
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
   if(!MrSurplusResolve()) return;
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
   MrSaveMeta(); MrFlush();
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
void MrSurplusScan(const string why)
{
   if(DdlActive() || ExActive()) return;
   g_mrSurOutstanding = (g_mrSpKey != 0);
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

void MrComplete(const int i, const string why)
{
   g_mr[i].st = MR_FILLED;
   PrintFormat("MR FILLED_CONFIRMED deal %I64u | %s %.2f of %.2f at original entry %.2f | recovered position %I64u | level %s (the re-entry keeps this level in the level book; ticket count %d) | %s",
               g_mr[i].deal, g_mr[i].type == POSITION_TYPE_BUY ? "BUY" : "SELL", g_mr[i].filled, g_mr[i].target, g_mr[i].entry, g_mr[i].fillPos,
               g_mr[i].level > 0 ? "L" + IntegerToString(g_mr[i].level) : "unknown", CountPositions(), why);
   g_mrRemovedFilled++;
   LbSync();
   const ulong key = g_mr[i].deal; const bool over = Mr38Overfill(g_mr[i].target, g_mr[i].filled, Ex38Step());
   MrRemove(i, MR_FILLED, g_mr[i].target, why);
   if(over) MrSurplusCheck(key, "OVERFILL_AT_COMPLETION");
   if(GgAny()) GgSaveAll();
   LbSync();
}

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
      if(MrOrderWorking(i) || now < g_mr[i].deadlineMs || MrTaggedOpen(g_mr[i].deal) != 0) { if(changed) { MrSaveRec(i); MrFlush(); } return; }
      MrRemove(i, MR_CANCELLED, g_mr[i].filled, "CANCEL_RECONCILED (request window over, no open fill)");
      return;
   }
   if(g_mr[i].st == MR_RECONCILE_ONLY)
   {
      int seen = 0, fin = 0; bool cov = false; MrRequestOrders(i, seen, fin, cov);
      const int cls = Ex38Classify(EX38_OP_OPEN, g_mr[i].lastRc);
      const bool def = Mr38Definitive(MrOrderWorking(i), seen, fin, cov, cls == EXC_DONE || cls == EXC_PARTIAL, g_mr[i].filled > g_mr[i].fillAtReq + 1e-9);
      if(Mr38Complete(g_mr[i].target, g_mr[i].filled, step) || (!MrOrderWorking(i) && (def || now >= g_mr[i].deadlineMs)))
      {
         g_mrRecOnlyResolved++;
         LbSync();
         const int rlv = g_mr[i].level; const bool rpart = g_mr[i].partial; const bool rcyc = (g_mr[i].cycle == MrCycleId() && CountPositions() > 0);
         MrRemove(i, MR_CANCELLED, g_mr[i].target, StringFormat("RECONCILE_ONLY resolved (%s): %.2f of %.2f filled is kept in the basket at L%d, no further request; a later fill of its tag up to %.2f is kept, above it closed",
                                                             Mr38Complete(g_mr[i].target, g_mr[i].filled, step) ? "full fill" : (def ? "request final at the broker" : "window over"),
                                                             g_mr[i].filled, g_mr[i].target, g_mr[i].level, g_mr[i].target));
         if(!ManualReentry_Enable && rcyc) MrrAbandonClosedLevel(rlv, rpart, "old recovery request resolved without an open fill (MRR R1: no re-entry)");
         return;
      }
      if(changed) { MrSaveRec(i); MrFlush(); }
      return;
   }
   if(Mr38Complete(g_mr[i].target, g_mr[i].filled, step)) { MrComplete(i, why); return; }
   if(g_mr[i].st == MR_IN_FLIGHT)
   {
      if(MrOrderWorking(i)) { if(changed) { MrSaveRec(i); MrFlush(); } return; }
      const int cls = Ex38Classify(EX38_OP_OPEN, g_mr[i].lastRc);
      int seen = 0, fin = 0; bool cov = false; MrRequestOrders(i, seen, fin, cov);
      const bool definitive = Mr38Definitive(false, seen, fin, cov, cls == EXC_DONE || cls == EXC_PARTIAL, g_mr[i].filled > g_mr[i].fillAtReq + 1e-9);
      if(!definitive)
      {
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

void MrSend(const int i0)
{
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
      MrReconcile(i, "AFTER_REQUEST");
      return;
   }
   g_mrReqNotExec++;
   g_mr[i].st = MR_RETRY; g_mr[i].nextMs = now + Ex38BackoffMs(cls, g_mr[i].attempts);
   PrintFormat("MR REQUEST NOT EXECUTED deal %I64u | rc=%u %s (definitive: the broker rejected it) | record kept, next try after %I64d ms when the price is still back at the entry (attempt %d/%d)",
               g_mr[i].deal, rc, Ex38ClassName(cls), g_mr[i].nextMs - now, g_mr[i].attempts, Exec_MaxAttempts);
   MrSaveRec(i); MrFlush();
}

void MrPumpSend()
{
   const int n = ArraySize(g_mr); if(n == 0) return;
   if(!ManualReentry_Enable) return;
   if(!Saf38MrSendAllowed(DdlActive(), ExActive(), PairPendingAny(), t1Locked, hedgeTrailActive)) return;
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
      if(st0 == MR_READY)
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
   if(!partial) LbAbandonLevel(level, StringFormat("position %I64u closed by hand, MULTI_MANUAL_IGNORE", posId));
   MrReceiptAdd(deal, closeMsc, 0.0, level);
   g_mrReceiptOnly++;
   PrintFormat("MR MULTI_MANUAL_IGNORE %s | deal %I64u (%s) position %I64u %.2f%s L%s | originals closed by hand in this cycle %d [%s]%s -> NO recovery of any of them until the cycle ends, no compensating order; the open positions keep T1 / T2 / PairClose / DD / session / grid (level book: next grid level L%d)",
               first ? "ON" : "(already on)", deal, src, posId, vol, partial ? " PARTIAL" : "", level > 0 ? IntegerToString(level) : "?", g_mrOrigN, MrOrigText(), done, LbNextLevel(CountPositions()));
   MrSaveMeta(); MrFlush();
   if(GgAny()) GgSaveAll();
   SessRescueRefresh();
}

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
   const bool mrrThisCycle = (nNow > 0 || g_cycStartMsc > 0) && !(g_mrrCycFirstOrd > 0 && posId < g_mrrCycFirstOrd);
   if(mrrThisCycle) g_mrrManualDeals++;
   if(nNow <= 0)
   {
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
   LbActivate(StringFormat("manual close deal %I64u of position %I64u", deal, posId));
   const int level = LbLevelOfPos(posId);
   if(level <= 0) MrFreezeGrid(MRF_LEVEL_UNPROVEN, StringFormat("manual close deal %I64u: position %I64u is not in the level book", deal, posId));
   if(partial && !g_cycIndexShift)
   {
      g_cycIndexShift = true;
      PrintFormat("=== MANUAL PARTIAL CLOSE | position %I64u (L%d): %.2f closed, %.2f still open | %s ===",
                  posId, level, vol, left, ManualPartial_FreezeGrid ? "ManualPartial_FreezeGrid=true: GRID FROZEN for this basket (R1 policy; exits / T1 / T2 / PairClose / DD keep working)" : "ManualPartial_FreezeGrid=false: the grid continues at the level-book level");
   }
   const string side = posType == POSITION_TYPE_BUY ? "BUY" : "SELL";
   const int oj = MrOrigFind(posId, level);
   const int ri = MrFindOrigRec(posId, level, true);
   int act = ManualReentry_Enable ? Mr38CycleDecision(ManualReentry_Enable, g_mrMulti, ri >= 0, MrFindOrigRec(posId, level, false) >= 0, oj >= 0, g_mrOrigN) : MRB_REENTRY_OFF;
   if(act == MRB_CREATE && MrRecoveringCount() > 0)
   {
      PrintFormat("MR INVARIANT | deal %I64u position %I64u L%d: another original still has a recovery record although the cycle counts %d original(s) [%s] -> treated as the 2nd original (MULTI_MANUAL_IGNORE)",
                  deal, posId, level, g_mrOrigN, MrOrigText());
      act = MRB_ABANDON;
   }
   if(oj >= 0) g_mrSameOrigAgain++;
   MrOrigAdd(posId, level);
   if(ManualReentry_Enable)
      PrintFormat("MR MANUAL CLOSE deal %I64u (%s) | position %I64u %s %.2f%s L%s | original %s | originals closed by hand in this cycle %d [%s] | multi %s -> %s",
                  deal, src, posId, side, vol, partial ? " PARTIAL" : "", level > 0 ? IntegerToString(level) : "?", oj >= 0 ? StringFormat("ALREADY SEEN (%I64u)", g_mrOrigPos[oj]) : "NEW",
                  g_mrOrigN, MrOrigText(), g_mrMulti ? "ON" : "off", Mr38DecisionName(act));
   if(act == MRB_ABANDON)
   {
      MrEnterMulti(deal, closeMsc, posId, level, partial, vol, src);
      return;
   }
   if(t1Locked || hedgeTrailActive)
   {
      if(!partial) LbAbandonLevel(level, "closed by hand while T1/T2 own the basket");
      MrReceiptAdd(deal, closeMsc, 0.0, level); g_mrReceiptOnly++;
      PrintFormat("MANUAL CLOSE | deal %I64u (%s) position %I64u %s %.2f%s L%d | T1/T2 own the basket: they keep managing the %d open position(s) | no re-entry", deal, src, posId, side, vol, partial ? " PARTIAL" : "", level, nNow);
      MrSaveMeta(); MrFlush();
      return;
   }
   if(act == MRB_MERGE)
   {
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
   if(StringFind(src, "RESTORE") == 0) MrReconcile(i, "CREATED_AT_RESTORE");
   if(GgAny()) GgSaveAll();
   SessRescueRefresh();
   skipGridThisTick = true;
}
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
   if(StringFind(c, "R2MR|") == 0) MrSurplusCheck((ulong)StringToInteger(StringSubstr(c, 5)), "EVENT");
}

void MrScanHistory(const string why)
{
   g_mrLastScan = TimeCurrent();
   if(CountPositions() <= 0) return;
   MrSurplusScan(why);
   const long cyc = MrCycleId(); if(cyc <= 0) return;
   const long from = MathMax(cyc, g_mrFloorMsc);
   if(!HistorySelect((datetime)(from / 1000), TimeCurrent() + 60)) return;
   ulong cand[]; int m = 0;
   ulong fdeal[], fpos[]; int nf = 0;
   for(int k = 0; k < HistoryDealsTotal(); k++)
   {
      const ulong d = HistoryDealGetTicket(k);
      if(d == 0 || HistoryDealGetString(d, DEAL_SYMBOL) != _Symbol) continue;
      const bool ownMagic = ((ulong)HistoryDealGetInteger(d, DEAL_MAGIC) == Magic);
      const long en = HistoryDealGetInteger(d, DEAL_ENTRY);
      if(en != DEAL_ENTRY_OUT && en != DEAL_ENTRY_INOUT && en != DEAL_ENTRY_OUT_BY) continue;
      if(HistoryDealGetInteger(d, DEAL_TIME_MSC) < from) continue;
      if(!Mr38IsManualReason(Mr38DealReason(d))) continue;
      if(MrFind(d) >= 0 || MrReceipted(d)) continue;
      if(!ownMagic) { ArrayResize(fdeal, nf + 1); ArrayResize(fpos, nf + 1); fdeal[nf] = d; fpos[nf] = (ulong)HistoryDealGetInteger(d, DEAL_POSITION_ID); nf++; continue; }
      ArrayResize(cand, m + 1); cand[m++] = d;
   }
   for(int a = 0; a < nf; a++) if(MrrPosOpenedByEa(fpos[a])) { ArrayResize(cand, m + 1); cand[m++] = fdeal[a]; g_mrrForeignMagic++; }
   for(int k = 0; k < m; k++)
   {
      if(MrrStaleCloseOfFinishedCycle(cand[k], "HISTORY_SCAN_" + why)) continue;
      g_mrScanFound++;
      PrintFormat("MR HISTORY SCAN (%s) | manual close deal %I64u was not processed by OnTradeTransaction -> processed now", why, cand[k]);
      MrOnManualClose(cand[k], "HISTORY_SCAN_" + why);
   }
}
int MrUnprocessedManualClosed(ulong &pid[], long &msc[])
{
   ArrayResize(pid, 0); ArrayResize(msc, 0);
   const long cyc = MrCycleId(); if(cyc <= 0) return 0;
   const long from = MathMax(cyc, g_mrFloorMsc);
   if(!HistorySelect((datetime)(from / 1000), TimeCurrent() + 60)) return 0;
   ulong cand[]; int m = 0;
   ulong fpos[]; int nf = 0;
   for(int k = 0; k < HistoryDealsTotal(); k++)
   {
      const ulong d = HistoryDealGetTicket(k);
      if(d == 0 || HistoryDealGetString(d, DEAL_SYMBOL) != _Symbol) continue;
      const bool ownMagic = ((ulong)HistoryDealGetInteger(d, DEAL_MAGIC) == Magic);
      const long en = HistoryDealGetInteger(d, DEAL_ENTRY);
      if((en != DEAL_ENTRY_OUT && en != DEAL_ENTRY_INOUT && en != DEAL_ENTRY_OUT_BY) || HistoryDealGetInteger(d, DEAL_TIME_MSC) < from) continue;
      if(!Mr38IsManualReason(Mr38DealReason(d)) || MrFind(d) >= 0 || MrReceipted(d)) continue;
      const ulong p = (ulong)HistoryDealGetInteger(d, DEAL_POSITION_ID);
      double left = 0.0; if(PositionOpenById(p, left)) continue;
      if(!ownMagic) { bool hf = false; for(int a = 0; a < nf; a++) if(fpos[a] == p) hf = true; if(!hf) { ArrayResize(fpos, nf + 1); fpos[nf++] = p; } continue; }
      bool have = false; for(int a = 0; a < m; a++) if(cand[a] == p) have = true;
      if(!have) { ArrayResize(cand, m + 1); cand[m++] = p; }
   }
   for(int a = 0; a < nf; a++)
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
   if(g_mrSurOutstanding && !DdlActive() && !ExActive()) MrSurplusScan("RETRY");
   if(g_mrLastCount >= 0 && total < g_mrLastCount) MrScanHistory("COUNT_DROP");
   else if(TimeCurrent() - g_mrLastScan >= 60) MrScanHistory("PERIODIC");
}

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
   g_mrGridFreeze = false; g_mrFreezeWhy = 0; g_mrNoRecN = 0; g_mrMetaCycle = 0; g_mrOrigN = 0; g_mrMulti = false;
   MrSurplusLedgerClear(); g_mrSpAttempts = 0; g_mrSpNextMs = 0; g_mrSurOutstanding = false;
   g_mrFloorMsc = MathMax(g_mrFloorMsc, Ex38TickMsc());
   if(ArraySize(g_mr) == 0) { if(MrPersistOn()) GlobalVariablesDeleteAll(MrNs()); MrSaveMeta(); }
   else MrSaveMeta();
   MrFlush();
}
bool MrOrphanGuard()
{
   if(!MrAnyCancelReconcile()) return false;
   MrReconcileAll();
   for(int i = 0; i < ArraySize(g_mr); i++)
   {
      if(g_mr[i].st != MR_CANCEL_RECONCILE) continue;
      const ulong t = MrTaggedOpen(g_mr[i].deal);
      if(t == 0) continue;
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

void MrRestoreLoad()
{
   ArrayResize(g_mr, 0); g_mrRcptN = 0; g_mrRcptNext = 0; g_mrFloorMsc = 0; g_mrMetaCycle = 0; g_mrGridFreeze = false; g_mrFreezeWhy = 0;
   g_mrrRestLvN = 0; ArrayResize(g_mrrRestLv, 0);
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
      if(Mr38Terminal(r.st))
      {
         PrintFormat("MR RECORD deal %I64u was %s before the stop -> removal finished, not revived", r.deal, Mr38StateName(r.st));
         GlobalVariablesDeleteAll(key); MrReceiptAdd(r.deal, r.closeMsc, r.st == MR_FILLED ? r.target : r.filled, r.level); continue;
      }
      const bool sameCycle = (r.cycle == cyc && nPos > 0);
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
         if(sameCycle && !r.partial && r.level > 0) { ArrayResize(g_mrrRestLv, g_mrrRestLvN + 1); g_mrrRestLv[g_mrrRestLvN++] = r.level; }
         continue;
      }
      if(r.st == MR_IN_FLIGHT || r.st == MR_READY || r.st == MR_RETRY || r.st == MR_PARTIAL || r.st == MR_RECONCILE_ONLY) g_exGraceUntil = MathMax(g_exGraceUntil, Ex38NowMs() + MathMax(1, Exec_ConfirmMs));
      const int i = ArraySize(g_mr); ArrayResize(g_mr, i + 1); g_mr[i] = r;
      g_mrRestoredN++;
   }
   if(ArraySize(g_mr) > g_mrMaxActive) g_mrMaxActive = ArraySize(g_mr);
   for(int i = 0; i < ArraySize(g_mr); i++) if(g_mr[i].cycle == cyc && g_mr[i].st != MR_CANCEL_RECONCILE) MrOrigAdd(g_mr[i].posId, g_mr[i].level);
   if(g_mrOrigN >= 2 && !g_mrMulti) { g_mrMulti = true; g_mrMultiOn++; PrintFormat("MR RESTORE | %d originals closed by hand in this cycle [%s] -> MULTI_MANUAL_IGNORE", g_mrOrigN, MrOrigText()); }
   if(incomplete > 0 && sameMeta)
   {
      for(int k = 0; k < nk; k++)
         if(MrFind(keys[k]) < 0 && !MrReceipted(keys[k]) && !GlobalVariableCheck(MrKey(keys[k]) + "s")) MrOnManualClose(keys[k], "RESTORE_INCOMPLETE");
   }
   PrintFormat("MR RESTORE LOAD | records %d restored (%d cancelled, %d incomplete) | receipts %d floor %I64d | originals closed by hand %d [%s] MULTI_MANUAL_IGNORE %s | surplus close in flight %I64u | grid freeze %s | cycle %I64d",
               ArraySize(g_mr), cancelled, incomplete, g_mrRcptN, g_mrFloorMsc, g_mrOrigN, MrOrigText(), g_mrMulti ? "ON" : "off", g_mrSpKey, g_mrGridFreeze ? MrFreezeName(g_mrFreezeWhy) : "no", cyc);
   MrSaveMeta(); GlobalVariablesFlush();
}
void MrRestoreFinish()
{
   if(ArraySize(g_mr) > 0 && g_exGraceUntil > Ex38NowMs()) Ex38RestartGrace("manual recovery record(s) restored");
   if(DdlActive()) MrOnDdActivate();
   else if(ExActive()) MrOnExitCommit();
   else if(t1Locked || hedgeTrailActive) MrOnT1Priority();
   else if(g_mrMulti && MrRecoveringCount() > 0) PrintFormat("MR RESTORE | MULTI_MANUAL_IGNORE of this cycle:%s", MrMultiSweep());
   const int n = ArraySize(g_mr);
   ulong keys[]; ArrayResize(keys, n); for(int k = 0; k < n; k++) keys[k] = g_mr[k].deal;
   for(int k = 0; k < n; k++) { const int i = MrFind(keys[k]); if(i >= 0) MrReconcile(i, "RESTORE"); }
   for(int k = 0; k < g_mrrRestLvN; k++) MrrAbandonClosedLevel(g_mrrRestLv[k], false, "closed by hand before the restart, its old recovery record is dropped (MRR R1: no re-entry)");
   g_mrrRestLvN = 0; ArrayResize(g_mrrRestLv, 0);
   if(!DdlActive() && !ExActive() && CountPositions() > 0) MrScanHistory("RESTART");
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

string MrrNs() { return OfhNs("OFH38Z", Magic); }
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
bool MrrStaleCloseOfFinishedCycle(const ulong deal, const string src)
{
   if(deal == 0 || MrFind(deal) >= 0 || MrReceipted(deal)) return false;
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
bool MrrTpOfRunningCycle(const ulong deal)
{
   const ulong posId = (ulong)HistoryDealGetInteger(deal, DEAL_POSITION_ID);
   const int own = Mrr38TpCycleOwner(posId, g_mrrCycFirstOrd, posId > 0 && LbLevelOfPos(posId) > 0);
   if(own > 0) return true;
   if(own < 0)
      PrintFormat("STALE TP OF A FINISHED CYCLE | deal %I64u position %I64u: ticket below the first order %I64u of the running basket (BasketCycleID %I64d) -> recorded only: no basket close, TP / grid / cycle of the running basket unchanged",
                  deal, posId, g_mrrCycFirstOrd, g_cycStartMsc);
   else
      PrintFormat("TP OF AN UNPROVEN CYCLE | deal %I64u position %I64u: %s -> no basket close and no TP change from this event (exits / T1 / T2 / PairClose / DD / session keep managing the running basket)",
                  deal, posId, posId == 0 ? "position of the deal not readable" : "first order of the running basket unknown and the position is not in its level book");
   return false;
}
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
      PrintFormat("CYCLE FINALIZED | BasketCycleID %I64d | %s | broker: EA positions 0, EA orders working %d, entry request without broker result %s, old recovery requests in flight %d | grid / GLOBAL / PairClose / T1-T2 / manual state reset by their cycle contracts | a later fill of one of those orders is closed, never a new L1",
                  g_mrrFinCyc, g_mrrLateClosed ? "late fill of the finished cycle closed" : StringFormat("%d manual-close deal(s)%s", g_mrrManualDeals, g_mrrFullManual ? ", FULL MANUAL BASKET CLOSE" : ""),
                  g_mrrLateOrdN, g_seRec.st == 0 ? "none" : "YES", fl);
   }
   g_mrrManualDeals = 0; g_mrrFullManual = false; g_mrrLateClosed = false;
}
void MrrOnNewL1(const ulong order)
{
   if(g_mrrAwaitL1) PrintFormat("L1 RESUMED | new BasketCycleID after the finished cycle %I64d (last block reason %s)", g_mrrFinCyc, g_mrrL1Why == "" ? "none" : g_mrrL1Why);
   const bool had = (g_mrrFinMsc > 0);
   MrrClearFinished(); g_mrrLateClosed = false; g_mrrSeenPos = false; g_mrrCycFirstOrd = order; g_mrrMaxSeenId = 0;
   if(had) MrrPersist();
}
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
#ifndef OFH38_PRECEDENCE_MQH
#define OFH38_PRECEDENCE_MQH

#ifndef OFH38_PRECEDENCE_CORE_MQH
#define OFH38_PRECEDENCE_CORE_MQH

#define AUTH_GRID            0
#define AUTH_PAIR_PENDING    1
#define AUTH_BASKET_EXITING  2
#define AUTH_DD_LOCK         3
#define AUTH_OWNER_REQUIRED  4
#define AUTH_FLAT            5

string Auth38Name(const int a)
{
   switch(a)
   {
      case AUTH_GRID: return "GRID_WAITING";             case AUTH_PAIR_PENDING: return "PAIR_CLOSE_PENDING"; case AUTH_BASKET_EXITING: return "BASKET_EXITING";
      case AUTH_DD_LOCK: return "DD_LOCK";               case AUTH_OWNER_REQUIRED: return "OWNER_REQUIRED";   case AUTH_FLAT: return "FLAT";
   }
   return "?";
}

int Auth38Resolve(const bool flat, const bool ddRec, const bool ddUnproven, const bool hedgeOpen, const bool exRec, const bool pairPend)
{
   if(exRec && ddRec && ddUnproven && !hedgeOpen) return AUTH_OWNER_REQUIRED;
   if(ddRec || hedgeOpen) return AUTH_DD_LOCK;
   if(exRec) return AUTH_BASKET_EXITING;
   if(flat) return AUTH_FLAT;
   if(pairPend) return AUTH_PAIR_PENDING;
   return AUTH_GRID;
}

bool Econ38BlocksDd(const double econ) { return econ >= 0.0; }
double Econ38BePrice(const double econ, const double net, const double bid, const double ask, const double tickValue, const double tickSize, const double eps)
{
   if(MathAbs(net) < eps || tickValue <= 0.0 || tickSize <= 0.0) return 0.0;
   const double mark = net > 0.0 ? bid : ask;
   return mark - econ * tickSize / (tickValue * net);
}

#define PRIO_BROKER_RECONCILE           1
#define PRIO_EXIT_COMMITTED             2
#define PRIO_T1T2                       3
#define PRIO_PAIR_CLOSE_PENDING         4
#define PRIO_MANUAL_RECOVERY_IN_FLIGHT  5
#define PRIO_SURPLUS_CLOSE_PENDING      6
#define PRIO_ORIGINAL_GRID_DRAWDOWN     7
#define PRIO_OTHER                      8
#define PRIO_N                          9

string Prio38Name(const int s)
{
   switch(s)
   {
      case PRIO_BROKER_RECONCILE: return "BROKER_RECONCILE";                   case PRIO_EXIT_COMMITTED: return "EXIT_COMMITTED";
      case PRIO_T1T2: return "T1_T2_ELIGIBLE_OR_LATCHED";                      case PRIO_PAIR_CLOSE_PENDING: return "PAIR_CLOSE_PENDING";
      case PRIO_MANUAL_RECOVERY_IN_FLIGHT: return "MANUAL_RECOVERY_IN_FLIGHT"; case PRIO_SURPLUS_CLOSE_PENDING: return "SURPLUS_CLOSE_PENDING";
      case PRIO_ORIGINAL_GRID_DRAWDOWN: return "ORIGINAL_GRID_DRAWDOWN";       case PRIO_OTHER: return "OTHER";
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
bool Prio38DdMayStart(const int s) { return s == PRIO_ORIGINAL_GRID_DRAWDOWN; }

#endif

int    g_authLast = -1;
bool   g_authOwnerReq = false; string g_authOwnerWhy = "";
long   g_pairWarnMsc = 0, g_r2DdLogPair = 0, g_r2DdLogEcon = 0, g_r2OwnerLogMsc = 0;
string g_r2Alerted = "";
long   g_r2DdDefPair = 0, g_r2DdDefEcon = 0, g_r2PairFirst = 0, g_r2T1DefPair = 0, g_r2PairMerged = 0, g_r2OwnerReqTicks = 0, g_r2PairWarnings = 0;
string g_r2EconKey = ""; double g_r2EconReal = 0.0; datetime g_r2EconAt = 0;

bool PairPendingAny() { return g_pairPend1 != 0 || g_pairPend2 != 0; }

void R2Warn(const string key, const string text)
{
   Print(text);
   if((bool)MQLInfoInteger(MQL_TESTER) || StringFind(g_r2Alerted, "|" + key + "|") >= 0) return;
   g_r2Alerted += "|" + key + "|"; if(StringLen(g_r2Alerted) > 2000) g_r2Alerted = "|" + key + "|";
   Alert(text);
}

#define R2_VOL_EPS 0.00000001
long   g_r2EconBadCnt = 0, g_r2EconBadLogMsc = 0;
string g_r2EconBadCode = "";
bool   g_r2EconOk = false;
void R2EconUnproven(const string code, const string detail, const long startMsc, const int err)
{
   g_r2EconBadCnt++;
   const long now = Ex38TickMsc();
   if(code == g_r2EconBadCode && now - g_r2EconBadLogMsc < 60000) return;
   g_r2EconBadCode = code; g_r2EconBadLogMsc = now;
   PrintFormat("ECONOMIC_HISTORY_UNPROVEN | %s%s | cycle start %I64d ms | error %d | deals in the selected history %d | EA positions %d | events %I64d -> the economic P/L of the basket cycle is NOT proven: final-session rule B is not eligible (fail closed, no zero or stale value used), rule A (position count) and every exit keep working; the DD B5 check keeps its unchanged legacy value (Owner review)",
               code, detail == "" ? "" : " " + detail, startMsc, err, HistoryDealsTotal(), CountPositions(), g_r2EconBadCnt);
}
string R2RealisedGap(const long startMsc, const ulong &ids[], const int n, const int total)
{
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      const ulong t = PositionGetTicket(i);
      if(t == 0 || PositionGetString(POSITION_SYMBOL) != _Symbol || (ulong)PositionGetInteger(POSITION_MAGIC) != Magic) continue;
      if(PositionGetInteger(POSITION_TIME_MSC) < startMsc) continue;
      const ulong pid = (ulong)PositionGetInteger(POSITION_IDENTIFIER);
      bool found = false; for(int a = 0; a < n && !found; a++) if(ids[a] == pid) found = true;
      if(!found) return StringFormat("ENTRY_DEAL_MISSING position %I64u", pid);
   }
   for(int a = 0; a < n; a++)
   {
      bool seen = false; for(int b = 0; b < a && !seen; b++) if(ids[b] == ids[a]) seen = true;
      if(seen) continue;
      double vIn = 0.0, vOut = 0.0;
      for(int k = 0; k < total; k++)
      {
         const ulong d = HistoryDealGetTicket(k);
         if(d == 0 || (ulong)HistoryDealGetInteger(d, DEAL_POSITION_ID) != ids[a] || HistoryDealGetInteger(d, DEAL_TIME_MSC) < startMsc) continue;
         const long en = HistoryDealGetInteger(d, DEAL_ENTRY);
         if(en == DEAL_ENTRY_INOUT) return StringFormat("INOUT_DEAL position %I64u", ids[a]);
         if(HistoryDealGetString(d, DEAL_SYMBOL) != _Symbol || (ulong)HistoryDealGetInteger(d, DEAL_MAGIC) != Magic) return StringFormat("FOREIGN_DEAL position %I64u deal %I64u (magic %I64d, not counted by the cycle sum)", ids[a], d, HistoryDealGetInteger(d, DEAL_MAGIC));
         if(en == DEAL_ENTRY_IN) vIn += HistoryDealGetDouble(d, DEAL_VOLUME); else vOut += HistoryDealGetDouble(d, DEAL_VOLUME);
      }
      double vOpen = 0.0; bool isOpen = false;
      for(int i = PositionsTotal() - 1; i >= 0 && !isOpen; i--)
      {
         const ulong t = PositionGetTicket(i);
         if(t != 0 && (ulong)PositionGetInteger(POSITION_IDENTIFIER) == ids[a]) { isOpen = true; vOpen = PositionGetDouble(POSITION_VOLUME); }
      }
      if(MathAbs(vIn - vOut - vOpen) > R2_VOL_EPS) return StringFormat("%s position %I64u (in %.2f out %.2f open %.2f lots)", isOpen ? "VOLUME_MISMATCH" : "EXIT_DEAL_MISSING", ids[a], vIn, vOut, vOpen);
   }
   ulong orphan[]; int nOrph = 0;
   for(int k = 0; k < total; k++)
   {
      const ulong d = HistoryDealGetTicket(k);
      if(d == 0 || HistoryDealGetString(d, DEAL_SYMBOL) != _Symbol || (ulong)HistoryDealGetInteger(d, DEAL_MAGIC) != Magic || HistoryDealGetInteger(d, DEAL_TIME_MSC) < startMsc) continue;
      const ulong pid = (ulong)HistoryDealGetInteger(d, DEAL_POSITION_ID);
      bool known = false; for(int a = 0; a < n && !known; a++) if(ids[a] == pid) known = true;
      for(int b = 0; b < nOrph && !known; b++) if(orphan[b] == pid) known = true;
      if(!known) { ArrayResize(orphan, nOrph + 1); orphan[nOrph++] = pid; }
   }
   if(nOrph <= 0) return "";
   string gap = "";
   for(int b = 0; b < nOrph && gap == ""; b++)
   {
      if(!HistorySelectByPosition((long)orphan[b])) { gap = StringFormat("POSITION_HISTORY_FAILED position %I64u", orphan[b]); break; }
      bool before = false;
      for(int k = HistoryDealsTotal() - 1; k >= 0 && !before; k--)
      {
         const ulong d = HistoryDealGetTicket(k);
         const long en = HistoryDealGetInteger(d, DEAL_ENTRY);
         if(d != 0 && (en == DEAL_ENTRY_IN || en == DEAL_ENTRY_INOUT) && HistoryDealGetInteger(d, DEAL_TIME_MSC) < startMsc) before = true;
      }
      if(!before) gap = StringFormat("ENTRY_DEAL_MISSING closed position %I64u (EA deal inside the cycle window, no entry deal before the start)", orphan[b]);
   }
   if(!HistorySelect((datetime)(startMsc / 1000) - 1, TimeCurrent() + 60) && gap == "") gap = "HISTORY_RESELECT_FAILED";
   return gap;
}
double R2RealisedCycle(const long startMsc, bool &ok)
{
   ok = false;
   if(startMsc <= 0) { R2EconUnproven("CYCLE_START_INVALID", "", startMsc, 0); return 0.0; }
   if(!HistorySelect((datetime)(startMsc / 1000) - 1, TimeCurrent() + 60)) { R2EconUnproven("HISTORY_SELECT_FAILED", "", startMsc, GetLastError()); return 0.0; }
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
   const string gap = R2RealisedGap(startMsc, ids, n, total);
   if(gap != "") R2EconUnproven("HISTORY_INCOMPLETE", gap, startMsc, 0);
   ok = (gap == "");
   return s;
}
double R2CycleEconomic(double &realised, double &floating)
{
   floating = BasketProfit();
   const long st = CycStartMsc();
   const string k = StringFormat("%I64d|%.2f|%d", st, AccountInfoDouble(ACCOUNT_BALANCE), PositionsTotal());
   if(k != g_r2EconKey || TimeCurrent() - g_r2EconAt >= 60) { g_r2EconReal = R2RealisedCycle(st, g_r2EconOk); g_r2EconKey = k; g_r2EconAt = TimeCurrent(); }
   realised = g_r2EconReal;
   return realised + floating;
}
bool R2CycleEconomicProven() { return g_r2EconOk; }

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

bool PairQualifiesNow(const int total)
{
   if(!basketModeLatched || !PairClose_BatTat || hedgeTrailActive || total < PairClose_TuLenh || PairClose_SoUSD <= 0) return false;
   if(MrSurplusInFlight()) return false;
   ulong a = 0, b = 0;
   return GetTwoLatestTickets(a, b) && CheckPairClose(a, b, PairClose_SoUSD);
}

long g_prBlocked[PRIO_N];
long g_prLogMsc[PRIO_N];
long g_prStarted = 0, g_prT1WhileDd = 0, g_prPairWaitSur = 0, g_prDdEpLogged = 0, g_prL1WaitOrder = 0;
int  g_prLast = 0;

bool Prio38OrderWorking()
{
   for(int k = OrdersTotal() - 1; k >= 0; k--)
   {
      const ulong t = OrderGetTicket(k);
      if(t != 0 && OrderGetString(ORDER_SYMBOL) == _Symbol && (ulong)OrderGetInteger(ORDER_MAGIC) == Magic) return true;
   }
   return false;
}
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
int Prio38DdState(const double pl, const double econ, bool &t1Elig)
{
   int nd = 0; double lp = 0.0;
   t1Elig = (basketModeLatched || CountPositions() >= 2) && T1EligibleNow(nd, lp);
   const bool unknown = (Ex38NowMs() < g_exGraceUntil) || Prio38OrderWorking();
   const bool surplus = MrSurplusInFlight() || g_mrSurOutstanding;
   const int r = Prio38Resolve(unknown, ExActive(), t1Locked || t2Armed || hedgeTrailActive, t1Elig, PairPendingAny(), MrInflightAny(), surplus,
                               Prio38GridPositions(), pl < 0.0, !Econ38BlocksDd(econ));
   return r;
}
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
void AuthOwnerRequiredTick()
{
   g_r2OwnerReqTicks++;
   const long now = Ex38TickMsc();
   if(now - g_r2OwnerLogMsc < 60000) return;
   g_r2OwnerLogMsc = now;
   R2Warn("OWNERREQ", StringFormat("R2 OWNER_REQUIRED | %s | no grid / L1 / recovery / close / hedge request - Terminal > Global Variables: delete the record the Owner rejects (prefix %s = exit, %s = DD lock), then re-initialise the EA",
                                   g_authOwnerWhy, ExNs(), DdlNs()));
}
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
#ifndef OFH38_BASKETEXIT_MQH
#define OFH38_BASKETEXIT_MQH

#define EXR_T1_HIT          1
#define EXR_T2_HIT          2
#define EXR_T1T2_BROKER     3
#define EXR_L1_TP_EXTRA     4
#define EXR_SESSION_LE_N    5
#define EXR_SESSION_PROFIT  6
#define EXR_MR_ORPHAN       8
#define EXR_LRP_FLATTEN    10
#define EXR_T4_BE100_FLAT  11
#define EXR_LATE_FILL      12
#define EXR_SESSION_CYCLE_LOSS 13

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
      case EXR_MR_ORPHAN: return "MR_ORPHAN_FILL";
      case EXR_LRP_FLATTEN: return "LRP_EMERGENCY_FLATTEN_TEST_ONLY";
      case EXR_T4_BE100_FLAT: return "T4_P0_BE100_FLAT";
      case EXR_LATE_FILL: return "LATE_FILL_OF_FINISHED_CYCLE";
      case EXR_SESSION_CYCLE_LOSS: return "SESSION_CLOSE_CYCLE_LOSS";
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
   if(g_pairPend1 != 0 || g_pairPend2 != 0)
   {
      g_r2PairMerged++;
      PrintFormat("BASKET_EXITING | PairClose leg(s) %I64u/%I64u still pending -> merged into the basket exit (one close authority, in-flight closes are not re-sent)", g_pairPend1, g_pairPend2);
      g_pairPend1 = 0; g_pairPend2 = 0; g_pairPendSinceMsc = 0;
   }
   MrOnExitCommit();
   ExPersist(); GlobalVariablesFlush();
}
void ExCommitOrphanClose() { CloseBasketR(EXR_MR_ORPHAN, EXP_NONE); }

void ExComplete()
{
   const long tm = Ex38TickMsc();
   long lastOut = 0;
   const double realF = ExRealisedSince(g_exStartMsc, lastOut, g_exSigMsc);
   if(lastOut > g_exLastDealMsc) g_exLastDealMsc = lastOut;
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
      if(MrInflightAny()) MrReconcileAll();
      if(MrInflightAny()) { MrLogOnce("EXWAIT_" + IntegerToString(g_exSigMsc), "BASKET_EXITING | broker flat, waiting for the reconciliation of a recovery request in flight (a late fill is closed with the basket)"); ExPersist(); return; }
      ExComplete();
   }
   else ExPersist();
}

void ExOnDeal(const ulong deal)
{
   g_exDeals++;
   const long dm = HistoryDealGetInteger(deal, DEAL_TIME_MSC);
   if(dm > g_exLastDealMsc) g_exLastDealMsc = dm;
}

bool CloseBasketR(const int reason, const int post)
{
   if(g_exState == EXS_IDLE)
   {
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

void ExRestore()
{
   g_exState = EXS_IDLE;
   const string ns = ExNs();
   if(!GlobalVariableCheck(ns + "state")) return;
   const string idWhy = OfhIdCheck(ns, Magic);
   if(idWhy != "") { PrintFormat("EXIT RECORD %s IGNORED | identity mismatch (%s)", ns, idWhy); return; }
   if(DdlActive())
   {
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
      if(pid[k] <= g_mrrFinMaxSeen) { older++; olds += StringFormat("%s%I64u", olds == "" ? "" : ", ", pid[k]); }
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
   else if(older > 0)
      PrintFormat("BROKER STATE INCONSISTENCY | %d position(s) of the finalized BasketCycleID %I64d reappeared without an L1 of the EA (%s; %d open now, %d would match the late-fill rule): the flat was transient -> adopted as the basket (as before), nothing closed by the late-fill rule",
                  older, g_mrrFinCyc, olds, np, late);
   MrrClearFinished(); g_mrrCycFirstOrd = minId;
   MrrPersist();
   return false;
}

#ifndef OFH38_CYCLELATCH_MQH
#define OFH38_CYCLELATCH_MQH

#ifndef OFH38_OWNER12_CORE_MQH
#define OFH38_OWNER12_CORE_MQH

#define O12_ENTRY_V26      0
#define O12_ENTRY_GLOBAL   1

bool O12EntryValid(const int v) { return v == O12_ENTRY_V26 || v == O12_ENTRY_GLOBAL; }
string O12EntryName(const int v) { return v == O12_ENTRY_V26 ? "0 = V26 truyen thong" : (v == O12_ENTRY_GLOBAL ? "1 = GLOBAL Grid Mode 1" : StringFormat("%d = INVALID", v)); }
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
#define O12M_OK          0
#define O12M_CONSISTENT  1
#define O12M_CONFLICT   -1
#define O12M_UNREADABLE -2
#define O12M_BADENTRY   -3
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

double O12PipToPrice(const double pips, const double pipSize) { return pips * pipSize; }
bool O12T1T2Valid(const double doiSlPip, const double lockPip, const double trailPip)
{
   return doiSlPip > 0.0 && lockPip >= 0.0 && lockPip < doiSlPip && trailPip > 0.0;
}

#define O12S_NONE          0
#define O12S_CLOSE_LE_N    1
#define O12S_RESCUE        2
#define O12S_CLOSE_CYCLE   3
#define O12S_RESCUE_CYCLE  4
#define O12S_DEFER         5
#define O12S_EPS_USD       0.000001
double O12SessionPctEff(const bool apply, const double pct) { return apply ? MathMax(0.0, pct) : 0.0; }
double O12SessionAllowedLoss(const double equity, const double pctEff) { return MathMax(0.0, equity) * MathMax(0.0, pctEff) / 100.0; }
int O12SessionDecision(const bool nearEnd, const bool inFlight, const int total, const int maxOrders, const bool econOk,
                       const double econ, const double equity, const double pctEff)
{
   if(total <= 0 || !nearEnd) return O12S_NONE;
   if(inFlight) return O12S_DEFER;
   if(total <= maxOrders) return O12S_CLOSE_LE_N;
   if(!econOk) return O12S_RESCUE;
   return (econ >= -O12SessionAllowedLoss(equity, pctEff) - O12S_EPS_USD) ? O12S_CLOSE_CYCLE : O12S_RESCUE_CYCLE;
}

uint O12Fnv1a(const string s)
{
   uint h = 2166136261;
   const int n = StringLen(s);
   for(int i = 0; i < n; i++) { h ^= (uint)StringGetCharacter(s, i); h *= 16777619; }
   return h;
}

#endif

#define CL_GG_ON        0
#define CL_GG_K         1
#define CL_GG_D         2
#define CL_MAXORD       3
#define CL_INITLOT      4
#define CL_MULTI        5
#define CL_COST         6
#define CL_SLIP         7
#define CL_EXIT_MODE    8
#define CL_EXIT_TF      9
#define CL_EXIT_EF     10
#define CL_EXIT_ES     11
#define CL_EXIT_ATR    12
#define CL_EXIT_STRONG 13
#define CL_EXIT_FSTART 14
#define CL_EXIT_FKEEP  15
#define CL_EXIT_MW     16
#define CL_EXIT_MS     17
#define CL_EXIT_TMIN   18
#define CL_EXIT_TMAX   19
#define CL38_N         20
#define CL38_R6_N      28
int Cl38R6Index(const int i) { const int m[CL38_N] = {2, 3, 4, 5, 6, 7, 10, 11, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27}; return (i >= 0 && i < CL38_N) ? m[i] : -1; }

double g_clIn[CL38_N];
double g_cl[CL38_N];
bool   g_clHave = false;
long   g_clCycle = 0;
bool   g_clFrozen = false;
string g_clFrozenWhy = "";
long   g_clFrozenTicks = 0, g_clLatched = 0, g_clMismatch = 0;
double g_clLdIn[GG38_LD_MAX]; int g_clLdInN = 0;
double g_clLd[GG38_LD_MAX];   int g_clLdN = 0;
long   g_clLdLegacy = 0;
long   g_clR6Migrated = 0;
int    ClLdCount() { return g_clHave ? g_clLdN : g_clLdInN; }
double ClLdGet(const int i) { const int n = ClLdCount(); if(i < 1 || i > n) return -1.0; return g_clHave ? g_clLd[i - 1] : g_clLdIn[i - 1]; }
void   ClLdLatchInputs() { g_clLdN = g_clLdInN; for(int i = 0; i < g_clLdInN; i++) g_clLd[i] = g_clLdIn[i]; }

string Cl38FieldName(const int i)
{
   const string nm[CL38_N] = {"Entry_Strategy", "GlobalGrid_OrdersPerGroup", "GlobalGrid_BreakoutDistanceUSD", "Max_Orders", "Initial_Lot", "Lot_Multi",
                              "Exit_CloseCostPerLotUSD", "Exit_SlipReservePoints", "Exit_Mode", "ExitTrend_TF", "ExitTrend_EmaFast", "ExitTrend_EmaSlow", "ExitTrend_AtrPeriod",
                              "ExitTrend_StrongScore", "ExitHyb_FloorStartPips", "ExitHyb_FloorKeepPct", "ExitHyb_AtrMultWeak", "ExitHyb_AtrMultStrong", "ExitHyb_TrailMinPips", "ExitHyb_TrailMaxPips"};
   return (i >= 0 && i < CL38_N) ? nm[i] : "?";
}
void ClReadInputs()
{
   const bool gl = (Entry_Strategy == OFH38_ENTRY_GLOBAL);
   g_clIn[CL_GG_ON] = gl ? 1 : 0;                            g_clIn[CL_GG_K] = GlobalGrid_OrdersPerGroup;   g_clIn[CL_GG_D] = GlobalGrid_BreakoutDistanceUSD;
   g_clIn[CL_MAXORD] = Max_Orders;                           g_clIn[CL_INITLOT] = Initial_Lot;              g_clIn[CL_MULTI] = Lot_Multi;
   g_clIn[CL_COST] = Exit_CloseCostPerLotUSD;                g_clIn[CL_SLIP] = Exit_SlipReservePoints;
   g_clIn[CL_EXIT_MODE] = (int)Exit_Mode;                    g_clIn[CL_EXIT_TF] = (int)ExitTrend_TF;
   g_clIn[CL_EXIT_EF] = ExitTrend_EmaFast;                   g_clIn[CL_EXIT_ES] = ExitTrend_EmaSlow;      g_clIn[CL_EXIT_ATR] = ExitTrend_AtrPeriod;
   g_clIn[CL_EXIT_STRONG] = ExitTrend_StrongScore;           g_clIn[CL_EXIT_FSTART] = ExitHyb_FloorStartPips;   g_clIn[CL_EXIT_FKEEP] = ExitHyb_FloorKeepPct;
   g_clIn[CL_EXIT_MW] = ExitHyb_AtrMultWeak;                 g_clIn[CL_EXIT_MS] = ExitHyb_AtrMultStrong;
   g_clIn[CL_EXIT_TMIN] = ExitHyb_TrailMinPips;              g_clIn[CL_EXIT_TMAX] = ExitHyb_TrailMaxPips;
   g_clLdInN = 0;
   if(gl)
   {
      double ld[]; int bad = 0;
      const int n = Gg38LdParse(GlobalGrid_LocalDistancesPips, ld, bad), req = Gg38LdRequired(GlobalGrid_OrdersPerGroup, Max_Orders);
      if(Gg38LdCheck(n, req) == GG38_LD_OK && req <= GG38_LD_MAX) { for(int i = 0; i < req; i++) g_clLdIn[i] = ld[i]; g_clLdInN = req; }
   }
}
double ClGet(const int i) { return g_clHave ? g_cl[i] : g_clIn[i]; }
string ClNs() { return OfhNs("OFH38K", Magic); }
string R7LegacyRpaNs() { return OfhNs("OFH38R", Magic); }
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
   GlobalVariableSet(ns + "ldv", 2); GlobalVariableSet(ns + "ldn", g_clLdN);
   for(int i = 0; i < g_clLdN; i++) GlobalVariableSet(ns + "ld" + IntegerToString(i), g_clLd[i]);
   GlobalVariableSet(ns + "r7v", 1);
   OfhIdStore(ns, Magic);
   GlobalVariablesFlush();
}
void ClClearRecord() { if(GlobalVariablesDeleteAll(ClNs()) > 0) GlobalVariablesFlush(); }

void ClTick(const int total)
{
   if(total <= 0 || g_cycStartMsc <= 0 || (g_clHave && g_clCycle == g_cycStartMsc)) return;
   for(int i = 0; i < CL38_N; i++) g_cl[i] = g_clIn[i];
   ClLdLatchInputs();
   g_clHave = true; g_clCycle = g_cycStartMsc; g_clFrozen = false; g_clFrozenWhy = ""; g_clLatched++;
   ClWrite();
   PrintFormat("CYCLE LATCH | BasketCycleID %I64d latched (V26 PairClose; until the basket is flat)", g_clCycle);
}
void ClOnCycleReset()
{
   g_clHave = false; g_clCycle = 0; g_clFrozen = false; g_clFrozenWhy = ""; g_clLdN = 0;
   if(CountPositions() <= 0) ClClearRecord();
}
void ClRestore()
{
   g_clHave = false; g_clCycle = 0; g_clFrozen = false; g_clFrozenWhy = ""; g_clLdN = 0;
   const int n = CountPositions();
   const string ns = ClNs();
   if(n <= 0) { ClClearRecord(); return; }
   const long cyc = g_cycStartMsc > 0 ? g_cycStartMsc : CycStartMsc();
   const bool r7Rec = GlobalVariableCheck(ns + "r7v") && (int)GlobalVariableGet(ns + "r7v") == 1 && (int)GlobalVariableGet(ns + "nf") == CL38_N;
   const bool r6Mode0 = !r7Rec && GlobalVariableCheck(ns + "pcv") && (int)GlobalVariableGet(ns + "pcv") == 1 && GlobalVariableCheck(ns + "pcm") && (int)GlobalVariableGet(ns + "pcm") == 0 && (int)GlobalVariableGet(ns + "nf") == CL38_R6_N;
   const bool have = GlobalVariableCheck(ns + "cyc") && OfhIdCheck(ns, Magic) == "" && (long)GlobalVariableGet(ns + "cyc") == cyc && cyc > 0 && (r7Rec || r6Mode0);
   if(!have)
   {
      for(int i = 0; i < CL38_N; i++) g_cl[i] = g_clIn[i];
      ClLdLatchInputs();
      g_clHave = true; g_clCycle = cyc; g_clLatched++;
      ClWrite();
      R2Warn("CLNOREC", StringFormat("CYCLE LATCH | open basket (%d positions, cycle %I64d) has no configuration record of this cycle (this build): the current inputs are latched now (basket of an older build / record lost)", n, cyc));
      return;
   }
   for(int i = 0; i < CL38_N; i++) g_cl[i] = GlobalVariableGet(ns + "f" + IntegerToString(r6Mode0 ? Cl38R6Index(i) : i));
   g_clHave = true; g_clCycle = cyc;
   if(r6Mode0) { g_clR6Migrated++; PrintFormat("CYCLE LATCH | R6 record of a V26 PairClose (mode 0) cycle %I64d migrated to the R7 layout (%d of %d fields; the Recursive Pair_A / Pair_A session / rebase-gate fields and the mode keys are dropped)", cyc, CL38_N, CL38_R6_N); }
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
            if(!MathIsValidNumber(v) || v < 0.0) { ldBad = true; break; }
            g_clLd[i] = v;
         }
         g_clLdN = ldBad ? 0 : m;
      }
   }
   const bool legacyGl = !ldRec && glLatched;
   const bool badGl    = ldBad && glLatched;
   const bool ldDiff   = ldRec && !ldBad && Gg38LdDiffers(g_clLdIn, g_clLdInN, g_clLd, g_clLdN);
   if(Cl38Diff(g_clIn, g_cl, CL38_N) < 0 && !ldDiff && !legacyGl && !badGl) { if(r6Mode0) ClWrite(); return; }
   g_clFrozen = true; g_clMismatch++;
   if(legacyGl) g_clLdLegacy++;
   string diff = "";
   for(int i = 0; i < CL38_N; i++) if(MathAbs(g_clIn[i] - g_cl[i]) > 1e-9 * MathMax(1.0, MathAbs(g_cl[i]))) diff += StringFormat(" %s %g->%g", Cl38FieldName(i), g_cl[i], g_clIn[i]);
   if(ldDiff)   diff += StringFormat(" GlobalGrid_LocalDistancesPips(effective) [%s]->[%s]", Gg38LdText(g_clLd, g_clLdN), Gg38LdText(g_clLdIn, g_clLdInN));
   if(legacyGl) diff += " GLOBAL_DISTANCE_RULE_OF_AN_OLDER_BUILD (the record has no internal distance list: that build placed the internal levels with G1..G25)";
   if(badGl)    diff += " GLOBAL_DISTANCE_LIST_RECORD_INCOMPLETE";
   g_clFrozenWhy = "CONFIG_CHANGED_MIDCYCLE:" + diff;
   if(r6Mode0) ClWrite();
   R2Warn("CLCHANGED_" + IntegerToString(cyc), StringFormat("CONFIG_CHANGED_MIDCYCLE | cycle %I64d (%d positions) was latched with other inputs:%s -> the cycle keeps its LATCHED configuration, NO new order (no grid level, no new rebase); a committed rebase and in-flight broker requests are reconciled; T1 / T2 / DD / session keep working; the new inputs apply from the next BasketCycleID",
                                                                 cyc, n, diff));
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
   if(ClLdCount() > 0) s += ",LD[" + (g_clHave ? Gg38LdText(g_clLd, g_clLdN) : Gg38LdText(g_clLdIn, g_clLdInN)) + "]";
   return s;
}
void ClPrintCounters(const string when)
{
   PrintFormat("CYCLE LATCH COUNTERS %s | cycles latched %I64d | mid-cycle input changes detected %I64d | frozen grid ticks %I64d | now %s", when, g_clLatched, g_clMismatch, g_clFrozenTicks,
               g_clFrozen ? g_clFrozenWhy : (g_clHave ? "latched" : "no cycle"));
}

#endif
#ifndef OFH38_GRIDLOT_MQH
#define OFH38_GRIDLOT_MQH

#ifndef OFH38_GRIDLOT_CORE_MQH
#define OFH38_GRIDLOT_CORE_MQH

double Gl38LadderLot(const double initLot, const double multi, const int idx, const double step)
{
   double lot = initLot * MathPow(multi, idx - 1);
   const double st = step > 0.0 ? step : 0.01;
   lot = MathCeil(lot / st) * st;
   return NormalizeDouble(lot, 2);
}

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

string g_glLogKeys = "";
long   g_glCapBlocks = 0, g_glMinBlocks = 0, g_glLimitBlocks = 0, g_glMarginBlocks = 0;

void GlLogOnce(const string key, const string text)
{
   const string k = "|" + key + "|";
   if(StringFind(g_glLogKeys, k) >= 0) return;
   g_glLogKeys += k; if(StringLen(g_glLogKeys) > 4000) g_glLogKeys = k;
   R2Warn(key, text);
}

double GlGridLot(const int level) { return CalcLot(level - 1); }

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

void GlPrintCounters(const string when)
{
   PrintFormat("GRIDLOT COUNTERS %s | strict broker limits %s | blocked: above VOLUME_MAX %I64d below min %I64d volume limit %I64d margin %I64d",
               when, GridLot_StrictBrokerLimits ? "ON" : "OFF", g_glCapBlocks, g_glMinBlocks, g_glLimitBlocks, g_glMarginBlocks);
}

#endif
double Exit38EconAfterExit(const double realised, const double floating, const double gross, const double costPerLot) { return realised + floating - gross * MathMax(0.0, costPerLot); }
double g_exCommLot = -1.0; long g_exCommKey = -1;
double Exit38PointValue() { const double ts = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE), tv = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE); return (ts > 0.0) ? tv / ts : 100.0; }
bool g_exCommOk = false;
double Exit38MeasuredCommLot()
{
   g_exCommOk = false;
   if(g_cycStartMsc <= 0) { R2EconUnproven("COMMISSION_CYCLE_START_INVALID", "", g_cycStartMsc, 0); return MathMax(0.0, g_exCommLot); }
   if(!HistorySelect((datetime)(g_cycStartMsc / 1000) - 1, TimeCurrent() + 60)) { R2EconUnproven("COMMISSION_HISTORY_SELECT_FAILED", "", g_cycStartMsc, GetLastError()); return MathMax(0.0, g_exCommLot); }
   g_exCommOk = true;
   const int total = HistoryDealsTotal();
   if(g_exCommKey == total && g_exCommLot >= 0.0) return g_exCommLot;
   double c = 0.0, v = 0.0;
   for(int k = 0; k < total; k++)
   {
      const ulong d = HistoryDealGetTicket(k);
      if(d == 0 || HistoryDealGetString(d, DEAL_SYMBOL) != _Symbol || (ulong)HistoryDealGetInteger(d, DEAL_MAGIC) != Magic) continue;
      if(HistoryDealGetInteger(d, DEAL_ENTRY) != DEAL_ENTRY_IN || HistoryDealGetInteger(d, DEAL_TIME_MSC) < g_cycStartMsc) continue;
      c += HistoryDealGetDouble(d, DEAL_COMMISSION) + HistoryDealGetDouble(d, DEAL_FEE); v += HistoryDealGetDouble(d, DEAL_VOLUME);
   }
   g_exCommKey = total; g_exCommLot = (v > 0.0) ? MathMax(0.0, -c / v) : 0.0;
   return g_exCommLot;
}
double Exit38CostPerLot() { return MathMax(MathMax(0.0, ClGet(CL_COST)), Exit38MeasuredCommLot()) + MathMax(0.0, ClGet(CL_SLIP)) * _Point * Exit38PointValue(); }
double Exit38EconNow(double &re, double &fl, double &net, double &gross, const bool fresh)
{
   if(fresh) { g_r2EconKey = ""; }
   R2CycleEconomic(re, fl);
   double vB = 0.0, vS = 0.0, sB = 0.0, sS = 0.0; BasketVolumeSums(vB, vS, sB, sS);
   net = vB - vS; gross = vB + vS;
   return Exit38EconAfterExit(re, fl, gross, Exit38CostPerLot());
}
bool Exit38EconProven() { return R2CycleEconomicProven() && g_exCommOk; }
double Exit38BePriceOf(const double econ, const double net)
{
   const double minV = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   const double be = Econ38BePrice(econ, net, SymbolInfoDouble(_Symbol, SYMBOL_BID), SymbolInfoDouble(_Symbol, SYMBOL_ASK),
                                   SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE), SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE), (minV > 0.0 ? minV : 0.01) * 0.5);
   return be > 0.0 ? PriceN(be) : 0.0;
}
double Exit38EconBePrice() { double re, fl, net, gross; const double e = Exit38EconNow(re, fl, net, gross, false); return Exit38BePriceOf(e, net); }
double Exit38MarginPerLot() { double m = 0.0; if(!OrderCalcMargin(ORDER_TYPE_BUY, _Symbol, 1.0, SymbolInfoDouble(_Symbol, SYMBOL_ASK), m)) m = 0.0; return m; }
#ifndef OFH38_EXITTREND_MQH
#define OFH38_EXITTREND_MQH

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
double Exit38TrendScore(const int dir, const double emaFast, const double emaSlow, const double atr)
{
   if(atr <= 0.0 || dir == 0) return 0.0;
   return dir * (emaFast - emaSlow) / atr;
}
bool Exit38Strong(const double score, const double strongScore) { return strongScore > 0.0 && score >= strongScore - 1e-12; }
double Exit38Clamp(const double x, const double lo, const double hi) { return MathMax(lo, MathMin(hi, x)); }
double Exit38Want(const int mode, const int dir, const double price, const double be, const double lockSl, const double curExit, const double trailT0,
                  const bool strong, const double mfe, const double floorStart, const double floorKeepPct, const double atr, const double multWeak, const double multStrong,
                  const double minDist, const double maxDist, bool &floorOn, double &floorPx, double &dist)
{
   floorOn = false; floorPx = 0.0; dist = trailT0;
   if(dir == 0) return curExit;
   double want = curExit;
   if(mode == EXIT38_T1_TREND && strong) return curExit;
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
   if(ExitMode() < EXIT38_T1_TREND && Exit_Mode < EXIT_T1_TREND) return;
   g_exEmaF = iMA(_Symbol, tf, MathMax(1, (int)ClGet(CL_EXIT_EF)), 0, MODE_EMA, PRICE_CLOSE);
   g_exEmaS = iMA(_Symbol, tf, MathMax(1, (int)ClGet(CL_EXIT_ES)), 0, MODE_EMA, PRICE_CLOSE);
   g_exAtr  = iATR(_Symbol, tf, MathMax(1, (int)ClGet(CL_EXIT_ATR)));
}
void ExitRelease() { if(g_exEmaF != INVALID_HANDLE) { IndicatorRelease(g_exEmaF); IndicatorRelease(g_exEmaS); IndicatorRelease(g_exAtr); g_exEmaF = g_exEmaS = g_exAtr = INVALID_HANDLE; } }
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
   const bool beyond = hedgeT1Trigger <= 0.0 || (trailDir > 0 ? tick.bid > hedgeT1Trigger + 1e-12 : tick.ask < hedgeT1Trigger - 1e-12);
   const double want = Exit38Want(mode, trailDir, px, hedgeClusterBe, floorSl, hedgeExitPrice, DistTrail(), strong, g_exMfe, floorStart, ClGet(CL_EXIT_FKEEP),
                                  have ? atr : 0.0, ClGet(CL_EXIT_MW), ClGet(CL_EXIT_MS), ClGet(CL_EXIT_TMIN) * PipSize, ClGet(CL_EXIT_TMAX) * PipSize, floorOn, floorPx, dist);
   if(floorOn) { g_exFloorTicks++; if(!g_exFloorWasOn) { g_exFloorWasOn = true; } }
   if(!beyond && !floorOn) return false;
   if(mode == EXIT38_T1_TREND && strong) { g_exDelayed++; return true; }
   const double w = PriceN(want);
   if(w <= 0.0) return false;
   if(!t2Armed)
   {
      t2Armed = true;
      if(t1Locked)
      PrintFormat("RSI6: T2 trail ON %s (%s) | SL %.5f | lock %.5f | trend score %.2f (%s) dist %.2f%s", trailDir > 0 ? "BUY" : "SELL", Exit38Name(mode), w, floorSl, score, strong ? "strong" : "weak", dist,
                  floorOn ? StringFormat(" | profit floor %.5f (MFE %.2f)", floorPx, g_exMfe) : "");
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

bool   O12GlobalLatched() { return ClGet(CL_GG_ON) > 0.5; }
int    O12LatchedK()      { return (int)ClGet(CL_GG_K); }
double O12LatchedD()      { return ClGet(CL_GG_D); }
long g_o12MaxOrdCycles = 0, g_o12SessDefer = 0; long g_o12MaxOrdCycle = 0;

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
string Rsi2PendingText()
{
   string w = "";
   if(g_seRec.st != 0) w += StringFormat("entry request without a broker result (L%d order %I64u); ", g_seRec.cnt, g_seRec.ord);
   if(MrPendingCount() > 0) w += StringFormat("%d manual-recovery record(s) to reconcile; ", MrPendingCount());
   if(MrSurplusInFlight()) w += "surplus close request in flight; ";
   if(DdlActive()) w += "DD lock state " + DdlStateName(g_ddlState) + "; ";
   if(ExActive()) w += "basket exit in progress; ";
   if(PairPendingAny()) w += StringFormat("pending legacy PairClose leg(s) %I64u / %I64u; ", g_pairPend1, g_pairPend2);
   if(g_authOwnerReq) w += "OWNER_REQUIRED: " + g_authOwnerWhy + "; ";
   return w;
}
string Rsi2OpenCycleRecords()
{
   if(!OfhIdReady()) return "";
   string ns[8], nm[8]; int cnt[8]; ArrayInitialize(cnt, 0);
   ns[0] = CycNs(); nm[0] = "cycle state";   ns[1] = ClNs();  nm[1] = "cycle latch";   ns[2] = LbNs();   nm[2] = "level book";   ns[3] = R7LegacyRpaNs(); nm[3] = "R6 RPA (read only)";
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
int Rsi2InitInvalidRsi(const string openRecBeforeRestore)
{
   const bool restored = !v38RestorePending;
   const bool connected = (bool)MQLInfoInteger(MQL_TESTER) || TerminalInfoInteger(TERMINAL_CONNECTED) != 0;
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
   PrintFormat("V38 CONFIG ERROR: RSI_Period must >= 2 (RSI_Period=%d) -> PROTECTIVE_ONLY | %s | EA positions %d, hedge positions %d, working orders %d | to reconcile: %s | no RSI handle, never replaced by 5 | BLOCKED: new L1, grid level (V26 / GLOBAL group), new PairClose pair, any Magic entry order, manual re-entry | RUNS: restore + reconciliation, DD Hedge Lock, T1 / T2 + broker SL / TP, exits / session close, committed closes | flat -> old cycle finalized, stays blocked until the Owner sets RSI_Period >= 2",
               RSI_Period, !restored ? "account not known yet: restore on the first tick with an account (ownership not guessed)" : (connected ? "account known, state restored, connected" : "account known, state restored, terminal NOT connected: the broker lists are not proven"),
               eaPos, hedgePos, wo, pend == "" ? "none" : pend);
   return dec;
}
void Rsi2Blocked(const int act, const string detail)
{
   g_rsiBlk[(act >= 1 && act <= 6) ? act : 0]++;
   const string key = StringFormat("|%d_%I64d|", act, g_cycStartMsc);
   if(StringFind(g_rsiBlkKeys, key) >= 0) return;
   if(StringLen(g_rsiBlkKeys) > 4000) g_rsiBlkKeys = "";
   g_rsiBlkKeys += key;
   PrintFormat("PROTECTIVE_ONLY BLOCKED | %s | %s | RSI_Period=%d < 2 (CONFIG ERROR): no new exposure / structure until the Owner sets RSI_Period >= 2 (the EA re-initialises and restores)", Rsi2ActName(act), detail, RSI_Period);
}
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
   PrintFormat("RSI SAFETY R2 COUNTERS %s | PROTECTIVE_ONLY (RSI_Period=%d) | phase %s, changes %I64d | ticks where the gate stopped: new L1 %I64d, grid level %I64d, new pair %I64d | entry backstop (must stay 0) %I64d",
               when, RSI_Period, Rsi2PhaseName(g_rsiPhase), g_rsiPhaseChanges, g_rsiBlk[RSI2_ACT_NEW_L1], g_rsiBlk[RSI2_ACT_GRID_LEVEL], g_rsiBlk[RSI2_ACT_PAIR_DECISION], g_rsiBlk[RSI2_ACT_ENTRY_ORDER]);
}

struct Su3Hist { bool ok; int deals; int openIds; int openUnlisted; ulong unlisted[8]; long latestOurInMsc; };
bool Su3PosListed(const ulong posId)
{
   for(int i = PositionsTotal() - 1; i >= 0; i--) { const ulong t = PositionGetTicket(i); if(t != 0 && (ulong)PositionGetInteger(POSITION_IDENTIFIER) == posId) return true; }
   return false;
}
void Su3HistoryScan(Su3Hist &h)
{
   h.ok = false; h.deals = 0; h.openIds = 0; h.openUnlisted = 0; h.latestOurInMsc = 0;
   if(!HistorySelect(0, D'2100.01.01')) return;
   h.ok = true; h.deals = HistoryDealsTotal();
   const double eps = Ex38Step() * 0.5;
   ulong id[]; double vol[]; int n = 0;
   for(int i = 0; i < h.deals; i++)
   {
      const ulong d = HistoryDealGetTicket(i);
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
   ns[0] = ClNs();  nm[0] = "cycle latch";   ns[1] = LbNs(); nm[1] = "level book"; ns[2] = R7LegacyRpaNs(); nm[2] = "R6 RPA (read only)";            ns[3] = GgNs(); nm[3] = "GLOBAL groups";
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
   const bool covers = (r.cycStart > 0 && h.latestOurInMsc >= r.cycStart - 60000);
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
bool Su3TryRestore(const string where, const bool force)
{
   if(!v38RestorePending) return true;
   if(!force && TimeCurrent() == g_su3LastEval) return false;
   g_su3LastEval = TimeCurrent();
   const int v = Su3Evaluate(where);
   if(!Su3MayRestore(v)) return false;
   RestoreState();
   if(v38RestorePending) return false;
   if(v == SU3_RESTORE_EXPOSURE) g_su3RestExp++; else g_su3RestFlat++;
   if(where != "INIT") ExitInit();
   PrintFormat("STARTUP SYNC RESTORED | %s (%s) | EA positions %d | BasketCycleID %I64d | the persisted state is restored by the normal restore", Su3Name(v), where, CountPositions(), g_cycStartMsc);
   return true;
}
void Su3PrintCounters(const string when)
{
   PrintFormat("STARTUP SAFETY R3 COUNTERS %s | evaluations %I64d | waits %I64d | OWNER_REQUIRED %I64d | restored with exposure %I64d, flat proven %I64d | last verdict %s | restore pending %d",
               when, g_su3Evals, g_su3Waits, g_su3Owner, g_su3RestExp, g_su3RestFlat, g_su3Verdict < 0 ? "-" : Su3Name(g_su3Verdict), v38RestorePending ? 1 : 0);
}

#define DZ_MAXZ          64
#define DZ_INF           1.0e100
#define DZ_E             1.0e-7
#define DZ_MAXZ_INPUT    50
#define DZ_R7_PHASE1     2
#define DZB_NONE             0
#define DZB_PHASE1_NEW_ZONE  1
#define DZB_PHASE1_ROUND2    2
#define DZB_MAX_ZONES        3
#define DZB_ZONE_FULL        4
#define DZB_R1_PENDING       5
#define DZB_LEDGER_GAP       6
#define DZB_UNPROVEN         7
#define DZB_INTEGRITY        8
#define DZB_CFG_MISMATCH     9
#define DZB_N               10

struct DzZone
{
   int    id;
   int    refId;
   int    dir;
   double priceRef;
   double threshold;
   double lo;
   double hi;
   bool   hasFill;
   double bLo;
   double bHi;
   int    u1;
   int    u2;
   int    r1;
   int    r2;
   long   createdMsc;
   int    createdLevel;
};
struct DzDecision
{
   bool   allow;
   bool   isNew;
   bool   hasB;
   int    zi;
   int    dir;
   int    round;
   int    refId;
   int    why;
   double p;
   double boundary;
   double threshold;
};

DzZone g_dzZ[DZ_MAXZ];
int    g_dzN = 0, g_dzNextId = 1, g_dzLastFillId = 0;
int    g_dzMaxZ = 10, g_dzPer = 3, g_dzRounds = 2, g_dzPolicy = 0, g_dzGapx = 0;
int    g_dzP1 = 3;
double g_dzStep = 2.0;
long   g_dzRollbacks = 0, g_dzVoidKept = 0, g_dzClamped = 0;

double DzR4(const double x)     { return MathRound(x * 10000.0) / 10000.0; }
bool   DzPosInf(const double x) { return x >= DZ_INF * 0.5; }
bool   DzNegInf(const double x) { return x <= -DZ_INF * 0.5; }
bool   DzFR()                   { return g_dzPolicy != DZ_POLICY_MR; }
string DzPolicyName(const int p) { return p == DZ_POLICY_FRM ? "FRM" : (p == DZ_POLICY_FRT ? "FRT" : (p == DZ_POLICY_MR ? "MR" : "?")); }
string DzGapxName(const int g)   { return g == DZ_GAPX_FILL ? "FILL" : (g == DZ_GAPX_CLAMP ? "CLAMP" : "?"); }
string DzEdge(const double x)    { return DzNegInf(x) ? "-inf" : (DzPosInf(x) ? "+inf" : DoubleToString(x, 2)); }
string DzDirName(const int d)    { return d == 0 ? "L1" : (d == 2 ? "INTERIOR" : (d > 0 ? "UP" : "DOWN")); }
bool   DzPhase1Reason(const int w) { return w == DZB_PHASE1_NEW_ZONE || w == DZB_PHASE1_ROUND2; }
string DzBlockName(const int w)
{
   switch(w)
   {
      case DZB_PHASE1_NEW_ZONE: return "PHASE1_ZONE_BLOCKED_NEW_ZONE";
      case DZB_PHASE1_ROUND2:   return "PHASE1_ZONE_BLOCKED_ROUND2_LOCKED";
      case DZB_MAX_ZONES:       return "ZONE_BLOCKED_MAX_ZONES";
      case DZB_ZONE_FULL:       return "ZONE_BLOCKED_ZONE_FULL";
      case DZB_R1_PENDING:      return "ZONE_BLOCKED_ROUND1_PENDING";
      case DZB_LEDGER_GAP:      return "ZONE_BLOCKED_LEDGER_GAP";
      case DZB_UNPROVEN:        return "ZONE_BLOCKED_LEDGER_UNPROVEN";
      case DZB_INTEGRITY:       return "ZONE_BLOCKED_INTEGRITY";
      case DZB_CFG_MISMATCH:    return "ZONE_BLOCKED_CONFIG_MISMATCH";
   }
   return "NONE";
}
void DzZoneClear(DzZone &z)
{
   z.id = 0; z.refId = 0; z.dir = 0; z.priceRef = 0.0; z.threshold = 0.0; z.lo = 0.0; z.hi = 0.0; z.hasFill = false;
   z.bLo = -DZ_INF; z.bHi = DZ_INF; z.u1 = 0; z.u2 = 0; z.r1 = 0; z.r2 = 0; z.createdMsc = 0; z.createdLevel = 0;
}
void DzDecInit(DzDecision &d, const double p)
{
   d.allow = false; d.isNew = false; d.hasB = false; d.zi = -1; d.dir = 0; d.round = 1; d.refId = 0; d.why = DZB_NONE; d.p = p; d.boundary = 0.0; d.threshold = 0.0;
}
void DzCoreReset(const int maxZ, const int p1, const int per, const int rounds, const double step, const int policy, const int gapx)
{
   for(int i = 0; i < DZ_MAXZ; i++) DzZoneClear(g_dzZ[i]);
   g_dzN = 0; g_dzNextId = 1; g_dzLastFillId = 0;
   g_dzMaxZ = maxZ; g_dzP1 = p1; g_dzPer = per; g_dzRounds = rounds; g_dzStep = step; g_dzPolicy = policy; g_dzGapx = gapx;
}
string DzCfgError(const int maxZ, const int p1, const int per, const int rounds, const double step, const int policy, const int gapx)
{
   if(maxZ < 1 || maxZ > DZ_MAXZ_INPUT) return StringFormat("MaxZones=%d must be 1..%d", maxZ, DZ_MAXZ_INPUT);
   if(p1 < 1 || p1 > maxZ) return StringFormat("Zone_Phase1UnlockZones=%d must be 1..MaxZones (%d): it is the COUNT of initial zones V1..VN that must each complete round 1 before Phase 2, not a zone number", p1, maxZ);
   if(!MathIsValidNumber(step) || !(step > 0.0) || step > 1000.0) return StringFormat("ZoneStepUSD=%s must be a finite number in (0, 1000] USD of price", DoubleToString(step, 4));
   if(per < 1 || per > 20) return StringFormat("OrdersPerZonePerRound=%d must be 1..20", per);
   if(rounds < 1 || rounds > 2) return StringFormat("MaxRoundsPerZone=%d must be 1..2 (Owner R6: no round 3)", rounds);
   if(policy < 0 || policy > 2) return StringFormat("DynamicZone_ResearchPolicy=%d must be 0 (FRM), 1 (FRT) or 2 (MR)", policy);
   if(gapx < 0 || gapx > 1) return StringFormat("DynamicZone_ResearchGapExtrema=%d must be 0 (FILL) or 1 (CLAMP)", gapx);
   return "";
}
string DzCfgDiff(const bool on, const int maxZ, const int p1, const int per, const int rounds, const double step, const int policy, const int gapx)
{
   string s = "";
   if(!on) s += " EnableDynamicZone true->false";
   if(p1 != g_dzP1) s += StringFormat(" Zone_Phase1UnlockZones %d->%d", g_dzP1, p1);
   if(maxZ != g_dzMaxZ) s += StringFormat(" MaxZones %d->%d", g_dzMaxZ, maxZ);
   if(per != g_dzPer) s += StringFormat(" OrdersPerZonePerRound %d->%d", g_dzPer, per);
   if(rounds != g_dzRounds) s += StringFormat(" MaxRoundsPerZone %d->%d", g_dzRounds, rounds);
   if(!(MathAbs(step - g_dzStep) <= 1e-9 * MathMax(1.0, MathAbs(g_dzStep)))) s += StringFormat(" ZoneStepUSD %.4f->%.4f", g_dzStep, step);
   if(policy != g_dzPolicy) s += StringFormat(" DynamicZone_ResearchPolicy %d->%d", g_dzPolicy, policy);
   if(gapx != g_dzGapx) s += StringFormat(" DynamicZone_ResearchGapExtrema %d->%d", g_dzGapx, gapx);
   return s;
}
int    DzIdx(const int id) { for(int i = 0; i < g_dzN; i++) if(g_dzZ[i].id == id) return i; return -1; }
int    DzTop()             { for(int i = 0; i < g_dzN; i++) if(DzPosInf(g_dzZ[i].bHi)) return i; return -1; }
int    DzBottom()          { for(int i = 0; i < g_dzN; i++) if(DzNegInf(g_dzZ[i].bLo)) return i; return -1; }
double DzDist(const int i, const double p) { return p > g_dzZ[i].hi ? p - g_dzZ[i].hi : (p < g_dzZ[i].lo ? g_dzZ[i].lo - p : 0.0); }
int    DzConfirmedTotal()  { int s = 0; for(int i = 0; i < g_dzN; i++) s += g_dzZ[i].u1 + g_dzZ[i].u2; return s; }
int    DzRound2Total()     { int s = 0; for(int i = 0; i < g_dzN; i++) s += g_dzZ[i].u2; return s; }
bool   DzPhase2()
{
   if(g_dzP1 < 1 || g_dzN < g_dzP1) return false;
   for(int i = 0; i < g_dzP1; i++) if(g_dzZ[i].u1 < g_dzPer) return false;
   return true;
}
string DzPhase1Text()
{
   string s = ""; int c = 0;
   for(int i = 0; i < g_dzP1; i++)
   {
      const int u = i < g_dzN ? g_dzZ[i].u1 : 0; c += MathMin(u, g_dzPer);
      s += StringFormat("%sV%d %d/%d", i > 0 ? ", " : "", i + 1, u, g_dzPer);
   }
   return StringFormat("%s (%d of %d confirmed)", s, c, g_dzP1 * g_dzPer);
}
int DzLocateFR(const double p, DzDecision &d)
{
   const int top = DzTop(), bot = DzBottom();
   if(top < 0 || bot < 0) return -2;
   const double fUp = DzR4(g_dzZ[top].hi + g_dzStep), fDn = DzR4(g_dzZ[bot].lo - g_dzStep);
   if(p >= fUp - DZ_E) { d.dir = 1;  d.hasB = true; d.boundary = (g_dzPolicy == DZ_POLICY_FRT) ? fUp : DzR4((g_dzZ[top].hi + p) / 2.0); d.threshold = fUp; d.refId = g_dzZ[top].id; return -1; }
   if(p <= fDn + DZ_E) { d.dir = -1; d.hasB = true; d.boundary = (g_dzPolicy == DZ_POLICY_FRT) ? fDn : DzR4((g_dzZ[bot].lo + p) / 2.0); d.threshold = fDn; d.refId = g_dzZ[bot].id; return -1; }
   for(int i = 0; i < g_dzN; i++) if(p >= g_dzZ[i].bLo - DZ_E && p < g_dzZ[i].bHi - DZ_E) return i;
   return -2;
}
bool DzCrosses(const int rf, const double p)
{
   for(int y = 0; y < g_dzN; y++)
   {
      if(y == rf) continue;
      if(p > g_dzZ[rf].hi && g_dzZ[y].lo > g_dzZ[rf].hi && g_dzZ[y].hi < p) return true;
      if(p < g_dzZ[rf].lo && g_dzZ[y].hi < g_dzZ[rf].lo && g_dzZ[y].lo > p) return true;
   }
   return false;
}
int DzLocateMR(const double p, DzDecision &d)
{
   int rf = DzIdx(g_dzLastFillId); if(rf < 0) rf = g_dzN - 1;
   int inside = -1;
   for(int i = 0; i < g_dzN; i++) if(p >= g_dzZ[i].lo - DZ_E && p <= g_dzZ[i].hi + DZ_E) { if(inside < 0 || i == rf) inside = i; }
   if(inside >= 0) return inside;
   int best = -1; double bd = DBL_MAX; bool refOk = false;
   for(int i = 0; i < g_dzN; i++)
   {
      const double ds = DzDist(i, p);
      if(ds < g_dzStep - DZ_E) { if(i == rf && !DzCrosses(rf, p)) refOk = true; if(ds < bd - DZ_E) { bd = ds; best = i; } }
   }
   if(refOk) return rf;
   if(best >= 0) return best;
   d.dir = p > g_dzZ[rf].hi ? 1 : -1; d.refId = g_dzZ[rf].id; d.threshold = d.dir > 0 ? DzR4(g_dzZ[rf].hi + g_dzStep) : DzR4(g_dzZ[rf].lo - g_dzStep);
   return -1;
}
int DzWhereId(const double p)
{
   if(g_dzN <= 0) return 0;
   DzDecision d; DzDecInit(d, p);
   const int zi = DzFR() ? DzLocateFR(p, d) : DzLocateMR(p, d);
   if(zi == -2) return -1;
   return zi >= 0 ? g_dzZ[zi].id : 0;
}
void DzClassify(const double p, DzDecision &d)
{
   DzDecInit(d, p);
   if(g_dzN <= 0) { d.isNew = true; d.allow = true; d.round = 1; d.dir = 0; return; }
   const int zi = DzFR() ? DzLocateFR(p, d) : DzLocateMR(p, d);
   if(zi == -2) { d.why = DZB_LEDGER_GAP; return; }
   const bool p2 = DzPhase2();
   if(zi < 0)
   {
      if(!p2 && g_dzN >= g_dzP1) { d.why = DZB_PHASE1_NEW_ZONE; return; }
      if(g_dzN >= g_dzMaxZ || g_dzN >= DZ_MAXZ) { d.why = DZB_MAX_ZONES; return; }
      if(DzFR() && d.hasB)
      {
         const int rz = d.dir > 0 ? DzTop() : DzBottom();
         if(rz < 0 || (d.dir > 0 ? !(d.boundary > g_dzZ[rz].bLo + DZ_E) : !(d.boundary < g_dzZ[rz].bHi - DZ_E))) { d.why = DZB_INTEGRITY; return; }
      }
      d.isNew = true; d.allow = true; d.round = 1; return;
   }
   d.zi = zi;
   if(g_dzZ[zi].u1 + g_dzZ[zi].r1 < g_dzPer) { d.allow = true; d.round = 1; return; }
   if(g_dzRounds >= 2)
   {
      if(g_dzZ[zi].u1 < g_dzPer) { d.why = DZB_R1_PENDING; return; }
      if(!p2) { d.why = DZB_PHASE1_ROUND2; return; }
      if(g_dzZ[zi].u2 + g_dzZ[zi].r2 < g_dzPer) { d.allow = true; d.round = 2; return; }
   }
   d.why = DZB_ZONE_FULL;
}
int DzCommit(const DzDecision &d, const long msc, const int level)
{
   if(!d.allow) return -1;
   if(d.isNew)
   {
      if(g_dzN >= DZ_MAXZ || g_dzN >= g_dzMaxZ) return -1;
      const int i = g_dzN;
      DzZoneClear(g_dzZ[i]);
      g_dzZ[i].id = g_dzNextId; g_dzZ[i].refId = d.refId; g_dzZ[i].priceRef = d.p; g_dzZ[i].threshold = d.threshold;
      g_dzZ[i].lo = d.p; g_dzZ[i].hi = d.p; g_dzZ[i].hasFill = false; g_dzZ[i].createdMsc = msc; g_dzZ[i].createdLevel = level;
      if(g_dzN == 0) g_dzZ[i].dir = 0;
      else
      {
         bool above = false, below = false;
         for(int k = 0; k < g_dzN; k++) { if(g_dzZ[k].lo > d.p) above = true; if(g_dzZ[k].hi < d.p) below = true; }
         g_dzZ[i].dir = (above && below) ? 2 : d.dir;
      }
      if(DzFR() && g_dzN > 0 && d.hasB)
      {
         if(d.dir > 0) { const int top = DzTop(); if(top < 0) return -1; g_dzZ[top].bHi = d.boundary; g_dzZ[i].bLo = d.boundary; }
         else          { const int bot = DzBottom(); if(bot < 0) return -1; g_dzZ[bot].bLo = d.boundary; g_dzZ[i].bHi = d.boundary; }
      }
      g_dzNextId++; g_dzN++;
      g_dzZ[i].r1++;
      return i;
   }
   if(d.zi < 0 || d.zi >= g_dzN) return -1;
   if(d.round == 2) g_dzZ[d.zi].r2++; else g_dzZ[d.zi].r1++;
   return d.zi;
}
bool DzConfirm(const int zi, const int round, const double px)
{
   if(round == 2) { g_dzZ[zi].r2--; g_dzZ[zi].u2++; } else { g_dzZ[zi].r1--; g_dzZ[zi].u1++; }
   double ex = px;
   if(DzFR() && g_dzGapx == DZ_GAPX_CLAMP) { if(px < g_dzZ[zi].bLo) ex = g_dzZ[zi].bLo; else if(px > g_dzZ[zi].bHi) ex = g_dzZ[zi].bHi; if(ex != px) g_dzClamped++; }
   if(!g_dzZ[zi].hasFill) { g_dzZ[zi].lo = ex; g_dzZ[zi].hi = ex; g_dzZ[zi].hasFill = true; }
   else { if(ex < g_dzZ[zi].lo) g_dzZ[zi].lo = ex; if(ex > g_dzZ[zi].hi) g_dzZ[zi].hi = ex; }
   g_dzLastFillId = g_dzZ[zi].id;
   return DzFR() && (px < g_dzZ[zi].bLo - DZ_E || px > g_dzZ[zi].bHi + DZ_E);
}
void DzRelease(const int zi, const int round)
{
   if(zi < 0 || zi >= g_dzN) return;
   if(round == 2) g_dzZ[zi].r2--; else g_dzZ[zi].r1--;
   if(g_dzZ[zi].hasFill || g_dzZ[zi].u1 + g_dzZ[zi].u2 + g_dzZ[zi].r1 + g_dzZ[zi].r2 != 0) return;
   if(zi != g_dzN - 1) { g_dzVoidKept++; return; }
   if(g_dzN == 1) { DzZoneClear(g_dzZ[0]); g_dzN = 0; g_dzNextId = 1; g_dzLastFillId = 0; g_dzRollbacks++; return; }
   if(DzFR())
   {
      if(DzPosInf(g_dzZ[zi].bHi) && !DzNegInf(g_dzZ[zi].bLo)) { for(int k = 0; k < g_dzN; k++) if(k != zi && MathAbs(g_dzZ[k].bHi - g_dzZ[zi].bLo) < DZ_E) g_dzZ[k].bHi = DZ_INF; }
      else if(DzNegInf(g_dzZ[zi].bLo) && !DzPosInf(g_dzZ[zi].bHi)) { for(int k = 0; k < g_dzN; k++) if(k != zi && MathAbs(g_dzZ[k].bLo - g_dzZ[zi].bHi) < DZ_E) g_dzZ[k].bLo = -DZ_INF; }
      else { g_dzVoidKept++; return; }
   }
   DzZoneClear(g_dzZ[zi]); g_dzN--; g_dzNextId--; g_dzRollbacks++;
}
string DzCheck()
{
   if(g_dzN > g_dzMaxZ) return StringFormat("zones %d > MaxZones %d", g_dzN, g_dzMaxZ);
   if(g_dzP1 < 1 || g_dzP1 > g_dzMaxZ) return StringFormat("Phase 1 zone count %d outside 1..MaxZones %d", g_dzP1, g_dzMaxZ);
   const bool p2 = DzPhase2();
   if(!p2 && g_dzN > g_dzP1) return StringFormat("%d zones before Phase 2 (V1..V%d not each %d confirmed)", g_dzN, g_dzP1, g_dzPer);
   const int cap2 = g_dzRounds >= 2 ? g_dzPer : 0;
   for(int i = 0; i < g_dzN; i++)
   {
      if(g_dzZ[i].id != i + 1) return StringFormat("zone ids not in creation order (position %d holds V%d)", i + 1, g_dzZ[i].id);
      if(g_dzZ[i].r1 < 0 || g_dzZ[i].r2 < 0) return StringFormat("zone V%d negative reservation", g_dzZ[i].id);
      if(g_dzZ[i].u1 + g_dzZ[i].r1 > g_dzPer) return StringFormat("zone V%d round 1 %d + %d reserved > %d", g_dzZ[i].id, g_dzZ[i].u1, g_dzZ[i].r1, g_dzPer);
      if(g_dzZ[i].u2 + g_dzZ[i].r2 > cap2) return StringFormat("zone V%d round 2 %d + %d reserved > %d", g_dzZ[i].id, g_dzZ[i].u2, g_dzZ[i].r2, cap2);
      if(g_dzZ[i].u2 + g_dzZ[i].r2 > 0 && g_dzZ[i].u1 < g_dzPer) return StringFormat("zone V%d round 2 before its own round 1 is confirmed (%d/%d)", g_dzZ[i].id, g_dzZ[i].u1, g_dzPer);
      if(g_dzZ[i].u2 + g_dzZ[i].r2 > 0 && !p2) return StringFormat("zone V%d round 2 before Phase 2", g_dzZ[i].id);
   }
   if(DzFR() && g_dzN > 0)
   {
      int s[]; ArrayResize(s, g_dzN);
      for(int i = 0; i < g_dzN; i++) s[i] = i;
      for(int i = 1; i < g_dzN; i++) { const int v = s[i]; int j = i - 1; while(j >= 0 && g_dzZ[s[j]].bLo > g_dzZ[v].bLo) { s[j + 1] = s[j]; j--; } s[j + 1] = v; }
      if(!DzNegInf(g_dzZ[s[0]].bLo) || !DzPosInf(g_dzZ[s[g_dzN - 1]].bHi)) return "FR partition: open ends missing";
      for(int i = 0; i < g_dzN; i++)
      {
         if(!(g_dzZ[s[i]].bLo < g_dzZ[s[i]].bHi)) return StringFormat("FR partition: zone V%d empty interval", g_dzZ[s[i]].id);
         if(i + 1 < g_dzN && MathAbs(g_dzZ[s[i]].bHi - g_dzZ[s[i + 1]].bLo) > DZ_E) return StringFormat("FR partition: gap / overlap between V%d and V%d", g_dzZ[s[i]].id, g_dzZ[s[i + 1]].id);
      }
   }
   return "";
}
string DzRestoreVerdict(const ulong &open[], const int nOpen, const ulong &conf[], const int nConf, const ulong &pend[], const int nPend, const int pendNoTicket)
{
   if(nOpen <= 0) return "";
   int unmatched = 0, matched = 0;
   for(int i = 0; i < nOpen; i++)
   {
      bool m = false;
      for(int k = 0; k < nConf && !m; k++) if(conf[k] == open[i]) m = true;
      for(int k = 0; k < nPend && !m; k++) if(pend[k] != 0 && pend[k] == open[i]) m = true;
      if(m) matched++; else unmatched++;
   }
   if(unmatched == 0) return "";
   if(unmatched == 1 && pendNoTicket > 0) return "";
   return StringFormat("%d of %d open position(s) not in the zone ledger (%d matched)", unmatched, nOpen, matched);
}

#define DZ_VERSION     3
#define DZ_VERSION_R7  2
#define DZA_RESERVED   1
#define DZA_PENDING    2
#define DZA_CONFIRMED  3

struct DzAdm
{
   ulong  order;
   ulong  posId;
   int    zoneId;
   int    round;
   int    level;
   int    side;
   double candPx;
   double fillPx;
   double lot;
   long   decMsc;
   long   cfmMsc;
   ulong  wm;
   int    st;
   bool   gap;
};
DzAdm      g_dzA[];
int        g_dzAN = 0;
bool       g_dzOn = false, g_dzUnproven = false, g_dzBad = false, g_dzLoaded = false;
string     g_dzBadWhy = "", g_dzUnprovenWhy = "";
ulong      g_dzL1Order = 0;
long       g_dzStartMsc = 0;
DzDecision g_dzDec;
bool       g_dzDecOk = false;
int        g_dzDecLevel = 0, g_dzDecSide = 0;
int        g_dzStLevel = 0, g_dzStWhy = 0;
long       g_dzStMsc = 0, g_dzStTicks = 0;
bool       g_dzStPhase1 = false;
long       g_dzBlkTicks[DZB_N], g_dzBlkCands[DZB_N];
long       g_dzLedgers = 0, g_dzAdmits = 0, g_dzCreates = 0, g_dzConfirms = 0, g_dzReleases = 0, g_dzPendings = 0, g_dzGapEvents = 0, g_dzPhase2Count = 0;
long       g_dzStallEpisodes = 0, g_dzPhase1Stalls = 0, g_dzRestored = 0, g_dzRestoreUnproven = 0, g_dzIntegrityFails = 0, g_dzMaxConfirmed = 0, g_dzMaxZonesSeen = 0, g_dzR2Admits = 0;
long       g_dzBkBlkCands = 0, g_dzBkPhase1Stalls = 0, g_dzBkGap = 0, g_dzBkPhase2Msc = 0;
int        g_dzBkPhase2Entries = 0;
string     g_dzOnce = "";
long       g_dzL1RelMin = -1, g_dzL1Quiet = 0, g_dzBaskets = 0, g_dzSkipNoSend = 0;
bool       g_dzQuiet = false;
bool       g_dzCfgMismatch = false;
string     g_dzCfgWhy = "";
long       g_dzCfgMismatches = 0, g_dzR7Migrated = 0;

string DzNs() { return OfhNs("OFH38V", Magic); }
void   DzLogOnce(const string key, const string text) { const string k = "|" + key + "|"; if(StringFind(g_dzOnce, k) >= 0) return; g_dzOnce += k; if(StringLen(g_dzOnce) > 4000) g_dzOnce = k; Print(text); }
bool   DzUnresolvedAny() { for(int a = 0; a < g_dzAN; a++) if(g_dzA[a].st == DZA_RESERVED || g_dzA[a].st == DZA_PENDING) return true; return false; }
bool   DzPosLinked(const ulong pid) { if(pid == 0) return false; for(int a = 0; a < g_dzAN; a++) if(g_dzA[a].st == DZA_CONFIRMED && g_dzA[a].posId == pid) return true; return false; }
string DzLedgerText()
{
   string s = "";
   for(int i = 0; i < g_dzN; i++)
   {
      const int res = g_dzZ[i].r1 + g_dzZ[i].r2;
      s += StringFormat("%sV%d:%d+%d%s", i > 0 ? " " : "", g_dzZ[i].id, g_dzZ[i].u1, g_dzZ[i].u2, res > 0 ? StringFormat("(+%d res)", res) : "");
   }
   return s == "" ? "empty" : s;
}
string DzZoneText(const int i)
{
   if(i < 0 || i >= g_dzN) return "?";
   return StringFormat("V%d %s ref %s | created by L%d @%.2f%s | confirmed hi %.2f lo %.2f | fixed edges [%s, %s) | R1 %d/%d R2 %d/%d reserved %d",
                       g_dzZ[i].id, DzDirName(g_dzZ[i].dir), g_dzZ[i].refId > 0 ? "V" + IntegerToString(g_dzZ[i].refId) : "-", g_dzZ[i].createdLevel, g_dzZ[i].priceRef,
                       g_dzZ[i].threshold != 0.0 ? StringFormat(" (threshold %.2f)", g_dzZ[i].threshold) : "", g_dzZ[i].hi, g_dzZ[i].lo,
                       DzFR() ? DzEdge(g_dzZ[i].bLo) : "n/a", DzFR() ? DzEdge(g_dzZ[i].bHi) : "n/a",
                       g_dzZ[i].u1, g_dzPer, g_dzZ[i].u2, g_dzRounds >= 2 ? g_dzPer : 0, g_dzZ[i].r1 + g_dzZ[i].r2);
}
string DzCfgText()
{
   return StringFormat("MaxZones %d, Phase 1 zones N %d (Phase 2 when EACH of V1..V%d holds %d confirmed round-1 entries = %d), ZoneStepUSD %.2f, OrdersPerZonePerRound %d, MaxRoundsPerZone %d (lifetime ceiling %d confirmed admissions), research policy %s, gap extrema %s",
                       g_dzMaxZ, g_dzP1, g_dzP1, g_dzPer, g_dzP1 * g_dzPer, g_dzStep, g_dzPer, g_dzRounds, g_dzMaxZ * g_dzPer * g_dzRounds, DzPolicyName(g_dzPolicy), DzGapxName(g_dzGapx));
}

string DzInputsError()
{
   if(!EnableDynamicZone) return "";
   if(Entry_Strategy != OFH38_ENTRY_GLOBAL) return "EnableDynamicZone=true needs Entry_Strategy=1 (GLOBAL Grid Mode 1): the zone layer only admits GLOBAL candidates";
   return DzCfgError(MaxZones, Zone_Phase1UnlockZones, OrdersPerZonePerRound, MaxRoundsPerZone, ZoneStepUSD, (int)DynamicZone_ResearchPolicy, (int)DynamicZone_ResearchGapExtrema);
}
void DzInitLog()
{
   if(!EnableDynamicZone)
   {
      Print("DZ R6 | EnableDynamicZone=false: zone layer OFF - no zone code on any decision path (R3 behaviour)");
      const string offErr = DzCfgError(MaxZones, Zone_Phase1UnlockZones, OrdersPerZonePerRound, MaxRoundsPerZone, ZoneStepUSD, (int)DynamicZone_ResearchPolicy, (int)DynamicZone_ResearchGapExtrema);
      if(offErr != "") PrintFormat("DZ R8 WARNING | zone inputs are not valid (%s): ignored while EnableDynamicZone=false, the EA would refuse to start with EnableDynamicZone=true", offErr);
      return;
   }
   PrintFormat("DZ R8 RESEARCH CANDIDATE | OWNER_PASS=PENDING LIVE_AUTHORIZED=NO PRODUCTION_READY=NO | inputs: MaxZones %d, Zone_Phase1UnlockZones %d (Phase 2 when EACH of V1..V%d holds %d broker-confirmed round-1 entries = %d; new zones from V%d), ZoneStepUSD %.2f, OrdersPerZonePerRound %d, MaxRoundsPerZone %d (lifetime ceiling %d), policy %s (RESEARCH, not Owner-approved), gap extrema %s (RESEARCH) | latched per basket at the L1 | Max_Orders %d (open positions, unchanged meaning) | GLOBAL K %d, D %.2f unchanged",
               MaxZones, Zone_Phase1UnlockZones, Zone_Phase1UnlockZones, OrdersPerZonePerRound, Zone_Phase1UnlockZones * OrdersPerZonePerRound, Zone_Phase1UnlockZones + 1,
               ZoneStepUSD, OrdersPerZonePerRound, MaxRoundsPerZone, MaxZones * OrdersPerZonePerRound * MaxRoundsPerZone, DzPolicyName((int)DynamicZone_ResearchPolicy),
               DzGapxName((int)DynamicZone_ResearchGapExtrema), Max_Orders, GlobalGrid_OrdersPerGroup, GlobalGrid_BreakoutDistanceUSD);
   if(Zone_Phase1UnlockZones >= MaxZones)
      PrintFormat("DZ R8 NOTE | Zone_Phase1UnlockZones %d = MaxZones %d: no new zone ID is left for Phase 2 -> Phase 2 = %s", Zone_Phase1UnlockZones, MaxZones,
                  MaxRoundsPerZone >= 2 ? "round 2 of V1..VN only" : "NO admission path (MaxRoundsPerZone 1: no round 2) - after Phase 1 every GLOBAL candidate of the basket is ZONE_BLOCKED, exits keep working");
   if(Max_Orders < Zone_Phase1UnlockZones * OrdersPerZonePerRound)
      PrintFormat("DZ R8 NOTE | Max_Orders %d (open positions) < Zone_Phase1UnlockZones x OrdersPerZonePerRound = %d: Phase 1 can complete only after some positions of the basket are closed (e.g. V26 PairClose); the confirmed zone quota is never given back",
                  Max_Orders, Zone_Phase1UnlockZones * OrdersPerZonePerRound);
   PrintFormat("DZ R6 SYMBOL | %s VOLUME_MIN %.2f STEP %.2f MAX %.2f LIMIT %.2f | contract %.2f | digits %d | account currency %s leverage 1:%I64d | margin mode %I64d | stop-out %.1f (mode %I64d)",
               _Symbol, SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN), SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP), SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX), SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_LIMIT),
               SymbolInfoDouble(_Symbol, SYMBOL_TRADE_CONTRACT_SIZE), _Digits, AccountInfoString(ACCOUNT_CURRENCY), AccountInfoInteger(ACCOUNT_LEVERAGE), AccountInfoInteger(ACCOUNT_MARGIN_MODE),
               AccountInfoDouble(ACCOUNT_MARGIN_SO_SO), AccountInfoInteger(ACCOUNT_MARGIN_SO_MODE));
}

void DzRamClear()
{
   DzCoreReset(MaxZones, Zone_Phase1UnlockZones, OrdersPerZonePerRound, MaxRoundsPerZone, ZoneStepUSD, (int)DynamicZone_ResearchPolicy, (int)DynamicZone_ResearchGapExtrema);
   g_dzAN = 0; ArrayResize(g_dzA, 0);
   g_dzOn = false; g_dzUnproven = false; g_dzBad = false; g_dzBadWhy = ""; g_dzUnprovenWhy = "";
   g_dzCfgMismatch = false; g_dzCfgWhy = "";
   g_dzL1Order = 0; g_dzStartMsc = 0; g_dzDecOk = false; g_dzDecLevel = 0; g_dzDecSide = 0;
   g_dzStLevel = 0; g_dzStWhy = 0; g_dzStMsc = 0; g_dzStTicks = 0; g_dzStPhase1 = false;
   g_dzBkBlkCands = 0; g_dzBkPhase1Stalls = 0; g_dzBkGap = 0; g_dzBkPhase2Msc = 0; g_dzBkPhase2Entries = 0;
}
void DzPersist()
{
   const string ns = DzNs();
   GlobalVariablesDeleteAll(ns);
   if(!g_dzOn && g_dzAN == 0 && g_dzN == 0) { GlobalVariablesFlush(); return; }
   GlobalVariableSet(ns + "v", DZ_VERSION);
   GlobalVariableSet(ns + "mz", g_dzMaxZ); GlobalVariableSet(ns + "pz", g_dzPer); GlobalVariableSet(ns + "rd", g_dzRounds); GlobalVariableSet(ns + "sp", g_dzStep);
   GlobalVariableSet(ns + "po", g_dzPolicy); GlobalVariableSet(ns + "gx", g_dzGapx);
   GlobalVariableSet(ns + "p1", g_dzP1);
   GlobalVariableSet(ns + "n", g_dzN); GlobalVariableSet(ns + "ni", g_dzNextId); GlobalVariableSet(ns + "lf", g_dzLastFillId);
   GlobalVariableSet(ns + "bad", g_dzBad ? 1 : 0); GlobalVariableSet(ns + "l1", (double)g_dzL1Order); GlobalVariableSet(ns + "sm", (double)g_dzStartMsc);
   GlobalVariableSet(ns + "p2m", (double)g_dzBkPhase2Msc); GlobalVariableSet(ns + "p2e", g_dzBkPhase2Entries);
   for(int i = 0; i < g_dzN; i++)
   {
      const string p = ns + "z" + IntegerToString(i);
      GlobalVariableSet(p + "id", g_dzZ[i].id); GlobalVariableSet(p + "rf", g_dzZ[i].refId); GlobalVariableSet(p + "dr", g_dzZ[i].dir);
      GlobalVariableSet(p + "pr", g_dzZ[i].priceRef); GlobalVariableSet(p + "th", g_dzZ[i].threshold); GlobalVariableSet(p + "lo", g_dzZ[i].lo); GlobalVariableSet(p + "hi", g_dzZ[i].hi);
      GlobalVariableSet(p + "hf", g_dzZ[i].hasFill ? 1 : 0); GlobalVariableSet(p + "bl", g_dzZ[i].bLo); GlobalVariableSet(p + "bh", g_dzZ[i].bHi);
      GlobalVariableSet(p + "u1", g_dzZ[i].u1); GlobalVariableSet(p + "u2", g_dzZ[i].u2); GlobalVariableSet(p + "r1", g_dzZ[i].r1); GlobalVariableSet(p + "r2", g_dzZ[i].r2);
      GlobalVariableSet(p + "cm", (double)g_dzZ[i].createdMsc); GlobalVariableSet(p + "cl", g_dzZ[i].createdLevel);
   }
   GlobalVariableSet(ns + "an", g_dzAN);
   for(int a = 0; a < g_dzAN; a++)
   {
      const string p = ns + "a" + IntegerToString(a);
      GlobalVariableSet(p + "or", (double)g_dzA[a].order); GlobalVariableSet(p + "pi", (double)g_dzA[a].posId); GlobalVariableSet(p + "zn", g_dzA[a].zoneId);
      GlobalVariableSet(p + "rd", g_dzA[a].round); GlobalVariableSet(p + "lv", g_dzA[a].level); GlobalVariableSet(p + "sd", g_dzA[a].side);
      GlobalVariableSet(p + "cp", g_dzA[a].candPx); GlobalVariableSet(p + "fp", g_dzA[a].fillPx); GlobalVariableSet(p + "lt", g_dzA[a].lot);
      GlobalVariableSet(p + "dm", (double)g_dzA[a].decMsc); GlobalVariableSet(p + "cf", (double)g_dzA[a].cfmMsc); GlobalVariableSet(p + "wm", (double)g_dzA[a].wm);
      GlobalVariableSet(p + "st", g_dzA[a].st); GlobalVariableSet(p + "gp", g_dzA[a].gap ? 1 : 0);
   }
   OfhIdStore(ns, Magic);
   GlobalVariableSet(ns + "on", 1);
   GlobalVariablesFlush();
}
void DzClearPersist() { if(GlobalVariablesDeleteAll(DzNs()) > 0) GlobalVariablesFlush(); }
double DzGv(const string k) { return GlobalVariableGet(k); }
bool DzLoad(const string ns, string &why)
{
   why = "";
   if(!GlobalVariableCheck(ns + "on")) { why = GlobalVariableCheck(ns + "v") ? "INCOMPLETE" : "NO_RECORD"; return false; }
   const string idc = OfhIdCheck(ns, Magic);
   if(idc != "") { why = "IDENTITY_" + idc; return false; }
   const int ver = (int)DzGv(ns + "v");
   if(ver != DZ_VERSION && ver != DZ_VERSION_R7) { why = "VERSION"; return false; }
   const int n = (int)DzGv(ns + "n"), an = (int)DzGv(ns + "an");
   if(n < 0 || n > DZ_MAXZ || an < 0 || an > 100000) { why = "COUNTS"; return false; }
   int p1 = DZ_R7_PHASE1;
   if(ver == DZ_VERSION) { if(!GlobalVariableCheck(ns + "p1")) { why = "P1_MISSING"; return false; } p1 = (int)DzGv(ns + "p1"); }
   const string ce = DzCfgError((int)DzGv(ns + "mz"), p1, (int)DzGv(ns + "pz"), (int)DzGv(ns + "rd"), DzGv(ns + "sp"), (int)DzGv(ns + "po"), (int)DzGv(ns + "gx"));
   if(ce != "") { why = "SNAPSHOT: " + ce; return false; }
   DzCoreReset((int)DzGv(ns + "mz"), p1, (int)DzGv(ns + "pz"), (int)DzGv(ns + "rd"), DzGv(ns + "sp"), (int)DzGv(ns + "po"), (int)DzGv(ns + "gx"));
   g_dzN = n; g_dzNextId = (int)DzGv(ns + "ni"); g_dzLastFillId = (int)DzGv(ns + "lf");
   g_dzBad = DzGv(ns + "bad") > 0.5; g_dzL1Order = (ulong)DzGv(ns + "l1"); g_dzStartMsc = (long)DzGv(ns + "sm");
   g_dzBkPhase2Msc = (long)DzGv(ns + "p2m"); g_dzBkPhase2Entries = (int)DzGv(ns + "p2e");
   for(int i = 0; i < n; i++)
   {
      const string p = ns + "z" + IntegerToString(i);
      if(!GlobalVariableCheck(p + "cl")) { why = StringFormat("ZONE_%d_MISSING", i); return false; }
      g_dzZ[i].id = (int)DzGv(p + "id"); g_dzZ[i].refId = (int)DzGv(p + "rf"); g_dzZ[i].dir = (int)DzGv(p + "dr");
      g_dzZ[i].priceRef = DzGv(p + "pr"); g_dzZ[i].threshold = DzGv(p + "th"); g_dzZ[i].lo = DzGv(p + "lo"); g_dzZ[i].hi = DzGv(p + "hi");
      g_dzZ[i].hasFill = DzGv(p + "hf") > 0.5; g_dzZ[i].bLo = DzGv(p + "bl"); g_dzZ[i].bHi = DzGv(p + "bh");
      g_dzZ[i].u1 = (int)DzGv(p + "u1"); g_dzZ[i].u2 = (int)DzGv(p + "u2"); g_dzZ[i].r1 = (int)DzGv(p + "r1"); g_dzZ[i].r2 = (int)DzGv(p + "r2");
      g_dzZ[i].createdMsc = (long)DzGv(p + "cm"); g_dzZ[i].createdLevel = (int)DzGv(p + "cl");
   }
   ArrayResize(g_dzA, an); g_dzAN = an;
   for(int a = 0; a < an; a++)
   {
      const string p = ns + "a" + IntegerToString(a);
      if(!GlobalVariableCheck(p + "gp")) { why = StringFormat("ADMISSION_%d_MISSING", a); return false; }
      g_dzA[a].order = (ulong)DzGv(p + "or"); g_dzA[a].posId = (ulong)DzGv(p + "pi"); g_dzA[a].zoneId = (int)DzGv(p + "zn");
      g_dzA[a].round = (int)DzGv(p + "rd"); g_dzA[a].level = (int)DzGv(p + "lv"); g_dzA[a].side = (int)DzGv(p + "sd");
      g_dzA[a].candPx = DzGv(p + "cp"); g_dzA[a].fillPx = DzGv(p + "fp"); g_dzA[a].lot = DzGv(p + "lt");
      g_dzA[a].decMsc = (long)DzGv(p + "dm"); g_dzA[a].cfmMsc = (long)DzGv(p + "cf"); g_dzA[a].wm = (ulong)DzGv(p + "wm");
      g_dzA[a].st = (int)DzGv(p + "st"); g_dzA[a].gap = DzGv(p + "gp") > 0.5;
   }
   const string chk = DzCheck();
   if(chk != "") { why = "INVARIANT: " + chk; return false; }
   return true;
}
void DzSetUnproven(const string why)
{
   g_dzUnproven = true; g_dzUnprovenWhy = why; g_dzRestoreUnproven++;
   PrintFormat("DZ BLOCKER ZONE_LEDGER_UNPROVEN | %s -> the zone quota of this basket cannot be proven: every zone admission is BLOCKED until the basket is flat (GLOBAL levels are not skipped; PairClose / T1 / T2 / DD / session keep working) | Owner decision D-R6-RESTORE", why);
}
void DzFail(const string why)
{
   if(g_dzBad) return;
   g_dzBad = true; g_dzBadWhy = why; g_dzIntegrityFails++;
   PrintFormat("DZ BLOCKER ZONE_LEDGER_INTEGRITY | %s -> fail safe: every zone admission is BLOCKED until the basket is flat (exits keep working) | %s", why, DzLedgerText());
}

int DzAdmAdd(const int zoneId, const int round, const int level, const int side, const double candPx, const double lot, const long msc, const ulong wm)
{
   ArrayResize(g_dzA, g_dzAN + 1);
   g_dzA[g_dzAN].order = 0; g_dzA[g_dzAN].posId = 0; g_dzA[g_dzAN].zoneId = zoneId; g_dzA[g_dzAN].round = round; g_dzA[g_dzAN].level = level; g_dzA[g_dzAN].side = side;
   g_dzA[g_dzAN].candPx = candPx; g_dzA[g_dzAN].fillPx = 0.0; g_dzA[g_dzAN].lot = lot; g_dzA[g_dzAN].decMsc = msc; g_dzA[g_dzAN].cfmMsc = 0; g_dzA[g_dzAN].wm = wm;
   g_dzA[g_dzAN].st = DZA_RESERVED; g_dzA[g_dzAN].gap = false;
   return g_dzAN++;
}
void DzAdmDel(const int a)
{
   if(a < 0 || a >= g_dzAN) return;
   for(int k = a; k < g_dzAN - 1; k++) g_dzA[k] = g_dzA[k + 1];
   g_dzAN--; ArrayResize(g_dzA, g_dzAN);
}

void DzStallEnd(const string how)
{
   if(g_dzStLevel == 0) return;
   const double sec = (Ex38TickMsc() - g_dzStMsc) / 1000.0;
   PrintFormat("DZ STALL END | GLOBAL L%d was zone-blocked %.1f s (%I64d ticks, last reason %s%s) -> %s", g_dzStLevel, sec, g_dzStTicks, DzBlockName(g_dzStWhy), g_dzStPhase1 ? ", PHASE 1 stall" : "", how);
   g_dzStLevel = 0; g_dzStWhy = 0; g_dzStMsc = 0; g_dzStTicks = 0; g_dzStPhase1 = false;
}
void DzBlocked(const int level, const int side, const double p, const double trigger, const int why, const int zi)
{
   g_dzBlkTicks[why]++;
   if(g_dzStLevel == level && g_dzStWhy == why) { g_dzStTicks++; return; }
   if(g_dzStLevel != level)
   {
      g_dzBlkCands[why]++; g_dzBkBlkCands++; g_dzStallEpisodes++;
      g_dzStMsc = Ex38TickMsc(); g_dzStTicks = 0; g_dzStPhase1 = false;
   }
   if(DzPhase1Reason(why) && !g_dzStPhase1) { g_dzStPhase1 = true; g_dzPhase1Stalls++; g_dzBkPhase1Stalls++; }
   g_dzStLevel = level; g_dzStWhy = why; g_dzStTicks++;
   const string zt = zi >= 0 ? StringFormat(" | candidate zone V%d R1 %d/%d R2 %d/%d", g_dzZ[zi].id, g_dzZ[zi].u1, g_dzPer, g_dzZ[zi].u2, g_dzRounds >= 2 ? g_dzPer : 0) : "";
   PrintFormat("DZ BLOCK | %s | GLOBAL L%d %s candidate %.2f (trigger %.2f) eligible, not admitted%s | level / side / anchor / lot / trigger unchanged: the same L%d is evaluated again on the next ticks (exits keep working) | phase %d | %s%s",
               DzBlockName(why), level, side > 0 ? "BUY" : "SELL", p, trigger, zt, level, DzPhase2() ? 2 : 1, DzLedgerText(),
               why == DZB_UNPROVEN ? " | " + g_dzUnprovenWhy : (why == DZB_INTEGRITY ? " | " + g_dzBadWhy : (why == DZB_CFG_MISMATCH ? " | latched -> input:" + g_dzCfgWhy : "")));
}

bool DzGate(const int level, const int ptype, const double px, const double trigger)
{
   g_dzDecOk = false;
   if(!g_dzOn && !g_dzUnproven) return false;
   const int side = (ptype == POSITION_TYPE_BUY) ? 1 : -1;
   const double p = NormalizeDouble(px, _Digits);
   if(g_dzStLevel != 0 && g_dzStLevel != level) DzStallEnd("LEVEL_CHANGED");
   DzDecision d; DzDecInit(d, p);
   int why = DZB_NONE, zi = -1;
   if(g_dzUnproven) why = DZB_UNPROVEN;
   else if(g_dzBad) why = DZB_INTEGRITY;
   else if(g_dzCfgMismatch) why = DZB_CFG_MISMATCH;
   else { DzClassify(p, d); if(!d.allow) { why = d.why; zi = d.zi; } }
   if(why != DZB_NONE) { DzBlocked(level, side, p, trigger, why, zi); return true; }
   g_dzDec = d; g_dzDecOk = true; g_dzDecLevel = level; g_dzDecSide = side;
   return false;
}
#define DZ_SEND_REFUSED  -2
int DzReserve(const int level, const int side, const double lot)
{
   const long msc = Ex38TickMsc();
   const int zi = DzCommit(g_dzDec, msc, level);
   if(zi < 0) { DzFail(StringFormat("reservation of L%d refused by the ledger (%s)", level, DzLedgerText())); return DZ_SEND_REFUSED; }
   const ulong wm = SafEntryWatermark(Magic);
   const int a = DzAdmAdd(g_dzZ[zi].id, g_dzDec.round, level, side, g_dzDec.p, lot, msc, wm);
   if(g_dzStLevel == level) DzStallEnd("ADMITTED");
   g_dzAdmits++; if(g_dzDec.round == 2) g_dzR2Admits++;
   if(g_dzDec.isNew) g_dzCreates++;
   if(g_dzDec.isNew && !(level == 1 && g_dzQuiet))
   {
      PrintFormat("DZ CREATE | %s (PROVISIONAL until its broker fill) | phase %d | %s", DzZoneText(zi), DzPhase2() ? 2 : 1, DzCfgText());
   }
   if(!(level == 1 && g_dzQuiet)) PrintFormat("DZ RESERVE | GLOBAL L%d %s candidate %.2f lot %.2f -> V%d round %d (reserved before the request) | phase %d | %s", level, side > 0 ? "BUY" : "SELL", g_dzDec.p, lot, g_dzZ[zi].id, g_dzDec.round, DzPhase2() ? 2 : 1, DzLedgerText());
   DzPersist();
   return a;
}
bool DzR3WillNotSend(const int expected) { return LastSentCount == expected || CountPositions() >= expected; }
int DzBeforeSend(const int level, const int side, const double lot, const int expected)
{
   if(!g_dzOn) { g_dzDecOk = false; return -1; }
   if(!g_dzDecOk || g_dzDecLevel != level || g_dzDecSide != side) { g_dzDecOk = false; DzFail(StringFormat("request of L%d %s without an admission decision of this tick", level, side > 0 ? "BUY" : "SELL")); return DZ_SEND_REFUSED; }
   g_dzDecOk = false;
   if(DzR3WillNotSend(expected)) { g_dzSkipNoSend++; return -1; }
   return DzReserve(level, side, lot);
}
int DzL1BeforeSend(const bool isBuy, const double lot, const double px)
{
   if(!EnableDynamicZone || !GgOn()) return -1;
   if(DzR3WillNotSend(1)) { g_dzSkipNoSend++; return -1; }
   if(g_dzOn || g_dzAN > 0 || g_dzN > 0)
   {
      if(DzUnresolvedAny()) return -1;
      PrintFormat("DZ WARNING | a ledger was still in memory at a new L1 (%s): closed", DzLedgerText());
      DzClearPersist();
   }
   DzRamClear();
   g_dzOn = true; g_dzLedgers++; g_dzStartMsc = Ex38TickMsc();
   g_dzQuiet = ((long)TimeCurrent() / 60 == g_dzL1RelMin);
   DzClassify(NormalizeDouble(px, _Digits), g_dzDec);
   g_dzDecOk = true; g_dzDecLevel = 1; g_dzDecSide = isBuy ? 1 : -1;
   if(!g_dzQuiet) PrintFormat("DZ BASKET START | ledger latched: %s | Phase 1: V1..V%d round 1 only, Phase 2 when each of them holds %d broker-confirmed (%d)", DzCfgText(), g_dzP1, g_dzPer, g_dzP1 * g_dzPer);
   const int a = DzReserve(1, g_dzDecSide, lot);
   g_dzDecOk = false;
   return a;
}
bool DzBlocksNewL1() { return DzUnresolvedAny(); }
void DzConfirmAdm(const int a, const ulong ord, const ulong pid, const double fill, const string src);
void DzReleaseAdm(const int a, const string why);
void DzAfterSend(const int a, const bool reached, const bool ok)
{
   if(a < 0 || a >= g_dzAN) return;
   if(a == 0 && g_dzA[a].level == 1 && ok) g_dzL1Order = trade.ResultOrder();
   if(!reached) { DzReleaseAdm(a, "NOT_SENT (no request reached OrderSend: entry hold / count guard of TrySendOrder)"); return; }
   const ulong ord = trade.ResultOrder();
   const uint rc = trade.ResultRetcode();
   if(ok)
   {
      const double fill = trade.ResultPrice() > 0.0 ? trade.ResultPrice() : (g_dzA[a].side > 0 ? SymbolInfoDouble(_Symbol, SYMBOL_ASK) : SymbolInfoDouble(_Symbol, SYMBOL_BID));
      DzConfirmAdm(a, ord, ord, fill, StringFormat("DONE rc=%u", rc));
      return;
   }
   const int cls = Saf38OpenRcClass(true, rc);
   if(cls == SAF_OR_PLACED || cls == SAF_OR_UNKNOWN || cls == SAF_OR_DONE)
   {
      g_dzA[a].st = DZA_PENDING; g_dzA[a].order = ord; g_dzPendings++;
      if(g_dzA[a].level == 1) g_dzL1Order = ord;
      PrintFormat("DZ PENDING | L%d V%d round %d: request rc=%u order %I64u has no confirmed fill -> reservation kept (quota not committed), reconciled from broker evidence", g_dzA[a].level, g_dzA[a].zoneId, g_dzA[a].round, rc, ord);
      DzPersist();
      return;
   }
   DzReleaseAdm(a, StringFormat("REJECTED rc=%u (%s)", rc, trade.ResultComment()));
}
void DzConfirmAdm(const int a, const ulong ord, const ulong pid, const double fill, const string src)
{
   if(a < 0 || a >= g_dzAN || g_dzA[a].st == DZA_CONFIRMED) return;
   const int zi = DzIdx(g_dzA[a].zoneId);
   if(zi < 0) { DzFail(StringFormat("confirmed L%d refers to a missing zone V%d", g_dzA[a].level, g_dzA[a].zoneId)); return; }
   const bool p2Before = DzPhase2();
   const int where = DzWhereId(fill);
   const bool outside = DzConfirm(zi, g_dzA[a].round, fill);
   g_dzA[a].st = DZA_CONFIRMED; g_dzA[a].order = ord; g_dzA[a].posId = pid; g_dzA[a].fillPx = fill; g_dzA[a].cfmMsc = Ex38TickMsc();
   g_dzA[a].gap = (where != g_dzA[a].zoneId) || outside;
   if(g_dzA[a].level == 1) { if(g_dzL1Order == 0) g_dzL1Order = ord; g_dzBaskets++; g_dzQuiet = false; }
   g_dzConfirms++;
   const int conf = DzConfirmedTotal();
   if(conf > g_dzMaxConfirmed) g_dzMaxConfirmed = conf;
   if(g_dzN > g_dzMaxZonesSeen) g_dzMaxZonesSeen = g_dzN;
   PrintFormat("DZ CONFIRM | GLOBAL L%d %s -> V%d round %d | candidate %.2f fill %.2f | order %I64u position %I64u | %s | confirmed admissions %d of ceiling %d | %s",
               g_dzA[a].level, g_dzA[a].side > 0 ? "BUY" : "SELL", g_dzA[a].zoneId, g_dzA[a].round, g_dzA[a].candPx, fill, ord, pid, src, conf, g_dzMaxZ * g_dzPer * g_dzRounds, DzLedgerText());
   if(g_dzA[a].gap)
   {
      g_dzGapEvents++; g_dzBkGap++;
      const string at = where > 0 ? "V" + IntegerToString(where) : (where == 0 ? "a new region" : "a ledger gap");
      PrintFormat("DZ GAP ATTRIBUTION | L%d reserved V%d at candidate %.2f, broker fill %.2f lies in %s%s: ZoneID stays V%d, V%d quota consumed, no zone created (Owner R6 §9) | extrema rule %s (research)",
                  g_dzA[a].level, g_dzA[a].zoneId, g_dzA[a].candPx, fill, at, outside ? " (outside its fixed edges)" : "", g_dzA[a].zoneId, g_dzA[a].zoneId, DzGapxName(g_dzGapx));
   }
   if(!p2Before && DzPhase2())
   {
      g_dzPhase2Count++; g_dzBkPhase2Msc = Ex38TickMsc(); g_dzBkPhase2Entries = conf;
      PrintFormat("DZ PHASE 2 ENABLED | N %d: %s broker-confirmed round-1 entries (%d confirmed admissions) -> %s%s are eligible from now on (the GLOBAL candidate decides which one is used)",
                  g_dzP1, DzPhase1Text(), conf, g_dzRounds >= 2 ? "old-zone round 2" : "no round 2 (MaxRoundsPerZone 1)",
                  g_dzP1 < g_dzMaxZ ? StringFormat(" + new zones V%d..V%d", g_dzP1 + 1, g_dzMaxZ) : " (no new zone ID left: N = MaxZones)");
   }
   const string chk = DzCheck();
   if(chk != "") DzFail(chk);
   DzPersist();
}
void DzReleaseAdm(const int a, const string why)
{
   if(a < 0 || a >= g_dzAN) return;
   const int id = g_dzA[a].zoneId, lv = g_dzA[a].level, rd = g_dzA[a].round, n0 = g_dzN;
   const int zi = DzIdx(id);
   if(zi >= 0 && g_dzA[a].st != DZA_CONFIRMED) DzRelease(zi, rd);
   g_dzReleases++;
   DzAdmDel(a);
   const bool quiet = (lv == 1 && g_dzQuiet);
   if(lv == 1) { g_dzL1RelMin = (long)TimeCurrent() / 60; if(quiet) g_dzL1Quiet++; }
   if(!quiet) PrintFormat("DZ RELEASE | L%d V%d round %d reservation released: %s%s | %s", lv, id, rd, why, g_dzN < n0 ? StringFormat(" | provisional zone V%d rolled back", id) : "", DzLedgerText());
   if(g_dzN == 0 && g_dzAN == 0) { g_dzOn = false; if(!quiet) Print("DZ LEDGER EMPTY | the L1 request was not executed: no ledger for this basket yet (further refusals in this minute: journal lines suppressed, counted)"); }
   const string chk = DzCheck();
   if(chk != "") DzFail(chk);
   DzPersist();
}
void DzEvidence(const ulong ord, const long sinceMsc, const ulong wm, bool &dealIn, bool &posListed, bool &posClosed, bool &working, int &hist, ulong &pid, double &px)
{
   dealIn = false; posListed = false; posClosed = false; working = false; hist = -1; pid = ord; px = 0.0;
   for(int k = OrdersTotal() - 1; k >= 0 && !working; k--)
   {
      const ulong t = OrderGetTicket(k);
      if(t != 0 && (t == ord || (OrderGetString(ORDER_SYMBOL) == _Symbol && (ulong)OrderGetInteger(ORDER_MAGIC) == Magic))) working = true;
   }
   if(ord != 0 && HistoryOrderSelect(ord))
   {
      const long os = HistoryOrderGetInteger(ord, ORDER_STATE);
      if(os == ORDER_STATE_FILLED || os == ORDER_STATE_PARTIAL) hist = 0;
      else if(os == ORDER_STATE_CANCELED || os == ORDER_STATE_REJECTED || os == ORDER_STATE_EXPIRED) hist = 1;
   }
   double vSum = 0.0, pvSum = 0.0;
   const long from = sinceMsc > 0 ? sinceMsc : 0;
   if(HistorySelect((datetime)(from / 1000) - 5, TimeCurrent() + 60))
   {
      const int total = HistoryDealsTotal();
      for(int k = 0; k < total; k++)
      {
         const ulong d = HistoryDealGetTicket(k);
         if(d == 0 || HistoryDealGetString(d, DEAL_SYMBOL) != _Symbol) continue;
         const long en = HistoryDealGetInteger(d, DEAL_ENTRY);
         if(en != DEAL_ENTRY_IN && en != DEAL_ENTRY_INOUT) continue;
         const ulong dp = (ulong)HistoryDealGetInteger(d, DEAL_POSITION_ID);
         if(ord != 0) { if((ulong)HistoryDealGetInteger(d, DEAL_ORDER) != ord) continue; }
         else
         {
            if(from <= 0 || (ulong)HistoryDealGetInteger(d, DEAL_MAGIC) != Magic || !Saf38DealIsOfRequest(d, wm, HistoryDealGetInteger(d, DEAL_TIME_MSC), from)) continue;
            if(StringFind(HistoryDealGetString(d, DEAL_COMMENT), "R2MR|") == 0) continue;
            if(DzPosLinked(dp)) continue;
            if(dealIn && dp != pid) continue;
         }
         dealIn = true; pid = dp;
         const double v = HistoryDealGetDouble(d, DEAL_VOLUME); vSum += v; pvSum += v * HistoryDealGetDouble(d, DEAL_PRICE);
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
   if(vSum > 0.0) px = pvSum / vSum;
   if(pid != 0)
      for(int i = PositionsTotal() - 1; i >= 0 && !posListed; i--)
      {
         const ulong t = PositionGetTicket(i);
         if(t != 0 && PositionSelectByTicket(t) && (ulong)PositionGetInteger(POSITION_IDENTIFIER) == pid) { posListed = true; px = PositionGetDouble(POSITION_PRICE_OPEN); }
      }
}
void DzResolve(const int a)
{
   bool dealIn = false, posListed = false, posClosed = false, working = false; int hist = -1; ulong pid = 0; double px = 0.0;
   DzEvidence(g_dzA[a].order, g_dzA[a].decMsc, g_dzA[a].wm, dealIn, posListed, posClosed, working, hist, pid, px);
   const long el = Ex38TickMsc() - g_dzA[a].decMsc;
   const int r = Saf38EntryResolve(dealIn, posListed, posClosed, working, hist, el, (long)SAF_UNKNOWN_RESOLVE_SEC * 1000, TerminalInfoInteger(TERMINAL_CONNECTED) != 0);
   if(r == SAF_ER_EXECUTED) { DzConfirmAdm(a, g_dzA[a].order != 0 ? g_dzA[a].order : pid, pid, px > 0.0 ? px : g_dzA[a].candPx, StringFormat("RECONCILED from broker evidence (deal %d, position listed %d / closed %d)", dealIn, posListed, posClosed)); return; }
   if(r == SAF_ER_NOTEXEC) { DzReleaseAdm(a, StringFormat("NOT_EXECUTED by broker evidence (order history %d, no deal, no position, nothing working)", hist)); return; }
   DzLogOnce("DZW_" + IntegerToString(g_dzA[a].decMsc), StringFormat("DZ PENDING WAIT | L%d V%d round %d request %I64u: no broker result yet (deal %d, position %d, order working %d, history %d) -> reservation kept", g_dzA[a].level, g_dzA[a].zoneId, g_dzA[a].round, g_dzA[a].order, dealIn, posListed, working, hist));
}

void DzTick()
{
   if(g_dzAN <= 0) return;
   for(int a = g_dzAN - 1; a >= 0; a--)
      if(a < g_dzAN && (g_dzA[a].st == DZA_RESERVED || g_dzA[a].st == DZA_PENDING)) DzResolve(a);
}
void DzOnCycleReset()
{
   if(!g_dzLoaded) return;
   if(CountPositions() > 0) { DzRamClear(); return; }
   if(!g_dzOn && !g_dzUnproven && g_dzAN == 0 && g_dzN == 0) return;
   if(DzUnresolvedAny()) return;
   DzStallEnd("BASKET_FLAT");
   PrintFormat("DZ LEDGER CLOSED | basket flat, every request reconciled | %d zone(s), %d confirmed admission(s) (round 2: %d), phase %d, zone-blocked GLOBAL candidates %I64d, Phase-1 stall episodes %I64d, gap attributions %I64d | %s%s",
               g_dzN, DzConfirmedTotal(), DzRound2Total(), DzPhase2() ? 2 : 1, g_dzBkBlkCands, g_dzBkPhase1Stalls, g_dzBkGap, DzLedgerText(), g_dzUnproven ? " | UNPROVEN basket" : "");
   DzRamClear();
   DzClearPersist();
}
void DzRestore()
{
   DzRamClear(); g_dzLoaded = true;
   const string ns = DzNs();
   const int nPos = CountPositions();
   string why = "";
   if(!DzLoad(ns, why))
   {
      DzRamClear();
      if(why != "NO_RECORD") { DzClearPersist(); PrintFormat("DZ RESTORE | zone record ignored (%s) - deleted", why); }
      if(nPos > 0 && EnableDynamicZone && GgOn()) DzSetUnproven(StringFormat("restart: %d open position(s) and no valid zone ledger (%s)", nPos, why));
      return;
   }
   g_dzOn = true;
   if((int)DzGv(ns + "v") == DZ_VERSION_R7) { g_dzR7Migrated++; PrintFormat("DZ RESTORE | R7 zone ledger (version 2, fixed Phase 1 rule V1 + V2) read as N = %d - its own rule, never the current input; written as version 3 at its next change", DZ_R7_PHASE1); }
   const string cdiff = DzCfgDiff(EnableDynamicZone, MaxZones, Zone_Phase1UnlockZones, OrdersPerZonePerRound, MaxRoundsPerZone, ZoneStepUSD, (int)DynamicZone_ResearchPolicy, (int)DynamicZone_ResearchGapExtrema);
   if(nPos <= 0)
   {
      if(DzUnresolvedAny())
      {
         if(cdiff != "") { g_dzCfgMismatch = true; g_dzCfgWhy = cdiff; g_dzCfgMismatches++; }
         PrintFormat("DZ RESTORE | basket flat, unresolved admission request(s) in the ledger: reconciled from broker evidence before any new L1 | %s%s", DzLedgerText(),
                     cdiff != "" ? " | CONFIG_MISMATCH (latched -> input:" + cdiff + "): the latched snapshot is kept; a late fill of this ledger gets no new grid entry" : "");
         return;
      }
      PrintFormat("DZ RESTORE | basket flat, every request reconciled: ledger of the finished basket closed (%s)%s", DzLedgerText(), cdiff != "" ? " | the current zone inputs apply from the next basket" : "");
      DzRamClear(); DzClearPersist();
      return;
   }
   ulong open[]; int no = 0;
   for(int p = 0; p < PositionsTotal(); p++)
   {
      const ulong t = PositionGetTicket(p);
      if(t == 0 || !PositionSelectByTicket(t) || !IsOursPos()) continue;
      if(StringFind(PositionGetString(POSITION_COMMENT), "R2MR") == 0) continue;
      ArrayResize(open, no + 1); open[no++] = (ulong)PositionGetInteger(POSITION_IDENTIFIER);
   }
   ulong conf[], pend[]; int nc = 0, np = 0, nNoTk = 0;
   for(int a = 0; a < g_dzAN; a++)
   {
      if(g_dzA[a].st == DZA_CONFIRMED) { ArrayResize(conf, nc + 1); conf[nc++] = g_dzA[a].posId; }
      else if(g_dzA[a].order != 0) { ArrayResize(pend, np + 1); pend[np++] = g_dzA[a].order; }
      else nNoTk++;
   }
   const string v = DzRestoreVerdict(open, no, conf, nc, pend, np, nNoTk);
   if(v != "") { DzRamClear(); DzSetUnproven("restart: " + v); return; }
   g_dzRestored++;
   PrintFormat("DZ RESTORED | %d open position(s) all in the ledger | %s | phase %d | %d unresolved request(s) reconciled from broker evidence next | %s", no, DzCfgText(), DzPhase2() ? 2 : 1, np + nNoTk, DzLedgerText());
   for(int i = 0; i < g_dzN; i++) PrintFormat("DZ RESTORED ZONE | %s", DzZoneText(i));
   if(cdiff != "")
   {
      g_dzCfgMismatch = true; g_dzCfgWhy = cdiff; g_dzCfgMismatches++;
      PrintFormat("DZ CONFIG_MISMATCH | open basket (%d positions) was latched with other zone inputs (latched -> input:%s) -> the basket keeps its LATCHED snapshot (N %d, quotas, zone map, phase %d: never reset, never reinterpreted, Phase 2 never unlocked by the new input); NO new grid entry of this basket (every GLOBAL candidate ZONE_BLOCKED_CONFIG_MISMATCH); pending zone requests are still reconciled; PairClose / T1 / T2 / DD / session / L1 TP / recovery keep working; the new inputs apply from the next basket (restoring the latched inputs resumes this basket) | %s",
                  nPos, cdiff, g_dzP1, DzPhase2() ? 2 : 1, DzPhase1Text());
   }
}
void DzPrintCounters(const string when)
{
   string b = "";
   for(int w = 1; w < DZB_N; w++) if(g_dzBlkCands[w] > 0 || g_dzBlkTicks[w] > 0) b += StringFormat(" %s %I64d (%I64d ticks)", DzBlockName(w), g_dzBlkCands[w], g_dzBlkTicks[w]);
   PrintFormat("DZ COUNTERS %s | EnableDynamicZone %s | baskets with a confirmed L1 %I64d (L1 reservations %I64d, refusals in the same minute not journaled %I64d) | requests refused by the R3 duplicate guard without a reservation %I64d | reservations %I64d (round 2: %I64d), zones created %I64d, confirmed %I64d, released %I64d, pending %I64d, provisional rollbacks %I64d (empty kept %I64d) | gap attributions %I64d (extrema clamped %I64d) | Phase 2 reached %I64d | zone-blocked GLOBAL candidates%s | stall episodes %I64d, Phase-1 stall episodes %I64d | max confirmed in one basket %I64d, max zones %I64d | restored %I64d, unproven %I64d, integrity failures %I64d | CONFIG_MISMATCH restores %I64d, R7 ledgers read %I64d",
               when, EnableDynamicZone ? "true" : "false", g_dzBaskets, g_dzLedgers, g_dzL1Quiet, g_dzSkipNoSend, g_dzAdmits, g_dzR2Admits, g_dzCreates, g_dzConfirms, g_dzReleases, g_dzPendings, g_dzRollbacks, g_dzVoidKept, g_dzGapEvents, g_dzClamped,
               g_dzPhase2Count, b == "" ? " none" : b, g_dzStallEpisodes, g_dzPhase1Stalls, g_dzMaxConfirmed, g_dzMaxZonesSeen, g_dzRestored, g_dzRestoreUnproven, g_dzIntegrityFails, g_dzCfgMismatches, g_dzR7Migrated);
}

int OnInit()
{
   trade.SetExpertMagicNumber(Magic);
   trade.SetAsyncMode(false);
   PipSize = GetPipSize();
   Ic38StartupDiag();
   const bool rsiPeriodOk=L1Rsi38PeriodValid(RSI_Period);
   g_rsiProt=false; g_rsiPhase=RSI2_PH_NORMAL; g_rsiBlkKeys=""; ArrayInitialize(g_rsiBlk, 0); g_rsiPhaseChanges=0;
   hRSI=INVALID_HANDLE;
   if(rsiPeriodOk)
   {
      ResetLastError();
      hRSI    = iRSI(_Symbol, RSI_TF, RSI_Period, PRICE_CLOSE);
      if(hRSI == INVALID_HANDLE) { const int rsiErr=GetLastError(); PrintFormat("V38 CONFIG ERROR | RSI init failed: iRSI(%s, %s, %d) error %d - the EA is not started", _Symbol, EnumToString(RSI_TF), RSI_Period, rsiErr); return INIT_FAILED; }
      ArraySetAsSeries(rsiVal, true);
   }
   const string sessErr=SessInputsError();
   if(sessErr!="")
   {
      PrintFormat("V38 CONFIG ERROR | sessions: %s", sessErr);
      return INIT_PARAMETERS_INCORRECT;
   }
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
   const int o12mig=O12MigrationCheck((int)Entry_Strategy, Enable_GlobalGridAIPro);
   if(o12mig<0)
   {
      PrintFormat("V38 CONFIG ERROR | Entry_Strategy=%d (%s) | legacy key Enable_GlobalGridAIPro='%s' | %s - the EA is not started (0 = V26 traditional, 1 = GLOBAL Grid Mode 1 only; an old SET must set Entry_Strategy explicitly and drop the bool key)",
                  (int)Entry_Strategy, O12EntryName((int)Entry_Strategy), Enable_GlobalGridAIPro, O12MigrationName(o12mig));
      return INIT_PARAMETERS_INCORRECT;
   }
   if(o12mig==O12M_CONSISTENT)
      PrintFormat("V38 MIGRATION | legacy key Enable_GlobalGridAIPro='%s' agrees with Entry_Strategy=%s - remove the old key from the SET", Enable_GlobalGridAIPro, O12EntryName((int)Entry_Strategy));
   if(!O12T1T2Valid(Khoang_Doi_SL, So_Pip_Doi_SL, Khoang_Trailing_SL) || ConfirmFromOrder<2)
   {
      PrintFormat("V38 CONFIG ERROR | T1/T2: Khoang_Doi_SL=%.1f > 0, 0 <= So_Pip_Doi_SL=%.1f < Khoang_Doi_SL, Khoang_Trailing_SL=%.1f > 0 (pip) | ConfirmFromOrder=%d >= 2", Khoang_Doi_SL, So_Pip_Doi_SL, Khoang_Trailing_SL, ConfirmFromOrder);
      return INIT_PARAMETERS_INCORRECT;
   }
   if(CloseProtect_MaxOrders<0)
   {
      PrintFormat("V38 CONFIG ERROR | session close: CloseProtect_MaxOrders=%d >= 0", CloseProtect_MaxOrders);
      return INIT_PARAMETERS_INCORRECT;
   }
   if(!MathIsValidNumber(CloseProtect_CycleMaxLossPct) || CloseProtect_CycleMaxLossPct<0.0 || CloseProtect_CycleMaxLossPct>=100.0)
   {
      PrintFormat("V38 CONFIG ERROR | session close: CloseProtect_CycleMaxLossPct=%s must be a finite percentage of the current equity with 0 <= value < 100 (0.30 = 0.30 %%) - the EA is not started (no value is clamped)",
                  DoubleToString(CloseProtect_CycleMaxLossPct, 4));
      return INIT_PARAMETERS_INCORRECT;
   }
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
   if(Entry_Strategy==OFH38_ENTRY_GLOBAL)
   {
      double ld[]; int bad=0;
      const int n=Gg38LdParse(GlobalGrid_LocalDistancesPips, ld, bad);
      const int req=Gg38LdRequired(GlobalGrid_OrdersPerGroup, Max_Orders);
      const int c=Gg38LdCheck(n, req);
      if(c!=GG38_LD_OK || req>GG38_LD_MAX)
      {
         PrintFormat("V38 CONFIG ERROR | GLOBAL Grid: GlobalGrid_LocalDistancesPips='%s' (%d characters) -> %s%s | K=%d Max_Orders=%d need at least %d distances (largest group: original grid %d internal positions, Max_Orders+1 sizing kept from R6 %d) | format: numbers >= 0 in pip, '.' decimal, separated by ',' or by ';' (not both), at most %d characters - the EA is not started (no fallback to G1..G25)",
                     GlobalGrid_LocalDistancesPips, StringLen(GlobalGrid_LocalDistancesPips), Gg38LdErrName(c), c==GG38_LD_SHORT?StringFormat(" (%d given)", n):(bad>0?StringFormat(" (element %d)", bad):""), GlobalGrid_OrdersPerGroup, Max_Orders, req,
                     Gg38MaxInternal(GlobalGrid_OrdersPerGroup, Max_Orders), Gg38MaxInternal(GlobalGrid_OrdersPerGroup, Max_Orders+1), GG38_LD_TEXT_MAX);
         return INIT_PARAMETERS_INCORRECT;
      }
   }
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
   {
      const string dzErr=DzInputsError();
      if(dzErr!="")
      {
         PrintFormat("V38 CONFIG ERROR | DYNAMIC ZONE R8: %s - the EA is not started (no value is clamped; the records of an open basket are kept untouched)", dzErr);
         return INIT_PARAMETERS_INCORRECT;
      }
   }
   DdlInitTrade();
   SessSetup();
   ClReadInputs();
   const string rsiOpenRec = rsiPeriodOk ? "" : Rsi2OpenCycleRecords();
   v38RestorePending=true;
   Su3TryRestore("INIT", true);
   if(g_r7MigBlocked) { PrintFormat("V38 STARTUP REFUSED | R7 MIGRATION BLOCKED (see the R7 MIGRATION lines above): the EA is not started, every record of the basket is kept as it was"); return INIT_FAILED; }
   if(!rsiPeriodOk && Rsi2InitInvalidRsi(rsiOpenRec)!=RSI2_INIT_PROTECTIVE) return INIT_PARAMETERS_INCORRECT;
   ExitInit();
   DzInitLog();
   PrintFormat("ONEFXHUB V38 FINAL (correction of FINAL B941B087: final-session rule A OR B, economic history validity; V26 PairClose only, L1 RSI internal M1 / 5, zone Phase 1 = V1..VN) Init | pip=%.5f (1 gia=10 pip) | RSI=%s(%d) | L1 TP_Pips=%.0f YP=%.0f%% | T1 trigger BE +/- %.0f pip = %.2f price | T1 lock BE +/- %.0f pip = %.2f | T2 trail %.0f pip = %.2f | spread added to the L1 TP %s | CatDD=%s | TimeFilter=%s | %s GMT+%d (server GMT+%d) | ConfirmFrom=L%d | PairClose: see the next line",
               PipSize, EnumToString(RSI_TF), RSI_Period, TP_Pips, Basket_TP_PhanTram,
               Khoang_Doi_SL, O12PipToPrice(Khoang_Doi_SL, PipSize), So_Pip_Doi_SL, O12PipToPrice(So_Pip_Doi_SL, PipSize), Khoang_Trailing_SL, O12PipToPrice(Khoang_Trailing_SL, PipSize),
               Bat_Cong_Spread_TP?"yes":"no",
               Bat_Cat_DD?StringFormat("%.2f%%", Cat_DD_PhanTram):"OFF",
               UseTimeFilter?"ON":"OFF(24/7)",
               SessDescribe(), LocalGMT, ServerGMT,
               ConfirmFromOrder);
   PrintFormat("V38 R7 PAIRCLOSE | V26_LEGACY_PAIR_CLOSE only (2 positions opened last, profit + swap >= %.2f USD, from %d positions, %s, %s) through the V38 execution layer | open cycle %s | DD HALT after a DD Hedge Lock: released only by a verified Owner full manual close (broker flat, no working order / request in flight, every close of the episode manual; stop-out / EA / SL / TP close keeps the HALT)",
               PairClose_SoUSD, PairClose_TuLenh, PairClose_BatTat ? "ON" : "OFF", PairClose_ChotDanVe ? "several pairs per tick (ChotDanVe)" : "one pair per tick",
               g_clHave ? StringFormat("latched%s", g_clFrozen ? " (FROZEN: " + g_clFrozenWhy + ")" : "") : "none (the next L1 latches the inputs)");
   PrintFormat("V38 SESSION A OR B | last %d min of the continuous session window, every tick: A = <= %d EA positions -> close + rest | > %d positions: B = verified economic P/L of the whole cycle >= -%.3f%% x current equity (rule %s, input %.3f%%; with or without a completed V26 PairClose; history not proven -> B not eligible) -> close + rest, else continue (rescue) and check again inside the window | SESSION_CLOSE owns the basket through BASKET_EXITING | %s",
               MinBeforeClose, CloseProtect_MaxOrders, CloseProtect_MaxOrders, O12SessionPctEff(CloseProtect_ApplyCycleLossRule, CloseProtect_CycleMaxLossPct),
               CloseProtect_ApplyCycleLossRule ? "ON" : "OFF = 0% allowance (break-even)", CloseProtect_CycleMaxLossPct, UseTimeFilter ? "time filter ON" : "time filter OFF: no session window, no session rule");
   if(UseTimeFilter && !Enable_Asia && !Enable_Europe && !Enable_US)
      Print("CANH BAO V38: UseTimeFilter=true nhung ca 3 phien deu TAT — khong bao gio mo L1 moi.");
   PrintFormat("V38 OWNER12 | entry strategy %s (latched per cycle: %s) | GLOBAL K=%d D=%.2f USD price (%d groups) | DoubleConfirm=%s from L%d | close window %d min: <=%d positions close + rest (A), >%d close + rest when the verified cycle economic P/L meets B, else continue (rescue) | legacy bool CloseProtect_CloseProfitAboveMax REMOVED | [R7 V26-ONLY] Pair_A cycle loss rule REMOVED",
               O12EntryName((int)Entry_Strategy), g_clHave?(O12GlobalLatched()?"GLOBAL Grid Mode 1":"V26 traditional"):"no cycle", GlobalGrid_OrdersPerGroup, GlobalGrid_BreakoutDistanceUSD,
               Gg38GroupCount(MathMax(GlobalGrid_OrdersPerGroup,1), Max_Orders), Enable_DoubleConfirmation?"ON":"OFF", ConfirmFromOrder,
               MinBeforeClose, CloseProtect_MaxOrders, CloseProtect_MaxOrders);
   if(O12GlobalLatched())
   {
      const int gk=GgK();
      double cur[]; ArrayResize(cur, GgLdN()); for(int i=0; i<GgLdN(); i++) cur[i]=GgLd(i+1);
      PrintFormat("V38 GLOBAL GEN | GLOBAL Mode 1 (%s) | K=%d D=%s USD price | internal distances (pip, ABSOLUTE from each group anchor = local L1) LD1..LD%d = [%s] (input '%s', %d characters) | structure needs %d (original grid: largest group %d internal positions, Max_Orders+1 sizing kept from R6 %d) | original L1..L%d groups %s | Max_Orders+1 layout L1..L%d %s | internal level: group anchor +/- LD[localIndex] x %.2f (PriceN) | breakout anchor [NPD R1]: BUY Ask >= highest open BUY of the previous group + D, SELL Bid <= lowest open SELL of the previous group - D on the price grid (point %g) | G1..G25 are NOT used by GLOBAL | cycle latch %s, older-build GLOBAL cycles frozen at restart %I64d",
                  g_clHave?"latched cycle":"inputs", gk, Gg38Num(GgD()), GgLdN(), Gg38LdText(cur, GgLdN()), GlobalGrid_LocalDistancesPips, StringLen(GlobalGrid_LocalDistancesPips), Gg38LdRequired(gk, Max_Orders),
                  Gg38MaxInternal(gk, Max_Orders), Gg38MaxInternal(gk, Max_Orders+1), Max_Orders, Gg38LayoutText(gk, Max_Orders), Max_Orders+1, Gg38LayoutText(gk, Max_Orders+1), PipSize, _Point,
                  g_clFrozen?g_clFrozenWhy:(g_clHave?"latched":"no cycle"), g_clLdLegacy);
   }
   else Print("V38 GLOBAL GEN | entry strategy V26 traditional: GlobalGrid_LocalDistancesPips is not read (not validated, not latched); G1..G25 / GetStep / GetTrigger unchanged");
   const string o12res=ClText();
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
   PrintFormat("V38 R2 | authority %s | precedence: pending (legacy) PairClose leg before DD / grid / L1 / recovery, cycle economically >= BE blocks a NEW DD Lock | manual re-entry %s | old recovery records pending %d (reconcile only) | grid freeze %s",
               Auth38Name(AuthCurrent()), ManualReentry_Enable?"ON":"REMOVED (MRR R1: a manual close is never re-entered)",
               MrPendingCount(), g_mrGridFreeze?MrFreezeName(g_mrFreezeWhy):"no");
   PrintFormat("V38 MRR R1 | manual close: no re-entry; a fully closed level is abandoned in the level book (never re-opened in the cycle), the grid continues at the next proven level | a manual close deal with another magic counts when its position was opened by the EA | an event of a finished cycle never touches the running basket | full manual close -> cycle finalized, new L1 on the next eligible tick (session / RSI / volume / margin unchanged) | a late fill of a finalized cycle is closed, never a new L1 | level book %s | partial close freezes grid=%s",
               LbOn()?"ON ("+LbText()+")":"off (no manual close in this basket: grid level = positions + 1 as V26)", ManualPartial_FreezeGrid?"ON (R1 policy)":"OFF (level book)");
   PrintFormat("V38 R3 FINAL | T1/T2 before DD%%: a NEW DD Lock only in ORIGINAL_GRID_DRAWDOWN (>= 2 grid positions, floating loss, cycle below economic BE, no T1/T2 latched or eligible on the tick, no pending PairClose leg / recovery in flight / surplus close / unknown broker result) | a DD Lock that started before T1 is kept (no automatic unwind)");
   PrintFormat("V38 R7 V26-ONLY | Recursive Pair_A REMOVED, PairClose = V26 legacy only | entry strategy %s | latched per cycle: %s | Max_Orders = GridMaxOrders %d | strict broker lot / margin check %s (symbol: min %.2f step %.2f max %.2f limit %.2f, contract %.0f) | ladder L%d = %.2f lots | cycle latch %s",
               Entry_Strategy==OFH38_ENTRY_GLOBAL?StringFormat("GLOBAL Grid Mode 1 (K=%d, D=%.2f)", GlobalGrid_OrdersPerGroup, GlobalGrid_BreakoutDistanceUSD):"V26 traditional", g_clHave?"yes":"no cycle", Max_Orders, GridLot_StrictBrokerLimits?"ON":"OFF",
               SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MIN), SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_STEP), SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MAX), SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_LIMIT),
               SymbolInfoDouble(_Symbol,SYMBOL_TRADE_CONTRACT_SIZE), Max_Orders, Gl38LadderLot(Initial_Lot, Lot_Multi, Max_Orders, SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_STEP)),
               g_clFrozen?g_clFrozenWhy:(g_clHave?"latched":"no cycle"));
   PrintFormat("V38 TWO-PAIRCLOSE P3 | exit mode %s | trend: %s EMA %.0f / %.0f ATR %.0f strong >= %.2f | hybrid floor from %.0f pip keeps %.0f%% of the MFE, ATR x %.2f weak / x %.2f strong, trail %.0f..%.0f pip | symbol margin: hedged %.2f, margin / lot %.2f",
               Exit38Name(ExitMode()), EnumToString((ENUM_TIMEFRAMES)(int)ClGet(CL_EXIT_TF)), ClGet(CL_EXIT_EF), ClGet(CL_EXIT_ES), ClGet(CL_EXIT_ATR), ClGet(CL_EXIT_STRONG), ClGet(CL_EXIT_FSTART), ClGet(CL_EXIT_FKEEP),
               ClGet(CL_EXIT_MW), ClGet(CL_EXIT_MS), ClGet(CL_EXIT_TMIN), ClGet(CL_EXIT_TMAX), SymbolInfoDouble(_Symbol,SYMBOL_MARGIN_HEDGED), Exit38MarginPerLot());

   if(!g_rsiProt)
   PrintFormat("V38 L1RSI R1 | L1 signal: native iRSI(%s, %s, %d, PRICE_CLOSE), last CLOSED bar (shift 1), multi-level 0..100 | 0..30 BUY, >30..50 SELL, >50..70 BUY, >70..100 SELL | RSI_Period >= %d (1 refused, never replaced) | L1 on the first eligible tick after the basket is flat (no wait for a new bar)",
               _Symbol, EnumToString(RSI_TF), RSI_Period, L1RSI_PERIOD_MIN);
   Rsi2Tick();
   PrintFormat("V38 SAFETY | FINAL STANDALONE SAFETY CORRECTION (base FINAL STANDALONE 950521CF; [R7 V26-ONLY] the RPA close rules S01 / S10 / S11 are removed with Recursive Pair_A) | entry: no request while a Magic order works or an entry request has no broker result (resolved by broker evidence or %d s) | DD hedge: broker evidence | records written only after a restore | R1: two-side T1 declared only when the broker shows every protective level (S12), basket exit: no second close request before the earlier one is reconciled (S13) | open entry record %s",
               SAF_UNKNOWN_RESOLVE_SEC, g_seRec.st==0?"none":StringFormat("#%d order %I64u", g_seRec.cnt, g_seRec.ord));

   return INIT_SUCCEEDED;
}
void OnDeinit(const int reason)
{
   if(!Saf38MayPersist(reason, v38RestorePending))
   {
      g_safNoPersist++;
      PrintFormat("V38 SAFETY | deinit reason %d before the records were restored (%s): no record written, the persisted state of the basket is kept", reason, reason==REASON_INITFAILED?"OnInit failed":"account not known yet");
      if(reason==REASON_INITFAILED)
         Print("V38 STARTUP REFUSED | the EA did not start: the reason is the 'V38 CONFIG ERROR' line printed just before | Strategy Tester then ends the pass with 'tester stopped because OnInit reports incorrect input parameters' (a failed RSI handle: 'OnInit failed') | visual mode: these lines are in the Journal of the visual tester window and in the agent log, the terminal Journal only shows the agent connecting and closing");
      ExitRelease();
      if(hRSI!=INVALID_HANDLE) IndicatorRelease(hRSI);
      Su3PrintCounters("DEINIT");
      return;
   }
   if(DdlActive())
   {
      DdlPersist();
      if((bool)MQLInfoInteger(MQL_TESTER) && reason!=REASON_PARAMETERS && reason!=REASON_CHARTCHANGE && reason!=REASON_RECOMPILE)
         DdlEndEpisode("TEST_END", true);
   }
   if(GgAny()) GgSaveAll();
   if(ExActive()) ExPersist();
   CycPersistIfChanged();
   GlobalVariablesFlush();
   Ex38PrintCounters("DEINIT");
   MrPrintCounters("DEINIT");
   MrrPrintCounters("DEINIT");
   DpmrPrintCounters("DEINIT");
   R2PrintCounters("DEINIT");
   LbPrintCounters("DEINIT");
   Prio38PrintCounters("DEINIT");
   GlPrintCounters("DEINIT");
   ClPrintCounters("DEINIT");
   SafPrintCounters("DEINIT");
   DzPrintCounters("DEINIT");
   SesPrintCounters("DEINIT");
   PrintFormat("TPC EXIT COUNTERS DEINIT | %s", ExitCountersText());
   ExitRelease();
   PrintFormat("V38 OWNER12 COUNTERS DEINIT | cycles that reached Max_Orders %d (grid level skipped at the cap) %I64d | session decisions deferred for an in-flight request %I64d | DD Lock episodes started %I64d (DD %s)",
               Max_Orders, g_o12MaxOrdCycles, g_o12SessDefer, g_prStarted, Bat_Cat_DD?"ON":"OFF");
   Rsi2PrintCounters("DEINIT");
   Su3PrintCounters("DEINIT");
   if(hRSI!=INVALID_HANDLE) IndicatorRelease(hRSI);
}

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

bool IsInTradingHours()
{
   if(!UseTimeFilter) return true;
   return SessInHours();
}

bool IsNearTradingEnd()
{
   if(!UseTimeFilter) return false;
   return SessNearEnd();
}

datetime CalcNextOpenTime()
{
   const datetime open_local=SessNextOpenLocal();
   PrintFormat("CalcNextOpenTime: mo lai %s (local)", open_local>0?TimeToString(open_local, TIME_DATE|TIME_MINUTES):"(khong co phien nao bat)");
   if(open_local<=0) return D'2099.12.31';
   return open_local - (datetime)SessDiff();
}

void NghiDenPhienSau()
{
   WaitNextSession = true;
   WaitUntilTime   = CalcNextOpenTime();
   PrintFormat("=== Cho den phien moi: %s (server) ===",
               TimeToString(WaitUntilTime, TIME_DATE|TIME_MINUTES));
}

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
string GridStepText(const int n)
{
   if(!GgOn()) return StringFormat("G%d=%.0fpip", n-1, GetStep(n)/PipSize);
   const int k=GgK(), lv=GgMax();
   if(Gg38IsBreakoutAnchor(n, k, lv)) return StringFormat("GLOBAL g%d ANCHOR D=%s", Gg38GroupOf(n, k, lv), Gg38Num(GgD()));
   const int li=Gg38LocalIndex(n, k, lv);
   return StringFormat("GLOBAL g%d local L%d LD%d=%spip", Gg38GroupOf(n, k, lv), li+1, li, li>=1?Gg38Num(GgLd(li)):"-");
}

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

bool OrderIsPending(ulong order_ticket)
{
   if(order_ticket==0) return false;
   if(!OrderSelect(order_ticket)) return false;
   if(OrderGetString(ORDER_SYMBOL)!=_Symbol) return false;
   if((ulong)OrderGetInteger(ORDER_MAGIC)!=Magic) return false;
   return true;
}

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

void ResetCycleState()
{
   if(g_cycStartMsc>0 && g_mrrSeenPos && CountPositions()<=0) MrrOnCycleFinalized();
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
   skipGridThisTick  = false;
   MrOnCycleReset();
   LbOnCycleReset();
   DzOnCycleReset();
   SesOnCycleReset();
   ClOnCycleReset();
   ExitOnCycleReset();
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
   g_pairPend1=0; g_pairPend2=0; g_cycIndexShift=false; g_cycStartMsc=0; g_pairPendSinceMsc=0;
   Ex38ResetRegistries();
}

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
   PrintFormat("DPMR COUNTERS %s | V26 PairClose: legacy pairs decided %I64d, pairs left pending %I64d | R6 mode-0 cycle latches migrated %I64d | DD HALT release checks %I64d, released %I64d, kept (stop-out / not manual / no evidence) %I64d",
               when, g_dpmrPairs, g_dpmrPairPend, g_clR6Migrated, g_dpmrDdChecks, g_dpmrDdReleases, g_dpmrDdKept);
}

bool   g_r7MigBlocked = false; string g_r7MigWhy = ""; int g_r7MigVerdict = -1; long g_r7MigChecks = 0;
int    R7GvCount(const string ns) { int c = 0; for(int i = GlobalVariablesTotal() - 1; i >= 0; i--) if(StringFind(GlobalVariableName(i), ns) == 0) c++; return c; }
bool   R7IsOpenPosId(const ulong id)
{
   if(id == 0) return false;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      const ulong t = PositionGetTicket(i);
      if(t == 0 || !PositionSelectByTicket(t) || !IsOursPos()) continue;
      if((ulong)PositionGetInteger(POSITION_IDENTIFIER) == id) return true;
   }
   return false;
}
bool R7MigrationPreflight()
{
   g_r7MigChecks++;
   if(!OfhIdReady()) return false;
   int eaPos = 0, hedgePos = 0, wo = 0; Rsi2Exposure(eaPos, hedgePos, wo);
   const long cycOpen = CycStartMsc();
   const string cns = CycNs(), kns = ClNs(), gns = GgNs(), rns = R7LegacyRpaNs();
   const bool cycOwn = OfhIdCheck(cns, Magic) == "";
   const long cycRec = (cycOwn && GlobalVariableCheck(cns + "st")) ? (long)GlobalVariableGet(cns + "st") : 0;
   bool cycOfOpen = false;
   if(cycOwn && GlobalVariableCheck(cns + "nk"))
   {
      const int nk = (int)GlobalVariableGet(cns + "nk");
      for(int k = 0; k < nk && k < 40 && !cycOfOpen; k++) if(OfhTicketIsOurs((ulong)GlobalVariableGet(cns + "k" + IntegerToString(k)), Magic)) cycOfOpen = true;
   }
   string ev = "", hist = "";
   bool rpaRec = false;
   const int rCnt = R7GvCount(rns);
   if(rCnt > 0)
   {
      const long rc = (long)GlobalVariableGet(rns + "cyc");
      const bool own = OfhIdCheck(rns, Magic) == "";
      bool mine = own && rc > 0 && (rc == cycOpen || rc == cycRec);
      if(own && !mine)
      {
         if(R7IsOpenPosId((ulong)GlobalVariableGet(rns + "bid")) || R7IsOpenPosId((ulong)GlobalVariableGet(rns + "kid"))) mine = true;
         const int nsub = (int)GlobalVariableGet(rns + "ns");
         for(int i = 0; i < nsub && i < 128 && !mine; i++) if(R7IsOpenPosId((ulong)GlobalVariableGet(rns + "s" + IntegerToString(i)))) mine = true;
         const int nq = (int)GlobalVariableGet(rns + "nq");
         for(int i = 0; i < nq && i < 128 && !mine; i++) if(R7IsOpenPosId((ulong)GlobalVariableGet(rns + "q" + IntegerToString(i) + "p"))) mine = true;
      }
      if(mine) { rpaRec = true; ev += StringFormat("RPA record %s (%d keys, cycle %I64d, state %d, epoch %d); ", rns, rCnt, rc, (int)GlobalVariableGet(rns + "st"), (int)GlobalVariableGet(rns + "ep")); }
      else hist += StringFormat("RPA record %s (%d keys, cycle %I64d%s) of another basket, kept untouched; ", rns, rCnt, rc, own ? "" : ", other identity");
   }
   bool latchRpa = false, latchOld = false;
   if(GlobalVariableCheck(kns + "cyc") && OfhIdCheck(kns, Magic) == "" && !GlobalVariableCheck(kns + "r7v"))
   {
      const long kc = (long)GlobalVariableGet(kns + "cyc");
      if(kc > 0 && (kc == cycOpen || kc == cycRec))
      {
         const bool pcv = GlobalVariableCheck(kns + "pcv") && (int)GlobalVariableGet(kns + "pcv") == 1 && GlobalVariableCheck(kns + "pcm");
         if(pcv && (int)GlobalVariableGet(kns + "pcm") == 1) { latchRpa = true; ev += StringFormat("cycle latch %s: PairClose mode 1 (Recursive Pair_A), cycle %I64d; ", kns, kc); }
         else if(!pcv) { latchOld = true; ev += StringFormat("cycle latch %s of a build older than the PairClose mode key (Recursive Pair_A only), cycle %I64d; ", kns, kc); }
      }
   }
   const bool t1s = cycOfOpen && GlobalVariableCheck(cns + "t1s") && GlobalVariableGet(cns + "t1s") > 0.5;
   if(t1s) ev += "cycle state: one-side T1 lock of a Recursive Pair_A Lk* (t1s = 1); ";
   bool ggSub = false;
   if(GlobalVariableCheck(gns + "off") && OfhIdCheck(gns, Magic) == "" && (int)GlobalVariableGet(gns + "off") >= 1)
   {
      const long gb = (long)GlobalVariableGet(gns + "basket");
      if(gb > 0 && (gb == cycOpen || gb == cycRec || (ulong)gb == SessBasketId())) { ggSub = true; ev += StringFormat("GLOBAL group record of subgrid epoch %d; ", (int)GlobalVariableGet(gns + "off")); }
   }
   int tagged = 0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      const ulong t = PositionGetTicket(i);
      if(t == 0 || !PositionSelectByTicket(t) || !IsOursPos()) continue;
      if(StringFind(PositionGetString(POSITION_COMMENT), "RPA|") == 0) tagged++;
   }
   const long hs = cycRec > 0 ? cycRec : cycOpen;
   if(hs > 0 && eaPos > 0 && HistorySelect((datetime)(hs / 1000) - 1, TimeCurrent() + 60))
      for(int k = HistoryDealsTotal() - 1; k >= 0; k--)
      {
         const ulong d = HistoryDealGetTicket(k);
         if(d == 0 || HistoryDealGetString(d, DEAL_SYMBOL) != _Symbol || (ulong)HistoryDealGetInteger(d, DEAL_MAGIC) != Magic) continue;
         if(HistoryDealGetInteger(d, DEAL_TIME_MSC) < hs) continue;
         if(StringFind(HistoryDealGetString(d, DEAL_COMMENT), "RPA|") == 0) tagged++;
      }
   if(tagged > 0) ev += StringFormat("%d position(s) / deal(s) of the open cycle commented RPA|; ", tagged);
   const int v = R7MigrationVerdict(rpaRec, latchRpa, latchOld, t1s, ggSub, tagged, eaPos, hedgePos, wo);
   const string txt = StringFormat("R7 MIGRATION PREFLIGHT | %s | EA positions %d, hedge positions %d, working orders %d | Recursive Pair_A trace of the open basket: %s | history only: %s",
                                   R7MigName(v), eaPos, hedgePos, wo, ev == "" ? "none" : ev, hist == "" ? "none" : hist);
   if(v != g_r7MigVerdict || txt != g_r7MigWhy)
   {
      Print(txt);
      if(v == R7MIG_BLOCKED)
         Print("R7 MIGRATION BLOCKED | this basket was opened by an R6 build with Recursive Pair_A. R7 has no Recursive Pair_A and does NOT adopt it as a V26 / GLOBAL basket: nothing is restored, reset, written, deleted, sent or closed, the restore stays pending. Owner action required (finish the cycle with the build that opened it, or close it by hand). Hot replacement during a Recursive Pair_A cycle is NOT supported.");
   }
   g_r7MigVerdict = v; g_r7MigWhy = txt; g_r7MigBlocked = (v == R7MIG_BLOCKED);
   return g_r7MigBlocked;
}
void RestoreState()
{
   if(R7MigrationPreflight()) return;
   ResetCycleState();
   OrderCount = CountPositions();
   if(OrderCount > 0)
   {
      GetFirstPosition(FirstPrice, FirstType);
      if(OrderCount >= 2) basketModeLatched = true;
   }
   V38RestoreModules();
}

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
   SafEntryRestore();
   CycRestore();
   if(CountPositions()>0 && SessRescueLoad()) SetSessionRescue(true, "RESTORED_AFTER_RESTART");
   else if(CountPositions()<=0 && GlobalVariableCheck(SessNs()+"rescue")) { GlobalVariablesDeleteAll(SessNs()); GlobalVariablesFlush(); }
   DdlRestore();
   if(DdlActive() && sessionRescue) SetSessionRescue(false, "DD_LOCK_TAKES_AUTHORITY");
   MrRestoreLoad();
   MrrRestore();
   LbRestore();
   ClRestore();
   if(g_lbSyncDeferred) { g_lbSyncDeferred = false; LbSync(); }
   if(g_pairPend1!=0 || g_pairPend2!=0)
      PrintFormat("PAIRCLOSE V26 | restart: cycle with pending V26 PairClose leg(s) %I64u / %I64u -> finished first (no new pair / grid level / L1 / DD Lock meanwhile)", g_pairPend1, g_pairPend2);
   CycDblConfirmCheck();
   GgRestore();
   DzRestore();
   SesPairRestore();
   ExRestore();
   MrRestoreFinish();
   R2AuthAfterRestore();
}

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

bool ClosePositionVerified(const ulong ticket)
{
   if(ticket==0) return false;
   return (Ex38Close(trade, ticket, "V26") == EXCL_CLOSED);
}

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

void CloseTwoLatest(ulong t1, ulong t2)
{
   if(PositionSelectByTicket(t2)) MrNoRecoverAdd((ulong)PositionGetInteger(POSITION_IDENTIFIER));
   if(PositionSelectByTicket(t1)) MrNoRecoverAdd((ulong)PositionGetInteger(POSITION_IDENTIFIER));
   ClosePositionVerified(t2);
   ClosePositionVerified(t1);
   const bool o2=OfhTicketIsOurs(t2, Magic), o1=OfhTicketIsOurs(t1, Magic);
   if(o1 || o2)
   {
      g_pairPend1=o1?t1:0; g_pairPend2=o2?t2:0;
      g_pairPendSinceMsc=Ex38TickMsc();
      g_dpmrPairPend++;
      PrintFormat("=== PAIR CLOSE PENDING | leg(s) not closed yet: %I64u%s %I64u%s | finished before any new pair / grid level / L1 / manual recovery / DD Lock (R2) ===",
                  t1, o1?" open":" closed", t2, o2?" open":" closed");
   }
   int real = CountPositions();
   OrderCount = real;
   LastSentOrder=0; LastSentTime=0; LastSentCount=0;
   DblConfirmNum=0; DblConfirmHit1=false; DblConfirmReady=false;
}

void RunPairCloseIfNeeded(int &total)
{
   if(PairPendingAny()) { skipGridThisTick=true; return; }
   if(!basketModeLatched) return;
   if(!PairClose_BatTat) return;
   if(hedgeTrailActive) return;
   if(total<PairClose_TuLenh) return;
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
         if(g_pairPend1!=0 || g_pairPend2!=0) { skipGridThisTick=true; break; }
         const int before=cur;
         cur=CountPositions();
         if(!PairClose_ChotDanVe) break;
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

bool TrySendOrder(bool is_buy, double lot, int expected_count, const string cmt="")
{
   if(!Rsi2Allowed(g_rsiProt, RSI2_ACT_ENTRY_ORDER)) { Rsi2Blocked(RSI2_ACT_ENTRY_ORDER, StringFormat("L%d %s %.2f '%s' refused by the backstop", expected_count, is_buy ? "BUY" : "SELL", lot, cmt)); return false; }
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
         g_safPlacedWait++;
         return false;
      }
      else
      {
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

   SafEntryIntent(expected_count);
   const long s0 = trade.m_sends;
   bool ok = is_buy ? trade.Buy(lot, _Symbol, 0.0, 0.0, 0.0, cmt) : trade.Sell(lot, _Symbol, 0.0, 0.0, 0.0, cmt);
   const bool reached = (trade.m_sends > s0);
   const int ocl = Saf38OpenRcClass(reached, reached ? trade.ResultRetcode() : 0);
   if(!ok) { PrintFormat("Send failed: %s", trade.ResultComment()); SafEntryAfterSend(ocl, expected_count); return false; }

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
      SafEntryAfterSend(ocl, expected_count);
      return false;
   }
}

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

bool IsOursPos()
{
   return PositionGetString(POSITION_SYMBOL)==_Symbol &&
          (ulong)PositionGetInteger(POSITION_MAGIC)==Magic;
}

double PriceN(const double v) { return NormalizeDouble(v,_Digits); }

double SpreadNow()
{
   MqlTick tick;
   if(!SymbolInfoTick(_Symbol,tick)) return _Point;
   return MathMax(tick.ask-tick.bid,_Point);
}

double BrokerMinPending()
{
   const double stops=(double)SymbolInfoInteger(_Symbol,SYMBOL_TRADE_STOPS_LEVEL)*_Point;
   const double freeze=(double)SymbolInfoInteger(_Symbol,SYMBOL_TRADE_FREEZE_LEVEL)*_Point;
   return MathMax(stops,freeze)+_Point;
}

double ToPrice(const double pips)
{
   return pips*PipSize;
}

double DistTP()
{
   double d=ToPrice(TP_Pips);
   if(Bat_Cong_Spread_TP) d+=SpreadNow();
   return MathMax(d,BrokerMinPending());
}

double DistTrail()
{
   return ToPrice(MathMax(Khoang_Trailing_SL,0.0));
}

double DistDoiGia()
{
   return ToPrice(MathMax(Khoang_Doi_SL,0.0));
}

double DistLockPip()
{
   return ToPrice(MathMax(So_Pip_Doi_SL,0.0));
}

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

bool SlHitsMarketNow(const int dir, const double sl)
{
   MqlTick tick;
   if(!SymbolInfoTick(_Symbol,tick) || sl<=0.0) return true;
   const double off=MathMax(BrokerMinPending(), SpreadNow()+_Point)+SpreadNow();
   if(dir>0) return (sl+1e-12 >= tick.bid-off);
   return (sl-1e-12 <= tick.ask+off);
}

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

double T1BePrice()
{
   if(!ExitEconBe()) return BasketBreakevenPrice();
   double vBuy=0.0,vSell=0.0,sumBuy=0.0,sumSell=0.0;
   if(!BasketVolumeSums(vBuy,vSell,sumBuy,sumSell)) return 0.0;
   const bool one=(vBuy<=0.0 || vSell<=0.0);
   if(one) return 0.0;
   const double minV=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MIN);
   if(MathAbs(vBuy-vSell)<(minV>0.0?minV:0.01)*0.5) return 0.0;
   return Exit38EconBePrice();
}

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

bool ModifySlTpVerified(const ulong ticket,const double sl,const double tp)
{
   return (Ex38Modify(trade, ticket, sl, tp) == EXM_CONFIRMED);
}

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

bool ClusterExitHit(const int dir,const double exitPx)
{
   if(dir==0 || exitPx<=0.0) return false;
   MqlTick tick;
   if(!SymbolInfoTick(_Symbol,tick)) return false;
   if(dir>0) return (tick.bid<=exitPx+1e-12);
   return (tick.ask>=exitPx-1e-12);
}

bool LockEntireCluster(const int netDir,const double lockSl)
{
   const bool one=(CountSide(1)<=0 || CountSide(-1)<=0);
   if(netDir==0 || one) return false;
   const double sl=PriceN(lockSl);
   const double be=T1BePrice();
   if(sl<=0.0 || be<=0.0) return false;
   if(SlHitsMarketNow(netDir,sl))
   {
      PrintFormat("RSI6: T1 SL %.5f sat/xuyen gia — chua khoa, cho khoang an toan", sl);
      return false;
   }

   hedgeBePrice=sl;
   hedgeExitPrice=sl;
   hedgeClusterBe=be;
   hedgeT1Trigger=PriceN(netDir>0?be+DistDoiGia():be-DistDoiGia());
   hedgeLockMoney=0.0;
   hedgeTrailDir=netDir;
   t1Dir=netDir;
   t1Locked=false;
   t2Armed=false;
   skipGridThisTick=true;
   hedgeTrailActive=true;

   ApplyClusterExit(netDir,sl);
   T1DeclareIfConfirmed();
   return true;
}
void T1DeclareLines()
{
   const int netDir=t1Dir; const double sl=hedgeBePrice;
   double vBuy=0.0,vSell=0.0,sumBuy=0.0,sumSell=0.0;
   BasketVolumeSums(vBuy,vSell,sumBuy,sumSell);
   PrintFormat("RSI6: T1 %s Net | lotB=%.2f lotS=%.2f | BE %.5f | khoa toan cum %.5f (SL ben +, TP ben - cung gia) | dung Grid, KHONG cat | moc T2 %.5f",
               netDir>0?"Buy":"Sell", vBuy, vSell, hedgeClusterBe, sl, hedgeT1Trigger);
}
bool T1AckPending() { return hedgeTrailActive && !t1Locked && t1Dir != 0 && hedgeBePrice > 0.0; }
void T2DeclareDeferred()
{
   const int dir=t1Dir;
   if(ExitMode()>=EXIT38_T1_TREND)
      PrintFormat("RSI6: T2 trail ON %s (%s) | SL %.5f | lock %.5f | declared after the broker confirmed the T1 lock (SAFETY S12)", dir>0?"BUY":"SELL", Exit38Name(ExitMode()), hedgeExitPrice, hedgeBePrice);
   else
      PrintFormat("RSI6: T2 trail ON %s | SL=gia ± %.0f pip, khong lui duoi khoa %.5f | declared after the broker confirmed the T1 lock (SAFETY S12)", dir>0?"BUY":"SELL", Khoang_Trailing_SL, hedgeBePrice);
}
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
      g_safT1Pending++;
      if(g_safT1PendCyc!=g_cycStartMsc) { g_safT1PendCyc=g_cycStartMsc; g_safT1PendEp++; }
      SafLogOnce(StringFormat("T1ACK_%I64d", g_cycStartMsc), StringFormat("SAFETY T1 PROTECTION PENDING | two-side lock %s at %.5f: the broker does not show every protective level yet (SL of the net side, TP of the other side) -> T1 NOT declared (no 'RSI6: T1' line, no T1_LOCK row, t1Locked false); the basket is owned and managed as before (no grid, EA exit level, T2 trailing, exits), levels re-applied every tick",
                                                                             t1Dir>0?"BUY":"SELL", hedgeBePrice));
      return false;
   }
   t1Locked=true;
   T1DeclareLines();
   if(t2Armed) T2DeclareDeferred();
   return true;
}

bool T1EligibleNow(int &netDir, double &lockPx)
{
   netDir=0; lockPx=0.0;
   if(CountSide(1)<=0 || CountSide(-1)<=0) return false;

   netDir=BasketNetDir();
   const double be=T1BePrice();
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

bool TryHedge()
{
   if(!basketModeLatched) return false;
   if(hedgeTrailActive || t1Locked) return false;
   if(PairPendingAny())
   {
      g_r2T1DefPair++;
      return false;
   }
   int netDir=0; double lockPx=0.0;
   if(!T1EligibleNow(netDir, lockPx)) return false;
   const bool locked=LockEntireCluster(netDir, lockPx);
   if(!locked && (CountSide(1)<=0 || CountSide(-1)<=0)) skipGridThisTick=true;
   if(locked) MrOnT1Priority();
   return locked;
}

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
      const bool undecl=T1AckPending();
      PrintFormat("RSI6: %s — gia cham muc thoat %.5f, chot het cum%s",
                  t2Armed?"T2":"T1", hedgeExitPrice, undecl?" | T1/T2 CHUA khai bao: broker chua hien du SL/TP (SAFETY S12) - dong theo muc thoat cua EA":"");
      CloseBasketR(t2Armed?EXR_T2_HIT:EXR_T1_HIT, EXP_NONE);
      return;
   }

   ApplyClusterExit(trailDir,hedgeExitPrice);

   if(T1AckPending() && T1DeclareIfConfirmed()) g_safT1LateDeclared++;

   if(ExitMode()>=EXIT38_T1_TREND) { ExitTrailModes(trailDir, tick, floorSl); return; }

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
      if(t1Locked)
      PrintFormat("RSI6: T2 trail ON %s | SL=gia ± %.0f pip, khong lui duoi khoa %.5f",
                  trailDir>0?"BUY":"SELL", Khoang_Trailing_SL, floorSl);
   }
   hedgeExitPrice=want;
   ApplyClusterExit(trailDir,want);
}

void ReconcileTrailFromPositions()
{
   if(hedgeTrailActive) return;
   if(!basketModeLatched) return;
   if(!t2Armed) return;
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
   if(t1Locked || t2Armed || hedgeTrailActive)
   {
      int dir=(t1Dir!=0)?t1Dir:hedgeTrailDir;
      if(dir==0) dir=BasketNetDir();
      const bool hit=(dir!=0 && hedgeExitPrice>0.0 && ClusterExitHit(dir,hedgeExitPrice));
      const bool sideGone=(CountSide(1)<=0 || CountSide(-1)<=0);
      if(hit || sideGone)
      {
         PrintFormat("DD CHECK | %.2f%% >= %.2f%% but the T1/T2 exit is under way (exit %.5f hit=%d, one side already closed=%d) -> the basket is closed by its exit, not hedged",
                     pct, Cat_DD_PhanTram, hedgeExitPrice, hit?1:0, sideGone?1:0);
         CloseBasketR(t2Armed?EXR_T2_HIT:EXR_T1_HIT, EXP_NONE);
         return true;
      }
   }
   double re=0.0, fl=0.0;
   const double econ=R2CycleEconomic(re, fl);
   bool t1Elig=false;
   const int prio=Prio38DdState(pl, econ, t1Elig);
   if(prio==PRIO_PAIR_CLOSE_PENDING) R2DdDeferred(1, pct, 0.0, 0.0, 0.0);
   else if(prio==PRIO_OTHER && Econ38BlocksDd(econ)) R2DdDeferred(2, pct, econ, re, fl);
   if(!Prio38DdMayStart(prio)) { Prio38DdBlocked(prio, pct, t1Elig); return false; }
   g_prLast=prio; g_prStarted++;
   return DdlActivate(pl, bal, pct);
}

#define SES_LEG_MAX      64
#define SES_SNAP_MAX     256
#define SES_VOL_EPS      0.00000001
bool Ses38LegClosedRule(const bool listed, const double volIn, const double volOut) { return !listed && volIn > 0.0 && volOut >= volIn - SES_VOL_EPS; }
bool Ses38OpConsistent(const int pairs, const int legs, const bool overflow) { return !overflow && pairs >= 1 && legs == 2 * pairs; }
bool Ses38OpFinished(const bool opOpen, const bool pendingNow) { return opOpen && !pendingNow; }
bool   g_sesDone = false;
int    g_sesPairs = 0;
long   g_sesCyc = 0;
bool   g_sesUnproven = false;
bool   g_sesLoaded = false;
bool   g_sesOpOpen = false;
bool   g_sesOpEvid = false;
bool   g_sesOpOver = false;
int    g_sesOpPairs = 0;
int    g_sesOpN = 0;
ulong  g_sesOpLeg[SES_LEG_MAX];
ulong  g_sesOpPend1 = 0;
ulong  g_sesOpPend2 = 0;
int    g_sesSnapN = 0;
ulong  g_sesSnapTk[SES_SNAP_MAX];
ulong  g_sesSnapPid[SES_SNAP_MAX];
long   g_sesSnapPairs = 0;
bool   g_sesSnapPend = false;
string g_sesOnce = "";
long   g_sesCntLatched = 0;
long   g_sesCntRejected = 0;
long   g_sesCntUnproven = 0;
long   g_sesCntOrigin = 0;
string SesNs()       { return OfhNs("OFH38P", Magic); }
long   SesCycNow()   { return g_cycStartMsc > 0 ? g_cycStartMsc : CycStartMsc(); }
bool   Ses38PairCompleted() { return g_sesDone && g_sesCyc > 0 && g_sesCyc == SesCycNow(); }
void   Ses38Journal(const string s) { Print(s); }
void   Ses38JournalOnce(const string key, const string s)
{
   if(StringFind(g_sesOnce, "|" + key + "|") >= 0) return;
   g_sesOnce = g_sesOnce + "|" + key + "|";
   if(StringLen(g_sesOnce) > 2000) g_sesOnce = "|" + key + "|";
   Print(s);
}
string SesStateText() { return "BasketCycleID " + IntegerToString(g_sesCyc) + " | V26PairCloseCompleted " + (g_sesDone ? "true" : "false") + " (" + IntegerToString(g_sesPairs) + " pair(s))" + (g_sesUnproven ? " | history before attach UNPROVEN" : "") + (g_sesOpOpen ? " | operation: " + IntegerToString(g_sesOpPairs) + " pair(s), " + IntegerToString(g_sesOpN) + " leg(s)" + (g_sesOpEvid ? ", waiting for broker deals" : ", leg(s) pending") : ""); }
void SesOpReset() { g_sesOpOpen = false; g_sesOpEvid = false; g_sesOpOver = false; g_sesOpPairs = 0; g_sesOpN = 0; g_sesOpPend1 = 0; g_sesOpPend2 = 0; }
void SesRamClear()
{
   g_sesDone = false; g_sesPairs = 0; g_sesCyc = 0; g_sesUnproven = false;
   SesOpReset();
   g_sesSnapN = 0; g_sesSnapPairs = 0; g_sesSnapPend = false;
}
void SesPersist()
{
   string ns = SesNs();
   GlobalVariablesDeleteAll(ns);
   GlobalVariableSet(ns + "v", 1);
   GlobalVariableSet(ns + "cyc", (double)g_sesCyc);
   GlobalVariableSet(ns + "done", g_sesDone ? 1 : 0);
   GlobalVariableSet(ns + "np", g_sesPairs);
   GlobalVariableSet(ns + "unp", g_sesUnproven ? 1 : 0);
   GlobalVariableSet(ns + "oo", g_sesOpOpen ? 1 : 0);
   GlobalVariableSet(ns + "oe", g_sesOpEvid ? 1 : 0);
   GlobalVariableSet(ns + "ov", g_sesOpOver ? 1 : 0);
   GlobalVariableSet(ns + "op", g_sesOpPairs);
   GlobalVariableSet(ns + "p1", (double)g_sesOpPend1);
   GlobalVariableSet(ns + "p2", (double)g_sesOpPend2);
   GlobalVariableSet(ns + "on", g_sesOpN);
   for(int i = 0; i < g_sesOpN; i++) GlobalVariableSet(ns + "l" + IntegerToString(i), (double)g_sesOpLeg[i]);
   OfhIdStore(ns, Magic);
   GlobalVariableSet(ns + "ok", 1);
   GlobalVariablesFlush();
}
void SesClearPersist() { if(GlobalVariablesDeleteAll(SesNs()) > 0) GlobalVariablesFlush(); }
int SesLegEvidence(const ulong pid)
{
   if(pid == 0) return -1;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong t = PositionGetTicket(i);
      if(t != 0 && PositionSelectByTicket(t) && (ulong)PositionGetInteger(POSITION_IDENTIFIER) == pid) return 0;
   }
   if(!HistorySelectByPosition((long)pid)) return 0;
   double vin = 0.0, vout = 0.0; bool mine = false, other = false;
   int total = HistoryDealsTotal();
   for(int k = 0; k < total; k++)
   {
      ulong d = HistoryDealGetTicket(k);
      if(d == 0) continue;
      long en = HistoryDealGetInteger(d, DEAL_ENTRY);
      double v = HistoryDealGetDouble(d, DEAL_VOLUME);
      if(en == DEAL_ENTRY_IN) { vin += v; if((ulong)HistoryDealGetInteger(d, DEAL_MAGIC) == Magic) mine = true; }
      else if(en == DEAL_ENTRY_OUT || en == DEAL_ENTRY_OUT_BY) { vout += v; if(HistoryDealGetInteger(d, DEAL_REASON) != DEAL_REASON_EXPERT) other = true; }
   }
   if(!Ses38LegClosedRule(false, vin, vout)) return 0;
   return (mine && !other) ? 1 : -1;
}
void SesEvidence()
{
   if(!g_sesOpEvid) return;
   if(!Ses38OpConsistent(g_sesOpPairs, g_sesOpN, g_sesOpOver))
   {
      g_sesCntRejected++;
      Ses38Journal("SESSION PAIR | V26 operation NOT counted: " + IntegerToString(g_sesOpPairs) + " pair(s) decided, " + IntegerToString(g_sesOpN) + " leg(s) observed leaving the basket" + (g_sesOpOver ? " (leg list overflow)" : "") + " - exactly 2 legs per pair are required | " + SesStateText());
      SesOpReset(); SesPersist();
      return;
   }
   int ok = 0;
   for(int i = 0; i < g_sesOpN; i++)
   {
      int e = SesLegEvidence(g_sesOpLeg[i]);
      if(e < 0)
      {
         g_sesCntRejected++;
         Ses38Journal("SESSION PAIR | V26 operation NOT counted: leg position " + IntegerToString((long)g_sesOpLeg[i]) + " was closed by something other than an EA close of this Magic (manual / SL / TP / stop-out) | " + SesStateText());
         SesOpReset(); SesPersist();
         return;
      }
      if(e > 0) ok++;
   }
   if(ok < g_sesOpN) { Ses38JournalOnce("SESW" + IntegerToString(g_sesCyc) + "_" + IntegerToString(g_sesOpN) + "_" + IntegerToString(ok), "SESSION PAIR | V26 operation finished, waiting for the broker deals of " + IntegerToString(g_sesOpN - ok) + " leg(s) (latch not set until every leg is proven closed in full)"); return; }
   g_sesPairs += g_sesOpPairs; g_sesDone = true; g_sesCntLatched++;
   Ses38Journal("SESSION PAIR | V26 PAIRCLOSE COMPLETED (broker deals: " + IntegerToString(g_sesOpN) + " leg(s) closed in full by the EA) -> V26PairCloseCompleted = true for BasketCycleID " + IntegerToString(g_sesCyc) + " (" + IntegerToString(g_sesPairs) + " completed pair(s)) - information only: the final-session rule A OR B does not depend on it");
   SesOpReset(); SesPersist();
}
bool  SesTicketOpen(const ulong t) { return t != 0 && PositionSelectByTicket(t) && IsOursPos(); }
ulong SesPidOfTicket(const ulong t) { if(t != 0 && PositionSelectByTicket(t)) return (ulong)PositionGetInteger(POSITION_IDENTIFIER); return 0; }
void  SesAddLeg(const ulong pid)
{
   if(pid == 0) return;
   for(int i = 0; i < g_sesOpN; i++) if(g_sesOpLeg[i] == pid) return;
   if(g_sesOpN >= SES_LEG_MAX) { g_sesOpOver = true; return; }
   g_sesOpLeg[g_sesOpN] = pid; g_sesOpN++;
}
void SesTick()
{
   if(CountPositions() <= 0) return;
   long cyc = SesCycNow();
   if(cyc <= 0) return;
   if(g_sesCyc != cyc)
   {
      if(g_sesCyc != 0) Ses38Journal("SESSION PAIR | BasketCycleID changed (" + IntegerToString(g_sesCyc) + " -> " + IntegerToString(cyc) + ") - the state of the other cycle is discarded, never carried into this basket");
      SesRamClear(); g_sesCyc = cyc;
      SesPersist();
   }
   if(g_sesOpEvid) SesEvidence();
}
void SesBefore()
{
   g_sesSnapN = 0;
   for(int i = 0; i < PositionsTotal() && g_sesSnapN < SES_SNAP_MAX; i++)
   {
      ulong t = PositionGetTicket(i);
      if(t == 0 || !PositionSelectByTicket(t) || !IsOursPos()) continue;
      g_sesSnapTk[g_sesSnapN] = t; g_sesSnapPid[g_sesSnapN] = (ulong)PositionGetInteger(POSITION_IDENTIFIER); g_sesSnapN++;
   }
   g_sesSnapPairs = g_dpmrPairs;
   g_sesSnapPend = PairPendingAny();
}
void SesAfterDecide(const string where)
{
   long dec = g_dpmrPairs - g_sesSnapPairs;
   g_sesSnapPairs = g_dpmrPairs;
   if(dec <= 0) { g_sesSnapN = 0; return; }
   g_sesOpOpen = true; g_sesOpEvid = false; g_sesOpPairs += (int)dec;
   for(int i = 0; i < g_sesSnapN; i++) if(!SesTicketOpen(g_sesSnapTk[i])) SesAddLeg(g_sesSnapPid[i]);
   g_sesSnapN = 0;
   if(PairPendingAny())
   {
      g_sesOpPend1 = SesPidOfTicket(g_pairPend1); g_sesOpPend2 = SesPidOfTicket(g_pairPend2);
      Ses38Journal("SESSION PAIR | " + where + ": " + IntegerToString(dec) + " V26 pair(s) decided, leg(s) pending -> not completed (latch unchanged) | " + SesStateText());
   }
   else
   {
      g_sesOpPend1 = 0; g_sesOpPend2 = 0;
      g_sesOpEvid = Ses38OpFinished(g_sesOpOpen, false);
   }
   SesPersist();
   if(g_sesOpEvid) SesEvidence();
}
void SesAfterPump()
{
   bool hadPend = g_sesSnapPend;
   g_sesSnapPend = false;
   if(!hadPend || PairPendingAny()) return;
   if(!g_sesOpOpen)
   {
      g_sesCntOrigin++;
      Ses38Journal("SESSION PAIR | pending V26 leg(s) finished but the start of their operation was not observed by this build (older record / record lost) -> not counted, latch unchanged | " + SesStateText());
      return;
   }
   SesAddLeg(g_sesOpPend1); SesAddLeg(g_sesOpPend2); g_sesOpPend1 = 0; g_sesOpPend2 = 0;
   g_sesOpEvid = Ses38OpFinished(g_sesOpOpen, false);
   SesPersist();
   SesEvidence();
}
void SesOnCycleReset()
{
   if(!g_sesLoaded) return;
   if(CountPositions() > 0) { SesRamClear(); return; }
   if(g_sesDone || g_sesOpOpen) Ses38Journal("SESSION PAIR | basket flat: state of BasketCycleID " + IntegerToString(g_sesCyc) + " reset (V26PairCloseCompleted " + (g_sesDone ? "true" : "false") + ", never carried into the next basket)");
   SesRamClear(); SesClearPersist();
}
void SesPairRestore()
{
   SesRamClear(); g_sesLoaded = true;
   string ns = SesNs();
   int n = CountPositions();
   if(n <= 0) { SesClearPersist(); return; }
   long cyc = SesCycNow();
   string why = "";
   if(!GlobalVariableCheck(ns + "ok")) why = GlobalVariableCheck(ns + "v") ? "record incomplete (stop during the write)" : "no record of this build (basket opened by an older build, or record lost)";
   else if(OfhIdCheck(ns, Magic) != "") why = "record of another identity (" + OfhIdCheck(ns, Magic) + ")";
   else if((int)GlobalVariableGet(ns + "v") != 1) why = "record version";
   else if(cyc <= 0 || (long)GlobalVariableGet(ns + "cyc") != cyc) why = "record of another BasketCycleID";
   if(why == "")
   {
      g_sesCyc = cyc; g_sesDone = GlobalVariableGet(ns + "done") > 0.5; g_sesPairs = (int)GlobalVariableGet(ns + "np"); g_sesUnproven = GlobalVariableGet(ns + "unp") > 0.5;
      g_sesOpOpen = GlobalVariableGet(ns + "oo") > 0.5; g_sesOpEvid = GlobalVariableGet(ns + "oe") > 0.5; g_sesOpOver = GlobalVariableGet(ns + "ov") > 0.5;
      g_sesOpPairs = (int)GlobalVariableGet(ns + "op"); g_sesOpPend1 = (ulong)GlobalVariableGet(ns + "p1"); g_sesOpPend2 = (ulong)GlobalVariableGet(ns + "p2");
      g_sesOpN = (int)GlobalVariableGet(ns + "on");
      if(g_sesOpN < 0 || g_sesOpN > SES_LEG_MAX) why = "record leg count";
      else
         for(int i = 0; i < g_sesOpN; i++)
         {
            if(!GlobalVariableCheck(ns + "l" + IntegerToString(i))) { why = "record leg missing"; break; }
            g_sesOpLeg[i] = (ulong)GlobalVariableGet(ns + "l" + IntegerToString(i));
         }
   }
   if(why != "")
   {
      SesRamClear(); g_sesCyc = cyc; g_sesUnproven = true; g_sesCntUnproven++;
      Ses38Journal("SESSION_PAIR_HISTORY_UNPROVEN | " + IntegerToString(n) + " open position(s): " + why + " -> no completed V26 PairClose is assumed for this basket (information only: the final-session rule A OR B does not depend on it); every exit keeps working");
      SesPersist();
      return;
   }
   if(g_sesOpOpen && !g_sesOpEvid && !PairPendingAny())
   {
      SesAddLeg(g_sesOpPend1); SesAddLeg(g_sesOpPend2); g_sesOpPend1 = 0; g_sesOpPend2 = 0;
      g_sesOpEvid = Ses38OpFinished(g_sesOpOpen, false);
      SesPersist();
   }
   Ses38Journal("SESSION PAIR RESTORED | " + SesStateText());
}
long g_sesCloseCycle = 0, g_sesRescueCycleTicks = 0, g_sesRescueLogMin = -1, g_sesCloseLeN = 0, g_sesRescueUnprovenTicks = 0;
void SesPrintCounters(const string when)
{
   PrintFormat("SESSION A OR B COUNTERS %s | rule B %s %.3f%% (effective %.3f%%) | session closes: rule A %I64d, rule B %I64d | rescue ticks: B loss larger than allowed %I64d, economic P/L not proven %I64d (ECONOMIC_HISTORY_UNPROVEN events %I64d) | V26 PairClose latch (information only): latched operations %I64d, not counted %I64d, unobserved %I64d, restores UNPROVEN %I64d | current: %s",
               when, CloseProtect_ApplyCycleLossRule ? "ON" : "OFF (0% allowance)", CloseProtect_CycleMaxLossPct, O12SessionPctEff(CloseProtect_ApplyCycleLossRule, CloseProtect_CycleMaxLossPct),
               g_sesCloseLeN, g_sesCloseCycle, g_sesRescueCycleTicks, g_sesRescueUnprovenTicks, g_r2EconBadCnt, g_sesCntLatched, g_sesCntRejected, g_sesCntOrigin, g_sesCntUnproven, SesStateText());
}

bool TrySessionCloseProtect(const int total)
{
   if(total<=0) return false;
   const bool nearEnd=IsNearTradingEnd();
   if(!nearEnd) return false;
   const bool inFlight=PairPendingAny();
   const bool hadPair=Ses38PairCompleted();
   const double pctEff=O12SessionPctEff(CloseProtect_ApplyCycleLossRule, CloseProtect_CycleMaxLossPct);
   double eq=AccountInfoDouble(ACCOUNT_EQUITY), econ=0.0, re=0.0, fl=0.0, net=0.0, gross=0.0;
   bool econOk=false;
   if(!inFlight && total>CloseProtect_MaxOrders) { econ=Exit38EconNow(re, fl, net, gross, false); econOk=Exit38EconProven(); }
   int dec=O12SessionDecision(nearEnd, inFlight, total, CloseProtect_MaxOrders, econOk, econ, eq, pctEff);
   if(dec==O12S_CLOSE_CYCLE)
   {
      econ=Exit38EconNow(re, fl, net, gross, true); econOk=Exit38EconProven(); eq=AccountInfoDouble(ACCOUNT_EQUITY);
      dec=O12SessionDecision(nearEnd, inFlight, total, CloseProtect_MaxOrders, econOk, econ, eq, pctEff);
   }
   switch(dec)
   {
      case O12S_DEFER:
         g_o12SessDefer++;
         return false;
      case O12S_CLOSE_CYCLE:
         g_sesCloseCycle++;
         PrintFormat("=== CLOSE WINDOW | SESSION_CLOSE owns the basket | rule B (verified economic P/L) | %d positions > %d | economic P/L %.2f (realised %.2f + floating %.2f - projected exit cost %.2f) >= -%.3f%% x equity %.2f = -%.2f | completed V26 PairClose in this cycle: %s | CAT HET + WAIT NEXT SESSION ===",
                     total, CloseProtect_MaxOrders, econ, re, fl, re + fl - econ, pctEff, eq, O12SessionAllowedLoss(eq, pctEff), hadPair ? IntegerToString(g_sesPairs) + " pair(s)" : (g_sesUnproven ? "none proven (history before attach UNPROVEN)" : "none"));
         CloseBasketR(EXR_SESSION_CYCLE_LOSS, EXP_WAIT_NEXT_SESSION);
         return true;
      case O12S_RESCUE_CYCLE:
         g_sesRescueCycleTicks++;
         if(!sessionRescue) SetSessionRescue(true, StringFormat("CLOSE WINDOW %d positions > %d and economic P/L %.2f < -%.3f%% x equity %.2f = -%.2f -> keep managing (rescue, no parallel L1), rules A and B checked again on every tick of the window",
                                                               total, CloseProtect_MaxOrders, econ, pctEff, eq, O12SessionAllowedLoss(eq, pctEff)));
         if((long)TimeCurrent() / 60 != g_sesRescueLogMin)
         {
            g_sesRescueLogMin = (long)TimeCurrent() / 60;
            PrintFormat("CLOSE WINDOW | rule A: %d positions > %d | rule B: economic P/L %.2f (realised %.2f + floating %.2f - projected exit cost %.2f) < allowed -%.2f (%.3f%% x equity %.2f) -> not closed, checked again", total, CloseProtect_MaxOrders, econ, re, fl, re + fl - econ, O12SessionAllowedLoss(eq, pctEff), pctEff, eq);
         }
         return false;
      case O12S_CLOSE_LE_N:
         g_sesCloseLeN++;
         PrintFormat("=== CLOSE WINDOW | SESSION_CLOSE owns the basket | rule A (position count) | total=%d <= %d%s | CAT HET + WAIT NEXT SESSION ===", total, CloseProtect_MaxOrders, sessionRescue ? " (basket was in SESSION_BASKET_RESCUE)" : "");
         CloseBasketR(EXR_SESSION_LE_N, EXP_WAIT_NEXT_SESSION);
         return true;
      case O12S_RESCUE:
         g_sesRescueUnprovenTicks++;
         if(!sessionRescue) SetSessionRescue(true, StringFormat("CLOSE WINDOW total=%d > %d and the economic P/L of the cycle is NOT PROVEN (ECONOMIC_HISTORY_UNPROVEN) -> rule B not eligible; the grid of the selected strategy continues to an exit, rules A and B checked again on every tick of the window", total, CloseProtect_MaxOrders));
         if((long)TimeCurrent() / 60 != g_sesRescueLogMin)
         {
            g_sesRescueLogMin = (long)TimeCurrent() / 60;
            PrintFormat("CLOSE WINDOW | rule A: %d positions > %d | rule B: economic P/L NOT PROVEN -> not eligible (fail closed), checked again", total, CloseProtect_MaxOrders);
         }
         return false;
   }
   return false;
}

double ManualLeaveDist()
{
   return MathMax(SpreadNow()+_Point, ToPrice(1.0));
}

double ManualMarkPx(const int posType)
{
   if(posType==POSITION_TYPE_BUY) return SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   return SymbolInfoDouble(_Symbol, SYMBOL_BID);
}

bool GetClosedDealOpenInfo(const ulong deal,int &posType,double &openPx,double &vol)
{
   vol=HistoryDealGetDouble(deal,DEAL_VOLUME);
   const long dtype=HistoryDealGetInteger(deal,DEAL_TYPE);
   posType=(dtype==DEAL_TYPE_SELL)?POSITION_TYPE_BUY:POSITION_TYPE_SELL;
   const ulong posId=(ulong)HistoryDealGetInteger(deal,DEAL_POSITION_ID);
   const double closePx=HistoryDealGetDouble(deal,DEAL_PRICE);
   openPx=0.0;
   const datetime tClose=(datetime)HistoryDealGetInteger(deal,DEAL_TIME);
   HistorySelect(tClose-30*86400, tClose+60);
   const int n=HistoryDealsTotal();
   for(int i=n-1;i>=0;i--)
   {
      const ulong d=HistoryDealGetTicket(i);
      if(d==0) continue;
      if((ulong)HistoryDealGetInteger(d,DEAL_POSITION_ID)!=posId) continue;
      const long en=HistoryDealGetInteger(d,DEAL_ENTRY);
      if(en!=DEAL_ENTRY_IN && en!=DEAL_ENTRY_INOUT) continue;
      openPx=HistoryDealGetDouble(d,DEAL_PRICE);
      if(openPx>0.0) break;
   }
   if(openPx<=0.0)
      openPx=closePx;
   HistoryDealSelect(deal);
   return (openPx>0.0 && vol>0.0);
}

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
   if(MrrStaleCloseOfFinishedCycle(deal, "EVENT")) return;
   MrOnManualClose(deal, "EVENT");
}

void OnTradeTransaction(const MqlTradeTransaction &trans,
                        const MqlTradeRequest &request,
                        const MqlTradeResult &result)
{
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
   if(g_authOwnerReq) { PrintFormat("R2 OWNER_REQUIRED | deal %I64u recorded only", deal); return; }
   const long entry=HistoryDealGetInteger(deal, DEAL_ENTRY);
   if(DdlActive())
   {
      const ulong dealMagic=(ulong)HistoryDealGetInteger(deal, DEAL_MAGIC);
      if(dealMagic==Magic || dealMagic==DDLock_HedgeMagic) DdlOnDeal(deal);
      if(dealMagic==Magic && entry==DEAL_ENTRY_IN) MrOnEntryDeal(deal);
      return;
   }
   if((ulong)HistoryDealGetInteger(deal, DEAL_MAGIC)!=Magic && !MrrForeignMagicManualClose(deal)) return;
   if(ExActive())
   {
      ExOnDeal(deal);
      if(entry==DEAL_ENTRY_IN) MrOnEntryDeal(deal);
      return;
   }

   if(entry==DEAL_ENTRY_IN) { MrOnEntryDeal(deal); return; }
   if(entry!=DEAL_ENTRY_OUT && entry!=DEAL_ENTRY_INOUT && !(entry==DEAL_ENTRY_OUT_BY && Mr38IsManualReason(Mr38DealReason(deal)))) return;

   const long reason=Mr38DealReason(deal);
   if(reason==DEAL_REASON_CLIENT || reason==DEAL_REASON_MOBILE || reason==DEAL_REASON_WEB)
   {
      V38OnManualClose(deal);
      return;
   }
   if(reason==DEAL_REASON_TP && CountPositions()>0 && !MrrTpOfRunningCycle(deal)) return;
   if((reason==DEAL_REASON_SL || reason==DEAL_REASON_SO || reason==DEAL_REASON_TP) &&
      (t1Locked || t2Armed || hedgeTrailActive) && CountPositions()>0)
   {
      Print("RSI6: T1/T2 — dính muc thoat, chot het cum con lai");
      CloseBasketR(EXR_T1T2_BROKER, EXP_NONE);
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
      CloseBasketR(EXR_L1_TP_EXTRA, EXP_SKIP_GRID);
      skipGridThisTick=true;
      return;
   }
}

void OnTick()
{
   V38OnTickBody();
   Rsi2Tick();
   if(!v38RestorePending) CycPersistIfChanged();
   AuthTick();
   g_mrLastCount = CountPositions();
   if(g_mrLastCount > 0) MrrNoteSeen();
   if(!v38RestorePending) LbSync();
}

void V38OnTickBody()
{
   skipGridThisTick=false;
   if(v38RestorePending && !Su3TryRestore("TICK", false)) return;
   DzTick();
   int total=CountPositions();
   OrderCount=total;
   const bool mrrAdopt=(total>0 && g_cycStartMsc<=0);
   if(total>0 && g_cycStartMsc<=0) g_cycStartMsc=CycStartMsc();
   ClTick(total);
   GgObserve();

   if(g_authOwnerReq)
   {
      AuthOwnerRequiredTick();
      if(total<=0) MrrL1Blocked("OWNER_REQUIRED", g_authOwnerWhy);
      return;
   }

   if(DdlActive())
   {
      MrReconcileAll();
      DdlManage();
      Prio38DdHoldsT1Watch();
      if(DdlActive() && CountPositions()<=0) MrrL1Blocked("DD_LOCK_" + DdlStateName(g_ddlState), "the DD lock owns the account state (a flat basket after a DD lock is HALT until a verified Owner full manual close releases it - DPMR R1 D04 - or the Owner decides)");
      return;
   }

   if(ExActive())
   {
      MrReconcileAll();
      ExPump();
      if(ExActive() && g_mrrAwaitL1) MrrL1Blocked("BASKET_EXITING", StringFormat("%s: EA positions %d, waiting until the broker shows the basket flat and every request is reconciled", ExReasonName(g_exReason), CountPositions()));
      return;
   }

   MrScanIfNeeded(total);
   MrReconcileAll();
   if(MrOrphanGuard()) return;
   total=CountPositions();
   OrderCount=total;
   if(mrrAdopt && total>0 && MrrLateFillGuard()) return;
   if(PairPendingAny())
   {
      SesBefore();
      PairPendingPump();
      SesAfterPump();
      total=CountPositions();
      OrderCount=total;
      if(total<=0)
      {
         ResetCycleState();
         return;
      }
   }
   SesTick();

   if(WaitNextSession)
   {
      if(TimeCurrent()>=WaitUntilTime && IsInTradingHours())
      {
         WaitNextSession=false;
         PrintFormat("=== Bot hoat dong tro lai | Local=%02d:%02d GMT+%d | %s ===",
                     GetLocalHour(), GetLocalMinute(), LocalGMT,
                     EnumToString(GetLocalDayOfWeek()));
      }
      else { if(total<=0) MrrL1Blocked("WAIT_NEXT_SESSION", StringFormat("session close rest until %s (server)", TimeToString(WaitUntilTime, TIME_DATE|TIME_MINUTES))); return; }
   }

   const bool in_hours=IsInTradingHours();
   const bool near_end=IsNearTradingEnd();

   if(total>0)
   {
      double pl0=0.0, bal0=0.0, pct0=0.0;
      if(Rsi2Allowed(g_rsiProt, RSI2_ACT_PAIR_DECISION) && !PairPendingAny() && DdThresholdReached(pl0, bal0, pct0) && PairQualifiesNow(total))
      {
         g_r2PairFirst++;
         PrintFormat("R2 PRECEDENCE (B3) | DD %.2f%% >= %.2f%% and PairClose L%d+L%d qualifies on the same tick -> the pair is decided first, DD decides on the remaining basket",
                     pct0, Cat_DD_PhanTram, total-1, total);
         SesBefore();
         RunPairCloseIfNeeded(total);
         SesAfterDecide("DD_PRECEDENCE");
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

   if(TrySessionCloseProtect(total)) return;
   total=CountPositions();
   OrderCount=total;

   if(total<=0)
   {
      ResetCycleState();
      if(MrAnyCancelReconcile())
      {
         MrLogOnce("L1WAIT_" + TimeToString(TimeCurrent(), TIME_DATE|TIME_MINUTES), "MR | no new L1: a recovery request of the finished cycle is still being reconciled");
         MrrL1Blocked("RECONCILIATION_PENDING", "an old recovery request of the finished cycle is reconciled first (a late fill of it is closed, never a new L1)");
         return;
      }
      if(Prio38OrderWorking())
      {
         g_prL1WaitOrder++;
         MrLogOnce("L1WAITORD_" + TimeToString(TimeCurrent(), TIME_DATE|TIME_MINUTES), "R3F | no new L1: a Magic order of the symbol is still working at the broker (it may fill) - waiting for its result");
         MrrL1Blocked("MAGIC_ORDER_WORKING", "an order of the EA still works at the broker: its result first (a fill of it after the finalization is closed, never a new L1)");
         return;
      }
      if(!Rsi2Allowed(g_rsiProt, RSI2_ACT_NEW_L1))
      {
         Rsi2Blocked(RSI2_ACT_NEW_L1, "basket flat, old BasketCycleID finalized, nothing in flight");
         MrrL1Blocked("CONFIG_RSI_PERIOD_PROTECTIVE_ONLY", StringFormat("RSI_Period=%d < 2: no new L1 until the Owner sets RSI_Period >= 2 (never replaced by 5)", RSI_Period));
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
         MrrL1Blocked(!in_hours ? "OUT_OF_SESSION" : "NEAR_SESSION_END", StringFormat("local %02d:%02d (Session Manager unchanged)", GetLocalHour(), GetLocalMinute()));
         return;
      }

      if(DzBlocksNewL1()) { MrrL1Blocked("DZ_RECONCILIATION_PENDING", "a zone admission request of the finished basket has no broker result yet: reconciled first (the ledger is reset only after reconciliation)"); return; }
      if(CopyBuffer(hRSI,0,1,1,rsiVal)<=0) { MrrL1Blocked("RSI_UNAVAILABLE", StringFormat("CopyBuffer of the RSI handle failed (error %d)", GetLastError())); return; }
      double rsi=rsiVal[0];
      if(!L1Rsi38ValueValid(rsi)) { MrrL1Blocked("RSI_INVALID", "RSI value outside 0..100"); return; }

      const int rsiSide=L1Rsi38Side(rsi);
      bool isBuy  = (rsiSide>0);
      bool isSell = (rsiSide<0);
      if(!isBuy && !isSell) return;

      double lot=CalcLot(0);
      if(!GlGridSendable(1, lot, isBuy)) { MrrL1Blocked("VOLUME_OR_MARGIN", StringFormat("L1 lot %.2f outside the broker limits / not enough margin (blocker logged by the lot check)", lot)); return; }
      const int dzL1=DzL1BeforeSend(isBuy, lot, isBuy?SymbolInfoDouble(_Symbol, SYMBOL_ASK):SymbolInfoDouble(_Symbol, SYMBOL_BID));
      if(dzL1==DZ_SEND_REFUSED) { MrrL1Blocked("DZ_RESERVATION_REFUSED", "the zone ledger refused the V1 reservation (integrity fail safe): no L1 request"); return; }
      const long dzL1s0=trade.m_sends;
      const bool dzL1ok=TrySendOrder(isBuy, lot, 1);
      DzAfterSend(dzL1, trade.m_sends>dzL1s0, dzL1ok);
      if(!dzL1ok) { MrrL1Blocked(g_safSendHeld ? "ENTRY_HOLD_BROKER_EVIDENCE" : "L1_REQUEST_NOT_DONE", g_safSendHeld ? "an entry request without a broker result / a working order of the EA: no second request (SAFETY S02)" : "the L1 request was not executed (retcode logged above); tried again on the next eligible tick"); return; }

      FirstPrice=trade.ResultPrice();
      if(FirstPrice==0) FirstPrice=isBuy?SymbolInfoDouble(_Symbol, SYMBOL_ASK)
                                         :SymbolInfoDouble(_Symbol, SYMBOL_BID);
      FirstType=isBuy?POSITION_TYPE_BUY:POSITION_TYPE_SELL;
      OrderCount=1;
      basketModeLatched=false;
      g_cycStartMsc=Ex38TickMsc();
      MrrOnNewL1(trade.ResultOrder());
      GgOnFill(1, FirstPrice);
      PrintFormat("=== L1 %s @ %.2f lot=%.2f RSI=%.1f | local=%02d:%02d ===",
                  isBuy?"BUY":"SELL", FirstPrice, lot, rsi,
                  GetLocalHour(), GetLocalMinute());
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

   if(total>=2)
      LatchBasketMode();

   ReconcileTrailFromPositions();
   if(hedgeTrailActive || t1Locked)
   {
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

   { if(Rsi2Allowed(g_rsiProt, RSI2_ACT_PAIR_DECISION)) { SesBefore(); RunPairCloseIfNeeded(total); SesAfterDecide("P8"); } else if(PairQualifiesNow(total)) Rsi2Blocked(RSI2_ACT_PAIR_DECISION, StringFormat("legacy pair L%d+L%d qualifies: not closed (no new structure)", total-1, total)); }
   total=CountPositions();
   OrderCount=total;
   if(total<=0)
   {
      ResetCycleState();
      return;
   }

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

   if(!basketModeLatched && total==1)
   {
      RestoreTpIfOneSide();
      TryL1YpLock();
   }

   if(hedgeTrailActive || t1Locked) return;
   if(skipGridThisTick) return;
   if(MrBlocksGrid())
   {
      if(!in_hours && !sessionRescue) return;
      MrPumpSend();
      return;
   }
   if(g_cycIndexShift && ManualPartial_FreezeGrid)
   {
      static long s_frzLog=0;
      if(g_cycStartMsc!=s_frzLog) { s_frzLog=g_cycStartMsc; PrintFormat("GRID FROZEN | manual partial close in this basket (positions=%d): no further level, exits keep working", total); }
      return;
   }
   if(g_mrGridFreeze) return;
   if(g_clFrozen) { ClFrozenTick(); return; }
   if(!Rsi2Allowed(g_rsiProt, RSI2_ACT_GRID_LEVEL)) { Rsi2Blocked(RSI2_ACT_GRID_LEVEL, StringFormat("%d positions, %s", total, (O12GlobalLatched() ? "GLOBAL grid" : "V26 grid"))); return; }
   if(total>=Max_Orders)
   {
      if(g_o12MaxOrdCycle!=g_cycStartMsc)
      {
         g_o12MaxOrdCycle=g_cycStartMsc; g_o12MaxOrdCycles++;
         PrintFormat("GRID AT MAX_ORDERS | %d open positions = Max_Orders %d: no further grid level in this basket (exits / T1 / T2 / PairClose / session keep working)", total, Max_Orders);
      }
      return;
   }
   if(!in_hours && !sessionRescue) return;

   int    nextNum=0, nextType=0;
   double trigger=0.0, lot=0.0;
   {
      nextNum =LbNextLevel(total);
      if(nextNum<=0) return;
      if(nextNum>Max_Orders) return;
      nextType=GetNextType(nextNum);
      trigger =GetTrigger(nextType, nextNum);
      lot     =GlGridLot(nextNum);
   }
   double bid      = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double ask      = SymbolInfoDouble(_Symbol, SYMBOL_ASK);

   string ggTag="";
   const int ggLevel = nextNum;
   GgSync(ggLevel-1);
   if(g_mrGridFreeze) return;
   if(!GgTrigger(ggLevel, nextType, trigger, ggTag))
   {
      return;
   }

   int  cfLevel=nextNum;
   bool need_confirm=(Enable_DoubleConfirmation && cfLevel>=ConfirmFromOrder);
   const int dcId = nextNum;

   if(nextType==POSITION_TYPE_BUY)
   {
      bool can_send=need_confirm
                    ? CheckDoubleConfirm(dcId, nextType, trigger)
                    : (NormalizeDouble(ask, _Digits)>=trigger);
      if(can_send)
      {
         if(DzGate(nextNum, nextType, ask, trigger)) can_send=false;
         else if(!GlGridSendable(nextNum, lot, true)) can_send=false;
      }
      if(can_send)
      {
         const int dzAb=DzBeforeSend(nextNum, 1, lot, total+1);
         if(dzAb==DZ_SEND_REFUSED) return;
         const long dzSb=trade.m_sends;
         const bool okB=TrySendOrder(true, lot, total+1);
         DzAfterSend(dzAb, trade.m_sends>dzSb, okB);
         if(LastSentOrder!=0 && LastSentCount==total+1) LbOnGridSend(LastSentOrder, nextNum);
         if(okB)
         {
            GgOnFill(ggLevel, trade.ResultPrice()>0.0?trade.ResultPrice():ask);
            OrderCount=total+1;
            if(nextNum>=2) LatchBasketMode();
            PrintFormat("BUY #%d lot=%.2f %s trigger=%.2f ask=%.2f%s%s",
                        nextNum, lot, GridStepText(nextNum),
                        trigger, ask, need_confirm?" [DBL-CONFIRMED]":"", ggTag);
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
         if(DzGate(nextNum, nextType, bid, trigger)) can_send=false;
         else if(!GlGridSendable(nextNum, lot, false)) can_send=false;
      }
      if(can_send)
      {
         const int dzAs=DzBeforeSend(nextNum, -1, lot, total+1);
         if(dzAs==DZ_SEND_REFUSED) return;
         const long dzSs=trade.m_sends;
         const bool okS=TrySendOrder(false, lot, total+1);
         DzAfterSend(dzAs, trade.m_sends>dzSs, okS);
         if(LastSentOrder!=0 && LastSentCount==total+1) LbOnGridSend(LastSentOrder, nextNum);
         if(okS)
         {
            GgOnFill(ggLevel, trade.ResultPrice()>0.0?trade.ResultPrice():bid);
            OrderCount=total+1;
            if(nextNum>=2) LatchBasketMode();
            PrintFormat("SELL #%d lot=%.2f %s trigger=%.2f bid=%.2f%s%s",
                        nextNum, lot, GridStepText(nextNum),
                        trigger, bid, need_confirm?" [DBL-CONFIRMED]":"", ggTag);
         }
      }
   }
}

double GetPipSize()
{
   string sym = _Symbol; StringToUpper(sym);
   if(StringFind(sym,"XAU")>=0 || StringFind(sym,"GOLD")>=0) return 0.1;
   int d = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
   if(d==5 || d==3) return SymbolInfoDouble(_Symbol, SYMBOL_POINT)*10.0;
   return SymbolInfoDouble(_Symbol, SYMBOL_POINT);
}
