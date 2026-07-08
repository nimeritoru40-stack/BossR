//+------------------------------------------------------------------+
//| BossR_State.mqh                                                  |
//+------------------------------------------------------------------+
#ifndef __BOSSR_STATE_MQH__
#define __BOSSR_STATE_MQH__

#property strict

#include <BossR\BossR_Common.mqh>

#define BOSSR_STATE_TYPE_NONE    0
#define BOSSR_STATE_TYPE_STRING  1
#define BOSSR_STATE_TYPE_INT     2
#define BOSSR_STATE_TYPE_DOUBLE  3
#define BOSSR_STATE_TYPE_BOOL    4

class C_BossR_State
{
private:
   string m_keys[];
   string m_values[];
   int    m_types[];

private:
   bool IsValidKey(const string key) const
   {
      return StringLen(key) > 0;
   }

   int FindIndex(const string key) const
   {
      int total = ArraySize(m_keys);

      for(int i = 0; i < total; i++)
      {
         if(m_types[i] != BOSSR_STATE_TYPE_NONE && m_keys[i] == key)
            return i;
      }

      return -1;
   }

   int FindFreeSlot() const
   {
      int total = ArraySize(m_keys);

      for(int i = 0; i < total; i++)
      {
         if(m_types[i] == BOSSR_STATE_TYPE_NONE)
            return i;
      }

      return -1;
   }

   bool WriteRaw(const string key, const string value, const int type)
   {
      if(!IsValidKey(key))
         return false;

      int index = FindIndex(key);

      if(index < 0)
         index = FindFreeSlot();

      if(index < 0)
      {
         int total = ArraySize(m_keys);
         int next  = total + 1;

         if(ArrayResize(m_keys, next) != next)
            return false;

         if(ArrayResize(m_values, next) != next)
            return false;

         if(ArrayResize(m_types, next) != next)
            return false;

         index = total;
      }

      m_keys[index]   = key;
      m_values[index] = value;
      m_types[index]  = type;

      return true;
   }

public:
   C_BossR_State()
   {
      Clear();
   }

   ~C_BossR_State()
   {
      Clear();
   }

   int Count() const
   {
      int count = 0;
      int total = ArraySize(m_keys);

      for(int i = 0; i < total; i++)
      {
         if(m_types[i] != BOSSR_STATE_TYPE_NONE)
            count++;
      }

      return count;
   }

   bool Exists(const string key) const
   {
      if(!IsValidKey(key))
         return false;

      return FindIndex(key) >= 0;
   }

   bool Remove(const string key)
   {
      int index = FindIndex(key);

      if(index < 0)
         return false;

      m_keys[index]   = "";
      m_values[index] = "";
      m_types[index]  = BOSSR_STATE_TYPE_NONE;

      return true;
   }

   void Clear()
   {
      ArrayResize(m_keys, 0);
      ArrayResize(m_values, 0);
      ArrayResize(m_types, 0);
   }

   bool WriteString(const string key, const string value)
   {
      return WriteRaw(key, value, BOSSR_STATE_TYPE_STRING);
   }

   bool WriteInt(const string key, const int value)
   {
      return WriteRaw(key, IntegerToString(value), BOSSR_STATE_TYPE_INT);
   }

   bool WriteDouble(const string key, const double value)
   {
      return WriteRaw(key, DoubleToString(value, 16), BOSSR_STATE_TYPE_DOUBLE);
   }

   bool WriteBool(const string key, const bool value)
   {
      if(value)
         return WriteRaw(key, "true", BOSSR_STATE_TYPE_BOOL);

      return WriteRaw(key, "false", BOSSR_STATE_TYPE_BOOL);
   }

   string ReadString(const string key, const string default_value = "") const
   {
      int index = FindIndex(key);

      if(index < 0 || m_types[index] != BOSSR_STATE_TYPE_STRING)
         return default_value;

      return m_values[index];
   }

   int ReadInt(const string key, const int default_value = 0) const
   {
      int index = FindIndex(key);

      if(index < 0 || m_types[index] != BOSSR_STATE_TYPE_INT)
         return default_value;

      return (int)StrToInteger(m_values[index]);
   }

   double ReadDouble(const string key, const double default_value = 0.0) const
   {
      int index = FindIndex(key);

      if(index < 0 || m_types[index] != BOSSR_STATE_TYPE_DOUBLE)
         return default_value;

      return StrToDouble(m_values[index]);
   }

   bool ReadBool(const string key, const bool default_value = false) const
   {
      int index = FindIndex(key);

      if(index < 0 || m_types[index] != BOSSR_STATE_TYPE_BOOL)
         return default_value;

      if(m_values[index] == "true")
         return true;

      if(m_values[index] == "false")
         return false;

      return default_value;
   }
};

#endif