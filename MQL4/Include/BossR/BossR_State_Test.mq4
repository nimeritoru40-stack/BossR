//+------------------------------------------------------------------+
//| BossR_State_Test.mq4                                             |
//| Runtime verification EA for BossR_State.mqh                      |
//+------------------------------------------------------------------+
#property strict

#include <BossR\BossR_State.mqh>

int g_pass = 0;
int g_fail = 0;

void Pass(const string test_name)
{
   g_pass++;
   Print("PASS: ", test_name);
}

void Fail(const string test_name, const string detail = "")
{
   g_fail++;

   if(detail == "")
      Print("FAIL: ", test_name);
   else
      Print("FAIL: ", test_name, " | ", detail);
}

void CheckBool(const string test_name, const bool actual, const bool expected)
{
   if(actual == expected)
      Pass(test_name);
   else
      Fail(test_name);
}

void CheckInt(const string test_name, const int actual, const int expected)
{
   if(actual == expected)
      Pass(test_name);
   else
      Fail(test_name, "actual=" + IntegerToString(actual) + ", expected=" + IntegerToString(expected));
}

void CheckString(const string test_name, const string actual, const string expected)
{
   if(actual == expected)
      Pass(test_name);
   else
      Fail(test_name, "actual=[" + actual + "], expected=[" + expected + "]");
}

void CheckDouble(const string test_name, const double actual, const double expected)
{
   if(MathAbs(actual - expected) <= 0.00000001)
      Pass(test_name);
   else
      Fail(test_name, "actual=" + DoubleToString(actual, 12) + ", expected=" + DoubleToString(expected, 12));
}

void RunBossRStateTests()
{
   C_BossR_State state;

   CheckInt("Initial count zero", state.Count(), 0);

   CheckBool("Missing key absent", state.Exists("missing"), false);
   CheckBool("Empty key absent", state.Exists(""), false);

   CheckString("Missing string default", state.ReadString("missing", "DEFAULT"), "DEFAULT");
   CheckInt("Missing int default", state.ReadInt("missing", 123), 123);
   CheckDouble("Missing double default", state.ReadDouble("missing", 9.87), 9.87);
   CheckBool("Missing bool default true", state.ReadBool("missing", true), true);
   CheckBool("Missing bool default false", state.ReadBool("missing", false), false);

   CheckBool("Reject empty string key", state.WriteString("", "bad"), false);
   CheckBool("Reject empty int key", state.WriteInt("", 1), false);
   CheckBool("Reject empty double key", state.WriteDouble("", 1.1), false);
   CheckBool("Reject empty bool key", state.WriteBool("", true), false);
   CheckInt("Count still zero after empty rejects", state.Count(), 0);

   CheckBool("Write string symbol", state.WriteString("symbol", "EURUSD"), true);
   CheckBool("Write int tickets", state.WriteInt("tickets", 7), true);
   CheckBool("Write int negative", state.WriteInt("negative", -42), true);
   CheckBool("Write int zero", state.WriteInt("zero", 0), true);
   CheckBool("Write double risk", state.WriteDouble("risk", 1.25), true);
   CheckBool("Write double drawdown", state.WriteDouble("drawdown", -3.75), true);
   CheckBool("Write double flat", state.WriteDouble("flat", 0.0), true);
   CheckBool("Write bool enabled", state.WriteBool("enabled", true), true);
   CheckBool("Write bool locked", state.WriteBool("locked", false), true);

   CheckInt("Count after nine writes", state.Count(), 9);

   CheckBool("Exists symbol", state.Exists("symbol"), true);
   CheckBool("Exists tickets", state.Exists("tickets"), true);
   CheckBool("Exists negative", state.Exists("negative"), true);
   CheckBool("Exists zero", state.Exists("zero"), true);
   CheckBool("Exists risk", state.Exists("risk"), true);
   CheckBool("Exists drawdown", state.Exists("drawdown"), true);
   CheckBool("Exists flat", state.Exists("flat"), true);
   CheckBool("Exists enabled", state.Exists("enabled"), true);
   CheckBool("Exists locked", state.Exists("locked"), true);

   CheckString("Read symbol", state.ReadString("symbol", "BAD"), "EURUSD");
   CheckInt("Read tickets", state.ReadInt("tickets", -1), 7);
   CheckInt("Read negative", state.ReadInt("negative", 0), -42);
   CheckInt("Read zero", state.ReadInt("zero", -99), 0);
   CheckDouble("Read risk", state.ReadDouble("risk", 0.0), 1.25);
   CheckDouble("Read drawdown", state.ReadDouble("drawdown", 0.0), -3.75);
   CheckDouble("Read flat", state.ReadDouble("flat", 99.0), 0.0);
   CheckBool("Read enabled true", state.ReadBool("enabled", false), true);
   CheckBool("Read locked false", state.ReadBool("locked", true), false);

   CheckString("Type mismatch int as string", state.ReadString("tickets", "DEFAULT"), "DEFAULT");
   CheckInt("Type mismatch string as int", state.ReadInt("symbol", 88), 88);
   CheckDouble("Type mismatch bool as double", state.ReadDouble("enabled", 6.66), 6.66);
   CheckBool("Type mismatch double as bool", state.ReadBool("risk", true), true);

   CheckBool("Overwrite symbol string", state.WriteString("symbol", "GBPUSD"), true);
   CheckInt("Count unchanged after symbol overwrite", state.Count(), 9);
   CheckString("Read overwritten symbol", state.ReadString("symbol", "BAD"), "GBPUSD");

   CheckBool("Overwrite tickets int", state.WriteInt("tickets", 99), true);
   CheckInt("Count unchanged after tickets overwrite", state.Count(), 9);
   CheckInt("Read overwritten tickets", state.ReadInt("tickets", -1), 99);

   CheckBool("Overwrite risk double", state.WriteDouble("risk", 2.50), true);
   CheckInt("Count unchanged after risk overwrite", state.Count(), 9);
   CheckDouble("Read overwritten risk", state.ReadDouble("risk", 0.0), 2.50);

   CheckBool("Overwrite enabled bool", state.WriteBool("enabled", false), true);
   CheckInt("Count unchanged after enabled overwrite", state.Count(), 9);
   CheckBool("Read overwritten enabled", state.ReadBool("enabled", true), false);

   CheckBool("Cross-type overwrite symbol to int", state.WriteInt("symbol", 12345), true);
   CheckInt("Count unchanged after cross-type overwrite", state.Count(), 9);
   CheckString("Old symbol string unreadable", state.ReadString("symbol", "DEFAULT"), "DEFAULT");
   CheckInt("New symbol int readable", state.ReadInt("symbol", -1), 12345);

   CheckBool("Remove symbol", state.Remove("symbol"), true);
   CheckInt("Count after remove symbol", state.Count(), 8);
   CheckBool("Symbol absent after remove", state.Exists("symbol"), false);
   CheckInt("Symbol default after remove", state.ReadInt("symbol", 777), 777);

   CheckBool("Remove missing false", state.Remove("missing"), false);
   CheckInt("Count unchanged after missing remove", state.Count(), 8);

   CheckBool("Remove tickets", state.Remove("tickets"), true);
   CheckInt("Count after remove tickets", state.Count(), 7);

   CheckBool("Remove risk", state.Remove("risk"), true);
   CheckInt("Count after remove risk", state.Count(), 6);

   CheckBool("Remove locked", state.Remove("locked"), true);
   CheckInt("Count after remove locked", state.Count(), 5);

   CheckBool("Remaining negative exists", state.Exists("negative"), true);
   CheckInt("Remaining negative intact", state.ReadInt("negative", 0), -42);

   CheckBool("Remaining zero exists", state.Exists("zero"), true);
   CheckInt("Remaining zero intact", state.ReadInt("zero", -99), 0);

   CheckBool("Remaining drawdown exists", state.Exists("drawdown"), true);
   CheckDouble("Remaining drawdown intact", state.ReadDouble("drawdown", 0.0), -3.75);

   CheckBool("Remaining flat exists", state.Exists("flat"), true);
   CheckDouble("Remaining flat intact", state.ReadDouble("flat", 99.0), 0.0);

   CheckBool("Remaining enabled exists", state.Exists("enabled"), true);
   CheckBool("Remaining enabled intact", state.ReadBool("enabled", true), false);

   CheckBool("Write into removed slot", state.WriteString("reuse", "OK"), true);
   CheckInt("Count after reuse write", state.Count(), 6);
   CheckBool("Reuse key exists", state.Exists("reuse"), true);
   CheckString("Reuse key value", state.ReadString("reuse", "BAD"), "OK");

   CheckBool("Remove reuse", state.Remove("reuse"), true);
   CheckInt("Count after remove reuse", state.Count(), 5);

   state.Clear();

   CheckInt("Count after clear", state.Count(), 0);
   CheckBool("Old negative absent after clear", state.Exists("negative"), false);
   CheckBool("Old enabled absent after clear", state.Exists("enabled"), false);
   CheckInt("Old int default after clear", state.ReadInt("negative", 555), 555);
   CheckDouble("Old double default after clear", state.ReadDouble("drawdown", 8.88), 8.88);
   CheckBool("Old bool default after clear", state.ReadBool("enabled", true), true);

   CheckBool("Write after clear", state.WriteString("after_clear", "OK"), true);
   CheckInt("Count after write post-clear", state.Count(), 1);
   CheckString("Read after clear", state.ReadString("after_clear", "BAD"), "OK");

   CheckBool("Remove only key after clear", state.Remove("after_clear"), true);
   CheckInt("Final count zero", state.Count(), 0);
}

int OnInit()
{
   Print("BossR_State_Test started.");

   RunBossRStateTests();

   Print("BossR_State_Test complete. PASS=", g_pass, " FAIL=", g_fail);

   if(g_fail == 0)
      Print("BOSSR_STATE_RUNTIME_VERIFIED");
   else
      Print("BOSSR_STATE_RUNTIME_FAILED");

   return INIT_SUCCEEDED;
}

void OnDeinit(const int reason)
{
}

void OnTick()
{
}