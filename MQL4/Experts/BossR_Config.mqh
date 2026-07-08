//+------------------------------------------------------------------+
//| BossR_Config.mqh                                                 |
//+------------------------------------------------------------------+
#ifndef __BOSSR_CONFIG_MQH__
#define __BOSSR_CONFIG_MQH__

#property strict

#include <BossR\BossR_Common.mqh>
#include <BossR\BossR_File.mqh>
#include <BossR\BossR_CSV.mqh>

#define BOSSR_CONFIG_TYPE_STRING "STRING"
#define BOSSR_CONFIG_TYPE_INT    "INT"
#define BOSSR_CONFIG_TYPE_DOUBLE "DOUBLE"
#define BOSSR_CONFIG_TYPE_BOOL   "BOOL"

class C_BossR_Config
{
private:
   string m_path;
   string m_keys[];
   string m_types[];
   string m_values[];
   int    m_count;

   int FindKey(string key)
   {
      for(int i = 0; i < m_count; i++)
      {
         if(m_keys[i] == key)
            return i;
      }
      return -1;
   }

   string BoolToText(bool value)
   {
      if(value)
         return "true";

      return "false";
   }

   bool TextToBool(string value, bool default_value)
   {
      string v = value;
      StringToLower(v);

      if(v == "true" || v == "1" || v == "yes" || v == "on")
         return true;

      if(v == "false" || v == "0" || v == "no" || v == "off")
         return false;

      return default_value;
   }

   void SetValue(string key, string type, string value)
   {
      int idx = FindKey(key);

      if(idx < 0)
      {
         ArrayResize(m_keys, m_count + 1);
         ArrayResize(m_types, m_count + 1);
         ArrayResize(m_values, m_count + 1);

         idx = m_count;
         m_count++;
      }

      m_keys[idx]   = key;
      m_types[idx]  = type;
      m_values[idx] = value;
   }

public:
   C_BossR_Config()
   {
      m_path  = "";
      m_count = 0;
   }

   void Clear()
   {
      ArrayResize(m_keys, 0);
      ArrayResize(m_types, 0);
      ArrayResize(m_values, 0);
      m_count = 0;
   }

   int Count()
   {
      return m_count;
   }

   string Path()
   {
      return m_path;
   }

   bool Exists(string key)
   {
      return (FindKey(key) >= 0);
   }

   bool Load(string path)
   {
      Clear();
      m_path = path;

      C_BossR_CSV csv;

      if(!csv.OpenRead(path, ','))
         return true;

      string row[];

      while(csv.ReadRow(row))
      {
         if(ArraySize(row) < 3)
            continue;

         if(row[0] == "Key" && row[1] == "Type" && row[2] == "Value")
            continue;

         if(StringLen(row[0]) <= 0)
            continue;

         SetValue(row[0], row[1], row[2]);
      }

      csv.Close();
      return true;
   }

   bool Save()
   {
      if(StringLen(m_path) <= 0)
         return false;

      C_BossR_CSV csv;

      if(!csv.OpenWrite(m_path, ','))
         return false;

      string row[];

      ArrayResize(row, 3);

      row[0] = "Key";
      row[1] = "Type";
      row[2] = "Value";

      if(!csv.WriteRow(row))
      {
         csv.Close();
         return false;
      }

      for(int i = 0; i < m_count; i++)
      {
         row[0] = m_keys[i];
         row[1] = m_types[i];
         row[2] = m_values[i];

         if(!csv.WriteRow(row))
         {
            csv.Close();
            return false;
         }
      }

      bool ok = csv.Flush();
      csv.Close();

      return ok;
   }

   bool WriteString(string key, string value)
   {
      SetValue(key, BOSSR_CONFIG_TYPE_STRING, value);
      return Save();
   }

   bool WriteInt(string key, int value)
   {
      SetValue(key, BOSSR_CONFIG_TYPE_INT, IntegerToString(value));
      return Save();
   }

   bool WriteDouble(string key, double value)
   {
      SetValue(key, BOSSR_CONFIG_TYPE_DOUBLE, DoubleToString(value, 8));
      return Save();
   }

   bool WriteBool(string key, bool value)
   {
      SetValue(key, BOSSR_CONFIG_TYPE_BOOL, BoolToText(value));
      return Save();
   }

   string ReadString(string key, string default_value)
   {
      int idx = FindKey(key);

      if(idx < 0)
         return default_value;

      return m_values[idx];
   }

   int ReadInt(string key, int default_value)
   {
      int idx = FindKey(key);

      if(idx < 0)
         return default_value;

      return StrToInteger(m_values[idx]);
   }

   double ReadDouble(string key, double default_value)
   {
      int idx = FindKey(key);

      if(idx < 0)
         return default_value;

      return StrToDouble(m_values[idx]);
   }

   bool ReadBool(string key, bool default_value)
   {
      int idx = FindKey(key);

      if(idx < 0)
         return default_value;

      return TextToBool(m_values[idx], default_value);
   }
};

#endif