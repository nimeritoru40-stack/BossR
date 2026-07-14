//+------------------------------------------------------------------+
//| BossR_Filter_Block7_AGGREGATION_FIXED_FULL.mqh                         |
//| BossR Framework - Filter Module                                  |
//| Block 7: deterministic filter aggregation engine                 |
//| MT4 only                                                         |
//+------------------------------------------------------------------+
#ifndef __BOSSR_FILTER_BLOCK7_AGGREGATION_FIXED_FULL_MQH__
#define __BOSSR_FILTER_BLOCK7_AGGREGATION_FIXED_FULL_MQH__

#include <BossR\BossR_Filter_Block6_VOLUME_FULL.mqh>

#define BOSSR_FILTER_MAX_AGGREGATE_STAGES 16

enum ENUM_BOSSR_FILTER_AGGREGATION_MODE
{
   BOSSR_FILTER_AGGREGATION_EVALUATE_ALL   = 0,
   BOSSR_FILTER_AGGREGATION_SHORT_CIRCUIT  = 1
};

struct SBossRFilterAggregateStage
{
   string                     name;
   bool                       configured;
   bool                       enabled;
   int                        order;
   SBossRFilterResult         result;

   void Reset(void)
   {
      name       = "";
      configured = false;
      enabled    = false;
      order      = -1;
      result.Reset();
   }
};

struct SBossRFilterAggregateResult
{
   ENUM_BOSSR_FILTER_DECISION decision;
   bool                       valid;
   datetime                   evaluated_at;
   int                        configured_count;
   int                        enabled_count;
   int                        evaluated_count;
   int                        passed_count;
   int                        failed_count;
   int                        unavailable_count;
   int                        disabled_count;
   int                        skipped_count;
   int                        terminal_stage_index;
   string                     terminal_stage_name;
   string                     reason;

   void Reset(void)
   {
      decision             = BOSSR_FILTER_DECISION_UNAVAILABLE;
      valid                = false;
      evaluated_at         = 0;
      configured_count     = 0;
      enabled_count        = 0;
      evaluated_count      = 0;
      passed_count         = 0;
      failed_count         = 0;
      unavailable_count    = 0;
      disabled_count       = 0;
      skipped_count        = 0;
      terminal_stage_index = -1;
      terminal_stage_name  = "";
      reason               = "";
   }
};

class CBossRFilterAggregationEngine
{
private:
   SBossRFilterAggregateStage m_stages[BOSSR_FILTER_MAX_AGGREGATE_STAGES];
   int                        m_stage_count;
   ENUM_BOSSR_FILTER_AGGREGATION_MODE m_mode;

   SBossRFilterAggregateResult m_last_result;

   long m_pipeline_evaluation_count;
   long m_pipeline_pass_count;
   long m_pipeline_fail_count;
   long m_pipeline_unavailable_count;
   long m_stage_evaluation_count;
   long m_stage_pass_count;
   long m_stage_fail_count;
   long m_stage_unavailable_count;
   long m_stage_disabled_count;
   long m_stage_skipped_count;

   string Trimmed(const string value) const
   {
      string result = value;
      result = StringTrimLeft(result);
      result = StringTrimRight(result);
      return(result);
   }

   bool IsValidDecision(const ENUM_BOSSR_FILTER_DECISION decision) const
   {
      return(decision == BOSSR_FILTER_DECISION_UNAVAILABLE ||
             decision == BOSSR_FILTER_DECISION_PASS ||
             decision == BOSSR_FILTER_DECISION_FAIL);
   }

   bool IsValidMode(const ENUM_BOSSR_FILTER_AGGREGATION_MODE mode) const
   {
      return(mode == BOSSR_FILTER_AGGREGATION_EVALUATE_ALL ||
             mode == BOSSR_FILTER_AGGREGATION_SHORT_CIRCUIT);
   }

   bool IsValidStageIndex(const int index) const
   {
      return(index >= 0 &&
             index < m_stage_count &&
             index < BOSSR_FILTER_MAX_AGGREGATE_STAGES);
   }

   bool IsValidResult(const SBossRFilterResult &result) const
   {
      if(!result.valid)
         return(false);

      if(!IsValidDecision(result.decision))
         return(false);

      if(result.evaluated_at <= 0)
         return(false);

      if(!MathIsValidNumber(result.value) ||
         !MathIsValidNumber(result.threshold))
      {
         return(false);
      }

      return(true);
   }

   string DecisionTextInternal(
      const ENUM_BOSSR_FILTER_DECISION decision) const
   {
      if(decision == BOSSR_FILTER_DECISION_PASS)
         return("PASS");

      if(decision == BOSSR_FILTER_DECISION_FAIL)
         return("FAIL");

      if(decision == BOSSR_FILTER_DECISION_UNAVAILABLE)
         return("UNAVAILABLE");

      return("INVALID");
   }

   string StageReason(const int index,
                      const SBossRFilterResult &result) const
   {
      string reason = result.reason;

      if(reason == "")
         reason = DecisionTextInternal(result.decision);

      return(m_stages[index].name + ": " + reason);
   }

   void RecordPipelineStatistics(
      const SBossRFilterAggregateResult &result)
   {
      m_pipeline_evaluation_count++;

      if(result.decision == BOSSR_FILTER_DECISION_PASS)
         m_pipeline_pass_count++;
      else if(result.decision == BOSSR_FILTER_DECISION_FAIL)
         m_pipeline_fail_count++;
      else
         m_pipeline_unavailable_count++;

      m_stage_evaluation_count  += result.evaluated_count;
      m_stage_pass_count        += result.passed_count;
      m_stage_fail_count        += result.failed_count;
      m_stage_unavailable_count += result.unavailable_count;
      m_stage_disabled_count    += result.disabled_count;
      m_stage_skipped_count     += result.skipped_count;
   }

public:
   CBossRFilterAggregationEngine(void)
   {
      Reset();
   }

   void Reset(void)
   {
      for(int i = 0; i < BOSSR_FILTER_MAX_AGGREGATE_STAGES; i++)
         m_stages[i].Reset();

      m_stage_count = 0;
      m_mode        = BOSSR_FILTER_AGGREGATION_SHORT_CIRCUIT;
      m_last_result.Reset();
      ClearRuntimeStatistics();
   }

   void ClearStages(void)
   {
      for(int i = 0; i < BOSSR_FILTER_MAX_AGGREGATE_STAGES; i++)
         m_stages[i].Reset();

      m_stage_count = 0;
      m_last_result.Reset();
   }

   void ClearRuntimeStatistics(void)
   {
      m_pipeline_evaluation_count  = 0;
      m_pipeline_pass_count        = 0;
      m_pipeline_fail_count        = 0;
      m_pipeline_unavailable_count = 0;
      m_stage_evaluation_count     = 0;
      m_stage_pass_count           = 0;
      m_stage_fail_count           = 0;
      m_stage_unavailable_count    = 0;
      m_stage_disabled_count       = 0;
      m_stage_skipped_count        = 0;
   }

   bool SetMode(const ENUM_BOSSR_FILTER_AGGREGATION_MODE mode)
   {
      if(!IsValidMode(mode))
         return(false);

      m_mode = mode;
      return(true);
   }

   ENUM_BOSSR_FILTER_AGGREGATION_MODE Mode(void) const
   {
      return(m_mode);
   }

   bool ShortCircuitEnabled(void) const
   {
      return(m_mode == BOSSR_FILTER_AGGREGATION_SHORT_CIRCUIT);
   }

   int Capacity(void) const
   {
      return(BOSSR_FILTER_MAX_AGGREGATE_STAGES);
   }

   int StageCount(void) const
   {
      return(m_stage_count);
   }

   bool AddStage(const string name,
                 const bool enabled = true)
   {
      const string clean_name = Trimmed(name);

      if(clean_name == "")
         return(false);

      if(m_stage_count >= BOSSR_FILTER_MAX_AGGREGATE_STAGES)
         return(false);

      for(int i = 0; i < m_stage_count; i++)
      {
         if(m_stages[i].configured &&
            m_stages[i].name == clean_name)
         {
            return(false);
         }
      }

      const int index = m_stage_count;
      m_stages[index].Reset();
      m_stages[index].name       = clean_name;
      m_stages[index].configured = true;
      m_stages[index].enabled    = enabled;
      m_stages[index].order      = index;
      m_stage_count++;

      return(true);
   }

   bool IsStageConfigured(const int index) const
   {
      if(!IsValidStageIndex(index))
         return(false);

      return(m_stages[index].configured);
   }

   string StageName(const int index) const
   {
      if(!IsValidStageIndex(index))
         return("");

      return(m_stages[index].name);
   }

   int StageOrder(const int index) const
   {
      if(!IsValidStageIndex(index))
         return(-1);

      return(m_stages[index].order);
   }

   bool SetStageEnabled(const int index,
                        const bool enabled)
   {
      if(!IsValidStageIndex(index))
         return(false);

      if(!m_stages[index].configured)
         return(false);

      m_stages[index].enabled = enabled;
      return(true);
   }

   bool IsStageEnabled(const int index) const
   {
      if(!IsValidStageIndex(index))
         return(false);

      return(m_stages[index].configured &&
             m_stages[index].enabled);
   }

   bool SetStageResult(const int index,
                       const SBossRFilterResult &result)
   {
      if(!IsValidStageIndex(index))
         return(false);

      if(!m_stages[index].configured)
         return(false);

      m_stages[index].result = result;
      return(true);
   }

   bool BuildStageResult(SBossRFilterResult &result,
                         const ENUM_BOSSR_FILTER_DECISION decision,
                         const datetime evaluated_at,
                         const double value,
                         const double threshold,
                         const string reason = "") const
   {
      result.Reset();

      if(!IsValidDecision(decision))
         return(false);

      if(evaluated_at <= 0)
         return(false);

      if(!MathIsValidNumber(value) ||
         !MathIsValidNumber(threshold))
      {
         return(false);
      }

      result.decision     = decision;
      result.valid        = true;
      result.evaluated_at = evaluated_at;
      result.value        = value;
      result.threshold    = threshold;
      result.reason       = reason;

      return(true);
   }

   bool SetStageDecision(const int index,
                         const ENUM_BOSSR_FILTER_DECISION decision,
                         const datetime evaluated_at,
                         const double value,
                         const double threshold,
                         const string reason = "")
   {
      SBossRFilterResult result;

      if(!BuildStageResult(result,
                           decision,
                           evaluated_at,
                           value,
                           threshold,
                           reason))
      {
         return(false);
      }

      return(SetStageResult(index, result));
   }

   bool ClearStageResult(const int index)
   {
      if(!IsValidStageIndex(index))
         return(false);

      m_stages[index].result.Reset();
      return(true);
   }

   bool Evaluate(const datetime evaluated_at = 0)
   {
      SBossRFilterAggregateResult aggregate;
      aggregate.Reset();

      datetime event_time = evaluated_at;

      if(event_time <= 0)
         event_time = TimeCurrent();

      if(event_time <= 0)
         return(false);

      aggregate.valid            = true;
      aggregate.evaluated_at     = event_time;
      aggregate.configured_count = m_stage_count;

      bool has_unavailable = false;
      int first_unavailable_index = -1;
      string first_unavailable_reason = "";

      for(int i = 0; i < m_stage_count; i++)
      {
         if(!m_stages[i].configured)
            continue;

         if(!m_stages[i].enabled)
         {
            aggregate.disabled_count++;
            continue;
         }

         aggregate.enabled_count++;

         SBossRFilterResult stage_result = m_stages[i].result;

         if(!IsValidResult(stage_result))
         {
            stage_result.Reset();
            stage_result.decision     = BOSSR_FILTER_DECISION_UNAVAILABLE;
            stage_result.valid        = true;
            stage_result.evaluated_at = event_time;
            stage_result.value        = 0.0;
            stage_result.threshold    = 0.0;
            stage_result.reason       = "Result unavailable";
         }

         aggregate.evaluated_count++;

         if(stage_result.decision == BOSSR_FILTER_DECISION_PASS)
         {
            aggregate.passed_count++;
         }
         else if(stage_result.decision == BOSSR_FILTER_DECISION_FAIL)
         {
            aggregate.failed_count++;

            if(aggregate.failed_count == 1)
            {
               aggregate.decision             = BOSSR_FILTER_DECISION_FAIL;
               aggregate.terminal_stage_index = i;
               aggregate.terminal_stage_name  = m_stages[i].name;
               aggregate.reason               = StageReason(i, stage_result);
            }

            if(ShortCircuitEnabled())
            {
               for(int j = i + 1; j < m_stage_count; j++)
               {
                  if(m_stages[j].configured &&
                     m_stages[j].enabled)
                  {
                     aggregate.skipped_count++;
                  }
                  else if(m_stages[j].configured)
                  {
                     aggregate.disabled_count++;
                  }
               }

               m_last_result = aggregate;
               RecordPipelineStatistics(aggregate);
               return(true);
            }
         }
         else
         {
            aggregate.unavailable_count++;

            if(!has_unavailable)
            {
               has_unavailable          = true;
               first_unavailable_index  = i;
               first_unavailable_reason = StageReason(i, stage_result);
            }
         }
      }

      if(aggregate.enabled_count <= 0)
      {
         aggregate.decision             = BOSSR_FILTER_DECISION_UNAVAILABLE;
         aggregate.terminal_stage_index = -1;
         aggregate.terminal_stage_name  = "";
         aggregate.reason               = "No enabled filters";
      }
      else if(aggregate.failed_count > 0)
      {
         aggregate.decision = BOSSR_FILTER_DECISION_FAIL;

         if(aggregate.reason == "")
            aggregate.reason = "One or more filters failed";
      }
      else if(has_unavailable)
      {
         aggregate.decision             = BOSSR_FILTER_DECISION_UNAVAILABLE;
         aggregate.terminal_stage_index = first_unavailable_index;
         aggregate.terminal_stage_name  =
            m_stages[first_unavailable_index].name;
         aggregate.reason = first_unavailable_reason;
      }
      else
      {
         aggregate.decision             = BOSSR_FILTER_DECISION_PASS;
         aggregate.terminal_stage_index = -1;
         aggregate.terminal_stage_name  = "";
         aggregate.reason               = "All enabled filters passed";
      }

      m_last_result = aggregate;
      RecordPipelineStatistics(aggregate);
      return(true);
   }

   ENUM_BOSSR_FILTER_DECISION LastDecision(void) const
   {
      return(m_last_result.decision);
   }

   bool LastResultValid(void) const
   {
      return(m_last_result.valid);
   }

   datetime LastEvaluationTime(void) const
   {
      return(m_last_result.evaluated_at);
   }

   string LastReason(void) const
   {
      return(m_last_result.reason);
   }

   int LastConfiguredCount(void) const
   {
      return(m_last_result.configured_count);
   }

   int LastEnabledCount(void) const
   {
      return(m_last_result.enabled_count);
   }

   int LastEvaluatedCount(void) const
   {
      return(m_last_result.evaluated_count);
   }

   int LastPassedCount(void) const
   {
      return(m_last_result.passed_count);
   }

   int LastFailedCount(void) const
   {
      return(m_last_result.failed_count);
   }

   int LastUnavailableCount(void) const
   {
      return(m_last_result.unavailable_count);
   }

   int LastDisabledCount(void) const
   {
      return(m_last_result.disabled_count);
   }

   int LastSkippedCount(void) const
   {
      return(m_last_result.skipped_count);
   }

   int LastTerminalStageIndex(void) const
   {
      return(m_last_result.terminal_stage_index);
   }

   string LastTerminalStageName(void) const
   {
      return(m_last_result.terminal_stage_name);
   }

   bool Passed(void) const
   {
      return(m_last_result.valid &&
             m_last_result.decision == BOSSR_FILTER_DECISION_PASS);
   }

   bool Failed(void) const
   {
      return(m_last_result.valid &&
             m_last_result.decision == BOSSR_FILTER_DECISION_FAIL);
   }

   bool Unavailable(void) const
   {
      return(m_last_result.valid &&
             m_last_result.decision ==
                BOSSR_FILTER_DECISION_UNAVAILABLE);
   }

   string DecisionText(
      const ENUM_BOSSR_FILTER_DECISION decision) const
   {
      return(DecisionTextInternal(decision));
   }

   long PipelineEvaluationCount(void) const
   {
      return(m_pipeline_evaluation_count);
   }

   long PipelinePassCount(void) const
   {
      return(m_pipeline_pass_count);
   }

   long PipelineFailCount(void) const
   {
      return(m_pipeline_fail_count);
   }

   long PipelineUnavailableCount(void) const
   {
      return(m_pipeline_unavailable_count);
   }

   long StageEvaluationCount(void) const
   {
      return(m_stage_evaluation_count);
   }

   long StagePassCount(void) const
   {
      return(m_stage_pass_count);
   }

   long StageFailCount(void) const
   {
      return(m_stage_fail_count);
   }

   long StageUnavailableCount(void) const
   {
      return(m_stage_unavailable_count);
   }

   long StageDisabledCount(void) const
   {
      return(m_stage_disabled_count);
   }

   long StageSkippedCount(void) const
   {
      return(m_stage_skipped_count);
   }

   double PipelinePassRate(void) const
   {
      if(m_pipeline_evaluation_count <= 0)
         return(0.0);

      return((double)m_pipeline_pass_count * 100.0 /
             (double)m_pipeline_evaluation_count);
   }
};

#endif // __BOSSR_FILTER_BLOCK7_AGGREGATION_FIXED_FULL_MQH__
//+------------------------------------------------------------------+
