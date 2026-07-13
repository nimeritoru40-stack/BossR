//+------------------------------------------------------------------+
//| BossR_Pattern_Block6_FULL.mqh                              |
//| BossR Framework - Pattern Module                                 |
//| Block 6: Pattern classification and aggregate helpers                 |
//| MT4 / MQL4                                                       |
//+------------------------------------------------------------------+
#ifndef BOSSR_PATTERN_BLOCK6_FULL_MQH
#define BOSSR_PATTERN_BLOCK6_FULL_MQH

class C_BossR_Pattern
{
private:
   double ComparisonEpsilon() const
   {
      return(0.000000000001);
   }

   bool LessOrEqual(const double value,
                    const double limit) const
   {
      return(value <= (limit + ComparisonEpsilon()));
   }

   bool GreaterOrEqual(const double value,
                       const double limit) const
   {
      return(value >= (limit - ComparisonEpsilon()));
   }

public:
   C_BossR_Pattern()
   {
   }

   bool IsValidOHLC(const double open_price,
                    const double high_price,
                    const double low_price,
                    const double close_price) const
   {
      if(open_price  < 0.0 ||
         high_price  < 0.0 ||
         low_price   < 0.0 ||
         close_price < 0.0)
      {
         return(false);
      }

      if(high_price < low_price)
         return(false);

      if(open_price > high_price || open_price < low_price)
         return(false);

      if(close_price > high_price || close_price < low_price)
         return(false);

      return(true);
   }

   double Range(const double high_price,
                const double low_price) const
   {
      if(high_price < low_price)
         return(0.0);

      return(high_price - low_price);
   }

   double Body(const double open_price,
               const double close_price) const
   {
      return(MathAbs(close_price - open_price));
   }

   double UpperWick(const double open_price,
                    const double high_price,
                    const double close_price) const
   {
      double body_high = MathMax(open_price, close_price);

      if(high_price < body_high)
         return(0.0);

      return(high_price - body_high);
   }

   double LowerWick(const double open_price,
                    const double low_price,
                    const double close_price) const
   {
      double body_low = MathMin(open_price, close_price);

      if(low_price > body_low)
         return(0.0);

      return(body_low - low_price);
   }

   double BodyPercent(const double open_price,
                      const double high_price,
                      const double low_price,
                      const double close_price) const
   {
      double candle_range = Range(high_price, low_price);

      if(candle_range <= 0.0)
         return(0.0);

      return(Body(open_price, close_price) / candle_range);
   }

   double UpperWickPercent(const double open_price,
                           const double high_price,
                           const double low_price,
                           const double close_price) const
   {
      double candle_range = Range(high_price, low_price);

      if(candle_range <= 0.0)
         return(0.0);

      return(UpperWick(open_price,
                       high_price,
                       close_price) / candle_range);
   }

   double LowerWickPercent(const double open_price,
                           const double high_price,
                           const double low_price,
                           const double close_price) const
   {
      double candle_range = Range(high_price, low_price);

      if(candle_range <= 0.0)
         return(0.0);

      return(LowerWick(open_price,
                       low_price,
                       close_price) / candle_range);
   }

   bool IsBullish(const double open_price,
                  const double close_price) const
   {
      return(close_price > open_price);
   }

   bool IsBearish(const double open_price,
                  const double close_price) const
   {
      return(close_price < open_price);
   }

   bool IsDoji(const double open_price,
               const double high_price,
               const double low_price,
               const double close_price,
               const double maximum_body_percent = 0.10) const
   {
      if(!IsValidOHLC(open_price,
                      high_price,
                      low_price,
                      close_price))
      {
         return(false);
      }

      if(maximum_body_percent < 0.0)
         return(false);

      double candle_range = Range(high_price, low_price);

      if(candle_range <= 0.0)
         return(true);

      return(
         LessOrEqual(
            BodyPercent(open_price,
                        high_price,
                        low_price,
                        close_price),
            maximum_body_percent
         )
      );
   }

   bool IsBullishMarubozu(const double open_price,
                          const double high_price,
                          const double low_price,
                          const double close_price,
                          const double maximum_wick_percent = 0.05) const
   {
      if(!IsValidOHLC(open_price,
                      high_price,
                      low_price,
                      close_price))
      {
         return(false);
      }

      if(maximum_wick_percent < 0.0)
         return(false);

      if(!IsBullish(open_price, close_price))
         return(false);

      if(Range(high_price, low_price) <= 0.0)
         return(false);

      double upper_percent =
         UpperWickPercent(open_price,
                          high_price,
                          low_price,
                          close_price);

      double lower_percent =
         LowerWickPercent(open_price,
                          high_price,
                          low_price,
                          close_price);

      return(
         LessOrEqual(upper_percent, maximum_wick_percent) &&
         LessOrEqual(lower_percent, maximum_wick_percent)
      );
   }

   bool IsBearishMarubozu(const double open_price,
                          const double high_price,
                          const double low_price,
                          const double close_price,
                          const double maximum_wick_percent = 0.05) const
   {
      if(!IsValidOHLC(open_price,
                      high_price,
                      low_price,
                      close_price))
      {
         return(false);
      }

      if(maximum_wick_percent < 0.0)
         return(false);

      if(!IsBearish(open_price, close_price))
         return(false);

      if(Range(high_price, low_price) <= 0.0)
         return(false);

      double upper_percent =
         UpperWickPercent(open_price,
                          high_price,
                          low_price,
                          close_price);

      double lower_percent =
         LowerWickPercent(open_price,
                          high_price,
                          low_price,
                          close_price);

      return(
         LessOrEqual(upper_percent, maximum_wick_percent) &&
         LessOrEqual(lower_percent, maximum_wick_percent)
      );
   }

   bool IsHammer(const double open_price,
                 const double high_price,
                 const double low_price,
                 const double close_price,
                 const double minimum_lower_wick_body_ratio = 2.0,
                 const double maximum_upper_wick_body_ratio = 0.50,
                 const double maximum_body_percent = 0.40) const
   {
      if(!IsValidOHLC(open_price,
                      high_price,
                      low_price,
                      close_price))
      {
         return(false);
      }

      if(minimum_lower_wick_body_ratio < 0.0 ||
         maximum_upper_wick_body_ratio < 0.0 ||
         maximum_body_percent < 0.0)
      {
         return(false);
      }

      double candle_range = Range(high_price, low_price);
      double candle_body  = Body(open_price, close_price);

      if(candle_range <= 0.0 || candle_body <= 0.0)
         return(false);

      double lower_wick =
         LowerWick(open_price,
                   low_price,
                   close_price);

      double upper_wick =
         UpperWick(open_price,
                   high_price,
                   close_price);

      double lower_ratio = lower_wick / candle_body;
      double upper_ratio = upper_wick / candle_body;
      double body_ratio  = candle_body / candle_range;

      return(
         GreaterOrEqual(lower_ratio,
                        minimum_lower_wick_body_ratio) &&
         LessOrEqual(upper_ratio,
                     maximum_upper_wick_body_ratio) &&
         LessOrEqual(body_ratio,
                     maximum_body_percent)
      );
   }

   bool IsShootingStar(const double open_price,
                       const double high_price,
                       const double low_price,
                       const double close_price,
                       const double minimum_upper_wick_body_ratio = 2.0,
                       const double maximum_lower_wick_body_ratio = 0.50,
                       const double maximum_body_percent = 0.40) const
   {
      if(!IsValidOHLC(open_price,
                      high_price,
                      low_price,
                      close_price))
      {
         return(false);
      }

      if(minimum_upper_wick_body_ratio < 0.0 ||
         maximum_lower_wick_body_ratio < 0.0 ||
         maximum_body_percent < 0.0)
      {
         return(false);
      }

      double candle_range = Range(high_price, low_price);
      double candle_body  = Body(open_price, close_price);

      if(candle_range <= 0.0 || candle_body <= 0.0)
         return(false);

      double upper_wick =
         UpperWick(open_price,
                   high_price,
                   close_price);

      double lower_wick =
         LowerWick(open_price,
                   low_price,
                   close_price);

      double upper_ratio = upper_wick / candle_body;
      double lower_ratio = lower_wick / candle_body;
      double body_ratio  = candle_body / candle_range;

      return(
         GreaterOrEqual(upper_ratio,
                        minimum_upper_wick_body_ratio) &&
         LessOrEqual(lower_ratio,
                     maximum_lower_wick_body_ratio) &&
         LessOrEqual(body_ratio,
                     maximum_body_percent)
      );
   }

   bool IsSpinningTop(const double open_price,
                      const double high_price,
                      const double low_price,
                      const double close_price,
                      const double maximum_body_percent = 0.35,
                      const double minimum_upper_wick_percent = 0.20,
                      const double minimum_lower_wick_percent = 0.20) const
   {
      if(!IsValidOHLC(open_price,
                      high_price,
                      low_price,
                      close_price))
      {
         return(false);
      }

      if(maximum_body_percent < 0.0 ||
         minimum_upper_wick_percent < 0.0 ||
         minimum_lower_wick_percent < 0.0)
      {
         return(false);
      }

      if(Range(high_price, low_price) <= 0.0)
         return(false);

      double body_percent =
         BodyPercent(open_price,
                     high_price,
                     low_price,
                     close_price);

      double upper_percent =
         UpperWickPercent(open_price,
                          high_price,
                          low_price,
                          close_price);

      double lower_percent =
         LowerWickPercent(open_price,
                          high_price,
                          low_price,
                          close_price);

      return(
         LessOrEqual(body_percent,
                     maximum_body_percent) &&
         GreaterOrEqual(upper_percent,
                        minimum_upper_wick_percent) &&
         GreaterOrEqual(lower_percent,
                        minimum_lower_wick_percent)
      );
   }

   bool IsValidPairOHLC(const double previous_open,
                        const double previous_high,
                        const double previous_low,
                        const double previous_close,
                        const double current_open,
                        const double current_high,
                        const double current_low,
                        const double current_close) const
   {
      return(
         IsValidOHLC(previous_open,
                     previous_high,
                     previous_low,
                     previous_close) &&
         IsValidOHLC(current_open,
                     current_high,
                     current_low,
                     current_close)
      );
   }

   bool IsInsideBar(const double previous_open,
                    const double previous_high,
                    const double previous_low,
                    const double previous_close,
                    const double current_open,
                    const double current_high,
                    const double current_low,
                    const double current_close) const
   {
      if(!IsValidPairOHLC(previous_open,
                          previous_high,
                          previous_low,
                          previous_close,
                          current_open,
                          current_high,
                          current_low,
                          current_close))
      {
         return(false);
      }

      bool contained =
         LessOrEqual(current_high, previous_high) &&
         GreaterOrEqual(current_low, previous_low);

      bool strictly_inside =
         current_high < (previous_high - ComparisonEpsilon()) ||
         current_low  > (previous_low  + ComparisonEpsilon());

      return(contained && strictly_inside);
   }

   bool IsOutsideBar(const double previous_open,
                     const double previous_high,
                     const double previous_low,
                     const double previous_close,
                     const double current_open,
                     const double current_high,
                     const double current_low,
                     const double current_close) const
   {
      if(!IsValidPairOHLC(previous_open,
                          previous_high,
                          previous_low,
                          previous_close,
                          current_open,
                          current_high,
                          current_low,
                          current_close))
      {
         return(false);
      }

      bool contains =
         GreaterOrEqual(current_high, previous_high) &&
         LessOrEqual(current_low, previous_low);

      bool strictly_outside =
         current_high > (previous_high + ComparisonEpsilon()) ||
         current_low  < (previous_low  - ComparisonEpsilon());

      return(contains && strictly_outside);
   }

   bool IsBullishEngulfing(const double previous_open,
                           const double previous_high,
                           const double previous_low,
                           const double previous_close,
                           const double current_open,
                           const double current_high,
                           const double current_low,
                           const double current_close,
                           const double minimum_body_ratio = 1.0) const
   {
      if(!IsValidPairOHLC(previous_open,
                          previous_high,
                          previous_low,
                          previous_close,
                          current_open,
                          current_high,
                          current_low,
                          current_close))
      {
         return(false);
      }

      if(minimum_body_ratio < 0.0)
         return(false);

      if(!IsBearish(previous_open, previous_close) ||
         !IsBullish(current_open, current_close))
      {
         return(false);
      }

      double previous_body = Body(previous_open, previous_close);
      double current_body  = Body(current_open, current_close);

      if(previous_body <= 0.0 || current_body <= 0.0)
         return(false);

      return(
         LessOrEqual(current_open, previous_close) &&
         GreaterOrEqual(current_close, previous_open) &&
         GreaterOrEqual(current_body,
                        previous_body * minimum_body_ratio)
      );
   }

   bool IsBearishEngulfing(const double previous_open,
                           const double previous_high,
                           const double previous_low,
                           const double previous_close,
                           const double current_open,
                           const double current_high,
                           const double current_low,
                           const double current_close,
                           const double minimum_body_ratio = 1.0) const
   {
      if(!IsValidPairOHLC(previous_open,
                          previous_high,
                          previous_low,
                          previous_close,
                          current_open,
                          current_high,
                          current_low,
                          current_close))
      {
         return(false);
      }

      if(minimum_body_ratio < 0.0)
         return(false);

      if(!IsBullish(previous_open, previous_close) ||
         !IsBearish(current_open, current_close))
      {
         return(false);
      }

      double previous_body = Body(previous_open, previous_close);
      double current_body  = Body(current_open, current_close);

      if(previous_body <= 0.0 || current_body <= 0.0)
         return(false);

      return(
         GreaterOrEqual(current_open, previous_close) &&
         LessOrEqual(current_close, previous_open) &&
         GreaterOrEqual(current_body,
                        previous_body * minimum_body_ratio)
      );
   }

   bool IsBullishHarami(const double previous_open,
                        const double previous_high,
                        const double previous_low,
                        const double previous_close,
                        const double current_open,
                        const double current_high,
                        const double current_low,
                        const double current_close,
                        const double maximum_body_ratio = 1.0) const
   {
      if(!IsValidPairOHLC(previous_open,
                          previous_high,
                          previous_low,
                          previous_close,
                          current_open,
                          current_high,
                          current_low,
                          current_close))
      {
         return(false);
      }

      if(maximum_body_ratio < 0.0)
         return(false);

      if(!IsBearish(previous_open, previous_close) ||
         !IsBullish(current_open, current_close))
      {
         return(false);
      }

      double previous_body = Body(previous_open, previous_close);
      double current_body  = Body(current_open, current_close);

      if(previous_body <= 0.0 || current_body <= 0.0)
         return(false);

      return(
         GreaterOrEqual(current_open, previous_close) &&
         LessOrEqual(current_close, previous_open) &&
         LessOrEqual(current_body,
                     previous_body * maximum_body_ratio)
      );
   }

   bool IsBearishHarami(const double previous_open,
                        const double previous_high,
                        const double previous_low,
                        const double previous_close,
                        const double current_open,
                        const double current_high,
                        const double current_low,
                        const double current_close,
                        const double maximum_body_ratio = 1.0) const
   {
      if(!IsValidPairOHLC(previous_open,
                          previous_high,
                          previous_low,
                          previous_close,
                          current_open,
                          current_high,
                          current_low,
                          current_close))
      {
         return(false);
      }

      if(maximum_body_ratio < 0.0)
         return(false);

      if(!IsBullish(previous_open, previous_close) ||
         !IsBearish(current_open, current_close))
      {
         return(false);
      }

      double previous_body = Body(previous_open, previous_close);
      double current_body  = Body(current_open, current_close);

      if(previous_body <= 0.0 || current_body <= 0.0)
         return(false);

      return(
         LessOrEqual(current_open, previous_close) &&
         GreaterOrEqual(current_close, previous_open) &&
         LessOrEqual(current_body,
                     previous_body * maximum_body_ratio)
      );
   }

   bool IsPiercingLine(const double previous_open,
                       const double previous_high,
                       const double previous_low,
                       const double previous_close,
                       const double current_open,
                       const double current_high,
                       const double current_low,
                       const double current_close,
                       const double minimum_penetration = 0.50) const
   {
      if(!IsValidPairOHLC(previous_open,
                          previous_high,
                          previous_low,
                          previous_close,
                          current_open,
                          current_high,
                          current_low,
                          current_close))
      {
         return(false);
      }

      if(minimum_penetration < 0.0 || minimum_penetration > 1.0)
         return(false);

      if(!IsBearish(previous_open, previous_close) ||
         !IsBullish(current_open, current_close))
      {
         return(false);
      }

      double target =
         previous_close +
         (previous_open - previous_close) * minimum_penetration;

      return(
         LessOrEqual(current_open, previous_close) &&
         GreaterOrEqual(current_close, target) &&
         current_close < (previous_open - ComparisonEpsilon())
      );
   }

   bool IsDarkCloudCover(const double previous_open,
                         const double previous_high,
                         const double previous_low,
                         const double previous_close,
                         const double current_open,
                         const double current_high,
                         const double current_low,
                         const double current_close,
                         const double minimum_penetration = 0.50) const
   {
      if(!IsValidPairOHLC(previous_open,
                          previous_high,
                          previous_low,
                          previous_close,
                          current_open,
                          current_high,
                          current_low,
                          current_close))
      {
         return(false);
      }

      if(minimum_penetration < 0.0 || minimum_penetration > 1.0)
         return(false);

      if(!IsBullish(previous_open, previous_close) ||
         !IsBearish(current_open, current_close))
      {
         return(false);
      }

      double target =
         previous_close -
         (previous_close - previous_open) * minimum_penetration;

      return(
         GreaterOrEqual(current_open, previous_close) &&
         LessOrEqual(current_close, target) &&
         current_close > (previous_open + ComparisonEpsilon())
      );
   }

   bool IsTweezerBottom(const double previous_open,
                        const double previous_high,
                        const double previous_low,
                        const double previous_close,
                        const double current_open,
                        const double current_high,
                        const double current_low,
                        const double current_close,
                        const double price_tolerance = 0.0) const
   {
      if(!IsValidPairOHLC(previous_open,
                          previous_high,
                          previous_low,
                          previous_close,
                          current_open,
                          current_high,
                          current_low,
                          current_close))
      {
         return(false);
      }

      if(price_tolerance < 0.0)
         return(false);

      return(
         IsBearish(previous_open, previous_close) &&
         IsBullish(current_open, current_close) &&
         MathAbs(previous_low - current_low) <=
            (price_tolerance + ComparisonEpsilon())
      );
   }

   bool IsTweezerTop(const double previous_open,
                     const double previous_high,
                     const double previous_low,
                     const double previous_close,
                     const double current_open,
                     const double current_high,
                     const double current_low,
                     const double current_close,
                     const double price_tolerance = 0.0) const
   {
      if(!IsValidPairOHLC(previous_open,
                          previous_high,
                          previous_low,
                          previous_close,
                          current_open,
                          current_high,
                          current_low,
                          current_close))
      {
         return(false);
      }

      if(price_tolerance < 0.0)
         return(false);

      return(
         IsBullish(previous_open, previous_close) &&
         IsBearish(current_open, current_close) &&
         MathAbs(previous_high - current_high) <=
            (price_tolerance + ComparisonEpsilon())
      );
   }


   bool IsValidTripleOHLC(const double first_open,
                          const double first_high,
                          const double first_low,
                          const double first_close,
                          const double second_open,
                          const double second_high,
                          const double second_low,
                          const double second_close,
                          const double third_open,
                          const double third_high,
                          const double third_low,
                          const double third_close) const
   {
      return(
         IsValidOHLC(first_open,
                     first_high,
                     first_low,
                     first_close) &&
         IsValidOHLC(second_open,
                     second_high,
                     second_low,
                     second_close) &&
         IsValidOHLC(third_open,
                     third_high,
                     third_low,
                     third_close)
      );
   }

   bool IsMorningStar(const double first_open,
                      const double first_high,
                      const double first_low,
                      const double first_close,
                      const double second_open,
                      const double second_high,
                      const double second_low,
                      const double second_close,
                      const double third_open,
                      const double third_high,
                      const double third_low,
                      const double third_close,
                      const double maximum_star_body_ratio = 0.50,
                      const double minimum_recovery = 0.50) const
   {
      if(!IsValidTripleOHLC(first_open, first_high, first_low, first_close,
                            second_open, second_high, second_low, second_close,
                            third_open, third_high, third_low, third_close))
      {
         return(false);
      }

      if(maximum_star_body_ratio < 0.0 ||
         minimum_recovery < 0.0 || minimum_recovery > 1.0)
      {
         return(false);
      }

      if(!IsBearish(first_open, first_close) ||
         !IsBullish(third_open, third_close))
      {
         return(false);
      }

      double first_body  = Body(first_open, first_close);
      double second_body = Body(second_open, second_close);

      if(first_body <= 0.0 ||
         second_body > first_body * maximum_star_body_ratio)
      {
         return(false);
      }

      double recovery_target =
         first_close + first_body * minimum_recovery;

      double second_body_high = MathMax(second_open, second_close);

      return(
         LessOrEqual(second_body_high, first_close) &&
         LessOrEqual(second_body_high, third_open) &&
         GreaterOrEqual(third_close, recovery_target) &&
         third_close < (first_open - ComparisonEpsilon())
      );
   }

   bool IsEveningStar(const double first_open,
                      const double first_high,
                      const double first_low,
                      const double first_close,
                      const double second_open,
                      const double second_high,
                      const double second_low,
                      const double second_close,
                      const double third_open,
                      const double third_high,
                      const double third_low,
                      const double third_close,
                      const double maximum_star_body_ratio = 0.50,
                      const double minimum_recovery = 0.50) const
   {
      if(!IsValidTripleOHLC(first_open, first_high, first_low, first_close,
                            second_open, second_high, second_low, second_close,
                            third_open, third_high, third_low, third_close))
      {
         return(false);
      }

      if(maximum_star_body_ratio < 0.0 ||
         minimum_recovery < 0.0 || minimum_recovery > 1.0)
      {
         return(false);
      }

      if(!IsBullish(first_open, first_close) ||
         !IsBearish(third_open, third_close))
      {
         return(false);
      }

      double first_body  = Body(first_open, first_close);
      double second_body = Body(second_open, second_close);

      if(first_body <= 0.0 ||
         second_body > first_body * maximum_star_body_ratio)
      {
         return(false);
      }

      double recovery_target =
         first_close - first_body * minimum_recovery;

      double second_body_low = MathMin(second_open, second_close);

      return(
         GreaterOrEqual(second_body_low, first_close) &&
         GreaterOrEqual(second_body_low, third_open) &&
         LessOrEqual(third_close, recovery_target) &&
         third_close > (first_open + ComparisonEpsilon())
      );
   }

   bool IsThreeWhiteSoldiers(const double first_open,
                             const double first_high,
                             const double first_low,
                             const double first_close,
                             const double second_open,
                             const double second_high,
                             const double second_low,
                             const double second_close,
                             const double third_open,
                             const double third_high,
                             const double third_low,
                             const double third_close,
                             const double maximum_upper_wick_percent = 0.25) const
   {
      if(!IsValidTripleOHLC(first_open, first_high, first_low, first_close,
                            second_open, second_high, second_low, second_close,
                            third_open, third_high, third_low, third_close))
      {
         return(false);
      }

      if(maximum_upper_wick_percent < 0.0)
         return(false);

      if(!IsBullish(first_open, first_close) ||
         !IsBullish(second_open, second_close) ||
         !IsBullish(third_open, third_close))
      {
         return(false);
      }

      if(!(second_close > first_close && third_close > second_close))
         return(false);

      if(second_open < first_open || second_open > first_close ||
         third_open < second_open || third_open > second_close)
      {
         return(false);
      }

      return(
         LessOrEqual(UpperWickPercent(first_open, first_high, first_low, first_close),
                     maximum_upper_wick_percent) &&
         LessOrEqual(UpperWickPercent(second_open, second_high, second_low, second_close),
                     maximum_upper_wick_percent) &&
         LessOrEqual(UpperWickPercent(third_open, third_high, third_low, third_close),
                     maximum_upper_wick_percent)
      );
   }

   bool IsThreeBlackCrows(const double first_open,
                          const double first_high,
                          const double first_low,
                          const double first_close,
                          const double second_open,
                          const double second_high,
                          const double second_low,
                          const double second_close,
                          const double third_open,
                          const double third_high,
                          const double third_low,
                          const double third_close,
                          const double maximum_lower_wick_percent = 0.25) const
   {
      if(!IsValidTripleOHLC(first_open, first_high, first_low, first_close,
                            second_open, second_high, second_low, second_close,
                            third_open, third_high, third_low, third_close))
      {
         return(false);
      }

      if(maximum_lower_wick_percent < 0.0)
         return(false);

      if(!IsBearish(first_open, first_close) ||
         !IsBearish(second_open, second_close) ||
         !IsBearish(third_open, third_close))
      {
         return(false);
      }

      if(!(second_close < first_close && third_close < second_close))
         return(false);

      if(second_open > first_open || second_open < first_close ||
         third_open > second_open || third_open < second_close)
      {
         return(false);
      }

      return(
         LessOrEqual(LowerWickPercent(first_open, first_high, first_low, first_close),
                     maximum_lower_wick_percent) &&
         LessOrEqual(LowerWickPercent(second_open, second_high, second_low, second_close),
                     maximum_lower_wick_percent) &&
         LessOrEqual(LowerWickPercent(third_open, third_high, third_low, third_close),
                     maximum_lower_wick_percent)
      );
   }

   bool IsThreeInsideUp(const double first_open,
                        const double first_high,
                        const double first_low,
                        const double first_close,
                        const double second_open,
                        const double second_high,
                        const double second_low,
                        const double second_close,
                        const double third_open,
                        const double third_high,
                        const double third_low,
                        const double third_close,
                        const double maximum_harami_body_ratio = 1.0) const
   {
      if(!IsValidTripleOHLC(first_open, first_high, first_low, first_close,
                            second_open, second_high, second_low, second_close,
                            third_open, third_high, third_low, third_close))
      {
         return(false);
      }

      return(
         IsBullishHarami(first_open, first_high, first_low, first_close,
                          second_open, second_high, second_low, second_close,
                          maximum_harami_body_ratio) &&
         IsBullish(third_open, third_close) &&
         third_close > (first_open + ComparisonEpsilon())
      );
   }

   bool IsThreeInsideDown(const double first_open,
                          const double first_high,
                          const double first_low,
                          const double first_close,
                          const double second_open,
                          const double second_high,
                          const double second_low,
                          const double second_close,
                          const double third_open,
                          const double third_high,
                          const double third_low,
                          const double third_close,
                          const double maximum_harami_body_ratio = 1.0) const
   {
      if(!IsValidTripleOHLC(first_open, first_high, first_low, first_close,
                            second_open, second_high, second_low, second_close,
                            third_open, third_high, third_low, third_close))
      {
         return(false);
      }

      return(
         IsBearishHarami(first_open, first_high, first_low, first_close,
                          second_open, second_high, second_low, second_close,
                          maximum_harami_body_ratio) &&
         IsBearish(third_open, third_close) &&
         third_close < (first_open - ComparisonEpsilon())
      );
   }

   bool IsThreeOutsideUp(const double first_open,
                         const double first_high,
                         const double first_low,
                         const double first_close,
                         const double second_open,
                         const double second_high,
                         const double second_low,
                         const double second_close,
                         const double third_open,
                         const double third_high,
                         const double third_low,
                         const double third_close,
                         const double minimum_engulf_body_ratio = 1.0) const
   {
      if(!IsValidTripleOHLC(first_open, first_high, first_low, first_close,
                            second_open, second_high, second_low, second_close,
                            third_open, third_high, third_low, third_close))
      {
         return(false);
      }

      return(
         IsBullishEngulfing(first_open, first_high, first_low, first_close,
                             second_open, second_high, second_low, second_close,
                             minimum_engulf_body_ratio) &&
         IsBullish(third_open, third_close) &&
         third_close > (second_close + ComparisonEpsilon())
      );
   }

   bool IsThreeOutsideDown(const double first_open,
                           const double first_high,
                           const double first_low,
                           const double first_close,
                           const double second_open,
                           const double second_high,
                           const double second_low,
                           const double second_close,
                           const double third_open,
                           const double third_high,
                           const double third_low,
                           const double third_close,
                           const double minimum_engulf_body_ratio = 1.0) const
   {
      if(!IsValidTripleOHLC(first_open, first_high, first_low, first_close,
                            second_open, second_high, second_low, second_close,
                            third_open, third_high, third_low, third_close))
      {
         return(false);
      }

      return(
         IsBearishEngulfing(first_open, first_high, first_low, first_close,
                             second_open, second_high, second_low, second_close,
                             minimum_engulf_body_ratio) &&
         IsBearish(third_open, third_close) &&
         third_close < (second_close - ComparisonEpsilon())
      );
   }


   bool IsRisingCloses3(const double first_close,
                        const double second_close,
                        const double third_close) const
   {
      if(first_close < 0.0 ||
         second_close < 0.0 ||
         third_close < 0.0)
      {
         return(false);
      }

      return(
         second_close > (first_close + ComparisonEpsilon()) &&
         third_close > (second_close + ComparisonEpsilon())
      );
   }

   bool IsFallingCloses3(const double first_close,
                         const double second_close,
                         const double third_close) const
   {
      if(first_close < 0.0 ||
         second_close < 0.0 ||
         third_close < 0.0)
      {
         return(false);
      }

      return(
         second_close < (first_close - ComparisonEpsilon()) &&
         third_close < (second_close - ComparisonEpsilon())
      );
   }

   bool IsRisingHighs3(const double first_high,
                       const double second_high,
                       const double third_high) const
   {
      if(first_high < 0.0 ||
         second_high < 0.0 ||
         third_high < 0.0)
      {
         return(false);
      }

      return(
         second_high > (first_high + ComparisonEpsilon()) &&
         third_high > (second_high + ComparisonEpsilon())
      );
   }

   bool IsFallingLows3(const double first_low,
                       const double second_low,
                       const double third_low) const
   {
      if(first_low < 0.0 ||
         second_low < 0.0 ||
         third_low < 0.0)
      {
         return(false);
      }

      return(
         second_low < (first_low - ComparisonEpsilon()) &&
         third_low < (second_low - ComparisonEpsilon())
      );
   }

   bool IsBullishThreeLineStrike(const double first_open,
                                 const double first_high,
                                 const double first_low,
                                 const double first_close,
                                 const double second_open,
                                 const double second_high,
                                 const double second_low,
                                 const double second_close,
                                 const double third_open,
                                 const double third_high,
                                 const double third_low,
                                 const double third_close,
                                 const double fourth_open,
                                 const double fourth_high,
                                 const double fourth_low,
                                 const double fourth_close) const
   {
      if(!IsValidTripleOHLC(first_open, first_high, first_low, first_close,
                            second_open, second_high, second_low, second_close,
                            third_open, third_high, third_low, third_close) ||
         !IsValidOHLC(fourth_open, fourth_high, fourth_low, fourth_close))
      {
         return(false);
      }

      if(!IsBullish(first_open, first_close) ||
         !IsBullish(second_open, second_close) ||
         !IsBullish(third_open, third_close) ||
         !IsBearish(fourth_open, fourth_close))
      {
         return(false);
      }

      if(!IsRisingCloses3(first_close, second_close, third_close))
         return(false);

      return(
         GreaterOrEqual(fourth_open, third_close) &&
         LessOrEqual(fourth_close, first_open)
      );
   }

   bool IsBearishThreeLineStrike(const double first_open,
                                 const double first_high,
                                 const double first_low,
                                 const double first_close,
                                 const double second_open,
                                 const double second_high,
                                 const double second_low,
                                 const double second_close,
                                 const double third_open,
                                 const double third_high,
                                 const double third_low,
                                 const double third_close,
                                 const double fourth_open,
                                 const double fourth_high,
                                 const double fourth_low,
                                 const double fourth_close) const
   {
      if(!IsValidTripleOHLC(first_open, first_high, first_low, first_close,
                            second_open, second_high, second_low, second_close,
                            third_open, third_high, third_low, third_close) ||
         !IsValidOHLC(fourth_open, fourth_high, fourth_low, fourth_close))
      {
         return(false);
      }

      if(!IsBearish(first_open, first_close) ||
         !IsBearish(second_open, second_close) ||
         !IsBearish(third_open, third_close) ||
         !IsBullish(fourth_open, fourth_close))
      {
         return(false);
      }

      if(!IsFallingCloses3(first_close, second_close, third_close))
         return(false);

      return(
         LessOrEqual(fourth_open, third_close) &&
         GreaterOrEqual(fourth_close, first_open)
      );
   }


   bool IsGapUp(const double previous_high,
                const double current_low) const
   {
      if(previous_high < 0.0 || current_low < 0.0)
         return(false);

      return(current_low > (previous_high + ComparisonEpsilon()));
   }

   bool IsGapDown(const double previous_low,
                  const double current_high) const
   {
      if(previous_low < 0.0 || current_high < 0.0)
         return(false);

      return(current_high < (previous_low - ComparisonEpsilon()));
   }

   bool IsBodyGapUp(const double previous_open,
                    const double previous_close,
                    const double current_open,
                    const double current_close) const
   {
      if(previous_open < 0.0 ||
         previous_close < 0.0 ||
         current_open < 0.0 ||
         current_close < 0.0)
      {
         return(false);
      }

      double previous_body_high = MathMax(previous_open, previous_close);
      double current_body_low   = MathMin(current_open, current_close);

      return(current_body_low >
             (previous_body_high + ComparisonEpsilon()));
   }

   bool IsBodyGapDown(const double previous_open,
                      const double previous_close,
                      const double current_open,
                      const double current_close) const
   {
      if(previous_open < 0.0 ||
         previous_close < 0.0 ||
         current_open < 0.0 ||
         current_close < 0.0)
      {
         return(false);
      }

      double previous_body_low  = MathMin(previous_open, previous_close);
      double current_body_high  = MathMax(current_open, current_close);

      return(current_body_high <
             (previous_body_low - ComparisonEpsilon()));
   }

   bool IsBullishKicker(const double previous_open,
                        const double previous_high,
                        const double previous_low,
                        const double previous_close,
                        const double current_open,
                        const double current_high,
                        const double current_low,
                        const double current_close) const
   {
      if(!IsValidPairOHLC(previous_open,
                          previous_high,
                          previous_low,
                          previous_close,
                          current_open,
                          current_high,
                          current_low,
                          current_close))
      {
         return(false);
      }

      if(!IsBearish(previous_open, previous_close) ||
         !IsBullish(current_open, current_close))
      {
         return(false);
      }

      return(IsBodyGapUp(previous_open,
                         previous_close,
                         current_open,
                         current_close));
   }

   bool IsBearishKicker(const double previous_open,
                        const double previous_high,
                        const double previous_low,
                        const double previous_close,
                        const double current_open,
                        const double current_high,
                        const double current_low,
                        const double current_close) const
   {
      if(!IsValidPairOHLC(previous_open,
                          previous_high,
                          previous_low,
                          previous_close,
                          current_open,
                          current_high,
                          current_low,
                          current_close))
      {
         return(false);
      }

      if(!IsBullish(previous_open, previous_close) ||
         !IsBearish(current_open, current_close))
      {
         return(false);
      }

      return(IsBodyGapDown(previous_open,
                           previous_close,
                           current_open,
                           current_close));
   }


   bool IsBullishSingleCandlePattern(const double open_price,
                                     const double high_price,
                                     const double low_price,
                                     const double close_price) const
   {
      if(!IsValidOHLC(open_price, high_price, low_price, close_price))
         return(false);

      return(
         IsHammer(open_price, high_price, low_price, close_price) ||
         IsBullishMarubozu(open_price, high_price, low_price, close_price)
      );
   }

   bool IsBearishSingleCandlePattern(const double open_price,
                                     const double high_price,
                                     const double low_price,
                                     const double close_price) const
   {
      if(!IsValidOHLC(open_price, high_price, low_price, close_price))
         return(false);

      return(
         IsShootingStar(open_price, high_price, low_price, close_price) ||
         IsBearishMarubozu(open_price, high_price, low_price, close_price)
      );
   }

   bool IsBullishTwoCandlePattern(const double previous_open,
                                  const double previous_high,
                                  const double previous_low,
                                  const double previous_close,
                                  const double current_open,
                                  const double current_high,
                                  const double current_low,
                                  const double current_close) const
   {
      if(!IsValidPairOHLC(previous_open,
                          previous_high,
                          previous_low,
                          previous_close,
                          current_open,
                          current_high,
                          current_low,
                          current_close))
      {
         return(false);
      }

      return(
         IsBullishEngulfing(previous_open,
                            previous_high,
                            previous_low,
                            previous_close,
                            current_open,
                            current_high,
                            current_low,
                            current_close) ||
         IsPiercingLine(previous_open,
                        previous_high,
                        previous_low,
                        previous_close,
                        current_open,
                        current_high,
                        current_low,
                        current_close) ||
         IsBullishHarami(previous_open,
                         previous_high,
                         previous_low,
                         previous_close,
                         current_open,
                         current_high,
                         current_low,
                         current_close) ||
         IsBullishKicker(previous_open,
                         previous_high,
                         previous_low,
                         previous_close,
                         current_open,
                         current_high,
                         current_low,
                         current_close)
      );
   }

   bool IsBearishTwoCandlePattern(const double previous_open,
                                  const double previous_high,
                                  const double previous_low,
                                  const double previous_close,
                                  const double current_open,
                                  const double current_high,
                                  const double current_low,
                                  const double current_close) const
   {
      if(!IsValidPairOHLC(previous_open,
                          previous_high,
                          previous_low,
                          previous_close,
                          current_open,
                          current_high,
                          current_low,
                          current_close))
      {
         return(false);
      }

      return(
         IsBearishEngulfing(previous_open,
                            previous_high,
                            previous_low,
                            previous_close,
                            current_open,
                            current_high,
                            current_low,
                            current_close) ||
         IsDarkCloudCover(previous_open,
                          previous_high,
                          previous_low,
                          previous_close,
                          current_open,
                          current_high,
                          current_low,
                          current_close) ||
         IsBearishHarami(previous_open,
                         previous_high,
                         previous_low,
                         previous_close,
                         current_open,
                         current_high,
                         current_low,
                         current_close) ||
         IsBearishKicker(previous_open,
                         previous_high,
                         previous_low,
                         previous_close,
                         current_open,
                         current_high,
                         current_low,
                         current_close)
      );
   }

   bool IsBullishThreeCandlePattern(const double first_open,
                                    const double first_high,
                                    const double first_low,
                                    const double first_close,
                                    const double second_open,
                                    const double second_high,
                                    const double second_low,
                                    const double second_close,
                                    const double third_open,
                                    const double third_high,
                                    const double third_low,
                                    const double third_close) const
   {
      if(!IsValidTripleOHLC(first_open,
                            first_high,
                            first_low,
                            first_close,
                            second_open,
                            second_high,
                            second_low,
                            second_close,
                            third_open,
                            third_high,
                            third_low,
                            third_close))
      {
         return(false);
      }

      return(
         IsMorningStar(first_open,
                       first_high,
                       first_low,
                       first_close,
                       second_open,
                       second_high,
                       second_low,
                       second_close,
                       third_open,
                       third_high,
                       third_low,
                       third_close) ||
         IsThreeWhiteSoldiers(first_open,
                              first_high,
                              first_low,
                              first_close,
                              second_open,
                              second_high,
                              second_low,
                              second_close,
                              third_open,
                              third_high,
                              third_low,
                              third_close) ||
         IsThreeInsideUp(first_open,
                         first_high,
                         first_low,
                         first_close,
                         second_open,
                         second_high,
                         second_low,
                         second_close,
                         third_open,
                         third_high,
                         third_low,
                         third_close) ||
         IsThreeOutsideUp(first_open,
                          first_high,
                          first_low,
                          first_close,
                          second_open,
                          second_high,
                          second_low,
                          second_close,
                          third_open,
                          third_high,
                          third_low,
                          third_close)
      );
   }

   bool IsBearishThreeCandlePattern(const double first_open,
                                    const double first_high,
                                    const double first_low,
                                    const double first_close,
                                    const double second_open,
                                    const double second_high,
                                    const double second_low,
                                    const double second_close,
                                    const double third_open,
                                    const double third_high,
                                    const double third_low,
                                    const double third_close) const
   {
      if(!IsValidTripleOHLC(first_open,
                            first_high,
                            first_low,
                            first_close,
                            second_open,
                            second_high,
                            second_low,
                            second_close,
                            third_open,
                            third_high,
                            third_low,
                            third_close))
      {
         return(false);
      }

      return(
         IsEveningStar(first_open,
                       first_high,
                       first_low,
                       first_close,
                       second_open,
                       second_high,
                       second_low,
                       second_close,
                       third_open,
                       third_high,
                       third_low,
                       third_close) ||
         IsThreeBlackCrows(first_open,
                           first_high,
                           first_low,
                           first_close,
                           second_open,
                           second_high,
                           second_low,
                           second_close,
                           third_open,
                           third_high,
                           third_low,
                           third_close) ||
         IsThreeInsideDown(first_open,
                           first_high,
                           first_low,
                           first_close,
                           second_open,
                           second_high,
                           second_low,
                           second_close,
                           third_open,
                           third_high,
                           third_low,
                           third_close) ||
         IsThreeOutsideDown(first_open,
                            first_high,
                            first_low,
                            first_close,
                            second_open,
                            second_high,
                            second_low,
                            second_close,
                            third_open,
                            third_high,
                            third_low,
                            third_close)
      );
   }

};

#endif