#property strict

#include <BossR\BossR_CSV.mqh>

int OnInit()
{
   C_BossR_CSV csv;

   if(!csv.OpenWrite("BossR_CSV_Smoke_Test.csv"))
   {
      Print("SMOKE FAIL: OpenWrite failed. err=", GetLastError());
      return INIT_FAILED;
   }

   csv.Write3("A", "B", "C");
   csv.Close();

   Print("SMOKE PASS: BossR_CSV compiled and wrote file.");
   return INIT_SUCCEEDED;
}

void OnTick()
{
}