//+------------------------------------------------------------------+
//| BossR_Event_Test.mq4                                             |
//+------------------------------------------------------------------+
#property strict

#include <BossR\BossR_Event.mqh>

#define EVT_NONE   1
#define EVT_STRING 2
#define EVT_INT    3
#define EVT_DOUBLE 4
#define EVT_BOOL   5
#define EVT_ORDER  6
#define EVT_CHAIN  7

int PASS = 0;
int FAIL = 0;

void Check(const bool condition, const string name)
{
   if(condition)
   {
      PASS++;
      Print("PASS: ", name);
   }
   else
   {
      FAIL++;
      Print("FAIL: ", name);
   }
}

class C_TestHandler : public C_BossR_EventHandler
{
public:
   int    calls;
   int    last_event_id;
   int    last_type;
   string last_string;
   int    last_int;
   double last_double;
   bool   last_bool;
   string order_log;

   C_TestHandler()
   {
      Reset();
   }

   void Reset()
   {
      calls         = 0;
      last_event_id = 0;
      last_type     = -1;
      last_string   = "";
      last_int      = 0;
      last_double   = 0.0;
      last_bool     = false;
      order_log     = "";
   }

   virtual void HandleEvent(C_BossR_Event &event)
   {
      calls++;
      last_event_id = event.EventId();
      last_type     = event.Type();
      last_string   = event.StringValue();
      last_int      = event.IntValue();
      last_double   = event.DoubleValue();
      last_bool     = event.BoolValue();
   }
};

class C_OrderHandler : public C_BossR_EventHandler
{
public:
   string tag;
   string *log;

   void Init(const string t, string &shared_log)
   {
      tag = t;
      log = &shared_log;
   }

   virtual void HandleEvent(C_BossR_Event &event)
   {
      if(log != NULL)
         *log = *log + tag;
   }
};

class C_ChainHandler : public C_BossR_EventHandler
{
public:
   C_BossR_EventBus *bus;
   int calls;

   void Init(C_BossR_EventBus &b)
   {
      bus = &b;
      calls = 0;
   }

   virtual void HandleEvent(C_BossR_Event &event)
   {
      calls++;
      if(bus != NULL)
         bus.Publish(EVT_INT, 777);
   }
};

int OnInit()
{
   C_BossR_EventBus bus;

   C_TestHandler h1;
   C_TestHandler h2;
   C_TestHandler h3;

   Check(bus.CountHandlers() == 0, "01 empty handler count");
   Check(bus.CountQueued() == 0, "02 empty queue count");
   Check(!bus.IsDispatching(), "03 not dispatching initially");
   Check(!bus.RegisterHandler(0, &h1), "04 reject event id zero");
   Check(!bus.RegisterHandler(-1, &h1), "05 reject negative event id");
   Check(!bus.RegisterHandler(EVT_NONE, NULL), "06 reject null handler");
   Check(bus.RegisterHandler(EVT_NONE, &h1), "07 register h1");
   Check(bus.CountHandlers() == 1, "08 count all after register");
   Check(bus.CountHandlers(EVT_NONE) == 1, "09 count event handlers");
   Check(bus.RegisterHandler(EVT_NONE, &h1), "10 duplicate register is idempotent");
   Check(bus.CountHandlers() == 1, "11 duplicate did not increase count");
   Check(bus.RegisterHandler(EVT_NONE, &h2), "12 register h2 same event");
   Check(bus.CountHandlers(EVT_NONE) == 2, "13 same event count two");
   Check(bus.RegisterHandler(EVT_STRING, &h3), "14 register h3 different event");
   Check(bus.CountHandlers() == 3, "15 total handlers three");
   Check(bus.CountHandlers(EVT_STRING) == 1, "16 string event handler count");
   Check(bus.CountHandlers(999) == 0, "17 unknown event handler count zero");

   Check(bus.Publish(EVT_NONE), "18 publish none");
   Check(bus.CountQueued() == 1, "19 queue count one");
   Check(bus.Dispatch() == 1, "20 dispatch one event");
   Check(bus.CountQueued() == 0, "21 queue empty after dispatch");
   Check(h1.calls == 1, "22 h1 received none");
   Check(h2.calls == 1, "23 h2 received none");
   Check(h3.calls == 0, "24 h3 ignored different event");
   Check(h1.last_event_id == EVT_NONE, "25 h1 event id none");
   Check(h1.last_type == BOSSR_EVENT_NONE, "26 h1 type none");

   h1.Reset(); h2.Reset(); h3.Reset();
   Check(bus.Publish(EVT_STRING, "BossR"), "27 publish string");
   Check(bus.Dispatch() == 1, "28 dispatch string");
   Check(h3.calls == 1, "29 h3 received string");
   Check(h3.last_type == BOSSR_EVENT_STRING, "30 string type ok");
   Check(h3.last_string == "BossR", "31 string payload ok");
   Check(h1.calls == 0, "32 h1 ignored string");
   Check(h2.calls == 0, "33 h2 ignored string");

   Check(bus.RegisterHandler(EVT_INT, &h1), "34 register int handler");
   Check(bus.Publish(EVT_INT, 42), "35 publish int");
   Check(bus.Dispatch() == 1, "36 dispatch int");
   Check(h1.calls == 1, "37 h1 received int");
   Check(h1.last_type == BOSSR_EVENT_INT, "38 int type ok");
   Check(h1.last_int == 42, "39 int payload ok");

   h1.Reset();
   Check(bus.RegisterHandler(EVT_DOUBLE, &h1), "40 register double handler");
   Check(bus.Publish(EVT_DOUBLE, 12.345), "41 publish double");
   Check(bus.Dispatch() == 1, "42 dispatch double");
   Check(h1.calls == 1, "43 h1 received double");
   Check(h1.last_type == BOSSR_EVENT_DOUBLE, "44 double type ok");
   Check(MathAbs(h1.last_double - 12.345) < 0.000001, "45 double payload ok");

   h1.Reset();
   Check(bus.RegisterHandler(EVT_BOOL, &h1), "46 register bool handler");
   Check(bus.Publish(EVT_BOOL, true), "47 publish bool true");
   Check(bus.Dispatch() == 1, "48 dispatch bool");
   Check(h1.calls == 1, "49 h1 received bool");
   Check(h1.last_type == BOSSR_EVENT_BOOL, "50 bool type ok");
   Check(h1.last_bool == true, "51 bool payload true");

   Check(!bus.Publish(0), "52 reject publish zero");
   Check(!bus.Publish(-5), "53 reject publish negative");
   Check(bus.CountQueued() == 0, "54 rejected publishes do not queue");

   Check(bus.Publish(EVT_INT, 1), "55 queue int 1");
   Check(bus.Publish(EVT_INT, 2), "56 queue int 2");
   Check(bus.Publish(EVT_INT, 3), "57 queue int 3");
   Check(bus.CountQueued() == 3, "58 queue count three");
   Check(bus.Dispatch() == 3, "59 dispatch three queued events");
   Check(bus.CountQueued() == 0, "60 queue empty after three");
   Check(h1.calls == 4, "61 h1 total int/double/bool/queue calls tracked");

   Check(bus.UnregisterHandler(EVT_NONE, &h2), "62 unregister h2");
   Check(bus.CountHandlers(EVT_NONE) == 1, "63 none handlers now one");
   Check(!bus.UnregisterHandler(EVT_NONE, &h2), "64 unregister missing h2 false");
   h1.Reset(); h2.Reset();
   Check(bus.Publish(EVT_NONE), "65 publish none after unregister");
   Check(bus.Dispatch() == 1, "66 dispatch none after unregister");
   Check(h1.calls == 1, "67 h1 still receives none");
   Check(h2.calls == 0, "68 h2 removed receives nothing");

   string shared = "";
   C_OrderHandler o1;
   C_OrderHandler o2;
   C_OrderHandler o3;
   o1.Init("A", shared);
   o2.Init("B", shared);
   o3.Init("C", shared);

   Check(bus.RegisterHandler(EVT_ORDER, &o1), "69 register order A");
   Check(bus.RegisterHandler(EVT_ORDER, &o2), "70 register order B");
   Check(bus.RegisterHandler(EVT_ORDER, &o3), "71 register order C");
   Check(bus.Publish(EVT_ORDER), "72 publish order event");
   Check(bus.Dispatch() == 1, "73 dispatch order event");
   Check(shared == "ABC", "74 deterministic handler order ABC");

   C_ChainHandler ch;
   ch.Init(bus);
   h1.Reset();

   Check(bus.RegisterHandler(EVT_CHAIN, &ch), "75 register chain handler");
   Check(bus.Publish(EVT_CHAIN), "76 publish chain event");
   Check(bus.Dispatch() == 1, "77 first dispatch only initial event");
   Check(ch.calls == 1, "78 chain handler called once");
   Check(bus.CountQueued() == 1, "79 chained event remains queued");
   Check(bus.Dispatch() == 1, "80 second dispatch handles chained event");
   Check(h1.calls >= 1, "81 int handler received chained event");
   Check(h1.last_int == 777, "82 chained int payload ok");
   Check(bus.CountQueued() == 0, "83 queue empty after chained dispatch");

   Check(bus.Clear(), "84 clear bus");
   Check(bus.CountHandlers() == 0, "85 handlers cleared");
   Check(bus.CountQueued() == 0, "86 queue cleared");
   Check(!bus.IsDispatching(), "87 not dispatching after clear");

   bool fill_ok = true;
   for(int i = 0; i < BOSSR_EVENT_MAX_QUEUE; i++)
   {
      if(!bus.Publish(EVT_INT, i))
         fill_ok = false;
   }
   Check(fill_ok, "88 queue fills to capacity");
   Check(bus.CountQueued() == BOSSR_EVENT_MAX_QUEUE, "89 queue capacity count");
   Check(!bus.Publish(EVT_INT, 999), "90 reject queue overflow");
   Check(bus.CountQueued() == BOSSR_EVENT_MAX_QUEUE, "91 overflow does not increase queue");

   Check(bus.Clear(), "92 clear after queue fill");

   C_TestHandler handlers[BOSSR_EVENT_MAX_HANDLERS];
   bool handlers_ok = true;
   for(int j = 0; j < BOSSR_EVENT_MAX_HANDLERS; j++)
   {
      if(!bus.RegisterHandler(EVT_NONE, &handlers[j]))
         handlers_ok = false;
   }
   Check(handlers_ok, "93 register max handlers");
   Check(bus.CountHandlers() == BOSSR_EVENT_MAX_HANDLERS, "94 max handler count");
   Check(!bus.RegisterHandler(EVT_NONE, &h1), "95 reject handler overflow");

   Check(bus.Publish(EVT_NONE), "96 publish to max handlers");
   Check(bus.Dispatch() == 1, "97 dispatch max handlers event");

   bool all_called = true;
   for(int k = 0; k < BOSSR_EVENT_MAX_HANDLERS; k++)
   {
      if(handlers[k].calls != 1)
         all_called = false;
   }
   Check(all_called, "98 all max handlers called once");

   Check(bus.Clear(), "99 final clear");
   Check(PASS == 99 && FAIL == 0, "100 verification accounting before final result");

   Print("BossR_Event_Test complete. PASS=", PASS, " FAIL=", FAIL);

   if(FAIL == 0 && PASS == 100)
      Print("BOSSR_EVENT_RUNTIME_VERIFIED");

   return INIT_SUCCEEDED;
}

void OnTick()
{
}

void OnDeinit(const int reason)
{
}