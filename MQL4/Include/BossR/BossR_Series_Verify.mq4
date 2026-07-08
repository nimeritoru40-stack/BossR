//+------------------------------------------------------------------+
//| BossR_Series_Verify.mq4                                          |
//+------------------------------------------------------------------+
#property strict

#include <BossR\BossR_Series.mqh>
#include <BossR\BossR_Bar.mqh>

C_BossR_Series Series;
C_BossR_Bar    Bar;

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

void Check(bool condition, string test_name)
{
   if(condition) Pass(test_name);
   else          Fail(test_name);
}

bool NearlyEqual(const double a, const double b)
{
   return MathAbs(a - b) < 0.0000000001;
}

int ManualHighestHighShift(const int start_shift, const int length)
{
   int best_shift = start_shift;
   double best_value = Bar.HighValue(start_shift);

   for(int i = start_shift + 1; i < start_shift + length; i++)
   {
      double v = Bar.HighValue(i);
      if(v > best_value)
      {
         best_value = v;
         best_shift = i;
      }
   }

   return best_shift;
}

int ManualLowestLowShift(const int start_shift, const int length)
{
   int best_shift = start_shift;
   double best_value = Bar.LowValue(start_shift);

   for(int i = start_shift + 1; i < start_shift + length; i++)
   {
      double v = Bar.LowValue(i);
      if(v < best_value)
      {
         best_value = v;
         best_shift = i;
      }
   }

   return best_shift;
}

double ManualAverageBody(const int start_shift, const int length)
{
   double sum = 0.0;

   for(int i = start_shift; i < start_shift + length; i++)
      sum += Bar.BodyPrice(i);

   return sum / length;
}

double ManualAverageRange(const int start_shift, const int length)
{
   double sum = 0.0;

   for(int i = start_shift; i < start_shift + length; i++)
      sum += Bar.RangePrice(i);

   return sum / length;
}

int ManualBullCount(const int start_shift, const int length)
{
   int count = 0;

   for(int i = start_shift; i < start_shift + length; i++)
   {
      if(Bar.IsBull(i))
         count++;
   }

   return count;
}

int ManualBearCount(const int start_shift, const int length)
{
   int count = 0;

   for(int i = start_shift; i < start_shift + length; i++)
   {
      if(Bar.IsBear(i))
         count++;
   }

   return count;
}

int ManualDojiCount(const int start_shift, const int length)
{
   int count = 0;

   for(int i = start_shift; i < start_shift + length; i++)
   {
      if(Bar.IsDoji(i))
         count++;
   }

   return count;
}

int OnInit()
{
   Print("=== BossR_Series Verification Started ===");

   Check(!Series.IsInitialized(), "Initial state is not initialized");

   Check(Series.Init(), "Series Init current symbol and timeframe");

   Check(Bar.Init(), "Bar Init current symbol and timeframe");

   Check(Series.IsInitialized(), "Series initialized after Init");

   Check(Series.SymbolName() == Symbol(), "SymbolName equals chart symbol");

   Check(Series.Timeframe() == Period(), "Timeframe equals chart period");

   Check(Series.Count() > 0, "Count > 0");

   Check(Series.HasClosedBars(1), "HasClosedBars 1 true");

   Check(Series.HasClosedBars(2), "HasClosedBars 2 true");

   Check(!Series.HasClosedBars(0), "HasClosedBars 0 false");

   Check(!Series.HasClosedBars(-1), "HasClosedBars negative false");

   Check(Series.IsValidClosedWindow(1, 1), "Closed window 1,1 valid");

   Check(Series.IsValidClosedWindow(1, 2), "Closed window 1,2 valid");

   Check(!Series.IsValidClosedWindow(0, 1), "Closed window shift 0 invalid");

   Check(!Series.IsValidClosedWindow(-1, 1), "Closed window negative shift invalid");

   Check(!Series.IsValidClosedWindow(1, 0), "Closed window zero length invalid");

   Check(!Series.IsValidClosedWindow(1, -1), "Closed window negative length invalid");

   Check(!Series.IsValidClosedWindow(Series.Count(), 1), "Closed window shift Count invalid");

   Check(!Series.IsValidClosedWindow(Series.Count() - 1, 2), "Closed window beyond Count invalid");

   int start_shift = 1;
   int length = 10;

   if(!Series.IsValidClosedWindow(start_shift, length))
   {
      Fail("Enough closed bars for main window");
      Print("=== BossR_Series Verification Complete ===");
      Print("PASS ", g_pass, " / FAIL ", g_fail);
      return INIT_SUCCEEDED;
   }

   Pass("Enough closed bars for main window");

   int hh_shift_manual = ManualHighestHighShift(start_shift, length);
   int ll_shift_manual = ManualLowestLowShift(start_shift, length);

   Check(Series.HighestHighShift(start_shift, length) == hh_shift_manual, "HighestHighShift correct");

   Check(Series.LowestLowShift(start_shift, length) == ll_shift_manual, "LowestLowShift correct");

   Check(NearlyEqual(Series.HighestHigh(start_shift, length), Bar.HighValue(hh_shift_manual)), "HighestHigh correct");

   Check(NearlyEqual(Series.LowestLow(start_shift, length), Bar.LowValue(ll_shift_manual)), "LowestLow correct");

   Check(NearlyEqual(Series.WindowRange(start_shift, length), Series.HighestHigh(start_shift, length) - Series.LowestLow(start_shift, length)), "WindowRange correct");

   Check(Series.WindowRange(start_shift, length) >= 0.0, "WindowRange >= 0");

   Check(NearlyEqual(Series.AverageBody(start_shift, length), ManualAverageBody(start_shift, length)), "AverageBody correct");

   Check(NearlyEqual(Series.AverageRange(start_shift, length), ManualAverageRange(start_shift, length)), "AverageRange correct");

   Check(Series.AverageBody(start_shift, length) >= 0.0, "AverageBody >= 0");

   Check(Series.AverageRange(start_shift, length) >= 0.0, "AverageRange >= 0");

   int bull_manual = ManualBullCount(start_shift, length);
   int bear_manual = ManualBearCount(start_shift, length);
   int doji_manual = ManualDojiCount(start_shift, length);

   Check(Series.BullCount(start_shift, length) == bull_manual, "BullCount correct");

   Check(Series.BearCount(start_shift, length) == bear_manual, "BearCount correct");

   Check(Series.DojiCount(start_shift, length) == doji_manual, "DojiCount correct");

   Check(Series.BullCount(start_shift, length) + Series.BearCount(start_shift, length) + Series.DojiCount(start_shift, length) == length, "Bull+Bear+Doji equals length");

   Check(Series.AllBull(start_shift, length) == (bull_manual == length), "AllBull correct");

   Check(Series.AllBear(start_shift, length) == (bear_manual == length), "AllBear correct");

   Check(Series.ContainsBull(start_shift, length) == (bull_manual > 0), "ContainsBull correct");

   Check(Series.ContainsBear(start_shift, length) == (bear_manual > 0), "ContainsBear correct");

   Check(Series.HighestHighShift(0, 1) == -1, "HighestHighShift rejects shift 0");

   Check(Series.LowestLowShift(0, 1) == -1, "LowestLowShift rejects shift 0");

   Check(Series.HighestHigh(0, 1) == 0.0, "HighestHigh invalid returns 0");

   Check(Series.LowestLow(0, 1) == 0.0, "LowestLow invalid returns 0");

   Check(Series.WindowRange(0, 1) == 0.0, "WindowRange invalid returns 0");

   Check(Series.AverageBody(0, 1) == 0.0, "AverageBody invalid returns 0");

   Check(Series.AverageRange(0, 1) == 0.0, "AverageRange invalid returns 0");

   Check(Series.BullCount(0, 1) == 0, "BullCount invalid returns 0");

   Check(Series.BearCount(0, 1) == 0, "BearCount invalid returns 0");

   Check(Series.DojiCount(0, 1) == 0, "DojiCount invalid returns 0");

   Check(!Series.AllBull(0, 1), "AllBull invalid false");

   Check(!Series.AllBear(0, 1), "AllBear invalid false");

   Check(!Series.ContainsBull(0, 1), "ContainsBull invalid false");

   Check(!Series.ContainsBear(0, 1), "ContainsBear invalid false");

   Series.Shutdown();

   Check(!Series.IsInitialized(), "Shutdown clears initialized state");

   Check(Series.SymbolName() == "", "Shutdown clears symbol");

   Check(Series.Timeframe() == 0, "Shutdown clears timeframe");

   Check(Series.Count() == 0, "Count returns 0 after shutdown");

   Check(!Series.HasClosedBars(1), "HasClosedBars false after shutdown");

   Check(!Series.IsValidClosedWindow(1, 1), "Closed window invalid after shutdown");

   Check(Series.HighestHighShift(1, 1) == -1, "HighestHighShift returns -1 after shutdown");

   Check(Series.LowestLowShift(1, 1) == -1, "LowestLowShift returns -1 after shutdown");

   Check(Series.HighestHigh(1, 1) == 0.0, "HighestHigh returns 0 after shutdown");

   Check(Series.LowestLow(1, 1) == 0.0, "LowestLow returns 0 after shutdown");

   Check(Series.WindowRange(1, 1) == 0.0, "WindowRange returns 0 after shutdown");

   Check(Series.AverageBody(1, 1) == 0.0, "AverageBody returns 0 after shutdown");

   Check(Series.AverageRange(1, 1) == 0.0, "AverageRange returns 0 after shutdown");

   Check(Series.BullCount(1, 1) == 0, "BullCount returns 0 after shutdown");

   Check(Series.BearCount(1, 1) == 0, "BearCount returns 0 after shutdown");

   Check(Series.DojiCount(1, 1) == 0, "DojiCount returns 0 after shutdown");

   Check(!Series.AllBull(1, 1), "AllBull false after shutdown");

   Check(!Series.AllBear(1, 1), "AllBear false after shutdown");

   Check(!Series.ContainsBull(1, 1), "ContainsBull false after shutdown");

   Check(!Series.ContainsBear(1, 1), "ContainsBear false after shutdown");

   Bar.Shutdown();

   Print("=== BossR_Series Verification Complete ===");
   Print("PASS ", g_pass, " / FAIL ", g_fail);

   return INIT_SUCCEEDED;
}

void OnDeinit(const int reason)
{
}

void OnTick()
{
}