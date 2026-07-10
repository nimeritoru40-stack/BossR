//+------------------------------------------------------------------+
//| BossR_Price.mqh                                                  |
//| BossR Framework - Price utilities                                |
//| Block 6                                                          |
//| MT4 only                                                         |
//+------------------------------------------------------------------+
#ifndef __BOSSR_PRICE_MQH__
#define __BOSSR_PRICE_MQH__

//+------------------------------------------------------------------+
//| C_BossR_Price                                                    |
//+------------------------------------------------------------------+
class C_BossR_Price
{
private:
   double ComparisonEpsilon(const double value_a,
                            const double value_b = 0.0,
                            const double value_c = 0.0)
   {
      double scale = MathMax(1.0, MathAbs(value_a));
      scale = MathMax(scale, MathAbs(value_b));
      scale = MathMax(scale, MathAbs(value_c));

      return(scale * 0.000000000001);
   }

   string ResolveSymbol(const string symbol_name)
   {
      if(symbol_name == "")
         return(Symbol());

      return(symbol_name);
   }

public:
   // ---------------------------------------------------------------
   // Symbol properties
   // ---------------------------------------------------------------
   int DigitsCount(const string symbol_name = "")
   {
      string symbol_value = ResolveSymbol(symbol_name);
      return((int)MarketInfo(symbol_value, MODE_DIGITS));
   }

   double PointSize(const string symbol_name = "")
   {
      string symbol_value = ResolveSymbol(symbol_name);
      return(MarketInfo(symbol_value, MODE_POINT));
   }

   double TickSize(const string symbol_name = "")
   {
      string symbol_value = ResolveSymbol(symbol_name);
      return(MarketInfo(symbol_value, MODE_TICKSIZE));
   }

   double TickValue(const string symbol_name = "")
   {
      string symbol_value = ResolveSymbol(symbol_name);
      return(MarketInfo(symbol_value, MODE_TICKVALUE));
   }

   double PipSize(const string symbol_name = "")
   {
      string symbol_value = ResolveSymbol(symbol_name);

      int digits_value = DigitsCount(symbol_value);
      double point_value = PointSize(symbol_value);

      if(point_value <= 0.0)
         return(0.0);

      if(digits_value == 3 || digits_value == 5)
         return(point_value * 10.0);

      return(point_value);
   }

   int PipFactor(const string symbol_name = "")
   {
      string symbol_value = ResolveSymbol(symbol_name);
      int digits_value = DigitsCount(symbol_value);

      if(digits_value == 3 || digits_value == 5)
         return(10);

      return(1);
   }

   // ---------------------------------------------------------------
   // Live prices
   // ---------------------------------------------------------------
   double BidPrice(const string symbol_name = "")
   {
      string symbol_value = ResolveSymbol(symbol_name);
      return(MarketInfo(symbol_value, MODE_BID));
   }

   double AskPrice(const string symbol_name = "")
   {
      string symbol_value = ResolveSymbol(symbol_name);
      return(MarketInfo(symbol_value, MODE_ASK));
   }

   double MidPrice(const string symbol_name = "")
   {
      string symbol_value = ResolveSymbol(symbol_name);

      double bid_value = BidPrice(symbol_value);
      double ask_value = AskPrice(symbol_value);

      if(bid_value <= 0.0 || ask_value <= 0.0)
         return(0.0);

      return((bid_value + ask_value) * 0.5);
   }

   double SpreadPrice(const string symbol_name = "")
   {
      string symbol_value = ResolveSymbol(symbol_name);

      double bid_value = BidPrice(symbol_value);
      double ask_value = AskPrice(symbol_value);

      if(bid_value <= 0.0 || ask_value <= 0.0)
         return(0.0);

      if(ask_value < bid_value)
         return(0.0);

      return(ask_value - bid_value);
   }

   double SpreadPoints(const string symbol_name = "")
   {
      string symbol_value = ResolveSymbol(symbol_name);

      double point_value = PointSize(symbol_value);
      double spread_value = SpreadPrice(symbol_value);

      if(point_value <= 0.0)
         return(0.0);

      return(spread_value / point_value);
   }

   double SpreadPips(const string symbol_name = "")
   {
      string symbol_value = ResolveSymbol(symbol_name);

      double pip_value = PipSize(symbol_value);
      double spread_value = SpreadPrice(symbol_value);

      if(pip_value <= 0.0)
         return(0.0);

      return(spread_value / pip_value);
   }

   // ---------------------------------------------------------------
   // Normalization
   // ---------------------------------------------------------------
   double NormalizePrice(const double price,
                         const string symbol_name = "")
   {
      string symbol_value = ResolveSymbol(symbol_name);
      int digits_value = DigitsCount(symbol_value);

      return(NormalizeDouble(price, digits_value));
   }

   double NormalizePriceByDigits(const double price,
                                 const int digits_value)
   {
      int safe_digits = digits_value;

      if(safe_digits < 0)
         safe_digits = 0;

      if(safe_digits > 8)
         safe_digits = 8;

      return(NormalizeDouble(price, safe_digits));
   }

   // ---------------------------------------------------------------
   // Point conversions
   // ---------------------------------------------------------------
   double PointsToPrice(const double points,
                        const string symbol_name = "")
   {
      string symbol_value = ResolveSymbol(symbol_name);
      double point_value = PointSize(symbol_value);

      if(point_value <= 0.0)
         return(0.0);

      return(points * point_value);
   }

   double PriceToPoints(const double price_distance,
                        const string symbol_name = "")
   {
      string symbol_value = ResolveSymbol(symbol_name);
      double point_value = PointSize(symbol_value);

      if(point_value <= 0.0)
         return(0.0);

      return(price_distance / point_value);
   }

   // ---------------------------------------------------------------
   // Pip conversions
   // ---------------------------------------------------------------
   double PipsToPrice(const double pips,
                      const string symbol_name = "")
   {
      string symbol_value = ResolveSymbol(symbol_name);
      double pip_value = PipSize(symbol_value);

      if(pip_value <= 0.0)
         return(0.0);

      return(pips * pip_value);
   }

   double PriceToPips(const double price_distance,
                      const string symbol_name = "")
   {
      string symbol_value = ResolveSymbol(symbol_name);
      double pip_value = PipSize(symbol_value);

      if(pip_value <= 0.0)
         return(0.0);

      return(price_distance / pip_value);
   }

   double PointsToPips(const double points,
                       const string symbol_name = "")
   {
      string symbol_value = ResolveSymbol(symbol_name);
      int factor = PipFactor(symbol_value);

      if(factor <= 0)
         return(0.0);

      return(points / factor);
   }

   double PipsToPoints(const double pips,
                       const string symbol_name = "")
   {
      string symbol_value = ResolveSymbol(symbol_name);
      int factor = PipFactor(symbol_value);

      return(pips * factor);
   }

   // ---------------------------------------------------------------
   // Deterministic conversions
   // ---------------------------------------------------------------
   double PipSizeFromProperties(const int digits_value,
                                const double point_value)
   {
      if(point_value <= 0.0)
         return(0.0);

      if(digits_value == 3 || digits_value == 5)
         return(point_value * 10.0);

      return(point_value);
   }

   int PipFactorFromDigits(const int digits_value)
   {
      if(digits_value == 3 || digits_value == 5)
         return(10);

      return(1);
   }

   double PointsToPriceByPoint(const double points,
                               const double point_value)
   {
      if(point_value <= 0.0)
         return(0.0);

      return(points * point_value);
   }

   double PriceToPointsByPoint(const double price_distance,
                               const double point_value)
   {
      if(point_value <= 0.0)
         return(0.0);

      return(price_distance / point_value);
   }

   double PipsToPriceByProperties(const double pips,
                                  const int digits_value,
                                  const double point_value)
   {
      double pip_value = PipSizeFromProperties(digits_value,
                                               point_value);

      if(pip_value <= 0.0)
         return(0.0);

      return(pips * pip_value);
   }

   double PriceToPipsByProperties(const double price_distance,
                                  const int digits_value,
                                  const double point_value)
   {
      double pip_value = PipSizeFromProperties(digits_value,
                                               point_value);

      if(pip_value <= 0.0)
         return(0.0);

      return(price_distance / pip_value);
   }

   double PointsToPipsByDigits(const double points,
                               const int digits_value)
   {
      int factor = PipFactorFromDigits(digits_value);

      if(factor <= 0)
         return(0.0);

      return(points / factor);
   }

   double PipsToPointsByDigits(const double pips,
                               const int digits_value)
   {
      int factor = PipFactorFromDigits(digits_value);
      return(pips * factor);
   }

   // ---------------------------------------------------------------
   // Price relationships
   // ---------------------------------------------------------------
   double Distance(const double price_a,
                   const double price_b)
   {
      return(MathAbs(price_a - price_b));
   }

   double SignedDistance(const double from_price,
                         const double to_price)
   {
      return(to_price - from_price);
   }

   double Midpoint(const double price_a,
                   const double price_b)
   {
      return((price_a + price_b) * 0.5);
   }

   double Higher(const double price_a,
                 const double price_b)
   {
      return(MathMax(price_a, price_b));
   }

   double Lower(const double price_a,
                const double price_b)
   {
      return(MathMin(price_a, price_b));
   }

   bool IsPositivePrice(const double price)
   {
      return(price > 0.0);
   }

   bool IsOrdered(const double low_price,
                  const double high_price)
   {
      return(low_price <= high_price);
   }

   bool IsInsideInclusive(const double price,
                          const double low_price,
                          const double high_price)
   {
      if(low_price > high_price)
         return(false);

      return(price >= low_price && price <= high_price);
   }

   bool IsInsideExclusive(const double price,
                          const double low_price,
                          const double high_price)
   {
      if(low_price >= high_price)
         return(false);

      return(price > low_price && price < high_price);
   }

   bool IsAbove(const double price,
                const double reference_price)
   {
      return(price > reference_price);
   }

   bool IsBelow(const double price,
                const double reference_price)
   {
      return(price < reference_price);
   }

   // ---------------------------------------------------------------
   // Block 2 - tolerance comparisons
   // ---------------------------------------------------------------
   bool Equals(const double price_a,
               const double price_b,
               const double tolerance)
   {
      double safe_tolerance = MathAbs(tolerance);
      double epsilon = ComparisonEpsilon(price_a,
                                         price_b,
                                         safe_tolerance);

      return(MathAbs(price_a - price_b) <=
             safe_tolerance + epsilon);
   }

   bool EqualsPoints(const double price_a,
                     const double price_b,
                     const double tolerance_points,
                     const string symbol_name = "")
   {
      double tolerance_price =
         MathAbs(PointsToPrice(tolerance_points, symbol_name));

      return(Equals(price_a, price_b, tolerance_price));
   }

   bool EqualsPips(const double price_a,
                   const double price_b,
                   const double tolerance_pips,
                   const string symbol_name = "")
   {
      double tolerance_price =
         MathAbs(PipsToPrice(tolerance_pips, symbol_name));

      return(Equals(price_a, price_b, tolerance_price));
   }

   bool IsAboveBy(const double price,
                  const double reference_price,
                  const double minimum_distance)
   {
      double safe_distance = MathAbs(minimum_distance);
      double boundary = reference_price + safe_distance;
      double epsilon = ComparisonEpsilon(price,
                                         reference_price,
                                         boundary);

      return(price > boundary + epsilon);
   }

   bool IsBelowBy(const double price,
                  const double reference_price,
                  const double minimum_distance)
   {
      double safe_distance = MathAbs(minimum_distance);
      double boundary = reference_price - safe_distance;
      double epsilon = ComparisonEpsilon(price,
                                         reference_price,
                                         boundary);

      return(price < boundary - epsilon);
   }

   bool IsAboveByPoints(const double price,
                        const double reference_price,
                        const double minimum_points,
                        const string symbol_name = "")
   {
      double minimum_price =
         MathAbs(PointsToPrice(minimum_points, symbol_name));

      return(IsAboveBy(price, reference_price, minimum_price));
   }

   bool IsBelowByPoints(const double price,
                        const double reference_price,
                        const double minimum_points,
                        const string symbol_name = "")
   {
      double minimum_price =
         MathAbs(PointsToPrice(minimum_points, symbol_name));

      return(IsBelowBy(price, reference_price, minimum_price));
   }

   bool IsAboveByPips(const double price,
                      const double reference_price,
                      const double minimum_pips,
                      const string symbol_name = "")
   {
      double minimum_price =
         MathAbs(PipsToPrice(minimum_pips, symbol_name));

      return(IsAboveBy(price, reference_price, minimum_price));
   }

   bool IsBelowByPips(const double price,
                      const double reference_price,
                      const double minimum_pips,
                      const string symbol_name = "")
   {
      double minimum_price =
         MathAbs(PipsToPrice(minimum_pips, symbol_name));

      return(IsBelowBy(price, reference_price, minimum_price));
   }

   // ---------------------------------------------------------------
   // Block 2 - clamping
   // ---------------------------------------------------------------
   double Clamp(const double price,
                const double low_price,
                const double high_price)
   {
      if(low_price > high_price)
         return(price);

      if(price < low_price)
         return(low_price);

      if(price > high_price)
         return(high_price);

      return(price);
   }

   double ClampOrdered(const double price,
                       const double price_a,
                       const double price_b)
   {
      double low_price = MathMin(price_a, price_b);
      double high_price = MathMax(price_a, price_b);

      return(Clamp(price, low_price, high_price));
   }

   // ---------------------------------------------------------------
   // Block 2 - step alignment
   // ---------------------------------------------------------------
   double SnapToStep(const double price,
                     const double step_size)
   {
      double safe_step = MathAbs(step_size);

      if(safe_step <= 0.0)
         return(price);

      return(MathRound(price / safe_step) * safe_step);
   }

   double SnapDownToStep(const double price,
                         const double step_size)
   {
      double safe_step = MathAbs(step_size);

      if(safe_step <= 0.0)
         return(price);

      double quotient = price / safe_step;
      double epsilon = ComparisonEpsilon(quotient);

      return(MathFloor(quotient + epsilon) * safe_step);
   }

   double SnapUpToStep(const double price,
                       const double step_size)
   {
      double safe_step = MathAbs(step_size);

      if(safe_step <= 0.0)
         return(price);

      double quotient = price / safe_step;
      double epsilon = ComparisonEpsilon(quotient);

      return(MathCeil(quotient - epsilon) * safe_step);
   }

   double SnapToPoint(const double price,
                      const string symbol_name = "")
   {
      string symbol_value = ResolveSymbol(symbol_name);
      double point_value = PointSize(symbol_value);

      if(point_value <= 0.0)
         return(NormalizePrice(price, symbol_value));

      return(NormalizePrice(SnapToStep(price, point_value),
                            symbol_value));
   }

   double SnapToPip(const double price,
                    const string symbol_name = "")
   {
      string symbol_value = ResolveSymbol(symbol_name);
      double pip_value = PipSize(symbol_value);

      if(pip_value <= 0.0)
         return(NormalizePrice(price, symbol_value));

      return(NormalizePrice(SnapToStep(price, pip_value),
                            symbol_value));
   }

   // ---------------------------------------------------------------
   // Block 2 - price movement
   // ---------------------------------------------------------------
   double AddPoints(const double price,
                    const double points,
                    const string symbol_name = "")
   {
      return(price + PointsToPrice(points, symbol_name));
   }

   double SubtractPoints(const double price,
                         const double points,
                         const string symbol_name = "")
   {
      return(price - PointsToPrice(points, symbol_name));
   }

   double AddPips(const double price,
                  const double pips,
                  const string symbol_name = "")
   {
      return(price + PipsToPrice(pips, symbol_name));
   }

   double SubtractPips(const double price,
                       const double pips,
                       const string symbol_name = "")
   {
      return(price - PipsToPrice(pips, symbol_name));
   }

   double MovePrice(const double price,
                    const double distance,
                    const int direction)
   {
      double safe_distance = MathAbs(distance);

      if(direction > 0)
         return(price + safe_distance);

      if(direction < 0)
         return(price - safe_distance);

      return(price);
   }

   double MovePricePoints(const double price,
                          const double points,
                          const int direction,
                          const string symbol_name = "")
   {
      double distance =
         MathAbs(PointsToPrice(points, symbol_name));

      return(MovePrice(price, distance, direction));
   }

   double MovePricePips(const double price,
                        const double pips,
                        const int direction,
                        const string symbol_name = "")
   {
      double distance =
         MathAbs(PipsToPrice(pips, symbol_name));

      return(MovePrice(price, distance, direction));
   }

   // ---------------------------------------------------------------
   // Block 2 - direction and crossings
   // ---------------------------------------------------------------
   int Direction(const double from_price,
                 const double to_price,
                 const double tolerance = 0.0)
   {
      double safe_tolerance = MathAbs(tolerance);
      double difference = to_price - from_price;

      if(difference > safe_tolerance)
         return(1);

      if(difference < -safe_tolerance)
         return(-1);

      return(0);
   }

   bool CrossedAbove(const double previous_price,
                     const double current_price,
                     const double level,
                     const double tolerance = 0.0)
   {
      double safe_tolerance = MathAbs(tolerance);

      bool was_below_or_equal =
         previous_price <= level + safe_tolerance;

      bool is_above =
         current_price > level + safe_tolerance;

      return(was_below_or_equal && is_above);
   }

   bool CrossedBelow(const double previous_price,
                     const double current_price,
                     const double level,
                     const double tolerance = 0.0)
   {
      double safe_tolerance = MathAbs(tolerance);

      bool was_above_or_equal =
         previous_price >= level - safe_tolerance;

      bool is_below =
         current_price < level - safe_tolerance;

      return(was_above_or_equal && is_below);
   }

   // ---------------------------------------------------------------
   // Block 3 - range geometry and relative position
   // ---------------------------------------------------------------
   double RangeSize(const double price_a,
                    const double price_b)
   {
      return(MathAbs(price_b - price_a));
   }

   double RangeMidpoint(const double price_a,
                        const double price_b)
   {
      return((price_a + price_b) * 0.5);
   }

   double PositionInRange(const double price,
                          const double price_a,
                          const double price_b)
   {
      double low_price = MathMin(price_a, price_b);
      double high_price = MathMax(price_a, price_b);
      double range_size = high_price - low_price;

      if(range_size <= 0.0)
         return(0.0);

      return((price - low_price) / range_size);
   }

   double PositionInRangeClamped(const double price,
                                 const double price_a,
                                 const double price_b)
   {
      double position = PositionInRange(price, price_a, price_b);
      return(MathMax(0.0, MathMin(1.0, position)));
   }

   double PriceAtFraction(const double price_a,
                          const double price_b,
                          const double fraction)
   {
      double low_price = MathMin(price_a, price_b);
      double high_price = MathMax(price_a, price_b);

      return(low_price + (high_price - low_price) * fraction);
   }

   double PriceAtFractionClamped(const double price_a,
                                 const double price_b,
                                 const double fraction)
   {
      double safe_fraction = MathMax(0.0, MathMin(1.0, fraction));
      return(PriceAtFraction(price_a, price_b, safe_fraction));
   }

   double DistanceToLowerEdge(const double price,
                              const double price_a,
                              const double price_b)
   {
      double low_price = MathMin(price_a, price_b);
      return(MathAbs(price - low_price));
   }

   double DistanceToUpperEdge(const double price,
                              const double price_a,
                              const double price_b)
   {
      double high_price = MathMax(price_a, price_b);
      return(MathAbs(high_price - price));
   }

   double DistanceToNearestEdge(const double price,
                                const double price_a,
                                const double price_b)
   {
      return(MathMin(DistanceToLowerEdge(price, price_a, price_b),
                     DistanceToUpperEdge(price, price_a, price_b)));
   }

   int NearestEdge(const double price,
                   const double price_a,
                   const double price_b)
   {
      double lower_distance = DistanceToLowerEdge(price, price_a, price_b);
      double upper_distance = DistanceToUpperEdge(price, price_a, price_b);

      if(lower_distance < upper_distance)
         return(-1);

      if(upper_distance < lower_distance)
         return(1);

      return(0);
   }

   bool IsInLowerFraction(const double price,
                          const double price_a,
                          const double price_b,
                          const double fraction)
   {
      double safe_fraction = MathMax(0.0, MathMin(1.0, fraction));
      double low_price = MathMin(price_a, price_b);
      double boundary = PriceAtFraction(price_a, price_b, safe_fraction);

      return(price >= low_price && price <= boundary);
   }

   bool IsInUpperFraction(const double price,
                          const double price_a,
                          const double price_b,
                          const double fraction)
   {
      double safe_fraction = MathMax(0.0, MathMin(1.0, fraction));
      double high_price = MathMax(price_a, price_b);
      double boundary = PriceAtFraction(price_a,
                                        price_b,
                                        1.0 - safe_fraction);

      return(price >= boundary && price <= high_price);
   }

   double PercentChange(const double from_price,
                        const double to_price)
   {
      if(from_price == 0.0)
         return(0.0);

      return(((to_price - from_price) / MathAbs(from_price)) * 100.0);
   }

   double ApplyPercentChange(const double price,
                             const double percent_change)
   {
      return(price + MathAbs(price) * (percent_change / 100.0));
   }


   // ---------------------------------------------------------------
   // Block 4 - tick value, monetary value and risk geometry
   // ---------------------------------------------------------------
   double TickValueForPriceDistanceByProperties(const double price_distance,
                                                 const double tick_size,
                                                 const double tick_value,
                                                 const double lots = 1.0)
   {
      if(tick_size <= 0.0 || tick_value <= 0.0 || lots <= 0.0)
         return(0.0);

      return((MathAbs(price_distance) / tick_size) * tick_value * lots);
   }

   double PointValueByProperties(const double point_size,
                                 const double tick_size,
                                 const double tick_value,
                                 const double lots = 1.0)
   {
      if(point_size <= 0.0 || tick_size <= 0.0 ||
         tick_value <= 0.0 || lots <= 0.0)
         return(0.0);

      return((point_size / tick_size) * tick_value * lots);
   }

   double PipValueByProperties(const int digits_value,
                               const double point_size,
                               const double tick_size,
                               const double tick_value,
                               const double lots = 1.0)
   {
      double pip_size = PipSizeFromProperties(digits_value, point_size);
      return(PointValueByProperties(pip_size,
                                    tick_size,
                                    tick_value,
                                    lots));
   }

   double RiskMoneyByDistance(const double entry_price,
                              const double stop_price,
                              const double tick_size,
                              const double tick_value,
                              const double lots = 1.0)
   {
      return(TickValueForPriceDistanceByProperties(entry_price - stop_price,
                                                   tick_size,
                                                   tick_value,
                                                   lots));
   }

   double LotsForRiskByDistance(const double risk_money,
                                const double entry_price,
                                const double stop_price,
                                const double tick_size,
                                const double tick_value)
   {
      if(risk_money <= 0.0)
         return(0.0);

      double one_lot_risk = RiskMoneyByDistance(entry_price,
                                                stop_price,
                                                tick_size,
                                                tick_value,
                                                1.0);
      if(one_lot_risk <= 0.0)
         return(0.0);

      return(risk_money / one_lot_risk);
   }

   double RewardRiskRatio(const double entry_price,
                          const double stop_price,
                          const double target_price)
   {
      double risk = MathAbs(entry_price - stop_price);
      double reward = MathAbs(target_price - entry_price);

      if(risk <= 0.0)
         return(0.0);

      return(reward / risk);
   }

   double TargetPriceForRewardRisk(const double entry_price,
                                   const double stop_price,
                                   const double reward_risk,
                                   const int direction)
   {
      double risk = MathAbs(entry_price - stop_price);
      double safe_ratio = MathAbs(reward_risk);

      if(direction > 0)
         return(entry_price + risk * safe_ratio);

      if(direction < 0)
         return(entry_price - risk * safe_ratio);

      return(entry_price);
   }

   double StopPriceForRiskDistance(const double entry_price,
                                   const double risk_distance,
                                   const int direction)
   {
      double safe_distance = MathAbs(risk_distance);

      if(direction > 0)
         return(entry_price - safe_distance);

      if(direction < 0)
         return(entry_price + safe_distance);

      return(entry_price);
   }

   double InterpolatePrice(const double start_price,
                           const double end_price,
                           const double fraction)
   {
      return(start_price + (end_price - start_price) * fraction);
   }

   double InterpolatePriceClamped(const double start_price,
                                  const double end_price,
                                  const double fraction)
   {
      double safe_fraction = MathMax(0.0, MathMin(1.0, fraction));
      return(InterpolatePrice(start_price, end_price, safe_fraction));
   }

   double DistancePercentOfRange(const double distance,
                                 const double range_size)
   {
      double safe_range = MathAbs(range_size);
      if(safe_range <= 0.0)
         return(0.0);

      return((MathAbs(distance) / safe_range) * 100.0);
   }

   double PriceDistancePercent(const double price_a,
                               const double price_b,
                               const double reference_range)
   {
      return(DistancePercentOfRange(price_a - price_b,
                                    reference_range));
   }


   // ---------------------------------------------------------------
   // Block 5 - OHLC candle price geometry
   // ---------------------------------------------------------------
   double CandleRange(const double high_price,
                      const double low_price)
   {
      return(MathAbs(high_price - low_price));
   }

   double CandleBody(const double open_price,
                     const double close_price)
   {
      return(MathAbs(close_price - open_price));
   }

   double CandleSignedBody(const double open_price,
                           const double close_price)
   {
      return(close_price - open_price);
   }

   double CandleMidPrice(const double high_price,
                         const double low_price)
   {
      return((high_price + low_price) * 0.5);
   }

   double CandleTypicalPrice(const double high_price,
                             const double low_price,
                             const double close_price)
   {
      return((high_price + low_price + close_price) / 3.0);
   }

   double CandleWeightedClose(const double high_price,
                              const double low_price,
                              const double close_price)
   {
      return((high_price + low_price + close_price * 2.0) / 4.0);
   }

   double CandleOHLC4(const double open_price,
                      const double high_price,
                      const double low_price,
                      const double close_price)
   {
      return((open_price + high_price + low_price + close_price) / 4.0);
   }

   double CandleUpperWick(const double open_price,
                          const double high_price,
                          const double close_price)
   {
      double body_top = MathMax(open_price, close_price);
      return(MathMax(0.0, high_price - body_top));
   }

   double CandleLowerWick(const double open_price,
                          const double low_price,
                          const double close_price)
   {
      double body_bottom = MathMin(open_price, close_price);
      return(MathMax(0.0, body_bottom - low_price));
   }

   double CandleTotalWick(const double open_price,
                          const double high_price,
                          const double low_price,
                          const double close_price)
   {
      return(CandleUpperWick(open_price, high_price, close_price) +
             CandleLowerWick(open_price, low_price, close_price));
   }

   int CandleDirection(const double open_price,
                       const double close_price,
                       const double tolerance = 0.0)
   {
      double safe_tolerance = MathMax(0.0, tolerance);
      double difference = close_price - open_price;

      if(difference > safe_tolerance)
         return(1);

      if(difference < -safe_tolerance)
         return(-1);

      return(0);
   }

   double CandleBodyPercent(const double open_price,
                            const double high_price,
                            const double low_price,
                            const double close_price)
   {
      double range_value = CandleRange(high_price, low_price);
      if(range_value <= 0.0)
         return(0.0);

      return((CandleBody(open_price, close_price) / range_value) * 100.0);
   }

   double CandleUpperWickPercent(const double open_price,
                                 const double high_price,
                                 const double low_price,
                                 const double close_price)
   {
      double range_value = CandleRange(high_price, low_price);
      if(range_value <= 0.0)
         return(0.0);

      return((CandleUpperWick(open_price, high_price, close_price) /
              range_value) * 100.0);
   }

   double CandleLowerWickPercent(const double open_price,
                                 const double high_price,
                                 const double low_price,
                                 const double close_price)
   {
      double range_value = CandleRange(high_price, low_price);
      if(range_value <= 0.0)
         return(0.0);

      return((CandleLowerWick(open_price, low_price, close_price) /
              range_value) * 100.0);
   }

   double TrueRange(const double high_price,
                    const double low_price,
                    const double previous_close)
   {
      double high_low = MathAbs(high_price - low_price);
      double high_previous = MathAbs(high_price - previous_close);
      double low_previous = MathAbs(low_price - previous_close);

      return(MathMax(high_low, MathMax(high_previous, low_previous)));
   }


   // ---------------------------------------------------------------
   // Block 6 - Candle structure and relationship classification
   // ---------------------------------------------------------------
   double CandleBodyTop(const double open_price,
                        const double close_price)
   {
      return(MathMax(open_price, close_price));
   }

   double CandleBodyBottom(const double open_price,
                           const double close_price)
   {
      return(MathMin(open_price, close_price));
   }

   bool IsValidCandle(const double open_price,
                      const double high_price,
                      const double low_price,
                      const double close_price,
                      const double tolerance = 0.0)
   {
      double safe_tolerance = MathMax(0.0, tolerance);
      double epsilon = ComparisonEpsilon(open_price,
                                         high_price,
                                         low_price);
      epsilon = MathMax(epsilon,
                        ComparisonEpsilon(close_price,
                                          safe_tolerance));

      if(high_price + safe_tolerance + epsilon < low_price)
         return(false);

      if(open_price > high_price + safe_tolerance + epsilon)
         return(false);

      if(open_price < low_price - safe_tolerance - epsilon)
         return(false);

      if(close_price > high_price + safe_tolerance + epsilon)
         return(false);

      if(close_price < low_price - safe_tolerance - epsilon)
         return(false);

      return(true);
   }

   double CandleClosePosition(const double high_price,
                              const double low_price,
                              const double close_price,
                              const bool clamp_result = true)
   {
      double range_value = high_price - low_price;
      if(range_value <= 0.0)
         return(0.0);

      double position = (close_price - low_price) / range_value;

      if(!clamp_result)
         return(position);

      return(MathMax(0.0, MathMin(1.0, position)));
   }

   double CandleClosePositionPercent(const double high_price,
                                     const double low_price,
                                     const double close_price,
                                     const bool clamp_result = true)
   {
      return(CandleClosePosition(high_price,
                                 low_price,
                                 close_price,
                                 clamp_result) * 100.0);
   }

   bool IsDoji(const double open_price,
               const double close_price,
               const double maximum_body = 0.0)
   {
      double safe_maximum = MathMax(0.0, maximum_body);
      double epsilon = ComparisonEpsilon(open_price,
                                         close_price,
                                         safe_maximum);
      return(CandleBody(open_price, close_price) <=
             safe_maximum + epsilon);
   }

   bool IsBullishCandle(const double open_price,
                        const double close_price,
                        const double tolerance = 0.0)
   {
      return(CandleDirection(open_price,
                             close_price,
                             tolerance) > 0);
   }

   bool IsBearishCandle(const double open_price,
                        const double close_price,
                        const double tolerance = 0.0)
   {
      return(CandleDirection(open_price,
                             close_price,
                             tolerance) < 0);
   }

   double CandleGap(const double current_open,
                    const double previous_close)
   {
      return(current_open - previous_close);
   }

   double CandleGapAbsolute(const double current_open,
                            const double previous_close)
   {
      return(MathAbs(CandleGap(current_open, previous_close)));
   }

   int CandleGapDirection(const double current_open,
                          const double previous_close,
                          const double tolerance = 0.0)
   {
      return(CandleDirection(previous_close,
                             current_open,
                             tolerance));
   }

   bool IsInsideBar(const double current_high,
                    const double current_low,
                    const double previous_high,
                    const double previous_low,
                    const bool allow_equal = true,
                    const double tolerance = 0.0)
   {
      double safe_tolerance = MathMax(0.0, tolerance);
      double epsilon = ComparisonEpsilon(current_high,
                                         current_low,
                                         previous_high);
      epsilon = MathMax(epsilon,
                        ComparisonEpsilon(previous_low,
                                          safe_tolerance));

      if(allow_equal)
      {
         return(current_high <= previous_high + safe_tolerance + epsilon &&
                current_low >= previous_low - safe_tolerance - epsilon);
      }

      return(current_high < previous_high + safe_tolerance - epsilon &&
             current_low > previous_low - safe_tolerance + epsilon);
   }

   bool IsOutsideBar(const double current_high,
                     const double current_low,
                     const double previous_high,
                     const double previous_low,
                     const bool allow_equal = true,
                     const double tolerance = 0.0)
   {
      double safe_tolerance = MathMax(0.0, tolerance);
      double epsilon = ComparisonEpsilon(current_high,
                                         current_low,
                                         previous_high);
      epsilon = MathMax(epsilon,
                        ComparisonEpsilon(previous_low,
                                          safe_tolerance));

      if(allow_equal)
      {
         return(current_high >= previous_high - safe_tolerance - epsilon &&
                current_low <= previous_low + safe_tolerance + epsilon);
      }

      return(current_high > previous_high - safe_tolerance + epsilon &&
             current_low < previous_low + safe_tolerance - epsilon);
   }

   double CandleRangeOverlap(const double high_a,
                             const double low_a,
                             const double high_b,
                             const double low_b)
   {
      double upper = MathMin(MathMax(high_a, low_a),
                             MathMax(high_b, low_b));
      double lower = MathMax(MathMin(high_a, low_a),
                             MathMin(high_b, low_b));

      return(MathMax(0.0, upper - lower));
   }

   bool IsBullishEngulfing(const double previous_open,
                           const double previous_close,
                           const double current_open,
                           const double current_close,
                           const bool allow_equal = true,
                           const double tolerance = 0.0)
   {
      if(!IsBearishCandle(previous_open, previous_close, tolerance))
         return(false);

      if(!IsBullishCandle(current_open, current_close, tolerance))
         return(false);

      double previous_top = CandleBodyTop(previous_open, previous_close);
      double previous_bottom = CandleBodyBottom(previous_open, previous_close);
      double current_top = CandleBodyTop(current_open, current_close);
      double current_bottom = CandleBodyBottom(current_open, current_close);
      double safe_tolerance = MathMax(0.0, tolerance);
      double epsilon = ComparisonEpsilon(previous_top,
                                         previous_bottom,
                                         current_top);
      epsilon = MathMax(epsilon,
                        ComparisonEpsilon(current_bottom,
                                          safe_tolerance));

      if(allow_equal)
      {
         return(current_top >= previous_top - safe_tolerance - epsilon &&
                current_bottom <= previous_bottom + safe_tolerance + epsilon);
      }

      return(current_top > previous_top - safe_tolerance + epsilon &&
             current_bottom < previous_bottom + safe_tolerance - epsilon);
   }

   bool IsBearishEngulfing(const double previous_open,
                           const double previous_close,
                           const double current_open,
                           const double current_close,
                           const bool allow_equal = true,
                           const double tolerance = 0.0)
   {
      if(!IsBullishCandle(previous_open, previous_close, tolerance))
         return(false);

      if(!IsBearishCandle(current_open, current_close, tolerance))
         return(false);

      double previous_top = CandleBodyTop(previous_open, previous_close);
      double previous_bottom = CandleBodyBottom(previous_open, previous_close);
      double current_top = CandleBodyTop(current_open, current_close);
      double current_bottom = CandleBodyBottom(current_open, current_close);
      double safe_tolerance = MathMax(0.0, tolerance);
      double epsilon = ComparisonEpsilon(previous_top,
                                         previous_bottom,
                                         current_top);
      epsilon = MathMax(epsilon,
                        ComparisonEpsilon(current_bottom,
                                          safe_tolerance));

      if(allow_equal)
      {
         return(current_top >= previous_top - safe_tolerance - epsilon &&
                current_bottom <= previous_bottom + safe_tolerance + epsilon);
      }

      return(current_top > previous_top - safe_tolerance + epsilon &&
             current_bottom < previous_bottom + safe_tolerance - epsilon);
   }

};

#endif