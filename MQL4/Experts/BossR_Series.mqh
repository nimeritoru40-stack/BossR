//+------------------------------------------------------------------+
//| BossR_Series.mqh                                                 |
//+------------------------------------------------------------------+
#ifndef __BOSSR_SERIES_MQH__
#define __BOSSR_SERIES_MQH__

#property strict

#include <BossR\BossR_Common.mqh>
#include <BossR\BossR_Bar.mqh>

class C_BossR_Series
{
private:
   C_BossR_Bar m_bar;
   bool        m_initialized;

public:
   C_BossR_Series()
   {
      m_initialized = false;
   }

   bool Init(const string symbol = "", const int timeframe = 0)
   {
      m_initialized = false;

      if(!m_bar.Init(symbol, timeframe))
         return false;

      m_initialized = true;
      return true;
   }

   void Shutdown()
   {
      m_bar.Shutdown();
      m_initialized = false;
   }

   bool IsInitialized() const
   {
      return m_initialized;
   }

   string SymbolName() const
   {
      return m_bar.SymbolName();
   }

   int Timeframe() const
   {
      return m_bar.Timeframe();
   }

   int Count() const
   {
      if(!m_initialized) return 0;
      return m_bar.Count();
   }

   bool HasClosedBars(const int bars_required) const
   {
      if(!m_initialized) return false;
      if(bars_required <= 0) return false;
      return Count() > bars_required;
   }

   bool IsValidClosedWindow(const int start_shift, const int length) const
   {
      if(!m_initialized) return false;
      if(start_shift < 1) return false;
      if(length <= 0) return false;
      if(start_shift + length - 1 >= Count()) return false;
      return true;
   }

   int HighestHighShift(const int start_shift, const int length) const
   {
      if(!IsValidClosedWindow(start_shift, length)) return -1;

      int best_shift = start_shift;
      double best_value = m_bar.HighValue(start_shift);

      for(int i = start_shift + 1; i < start_shift + length; i++)
      {
         double v = m_bar.HighValue(i);
         if(v > best_value)
         {
            best_value = v;
            best_shift = i;
         }
      }

      return best_shift;
   }

   int LowestLowShift(const int start_shift, const int length) const
   {
      if(!IsValidClosedWindow(start_shift, length)) return -1;

      int best_shift = start_shift;
      double best_value = m_bar.LowValue(start_shift);

      for(int i = start_shift + 1; i < start_shift + length; i++)
      {
         double v = m_bar.LowValue(i);
         if(v < best_value)
         {
            best_value = v;
            best_shift = i;
         }
      }

      return best_shift;
   }

   double HighestHigh(const int start_shift, const int length) const
   {
      int shift = HighestHighShift(start_shift, length);
      if(shift < 0) return 0.0;
      return m_bar.HighValue(shift);
   }

   double LowestLow(const int start_shift, const int length) const
   {
      int shift = LowestLowShift(start_shift, length);
      if(shift < 0) return 0.0;
      return m_bar.LowValue(shift);
   }

   double WindowRange(const int start_shift, const int length) const
   {
      if(!IsValidClosedWindow(start_shift, length)) return 0.0;
      return HighestHigh(start_shift, length) - LowestLow(start_shift, length);
   }

   double AverageBody(const int start_shift, const int length) const
   {
      if(!IsValidClosedWindow(start_shift, length)) return 0.0;

      double sum = 0.0;

      for(int i = start_shift; i < start_shift + length; i++)
         sum += m_bar.BodyPrice(i);

      return sum / length;
   }

   double AverageRange(const int start_shift, const int length) const
   {
      if(!IsValidClosedWindow(start_shift, length)) return 0.0;

      double sum = 0.0;

      for(int i = start_shift; i < start_shift + length; i++)
         sum += m_bar.RangePrice(i);

      return sum / length;
   }

   int BullCount(const int start_shift, const int length) const
   {
      if(!IsValidClosedWindow(start_shift, length)) return 0;

      int count = 0;

      for(int i = start_shift; i < start_shift + length; i++)
      {
         if(m_bar.IsBull(i))
            count++;
      }

      return count;
   }

   int BearCount(const int start_shift, const int length) const
   {
      if(!IsValidClosedWindow(start_shift, length)) return 0;

      int count = 0;

      for(int i = start_shift; i < start_shift + length; i++)
      {
         if(m_bar.IsBear(i))
            count++;
      }

      return count;
   }

   int DojiCount(const int start_shift, const int length) const
   {
      if(!IsValidClosedWindow(start_shift, length)) return 0;

      int count = 0;

      for(int i = start_shift; i < start_shift + length; i++)
      {
         if(m_bar.IsDoji(i))
            count++;
      }

      return count;
   }

   bool AllBull(const int start_shift, const int length) const
   {
      if(!IsValidClosedWindow(start_shift, length)) return false;
      return BullCount(start_shift, length) == length;
   }

   bool AllBear(const int start_shift, const int length) const
   {
      if(!IsValidClosedWindow(start_shift, length)) return false;
      return BearCount(start_shift, length) == length;
   }

   bool ContainsBull(const int start_shift, const int length) const
   {
      if(!IsValidClosedWindow(start_shift, length)) return false;
      return BullCount(start_shift, length) > 0;
   }

   bool ContainsBear(const int start_shift, const int length) const
   {
      if(!IsValidClosedWindow(start_shift, length)) return false;
      return BearCount(start_shift, length) > 0;
   }
};

#endif