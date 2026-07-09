//+------------------------------------------------------------------+
//| BossR_Math_Verify.mq4                                            |
//+------------------------------------------------------------------+
#property strict

#include <BossR\BossR_Math.mqh>

C_BossR_Math BossMath;

int g_pass = 0;
int g_fail = 0;

void Pass(string test_name){ g_pass++; Print("PASS: ", test_name); }
void Fail(string test_name){ g_fail++; Print("FAIL: ", test_name); }

void ExpectInt(string test_name, int actual, int expected)
{
   if(actual == expected) Pass(test_name);
   else
   {
      Fail(test_name);
      Print("   actual=", actual, " expected=", expected);
   }
}

void ExpectDouble(string test_name, double actual, double expected, double epsilon = 0.00000001)
{
   if(MathAbs(actual - expected) <= epsilon) Pass(test_name);
   else
   {
      Fail(test_name);
      Print("   actual=", DoubleToString(actual, 10),
            " expected=", DoubleToString(expected, 10));
   }
}

int OnInit()
{
   Print("=== BossR_Math Verification Started ===");

   //=========================================================
   // Block 4
   //=========================================================

   ExpectDouble("SafeDivide normal", BossMath.SafeDivide(10.0, 2.0), 5.0);
   ExpectDouble("SafeDivide zero fallback default", BossMath.SafeDivide(10.0, 0.0), 0.0);
   ExpectDouble("SafeDivide zero custom fallback", BossMath.SafeDivide(10.0, 0.0, -99.0), -99.0);

   ExpectDouble("Ratio normal", BossMath.Ratio(5.0, 10.0), 0.5);
   ExpectDouble("Ratio zero fallback", BossMath.Ratio(5.0, 0.0, 7.0), 7.0);

   ExpectInt("Sign positive", BossMath.Sign(5.0), 1);
   ExpectInt("Sign negative", BossMath.Sign(-5.0), -1);
   ExpectInt("Sign zero", BossMath.Sign(0.0), 0);

   ExpectInt("Direction up", BossMath.Direction(1.0, 2.0), 1);
   ExpectInt("Direction down", BossMath.Direction(2.0, 1.0), -1);
   ExpectInt("Direction flat", BossMath.Direction(2.0, 2.0), 0);

   ExpectDouble("Distance positive", BossMath.Distance(2.0, 5.0), 3.0);
   ExpectDouble("Distance negative", BossMath.Distance(5.0, 2.0), -3.0);
   ExpectDouble("AbsoluteDistance", BossMath.AbsoluteDistance(5.0, 2.0), 3.0);

   ExpectDouble("Midpoint normal", BossMath.Midpoint(2.0, 6.0), 4.0);
   ExpectDouble("Lerp half", BossMath.Lerp(10.0, 20.0, 0.5), 15.0);

   ExpectDouble("InverseLerp half", BossMath.InverseLerp(10.0, 20.0, 15.0), 0.5);
   ExpectDouble("MapRange normal", BossMath.MapRange(50.0, 0.0, 100.0, 0.0, 10.0), 5.0);

   ExpectDouble("Saturate below", BossMath.Saturate(-0.5), 0.0);
   ExpectDouble("Saturate middle", BossMath.Saturate(0.5), 0.5);
   ExpectDouble("Saturate above", BossMath.Saturate(1.5), 1.0);

   ExpectDouble("Wrap inside", BossMath.Wrap(5.0, 0.0, 10.0), 5.0);
   ExpectDouble("Wrap above", BossMath.Wrap(12.0, 0.0, 10.0), 2.0);
   ExpectDouble("Wrap below", BossMath.Wrap(-2.0, 0.0, 10.0), 8.0);
   ExpectDouble("Wrap zero range", BossMath.Wrap(12.0, 5.0, 5.0), 5.0);

   ExpectInt("ModI positive", BossMath.ModI(7, 5), 2);
   ExpectInt("ModI negative", BossMath.ModI(-1, 5), 4);
   ExpectInt("ModI zero modulus", BossMath.ModI(7, 0), 0);

   ExpectDouble("ModD positive", BossMath.ModD(7.5, 5.0), 2.5);
   ExpectDouble("ModD negative", BossMath.ModD(-1.0, 5.0), 4.0);
   ExpectDouble("ModD zero modulus", BossMath.ModD(7.5, 0.0), 0.0);

   ExpectInt("WrapI inside", BossMath.WrapI(3, 1, 5), 3);
   ExpectInt("WrapI above", BossMath.WrapI(6, 1, 5), 1);
   ExpectInt("WrapI below", BossMath.WrapI(0, 1, 5), 5);

   //=========================================================
   // Block 5A
   //=========================================================

   ExpectInt("IsFinite normal", BossMath.IsFinite(123.45), true);
   ExpectInt("IsFinite negative", BossMath.IsFinite(-987.6), true);
   ExpectInt("IsNaN normal", BossMath.IsNaN(1.0), false);

   ExpectInt("AlmostEqual equal", BossMath.AlmostEqual(5.0, 5.0), true);
   ExpectInt("AlmostEqual epsilon", BossMath.AlmostEqual(5.0, 5.000000001), true);
   ExpectInt("AlmostEqual different", BossMath.AlmostEqual(5.0, 5.1), false);

   ExpectInt("Within inclusive", BossMath.Within(5, 0, 10), true);
   ExpectInt("Within lower", BossMath.Within(0, 0, 10), true);
   ExpectInt("Within upper", BossMath.Within(10, 0, 10), true);
   ExpectInt("Within exclusive", BossMath.Within(0, 0, 10, false), false);
   ExpectInt("Within outside", BossMath.Within(15, 0, 10), false);
   ExpectInt("Within reversed", BossMath.Within(5, 10, 0), true);

   ExpectInt("CrossAbove", BossMath.CrossesAbove(1, 3, 2, 2), true);
   ExpectInt("CrossAbove false", BossMath.CrossesAbove(3, 4, 2, 2), false);
   ExpectInt("CrossBelow", BossMath.CrossesBelow(3, 1, 2, 2), true);
   ExpectInt("CrossBelow false", BossMath.CrossesBelow(1, 0, 2, 2), false);

   ExpectInt("Crosses up", BossMath.Crosses(1, 3, 2, 2), 1);
   ExpectInt("Crosses down", BossMath.Crosses(3, 1, 2, 2), -1);
   ExpectInt("Crosses none", BossMath.Crosses(1, 1.5, 2, 2), 0);

   //=========================================================
   // Block 5B
   //=========================================================

   double vA[3];
   vA[0] = 2.0;
   vA[1] = 4.0;
   vA[2] = 6.0;

   double wA[3];
   wA[0] = 1.0;
   wA[1] = 1.0;
   wA[2] = 2.0;

   double zeroW[3];
   zeroW[0] = 0.0;
   zeroW[1] = 0.0;
   zeroW[2] = 0.0;

   ExpectDouble("WeightedAverage equal weights",
                BossMath.WeightedAverage(10.0, 1.0, 20.0, 1.0),
                15.0);

   ExpectDouble("WeightedAverage weighted",
                BossMath.WeightedAverage(10.0, 1.0, 20.0, 3.0),
                17.5);

   ExpectDouble("WeightedAverage zero fallback",
                BossMath.WeightedAverage(10.0, 0.0, 20.0, 0.0, -1.0),
                -1.0);

   ExpectDouble("WeightedMeanArray normal",
                BossMath.WeightedMeanArray(vA, wA, 3),
                4.5);

   ExpectDouble("WeightedMeanArray zero fallback",
                BossMath.WeightedMeanArray(vA, zeroW, 3, -5.0),
                -5.0);

   ExpectDouble("RootMeanSquare normal",
                BossMath.RootMeanSquare(vA, 3),
                MathSqrt((4.0 + 16.0 + 36.0) / 3.0));

   ExpectDouble("RootMeanSquare empty fallback",
                BossMath.RootMeanSquare(vA, 0, -9.0),
                -9.0);

   ExpectDouble("HarmonicMean normal",
                BossMath.HarmonicMean(vA, 3),
                3.2727272727,
                0.0000001);

   double hasZero[3];
   hasZero[0] = 2.0;
   hasZero[1] = 0.0;
   hasZero[2] = 6.0;

   ExpectDouble("HarmonicMean zero fallback",
                BossMath.HarmonicMean(hasZero, 3, -3.0),
                -3.0);

   double geo[3];
   geo[0] = 2.0;
   geo[1] = 8.0;
   geo[2] = 4.0;

   ExpectDouble("GeometricMean normal",
                BossMath.GeometricMean(geo, 3),
                4.0,
                0.0000001);

   double geoBad[3];
   geoBad[0] = 2.0;
   geoBad[1] = -8.0;
   geoBad[2] = 4.0;

   ExpectDouble("GeometricMean bad fallback",
                BossMath.GeometricMean(geoBad, 3, -8.0),
                -8.0);

   ExpectDouble("CoefficientOfVariation normal",
                BossMath.CoefficientOfVariation(vA, 3),
                MathSqrt(((2.0 - 4.0) * (2.0 - 4.0) +
                          (4.0 - 4.0) * (4.0 - 4.0) +
                          (6.0 - 4.0) * (6.0 - 4.0)) / 3.0) / 4.0,
                0.0000001);

   double cvZeroMean[2];
   cvZeroMean[0] = -1.0;
   cvZeroMean[1] = 1.0;

   ExpectDouble("CoefficientOfVariation zero mean fallback",
                BossMath.CoefficientOfVariation(cvZeroMean, 2, -2.0),
                -2.0);

   double normalized[];
   bool normOk = BossMath.NormalizeWeights(wA, normalized, 3);

   ExpectInt("NormalizeWeights returns true", normOk, true);
   ExpectDouble("NormalizeWeights 0", normalized[0], 0.25);
   ExpectDouble("NormalizeWeights 1", normalized[1], 0.25);
   ExpectDouble("NormalizeWeights 2", normalized[2], 0.50);

   double normalizedBad[];
   bool normBad = BossMath.NormalizeWeights(zeroW, normalizedBad, 3);

   ExpectInt("NormalizeWeights zero returns false", normBad, false);

   Print("=== BossR_Math Verification Complete ===");
   Print("PASS ", g_pass, " / FAIL ", g_fail);

   return INIT_SUCCEEDED;
}

void OnDeinit(const int reason){}
void OnTick(){}