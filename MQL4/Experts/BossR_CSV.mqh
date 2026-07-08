//+------------------------------------------------------------------+
//| BossR_CSV.mqh                                                    |
//| Production CSV read/write layer                                  |
//+------------------------------------------------------------------+
#property strict

#ifndef __BOSSR_CSV_MQH__
#define __BOSSR_CSV_MQH__

#include <BossR\BossR_File.mqh>

class C_BossR_CSV
{
private:
   C_BossR_File m_file;

   string       m_path;
   ushort       m_delimiter;
   bool         m_open;

   int          m_read_handle;
   bool         m_read_open;

private:
   string Delim()
   {
      return CharToString((uchar)m_delimiter);
   }

   void PushField(string &fields[], string value)
   {
      int n = ArraySize(fields);
      ArrayResize(fields, n + 1);
      fields[n] = value;
   }

public:
   C_BossR_CSV()
   {
      m_path        = "";
      m_delimiter   = ',';
      m_open        = false;
      m_read_handle = INVALID_HANDLE;
      m_read_open   = false;
   }

   ~C_BossR_CSV()
   {
      Close();
   }

   void Close()
   {
      if(m_open)
      {
         m_file.Close();
         m_open = false;
      }

      if(m_read_open && m_read_handle != INVALID_HANDLE)
      {
         FileClose(m_read_handle);
         m_read_handle = INVALID_HANDLE;
         m_read_open = false;
      }
   }

   bool IsOpen() const
   {
      return (m_open || m_read_open);
   }

   bool IsWriteOpen() const
   {
      return m_open;
   }

   bool IsReadOpen() const
   {
      return m_read_open;
   }

   string Path() const
   {
      return m_path;
   }

   ushort Delimiter() const
   {
      return m_delimiter;
   }

   bool OpenWrite(const string path, const ushort delimiter = ',')
   {
      Close();

      m_path      = path;
      m_delimiter = delimiter;

      m_open = m_file.Open(path, FILE_WRITE | FILE_TXT);
      return m_open;
   }

   bool OpenAppend(const string path, const ushort delimiter = ',')
   {
      Close();

      m_path      = path;
      m_delimiter = delimiter;

      if(!m_file.Open(path, FILE_READ | FILE_WRITE | FILE_TXT))
         return false;

      if(!m_file.SeekEnd())
      {
         m_file.Close();
         return false;
      }

      m_open = true;
      return true;
   }

   bool OpenRead(const string path, const ushort delimiter = ',')
   {
      Close();

      m_path      = path;
      m_delimiter = delimiter;

      m_read_handle = FileOpen(path, FILE_READ | FILE_BIN);
      if(m_read_handle == INVALID_HANDLE)
      {
         m_read_open = false;
         return false;
      }

      m_read_open = true;
      return true;
   }

   bool IsEOF()
   {
      if(!m_read_open || m_read_handle == INVALID_HANDLE)
         return true;

      return FileIsEnding(m_read_handle);
   }

   bool Flush()
   {
      if(!m_open)
         return false;

      return m_file.Flush();
   }

   bool Delete(const string path)
   {
      Close();
      return m_file.Delete(path);
   }

   bool Exists(const string path)
   {
      return m_file.Exists(path);
   }

   int Size()
   {
      if(m_open)
         return m_file.Size();

      if(m_read_open && m_read_handle != INVALID_HANDLE)
         return (int)FileSize(m_read_handle);

      if(m_path == "")
         return -1;

      int h = FileOpen(m_path, FILE_READ | FILE_BIN);
      if(h == INVALID_HANDLE)
         return -1;

      int s = (int)FileSize(h);
      FileClose(h);
      return s;
   }

private:
   string EscapeField(const string value)
   {
      string s = value;

      bool quote =
         (StringFind(s, Delim()) >= 0) ||
         (StringFind(s, "\"") >= 0) ||
         (StringFind(s, "\r") >= 0) ||
         (StringFind(s, "\n") >= 0);

      if(!quote)
         return s;

      StringReplace(s, "\"", "\"\"");

      return "\"" + s + "\"";
   }

   string BuildRow(string &fields[])
   {
      string row = "";

      int count = ArraySize(fields);

      for(int i = 0; i < count; i++)
      {
         if(i > 0)
            row += Delim();

         row += EscapeField(fields[i]);
      }

      return row;
   }

public:
   bool WriteRow(string &fields[])
   {
      if(!m_open)
         return false;

      string row = BuildRow(fields);

      return m_file.WriteStringRaw(row + "\r\n");
   }

   bool Write1(const string a)
   {
      string f[];
      ArrayResize(f, 1);
      f[0] = a;
      return WriteRow(f);
   }

   bool Write2(const string a, const string b)
   {
      string f[];
      ArrayResize(f, 2);
      f[0] = a;
      f[1] = b;
      return WriteRow(f);
   }

   bool Write3(const string a, const string b, const string c)
   {
      string f[];
      ArrayResize(f, 3);
      f[0] = a;
      f[1] = b;
      f[2] = c;
      return WriteRow(f);
   }

   bool Write4(const string a, const string b, const string c, const string d)
   {
      string f[];
      ArrayResize(f, 4);
      f[0] = a;
      f[1] = b;
      f[2] = c;
      f[3] = d;
      return WriteRow(f);
   }

   bool Write5(const string a, const string b, const string c, const string d, const string e)
   {
      string f[];
      ArrayResize(f, 5);
      f[0] = a;
      f[1] = b;
      f[2] = c;
      f[3] = d;
      f[4] = e;
      return WriteRow(f);
   }

   bool Write6(const string a, const string b, const string c, const string d, const string e, const string g)
   {
      string f[];
      ArrayResize(f, 6);
      f[0] = a;
      f[1] = b;
      f[2] = c;
      f[3] = d;
      f[4] = e;
      f[5] = g;
      return WriteRow(f);
   }

   bool ReadRow(string &fields[])
   {
      ArrayResize(fields, 0);

      if(!m_read_open || m_read_handle == INVALID_HANDLE)
         return false;

      if(FileIsEnding(m_read_handle))
         return false;

      string field = "";
      bool in_quotes = false;
      bool got_any = false;

      while(!FileIsEnding(m_read_handle))
      {
         int c = FileReadInteger(m_read_handle, CHAR_VALUE);
         got_any = true;

         if(in_quotes)
         {
            if(c == '"')
            {
               if(!FileIsEnding(m_read_handle))
               {
                  int pos = (int)FileTell(m_read_handle);
                  int next = FileReadInteger(m_read_handle, CHAR_VALUE);

                  if(next == '"')
                  {
                     field += "\"";
                  }
                  else
                  {
                     FileSeek(m_read_handle, pos, SEEK_SET);
                     in_quotes = false;
                  }
               }
               else
               {
                  in_quotes = false;
               }
            }
            else
            {
               field += CharToString((uchar)c);
            }
         }
         else
         {
            if(c == '"')
            {
               in_quotes = true;
            }
            else if(c == m_delimiter)
            {
               PushField(fields, field);
               field = "";
            }
            else if(c == '\r')
            {
               if(!FileIsEnding(m_read_handle))
               {
                  int pos2 = (int)FileTell(m_read_handle);
                  int next2 = FileReadInteger(m_read_handle, CHAR_VALUE);

                  if(next2 != '\n')
                     FileSeek(m_read_handle, pos2, SEEK_SET);
               }

               PushField(fields, field);
               return true;
            }
            else if(c == '\n')
            {
               PushField(fields, field);
               return true;
            }
            else
            {
               field += CharToString((uchar)c);
            }
         }
      }

      if(got_any)
      {
         PushField(fields, field);
         return true;
      }

      return false;
   }
};

#endif