//+------------------------------------------------------------------+
//| BossR_Filter_Verify_Block7_AGGREGATION_FIXED_FULL.mq4                  |
//| BossR Framework - Filter Module Verifier                         |
//| Block 7 runtime verification                                     |
//| MT4 only                                                         |
//+------------------------------------------------------------------+
#property strict

#include <BossR\BossR_Filter_Block7_AGGREGATION_FIXED_FULL.mqh>

CBossRFilter                  g_filter;
CBossRFilterAggregationEngine g_engine;

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
      Print("   actual=", actual,
            " expected=", expected);
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
      Print("   actual=", actual,
            " expected=", expected);
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
      Print("   actual=[", actual,
            "] expected=[", expected, "]");
   }
}

int OnInit()
{
   const datetime t1 =
      StrToTime("2026.07.14 18:00:00");
   const datetime t2 =
      StrToTime("2026.07.14 18:01:00");
   const datetime monday_noon =
      StrToTime("2026.07.13 12:00:00");

   // ---------------------------------------------------------------
   // Blocks 1-6 regression
   // ---------------------------------------------------------------
   CheckBool("B1 configure",
             g_filter.Configure(
                " Aggregation Regression ", 701, true
             ),
             true);
   CheckString("B1 name",
               g_filter.Name(),
               "Aggregation Regression");
   CheckInt("B1 id", g_filter.Id(), 701);
   CheckBool("B1 start", g_filter.Start(), true);
   CheckString("B1 running",
               g_filter.StateText(), "RUNNING");

   double spread = 0.0;
   CheckBool("B2 calculate spread",
             g_filter.CalculateSpreadPips(
                1.10000, 1.10015, 0.00001, 5, spread
             ),
             true);
   CheckDouble("B2 spread value", spread, 1.5);
   CheckInt("B2 spread decision",
            (int)g_filter.SpreadDecision(1.5, 2.0),
            (int)BOSSR_FILTER_DECISION_PASS);

   CheckBool("B3 session inside",
             g_filter.IsTimeInsideSession(
                monday_noon, 9, 0, 17, 0
             ),
             true);
   CheckInt("B3 session decision",
            (int)g_filter.SessionDecision(
               monday_noon,
               9, 0, 17, 0,
               false, true, true, true,
               true, true, false
            ),
            (int)BOSSR_FILTER_DECISION_PASS);

   CheckInt("B4 volatility decision",
            (int)g_filter.VolatilityDecision(
               12.0, 5.0, 20.0
            ),
            (int)BOSSR_FILTER_DECISION_PASS);

   CheckInt("B5 trend decision",
            (int)g_filter.TrendDecision(
               1.1020, 1.1010, 1.1000,
               1, true, 0.0
            ),
            (int)BOSSR_FILTER_DECISION_PASS);

   double volumes[5];
   volumes[0] = 100.0;
   volumes[1] = 120.0;
   volumes[2] = 80.0;
   volumes[3] = 110.0;
   volumes[4] = 90.0;

   double average = -1.0;
   CheckBool("B6 average volume",
             g_filter.CalculateAverageVolume(
                volumes, 5, average
             ),
             true);
   CheckDouble("B6 average value", average, 100.0);
   CheckInt("B6 volume decision",
            (int)g_filter.VolumeDecision(
               150.0, 100.0, 200.0
            ),
            (int)BOSSR_FILTER_DECISION_PASS);

   // ---------------------------------------------------------------
   // Defaults and configuration
   // ---------------------------------------------------------------
   CheckInt("Default capacity",
            g_engine.Capacity(),
            BOSSR_FILTER_MAX_AGGREGATE_STAGES);
   CheckInt("Default stage count",
            g_engine.StageCount(), 0);
   CheckInt("Default mode",
            (int)g_engine.Mode(),
            (int)BOSSR_FILTER_AGGREGATION_SHORT_CIRCUIT);
   CheckBool("Default short circuit",
             g_engine.ShortCircuitEnabled(), true);
   CheckLong("Default pipeline count",
             g_engine.PipelineEvaluationCount(), 0);

   CheckBool("Reject blank stage",
             g_engine.AddStage("   ", true), false);
   CheckBool("Add spread stage",
             g_engine.AddStage(" Spread ", true), true);
   CheckBool("Add session stage",
             g_engine.AddStage("Session", true), true);
   CheckBool("Add volatility stage",
             g_engine.AddStage("Volatility", true), true);
   CheckBool("Add trend stage",
             g_engine.AddStage("Trend", true), true);
   CheckBool("Add volume stage",
             g_engine.AddStage("Volume", true), true);
   CheckInt("Five stages configured",
            g_engine.StageCount(), 5);
   CheckString("Trimmed stage name",
               g_engine.StageName(0), "Spread");
   CheckInt("Deterministic order zero",
            g_engine.StageOrder(0), 0);
   CheckInt("Deterministic order four",
            g_engine.StageOrder(4), 4);
   CheckBool("Reject duplicate name",
             g_engine.AddStage("Spread", true), false);
   CheckBool("Invalid stage disabled query",
             g_engine.IsStageEnabled(99), false);

   // ---------------------------------------------------------------
   // Unified all-pass pipeline
   // ---------------------------------------------------------------
   CheckBool("Set spread pass",
             g_engine.SetStageDecision(
                0, BOSSR_FILTER_DECISION_PASS,
                t1, 1.2, 2.0, "Spread within limit"
             ),
             true);
   CheckBool("Set session pass",
             g_engine.SetStageDecision(
                1, BOSSR_FILTER_DECISION_PASS,
                t1, 720.0, 1020.0,
                "Inside enabled session"
             ),
             true);
   CheckBool("Set volatility pass",
             g_engine.SetStageDecision(
                2, BOSSR_FILTER_DECISION_PASS,
                t1, 12.0, 20.0,
                "Volatility inside limits"
             ),
             true);
   CheckBool("Set trend pass",
             g_engine.SetStageDecision(
                3, BOSSR_FILTER_DECISION_PASS,
                t1, 1.0, 1.0,
                "Trend direction matched"
             ),
             true);
   CheckBool("Set volume pass",
             g_engine.SetStageDecision(
                4, BOSSR_FILTER_DECISION_PASS,
                t1, 150.0, 200.0,
                "Volume inside limits"
             ),
             true);

   CheckBool("Evaluate all pass",
             g_engine.Evaluate(t1), true);
   CheckBool("Composite pass",
             g_engine.Passed(), true);
   CheckInt("Composite pass decision",
            (int)g_engine.LastDecision(),
            (int)BOSSR_FILTER_DECISION_PASS);
   CheckString("Composite pass reason",
               g_engine.LastReason(),
               "All enabled filters passed");
   CheckInt("All pass enabled count",
            g_engine.LastEnabledCount(), 5);
   CheckInt("All pass evaluated count",
            g_engine.LastEvaluatedCount(), 5);
   CheckInt("All pass passed count",
            g_engine.LastPassedCount(), 5);
   CheckInt("All pass failed count",
            g_engine.LastFailedCount(), 0);
   CheckInt("All pass unavailable count",
            g_engine.LastUnavailableCount(), 0);
   CheckInt("All pass skipped count",
            g_engine.LastSkippedCount(), 0);
   CheckInt("All pass terminal index",
            g_engine.LastTerminalStageIndex(), -1);

   // ---------------------------------------------------------------
   // Enable/disable controls
   // ---------------------------------------------------------------
   CheckBool("Disable volatility",
             g_engine.SetStageEnabled(2, false), true);
   CheckBool("Volatility disabled",
             g_engine.IsStageEnabled(2), false);
   CheckBool("Evaluate disabled stage",
             g_engine.Evaluate(t1), true);
   CheckBool("Disabled pipeline pass",
             g_engine.Passed(), true);
   CheckInt("Disabled enabled count",
            g_engine.LastEnabledCount(), 4);
   CheckInt("Disabled evaluated count",
            g_engine.LastEvaluatedCount(), 4);
   CheckInt("Disabled count",
            g_engine.LastDisabledCount(), 1);
   CheckBool("Re-enable volatility",
             g_engine.SetStageEnabled(2, true), true);

   // ---------------------------------------------------------------
   // Deterministic short-circuit failure
   // ---------------------------------------------------------------
   CheckBool("Set session fail",
             g_engine.SetStageDecision(
                1, BOSSR_FILTER_DECISION_FAIL,
                t1, 480.0, 540.0,
                "Outside enabled session"
             ),
             true);
   CheckBool("Set later trend fail",
             g_engine.SetStageDecision(
                3, BOSSR_FILTER_DECISION_FAIL,
                t1, -1.0, 1.0,
                "Trend direction mismatch"
             ),
             true);

   CheckBool("Evaluate short circuit fail",
             g_engine.Evaluate(t1), true);
   CheckBool("Composite failed",
             g_engine.Failed(), true);
   CheckInt("Short circuit decision",
            (int)g_engine.LastDecision(),
            (int)BOSSR_FILTER_DECISION_FAIL);
   CheckInt("First failure index",
            g_engine.LastTerminalStageIndex(), 1);
   CheckString("First failure name",
               g_engine.LastTerminalStageName(),
               "Session");
   CheckString("First failure reason",
               g_engine.LastReason(),
               "Session: Outside enabled session");
   CheckInt("Short circuit evaluated",
            g_engine.LastEvaluatedCount(), 2);
   CheckInt("Short circuit pass count",
            g_engine.LastPassedCount(), 1);
   CheckInt("Short circuit fail count",
            g_engine.LastFailedCount(), 1);
   CheckInt("Short circuit skipped",
            g_engine.LastSkippedCount(), 3);

   // ---------------------------------------------------------------
   // Evaluate-all mode still reports first failure deterministically
   // ---------------------------------------------------------------
   CheckBool("Set evaluate all mode",
             g_engine.SetMode(
                BOSSR_FILTER_AGGREGATION_EVALUATE_ALL
             ),
             true);
   CheckBool("Short circuit now false",
             g_engine.ShortCircuitEnabled(), false);
   CheckBool("Evaluate all failures",
             g_engine.Evaluate(t1), true);
   CheckBool("Evaluate all composite fail",
             g_engine.Failed(), true);
   CheckInt("Evaluate all evaluated count",
            g_engine.LastEvaluatedCount(), 5);
   CheckInt("Evaluate all failed count",
            g_engine.LastFailedCount(), 2);
   CheckInt("Evaluate all skipped count",
            g_engine.LastSkippedCount(), 0);
   CheckInt("Evaluate all first failure",
            g_engine.LastTerminalStageIndex(), 1);
   CheckString("Evaluate all reason stable",
               g_engine.LastReason(),
               "Session: Outside enabled session");

   // ---------------------------------------------------------------
   // UNAVAILABLE propagation
   // ---------------------------------------------------------------
   CheckBool("Restore session pass",
             g_engine.SetStageDecision(
                1, BOSSR_FILTER_DECISION_PASS,
                t2, 720.0, 1020.0,
                "Inside enabled session"
             ),
             true);
   CheckBool("Restore trend pass",
             g_engine.SetStageDecision(
                3, BOSSR_FILTER_DECISION_PASS,
                t2, 1.0, 1.0,
                "Trend direction matched"
             ),
             true);
   CheckBool("Set volatility unavailable",
             g_engine.SetStageDecision(
                2, BOSSR_FILTER_DECISION_UNAVAILABLE,
                t2, 0.0, 20.0,
                "Volatility market data unavailable"
             ),
             true);

   CheckBool("Evaluate unavailable",
             g_engine.Evaluate(t2), true);
   CheckBool("Composite unavailable",
             g_engine.Unavailable(), true);
   CheckInt("Unavailable decision",
            (int)g_engine.LastDecision(),
            (int)BOSSR_FILTER_DECISION_UNAVAILABLE);
   CheckInt("Unavailable terminal index",
            g_engine.LastTerminalStageIndex(), 2);
   CheckString("Unavailable terminal name",
               g_engine.LastTerminalStageName(),
               "Volatility");
   CheckString("Unavailable reason",
               g_engine.LastReason(),
               "Volatility: Volatility market data unavailable");
   CheckInt("Unavailable count one",
            g_engine.LastUnavailableCount(), 1);
   CheckInt("Unavailable all evaluated",
            g_engine.LastEvaluatedCount(), 5);

   // ---------------------------------------------------------------
   // Missing stage result becomes deterministic UNAVAILABLE
   // ---------------------------------------------------------------
   CheckBool("Clear session result",
             g_engine.ClearStageResult(1), true);
   CheckBool("Restore volatility pass",
             g_engine.SetStageDecision(
                2, BOSSR_FILTER_DECISION_PASS,
                t2, 12.0, 20.0,
                "Volatility inside limits"
             ),
             true);
   CheckBool("Evaluate missing result",
             g_engine.Evaluate(t2), true);
   CheckBool("Missing result unavailable",
             g_engine.Unavailable(), true);
   CheckInt("Missing result index",
            g_engine.LastTerminalStageIndex(), 1);
   CheckString("Missing result reason",
               g_engine.LastReason(),
               "Session: Result unavailable");

   // ---------------------------------------------------------------
   // No enabled stages
   // ---------------------------------------------------------------
   for(int i = 0; i < g_engine.StageCount(); i++)
      CheckBool("Disable stage " + IntegerToString(i),
                g_engine.SetStageEnabled(i, false), true);

   CheckBool("Evaluate no enabled",
             g_engine.Evaluate(t2), true);
   CheckBool("No enabled unavailable",
             g_engine.Unavailable(), true);
   CheckString("No enabled reason",
               g_engine.LastReason(),
               "No enabled filters");
   CheckInt("No enabled evaluated",
            g_engine.LastEvaluatedCount(), 0);
   CheckInt("No enabled disabled",
            g_engine.LastDisabledCount(), 5);

   // ---------------------------------------------------------------
   // Runtime statistics
   // Evaluations:
   // 1 all pass, 2 disabled pass, 3 short fail,
   // 4 evaluate-all fail, 5 unavailable,
   // 6 missing unavailable, 7 no-enabled unavailable.
   // ---------------------------------------------------------------
   CheckLong("Pipeline evaluations",
             g_engine.PipelineEvaluationCount(), 7);
   CheckLong("Pipeline passes",
             g_engine.PipelinePassCount(), 2);
   CheckLong("Pipeline failures",
             g_engine.PipelineFailCount(), 2);
   CheckLong("Pipeline unavailable",
             g_engine.PipelineUnavailableCount(), 3);
   CheckDouble("Pipeline pass rate",
               g_engine.PipelinePassRate(),
               (2.0 * 100.0 / 7.0));

   CheckLong("Accumulated stage evaluations",
             g_engine.StageEvaluationCount(), 26);
   CheckLong("Accumulated stage passes",
             g_engine.StagePassCount(), 21);
   CheckLong("Accumulated stage failures",
             g_engine.StageFailCount(), 3);
   CheckLong("Accumulated unavailable",
             g_engine.StageUnavailableCount(), 2);
   CheckLong("Accumulated disabled",
             g_engine.StageDisabledCount(), 6);
   CheckLong("Accumulated skipped",
             g_engine.StageSkippedCount(), 3);

   // ---------------------------------------------------------------
   // Statistics reset preserves configuration
   // ---------------------------------------------------------------
   g_engine.ClearRuntimeStatistics();

   CheckLong("Cleared pipeline evaluations",
             g_engine.PipelineEvaluationCount(), 0);
   CheckLong("Cleared stage evaluations",
             g_engine.StageEvaluationCount(), 0);
   CheckInt("Configuration preserved",
            g_engine.StageCount(), 5);
   CheckString("Stage name preserved",
               g_engine.StageName(4), "Volume");

   Print("BossR_Filter_Verify_Block7_AGGREGATION_FIXED_FULL: PASS ",
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
