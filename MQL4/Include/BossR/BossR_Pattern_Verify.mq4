//+------------------------------------------------------------------+
//| BossR_Pattern_Verify_Block6_FULL.mq4                             |
//| BossR Framework - Pattern Module Verification                    |
//| Block 6                                                          |
//| Compile this EA only                                              |
//+------------------------------------------------------------------+
#property strict

#include <BossR\BossR_Pattern_Block6_FULL.mqh>

C_BossR_Pattern BossPattern;

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
//| OHLC validation tests                                            |
//+------------------------------------------------------------------+
void TestValidOHLC()
{
   ExpectBool(
      "ValidOHLC normal bullish",
      BossPattern.IsValidOHLC(1.1000, 1.1050, 1.0950, 1.1030),
      true
   );

   ExpectBool(
      "ValidOHLC normal bearish",
      BossPattern.IsValidOHLC(1.1030, 1.1050, 1.0950, 1.1000),
      true
   );

   ExpectBool(
      "ValidOHLC flat candle",
      BossPattern.IsValidOHLC(1.1000, 1.1000, 1.1000, 1.1000),
      true
   );

   ExpectBool(
      "ValidOHLC high below low",
      BossPattern.IsValidOHLC(1.1000, 1.0900, 1.1100, 1.1000),
      false
   );

   ExpectBool(
      "ValidOHLC open above high",
      BossPattern.IsValidOHLC(1.1100, 1.1050, 1.0950, 1.1000),
      false
   );

   ExpectBool(
      "ValidOHLC open below low",
      BossPattern.IsValidOHLC(1.0900, 1.1050, 1.0950, 1.1000),
      false
   );

   ExpectBool(
      "ValidOHLC close above high",
      BossPattern.IsValidOHLC(1.1000, 1.1050, 1.0950, 1.1100),
      false
   );

   ExpectBool(
      "ValidOHLC close below low",
      BossPattern.IsValidOHLC(1.1000, 1.1050, 1.0950, 1.0900),
      false
   );

   ExpectBool(
      "ValidOHLC negative open",
      BossPattern.IsValidOHLC(-1.0, 1.0, 0.0, 0.5),
      false
   );

   ExpectBool(
      "ValidOHLC zero prices",
      BossPattern.IsValidOHLC(0.0, 0.0, 0.0, 0.0),
      true
   );
}

//+------------------------------------------------------------------+
//| Measurement tests                                                |
//+------------------------------------------------------------------+
void TestMeasurements()
{
   ExpectDouble(
      "Range normal",
      BossPattern.Range(1.1050, 1.0950),
      0.0100
   );

   ExpectDouble(
      "Range flat",
      BossPattern.Range(1.1000, 1.1000),
      0.0
   );

   ExpectDouble(
      "Range invalid",
      BossPattern.Range(1.0900, 1.1000),
      0.0
   );

   ExpectDouble(
      "Body bullish",
      BossPattern.Body(1.1000, 1.1040),
      0.0040
   );

   ExpectDouble(
      "Body bearish",
      BossPattern.Body(1.1040, 1.1000),
      0.0040
   );

   ExpectDouble(
      "Body doji",
      BossPattern.Body(1.1000, 1.1000),
      0.0
   );

   ExpectDouble(
      "UpperWick bullish",
      BossPattern.UpperWick(1.1000, 1.1060, 1.1040),
      0.0020
   );

   ExpectDouble(
      "UpperWick bearish",
      BossPattern.UpperWick(1.1040, 1.1060, 1.1000),
      0.0020
   );

   ExpectDouble(
      "UpperWick invalid high",
      BossPattern.UpperWick(1.1000, 1.0990, 1.1040),
      0.0
   );

   ExpectDouble(
      "LowerWick bullish",
      BossPattern.LowerWick(1.1000, 1.0960, 1.1040),
      0.0040
   );

   ExpectDouble(
      "LowerWick bearish",
      BossPattern.LowerWick(1.1040, 1.0960, 1.1000),
      0.0040
   );

   ExpectDouble(
      "LowerWick invalid low",
      BossPattern.LowerWick(1.1000, 1.1010, 1.1040),
      0.0
   );

   ExpectDouble(
      "BodyPercent fifty percent",
      BossPattern.BodyPercent(1.1000, 1.1060, 1.0960, 1.1050),
      0.50
   );

   ExpectDouble(
      "BodyPercent flat range",
      BossPattern.BodyPercent(1.1000, 1.1000, 1.1000, 1.1000),
      0.0
   );

   ExpectDouble(
      "UpperWickPercent twenty percent",
      BossPattern.UpperWickPercent(
         1.1000,
         1.1100,
         1.0900,
         1.1060
      ),
      0.20
   );

   ExpectDouble(
      "LowerWickPercent fifty percent",
      BossPattern.LowerWickPercent(
         1.1000,
         1.1100,
         1.0900,
         1.1060
      ),
      0.50
   );
}

//+------------------------------------------------------------------+
//| Direction tests                                                  |
//+------------------------------------------------------------------+
void TestDirection()
{
   ExpectBool(
      "Bullish true",
      BossPattern.IsBullish(1.1000, 1.1010),
      true
   );

   ExpectBool(
      "Bullish bearish false",
      BossPattern.IsBullish(1.1010, 1.1000),
      false
   );

   ExpectBool(
      "Bullish equal false",
      BossPattern.IsBullish(1.1000, 1.1000),
      false
   );

   ExpectBool(
      "Bearish true",
      BossPattern.IsBearish(1.1010, 1.1000),
      true
   );

   ExpectBool(
      "Bearish bullish false",
      BossPattern.IsBearish(1.1000, 1.1010),
      false
   );

   ExpectBool(
      "Bearish equal false",
      BossPattern.IsBearish(1.1000, 1.1000),
      false
   );
}

//+------------------------------------------------------------------+
//| Doji tests                                                       |
//+------------------------------------------------------------------+
void TestDoji()
{
   ExpectBool(
      "Doji exact",
      BossPattern.IsDoji(1.1000, 1.1100, 1.0900, 1.1000),
      true
   );

   ExpectBool(
      "Doji small body",
      BossPattern.IsDoji(1.1000, 1.1100, 1.0900, 1.1010),
      true
   );

   ExpectBool(
      "Doji boundary",
      BossPattern.IsDoji(
         1.1000,
         1.1100,
         1.0900,
         1.1020,
         0.10
      ),
      true
   );

   ExpectBool(
      "Doji body too large",
      BossPattern.IsDoji(
         1.1000,
         1.1100,
         1.0900,
         1.1030,
         0.10
      ),
      false
   );

   ExpectBool(
      "Doji flat candle",
      BossPattern.IsDoji(1.1000, 1.1000, 1.1000, 1.1000),
      true
   );

   ExpectBool(
      "Doji invalid OHLC",
      BossPattern.IsDoji(1.1000, 1.0900, 1.1100, 1.1000),
      false
   );

   ExpectBool(
      "Doji invalid threshold",
      BossPattern.IsDoji(
         1.1000,
         1.1100,
         1.0900,
         1.1000,
         -0.10
      ),
      false
   );
}

//+------------------------------------------------------------------+
//| Marubozu tests                                                   |
//+------------------------------------------------------------------+
void TestMarubozu()
{
   ExpectBool(
      "BullishMarubozu exact",
      BossPattern.IsBullishMarubozu(
         1.1000,
         1.1100,
         1.1000,
         1.1100
      ),
      true
   );

   ExpectBool(
      "BullishMarubozu small wicks",
      BossPattern.IsBullishMarubozu(
         1.1005,
         1.1100,
         1.1000,
         1.1095,
         0.05
      ),
      true
   );

   ExpectBool(
      "BullishMarubozu upper wick too large",
      BossPattern.IsBullishMarubozu(
         1.1000,
         1.1110,
         1.1000,
         1.1090,
         0.05
      ),
      false
   );

   ExpectBool(
      "BullishMarubozu bearish false",
      BossPattern.IsBullishMarubozu(
         1.1100,
         1.1100,
         1.1000,
         1.1000
      ),
      false
   );

   ExpectBool(
      "BearishMarubozu exact",
      BossPattern.IsBearishMarubozu(
         1.1100,
         1.1100,
         1.1000,
         1.1000
      ),
      true
   );

   ExpectBool(
      "BearishMarubozu small wicks",
      BossPattern.IsBearishMarubozu(
         1.1095,
         1.1100,
         1.1000,
         1.1005,
         0.05
      ),
      true
   );

   ExpectBool(
      "BearishMarubozu lower wick too large",
      BossPattern.IsBearishMarubozu(
         1.1090,
         1.1100,
         1.0990,
         1.1010,
         0.05
      ),
      false
   );

   ExpectBool(
      "BearishMarubozu bullish false",
      BossPattern.IsBearishMarubozu(
         1.1000,
         1.1100,
         1.1000,
         1.1100
      ),
      false
   );

   ExpectBool(
      "Marubozu invalid threshold",
      BossPattern.IsBullishMarubozu(
         1.1000,
         1.1100,
         1.1000,
         1.1100,
         -0.01
      ),
      false
   );
}

//+------------------------------------------------------------------+
//| Hammer tests                                                     |
//+------------------------------------------------------------------+
void TestHammer()
{
   ExpectBool(
      "Hammer bullish body",
      BossPattern.IsHammer(
         1.1000,
         1.1030,
         1.0900,
         1.1020
      ),
      true
   );

   ExpectBool(
      "Hammer bearish body",
      BossPattern.IsHammer(
         1.1020,
         1.1030,
         1.0900,
         1.1000
      ),
      true
   );

   ExpectBool(
      "Hammer lower wick too short",
      BossPattern.IsHammer(
         1.1000,
         1.1030,
         1.0970,
         1.1020
      ),
      false
   );

   ExpectBool(
      "Hammer upper wick too long",
      BossPattern.IsHammer(
         1.1000,
         1.1060,
         1.0900,
         1.1020
      ),
      false
   );

   ExpectBool(
      "Hammer body too large",
      BossPattern.IsHammer(
         1.0950,
         1.1050,
         1.0800,
         1.1050
      ),
      false
   );

   ExpectBool(
      "Hammer doji rejected",
      BossPattern.IsHammer(
         1.1000,
         1.1010,
         1.0900,
         1.1000
      ),
      false
   );

   ExpectBool(
      "Hammer invalid OHLC",
      BossPattern.IsHammer(
         1.1000,
         1.0900,
         1.1100,
         1.1000
      ),
      false
   );

   ExpectBool(
      "Hammer invalid ratio",
      BossPattern.IsHammer(
         1.1000,
         1.1030,
         1.0900,
         1.1020,
         -1.0
      ),
      false
   );
}

//+------------------------------------------------------------------+
//| Shooting star tests                                              |
//+------------------------------------------------------------------+
void TestShootingStar()
{
   ExpectBool(
      "ShootingStar bullish body",
      BossPattern.IsShootingStar(
         1.1000,
         1.1120,
         1.0990,
         1.1020
      ),
      true
   );

   ExpectBool(
      "ShootingStar bearish body",
      BossPattern.IsShootingStar(
         1.1020,
         1.1120,
         1.0990,
         1.1000
      ),
      true
   );

   ExpectBool(
      "ShootingStar upper wick too short",
      BossPattern.IsShootingStar(
         1.1000,
         1.1050,
         1.0990,
         1.1020
      ),
      false
   );

   ExpectBool(
      "ShootingStar lower wick too long",
      BossPattern.IsShootingStar(
         1.1000,
         1.1120,
         1.0960,
         1.1020
      ),
      false
   );

   ExpectBool(
      "ShootingStar body too large",
      BossPattern.IsShootingStar(
         1.0900,
         1.1150,
         1.0900,
         1.1000
      ),
      false
   );

   ExpectBool(
      "ShootingStar doji rejected",
      BossPattern.IsShootingStar(
         1.1000,
         1.1120,
         1.0990,
         1.1000
      ),
      false
   );

   ExpectBool(
      "ShootingStar invalid ratio",
      BossPattern.IsShootingStar(
         1.1000,
         1.1120,
         1.0990,
         1.1020,
         -1.0
      ),
      false
   );
}

//+------------------------------------------------------------------+
//| Spinning top tests                                               |
//+------------------------------------------------------------------+
void TestSpinningTop()
{
   ExpectBool(
      "SpinningTop bullish",
      BossPattern.IsSpinningTop(
         1.1000,
         1.1100,
         1.0900,
         1.1040
      ),
      true
   );

   ExpectBool(
      "SpinningTop bearish",
      BossPattern.IsSpinningTop(
         1.1040,
         1.1100,
         1.0900,
         1.1000
      ),
      true
   );

   ExpectBool(
      "SpinningTop exact doji",
      BossPattern.IsSpinningTop(
         1.1000,
         1.1100,
         1.0900,
         1.1000
      ),
      true
   );

   ExpectBool(
      "SpinningTop body too large",
      BossPattern.IsSpinningTop(
         1.0950,
         1.1100,
         1.0900,
         1.1050
      ),
      false
   );

   ExpectBool(
      "SpinningTop upper wick too short",
      BossPattern.IsSpinningTop(
         1.1000,
         1.1050,
         1.0900,
         1.1040
      ),
      false
   );

   ExpectBool(
      "SpinningTop lower wick too short",
      BossPattern.IsSpinningTop(
         1.0960,
         1.1100,
         1.0950,
         1.1000
      ),
      false
   );

   ExpectBool(
      "SpinningTop flat rejected",
      BossPattern.IsSpinningTop(
         1.1000,
         1.1000,
         1.1000,
         1.1000
      ),
      false
   );

   ExpectBool(
      "SpinningTop invalid threshold",
      BossPattern.IsSpinningTop(
         1.1000,
         1.1100,
         1.0900,
         1.1040,
         -0.35
      ),
      false
   );
}



//+------------------------------------------------------------------+
//| Pair validation tests                                            |
//+------------------------------------------------------------------+
void TestPairValidation()
{
   ExpectBool("Pair valid",
      BossPattern.IsValidPairOHLC(1.1050,1.1060,1.0990,1.1000,
                                  1.0990,1.1070,1.0980,1.1060), true);
   ExpectBool("Pair invalid previous",
      BossPattern.IsValidPairOHLC(1.1050,1.0990,1.1060,1.1000,
                                  1.0990,1.1070,1.0980,1.1060), false);
   ExpectBool("Pair invalid current",
      BossPattern.IsValidPairOHLC(1.1050,1.1060,1.0990,1.1000,
                                  1.0990,1.0970,1.1080,1.1060), false);
}

//+------------------------------------------------------------------+
//| Inside and outside bar tests                                     |
//+------------------------------------------------------------------+
void TestBarContainment()
{
   ExpectBool("InsideBar strict both", BossPattern.IsInsideBar(
      1.1000,1.1100,1.0900,1.1050, 1.1010,1.1080,1.0920,1.1040), true);
   ExpectBool("InsideBar equal high", BossPattern.IsInsideBar(
      1.1000,1.1100,1.0900,1.1050, 1.1010,1.1100,1.0920,1.1040), true);
   ExpectBool("InsideBar identical rejected", BossPattern.IsInsideBar(
      1.1000,1.1100,1.0900,1.1050, 1.1000,1.1100,1.0900,1.1050), false);
   ExpectBool("InsideBar high outside", BossPattern.IsInsideBar(
      1.1000,1.1100,1.0900,1.1050, 1.1010,1.1110,1.0920,1.1040), false);
   ExpectBool("InsideBar invalid pair", BossPattern.IsInsideBar(
      1.1000,1.0900,1.1100,1.1050, 1.1010,1.1080,1.0920,1.1040), false);

   ExpectBool("OutsideBar strict both", BossPattern.IsOutsideBar(
      1.1010,1.1080,1.0920,1.1040, 1.1000,1.1100,1.0900,1.1050), true);
   ExpectBool("OutsideBar equal low", BossPattern.IsOutsideBar(
      1.1010,1.1080,1.0920,1.1040, 1.1000,1.1100,1.0920,1.1050), true);
   ExpectBool("OutsideBar identical rejected", BossPattern.IsOutsideBar(
      1.1000,1.1100,1.0900,1.1050, 1.1000,1.1100,1.0900,1.1050), false);
   ExpectBool("OutsideBar low inside", BossPattern.IsOutsideBar(
      1.1000,1.1100,1.0900,1.1050, 1.1010,1.1110,1.0920,1.1040), false);
}

//+------------------------------------------------------------------+
//| Engulfing tests                                                  |
//+------------------------------------------------------------------+
void TestEngulfing()
{
   ExpectBool("BullishEngulfing exact boundary", BossPattern.IsBullishEngulfing(
      1.1050,1.1060,1.0990,1.1000, 1.1000,1.1070,1.0990,1.1050), true);
   ExpectBool("BullishEngulfing larger", BossPattern.IsBullishEngulfing(
      1.1050,1.1060,1.0990,1.1000, 1.0990,1.1080,1.0980,1.1070), true);
   ExpectBool("BullishEngulfing body too small", BossPattern.IsBullishEngulfing(
      1.1050,1.1060,1.0990,1.1000, 1.1010,1.1060,1.1000,1.1040), false);
   ExpectBool("BullishEngulfing wrong previous direction", BossPattern.IsBullishEngulfing(
      1.1000,1.1060,1.0990,1.1050, 1.0990,1.1080,1.0980,1.1070), false);
   ExpectBool("BullishEngulfing ratio filter", BossPattern.IsBullishEngulfing(
      1.1050,1.1060,1.0990,1.1000, 1.0990,1.1080,1.0980,1.1070,1.70), false);
   ExpectBool("BullishEngulfing invalid ratio", BossPattern.IsBullishEngulfing(
      1.1050,1.1060,1.0990,1.1000, 1.0990,1.1080,1.0980,1.1070,-1.0), false);

   ExpectBool("BearishEngulfing exact boundary", BossPattern.IsBearishEngulfing(
      1.1000,1.1060,1.0990,1.1050, 1.1050,1.1060,1.0980,1.1000), true);
   ExpectBool("BearishEngulfing larger", BossPattern.IsBearishEngulfing(
      1.1000,1.1060,1.0990,1.1050, 1.1070,1.1080,1.0980,1.0990), true);
   ExpectBool("BearishEngulfing body too small", BossPattern.IsBearishEngulfing(
      1.1000,1.1060,1.0990,1.1050, 1.1040,1.1060,1.1000,1.1010), false);
   ExpectBool("BearishEngulfing wrong previous direction", BossPattern.IsBearishEngulfing(
      1.1050,1.1060,1.0990,1.1000, 1.1070,1.1080,1.0980,1.0990), false);
}

//+------------------------------------------------------------------+
//| Harami tests                                                     |
//+------------------------------------------------------------------+
void TestHarami()
{
   ExpectBool("BullishHarami contained", BossPattern.IsBullishHarami(
      1.1100,1.1110,1.0990,1.1000, 1.1020,1.1080,1.1010,1.1070), true);
   ExpectBool("BullishHarami boundary", BossPattern.IsBullishHarami(
      1.1100,1.1110,1.0990,1.1000, 1.1000,1.1110,1.0990,1.1100), true);
   ExpectBool("BullishHarami escapes body", BossPattern.IsBullishHarami(
      1.1100,1.1110,1.0990,1.1000, 1.0990,1.1080,1.0980,1.1070), false);
   ExpectBool("BullishHarami ratio filter", BossPattern.IsBullishHarami(
      1.1100,1.1110,1.0990,1.1000, 1.1020,1.1080,1.1010,1.1070,0.40), false);
   ExpectBool("BullishHarami invalid ratio", BossPattern.IsBullishHarami(
      1.1100,1.1110,1.0990,1.1000, 1.1020,1.1080,1.1010,1.1070,-1.0), false);

   ExpectBool("BearishHarami contained", BossPattern.IsBearishHarami(
      1.1000,1.1110,1.0990,1.1100, 1.1080,1.1090,1.1020,1.1030), true);
   ExpectBool("BearishHarami boundary", BossPattern.IsBearishHarami(
      1.1000,1.1110,1.0990,1.1100, 1.1100,1.1110,1.0990,1.1000), true);
   ExpectBool("BearishHarami escapes body", BossPattern.IsBearishHarami(
      1.1000,1.1110,1.0990,1.1100, 1.1110,1.1120,1.1020,1.1030), false);
   ExpectBool("BearishHarami wrong direction", BossPattern.IsBearishHarami(
      1.1100,1.1110,1.0990,1.1000, 1.1080,1.1090,1.1020,1.1030), false);
}

//+------------------------------------------------------------------+
//| Piercing and dark-cloud tests                                    |
//+------------------------------------------------------------------+
void TestPenetrationPatterns()
{
   ExpectBool("PiercingLine boundary", BossPattern.IsPiercingLine(
      1.1100,1.1110,1.0990,1.1000, 1.0990,1.1080,1.0980,1.1050), true);
   ExpectBool("PiercingLine above midpoint", BossPattern.IsPiercingLine(
      1.1100,1.1110,1.0990,1.1000, 1.0990,1.1090,1.0980,1.1070), true);
   ExpectBool("PiercingLine below midpoint", BossPattern.IsPiercingLine(
      1.1100,1.1110,1.0990,1.1000, 1.0990,1.1040,1.0980,1.1040), false);
   ExpectBool("PiercingLine full engulf rejected", BossPattern.IsPiercingLine(
      1.1100,1.1110,1.0990,1.1000, 1.0990,1.1120,1.0980,1.1110), false);
   ExpectBool("PiercingLine invalid penetration", BossPattern.IsPiercingLine(
      1.1100,1.1110,1.0990,1.1000, 1.0990,1.1080,1.0980,1.1050,1.10), false);

   ExpectBool("DarkCloud boundary", BossPattern.IsDarkCloudCover(
      1.1000,1.1110,1.0990,1.1100, 1.1110,1.1120,1.1020,1.1050), true);
   ExpectBool("DarkCloud below midpoint", BossPattern.IsDarkCloudCover(
      1.1000,1.1110,1.0990,1.1100, 1.1110,1.1120,1.1020,1.1030), true);
   ExpectBool("DarkCloud above midpoint", BossPattern.IsDarkCloudCover(
      1.1000,1.1110,1.0990,1.1100, 1.1110,1.1120,1.1060,1.1060), false);
   ExpectBool("DarkCloud full engulf rejected", BossPattern.IsDarkCloudCover(
      1.1000,1.1110,1.0990,1.1100, 1.1110,1.1120,1.0980,1.0990), false);
}

//+------------------------------------------------------------------+
//| Tweezer tests                                                    |
//+------------------------------------------------------------------+
void TestTweezers()
{
   ExpectBool("TweezerBottom exact", BossPattern.IsTweezerBottom(
      1.1060,1.1070,1.0990,1.1010, 1.1010,1.1080,1.0990,1.1060), true);
   ExpectBool("TweezerBottom tolerance", BossPattern.IsTweezerBottom(
      1.1060,1.1070,1.0990,1.1010, 1.1010,1.1080,1.0994,1.1060,0.0005), true);
   ExpectBool("TweezerBottom beyond tolerance", BossPattern.IsTweezerBottom(
      1.1060,1.1070,1.0990,1.1010, 1.1010,1.1080,1.0996,1.1060,0.0005), false);
   ExpectBool("TweezerBottom wrong directions", BossPattern.IsTweezerBottom(
      1.1010,1.1070,1.0990,1.1060, 1.1010,1.1080,1.0990,1.1060), false);
   ExpectBool("TweezerBottom invalid tolerance", BossPattern.IsTweezerBottom(
      1.1060,1.1070,1.0990,1.1010, 1.1010,1.1080,1.0990,1.1060,-0.0001), false);

   ExpectBool("TweezerTop exact", BossPattern.IsTweezerTop(
      1.1000,1.1080,1.0990,1.1060, 1.1060,1.1080,1.1000,1.1010), true);
   ExpectBool("TweezerTop tolerance", BossPattern.IsTweezerTop(
      1.1000,1.1080,1.0990,1.1060, 1.1060,1.1084,1.1000,1.1010,0.0005), true);
   ExpectBool("TweezerTop beyond tolerance", BossPattern.IsTweezerTop(
      1.1000,1.1080,1.0990,1.1060, 1.1060,1.1086,1.1000,1.1010,0.0005), false);
   ExpectBool("TweezerTop wrong directions", BossPattern.IsTweezerTop(
      1.1060,1.1080,1.0990,1.1000, 1.1060,1.1080,1.1000,1.1010), false);
}



//+------------------------------------------------------------------+
//| Triple validation tests                                          |
//+------------------------------------------------------------------+
void TestTripleValidation()
{
   ExpectBool("ValidTriple normal", BossPattern.IsValidTripleOHLC(
      1.1100,1.1110,1.0990,1.1000,
      1.0990,1.1020,1.0980,1.1010,
      1.1010,1.1090,1.1000,1.1080), true);

   ExpectBool("ValidTriple invalid first", BossPattern.IsValidTripleOHLC(
      1.1100,1.0990,1.1110,1.1000,
      1.0990,1.1020,1.0980,1.1010,
      1.1010,1.1090,1.1000,1.1080), false);

   ExpectBool("ValidTriple invalid second", BossPattern.IsValidTripleOHLC(
      1.1100,1.1110,1.0990,1.1000,
      1.0990,1.0980,1.1020,1.1010,
      1.1010,1.1090,1.1000,1.1080), false);

   ExpectBool("ValidTriple invalid third", BossPattern.IsValidTripleOHLC(
      1.1100,1.1110,1.0990,1.1000,
      1.0990,1.1020,1.0980,1.1010,
      1.1010,1.1000,1.1090,1.1080), false);
}

//+------------------------------------------------------------------+
//| Morning and evening star tests                                   |
//+------------------------------------------------------------------+
void TestStarPatterns()
{
   ExpectBool("MorningStar valid", BossPattern.IsMorningStar(
      1.1100,1.1110,1.0990,1.1000,
      1.0980,1.1000,1.0960,1.0990,
      1.0990,1.1080,1.0980,1.1060), true);
   ExpectBool("MorningStar boundary recovery", BossPattern.IsMorningStar(
      1.1100,1.1110,1.0990,1.1000,
      1.0980,1.1000,1.0960,1.0990,
      1.0990,1.1060,1.0980,1.1050), true);
   ExpectBool("MorningStar star too large", BossPattern.IsMorningStar(
      1.1100,1.1110,1.0990,1.1000,
      1.0960,1.1020,1.0950,1.1015,
      1.1000,1.1080,1.0990,1.1060), false);
   ExpectBool("MorningStar insufficient recovery", BossPattern.IsMorningStar(
      1.1100,1.1110,1.0990,1.1000,
      1.0980,1.1000,1.0960,1.0990,
      1.0990,1.1040,1.0980,1.1040), false);
   ExpectBool("MorningStar no separation", BossPattern.IsMorningStar(
      1.1100,1.1110,1.0990,1.1000,
      1.0990,1.1020,1.0980,1.1010,
      1.1010,1.1080,1.1000,1.1060), false);
   ExpectBool("MorningStar invalid ratio", BossPattern.IsMorningStar(
      1.1100,1.1110,1.0990,1.1000,
      1.0980,1.1000,1.0960,1.0990,
      1.0990,1.1080,1.0980,1.1060,-0.1), false);

   ExpectBool("EveningStar valid", BossPattern.IsEveningStar(
      1.1000,1.1110,1.0990,1.1100,
      1.1110,1.1140,1.1100,1.1120,
      1.1110,1.1120,1.1020,1.1040), true);
   ExpectBool("EveningStar boundary recovery", BossPattern.IsEveningStar(
      1.1000,1.1110,1.0990,1.1100,
      1.1110,1.1140,1.1100,1.1120,
      1.1110,1.1120,1.1050,1.1050), true);
   ExpectBool("EveningStar star too large", BossPattern.IsEveningStar(
      1.1000,1.1110,1.0990,1.1100,
      1.1080,1.1150,1.1070,1.1135,
      1.1120,1.1130,1.1020,1.1040), false);
   ExpectBool("EveningStar insufficient recovery", BossPattern.IsEveningStar(
      1.1000,1.1110,1.0990,1.1100,
      1.1110,1.1140,1.1100,1.1120,
      1.1110,1.1120,1.1060,1.1060), false);
   ExpectBool("EveningStar no separation", BossPattern.IsEveningStar(
      1.1000,1.1110,1.0990,1.1100,
      1.1090,1.1120,1.1080,1.1110,
      1.1100,1.1110,1.1020,1.1040), false);
   ExpectBool("EveningStar invalid recovery", BossPattern.IsEveningStar(
      1.1000,1.1110,1.0990,1.1100,
      1.1110,1.1140,1.1100,1.1120,
      1.1110,1.1120,1.1020,1.1040,0.5,1.1), false);
}

//+------------------------------------------------------------------+
//| Three soldiers and crows tests                                  |
//+------------------------------------------------------------------+
void TestThreeTrendCandles()
{
   ExpectBool("ThreeWhiteSoldiers valid", BossPattern.IsThreeWhiteSoldiers(
      1.1000,1.1060,1.0990,1.1050,
      1.1030,1.1090,1.1020,1.1080,
      1.1060,1.1120,1.1050,1.1110), true);
   ExpectBool("ThreeWhiteSoldiers non rising close", BossPattern.IsThreeWhiteSoldiers(
      1.1000,1.1060,1.0990,1.1050,
      1.1030,1.1060,1.1020,1.1040,
      1.1030,1.1100,1.1020,1.1090), false);
   ExpectBool("ThreeWhiteSoldiers open outside body", BossPattern.IsThreeWhiteSoldiers(
      1.1000,1.1060,1.0990,1.1050,
      1.1060,1.1100,1.1050,1.1090,
      1.1080,1.1130,1.1070,1.1120), false);
   ExpectBool("ThreeWhiteSoldiers long upper wick", BossPattern.IsThreeWhiteSoldiers(
      1.1000,1.1100,1.0990,1.1050,
      1.1030,1.1090,1.1020,1.1080,
      1.1060,1.1120,1.1050,1.1110), false);
   ExpectBool("ThreeWhiteSoldiers invalid threshold", BossPattern.IsThreeWhiteSoldiers(
      1.1000,1.1060,1.0990,1.1050,
      1.1030,1.1090,1.1020,1.1080,
      1.1060,1.1120,1.1050,1.1110,-0.1), false);

   ExpectBool("ThreeBlackCrows valid", BossPattern.IsThreeBlackCrows(
      1.1100,1.1110,1.1040,1.1050,
      1.1070,1.1080,1.1010,1.1020,
      1.1040,1.1050,1.0980,1.0990), true);
   ExpectBool("ThreeBlackCrows non falling close", BossPattern.IsThreeBlackCrows(
      1.1100,1.1110,1.1040,1.1050,
      1.1070,1.1080,1.1030,1.1060,
      1.1050,1.1060,1.0980,1.0990), false);
   ExpectBool("ThreeBlackCrows open outside body", BossPattern.IsThreeBlackCrows(
      1.1100,1.1110,1.1040,1.1050,
      1.1040,1.1050,1.0990,1.1000,
      1.1020,1.1030,1.0960,1.0970), false);
   ExpectBool("ThreeBlackCrows long lower wick", BossPattern.IsThreeBlackCrows(
      1.1100,1.1110,1.1000,1.1050,
      1.1070,1.1080,1.1010,1.1020,
      1.1040,1.1050,1.0980,1.0990), false);
   ExpectBool("ThreeBlackCrows wrong direction", BossPattern.IsThreeBlackCrows(
      1.1050,1.1110,1.1040,1.1100,
      1.1070,1.1080,1.1010,1.1020,
      1.1040,1.1050,1.0980,1.0990), false);
}

//+------------------------------------------------------------------+
//| Three inside tests                                               |
//+------------------------------------------------------------------+
void TestThreeInside()
{
   ExpectBool("ThreeInsideUp valid", BossPattern.IsThreeInsideUp(
      1.1100,1.1110,1.0990,1.1000,
      1.1020,1.1080,1.1010,1.1070,
      1.1060,1.1130,1.1050,1.1120), true);
   ExpectBool("ThreeInsideUp no breakout", BossPattern.IsThreeInsideUp(
      1.1100,1.1110,1.0990,1.1000,
      1.1020,1.1080,1.1010,1.1070,
      1.1060,1.1100,1.1050,1.1090), false);
   ExpectBool("ThreeInsideUp invalid harami", BossPattern.IsThreeInsideUp(
      1.1100,1.1110,1.0990,1.1000,
      1.0990,1.1080,1.0980,1.1070,
      1.1060,1.1130,1.1050,1.1120), false);
   ExpectBool("ThreeInsideUp invalid ratio", BossPattern.IsThreeInsideUp(
      1.1100,1.1110,1.0990,1.1000,
      1.1020,1.1080,1.1010,1.1070,
      1.1060,1.1130,1.1050,1.1120,-1.0), false);

   ExpectBool("ThreeInsideDown valid", BossPattern.IsThreeInsideDown(
      1.1000,1.1110,1.0990,1.1100,
      1.1080,1.1090,1.1020,1.1030,
      1.1040,1.1050,1.0970,1.0980), true);
   ExpectBool("ThreeInsideDown no breakout", BossPattern.IsThreeInsideDown(
      1.1000,1.1110,1.0990,1.1100,
      1.1080,1.1090,1.1020,1.1030,
      1.1040,1.1050,1.1000,1.1010), false);
   ExpectBool("ThreeInsideDown invalid harami", BossPattern.IsThreeInsideDown(
      1.1000,1.1110,1.0990,1.1100,
      1.1110,1.1120,1.1020,1.1030,
      1.1040,1.1050,1.0970,1.0980), false);
   ExpectBool("ThreeInsideDown wrong third direction", BossPattern.IsThreeInsideDown(
      1.1000,1.1110,1.0990,1.1100,
      1.1080,1.1090,1.1020,1.1030,
      1.0980,1.1050,1.0970,1.1040), false);
}

//+------------------------------------------------------------------+
//| Three outside tests                                              |
//+------------------------------------------------------------------+
void TestThreeOutside()
{
   ExpectBool("ThreeOutsideUp valid", BossPattern.IsThreeOutsideUp(
      1.1050,1.1060,1.0990,1.1000,
      1.0990,1.1080,1.0980,1.1070,
      1.1060,1.1110,1.1050,1.1100), true);
   ExpectBool("ThreeOutsideUp no continuation", BossPattern.IsThreeOutsideUp(
      1.1050,1.1060,1.0990,1.1000,
      1.0990,1.1080,1.0980,1.1070,
      1.1060,1.1070,1.1030,1.1040), false);
   ExpectBool("ThreeOutsideUp invalid engulf", BossPattern.IsThreeOutsideUp(
      1.1050,1.1060,1.0990,1.1000,
      1.1010,1.1060,1.1000,1.1040,
      1.1030,1.1110,1.1020,1.1100), false);
   ExpectBool("ThreeOutsideUp invalid ratio", BossPattern.IsThreeOutsideUp(
      1.1050,1.1060,1.0990,1.1000,
      1.0990,1.1080,1.0980,1.1070,
      1.1060,1.1110,1.1050,1.1100,-1.0), false);

   ExpectBool("ThreeOutsideDown valid", BossPattern.IsThreeOutsideDown(
      1.1000,1.1060,1.0990,1.1050,
      1.1070,1.1080,1.0980,1.0990,
      1.1000,1.1010,1.0950,1.0960), true);
   ExpectBool("ThreeOutsideDown no continuation", BossPattern.IsThreeOutsideDown(
      1.1000,1.1060,1.0990,1.1050,
      1.1070,1.1080,1.0980,1.0990,
      1.0980,1.1030,1.0970,1.1020), false);
   ExpectBool("ThreeOutsideDown invalid engulf", BossPattern.IsThreeOutsideDown(
      1.1000,1.1060,1.0990,1.1050,
      1.1040,1.1060,1.1000,1.1010,
      1.1020,1.1030,1.0950,1.0960), false);
   ExpectBool("ThreeOutsideDown wrong third direction", BossPattern.IsThreeOutsideDown(
      1.1000,1.1060,1.0990,1.1050,
      1.1070,1.1080,1.0980,1.0990,
      1.0960,1.1030,1.0950,1.1020), false);
}


//+------------------------------------------------------------------+
//| Block 4 sequence tests                                           |
//+------------------------------------------------------------------+
void TestThreeValueSequences()
{
   ExpectBool("RisingCloses3 valid",
      BossPattern.IsRisingCloses3(1.1000,1.1010,1.1020), true);
   ExpectBool("RisingCloses3 equal second false",
      BossPattern.IsRisingCloses3(1.1000,1.1000,1.1020), false);
   ExpectBool("RisingCloses3 falling third false",
      BossPattern.IsRisingCloses3(1.1000,1.1020,1.1010), false);
   ExpectBool("RisingCloses3 negative false",
      BossPattern.IsRisingCloses3(-1.0,1.1010,1.1020), false);

   ExpectBool("FallingCloses3 valid",
      BossPattern.IsFallingCloses3(1.1020,1.1010,1.1000), true);
   ExpectBool("FallingCloses3 equal second false",
      BossPattern.IsFallingCloses3(1.1020,1.1020,1.1000), false);
   ExpectBool("FallingCloses3 rising third false",
      BossPattern.IsFallingCloses3(1.1020,1.1000,1.1010), false);
   ExpectBool("FallingCloses3 negative false",
      BossPattern.IsFallingCloses3(1.1020,1.1010,-1.0), false);

   ExpectBool("RisingHighs3 valid",
      BossPattern.IsRisingHighs3(1.1050,1.1060,1.1070), true);
   ExpectBool("RisingHighs3 equal false",
      BossPattern.IsRisingHighs3(1.1050,1.1050,1.1070), false);
   ExpectBool("RisingHighs3 reversal false",
      BossPattern.IsRisingHighs3(1.1050,1.1070,1.1060), false);
   ExpectBool("RisingHighs3 negative false",
      BossPattern.IsRisingHighs3(-1.0,1.1060,1.1070), false);

   ExpectBool("FallingLows3 valid",
      BossPattern.IsFallingLows3(1.0950,1.0940,1.0930), true);
   ExpectBool("FallingLows3 equal false",
      BossPattern.IsFallingLows3(1.0950,1.0950,1.0930), false);
   ExpectBool("FallingLows3 reversal false",
      BossPattern.IsFallingLows3(1.0950,1.0930,1.0940), false);
   ExpectBool("FallingLows3 negative false",
      BossPattern.IsFallingLows3(1.0950,-1.0,1.0930), false);
}

//+------------------------------------------------------------------+
//| Block 4 three line strike tests                                  |
//+------------------------------------------------------------------+
void TestThreeLineStrike()
{
   ExpectBool("BullishThreeLineStrike valid",
      BossPattern.IsBullishThreeLineStrike(
         1.1000,1.1030,1.0990,1.1020,
         1.1010,1.1050,1.1000,1.1040,
         1.1030,1.1070,1.1020,1.1060,
         1.1060,1.1070,1.0980,1.0990), true);

   ExpectBool("BullishThreeLineStrike equal boundary valid",
      BossPattern.IsBullishThreeLineStrike(
         1.1000,1.1030,1.0990,1.1020,
         1.1010,1.1050,1.1000,1.1040,
         1.1030,1.1070,1.1020,1.1060,
         1.1060,1.1070,1.0990,1.1000), true);

   ExpectBool("BullishThreeLineStrike fourth wrong direction",
      BossPattern.IsBullishThreeLineStrike(
         1.1000,1.1030,1.0990,1.1020,
         1.1010,1.1050,1.1000,1.1040,
         1.1030,1.1070,1.1020,1.1060,
         1.1050,1.1080,1.1040,1.1070), false);

   ExpectBool("BullishThreeLineStrike closes not rising",
      BossPattern.IsBullishThreeLineStrike(
         1.1000,1.1040,1.0990,1.1030,
         1.1020,1.1050,1.1010,1.1040,
         1.1020,1.1040,1.1010,1.1030,
         1.1030,1.1040,1.0980,1.0990), false);

   ExpectBool("BullishThreeLineStrike open below third close",
      BossPattern.IsBullishThreeLineStrike(
         1.1000,1.1030,1.0990,1.1020,
         1.1010,1.1050,1.1000,1.1040,
         1.1030,1.1070,1.1020,1.1060,
         1.1050,1.1060,1.0980,1.0990), false);

   ExpectBool("BullishThreeLineStrike close above first open",
      BossPattern.IsBullishThreeLineStrike(
         1.1000,1.1030,1.0990,1.1020,
         1.1010,1.1050,1.1000,1.1040,
         1.1030,1.1070,1.1020,1.1060,
         1.1060,1.1070,1.0990,1.1010), false);

   ExpectBool("BullishThreeLineStrike invalid fourth OHLC",
      BossPattern.IsBullishThreeLineStrike(
         1.1000,1.1030,1.0990,1.1020,
         1.1010,1.1050,1.1000,1.1040,
         1.1030,1.1070,1.1020,1.1060,
         1.1060,1.1000,1.0980,1.0990), false);

   ExpectBool("BearishThreeLineStrike valid",
      BossPattern.IsBearishThreeLineStrike(
         1.1060,1.1070,1.1030,1.1040,
         1.1050,1.1060,1.1010,1.1020,
         1.1030,1.1040,1.0990,1.1000,
         1.1000,1.1080,1.0990,1.1070), true);

   ExpectBool("BearishThreeLineStrike equal boundary valid",
      BossPattern.IsBearishThreeLineStrike(
         1.1060,1.1070,1.1030,1.1040,
         1.1050,1.1060,1.1010,1.1020,
         1.1030,1.1040,1.0990,1.1000,
         1.1000,1.1060,1.0990,1.1060), true);

   ExpectBool("BearishThreeLineStrike fourth wrong direction",
      BossPattern.IsBearishThreeLineStrike(
         1.1060,1.1070,1.1030,1.1040,
         1.1050,1.1060,1.1010,1.1020,
         1.1030,1.1040,1.0990,1.1000,
         1.1010,1.1020,1.0980,1.0990), false);

   ExpectBool("BearishThreeLineStrike closes not falling",
      BossPattern.IsBearishThreeLineStrike(
         1.1060,1.1070,1.1030,1.1040,
         1.1050,1.1060,1.1010,1.1020,
         1.1030,1.1050,1.1020,1.1040,
         1.1040,1.1080,1.1030,1.1070), false);

   ExpectBool("BearishThreeLineStrike open above third close",
      BossPattern.IsBearishThreeLineStrike(
         1.1060,1.1070,1.1030,1.1040,
         1.1050,1.1060,1.1010,1.1020,
         1.1030,1.1040,1.0990,1.1000,
         1.1010,1.1080,1.1000,1.1070), false);

   ExpectBool("BearishThreeLineStrike close below first open",
      BossPattern.IsBearishThreeLineStrike(
         1.1060,1.1070,1.1030,1.1040,
         1.1050,1.1060,1.1010,1.1020,
         1.1030,1.1040,1.0990,1.1000,
         1.1000,1.1060,1.0990,1.1050), false);

   ExpectBool("BearishThreeLineStrike invalid first OHLC",
      BossPattern.IsBearishThreeLineStrike(
         1.1060,1.1000,1.1030,1.1040,
         1.1050,1.1060,1.1010,1.1020,
         1.1030,1.1040,1.0990,1.1000,
         1.1000,1.1080,1.0990,1.1070), false);
}


//+------------------------------------------------------------------+
//| Block 5 gap and window tests                                     |
//+------------------------------------------------------------------+
void TestGapWindows()
{
   ExpectBool("GapUp valid",
      BossPattern.IsGapUp(1.1000, 1.1010), true);
   ExpectBool("GapUp touching false",
      BossPattern.IsGapUp(1.1000, 1.1000), false);
   ExpectBool("GapUp overlap false",
      BossPattern.IsGapUp(1.1000, 1.0990), false);
   ExpectBool("GapUp negative false",
      BossPattern.IsGapUp(-1.0, 1.1010), false);

   ExpectBool("GapDown valid",
      BossPattern.IsGapDown(1.1000, 1.0990), true);
   ExpectBool("GapDown touching false",
      BossPattern.IsGapDown(1.1000, 1.1000), false);
   ExpectBool("GapDown overlap false",
      BossPattern.IsGapDown(1.1000, 1.1010), false);
   ExpectBool("GapDown negative false",
      BossPattern.IsGapDown(1.1000, -1.0), false);

   ExpectBool("BodyGapUp valid",
      BossPattern.IsBodyGapUp(1.1000,1.0980,1.1010,1.1030), true);
   ExpectBool("BodyGapUp touching false",
      BossPattern.IsBodyGapUp(1.1000,1.0980,1.1000,1.1030), false);
   ExpectBool("BodyGapUp overlap false",
      BossPattern.IsBodyGapUp(1.1000,1.0980,1.0990,1.1030), false);
   ExpectBool("BodyGapUp negative false",
      BossPattern.IsBodyGapUp(-1.0,1.0980,1.1010,1.1030), false);

   ExpectBool("BodyGapDown valid",
      BossPattern.IsBodyGapDown(1.1000,1.1020,1.0990,1.0970), true);
   ExpectBool("BodyGapDown touching false",
      BossPattern.IsBodyGapDown(1.1000,1.1020,1.1000,1.0970), false);
   ExpectBool("BodyGapDown overlap false",
      BossPattern.IsBodyGapDown(1.1000,1.1020,1.1010,1.0970), false);
   ExpectBool("BodyGapDown negative false",
      BossPattern.IsBodyGapDown(1.1000,1.1020,-1.0,1.0970), false);
}

//+------------------------------------------------------------------+
//| Block 5 kicker tests                                             |
//+------------------------------------------------------------------+
void TestKickers()
{
   ExpectBool("BullishKicker valid",
      BossPattern.IsBullishKicker(
         1.1050,1.1060,1.0990,1.1000,
         1.1060,1.1110,1.1050,1.1100), true);

   ExpectBool("BullishKicker body touching false",
      BossPattern.IsBullishKicker(
         1.1050,1.1060,1.0990,1.1000,
         1.1050,1.1100,1.1040,1.1090), false);

   ExpectBool("BullishKicker first not bearish",
      BossPattern.IsBullishKicker(
         1.1000,1.1060,1.0990,1.1050,
         1.1060,1.1110,1.1050,1.1100), false);

   ExpectBool("BullishKicker second not bullish",
      BossPattern.IsBullishKicker(
         1.1050,1.1060,1.0990,1.1000,
         1.1100,1.1110,1.1050,1.1060), false);

   ExpectBool("BearishKicker valid",
      BossPattern.IsBearishKicker(
         1.1000,1.1060,1.0990,1.1050,
         1.0990,1.1000,1.0940,1.0950), true);

   ExpectBool("BearishKicker body touching false",
      BossPattern.IsBearishKicker(
         1.1000,1.1060,1.0990,1.1050,
         1.1000,1.1010,1.0950,1.0960), false);

   ExpectBool("BearishKicker first not bullish",
      BossPattern.IsBearishKicker(
         1.1050,1.1060,1.0990,1.1000,
         1.0990,1.1000,1.0940,1.0950), false);

   ExpectBool("BearishKicker second not bearish",
      BossPattern.IsBearishKicker(
         1.1000,1.1060,1.0990,1.1050,
         1.0950,1.1000,1.0940,1.0990), false);
}


//+------------------------------------------------------------------+
//| Block 6 aggregate classification tests                           |
//+------------------------------------------------------------------+
void TestAggregateClassifiers()
{
   ExpectBool("BullishSingle hammer true",
      BossPattern.IsBullishSingleCandlePattern(
         1.1000,1.1010,1.0950,1.1008), true);

   ExpectBool("BullishSingle ordinary false",
      BossPattern.IsBullishSingleCandlePattern(
         1.1000,1.1040,1.0980,1.1020), false);

   ExpectBool("BullishSingle invalid false",
      BossPattern.IsBullishSingleCandlePattern(
         1.1000,1.0990,1.0980,1.1020), false);

   ExpectBool("BearishSingle shooting star true",
      BossPattern.IsBearishSingleCandlePattern(
         1.1008,1.1060,1.1000,1.1000), true);

   ExpectBool("BearishSingle ordinary false",
      BossPattern.IsBearishSingleCandlePattern(
         1.1020,1.1040,1.0980,1.1000), false);

   ExpectBool("BearishSingle invalid false",
      BossPattern.IsBearishSingleCandlePattern(
         1.1020,1.1010,1.0980,1.1000), false);

   ExpectBool("BullishTwo engulfing true",
      BossPattern.IsBullishTwoCandlePattern(
         1.1050,1.1060,1.0990,1.1000,
         1.0990,1.1080,1.0980,1.1070), true);

   ExpectBool("BullishTwo ordinary false",
      BossPattern.IsBullishTwoCandlePattern(
         1.1000,1.1040,1.0990,1.1020,
         1.1020,1.1050,1.1010,1.1030), false);

   ExpectBool("BullishTwo invalid false",
      BossPattern.IsBullishTwoCandlePattern(
         1.1000,1.0990,1.0980,1.1020,
         1.1020,1.1050,1.1010,1.1030), false);

   ExpectBool("BearishTwo engulfing true",
      BossPattern.IsBearishTwoCandlePattern(
         1.1000,1.1060,1.0990,1.1050,
         1.1060,1.1070,1.0980,1.0990), true);

   ExpectBool("BearishTwo ordinary false",
      BossPattern.IsBearishTwoCandlePattern(
         1.1030,1.1050,1.1010,1.1020,
         1.1020,1.1040,1.0990,1.1010), false);

   ExpectBool("BearishTwo invalid false",
      BossPattern.IsBearishTwoCandlePattern(
         1.1030,1.1020,1.1010,1.1020,
         1.1020,1.1040,1.0990,1.1010), false);

   ExpectBool("BullishThree soldiers true",
      BossPattern.IsBullishThreeCandlePattern(
         1.1000,1.1030,1.0990,1.1020,
         1.1010,1.1050,1.1000,1.1040,
         1.1030,1.1070,1.1020,1.1060), true);

   ExpectBool("BullishThree ordinary false",
      BossPattern.IsBullishThreeCandlePattern(
         1.1000,1.1040,1.0990,1.1020,
         1.1020,1.1050,1.1010,1.1030,
         1.1030,1.1060,1.1020,1.1040), false);

   ExpectBool("BullishThree invalid false",
      BossPattern.IsBullishThreeCandlePattern(
         1.1000,1.0990,1.0980,1.1020,
         1.1020,1.1050,1.1010,1.1030,
         1.1030,1.1060,1.1020,1.1040), false);

   ExpectBool("BearishThree crows true",
      BossPattern.IsBearishThreeCandlePattern(
         1.1060,1.1070,1.1030,1.1040,
         1.1050,1.1060,1.1010,1.1020,
         1.1030,1.1040,1.0990,1.1000), true);

   ExpectBool("BearishThree ordinary false",
      BossPattern.IsBearishThreeCandlePattern(
         1.1040,1.1050,1.1010,1.1030,
         1.1030,1.1040,1.1000,1.1020,
         1.1020,1.1030,1.0990,1.1010), false);

   ExpectBool("BearishThree invalid false",
      BossPattern.IsBearishThreeCandlePattern(
         1.1040,1.1030,1.1010,1.1030,
         1.1030,1.1040,1.1000,1.1020,
         1.1020,1.1030,1.0990,1.1010), false);
}

//+------------------------------------------------------------------+
//| Expert initialization                                            |
//+------------------------------------------------------------------+
int OnInit()
{
   Print("==================================================");
   Print("BossR_Pattern Block 6 verification started");
   Print("==================================================");

   TestValidOHLC();
   TestMeasurements();
   TestDirection();
   TestDoji();
   TestMarubozu();
   TestHammer();
   TestShootingStar();
   TestSpinningTop();
   TestPairValidation();
   TestBarContainment();
   TestEngulfing();
   TestHarami();
   TestPenetrationPatterns();
   TestTweezers();
   TestTripleValidation();
   TestStarPatterns();
   TestThreeTrendCandles();
   TestThreeInside();
   TestThreeOutside();
   TestThreeValueSequences();
   TestThreeLineStrike();
   TestGapWindows();
   TestKickers();
   TestAggregateClassifiers();

   Print("==================================================");
   Print("BossR_Pattern_Verify_Block6_FULL ",
         Symbol(),
         ",",
         IntegerToString(Period()),
         ": PASS ",
         g_pass,
         " / FAIL ",
         g_fail);
   Print("==================================================");

   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert tick                                                      |
//+------------------------------------------------------------------+
void OnTick()
{
}