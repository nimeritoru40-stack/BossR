//+------------------------------------------------------------------+
//| BossR_Risk_Verify_Block6_FIXED_FULL.mq4                         |
//| BossR Framework - Risk Module Verifier                           |
//| Block 6 runtime verification                                     |
//| MT4 only                                                         |
//+------------------------------------------------------------------+
#property strict

#include <BossR\BossR_Risk_Block6_FIXED_FULL.mqh>

CBossRRisk g_risk;
int g_pass = 0;
int g_fail = 0;

bool Near(const double actual,
          const double expected,
          const double epsilon = 0.000000001)
{
   return(MathAbs(actual - expected) <= epsilon);
}

void CheckDouble(const string name,
                 const double actual,
                 const double expected,
                 const double epsilon = 0.000000001)
{
   if(Near(actual, expected, epsilon))
      g_pass++;
   else
   {
      g_fail++;
      Print("FAIL: ", name);
      Print("   actual=", DoubleToString(actual, 12),
            " expected=", DoubleToString(expected, 12));
   }
}

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

int OnInit()
{
   // ---------------------------------------------------------------
   // Blocks 1-5 regression
   // ---------------------------------------------------------------
   CheckDouble("B1 RiskMoney",
               g_risk.RiskMoney(10000.0, 1.0),
               100.0);

   CheckDouble("B2 PositionLots",
               g_risk.PositionLots(
                  10000.0, 1.0, 100.0,
                  1.0, 0.00001, 0.00001,
                  0.01, 100.0, 0.01
               ),
               1.0);

   CheckBool("B3 Geometry",
             g_risk.IsGeometryValid(
                OP_BUY, 1.1000, 1.0950, 1.1100
             ),
             true);

   CheckBool("B4 Can add risk",
             g_risk.CanAddRiskMoney(
                10000.0, 200.0, 300.0, 5.0
             ),
             true);

   CheckBool("B5 Risk lock neither",
             g_risk.ShouldRiskLock(
                10000.0, -100.0, 5.0, 1, 3
             ),
             false);

   CheckDouble("B5 Risk scale",
               g_risk.RiskScaleAfterLosses(
                  2, 0.25, 0.0
               ),
               0.5);

   // ---------------------------------------------------------------
   // Pre-trade geometry facade
   // ---------------------------------------------------------------
   CheckBool("Geometry facade buy valid",
             g_risk.IsPreTradeGeometryAllowed(
                OP_BUY,
                1.1000, 1.0950, 1.1100,
                0.0001, 50.0, 2.0
             ),
             true);

   CheckBool("Geometry facade sell valid",
             g_risk.IsPreTradeGeometryAllowed(
                OP_SELL,
                1.1000, 1.1050, 1.0900,
                0.0001, 50.0, 2.0
             ),
             true);

   CheckBool("Geometry facade bad stop",
             g_risk.IsPreTradeGeometryAllowed(
                OP_BUY,
                1.1000, 1.1050, 1.1100,
                0.0001, 50.0, 2.0
             ),
             false);

   CheckBool("Geometry facade stop too close",
             g_risk.IsPreTradeGeometryAllowed(
                OP_BUY,
                1.1000, 1.0975, 1.1100,
                0.0001, 50.0, 2.0
             ),
             false);

   CheckBool("Geometry facade RR too low",
             g_risk.IsPreTradeGeometryAllowed(
                OP_BUY,
                1.1000, 1.0950, 1.1050,
                0.0001, 50.0, 2.0
             ),
             false);

   CheckBool("Geometry facade invalid point",
             g_risk.IsPreTradeGeometryAllowed(
                OP_BUY,
                1.1000, 1.0950, 1.1100,
                0.0, 50.0, 2.0
             ),
             false);

   // ---------------------------------------------------------------
   // Capacity facade
   // ---------------------------------------------------------------
   CheckBool("Capacity facade valid",
             g_risk.IsPreTradeCapacityAllowed(
                10000.0,
                200.0, 100.0, 5.0,
                2, 5,
                1.0, 0.5, 2.0
             ),
             true);

   CheckBool("Capacity facade risk fail",
             g_risk.IsPreTradeCapacityAllowed(
                10000.0,
                450.0, 100.0, 5.0,
                2, 5,
                1.0, 0.5, 2.0
             ),
             false);

   CheckBool("Capacity facade count fail",
             g_risk.IsPreTradeCapacityAllowed(
                10000.0,
                200.0, 100.0, 5.0,
                5, 5,
                1.0, 0.5, 2.0
             ),
             false);

   CheckBool("Capacity facade symbol fail",
             g_risk.IsPreTradeCapacityAllowed(
                10000.0,
                200.0, 100.0, 5.0,
                2, 5,
                1.8, 0.5, 2.0
             ),
             false);

   // ---------------------------------------------------------------
   // Lock facade
   // ---------------------------------------------------------------
   CheckBool("Lock facade unlocked",
             g_risk.IsPreTradeLockAllowed(false, false),
             true);

   CheckBool("Lock facade risk locked",
             g_risk.IsPreTradeLockAllowed(true, false),
             false);

   CheckBool("Lock facade manual locked",
             g_risk.IsPreTradeLockAllowed(false, true),
             false);

   // ---------------------------------------------------------------
   // Unified CanOpenTrade
   // ---------------------------------------------------------------
   CheckBool("CanOpen valid buy",
             g_risk.CanOpenTrade(
                OP_BUY,
                1.1000, 1.0950, 1.1100,
                0.0001, 50.0, 2.0,
                10000.0,
                200.0, 100.0, 5.0,
                2, 5,
                1.0, 0.5, 2.0,
                false, false
             ),
             true);

   CheckBool("CanOpen valid sell",
             g_risk.CanOpenTrade(
                OP_SELL,
                1.1000, 1.1050, 1.0900,
                0.0001, 50.0, 2.0,
                10000.0,
                200.0, 100.0, 5.0,
                2, 5,
                1.0, 0.5, 2.0,
                false, false
             ),
             true);

   CheckBool("CanOpen risk locked",
             g_risk.CanOpenTrade(
                OP_BUY,
                1.1000, 1.0950, 1.1100,
                0.0001, 50.0, 2.0,
                10000.0,
                200.0, 100.0, 5.0,
                2, 5,
                1.0, 0.5, 2.0,
                true, false
             ),
             false);

   CheckBool("CanOpen manual locked",
             g_risk.CanOpenTrade(
                OP_BUY,
                1.1000, 1.0950, 1.1100,
                0.0001, 50.0, 2.0,
                10000.0,
                200.0, 100.0, 5.0,
                2, 5,
                1.0, 0.5, 2.0,
                false, true
             ),
             false);

   CheckBool("CanOpen bad geometry",
             g_risk.CanOpenTrade(
                OP_BUY,
                1.1000, 1.1050, 1.1100,
                0.0001, 50.0, 2.0,
                10000.0,
                200.0, 100.0, 5.0,
                2, 5,
                1.0, 0.5, 2.0,
                false, false
             ),
             false);

   CheckBool("CanOpen stop too close",
             g_risk.CanOpenTrade(
                OP_BUY,
                1.1000, 1.0975, 1.1100,
                0.0001, 50.0, 2.0,
                10000.0,
                200.0, 100.0, 5.0,
                2, 5,
                1.0, 0.5, 2.0,
                false, false
             ),
             false);

   CheckBool("CanOpen RR fail",
             g_risk.CanOpenTrade(
                OP_BUY,
                1.1000, 1.0950, 1.1050,
                0.0001, 50.0, 2.0,
                10000.0,
                200.0, 100.0, 5.0,
                2, 5,
                1.0, 0.5, 2.0,
                false, false
             ),
             false);

   CheckBool("CanOpen risk capacity fail",
             g_risk.CanOpenTrade(
                OP_BUY,
                1.1000, 1.0950, 1.1100,
                0.0001, 50.0, 2.0,
                10000.0,
                450.0, 100.0, 5.0,
                2, 5,
                1.0, 0.5, 2.0,
                false, false
             ),
             false);

   CheckBool("CanOpen count fail",
             g_risk.CanOpenTrade(
                OP_BUY,
                1.1000, 1.0950, 1.1100,
                0.0001, 50.0, 2.0,
                10000.0,
                200.0, 100.0, 5.0,
                5, 5,
                1.0, 0.5, 2.0,
                false, false
             ),
             false);

   CheckBool("CanOpen symbol fail",
             g_risk.CanOpenTrade(
                OP_BUY,
                1.1000, 1.0950, 1.1100,
                0.0001, 50.0, 2.0,
                10000.0,
                200.0, 100.0, 5.0,
                2, 5,
                1.8, 0.5, 2.0,
                false, false
             ),
             false);

   // ---------------------------------------------------------------
   // Maximum additional capacity
   // ---------------------------------------------------------------
   CheckDouble("Maximum additional risk full",
               g_risk.MaximumAdditionalRiskMoney(
                  10000.0, 0.0, 5.0
               ),
               500.0);

   CheckDouble("Maximum additional risk partial",
               g_risk.MaximumAdditionalRiskMoney(
                  10000.0, 125.0, 5.0
               ),
               375.0);

   CheckDouble("Maximum additional risk exhausted",
               g_risk.MaximumAdditionalRiskMoney(
                  10000.0, 500.0, 5.0
               ),
               0.0);

   CheckDouble("Maximum additional symbol full",
               g_risk.MaximumAdditionalSymbolLots(
                  0.0, 2.0, 0.01
               ),
               2.0);

   CheckDouble("Maximum additional symbol partial",
               g_risk.MaximumAdditionalSymbolLots(
                  1.235, 2.0, 0.01
               ),
               0.76);

   CheckDouble("Maximum additional symbol exhausted",
               g_risk.MaximumAdditionalSymbolLots(
                  2.0, 2.0, 0.01
               ),
               0.0);

   CheckDouble("Maximum additional symbol invalid step",
               g_risk.MaximumAdditionalSymbolLots(
                  1.0, 2.0, 0.0
               ),
               0.0);

   // ---------------------------------------------------------------
   // Capped proposed values
   // ---------------------------------------------------------------
   CheckDouble("Capped risk under",
               g_risk.CappedProposedRiskMoney(
                  10000.0, 200.0, 100.0, 5.0
               ),
               100.0);

   CheckDouble("Capped risk exact",
               g_risk.CappedProposedRiskMoney(
                  10000.0, 200.0, 300.0, 5.0
               ),
               300.0);

   CheckDouble("Capped risk over",
               g_risk.CappedProposedRiskMoney(
                  10000.0, 200.0, 500.0, 5.0
               ),
               300.0);

   CheckDouble("Capped risk invalid proposed",
               g_risk.CappedProposedRiskMoney(
                  10000.0, 200.0, 0.0, 5.0
               ),
               0.0);

   CheckDouble("Capped lots under",
               g_risk.CappedProposedLots(
                  1.0, 0.5, 2.0, 0.01
               ),
               0.5);

   CheckDouble("Capped lots exact",
               g_risk.CappedProposedLots(
                  1.0, 1.0, 2.0, 0.01
               ),
               1.0);

   CheckDouble("Capped lots over",
               g_risk.CappedProposedLots(
                  1.0, 1.5, 2.0, 0.01
               ),
               1.0);

   CheckDouble("Capped lots step floor",
               g_risk.CappedProposedLots(
                  1.0, 0.567, 2.0, 0.01
               ),
               0.56);

   CheckDouble("Capped lots invalid proposed",
               g_risk.CappedProposedLots(
                  1.0, 0.0, 2.0, 0.01
               ),
               0.0);

   CheckDouble("Capped lots invalid step",
               g_risk.CappedProposedLots(
                  1.0, 0.5, 2.0, 0.0
               ),
               0.0);

   // ---------------------------------------------------------------
   // Effective risk percent
   // ---------------------------------------------------------------
   CheckDouble("Effective risk no losses",
               g_risk.EffectiveRiskPercent(
                  2.0, 0, 0.25, 0.0,
                  false, false
               ),
               2.0);

   CheckDouble("Effective risk one loss",
               g_risk.EffectiveRiskPercent(
                  2.0, 1, 0.25, 0.0,
                  false, false
               ),
               1.5);

   CheckDouble("Effective risk two losses",
               g_risk.EffectiveRiskPercent(
                  2.0, 2, 0.25, 0.0,
                  false, false
               ),
               1.0);

   CheckDouble("Effective risk minimum scale",
               g_risk.EffectiveRiskPercent(
                  2.0, 10, 0.25, 0.2,
                  false, false
               ),
               0.4);

   CheckDouble("Effective risk locked",
               g_risk.EffectiveRiskPercent(
                  2.0, 0, 0.25, 0.0,
                  true, false
               ),
               0.0);

   CheckDouble("Effective risk manual lock",
               g_risk.EffectiveRiskPercent(
                  2.0, 0, 0.25, 0.0,
                  false, true
               ),
               0.0);

   // ---------------------------------------------------------------
   // Facade position sizing
   // ---------------------------------------------------------------
   CheckDouble("Facade lots no losses",
               g_risk.FacadePositionLots(
                  10000.0,
                  1.0,
                  0, 0.25, 0.0,
                  OP_BUY,
                  1.10000, 1.09900,
                  1.0, 0.00001, 0.00001,
                  0.01, 100.0, 0.01,
                  0.0, 100.0,
                  false, false
               ),
               1.0);

   CheckDouble("Facade lots one loss",
               g_risk.FacadePositionLots(
                  10000.0,
                  1.0,
                  1, 0.25, 0.0,
                  OP_BUY,
                  1.10000, 1.09900,
                  1.0, 0.00001, 0.00001,
                  0.01, 100.0, 0.01,
                  0.0, 100.0,
                  false, false
               ),
               0.75);

   CheckDouble("Facade lots two losses",
               g_risk.FacadePositionLots(
                  10000.0,
                  1.0,
                  2, 0.25, 0.0,
                  OP_BUY,
                  1.10000, 1.09900,
                  1.0, 0.00001, 0.00001,
                  0.01, 100.0, 0.01,
                  0.0, 100.0,
                  false, false
               ),
               0.5);

   CheckDouble("Facade lots symbol capped",
               g_risk.FacadePositionLots(
                  10000.0,
                  1.0,
                  0, 0.25, 0.0,
                  OP_BUY,
                  1.10000, 1.09900,
                  1.0, 0.00001, 0.00001,
                  0.01, 100.0, 0.01,
                  1.6, 2.0,
                  false, false
               ),
               0.4);

   CheckDouble("Facade lots risk locked",
               g_risk.FacadePositionLots(
                  10000.0,
                  1.0,
                  0, 0.25, 0.0,
                  OP_BUY,
                  1.10000, 1.09900,
                  1.0, 0.00001, 0.00001,
                  0.01, 100.0, 0.01,
                  0.0, 100.0,
                  true, false
               ),
               0.0);

   CheckDouble("Facade lots manual locked",
               g_risk.FacadePositionLots(
                  10000.0,
                  1.0,
                  0, 0.25, 0.0,
                  OP_BUY,
                  1.10000, 1.09900,
                  1.0, 0.00001, 0.00001,
                  0.01, 100.0, 0.01,
                  0.0, 100.0,
                  false, true
               ),
               0.0);

   CheckDouble("Facade lots invalid stop",
               g_risk.FacadePositionLots(
                  10000.0,
                  1.0,
                  0, 0.25, 0.0,
                  OP_BUY,
                  1.10000, 1.10100,
                  1.0, 0.00001, 0.00001,
                  0.01, 100.0, 0.01,
                  0.0, 100.0,
                  false, false
               ),
               0.0);

   CheckDouble("Facade lots sell",
               g_risk.FacadePositionLots(
                  10000.0,
                  1.0,
                  0, 0.25, 0.0,
                  OP_SELL,
                  1.10000, 1.10100,
                  1.0, 0.00001, 0.00001,
                  0.01, 100.0, 0.01,
                  0.0, 100.0,
                  false, false
               ),
               1.0);

   Print("BossR_Risk_Verify_Block6_FIXED_FULL: PASS ",
         g_pass,
         " / FAIL ",
         g_fail);

   ExpertRemove();
   return(INIT_SUCCEEDED);
}

void OnTick()
{
}
