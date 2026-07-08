//+------------------------------------------------------------------+
//| BossR_Bar_Verify.mq4                                             |
//+------------------------------------------------------------------+
#property strict

#include <BossR\BossR_Bar.mqh>

C_BossR_Bar Bar;

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

int OnInit()
{
   Print("=== BossR_Bar Verification Started ===");

   Check(!Bar.IsInitialized(), "Initial state is not initialized");

   Check(Bar.Init(), "Init current symbol and timeframe");

   Check(Bar.IsInitialized(), "Initialized after Init");

   Check(Bar.SymbolName() == Symbol(), "SymbolName equals chart symbol");

   Check(Bar.Timeframe() == Period(), "Timeframe equals chart period");

   Check(Bar.Count() > 0, "Count > 0");

   Check(Bar.IsValidShift(0), "Shift 0 valid");

   Check(Bar.IsValidShift(1), "Shift 1 valid");

   Check(!Bar.IsValidShift(-1), "Negative shift invalid");

   Check(!Bar.IsValidShift(Bar.Count()), "Shift equal to Count invalid");

   Check(Bar.TimeValue(0) > 0, "TimeValue shift 0 > 0");

   Check(Bar.TimeValue(1) > 0, "TimeValue shift 1 > 0");

   Check(Bar.OpenValue(0) > 0.0, "OpenValue shift 0 > 0");

   Check(Bar.HighValue(0) > 0.0, "HighValue shift 0 > 0");

   Check(Bar.LowValue(0) > 0.0, "LowValue shift 0 > 0");

   Check(Bar.CloseValue(0) > 0.0, "CloseValue shift 0 > 0");

   Check(Bar.VolumeValue(0) >= 0, "VolumeValue shift 0 >= 0");

   Check(Bar.HasOHLC(0), "HasOHLC shift 0");

   Check(Bar.HasOHLC(1), "HasOHLC shift 1");

   double o = Bar.OpenValue(1);
   double h = Bar.HighValue(1);
   double l = Bar.LowValue(1);
   double c = Bar.CloseValue(1);

   Check(h >= l, "High >= Low");

   Check(o <= h && o >= l, "Open inside High Low");

   Check(c <= h && c >= l, "Close inside High Low");

   Check(NearlyEqual(Bar.BodyPrice(1), MathAbs(c - o)), "BodyPrice correct");

   Check(NearlyEqual(Bar.RangePrice(1), h - l), "RangePrice correct");

   Check(Bar.RangePrice(1) >= 0.0, "RangePrice >= 0");

   Check(Bar.BodyPrice(1) >= 0.0, "BodyPrice >= 0");

   Check(Bar.UpperWickPrice(1) >= 0.0, "UpperWickPrice >= 0");

   Check(Bar.LowerWickPrice(1) >= 0.0, "LowerWickPrice >= 0");

   double expected_upper = h - MathMax(o, c);
   double expected_lower = MathMin(o, c) - l;

   Check(NearlyEqual(Bar.UpperWickPrice(1), expected_upper), "UpperWickPrice correct");

   Check(NearlyEqual(Bar.LowerWickPrice(1), expected_lower), "LowerWickPrice correct");

   Check(NearlyEqual(Bar.MidPrice(1), (h + l) * 0.5), "MidPrice correct");

   Check(NearlyEqual(Bar.HL2(1), (h + l) * 0.5), "HL2 correct");

   Check(NearlyEqual(Bar.OC2(1), (o + c) * 0.5), "OC2 correct");

   Check(NearlyEqual(Bar.HLC3(1), (h + l + c) / 3.0), "HLC3 correct");

   if(c > o)
   {
      Check(Bar.IsBull(1), "IsBull true on bull bar");
      Check(!Bar.IsBear(1), "IsBear false on bull bar");
      Check(!Bar.IsDoji(1), "IsDoji false on bull bar");
   }
   else if(c < o)
   {
      Check(Bar.IsBear(1), "IsBear true on bear bar");
      Check(!Bar.IsBull(1), "IsBull false on bear bar");
      Check(!Bar.IsDoji(1), "IsDoji false on bear bar");
   }
   else
   {
      Check(Bar.IsDoji(1), "IsDoji true on doji bar");
      Check(!Bar.IsBull(1), "IsBull false on doji bar");
      Check(!Bar.IsBear(1), "IsBear false on doji bar");
   }

   Check(!Bar.IsClosedBar(0), "Shift 0 is not closed bar");

   Check(Bar.IsClosedBar(1), "Shift 1 is closed bar");

   Check(Bar.TimeValue(-1) == 0, "TimeValue invalid shift returns 0");

   Check(Bar.OpenValue(-1) == 0.0, "OpenValue invalid shift returns 0");

   Check(Bar.HighValue(-1) == 0.0, "HighValue invalid shift returns 0");

   Check(Bar.LowValue(-1) == 0.0, "LowValue invalid shift returns 0");

   Check(Bar.CloseValue(-1) == 0.0, "CloseValue invalid shift returns 0");

   Check(Bar.VolumeValue(-1) == 0, "VolumeValue invalid shift returns 0");

   Check(!Bar.HasOHLC(-1), "HasOHLC invalid shift false");

   Check(!Bar.IsBull(-1), "IsBull invalid shift false");

   Check(!Bar.IsBear(-1), "IsBear invalid shift false");

   Check(!Bar.IsDoji(-1), "IsDoji invalid shift false");

   Check(Bar.BodyPrice(-1) == 0.0, "BodyPrice invalid shift returns 0");

   Check(Bar.RangePrice(-1) == 0.0, "RangePrice invalid shift returns 0");

   Check(Bar.UpperWickPrice(-1) == 0.0, "UpperWickPrice invalid shift returns 0");

   Check(Bar.LowerWickPrice(-1) == 0.0, "LowerWickPrice invalid shift returns 0");

   Check(Bar.MidPrice(-1) == 0.0, "MidPrice invalid shift returns 0");

   Check(Bar.HL2(-1) == 0.0, "HL2 invalid shift returns 0");

   Check(Bar.OC2(-1) == 0.0, "OC2 invalid shift returns 0");

   Check(Bar.HLC3(-1) == 0.0, "HLC3 invalid shift returns 0");

   Check(!Bar.IsClosedBar(-1), "IsClosedBar invalid shift false");

   Bar.Shutdown();

   Check(!Bar.IsInitialized(), "Shutdown clears initialized state");

   Check(Bar.SymbolName() == "", "Shutdown clears symbol");

   Check(Bar.Timeframe() == 0, "Shutdown clears timeframe");

   Check(Bar.Count() == 0, "Count returns 0 after shutdown");

   Check(!Bar.IsValidShift(0), "Shift invalid after shutdown");

   Check(Bar.TimeValue(0) == 0, "TimeValue returns 0 after shutdown");

   Check(Bar.OpenValue(0) == 0.0, "OpenValue returns 0 after shutdown");

   Check(Bar.HighValue(0) == 0.0, "HighValue returns 0 after shutdown");

   Check(Bar.LowValue(0) == 0.0, "LowValue returns 0 after shutdown");

   Check(Bar.CloseValue(0) == 0.0, "CloseValue returns 0 after shutdown");

   Check(Bar.VolumeValue(0) == 0, "VolumeValue returns 0 after shutdown");

   Check(!Bar.HasOHLC(0), "HasOHLC false after shutdown");

   Check(!Bar.IsClosedBar(1), "IsClosedBar false after shutdown");

   Print("=== BossR_Bar Verification Complete ===");
   Print("PASS ", g_pass, " / FAIL ", g_fail);

   return INIT_SUCCEEDED;
}

void OnDeinit(const int reason)
{
}

void OnTick()
{
}