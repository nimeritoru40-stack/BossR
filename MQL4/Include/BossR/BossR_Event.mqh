//+------------------------------------------------------------------+
//| BossR_Event.mqh                                                  |
//+------------------------------------------------------------------+
#ifndef __BOSSR_EVENT_MQH__
#define __BOSSR_EVENT_MQH__

#include <BossR\BossR_Common.mqh>
#include <BossR\BossR_Time.mqh>

class C_BossR_Event
{
private:
   bool     m_initialized;
   string   m_symbol;
   int      m_timeframe;
   datetime m_last_bar_time;
   bool     m_new_bar;

   int      m_last_hour;
   int      m_last_day;
   int      m_last_week;
   int      m_last_month;

   bool     m_new_hour;
   bool     m_new_day;
   bool     m_new_week;
   bool     m_new_month;

public:
   C_BossR_Event()
   {
      m_initialized   = false;
      m_symbol        = "";
      m_timeframe     = 0;
      m_last_bar_time = 0;
      m_new_bar       = false;

      m_last_hour     = -1;
      m_last_day      = -1;
      m_last_week     = -1;
      m_last_month    = -1;

      m_new_hour      = false;
      m_new_day       = false;
      m_new_week      = false;
      m_new_month     = false;
   }

   ~C_BossR_Event()
   {
      Shutdown();
   }

   bool Init()
   {
      m_initialized   = true;
      m_symbol        = Symbol();
      m_timeframe     = Period();
      m_last_bar_time = 0;
      m_new_bar       = false;

      m_last_hour     = -1;
      m_last_day      = -1;
      m_last_week     = -1;
      m_last_month    = -1;

      m_new_hour      = false;
      m_new_day       = false;
      m_new_week      = false;
      m_new_month     = false;

      return true;
   }

   void Shutdown()
   {
      m_initialized   = false;
      m_symbol        = "";
      m_timeframe     = 0;
      m_last_bar_time = 0;
      m_new_bar       = false;

      m_last_hour     = -1;
      m_last_day      = -1;
      m_last_week     = -1;
      m_last_month    = -1;

      m_new_hour      = false;
      m_new_day       = false;
      m_new_week      = false;
      m_new_month     = false;
   }

   bool IsInitialized() const
   {
      return m_initialized;
   }

   string ModuleName() const
   {
      return "BossR_Event";
   }

   bool Configure(const string symbol, const int timeframe)
   {
      if(symbol == "")
         return false;

      if(timeframe <= 0)
         return false;

      m_symbol        = symbol;
      m_timeframe     = timeframe;
      m_last_bar_time = 0;
      m_new_bar       = false;

      m_last_hour     = -1;
      m_last_day      = -1;
      m_last_week     = -1;
      m_last_month    = -1;

      m_new_hour      = false;
      m_new_day       = false;
      m_new_week      = false;
      m_new_month     = false;

      return true;
   }

   string EventSymbol() const
   {
      return m_symbol;
   }

   int EventTimeframe() const
   {
      return m_timeframe;
   }

   datetime LastBarTime() const
   {
      return m_last_bar_time;
   }

   bool PollAt(const datetime current_bar_time)
   {
      m_new_bar   = false;
      m_new_hour  = false;
      m_new_day   = false;
      m_new_week  = false;
      m_new_month = false;

      if(!m_initialized)
         return false;

      if(m_symbol == "" || m_timeframe <= 0)
         return false;

      if(current_bar_time <= 0)
         return false;

      int current_hour =
         TimeYear(current_bar_time) * 100000 +
         TimeDayOfYear(current_bar_time) * 100 +
         TimeHour(current_bar_time);

      int current_day =
         TimeYear(current_bar_time) * 1000 +
         TimeDayOfYear(current_bar_time);

      int current_week =
         TimeYear(current_bar_time) * 100 +
         TimeDayOfYear(current_bar_time) / 7;

      int current_month =
         TimeYear(current_bar_time) * 100 +
         TimeMonth(current_bar_time);

      if(m_last_hour < 0)
         m_last_hour = current_hour;
      else if(current_hour != m_last_hour)
      {
         m_last_hour = current_hour;
         m_new_hour = true;
      }

      if(m_last_day < 0)
         m_last_day = current_day;
      else if(current_day != m_last_day)
      {
         m_last_day = current_day;
         m_new_day = true;
      }

      if(m_last_week < 0)
         m_last_week = current_week;
      else if(current_week != m_last_week)
      {
         m_last_week = current_week;
         m_new_week = true;
      }

      if(m_last_month < 0)
         m_last_month = current_month;
      else if(current_month != m_last_month)
      {
         m_last_month = current_month;
         m_new_month = true;
      }

      if(m_last_bar_time == 0)
      {
         m_last_bar_time = current_bar_time;
         m_new_bar = false;
         return true;
      }

      if(current_bar_time != m_last_bar_time)
      {
         m_last_bar_time = current_bar_time;
         m_new_bar = true;
         return true;
      }

      return true;
   }

   bool Poll()
   {
      if(!m_initialized)
      {
         m_new_bar   = false;
         m_new_hour  = false;
         m_new_day   = false;
         m_new_week  = false;
         m_new_month = false;
         return false;
      }

      if(m_symbol == "" || m_timeframe <= 0)
      {
         m_new_bar   = false;
         m_new_hour  = false;
         m_new_day   = false;
         m_new_week  = false;
         m_new_month = false;
         return false;
      }

      datetime current_bar_time = iTime(m_symbol, m_timeframe, 0);
      return PollAt(current_bar_time);
   }

   bool IsNewBar() const
   {
      return m_new_bar;
   }

   bool IsNewHour() const
   {
      return m_new_hour;
   }

   bool IsNewDay() const
   {
      return m_new_day;
   }

   bool IsNewWeek() const
   {
      return m_new_week;
   }

   bool IsNewMonth() const
   {
      return m_new_month;
   }
};

#endif