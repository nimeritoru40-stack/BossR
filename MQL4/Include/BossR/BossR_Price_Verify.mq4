//+------------------------------------------------------------------+
//| BossR_Price_Verify.mq4                                           |
//| BossR Framework - BossR_Price Block 6 verifier                   |
//| Compile and execute this EA only                                 |
//| MT4 only                                                         |
//+------------------------------------------------------------------+
#property strict

#include <BossR\BossR_Price.mqh>

C_BossR_Price BossPrice;

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
   Print("   actual=", actual, " expected=", expected);
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
         " expected=", DoubleToString(expected, 12),
         " epsilon=", DoubleToString(epsilon, 12));
}

void ExpectGreater(const string test_name,
                   const double actual,
                   const double minimum)
{
   if(actual > minimum)
   {
      Pass(test_name);
      return;
   }

   Fail(test_name);
   Print("   actual=", DoubleToString(actual, 12),
         " expected greater than ",
         DoubleToString(minimum, 12));
}

void ExpectGreaterOrEqual(const string test_name,
                          const double actual,
                          const double minimum)
{
   if(actual >= minimum)
   {
      Pass(test_name);
      return;
   }

   Fail(test_name);
   Print("   actual=", DoubleToString(actual, 12),
         " expected >= ",
         DoubleToString(minimum, 12));
}

void ExpectLessOrEqual(const string test_name,
                       const double actual,
                       const double maximum)
{
   if(actual <= maximum)
   {
      Pass(test_name);
      return;
   }

   Fail(test_name);
   Print("   actual=", DoubleToString(actual, 12),
         " expected <= ",
         DoubleToString(maximum, 12));
}

//+------------------------------------------------------------------+
//| Block 1 deterministic tests                                      |
//+------------------------------------------------------------------+
void TestPipProperties()
{
   ExpectDouble("5-digit pip size",
                BossPrice.PipSizeFromProperties(5, 0.00001),
                0.00010);

   ExpectDouble("4-digit pip size",
                BossPrice.PipSizeFromProperties(4, 0.00010),
                0.00010);

   ExpectDouble("3-digit pip size",
                BossPrice.PipSizeFromProperties(3, 0.001),
                0.010);

   ExpectDouble("2-digit pip size",
                BossPrice.PipSizeFromProperties(2, 0.01),
                0.01);

   ExpectDouble("Invalid zero point pip size",
                BossPrice.PipSizeFromProperties(5, 0.0),
                0.0);

   ExpectDouble("Invalid negative point pip size",
                BossPrice.PipSizeFromProperties(5, -0.00001),
                0.0);

   ExpectInt("5-digit pip factor",
             BossPrice.PipFactorFromDigits(5),
             10);

   ExpectInt("4-digit pip factor",
             BossPrice.PipFactorFromDigits(4),
             1);

   ExpectInt("3-digit pip factor",
             BossPrice.PipFactorFromDigits(3),
             10);

   ExpectInt("2-digit pip factor",
             BossPrice.PipFactorFromDigits(2),
             1);
}

void TestPointConversions()
{
   ExpectDouble("Points to price positive",
                BossPrice.PointsToPriceByPoint(25.0, 0.00001),
                0.00025);

   ExpectDouble("Points to price negative",
                BossPrice.PointsToPriceByPoint(-25.0, 0.00001),
                -0.00025);

   ExpectDouble("Points to price zero",
                BossPrice.PointsToPriceByPoint(0.0, 0.00001),
                0.0);

   ExpectDouble("Points to price invalid point",
                BossPrice.PointsToPriceByPoint(25.0, 0.0),
                0.0);

   ExpectDouble("Price to points positive",
                BossPrice.PriceToPointsByPoint(0.00025, 0.00001),
                25.0);

   ExpectDouble("Price to points negative",
                BossPrice.PriceToPointsByPoint(-0.00025, 0.00001),
                -25.0);

   ExpectDouble("Price to points invalid point",
                BossPrice.PriceToPointsByPoint(0.00025, 0.0),
                0.0);

   double source_points = 123.5;
   double converted_price =
      BossPrice.PointsToPriceByPoint(source_points, 0.00001);

   double restored_points =
      BossPrice.PriceToPointsByPoint(converted_price, 0.00001);

   ExpectDouble("Point conversion round trip",
                restored_points,
                source_points);
}

void TestPipConversions()
{
   ExpectDouble("5-digit pips to price",
                BossPrice.PipsToPriceByProperties(12.5, 5, 0.00001),
                0.00125);

   ExpectDouble("4-digit pips to price",
                BossPrice.PipsToPriceByProperties(12.5, 4, 0.00010),
                0.00125);

   ExpectDouble("3-digit pips to price",
                BossPrice.PipsToPriceByProperties(12.5, 3, 0.001),
                0.125);

   ExpectDouble("2-digit pips to price",
                BossPrice.PipsToPriceByProperties(12.5, 2, 0.01),
                0.125);

   ExpectDouble("Pips to price negative",
                BossPrice.PipsToPriceByProperties(-12.5, 5, 0.00001),
                -0.00125);

   ExpectDouble("Pips to price invalid point",
                BossPrice.PipsToPriceByProperties(12.5, 5, 0.0),
                0.0);

   ExpectDouble("5-digit price to pips",
                BossPrice.PriceToPipsByProperties(0.00125, 5, 0.00001),
                12.5);

   ExpectDouble("4-digit price to pips",
                BossPrice.PriceToPipsByProperties(0.00125, 4, 0.00010),
                12.5);

   ExpectDouble("3-digit price to pips",
                BossPrice.PriceToPipsByProperties(0.125, 3, 0.001),
                12.5);

   ExpectDouble("2-digit price to pips",
                BossPrice.PriceToPipsByProperties(0.125, 2, 0.01),
                12.5);

   ExpectDouble("Price to pips invalid point",
                BossPrice.PriceToPipsByProperties(0.00125, 5, 0.0),
                0.0);

   ExpectDouble("5-digit points to pips",
                BossPrice.PointsToPipsByDigits(125.0, 5),
                12.5);

   ExpectDouble("4-digit points to pips",
                BossPrice.PointsToPipsByDigits(12.5, 4),
                12.5);

   ExpectDouble("3-digit pips to points",
                BossPrice.PipsToPointsByDigits(12.5, 3),
                125.0);

   ExpectDouble("2-digit pips to points",
                BossPrice.PipsToPointsByDigits(12.5, 2),
                12.5);

   double source_pips = 37.25;
   double converted_price =
      BossPrice.PipsToPriceByProperties(source_pips, 5, 0.00001);

   double restored_pips =
      BossPrice.PriceToPipsByProperties(converted_price,
                                        5,
                                        0.00001);

   ExpectDouble("Pip conversion round trip",
                restored_pips,
                source_pips);
}

void TestNormalization()
{
   ExpectDouble("Normalize 5 digits",
                BossPrice.NormalizePriceByDigits(1.123456789, 5),
                1.12346);

   ExpectDouble("Normalize 3 digits",
                BossPrice.NormalizePriceByDigits(123.45678, 3),
                123.457);

   ExpectDouble("Normalize zero digits",
                BossPrice.NormalizePriceByDigits(123.6, 0),
                124.0);

   ExpectDouble("Normalize negative digits clamps zero",
                BossPrice.NormalizePriceByDigits(123.6, -5),
                124.0);

   ExpectDouble("Normalize excessive digits clamps eight",
                BossPrice.NormalizePriceByDigits(1.1234567899, 12),
                1.12345679);
}

void TestRelationships()
{
   ExpectDouble("Absolute distance ascending",
                BossPrice.Distance(1.1000, 1.1050),
                0.0050);

   ExpectDouble("Absolute distance descending",
                BossPrice.Distance(1.1050, 1.1000),
                0.0050);

   ExpectDouble("Signed distance positive",
                BossPrice.SignedDistance(1.1000, 1.1050),
                0.0050);

   ExpectDouble("Signed distance negative",
                BossPrice.SignedDistance(1.1050, 1.1000),
                -0.0050);

   ExpectDouble("Midpoint normal",
                BossPrice.Midpoint(1.1000, 1.1100),
                1.1050);

   ExpectDouble("Midpoint reversed",
                BossPrice.Midpoint(1.1100, 1.1000),
                1.1050);

   ExpectDouble("Higher first",
                BossPrice.Higher(10.0, 5.0),
                10.0);

   ExpectDouble("Higher second",
                BossPrice.Higher(5.0, 10.0),
                10.0);

   ExpectDouble("Lower first",
                BossPrice.Lower(5.0, 10.0),
                5.0);

   ExpectDouble("Lower second",
                BossPrice.Lower(10.0, 5.0),
                5.0);

   ExpectBool("Positive price true",
              BossPrice.IsPositivePrice(1.0),
              true);

   ExpectBool("Zero price false",
              BossPrice.IsPositivePrice(0.0),
              false);

   ExpectBool("Negative price false",
              BossPrice.IsPositivePrice(-1.0),
              false);

   ExpectBool("Ordered range true",
              BossPrice.IsOrdered(1.0, 2.0),
              true);

   ExpectBool("Equal range ordered",
              BossPrice.IsOrdered(2.0, 2.0),
              true);

   ExpectBool("Reversed range false",
              BossPrice.IsOrdered(2.0, 1.0),
              false);

   ExpectBool("Inside inclusive middle",
              BossPrice.IsInsideInclusive(1.5, 1.0, 2.0),
              true);

   ExpectBool("Inside inclusive low edge",
              BossPrice.IsInsideInclusive(1.0, 1.0, 2.0),
              true);

   ExpectBool("Inside inclusive high edge",
              BossPrice.IsInsideInclusive(2.0, 1.0, 2.0),
              true);

   ExpectBool("Inside inclusive outside",
              BossPrice.IsInsideInclusive(2.5, 1.0, 2.0),
              false);

   ExpectBool("Inside inclusive reversed false",
              BossPrice.IsInsideInclusive(1.5, 2.0, 1.0),
              false);

   ExpectBool("Inside exclusive middle",
              BossPrice.IsInsideExclusive(1.5, 1.0, 2.0),
              true);

   ExpectBool("Inside exclusive low edge false",
              BossPrice.IsInsideExclusive(1.0, 1.0, 2.0),
              false);

   ExpectBool("Inside exclusive high edge false",
              BossPrice.IsInsideExclusive(2.0, 1.0, 2.0),
              false);

   ExpectBool("Inside exclusive equal range false",
              BossPrice.IsInsideExclusive(1.0, 1.0, 1.0),
              false);

   ExpectBool("Above true",
              BossPrice.IsAbove(2.0, 1.0),
              true);

   ExpectBool("Above equal false",
              BossPrice.IsAbove(1.0, 1.0),
              false);

   ExpectBool("Below true",
              BossPrice.IsBelow(1.0, 2.0),
              true);

   ExpectBool("Below equal false",
              BossPrice.IsBelow(1.0, 1.0),
              false);
}

//+------------------------------------------------------------------+
//| Block 2 tests                                                    |
//+------------------------------------------------------------------+
void TestToleranceComparisons()
{
   ExpectBool("Equals exact",
              BossPrice.Equals(1.1000, 1.1000, 0.0),
              true);

   ExpectBool("Equals inside tolerance",
              BossPrice.Equals(1.1000, 1.1005, 0.0010),
              true);

   ExpectBool("Equals at tolerance",
              BossPrice.Equals(1.1000, 1.1010, 0.0010),
              true);

   ExpectBool("Equals outside tolerance",
              BossPrice.Equals(1.1000, 1.1011, 0.0010),
              false);

   ExpectBool("Equals negative tolerance sanitized",
              BossPrice.Equals(1.1000, 1.1005, -0.0010),
              true);

   ExpectBool("Above by true",
              BossPrice.IsAboveBy(1.1020, 1.1000, 0.0010),
              true);

   ExpectBool("Above by exact boundary false",
              BossPrice.IsAboveBy(1.1010, 1.1000, 0.0010),
              false);

   ExpectBool("Above by insufficient false",
              BossPrice.IsAboveBy(1.1005, 1.1000, 0.0010),
              false);

   ExpectBool("Above by negative distance sanitized",
              BossPrice.IsAboveBy(1.1020, 1.1000, -0.0010),
              true);

   ExpectBool("Below by true",
              BossPrice.IsBelowBy(1.0980, 1.1000, 0.0010),
              true);

   ExpectBool("Below by exact boundary false",
              BossPrice.IsBelowBy(1.0990, 1.1000, 0.0010),
              false);

   ExpectBool("Below by insufficient false",
              BossPrice.IsBelowBy(1.0995, 1.1000, 0.0010),
              false);

   ExpectBool("Below by negative distance sanitized",
              BossPrice.IsBelowBy(1.0980, 1.1000, -0.0010),
              true);
}

void TestClamping()
{
   ExpectDouble("Clamp inside",
                BossPrice.Clamp(5.0, 0.0, 10.0),
                5.0);

   ExpectDouble("Clamp below",
                BossPrice.Clamp(-2.0, 0.0, 10.0),
                0.0);

   ExpectDouble("Clamp above",
                BossPrice.Clamp(12.0, 0.0, 10.0),
                10.0);

   ExpectDouble("Clamp low edge",
                BossPrice.Clamp(0.0, 0.0, 10.0),
                0.0);

   ExpectDouble("Clamp high edge",
                BossPrice.Clamp(10.0, 0.0, 10.0),
                10.0);

   ExpectDouble("Clamp reversed returns original",
                BossPrice.Clamp(12.0, 10.0, 0.0),
                12.0);

   ExpectDouble("Clamp ordered reversed below",
                BossPrice.ClampOrdered(-2.0, 10.0, 0.0),
                0.0);

   ExpectDouble("Clamp ordered reversed above",
                BossPrice.ClampOrdered(12.0, 10.0, 0.0),
                10.0);

   ExpectDouble("Clamp ordered reversed inside",
                BossPrice.ClampOrdered(5.0, 10.0, 0.0),
                5.0);
}

void TestStepAlignment()
{
   ExpectDouble("Snap nearest",
                BossPrice.SnapToStep(1.23456, 0.00010),
                1.23460);

   ExpectDouble("Snap nearest lower",
                BossPrice.SnapToStep(1.23454, 0.00010),
                1.23450);

   ExpectDouble("Snap negative step sanitized",
                BossPrice.SnapToStep(1.23456, -0.00010),
                1.23460);

   ExpectDouble("Snap zero step unchanged",
                BossPrice.SnapToStep(1.23456, 0.0),
                1.23456);

   ExpectDouble("Snap down",
                BossPrice.SnapDownToStep(1.23459, 0.00010),
                1.23450);

   ExpectDouble("Snap up",
                BossPrice.SnapUpToStep(1.23451, 0.00010),
                1.23460);

   ExpectDouble("Snap down exact",
                BossPrice.SnapDownToStep(1.23450, 0.00010),
                1.23450);

   ExpectDouble("Snap up exact",
                BossPrice.SnapUpToStep(1.23450, 0.00010),
                1.23450);
}

void TestMovement()
{
   ExpectDouble("Move positive",
                BossPrice.MovePrice(1.1000, 0.0050, 1),
                1.1050);

   ExpectDouble("Move negative",
                BossPrice.MovePrice(1.1000, 0.0050, -1),
                1.0950);

   ExpectDouble("Move zero direction",
                BossPrice.MovePrice(1.1000, 0.0050, 0),
                1.1000);

   ExpectDouble("Move positive sanitizes negative distance",
                BossPrice.MovePrice(1.1000, -0.0050, 1),
                1.1050);

   ExpectDouble("Move negative sanitizes negative distance",
                BossPrice.MovePrice(1.1000, -0.0050, -1),
                1.0950);
}

void TestDirection()
{
   ExpectInt("Direction up",
             BossPrice.Direction(1.1000, 1.1010),
             1);

   ExpectInt("Direction down",
             BossPrice.Direction(1.1010, 1.1000),
             -1);

   ExpectInt("Direction flat",
             BossPrice.Direction(1.1000, 1.1000),
             0);

   ExpectInt("Direction inside positive tolerance",
             BossPrice.Direction(1.1000, 1.1005, 0.0010),
             0);

   ExpectInt("Direction inside negative tolerance sanitized",
             BossPrice.Direction(1.1000, 1.1005, -0.0010),
             0);

   ExpectInt("Direction above tolerance",
             BossPrice.Direction(1.1000, 1.1011, 0.0010),
             1);

   ExpectInt("Direction below tolerance",
             BossPrice.Direction(1.1000, 1.0989, 0.0010),
             -1);
}

void TestCrossings()
{
   ExpectBool("Crossed above true",
              BossPrice.CrossedAbove(1.0990, 1.1010, 1.1000),
              true);

   ExpectBool("Crossed above from level",
              BossPrice.CrossedAbove(1.1000, 1.1010, 1.1000),
              true);

   ExpectBool("Crossed above already above false",
              BossPrice.CrossedAbove(1.1010, 1.1020, 1.1000),
              false);

   ExpectBool("Crossed above ends at level false",
              BossPrice.CrossedAbove(1.0990, 1.1000, 1.1000),
              false);

   ExpectBool("Crossed above tolerance blocks near move",
              BossPrice.CrossedAbove(1.0990,
                                     1.1005,
                                     1.1000,
                                     0.0010),
              false);

   ExpectBool("Crossed above tolerance true",
              BossPrice.CrossedAbove(1.0990,
                                     1.1011,
                                     1.1000,
                                     0.0010),
              true);

   ExpectBool("Crossed below true",
              BossPrice.CrossedBelow(1.1010, 1.0990, 1.1000),
              true);

   ExpectBool("Crossed below from level",
              BossPrice.CrossedBelow(1.1000, 1.0990, 1.1000),
              true);

   ExpectBool("Crossed below already below false",
              BossPrice.CrossedBelow(1.0990, 1.0980, 1.1000),
              false);

   ExpectBool("Crossed below ends at level false",
              BossPrice.CrossedBelow(1.1010, 1.1000, 1.1000),
              false);

   ExpectBool("Crossed below tolerance blocks near move",
              BossPrice.CrossedBelow(1.1010,
                                     1.0995,
                                     1.1000,
                                     0.0010),
              false);

   ExpectBool("Crossed below tolerance true",
              BossPrice.CrossedBelow(1.1010,
                                     1.0989,
                                     1.1000,
                                     0.0010),
              true);
}


//+------------------------------------------------------------------+
//| Block 3 range geometry tests                                     |
//+------------------------------------------------------------------+
void TestRangeGeometry()
{
   ExpectDouble("Range size ascending",
                BossPrice.RangeSize(1.1000, 1.1100),
                0.0100);

   ExpectDouble("Range size descending",
                BossPrice.RangeSize(1.1100, 1.1000),
                0.0100);

   ExpectDouble("Range size equal",
                BossPrice.RangeSize(1.1000, 1.1000),
                0.0);

   ExpectDouble("Range midpoint ascending",
                BossPrice.RangeMidpoint(10.0, 20.0),
                15.0);

   ExpectDouble("Range midpoint descending",
                BossPrice.RangeMidpoint(20.0, 10.0),
                15.0);

   ExpectDouble("Position lower edge",
                BossPrice.PositionInRange(10.0, 10.0, 20.0),
                0.0);

   ExpectDouble("Position midpoint",
                BossPrice.PositionInRange(15.0, 10.0, 20.0),
                0.5);

   ExpectDouble("Position upper edge",
                BossPrice.PositionInRange(20.0, 10.0, 20.0),
                1.0);

   ExpectDouble("Position reversed range",
                BossPrice.PositionInRange(12.5, 20.0, 10.0),
                0.25);

   ExpectDouble("Position below range",
                BossPrice.PositionInRange(5.0, 10.0, 20.0),
                -0.5);

   ExpectDouble("Position above range",
                BossPrice.PositionInRange(25.0, 10.0, 20.0),
                1.5);

   ExpectDouble("Position zero range safe",
                BossPrice.PositionInRange(10.0, 10.0, 10.0),
                0.0);

   ExpectDouble("Clamped position below",
                BossPrice.PositionInRangeClamped(5.0, 10.0, 20.0),
                0.0);

   ExpectDouble("Clamped position inside",
                BossPrice.PositionInRangeClamped(17.5, 10.0, 20.0),
                0.75);

   ExpectDouble("Clamped position above",
                BossPrice.PositionInRangeClamped(25.0, 10.0, 20.0),
                1.0);

   ExpectDouble("Price at zero fraction",
                BossPrice.PriceAtFraction(10.0, 20.0, 0.0),
                10.0);

   ExpectDouble("Price at quarter fraction",
                BossPrice.PriceAtFraction(10.0, 20.0, 0.25),
                12.5);

   ExpectDouble("Price at reversed fraction",
                BossPrice.PriceAtFraction(20.0, 10.0, 0.75),
                17.5);

   ExpectDouble("Price fraction extrapolates below",
                BossPrice.PriceAtFraction(10.0, 20.0, -0.5),
                5.0);

   ExpectDouble("Price fraction extrapolates above",
                BossPrice.PriceAtFraction(10.0, 20.0, 1.5),
                25.0);

   ExpectDouble("Clamped fraction below",
                BossPrice.PriceAtFractionClamped(10.0, 20.0, -0.5),
                10.0);

   ExpectDouble("Clamped fraction above",
                BossPrice.PriceAtFractionClamped(10.0, 20.0, 1.5),
                20.0);
}

void TestRangeEdges()
{
   ExpectDouble("Distance lower edge inside",
                BossPrice.DistanceToLowerEdge(13.0, 10.0, 20.0),
                3.0);

   ExpectDouble("Distance upper edge inside",
                BossPrice.DistanceToUpperEdge(13.0, 10.0, 20.0),
                7.0);

   ExpectDouble("Distance lower reversed",
                BossPrice.DistanceToLowerEdge(13.0, 20.0, 10.0),
                3.0);

   ExpectDouble("Distance nearest lower",
                BossPrice.DistanceToNearestEdge(13.0, 10.0, 20.0),
                3.0);

   ExpectDouble("Distance nearest upper",
                BossPrice.DistanceToNearestEdge(18.0, 10.0, 20.0),
                2.0);

   ExpectInt("Nearest edge lower",
             BossPrice.NearestEdge(13.0, 10.0, 20.0),
             -1);

   ExpectInt("Nearest edge upper",
             BossPrice.NearestEdge(18.0, 10.0, 20.0),
             1);

   ExpectInt("Nearest edge midpoint tie",
             BossPrice.NearestEdge(15.0, 10.0, 20.0),
             0);

   ExpectBool("Lower quarter true",
              BossPrice.IsInLowerFraction(12.5, 10.0, 20.0, 0.25),
              true);

   ExpectBool("Lower quarter outside false",
              BossPrice.IsInLowerFraction(12.6, 10.0, 20.0, 0.25),
              false);

   ExpectBool("Upper quarter true",
              BossPrice.IsInUpperFraction(17.5, 10.0, 20.0, 0.25),
              true);

   ExpectBool("Upper quarter outside false",
              BossPrice.IsInUpperFraction(17.4, 10.0, 20.0, 0.25),
              false);

   ExpectBool("Lower fraction rejects below range",
              BossPrice.IsInLowerFraction(9.0, 10.0, 20.0, 0.25),
              false);

   ExpectBool("Upper fraction rejects above range",
              BossPrice.IsInUpperFraction(21.0, 10.0, 20.0, 0.25),
              false);
}

void TestPercentChanges()
{
   ExpectDouble("Percent change positive",
                BossPrice.PercentChange(100.0, 110.0),
                10.0);

   ExpectDouble("Percent change negative",
                BossPrice.PercentChange(100.0, 90.0),
                -10.0);

   ExpectDouble("Percent change negative base",
                BossPrice.PercentChange(-100.0, -90.0),
                10.0);

   ExpectDouble("Percent change zero base safe",
                BossPrice.PercentChange(0.0, 10.0),
                0.0);

   ExpectDouble("Apply percent positive",
                BossPrice.ApplyPercentChange(100.0, 10.0),
                110.0);

   ExpectDouble("Apply percent negative",
                BossPrice.ApplyPercentChange(100.0, -10.0),
                90.0);

   ExpectDouble("Apply percent negative price",
                BossPrice.ApplyPercentChange(-100.0, 10.0),
                -90.0);

   ExpectDouble("Percent round trip",
                BossPrice.PercentChange(100.0,
                   BossPrice.ApplyPercentChange(100.0, 37.5)),
                37.5);
}

//+------------------------------------------------------------------+
//| Runtime market tests                                             |
//+------------------------------------------------------------------+
void TestLiveSymbol()
{
   string symbol_name = Symbol();

   int digits_value = BossPrice.DigitsCount(symbol_name);
   double point_value = BossPrice.PointSize(symbol_name);
   double pip_value = BossPrice.PipSize(symbol_name);
   int pip_factor = BossPrice.PipFactor(symbol_name);

   double bid_value = BossPrice.BidPrice(symbol_name);
   double ask_value = BossPrice.AskPrice(symbol_name);
   double mid_value = BossPrice.MidPrice(symbol_name);

   double spread_price = BossPrice.SpreadPrice(symbol_name);
   double spread_points = BossPrice.SpreadPoints(symbol_name);
   double spread_pips = BossPrice.SpreadPips(symbol_name);

   ExpectGreaterOrEqual("Live digits nonnegative",
                        digits_value,
                        0);

   ExpectGreater("Live point positive",
                 point_value,
                 0.0);

   ExpectGreater("Live pip positive",
                 pip_value,
                 0.0);

   ExpectBool("Live pip factor valid",
              pip_factor == 1 || pip_factor == 10,
              true);

   ExpectGreater("Live bid positive",
                 bid_value,
                 0.0);

   ExpectGreater("Live ask positive",
                 ask_value,
                 0.0);

   ExpectGreaterOrEqual("Live ask not below bid",
                        ask_value,
                        bid_value);

   ExpectGreaterOrEqual("Live midpoint not below bid",
                        mid_value,
                        bid_value);

   ExpectLessOrEqual("Live midpoint not above ask",
                     mid_value,
                     ask_value);

   ExpectGreaterOrEqual("Live spread price nonnegative",
                        spread_price,
                        0.0);

   ExpectGreaterOrEqual("Live spread points nonnegative",
                        spread_points,
                        0.0);

   ExpectGreaterOrEqual("Live spread pips nonnegative",
                        spread_pips,
                        0.0);

   ExpectDouble("Live spread price relationship",
                spread_price,
                ask_value - bid_value,
                point_value * 0.1);

   ExpectDouble("Live midpoint relationship",
                mid_value,
                (bid_value + ask_value) * 0.5,
                point_value * 0.1);

   ExpectDouble("Live point conversion round trip",
                BossPrice.PriceToPoints(
                   BossPrice.PointsToPrice(123.0, symbol_name),
                   symbol_name),
                123.0,
                0.000001);

   ExpectDouble("Live pip conversion round trip",
                BossPrice.PriceToPips(
                   BossPrice.PipsToPrice(12.5, symbol_name),
                   symbol_name),
                12.5,
                0.000001);

   ExpectDouble("Live points and pips relationship",
                BossPrice.PipsToPoints(1.0, symbol_name),
                pip_factor,
                0.000001);

   double raw_price = bid_value + point_value * 0.4321;
   double normalized_price =
      BossPrice.NormalizePrice(raw_price, symbol_name);

   ExpectDouble("Live normalized price uses symbol digits",
                normalized_price,
                NormalizeDouble(raw_price, digits_value));

   ExpectDouble("Default symbol point matches explicit",
                BossPrice.PointSize(),
                BossPrice.PointSize(symbol_name));

   ExpectDouble("Default symbol pip matches explicit",
                BossPrice.PipSize(),
                BossPrice.PipSize(symbol_name));

   double point_test_price =
      BossPrice.AddPoints(bid_value, 10.0, symbol_name);

   ExpectDouble("Live add points",
                point_test_price,
                bid_value + point_value * 10.0,
                point_value * 0.1);

   ExpectDouble("Live subtract points",
                BossPrice.SubtractPoints(bid_value,
                                         10.0,
                                         symbol_name),
                bid_value - point_value * 10.0,
                point_value * 0.1);

   ExpectDouble("Live add pips",
                BossPrice.AddPips(bid_value,
                                  2.0,
                                  symbol_name),
                bid_value + pip_value * 2.0,
                point_value * 0.1);

   ExpectDouble("Live subtract pips",
                BossPrice.SubtractPips(bid_value,
                                       2.0,
                                       symbol_name),
                bid_value - pip_value * 2.0,
                point_value * 0.1);

   ExpectBool("Live equals points true",
              BossPrice.EqualsPoints(bid_value,
                                     bid_value + point_value,
                                     1.0,
                                     symbol_name),
              true);

   ExpectBool("Live equals points false",
              BossPrice.EqualsPoints(bid_value,
                                     bid_value + point_value * 2.0,
                                     1.0,
                                     symbol_name),
              false);

   ExpectBool("Live equals pips true",
              BossPrice.EqualsPips(bid_value,
                                   bid_value + pip_value,
                                   1.0,
                                   symbol_name),
              true);

   ExpectBool("Live above by points",
              BossPrice.IsAboveByPoints(bid_value + point_value * 2.0,
                                        bid_value,
                                        1.0,
                                        symbol_name),
              true);

   ExpectBool("Live below by points",
              BossPrice.IsBelowByPoints(bid_value - point_value * 2.0,
                                        bid_value,
                                        1.0,
                                        symbol_name),
              true);

   ExpectDouble("Live move points up",
                BossPrice.MovePricePoints(bid_value,
                                          10.0,
                                          1,
                                          symbol_name),
                bid_value + point_value * 10.0,
                point_value * 0.1);

   ExpectDouble("Live move points down",
                BossPrice.MovePricePoints(bid_value,
                                          10.0,
                                          -1,
                                          symbol_name),
                bid_value - point_value * 10.0,
                point_value * 0.1);

   ExpectDouble("Live move pips up",
                BossPrice.MovePricePips(bid_value,
                                        2.0,
                                        1,
                                        symbol_name),
                bid_value + pip_value * 2.0,
                point_value * 0.1);

   double snapped_point =
      BossPrice.SnapToPoint(bid_value + point_value * 0.37,
                            symbol_name);

   ExpectDouble("Live snap point normalized",
                snapped_point,
                NormalizeDouble(snapped_point, digits_value));

   double snapped_pip =
      BossPrice.SnapToPip(bid_value + pip_value * 0.37,
                          symbol_name);

   ExpectDouble("Live snap pip normalized",
                snapped_pip,
                NormalizeDouble(snapped_pip, digits_value));
}


//+------------------------------------------------------------------+
//| Block 4 deterministic tests                                      |
//+------------------------------------------------------------------+
void TestTickAndMonetaryValue()
{
   ExpectDouble("Tick money one tick",
                BossPrice.TickValueForPriceDistanceByProperties(0.00001, 0.00001, 1.0, 1.0),
                1.0);
   ExpectDouble("Tick money ten ticks",
                BossPrice.TickValueForPriceDistanceByProperties(0.00010, 0.00001, 1.0, 1.0),
                10.0);
   ExpectDouble("Tick money negative distance absolute",
                BossPrice.TickValueForPriceDistanceByProperties(-0.00010, 0.00001, 1.0, 1.0),
                10.0);
   ExpectDouble("Tick money two lots",
                BossPrice.TickValueForPriceDistanceByProperties(0.00010, 0.00001, 1.0, 2.0),
                20.0);
   ExpectDouble("Tick money invalid tick size",
                BossPrice.TickValueForPriceDistanceByProperties(0.00010, 0.0, 1.0, 1.0),
                0.0);
   ExpectDouble("Tick money invalid tick value",
                BossPrice.TickValueForPriceDistanceByProperties(0.00010, 0.00001, 0.0, 1.0),
                0.0);
   ExpectDouble("Tick money invalid lots",
                BossPrice.TickValueForPriceDistanceByProperties(0.00010, 0.00001, 1.0, 0.0),
                0.0);

   ExpectDouble("Point value equal tick",
                BossPrice.PointValueByProperties(0.00001, 0.00001, 1.0, 1.0),
                1.0);
   ExpectDouble("Point value half tick",
                BossPrice.PointValueByProperties(0.00001, 0.00002, 2.0, 1.0),
                1.0);
   ExpectDouble("Point value two lots",
                BossPrice.PointValueByProperties(0.00001, 0.00001, 1.0, 2.0),
                2.0);
   ExpectDouble("Point value invalid point",
                BossPrice.PointValueByProperties(0.0, 0.00001, 1.0, 1.0),
                0.0);

   ExpectDouble("Five digit pip value",
                BossPrice.PipValueByProperties(5, 0.00001, 0.00001, 1.0, 1.0),
                10.0);
   ExpectDouble("Four digit pip value",
                BossPrice.PipValueByProperties(4, 0.00010, 0.00010, 10.0, 1.0),
                10.0);
   ExpectDouble("Three digit pip value",
                BossPrice.PipValueByProperties(3, 0.001, 0.001, 1.0, 1.0),
                10.0);
   ExpectDouble("Pip value two lots",
                BossPrice.PipValueByProperties(5, 0.00001, 0.00001, 1.0, 2.0),
                20.0);
}

void TestRiskGeometry()
{
   ExpectDouble("Risk money long",
                BossPrice.RiskMoneyByDistance(1.10100, 1.10000, 0.00001, 1.0, 1.0),
                100.0);
   ExpectDouble("Risk money short",
                BossPrice.RiskMoneyByDistance(1.10000, 1.10100, 0.00001, 1.0, 1.0),
                100.0);
   ExpectDouble("Risk money half lot",
                BossPrice.RiskMoneyByDistance(1.10100, 1.10000, 0.00001, 1.0, 0.5),
                50.0);
   ExpectDouble("Risk money zero distance",
                BossPrice.RiskMoneyByDistance(1.10000, 1.10000, 0.00001, 1.0, 1.0),
                0.0);

   ExpectDouble("Lots for risk one lot",
                BossPrice.LotsForRiskByDistance(100.0, 1.10100, 1.10000, 0.00001, 1.0),
                1.0);
   ExpectDouble("Lots for risk half lot",
                BossPrice.LotsForRiskByDistance(50.0, 1.10100, 1.10000, 0.00001, 1.0),
                0.5);
   ExpectDouble("Lots for risk invalid money",
                BossPrice.LotsForRiskByDistance(0.0, 1.10100, 1.10000, 0.00001, 1.0),
                0.0);
   ExpectDouble("Lots for risk zero stop distance",
                BossPrice.LotsForRiskByDistance(100.0, 1.10000, 1.10000, 0.00001, 1.0),
                0.0);

   ExpectDouble("Reward risk two",
                BossPrice.RewardRiskRatio(1.1000, 1.0950, 1.1100),
                2.0);
   ExpectDouble("Reward risk short two",
                BossPrice.RewardRiskRatio(1.1000, 1.1050, 1.0900),
                2.0);
   ExpectDouble("Reward risk zero risk",
                BossPrice.RewardRiskRatio(1.1000, 1.1000, 1.1100),
                0.0);
   ExpectDouble("Reward risk absolute target",
                BossPrice.RewardRiskRatio(1.1000, 1.0950, 1.0900),
                2.0);

   ExpectDouble("Target long 2R",
                BossPrice.TargetPriceForRewardRisk(1.1000, 1.0950, 2.0, 1),
                1.1100);
   ExpectDouble("Target short 2R",
                BossPrice.TargetPriceForRewardRisk(1.1000, 1.1050, 2.0, -1),
                1.0900);
   ExpectDouble("Target negative ratio sanitized",
                BossPrice.TargetPriceForRewardRisk(1.1000, 1.0950, -2.0, 1),
                1.1100);
   ExpectDouble("Target zero direction unchanged",
                BossPrice.TargetPriceForRewardRisk(1.1000, 1.0950, 2.0, 0),
                1.1000);

   ExpectDouble("Stop long",
                BossPrice.StopPriceForRiskDistance(1.1000, 0.0050, 1),
                1.0950);
   ExpectDouble("Stop short",
                BossPrice.StopPriceForRiskDistance(1.1000, 0.0050, -1),
                1.1050);
   ExpectDouble("Stop negative distance sanitized",
                BossPrice.StopPriceForRiskDistance(1.1000, -0.0050, 1),
                1.0950);
   ExpectDouble("Stop zero direction unchanged",
                BossPrice.StopPriceForRiskDistance(1.1000, 0.0050, 0),
                1.1000);
}

void TestInterpolationAndDistancePercent()
{
   ExpectDouble("Interpolate quarter",
                BossPrice.InterpolatePrice(1.1000, 1.2000, 0.25),
                1.1250);
   ExpectDouble("Interpolate reversed quarter",
                BossPrice.InterpolatePrice(1.2000, 1.1000, 0.25),
                1.1750);
   ExpectDouble("Interpolate extrapolate above",
                BossPrice.InterpolatePrice(1.1000, 1.2000, 1.5),
                1.2500);
   ExpectDouble("Interpolate extrapolate below",
                BossPrice.InterpolatePrice(1.1000, 1.2000, -0.5),
                1.0500);
   ExpectDouble("Interpolate clamped above",
                BossPrice.InterpolatePriceClamped(1.1000, 1.2000, 1.5),
                1.2000);
   ExpectDouble("Interpolate clamped below",
                BossPrice.InterpolatePriceClamped(1.1000, 1.2000, -0.5),
                1.1000);

   ExpectDouble("Distance percent quarter",
                BossPrice.DistancePercentOfRange(0.0025, 0.0100),
                25.0);
   ExpectDouble("Distance percent absolute",
                BossPrice.DistancePercentOfRange(-0.0025, -0.0100),
                25.0);
   ExpectDouble("Distance percent zero range",
                BossPrice.DistancePercentOfRange(0.0025, 0.0),
                0.0);
   ExpectDouble("Price distance percent",
                BossPrice.PriceDistancePercent(1.1025, 1.1000, 0.0100),
                25.0);
}



//+------------------------------------------------------------------+
//| Block 5 deterministic tests                                      |
//+------------------------------------------------------------------+
void TestCandleCorePrices()
{
   ExpectDouble("Candle range normal", BossPrice.CandleRange(1.1100, 1.1000), 0.0100);
   ExpectDouble("Candle range reversed", BossPrice.CandleRange(1.1000, 1.1100), 0.0100);
   ExpectDouble("Candle range zero", BossPrice.CandleRange(1.1000, 1.1000), 0.0);

   ExpectDouble("Candle body bullish", BossPrice.CandleBody(1.1020, 1.1080), 0.0060);
   ExpectDouble("Candle body bearish", BossPrice.CandleBody(1.1080, 1.1020), 0.0060);
   ExpectDouble("Candle body doji", BossPrice.CandleBody(1.1050, 1.1050), 0.0);

   ExpectDouble("Candle signed body bullish", BossPrice.CandleSignedBody(1.1020, 1.1080), 0.0060);
   ExpectDouble("Candle signed body bearish", BossPrice.CandleSignedBody(1.1080, 1.1020), -0.0060);
   ExpectDouble("Candle signed body doji", BossPrice.CandleSignedBody(1.1050, 1.1050), 0.0);

   ExpectDouble("Candle mid price", BossPrice.CandleMidPrice(1.1100, 1.1000), 1.1050);
   ExpectDouble("Candle mid reversed", BossPrice.CandleMidPrice(1.1000, 1.1100), 1.1050);
   ExpectDouble("Candle mid equal", BossPrice.CandleMidPrice(1.1050, 1.1050), 1.1050);

   ExpectDouble("Candle typical price", BossPrice.CandleTypicalPrice(1.1100, 1.1000, 1.1080), 1.1060);
   ExpectDouble("Candle weighted close", BossPrice.CandleWeightedClose(1.1100, 1.1000, 1.1080), 1.1065);
   ExpectDouble("Candle OHLC4", BossPrice.CandleOHLC4(1.1020, 1.1100, 1.1000, 1.1080), 1.1050);
}

void TestCandleWicks()
{
   ExpectDouble("Upper wick bullish", BossPrice.CandleUpperWick(1.1020, 1.1100, 1.1080), 0.0020);
   ExpectDouble("Upper wick bearish", BossPrice.CandleUpperWick(1.1080, 1.1100, 1.1020), 0.0020);
   ExpectDouble("Upper wick none", BossPrice.CandleUpperWick(1.1020, 1.1080, 1.1080), 0.0);

   ExpectDouble("Lower wick bullish", BossPrice.CandleLowerWick(1.1020, 1.1000, 1.1080), 0.0020);
   ExpectDouble("Lower wick bearish", BossPrice.CandleLowerWick(1.1080, 1.1000, 1.1020), 0.0020);
   ExpectDouble("Lower wick none", BossPrice.CandleLowerWick(1.1020, 1.1020, 1.1080), 0.0);

   ExpectDouble("Total wick balanced", BossPrice.CandleTotalWick(1.1020, 1.1100, 1.1000, 1.1080), 0.0040);
   ExpectDouble("Total wick upper only", BossPrice.CandleTotalWick(1.1020, 1.1100, 1.1020, 1.1080), 0.0020);
   ExpectDouble("Total wick lower only", BossPrice.CandleTotalWick(1.1020, 1.1080, 1.1000, 1.1080), 0.0020);
   ExpectDouble("Total wick none", BossPrice.CandleTotalWick(1.1020, 1.1080, 1.1020, 1.1080), 0.0);
}

void TestCandleDirectionAndPercent()
{
   ExpectInt("Candle direction bullish", BossPrice.CandleDirection(1.1020, 1.1080), 1);
   ExpectInt("Candle direction bearish", BossPrice.CandleDirection(1.1080, 1.1020), -1);
   ExpectInt("Candle direction doji", BossPrice.CandleDirection(1.1050, 1.1050), 0);
   ExpectInt("Candle direction inside tolerance", BossPrice.CandleDirection(1.1000, 1.1004, 0.0005), 0);
   ExpectInt("Candle direction above tolerance", BossPrice.CandleDirection(1.1000, 1.1006, 0.0005), 1);
   ExpectInt("Candle direction negative tolerance sanitized", BossPrice.CandleDirection(1.1000, 1.1001, -1.0), 1);

   ExpectDouble("Candle body percent sixty", BossPrice.CandleBodyPercent(1.1020, 1.1100, 1.1000, 1.1080), 60.0);
   ExpectDouble("Candle body percent bearish sixty", BossPrice.CandleBodyPercent(1.1080, 1.1100, 1.1000, 1.1020), 60.0);
   ExpectDouble("Candle body percent zero range", BossPrice.CandleBodyPercent(1.1000, 1.1000, 1.1000, 1.1000), 0.0);

   ExpectDouble("Upper wick percent twenty", BossPrice.CandleUpperWickPercent(1.1020, 1.1100, 1.1000, 1.1080), 20.0);
   ExpectDouble("Upper wick percent zero", BossPrice.CandleUpperWickPercent(1.1020, 1.1080, 1.1000, 1.1080), 0.0);
   ExpectDouble("Upper wick percent zero range", BossPrice.CandleUpperWickPercent(1.1000, 1.1000, 1.1000, 1.1000), 0.0);

   ExpectDouble("Lower wick percent twenty", BossPrice.CandleLowerWickPercent(1.1020, 1.1100, 1.1000, 1.1080), 20.0);
   ExpectDouble("Lower wick percent zero", BossPrice.CandleLowerWickPercent(1.1000, 1.1100, 1.1000, 1.1080), 0.0);
   ExpectDouble("Lower wick percent zero range", BossPrice.CandleLowerWickPercent(1.1000, 1.1000, 1.1000, 1.1000), 0.0);
}

void TestTrueRange()
{
   ExpectDouble("True range normal", BossPrice.TrueRange(1.1100, 1.1000, 1.1050), 0.0100);
   ExpectDouble("True range gap up", BossPrice.TrueRange(1.1200, 1.1100, 1.1000), 0.0200);
   ExpectDouble("True range gap down", BossPrice.TrueRange(1.1000, 1.0900, 1.1100), 0.0200);
   ExpectDouble("True range previous at high", BossPrice.TrueRange(1.1100, 1.1000, 1.1100), 0.0100);
   ExpectDouble("True range previous at low", BossPrice.TrueRange(1.1100, 1.1000, 1.1000), 0.0100);
   ExpectDouble("True range zero", BossPrice.TrueRange(1.1000, 1.1000, 1.1000), 0.0);
}



//+------------------------------------------------------------------+
//| Block 6 deterministic tests                                      |
//+------------------------------------------------------------------+
void TestCandleStructure()
{
   ExpectDouble("Body top bullish", BossPrice.CandleBodyTop(1.1020, 1.1080), 1.1080);
   ExpectDouble("Body top bearish", BossPrice.CandleBodyTop(1.1080, 1.1020), 1.1080);
   ExpectDouble("Body bottom bullish", BossPrice.CandleBodyBottom(1.1020, 1.1080), 1.1020);
   ExpectDouble("Body bottom bearish", BossPrice.CandleBodyBottom(1.1080, 1.1020), 1.1020);

   ExpectBool("Valid candle normal", BossPrice.IsValidCandle(1.1020, 1.1100, 1.1000, 1.1080), true);
   ExpectBool("Valid candle doji", BossPrice.IsValidCandle(1.1050, 1.1050, 1.1050, 1.1050), true);
   ExpectBool("Invalid high below low", BossPrice.IsValidCandle(1.1020, 1.0990, 1.1000, 1.1010), false);
   ExpectBool("Invalid open above high", BossPrice.IsValidCandle(1.1110, 1.1100, 1.1000, 1.1080), false);
   ExpectBool("Invalid close below low", BossPrice.IsValidCandle(1.1020, 1.1100, 1.1000, 1.0990), false);
   ExpectBool("Valid candle tolerance", BossPrice.IsValidCandle(1.1101, 1.1100, 1.1000, 1.1080, 0.0001), true);

   ExpectDouble("Close position middle", BossPrice.CandleClosePosition(1.1100, 1.1000, 1.1050), 0.5);
   ExpectDouble("Close position high", BossPrice.CandleClosePosition(1.1100, 1.1000, 1.1100), 1.0);
   ExpectDouble("Close position low", BossPrice.CandleClosePosition(1.1100, 1.1000, 1.1000), 0.0);
   ExpectDouble("Close position clamps high", BossPrice.CandleClosePosition(1.1100, 1.1000, 1.1200), 1.0);
   ExpectDouble("Close position extrapolates high", BossPrice.CandleClosePosition(1.1100, 1.1000, 1.1200, false), 2.0);
   ExpectDouble("Close position zero range", BossPrice.CandleClosePosition(1.1000, 1.1000, 1.1000), 0.0);
   ExpectDouble("Close position percent", BossPrice.CandleClosePositionPercent(1.1100, 1.1000, 1.1075), 75.0);
}

void TestCandleClassification()
{
   ExpectBool("Doji exact", BossPrice.IsDoji(1.1000, 1.1000), true);
   ExpectBool("Doji within maximum body", BossPrice.IsDoji(1.1000, 1.1004, 0.0005), true);
   ExpectBool("Doji above maximum body false", BossPrice.IsDoji(1.1000, 1.1006, 0.0005), false);
   ExpectBool("Doji negative maximum sanitized", BossPrice.IsDoji(1.1000, 1.1001, -1.0), false);

   ExpectBool("Bullish candle true", BossPrice.IsBullishCandle(1.1000, 1.1010), true);
   ExpectBool("Bullish candle doji false", BossPrice.IsBullishCandle(1.1000, 1.1000), false);
   ExpectBool("Bullish inside tolerance false", BossPrice.IsBullishCandle(1.1000, 1.1004, 0.0005), false);
   ExpectBool("Bearish candle true", BossPrice.IsBearishCandle(1.1010, 1.1000), true);
   ExpectBool("Bearish candle doji false", BossPrice.IsBearishCandle(1.1000, 1.1000), false);
   ExpectBool("Bearish inside tolerance false", BossPrice.IsBearishCandle(1.1004, 1.1000, 0.0005), false);
}

void TestGapsAndBarRelationships()
{
   ExpectDouble("Gap positive", BossPrice.CandleGap(1.1050, 1.1000), 0.0050);
   ExpectDouble("Gap negative", BossPrice.CandleGap(1.0950, 1.1000), -0.0050);
   ExpectDouble("Gap absolute", BossPrice.CandleGapAbsolute(1.0950, 1.1000), 0.0050);
   ExpectInt("Gap direction up", BossPrice.CandleGapDirection(1.1050, 1.1000), 1);
   ExpectInt("Gap direction down", BossPrice.CandleGapDirection(1.0950, 1.1000), -1);
   ExpectInt("Gap direction tolerance flat", BossPrice.CandleGapDirection(1.1004, 1.1000, 0.0005), 0);

   ExpectBool("Inside bar strict true", BossPrice.IsInsideBar(1.1080, 1.1020, 1.1100, 1.1000, false), true);
   ExpectBool("Inside bar equal allowed", BossPrice.IsInsideBar(1.1100, 1.1020, 1.1100, 1.1000, true), true);
   ExpectBool("Inside bar equal strict false", BossPrice.IsInsideBar(1.1100, 1.1020, 1.1100, 1.1000, false), false);
   ExpectBool("Inside bar outside false", BossPrice.IsInsideBar(1.1110, 1.1020, 1.1100, 1.1000), false);

   ExpectBool("Outside bar strict true", BossPrice.IsOutsideBar(1.1120, 1.0980, 1.1100, 1.1000, false), true);
   ExpectBool("Outside bar equal allowed", BossPrice.IsOutsideBar(1.1100, 1.0980, 1.1100, 1.1000, true), true);
   ExpectBool("Outside bar equal strict false", BossPrice.IsOutsideBar(1.1100, 1.0980, 1.1100, 1.1000, false), false);
   ExpectBool("Outside bar inside false", BossPrice.IsOutsideBar(1.1080, 1.1020, 1.1100, 1.1000), false);

   ExpectDouble("Range overlap partial", BossPrice.CandleRangeOverlap(1.1100, 1.1000, 1.1150, 1.1050), 0.0050);
   ExpectDouble("Range overlap contained", BossPrice.CandleRangeOverlap(1.1100, 1.1000, 1.1080, 1.1020), 0.0060);
   ExpectDouble("Range overlap none", BossPrice.CandleRangeOverlap(1.1100, 1.1000, 1.1200, 1.1150), 0.0);
   ExpectDouble("Range overlap reversed inputs", BossPrice.CandleRangeOverlap(1.1000, 1.1100, 1.1150, 1.1050), 0.0050);
}

void TestEngulfing()
{
   ExpectBool("Bullish engulfing true", BossPrice.IsBullishEngulfing(1.1080, 1.1020, 1.1010, 1.1090), true);
   ExpectBool("Bullish engulfing equal allowed", BossPrice.IsBullishEngulfing(1.1080, 1.1020, 1.1020, 1.1080, true), true);
   ExpectBool("Bullish engulfing equal strict false", BossPrice.IsBullishEngulfing(1.1080, 1.1020, 1.1020, 1.1080, false), false);
   ExpectBool("Bullish engulfing wrong previous direction", BossPrice.IsBullishEngulfing(1.1020, 1.1080, 1.1010, 1.1090), false);
   ExpectBool("Bullish engulfing too small false", BossPrice.IsBullishEngulfing(1.1080, 1.1020, 1.1030, 1.1070), false);

   ExpectBool("Bearish engulfing true", BossPrice.IsBearishEngulfing(1.1020, 1.1080, 1.1090, 1.1010), true);
   ExpectBool("Bearish engulfing equal allowed", BossPrice.IsBearishEngulfing(1.1020, 1.1080, 1.1080, 1.1020, true), true);
   ExpectBool("Bearish engulfing equal strict false", BossPrice.IsBearishEngulfing(1.1020, 1.1080, 1.1080, 1.1020, false), false);
   ExpectBool("Bearish engulfing wrong previous direction", BossPrice.IsBearishEngulfing(1.1080, 1.1020, 1.1090, 1.1010), false);
   ExpectBool("Bearish engulfing too small false", BossPrice.IsBearishEngulfing(1.1020, 1.1080, 1.1070, 1.1030), false);
}

//+------------------------------------------------------------------+
//| Expert initialization                                            |
//+------------------------------------------------------------------+
int OnInit()
{
   Print("=== BossR_Price Block 6 Verification Started ===");
   Print("Symbol=", Symbol(),
         " Digits=", Digits,
         " Point=", DoubleToString(Point, Digits));

   TestPipProperties();
   TestPointConversions();
   TestPipConversions();
   TestNormalization();
   TestRelationships();

   TestToleranceComparisons();
   TestClamping();
   TestStepAlignment();
   TestMovement();
   TestDirection();
   TestCrossings();

   TestRangeGeometry();
   TestRangeEdges();
   TestPercentChanges();

   TestTickAndMonetaryValue();
   TestRiskGeometry();
   TestInterpolationAndDistancePercent();

   TestCandleCorePrices();
   TestCandleWicks();
   TestCandleDirectionAndPercent();
   TestTrueRange();

   TestCandleStructure();
   TestCandleClassification();
   TestGapsAndBarRelationships();
   TestEngulfing();

   RefreshRates();
   TestLiveSymbol();

   Print("=== BossR_Price Block 6 Verification Complete ===");
   Print("PASS ", g_pass, " / FAIL ", g_fail);

   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization                                          |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
}

//+------------------------------------------------------------------+
//| Expert tick                                                      |
//+------------------------------------------------------------------+
void OnTick()
{
}
//+------------------------------------------------------------------+