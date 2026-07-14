//+------------------------------------------------------------------+
//| BossR_Strategy_Verify_Block7_PERFORMANCE_FULL.mq4                       |
//| BossR Framework - Strategy Module Verifier                       |
//| Block 1 runtime verification                                     |
//| MT4 only                                                         |
//+------------------------------------------------------------------+
#property strict

#include <BossR\BossR_Strategy_Block7_PERFORMANCE_FULL.mqh>

CBossRStrategy g_strategy;
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

void CheckDateTime(const string name,
                   const datetime actual,
                   const datetime expected)
{
   if(actual == expected)
      g_pass++;
   else
   {
      g_fail++;
      Print("FAIL: ", name);
      Print("   actual=", TimeToString(actual, TIME_DATE|TIME_SECONDS),
            " expected=", TimeToString(expected, TIME_DATE|TIME_SECONDS));
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

void CheckDouble(const string name,
                 const double actual,
                 const double expected,
                 const double tolerance = 0.000000001)
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

int OnInit()
{
   // ---------------------------------------------------------------
   // Default state
   // ---------------------------------------------------------------
   CheckString("Default name", g_strategy.Name(), "");
   CheckInt("Default id", g_strategy.Id(), 0);
   CheckInt("Default magic", g_strategy.MagicNumber(), 0);
   CheckBool("Default enabled", g_strategy.IsEnabled(), false);
   CheckInt("Default evaluation mode",
            (int)g_strategy.EvaluationMode(),
            (int)BOSSR_STRATEGY_EVALUATE_NEW_BAR);
   CheckInt("Default direction mode",
            (int)g_strategy.DirectionMode(),
            (int)BOSSR_STRATEGY_DIRECTION_NONE);
   CheckInt("Default state",
            (int)g_strategy.State(),
            (int)BOSSR_STRATEGY_STATE_RESET);
   CheckBool("Default configured", g_strategy.IsConfigured(), false);
   CheckBool("Default operational", g_strategy.IsOperational(), false);
   CheckBool("Default long denied", g_strategy.AllowsLong(), false);
   CheckBool("Default short denied", g_strategy.AllowsShort(), false);
   CheckBool("Default new bar", g_strategy.EvaluateOnNewBarOnly(), true);
   CheckLong("Default evaluations", g_strategy.EvaluationCount(), 0);
   CheckLong("Default signals", g_strategy.SignalCount(), 0);
   CheckLong("Default errors", g_strategy.ErrorCount(), 0);
   CheckDateTime("Default last evaluation",
                 g_strategy.LastEvaluationTime(), 0);
   CheckDateTime("Default last signal",
                 g_strategy.LastSignalTime(), 0);
   CheckString("Default evaluation text",
               g_strategy.EvaluationModeText(), "NEW_BAR");
   CheckString("Default direction text",
               g_strategy.DirectionModeText(), "NONE");
   CheckString("Default state text",
               g_strategy.StateText(), "RESET");

   // ---------------------------------------------------------------
   // Invalid configuration must not mutate the object
   // ---------------------------------------------------------------
   CheckBool("Configure empty name rejected",
             g_strategy.Configure(
                "", 1, 8801001,
                BOSSR_STRATEGY_EVALUATE_NEW_BAR,
                BOSSR_STRATEGY_DIRECTION_BOTH,
                true
             ),
             false);

   CheckBool("Configure whitespace name rejected",
             g_strategy.Configure(
                "   ", 1, 8801001,
                BOSSR_STRATEGY_EVALUATE_NEW_BAR,
                BOSSR_STRATEGY_DIRECTION_BOTH,
                true
             ),
             false);

   CheckBool("Configure zero id rejected",
             g_strategy.Configure(
                "Core", 0, 8801001,
                BOSSR_STRATEGY_EVALUATE_NEW_BAR,
                BOSSR_STRATEGY_DIRECTION_BOTH,
                true
             ),
             false);

   CheckBool("Configure negative magic rejected",
             g_strategy.Configure(
                "Core", 1, -1,
                BOSSR_STRATEGY_EVALUATE_NEW_BAR,
                BOSSR_STRATEGY_DIRECTION_BOTH,
                true
             ),
             false);

   CheckBool("Still unconfigured after rejects",
             g_strategy.IsConfigured(), false);

   // ---------------------------------------------------------------
   // Valid configuration
   // ---------------------------------------------------------------
   CheckBool("Configure valid",
             g_strategy.Configure(
                "  BossR Core Strategy  ",
                101,
                8801101,
                BOSSR_STRATEGY_EVALUATE_NEW_BAR,
                BOSSR_STRATEGY_DIRECTION_BOTH,
                true
             ),
             true);

   CheckString("Configured trimmed name",
               g_strategy.Name(), "BossR Core Strategy");
   CheckInt("Configured id", g_strategy.Id(), 101);
   CheckInt("Configured magic", g_strategy.MagicNumber(), 8801101);
   CheckBool("Configured enabled", g_strategy.IsEnabled(), true);
   CheckBool("Configured state", 
             g_strategy.State() == BOSSR_STRATEGY_STATE_READY,
             true);
   CheckBool("Configured valid", g_strategy.IsConfigured(), true);
   CheckBool("Configured operational", g_strategy.IsOperational(), true);
   CheckBool("Both allows long", g_strategy.AllowsLong(), true);
   CheckBool("Both allows short", g_strategy.AllowsShort(), true);
   CheckString("Configured state text", g_strategy.StateText(), "READY");

   // ---------------------------------------------------------------
   // Setters and directional modes
   // ---------------------------------------------------------------
   CheckBool("SetName blank rejected", g_strategy.SetName("  "), false);
   CheckString("Name preserved after reject",
               g_strategy.Name(), "BossR Core Strategy");
   CheckBool("SetName valid", g_strategy.SetName(" Strategy Alpha "), true);
   CheckString("SetName trimmed", g_strategy.Name(), "Strategy Alpha");

   CheckBool("SetId zero rejected", g_strategy.SetId(0), false);
   CheckInt("Id preserved after reject", g_strategy.Id(), 101);
   CheckBool("SetId valid", g_strategy.SetId(202), true);
   CheckInt("Id updated", g_strategy.Id(), 202);

   CheckBool("SetMagic zero rejected",
             g_strategy.SetMagicNumber(0), false);
   CheckInt("Magic preserved after reject",
            g_strategy.MagicNumber(), 8801101);
   CheckBool("SetMagic valid",
             g_strategy.SetMagicNumber(8801202), true);
   CheckInt("Magic updated", g_strategy.MagicNumber(), 8801202);

   CheckBool("Set every tick",
             g_strategy.SetEvaluationMode(
                BOSSR_STRATEGY_EVALUATE_EVERY_TICK
             ),
             true);
   CheckBool("Every tick not new bar",
             g_strategy.EvaluateOnNewBarOnly(), false);
   CheckString("Every tick text",
               g_strategy.EvaluationModeText(), "EVERY_TICK");

   CheckBool("Set long only",
             g_strategy.SetDirectionMode(
                BOSSR_STRATEGY_DIRECTION_LONG_ONLY
             ),
             true);
   CheckBool("Long only allows long", g_strategy.AllowsLong(), true);
   CheckBool("Long only denies short", g_strategy.AllowsShort(), false);
   CheckString("Long only text",
               g_strategy.DirectionModeText(), "LONG_ONLY");

   CheckBool("Set short only",
             g_strategy.SetDirectionMode(
                BOSSR_STRATEGY_DIRECTION_SHORT_ONLY
             ),
             true);
   CheckBool("Short only denies long", g_strategy.AllowsLong(), false);
   CheckBool("Short only allows short", g_strategy.AllowsShort(), true);
   CheckString("Short only text",
               g_strategy.DirectionModeText(), "SHORT_ONLY");

   CheckBool("Set none",
             g_strategy.SetDirectionMode(
                BOSSR_STRATEGY_DIRECTION_NONE
             ),
             true);
   CheckBool("None not operational", g_strategy.IsOperational(), false);
   CheckBool("Start denied with none", g_strategy.Start(), false);

   CheckBool("Restore both",
             g_strategy.SetDirectionMode(
                BOSSR_STRATEGY_DIRECTION_BOTH
             ),
             true);

   // ---------------------------------------------------------------
   // Enable and lifecycle transitions
   // ---------------------------------------------------------------
   g_strategy.SetEnabled(false);
   CheckBool("Disabled flag", g_strategy.IsEnabled(), false);
   CheckBool("Disabled not operational", g_strategy.IsOperational(), false);
   CheckBool("Start denied disabled", g_strategy.Start(), false);

   g_strategy.SetEnabled(true);
   CheckBool("Re-enabled", g_strategy.IsEnabled(), true);
   CheckBool("Ready operational", g_strategy.IsOperational(), true);

   CheckBool("Start from ready", g_strategy.Start(), true);
   CheckInt("Running state",
            (int)g_strategy.State(),
            (int)BOSSR_STRATEGY_STATE_RUNNING);
   CheckString("Running text", g_strategy.StateText(), "RUNNING");
   CheckBool("Start while running rejected", g_strategy.Start(), false);

   CheckBool("Pause from running", g_strategy.Pause(), true);
   CheckInt("Paused state",
            (int)g_strategy.State(),
            (int)BOSSR_STRATEGY_STATE_PAUSED);
   CheckBool("Paused not operational", g_strategy.IsOperational(), false);
   CheckBool("Pause while paused rejected", g_strategy.Pause(), false);

   CheckBool("Restart from paused", g_strategy.Start(), true);
   CheckBool("Running operational", g_strategy.IsOperational(), true);

   CheckBool("Stop from running", g_strategy.Stop(), true);
   CheckInt("Stopped state",
            (int)g_strategy.State(),
            (int)BOSSR_STRATEGY_STATE_STOPPED);
   CheckBool("Stopped not operational", g_strategy.IsOperational(), false);
   CheckBool("Restart from stopped", g_strategy.Start(), true);

   // ---------------------------------------------------------------
   // Runtime statistics
   // ---------------------------------------------------------------
   const datetime t1 = StrToTime("2026.07.14 12:00:00");
   const datetime t2 = StrToTime("2026.07.14 12:01:00");

   g_strategy.RecordEvaluation(t1);
   g_strategy.RecordEvaluation(0);
   g_strategy.RecordSignal(t2);
   g_strategy.RecordSignal(0);

   CheckLong("Evaluation count two",
             g_strategy.EvaluationCount(), 2);
   CheckLong("Signal count two",
             g_strategy.SignalCount(), 2);
   CheckDateTime("Evaluation time preserves positive",
                 g_strategy.LastEvaluationTime(), t1);
   CheckDateTime("Signal time preserves positive",
                 g_strategy.LastSignalTime(), t2);

   g_strategy.MarkError();
   CheckLong("Error count one", g_strategy.ErrorCount(), 1);
   CheckInt("Error state",
            (int)g_strategy.State(),
            (int)BOSSR_STRATEGY_STATE_ERROR);
   CheckString("Error text", g_strategy.StateText(), "ERROR");
   CheckBool("Error not operational", g_strategy.IsOperational(), false);
   CheckBool("Start from error rejected", g_strategy.Start(), false);

   g_strategy.ClearRuntimeStatistics();
   CheckLong("Clear evaluations", g_strategy.EvaluationCount(), 0);
   CheckLong("Clear signals", g_strategy.SignalCount(), 0);
   CheckLong("Clear errors", g_strategy.ErrorCount(), 0);
   CheckDateTime("Clear evaluation time",
                 g_strategy.LastEvaluationTime(), 0);
   CheckDateTime("Clear signal time",
                 g_strategy.LastSignalTime(), 0);
   CheckInt("Clear statistics preserves state",
            (int)g_strategy.State(),
            (int)BOSSR_STRATEGY_STATE_ERROR);

   // ---------------------------------------------------------------
   // Direct state validation
   // ---------------------------------------------------------------
   CheckBool("Set ready state",
             g_strategy.SetState(BOSSR_STRATEGY_STATE_READY), true);
   CheckBool("Ready restored operational",
             g_strategy.IsOperational(), true);

   CheckBool("Set reset state",
             g_strategy.SetState(BOSSR_STRATEGY_STATE_RESET), true);
   CheckBool("Reset state not configured",
             g_strategy.IsConfigured(), false);
   CheckBool("Stop from reset rejected",
             g_strategy.Stop(), false);

   // ---------------------------------------------------------------
   // Full reset
   // ---------------------------------------------------------------
   g_strategy.Reset();

   CheckString("Reset name", g_strategy.Name(), "");
   CheckInt("Reset id", g_strategy.Id(), 0);
   CheckInt("Reset magic", g_strategy.MagicNumber(), 0);
   CheckBool("Reset enabled", g_strategy.IsEnabled(), false);
   CheckInt("Reset evaluation mode",
            (int)g_strategy.EvaluationMode(),
            (int)BOSSR_STRATEGY_EVALUATE_NEW_BAR);
   CheckInt("Reset direction mode",
            (int)g_strategy.DirectionMode(),
            (int)BOSSR_STRATEGY_DIRECTION_NONE);
   CheckInt("Reset lifecycle state",
            (int)g_strategy.State(),
            (int)BOSSR_STRATEGY_STATE_RESET);
   CheckBool("Reset configured", g_strategy.IsConfigured(), false);
   CheckLong("Reset evaluations", g_strategy.EvaluationCount(), 0);
   CheckLong("Reset signals", g_strategy.SignalCount(), 0);
   CheckLong("Reset errors", g_strategy.ErrorCount(), 0);


   // ---------------------------------------------------------------
   // Block 2: signal contract and evaluation results
   // ---------------------------------------------------------------
   CheckString("Signal text none",
               g_strategy.SignalText(BOSSR_STRATEGY_SIGNAL_NONE), "NONE");
   CheckString("Signal text buy",
               g_strategy.SignalText(BOSSR_STRATEGY_SIGNAL_BUY), "BUY");
   CheckString("Signal text sell",
               g_strategy.SignalText(BOSSR_STRATEGY_SIGNAL_SELL), "SELL");
   CheckString("Signal text exit",
               g_strategy.SignalText(BOSSR_STRATEGY_SIGNAL_EXIT), "EXIT");

   CheckBool("Signal valid none",
             g_strategy.IsValidSignal(BOSSR_STRATEGY_SIGNAL_NONE), true);
   CheckBool("Signal valid buy",
             g_strategy.IsValidSignal(BOSSR_STRATEGY_SIGNAL_BUY), true);
   CheckBool("Signal valid sell",
             g_strategy.IsValidSignal(BOSSR_STRATEGY_SIGNAL_SELL), true);
   CheckBool("Signal valid exit",
             g_strategy.IsValidSignal(BOSSR_STRATEGY_SIGNAL_EXIT), true);

   g_strategy.Configure(
      "Signal Strategy",
      303,
      8801303,
      BOSSR_STRATEGY_EVALUATE_NEW_BAR,
      BOSSR_STRATEGY_DIRECTION_BOTH,
      true
   );

   CheckBool("Both signal allows buy",
             g_strategy.SignalAllowed(BOSSR_STRATEGY_SIGNAL_BUY), true);
   CheckBool("Both signal allows sell",
             g_strategy.SignalAllowed(BOSSR_STRATEGY_SIGNAL_SELL), true);
   CheckBool("Signal allows none",
             g_strategy.SignalAllowed(BOSSR_STRATEGY_SIGNAL_NONE), true);
   CheckBool("Signal allows exit",
             g_strategy.SignalAllowed(BOSSR_STRATEGY_SIGNAL_EXIT), true);

   g_strategy.SetDirectionMode(BOSSR_STRATEGY_DIRECTION_LONG_ONLY);
   CheckBool("Long-only signal allows buy",
             g_strategy.SignalAllowed(BOSSR_STRATEGY_SIGNAL_BUY), true);
   CheckBool("Long-only signal denies sell",
             g_strategy.SignalAllowed(BOSSR_STRATEGY_SIGNAL_SELL), false);

   g_strategy.SetDirectionMode(BOSSR_STRATEGY_DIRECTION_SHORT_ONLY);
   CheckBool("Short-only signal denies buy",
             g_strategy.SignalAllowed(BOSSR_STRATEGY_SIGNAL_BUY), false);
   CheckBool("Short-only signal allows sell",
             g_strategy.SignalAllowed(BOSSR_STRATEGY_SIGNAL_SELL), true);

   g_strategy.SetDirectionMode(BOSSR_STRATEGY_DIRECTION_BOTH);

   SBossRStrategyResult result;
   result.Reset();

   CheckInt("Result reset signal",
            (int)result.signal,
            (int)BOSSR_STRATEGY_SIGNAL_NONE);
   CheckBool("Result reset valid", result.valid, false);
   CheckDateTime("Result reset evaluated time", result.evaluated_at, 0);
   CheckBool("Result reset confidence zero",
             result.confidence == 0.0, true);
   CheckBool("Result reset entry zero",
             result.entry_price == 0.0, true);
   CheckBool("Result reset stop zero",
             result.stop_loss == 0.0, true);
   CheckBool("Result reset target zero",
             result.take_profit == 0.0, true);
   CheckInt("Result reset hold bars", result.hold_bars, 0);
   CheckString("Result reset reason", result.reason, "");

   const datetime t3 = StrToTime("2026.07.14 12:02:00");

   g_strategy.MakeNoSignalResult(result, t3, "No setup");
   CheckInt("No-signal direction",
            (int)result.signal,
            (int)BOSSR_STRATEGY_SIGNAL_NONE);
   CheckBool("No-signal valid", result.valid, true);
   CheckDateTime("No-signal time", result.evaluated_at, t3);
   CheckString("No-signal reason", result.reason, "No setup");
   CheckBool("No-signal validates",
             g_strategy.ValidateResult(result), true);

   g_strategy.MakeNoSignalResult(result, 0, "Invalid time");
   CheckBool("No-signal zero time invalid", result.valid, false);
   CheckBool("No-signal zero time rejected",
             g_strategy.ValidateResult(result), false);

   CheckBool("Create buy result",
             g_strategy.MakeEntryResult(
                result,
                BOSSR_STRATEGY_SIGNAL_BUY,
                t3,
                75.0,
                1.2500,
                1.2450,
                1.2600,
                12,
                "Bullish setup"
             ),
             true);

   CheckInt("Buy result signal",
            (int)result.signal,
            (int)BOSSR_STRATEGY_SIGNAL_BUY);
   CheckBool("Buy result valid", result.valid, true);
   CheckBool("Buy confidence", result.confidence == 75.0, true);
   CheckBool("Buy entry", result.entry_price == 1.2500, true);
   CheckBool("Buy stop", result.stop_loss == 1.2450, true);
   CheckBool("Buy target", result.take_profit == 1.2600, true);
   CheckInt("Buy hold bars", result.hold_bars, 12);
   CheckString("Buy reason", result.reason, "Bullish setup");
   CheckBool("Buy validates", g_strategy.ValidateResult(result), true);

   g_strategy.SetDirectionMode(BOSSR_STRATEGY_DIRECTION_SHORT_ONLY);
   CheckBool("Buy rejected by direction",
             g_strategy.MakeEntryResult(
                result,
                BOSSR_STRATEGY_SIGNAL_BUY,
                t3,
                50.0,
                1.2000,
                1.1900,
                1.2200,
                5,
                "Blocked"
             ),
             false);
   CheckBool("Rejected buy resets valid", result.valid, false);

   g_strategy.SetDirectionMode(BOSSR_STRATEGY_DIRECTION_BOTH);

   CheckBool("Create sell result",
             g_strategy.MakeEntryResult(
                result,
                BOSSR_STRATEGY_SIGNAL_SELL,
                t3,
                88.0,
                1.3000,
                1.3100,
                1.2800,
                8,
                "Bearish setup"
             ),
             true);
   CheckBool("Sell validates", g_strategy.ValidateResult(result), true);

   CheckBool("Entry rejects none signal",
             g_strategy.MakeEntryResult(
                result,
                BOSSR_STRATEGY_SIGNAL_NONE,
                t3,
                50.0,
                1.0,
                0.9,
                1.1,
                2,
                "Invalid"
             ),
             false);

   CheckBool("Entry rejects exit signal",
             g_strategy.MakeEntryResult(
                result,
                BOSSR_STRATEGY_SIGNAL_EXIT,
                t3,
                50.0,
                0.0,
                0.0,
                0.0,
                0,
                "Invalid"
             ),
             false);

   CheckBool("Entry rejects confidence below zero",
             g_strategy.MakeEntryResult(
                result,
                BOSSR_STRATEGY_SIGNAL_BUY,
                t3,
                -0.1,
                1.0,
                0.9,
                1.1,
                2,
                "Invalid confidence"
             ),
             false);

   CheckBool("Entry rejects confidence above 100",
             g_strategy.MakeEntryResult(
                result,
                BOSSR_STRATEGY_SIGNAL_BUY,
                t3,
                100.1,
                1.0,
                0.9,
                1.1,
                2,
                "Invalid confidence"
             ),
             false);

   CheckBool("Entry rejects negative hold bars",
             g_strategy.MakeEntryResult(
                result,
                BOSSR_STRATEGY_SIGNAL_BUY,
                t3,
                50.0,
                1.0,
                0.9,
                1.1,
                -1,
                "Invalid hold"
             ),
             false);

   CheckBool("Entry rejects negative entry price",
             g_strategy.MakeEntryResult(
                result,
                BOSSR_STRATEGY_SIGNAL_BUY,
                t3,
                50.0,
                -1.0,
                0.9,
                1.1,
                2,
                "Invalid entry"
             ),
             false);

   CheckBool("Create exit result",
             g_strategy.MakeExitResult(
                result,
                t3,
                90.0,
                "Exit condition"
             ),
             true);
   CheckInt("Exit result signal",
            (int)result.signal,
            (int)BOSSR_STRATEGY_SIGNAL_EXIT);
   CheckBool("Exit result validates",
             g_strategy.ValidateResult(result), true);
   CheckString("Exit reason", result.reason, "Exit condition");

   CheckBool("Exit rejects zero time",
             g_strategy.MakeExitResult(
                result,
                0,
                50.0,
                "Invalid time"
             ),
             false);

   CheckBool("Exit rejects bad confidence",
             g_strategy.MakeExitResult(
                result,
                t3,
                101.0,
                "Invalid confidence"
             ),
             false);


   // ---------------------------------------------------------------
   // Block 3: evaluation gating
   // ---------------------------------------------------------------
   g_strategy.Reset();

   const datetime gate_tick_1 = StrToTime("2026.07.14 12:10:00");
   const datetime gate_tick_2 = StrToTime("2026.07.14 12:10:01");
   const datetime gate_bar_1  = StrToTime("2026.07.14 12:10:00");
   const datetime gate_bar_2  = StrToTime("2026.07.14 12:11:00");

   CheckBool("Gate reset cannot evaluate",
             g_strategy.CanEvaluate(gate_tick_1, gate_bar_1), false);
   CheckBool("Gate reset begin rejected",
             g_strategy.BeginEvaluation(gate_tick_1, gate_bar_1), false);
   CheckLong("Gate reject increments while reset",
             g_strategy.GateRejectCount(), 1);

   CheckBool("Gate configure",
             g_strategy.Configure(
                "Gate Strategy",
                404,
                8801404,
                BOSSR_STRATEGY_EVALUATE_NEW_BAR,
                BOSSR_STRATEGY_DIRECTION_BOTH,
                true
             ),
             true);
   CheckBool("Gate start", g_strategy.Start(), true);

   CheckDateTime("Gate default tick time",
                 g_strategy.LastGateTickTime(), 0);
   CheckDateTime("Gate default bar time",
                 g_strategy.LastGateBarTime(), 0);
   CheckLong("Gate default accepts", g_strategy.GateAcceptCount(), 0);
   CheckLong("Gate prior reject preserved",
             g_strategy.GateRejectCount(), 1);

   CheckBool("New-bar zero tick rejected",
             g_strategy.CanEvaluate(0, gate_bar_1), false);
   CheckBool("New-bar zero bar rejected",
             g_strategy.CanEvaluate(gate_tick_1, 0), false);

   CheckBool("New-bar first allowed",
             g_strategy.CanEvaluate(gate_tick_1, gate_bar_1), true);
   CheckBool("New-bar first accepted",
             g_strategy.BeginEvaluation(gate_tick_1, gate_bar_1), true);
   CheckDateTime("New-bar stores tick",
                 g_strategy.LastGateTickTime(), gate_tick_1);
   CheckDateTime("New-bar stores bar",
                 g_strategy.LastGateBarTime(), gate_bar_1);
   CheckLong("New-bar accept count one",
             g_strategy.GateAcceptCount(), 1);
   CheckLong("New-bar evaluation count one",
             g_strategy.EvaluationCount(), 1);
   CheckDateTime("New-bar last evaluation time",
                 g_strategy.LastEvaluationTime(), gate_tick_1);

   CheckBool("Same bar denied despite new tick",
             g_strategy.CanEvaluate(gate_tick_2, gate_bar_1), false);
   CheckBool("Same bar begin rejected",
             g_strategy.BeginEvaluation(gate_tick_2, gate_bar_1), false);
   CheckLong("Same bar reject count two",
             g_strategy.GateRejectCount(), 2);
   CheckLong("Same bar does not add evaluation",
             g_strategy.EvaluationCount(), 1);

   CheckBool("Next bar allowed",
             g_strategy.CanEvaluate(gate_tick_2, gate_bar_2), true);
   CheckBool("Next bar accepted",
             g_strategy.BeginEvaluation(gate_tick_2, gate_bar_2), true);
   CheckLong("Next bar accept count two",
             g_strategy.GateAcceptCount(), 2);
   CheckLong("Next bar evaluation count two",
             g_strategy.EvaluationCount(), 2);
   CheckDateTime("Next bar stored",
                 g_strategy.LastGateBarTime(), gate_bar_2);

   g_strategy.Pause();
   CheckBool("Paused gate denied",
             g_strategy.CanEvaluate(
                StrToTime("2026.07.14 12:11:02"),
                StrToTime("2026.07.14 12:12:00")
             ),
             false);
   CheckBool("Paused begin rejected",
             g_strategy.BeginEvaluation(
                StrToTime("2026.07.14 12:11:02"),
                StrToTime("2026.07.14 12:12:00")
             ),
             false);

   g_strategy.Start();
   g_strategy.SetEvaluationMode(BOSSR_STRATEGY_EVALUATE_EVERY_TICK);
   g_strategy.ResetEvaluationGate();

   CheckDateTime("Reset gate tick cleared",
                 g_strategy.LastGateTickTime(), 0);
   CheckDateTime("Reset gate bar cleared",
                 g_strategy.LastGateBarTime(), 0);
   CheckLong("Reset gate accepts cleared",
             g_strategy.GateAcceptCount(), 0);
   CheckLong("Reset gate rejects cleared",
             g_strategy.GateRejectCount(), 0);
   CheckLong("Reset gate preserves evaluation count",
             g_strategy.EvaluationCount(), 2);

   CheckBool("Every-tick first allowed",
             g_strategy.CanEvaluate(gate_tick_1, 0), true);
   CheckBool("Every-tick first accepted",
             g_strategy.BeginEvaluation(gate_tick_1, 0), true);
   CheckLong("Every-tick accepts one",
             g_strategy.GateAcceptCount(), 1);
   CheckLong("Every-tick total evaluations three",
             g_strategy.EvaluationCount(), 3);

   CheckBool("Duplicate tick denied",
             g_strategy.CanEvaluate(gate_tick_1, gate_bar_2), false);
   CheckBool("Duplicate tick begin rejected",
             g_strategy.BeginEvaluation(gate_tick_1, gate_bar_2), false);
   CheckLong("Duplicate tick reject one",
             g_strategy.GateRejectCount(), 1);

   CheckBool("Different tick allowed same bar",
             g_strategy.CanEvaluate(gate_tick_2, gate_bar_2), true);
   CheckBool("Different tick accepted same bar",
             g_strategy.BeginEvaluation(gate_tick_2, gate_bar_2), true);
   CheckLong("Every-tick accepts two",
             g_strategy.GateAcceptCount(), 2);
   CheckLong("Every-tick total evaluations four",
             g_strategy.EvaluationCount(), 4);

   g_strategy.SetEnabled(false);
   CheckBool("Disabled gate denied",
             g_strategy.CanEvaluate(
                StrToTime("2026.07.14 12:10:02"),
                gate_bar_2
             ),
             false);

   g_strategy.SetEnabled(true);
   g_strategy.Stop();
   CheckBool("Stopped gate denied",
             g_strategy.CanEvaluate(
                StrToTime("2026.07.14 12:10:03"),
                gate_bar_2
             ),
             false);

   g_strategy.Start();
   g_strategy.ClearRuntimeStatistics();

   CheckLong("Clear stats clears gate accepts",
             g_strategy.GateAcceptCount(), 0);
   CheckLong("Clear stats clears gate rejects",
             g_strategy.GateRejectCount(), 0);
   CheckDateTime("Clear stats clears gate tick",
                 g_strategy.LastGateTickTime(), 0);
   CheckDateTime("Clear stats clears gate bar",
                 g_strategy.LastGateBarTime(), 0);
   CheckLong("Clear stats clears evaluations",
             g_strategy.EvaluationCount(), 0);


   // ---------------------------------------------------------------
   // Block 4: signal throttling and cooldown
   // ---------------------------------------------------------------
   g_strategy.Reset();

   const datetime sig_tick_1 = StrToTime("2026.07.14 13:00:01");
   const datetime sig_tick_2 = StrToTime("2026.07.14 13:01:01");
   const datetime sig_tick_3 = StrToTime("2026.07.14 13:02:01");
   const datetime sig_tick_4 = StrToTime("2026.07.14 13:03:01");
   const datetime sig_bar_1  = StrToTime("2026.07.14 13:00:00");
   const datetime sig_bar_2  = StrToTime("2026.07.14 13:01:00");
   const datetime sig_bar_3  = StrToTime("2026.07.14 13:02:00");
   const datetime sig_bar_4  = StrToTime("2026.07.14 13:03:00");

   CheckInt("Default cooldown zero",
            g_strategy.SignalCooldownBars(), 0);
   CheckDateTime("Default signal bar zero",
                 g_strategy.LastSignalBarTime(), 0);
   CheckInt("Default emitted signal none",
            (int)g_strategy.LastEmittedSignal(),
            (int)BOSSR_STRATEGY_SIGNAL_NONE);
   CheckLong("Default signal accepts zero",
             g_strategy.SignalAcceptCount(), 0);
   CheckLong("Default signal rejects zero",
             g_strategy.SignalRejectCount(), 0);

   CheckBool("Negative cooldown rejected",
             g_strategy.SetSignalCooldownBars(-1), false);
   CheckInt("Cooldown preserved after reject",
            g_strategy.SignalCooldownBars(), 0);
   CheckBool("Set cooldown two",
             g_strategy.SetSignalCooldownBars(2), true);
   CheckInt("Cooldown two stored",
            g_strategy.SignalCooldownBars(), 2);

   CheckBool("Unconfigured signal denied",
             g_strategy.CanEmitSignal(
                BOSSR_STRATEGY_SIGNAL_BUY,
                sig_tick_1,
                sig_bar_1,
                99
             ),
             false);
   CheckBool("Unconfigured emit rejected",
             g_strategy.EmitSignal(
                BOSSR_STRATEGY_SIGNAL_BUY,
                sig_tick_1,
                sig_bar_1,
                99
             ),
             false);
   CheckLong("Unconfigured reject increments",
             g_strategy.SignalRejectCount(), 1);

   CheckBool("Throttle configure",
             g_strategy.Configure(
                "Throttle Strategy",
                505,
                8801505,
                BOSSR_STRATEGY_EVALUATE_NEW_BAR,
                BOSSR_STRATEGY_DIRECTION_BOTH,
                true
             ),
             true);
   CheckBool("Throttle start", g_strategy.Start(), true);

   CheckBool("None signal denied",
             g_strategy.CanEmitSignal(
                BOSSR_STRATEGY_SIGNAL_NONE,
                sig_tick_1,
                sig_bar_1,
                99
             ),
             false);
   CheckBool("Zero signal time denied",
             g_strategy.CanEmitSignal(
                BOSSR_STRATEGY_SIGNAL_BUY,
                0,
                sig_bar_1,
                99
             ),
             false);
   CheckBool("Zero signal bar denied",
             g_strategy.CanEmitSignal(
                BOSSR_STRATEGY_SIGNAL_BUY,
                sig_tick_1,
                0,
                99
             ),
             false);

   CheckBool("First buy allowed",
             g_strategy.CanEmitSignal(
                BOSSR_STRATEGY_SIGNAL_BUY,
                sig_tick_1,
                sig_bar_1,
                99
             ),
             true);
   CheckBool("First buy emitted",
             g_strategy.EmitSignal(
                BOSSR_STRATEGY_SIGNAL_BUY,
                sig_tick_1,
                sig_bar_1,
                99
             ),
             true);
   CheckDateTime("First signal bar stored",
                 g_strategy.LastSignalBarTime(), sig_bar_1);
   CheckInt("First signal stored buy",
            (int)g_strategy.LastEmittedSignal(),
            (int)BOSSR_STRATEGY_SIGNAL_BUY);
   CheckLong("First signal accepts one",
             g_strategy.SignalAcceptCount(), 1);
   CheckLong("RecordSignal count one",
             g_strategy.SignalCount(), 1);
   CheckDateTime("RecordSignal time one",
                 g_strategy.LastSignalTime(), sig_tick_1);

   CheckBool("Same bar duplicate denied",
             g_strategy.CanEmitSignal(
                BOSSR_STRATEGY_SIGNAL_SELL,
                sig_tick_2,
                sig_bar_1,
                99
             ),
             false);
   CheckBool("Same bar emit rejected",
             g_strategy.EmitSignal(
                BOSSR_STRATEGY_SIGNAL_SELL,
                sig_tick_2,
                sig_bar_1,
                99
             ),
             false);
   CheckLong("Same bar rejection count two",
             g_strategy.SignalRejectCount(), 2);
   CheckLong("Same bar does not add signal",
             g_strategy.SignalCount(), 1);

   CheckBool("Cooldown bar one denied",
             g_strategy.CanEmitSignal(
                BOSSR_STRATEGY_SIGNAL_SELL,
                sig_tick_2,
                sig_bar_2,
                1
             ),
             false);
   CheckBool("Cooldown bar one emit rejected",
             g_strategy.EmitSignal(
                BOSSR_STRATEGY_SIGNAL_SELL,
                sig_tick_2,
                sig_bar_2,
                1
             ),
             false);

   CheckBool("Cooldown exact boundary allowed",
             g_strategy.CanEmitSignal(
                BOSSR_STRATEGY_SIGNAL_SELL,
                sig_tick_3,
                sig_bar_3,
                2
             ),
             true);
   CheckBool("Cooldown exact boundary emitted",
             g_strategy.EmitSignal(
                BOSSR_STRATEGY_SIGNAL_SELL,
                sig_tick_3,
                sig_bar_3,
                2
             ),
             true);
   CheckInt("Second signal stored sell",
            (int)g_strategy.LastEmittedSignal(),
            (int)BOSSR_STRATEGY_SIGNAL_SELL);
   CheckLong("Signal accepts two",
             g_strategy.SignalAcceptCount(), 2);
   CheckLong("RecordSignal count two",
             g_strategy.SignalCount(), 2);

   g_strategy.SetDirectionMode(BOSSR_STRATEGY_DIRECTION_LONG_ONLY);
   CheckBool("Short blocked by direction",
             g_strategy.CanEmitSignal(
                BOSSR_STRATEGY_SIGNAL_SELL,
                sig_tick_4,
                sig_bar_4,
                2
             ),
             false);
   CheckBool("Exit allowed by direction",
             g_strategy.CanEmitSignal(
                BOSSR_STRATEGY_SIGNAL_EXIT,
                sig_tick_4,
                sig_bar_4,
                2
             ),
             true);

   CheckBool("Exit emitted",
             g_strategy.EmitSignal(
                BOSSR_STRATEGY_SIGNAL_EXIT,
                sig_tick_4,
                sig_bar_4,
                2
             ),
             true);
   CheckInt("Exit stored",
            (int)g_strategy.LastEmittedSignal(),
            (int)BOSSR_STRATEGY_SIGNAL_EXIT);
   CheckLong("Signal accepts three",
             g_strategy.SignalAcceptCount(), 3);
   CheckLong("RecordSignal count three",
             g_strategy.SignalCount(), 3);

   g_strategy.Pause();
   CheckBool("Paused signal denied",
             g_strategy.CanEmitSignal(
                BOSSR_STRATEGY_SIGNAL_BUY,
                StrToTime("2026.07.14 13:04:01"),
                StrToTime("2026.07.14 13:04:00"),
                2
             ),
             false);

   g_strategy.Start();
   g_strategy.SetEnabled(false);
   CheckBool("Disabled signal denied",
             g_strategy.CanEmitSignal(
                BOSSR_STRATEGY_SIGNAL_BUY,
                StrToTime("2026.07.14 13:05:01"),
                StrToTime("2026.07.14 13:05:00"),
                2
             ),
             false);

   g_strategy.SetEnabled(true);
   g_strategy.ResetSignalThrottle();

   CheckDateTime("Throttle reset signal bar",
                 g_strategy.LastSignalBarTime(), 0);
   CheckInt("Throttle reset signal none",
            (int)g_strategy.LastEmittedSignal(),
            (int)BOSSR_STRATEGY_SIGNAL_NONE);
   CheckLong("Throttle reset accepts",
             g_strategy.SignalAcceptCount(), 0);
   CheckLong("Throttle reset rejects",
             g_strategy.SignalRejectCount(), 0);
   CheckLong("Throttle reset preserves signal count",
             g_strategy.SignalCount(), 3);
   CheckInt("Throttle reset preserves cooldown",
            g_strategy.SignalCooldownBars(), 2);

   CheckBool("After throttle reset signal allowed",
             g_strategy.CanEmitSignal(
                BOSSR_STRATEGY_SIGNAL_BUY,
                sig_tick_1,
                sig_bar_1,
                0
             ),
             true);

   g_strategy.ClearRuntimeStatistics();

   CheckDateTime("Clear stats signal bar",
                 g_strategy.LastSignalBarTime(), 0);
   CheckInt("Clear stats emitted signal none",
            (int)g_strategy.LastEmittedSignal(),
            (int)BOSSR_STRATEGY_SIGNAL_NONE);
   CheckLong("Clear stats signal accepts zero",
             g_strategy.SignalAcceptCount(), 0);
   CheckLong("Clear stats signal rejects zero",
             g_strategy.SignalRejectCount(), 0);
   CheckLong("Clear stats record signal zero",
             g_strategy.SignalCount(), 0);
   CheckInt("Clear stats preserves cooldown",
            g_strategy.SignalCooldownBars(), 2);


   // ---------------------------------------------------------------
   // Block 5: position state and one-active-trade guard
   // ---------------------------------------------------------------
   g_strategy.Reset();

   const datetime pos_open_time = StrToTime("2026.07.14 14:00:05");
   const datetime pos_open_bar  = StrToTime("2026.07.14 14:00:00");

   CheckInt("Default position state flat",
            (int)g_strategy.PositionState(),
            (int)BOSSR_STRATEGY_POSITION_FLAT);
   CheckString("Default position text",
               g_strategy.PositionStateText(), "FLAT");
   CheckBool("Default is flat", g_strategy.IsFlat(), true);
   CheckBool("Default no pending",
             g_strategy.HasPendingPosition(), false);
   CheckBool("Default no open",
             g_strategy.HasOpenPosition(), false);
   CheckBool("Default no active",
             g_strategy.HasActivePosition(), false);
   CheckInt("Default position direction none",
            (int)g_strategy.PositionDirection(),
            (int)BOSSR_STRATEGY_SIGNAL_NONE);
   CheckInt("Default ticket minus one",
            g_strategy.PositionTicket(), -1);
   CheckDateTime("Default position time zero",
                 g_strategy.PositionOpenTime(), 0);
   CheckDateTime("Default position bar zero",
                 g_strategy.PositionOpenBarTime(), 0);
   CheckBool("Default entry price zero",
             g_strategy.PositionEntryPrice() == 0.0, true);
   CheckLong("Default open count zero",
             g_strategy.PositionOpenCount(), 0);
   CheckLong("Default close count zero",
             g_strategy.PositionCloseCount(), 0);
   CheckLong("Default reject count zero",
             g_strategy.PositionRejectCount(), 0);

   CheckBool("Unconfigured entry denied",
             g_strategy.CanRequestEntry(
                BOSSR_STRATEGY_SIGNAL_BUY
             ),
             false);
   CheckBool("Unconfigured pending rejected",
             g_strategy.MarkEntryPending(
                BOSSR_STRATEGY_SIGNAL_BUY
             ),
             false);
   CheckLong("Unconfigured position reject one",
             g_strategy.PositionRejectCount(), 1);

   CheckBool("Position configure",
             g_strategy.Configure(
                "Position Strategy",
                606,
                8801606,
                BOSSR_STRATEGY_EVALUATE_NEW_BAR,
                BOSSR_STRATEGY_DIRECTION_BOTH,
                true
             ),
             true);
   CheckBool("Position start", g_strategy.Start(), true);

   CheckBool("None entry denied",
             g_strategy.CanRequestEntry(
                BOSSR_STRATEGY_SIGNAL_NONE
             ),
             false);
   CheckBool("Exit entry denied",
             g_strategy.CanRequestEntry(
                BOSSR_STRATEGY_SIGNAL_EXIT
             ),
             false);
   CheckBool("Buy entry allowed",
             g_strategy.CanRequestEntry(
                BOSSR_STRATEGY_SIGNAL_BUY
             ),
             true);
   CheckBool("Sell entry allowed",
             g_strategy.CanRequestEntry(
                BOSSR_STRATEGY_SIGNAL_SELL
             ),
             true);

   g_strategy.SetDirectionMode(BOSSR_STRATEGY_DIRECTION_LONG_ONLY);
   CheckBool("Long-only buy allowed",
             g_strategy.CanRequestEntry(
                BOSSR_STRATEGY_SIGNAL_BUY
             ),
             true);
   CheckBool("Long-only sell denied",
             g_strategy.CanRequestEntry(
                BOSSR_STRATEGY_SIGNAL_SELL
             ),
             false);

   g_strategy.SetDirectionMode(BOSSR_STRATEGY_DIRECTION_BOTH);

   CheckBool("Mark buy pending",
             g_strategy.MarkEntryPending(
                BOSSR_STRATEGY_SIGNAL_BUY
             ),
             true);
   CheckInt("Pending state stored",
            (int)g_strategy.PositionState(),
            (int)BOSSR_STRATEGY_POSITION_PENDING);
   CheckString("Pending text",
               g_strategy.PositionStateText(), "PENDING");
   CheckBool("Pending flag true",
             g_strategy.HasPendingPosition(), true);
   CheckBool("Pending active true",
             g_strategy.HasActivePosition(), true);
   CheckBool("Pending not flat",
             g_strategy.IsFlat(), false);
   CheckInt("Pending direction buy",
            (int)g_strategy.PositionDirection(),
            (int)BOSSR_STRATEGY_SIGNAL_BUY);
   CheckBool("Second entry blocked while pending",
             g_strategy.CanRequestEntry(
                BOSSR_STRATEGY_SIGNAL_SELL
             ),
             false);
   CheckBool("Second pending rejected",
             g_strategy.MarkEntryPending(
                BOSSR_STRATEGY_SIGNAL_SELL
             ),
             false);
   CheckLong("Pending duplicate reject two",
             g_strategy.PositionRejectCount(), 2);

   CheckBool("Confirm open bad ticket rejected",
             g_strategy.ConfirmPositionOpen(
                0,
                pos_open_time,
                pos_open_bar,
                1.2500
             ),
             false);
   CheckBool("Still pending after bad confirm",
             g_strategy.HasPendingPosition(), true);

   CheckBool("Confirm open bad time rejected",
             g_strategy.ConfirmPositionOpen(
                10001,
                0,
                pos_open_bar,
                1.2500
             ),
             false);
   CheckBool("Confirm open bad price rejected",
             g_strategy.ConfirmPositionOpen(
                10001,
                pos_open_time,
                pos_open_bar,
                0.0
             ),
             false);

   CheckBool("Confirm position open",
             g_strategy.ConfirmPositionOpen(
                10001,
                pos_open_time,
                pos_open_bar,
                1.2500
             ),
             true);
   CheckInt("Open state stored",
            (int)g_strategy.PositionState(),
            (int)BOSSR_STRATEGY_POSITION_OPEN);
   CheckString("Open text",
               g_strategy.PositionStateText(), "OPEN");
   CheckBool("Open flag true",
             g_strategy.HasOpenPosition(), true);
   CheckBool("Open active true",
             g_strategy.HasActivePosition(), true);
   CheckInt("Open ticket stored",
            g_strategy.PositionTicket(), 10001);
   CheckDateTime("Open time stored",
                 g_strategy.PositionOpenTime(), pos_open_time);
   CheckDateTime("Open bar stored",
                 g_strategy.PositionOpenBarTime(), pos_open_bar);
   CheckBool("Entry price stored",
             g_strategy.PositionEntryPrice() == 1.2500, true);
   CheckLong("Open count one",
             g_strategy.PositionOpenCount(), 1);
   CheckBool("New entry blocked while open",
             g_strategy.CanRequestEntry(
                BOSSR_STRATEGY_SIGNAL_BUY
             ),
             false);
   CheckBool("Exit allowed while open",
             g_strategy.CanRequestExit(), true);

   CheckBool("Cancel pending rejected while open",
             g_strategy.CancelPendingEntry(), false);
   CheckBool("Wrong ticket close rejected",
             g_strategy.ConfirmPositionClosed(99999), false);
   CheckBool("Still open after wrong close",
             g_strategy.HasOpenPosition(), true);

   CheckBool("Correct ticket close accepted",
             g_strategy.ConfirmPositionClosed(10001), true);
   CheckBool("Flat after close",
             g_strategy.IsFlat(), true);
   CheckBool("No active after close",
             g_strategy.HasActivePosition(), false);
   CheckInt("Ticket cleared after close",
            g_strategy.PositionTicket(), -1);
   CheckInt("Direction cleared after close",
            (int)g_strategy.PositionDirection(),
            (int)BOSSR_STRATEGY_SIGNAL_NONE);
   CheckLong("Close count one",
             g_strategy.PositionCloseCount(), 1);
   CheckLong("Open count preserved one",
             g_strategy.PositionOpenCount(), 1);
   CheckBool("Exit denied while flat",
             g_strategy.CanRequestExit(), false);

   CheckBool("Mark sell pending",
             g_strategy.MarkEntryPending(
                BOSSR_STRATEGY_SIGNAL_SELL
             ),
             true);
   CheckBool("Cancel pending accepted",
             g_strategy.CancelPendingEntry(), true);
   CheckBool("Flat after cancel",
             g_strategy.IsFlat(), true);
   CheckLong("Cancel does not count close",
             g_strategy.PositionCloseCount(), 1);

   CheckBool("Cancel while flat rejected",
             g_strategy.CancelPendingEntry(), false);

   g_strategy.Pause();
   CheckBool("Paused entry denied",
             g_strategy.CanRequestEntry(
                BOSSR_STRATEGY_SIGNAL_BUY
             ),
             false);
   CheckBool("Paused exit denied",
             g_strategy.CanRequestExit(), false);

   g_strategy.Start();
   CheckBool("Pending before reset tracking",
             g_strategy.MarkEntryPending(
                BOSSR_STRATEGY_SIGNAL_BUY
             ),
             true);

   g_strategy.ResetPositionTracking();

   CheckBool("Tracking reset flat",
             g_strategy.IsFlat(), true);
   CheckLong("Tracking reset opens zero",
             g_strategy.PositionOpenCount(), 0);
   CheckLong("Tracking reset closes zero",
             g_strategy.PositionCloseCount(), 0);
   CheckLong("Tracking reset rejects zero",
             g_strategy.PositionRejectCount(), 0);

   CheckBool("Open cycle pending",
             g_strategy.MarkEntryPending(
                BOSSR_STRATEGY_SIGNAL_BUY
             ),
             true);
   CheckBool("Open cycle confirm",
             g_strategy.ConfirmPositionOpen(
                20002,
                pos_open_time,
                pos_open_bar,
                1.2600
             ),
             true);

   g_strategy.ClearRuntimeStatistics();

   CheckBool("Clear stats resets flat",
             g_strategy.IsFlat(), true);
   CheckInt("Clear stats ticket minus one",
            g_strategy.PositionTicket(), -1);
   CheckLong("Clear stats open count zero",
             g_strategy.PositionOpenCount(), 0);
   CheckLong("Clear stats close count zero",
             g_strategy.PositionCloseCount(), 0);
   CheckLong("Clear stats reject count zero",
             g_strategy.PositionRejectCount(), 0);
   CheckBool("Clear stats preserves configured",
             g_strategy.IsConfigured(), true);
   CheckBool("Clear stats preserves running",
             g_strategy.State() == BOSSR_STRATEGY_STATE_RUNNING,
             true);


   // ---------------------------------------------------------------
   // Block 6: execution lifecycle reconciliation
   // ---------------------------------------------------------------
   g_strategy.Reset();

   const datetime rec_open_time_1 = StrToTime("2026.07.14 15:00:05");
   const datetime rec_open_bar_1  = StrToTime("2026.07.14 15:00:00");
   const datetime rec_open_time_2 = StrToTime("2026.07.14 15:01:05");
   const datetime rec_open_bar_2  = StrToTime("2026.07.14 15:01:00");
   const datetime rec_time_1      = StrToTime("2026.07.14 15:02:00");
   const datetime rec_time_2      = StrToTime("2026.07.14 15:03:00");
   const datetime rec_time_3      = StrToTime("2026.07.14 15:04:00");

   CheckLong("Default reconcile count zero",
             g_strategy.ReconcileCount(), 0);
   CheckLong("Default reconcile change zero",
             g_strategy.ReconcileChangeCount(), 0);
   CheckLong("Default reconcile reject zero",
             g_strategy.ReconcileRejectCount(), 0);
   CheckDateTime("Default reconcile time zero",
                 g_strategy.LastReconcileTime(), 0);

   CheckString("Reconcile text no change",
               g_strategy.ReconcileResultText(
                  BOSSR_STRATEGY_RECONCILE_NO_CHANGE
               ),
               "NO_CHANGE");
   CheckString("Reconcile text adopted",
               g_strategy.ReconcileResultText(
                  BOSSR_STRATEGY_RECONCILE_ADOPTED_OPEN
               ),
               "ADOPTED_OPEN");
   CheckString("Reconcile text updated",
               g_strategy.ReconcileResultText(
                  BOSSR_STRATEGY_RECONCILE_UPDATED_OPEN
               ),
               "UPDATED_OPEN");
   CheckString("Reconcile text cleared",
               g_strategy.ReconcileResultText(
                  BOSSR_STRATEGY_RECONCILE_CLEARED_STALE
               ),
               "CLEARED_STALE");
   CheckString("Reconcile text rejected",
               g_strategy.ReconcileResultText(
                  BOSSR_STRATEGY_RECONCILE_REJECTED
               ),
               "REJECTED");

   CheckBool("Reconcile configure",
             g_strategy.Configure(
                "Reconcile Strategy",
                707,
                8801707,
                BOSSR_STRATEGY_EVALUATE_NEW_BAR,
                BOSSR_STRATEGY_DIRECTION_BOTH,
                true
             ),
             true);
   CheckBool("Reconcile start", g_strategy.Start(), true);

   ENUM_BOSSR_STRATEGY_RECONCILE_RESULT rec_result;

   rec_result = g_strategy.ReconcileBrokerPosition(
      false,
      -1,
      BOSSR_STRATEGY_SIGNAL_NONE,
      0,
      0,
      0.0,
      rec_time_1
   );

   CheckInt("Flat broker no-position no change",
            (int)rec_result,
            (int)BOSSR_STRATEGY_RECONCILE_NO_CHANGE);
   CheckLong("Reconcile count one",
             g_strategy.ReconcileCount(), 1);
   CheckLong("Reconcile changes zero",
             g_strategy.ReconcileChangeCount(), 0);
   CheckDateTime("Reconcile time stored",
                 g_strategy.LastReconcileTime(), rec_time_1);

   rec_result = g_strategy.ReconcileBrokerPosition(
      true,
      30003,
      BOSSR_STRATEGY_SIGNAL_BUY,
      rec_open_time_1,
      rec_open_bar_1,
      1.2700,
      0
   );

   CheckInt("Zero reconcile time rejected",
            (int)rec_result,
            (int)BOSSR_STRATEGY_RECONCILE_REJECTED);
   CheckLong("Reconcile reject one",
             g_strategy.ReconcileRejectCount(), 1);
   CheckDateTime("Rejected time preserves prior",
                 g_strategy.LastReconcileTime(), rec_time_1);

   rec_result = g_strategy.ReconcileBrokerPosition(
      true,
      0,
      BOSSR_STRATEGY_SIGNAL_BUY,
      rec_open_time_1,
      rec_open_bar_1,
      1.2700,
      rec_time_2
   );

   CheckInt("Bad broker ticket rejected",
            (int)rec_result,
            (int)BOSSR_STRATEGY_RECONCILE_REJECTED);
   CheckLong("Reconcile reject two",
             g_strategy.ReconcileRejectCount(), 2);

   rec_result = g_strategy.ReconcileBrokerPosition(
      true,
      30003,
      BOSSR_STRATEGY_SIGNAL_EXIT,
      rec_open_time_1,
      rec_open_bar_1,
      1.2700,
      rec_time_2
   );

   CheckInt("Bad broker direction rejected",
            (int)rec_result,
            (int)BOSSR_STRATEGY_RECONCILE_REJECTED);

   rec_result = g_strategy.ReconcileBrokerPosition(
      true,
      30003,
      BOSSR_STRATEGY_SIGNAL_BUY,
      rec_open_time_1,
      rec_open_bar_1,
      1.2700,
      rec_time_2
   );

   CheckInt("Flat adopts broker position",
            (int)rec_result,
            (int)BOSSR_STRATEGY_RECONCILE_ADOPTED_OPEN);
   CheckBool("Adopted state open",
             g_strategy.HasOpenPosition(), true);
   CheckInt("Adopted ticket",
            g_strategy.PositionTicket(), 30003);
   CheckInt("Adopted direction buy",
            (int)g_strategy.PositionDirection(),
            (int)BOSSR_STRATEGY_SIGNAL_BUY);
   CheckDateTime("Adopted open time",
                 g_strategy.PositionOpenTime(), rec_open_time_1);
   CheckDateTime("Adopted open bar",
                 g_strategy.PositionOpenBarTime(), rec_open_bar_1);
   CheckBool("Adopted entry price",
             g_strategy.PositionEntryPrice() == 1.2700, true);
   CheckLong("Adopt increments open count",
             g_strategy.PositionOpenCount(), 1);
   CheckLong("Adopt increments change count",
             g_strategy.ReconcileChangeCount(), 1);

   rec_result = g_strategy.ReconcileBrokerPosition(
      true,
      30003,
      BOSSR_STRATEGY_SIGNAL_BUY,
      rec_open_time_1,
      rec_open_bar_1,
      1.2700,
      rec_time_3
   );

   CheckInt("Matching broker state no change",
            (int)rec_result,
            (int)BOSSR_STRATEGY_RECONCILE_NO_CHANGE);
   CheckLong("No-change preserves change count",
             g_strategy.ReconcileChangeCount(), 1);

   rec_result = g_strategy.ReconcileBrokerPosition(
      true,
      40004,
      BOSSR_STRATEGY_SIGNAL_SELL,
      rec_open_time_2,
      rec_open_bar_2,
      1.2650,
      rec_time_3
   );

   CheckInt("Changed broker state updated",
            (int)rec_result,
            (int)BOSSR_STRATEGY_RECONCILE_UPDATED_OPEN);
   CheckInt("Updated ticket",
            g_strategy.PositionTicket(), 40004);
   CheckInt("Updated direction sell",
            (int)g_strategy.PositionDirection(),
            (int)BOSSR_STRATEGY_SIGNAL_SELL);
   CheckDateTime("Updated open time",
                 g_strategy.PositionOpenTime(), rec_open_time_2);
   CheckDateTime("Updated open bar",
                 g_strategy.PositionOpenBarTime(), rec_open_bar_2);
   CheckBool("Updated entry price",
             g_strategy.PositionEntryPrice() == 1.2650, true);
   CheckLong("Update increments change count",
             g_strategy.ReconcileChangeCount(), 2);
   CheckLong("Update does not increment open count",
             g_strategy.PositionOpenCount(), 1);

   CheckBool("Replace wrong ticket rejected",
             g_strategy.ReplacePositionTicket(12345, 50005), false);
   CheckBool("Replace valid ticket",
             g_strategy.ReplacePositionTicket(40004, 50005), true);
   CheckInt("Replacement ticket stored",
            g_strategy.PositionTicket(), 50005);

   rec_result = g_strategy.ReconcileBrokerPosition(
      false,
      -1,
      BOSSR_STRATEGY_SIGNAL_NONE,
      0,
      0,
      0.0,
      rec_time_3
   );

   CheckInt("Missing broker position clears stale",
            (int)rec_result,
            (int)BOSSR_STRATEGY_RECONCILE_CLEARED_STALE);
   CheckBool("Cleared stale now flat",
             g_strategy.IsFlat(), true);
   CheckLong("Clear stale increments change count",
             g_strategy.ReconcileChangeCount(), 3);
   CheckLong("External clear does not count close",
             g_strategy.PositionCloseCount(), 0);

   CheckBool("Mark pending for reject test",
             g_strategy.MarkEntryPending(
                BOSSR_STRATEGY_SIGNAL_BUY
             ),
             true);
   CheckBool("Reject pending accepted",
             g_strategy.RejectPendingEntry(), true);
   CheckBool("Rejected pending returns flat",
             g_strategy.IsFlat(), true);
   CheckBool("Reject pending while flat denied",
             g_strategy.RejectPendingEntry(), false);

   CheckBool("Mark pending for adoption",
             g_strategy.MarkEntryPending(
                BOSSR_STRATEGY_SIGNAL_SELL
             ),
             true);

   rec_result = g_strategy.ReconcileBrokerPosition(
      true,
      60006,
      BOSSR_STRATEGY_SIGNAL_SELL,
      rec_open_time_2,
      rec_open_bar_2,
      1.2600,
      rec_time_3
   );

   CheckInt("Pending adopts broker open",
            (int)rec_result,
            (int)BOSSR_STRATEGY_RECONCILE_ADOPTED_OPEN);
   CheckBool("Pending adoption open",
             g_strategy.HasOpenPosition(), true);
   CheckInt("Pending adoption ticket",
            g_strategy.PositionTicket(), 60006);
   CheckLong("Second adoption open count two",
             g_strategy.PositionOpenCount(), 2);

   g_strategy.ResetPositionTracking();

   CheckLong("Reset position tracking preserves reconcile count",
             g_strategy.ReconcileCount(), 9);
   CheckLong("Reset position tracking preserves changes",
             g_strategy.ReconcileChangeCount(), 4);

   g_strategy.ClearRuntimeStatistics();

   CheckLong("Clear stats reconcile count zero",
             g_strategy.ReconcileCount(), 0);
   CheckLong("Clear stats reconcile changes zero",
             g_strategy.ReconcileChangeCount(), 0);
   CheckLong("Clear stats reconcile rejects zero",
             g_strategy.ReconcileRejectCount(), 0);
   CheckDateTime("Clear stats reconcile time zero",
                 g_strategy.LastReconcileTime(), 0);



   // ---------------------------------------------------------------
   // Block 7: strategy performance statistics
   // ---------------------------------------------------------------
   g_strategy.ResetPerformanceStatistics();
   CheckLong("Performance default trades", g_strategy.PerformanceTradeCount(), 0);
   CheckLong("Performance default wins", g_strategy.WinCount(), 0);
   CheckLong("Performance default losses", g_strategy.LossCount(), 0);
   CheckLong("Performance default breakeven", g_strategy.BreakevenCount(), 0);
   CheckDouble("Performance default gross profit", g_strategy.GrossProfit(), 0.0);
   CheckDouble("Performance default gross loss", g_strategy.GrossLoss(), 0.0);
   CheckDouble("Performance default net", g_strategy.NetProfit(), 0.0);
   CheckDouble("Performance default factor", g_strategy.ProfitFactor(), 0.0);
   CheckDouble("Performance default expectancy", g_strategy.Expectancy(), 0.0);
   CheckLong("Performance default R count", g_strategy.RMultipleCount(), 0);

   CheckBool("Reject negative risk", g_strategy.RecordClosedTrade(10.0, -1.0, 2.0, 1.0), false);
   CheckBool("Reject negative MFE", g_strategy.RecordClosedTrade(10.0, 5.0, -2.0, 1.0), false);
   CheckBool("Reject negative MAE", g_strategy.RecordClosedTrade(10.0, 5.0, 2.0, -1.0), false);
   CheckLong("Rejected trades not counted", g_strategy.PerformanceTradeCount(), 0);

   CheckBool("Record win one", g_strategy.RecordClosedTrade(100.0, 50.0, 140.0, 20.0), true);
   CheckBool("Record win two", g_strategy.RecordClosedTrade(50.0, 50.0, 70.0, 15.0), true);
   CheckLong("Two trades", g_strategy.PerformanceTradeCount(), 2);
   CheckLong("Two wins", g_strategy.WinCount(), 2);
   CheckInt("Current win streak two", g_strategy.CurrentWinStreak(), 2);
   CheckInt("Max win streak two", g_strategy.MaxWinStreak(), 2);
   CheckDouble("Gross profit 150", g_strategy.GrossProfit(), 150.0);
   CheckDouble("Largest win 100", g_strategy.LargestWin(), 100.0);
   CheckDouble("Average win 75", g_strategy.AverageWin(), 75.0);

   CheckBool("Record loss one", g_strategy.RecordClosedTrade(-40.0, 40.0, 10.0, 55.0), true);
   CheckBool("Record loss two", g_strategy.RecordClosedTrade(-60.0, 30.0, 5.0, 80.0), true);
   CheckLong("Four trades", g_strategy.PerformanceTradeCount(), 4);
   CheckLong("Two losses", g_strategy.LossCount(), 2);
   CheckInt("Current loss streak two", g_strategy.CurrentLossStreak(), 2);
   CheckInt("Current win streak reset", g_strategy.CurrentWinStreak(), 0);
   CheckInt("Max loss streak two", g_strategy.MaxLossStreak(), 2);
   CheckDouble("Gross loss minus 100", g_strategy.GrossLoss(), -100.0);
   CheckDouble("Largest loss minus 60", g_strategy.LargestLoss(), -60.0);
   CheckDouble("Average loss minus 50", g_strategy.AverageLoss(), -50.0);
   CheckDouble("Net profit 50", g_strategy.NetProfit(), 50.0);
   CheckDouble("Profit factor 1.5", g_strategy.ProfitFactor(), 1.5);
   CheckDouble("Expectancy 12.5", g_strategy.Expectancy(), 12.5);

   CheckBool("Record breakeven", g_strategy.RecordClosedTrade(0.0, 25.0, 12.0, 9.0), true);
   CheckLong("Five trades", g_strategy.PerformanceTradeCount(), 5);
   CheckLong("One breakeven", g_strategy.BreakevenCount(), 1);
   CheckInt("Breakeven resets win streak", g_strategy.CurrentWinStreak(), 0);
   CheckInt("Breakeven resets loss streak", g_strategy.CurrentLossStreak(), 0);
   CheckDouble("Expectancy ten", g_strategy.Expectancy(), 10.0);

   CheckLong("R count five", g_strategy.RMultipleCount(), 5);
   CheckDouble("Total R zero", g_strategy.TotalRMultiple(), 0.0);
   CheckDouble("Average R zero", g_strategy.AverageRMultiple(), 0.0);
   CheckDouble("Best R two", g_strategy.BestRMultiple(), 2.0);
   CheckDouble("Worst R minus two", g_strategy.WorstRMultiple(), -2.0);

   CheckDouble("Total MFE 237", g_strategy.TotalMFE(), 237.0);
   CheckDouble("Total MAE 179", g_strategy.TotalMAE(), 179.0);
   CheckDouble("Average MFE 47.4", g_strategy.AverageMFE(), 47.4);
   CheckDouble("Average MAE 35.8", g_strategy.AverageMAE(), 35.8);
   CheckDouble("Largest MFE 140", g_strategy.LargestMFE(), 140.0);
   CheckDouble("Largest MAE 80", g_strategy.LargestMAE(), 80.0);

   CheckBool("Excursion hook first", g_strategy.RecordOpenTradeExcursion(15.0, 5.0), true);
   CheckBool("Excursion hook maxima", g_strategy.RecordOpenTradeExcursion(12.0, 8.0), true);
   CheckBool("Excursion hook reject", g_strategy.RecordOpenTradeExcursion(-1.0, 2.0), false);
   CheckDouble("Open MFE keeps max", g_strategy.OpenTradeMFE(), 15.0);
   CheckDouble("Open MAE keeps max", g_strategy.OpenTradeMAE(), 8.0);
   CheckBool("Close using excursion hooks", g_strategy.RecordClosedTrade(30.0, 10.0), true);
   CheckDouble("Hook close adds MFE", g_strategy.TotalMFE(), 252.0);
   CheckDouble("Hook close adds MAE", g_strategy.TotalMAE(), 187.0);
   CheckDouble("Hook close clears open MFE", g_strategy.OpenTradeMFE(), 0.0);
   CheckDouble("Hook close clears open MAE", g_strategy.OpenTradeMAE(), 0.0);
   CheckLong("Six trades after hook close", g_strategy.PerformanceTradeCount(), 6);
   CheckLong("Three wins after hook close", g_strategy.WinCount(), 3);
   CheckDouble("Net after hook close", g_strategy.NetProfit(), 80.0);
   CheckDouble("Best R after hook close", g_strategy.BestRMultiple(), 3.0);

   g_strategy.ResetPerformanceStatistics();
   CheckLong("Performance reset trades", g_strategy.PerformanceTradeCount(), 0);
   CheckLong("Performance reset wins", g_strategy.WinCount(), 0);
   CheckLong("Performance reset losses", g_strategy.LossCount(), 0);
   CheckLong("Performance reset breakeven", g_strategy.BreakevenCount(), 0);
   CheckDouble("Performance reset net", g_strategy.NetProfit(), 0.0);
   CheckInt("Performance reset max wins", g_strategy.MaxWinStreak(), 0);
   CheckInt("Performance reset max losses", g_strategy.MaxLossStreak(), 0);
   CheckLong("Performance reset R count", g_strategy.RMultipleCount(), 0);
   CheckDouble("Performance reset MFE", g_strategy.TotalMFE(), 0.0);
   CheckDouble("Performance reset MAE", g_strategy.TotalMAE(), 0.0);

   CheckBool("Record before global clear", g_strategy.RecordClosedTrade(25.0, 10.0, 30.0, 4.0), true);
   g_strategy.ClearRuntimeStatistics();
   CheckLong("Global clear performance trades", g_strategy.PerformanceTradeCount(), 0);
   CheckDouble("Global clear performance net", g_strategy.NetProfit(), 0.0);
   CheckDouble("Global clear performance MFE", g_strategy.TotalMFE(), 0.0);

   Print("BossR_Strategy_Verify_Block7_PERFORMANCE_FULL: PASS ",
         g_pass, " / FAIL ", g_fail);

   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{
}

void OnTick()
{
}
//+------------------------------------------------------------------+
