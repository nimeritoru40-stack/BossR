//+------------------------------------------------------------------+
//| BossR_Event_Verify.mq4                                           |
//+------------------------------------------------------------------+
#property strict

#include <BossR\BossR_Event.mqh>

C_BossR_Event BossEvent;

int g_pass = 0;
int g_fail = 0;

void Pass(string test_name){ g_pass++; Print("PASS: ", test_name); }
void Fail(string test_name){ g_fail++; Print("FAIL: ", test_name); }

int OnInit()
{
   Print("=== BossR_Event Verification Started ===");

   if(!BossEvent.IsInitialized()) Pass("Initial state is not initialized"); else Fail("Initial state is not initialized");
   if(BossEvent.ModuleName() == "BossR_Event") Pass("ModuleName()"); else Fail("ModuleName()");
   if(BossEvent.Init()) Pass("Init returns true"); else Fail("Init returns true");
   if(BossEvent.IsInitialized()) Pass("State is initialized after Init"); else Fail("State is initialized after Init");

   if(BossEvent.EventSymbol() == Symbol()) Pass("Default symbol after Init"); else Fail("Default symbol after Init");
   if(BossEvent.EventTimeframe() == Period()) Pass("Default timeframe after Init"); else Fail("Default timeframe after Init");
   if(BossEvent.LastBarTime() == 0) Pass("Initial LastBarTime is zero"); else Fail("Initial LastBarTime is zero");
   if(!BossEvent.IsNewBar()) Pass("Initial IsNewBar false"); else Fail("Initial IsNewBar false");

   if(!BossEvent.Configure("", PERIOD_M1)) Pass("Configure rejects empty symbol"); else Fail("Configure rejects empty symbol");
   if(!BossEvent.Configure(Symbol(), 0)) Pass("Configure rejects zero timeframe"); else Fail("Configure rejects zero timeframe");
   if(!BossEvent.Configure(Symbol(), -1)) Pass("Configure rejects negative timeframe"); else Fail("Configure rejects negative timeframe");

   if(BossEvent.Configure(Symbol(), PERIOD_M1)) Pass("Configure valid symbol/timeframe"); else Fail("Configure valid symbol/timeframe");
   if(BossEvent.EventSymbol() == Symbol()) Pass("Configured symbol stored"); else Fail("Configured symbol stored");
   if(BossEvent.EventTimeframe() == PERIOD_M1) Pass("Configured timeframe stored"); else Fail("Configured timeframe stored");
   if(BossEvent.LastBarTime() == 0) Pass("Configure resets LastBarTime"); else Fail("Configure resets LastBarTime");
   if(!BossEvent.IsNewBar()) Pass("Configure resets IsNewBar"); else Fail("Configure resets IsNewBar");

   if(BossEvent.Poll()) Pass("First Poll returns true"); else Fail("First Poll returns true");

   datetime first_bar_time = BossEvent.LastBarTime();

   if(first_bar_time > 0) Pass("First Poll stores LastBarTime"); else Fail("First Poll stores LastBarTime");
   if(!BossEvent.IsNewBar()) Pass("First Poll IsNewBar false"); else Fail("First Poll IsNewBar false");

   if(BossEvent.Poll()) Pass("Second Poll returns true"); else Fail("Second Poll returns true");
   if(BossEvent.LastBarTime() == first_bar_time) Pass("Second Poll preserves LastBarTime"); else Fail("Second Poll preserves LastBarTime");
   if(!BossEvent.IsNewBar()) Pass("Second Poll IsNewBar false same bar"); else Fail("Second Poll IsNewBar false same bar");

   if(BossEvent.Configure(Symbol(), PERIOD_M1)) Pass("Reconfigure before PollAt tests"); else Fail("Reconfigure before PollAt tests");

   datetime bar_a = StrToTime("2026.07.08 12:30:00");
   datetime bar_b = StrToTime("2026.07.08 12:31:00");

   if(!BossEvent.PollAt(0)) Pass("PollAt rejects zero time"); else Fail("PollAt rejects zero time");
   if(BossEvent.LastBarTime() == 0) Pass("PollAt zero does not set LastBarTime"); else Fail("PollAt zero does not set LastBarTime");
   if(!BossEvent.IsNewBar()) Pass("PollAt zero leaves IsNewBar false"); else Fail("PollAt zero leaves IsNewBar false");

   if(BossEvent.PollAt(bar_a)) Pass("PollAt first bar returns true"); else Fail("PollAt first bar returns true");
   if(BossEvent.LastBarTime() == bar_a) Pass("PollAt first bar stores LastBarTime"); else Fail("PollAt first bar stores LastBarTime");
   if(!BossEvent.IsNewBar()) Pass("PollAt first bar IsNewBar false"); else Fail("PollAt first bar IsNewBar false");

   if(BossEvent.PollAt(bar_a)) Pass("PollAt same bar returns true"); else Fail("PollAt same bar returns true");
   if(BossEvent.LastBarTime() == bar_a) Pass("PollAt same bar preserves LastBarTime"); else Fail("PollAt same bar preserves LastBarTime");
   if(!BossEvent.IsNewBar()) Pass("PollAt same bar IsNewBar false"); else Fail("PollAt same bar IsNewBar false");

   if(BossEvent.PollAt(bar_b)) Pass("PollAt new bar returns true"); else Fail("PollAt new bar returns true");
   if(BossEvent.LastBarTime() == bar_b) Pass("PollAt new bar updates LastBarTime"); else Fail("PollAt new bar updates LastBarTime");
   if(BossEvent.IsNewBar()) Pass("PollAt new bar IsNewBar true"); else Fail("PollAt new bar IsNewBar true");

   if(BossEvent.PollAt(bar_b)) Pass("PollAt repeated new bar returns true"); else Fail("PollAt repeated new bar returns true");
   if(BossEvent.LastBarTime() == bar_b) Pass("PollAt repeated preserves LastBarTime"); else Fail("PollAt repeated preserves LastBarTime");
   if(!BossEvent.IsNewBar()) Pass("PollAt repeated IsNewBar false"); else Fail("PollAt repeated IsNewBar false");

   if(BossEvent.Configure(Symbol(), PERIOD_M1)) Pass("Reconfigure before day tests"); else Fail("Reconfigure before day tests");

   datetime day_a = StrToTime("2026.07.08 23:59:00");
   datetime day_b = StrToTime("2026.07.09 00:00:00");
   datetime day_c = StrToTime("2026.07.09 00:01:00");

   BossEvent.PollAt(day_a);
   if(!BossEvent.IsNewDay()) Pass("Day Init"); else Fail("Day Init");

   BossEvent.PollAt(day_b);
   if(BossEvent.IsNewDay()) Pass("Day Change"); else Fail("Day Change");

   BossEvent.PollAt(day_c);
   if(!BossEvent.IsNewDay()) Pass("Day One Shot"); else Fail("Day One Shot");

   if(BossEvent.Configure(Symbol(), PERIOD_M1)) Pass("Reconfigure before week tests"); else Fail("Reconfigure before week tests");

   datetime week_a = StrToTime("2026.07.06 12:00:00");
   datetime week_b = StrToTime("2026.07.13 12:00:00");
   datetime week_c = StrToTime("2026.07.13 12:01:00");

   BossEvent.PollAt(week_a);
   if(!BossEvent.IsNewWeek()) Pass("Week Init"); else Fail("Week Init");

   BossEvent.PollAt(week_b);
   if(BossEvent.IsNewWeek()) Pass("Week Change"); else Fail("Week Change");

   BossEvent.PollAt(week_c);
   if(!BossEvent.IsNewWeek()) Pass("Week One Shot"); else Fail("Week One Shot");

   if(BossEvent.Configure(Symbol(), PERIOD_M1)) Pass("Reconfigure before month tests"); else Fail("Reconfigure before month tests");

   datetime month_a = StrToTime("2026.07.31 23:59:00");
   datetime month_b = StrToTime("2026.08.01 00:00:00");
   datetime month_c = StrToTime("2026.08.01 00:01:00");

   BossEvent.PollAt(month_a);
   if(!BossEvent.IsNewMonth()) Pass("Month Init"); else Fail("Month Init");

   BossEvent.PollAt(month_b);
   if(BossEvent.IsNewMonth()) Pass("Month Change"); else Fail("Month Change");

   BossEvent.PollAt(month_c);
   if(!BossEvent.IsNewMonth()) Pass("Month One Shot"); else Fail("Month One Shot");

   if(BossEvent.Configure(Symbol(), PERIOD_M1)) Pass("Reconfigure before hour tests"); else Fail("Reconfigure before hour tests");

   datetime hour_a = StrToTime("2026.07.08 12:59:00");
   datetime hour_b = StrToTime("2026.07.08 13:00:00");
   datetime hour_c = StrToTime("2026.07.08 13:01:00");

   BossEvent.PollAt(hour_a);
   if(!BossEvent.IsNewHour()) Pass("Hour Init"); else Fail("Hour Init");

   BossEvent.PollAt(hour_b);
   if(BossEvent.IsNewHour()) Pass("Hour Change"); else Fail("Hour Change");

   BossEvent.PollAt(hour_c);
   if(!BossEvent.IsNewHour()) Pass("Hour One Shot"); else Fail("Hour One Shot");
      if(!BossEvent.ConfigureSession(-1, 0)) Pass("ConfigureSession rejects negative hour"); else Fail("ConfigureSession rejects negative hour");
   if(!BossEvent.ConfigureSession(24, 0)) Pass("ConfigureSession rejects hour above 23"); else Fail("ConfigureSession rejects hour above 23");
   if(!BossEvent.ConfigureSession(8, -1)) Pass("ConfigureSession rejects negative minute"); else Fail("ConfigureSession rejects negative minute");
   if(!BossEvent.ConfigureSession(8, 60)) Pass("ConfigureSession rejects minute above 59"); else Fail("ConfigureSession rejects minute above 59");

   if(BossEvent.Configure(Symbol(), PERIOD_M1)) Pass("Reconfigure before session tests"); else Fail("Reconfigure before session tests");
   if(BossEvent.ConfigureSession(8, 30)) Pass("ConfigureSession valid custom session"); else Fail("ConfigureSession valid custom session");

   datetime session_a = StrToTime("2026.07.08 08:29:00");
   datetime session_b = StrToTime("2026.07.08 08:30:00");
   datetime session_c = StrToTime("2026.07.08 08:31:00");

   BossEvent.PollAt(session_a);
   if(!BossEvent.IsNewSession()) Pass("Session Init"); else Fail("Session Init");

   BossEvent.PollAt(session_b);
   if(BossEvent.IsNewSession()) Pass("Session Change"); else Fail("Session Change");

   BossEvent.PollAt(session_c);
   if(!BossEvent.IsNewSession()) Pass("Session One Shot"); else Fail("Session One Shot");

   BossEvent.Shutdown();

   if(!BossEvent.IsInitialized()) Pass("State is not initialized after Shutdown"); else Fail("State is not initialized after Shutdown");
   if(BossEvent.EventSymbol() == "") Pass("Shutdown clears symbol"); else Fail("Shutdown clears symbol");
   if(BossEvent.EventTimeframe() == 0) Pass("Shutdown clears timeframe"); else Fail("Shutdown clears timeframe");
   if(BossEvent.LastBarTime() == 0) Pass("Shutdown clears LastBarTime"); else Fail("Shutdown clears LastBarTime");
   if(!BossEvent.IsNewBar()) Pass("Shutdown clears IsNewBar"); else Fail("Shutdown clears IsNewBar");

   Print("=== BossR_Event Verification Complete ===");
   Print("PASS ", g_pass, " / FAIL ", g_fail);

   return INIT_SUCCEEDED;
}

void OnDeinit(const int reason){}
void OnTick(){}