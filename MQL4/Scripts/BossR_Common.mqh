//+------------------------------------------------------------------+
//| BossR Common Header                                              |
//+------------------------------------------------------------------+
#ifndef __BOSSR_COMMON_MQH__
#define __BOSSR_COMMON_MQH__

//--- Platform Name
#define BOSSR_PLATFORM "BossR"
#define BOSSR_PLATFORM_VERSION "1.0"

//--- Version Constants
#define BOSSR_VERSION_MAJOR 1
#define BOSSR_VERSION_MINOR 0
#define BOSSR_VERSION_PATCH 0

//--- Module Identifiers
#define MODULE_CORE       1
#define MODULE_TRADE      2
#define MODULE_SIGNAL     3
#define MODULE_RISK       4
#define MODULE_UTILITY    5

//--- Error Codes
#define ERR_BOSSR_OK              0
#define ERR_BOSSR_INVALID_PARAM   1001
#define ERR_BOSSR_NOT_INITIALIZED 1002
#define ERR_BOSSR_TRADE_FAILED    1003
#define ERR_BOSSR_SIGNAL_ERROR    1004

//--- Basic Init Helpers
bool InitBossR()
{
   return true;
}

void UninitBossR()
{
}

//--- Safe String Helpers
string SafeStringCopy(string source, int maxLen = 256)
{
   if(maxLen <= 0) maxLen = 256;
   return StringSubstr(source, 0, maxLen);
}

bool SafeStringValid(string str)
{
   return StringLen(str) > 0;
}

//--- Global Compile Checks
#ifndef MQL4
   #error "This include file is for MQL4 only"
#endif

#endif // __BOSSR_COMMON_MQH__
