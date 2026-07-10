//+------------------------------------------------------------------+
//| BossR_Indicator_Verify_Block6.mq4                                |
//| BossR Framework - Indicator Block 6 Verification                 |
//+------------------------------------------------------------------+
#property strict

#include <BossR\BossR_Indicator.mqh>

C_BossR_Indicator BossIndicator;

int g_pass = 0;
int g_fail = 0;

void Pass(const string name)
{
   g_pass++;
   Print("PASS: ", name);
}

void Fail(const string name)
{
   g_fail++;
   Print("FAIL: ", name);
}

void ExpectBool(
   const string name,
   const bool actual,
   const bool expected
)
{
   if(actual == expected)
   {
      Pass(name);
      return;
   }

   Fail(name);
   Print(
      "   actual=",
      actual ? "true" : "false",
      " expected=",
      expected ? "true" : "false"
   );
}

void ExpectInt(
   const string name,
   const int actual,
   const int expected
)
{
   if(actual == expected)
   {
      Pass(name);
      return;
   }

   Fail(name);
   Print("   actual=", actual, " expected=", expected);
}

void ExpectString(
   const string name,
   const string actual,
   const string expected
)
{
   if(actual == expected)
   {
      Pass(name);
      return;
   }

   Fail(name);
   Print("   actual=[", actual, "] expected=[", expected, "]");
}

void ExpectDouble(
   const string name,
   const double actual,
   const double expected,
   const double epsilon = 0.0000000001
)
{
   if(MathAbs(actual - expected) <= epsilon)
   {
      Pass(name);
      return;
   }

   Fail(name);
   Print(
      "   actual=",
      DoubleToString(actual, 10),
      " expected=",
      DoubleToString(expected, 10)
   );
}

int OnInit()
{
   Print("=== BossR_Indicator Block 6 Verification Started ===");

   ExpectBool("Constructor initialized false",
              BossIndicator.IsInitialized(), false);
   ExpectBool("Constructor configured false",
              BossIndicator.IsConfigured(), false);
   ExpectString("Constructor symbol current chart",
                BossIndicator.GetSymbol(), Symbol());
   ExpectInt("Constructor timeframe current chart",
             (int)BossIndicator.GetTimeframe(), Period());

   ExpectBool("Initialize current chart",
              BossIndicator.Initialize(), true);
   ExpectBool("Initialized true",
              BossIndicator.IsInitialized(), true);
   ExpectBool("Configured true",
              BossIndicator.IsConfigured(), true);

   int shift = 1;
   if(BossIndicator.BarsCount() <= shift + 1)
      shift = 0;

   double o = iOpen(Symbol(), Period(), shift);
   double h = iHigh(Symbol(), Period(), shift);
   double l = iLow(Symbol(), Period(), shift);
   double c = iClose(Symbol(), Period(), shift);

   int previous_shift = shift + 1;
   bool has_previous = BossIndicator.IsValidShift(previous_shift);

   double previous_close = 0.0;
   if(has_previous)
      previous_close = iClose(Symbol(), Period(), previous_shift);

   double range = h - l;
   double expected_true_range = range;
   double expected_gap = 0.0;
   double expected_gap_percent = 0.0;
   double expected_close_change = 0.0;
   double expected_close_change_percent = 0.0;

   if(has_previous)
   {
      expected_true_range = MathMax(
         range,
         MathMax(
            MathAbs(h - previous_close),
            MathAbs(l - previous_close)
         )
      );

      expected_gap = o - previous_close;
      expected_close_change = c - previous_close;

      if(previous_close != 0.0)
      {
         expected_gap_percent =
            (expected_gap / previous_close) * 100.0;
         expected_close_change_percent =
            (expected_close_change / previous_close) * 100.0;
      }
   }

   double expected_midpoint_position = 0.0;
   if(range > 0.0)
   {
      double midpoint = (o + c) / 2.0;
      expected_midpoint_position = (midpoint - l) / range;
   }

   // Block 5 regression checks
   double body = MathAbs(c - o);
   double upper = h - MathMax(o, c);
   double lower = MathMin(o, c) - l;

   ExpectDouble("Regression signed body",
                BossIndicator.GetSignedBody(shift), c - o);

   if(range > 0.0)
   {
      ExpectDouble("Regression body ratio",
                   BossIndicator.GetBodyRatio(shift),
                   body / range);
      ExpectDouble("Regression upper wick ratio",
                   BossIndicator.GetUpperWickRatio(shift),
                   upper / range);
      ExpectDouble("Regression lower wick ratio",
                   BossIndicator.GetLowerWickRatio(shift),
                   lower / range);
      ExpectDouble("Regression close position",
                   BossIndicator.GetClosePosition(shift),
                   (c - l) / range);
   }

   // Block 6
   ExpectDouble("Block6 true range",
                BossIndicator.GetTrueRange(shift),
                expected_true_range);

   ExpectDouble("Block6 gap",
                BossIndicator.GetGap(shift),
                expected_gap);

   ExpectDouble("Block6 gap percent",
                BossIndicator.GetGapPercent(shift),
                expected_gap_percent);

   ExpectBool("Block6 gap up",
              BossIndicator.IsGapUp(shift),
              expected_gap > 0.0);

   ExpectBool("Block6 gap down",
              BossIndicator.IsGapDown(shift),
              expected_gap < 0.0);

   ExpectDouble("Block6 midpoint position",
                BossIndicator.GetMidpointPosition(shift),
                expected_midpoint_position);

   ExpectDouble("Block6 midpoint percent",
                BossIndicator.GetMidpointPositionPercent(shift),
                expected_midpoint_position * 100.0);

   ExpectDouble("Block6 close change",
                BossIndicator.GetCloseChange(shift),
                expected_close_change);

   ExpectDouble("Block6 close change percent",
                BossIndicator.GetCloseChangePercent(shift),
                expected_close_change_percent);

   if(range > 0.0)
   {
      ExpectBool("Block6 midpoint bounded",
                 BossIndicator.GetMidpointPosition(shift) >= 0.0
                 && BossIndicator.GetMidpointPosition(shift) <= 1.0,
                 true);
   }

   ExpectBool("Block6 true range covers range",
              BossIndicator.GetTrueRange(shift)
              + 0.0000000001 >= BossIndicator.GetRange(shift),
              true);

   int oldest_shift = BossIndicator.BarsCount() - 1;

   if(oldest_shift >= 0)
   {
      ExpectDouble("Block6 oldest gap zero",
                   BossIndicator.GetGap(oldest_shift), 0.0);
      ExpectDouble("Block6 oldest gap percent zero",
                   BossIndicator.GetGapPercent(oldest_shift), 0.0);
      ExpectBool("Block6 oldest gap up false",
                 BossIndicator.IsGapUp(oldest_shift), false);
      ExpectBool("Block6 oldest gap down false",
                 BossIndicator.IsGapDown(oldest_shift), false);
      ExpectDouble("Block6 oldest close change zero",
                   BossIndicator.GetCloseChange(oldest_shift), 0.0);
      ExpectDouble("Block6 oldest close percent zero",
                   BossIndicator.GetCloseChangePercent(oldest_shift), 0.0);
      ExpectDouble("Block6 oldest true range raw range",
                   BossIndicator.GetTrueRange(oldest_shift),
                   BossIndicator.GetRange(oldest_shift));
   }

   int invalid_shift = BossIndicator.BarsCount();

   ExpectDouble("Block6 invalid true range zero",
                BossIndicator.GetTrueRange(invalid_shift), 0.0);
   ExpectDouble("Block6 invalid gap zero",
                BossIndicator.GetGap(invalid_shift), 0.0);
   ExpectDouble("Block6 invalid gap percent zero",
                BossIndicator.GetGapPercent(invalid_shift), 0.0);
   ExpectBool("Block6 invalid gap up false",
              BossIndicator.IsGapUp(invalid_shift), false);
   ExpectBool("Block6 invalid gap down false",
              BossIndicator.IsGapDown(invalid_shift), false);
   ExpectDouble("Block6 invalid midpoint zero",
                BossIndicator.GetMidpointPosition(invalid_shift), 0.0);
   ExpectDouble("Block6 invalid midpoint percent zero",
                BossIndicator.GetMidpointPositionPercent(invalid_shift), 0.0);
   ExpectDouble("Block6 invalid close change zero",
                BossIndicator.GetCloseChange(invalid_shift), 0.0);
   ExpectDouble("Block6 invalid close percent zero",
                BossIndicator.GetCloseChangePercent(invalid_shift), 0.0);

   ExpectDouble("Block6 negative true range zero",
                BossIndicator.GetTrueRange(-1), 0.0);
   ExpectDouble("Block6 negative gap zero",
                BossIndicator.GetGap(-1), 0.0);
   ExpectDouble("Block6 negative midpoint zero",
                BossIndicator.GetMidpointPosition(-1), 0.0);
   ExpectDouble("Block6 negative close change zero",
                BossIndicator.GetCloseChange(-1), 0.0);

   // Alternate timeframe
   ExpectBool("Block6 set M5",
              BossIndicator.SetTimeframe(PERIOD_M5), true);

   int m5_shift = 1;
   if(BossIndicator.BarsCount() <= m5_shift + 1)
      m5_shift = 0;

   double m5_h = iHigh(Symbol(), PERIOD_M5, m5_shift);
   double m5_l = iLow(Symbol(), PERIOD_M5, m5_shift);
   double m5_range = m5_h - m5_l;

   int m5_previous_shift = m5_shift + 1;
   double m5_expected_true_range = m5_range;

   if(BossIndicator.IsValidShift(m5_previous_shift))
   {
      double m5_previous_close =
         iClose(Symbol(), PERIOD_M5, m5_previous_shift);

      m5_expected_true_range = MathMax(
         m5_range,
         MathMax(
            MathAbs(m5_h - m5_previous_close),
            MathAbs(m5_l - m5_previous_close)
         )
      );
   }

   ExpectDouble("Block6 M5 true range",
                BossIndicator.GetTrueRange(m5_shift),
                m5_expected_true_range);

   BossIndicator.Shutdown();

   ExpectBool("Shutdown initialized false",
              BossIndicator.IsInitialized(), false);
   ExpectBool("Shutdown configured false",
              BossIndicator.IsConfigured(), false);
   ExpectBool("Shutdown series not ready",
              BossIndicator.IsSeriesReady(), false);
   ExpectBool("Shutdown BarsCount accessible",
              BossIndicator.BarsCount() > 0, true);

   BossIndicator.Reset();

   ExpectBool("Reset initialized false",
              BossIndicator.IsInitialized(), false);
   ExpectString("Reset symbol current chart",
                BossIndicator.GetSymbol(), Symbol());
   ExpectInt("Reset timeframe current chart",
             (int)BossIndicator.GetTimeframe(), Period());

   Print("=== BossR_Indicator Block 6 Verification Complete ===");
   Print("PASS ", g_pass, " / FAIL ", g_fail);

   return INIT_SUCCEEDED;
}

void OnDeinit(const int reason)
{
}

void OnTick()
{
}
