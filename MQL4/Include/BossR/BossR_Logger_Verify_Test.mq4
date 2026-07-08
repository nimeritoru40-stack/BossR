//+------------------------------------------------------------------+
//| BossR_Logger_Smoke_Test.mq4                                      |
//+------------------------------------------------------------------+
#property strict

#include <BossR\BossR_Logger.mqh>

C_BossR_Logger Log;

int OnInit()
{
   bool ok = Log.Init(
      "BossR_Logger_Smoke_Test",
      BOSSR_LOG_DEBUG,
      true,
      true,
      "BossR_Logger_Smoke_Test.csv"
   );

   if(!ok)
   {
      Print("LOGGER SMOKE TEST FAILED: Init failed");
      return INIT_FAILED;
   }

   Log.Debug("Debug message OK");
   Log.Info("Info message OK");
   Log.Warn("Warning message OK");
   Log.Error("Error message OK");

   Print("BossR Logger Smoke Test complete.");
   return INIT_SUCCEEDED;
}

void OnDeinit(const int reason)
{
   Log.Info("Deinit reason = " + IntegerToString(reason));
   Log.Shutdown();
}

void OnTick()
{
}