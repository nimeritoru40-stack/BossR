//+------------------------------------------------------------------+
//| BossR_File.mqh                                                   |
//| Production MT4 file wrapper                                      |
//+------------------------------------------------------------------+
#property strict

#ifndef __BOSSR_FILE_MQH__
#define __BOSSR_FILE_MQH__

class C_BossR_File
{
private:
   int    m_handle;
   string m_path;
   int    m_flags;
   bool   m_open;

public:
   C_BossR_File()
   {
      m_handle = INVALID_HANDLE;
      m_path   = "";
      m_flags  = 0;
      m_open   = false;
   }

   ~C_BossR_File()
   {
      Close();
   }

   bool Open(const string path, const int flags, const ushort delimiter = ';')
   {
      Close();

      ResetLastError();

      m_handle = FileOpen(path, flags, delimiter);

      if(m_handle == INVALID_HANDLE)
      {
         m_open  = false;
         m_path  = path;
         m_flags = flags;
         return false;
      }

      m_open  = true;
      m_path  = path;
      m_flags = flags;
      return true;
   }

   void Close()
   {
      if(m_open && m_handle != INVALID_HANDLE)
         FileClose(m_handle);

      m_handle = INVALID_HANDLE;
      m_open   = false;
   }

   bool IsOpen() const
   {
      return (m_open && m_handle != INVALID_HANDLE);
   }

   int Handle() const
   {
      return m_handle;
   }

   string Path() const
   {
      return m_path;
   }

   int Flags() const
   {
      return m_flags;
   }

   int LastError() const
   {
      return GetLastError();
   }

   bool Flush()
   {
      if(!IsOpen()) return false;

      ResetLastError();
      FileFlush(m_handle);
      return (GetLastError() == 0);
   }

   bool Delete(const string path, const int common_flag = 0)
   {
      ResetLastError();
      return FileDelete(path, common_flag);
   }

   bool Exists(const string path, const int common_flag = 0)
   {
      ResetLastError();

      int h = FileOpen(path, FILE_READ | FILE_BIN | common_flag);
      if(h == INVALID_HANDLE)
         return false;

      FileClose(h);
      return true;
   }

   int Size()
   {
      if(!IsOpen()) return -1;

      ResetLastError();
      return (int)FileSize(m_handle);
   }

   int Tell()
   {
      if(!IsOpen()) return -1;

      ResetLastError();
      return (int)FileTell(m_handle);
   }

   bool Seek(const int offset, const int origin)
   {
      if(!IsOpen()) return false;

      ResetLastError();
      return FileSeek(m_handle, offset, origin);
   }

   bool SeekStart()
   {
      return Seek(0, SEEK_SET);
   }

   bool SeekEnd()
   {
      return Seek(0, SEEK_END);
   }

   bool IsEnding()
   {
      if(!IsOpen()) return true;

      ResetLastError();
      return FileIsEnding(m_handle);
   }

   bool WriteStringRaw(const string text)
   {
      if(!IsOpen()) return false;

      ResetLastError();
      uint written = (uint)FileWriteString(m_handle, text);
      return (written == (uint)StringLen(text));
   }

   bool WriteLine(const string text)
   {
      if(!IsOpen()) return false;

      ResetLastError();
      uint written = (uint)FileWrite(m_handle, text);
      return (written > 0);
   }

   bool WriteCSV2(const string a, const string b)
   {
      if(!IsOpen()) return false;

      ResetLastError();
      uint written = (uint)FileWrite(m_handle, a, b);
      return (written > 0);
   }

   bool WriteCSV3(const string a, const string b, const string c)
   {
      if(!IsOpen()) return false;

      ResetLastError();
      uint written = (uint)FileWrite(m_handle, a, b, c);
      return (written > 0);
   }

   bool WriteCSV4(const string a, const string b, const string c, const string d)
   {
      if(!IsOpen()) return false;

      ResetLastError();
      uint written = (uint)FileWrite(m_handle, a, b, c, d);
      return (written > 0);
   }

   string ReadString()
   {
      if(!IsOpen()) return "";

      ResetLastError();
      return FileReadString(m_handle);
   }

   int ReadInteger(const int size = INT_VALUE)
   {
      if(!IsOpen()) return 0;

      ResetLastError();
      return FileReadInteger(m_handle, size);
   }

   bool WriteInteger(const int value, const int size = INT_VALUE)
   {
      if(!IsOpen()) return false;

      ResetLastError();
      FileWriteInteger(m_handle, value, size);
      return (GetLastError() == 0);
   }

   int ReadArray(uchar &buffer[], const int start, const int count)
   {
      if(!IsOpen()) return -1;

      ResetLastError();
      return (int)FileReadArray(m_handle, buffer, start, count);
   }

   int WriteArray(const uchar &buffer[], const int start, const int count)
   {
      if(!IsOpen()) return -1;

      ResetLastError();
      return (int)FileWriteArray(m_handle, buffer, start, count);
   }
};

#endif