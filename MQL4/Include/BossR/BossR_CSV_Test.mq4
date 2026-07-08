//+------------------------------------------------------------------+
//| BossR_CSV_Test.mq4                                               |
//| Runtime verifier for BossR_CSV.mqh                               |
//+------------------------------------------------------------------+
#property strict

#include <BossR\BossR_CSV.mqh>

int g_pass = 0;
int g_fail = 0;

void Pass(string name)
{
   g_pass++;
   Print("[PASS] ", name);
}

void Fail(string name, string detail)
{
   g_fail++;
   Print("[FAIL] ", name, " | ", detail, " | err=", GetLastError());
}

void Check(bool condition, string name, string detail = "")
{
   if(condition) Pass(name);
   else Fail(name, detail);
}

string ReadWholeFile(const string path)
{
   int h = FileOpen(path, FILE_READ | FILE_BIN);
   if(h == INVALID_HANDLE)
      return "";

   int size = (int)FileSize(h);
   uchar bytes[];
   ArrayResize(bytes, size);

   FileReadArray(h, bytes, 0, size);
   FileClose(h);

   string s = "";
   for(int i = 0; i < size; i++)
      s += CharToString(bytes[i]);

   return s;
}

int OnInit()
{
   Print("========== BossR_CSV_Test START ==========");

   Test_Open_Write_Header_Row();
   Test_Overwrite();
   Test_Append();
   Test_Comma_Escape();
   Test_Quote_Escape();
   Test_CRLF_Escape();
   Test_Semicolon_Delimiter();
   Test_WriteRow_Array();
   Test_Closed_Safety();

   Print("========== BossR_CSV_Test RESULT ==========");
   Print("PASS = ", g_pass);
   Print("FAIL = ", g_fail);

   if(g_fail == 0)
      Print("BossR_CSV.mqh VERIFIED.");
   else
      Print("BossR_CSV.mqh NOT VERIFIED.");

   return INIT_SUCCEEDED;
}

void OnDeinit(const int reason)
{
}

void OnTick()
{
}

void Test_Open_Write_Header_Row()
{
   C_BossR_CSV csv;
   string path = "BossR_CSV_Test_BASIC.csv";

   csv.Delete(path);

   Check(csv.OpenWrite(path), "BASIC open write");
   Check(csv.Write3("Time", "Symbol", "CloseR"), "BASIC write header");
   Check(csv.Write3("2026.07.07 00:00", "EURUSD", "12.34"), "BASIC write row");
   csv.Close();

   string raw = ReadWholeFile(path);
   string expected = "Time,Symbol,CloseR\r\n2026.07.07 00:00,EURUSD,12.34\r\n";

   Check(raw == expected, "BASIC raw file equality", "got [" + raw + "]");
}

void Test_Overwrite()
{
   C_BossR_CSV csv;
   string path = "BossR_CSV_Test_OVERWRITE.csv";

   csv.Delete(path);

   Check(csv.OpenWrite(path), "OVERWRITE first open");
   Check(csv.Write1("OLD"), "OVERWRITE old write");
   csv.Close();

   Check(csv.OpenWrite(path), "OVERWRITE second open");
   Check(csv.Write1("NEW"), "OVERWRITE new write");
   csv.Close();

   string raw = ReadWholeFile(path);
   Check(raw == "NEW\r\n", "OVERWRITE verified", "got [" + raw + "]");
}

void Test_Append()
{
   C_BossR_CSV csv;
   string path = "BossR_CSV_Test_APPEND.csv";

   csv.Delete(path);

   Check(csv.OpenWrite(path), "APPEND open write");
   Check(csv.Write1("ONE"), "APPEND write ONE");
   csv.Close();

   Check(csv.OpenAppend(path), "APPEND open append");
   Check(csv.Write1("TWO"), "APPEND write TWO");
   csv.Close();

   string raw = ReadWholeFile(path);
   Check(raw == "ONE\r\nTWO\r\n", "APPEND raw equality", "got [" + raw + "]");
}

void Test_Comma_Escape()
{
   C_BossR_CSV csv;
   string path = "BossR_CSV_Test_COMMA.csv";

   csv.Delete(path);

   Check(csv.OpenWrite(path), "COMMA open");
   Check(csv.Write2("A,B", "C"), "COMMA write");
   csv.Close();

   string raw = ReadWholeFile(path);
   Check(raw == "\"A,B\",C\r\n", "COMMA escaped", "got [" + raw + "]");
}

void Test_Quote_Escape()
{
   C_BossR_CSV csv;
   string path = "BossR_CSV_Test_QUOTE.csv";

   csv.Delete(path);

   Check(csv.OpenWrite(path), "QUOTE open");
   Check(csv.Write2("A\"B", "C"), "QUOTE write");
   csv.Close();

   string raw = ReadWholeFile(path);
   Check(raw == "\"A\"\"B\",C\r\n", "QUOTE escaped", "got [" + raw + "]");
}

void Test_CRLF_Escape()
{
   C_BossR_CSV csv;
   string path = "BossR_CSV_Test_CRLF.csv";

   csv.Delete(path);

   Check(csv.OpenWrite(path), "CRLF open");
   Check(csv.Write2("A\r\nB", "C"), "CRLF write");
   csv.Close();

   string raw = ReadWholeFile(path);
   Check(raw == "\"A\r\nB\",C\r\n", "CRLF escaped", "got [" + raw + "]");
}

void Test_Semicolon_Delimiter()
{
   C_BossR_CSV csv;
   string path = "BossR_CSV_Test_SEMI.csv";

   csv.Delete(path);

   Check(csv.OpenWrite(path, ';'), "SEMI open");
   Check(csv.Write3("A", "B;C", "D"), "SEMI write");
   csv.Close();

   string raw = ReadWholeFile(path);
   Check(raw == "A;\"B;C\";D\r\n", "SEMI raw equality", "got [" + raw + "]");
}

void Test_WriteRow_Array()
{
   C_BossR_CSV csv;
   string path = "BossR_CSV_Test_ARRAY.csv";

   csv.Delete(path);

   string fields[];
   ArrayResize(fields, 4);
   fields[0] = "A";
   fields[1] = "B";
   fields[2] = "C";
   fields[3] = "D";

   Check(csv.OpenWrite(path), "ARRAY open");
   Check(csv.WriteRow(fields), "ARRAY write row");
   csv.Close();

   string raw = ReadWholeFile(path);
   Check(raw == "A,B,C,D\r\n", "ARRAY raw equality", "got [" + raw + "]");
}

void Test_Closed_Safety()
{
   C_BossR_CSV csv;

   Check(!csv.IsOpen(), "CLOSED initial IsOpen false");
   Check(!csv.Write1("NOPE"), "CLOSED Write1 false");
   Check(!csv.Write2("A", "B"), "CLOSED Write2 false");
   Check(!csv.Flush(), "CLOSED Flush false");
}