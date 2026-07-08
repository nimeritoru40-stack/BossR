//+------------------------------------------------------------------+
//| BossR_Bar.mqh                                                    |
//+------------------------------------------------------------------+
#ifndef __BOSSR_BAR_MQH__
#define __BOSSR_BAR_MQH__

#property strict

#include <BossR\BossR_Common.mqh>
#include <BossR\BossR_Market.mqh>

class C_BossR_Bar
{
private:
   string m_symbol;
   int    m_timeframe;
   bool   m_initialized;

public:
   C_BossR_Bar()
   {
      m_symbol      = "";
      m_timeframe   = 0;
      m_initialized = false;
   }

   bool Init(const string symbol = "", const int timeframe = 0)
   {
      if(symbol == "")
         m_symbol = Symbol();
      else
         m_symbol = symbol;

      if(timeframe == 0)
         m_timeframe = Period();
      else
         m_timeframe = timeframe;

      if(m_symbol == "")
      {
         m_initialized = false;
         return false;
      }

      if(m_timeframe <= 0)
      {
         m_initialized = false;
         return false;
      }

      if(iBars(m_symbol, m_timeframe) <= 0)
      {
         m_initialized = false;
         return false;
      }

      m_initialized = true;
      return true;
   }

   void Shutdown()
   {
      m_symbol      = "";
      m_timeframe   = 0;
      m_initialized = false;
   }

   bool IsInitialized() const
   {
      return m_initialized;
   }

   string SymbolName() const
   {
      return m_symbol;
   }

   int Timeframe() const
   {
      return m_timeframe;
   }

   int Count() const
   {
      if(!m_initialized) return 0;
      return iBars(m_symbol, m_timeframe);
   }

   bool IsValidShift(const int shift) const
   {
      if(!m_initialized) return false;
      if(shift < 0) return false;
      if(shift >= Count()) return false;
      return true;
   }

   datetime TimeValue(const int shift) const
   {
      if(!IsValidShift(shift)) return 0;
      return iTime(m_symbol, m_timeframe, shift);
   }

   double OpenValue(const int shift) const
   {
      if(!IsValidShift(shift)) return 0.0;
      return iOpen(m_symbol, m_timeframe, shift);
   }

   double HighValue(const int shift) const
   {
      if(!IsValidShift(shift)) return 0.0;
      return iHigh(m_symbol, m_timeframe, shift);
   }

   double LowValue(const int shift) const
   {
      if(!IsValidShift(shift)) return 0.0;
      return iLow(m_symbol, m_timeframe, shift);
   }

   double CloseValue(const int shift) const
   {
      if(!IsValidShift(shift)) return 0.0;
      return iClose(m_symbol, m_timeframe, shift);
   }

   long VolumeValue(const int shift) const
   {
      if(!IsValidShift(shift)) return 0;
      return iVolume(m_symbol, m_timeframe, shift);
   }

   bool HasOHLC(const int shift) const
   {
      if(!IsValidShift(shift)) return false;

      double o = OpenValue(shift);
      double h = HighValue(shift);
      double l = LowValue(shift);
      double c = CloseValue(shift);

      if(o <= 0.0) return false;
      if(h <= 0.0) return false;
      if(l <= 0.0) return false;
      if(c <= 0.0) return false;

      if(h < l) return false;
      if(o > h) return false;
      if(o < l) return false;
      if(c > h) return false;
      if(c < l) return false;

      return true;
   }

   bool IsBull(const int shift) const
   {
      if(!HasOHLC(shift)) return false;
      return CloseValue(shift) > OpenValue(shift);
   }

   bool IsBear(const int shift) const
   {
      if(!HasOHLC(shift)) return false;
      return CloseValue(shift) < OpenValue(shift);
   }

   bool IsDoji(const int shift) const
   {
      if(!HasOHLC(shift)) return false;
      return CloseValue(shift) == OpenValue(shift);
   }

   double BodyPrice(const int shift) const
   {
      if(!HasOHLC(shift)) return 0.0;
      return MathAbs(CloseValue(shift) - OpenValue(shift));
   }

   double RangePrice(const int shift) const
   {
      if(!HasOHLC(shift)) return 0.0;
      return HighValue(shift) - LowValue(shift);
   }

   double UpperWickPrice(const int shift) const
   {
      if(!HasOHLC(shift)) return 0.0;

      double top_body = MathMax(OpenValue(shift), CloseValue(shift));
      return HighValue(shift) - top_body;
   }

   double LowerWickPrice(const int shift) const
   {
      if(!HasOHLC(shift)) return 0.0;

      double bottom_body = MathMin(OpenValue(shift), CloseValue(shift));
      return bottom_body - LowValue(shift);
   }

   double MidPrice(const int shift) const
   {
      if(!HasOHLC(shift)) return 0.0;
      return (HighValue(shift) + LowValue(shift)) * 0.5;
   }

   double HL2(const int shift) const
   {
      return MidPrice(shift);
   }

   double OC2(const int shift) const
   {
      if(!HasOHLC(shift)) return 0.0;
      return (OpenValue(shift) + CloseValue(shift)) * 0.5;
   }

   double HLC3(const int shift) const
   {
      if(!HasOHLC(shift)) return 0.0;
      return (HighValue(shift) + LowValue(shift) + CloseValue(shift)) / 3.0;
   }

   bool IsClosedBar(const int shift) const
   {
      if(!IsValidShift(shift)) return false;
      return shift > 0;
   }
};

#endif