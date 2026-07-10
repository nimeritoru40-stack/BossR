//+------------------------------------------------------------------+
//| BossR_Indicator.mqh                                              |
//| BossR Framework - Indicator Foundation                           |
//| Block 6                                                          |
//+------------------------------------------------------------------+
#ifndef __BOSSR_INDICATOR_MQH__
#define __BOSSR_INDICATOR_MQH__

class C_BossR_Indicator
{
private:
   bool            m_initialized;
   string          m_symbol;
   ENUM_TIMEFRAMES m_timeframe;
   string          m_name;
   string          m_short_name;
   string          m_description;

   string NormalizeSymbol(const string symbol) const
   {
      if(StringLen(symbol) <= 0)
         return Symbol();
      return symbol;
   }

   ENUM_TIMEFRAMES NormalizeTimeframe(const ENUM_TIMEFRAMES timeframe) const
   {
      if(timeframe == PERIOD_CURRENT)
         return (ENUM_TIMEFRAMES)Period();
      return timeframe;
   }

   void ResetMetadata(void)
   {
      m_name        = "BossR_Indicator";
      m_short_name  = "BossR";
      m_description = "";
   }

public:
   C_BossR_Indicator(void)
   {
      m_initialized = false;
      m_symbol      = Symbol();
      m_timeframe   = (ENUM_TIMEFRAMES)Period();
      ResetMetadata();
   }

   ~C_BossR_Indicator(void)
   {
      Shutdown();
   }

   bool IsValidSymbol(const string symbol) const
   {
      string resolved_symbol = NormalizeSymbol(symbol);
      if(StringLen(resolved_symbol) <= 0)
         return false;
      return (MarketInfo(resolved_symbol, MODE_POINT) > 0.0);
   }

   bool IsValidTimeframe(const ENUM_TIMEFRAMES timeframe) const
   {
      ENUM_TIMEFRAMES resolved_timeframe = NormalizeTimeframe(timeframe);

      switch(resolved_timeframe)
      {
         case PERIOD_M1:
         case PERIOD_M5:
         case PERIOD_M15:
         case PERIOD_M30:
         case PERIOD_H1:
         case PERIOD_H4:
         case PERIOD_D1:
         case PERIOD_W1:
         case PERIOD_MN1:
            return true;
      }
      return false;
   }

   bool Initialize(
      const string symbol = "",
      const ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT
   )
   {
      string resolved_symbol = NormalizeSymbol(symbol);
      ENUM_TIMEFRAMES resolved_timeframe = NormalizeTimeframe(timeframe);

      if(!IsValidSymbol(resolved_symbol))
         return false;
      if(!IsValidTimeframe(resolved_timeframe))
         return false;

      m_symbol      = resolved_symbol;
      m_timeframe   = resolved_timeframe;
      m_initialized = true;
      return true;
   }

   void Shutdown(void)
   {
      m_initialized = false;
   }

   void Reset(void)
   {
      m_initialized = false;
      m_symbol      = Symbol();
      m_timeframe   = (ENUM_TIMEFRAMES)Period();
      ResetMetadata();
   }

   bool IsInitialized(void) const
   {
      return m_initialized;
   }

   bool IsConfigured(void) const
   {
      if(!m_initialized)
         return false;
      if(!IsValidSymbol(m_symbol))
         return false;
      if(!IsValidTimeframe(m_timeframe))
         return false;
      if(StringLen(m_name) <= 0)
         return false;
      if(StringLen(m_short_name) <= 0)
         return false;
      return true;
   }

   bool SetSymbol(const string symbol)
   {
      string resolved_symbol = NormalizeSymbol(symbol);
      if(!IsValidSymbol(resolved_symbol))
         return false;
      m_symbol = resolved_symbol;
      return true;
   }

   string GetSymbol(void) const
   {
      return m_symbol;
   }

   bool SetTimeframe(const ENUM_TIMEFRAMES timeframe)
   {
      ENUM_TIMEFRAMES resolved_timeframe = NormalizeTimeframe(timeframe);
      if(!IsValidTimeframe(resolved_timeframe))
         return false;
      m_timeframe = resolved_timeframe;
      return true;
   }

   ENUM_TIMEFRAMES GetTimeframe(void) const
   {
      return m_timeframe;
   }

   bool SetName(const string name)
   {
      if(StringLen(name) <= 0)
         return false;
      m_name = name;
      return true;
   }

   string GetName(void) const
   {
      return m_name;
   }

   bool SetShortName(const string short_name)
   {
      if(StringLen(short_name) <= 0)
         return false;
      m_short_name = short_name;
      return true;
   }

   string GetShortName(void) const
   {
      return m_short_name;
   }

   bool SetDescription(const string description)
   {
      m_description = description;
      return true;
   }

   string GetDescription(void) const
   {
      return m_description;
   }

   void ClearDescription(void)
   {
      m_description = "";
   }

   int BarsCount(void) const
   {
      if(!IsValidSymbol(m_symbol))
         return 0;
      if(!IsValidTimeframe(m_timeframe))
         return 0;

      int bars = iBars(m_symbol, (int)m_timeframe);
      if(bars < 0)
         return 0;
      return bars;
   }

   int GetBarsCount(void) const
   {
      return BarsCount();
   }

   bool IsSeriesReady(const int minimum_bars = 1) const
   {
      if(!IsConfigured())
         return false;
      if(minimum_bars < 1)
         return false;
      return (BarsCount() >= minimum_bars);
   }

   bool IsValidShift(const int shift) const
   {
      if(shift < 0)
         return false;

      int bars = BarsCount();
      if(bars <= 0)
         return false;

      return (shift < bars);
   }

   double GetOpen(const int shift) const
   {
      if(!IsValidShift(shift))
         return 0.0;
      return iOpen(m_symbol, (int)m_timeframe, shift);
   }

   double GetHigh(const int shift) const
   {
      if(!IsValidShift(shift))
         return 0.0;
      return iHigh(m_symbol, (int)m_timeframe, shift);
   }

   double GetLow(const int shift) const
   {
      if(!IsValidShift(shift))
         return 0.0;
      return iLow(m_symbol, (int)m_timeframe, shift);
   }

   double GetClose(const int shift) const
   {
      if(!IsValidShift(shift))
         return 0.0;
      return iClose(m_symbol, (int)m_timeframe, shift);
   }

   datetime GetTime(const int shift) const
   {
      if(!IsValidShift(shift))
         return (datetime)0;
      return iTime(m_symbol, (int)m_timeframe, shift);
   }

   long GetVolume(const int shift) const
   {
      if(!IsValidShift(shift))
         return 0;
      return iVolume(m_symbol, (int)m_timeframe, shift);
   }

   bool TryGetOpen(const int shift, double &value) const
   {
      value = 0.0;
      if(!IsValidShift(shift))
         return false;
      value = iOpen(m_symbol, (int)m_timeframe, shift);
      return true;
   }

   bool TryGetHigh(const int shift, double &value) const
   {
      value = 0.0;
      if(!IsValidShift(shift))
         return false;
      value = iHigh(m_symbol, (int)m_timeframe, shift);
      return true;
   }

   bool TryGetLow(const int shift, double &value) const
   {
      value = 0.0;
      if(!IsValidShift(shift))
         return false;
      value = iLow(m_symbol, (int)m_timeframe, shift);
      return true;
   }

   bool TryGetClose(const int shift, double &value) const
   {
      value = 0.0;
      if(!IsValidShift(shift))
         return false;
      value = iClose(m_symbol, (int)m_timeframe, shift);
      return true;
   }

   bool TryGetTime(const int shift, datetime &value) const
   {
      value = (datetime)0;
      if(!IsValidShift(shift))
         return false;
      value = iTime(m_symbol, (int)m_timeframe, shift);
      return true;
   }

   bool TryGetVolume(const int shift, long &value) const
   {
      value = 0;
      if(!IsValidShift(shift))
         return false;
      value = iVolume(m_symbol, (int)m_timeframe, shift);
      return true;
   }

   double GetRange(const int shift) const
   {
      if(!IsValidShift(shift))
         return 0.0;
      return (GetHigh(shift) - GetLow(shift));
   }

   double GetBody(const int shift) const
   {
      if(!IsValidShift(shift))
         return 0.0;
      return MathAbs(GetClose(shift) - GetOpen(shift));
   }

   double GetUpperWick(const int shift) const
   {
      if(!IsValidShift(shift))
         return 0.0;

      double wick = GetHigh(shift) -
                    MathMax(GetOpen(shift), GetClose(shift));

      if(wick < 0.0)
         return 0.0;
      return wick;
   }

   double GetLowerWick(const int shift) const
   {
      if(!IsValidShift(shift))
         return 0.0;

      double wick = MathMin(GetOpen(shift), GetClose(shift)) -
                    GetLow(shift);

      if(wick < 0.0)
         return 0.0;
      return wick;
   }

   bool IsBullish(const int shift) const
   {
      if(!IsValidShift(shift))
         return false;
      return (GetClose(shift) > GetOpen(shift));
   }

   bool IsBearish(const int shift) const
   {
      if(!IsValidShift(shift))
         return false;
      return (GetClose(shift) < GetOpen(shift));
   }

   bool IsDoji(
      const int shift,
      const double tolerance = 0.0
   ) const
   {
      if(!IsValidShift(shift))
         return false;
      if(tolerance < 0.0)
         return false;
      return (GetBody(shift) <= tolerance);
   }

   double GetMedianPrice(const int shift) const
   {
      if(!IsValidShift(shift))
         return 0.0;
      return (GetHigh(shift) + GetLow(shift)) / 2.0;
   }

   double GetTypicalPrice(const int shift) const
   {
      if(!IsValidShift(shift))
         return 0.0;
      return (GetHigh(shift) + GetLow(shift) + GetClose(shift)) / 3.0;
   }

   double GetWeightedPrice(const int shift) const
   {
      if(!IsValidShift(shift))
         return 0.0;

      return (
         GetHigh(shift)
         + GetLow(shift)
         + (2.0 * GetClose(shift))
      ) / 4.0;
   }

   // Block 5 --------------------------------------------------------

   double GetSignedBody(const int shift) const
   {
      if(!IsValidShift(shift))
         return 0.0;
      return (GetClose(shift) - GetOpen(shift));
   }

   double GetBodyRatio(const int shift) const
   {
      if(!IsValidShift(shift))
         return 0.0;

      double range = GetRange(shift);
      if(range <= 0.0)
         return 0.0;

      return GetBody(shift) / range;
   }

   double GetUpperWickRatio(const int shift) const
   {
      if(!IsValidShift(shift))
         return 0.0;

      double range = GetRange(shift);
      if(range <= 0.0)
         return 0.0;

      return GetUpperWick(shift) / range;
   }

   double GetLowerWickRatio(const int shift) const
   {
      if(!IsValidShift(shift))
         return 0.0;

      double range = GetRange(shift);
      if(range <= 0.0)
         return 0.0;

      return GetLowerWick(shift) / range;
   }

   double GetBodyPercent(const int shift) const
   {
      return GetBodyRatio(shift) * 100.0;
   }

   double GetUpperWickPercent(const int shift) const
   {
      return GetUpperWickRatio(shift) * 100.0;
   }

   double GetLowerWickPercent(const int shift) const
   {
      return GetLowerWickRatio(shift) * 100.0;
   }

   double GetClosePosition(const int shift) const
   {
      if(!IsValidShift(shift))
         return 0.0;

      double range = GetRange(shift);
      if(range <= 0.0)
         return 0.0;

      return (GetClose(shift) - GetLow(shift)) / range;
   }

   double GetClosePositionPercent(const int shift) const
   {
      return GetClosePosition(shift) * 100.0;
   }
   // Block 6 --------------------------------------------------------

   double GetTrueRange(const int shift) const
   {
      if(!IsValidShift(shift))
         return 0.0;

      double high = GetHigh(shift);
      double low = GetLow(shift);
      double range = high - low;

      int previous_shift = shift + 1;
      if(!IsValidShift(previous_shift))
         return range;

      double previous_close = GetClose(previous_shift);
      double high_gap = MathAbs(high - previous_close);
      double low_gap = MathAbs(low - previous_close);

      return MathMax(range, MathMax(high_gap, low_gap));
   }

   double GetGap(const int shift) const
   {
      if(!IsValidShift(shift))
         return 0.0;

      int previous_shift = shift + 1;
      if(!IsValidShift(previous_shift))
         return 0.0;

      return GetOpen(shift) - GetClose(previous_shift);
   }

   double GetGapPercent(const int shift) const
   {
      if(!IsValidShift(shift))
         return 0.0;

      int previous_shift = shift + 1;
      if(!IsValidShift(previous_shift))
         return 0.0;

      double previous_close = GetClose(previous_shift);
      if(previous_close == 0.0)
         return 0.0;

      return (GetGap(shift) / previous_close) * 100.0;
   }

   bool IsGapUp(const int shift) const
   {
      return (GetGap(shift) > 0.0);
   }

   bool IsGapDown(const int shift) const
   {
      return (GetGap(shift) < 0.0);
   }

   double GetMidpointPosition(const int shift) const
   {
      if(!IsValidShift(shift))
         return 0.0;

      double range = GetRange(shift);
      if(range <= 0.0)
         return 0.0;

      double midpoint = (GetOpen(shift) + GetClose(shift)) / 2.0;
      return (midpoint - GetLow(shift)) / range;
   }

   double GetMidpointPositionPercent(const int shift) const
   {
      return GetMidpointPosition(shift) * 100.0;
   }

   double GetCloseChange(const int shift) const
   {
      if(!IsValidShift(shift))
         return 0.0;

      int previous_shift = shift + 1;
      if(!IsValidShift(previous_shift))
         return 0.0;

      return GetClose(shift) - GetClose(previous_shift);
   }

   double GetCloseChangePercent(const int shift) const
   {
      if(!IsValidShift(shift))
         return 0.0;

      int previous_shift = shift + 1;
      if(!IsValidShift(previous_shift))
         return 0.0;

      double previous_close = GetClose(previous_shift);
      if(previous_close == 0.0)
         return 0.0;

      return (GetCloseChange(shift) / previous_close) * 100.0;
   }

};

#endif
