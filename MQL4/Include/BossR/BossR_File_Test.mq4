//+------------------------------------------------------------------+
//| BossR_File_Test.mq4                                              |
//| Runtime verifier for BossR_File.mqh                              |
//+------------------------------------------------------------------+
#property strict

#include <BossR\BossR_File.mqh>

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

int OnInit()
{
   Print("========== BossR_File_Test START ==========");

   Test_Create_Write_Read_TXT();
   Test_Append_TXT();
   Test_CSV_Write_Read();
   Test_BIN_Integer();
   Test_BIN_Array();
   Test_Seek_Tell_Size();
   Test_Exists_Delete();
   Test_Closed_Handle_Safety();

   Print("========== BossR_File_Test RESULT ==========");
   Print("PASS = ", g_pass);
   Print("FAIL = ", g_fail);

   if(g_fail == 0)
      Print("BossR_File.mqh VERIFIED.");
   else
      Print("BossR_File.mqh NOT VERIFIED.");

   return INIT_SUCCEEDED;
}

void OnDeinit(const int reason)
{
}

void OnTick()
{
}

//+------------------------------------------------------------------+
//| Tests                                                            |
//+------------------------------------------------------------------+

void Test_Create_Write_Read_TXT()
{
   C_BossR_File f;
   string path = "BossR_File_Test_TXT.txt";

   f.Delete(path);

   Check(f.Open(path, FILE_WRITE | FILE_TXT), "TXT open write");
   Check(f.WriteStringRaw("ABC"), "TXT raw write ABC");
   f.Close();

   Check(f.Open(path, FILE_READ | FILE_TXT), "TXT open read");
   string s = f.ReadString();
   Check(s == "ABC", "TXT read string", "Expected ABC got " + s);
   f.Close();
}

void Test_Append_TXT()
{
   C_BossR_File f;
   string path = "BossR_File_Test_APPEND.txt";

   f.Delete(path);

   Check(f.Open(path, FILE_WRITE | FILE_TXT), "APPEND create");
   Check(f.WriteStringRaw("ONE"), "APPEND write ONE");
   f.Close();

   Check(f.Open(path, FILE_READ | FILE_WRITE | FILE_TXT), "APPEND reopen RW");
   Check(f.SeekEnd(), "APPEND seek end");
   Check(f.WriteStringRaw("TWO"), "APPEND write TWO");
   f.Close();

   Check(f.Open(path, FILE_READ | FILE_TXT), "APPEND open read");
   string s = f.ReadString();
   Check(s == "ONETWO", "APPEND read combined", "Expected ONETWO got " + s);
   f.Close();
}

void Test_CSV_Write_Read()
{
   C_BossR_File f;
   string path = "BossR_File_Test_CSV.csv";

   f.Delete(path);

   Check(f.Open(path, FILE_WRITE | FILE_CSV, ','), "CSV open write");
   Check(f.WriteCSV3("A", "B", "C"), "CSV write 3 fields");
   f.Close();

   Check(f.Open(path, FILE_READ | FILE_CSV, ','), "CSV open read");

   string a = f.ReadString();
   string b = f.ReadString();
   string c = f.ReadString();

   Check(a == "A", "CSV read field A", "got " + a);
   Check(b == "B", "CSV read field B", "got " + b);
   Check(c == "C", "CSV read field C", "got " + c);

   f.Close();
}

void Test_BIN_Integer()
{
   C_BossR_File f;
   string path = "BossR_File_Test_INT.bin";

   f.Delete(path);

   Check(f.Open(path, FILE_WRITE | FILE_BIN), "BIN integer open write");
   Check(f.WriteInteger(123456789, INT_VALUE), "BIN write integer");
   f.Close();

   Check(f.Open(path, FILE_READ | FILE_BIN), "BIN integer open read");
   int value = f.ReadInteger(INT_VALUE);
   Check(value == 123456789, "BIN read integer", "Expected 123456789 got " + IntegerToString(value));
   f.Close();
}

void Test_BIN_Array()
{
   C_BossR_File f;
   string path = "BossR_File_Test_ARRAY.bin";

   uchar out[];
   ArrayResize(out, 5);
   out[0] = 10;
   out[1] = 20;
   out[2] = 30;
   out[3] = 40;
   out[4] = 50;

   f.Delete(path);

   Check(f.Open(path, FILE_WRITE | FILE_BIN), "BIN array open write");
   int written = f.WriteArray(out, 0, 5);
   Check(written == 5, "BIN array write count", "got " + IntegerToString(written));
   f.Close();

   uchar in[];
   ArrayResize(in, 5);

   Check(f.Open(path, FILE_READ | FILE_BIN), "BIN array open read");
   int read = f.ReadArray(in, 0, 5);
   Check(read == 5, "BIN array read count", "got " + IntegerToString(read));

   bool same =
      in[0] == 10 &&
      in[1] == 20 &&
      in[2] == 30 &&
      in[3] == 40 &&
      in[4] == 50;

   Check(same, "BIN array byte equality");
   f.Close();
}

void Test_Seek_Tell_Size()
{
   C_BossR_File f;
   string path = "BossR_File_Test_SEEK.bin";

   f.Delete(path);

   Check(f.Open(path, FILE_WRITE | FILE_BIN), "SEEK open write");
   Check(f.WriteStringRaw("ABCDE"), "SEEK write ABCDE");
   Check(f.Size() == 5, "SEEK size 5", "got " + IntegerToString(f.Size()));

   Check(f.Seek(2, SEEK_SET), "SEEK set 2");
   Check(f.Tell() == 2, "SEEK tell 2", "got " + IntegerToString(f.Tell()));

   Check(f.WriteStringRaw("Z"), "SEEK overwrite Z");
   f.Close();

   Check(f.Open(path, FILE_READ | FILE_TXT), "SEEK open read txt");
   string s = f.ReadString();
   Check(s == "ABZDE", "SEEK partial overwrite verified", "Expected ABZDE got " + s);
   f.Close();
}

void Test_Exists_Delete()
{
   C_BossR_File f;
   string path = "BossR_File_Test_EXISTS.txt";

   f.Delete(path);

   Check(!f.Exists(path), "EXISTS false before create");

   Check(f.Open(path, FILE_WRITE | FILE_TXT), "EXISTS create file");
   Check(f.WriteStringRaw("X"), "EXISTS write X");
   f.Close();

   Check(f.Exists(path), "EXISTS true after create");
   Check(f.Delete(path), "DELETE existing file");
   Check(!f.Exists(path), "EXISTS false after delete");
}

void Test_Closed_Handle_Safety()
{
   C_BossR_File f;

   Check(!f.IsOpen(), "CLOSED initial IsOpen false");
   Check(f.Size() == -1, "CLOSED size returns -1");
   Check(f.Tell() == -1, "CLOSED tell returns -1");
   Check(!f.SeekStart(), "CLOSED seek start false");
   Check(!f.WriteStringRaw("NOPE"), "CLOSED write raw false");
   Check(f.ReadString() == "", "CLOSED read string empty");
}