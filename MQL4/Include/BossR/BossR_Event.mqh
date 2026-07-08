//+------------------------------------------------------------------+
//| BossR_Event.mqh                                                  |
//+------------------------------------------------------------------+
#ifndef __BOSSR_EVENT_MQH__
#define __BOSSR_EVENT_MQH__

#include <BossR\BossR_Common.mqh>
#include <BossR\BossR_Time.mqh>

#define BOSSR_EVENT_NONE        0
#define BOSSR_EVENT_NEW_BAR     1
#define BOSSR_EVENT_NEW_HOUR    2
#define BOSSR_EVENT_NEW_DAY     3
#define BOSSR_EVENT_NEW_WEEK    4
#define BOSSR_EVENT_NEW_MONTH   5
#define BOSSR_EVENT_NEW_SESSION 6

#define BOSSR_EVENT_MAX_ID       64
#define BOSSR_EVENT_MAX_HANDLERS 16

class C_BossR_EventHandler
{
public:
   virtual void OnEvent(const int event_id)
   {
   }
};

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
   int      m_last_session;

   int      m_session_hour;
   int      m_session_minute;

   bool     m_new_hour;
   bool     m_new_day;
   bool     m_new_week;
   bool     m_new_month;
   bool     m_new_session;

   int                   m_handler_event_ids[BOSSR_EVENT_MAX_HANDLERS];
   C_BossR_EventHandler *m_handlers[BOSSR_EVENT_MAX_HANDLERS];

private:
   void ResetHandlers()
   {
      for(int i = 0; i < BOSSR_EVENT_MAX_HANDLERS; i++)
      {
         m_handler_event_ids[i] = BOSSR_EVENT_NONE;
         m_handlers[i] = NULL;
      }
   }

   bool IsValidEventId(const int event_id) const
   {
      if(event_id <= BOSSR_EVENT_NONE)
         return false;

      if(event_id >= BOSSR_EVENT_MAX_ID)
         return false;

      return true;
   }

   int SessionKey(const datetime current_time) const
   {
      string date_text = TimeToString(current_time, TIME_DATE);

      string hour_text = IntegerToString(m_session_hour);
      if(m_session_hour < 10)
         hour_text = "0" + hour_text;

      string minute_text = IntegerToString(m_session_minute);
      if(m_session_minute < 10)
         minute_text = "0" + minute_text;

      datetime session_start =
         StrToTime(date_text + " " + hour_text + ":" + minute_text + ":00");

      datetime session_day_time = current_time;

      if(current_time < session_start)
         session_day_time = current_time - 86400;

      return TimeYear(session_day_time) * 1000 + TimeDayOfYear(session_day_time);
   }

public:
   C_BossR_Event()
   {
      m_initialized    = false;
      m_symbol         = "";
      m_timeframe      = 0;
      m_last_bar_time  = 0;
      m_new_bar        = false;

      m_last_hour      = -1;
      m_last_day       = -1;
      m_last_week      = -1;
      m_last_month     = -1;
      m_last_session   = -1;

      m_session_hour   = 0;
      m_session_minute = 0;

      m_new_hour       = false;
      m_new_day        = false;
      m_new_week       = false;
      m_new_month      = false;
      m_new_session    = false;

      ResetHandlers();
   }

   ~C_BossR_Event()
   {
      Shutdown();
   }

   bool Init()
   {
      m_initialized    = true;
      m_symbol         = Symbol();
      m_timeframe      = Period();
      m_last_bar_time  = 0;
      m_new_bar        = false;

      m_last_hour      = -1;
      m_last_day       = -1;
      m_last_week      = -1;
      m_last_month     = -1;
      m_last_session   = -1;

      m_session_hour   = 0;
      m_session_minute = 0;

      m_new_hour       = false;
      m_new_day        = false;
      m_new_week       = false;
      m_new_month      = false;
      m_new_session    = false;

      ResetHandlers();

      return true;
   }

   void Shutdown()
   {
      m_initialized    = false;
      m_symbol         = "";
      m_timeframe      = 0;
      m_last_bar_time  = 0;
      m_new_bar        = false;

      m_last_hour      = -1;
      m_last_day       = -1;
      m_last_week      = -1;
      m_last_month     = -1;
      m_last_session   = -1;

      m_session_hour   = 0;
      m_session_minute = 0;

      m_new_hour       = false;
      m_new_day        = false;
      m_new_week       = false;
      m_new_month      = false;
      m_new_session    = false;

      ResetHandlers();
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
      m_last_session  = -1;

      m_new_hour      = false;
      m_new_day       = false;
      m_new_week      = false;
      m_new_month     = false;
      m_new_session   = false;

      return true;
   }

   bool ConfigureSession(const int hour, const int minute)
   {
      if(hour < 0 || hour > 23)
         return false;

      if(minute < 0 || minute > 59)
         return false;

      m_session_hour   = hour;
      m_session_minute = minute;
      m_last_session   = -1;
      m_new_session    = false;

      return true;
   }

   bool RegisterHandler(const int event_id, C_BossR_EventHandler &handler)
   {
      if(!IsValidEventId(event_id))
         return false;

      C_BossR_EventHandler *handler_ptr = GetPointer(handler);

      if(handler_ptr == NULL)
         return false;

      for(int i = 0; i < BOSSR_EVENT_MAX_HANDLERS; i++)
      {
         if(m_handler_event_ids[i] == event_id && m_handlers[i] == handler_ptr)
            return false;
      }

      for(int j = 0; j < BOSSR_EVENT_MAX_HANDLERS; j++)
      {
         if(m_handlers[j] == NULL)
         {
            m_handler_event_ids[j] = event_id;
            m_handlers[j] = handler_ptr;
            return true;
         }
      }

      return false;
   }

   bool UnregisterHandler(const int event_id, C_BossR_EventHandler &handler)
   {
      if(!IsValidEventId(event_id))
         return false;

      C_BossR_EventHandler *handler_ptr = GetPointer(handler);

      if(handler_ptr == NULL)
         return false;

      for(int i = 0; i < BOSSR_EVENT_MAX_HANDLERS; i++)
      {
         if(m_handler_event_ids[i] == event_id && m_handlers[i] == handler_ptr)
         {
            m_handler_event_ids[i] = BOSSR_EVENT_NONE;
            m_handlers[i] = NULL;
            return true;
         }
      }

      return false;
   }

   void ClearHandlers()
   {
      ResetHandlers();
   }

   int HandlerCount() const
   {
      int count = 0;

      for(int i = 0; i < BOSSR_EVENT_MAX_HANDLERS; i++)
      {
         if(m_handlers[i] != NULL)
            count++;
      }

      return count;
   }

   int FireEvent(const int event_id)
   {
      if(!IsValidEventId(event_id))
         return 0;

      int fired = 0;

      for(int i = 0; i < BOSSR_EVENT_MAX_HANDLERS; i++)
      {
         if(m_handler_event_ids[i] == event_id && m_handlers[i] != NULL)
         {
            m_handlers[i].OnEvent(event_id);
            fired++;
         }
      }

      return fired;
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
      m_new_bar     = false;
      m_new_hour    = false;
      m_new_day     = false;
      m_new_week    = false;
      m_new_month   = false;
      m_new_session = false;

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

      int current_session = SessionKey(current_bar_time);

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

      if(m_last_session < 0)
         m_last_session = current_session;
      else if(current_session != m_last_session)
      {
         m_last_session = current_session;
         m_new_session = true;
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
         m_new_bar     = false;
         m_new_hour    = false;
         m_new_day     = false;
         m_new_week    = false;
         m_new_month   = false;
         m_new_session = false;
         return false;
      }

      if(m_symbol == "" || m_timeframe <= 0)
      {
         m_new_bar     = false;
         m_new_hour    = false;
         m_new_day     = false;
         m_new_week    = false;
         m_new_month   = false;
         m_new_session = false;
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

   bool IsNewSession() const
   {
      return m_new_session;
   }
};

#endif