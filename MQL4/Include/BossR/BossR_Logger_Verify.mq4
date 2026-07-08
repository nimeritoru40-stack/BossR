//+------------------------------------------------------------------+
//| BossR_Logger_Verify.mq4                                          |
//+------------------------------------------------------------------+
#property strict

#include <BossR\BossR_Common.mqh>
#include <BossR\BossR_CSV.mqh>
#include <BossR\BossR_Logger.mqh>

C_BossR_Logger Log;
C_BossR_CSV    CSV;

int g_pass = 0;
int g_fail = 0;

string TEST_MODULE = "BossR_Logger_Verify";
string TEST_FILE;

bool found_debug = false;
bool found_info  = false;
bool found_warn  = false;
bool found_error = false;

void Pass(string name)
{
   g_pass++;
   Print("[PASS] ", name);
}

void Fail(string name)
{
   g_fail++;
   Print("[FAIL] ", name);
}

string RowToText(string &row[])
{
   string s = "";

   for(int i = 0; i < ArraySize(row); i++)
   {
      if(i > 0)
         s += " | ";

      s += row[i];
   }

   return s;
}

bool RowHas(string &row[], string level, string message)
{
   string s = RowToText(row);

   if(StringFind(s, TEST_MODULE) < 0)
      return false;

   if(StringFind(s, level) < 0)
      return false;

   if(StringFind(s, message) < 0)
      return false;

   return true;
}

int OnInit()
{
   TEST_FILE = "BossR_Logger_Verify_" + IntegerToString(TimeLocal()) + ".csv";

   Print("========== BossR_Logger_Verify START ==========");
   Print("CSV file: ", TEST_FILE);

   bool init_ok = Log.Init(
      TEST_MODULE,
      BOSSR_LOG_DEBUG,
      true,
      true,
      TEST_FILE
   );

   if(init_ok) Pass("Logger Init");
   else        Fail("Logger Init");

   Log.Debug("VERIFY_DEBUG_MESSAGE");
   Log.Info("VERIFY_INFO_MESSAGE");
   Log.Warn("VERIFY_WARN_MESSAGE");
   Log.Error("VERIFY_ERROR_MESSAGE");

   Log.Shutdown();
   Pass("Logger Shutdown");

   if(CSV.OpenRead(TEST_FILE, ','))
      Pass("CSV OpenRead logger output");
   else
   {
      Fail("CSV OpenRead logger output");
      PrintResult();
      return INIT_FAILED;
   }

   string row[];
   int rows = 0;

   while(CSV.ReadRow(row))
   {
      rows++;

      if(RowHas(row, "DEBUG", "VERIFY_DEBUG_MESSAGE"))
         found_debug = true;

      if(RowHas(row, "INFO", "VERIFY_INFO_MESSAGE"))
         found_info = true;

      if(RowHas(row, "WARN", "VERIFY_WARN_MESSAGE"))
         found_warn = true;

      if(RowHas(row, "ERROR", "VERIFY_ERROR_MESSAGE"))
         found_error = true;
   }

   CSV.Close();

   if(rows >= 4)
      Pass("CSV row count >= required minimum");
   else
      Fail("CSV row count too low = " + IntegerToString(rows));

   if(found_debug) Pass("CSV DEBUG row found");
   else            Fail("CSV DEBUG row missing");

   if(found_info)  Pass("CSV INFO row found");
   else            Fail("CSV INFO row missing");

   if(found_warn)  Pass("CSV WARN row found");
   else            Fail("CSV WARN row missing");

   if(found_error) Pass("CSV ERROR row found");
   else            Fail("CSV ERROR row missing");

   PrintResult();

   if(g_fail == 0)
      return INIT_SUCCEEDED;

   return INIT_FAILED;
}

void PrintResult()
{
   Print("========== BossR_Logger_Verify RESULT ==========");
   Print("PASS = ", g_pass);
   Print("FAIL = ", g_fail);

   if(g_fail == 0)
      Print("BossR_Logger.mqh VERIFIED. FREEZE LOGGER.");
   else
      Print("BossR_Logger.mqh NOT frozen yet.");
}

void OnDeinit(const int reason)
{
}

void OnTick()
{
}