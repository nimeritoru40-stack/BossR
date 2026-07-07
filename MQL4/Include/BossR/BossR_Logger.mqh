//+------------------------------------------------------------------+
//| BossR_Logger.mqh                                                 |
//| Production logger for BossR MT4 framework                         |
//+------------------------------------------------------------------+
#ifndef __BOSSR_LOGGER_MQH__
#define __BOSSR_LOGGER_MQH__

#include <BossR\BossR_Common.mqh>

enum BOSSR_LOG_LEVEL
{
   BOSSR_LOG_DEBUG = 0,
   BOSSR_LOG_INFO  = 1,
   BOSSR_LOG_WARN  = 2,
   BOSSR_LOG_ERROR = 3,
   BOSSR_LOG_OFF   = 4
};

class C_BossR_Logger
{
private:
   string          m_name;
   string          m_fileName;
   BOSSR_LOG_LEVEL m_minLevel;
   bool            m_consoleEnabled;
   bool            m_fileEnabled;
   bool            m_initialized;

   string LevelToText(const BOSSR_LOG_LEVEL level)
   {
      if(level == BOSSR_LOG_DEBUG) return "DEBUG";
      if(level == BOSSR_LOG_INFO)  return "INFO";
      if(level == BOSSR_LOG_WARN)  return "WARN";
      if(level == BOSSR_LOG_ERROR) return "ERROR";
      return "OFF";
   }

   bool ShouldLog(const BOSSR_LOG_LEVEL level)
   {
      if(!m_initialized) return false;
      if(m_minLevel == BOSSR_LOG_OFF) return false;
      return (level >= m_minLevel);
   }

   string BuildLine(const BOSSR_LOG_LEVEL level, const string msg)
   {
      return StringFormat(
         "%s | %s | %s | %s",
         TimeToString(TimeLocal(), TIME_DATE | TIME_SECONDS),
         m_name,
         LevelToText(level),
         msg
      );
   }

   void WriteFileLine(const string line)
   {
      if(!m_fileEnabled || m_fileName == "") return;

      int handle = FileOpen(
         m_fileName,
         FILE_TXT | FILE_READ | FILE_WRITE | FILE_SHARE_READ | FILE_ANSI
      );

      if(handle == INVALID_HANDLE)
      {
         Print("BossR Logger file open failed: ", m_fileName, " err=", GetLastError());
         ResetLastError();
         return;
      }

      FileSeek(handle, 0, SEEK_END);
      FileWrite(handle, line);
      FileClose(handle);
   }

public:
   C_BossR_Logger()
   {
      m_name           = "BossR";
      m_fileName       = "";
      m_minLevel       = BOSSR_LOG_INFO;
      m_consoleEnabled = true;
      m_fileEnabled    = false;
      m_initialized    = false;
   }

   bool Init(
      const string moduleName,
      const BOSSR_LOG_LEVEL minLevel = BOSSR_LOG_INFO,
      const bool consoleEnabled = true,
      const bool fileEnabled = false,
      const string fileName = ""
   )
   {
      if(moduleName == "")
         m_name = "BossR";
      else
         m_name = moduleName;

      m_minLevel       = minLevel;
      m_consoleEnabled = consoleEnabled;
      m_fileEnabled    = fileEnabled;
      m_fileName       = fileName;
      m_initialized    = true;

      Info("Logger initialized");
      return true;
   }

   void Shutdown()
   {
      if(m_initialized)
         Info("Logger shutdown");

      m_initialized = false;
   }

   bool IsInitialized()
   {
      return m_initialized;
   }

   void SetMinLevel(const BOSSR_LOG_LEVEL level)
   {
      m_minLevel = level;
   }

   BOSSR_LOG_LEVEL GetMinLevel()
   {
      return m_minLevel;
   }

   void EnableConsole(const bool enabled)
   {
      m_consoleEnabled = enabled;
   }

   void EnableFile(const bool enabled, const string fileName = "")
   {
      m_fileEnabled = enabled;

      if(fileName != "")
         m_fileName = fileName;
   }

   void Log(const BOSSR_LOG_LEVEL level, const string msg)
   {
      if(!ShouldLog(level)) return;

      string line = BuildLine(level, msg);

      if(m_consoleEnabled)
         Print(line);

      WriteFileLine(line);
   }

   void Debug(const string msg) { Log(BOSSR_LOG_DEBUG, msg); }
   void Info (const string msg) { Log(BOSSR_LOG_INFO,  msg); }
   void Warn (const string msg) { Log(BOSSR_LOG_WARN,  msg); }
   void Error(const string msg) { Log(BOSSR_LOG_ERROR, msg); }
};

#endif