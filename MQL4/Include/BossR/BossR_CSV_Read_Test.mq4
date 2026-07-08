//+------------------------------------------------------------------+
//| BossR_CSV_Read_Test.mq4                                          |
//+------------------------------------------------------------------+
#property strict

#include <BossR\BossR_CSV.mqh>

int PASS = 0;
int FAIL = 0;

void Check(bool condition, string name)
{
   if(condition)
   {
      PASS++;
      Print("PASS | ", name);
   }
   else
   {
      FAIL++;
      Print("FAIL | ", name);
   }
}

void Test_BasicRead()
{
   Print("========== TEST BASIC READ ==========");

   string path = "BossR_CSV_Read_BASIC.csv";

   C_BossR_CSV csv;
   csv.Delete(path);

   Check(csv.OpenWrite(path), "OpenWrite BASIC");
   Check(csv.Write3("A", "B", "C"), "Write ABC");
   csv.Close();

   Check(csv.OpenRead(path), "OpenRead BASIC");
   Check(csv.IsReadOpen(), "IsReadOpen true");

   string row[];
   Check(csv.ReadRow(row), "ReadRow BASIC returns true");
   Check(ArraySize(row) == 3, "BASIC field count 3");

   if(ArraySize(row) == 3)
   {
      Check(row[0] == "A", "BASIC field 0 A");
      Check(row[1] == "B", "BASIC field 1 B");
      Check(row[2] == "C", "BASIC field 2 C");
   }

   Check(!csv.ReadRow(row), "BASIC second ReadRow false at EOF");

   csv.Close();
}

void Test_MultiRow()
{
   Print("========== TEST MULTI ROW ==========");

   string path = "BossR_CSV_Read_MULTI.csv";

   C_BossR_CSV csv;
   csv.Delete(path);

   Check(csv.OpenWrite(path), "OpenWrite MULTI");
   Check(csv.Write3("R1A", "R1B", "R1C"), "Write row 1");
   Check(csv.Write3("R2A", "R2B", "R2C"), "Write row 2");
   Check(csv.Write3("R3A", "R3B", "R3C"), "Write row 3");
   csv.Close();

   Check(csv.OpenRead(path), "OpenRead MULTI");

   string row[];

   Check(csv.ReadRow(row), "Read row 1");
   Check(ArraySize(row) == 3 && row[0] == "R1A" && row[1] == "R1B" && row[2] == "R1C", "Row 1 values");

   Check(csv.ReadRow(row), "Read row 2");
   Check(ArraySize(row) == 3 && row[0] == "R2A" && row[1] == "R2B" && row[2] == "R2C", "Row 2 values");

   Check(csv.ReadRow(row), "Read row 3");
   Check(ArraySize(row) == 3 && row[0] == "R3A" && row[1] == "R3B" && row[2] == "R3C", "Row 3 values");

   Check(!csv.ReadRow(row), "MULTI EOF false");

   csv.Close();
}

void Test_QuotedFields()
{
   Print("========== TEST QUOTED FIELDS ==========");

   string path = "BossR_CSV_Read_QUOTE.csv";

   C_BossR_CSV csv;
   csv.Delete(path);

   Check(csv.OpenWrite(path), "OpenWrite QUOTE");
   Check(csv.Write4("plain", "has,comma", "has \"quote\"", "end"), "Write quoted fields");
   csv.Close();

   Check(csv.OpenRead(path), "OpenRead QUOTE");

   string row[];
   Check(csv.ReadRow(row), "ReadRow QUOTE");
   Check(ArraySize(row) == 4, "QUOTE field count 4");

   if(ArraySize(row) == 4)
   {
      Check(row[0] == "plain", "QUOTE field plain");
      Check(row[1] == "has,comma", "QUOTE field comma");
      Check(row[2] == "has \"quote\"", "QUOTE field quote");
      Check(row[3] == "end", "QUOTE field end");
   }

   csv.Close();
}

void Test_EmptyFields()
{
   Print("========== TEST EMPTY FIELDS ==========");

   string path = "BossR_CSV_Read_EMPTY.csv";

   C_BossR_CSV csv;
   csv.Delete(path);

   Check(csv.OpenWrite(path), "OpenWrite EMPTY");
   Check(csv.Write4("A", "", "C", ""), "Write empty fields");
   csv.Close();

   Check(csv.OpenRead(path), "OpenRead EMPTY");

   string row[];
   Check(csv.ReadRow(row), "ReadRow EMPTY");
   Check(ArraySize(row) == 4, "EMPTY field count 4");

   if(ArraySize(row) == 4)
   {
      Check(row[0] == "A", "EMPTY field 0 A");
      Check(row[1] == "", "EMPTY field 1 empty");
      Check(row[2] == "C", "EMPTY field 2 C");
      Check(row[3] == "", "EMPTY field 3 empty");
   }

   csv.Close();
}

void Test_ReadMissingFile()
{
   Print("========== TEST MISSING FILE ==========");

   string path = "BossR_CSV_Read_MISSING.csv";

   C_BossR_CSV csv;
   csv.Delete(path);

   Check(!csv.OpenRead(path), "OpenRead missing file false");
   Check(!csv.IsReadOpen(), "Missing file IsReadOpen false");
}

int OnInit()
{
   PASS = 0;
   FAIL = 0;

   Print("========================================");
   Print("BossR CSV Read Test START");
   Print("========================================");

   Test_BasicRead();
   Test_MultiRow();
   Test_QuotedFields();
   Test_EmptyFields();
   Test_ReadMissingFile();

   Print("========================================");
   Print("BossR CSV Read Test COMPLETE");
   Print("PASS = ", PASS);
   Print("FAIL = ", FAIL);
   Print("========================================");

   if(FAIL == 0)
      Print("BOSSR_CSV_READ_RESULT = PASS");
   else
      Print("BOSSR_CSV_READ_RESULT = FAIL");

   return INIT_SUCCEEDED;
}

void OnDeinit(const int reason)
{
}

void OnTick()
{
}