//+------------------------------------------------------------------+
//| BossR_Filter_Verify_Block6_VOLUME_FULL.mq4                       |
//| BossR Framework - Filter Module Verifier                         |
//| Block 6 runtime verification                                     |
//| MT4 only                                                         |
//+------------------------------------------------------------------+
#property strict

#include <BossR\BossR_Filter_Block6_VOLUME_FULL.mqh>

CBossRFilter g_filter;
int g_pass = 0;
int g_fail = 0;

void CheckBool(const string name,
               const bool actual,
               const bool expected)
{
   if(actual == expected)
      g_pass++;
   else
   {
      g_fail++;
      Print("FAIL: ", name);
      Print("   actual=", (actual ? "true" : "false"),
            " expected=", (expected ? "true" : "false"));
   }
}

void CheckInt(const string name,
              const int actual,
              const int expected)
{
   if(actual == expected)
      g_pass++;
   else
   {
      g_fail++;
      Print("FAIL: ", name);
      Print("   actual=", actual, " expected=", expected);
   }
}

void CheckLong(const string name,
               const long actual,
               const long expected)
{
   if(actual == expected)
      g_pass++;
   else
   {
      g_fail++;
      Print("FAIL: ", name);
      Print("   actual=", actual, " expected=", expected);
   }
}

void CheckDouble(const string name,
                 const double actual,
                 const double expected,
                 const double tolerance = 0.0000001)
{
   if(MathAbs(actual - expected) <= tolerance)
      g_pass++;
   else
   {
      g_fail++;
      Print("FAIL: ", name);
      Print("   actual=", DoubleToString(actual, 10),
            " expected=", DoubleToString(expected, 10));
   }
}

void CheckString(const string name,
                 const string actual,
                 const string expected)
{
   if(actual == expected)
      g_pass++;
   else
   {
      g_fail++;
      Print("FAIL: ", name);
      Print("   actual=[", actual, "] expected=[", expected, "]");
   }
}

int OnInit()
{
   const datetime t1 = StrToTime("2026.07.14 17:30:00");
   const datetime t2 = StrToTime("2026.07.14 17:31:00");
   const datetime t3 = StrToTime("2026.07.14 17:32:00");
   const datetime t4 = StrToTime("2026.07.14 17:33:00");
   const datetime monday_noon =
      StrToTime("2026.07.13 12:00:00");

   // ---------------------------------------------------------------
   // Blocks 1-5 regression
   // ---------------------------------------------------------------
   CheckBool("B1 configure",
             g_filter.Configure(" Volume Filter ", 601, true),
             true);
   CheckString("B1 name", g_filter.Name(), "Volume Filter");
   CheckBool("B1 start", g_filter.Start(), true);

   double spread = 0.0;
   CheckBool("B2 spread",
             g_filter.CalculateSpreadPips(
                1.10000, 1.10015, 0.00001, 5, spread
             ),
             true);
   CheckDouble("B2 spread value", spread, 1.5);

   CheckBool("B3 session",
             g_filter.IsTimeInsideSession(
                monday_noon, 9, 0, 17, 0
             ),
             true);

   CheckInt("B4 volatility",
            (int)g_filter.VolatilityDecision(12.0, 5.0, 20.0),
            (int)BOSSR_FILTER_DECISION_PASS);

   CheckInt("B5 trend",
            (int)g_filter.TrendDecision(
               1.1020, 1.1010, 1.1000,
               1, true, 0.0
            ),
            (int)BOSSR_FILTER_DECISION_PASS);

   // ---------------------------------------------------------------
   // Volume configuration and value validation
   // ---------------------------------------------------------------
   CheckBool("Lookback one valid",
             g_filter.IsValidVolumeLookback(1), true);
   CheckBool("Lookback twenty valid",
             g_filter.IsValidVolumeLookback(20), true);
   CheckBool("Lookback zero invalid",
             g_filter.IsValidVolumeLookback(0), false);
   CheckBool("Lookback negative invalid",
             g_filter.IsValidVolumeLookback(-1), false);

   CheckBool("Zero volume valid",
             g_filter.IsValidVolumeValue(0.0), true);
   CheckBool("Positive volume valid",
             g_filter.IsValidVolumeValue(100.0), true);
   CheckBool("Negative volume invalid",
             g_filter.IsValidVolumeValue(-1.0), false);

   // ---------------------------------------------------------------
   // Average-volume calculation
   // ---------------------------------------------------------------
   double volumes_a[5];
   volumes_a[0] = 100.0;
   volumes_a[1] = 120.0;
   volumes_a[2] = 80.0;
   volumes_a[3] = 110.0;
   volumes_a[4] = 90.0;

   double average = -1.0;

   CheckBool("Average volume valid",
             g_filter.CalculateAverageVolume(
                volumes_a, 5, average
             ),
             true);
   CheckDouble("Average volume value", average, 100.0);

   CheckBool("Average subset valid",
             g_filter.CalculateAverageVolume(
                volumes_a, 2, average
             ),
             true);
   CheckDouble("Average subset value", average, 110.0);

   CheckBool("Average zero count invalid",
             g_filter.CalculateAverageVolume(
                volumes_a, 0, average
             ),
             false);
   CheckDouble("Average reset after zero count",
               average, 0.0);

   CheckBool("Average oversized count invalid",
             g_filter.CalculateAverageVolume(
                volumes_a, 6, average
             ),
             false);

   double volumes_bad[3];
   volumes_bad[0] = 100.0;
   volumes_bad[1] = -1.0;
   volumes_bad[2] = 100.0;

   CheckBool("Average negative value invalid",
             g_filter.CalculateAverageVolume(
                volumes_bad, 3, average
             ),
             false);

   double volumes_zero[3];
   volumes_zero[0] = 0.0;
   volumes_zero[1] = 0.0;
   volumes_zero[2] = 0.0;

   CheckBool("Average zero values valid",
             g_filter.CalculateAverageVolume(
                volumes_zero, 3, average
             ),
             true);
   CheckDouble("Average zero value", average, 0.0);

   // ---------------------------------------------------------------
   // Relative-volume ratio
   // ---------------------------------------------------------------
   double ratio = -1.0;

   CheckBool("Ratio equal average",
             g_filter.CalculateVolumeRatio(
                100.0, 100.0, ratio
             ),
             true);
   CheckDouble("Ratio equal value", ratio, 1.0);

   CheckBool("Ratio above average",
             g_filter.CalculateVolumeRatio(
                150.0, 100.0, ratio
             ),
             true);
   CheckDouble("Ratio above value", ratio, 1.5);

   CheckBool("Ratio below average",
             g_filter.CalculateVolumeRatio(
                50.0, 100.0, ratio
             ),
             true);
   CheckDouble("Ratio below value", ratio, 0.5);

   CheckBool("Ratio zero current valid",
             g_filter.CalculateVolumeRatio(
                0.0, 100.0, ratio
             ),
             true);
   CheckDouble("Ratio zero current value", ratio, 0.0);

   CheckBool("Ratio zero average invalid",
             g_filter.CalculateVolumeRatio(
                100.0, 0.0, ratio
             ),
             false);
   CheckDouble("Ratio reset zero average", ratio, 0.0);

   CheckBool("Ratio negative current invalid",
             g_filter.CalculateVolumeRatio(
                -1.0, 100.0, ratio
             ),
             false);
   CheckBool("Ratio negative average invalid",
             g_filter.CalculateVolumeRatio(
                100.0, -1.0, ratio
             ),
             false);

   // ---------------------------------------------------------------
   // Pure threshold decisions
   // ---------------------------------------------------------------
   CheckInt("Below minimum fail",
            (int)g_filter.VolumeDecision(99.0, 100.0, 200.0),
            (int)BOSSR_FILTER_DECISION_FAIL);
   CheckInt("At minimum pass",
            (int)g_filter.VolumeDecision(100.0, 100.0, 200.0),
            (int)BOSSR_FILTER_DECISION_PASS);
   CheckInt("Inside limits pass",
            (int)g_filter.VolumeDecision(150.0, 100.0, 200.0),
            (int)BOSSR_FILTER_DECISION_PASS);
   CheckInt("At maximum pass",
            (int)g_filter.VolumeDecision(200.0, 100.0, 200.0),
            (int)BOSSR_FILTER_DECISION_PASS);
   CheckInt("Above maximum fail",
            (int)g_filter.VolumeDecision(201.0, 100.0, 200.0),
            (int)BOSSR_FILTER_DECISION_FAIL);
   CheckInt("No maximum pass",
            (int)g_filter.VolumeDecision(1000.0, 100.0, 0.0),
            (int)BOSSR_FILTER_DECISION_PASS);
   CheckInt("Zero thresholds pass",
            (int)g_filter.VolumeDecision(0.0, 0.0, 0.0),
            (int)BOSSR_FILTER_DECISION_PASS);
   CheckInt("Negative value unavailable",
            (int)g_filter.VolumeDecision(-1.0, 0.0, 0.0),
            (int)BOSSR_FILTER_DECISION_UNAVAILABLE);
   CheckInt("Negative minimum unavailable",
            (int)g_filter.VolumeDecision(100.0, -1.0, 0.0),
            (int)BOSSR_FILTER_DECISION_UNAVAILABLE);
   CheckInt("Negative maximum unavailable",
            (int)g_filter.VolumeDecision(100.0, 0.0, -1.0),
            (int)BOSSR_FILTER_DECISION_UNAVAILABLE);
   CheckInt("Maximum below minimum unavailable",
            (int)g_filter.VolumeDecision(100.0, 200.0, 100.0),
            (int)BOSSR_FILTER_DECISION_UNAVAILABLE);

   // ---------------------------------------------------------------
   // Deterministic recorded evaluations
   // ---------------------------------------------------------------
   CheckBool("Evaluate below minimum",
             g_filter.EvaluateVolumeValue(
                90.0, 100.0, 200.0, t1, "Volume"
             ),
             true);
   CheckBool("Below minimum fail stored",
             g_filter.Failed(), true);
   CheckString("Below minimum reason",
               g_filter.LastReason(),
               "Volume below minimum");
   CheckDouble("Below minimum value",
               g_filter.LastValue(), 90.0);

   CheckBool("Evaluate at minimum",
             g_filter.EvaluateVolumeValue(
                100.0, 100.0, 200.0, t2, "Volume"
             ),
             true);
   CheckBool("At minimum pass stored",
             g_filter.Passed(), true);

   CheckBool("Evaluate inside limits",
             g_filter.EvaluateVolumeValue(
                150.0, 100.0, 200.0, t3, "Volume"
             ),
             true);
   CheckBool("Inside limits pass stored",
             g_filter.Passed(), true);
   CheckString("Inside limits reason",
               g_filter.LastReason(),
               "Volume inside limits");

   CheckBool("Evaluate at maximum",
             g_filter.EvaluateVolumeValue(
                200.0, 100.0, 200.0, t4, "Volume"
             ),
             true);
   CheckBool("At maximum pass stored",
             g_filter.Passed(), true);

   CheckBool("Evaluate above maximum",
             g_filter.EvaluateVolumeValue(
                201.0, 100.0, 200.0, t4, "Volume"
             ),
             true);
   CheckBool("Above maximum fail stored",
             g_filter.Failed(), true);
   CheckString("Above maximum reason",
               g_filter.LastReason(),
               "Volume above maximum");

   CheckBool("Evaluate no maximum",
             g_filter.EvaluateVolumeValue(
                1000.0, 100.0, 0.0, t4, "Volume"
             ),
             true);
   CheckBool("No maximum pass stored",
             g_filter.Passed(), true);
   CheckDouble("No maximum threshold stored",
               g_filter.LastThreshold(), 0.0);

   CheckBool("Evaluate relative below minimum",
             g_filter.EvaluateVolumeValue(
                0.75, 1.0, 2.0, t4, "Relative volume"
             ),
             true);
   CheckBool("Relative below fail stored",
             g_filter.Failed(), true);
   CheckString("Relative below reason",
               g_filter.LastReason(),
               "Relative volume below minimum");

   CheckBool("Evaluate relative pass",
             g_filter.EvaluateVolumeValue(
                1.50, 1.0, 2.0, t4, "Relative volume"
             ),
             true);
   CheckBool("Relative pass stored",
             g_filter.Passed(), true);
   CheckString("Relative pass reason",
               g_filter.LastReason(),
               "Relative volume inside limits");

   CheckBool("Evaluate invalid value",
             g_filter.EvaluateVolumeValue(
                -1.0, 0.0, 0.0, t4, "Volume"
             ),
             true);
   CheckBool("Invalid value unavailable",
             g_filter.Unavailable(), true);
   CheckString("Invalid value reason",
               g_filter.LastReason(),
               "Invalid volume data");

   CheckBool("Evaluate invalid thresholds",
             g_filter.EvaluateVolumeValue(
                100.0, 200.0, 100.0, t4, "Volume"
             ),
             true);
   CheckBool("Invalid thresholds unavailable",
             g_filter.Unavailable(), true);
   CheckString("Invalid thresholds reason",
               g_filter.LastReason(),
               "Invalid volume thresholds");

   CheckLong("Evaluation total ten",
             g_filter.EvaluationCount(), 10);
   CheckLong("Pass total five",
             g_filter.PassCount(), 5);
   CheckLong("Fail total three",
             g_filter.FailCount(), 3);
   CheckLong("Unavailable total two",
             g_filter.UnavailableCount(), 2);
   CheckDouble("Pass rate fifty",
               g_filter.PassRate(), 50.0);

   // ---------------------------------------------------------------
   // Operational guards
   // ---------------------------------------------------------------
   CheckBool("Pause", g_filter.Pause(), true);
   CheckBool("Paused volume rejected",
             g_filter.EvaluateVolumeValue(
                100.0, 0.0, 0.0, t4, "Volume"
             ),
             false);
   CheckLong("Paused count unchanged",
             g_filter.EvaluationCount(), 10);
   CheckBool("Restart", g_filter.Start(), true);

   g_filter.SetEnabled(false);
   CheckBool("Disabled volume rejected",
             g_filter.EvaluateVolumeValue(
                100.0, 0.0, 0.0, t4, "Volume"
             ),
             false);
   CheckLong("Disabled count unchanged",
             g_filter.EvaluationCount(), 10);
   g_filter.SetEnabled(true);

   // ---------------------------------------------------------------
   // Invalid market-path configurations
   // ---------------------------------------------------------------
   const long before_blank = g_filter.EvaluationCount();

   CheckBool("Blank absolute symbol recorded",
             g_filter.EvaluateAbsoluteVolume(
                "   ", PERIOD_M1, 1, 0.0, 0.0, TimeCurrent()
             ),
             true);
   CheckLong("Blank absolute increment",
             g_filter.EvaluationCount(), before_blank + 1);
   CheckBool("Blank absolute unavailable",
             g_filter.Unavailable(), true);
   CheckString("Blank absolute reason",
               g_filter.LastReason(), "Invalid symbol");

   const long before_shift = g_filter.EvaluationCount();

   CheckBool("Invalid absolute shift recorded",
             g_filter.EvaluateAbsoluteVolume(
                Symbol(), PERIOD_M1, -1, 0.0, 0.0, TimeCurrent()
             ),
             true);
   CheckLong("Invalid absolute shift increment",
             g_filter.EvaluationCount(), before_shift + 1);
   CheckBool("Invalid absolute unavailable",
             g_filter.Unavailable(), true);
   CheckString("Invalid absolute reason",
               g_filter.LastReason(),
               "Invalid volume configuration");

   const long before_lookback = g_filter.EvaluationCount();

   CheckBool("Invalid relative lookback recorded",
             g_filter.EvaluateRelativeVolume(
                Symbol(), PERIOD_M1, 1, 0,
                0.0, 0.0, TimeCurrent()
             ),
             true);
   CheckLong("Invalid relative lookback increment",
             g_filter.EvaluationCount(), before_lookback + 1);
   CheckBool("Invalid relative unavailable",
             g_filter.Unavailable(), true);
   CheckString("Invalid relative reason",
               g_filter.LastReason(),
               "Invalid volume configuration");

   // ---------------------------------------------------------------
   // Live absolute-volume path
   // ---------------------------------------------------------------
   const long before_live_absolute = g_filter.EvaluationCount();

   CheckBool("Live absolute volume recorded",
             g_filter.EvaluateCurrentAbsoluteVolume(
                1, 0.0, 0.0
             ),
             true);
   CheckLong("Live absolute increment",
             g_filter.EvaluationCount(),
             before_live_absolute + 1);
   CheckBool("Live absolute decision valid",
             g_filter.LastDecision() ==
                BOSSR_FILTER_DECISION_PASS ||
             g_filter.LastDecision() ==
                BOSSR_FILTER_DECISION_UNAVAILABLE,
             true);

   if(g_filter.LastDecision() == BOSSR_FILTER_DECISION_PASS)
   {
      CheckBool("Live absolute nonnegative",
                g_filter.LastValue() >= 0.0, true);
      CheckString("Live absolute reason",
                  g_filter.LastReason(),
                  "Volume inside limits");
   }
   else
   {
      CheckBool("Live absolute unavailable reason",
                g_filter.LastReason() != "", true);
   }

   // ---------------------------------------------------------------
   // Live relative-volume path
   // ---------------------------------------------------------------
   const long before_live_relative = g_filter.EvaluationCount();

   CheckBool("Live relative volume recorded",
             g_filter.EvaluateCurrentRelativeVolume(
                1, 10, 0.0, 0.0
             ),
             true);
   CheckLong("Live relative increment",
             g_filter.EvaluationCount(),
             before_live_relative + 1);
   CheckBool("Live relative decision valid",
             g_filter.LastDecision() ==
                BOSSR_FILTER_DECISION_PASS ||
             g_filter.LastDecision() ==
                BOSSR_FILTER_DECISION_UNAVAILABLE,
             true);

   if(g_filter.LastDecision() == BOSSR_FILTER_DECISION_PASS)
   {
      CheckBool("Live relative nonnegative",
                g_filter.LastValue() >= 0.0, true);
      CheckString("Live relative reason",
                  g_filter.LastReason(),
                  "Relative volume inside limits");
   }
   else
   {
      CheckBool("Live relative unavailable reason",
                g_filter.LastReason() != "", true);
   }

   Print("BossR_Filter_Verify_Block6_VOLUME_FULL: PASS ",
         g_pass, " / FAIL ", g_fail);

   ExpertRemove();
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{
}

void OnTick()
{
}
//+------------------------------------------------------------------+
