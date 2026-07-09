#ifndef BOSSR_STRING_MQH
#define BOSSR_STRING_MQH
#property strict

class C_BossR_String
{
private:
   bool IsSpaceChar(const ushort ch) const
   {
      return (ch == 32 || ch == 9 || ch == 10 || ch == 13);
   }

public:
   C_BossR_String() {}
   ~C_BossR_String() {}

   int Length(const string value) const { return StringLen(value); }

   bool IsEmpty(const string value) const { return (StringLen(value) == 0); }

   string TrimLeft(const string value) const
   {
      int len = StringLen(value);
      int i = 0;

      while(i < len && IsSpaceChar((ushort)StringGetCharacter(value, i)))
         i++;

      if(i >= len) return "";
      return StringSubstr(value, i);
   }

   string TrimRight(const string value) const
   {
      int len = StringLen(value);
      int i = len - 1;

      while(i >= 0 && IsSpaceChar((ushort)StringGetCharacter(value, i)))
         i--;

      if(i < 0) return "";
      return StringSubstr(value, 0, i + 1);
   }

   string Trim(const string value) const
   {
      return TrimRight(TrimLeft(value));
   }

   string ToUpper(const string value) const
   {
      string result = value;
      StringToUpper(result);
      return result;
   }

   string ToLower(const string value) const
   {
      string result = value;
      StringToLower(result);
      return result;
   }

   bool EqualsIgnoreCase(const string left, const string right) const
   {
      return (ToUpper(left) == ToUpper(right));
   }

   bool Contains(const string value, const string needle) const
   {
      if(needle == "") return true;
      return (StringFind(value, needle, 0) >= 0);
   }

   bool ContainsIgnoreCase(const string value, const string needle) const
   {
      if(needle == "") return true;
      return (StringFind(ToUpper(value), ToUpper(needle), 0) >= 0);
   }

   bool StartsWith(const string value, const string prefix) const
   {
      int prefix_len = StringLen(prefix);
      if(prefix_len == 0) return true;
      if(StringLen(value) < prefix_len) return false;
      return (StringSubstr(value, 0, prefix_len) == prefix);
   }

   bool StartsWithIgnoreCase(const string value, const string prefix) const
   {
      return StartsWith(ToUpper(value), ToUpper(prefix));
   }

   bool EndsWith(const string value, const string suffix) const
   {
      int value_len  = StringLen(value);
      int suffix_len = StringLen(suffix);

      if(suffix_len == 0) return true;
      if(value_len < suffix_len) return false;

      return (StringSubstr(value, value_len - suffix_len, suffix_len) == suffix);
   }

   bool EndsWithIgnoreCase(const string value, const string suffix) const
   {
      return EndsWith(ToUpper(value), ToUpper(suffix));
   }

   string Replace(const string value, const string from_text, const string to_text) const
   {
      if(from_text == "")
         return value;

      int value_len = StringLen(value);
      int from_len  = StringLen(from_text);

      if(value_len <= 0 || from_len <= 0)
         return value;

      string result = "";
      int pos = 0;

      while(pos < value_len)
      {
         int found = StringFind(value, from_text, pos);

         if(found < 0)
         {
            result += StringSubstr(value, pos);
            break;
         }

         if(found > pos)
            result += StringSubstr(value, pos, found - pos);

         result += to_text;
         pos = found + from_len;
      }

      return result;
   }

   string Remove(const string value, const int start, const int count) const
   {
      int len = StringLen(value);

      if(len <= 0) return "";
      if(start < 0 || start >= len) return value;
      if(count <= 0) return value;

      int safe_count = count;
      if(start + safe_count > len)
         safe_count = len - start;

      int right_start = start + safe_count;

      string left = "";
      string right = "";

      if(start > 0)
         left = StringSubstr(value, 0, start);

      if(right_start < len)
         right = StringSubstr(value, right_start, len - right_start);

      return left + right;
   }

   string Insert(const string value, const int index, const string insert_text) const
   {
      int len = StringLen(value);

      if(insert_text == "")
         return value;

      if(index <= 0)
         return insert_text + value;

      if(index >= len)
         return value + insert_text;

      return StringSubstr(value, 0, index) + insert_text + StringSubstr(value, index);
   }

   string Repeat(const string value, const int count) const
   {
      if(count <= 0 || value == "")
         return "";

      string result = "";

      for(int i = 0; i < count; i++)
         result += value;

      return result;
   }

   int IndexOf(const string value, const string needle, const int start = 0) const
   {
      int len = StringLen(value);

      if(needle == "")
      {
         if(start < 0) return 0;
         if(start <= len) return start;
         return -1;
      }

      if(start < 0)
         return StringFind(value, needle, 0);

      if(start >= len)
         return -1;

      return StringFind(value, needle, start);
   }

   int LastIndexOf(const string value, const string needle) const
   {
      int len = StringLen(value);

      if(needle == "")
         return len;

      int last = -1;
      int pos = StringFind(value, needle, 0);

      while(pos >= 0)
      {
         last = pos;
         pos = StringFind(value, needle, pos + 1);
      }

      return last;
   }

   int CountOccurrences(const string value, const string needle) const
   {
      if(value == "" || needle == "")
         return 0;

      int count = 0;
      int pos = 0;
      int needle_len = StringLen(needle);
      int found = StringFind(value, needle, pos);

      while(found >= 0)
      {
         count++;
         pos = found + needle_len;
         found = StringFind(value, needle, pos);
      }

      return count;
   }

   string Substring(const string value, const int start, const int count) const
   {
      int len = StringLen(value);

      if(len <= 0) return "";
      if(count <= 0) return "";

      int safe_start = start;
      if(safe_start < 0)
         safe_start = 0;

      if(safe_start >= len)
         return "";

      int safe_count = count;
      if(safe_start + safe_count > len)
         safe_count = len - safe_start;

      if(safe_count <= 0)
         return "";

      return StringSubstr(value, safe_start, safe_count);
   }

   string Left(const string value, const int count) const
   {
      return Substring(value, 0, count);
   }

   string Right(const string value, const int count) const
   {
      int len = StringLen(value);

      if(len <= 0) return "";
      if(count <= 0) return "";

      if(count >= len)
         return value;

      return StringSubstr(value, len - count, count);
   }

   string Mid(const string value, const int start, const int count) const
   {
      return Substring(value, start, count);
   }
};

#endif