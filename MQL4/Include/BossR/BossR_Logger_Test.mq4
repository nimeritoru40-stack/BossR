//+------------------------------------------------------------------+
//| BossR_Logger_Test.mq4                                            |
//+------------------------------------------------------------------+
#property strict

#include <BossR\BossR_Logger.mqh>

C_BossR_Logger Log;

int OnInit()
{
   Log.Init(
      "BossR_Logger_Test",
      BOSSR_LOG_DEBUG,
      true,
      true,
      "BossR_Logger_Test.log"
   );

   Log.Debug("Debug message OK");
   Log.Info("Info message OK");
   Log.Warn("Warning message OK");
   Log.Error("Error message OK");

   Print("BossR Logger Test complete.");
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