//+------------------------------------------------------------------+
//| BossR_String_Verify.mq4                                          |
//| BossR Framework                                                  |
//+------------------------------------------------------------------+
#property strict

#include <BossR\BossR_String.mqh>

C_BossR_String BossString;

int g_pass = 0;
int g_fail = 0;

void Pass(string test_name)
{
   g_pass++;
   Print("PASS: ", test_name);
}

void Fail(string test_name)
{
   g_fail++;
   Print("FAIL: ", test_name);
}

void ExpectBool(string test_name, bool actual, bool expected)
{
   if(actual == expected)
      Pass(test_name);
   else
   {
      Fail(test_name);
      Print("   actual=[", actual, "] expected=[", expected, "]");
   }
}

void ExpectInt(string test_name, int actual, int expected)
{
   if(actual == expected)
      Pass(test_name);
   else
   {
      Fail(test_name);
      Print("   actual=[", actual, "] expected=[", expected, "]");
   }
}

void ExpectString(string test_name, string actual, string expected)
{
   if(actual == expected)
      Pass(test_name);
   else
   {
      Fail(test_name);
      Print("   actual=[", actual, "] expected=[", expected, "]");
   }
}

int OnInit()
{
   Print("=== BossR_String Verification Started ===");

   // ------------------------------------------------------------
   // Block 1 — basic length / empty / trim / case
   // ------------------------------------------------------------
   ExpectInt("Block1 Length empty", BossString.Length(""), 0);
   ExpectInt("Block1 Length abc", BossString.Length("abc"), 3);
   ExpectInt("Block1 Length spaces", BossString.Length("   "), 3);

   ExpectBool("Block1 IsEmpty empty", BossString.IsEmpty(""), true);
   ExpectBool("Block1 IsEmpty non-empty", BossString.IsEmpty("abc"), false);
   ExpectBool("Block1 IsEmpty space false", BossString.IsEmpty(" "), false);

   ExpectString("Block1 TrimLeft empty", BossString.TrimLeft(""), "");
   ExpectString("Block1 TrimLeft none", BossString.TrimLeft("abc"), "abc");
   ExpectString("Block1 TrimLeft spaces", BossString.TrimLeft("   abc"), "abc");
   ExpectString("Block1 TrimLeft tabs", BossString.TrimLeft("\t\tabc"), "abc");
   ExpectString("Block1 TrimLeft mixed", BossString.TrimLeft(" \t\r\nabc"), "abc");

   ExpectString("Block1 TrimRight empty", BossString.TrimRight(""), "");
   ExpectString("Block1 TrimRight none", BossString.TrimRight("abc"), "abc");
   ExpectString("Block1 TrimRight spaces", BossString.TrimRight("abc   "), "abc");
   ExpectString("Block1 TrimRight tabs", BossString.TrimRight("abc\t\t"), "abc");
   ExpectString("Block1 TrimRight mixed", BossString.TrimRight("abc \t\r\n"), "abc");

   ExpectString("Block1 Trim both", BossString.Trim("   abc   "), "abc");
   ExpectString("Block1 Trim all spaces", BossString.Trim("     "), "");
   ExpectString("Block1 Trim mixed both", BossString.Trim(" \t abc \r\n"), "abc");

   ExpectString("Block1 ToUpper", BossString.ToUpper("AbC123"), "ABC123");
   ExpectString("Block1 ToLower", BossString.ToLower("AbC123"), "abc123");

   // ------------------------------------------------------------
   // Block 2 — comparison / contains / starts / ends
   // ------------------------------------------------------------
   ExpectBool("Block2 EqualsIgnoreCase same", BossString.EqualsIgnoreCase("abc", "ABC"), true);
   ExpectBool("Block2 EqualsIgnoreCase mixed", BossString.EqualsIgnoreCase("AbC", "aBc"), true);
   ExpectBool("Block2 EqualsIgnoreCase false", BossString.EqualsIgnoreCase("abc", "abd"), false);
   ExpectBool("Block2 EqualsIgnoreCase empty", BossString.EqualsIgnoreCase("", ""), true);

   ExpectBool("Block2 Contains true", BossString.Contains("abcdef", "bcd"), true);
   ExpectBool("Block2 Contains false", BossString.Contains("abcdef", "xyz"), false);
   ExpectBool("Block2 Contains empty needle", BossString.Contains("abcdef", ""), true);
   ExpectBool("Block2 Contains exact", BossString.Contains("abcdef", "abcdef"), true);
   ExpectBool("Block2 Contains case false", BossString.Contains("abcdef", "BCD"), false);

   ExpectBool("Block2 ContainsIgnoreCase true", BossString.ContainsIgnoreCase("abcdef", "BCD"), true);
   ExpectBool("Block2 ContainsIgnoreCase false", BossString.ContainsIgnoreCase("abcdef", "XYZ"), false);
   ExpectBool("Block2 ContainsIgnoreCase empty needle", BossString.ContainsIgnoreCase("abcdef", ""), true);

   ExpectBool("Block2 StartsWith true", BossString.StartsWith("abcdef", "abc"), true);
   ExpectBool("Block2 StartsWith false", BossString.StartsWith("abcdef", "bcd"), false);
   ExpectBool("Block2 StartsWith empty prefix", BossString.StartsWith("abcdef", ""), true);
   ExpectBool("Block2 StartsWith exact", BossString.StartsWith("abcdef", "abcdef"), true);
   ExpectBool("Block2 StartsWith longer false", BossString.StartsWith("abc", "abcdef"), false);
   ExpectBool("Block2 StartsWith case false", BossString.StartsWith("abcdef", "ABC"), false);

   ExpectBool("Block2 StartsWithIgnoreCase true", BossString.StartsWithIgnoreCase("abcdef", "ABC"), true);
   ExpectBool("Block2 StartsWithIgnoreCase false", BossString.StartsWithIgnoreCase("abcdef", "BCD"), false);

   ExpectBool("Block2 EndsWith true", BossString.EndsWith("abcdef", "def"), true);
   ExpectBool("Block2 EndsWith false", BossString.EndsWith("abcdef", "cde"), false);
   ExpectBool("Block2 EndsWith empty suffix", BossString.EndsWith("abcdef", ""), true);
   ExpectBool("Block2 EndsWith exact", BossString.EndsWith("abcdef", "abcdef"), true);
   ExpectBool("Block2 EndsWith longer false", BossString.EndsWith("abc", "abcdef"), false);
   ExpectBool("Block2 EndsWith case false", BossString.EndsWith("abcdef", "DEF"), false);

   ExpectBool("Block2 EndsWithIgnoreCase true", BossString.EndsWithIgnoreCase("abcdef", "DEF"), true);
   ExpectBool("Block2 EndsWithIgnoreCase false", BossString.EndsWithIgnoreCase("abcdef", "CDE"), false);

   // ------------------------------------------------------------
   // Block 3 — Replace / Remove / Insert / Repeat
   // ------------------------------------------------------------
   ExpectString("Block3 Replace empty value", BossString.Replace("", "a", "b"), "");
   ExpectString("Block3 Replace empty from unchanged", BossString.Replace("abc", "", "x"), "abc");
   ExpectString("Block3 Replace one", BossString.Replace("abc", "b", "X"), "aXc");
   ExpectString("Block3 Replace multiple", BossString.Replace("aaaa", "a", "b"), "bbbb");
   ExpectString("Block3 Replace word", BossString.Replace("one two one", "one", "1"), "1 two 1");
   ExpectString("Block3 Replace remove", BossString.Replace("a-b-c", "-", ""), "abc");
   ExpectString("Block3 Replace no match", BossString.Replace("abc", "z", "x"), "abc");

   ExpectString("Block3 Remove empty", BossString.Remove("", 0, 1), "");
   ExpectString("Block3 Remove middle", BossString.Remove("abcdef", 2, 2), "abef");
   ExpectString("Block3 Remove start", BossString.Remove("abcdef", 0, 2), "cdef");
   ExpectString("Block3 Remove end", BossString.Remove("abcdef", 4, 2), "abcd");
   ExpectString("Block3 Remove beyond count clamps", BossString.Remove("abcdef", 4, 99), "abcd");
   ExpectString("Block3 Remove negative start unchanged", BossString.Remove("abcdef", -1, 2), "abcdef");
   ExpectString("Block3 Remove start too large unchanged", BossString.Remove("abcdef", 99, 2), "abcdef");
   ExpectString("Block3 Remove zero count unchanged", BossString.Remove("abcdef", 2, 0), "abcdef");
   ExpectString("Block3 Remove negative count unchanged", BossString.Remove("abcdef", 2, -1), "abcdef");
   ExpectString("Block3 Remove full", BossString.Remove("abcdef", 0, 6), "");

   ExpectString("Block3 Insert empty value", BossString.Insert("", 0, "x"), "x");
   ExpectString("Block3 Insert empty insert unchanged", BossString.Insert("abc", 1, ""), "abc");
   ExpectString("Block3 Insert start", BossString.Insert("abc", 0, "x"), "xabc");
   ExpectString("Block3 Insert negative clamps start", BossString.Insert("abc", -5, "x"), "xabc");
   ExpectString("Block3 Insert middle", BossString.Insert("abc", 1, "x"), "axbc");
   ExpectString("Block3 Insert end", BossString.Insert("abc", 3, "x"), "abcx");
   ExpectString("Block3 Insert beyond end clamps", BossString.Insert("abc", 99, "x"), "abcx");

   ExpectString("Block3 Repeat zero", BossString.Repeat("a", 0), "");
   ExpectString("Block3 Repeat negative", BossString.Repeat("a", -1), "");
   ExpectString("Block3 Repeat empty", BossString.Repeat("", 3), "");
   ExpectString("Block3 Repeat one", BossString.Repeat("ab", 1), "ab");
   ExpectString("Block3 Repeat many", BossString.Repeat("ab", 3), "ababab");

   // ------------------------------------------------------------
   // Block 4 — IndexOf / LastIndexOf / Count / Substring / Left / Right / Mid
   // ------------------------------------------------------------
   ExpectInt("Block4 IndexOf basic", BossString.IndexOf("abcdef", "cd"), 2);
   ExpectInt("Block4 IndexOf missing", BossString.IndexOf("abcdef", "xy"), -1);
   ExpectInt("Block4 IndexOf empty needle", BossString.IndexOf("abcdef", ""), 0);
   ExpectInt("Block4 IndexOf empty needle start", BossString.IndexOf("abcdef", "", 3), 3);
   ExpectInt("Block4 IndexOf empty needle beyond", BossString.IndexOf("abcdef", "", 99), -1);
   ExpectInt("Block4 IndexOf start", BossString.IndexOf("abcabc", "abc", 1), 3);
   ExpectInt("Block4 IndexOf negative start", BossString.IndexOf("abcabc", "abc", -5), 0);
   ExpectInt("Block4 IndexOf start too large", BossString.IndexOf("abcabc", "abc", 99), -1);
   ExpectInt("Block4 IndexOf empty value", BossString.IndexOf("", "a"), -1);
   ExpectInt("Block4 IndexOf empty value empty needle", BossString.IndexOf("", ""), 0);

   ExpectInt("Block4 LastIndexOf basic", BossString.LastIndexOf("abcabc", "abc"), 3);
   ExpectInt("Block4 LastIndexOf single", BossString.LastIndexOf("abcdef", "cd"), 2);
   ExpectInt("Block4 LastIndexOf missing", BossString.LastIndexOf("abcdef", "xy"), -1);
   ExpectInt("Block4 LastIndexOf empty needle", BossString.LastIndexOf("abcdef", ""), 6);
   ExpectInt("Block4 LastIndexOf empty value", BossString.LastIndexOf("", "a"), -1);
   ExpectInt("Block4 LastIndexOf empty value empty needle", BossString.LastIndexOf("", ""), 0);

   ExpectInt("Block4 CountOccurrences none", BossString.CountOccurrences("abcdef", "xy"), 0);
   ExpectInt("Block4 CountOccurrences one", BossString.CountOccurrences("abcdef", "cd"), 1);
   ExpectInt("Block4 CountOccurrences many", BossString.CountOccurrences("abcabcabc", "abc"), 3);
   ExpectInt("Block4 CountOccurrences non-overlap", BossString.CountOccurrences("aaaa", "aa"), 2);
   ExpectInt("Block4 CountOccurrences empty value", BossString.CountOccurrences("", "a"), 0);
   ExpectInt("Block4 CountOccurrences empty needle", BossString.CountOccurrences("abc", ""), 0);

   ExpectString("Block4 Substring basic", BossString.Substring("abcdef", 2, 3), "cde");
   ExpectString("Block4 Substring start zero", BossString.Substring("abcdef", 0, 2), "ab");
   ExpectString("Block4 Substring negative start clamps", BossString.Substring("abcdef", -3, 2), "ab");
   ExpectString("Block4 Substring beyond end empty", BossString.Substring("abcdef", 99, 2), "");
   ExpectString("Block4 Substring zero count empty", BossString.Substring("abcdef", 2, 0), "");
   ExpectString("Block4 Substring negative count empty", BossString.Substring("abcdef", 2, -1), "");
   ExpectString("Block4 Substring count clamps", BossString.Substring("abcdef", 4, 99), "ef");
   ExpectString("Block4 Substring empty value", BossString.Substring("", 0, 2), "");

   ExpectString("Block4 Left basic", BossString.Left("abcdef", 3), "abc");
   ExpectString("Block4 Left zero", BossString.Left("abcdef", 0), "");
   ExpectString("Block4 Left negative", BossString.Left("abcdef", -1), "");
   ExpectString("Block4 Left beyond", BossString.Left("abcdef", 99), "abcdef");
   ExpectString("Block4 Left empty", BossString.Left("", 3), "");

   ExpectString("Block4 Right basic", BossString.Right("abcdef", 3), "def");
   ExpectString("Block4 Right zero", BossString.Right("abcdef", 0), "");
   ExpectString("Block4 Right negative", BossString.Right("abcdef", -1), "");
   ExpectString("Block4 Right beyond", BossString.Right("abcdef", 99), "abcdef");
   ExpectString("Block4 Right empty", BossString.Right("", 3), "");

   ExpectString("Block4 Mid basic", BossString.Mid("abcdef", 2, 3), "cde");
   ExpectString("Block4 Mid start", BossString.Mid("abcdef", 0, 2), "ab");
   ExpectString("Block4 Mid negative start", BossString.Mid("abcdef", -1, 2), "ab");
   ExpectString("Block4 Mid beyond", BossString.Mid("abcdef", 99, 2), "");
   ExpectString("Block4 Mid count clamps", BossString.Mid("abcdef", 4, 99), "ef");

   Print("=== BossR_String Verification Complete ===");
   Print("PASS ", g_pass, " / FAIL ", g_fail);

   return INIT_SUCCEEDED;
}