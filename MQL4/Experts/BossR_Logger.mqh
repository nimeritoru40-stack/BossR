//+------------------------------------------------------------------+
//| BossR_Logger.mqh                                                 |
//+------------------------------------------------------------------+
#ifndef __BOSSR_LOGGER_MQH__
#define __BOSSR_LOGGER_MQH__

#include <BossR\BossR_CSV.mqh>

#define BOSSR_LOG_DEBUG 0
#define BOSSR_LOG_INFO  1
#define BOSSR_LOG_WARN  2
#define BOSSR_LOG_ERROR 3

class C_BossR_Logger
{
private:
   C_BossR_CSV m_csv;

   string m_module;
   string m_path;

   int    m_min_level;
   bool   m_terminal;
   bool   m_csv_enabled;
   bool   m_ready;

private:
   string Timestamp()
   {
      string t = TimeToString(TimeCurrent(), TIME_DATE | TIME_SECONDS);
      StringReplace(t, ".", "-");
      StringReplace(t, " ", "T");
      return t;
   }

   string LevelText(const int level)
   {
      if(level == BOSSR_LOG_DEBUG) return "DEBUG";
      if(level == BOSSR_LOG_INFO)  return "INFO";
      if(level == BOSSR_LOG_WARN)  return "WARN";
      if(level == BOSSR_LOG_ERROR) return "ERROR";
      return "UNKNOWN";
   }

   bool ShouldLog(const int level)
   {
      return (level >= m_min_level);
   }

   bool WriteHeaderIfNeeded()
   {
      if(!m_csv_enabled)
         return true;

      bool need_header = !m_csv.Exists(m_path);

      if(need_header)
      {
         if(!m_csv.OpenWrite(m_path, ','))
            return false;
      }
      else
      {
         if(!m_csv.OpenAppend(m_path, ','))
            return false;

         if(m_csv.Size() <= 0)
            need_header = true;
      }

      if(need_header)
      {
         if(!m_csv.Write5(
            "timestamp",
            "module",
            "level",
            "message",
            "symbol"
         ))
            return false;

         if(!m_csv.Flush())
            return false;
      }

      return true;
   }

public:
   C_BossR_Logger()
   {
      m_module      = "";
      m_path        = "";
      m_min_level   = BOSSR_LOG_INFO;
      m_terminal    = true;
      m_csv_enabled = false;
      m_ready       = false;
   }

   ~C_BossR_Logger()
   {
      Shutdown();
   }

   bool Init(
      const string module_name,
      const int    min_level,
      const bool   terminal_logging,
      const bool   csv_logging,
      const string csv_path
   )
   {
      Shutdown();

      m_module      = module_name;
      m_min_level   = min_level;
      m_terminal    = terminal_logging;
      m_csv_enabled = csv_logging;
      m_path        = csv_path;
      m_ready       = false;

      if(m_module == "")
         m_module = "UNKNOWN";

      if(m_csv_enabled)
      {
         if(m_path == "")
            return false;

         if(!WriteHeaderIfNeeded())
         {
            m_csv.Close();
            return false;
         }
      }

      m_ready = true;
      return true;
   }

   void Shutdown()
   {
      if(m_csv.IsOpen())
      {
         m_csv.Flush();
         m_csv.Close();
      }

      m_ready = false;
   }

   bool IsReady() const
   {
      return m_ready;
   }

   string Module() const
   {
      return m_module;
   }

   string Path() const
   {
      return m_path;
   }

   int MinLevel() const
   {
      return m_min_level;
   }

   bool TerminalEnabled() const
   {
      return m_terminal;
   }

   bool CSVEnabled() const
   {
      return m_csv_enabled;
   }

   int CSVSize()
   {
      if(!m_csv_enabled)
         return 0;

      return m_csv.Size();
   }

   bool DeleteCSV(const string path)
   {
      if(m_csv.IsOpen())
         m_csv.Close();

      return m_csv.Delete(path);
   }

   bool Log(const int level, const string message)
   {
      if(!m_ready)
         return false;

      if(!ShouldLog(level))
         return true;

      string ts  = Timestamp();
      string lvl = LevelText(level);
      string sym = Symbol();

      if(m_terminal)
         Print(ts + " [" + m_module + "] " + lvl + ": " + message);

      if(m_csv_enabled)
      {
         if(!m_csv.IsOpen())
            return false;

         if(!m_csv.Write5(ts, m_module, lvl, message, sym))
            return false;

         if(!m_csv.Flush())
            return false;
      }

      return true;
   }

   bool Debug(const string message)
   {
      return Log(BOSSR_LOG_DEBUG, message);
   }

   bool Info(const string message)
   {
      return Log(BOSSR_LOG_INFO, message);
   }

   bool Warn(const string message)
   {
      return Log(BOSSR_LOG_WARN, message);
   }

   bool Error(const string message)
   {
      return Log(BOSSR_LOG_ERROR, message);
   }
};

#endif