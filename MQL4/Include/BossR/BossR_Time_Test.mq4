//+------------------------------------------------------------------+
//| BossR_Time_Test.mq4                                              |
//+------------------------------------------------------------------+
#property strict

#include <BossR\BossR_Time.mqh>

int PASS = 0;
int FAIL = 0;

void Check(const bool condition, const string name)
{
   if(condition)
   {
      PASS++;
      Print("PASS: ", name);
   }
   else
   {
      FAIL++;
      Print("FAIL: ", name);
   }
}

int OnInit()
{
   C_BossR_Time T;

   datetime fixed = StrToTime("2026.07.08 15:30:45");
   datetime monday = StrToTime("2026.07.06 12:00:00");
   datetime saturday = StrToTime("2026.07.11 12:00:00");
   datetime sunday = StrToTime("2026.07.12 12:00:00");

   Check(T.BrokerTime() > 0, "001 broker time valid");
   Check(T.LocalTime() > 0, "002 local time valid");
   Check(T.UTCTime() > 0, "003 utc time valid");

   Check(T.TimeframeSeconds(PERIOD_M1) == 60, "004 M1 seconds");
   Check(T.TimeframeSeconds(PERIOD_M5) == 300, "005 M5 seconds");
   Check(T.TimeframeSeconds(PERIOD_M15) == 900, "006 M15 seconds");
   Check(T.TimeframeSeconds(PERIOD_M30) == 1800, "007 M30 seconds");
   Check(T.TimeframeSeconds(PERIOD_H1) == 3600, "008 H1 seconds");
   Check(T.TimeframeSeconds(PERIOD_H4) == 14400, "009 H4 seconds");
   Check(T.TimeframeSeconds(PERIOD_D1) == 86400, "010 D1 seconds");
   Check(T.TimeframeSeconds(PERIOD_W1) == 604800, "011 W1 seconds");
   Check(T.TimeframeSeconds(PERIOD_MN1) == 2592000, "012 MN1 seconds");
   Check(T.TimeframeSeconds(2) == 120, "013 custom 2 minute seconds");
   Check(T.TimeframeSeconds(0) == 0, "014 zero timeframe rejected");
   Check(T.TimeframeSeconds(-1) == 0, "015 negative timeframe rejected");

   Check(T.Year(fixed) == 2026, "016 year");
   Check(T.Month(fixed) == 7, "017 month");
   Check(T.Day(fixed) == 8, "018 day");
   Check(T.Hour(fixed) == 15, "019 hour");
   Check(T.Minute(fixed) == 30, "020 minute");
   Check(T.Second(fixed) == 45, "021 second");

   Check(T.DayOfWeek(monday) == 1, "022 monday day of week");
   Check(T.DayOfWeek(saturday) == 6, "023 saturday day of week");
   Check(T.DayOfWeek(sunday) == 0, "024 sunday day of week");

   Check(!T.IsWeekend(monday), "025 monday not weekend");
   Check(T.IsWeekend(saturday), "026 saturday weekend");
   Check(T.IsWeekend(sunday), "027 sunday weekend");

   Check(T.DayOfYear(StrToTime("2026.01.01 00:00:00")) == 0, "028 day of year jan 1");
   Check(T.DayOfYear(StrToTime("2026.01.02 00:00:00")) == 1, "029 day of year jan 2");
   Check(T.WeekOfYear(StrToTime("2026.01.01 00:00:00")) == 1, "030 week of year start");
   Check(T.WeekOfYear(StrToTime("2026.01.08 00:00:00")) == 2, "031 week of year second week");

   Check(T.IsAsianSession(StrToTime("2026.07.08 00:00:00")), "032 asian start");
   Check(T.IsAsianSession(StrToTime("2026.07.08 07:59:59")), "033 asian end inside");
   Check(!T.IsAsianSession(StrToTime("2026.07.08 08:00:00")), "034 asian end outside");

   Check(T.IsLondonSession(StrToTime("2026.07.08 08:00:00")), "035 london start");
   Check(T.IsLondonSession(StrToTime("2026.07.08 15:59:59")), "036 london end inside");
   Check(!T.IsLondonSession(StrToTime("2026.07.08 16:00:00")), "037 london end outside");

   Check(T.IsNewYorkSession(StrToTime("2026.07.08 13:00:00")), "038 newyork start");
   Check(T.IsNewYorkSession(StrToTime("2026.07.08 21:59:59")), "039 newyork end inside");
   Check(!T.IsNewYorkSession(StrToTime("2026.07.08 22:00:00")), "040 newyork end outside");

   Check(T.SessionName(StrToTime("2026.07.08 02:00:00")) == "ASIAN", "041 session asian");
   Check(T.SessionName(StrToTime("2026.07.08 09:00:00")) == "LONDON", "042 session london");
   Check(T.SessionName(StrToTime("2026.07.08 14:00:00")) == "LONDON_NEWYORK", "043 session overlap");
   Check(T.SessionName(StrToTime("2026.07.08 18:00:00")) == "NEWYORK", "044 session newyork");
   Check(T.SessionName(StrToTime("2026.07.08 23:00:00")) == "OFF", "045 session off");

   Check(T.FormatDate(fixed) == "2026.07.08", "046 format date");
   Check(T.FormatTime(fixed) == "15:30:45", "047 format time");
   Check(T.FormatDateTime(fixed) == "2026.07.08 15:30:45", "048 format datetime");

   Check(T.CurrentBarTime(Symbol(), Period()) > 0, "049 current bar time valid");
   Check(T.BarOpenTime(Symbol(), Period(), 0) == T.CurrentBarTime(Symbol(), Period()), "050 bar open shift zero equals current");
   Check(T.BarOpenTime(Symbol(), Period(), 1) > 0, "051 previous bar open valid");
   Check(T.BarOpenTime(Symbol(), Period(), -1) == 0, "052 negative shift rejected");

   Check(T.BarsSince(Symbol(), Period(), T.CurrentBarTime(Symbol(), Period())) == 0, "053 bars since current bar zero");
   Check(T.BarsSince(Symbol(), Period(), 0) == -1, "054 bars since invalid time rejected");

   Check(T.SecondsUntilNextBar(PERIOD_M1) >= 1, "055 seconds next M1 lower");
   Check(T.SecondsUntilNextBar(PERIOD_M1) <= 60, "056 seconds next M1 upper");
   Check(T.SecondsUntilNextBar(PERIOD_M5) >= 1, "057 seconds next M5 lower");
   Check(T.SecondsUntilNextBar(PERIOD_M5) <= 300, "058 seconds next M5 upper");
   Check(T.SecondsUntilNextBar(0) == 0, "059 seconds next invalid timeframe");

   Check(T.CacheCount() == 0, "060 cache initially empty");
   Check(!T.IsNewBar(Symbol(), Period()), "061 first newbar call seeds false");
   Check(T.CacheCount() == 1, "062 cache count after first symbol");
   Check(!T.IsNewBar(Symbol(), Period()), "063 second same bar false");
   Check(T.CacheCount() == 1, "064 same symbol/timeframe not duplicate");

   Check(!T.IsNewBar(Symbol(), PERIOD_M1), "065 seed M1");
   Check(T.CacheCount() >= 1, "066 cache count after M1 seed");
   Check(!T.IsNewBar(Symbol(), PERIOD_M5), "067 seed M5");
   Check(T.CacheCount() >= 1, "068 cache count after M5 seed");

   T.Clear();
   Check(T.CacheCount() == 0, "069 clear cache");

   Check(!T.IsNewBar("EURUSD", PERIOD_M1), "070 seed EURUSD M1");
   Check(!T.IsNewBar("EURUSD", PERIOD_M5), "071 seed EURUSD M5");
   Check(!T.IsNewBar("GBPUSD", PERIOD_M1), "072 seed GBPUSD M1");
   Check(T.CacheCount() == 3, "073 three cache slots");

   T.Clear();
   Check(T.CacheCount() == 0, "074 clear cache again");

   bool slot_ok = true;
   for(int i = 0; i < 32; i++)
   {
      string s = "SYM" + IntegerToString(i);
      bool result = T.IsNewBar(s, PERIOD_M1);
      if(result)
         slot_ok = false;
   }
   Check(slot_ok, "075 unsupported symbols do not falsely trigger");
   Check(T.CacheCount() == 0, "076 invalid symbols do not consume cache slots");

   Check(T.TimeframeSeconds(PERIOD_M1) < T.TimeframeSeconds(PERIOD_M5), "077 timeframe order M1 M5");
   Check(T.TimeframeSeconds(PERIOD_M5) < T.TimeframeSeconds(PERIOD_M15), "078 timeframe order M5 M15");
   Check(T.TimeframeSeconds(PERIOD_M15) < T.TimeframeSeconds(PERIOD_M30), "079 timeframe order M15 M30");
   Check(T.TimeframeSeconds(PERIOD_M30) < T.TimeframeSeconds(PERIOD_H1), "080 timeframe order M30 H1");
   Check(T.TimeframeSeconds(PERIOD_H1) < T.TimeframeSeconds(PERIOD_H4), "081 timeframe order H1 H4");
   Check(T.TimeframeSeconds(PERIOD_H4) < T.TimeframeSeconds(PERIOD_D1), "082 timeframe order H4 D1");
   Check(T.TimeframeSeconds(PERIOD_D1) < T.TimeframeSeconds(PERIOD_W1), "083 timeframe order D1 W1");

   Check(T.Hour(StrToTime("2026.07.08 00:00:00")) == 0, "084 hour midnight");
   Check(T.Hour(StrToTime("2026.07.08 23:59:59")) == 23, "085 hour end day");
   Check(T.Minute(StrToTime("2026.07.08 00:00:00")) == 0, "086 minute zero");
   Check(T.Minute(StrToTime("2026.07.08 23:59:59")) == 59, "087 minute fifty nine");
   Check(T.Second(StrToTime("2026.07.08 23:59:59")) == 59, "088 second fifty nine");

   Check(T.SessionName(StrToTime("2026.07.08 07:00:00")) == "ASIAN", "089 boundary asian");
   Check(T.SessionName(StrToTime("2026.07.08 08:00:00")) == "LONDON", "090 boundary london");
   Check(T.SessionName(StrToTime("2026.07.08 13:00:00")) == "LONDON_NEWYORK", "091 boundary overlap start");
   Check(T.SessionName(StrToTime("2026.07.08 16:00:00")) == "NEWYORK", "092 boundary newyork only");
   Check(T.SessionName(StrToTime("2026.07.08 22:00:00")) == "OFF", "093 boundary off");

   Check(T.FormatDate(StrToTime("2026.12.31 23:59:59")) == "2026.12.31", "094 format year end date");
   Check(T.FormatTime(StrToTime("2026.12.31 23:59:59")) == "23:59:59", "095 format year end time");
   Check(T.FormatDateTime(StrToTime("2026.12.31 23:59:59")) == "2026.12.31 23:59:59", "096 format year end datetime");

   Check(T.Year(StrToTime("2030.01.01 00:00:00")) == 2030, "097 future year");
   Check(T.Month(StrToTime("2030.12.01 00:00:00")) == 12, "098 december month");
   Check(T.Day(StrToTime("2030.12.31 00:00:00")) == 31, "099 month day 31");

   Check(PASS == 99 && FAIL == 0, "100 verification accounting before final result");

   Print("BossR_Time_Test complete. PASS=", PASS, " FAIL=", FAIL);

   if(PASS == 100 && FAIL == 0)
      Print("BOSSR_TIME_RUNTIME_VERIFIED");

   return INIT_SUCCEEDED;
}

void OnTick()
{
}

void OnDeinit(const int reason)
{
}