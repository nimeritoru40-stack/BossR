//+------------------------------------------------------------------+
//| BossR_Candle_Verify_Block6_STRUCTURE_FULL.mq4                    |
//| BossR Framework - BossR_Candle Block 6 verifier                  |
//| Compile and execute this EA only                                 |
//| MT4 only                                                         |
//+------------------------------------------------------------------+
#property strict

#include <BossR\BossR_Candle_Block6_STRUCTURE_FULL.mqh>

C_BossR_Candle_Block6 BossCandle;

int g_pass = 0;
int g_fail = 0;

void Pass(const string test_name)
{
   g_pass++;
   Print("PASS: ", test_name);
}

void Fail(const string test_name)
{
   g_fail++;
   Print("FAIL: ", test_name);
}

void ExpectBool(const string test_name,
                const bool actual,
                const bool expected)
{
   if(actual == expected)
   {
      Pass(test_name);
      return;
   }

   Fail(test_name);
   Print("   actual=", actual, " expected=", expected);
}

void ExpectDouble(const string test_name,
                  const double actual,
                  const double expected,
                  const double epsilon = 0.000000001)
{
   if(MathAbs(actual - expected) <= epsilon)
   {
      Pass(test_name);
      return;
   }

   Fail(test_name);
   Print("   actual=", DoubleToString(actual, 12),
         " expected=", DoubleToString(expected, 12));
}

void TestInheritedBlock5()
{
   ExpectBool("Inherited morning star",
              BossCandle.IsMorningStar(
                 1.1060, 1.1070, 1.0990, 1.1000,
                 1.0995, 1.1010, 1.0985, 1.1000,
                 1.1000, 1.1050, 1.0995, 1.1035),
              true);

   ExpectBool("Inherited three white soldiers",
              BossCandle.IsThreeWhiteSoldiers(
                 1.1000, 1.1045, 1.0995, 1.1040,
                 1.1020, 1.1065, 1.1015, 1.1060,
                 1.1040, 1.1085, 1.1035, 1.1080),
              true);

   ExpectBool("Inherited three inside up",
              BossCandle.IsThreeInsideUp(
                 1.1060, 1.1000,
                 1.1010, 1.1040,
                 1.1040, 1.1070),
              true);

   ExpectBool("Inherited falling closes",
              BossCandle.AreClosesFalling(1.1030, 1.1020, 1.1010),
              true);
}

void TestRangeRelationships()
{
   ExpectBool("Range expansion true",
              BossCandle.IsRangeExpansion(
                 1.1050, 1.1000,
                 1.1080, 1.0980,
                 2.0),
              true);

   ExpectBool("Range expansion rejects small",
              BossCandle.IsRangeExpansion(
                 1.1050, 1.1000,
                 1.1060, 1.1000,
                 1.5),
              false);

   ExpectBool("Range expansion zero reference false",
              BossCandle.IsRangeExpansion(
                 1.1000, 1.1000,
                 1.1060, 1.1000),
              false);

   ExpectBool("Range contraction true",
              BossCandle.IsRangeContraction(
                 1.1100, 1.1000,
                 1.1070, 1.1020,
                 0.5),
              true);

   ExpectBool("Range contraction rejects large",
              BossCandle.IsRangeContraction(
                 1.1100, 1.1000,
                 1.1090, 1.1010,
                 0.5),
              false);

   ExpectDouble("Range multiple",
                BossCandle.RangeMultiple(
                   1.1050, 1.1000,
                   1.1100, 1.1000),
                2.0);

   ExpectDouble("Range multiple zero reference",
                BossCandle.RangeMultiple(
                   1.1000, 1.1000,
                   1.1100, 1.1000),
                0.0);
}

void TestOverlap()
{
   ExpectDouble("Price overlap partial",
                BossCandle.PriceOverlap(
                   1.1100, 1.1000,
                   1.1150, 1.1050),
                0.0050);

   ExpectDouble("Price overlap none",
                BossCandle.PriceOverlap(
                   1.1050, 1.1000,
                   1.1150, 1.1100),
                0.0);

   ExpectDouble("Price overlap contained",
                BossCandle.PriceOverlap(
                   1.1100, 1.1000,
                   1.1080, 1.1020),
                0.0060);

   ExpectDouble("Overlap ratio half",
                BossCandle.PriceOverlapRatio(
                   1.1100, 1.1000,
                   1.1150, 1.1050),
                0.5);

   ExpectDouble("Overlap ratio contained",
                BossCandle.PriceOverlapRatio(
                   1.1100, 1.1000,
                   1.1080, 1.1020),
                1.0);

   ExpectBool("Minimum overlap true",
              BossCandle.HasMinimumPriceOverlap(
                 1.1100, 1.1000,
                 1.1150, 1.1050,
                 0.5),
              true);

   ExpectBool("Minimum overlap false",
              BossCandle.HasMinimumPriceOverlap(
                 1.1100, 1.1000,
                 1.1150, 1.1050,
                 0.6),
              false);
}

void TestFairValueGaps()
{
   ExpectBool("Bullish FVG true",
              BossCandle.IsBullishFairValueGap(
                 1.1050, 1.1060),
              true);

   ExpectBool("Bullish FVG touching false",
              BossCandle.IsBullishFairValueGap(
                 1.1050, 1.1050),
              false);

   ExpectBool("Bullish FVG minimum gap true",
              BossCandle.IsBullishFairValueGap(
                 1.1050, 1.1070, 0.0010),
              true);

   ExpectBool("Bullish FVG minimum gap false",
              BossCandle.IsBullishFairValueGap(
                 1.1050, 1.1055, 0.0010),
              false);

   ExpectDouble("Bullish FVG size",
                BossCandle.BullishFairValueGapSize(
                   1.1050, 1.1075),
                0.0025);

   ExpectBool("Bearish FVG true",
              BossCandle.IsBearishFairValueGap(
                 1.1000, 1.0990),
              true);

   ExpectBool("Bearish FVG touching false",
              BossCandle.IsBearishFairValueGap(
                 1.1000, 1.1000),
              false);

   ExpectDouble("Bearish FVG size",
                BossCandle.BearishFairValueGapSize(
                   1.1000, 1.0975),
                0.0025);

   ExpectDouble("Bearish FVG no gap size zero",
                BossCandle.BearishFairValueGapSize(
                   1.1000, 1.1010),
                0.0);
}

void TestLiquiditySweeps()
{
   ExpectBool("Bullish liquidity sweep true",
              BossCandle.IsBullishLiquiditySweep(
                 1.1000,
                 1.1010, 1.1030, 1.0980, 1.1015),
              true);

   ExpectBool("Bullish sweep closes below false",
              BossCandle.IsBullishLiquiditySweep(
                 1.1000,
                 1.1010, 1.1030, 1.0980, 1.0995),
              false);

   ExpectBool("Bullish sweep no penetration false",
              BossCandle.IsBullishLiquiditySweep(
                 1.1000,
                 1.1010, 1.1030, 1.1000, 1.1015),
              false);

   ExpectBool("Bullish sweep minimum penetration true",
              BossCandle.IsBullishLiquiditySweep(
                 1.1000,
                 1.1010, 1.1030, 1.0980, 1.1015,
                 0.0010),
              true);

   ExpectBool("Bearish liquidity sweep true",
              BossCandle.IsBearishLiquiditySweep(
                 1.1100,
                 1.1090, 1.1120, 1.1070, 1.1085),
              true);

   ExpectBool("Bearish sweep closes above false",
              BossCandle.IsBearishLiquiditySweep(
                 1.1100,
                 1.1090, 1.1120, 1.1070, 1.1105),
              false);

   ExpectBool("Bearish sweep invalid candle false",
              BossCandle.IsBearishLiquiditySweep(
                 1.1100,
                 1.1090, 1.1070, 1.1120, 1.1085),
              false);
}

void TestDisplacement()
{
   ExpectBool("Bullish displacement true",
              BossCandle.IsBullishDisplacement(
                 1.1000, 1.1080, 1.0990, 1.1070,
                 0.0050),
              true);

   ExpectBool("Bullish displacement wrong direction",
              BossCandle.IsBullishDisplacement(
                 1.1070, 1.1080, 1.0990, 1.1000,
                 0.0050),
              false);

   ExpectBool("Bullish displacement insufficient range",
              BossCandle.IsBullishDisplacement(
                 1.1000, 1.1060, 1.0990, 1.1050,
                 0.0050),
              false);

   ExpectBool("Bullish displacement long upper wick",
              BossCandle.IsBullishDisplacement(
                 1.1000, 1.1120, 1.0990, 1.1070,
                 0.0050),
              false);

   ExpectBool("Bearish displacement true",
              BossCandle.IsBearishDisplacement(
                 1.1070, 1.1080, 1.0990, 1.1000,
                 0.0050),
              true);

   ExpectBool("Bearish displacement wrong direction",
              BossCandle.IsBearishDisplacement(
                 1.1000, 1.1080, 1.0990, 1.1070,
                 0.0050),
              false);

   ExpectBool("Bearish displacement long lower wick",
              BossCandle.IsBearishDisplacement(
                 1.1070, 1.1080, 1.0950, 1.1000,
                 0.0050),
              false);

   ExpectBool("Displacement zero reference false",
              BossCandle.IsBullishDisplacement(
                 1.1000, 1.1080, 1.0990, 1.1070,
                 0.0),
              false);
}

void TestBreakouts()
{
   ExpectBool("Close above range true",
              BossCandle.ClosesAboveRange(
                 1.1110, 1.1100),
              true);

   ExpectBool("Close above touching false",
              BossCandle.ClosesAboveRange(
                 1.1100, 1.1100),
              false);

   ExpectBool("Close below range true",
              BossCandle.ClosesBelowRange(
                 1.0990, 1.1000),
              true);

   ExpectBool("Bullish outside breakout true",
              BossCandle.IsBullishOutsideBreakout(
                 1.1100, 1.1000,
                 1.1050, 1.1120, 1.0980, 1.1110),
              true);

   ExpectBool("Bullish outside breakout close inside false",
              BossCandle.IsBullishOutsideBreakout(
                 1.1100, 1.1000,
                 1.1050, 1.1120, 1.0980, 1.1090),
              false);

   ExpectBool("Bearish outside breakout true",
              BossCandle.IsBearishOutsideBreakout(
                 1.1100, 1.1000,
                 1.1050, 1.1120, 1.0980, 1.0990),
              true);

   ExpectBool("Bearish outside breakout not outside false",
              BossCandle.IsBearishOutsideBreakout(
                 1.1100, 1.1000,
                 1.1050, 1.1090, 1.0980, 1.0990),
              false);
}

void TestRuntime()
{
   int bars = iBars(Symbol(), Period());

   ExpectBool("Runtime enough bars", bars > 3, true);

   if(bars <= 3)
      return;

   double high_1 = iHigh(Symbol(), Period(), 3);
   double low_1  = iLow(Symbol(), Period(), 3);

   double open_2  = iOpen(Symbol(), Period(), 2);
   double high_2  = iHigh(Symbol(), Period(), 2);
   double low_2   = iLow(Symbol(), Period(), 2);
   double close_2 = iClose(Symbol(), Period(), 2);

   double high_3 = iHigh(Symbol(), Period(), 1);
   double low_3  = iLow(Symbol(), Period(), 1);

   ExpectBool("Runtime middle candle valid",
              BossCandle.IsValid(open_2, high_2,
                                 low_2, close_2),
              true);

   double overlap = BossCandle.PriceOverlap(
      high_1, low_1,
      high_2, low_2);

   ExpectBool("Runtime overlap nonnegative",
              overlap >= 0.0,
              true);

   double multiple = BossCandle.RangeMultiple(
      high_1, low_1,
      high_2, low_2);

   ExpectBool("Runtime range multiple nonnegative",
              multiple >= 0.0,
              true);

   bool bullish_fvg = BossCandle.IsBullishFairValueGap(
      high_1, low_3);

   bool bearish_fvg = BossCandle.IsBearishFairValueGap(
      low_1, high_3);

   ExpectBool("Runtime opposing FVG mutually exclusive",
              bullish_fvg && bearish_fvg,
              false);
}

int OnInit()
{
   Print("==================================================");
   Print("BossR_Candle Block 6 Verification Started");
   Print("Symbol=", Symbol(), " Period=", Period());
   Print("==================================================");

   TestInheritedBlock5();
   TestRangeRelationships();
   TestOverlap();
   TestFairValueGaps();
   TestLiquiditySweeps();
   TestDisplacement();
   TestBreakouts();
   TestRuntime();

   Print("==================================================");
   Print("BossR_Candle_Verify_Block6_STRUCTURE_FULL COMPLETE");
   Print("PASS ", g_pass, " / FAIL ", g_fail);
   Print("==================================================");

   if(g_fail > 0)
      return(INIT_FAILED);

   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{
}

void OnTick()
{
}
