#ifndef __BOSSR_COMMON_MQH__
#define __BOSSR_COMMON_MQH__

#property strict

#define BOSSR_PLATFORM_NAME      "BossR"
#define BOSSR_VERSION_MAJOR      1
#define BOSSR_VERSION_MINOR      0
#define BOSSR_VERSION_PATCH      0
#define BOSSR_PLATFORM_VERSION   "1.0.0"

#define BOSSR_MODULE_COMMON      1
#define BOSSR_MODULE_RESEARCH    2
#define BOSSR_MODULE_DISCOVERY   3

#define BOSSR_OK                 0
#define BOSSR_ERR_FILE_OPEN      1002

string BossR_Version(){ return BOSSR_PLATFORM_VERSION; }
string BossR_Name(){ return BOSSR_PLATFORM_NAME; }

string BossR_ModuleName(const int module_id)
{
   if(module_id == BOSSR_MODULE_COMMON) return "COMMON";
   if(module_id == BOSSR_MODULE_RESEARCH) return "RESEARCH";
   if(module_id == BOSSR_MODULE_DISCOVERY) return "DISCOVERY";
   return "UNKNOWN";
}

string BossR_ErrorName(const int error_code)
{
   if(error_code == BOSSR_OK) return "OK";
   if(error_code == BOSSR_ERR_FILE_OPEN) return "FILE_OPEN";
   return "UNMAPPED_ERROR";
}

bool BossR_Init(){ return true; }

#endif