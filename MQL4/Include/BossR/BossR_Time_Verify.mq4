//+------------------------------------------------------------------+
//| BossR_Time_Verify.mq4                                            |
//+------------------------------------------------------------------+
#property strict

#include <BossR\BossR_Time.mqh>

C_BossR_Time BossTime;

int g_pass = 0;
int g_fail = 0;

void Pass(string test_name)
{
   g_pass++;
   Print("PASS: ", test_name);
}

void Fail(string test_name)
{
   g_fail++;
   Print("FAIL: ", test_name);
}

int OnInit()
{
   Print("=== BossR_Time Verification Started ===");

   if(!BossTime.IsInitialized()) Pass("Initial state is not initialized"); else Fail("Initial state is not initialized");
   if(BossTime.Init()) Pass("Init returns true"); else Fail("Init returns true");
   if(BossTime.IsInitialized()) Pass("State is initialized after Init"); else Fail("State is initialized after Init");

   datetime now = BossTime.Now();
   datetime local = BossTime.LocalNow();

   if(now > 0) Pass("Now returns valid server time"); else Fail("Now returns valid server time");
   if(local > 0) Pass("LocalNow returns valid local time"); else Fail("LocalNow returns valid local time");

   if(StringLen(BossTime.ToDateString(now)) == 10) Pass("ToDateString()"); else Fail("ToDateString()");
   if(StringLen(BossTime.ToTimeString(now)) == 8) Pass("ToTimeString()"); else Fail("ToTimeString()");
   if(StringLen(BossTime.ToDateTimeString(now)) == 19) Pass("ToDateTimeString()"); else Fail("ToDateTimeString()");

   if(BossTime.Year(now) >= 2025) Pass("Year()"); else Fail("Year()");
   if(BossTime.Month(now) >= 1 && BossTime.Month(now) <= 12) Pass("Month()"); else Fail("Month()");
   if(BossTime.Day(now) >= 1 && BossTime.Day(now) <= 31) Pass("Day()"); else Fail("Day()");
   if(BossTime.Hour(now) >= 0 && BossTime.Hour(now) <= 23) Pass("Hour()"); else Fail("Hour()");
   if(BossTime.Minute(now) >= 0 && BossTime.Minute(now) <= 59) Pass("Minute()"); else Fail("Minute()");
   if(BossTime.Second(now) >= 0 && BossTime.Second(now) <= 59) Pass("Second()");

   int dow = BossTime.DayOfWeek(now);
   if(dow >= 0 && dow <= 6) Pass("DayOfWeek()"); else Fail("DayOfWeek()");
   if(BossTime.IsWeekend(now) != BossTime.IsWeekday(now)) Pass("Weekend/Weekday complement"); else Fail("Weekend/Weekday complement");

   datetime test_time = StrToTime("2026.07.08 12:34:56");

   if(BossTime.StartOfDay(test_time) == StrToTime("2026.07.08 00:00:00")) Pass("StartOfDay()"); else Fail("StartOfDay()");
   if(BossTime.StartOfHour(test_time) == StrToTime("2026.07.08 12:00:00")) Pass("StartOfHour()"); else Fail("StartOfHour()");
   if(BossTime.StartOfMinute(test_time) == StrToTime("2026.07.08 12:34:00")) Pass("StartOfMinute()"); else Fail("StartOfMinute()");

   if(BossTime.SameDay(test_time, StrToTime("2026.07.08 23:59:59"))) Pass("SameDay()"); else Fail("SameDay()");
   if(BossTime.SameHour(test_time, StrToTime("2026.07.08 12:59:59"))) Pass("SameHour()"); else Fail("SameHour()");
   if(BossTime.SameMinute(test_time, StrToTime("2026.07.08 12:34:59"))) Pass("SameMinute()"); else Fail("SameMinute()");

   if(BossTime.TimeframeSeconds(PERIOD_M1) == 60) Pass("TimeframeSeconds M1"); else Fail("TimeframeSeconds M1");
   if(BossTime.TimeframeSeconds(PERIOD_M5) == 300) Pass("TimeframeSeconds M5"); else Fail("TimeframeSeconds M5");
   if(BossTime.TimeframeSeconds(PERIOD_H1) == 3600) Pass("TimeframeSeconds H1"); else Fail("TimeframeSeconds H1");
   if(BossTime.TimeframeSeconds(PERIOD_D1) == 86400) Pass("TimeframeSeconds D1"); else Fail("TimeframeSeconds D1");
   if(BossTime.TimeframeSeconds(PERIOD_W1) == 604800) Pass("TimeframeSeconds W1"); else Fail("TimeframeSeconds W1");
   if(BossTime.TimeframeSeconds(PERIOD_MN1) == 0) Pass("TimeframeSeconds MN1"); else Fail("TimeframeSeconds MN1");
   if(BossTime.TimeframeSeconds(9999) == 0) Pass("TimeframeSeconds invalid"); else Fail("TimeframeSeconds invalid");

   if(BossTime.StartOfMonth(test_time) == StrToTime("2026.07.01 00:00:00")) Pass("StartOfMonth()"); else Fail("StartOfMonth()");
   if(BossTime.StartOfWeek(test_time) == StrToTime("2026.07.06 00:00:00")) Pass("StartOfWeek()"); else Fail("StartOfWeek()");

   if(BossTime.StartOfBar(test_time, PERIOD_M5) == StrToTime("2026.07.08 12:30:00")) Pass("StartOfBar M5"); else Fail("StartOfBar M5");
   if(BossTime.StartOfBar(test_time, PERIOD_H1) == StrToTime("2026.07.08 12:00:00")) Pass("StartOfBar H1"); else Fail("StartOfBar H1");
   if(BossTime.StartOfBar(test_time, PERIOD_D1) == StrToTime("2026.07.08 00:00:00")) Pass("StartOfBar D1"); else Fail("StartOfBar D1");
   if(BossTime.StartOfBar(test_time, PERIOD_W1) == StrToTime("2026.07.06 00:00:00")) Pass("StartOfBar W1"); else Fail("StartOfBar W1");
   if(BossTime.StartOfBar(test_time, PERIOD_MN1) == StrToTime("2026.07.01 00:00:00")) Pass("StartOfBar MN1"); else Fail("StartOfBar MN1");

   datetime m5_open = BossTime.StartOfBar(test_time, PERIOD_M5);
   datetime m5_inside = m5_open + BossTime.TimeframeSeconds(PERIOD_M5) - 1;
   datetime m5_next_open = m5_open + BossTime.TimeframeSeconds(PERIOD_M5);

   if(BossTime.IsBarOpenTime(m5_open, PERIOD_M5)) Pass("IsBarOpenTime true"); else Fail("IsBarOpenTime true");
   if(!BossTime.IsBarOpenTime(test_time, PERIOD_M5)) Pass("IsBarOpenTime false"); else Fail("IsBarOpenTime false");

   if(BossTime.SameBar(test_time, m5_inside, PERIOD_M5)) Pass("SameBar true"); else Fail("SameBar true");
   if(!BossTime.SameBar(test_time, m5_next_open, PERIOD_M5)) Pass("SameBar false"); else Fail("SameBar false");

   BossTime.Shutdown();

   if(!BossTime.IsInitialized()) Pass("State is not initialized after Shutdown"); else Fail("State is not initialized after Shutdown");

   Print("=== BossR_Time Verification Complete ===");
   Print("PASS ", g_pass, " / FAIL ", g_fail);

   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason){}
void OnTick(){}