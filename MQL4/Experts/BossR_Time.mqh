//+------------------------------------------------------------------+
//| BossR_Time.mqh                                                   |
//+------------------------------------------------------------------+
#ifndef __BOSSR_TIME_MQH__
#define __BOSSR_TIME_MQH__

#property strict

#include <BossR\BossR_Common.mqh>

class C_BossR_Time
{
private:
   bool m_initialized;

public:
   C_BossR_Time(){ m_initialized = false; }
   ~C_BossR_Time(){}

   bool Init(){ m_initialized = true; return true; }
   void Shutdown(){ m_initialized = false; }
   bool IsInitialized() const{ return m_initialized; }

   datetime Now() const{ return TimeCurrent(); }
   datetime LocalNow() const{ return TimeLocal(); }

   string ToDateString(const datetime value) const{ return TimeToString(value, TIME_DATE); }
   string ToTimeString(const datetime value) const{ return TimeToString(value, TIME_SECONDS); }
   string ToDateTimeString(const datetime value) const{ return TimeToString(value, TIME_DATE | TIME_SECONDS); }

   int Year(const datetime value) const{ return TimeYear(value); }
   int Month(const datetime value) const{ return TimeMonth(value); }
   int Day(const datetime value) const{ return TimeDay(value); }
   int Hour(const datetime value) const{ return TimeHour(value); }
   int Minute(const datetime value) const{ return TimeMinute(value); }
   int Second(const datetime value) const{ return TimeSeconds(value); }

   int DayOfWeek(const datetime value) const{ return TimeDayOfWeek(value); }

   bool IsWeekend(const datetime value) const
   {
      int dow = TimeDayOfWeek(value);
      return (dow == 0 || dow == 6);
   }

   bool IsWeekday(const datetime value) const
   {
      return !IsWeekend(value);
   }

   datetime StartOfDay(const datetime value) const
   {
      return StrToTime(TimeToString(value, TIME_DATE));
   }

   datetime StartOfHour(const datetime value) const
   {
      return value - (TimeMinute(value) * 60) - TimeSeconds(value);
   }

   datetime StartOfMinute(const datetime value) const
   {
      return value - TimeSeconds(value);
   }

   bool SameDay(const datetime a, const datetime b) const{ return (StartOfDay(a) == StartOfDay(b)); }
   bool SameHour(const datetime a, const datetime b) const{ return (StartOfHour(a) == StartOfHour(b)); }
   bool SameMinute(const datetime a, const datetime b) const{ return (StartOfMinute(a) == StartOfMinute(b)); }

   int TimeframeSeconds(const int timeframe) const
   {
      switch(timeframe)
      {
         case PERIOD_M1:  return 60;
         case PERIOD_M5:  return 300;
         case PERIOD_M15: return 900;
         case PERIOD_M30: return 1800;
         case PERIOD_H1:  return 3600;
         case PERIOD_H4:  return 14400;
         case PERIOD_D1:  return 86400;
         case PERIOD_W1:  return 604800;
         case PERIOD_MN1: return 0;
      }

      return 0;
   }

   datetime StartOfMonth(const datetime value) const
   {
      string text = StringFormat("%04d.%02d.01 00:00:00", TimeYear(value), TimeMonth(value));
      return StrToTime(text);
   }

   datetime StartOfWeek(const datetime value) const
   {
      datetime day_start = StartOfDay(value);
      int dow = TimeDayOfWeek(value);

      if(dow == 0)
         return day_start - (6 * 86400);

      return day_start - ((dow - 1) * 86400);
   }

   datetime StartOfBar(const datetime value, const int timeframe) const
   {
      if(timeframe == PERIOD_MN1)
         return StartOfMonth(value);

      if(timeframe == PERIOD_W1)
         return StartOfWeek(value);

      if(timeframe == PERIOD_D1)
         return StartOfDay(value);

      int seconds = TimeframeSeconds(timeframe);

      if(seconds <= 0)
         return 0;

      return value - (value % seconds);
   }

   bool IsBarOpenTime(const datetime value, const int timeframe) const
   {
      return (value == StartOfBar(value, timeframe));
   }

   bool SameBar(const datetime a, const datetime b, const int timeframe) const
   {
      return (StartOfBar(a, timeframe) == StartOfBar(b, timeframe));
   }
};

#endif