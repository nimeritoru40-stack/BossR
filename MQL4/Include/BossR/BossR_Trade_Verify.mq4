//+------------------------------------------------------------------+
//| BossR_Trade_Verify_Block6_FULL.mq4                              |
//| BossR Framework - Trade Module Verification                     |
//| Block 6                                                         |
//| Compile this EA only                                             |
//+------------------------------------------------------------------+
#property strict

#include <BossR\BossR_Trade_Block6_FULL.mqh>

C_BossR_Trade BossTrade;

int g_pass = 0;
int g_fail = 0;

//+------------------------------------------------------------------+
//| Test helpers                                                     |
//+------------------------------------------------------------------+
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
   Print("   actual=", actual,
         " expected=", expected);
}

void ExpectInt(const string test_name,
               const int actual,
               const int expected)
{
   if(actual == expected)
   {
      Pass(test_name);
      return;
   }

   Fail(test_name);
   Print("   actual=", actual,
         " expected=", expected);
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
   Print("   actual=",
         DoubleToString(actual, 10),
         " expected=",
         DoubleToString(expected, 10));
}

//+------------------------------------------------------------------+
//| Order type tests                                                 |
//+------------------------------------------------------------------+
void TestOrderTypes()
{
   ExpectBool("Market BUY", BossTrade.IsMarketOrderType(OP_BUY), true);
   ExpectBool("Market SELL", BossTrade.IsMarketOrderType(OP_SELL), true);
   ExpectBool("Market BUYLIMIT false", BossTrade.IsMarketOrderType(OP_BUYLIMIT), false);
   ExpectBool("Market invalid false", BossTrade.IsMarketOrderType(99), false);

   ExpectBool("Pending BUYLIMIT", BossTrade.IsPendingOrderType(OP_BUYLIMIT), true);
   ExpectBool("Pending SELLLIMIT", BossTrade.IsPendingOrderType(OP_SELLLIMIT), true);
   ExpectBool("Pending BUYSTOP", BossTrade.IsPendingOrderType(OP_BUYSTOP), true);
   ExpectBool("Pending SELLSTOP", BossTrade.IsPendingOrderType(OP_SELLSTOP), true);
   ExpectBool("Pending BUY false", BossTrade.IsPendingOrderType(OP_BUY), false);
   ExpectBool("Pending invalid false", BossTrade.IsPendingOrderType(-1), false);

   ExpectBool("Supported BUY", BossTrade.IsSupportedOrderType(OP_BUY), true);
   ExpectBool("Supported SELLSTOP", BossTrade.IsSupportedOrderType(OP_SELLSTOP), true);
   ExpectBool("Supported invalid false", BossTrade.IsSupportedOrderType(6), false);

   ExpectBool("BuySide BUY", BossTrade.IsBuySideType(OP_BUY), true);
   ExpectBool("BuySide BUYLIMIT", BossTrade.IsBuySideType(OP_BUYLIMIT), true);
   ExpectBool("BuySide BUYSTOP", BossTrade.IsBuySideType(OP_BUYSTOP), true);
   ExpectBool("BuySide SELL false", BossTrade.IsBuySideType(OP_SELL), false);

   ExpectBool("SellSide SELL", BossTrade.IsSellSideType(OP_SELL), true);
   ExpectBool("SellSide SELLLIMIT", BossTrade.IsSellSideType(OP_SELLLIMIT), true);
   ExpectBool("SellSide SELLSTOP", BossTrade.IsSellSideType(OP_SELLSTOP), true);
   ExpectBool("SellSide BUY false", BossTrade.IsSellSideType(OP_BUY), false);

   ExpectInt("Direction BUY +1", BossTrade.DirectionSign(OP_BUY), 1);
   ExpectInt("Direction BUYSTOP +1", BossTrade.DirectionSign(OP_BUYSTOP), 1);
   ExpectInt("Direction SELL -1", BossTrade.DirectionSign(OP_SELL), -1);
   ExpectInt("Direction SELLLIMIT -1", BossTrade.DirectionSign(OP_SELLLIMIT), -1);
   ExpectInt("Direction invalid zero", BossTrade.DirectionSign(99), 0);

   ExpectBool("Magic zero valid", BossTrade.IsValidMagicNumber(0), true);
   ExpectBool("Magic positive valid", BossTrade.IsValidMagicNumber(260713), true);
   ExpectBool("Magic negative false", BossTrade.IsValidMagicNumber(-1), false);
}

//+------------------------------------------------------------------+
//| Precision tests                                                  |
//+------------------------------------------------------------------+
void TestPrecision()
{
   ExpectInt("LotDigits 1", BossTrade.LotDigits(1.0), 0);
   ExpectInt("LotDigits 0.1", BossTrade.LotDigits(0.1), 1);
   ExpectInt("LotDigits 0.01", BossTrade.LotDigits(0.01), 2);
   ExpectInt("LotDigits 0.001", BossTrade.LotDigits(0.001), 3);
   ExpectInt("LotDigits invalid", BossTrade.LotDigits(0.0), 0);

   ExpectDouble("PipSize 5 digits", BossTrade.PipSize(0.00001, 5), 0.0001);
   ExpectDouble("PipSize 4 digits", BossTrade.PipSize(0.0001, 4), 0.0001);
   ExpectDouble("PipSize 3 digits", BossTrade.PipSize(0.001, 3), 0.01);
   ExpectDouble("PipSize 2 digits", BossTrade.PipSize(0.01, 2), 0.01);
   ExpectDouble("PipSize invalid point", BossTrade.PipSize(0.0, 5), 0.0);
   ExpectDouble("PipSize invalid digits", BossTrade.PipSize(0.00001, -1), 0.0);

   ExpectDouble("NormalizePrice 5 digits",
      BossTrade.NormalizePriceValue(1.1234567, 5), 1.12346);
   ExpectDouble("NormalizePrice 3 digits",
      BossTrade.NormalizePriceValue(150.1237, 3), 150.124);
   ExpectDouble("NormalizePrice invalid price",
      BossTrade.NormalizePriceValue(-1.0, 5), 0.0);
   ExpectDouble("NormalizePrice invalid digits",
      BossTrade.NormalizePriceValue(1.1000, 9), 0.0);
}

//+------------------------------------------------------------------+
//| Lot tests                                                        |
//+------------------------------------------------------------------+
void TestLots()
{
   ExpectDouble("NormalizeLots exact",
      BossTrade.NormalizeLotsValue(0.10,0.01,100.0,0.01), 0.10);
   ExpectDouble("NormalizeLots floor",
      BossTrade.NormalizeLotsValue(0.127,0.01,100.0,0.01), 0.12);
   ExpectDouble("NormalizeLots clamp min",
      BossTrade.NormalizeLotsValue(0.001,0.01,100.0,0.01), 0.01);
   ExpectDouble("NormalizeLots clamp max",
      BossTrade.NormalizeLotsValue(150.0,0.01,100.0,0.01), 100.0);
   ExpectDouble("NormalizeLots offset step",
      BossTrade.NormalizeLotsValue(0.36,0.05,10.0,0.10), 0.35);
   ExpectDouble("NormalizeLots invalid step",
      BossTrade.NormalizeLotsValue(0.10,0.01,100.0,0.0), 0.0);

   ExpectBool("ValidLots min", BossTrade.IsValidLots(0.01,0.01,100.0,0.01), true);
   ExpectBool("ValidLots middle", BossTrade.IsValidLots(0.25,0.01,100.0,0.01), true);
   ExpectBool("ValidLots max", BossTrade.IsValidLots(100.0,0.01,100.0,0.01), true);
   ExpectBool("ValidLots below min", BossTrade.IsValidLots(0.001,0.01,100.0,0.01), false);
   ExpectBool("ValidLots above max", BossTrade.IsValidLots(100.01,0.01,100.0,0.01), false);
   ExpectBool("ValidLots off step", BossTrade.IsValidLots(0.125,0.01,100.0,0.01), false);
}

//+------------------------------------------------------------------+
//| Distance tests                                                   |
//+------------------------------------------------------------------+
void TestDistances()
{
   ExpectDouble("SpreadPoints valid",
      BossTrade.SpreadPoints(1.10020,1.10000,0.00001), 20.0);
   ExpectDouble("SpreadPoints zero",
      BossTrade.SpreadPoints(1.10000,1.10000,0.00001), 0.0);
   ExpectDouble("SpreadPoints crossed invalid",
      BossTrade.SpreadPoints(1.09990,1.10000,0.00001), 0.0);
   ExpectDouble("SpreadPoints point invalid",
      BossTrade.SpreadPoints(1.10020,1.10000,0.0), 0.0);

   ExpectDouble("DistancePoints valid",
      BossTrade.PriceDistancePoints(1.10100,1.10000,0.00001), 100.0);
   ExpectDouble("DistancePoints reverse",
      BossTrade.PriceDistancePoints(1.10000,1.10100,0.00001), 100.0);
   ExpectDouble("DistancePoints equal",
      BossTrade.PriceDistancePoints(1.10000,1.10000,0.00001), 0.0);
   ExpectDouble("DistancePoints invalid point",
      BossTrade.PriceDistancePoints(1.10100,1.10000,0.0), 0.0);
}

//+------------------------------------------------------------------+
//| Stop and target tests                                            |
//+------------------------------------------------------------------+
void TestStopsAndTargets()
{
   ExpectBool("BUY SL valid",
      BossTrade.IsStopLossValid(OP_BUY,1.10000,1.09900,50,0.00001), true);
   ExpectBool("BUY SL boundary valid",
      BossTrade.IsStopLossValid(OP_BUY,1.10000,1.09950,50,0.00001), true);
   ExpectBool("BUY SL too close",
      BossTrade.IsStopLossValid(OP_BUY,1.10000,1.09960,50,0.00001), false);
   ExpectBool("SELL SL valid",
      BossTrade.IsStopLossValid(OP_SELL,1.10000,1.10100,50,0.00001), true);
   ExpectBool("SELL SL boundary valid",
      BossTrade.IsStopLossValid(OP_SELL,1.10000,1.10050,50,0.00001), true);
   ExpectBool("SELL SL too close",
      BossTrade.IsStopLossValid(OP_SELL,1.10000,1.10040,50,0.00001), false);
   ExpectBool("SL invalid type",
      BossTrade.IsStopLossValid(99,1.10000,1.09900,50,0.00001), false);

   ExpectBool("BUY TP valid",
      BossTrade.IsTakeProfitValid(OP_BUY,1.10000,1.10100,50,0.00001), true);
   ExpectBool("BUY TP boundary valid",
      BossTrade.IsTakeProfitValid(OP_BUY,1.10000,1.10050,50,0.00001), true);
   ExpectBool("BUY TP too close",
      BossTrade.IsTakeProfitValid(OP_BUY,1.10000,1.10040,50,0.00001), false);
   ExpectBool("SELL TP valid",
      BossTrade.IsTakeProfitValid(OP_SELL,1.10000,1.09900,50,0.00001), true);
   ExpectBool("SELL TP boundary valid",
      BossTrade.IsTakeProfitValid(OP_SELL,1.10000,1.09950,50,0.00001), true);
   ExpectBool("SELL TP too close",
      BossTrade.IsTakeProfitValid(OP_SELL,1.10000,1.09960,50,0.00001), false);
   ExpectBool("TP invalid type",
      BossTrade.IsTakeProfitValid(99,1.10000,1.10100,50,0.00001), false);
}


//+------------------------------------------------------------------+
//| Block 2 directional move tests                                   |
//+------------------------------------------------------------------+
void TestDirectionalMoves()
{
   ExpectDouble("SignedPriceMove BUY profit",
      BossTrade.SignedPriceMove(OP_BUY,1.1000,1.1020), 0.0020);
   ExpectDouble("SignedPriceMove BUY loss",
      BossTrade.SignedPriceMove(OP_BUY,1.1000,1.0980), -0.0020);
   ExpectDouble("SignedPriceMove SELL profit",
      BossTrade.SignedPriceMove(OP_SELL,1.1000,1.0980), 0.0020);
   ExpectDouble("SignedPriceMove SELL loss",
      BossTrade.SignedPriceMove(OP_SELL,1.1000,1.1020), -0.0020);
   ExpectDouble("SignedPriceMove pending buy",
      BossTrade.SignedPriceMove(OP_BUYSTOP,1.1000,1.1010), 0.0010);
   ExpectDouble("SignedPriceMove invalid type",
      BossTrade.SignedPriceMove(99,1.1000,1.1010), 0.0);

   ExpectDouble("SignedMovePoints BUY +100",
      BossTrade.SignedMovePoints(OP_BUY,1.1000,1.1010,0.00001), 100.0);
   ExpectDouble("SignedMovePoints SELL +100",
      BossTrade.SignedMovePoints(OP_SELL,1.1000,1.0990,0.00001), 100.0);
   ExpectDouble("SignedMovePoints BUY -100",
      BossTrade.SignedMovePoints(OP_BUY,1.1000,1.0990,0.00001), -100.0);
   ExpectDouble("SignedMovePoints invalid point",
      BossTrade.SignedMovePoints(OP_BUY,1.1000,1.1010,0.0), 0.0);

   ExpectBool("IsProfitableMove BUY true",
      BossTrade.IsProfitableMove(OP_BUY,1.1000,1.1010), true);
   ExpectBool("IsProfitableMove SELL true",
      BossTrade.IsProfitableMove(OP_SELL,1.1000,1.0990), true);
   ExpectBool("IsProfitableMove flat false",
      BossTrade.IsProfitableMove(OP_BUY,1.1000,1.1000), false);
   ExpectBool("IsLosingMove BUY true",
      BossTrade.IsLosingMove(OP_BUY,1.1000,1.0990), true);
   ExpectBool("IsLosingMove SELL true",
      BossTrade.IsLosingMove(OP_SELL,1.1000,1.1010), true);
   ExpectBool("IsLosingMove flat false",
      BossTrade.IsLosingMove(OP_SELL,1.1000,1.1000), false);
}

//+------------------------------------------------------------------+
//| Block 2 risk/reward tests                                        |
//+------------------------------------------------------------------+
void TestRiskReward()
{
   ExpectDouble("RiskDistance BUY",
      BossTrade.RiskDistancePoints(OP_BUY,1.1000,1.0990,0.00001), 100.0);
   ExpectDouble("RiskDistance SELL",
      BossTrade.RiskDistancePoints(OP_SELL,1.1000,1.1010,0.00001), 100.0);
   ExpectDouble("RiskDistance wrong BUY side",
      BossTrade.RiskDistancePoints(OP_BUY,1.1000,1.1010,0.00001), 0.0);
   ExpectDouble("RiskDistance invalid type",
      BossTrade.RiskDistancePoints(99,1.1000,1.0990,0.00001), 0.0);

   ExpectDouble("RewardDistance BUY",
      BossTrade.RewardDistancePoints(OP_BUY,1.1000,1.1020,0.00001), 200.0);
   ExpectDouble("RewardDistance SELL",
      BossTrade.RewardDistancePoints(OP_SELL,1.1000,1.0980,0.00001), 200.0);
   ExpectDouble("RewardDistance wrong SELL side",
      BossTrade.RewardDistancePoints(OP_SELL,1.1000,1.1020,0.00001), 0.0);
   ExpectDouble("RewardDistance invalid point",
      BossTrade.RewardDistancePoints(OP_BUY,1.1000,1.1020,0.0), 0.0);

   ExpectDouble("RiskReward BUY 2",
      BossTrade.RiskRewardRatio(OP_BUY,1.1000,1.0990,1.1020,0.00001), 2.0);
   ExpectDouble("RiskReward SELL 3",
      BossTrade.RiskRewardRatio(OP_SELL,1.1000,1.1010,1.0970,0.00001), 3.0);
   ExpectDouble("RiskReward invalid stop",
      BossTrade.RiskRewardRatio(OP_BUY,1.1000,1.1010,1.1020,0.00001), 0.0);
   ExpectDouble("RiskReward invalid target",
      BossTrade.RiskRewardRatio(OP_BUY,1.1000,1.0990,1.0980,0.00001), 0.0);

   ExpectBool("RiskRewardAtLeast exact true",
      BossTrade.IsRiskRewardAtLeast(OP_BUY,1.1000,1.0990,1.1020,0.00001,2.0), true);
   ExpectBool("RiskRewardAtLeast above true",
      BossTrade.IsRiskRewardAtLeast(OP_BUY,1.1000,1.0990,1.1030,0.00001,2.0), true);
   ExpectBool("RiskRewardAtLeast below false",
      BossTrade.IsRiskRewardAtLeast(OP_BUY,1.1000,1.0990,1.1015,0.00001,2.0), false);
   ExpectBool("RiskRewardAtLeast negative minimum false",
      BossTrade.IsRiskRewardAtLeast(OP_BUY,1.1000,1.0990,1.1020,0.00001,-1.0), false);
}

//+------------------------------------------------------------------+
//| Block 2 money and lot sizing tests                               |
//+------------------------------------------------------------------+
void TestRiskSizing()
{
   ExpectDouble("RiskMoney one percent",
      BossTrade.RiskMoney(10000.0,1.0), 100.0);
   ExpectDouble("RiskMoney half percent",
      BossTrade.RiskMoney(10000.0,0.5), 50.0);
   ExpectDouble("RiskMoney full percent",
      BossTrade.RiskMoney(10000.0,100.0), 10000.0);
   ExpectDouble("RiskMoney zero balance invalid",
      BossTrade.RiskMoney(0.0,1.0), 0.0);
   ExpectDouble("RiskMoney zero risk invalid",
      BossTrade.RiskMoney(10000.0,0.0), 0.0);
   ExpectDouble("RiskMoney over 100 invalid",
      BossTrade.RiskMoney(10000.0,101.0), 0.0);

   ExpectDouble("RawLotsByRisk one lot",
      BossTrade.RawLotsByRisk(100.0,100.0,1.0,1.0), 1.0);
   ExpectDouble("RawLotsByRisk half lot",
      BossTrade.RawLotsByRisk(50.0,100.0,1.0,1.0), 0.5);
   ExpectDouble("RawLotsByRisk tick size two",
      BossTrade.RawLotsByRisk(100.0,100.0,2.0,2.0), 1.0);
   ExpectDouble("RawLotsByRisk invalid stop",
      BossTrade.RawLotsByRisk(100.0,0.0,1.0,1.0), 0.0);
   ExpectDouble("RawLotsByRisk invalid tick value",
      BossTrade.RawLotsByRisk(100.0,100.0,0.0,1.0), 0.0);

   ExpectDouble("LotsByRisk exact",
      BossTrade.LotsByRisk(10000.0,1.0,100.0,1.0,1.0,0.01,100.0,0.01), 1.0);
   ExpectDouble("LotsByRisk floor",
      BossTrade.LotsByRisk(10000.0,1.0,333.0,1.0,1.0,0.01,100.0,0.01), 0.30);
   ExpectDouble("LotsByRisk clamp min",
      BossTrade.LotsByRisk(1000.0,0.1,10000.0,1.0,1.0,0.01,100.0,0.01), 0.01);
   ExpectDouble("LotsByRisk clamp max",
      BossTrade.LotsByRisk(1000000.0,100.0,1.0,1.0,1.0,0.01,100.0,0.01), 100.0);
   ExpectDouble("LotsByRisk invalid risk",
      BossTrade.LotsByRisk(10000.0,0.0,100.0,1.0,1.0,0.01,100.0,0.01), 0.0);
}

//+------------------------------------------------------------------+
//| Block 2 spread limit tests                                       |
//+------------------------------------------------------------------+
void TestSpreadLimit()
{
   ExpectBool("SpreadWithinLimit below",
      BossTrade.IsSpreadWithinLimit(1.10010,1.10000,0.00001,20.0), true);
   ExpectBool("SpreadWithinLimit exact",
      BossTrade.IsSpreadWithinLimit(1.10020,1.10000,0.00001,20.0), true);
   ExpectBool("SpreadWithinLimit above",
      BossTrade.IsSpreadWithinLimit(1.10021,1.10000,0.00001,20.0), false);
   ExpectBool("SpreadWithinLimit zero spread",
      BossTrade.IsSpreadWithinLimit(1.10000,1.10000,0.00001,0.0), true);
   ExpectBool("SpreadWithinLimit crossed false",
      BossTrade.IsSpreadWithinLimit(1.09990,1.10000,0.00001,20.0), false);
   ExpectBool("SpreadWithinLimit negative max false",
      BossTrade.IsSpreadWithinLimit(1.10010,1.10000,0.00001,-1.0), false);
}


//+------------------------------------------------------------------+
//| Block 3 tests                                                    |
//+------------------------------------------------------------------+
void TestTradeIdentity()
{
   ExpectBool("Identity exact true",BossTrade.MatchesTradeIdentity("EURUSD",260713,"EURUSD",260713),true);
   ExpectBool("Identity symbol mismatch",BossTrade.MatchesTradeIdentity("GBPUSD",260713,"EURUSD",260713),false);
   ExpectBool("Identity magic mismatch",BossTrade.MatchesTradeIdentity("EURUSD",260714,"EURUSD",260713),false);
   ExpectBool("Identity case sensitive",BossTrade.MatchesTradeIdentity("eurusd",260713,"EURUSD",260713),false);
   ExpectBool("Identity empty order symbol",BossTrade.MatchesTradeIdentity("",260713,"EURUSD",260713),false);
   ExpectBool("Identity empty required symbol",BossTrade.MatchesTradeIdentity("EURUSD",260713,"",260713),false);
   ExpectBool("Identity negative magic",BossTrade.MatchesTradeIdentity("EURUSD",-1,"EURUSD",260713),false);
   ExpectBool("Identity zero magic true",BossTrade.MatchesTradeIdentity("EURUSD",0,"EURUSD",0),true);
}

void TestEntryGuards()
{
   datetime b1=D'2026.07.13 12:00:00';
   datetime b2=D'2026.07.13 12:01:00';
   ExpectBool("EntryBar no prior true",BossTrade.IsEntryBarAllowed(b1,0),true);
   ExpectBool("EntryBar different true",BossTrade.IsEntryBarAllowed(b2,b1),true);
   ExpectBool("EntryBar same false",BossTrade.IsEntryBarAllowed(b1,b1),false);
   ExpectBool("EntryBar invalid current false",BossTrade.IsEntryBarAllowed(0,b1),false);
   ExpectBool("EntryBar future prior different",BossTrade.IsEntryBarAllowed(b1,b2),true);
   ExpectBool("Slippage zero valid",BossTrade.IsSlippageValid(0),true);
   ExpectBool("Slippage positive valid",BossTrade.IsSlippageValid(30),true);
   ExpectBool("Slippage negative false",BossTrade.IsSlippageValid(-1),false);
}

void TestMarketEntryPrice()
{
   ExpectDouble("MarketEntry BUY ask",BossTrade.MarketEntryPrice(OP_BUY,1.10020,1.10000),1.10020);
   ExpectDouble("MarketEntry SELL bid",BossTrade.MarketEntryPrice(OP_SELL,1.10020,1.10000),1.10000);
   ExpectDouble("MarketEntry pending false",BossTrade.MarketEntryPrice(OP_BUYSTOP,1.10020,1.10000),0.0);
   ExpectDouble("MarketEntry invalid type",BossTrade.MarketEntryPrice(99,1.10020,1.10000),0.0);
   ExpectDouble("MarketEntry crossed prices",BossTrade.MarketEntryPrice(OP_BUY,1.09990,1.10000),0.0);
   ExpectDouble("MarketEntry zero ask",BossTrade.MarketEntryPrice(OP_BUY,0.0,1.10000),0.0);
   ExpectDouble("MarketEntry zero bid",BossTrade.MarketEntryPrice(OP_SELL,1.10020,0.0),0.0);
}

void TestPendingEntryPrices()
{
   double ask=1.10020,bid=1.10000,pt=0.00001;
   ExpectBool("BUYLIMIT valid",BossTrade.IsPendingEntryPriceValid(OP_BUYLIMIT,1.09950,ask,bid,50,pt),true);
   ExpectBool("BUYLIMIT boundary",BossTrade.IsPendingEntryPriceValid(OP_BUYLIMIT,1.09970,ask,bid,50,pt),true);
   ExpectBool("BUYLIMIT too close",BossTrade.IsPendingEntryPriceValid(OP_BUYLIMIT,1.09980,ask,bid,50,pt),false);
   ExpectBool("SELLLIMIT valid",BossTrade.IsPendingEntryPriceValid(OP_SELLLIMIT,1.10070,ask,bid,50,pt),true);
   ExpectBool("SELLLIMIT boundary",BossTrade.IsPendingEntryPriceValid(OP_SELLLIMIT,1.10050,ask,bid,50,pt),true);
   ExpectBool("SELLLIMIT too close",BossTrade.IsPendingEntryPriceValid(OP_SELLLIMIT,1.10040,ask,bid,50,pt),false);
   ExpectBool("BUYSTOP valid",BossTrade.IsPendingEntryPriceValid(OP_BUYSTOP,1.10090,ask,bid,50,pt),true);
   ExpectBool("BUYSTOP boundary",BossTrade.IsPendingEntryPriceValid(OP_BUYSTOP,1.10070,ask,bid,50,pt),true);
   ExpectBool("BUYSTOP too close",BossTrade.IsPendingEntryPriceValid(OP_BUYSTOP,1.10060,ask,bid,50,pt),false);
   ExpectBool("SELLSTOP valid",BossTrade.IsPendingEntryPriceValid(OP_SELLSTOP,1.09930,ask,bid,50,pt),true);
   ExpectBool("SELLSTOP boundary",BossTrade.IsPendingEntryPriceValid(OP_SELLSTOP,1.09950,ask,bid,50,pt),true);
   ExpectBool("SELLSTOP too close",BossTrade.IsPendingEntryPriceValid(OP_SELLSTOP,1.09960,ask,bid,50,pt),false);
   ExpectBool("Pending market type false",BossTrade.IsPendingEntryPriceValid(OP_BUY,1.09950,ask,bid,50,pt),false);
   ExpectBool("Pending crossed market false",BossTrade.IsPendingEntryPriceValid(OP_BUYLIMIT,1.09950,1.09990,1.10000,50,pt),false);
   ExpectBool("Pending negative distance false",BossTrade.IsPendingEntryPriceValid(OP_BUYLIMIT,1.09950,ask,bid,-1,pt),false);
   ExpectBool("Pending invalid point false",BossTrade.IsPendingEntryPriceValid(OP_BUYLIMIT,1.09950,ask,bid,50,0.0),false);
}

void TestRequestValidation()
{
   datetime now=D'2026.07.13 12:00:00';
   ExpectBool("Expiration zero valid",BossTrade.IsExpirationValid(0,now),true);
   ExpectBool("Expiration future valid",BossTrade.IsExpirationValid(D'2026.07.13 13:00:00',now),true);
   ExpectBool("Expiration exact false",BossTrade.IsExpirationValid(now,now),false);
   ExpectBool("Expiration past false",BossTrade.IsExpirationValid(D'2026.07.13 11:00:00',now),false);
   ExpectBool("Expiration invalid current false",BossTrade.IsExpirationValid(0,0),false);
   ExpectBool("Request market valid",BossTrade.IsTradeRequestStructurallyValid(OP_BUY,0.10,0.01,100.0,0.01,260713,30),true);
   ExpectBool("Request pending valid",BossTrade.IsTradeRequestStructurallyValid(OP_SELLSTOP,0.10,0.01,100.0,0.01,260713,0),true);
   ExpectBool("Request invalid type",BossTrade.IsTradeRequestStructurallyValid(99,0.10,0.01,100.0,0.01,260713,30),false);
   ExpectBool("Request invalid lots",BossTrade.IsTradeRequestStructurallyValid(OP_BUY,0.125,0.01,100.0,0.01,260713,30),false);
   ExpectBool("Request invalid magic",BossTrade.IsTradeRequestStructurallyValid(OP_BUY,0.10,0.01,100.0,0.01,-1,30),false);
   ExpectBool("Request invalid slippage",BossTrade.IsTradeRequestStructurallyValid(OP_BUY,0.10,0.01,100.0,0.01,260713,-1),false);
}


//+------------------------------------------------------------------+
//| Block 4 profit accounting tests                                  |
//+------------------------------------------------------------------+
void TestProfitAccounting()
{
   ExpectDouble("GrossProfit BUY win",
      BossTrade.GrossProfitMoney(OP_BUY,1.1000,1.1010,1.0,1.0,1.0,0.00001),100.0);
   ExpectDouble("GrossProfit BUY loss",
      BossTrade.GrossProfitMoney(OP_BUY,1.1000,1.0990,1.0,1.0,1.0,0.00001),-100.0);
   ExpectDouble("GrossProfit SELL win",
      BossTrade.GrossProfitMoney(OP_SELL,1.1000,1.0990,1.0,1.0,1.0,0.00001),100.0);
   ExpectDouble("GrossProfit SELL loss",
      BossTrade.GrossProfitMoney(OP_SELL,1.1000,1.1010,1.0,1.0,1.0,0.00001),-100.0);
   ExpectDouble("GrossProfit half lot",
      BossTrade.GrossProfitMoney(OP_BUY,1.1000,1.1010,0.5,1.0,1.0,0.00001),50.0);
   ExpectDouble("GrossProfit tick size two",
      BossTrade.GrossProfitMoney(OP_BUY,1.1000,1.1010,1.0,2.0,2.0,0.00001),100.0);
   ExpectDouble("GrossProfit pending invalid",
      BossTrade.GrossProfitMoney(OP_BUYSTOP,1.1000,1.1010,1.0,1.0,1.0,0.00001),0.0);
   ExpectDouble("GrossProfit invalid lots",
      BossTrade.GrossProfitMoney(OP_BUY,1.1000,1.1010,0.0,1.0,1.0,0.00001),0.0);

   ExpectDouble("NetProfit positive fees",
      BossTrade.NetProfitMoney(100.0,-7.0,-1.5),91.5);
   ExpectDouble("NetProfit loss",
      BossTrade.NetProfitMoney(-100.0,-7.0,1.0),-106.0);
   ExpectDouble("NetProfit zero",
      BossTrade.NetProfitMoney(5.0,-4.0,-1.0),0.0);

   ExpectBool("NetWinner true",
      BossTrade.IsNetWinner(100.0,-7.0,-1.5),true);
   ExpectBool("NetWinner zero false",
      BossTrade.IsNetWinner(5.0,-4.0,-1.0),false);
   ExpectBool("NetLoser true",
      BossTrade.IsNetLoser(-100.0,-7.0,1.0),true);
   ExpectBool("NetLoser zero false",
      BossTrade.IsNetLoser(5.0,-4.0,-1.0),false);
}

//+------------------------------------------------------------------+
//| Block 4 lifecycle tests                                          |
//+------------------------------------------------------------------+
void TestLifecycle()
{
   datetime open_time=D'2026.07.13 12:00:00';
   datetime later=D'2026.07.13 12:05:30';
   datetime earlier=D'2026.07.13 11:59:59';

   ExpectBool("TradeOpen zero close",
      BossTrade.IsTradeOpen(0),true);
   ExpectBool("TradeOpen closed false",
      BossTrade.IsTradeOpen(later),false);
   ExpectBool("TradeClosed true",
      BossTrade.IsTradeClosed(later),true);
   ExpectBool("TradeClosed zero false",
      BossTrade.IsTradeClosed(0),false);

   ExpectInt("HeldSeconds valid",
      BossTrade.HeldSeconds(open_time,later),330);
   ExpectInt("HeldSeconds same",
      BossTrade.HeldSeconds(open_time,open_time),0);
   ExpectInt("HeldSeconds earlier invalid",
      BossTrade.HeldSeconds(open_time,earlier),0);
   ExpectInt("HeldSeconds invalid open",
      BossTrade.HeldSeconds(0,later),0);

   ExpectBool("HoldLimit below false",
      BossTrade.HasReachedHoldLimit(open_time,later,331),false);
   ExpectBool("HoldLimit exact true",
      BossTrade.HasReachedHoldLimit(open_time,later,330),true);
   ExpectBool("HoldLimit above true",
      BossTrade.HasReachedHoldLimit(open_time,later,300),true);
   ExpectBool("HoldLimit zero exact true",
      BossTrade.HasReachedHoldLimit(open_time,open_time,0),true);
   ExpectBool("HoldLimit negative false",
      BossTrade.HasReachedHoldLimit(open_time,later,-1),false);
   ExpectBool("HoldLimit invalid time false",
      BossTrade.HasReachedHoldLimit(0,later,60),false);
}

//+------------------------------------------------------------------+
//| Block 4 points target tests                                      |
//+------------------------------------------------------------------+
void TestPointTargets()
{
   ExpectDouble("ProfitPoints BUY win",
      BossTrade.ProfitPoints(OP_BUY,1.1000,1.1010,0.00001),100.0);
   ExpectDouble("ProfitPoints SELL win",
      BossTrade.ProfitPoints(OP_SELL,1.1000,1.0990,0.00001),100.0);
   ExpectDouble("ProfitPoints BUY loss",
      BossTrade.ProfitPoints(OP_BUY,1.1000,1.0990,0.00001),-100.0);
   ExpectDouble("ProfitPoints pending invalid",
      BossTrade.ProfitPoints(OP_BUYSTOP,1.1000,1.1010,0.00001),0.0);

   ExpectBool("ProfitTarget below false",
      BossTrade.HasReachedProfitTargetPoints(OP_BUY,1.1000,1.1009,0.00001,100.0),false);
   ExpectBool("ProfitTarget exact true",
      BossTrade.HasReachedProfitTargetPoints(OP_BUY,1.1000,1.1010,0.00001,100.0),true);
   ExpectBool("ProfitTarget above true",
      BossTrade.HasReachedProfitTargetPoints(OP_SELL,1.1000,1.0989,0.00001,100.0),true);
   ExpectBool("ProfitTarget negative false",
      BossTrade.HasReachedProfitTargetPoints(OP_BUY,1.1000,1.1010,0.00001,-1.0),false);

   ExpectBool("LossLimit below false",
      BossTrade.HasReachedLossLimitPoints(OP_BUY,1.1000,1.0991,0.00001,100.0),false);
   ExpectBool("LossLimit exact true",
      BossTrade.HasReachedLossLimitPoints(OP_BUY,1.1000,1.0990,0.00001,100.0),true);
   ExpectBool("LossLimit beyond true",
      BossTrade.HasReachedLossLimitPoints(OP_SELL,1.1000,1.1011,0.00001,100.0),true);
   ExpectBool("LossLimit negative false",
      BossTrade.HasReachedLossLimitPoints(OP_BUY,1.1000,1.0990,0.00001,-1.0),false);
}


//+------------------------------------------------------------------+
//| Block 5 close validation tests                                   |
//+------------------------------------------------------------------+
void TestCloseValidation()
{
   ExpectBool("CloseLots full valid",
      BossTrade.IsCloseLotsValid(1.00,1.00,0.01,0.01),true);
   ExpectBool("CloseLots partial valid",
      BossTrade.IsCloseLotsValid(0.40,1.00,0.01,0.01),true);
   ExpectBool("CloseLots leaves min valid",
      BossTrade.IsCloseLotsValid(0.99,1.00,0.01,0.01),true);
   ExpectBool("CloseLots leaves below min false",
      BossTrade.IsCloseLotsValid(0.995,1.00,0.01,0.01),false);
   ExpectBool("CloseLots above order false",
      BossTrade.IsCloseLotsValid(1.01,1.00,0.01,0.01),false);
   ExpectBool("CloseLots zero false",
      BossTrade.IsCloseLotsValid(0.00,1.00,0.01,0.01),false);
   ExpectBool("CloseLots off step false",
      BossTrade.IsCloseLotsValid(0.125,1.00,0.01,0.01),false);

   ExpectDouble("ClosePrice BUY bid",
      BossTrade.ClosePriceForMarketOrder(OP_BUY,1.10020,1.10000),1.10000);
   ExpectDouble("ClosePrice SELL ask",
      BossTrade.ClosePriceForMarketOrder(OP_SELL,1.10020,1.10000),1.10020);
   ExpectDouble("ClosePrice pending false",
      BossTrade.ClosePriceForMarketOrder(OP_BUYSTOP,1.10020,1.10000),0.0);
   ExpectDouble("ClosePrice crossed false",
      BossTrade.ClosePriceForMarketOrder(OP_BUY,1.09990,1.10000),0.0);

   ExpectBool("CloseRequest full valid",
      BossTrade.IsMarketCloseRequestValid(OP_BUY,1.00,1.00,0.01,0.01,30),true);
   ExpectBool("CloseRequest partial valid",
      BossTrade.IsMarketCloseRequestValid(OP_SELL,0.50,1.00,0.01,0.01,0),true);
   ExpectBool("CloseRequest pending false",
      BossTrade.IsMarketCloseRequestValid(OP_BUYSTOP,1.00,1.00,0.01,0.01,30),false);
   ExpectBool("CloseRequest bad lots false",
      BossTrade.IsMarketCloseRequestValid(OP_BUY,0.125,1.00,0.01,0.01,30),false);
   ExpectBool("CloseRequest bad slippage false",
      BossTrade.IsMarketCloseRequestValid(OP_BUY,1.00,1.00,0.01,0.01,-1),false);
}

//+------------------------------------------------------------------+
//| Block 5 modification tests                                       |
//+------------------------------------------------------------------+
void TestModificationHelpers()
{
   ExpectBool("StopImprove BUY no existing",
      BossTrade.IsStopModificationImprovement(OP_BUY,0.0,1.0990),true);
   ExpectBool("StopImprove BUY higher true",
      BossTrade.IsStopModificationImprovement(OP_BUY,1.0990,1.0995),true);
   ExpectBool("StopImprove BUY same false",
      BossTrade.IsStopModificationImprovement(OP_BUY,1.0990,1.0990),false);
   ExpectBool("StopImprove BUY lower false",
      BossTrade.IsStopModificationImprovement(OP_BUY,1.0990,1.0985),false);
   ExpectBool("StopImprove SELL lower true",
      BossTrade.IsStopModificationImprovement(OP_SELL,1.1010,1.1005),true);
   ExpectBool("StopImprove SELL same false",
      BossTrade.IsStopModificationImprovement(OP_SELL,1.1010,1.1010),false);
   ExpectBool("StopImprove SELL higher false",
      BossTrade.IsStopModificationImprovement(OP_SELL,1.1010,1.1015),false);
   ExpectBool("StopImprove invalid type false",
      BossTrade.IsStopModificationImprovement(OP_BUYSTOP,0.0,1.0990),false);

   ExpectBool("TPImprove BUY no existing",
      BossTrade.IsTakeProfitModificationImprovement(OP_BUY,0.0,1.1020),true);
   ExpectBool("TPImprove BUY higher true",
      BossTrade.IsTakeProfitModificationImprovement(OP_BUY,1.1020,1.1030),true);
   ExpectBool("TPImprove BUY same false",
      BossTrade.IsTakeProfitModificationImprovement(OP_BUY,1.1020,1.1020),false);
   ExpectBool("TPImprove BUY lower false",
      BossTrade.IsTakeProfitModificationImprovement(OP_BUY,1.1020,1.1010),false);
   ExpectBool("TPImprove SELL lower true",
      BossTrade.IsTakeProfitModificationImprovement(OP_SELL,1.0980,1.0970),true);
   ExpectBool("TPImprove SELL same false",
      BossTrade.IsTakeProfitModificationImprovement(OP_SELL,1.0980,1.0980),false);
   ExpectBool("TPImprove SELL higher false",
      BossTrade.IsTakeProfitModificationImprovement(OP_SELL,1.0980,1.0990),false);
   ExpectBool("TPImprove invalid type false",
      BossTrade.IsTakeProfitModificationImprovement(OP_SELLSTOP,0.0,1.0980),false);
}

//+------------------------------------------------------------------+
//| Block 5 breakeven tests                                          |
//+------------------------------------------------------------------+
void TestBreakeven()
{
   ExpectDouble("Breakeven BUY zero offset",
      BossTrade.BreakevenPrice(OP_BUY,1.10000,0,0.00001,5),1.10000);
   ExpectDouble("Breakeven BUY positive offset",
      BossTrade.BreakevenPrice(OP_BUY,1.10000,20,0.00001,5),1.10020);
   ExpectDouble("Breakeven SELL positive offset",
      BossTrade.BreakevenPrice(OP_SELL,1.10000,20,0.00001,5),1.09980);
   ExpectDouble("Breakeven invalid type",
      BossTrade.BreakevenPrice(OP_BUYSTOP,1.10000,20,0.00001,5),0.0);
   ExpectDouble("Breakeven negative offset",
      BossTrade.BreakevenPrice(OP_BUY,1.10000,-1,0.00001,5),0.0);

   ExpectBool("BETrigger BUY below false",
      BossTrade.HasReachedBreakevenTrigger(OP_BUY,1.1000,1.1009,0.00001,100.0),false);
   ExpectBool("BETrigger BUY exact true",
      BossTrade.HasReachedBreakevenTrigger(OP_BUY,1.1000,1.1010,0.00001,100.0),true);
   ExpectBool("BETrigger SELL above true",
      BossTrade.HasReachedBreakevenTrigger(OP_SELL,1.1000,1.0989,0.00001,100.0),true);
   ExpectBool("BETrigger negative false",
      BossTrade.HasReachedBreakevenTrigger(OP_BUY,1.1000,1.1010,0.00001,-1.0),false);

   ExpectBool("ShouldBE BUY true",
      BossTrade.ShouldMoveStopToBreakeven(OP_BUY,1.1000,1.1010,1.0990,100.0,0.0,0.00001,5),true);
   ExpectBool("ShouldBE BUY not triggered",
      BossTrade.ShouldMoveStopToBreakeven(OP_BUY,1.1000,1.1009,1.0990,100.0,0.0,0.00001,5),false);
   ExpectBool("ShouldBE BUY already better false",
      BossTrade.ShouldMoveStopToBreakeven(OP_BUY,1.1000,1.1010,1.1005,100.0,0.0,0.00001,5),false);
   ExpectBool("ShouldBE SELL true",
      BossTrade.ShouldMoveStopToBreakeven(OP_SELL,1.1000,1.0990,1.1010,100.0,0.0,0.00001,5),true);
   ExpectBool("ShouldBE SELL already better false",
      BossTrade.ShouldMoveStopToBreakeven(OP_SELL,1.1000,1.0990,1.0995,100.0,0.0,0.00001,5),false);
}


//+------------------------------------------------------------------+
//| Block 6 trailing stop tests                                      |
//+------------------------------------------------------------------+
void TestTrailingStops()
{
   ExpectDouble("TrailingPrice BUY",
      BossTrade.TrailingStopPrice(OP_BUY,1.10200,50,0.00001,5),1.10150);
   ExpectDouble("TrailingPrice SELL",
      BossTrade.TrailingStopPrice(OP_SELL,1.09800,50,0.00001,5),1.09850);
   ExpectDouble("TrailingPrice zero distance",
      BossTrade.TrailingStopPrice(OP_BUY,1.10200,0,0.00001,5),1.10200);
   ExpectDouble("TrailingPrice invalid type",
      BossTrade.TrailingStopPrice(OP_BUYSTOP,1.10200,50,0.00001,5),0.0);
   ExpectDouble("TrailingPrice negative distance",
      BossTrade.TrailingStopPrice(OP_BUY,1.10200,-1,0.00001,5),0.0);

   ExpectBool("TrailingTrigger BUY below false",
      BossTrade.HasReachedTrailingTrigger(OP_BUY,1.1000,1.1009,0.00001,100.0),false);
   ExpectBool("TrailingTrigger BUY exact true",
      BossTrade.HasReachedTrailingTrigger(OP_BUY,1.1000,1.1010,0.00001,100.0),true);
   ExpectBool("TrailingTrigger SELL above true",
      BossTrade.HasReachedTrailingTrigger(OP_SELL,1.1000,1.0989,0.00001,100.0),true);
   ExpectBool("TrailingTrigger negative false",
      BossTrade.HasReachedTrailingTrigger(OP_BUY,1.1000,1.1010,0.00001,-1.0),false);

   ExpectBool("ShouldTrail BUY true",
      BossTrade.ShouldTrailStop(OP_BUY,1.1000,1.1020,1.1000,100.0,50.0,0.00001,5),true);
   ExpectBool("ShouldTrail BUY not triggered",
      BossTrade.ShouldTrailStop(OP_BUY,1.1000,1.1009,1.0990,100.0,50.0,0.00001,5),false);
   ExpectBool("ShouldTrail BUY no improvement",
      BossTrade.ShouldTrailStop(OP_BUY,1.1000,1.1020,1.1017,100.0,50.0,0.00001,5),false);
   ExpectBool("ShouldTrail SELL true",
      BossTrade.ShouldTrailStop(OP_SELL,1.1000,1.0980,1.1000,100.0,50.0,0.00001,5),true);
   ExpectBool("ShouldTrail SELL no improvement",
      BossTrade.ShouldTrailStop(OP_SELL,1.1000,1.0980,1.0983,100.0,50.0,0.00001,5),false);
}

//+------------------------------------------------------------------+
//| Block 6 market preflight tests                                   |
//+------------------------------------------------------------------+
void TestMarketPreflight()
{
   ExpectBool("MarketPreflight BUY valid",
      BossTrade.IsMarketOrderPreflightValid(OP_BUY,0.10,0.01,100.0,0.01,260713,30,
                                            1.10020,1.10000,0.00001,20.0),true);

   ExpectBool("MarketPreflight SELL valid",
      BossTrade.IsMarketOrderPreflightValid(OP_SELL,0.10,0.01,100.0,0.01,260713,0,
                                            1.10020,1.10000,0.00001,20.0),true);

   ExpectBool("MarketPreflight pending false",
      BossTrade.IsMarketOrderPreflightValid(OP_BUYSTOP,0.10,0.01,100.0,0.01,260713,30,
                                            1.10020,1.10000,0.00001,20.0),false);

   ExpectBool("MarketPreflight bad lots false",
      BossTrade.IsMarketOrderPreflightValid(OP_BUY,0.125,0.01,100.0,0.01,260713,30,
                                            1.10020,1.10000,0.00001,20.0),false);

   ExpectBool("MarketPreflight bad magic false",
      BossTrade.IsMarketOrderPreflightValid(OP_BUY,0.10,0.01,100.0,0.01,-1,30,
                                            1.10020,1.10000,0.00001,20.0),false);

   ExpectBool("MarketPreflight crossed prices false",
      BossTrade.IsMarketOrderPreflightValid(OP_BUY,0.10,0.01,100.0,0.01,260713,30,
                                            1.09990,1.10000,0.00001,20.0),false);

   ExpectBool("MarketPreflight spread above false",
      BossTrade.IsMarketOrderPreflightValid(OP_BUY,0.10,0.01,100.0,0.01,260713,30,
                                            1.10021,1.10000,0.00001,20.0),false);

   ExpectBool("MarketPreflight negative max spread false",
      BossTrade.IsMarketOrderPreflightValid(OP_BUY,0.10,0.01,100.0,0.01,260713,30,
                                            1.10020,1.10000,0.00001,-1.0),false);
}

//+------------------------------------------------------------------+
//| Block 6 pending preflight tests                                  |
//+------------------------------------------------------------------+
void TestPendingPreflight()
{
   datetime now=D'2026.07.13 12:00:00';

   ExpectBool("PendingPreflight BUYLIMIT valid",
      BossTrade.IsPendingOrderPreflightValid(OP_BUYLIMIT,0.10,0.01,100.0,0.01,260713,30,
                                             1.09950,1.10020,1.10000,50,0.00001,
                                             D'2026.07.13 13:00:00',now),true);

   ExpectBool("PendingPreflight SELLSTOP valid no expiration",
      BossTrade.IsPendingOrderPreflightValid(OP_SELLSTOP,0.10,0.01,100.0,0.01,260713,0,
                                             1.09930,1.10020,1.10000,50,0.00001,
                                             0,now),true);

   ExpectBool("PendingPreflight market false",
      BossTrade.IsPendingOrderPreflightValid(OP_BUY,0.10,0.01,100.0,0.01,260713,30,
                                             1.09950,1.10020,1.10000,50,0.00001,
                                             D'2026.07.13 13:00:00',now),false);

   ExpectBool("PendingPreflight bad price false",
      BossTrade.IsPendingOrderPreflightValid(OP_BUYLIMIT,0.10,0.01,100.0,0.01,260713,30,
                                             1.09980,1.10020,1.10000,50,0.00001,
                                             D'2026.07.13 13:00:00',now),false);

   ExpectBool("PendingPreflight expired false",
      BossTrade.IsPendingOrderPreflightValid(OP_BUYLIMIT,0.10,0.01,100.0,0.01,260713,30,
                                             1.09950,1.10020,1.10000,50,0.00001,
                                             D'2026.07.13 11:00:00',now),false);

   ExpectBool("PendingPreflight bad lots false",
      BossTrade.IsPendingOrderPreflightValid(OP_BUYLIMIT,0.125,0.01,100.0,0.01,260713,30,
                                             1.09950,1.10020,1.10000,50,0.00001,
                                             D'2026.07.13 13:00:00',now),false);

   ExpectBool("PendingPreflight invalid current time false",
      BossTrade.IsPendingOrderPreflightValid(OP_BUYLIMIT,0.10,0.01,100.0,0.01,260713,30,
                                             1.09950,1.10020,1.10000,50,0.00001,
                                             0,0),false);
}

//+------------------------------------------------------------------+
//| Block 6 stop preflight tests                                     |
//+------------------------------------------------------------------+
void TestStopsPreflight()
{
   ExpectBool("StopsPreflight BUY both valid",
      BossTrade.IsMarketStopsPreflightValid(OP_BUY,1.10000,1.09900,1.10200,50,0.00001),true);

   ExpectBool("StopsPreflight SELL both valid",
      BossTrade.IsMarketStopsPreflightValid(OP_SELL,1.10000,1.10100,1.09800,50,0.00001),true);

   ExpectBool("StopsPreflight BUY no SL valid",
      BossTrade.IsMarketStopsPreflightValid(OP_BUY,1.10000,0.0,1.10200,50,0.00001),true);

   ExpectBool("StopsPreflight BUY no TP valid",
      BossTrade.IsMarketStopsPreflightValid(OP_BUY,1.10000,1.09900,0.0,50,0.00001),true);

   ExpectBool("StopsPreflight no stops valid",
      BossTrade.IsMarketStopsPreflightValid(OP_BUY,1.10000,0.0,0.0,50,0.00001),true);

   ExpectBool("StopsPreflight BUY bad SL false",
      BossTrade.IsMarketStopsPreflightValid(OP_BUY,1.10000,1.09960,1.10200,50,0.00001),false);

   ExpectBool("StopsPreflight BUY bad TP false",
      BossTrade.IsMarketStopsPreflightValid(OP_BUY,1.10000,1.09900,1.10040,50,0.00001),false);

   ExpectBool("StopsPreflight pending false",
      BossTrade.IsMarketStopsPreflightValid(OP_BUYSTOP,1.10000,1.09900,1.10200,50,0.00001),false);

   ExpectBool("StopsPreflight invalid point false",
      BossTrade.IsMarketStopsPreflightValid(OP_BUY,1.10000,1.09900,1.10200,50,0.0),false);
}

//+------------------------------------------------------------------+
//| Expert initialization                                            |
//+------------------------------------------------------------------+
int OnInit()
{
   Print("BossR_Trade Block 6 verification started");

   TestOrderTypes();
   TestPrecision();
   TestLots();
   TestDistances();
   TestStopsAndTargets();
   TestDirectionalMoves();
   TestRiskReward();
   TestRiskSizing();
   TestSpreadLimit();
   TestTradeIdentity();
   TestEntryGuards();
   TestMarketEntryPrice();
   TestPendingEntryPrices();
   TestRequestValidation();
   TestProfitAccounting();
   TestLifecycle();
   TestPointTargets();
   TestCloseValidation();
   TestModificationHelpers();
   TestBreakeven();
   TestTrailingStops();
   TestMarketPreflight();
   TestPendingPreflight();
   TestStopsPreflight();

   Print("BossR_Trade_Verify_Block6_FULL ",
         Symbol(),
         ",",
         Period(),
         ": PASS ",
         g_pass,
         " / FAIL ",
         g_fail);

   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert tick                                                      |
//+------------------------------------------------------------------+
void OnTick()
{
}
