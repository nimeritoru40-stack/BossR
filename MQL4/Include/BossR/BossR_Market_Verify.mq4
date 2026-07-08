//+------------------------------------------------------------------+
//| BossR_Market_Verify.mq4                                          |
//+------------------------------------------------------------------+
#property strict

#include <BossR\BossR_Market.mqh>

C_BossR_Market Market;

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

int OnInit()
{
   Print("=== BossR_Market Verification Started ===");

   Check(!Market.IsInitialized(), "Initial state is not initialized");

   Check(Market.Init(), "Init current symbol");

   Check(Market.IsInitialized(), "Initialized after Init");

   Check(Market.SymbolName() == Symbol(), "SymbolName equals chart symbol");

   Check(Market.DigitsValue() > 0, "DigitsValue > 0");

   Check(Market.PointValue() > 0.0, "PointValue > 0");

   Check(Market.PipValue() > 0.0, "PipValue > 0");

   int digits = Market.DigitsValue();

   if(digits == 3 || digits == 5)
      Check(MathAbs(Market.PipValue() - Market.PointValue() * 10.0) < 0.0000000001, "PipValue correct for 3/5 digit symbol");
   else
      Check(MathAbs(Market.PipValue() - Market.PointValue()) < 0.0000000001, "PipValue correct for non 3/5 digit symbol");

   Check(Market.Refresh(), "Refresh succeeds");

   Check(Market.BidValue() > 0.0, "BidValue > 0");

   Check(Market.AskValue() > 0.0, "AskValue > 0");

   Check(Market.AskValue() >= Market.BidValue(), "AskValue >= BidValue");

   Check(Market.SpreadPoints() >= 0.0, "SpreadPoints >= 0");

   Check(Market.SpreadPips() >= 0.0, "SpreadPips >= 0");

   Check(Market.HasValidPrices(), "HasValidPrices true");

   double ten_pips_price = Market.PipsToPrice(10.0);
   Check(ten_pips_price > 0.0, "PipsToPrice positive");

   double back_to_pips = Market.PriceToPips(ten_pips_price);
   Check(MathAbs(back_to_pips - 10.0) < 0.0000001, "PriceToPips inverse conversion");

   double raw_price = Market.AskValue() + Market.PipsToPrice(1.23456);
   double norm_price = Market.NormalizePrice(raw_price);

   Check(norm_price == NormalizeDouble(raw_price, Market.DigitsValue()), "NormalizePrice matches MT4 NormalizeDouble");

   Market.Shutdown();

   Check(!Market.IsInitialized(), "Shutdown clears initialized state");

   Check(Market.SymbolName() == "", "Shutdown clears symbol");

   Check(Market.DigitsValue() == 0, "DigitsValue returns 0 after shutdown");

   Check(Market.PointValue() == 0.0, "PointValue returns 0 after shutdown");

   Check(Market.PipValue() == 0.0, "PipValue returns 0 after shutdown");

   Check(Market.BidValue() == 0.0, "BidValue returns 0 after shutdown");

   Check(Market.AskValue() == 0.0, "AskValue returns 0 after shutdown");

   Check(Market.SpreadPoints() == 0.0, "SpreadPoints returns 0 after shutdown");

   Check(Market.SpreadPips() == 0.0, "SpreadPips returns 0 after shutdown");

   Check(!Market.Refresh(), "Refresh fails after shutdown");

   Check(!Market.HasValidPrices(), "HasValidPrices false after shutdown");

   Check(Market.PipsToPrice(10.0) == 0.0, "PipsToPrice returns 0 after shutdown");

   Check(Market.PriceToPips(0.0010) == 0.0, "PriceToPips returns 0 after shutdown");

   Print("=== BossR_Market Verification Complete ===");
   Print("PASS ", g_pass, " / FAIL ", g_fail);

   return INIT_SUCCEEDED;
}

void OnDeinit(const int reason)
{
}

void OnTick()
{
}