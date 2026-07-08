//+------------------------------------------------------------------+
//| BossR_File.mqh                                                   |
//| Production file and CSV helpers for BossR MT4 framework          |
//+------------------------------------------------------------------+
#ifndef __BOSSR_FILE_MQH__
#define __BOSSR_FILE_MQH__

#include <BossR\BossR_Common.mqh>

class C_BossR_File
{
private:
   int    m_handle;
   string m_path;
   bool   m_open;

public:
   C_BossR_File()
   {
      m_handle = INVALID_HANDLE;
      m_path   = "";
      m_open   = false;
   }

   ~C_BossR_File()
   {
      if(IsOpen())
         Close();
   }

   bool Open(const string path, const int flags = FILE_TXT | FILE_READ | FILE_WRITE | FILE_ANSI)
   {
      if(path == "")
         return false;

      if(IsOpen())
         Close();

      m_handle = FileOpen(path, flags);
      if(m_handle == INVALID_HANDLE)
      {
         ResetLastError();
         return false;
      }

      m_path = path;
      m_open = true;
      return true;
   }

   bool IsOpen() const
   {
      return (m_open && m_handle != INVALID_HANDLE);
   }

   bool Close()
   {
      if(!IsOpen())
      {
         m_open = false;
         m_handle = INVALID_HANDLE;
         return true;
      }

      FileClose(m_handle);
      m_handle = INVALID_HANDLE;
      m_open = false;
      return true;
   }

   bool Delete(const string path)
   {
      if(path == "")
         return false;

      return FileDelete(path);
   }

   bool WriteString(const string text)
   {
      if(!IsOpen())
         return false;

      return (FileWriteString(m_handle, text) >= 0);
   }

   bool WriteLine(const string line)
   {
      if(!IsOpen())
         return false;

      return WriteString(line + "\n");
   }

   bool SeekToEnd()
   {
      if(!IsOpen())
         return false;

      return (FileSeek(m_handle, 0, SEEK_END) != -1);
   }

   string Path() const
   {
      return m_path;
   }
};

class C_BossR_CSVWriter
{
private:
   C_BossR_File m_csv;
   string       m_path;
   bool         m_append;

public:
   C_BossR_CSVWriter()
   {
      m_path   = "";
      m_append = false;
   }

   ~C_BossR_CSVWriter()
   {
      if(m_csv.IsOpen())
         m_csv.Close();
   }

   bool Init(const string path, const bool append = false)
   {
      if(path == "")
         return false;

      m_path   = path;
      m_append = append;
      return true;
   }

   bool Open()
   {
      if(m_path == "")
         return false;

      if(m_csv.IsOpen())
         m_csv.Close();

      if(!m_append)
         m_csv.Delete(m_path);

      if(!m_csv.Open(m_path, FILE_TXT | FILE_READ | FILE_WRITE | FILE_ANSI))
         return false;

      if(m_append)
      {
         if(!m_csv.SeekToEnd())
         {
            m_csv.Close();
            return false;
         }
      }

      return true;
   }

   bool IsOpen()
   {
      return m_csv.IsOpen();
   }

   bool Close()
   {
      return m_csv.Close();
   }

   bool DeleteCSV()
   {
      if(m_csv.IsOpen())
         m_csv.Close();

      if(m_path == "")
         return false;

      return m_csv.Delete(m_path);
   }

   static string EscapeValue(const string value)
   {
      string result = value;
      if(result == "")
         return "\"\"";

      if(StringFind(result, "\"", 0) >= 0)
         result = StringReplace(result, "\"", "\"\"");

      bool needsQuotes = false;
      int len = StringLen(result);
      if(len > 0)
      {
         int first = StringGetCharacter(result, 0);
         int last  = StringGetCharacter(result, len - 1);
         if(first == 32 || last == 32 || first == 9 || last == 9)
            needsQuotes = true;
      }

      if(StringFind(result, ",", 0) >= 0 ||
         StringFind(result, "\n", 0) >= 0 ||
         StringFind(result, "\r", 0) >= 0 ||
         StringFind(result, "\"", 0) >= 0 ||
         needsQuotes)
      {
         return "\"" + result + "\"";
      }

      return result;
   }

   bool WriteRow(const string &values[], const int count)
   {
      if(!IsOpen() && !Open())
         return false;

      string line = "";
      for(int i = 0; i < count; ++i)
      {
         if(i > 0)
            line += ",";

         line += EscapeValue(values[i]);
      }

      return m_csv.WriteLine(line);
   }
};

#endif
