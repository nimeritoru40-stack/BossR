//+------------------------------------------------------------------+
//| BossR_Portfolio_Verify_Block6_CONTROL_FULL.mq4                   |
//| BossR Framework - Portfolio Module Verifier                      |
//| Block 6 runtime verification                                     |
//| MT4 only                                                         |
//+------------------------------------------------------------------+
#property strict

#include <BossR\BossR_Portfolio_Block6_CONTROL_FULL.mqh>

CBossRPortfolio g_portfolio;
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
   // Block 1-5 regression
   double base[6] = {100.0, -40.0, 25.0, 0.0, -10.0, 5.0};
   double alloc[5] = {40.0, 30.0, 20.0, 10.0, 0.0};
   double equity[8] =
   {
      1000.0, 1100.0, 1050.0, 900.0,
      950.0, 1200.0, 1140.0, 1260.0
   };
   double correlations[4] = {0.20, 0.40, -0.50, 0.75};

   CheckDouble("B1 SumSigned",
               g_portfolio.SumSigned(base, 6), 80.0);
   CheckDouble("B2 HHI",
               g_portfolio.HerfindahlIndex(alloc, 5), 0.30);
   CheckBool("B3 NeedsRebalance",
             g_portfolio.NeedsRebalance(
                22.9, 25.0, 2.0
             ), true);
   CheckDouble("B4 MaximumDrawdownValue",
               g_portfolio.MaximumDrawdownValue(
                  equity, 8
               ), 200.0);
   CheckDouble("B5 DependencyScore",
               g_portfolio.DependencyScore(
                  correlations, 4, 0.70
               ), 0.041666666667,
               0.000000001);

   // Exposure gate
   CheckBool("ExposureLimitPass below",
             g_portfolio.ExposureLimitPass(
                3.0, 1.0, 5.0
             ), true);
   CheckBool("ExposureLimitPass exact",
             g_portfolio.ExposureLimitPass(
                3.0, 2.0, 5.0
             ), true);
   CheckBool("ExposureLimitPass above",
             g_portfolio.ExposureLimitPass(
                3.0, 2.1, 5.0
             ), false);
   CheckBool("ExposureLimitPass zero proposal",
             g_portfolio.ExposureLimitPass(
                3.0, 0.0, 5.0
             ), true);
   CheckBool("ExposureLimitPass invalid current",
             g_portfolio.ExposureLimitPass(
                -1.0, 1.0, 5.0
             ), false);
   CheckBool("ExposureLimitPass invalid proposal",
             g_portfolio.ExposureLimitPass(
                3.0, -1.0, 5.0
             ), false);
   CheckBool("ExposureLimitPass invalid max",
             g_portfolio.ExposureLimitPass(
                3.0, 1.0, -1.0
             ), false);
   CheckBool("ExposureLimitPass invalid epsilon",
             g_portfolio.ExposureLimitPass(
                3.0, 1.0, 5.0, -1.0
             ), false);

   // Concentration gate: projected component / projected portfolio
   CheckBool("ConcentrationLimitPass below",
             g_portfolio.ConcentrationLimitPass(
                20.0, 10.0, 100.0, 30.0
             ), true);
   CheckBool("ConcentrationLimitPass exact",
             g_portfolio.ConcentrationLimitPass(
                20.0, 14.285714285714, 100.0, 30.0
             ), true);
   CheckBool("ConcentrationLimitPass above",
             g_portfolio.ConcentrationLimitPass(
                20.0, 15.0, 100.0, 30.0
             ), false);
   CheckBool("ConcentrationLimitPass invalid current",
             g_portfolio.ConcentrationLimitPass(
                -1.0, 10.0, 100.0, 30.0
             ), false);
   CheckBool("ConcentrationLimitPass invalid proposal",
             g_portfolio.ConcentrationLimitPass(
                20.0, -1.0, 100.0, 30.0
             ), false);
   CheckBool("ConcentrationLimitPass invalid portfolio",
             g_portfolio.ConcentrationLimitPass(
                20.0, 10.0, 0.0, 30.0
             ), false);
   CheckBool("ConcentrationLimitPass invalid max",
             g_portfolio.ConcentrationLimitPass(
                20.0, 10.0, 100.0, -1.0
             ), false);

   // Capacity
   CheckDouble("MaximumAdmissibleExposure",
               g_portfolio.MaximumAdmissibleExposure(
                  3.0, 5.0
               ), 2.0);
   CheckDouble("MaximumAdmissibleExposure full",
               g_portfolio.MaximumAdmissibleExposure(
                  5.0, 5.0
               ), 0.0);
   CheckDouble("MaximumAdmissibleExposure over",
               g_portfolio.MaximumAdmissibleExposure(
                  6.0, 5.0
               ), 0.0);
   CheckDouble("MaximumAdmissibleExposure invalid",
               g_portfolio.MaximumAdmissibleExposure(
                  -1.0, 5.0
               ), 0.0);

   CheckDouble("MaximumAdmissibleConcentrationValue",
               g_portfolio.MaximumAdmissibleConcentrationValue(
                  20.0, 100.0, 30.0
               ), 14.285714285714,
               0.000000001);
   CheckDouble("MaximumAdmissibleConcentrationValue at limit",
               g_portfolio.MaximumAdmissibleConcentrationValue(
                  30.0, 100.0, 30.0
               ), 0.0);
   CheckDouble("MaximumAdmissibleConcentrationValue over",
               g_portfolio.MaximumAdmissibleConcentrationValue(
                  40.0, 100.0, 30.0
               ), 0.0);
   CheckDouble("MaximumAdmissibleConcentrationValue invalid portfolio",
               g_portfolio.MaximumAdmissibleConcentrationValue(
                  20.0, 0.0, 30.0
               ), 0.0);
   CheckDouble("MaximumAdmissibleConcentrationValue invalid percent",
               g_portfolio.MaximumAdmissibleConcentrationValue(
                  20.0, 100.0, 100.0
               ), 0.0);

   CheckDouble("MaximumAdmissibleValue exposure binds",
               g_portfolio.MaximumAdmissibleValue(
                  3.0, 5.0,
                  20.0, 100.0, 30.0
               ), 2.0);
   CheckDouble("MaximumAdmissibleValue concentration binds",
               g_portfolio.MaximumAdmissibleValue(
                  0.0, 100.0,
                  20.0, 100.0, 30.0
               ), 14.285714285714,
               0.000000001);

   // Admission scaling
   CheckDouble("ScaleAdmissionValue request binds",
               g_portfolio.ScaleAdmissionValue(
                  1.0,
                  3.0, 5.0,
                  20.0, 100.0, 30.0,
                  0.50, 0.70
               ), 1.0);
   CheckDouble("ScaleAdmissionValue exposure binds",
               g_portfolio.ScaleAdmissionValue(
                  10.0,
                  3.0, 5.0,
                  20.0, 100.0, 30.0,
                  0.50, 0.70
               ), 2.0);
   CheckDouble("ScaleAdmissionValue correlation half",
               g_portfolio.ScaleAdmissionValue(
                  2.0,
                  3.0, 5.0,
                  20.0, 100.0, 30.0,
                  0.85, 0.70
               ), 1.0);
   CheckDouble("ScaleAdmissionValue correlation zero",
               g_portfolio.ScaleAdmissionValue(
                  2.0,
                  3.0, 5.0,
                  20.0, 100.0, 30.0,
                  1.00, 0.70
               ), 0.0);
   CheckDouble("ScaleAdmissionValue invalid request",
               g_portfolio.ScaleAdmissionValue(
                  0.0,
                  3.0, 5.0,
                  20.0, 100.0, 30.0,
                  0.50, 0.70
               ), 0.0);

   // Composite admission
   CheckBool("PortfolioAdmissionPass true",
             g_portfolio.PortfolioAdmissionPass(
                1000.0, 950.0, 10.0,
                3.0, 1.0, 5.0,
                20.0, 100.0, 30.0,
                correlations, 4, 0.70, 1
             ), true);

   CheckBool("PortfolioAdmissionPass drawdown fail",
             g_portfolio.PortfolioAdmissionPass(
                1000.0, 850.0, 10.0,
                3.0, 1.0, 5.0,
                20.0, 100.0, 30.0,
                correlations, 4, 0.70, 1
             ), false);

   CheckBool("PortfolioAdmissionPass exposure fail",
             g_portfolio.PortfolioAdmissionPass(
                1000.0, 950.0, 10.0,
                3.0, 3.0, 5.0,
                20.0, 100.0, 30.0,
                correlations, 4, 0.70, 1
             ), false);

   CheckBool("PortfolioAdmissionPass concentration fail",
             g_portfolio.PortfolioAdmissionPass(
                1000.0, 950.0, 10.0,
                0.0, 15.0, 100.0,
                20.0, 100.0, 30.0,
                correlations, 4, 0.70, 1
             ), false);

   double dependent[4] = {0.80, -0.90, 0.20, 0.10};

   CheckBool("PortfolioAdmissionPass dependency fail",
             g_portfolio.PortfolioAdmissionPass(
                1000.0, 950.0, 10.0,
                3.0, 1.0, 5.0,
                20.0, 100.0, 30.0,
                dependent, 4, 0.70, 1
             ), false);

   CheckBool("PortfolioAdmissionPass invalid epsilon",
             g_portfolio.PortfolioAdmissionPass(
                1000.0, 950.0, 10.0,
                3.0, 1.0, 5.0,
                20.0, 100.0, 30.0,
                correlations, 4, 0.70, 1, -1.0
             ), false);

   // Deterministic control codes
   CheckInt("PortfolioControlCode pass",
            g_portfolio.PortfolioControlCode(
               1000.0, 950.0, 10.0,
               3.0, 1.0, 5.0,
               20.0, 100.0, 30.0,
               correlations, 4, 0.70, 1
            ), 0);

   CheckInt("PortfolioControlCode drawdown",
            g_portfolio.PortfolioControlCode(
               1000.0, 850.0, 10.0,
               3.0, 1.0, 5.0,
               20.0, 100.0, 30.0,
               correlations, 4, 0.70, 1
            ), 1);

   CheckInt("PortfolioControlCode exposure",
            g_portfolio.PortfolioControlCode(
               1000.0, 950.0, 10.0,
               3.0, 3.0, 5.0,
               20.0, 100.0, 30.0,
               correlations, 4, 0.70, 1
            ), 2);

   CheckInt("PortfolioControlCode concentration",
            g_portfolio.PortfolioControlCode(
               1000.0, 950.0, 10.0,
               0.0, 15.0, 100.0,
               20.0, 100.0, 30.0,
               correlations, 4, 0.70, 1
            ), 3);

   CheckInt("PortfolioControlCode dependency",
            g_portfolio.PortfolioControlCode(
               1000.0, 950.0, 10.0,
               3.0, 1.0, 5.0,
               20.0, 100.0, 30.0,
               dependent, 4, 0.70, 1
            ), 4);

   CheckInt("PortfolioControlCode invalid epsilon",
            g_portfolio.PortfolioControlCode(
               1000.0, 950.0, 10.0,
               3.0, 1.0, 5.0,
               20.0, 100.0, 30.0,
               correlations, 4, 0.70, 1, -1.0
            ), -1);

   // Precedence: drawdown must win before exposure/concentration/dependency
   CheckInt("PortfolioControlCode precedence",
            g_portfolio.PortfolioControlCode(
               1000.0, 800.0, 10.0,
               10.0, 10.0, 5.0,
               90.0, 100.0, 30.0,
               dependent, 4, 0.70, 0
            ), 1);

   Print("BossR_Portfolio_Verify_Block6_CONTROL_FULL: PASS ",
         g_pass,
         " / FAIL ",
         g_fail);

   ExpertRemove();
   return(INIT_SUCCEEDED);
}

void OnTick()
{
}
