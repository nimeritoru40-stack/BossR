//+------------------------------------------------------------------+
//| BossR_Config_Test.mq4                                            |
//+------------------------------------------------------------------+
#property strict

#include <BossR\BossR_Config.mqh>

int g_pass = 0;
int g_fail = 0;

string g_path = "BossR_Config_Test.csv";

C_BossR_Config cfg;
C_BossR_Config cfg_reload;
C_BossR_Config cfg_reload2;

void Check(string name, bool ok)
{
   if(ok)
   {
      g_pass++;
      Print("[PASS] ", name);
   }
   else
   {
      g_fail++;
      Print("[FAIL] ", name);
   }
}

int OnInit()
{
   Print("========== BossR_Config_Test START ==========");

   Check("Load missing/new file", cfg.Load(g_path));
   Check("Initial count zero", cfg.Count() == 0);

   Check("Missing string default", cfg.ReadString("MissingString", "DEFAULT") == "DEFAULT");
   Check("Missing int default", cfg.ReadInt("MissingInt", 77) == 77);
   Check("Missing double default", MathAbs(cfg.ReadDouble("MissingDouble", 12.34) - 12.34) < 0.00000001);
   Check("Missing bool default true", cfg.ReadBool("MissingBoolTrue", true) == true);
   Check("Missing bool default false", cfg.ReadBool("MissingBoolFalse", false) == false);

   Check("WriteString", cfg.WriteString("StrategyName", "BossR Core"));
   Check("WriteInt", cfg.WriteInt("MagicNumber", 260708));
   Check("WriteDouble", cfg.WriteDouble("RiskPercent", 1.25));
   Check("WriteBool true", cfg.WriteBool("EnableTrading", true));
   Check("WriteBool false", cfg.WriteBool("UseNewsFilter", false));

   Check("Count after writes", cfg.Count() == 5);
   Check("Exists StrategyName", cfg.Exists("StrategyName"));
   Check("Exists missing false", !cfg.Exists("NoSuchKey"));

   Check("ReadString live", cfg.ReadString("StrategyName", "") == "BossR Core");
   Check("ReadInt live", cfg.ReadInt("MagicNumber", 0) == 260708);
   Check("ReadDouble live", MathAbs(cfg.ReadDouble("RiskPercent", 0.0) - 1.25) < 0.00000001);
   Check("ReadBool true live", cfg.ReadBool("EnableTrading", false) == true);
   Check("ReadBool false live", cfg.ReadBool("UseNewsFilter", true) == false);

   Check("Overwrite string", cfg.WriteString("StrategyName", "BossR Updated"));
   Check("Overwrite int", cfg.WriteInt("MagicNumber", 999));
   Check("Overwrite double", cfg.WriteDouble("RiskPercent", 2.50));
   Check("Overwrite bool", cfg.WriteBool("EnableTrading", false));

   Check("Count after overwrite unchanged", cfg.Count() == 5);
   Check("Read overwritten string", cfg.ReadString("StrategyName", "") == "BossR Updated");
   Check("Read overwritten int", cfg.ReadInt("MagicNumber", 0) == 999);
   Check("Read overwritten double", MathAbs(cfg.ReadDouble("RiskPercent", 0.0) - 2.50) < 0.00000001);
   Check("Read overwritten bool", cfg.ReadBool("EnableTrading", true) == false);

   Check("Reload file", cfg_reload.Load(g_path));
   Check("Reload count", cfg_reload.Count() == 5);
   Check("Reload string", cfg_reload.ReadString("StrategyName", "") == "BossR Updated");
   Check("Reload int", cfg_reload.ReadInt("MagicNumber", 0) == 999);
   Check("Reload double", MathAbs(cfg_reload.ReadDouble("RiskPercent", 0.0) - 2.50) < 0.00000001);
   Check("Reload bool false", cfg_reload.ReadBool("EnableTrading", true) == false);
   Check("Reload bool second false", cfg_reload.ReadBool("UseNewsFilter", true) == false);

   Check("Reload missing string default", cfg_reload.ReadString("NotThere", "fallback") == "fallback");
   Check("Reload missing int default", cfg_reload.ReadInt("NotThereInt", -5) == -5);
   Check("Reload missing double default", MathAbs(cfg_reload.ReadDouble("NotThereDouble", -9.5) - (-9.5)) < 0.00000001);
   Check("Reload missing bool default", cfg_reload.ReadBool("NotThereBool", true) == true);

   Check("Special string comma", cfg_reload.WriteString("CommaValue", "A,B,C"));
   Check("Special string quote", cfg_reload.WriteString("QuoteValue", "He said BossR"));
   Check("Special string pipe", cfg_reload.WriteString("PipeValue", "A|B|C"));

   Check("Reload special file", cfg_reload2.Load(g_path));
   Check("Special comma read", cfg_reload2.ReadString("CommaValue", "") == "A,B,C");
   Check("Special quote read", cfg_reload2.ReadString("QuoteValue", "") == "He said BossR");
   Check("Special pipe read", cfg_reload2.ReadString("PipeValue", "") == "A|B|C");

   Check("Final save", cfg_reload2.Save());

   Print("========== BossR_Config_Test RESULT ==========");
   Print("PASS = ", g_pass);
   Print("FAIL = ", g_fail);

   if(g_fail == 0)
      Print("BossR_Config.mqh VERIFIED.");
   else
      Print("BossR_Config.mqh NOT VERIFIED.");

   return(g_fail == 0 ? INIT_SUCCEEDED : INIT_FAILED);
}

void OnDeinit(const int reason)
{
   Print("BossR_Config_Test deinit reason = ", reason);
}

void OnTick()
{
}