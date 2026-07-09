//+------------------------------------------------------------------+
//| BossR_Math.mqh                                                   |
//+------------------------------------------------------------------+
#ifndef __BOSSR_MATH_MQH__
#define __BOSSR_MATH_MQH__

#property strict

#define BOSSR_MATH_EPSILON 0.00000001

class C_BossR_Math
{
public:
   double WeightedAverage(const double valueA,
                          const double weightA,
                          const double valueB,
                          const double weightB,
                          const double fallback = 0.0) const
   {
      double totalWeight = weightA + weightB;

      if(IsZero(totalWeight))
         return fallback;

      return ((valueA * weightA) + (valueB * weightB)) / totalWeight;
   }

   double WeightedMeanArray(const double &values[],
                            const double &weights[],
                            const int count,
                            const double fallback = 0.0) const
   {
      if(count <= 0)
         return fallback;

      double weightedSum = 0.0;
      double totalWeight = 0.0;

      for(int i = 0; i < count; i++)
      {
         weightedSum += values[i] * weights[i];
         totalWeight += weights[i];
      }

      if(IsZero(totalWeight))
         return fallback;

      return weightedSum / totalWeight;
   }

   double RootMeanSquare(const double &values[],
                         const int count,
                         const double fallback = 0.0) const
   {
      if(count <= 0)
         return fallback;

      double sumSquares = 0.0;

      for(int i = 0; i < count; i++)
         sumSquares += values[i] * values[i];

      return MathSqrt(sumSquares / count);
   }

   double HarmonicMean(const double &values[],
                       const int count,
                       const double fallback = 0.0) const
   {
      if(count <= 0)
         return fallback;

      double denom = 0.0;

      for(int i = 0; i < count; i++)
      {
         if(IsZero(values[i]))
            return fallback;

         denom += 1.0 / values[i];
      }

      if(IsZero(denom))
         return fallback;

      return count / denom;
   }

   double GeometricMean(const double &values[],
                        const int count,
                        const double fallback = 0.0) const
   {
      if(count <= 0)
         return fallback;

      double logSum = 0.0;

      for(int i = 0; i < count; i++)
      {
         if(values[i] <= 0.0)
            return fallback;

         logSum += MathLog(values[i]);
      }

      return MathExp(logSum / count);
   }

     double CoefficientOfVariation(const double &values[],
                                 const int count,
                                 const double fallback = 0.0) const
   {
      if(count <= 1)
         return fallback;

      double mean = 0.0;

      if(!ArrayMeanD(values, mean))
         return fallback;

      if(IsZero(mean))
         return fallback;

      double sd = 0.0;

      if(!ArrayStdDevD(values, sd, false))
         return fallback;

      return sd / MathAbs(mean);
   }

   bool NormalizeWeights(const double &inputWeights[],
                         double &outputWeights[],
                         const int count)
   {
      if(count <= 0)
         return false;

      double total = 0.0;

      for(int i = 0; i < count; i++)
         total += inputWeights[i];

      if(IsZero(total))
         return false;

      ArrayResize(outputWeights, count);

      for(int j = 0; j < count; j++)
         outputWeights[j] = inputWeights[j] / total;

      return true;
   }
   //=========================================================
   // Floating Point Safety
   //=========================================================

   bool IsNaN(const double value) const
   {
      return (value != value);
   }

   bool IsFinite(const double value) const
   {
      if(IsNaN(value))
         return false;

      if(MathAbs(value) > DBL_MAX)
         return false;

      return true;
   }

   bool AlmostEqual(const double a,
                    const double b,
                    const double epsilon = 1e-8) const
   {
      return (MathAbs(a - b) <= epsilon);
   }

   bool Within(const double value,
               const double low,
               const double high,
               const bool inclusive = true) const
   {
      double lo = MathMin(low, high);
      double hi = MathMax(low, high);

      if(inclusive)
         return (value >= lo && value <= hi);

      return (value > lo && value < hi);
   }

   //=========================================================
   // Crossing Helpers
   //=========================================================

   bool CrossesAbove(const double previousA,
                     const double currentA,
                     const double previousB,
                     const double currentB) const
   {
      return (previousA <= previousB &&
              currentA  > currentB);
   }

   bool CrossesBelow(const double previousA,
                     const double currentA,
                     const double previousB,
                     const double currentB) const
   {
      return (previousA >= previousB &&
              currentA  < currentB);
   }

   int Crosses(const double previousA,
               const double currentA,
               const double previousB,
               const double currentB) const
   {
      if(CrossesAbove(previousA,currentA,previousB,currentB))
         return 1;

      if(CrossesBelow(previousA,currentA,previousB,currentB))
         return -1;

      return 0;
   }
   double SafeDivide(const double numerator, const double denominator, const double fallback = 0.0)
   {
      if(IsZero(denominator))
         return fallback;
      return numerator / denominator;
   }

   double Ratio(const double value, const double base, const double fallback = 0.0)
   {
      return SafeDivide(value, base, fallback);
   }

   int Sign(const double value)
   {
      if(IsGreater(value, 0.0)) return 1;
      if(IsLess(value, 0.0))    return -1;
      return 0;
   }

   int Direction(const double from_value, const double to_value)
   {
      return Sign(to_value - from_value);
   }

   double Distance(const double from_value, const double to_value)
   {
      return to_value - from_value;
   }

   double AbsoluteDistance(const double a, const double b)
   {
      return MathAbs(b - a);
   }

   double Midpoint(const double a, const double b)
   {
      return (a + b) * 0.5;
   }

   double Lerp(const double a, const double b, const double t)
   {
      return a + (b - a) * t;
   }

   double InverseLerp(const double a, const double b, const double value)
   {
      if(IsZero(b - a))
         return 0.0;
      return (value - a) / (b - a);
   }

   double MapRange(const double value,
                   const double in_min,
                   const double in_max,
                   const double out_min,
                   const double out_max)
   {
      double t = InverseLerp(in_min, in_max, value);
      return Lerp(out_min, out_max, t);
   }

   double Saturate(const double value)
   {
      return ClampD(value, 0.0, 1.0);
   }

   double Wrap(const double value, const double min_value, const double max_value)
   {
      double low  = MinD(min_value, max_value);
      double high = MaxD(min_value, max_value);
      double span = high - low;

      if(IsZero(span))
         return low;

      double x = value - low;
      double wrapped = x - MathFloor(x / span) * span;

      return low + wrapped;
   }

   int ModI(const int value, const int modulus)
   {
      if(modulus == 0)
         return 0;

      int m = MathAbs(modulus);
      int r = value % m;

      if(r < 0)
         r += m;

      return r;
   }

   double ModD(const double value, const double modulus)
   {
      if(IsZero(modulus))
         return 0.0;

      double m = MathAbs(modulus);
      return value - MathFloor(value / m) * m;
   }

   int WrapI(const int value, const int min_value, const int max_value)
   {
      int low  = MathMin(min_value, max_value);
      int high = MathMax(min_value, max_value);
      int span = high - low + 1;

      if(span <= 0)
         return low;

      return low + ModI(value - low, span);
   }
   double Epsilon() const { return BOSSR_MATH_EPSILON; }

   bool IsZero(const double value, const double epsilon = BOSSR_MATH_EPSILON) const
   {
      return MathAbs(value) <= epsilon;
   }

   bool IsEqual(const double a, const double b, const double epsilon = BOSSR_MATH_EPSILON) const
   {
      return MathAbs(a - b) <= epsilon;
   }

   bool IsGreater(const double a, const double b, const double epsilon = BOSSR_MATH_EPSILON) const
   {
      return (a - b) > epsilon;
   }

   bool IsLess(const double a, const double b, const double epsilon = BOSSR_MATH_EPSILON) const
   {
      return (b - a) > epsilon;
   }

   bool IsGreaterOrEqual(const double a, const double b, const double epsilon = BOSSR_MATH_EPSILON) const
   {
      return IsGreater(a, b, epsilon) || IsEqual(a, b, epsilon);
   }

   bool IsLessOrEqual(const double a, const double b, const double epsilon = BOSSR_MATH_EPSILON) const
   {
      return IsLess(a, b, epsilon) || IsEqual(a, b, epsilon);
   }

   double MinD(const double a, const double b) const { return (a < b ? a : b); }
   double MaxD(const double a, const double b) const { return (a > b ? a : b); }
   int MinI(const int a, const int b) const { return (a < b ? a : b); }
   int MaxI(const int a, const int b) const { return (a > b ? a : b); }

   double ClampD(const double value, const double min_value, const double max_value) const
   {
      double lo = MinD(min_value, max_value);
      double hi = MaxD(min_value, max_value);
      if(value < lo) return lo;
      if(value > hi) return hi;
      return value;
   }

   int ClampI(const int value, const int min_value, const int max_value) const
   {
      int lo = MinI(min_value, max_value);
      int hi = MaxI(min_value, max_value);
      if(value < lo) return lo;
      if(value > hi) return hi;
      return value;
   }

   bool IsInRangeD(const double value, const double min_value, const double max_value, const double epsilon = BOSSR_MATH_EPSILON) const
   {
      double lo = MinD(min_value, max_value);
      double hi = MaxD(min_value, max_value);
      return IsGreaterOrEqual(value, lo, epsilon) && IsLessOrEqual(value, hi, epsilon);
   }

   bool IsInRangeI(const int value, const int min_value, const int max_value) const
   {
      int lo = MinI(min_value, max_value);
      int hi = MaxI(min_value, max_value);
      return (value >= lo && value <= hi);
   }

   double Normalize01(const double value, const double min_value, const double max_value) const
   {
      double lo = MinD(min_value, max_value);
      double hi = MaxD(min_value, max_value);
      double range = hi - lo;
      if(IsZero(range)) return 0.0;
      return ClampD((value - lo) / range, 0.0, 1.0);
   }

   double Percent(const double part, const double total) const
   {
      if(IsZero(total)) return 0.0;
      return (part / total) * 100.0;
   }

   double RoundToDigits(const double value, const int digits) const
   {
      return NormalizeDouble(value, ClampI(digits, 0, 8));
   }

   double RoundToStep(const double value, const double step) const
   {
      if(IsZero(step)) return value;
      double safe_step = MathAbs(step);
      return MathRound(value / safe_step) * safe_step;
   }

   int ArrayCountD(const double &values[]) const
   {
      return ArraySize(values);
   }

   bool ArrayMinD(const double &values[], double &result) const
   {
      int count = ArraySize(values);
      if(count <= 0) { result = 0.0; return false; }

      result = values[0];
      for(int i = 1; i < count; i++)
         if(values[i] < result) result = values[i];

      return true;
   }

   bool ArrayMaxD(const double &values[], double &result) const
   {
      int count = ArraySize(values);
      if(count <= 0) { result = 0.0; return false; }

      result = values[0];
      for(int i = 1; i < count; i++)
         if(values[i] > result) result = values[i];

      return true;
   }

   bool ArraySumD(const double &values[], double &result) const
   {
      int count = ArraySize(values);
      if(count <= 0) { result = 0.0; return false; }

      result = 0.0;
      for(int i = 0; i < count; i++)
         result += values[i];

      return true;
   }

   bool ArrayMeanD(const double &values[], double &result) const
   {
      int count = ArraySize(values);
      if(count <= 0) { result = 0.0; return false; }

      double sum = 0.0;
      ArraySumD(values, sum);
      result = sum / count;
      return true;
   }

   bool ArrayRangeD(const double &values[], double &result) const
   {
      double mn = 0.0, mx = 0.0;
      if(!ArrayMinD(values, mn) || !ArrayMaxD(values, mx))
      {
         result = 0.0;
         return false;
      }

      result = mx - mn;
      return true;
   }

   int CountLessD(const double &values[], const double threshold, const double epsilon = BOSSR_MATH_EPSILON) const
   {
      int hits = 0;
      for(int i = 0; i < ArraySize(values); i++)
         if(IsLess(values[i], threshold, epsilon)) hits++;
      return hits;
   }

   int CountLessOrEqualD(const double &values[], const double threshold, const double epsilon = BOSSR_MATH_EPSILON) const
   {
      int hits = 0;
      for(int i = 0; i < ArraySize(values); i++)
         if(IsLessOrEqual(values[i], threshold, epsilon)) hits++;
      return hits;
   }

   int CountGreaterD(const double &values[], const double threshold, const double epsilon = BOSSR_MATH_EPSILON) const
   {
      int hits = 0;
      for(int i = 0; i < ArraySize(values); i++)
         if(IsGreater(values[i], threshold, epsilon)) hits++;
      return hits;
   }

   int CountGreaterOrEqualD(const double &values[], const double threshold, const double epsilon = BOSSR_MATH_EPSILON) const
   {
      int hits = 0;
      for(int i = 0; i < ArraySize(values); i++)
         if(IsGreaterOrEqual(values[i], threshold, epsilon)) hits++;
      return hits;
   }

   double PercentileRankD(const double &values[], const double value, const bool inclusive = true, const double epsilon = BOSSR_MATH_EPSILON) const
   {
      int count = ArraySize(values);
      if(count <= 0) return 0.0;

      int hits = (inclusive ? CountLessOrEqualD(values, value, epsilon) : CountLessD(values, value, epsilon));
      return Percent(hits, count);
   }

   bool NearestRankPercentileD(const double &values[], const double percentile, double &result) const
   {
      int count = ArraySize(values);
      if(count <= 0) { result = 0.0; return false; }

      double temp[];
      ArrayResize(temp, count);

      for(int i = 0; i < count; i++)
         temp[i] = values[i];

      ArraySort(temp, WHOLE_ARRAY, 0, MODE_ASCEND);

      double p = ClampD(percentile, 0.0, 100.0);

      if(IsZero(p))
      {
         result = temp[0];
         return true;
      }

      int rank = (int)MathCeil((p / 100.0) * count);
      rank = ClampI(rank, 1, count);

      result = temp[rank - 1];
      return true;
   }

   bool MedianD(const double &values[], double &result) const
   {
      int count = ArraySize(values);
      if(count <= 0) { result = 0.0; return false; }

      double temp[];
      ArrayResize(temp, count);

      for(int i = 0; i < count; i++)
         temp[i] = values[i];

      ArraySort(temp, WHOLE_ARRAY, 0, MODE_ASCEND);

      int mid = count / 2;

      if((count % 2) == 1)
         result = temp[mid];
      else
         result = (temp[mid - 1] + temp[mid]) / 2.0;

      return true;
   }

   bool ArrayVarianceD(const double &values[], double &result, const bool sample = false) const
   {
      int count = ArraySize(values);

      if(count <= 0)
      {
         result = 0.0;
         return false;
      }

      if(sample && count < 2)
      {
         result = 0.0;
         return false;
      }

      double mean = 0.0;
      ArrayMeanD(values, mean);

      double sum_sq = 0.0;

      for(int i = 0; i < count; i++)
      {
         double diff = values[i] - mean;
         sum_sq += diff * diff;
      }

      int divisor = (sample ? count - 1 : count);
      result = sum_sq / divisor;

      return true;
   }

   bool ArrayStdDevD(const double &values[], double &result, const bool sample = false) const
   {
      double variance = 0.0;

      if(!ArrayVarianceD(values, variance, sample))
      {
         result = 0.0;
         return false;
      }

      result = MathSqrt(variance);
      return true;
   }

   double ZScoreD(const double value, const double mean, const double std_dev) const
   {
      if(IsZero(std_dev))
         return 0.0;

      return (value - mean) / std_dev;
   }

   bool ArrayZScoreD(const double &values[], const int index, double &result, const bool sample = false) const
   {
      int count = ArraySize(values);

      if(index < 0 || index >= count)
      {
         result = 0.0;
         return false;
      }

      double mean = 0.0;
      double std_dev = 0.0;

      if(!ArrayMeanD(values, mean) || !ArrayStdDevD(values, std_dev, sample))
      {
         result = 0.0;
         return false;
      }

      result = ZScoreD(values[index], mean, std_dev);
      return true;
   }

   double ChangeD(const double current_value, const double previous_value) const
   {
      return current_value - previous_value;
   }

   double PercentChangeD(const double current_value, const double previous_value) const
   {
      if(IsZero(previous_value))
         return 0.0;

      return ((current_value - previous_value) / previous_value) * 100.0;
   }

   double AbsPercentChangeD(const double current_value, const double previous_value) const
   {
      return MathAbs(PercentChangeD(current_value, previous_value));
   }

   bool SlopeD(const double x1, const double y1, const double x2, const double y2, double &result) const
   {
      double dx = x2 - x1;

      if(IsZero(dx))
      {
         result = 0.0;
         return false;
      }

      result = (y2 - y1) / dx;
      return true;
   }

   bool LinearRegressionSlopeD(const double &values[], double &result) const
   {
      int count = ArraySize(values);

      if(count < 2)
      {
         result = 0.0;
         return false;
      }

      double sum_x = 0.0;
      double sum_y = 0.0;
      double sum_xy = 0.0;
      double sum_x2 = 0.0;

      for(int i = 0; i < count; i++)
      {
         double x = i;
         double y = values[i];

         sum_x  += x;
         sum_y  += y;
         sum_xy += x * y;
         sum_x2 += x * x;
      }

      double denominator = (count * sum_x2) - (sum_x * sum_x);

      if(IsZero(denominator))
      {
         result = 0.0;
         return false;
      }

      result = ((count * sum_xy) - (sum_x * sum_y)) / denominator;
      return true;
   }
};


//=========================================================
// BossR_Math Block 5B Compatibility Wrappers
// These preserve verifier calls that use free-function names.
//=========================================================

double BossR_Math_GetArrayMean(const double &values[], const int count, const double fallback = 0.0)
{
   if(count <= 0)
      return fallback;

   double sum = 0.0;
   for(int i = 0; i < count; i++)
      sum += values[i];

   return sum / count;
}

double Mean(const double &values[], const int count, const double fallback = 0.0)
{
   return BossR_Math_GetArrayMean(values, count, fallback);
}

double StandardDeviation(const double &values[], const int count, const bool sample = false, const double fallback = 0.0)
{
   if(count <= 0)
      return fallback;

   if(sample && count < 2)
      return fallback;

   double mean = BossR_Math_GetArrayMean(values, count, fallback);
   double sum_sq = 0.0;

   for(int i = 0; i < count; i++)
   {
      double diff = values[i] - mean;
      sum_sq += diff * diff;
   }

   int divisor = (sample ? count - 1 : count);
   if(divisor <= 0)
      return fallback;

   return MathSqrt(sum_sq / divisor);
}

double WeightedAverage(const double valueA,
                       const double weightA,
                       const double valueB,
                       const double weightB,
                       const double fallback = 0.0)
{
   C_BossR_Math math;
   return math.WeightedAverage(valueA, weightA, valueB, weightB, fallback);
}

double WeightedMeanArray(const double &values[],
                         const double &weights[],
                         const int count,
                         const double fallback = 0.0)
{
   C_BossR_Math math;
   return math.WeightedMeanArray(values, weights, count, fallback);
}

double RootMeanSquare(const double &values[],
                      const int count,
                      const double fallback = 0.0)
{
   C_BossR_Math math;
   return math.RootMeanSquare(values, count, fallback);
}

double HarmonicMean(const double &values[],
                    const int count,
                    const double fallback = 0.0)
{
   C_BossR_Math math;
   return math.HarmonicMean(values, count, fallback);
}

double GeometricMean(const double &values[],
                     const int count,
                     const double fallback = 0.0)
{
   C_BossR_Math math;
   return math.GeometricMean(values, count, fallback);
}

double CoefficientOfVariation(const double &values[],
                              const int count,
                              const double fallback = 0.0)
{
   if(count <= 1)
      return fallback;

   double mean = Mean(values, count, fallback);
   if(MathAbs(mean) <= BOSSR_MATH_EPSILON)
      return fallback;

   double sd = StandardDeviation(values, count, false, fallback);
   return sd / MathAbs(mean);
}

bool NormalizeWeights(const double &inputWeights[],
                      double &outputWeights[],
                      const int count)
{
   C_BossR_Math math;
   return math.NormalizeWeights(inputWeights, outputWeights, count);
}


#endif