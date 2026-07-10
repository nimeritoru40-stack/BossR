//+------------------------------------------------------------------+
//| BossR_Candle.mqh                                                 |
//| BossR Framework - Candle utilities                               |
//| Block 1                                                          |
//| MT4 only                                                         |
//+------------------------------------------------------------------+
#ifndef __BOSSR_CANDLE_MQH__
#define __BOSSR_CANDLE_MQH__

#include <BossR\BossR_Price.mqh>

//+------------------------------------------------------------------+
//| C_BossR_Candle                                                   |
//+------------------------------------------------------------------+
class C_BossR_Candle
{
private:
   C_BossR_Price m_price;

   double Epsilon(const double value_a,
                  const double value_b = 0.0,
                  const double value_c = 0.0,
                  const double value_d = 0.0)
   {
      double scale = MathMax(1.0, MathAbs(value_a));
      scale = MathMax(scale, MathAbs(value_b));
      scale = MathMax(scale, MathAbs(value_c));
      scale = MathMax(scale, MathAbs(value_d));

      return(scale * 0.000000000001);
   }

public:
   // ---------------------------------------------------------------
   // Deterministic OHLC validation
   // ---------------------------------------------------------------
   bool IsValid(const double open_price,
                const double high_price,
                const double low_price,
                const double close_price)
   {
      if(open_price <= 0.0 ||
         high_price <= 0.0 ||
         low_price <= 0.0 ||
         close_price <= 0.0)
      {
         return(false);
      }

      double epsilon = Epsilon(open_price,
                               high_price,
                               low_price,
                               close_price);

      if(high_price + epsilon < low_price)
         return(false);

      if(open_price > high_price + epsilon)
         return(false);

      if(open_price < low_price - epsilon)
         return(false);

      if(close_price > high_price + epsilon)
         return(false);

      if(close_price < low_price - epsilon)
         return(false);

      return(true);
   }

   // ---------------------------------------------------------------
   // Core candle measurements
   // ---------------------------------------------------------------
   double Range(const double high_price,
                const double low_price)
   {
      if(high_price < low_price)
         return(0.0);

      return(high_price - low_price);
   }

   double BodySigned(const double open_price,
                     const double close_price)
   {
      return(close_price - open_price);
   }

   double BodySize(const double open_price,
                   const double close_price)
   {
      return(MathAbs(BodySigned(open_price, close_price)));
   }

   double BodyHigh(const double open_price,
                   const double close_price)
   {
      return(MathMax(open_price, close_price));
   }

   double BodyLow(const double open_price,
                  const double close_price)
   {
      return(MathMin(open_price, close_price));
   }

   double UpperWick(const double open_price,
                    const double high_price,
                    const double close_price)
   {
      double wick = high_price - BodyHigh(open_price, close_price);

      if(wick < 0.0)
         return(0.0);

      return(wick);
   }

   double LowerWick(const double open_price,
                    const double low_price,
                    const double close_price)
   {
      double wick = BodyLow(open_price, close_price) - low_price;

      if(wick < 0.0)
         return(0.0);

      return(wick);
   }

   // ---------------------------------------------------------------
   // Derived candle prices
   // ---------------------------------------------------------------
   double MidPrice(const double high_price,
                   const double low_price)
   {
      if(high_price < low_price)
         return(0.0);

      return((high_price + low_price) * 0.5);
   }

   double TypicalPrice(const double high_price,
                       const double low_price,
                       const double close_price)
   {
      if(high_price < low_price)
         return(0.0);

      return((high_price + low_price + close_price) / 3.0);
   }

   double WeightedClose(const double high_price,
                        const double low_price,
                        const double close_price)
   {
      if(high_price < low_price)
         return(0.0);

      return((high_price + low_price + (close_price * 2.0)) * 0.25);
   }

   double AveragePrice(const double open_price,
                       const double high_price,
                       const double low_price,
                       const double close_price)
   {
      if(!IsValid(open_price, high_price, low_price, close_price))
         return(0.0);

      return((open_price + high_price + low_price + close_price) * 0.25);
   }

   // ---------------------------------------------------------------
   // Candle direction
   // ---------------------------------------------------------------
   bool IsBull(const double open_price,
               const double close_price,
               const double tolerance = 0.0)
   {
      double safe_tolerance = MathMax(0.0, tolerance);
      return(close_price > open_price + safe_tolerance);
   }

   bool IsBear(const double open_price,
               const double close_price,
               const double tolerance = 0.0)
   {
      double safe_tolerance = MathMax(0.0, tolerance);
      return(close_price < open_price - safe_tolerance);
   }

   bool IsDoji(const double open_price,
               const double close_price,
               const double tolerance = 0.0)
   {
      double safe_tolerance = MathMax(0.0, tolerance);
      return(MathAbs(close_price - open_price) <= safe_tolerance);
   }

   int Direction(const double open_price,
                 const double close_price,
                 const double tolerance = 0.0)
   {
      if(IsBull(open_price, close_price, tolerance))
         return(1);

      if(IsBear(open_price, close_price, tolerance))
         return(-1);

      return(0);
   }

   // ---------------------------------------------------------------
   // Runtime series access
   // ---------------------------------------------------------------
   bool Read(const string symbol_name,
             const int timeframe,
             const int shift,
             double &open_price,
             double &high_price,
             double &low_price,
             double &close_price,
             datetime &bar_time)
   {
      if(timeframe <= 0 || shift < 0)
         return(false);

      string resolved_symbol = symbol_name;

      if(resolved_symbol == "")
         resolved_symbol = Symbol();

      int available_bars = iBars(resolved_symbol, timeframe);

      if(available_bars <= shift)
         return(false);

      open_price  = iOpen(resolved_symbol, timeframe, shift);
      high_price  = iHigh(resolved_symbol, timeframe, shift);
      low_price   = iLow(resolved_symbol, timeframe, shift);
      close_price = iClose(resolved_symbol, timeframe, shift);
      bar_time    = iTime(resolved_symbol, timeframe, shift);

      if(bar_time <= 0)
         return(false);

      if(!IsValid(open_price, high_price, low_price, close_price))
         return(false);

      int digits_count = m_price.DigitsCount(resolved_symbol);

      open_price  = NormalizeDouble(open_price, digits_count);
      high_price  = NormalizeDouble(high_price, digits_count);
      low_price   = NormalizeDouble(low_price, digits_count);
      close_price = NormalizeDouble(close_price, digits_count);

      return(true);
   }
};

#endif
