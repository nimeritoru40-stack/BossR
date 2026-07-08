#property strict

#include <BossR\BossR_File.mqh>

int OnInit()
{
   string path = TerminalInfoString(TERMINAL_DATA_PATH) + "\\MQL4\\Files\\bossr_csv_runtime_test.csv";

   C_BossR_CSVWriter writer;
   if(!writer.Init(path, false))
      return INIT_FAILED;

   if(!writer.Open())
      return INIT_FAILED;

   string row1[3];
   row1[0] = "alpha";
   row1[1] = "beta";
   row1[2] = "gamma";
   if(!writer.WriteRow(row1, 3))
      return INIT_FAILED;

   string row2[3];
   row2[0] = "hello,world";
   row2[1] = "line\nbreak";
   row2[2] = "quoted\"value";
   if(!writer.WriteRow(row2, 3))
      return INIT_FAILED;

   if(!writer.Close())
      return INIT_FAILED;

   if(!writer.Open())
      return INIT_FAILED;

   if(!writer.Close())
      return INIT_FAILED;

   if(!writer.DeleteCSV())
      return INIT_FAILED;

   return INIT_SUCCEEDED;
}
