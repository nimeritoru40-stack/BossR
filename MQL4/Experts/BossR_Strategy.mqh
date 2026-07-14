//+------------------------------------------------------------------+
//| BossR_Strategy_Block7_PERFORMANCE_FULL.mqh                              |
//| BossR Framework - Strategy Module                                |
//| Block 1: core identity, configuration and lifecycle state        |
//| MT4 only                                                         |
//+------------------------------------------------------------------+
#ifndef __BOSSR_STRATEGY_BLOCK7_PERFORMANCE_FULL_MQH__
#define __BOSSR_STRATEGY_BLOCK7_PERFORMANCE_FULL_MQH__

//+------------------------------------------------------------------+
//| Strategy evaluation timing                                      |
//+------------------------------------------------------------------+
enum ENUM_BOSSR_STRATEGY_EVALUATION_MODE
{
   BOSSR_STRATEGY_EVALUATE_EVERY_TICK = 0,
   BOSSR_STRATEGY_EVALUATE_NEW_BAR    = 1
};

//+------------------------------------------------------------------+
//| Strategy directional permission                                 |
//+------------------------------------------------------------------+
enum ENUM_BOSSR_STRATEGY_DIRECTION_MODE
{
   BOSSR_STRATEGY_DIRECTION_NONE      = 0,
   BOSSR_STRATEGY_DIRECTION_LONG_ONLY = 1,
   BOSSR_STRATEGY_DIRECTION_SHORT_ONLY= 2,
   BOSSR_STRATEGY_DIRECTION_BOTH      = 3
};

//+------------------------------------------------------------------+
//| Strategy lifecycle state                                        |
//+------------------------------------------------------------------+
enum ENUM_BOSSR_STRATEGY_STATE
{
   BOSSR_STRATEGY_STATE_RESET       = 0,
   BOSSR_STRATEGY_STATE_READY       = 1,
   BOSSR_STRATEGY_STATE_RUNNING     = 2,
   BOSSR_STRATEGY_STATE_PAUSED      = 3,
   BOSSR_STRATEGY_STATE_STOPPED     = 4,
   BOSSR_STRATEGY_STATE_ERROR       = 5
};


//+------------------------------------------------------------------+
//| Strategy signal direction                                       |
//+------------------------------------------------------------------+
enum ENUM_BOSSR_STRATEGY_SIGNAL
{
   BOSSR_STRATEGY_SIGNAL_NONE = 0,
   BOSSR_STRATEGY_SIGNAL_BUY  = 1,
   BOSSR_STRATEGY_SIGNAL_SELL = 2,
   BOSSR_STRATEGY_SIGNAL_EXIT = 3
};


//+------------------------------------------------------------------+
//| Strategy position state                                         |
//+------------------------------------------------------------------+
enum ENUM_BOSSR_STRATEGY_POSITION_STATE
{
   BOSSR_STRATEGY_POSITION_FLAT    = 0,
   BOSSR_STRATEGY_POSITION_PENDING = 1,
   BOSSR_STRATEGY_POSITION_OPEN    = 2
};


//+------------------------------------------------------------------+
//| Strategy reconciliation outcome                                 |
//+------------------------------------------------------------------+
enum ENUM_BOSSR_STRATEGY_RECONCILE_RESULT
{
   BOSSR_STRATEGY_RECONCILE_NO_CHANGE       = 0,
   BOSSR_STRATEGY_RECONCILE_ADOPTED_OPEN    = 1,
   BOSSR_STRATEGY_RECONCILE_UPDATED_OPEN    = 2,
   BOSSR_STRATEGY_RECONCILE_CLEARED_STALE   = 3,
   BOSSR_STRATEGY_RECONCILE_REJECTED        = 4
};

//+------------------------------------------------------------------+
//| Strategy evaluation result                                      |
//+------------------------------------------------------------------+
struct SBossRStrategyResult
{
   ENUM_BOSSR_STRATEGY_SIGNAL signal;
   bool                       valid;
   datetime                   evaluated_at;
   double                     confidence;
   double                     entry_price;
   double                     stop_loss;
   double                     take_profit;
   int                        hold_bars;
   string                     reason;

   void Reset(void)
   {
      signal        = BOSSR_STRATEGY_SIGNAL_NONE;
      valid         = false;
      evaluated_at  = 0;
      confidence    = 0.0;
      entry_price   = 0.0;
      stop_loss     = 0.0;
      take_profit   = 0.0;
      hold_bars     = 0;
      reason        = "";
   }
};

//+------------------------------------------------------------------+
//| CBossRStrategy                                                  |
//+------------------------------------------------------------------+
class CBossRStrategy
{
private:
   string                                m_name;
   int                                   m_id;
   int                                   m_magic_number;
   bool                                  m_enabled;
   ENUM_BOSSR_STRATEGY_EVALUATION_MODE   m_evaluation_mode;
   ENUM_BOSSR_STRATEGY_DIRECTION_MODE    m_direction_mode;
   ENUM_BOSSR_STRATEGY_STATE             m_state;
   datetime                              m_last_evaluation_time;
   datetime                              m_last_signal_time;
   long                                  m_evaluation_count;
   long                                  m_signal_count;
   long                                  m_error_count;
   datetime                              m_last_gate_tick_time;
   datetime                              m_last_gate_bar_time;
   long                                  m_gate_accept_count;
   long                                  m_gate_reject_count;
   int                                   m_signal_cooldown_bars;
   datetime                              m_last_signal_bar_time;
   ENUM_BOSSR_STRATEGY_SIGNAL            m_last_emitted_signal;
   long                                  m_signal_accept_count;
   long                                  m_signal_reject_count;
   ENUM_BOSSR_STRATEGY_POSITION_STATE  m_position_state;
   ENUM_BOSSR_STRATEGY_SIGNAL          m_position_direction;
   int                                   m_position_ticket;
   datetime                              m_position_open_time;
   datetime                              m_position_open_bar_time;
   double                                m_position_entry_price;
   long                                  m_position_open_count;
   long                                  m_position_close_count;
   long                                  m_position_reject_count;
   long                                  m_reconcile_count;
   long                                  m_reconcile_change_count;
   long                                  m_reconcile_reject_count;
   datetime                              m_last_reconcile_time;
   long                                  m_performance_trade_count;
   long                                  m_performance_win_count;
   long                                  m_performance_loss_count;
   long                                  m_performance_breakeven_count;
   double                                m_gross_profit;
   double                                m_gross_loss;
   double                                m_net_profit;
   double                                m_largest_win;
   double                                m_largest_loss;
   int                                   m_current_win_streak;
   int                                   m_current_loss_streak;
   int                                   m_max_win_streak;
   int                                   m_max_loss_streak;
   long                                  m_r_multiple_count;
   double                                m_total_r_multiple;
   double                                m_best_r_multiple;
   double                                m_worst_r_multiple;
   double                                m_total_mfe;
   double                                m_total_mae;
   double                                m_largest_mfe;
   double                                m_largest_mae;
   double                                m_open_trade_mfe;
   double                                m_open_trade_mae;

   string Trimmed(const string value) const
   {
      string result = value;
      result = StringTrimLeft(result);
      result = StringTrimRight(result);
      return(result);
   }

   bool IsValidEvaluationMode(
      const ENUM_BOSSR_STRATEGY_EVALUATION_MODE mode) const
   {
      return(mode == BOSSR_STRATEGY_EVALUATE_EVERY_TICK ||
             mode == BOSSR_STRATEGY_EVALUATE_NEW_BAR);
   }

   bool IsValidDirectionMode(
      const ENUM_BOSSR_STRATEGY_DIRECTION_MODE mode) const
   {
      return(mode == BOSSR_STRATEGY_DIRECTION_NONE       ||
             mode == BOSSR_STRATEGY_DIRECTION_LONG_ONLY  ||
             mode == BOSSR_STRATEGY_DIRECTION_SHORT_ONLY ||
             mode == BOSSR_STRATEGY_DIRECTION_BOTH);
   }

   bool IsValidState(const ENUM_BOSSR_STRATEGY_STATE state) const
   {
      return(state == BOSSR_STRATEGY_STATE_RESET   ||
             state == BOSSR_STRATEGY_STATE_READY   ||
             state == BOSSR_STRATEGY_STATE_RUNNING ||
             state == BOSSR_STRATEGY_STATE_PAUSED  ||
             state == BOSSR_STRATEGY_STATE_STOPPED ||
             state == BOSSR_STRATEGY_STATE_ERROR);
   }

public:
   CBossRStrategy(void)
   {
      Reset();
   }

   void Reset(void)
   {
      m_name                 = "";
      m_id                   = 0;
      m_magic_number         = 0;
      m_enabled              = false;
      m_evaluation_mode      = BOSSR_STRATEGY_EVALUATE_NEW_BAR;
      m_direction_mode       = BOSSR_STRATEGY_DIRECTION_NONE;
      m_state                = BOSSR_STRATEGY_STATE_RESET;
      m_last_evaluation_time = 0;
      m_last_signal_time     = 0;
      m_evaluation_count     = 0;
      m_signal_count         = 0;
      m_error_count          = 0;
      m_last_gate_tick_time     = 0;
      m_last_gate_bar_time      = 0;
      m_gate_accept_count       = 0;
      m_gate_reject_count       = 0;
      m_signal_cooldown_bars     = 0;
      m_last_signal_bar_time     = 0;
      m_last_emitted_signal      = BOSSR_STRATEGY_SIGNAL_NONE;
      m_signal_accept_count      = 0;
      m_signal_reject_count      = 0;
      m_position_state           = BOSSR_STRATEGY_POSITION_FLAT;
      m_position_direction       = BOSSR_STRATEGY_SIGNAL_NONE;
      m_position_ticket          = -1;
      m_position_open_time       = 0;
      m_position_open_bar_time   = 0;
      m_position_entry_price     = 0.0;
      m_position_open_count      = 0;
      m_position_close_count     = 0;
      m_position_reject_count    = 0;
      m_reconcile_count          = 0;
      m_reconcile_change_count   = 0;
      m_reconcile_reject_count   = 0;
      m_last_reconcile_time      = 0;
      m_performance_trade_count = 0;
      m_performance_win_count   = 0;
      m_performance_loss_count  = 0;
      m_performance_breakeven_count = 0;
      m_gross_profit            = 0.0;
      m_gross_loss              = 0.0;
      m_net_profit              = 0.0;
      m_largest_win             = 0.0;
      m_largest_loss            = 0.0;
      m_current_win_streak      = 0;
      m_current_loss_streak     = 0;
      m_max_win_streak          = 0;
      m_max_loss_streak         = 0;
      m_r_multiple_count        = 0;
      m_total_r_multiple        = 0.0;
      m_best_r_multiple         = 0.0;
      m_worst_r_multiple        = 0.0;
      m_total_mfe               = 0.0;
      m_total_mae               = 0.0;
      m_largest_mfe             = 0.0;
      m_largest_mae             = 0.0;
      m_open_trade_mfe          = 0.0;
      m_open_trade_mae          = 0.0;
   }

   bool Configure(const string name,
                  const int id,
                  const int magic_number,
                  const ENUM_BOSSR_STRATEGY_EVALUATION_MODE evaluation_mode,
                  const ENUM_BOSSR_STRATEGY_DIRECTION_MODE direction_mode,
                  const bool enabled = true)
   {
      const string clean_name = Trimmed(name);

      if(clean_name == "")
         return(false);

      if(id <= 0)
         return(false);

      if(magic_number <= 0)
         return(false);

      if(!IsValidEvaluationMode(evaluation_mode))
         return(false);

      if(!IsValidDirectionMode(direction_mode))
         return(false);

      m_name            = clean_name;
      m_id              = id;
      m_magic_number    = magic_number;
      m_evaluation_mode = evaluation_mode;
      m_direction_mode  = direction_mode;
      m_enabled         = enabled;
      m_state           = BOSSR_STRATEGY_STATE_READY;

      return(true);
   }

   bool IsConfigured(void) const
   {
      return(m_name != "" &&
             m_id > 0 &&
             m_magic_number > 0 &&
             IsValidEvaluationMode(m_evaluation_mode) &&
             IsValidDirectionMode(m_direction_mode) &&
             m_state != BOSSR_STRATEGY_STATE_RESET);
   }

   bool IsOperational(void) const
   {
      if(!IsConfigured())
         return(false);

      if(!m_enabled)
         return(false);

      if(m_direction_mode == BOSSR_STRATEGY_DIRECTION_NONE)
         return(false);

      return(m_state == BOSSR_STRATEGY_STATE_READY ||
             m_state == BOSSR_STRATEGY_STATE_RUNNING);
   }

   bool SetName(const string name)
   {
      const string clean_name = Trimmed(name);

      if(clean_name == "")
         return(false);

      m_name = clean_name;
      return(true);
   }

   string Name(void) const
   {
      return(m_name);
   }

   bool SetId(const int id)
   {
      if(id <= 0)
         return(false);

      m_id = id;
      return(true);
   }

   int Id(void) const
   {
      return(m_id);
   }

   bool SetMagicNumber(const int magic_number)
   {
      if(magic_number <= 0)
         return(false);

      m_magic_number = magic_number;
      return(true);
   }

   int MagicNumber(void) const
   {
      return(m_magic_number);
   }

   void SetEnabled(const bool enabled)
   {
      m_enabled = enabled;
   }

   bool IsEnabled(void) const
   {
      return(m_enabled);
   }

   bool SetEvaluationMode(
      const ENUM_BOSSR_STRATEGY_EVALUATION_MODE mode)
   {
      if(!IsValidEvaluationMode(mode))
         return(false);

      m_evaluation_mode = mode;
      return(true);
   }

   ENUM_BOSSR_STRATEGY_EVALUATION_MODE EvaluationMode(void) const
   {
      return(m_evaluation_mode);
   }

   bool EvaluateOnNewBarOnly(void) const
   {
      return(m_evaluation_mode == BOSSR_STRATEGY_EVALUATE_NEW_BAR);
   }

   bool SetDirectionMode(
      const ENUM_BOSSR_STRATEGY_DIRECTION_MODE mode)
   {
      if(!IsValidDirectionMode(mode))
         return(false);

      m_direction_mode = mode;
      return(true);
   }

   ENUM_BOSSR_STRATEGY_DIRECTION_MODE DirectionMode(void) const
   {
      return(m_direction_mode);
   }

   bool AllowsLong(void) const
   {
      return(m_direction_mode == BOSSR_STRATEGY_DIRECTION_LONG_ONLY ||
             m_direction_mode == BOSSR_STRATEGY_DIRECTION_BOTH);
   }

   bool AllowsShort(void) const
   {
      return(m_direction_mode == BOSSR_STRATEGY_DIRECTION_SHORT_ONLY ||
             m_direction_mode == BOSSR_STRATEGY_DIRECTION_BOTH);
   }

   bool SetState(const ENUM_BOSSR_STRATEGY_STATE state)
   {
      if(!IsValidState(state))
         return(false);

      m_state = state;
      return(true);
   }

   ENUM_BOSSR_STRATEGY_STATE State(void) const
   {
      return(m_state);
   }

   bool Start(void)
   {
      if(!IsConfigured())
         return(false);

      if(!m_enabled)
         return(false);

      if(m_direction_mode == BOSSR_STRATEGY_DIRECTION_NONE)
         return(false);

      if(m_state != BOSSR_STRATEGY_STATE_READY &&
         m_state != BOSSR_STRATEGY_STATE_PAUSED &&
         m_state != BOSSR_STRATEGY_STATE_STOPPED)
      {
         return(false);
      }

      m_state = BOSSR_STRATEGY_STATE_RUNNING;
      return(true);
   }

   bool Pause(void)
   {
      if(m_state != BOSSR_STRATEGY_STATE_RUNNING)
         return(false);

      m_state = BOSSR_STRATEGY_STATE_PAUSED;
      return(true);
   }

   bool Stop(void)
   {
      if(m_state == BOSSR_STRATEGY_STATE_RESET)
         return(false);

      m_state = BOSSR_STRATEGY_STATE_STOPPED;
      return(true);
   }

   void MarkError(void)
   {
      m_error_count++;
      m_state = BOSSR_STRATEGY_STATE_ERROR;
   }

   void RecordEvaluation(const datetime evaluation_time)
   {
      m_evaluation_count++;

      if(evaluation_time > 0)
         m_last_evaluation_time = evaluation_time;
   }

   void RecordSignal(const datetime signal_time)
   {
      m_signal_count++;

      if(signal_time > 0)
         m_last_signal_time = signal_time;
   }

   datetime LastEvaluationTime(void) const
   {
      return(m_last_evaluation_time);
   }

   datetime LastSignalTime(void) const
   {
      return(m_last_signal_time);
   }

   long EvaluationCount(void) const
   {
      return(m_evaluation_count);
   }

   long SignalCount(void) const
   {
      return(m_signal_count);
   }

   long ErrorCount(void) const
   {
      return(m_error_count);
   }

   void ClearRuntimeStatistics(void)
   {
      m_last_evaluation_time = 0;
      m_last_signal_time     = 0;
      m_evaluation_count     = 0;
      m_signal_count         = 0;
      m_error_count          = 0;
      m_last_gate_tick_time     = 0;
      m_last_gate_bar_time      = 0;
      m_gate_accept_count       = 0;
      m_gate_reject_count       = 0;
      m_last_signal_bar_time     = 0;
      m_last_emitted_signal      = BOSSR_STRATEGY_SIGNAL_NONE;
      m_signal_accept_count      = 0;
      m_signal_reject_count      = 0;
      m_position_state           = BOSSR_STRATEGY_POSITION_FLAT;
      m_position_direction       = BOSSR_STRATEGY_SIGNAL_NONE;
      m_position_ticket          = -1;
      m_position_open_time       = 0;
      m_position_open_bar_time   = 0;
      m_position_entry_price     = 0.0;
      m_position_open_count      = 0;
      m_position_close_count     = 0;
      m_position_reject_count    = 0;
      m_reconcile_count          = 0;
      m_reconcile_change_count   = 0;
      m_reconcile_reject_count   = 0;
      m_last_reconcile_time      = 0;
      m_performance_trade_count = 0;
      m_performance_win_count   = 0;
      m_performance_loss_count  = 0;
      m_performance_breakeven_count = 0;
      m_gross_profit            = 0.0;
      m_gross_loss              = 0.0;
      m_net_profit              = 0.0;
      m_largest_win             = 0.0;
      m_largest_loss            = 0.0;
      m_current_win_streak      = 0;
      m_current_loss_streak     = 0;
      m_max_win_streak          = 0;
      m_max_loss_streak         = 0;
      m_r_multiple_count        = 0;
      m_total_r_multiple        = 0.0;
      m_best_r_multiple         = 0.0;
      m_worst_r_multiple        = 0.0;
      m_total_mfe               = 0.0;
      m_total_mae               = 0.0;
      m_largest_mfe             = 0.0;
      m_largest_mae             = 0.0;
      m_open_trade_mfe          = 0.0;
      m_open_trade_mae          = 0.0;
   }

   string EvaluationModeText(void) const
   {
      if(m_evaluation_mode == BOSSR_STRATEGY_EVALUATE_EVERY_TICK)
         return("EVERY_TICK");

      if(m_evaluation_mode == BOSSR_STRATEGY_EVALUATE_NEW_BAR)
         return("NEW_BAR");

      return("INVALID");
   }

   string DirectionModeText(void) const
   {
      if(m_direction_mode == BOSSR_STRATEGY_DIRECTION_NONE)
         return("NONE");

      if(m_direction_mode == BOSSR_STRATEGY_DIRECTION_LONG_ONLY)
         return("LONG_ONLY");

      if(m_direction_mode == BOSSR_STRATEGY_DIRECTION_SHORT_ONLY)
         return("SHORT_ONLY");

      if(m_direction_mode == BOSSR_STRATEGY_DIRECTION_BOTH)
         return("BOTH");

      return("INVALID");
   }

   string StateText(void) const
   {
      if(m_state == BOSSR_STRATEGY_STATE_RESET)
         return("RESET");

      if(m_state == BOSSR_STRATEGY_STATE_READY)
         return("READY");

      if(m_state == BOSSR_STRATEGY_STATE_RUNNING)
         return("RUNNING");

      if(m_state == BOSSR_STRATEGY_STATE_PAUSED)
         return("PAUSED");

      if(m_state == BOSSR_STRATEGY_STATE_STOPPED)
         return("STOPPED");

      if(m_state == BOSSR_STRATEGY_STATE_ERROR)
         return("ERROR");

      return("INVALID");
   }

   bool IsValidSignal(const ENUM_BOSSR_STRATEGY_SIGNAL signal) const
   {
      return(signal == BOSSR_STRATEGY_SIGNAL_NONE ||
             signal == BOSSR_STRATEGY_SIGNAL_BUY  ||
             signal == BOSSR_STRATEGY_SIGNAL_SELL ||
             signal == BOSSR_STRATEGY_SIGNAL_EXIT);
   }

   bool SignalAllowed(const ENUM_BOSSR_STRATEGY_SIGNAL signal) const
   {
      if(!IsValidSignal(signal))
         return(false);

      if(signal == BOSSR_STRATEGY_SIGNAL_NONE ||
         signal == BOSSR_STRATEGY_SIGNAL_EXIT)
      {
         return(true);
      }

      if(signal == BOSSR_STRATEGY_SIGNAL_BUY)
         return(AllowsLong());

      if(signal == BOSSR_STRATEGY_SIGNAL_SELL)
         return(AllowsShort());

      return(false);
   }

   bool ValidateResult(const SBossRStrategyResult &result) const
   {
      if(!result.valid)
         return(false);

      if(!IsValidSignal(result.signal))
         return(false);

      if(!SignalAllowed(result.signal))
         return(false);

      if(result.evaluated_at <= 0)
         return(false);

      if(result.confidence < 0.0 || result.confidence > 100.0)
         return(false);

      if(result.hold_bars < 0)
         return(false);

      if(result.signal == BOSSR_STRATEGY_SIGNAL_BUY ||
         result.signal == BOSSR_STRATEGY_SIGNAL_SELL)
      {
         if(result.entry_price < 0.0)
            return(false);

         if(result.stop_loss < 0.0)
            return(false);

         if(result.take_profit < 0.0)
            return(false);
      }

      return(true);
   }

   void MakeNoSignalResult(SBossRStrategyResult &result,
                           const datetime evaluated_at,
                           const string reason = "") const
   {
      result.Reset();
      result.signal       = BOSSR_STRATEGY_SIGNAL_NONE;
      result.valid        = (evaluated_at > 0);
      result.evaluated_at = evaluated_at;
      result.reason       = reason;
   }

   bool MakeEntryResult(SBossRStrategyResult &result,
                        const ENUM_BOSSR_STRATEGY_SIGNAL signal,
                        const datetime evaluated_at,
                        const double confidence,
                        const double entry_price,
                        const double stop_loss,
                        const double take_profit,
                        const int hold_bars,
                        const string reason = "") const
   {
      result.Reset();

      if(signal != BOSSR_STRATEGY_SIGNAL_BUY &&
         signal != BOSSR_STRATEGY_SIGNAL_SELL)
      {
         return(false);
      }

      result.signal       = signal;
      result.valid        = true;
      result.evaluated_at = evaluated_at;
      result.confidence   = confidence;
      result.entry_price  = entry_price;
      result.stop_loss    = stop_loss;
      result.take_profit  = take_profit;
      result.hold_bars    = hold_bars;
      result.reason       = reason;

      if(!ValidateResult(result))
      {
         result.Reset();
         return(false);
      }

      return(true);
   }

   bool MakeExitResult(SBossRStrategyResult &result,
                       const datetime evaluated_at,
                       const double confidence,
                       const string reason = "") const
   {
      result.Reset();
      result.signal       = BOSSR_STRATEGY_SIGNAL_EXIT;
      result.valid        = true;
      result.evaluated_at = evaluated_at;
      result.confidence   = confidence;
      result.reason       = reason;

      if(!ValidateResult(result))
      {
         result.Reset();
         return(false);
      }

      return(true);
   }

   string SignalText(const ENUM_BOSSR_STRATEGY_SIGNAL signal) const
   {
      if(signal == BOSSR_STRATEGY_SIGNAL_NONE)
         return("NONE");

      if(signal == BOSSR_STRATEGY_SIGNAL_BUY)
         return("BUY");

      if(signal == BOSSR_STRATEGY_SIGNAL_SELL)
         return("SELL");

      if(signal == BOSSR_STRATEGY_SIGNAL_EXIT)
         return("EXIT");

      return("INVALID");
   }


   bool CanEvaluate(const datetime tick_time,
                    const datetime bar_time) const
   {
      if(!IsOperational())
         return(false);

      if(tick_time <= 0)
         return(false);

      if(m_evaluation_mode == BOSSR_STRATEGY_EVALUATE_EVERY_TICK)
         return(tick_time != m_last_gate_tick_time);

      if(m_evaluation_mode == BOSSR_STRATEGY_EVALUATE_NEW_BAR)
      {
         if(bar_time <= 0)
            return(false);

         return(bar_time != m_last_gate_bar_time);
      }

      return(false);
   }

   bool BeginEvaluation(const datetime tick_time,
                        const datetime bar_time)
   {
      if(!CanEvaluate(tick_time, bar_time))
      {
         m_gate_reject_count++;
         return(false);
      }

      m_last_gate_tick_time = tick_time;

      if(m_evaluation_mode == BOSSR_STRATEGY_EVALUATE_NEW_BAR)
         m_last_gate_bar_time = bar_time;

      m_gate_accept_count++;
      RecordEvaluation(tick_time);
      return(true);
   }

   void ResetEvaluationGate(void)
   {
      m_last_gate_tick_time = 0;
      m_last_gate_bar_time  = 0;
      m_gate_accept_count   = 0;
      m_gate_reject_count   = 0;
   }

   datetime LastGateTickTime(void) const
   {
      return(m_last_gate_tick_time);
   }

   datetime LastGateBarTime(void) const
   {
      return(m_last_gate_bar_time);
   }

   long GateAcceptCount(void) const
   {
      return(m_gate_accept_count);
   }

   long GateRejectCount(void) const
   {
      return(m_gate_reject_count);
   }


   bool SetSignalCooldownBars(const int bars)
   {
      if(bars < 0)
         return(false);

      m_signal_cooldown_bars = bars;
      return(true);
   }

   int SignalCooldownBars(void) const
   {
      return(m_signal_cooldown_bars);
   }

   bool CanEmitSignal(const ENUM_BOSSR_STRATEGY_SIGNAL signal,
                      const datetime signal_time,
                      const datetime signal_bar_time,
                      const int bars_since_last_signal) const
   {
      if(!IsOperational())
         return(false);

      if(!IsValidSignal(signal))
         return(false);

      if(signal == BOSSR_STRATEGY_SIGNAL_NONE)
         return(false);

      if(!SignalAllowed(signal))
         return(false);

      if(signal_time <= 0 || signal_bar_time <= 0)
         return(false);

      if(signal_bar_time == m_last_signal_bar_time)
         return(false);

      if(m_signal_cooldown_bars > 0 &&
         m_last_signal_bar_time > 0 &&
         bars_since_last_signal < m_signal_cooldown_bars)
      {
         return(false);
      }

      return(true);
   }

   bool EmitSignal(const ENUM_BOSSR_STRATEGY_SIGNAL signal,
                   const datetime signal_time,
                   const datetime signal_bar_time,
                   const int bars_since_last_signal)
   {
      if(!CanEmitSignal(signal,
                        signal_time,
                        signal_bar_time,
                        bars_since_last_signal))
      {
         m_signal_reject_count++;
         return(false);
      }

      m_last_signal_bar_time = signal_bar_time;
      m_last_emitted_signal  = signal;
      m_signal_accept_count++;
      RecordSignal(signal_time);
      return(true);
   }

   void ResetSignalThrottle(void)
   {
      m_last_signal_bar_time = 0;
      m_last_emitted_signal  = BOSSR_STRATEGY_SIGNAL_NONE;
      m_signal_accept_count  = 0;
      m_signal_reject_count  = 0;
   }

   datetime LastSignalBarTime(void) const
   {
      return(m_last_signal_bar_time);
   }

   ENUM_BOSSR_STRATEGY_SIGNAL LastEmittedSignal(void) const
   {
      return(m_last_emitted_signal);
   }

   long SignalAcceptCount(void) const
   {
      return(m_signal_accept_count);
   }

   long SignalRejectCount(void) const
   {
      return(m_signal_reject_count);
   }


   bool IsValidPositionState(
      const ENUM_BOSSR_STRATEGY_POSITION_STATE state) const
   {
      return(state == BOSSR_STRATEGY_POSITION_FLAT ||
             state == BOSSR_STRATEGY_POSITION_PENDING ||
             state == BOSSR_STRATEGY_POSITION_OPEN);
   }

   bool IsFlat(void) const
   {
      return(m_position_state == BOSSR_STRATEGY_POSITION_FLAT);
   }

   bool HasPendingPosition(void) const
   {
      return(m_position_state == BOSSR_STRATEGY_POSITION_PENDING);
   }

   bool HasOpenPosition(void) const
   {
      return(m_position_state == BOSSR_STRATEGY_POSITION_OPEN);
   }

   bool HasActivePosition(void) const
   {
      return(m_position_state == BOSSR_STRATEGY_POSITION_PENDING ||
             m_position_state == BOSSR_STRATEGY_POSITION_OPEN);
   }

   bool CanRequestEntry(const ENUM_BOSSR_STRATEGY_SIGNAL signal) const
   {
      if(!IsOperational())
         return(false);

      if(signal != BOSSR_STRATEGY_SIGNAL_BUY &&
         signal != BOSSR_STRATEGY_SIGNAL_SELL)
      {
         return(false);
      }

      if(!SignalAllowed(signal))
         return(false);

      return(IsFlat());
   }

   bool MarkEntryPending(const ENUM_BOSSR_STRATEGY_SIGNAL signal)
   {
      if(!CanRequestEntry(signal))
      {
         m_position_reject_count++;
         return(false);
      }

      m_position_state         = BOSSR_STRATEGY_POSITION_PENDING;
      m_position_direction     = signal;
      m_position_ticket        = -1;
      m_position_open_time     = 0;
      m_position_open_bar_time = 0;
      m_position_entry_price   = 0.0;
      return(true);
   }

   bool ConfirmPositionOpen(const int ticket,
                            const datetime open_time,
                            const datetime open_bar_time,
                            const double entry_price)
   {
      if(m_position_state != BOSSR_STRATEGY_POSITION_PENDING)
      {
         m_position_reject_count++;
         return(false);
      }

      if(ticket <= 0 ||
         open_time <= 0 ||
         open_bar_time <= 0 ||
         entry_price <= 0.0)
      {
         m_position_reject_count++;
         return(false);
      }

      if(m_position_direction != BOSSR_STRATEGY_SIGNAL_BUY &&
         m_position_direction != BOSSR_STRATEGY_SIGNAL_SELL)
      {
         m_position_reject_count++;
         return(false);
      }

      m_position_state         = BOSSR_STRATEGY_POSITION_OPEN;
      m_position_ticket        = ticket;
      m_position_open_time     = open_time;
      m_position_open_bar_time = open_bar_time;
      m_position_entry_price   = entry_price;
      m_position_open_count++;
      return(true);
   }

   bool CancelPendingEntry(void)
   {
      if(m_position_state != BOSSR_STRATEGY_POSITION_PENDING)
      {
         m_position_reject_count++;
         return(false);
      }

      ClearCurrentPositionState();
      return(true);
   }

   bool CanRequestExit(void) const
   {
      if(!IsOperational())
         return(false);

      return(HasOpenPosition());
   }

   bool ConfirmPositionClosed(const int ticket)
   {
      if(m_position_state != BOSSR_STRATEGY_POSITION_OPEN)
      {
         m_position_reject_count++;
         return(false);
      }

      if(ticket <= 0 || ticket != m_position_ticket)
      {
         m_position_reject_count++;
         return(false);
      }

      m_position_close_count++;
      ClearCurrentPositionState();
      return(true);
   }

   void ClearCurrentPositionState(void)
   {
      m_position_state         = BOSSR_STRATEGY_POSITION_FLAT;
      m_position_direction     = BOSSR_STRATEGY_SIGNAL_NONE;
      m_position_ticket        = -1;
      m_position_open_time     = 0;
      m_position_open_bar_time = 0;
      m_position_entry_price   = 0.0;
   }

   void ResetPositionTracking(void)
   {
      ClearCurrentPositionState();
      m_position_open_count   = 0;
      m_position_close_count  = 0;
      m_position_reject_count = 0;
   }

   ENUM_BOSSR_STRATEGY_POSITION_STATE PositionState(void) const
   {
      return(m_position_state);
   }

   ENUM_BOSSR_STRATEGY_SIGNAL PositionDirection(void) const
   {
      return(m_position_direction);
   }

   int PositionTicket(void) const
   {
      return(m_position_ticket);
   }

   datetime PositionOpenTime(void) const
   {
      return(m_position_open_time);
   }

   datetime PositionOpenBarTime(void) const
   {
      return(m_position_open_bar_time);
   }

   double PositionEntryPrice(void) const
   {
      return(m_position_entry_price);
   }

   long PositionOpenCount(void) const
   {
      return(m_position_open_count);
   }

   long PositionCloseCount(void) const
   {
      return(m_position_close_count);
   }

   long PositionRejectCount(void) const
   {
      return(m_position_reject_count);
   }

   string PositionStateText(void) const
   {
      if(m_position_state == BOSSR_STRATEGY_POSITION_FLAT)
         return("FLAT");

      if(m_position_state == BOSSR_STRATEGY_POSITION_PENDING)
         return("PENDING");

      if(m_position_state == BOSSR_STRATEGY_POSITION_OPEN)
         return("OPEN");

      return("INVALID");
   }


   bool RejectPendingEntry(void)
   {
      if(m_position_state != BOSSR_STRATEGY_POSITION_PENDING)
      {
         m_position_reject_count++;
         return(false);
      }

      ClearCurrentPositionState();
      return(true);
   }

   bool ReplacePositionTicket(const int old_ticket,
                              const int new_ticket)
   {
      if(m_position_state != BOSSR_STRATEGY_POSITION_OPEN)
      {
         m_position_reject_count++;
         return(false);
      }

      if(old_ticket <= 0 ||
         new_ticket <= 0 ||
         old_ticket != m_position_ticket)
      {
         m_position_reject_count++;
         return(false);
      }

      m_position_ticket = new_ticket;
      return(true);
   }

   ENUM_BOSSR_STRATEGY_RECONCILE_RESULT ReconcileBrokerPosition(
      const bool broker_has_position,
      const int broker_ticket,
      const ENUM_BOSSR_STRATEGY_SIGNAL broker_direction,
      const datetime broker_open_time,
      const datetime broker_open_bar_time,
      const double broker_entry_price,
      const datetime reconcile_time)
   {
      m_reconcile_count++;

      if(reconcile_time <= 0)
      {
         m_reconcile_reject_count++;
         return(BOSSR_STRATEGY_RECONCILE_REJECTED);
      }

      m_last_reconcile_time = reconcile_time;

      if(!broker_has_position)
      {
         if(m_position_state == BOSSR_STRATEGY_POSITION_FLAT)
            return(BOSSR_STRATEGY_RECONCILE_NO_CHANGE);

         ClearCurrentPositionState();
         m_reconcile_change_count++;
         return(BOSSR_STRATEGY_RECONCILE_CLEARED_STALE);
      }

      if(broker_ticket <= 0 ||
         (broker_direction != BOSSR_STRATEGY_SIGNAL_BUY &&
          broker_direction != BOSSR_STRATEGY_SIGNAL_SELL) ||
         broker_open_time <= 0 ||
         broker_open_bar_time <= 0 ||
         broker_entry_price <= 0.0)
      {
         m_reconcile_reject_count++;
         return(BOSSR_STRATEGY_RECONCILE_REJECTED);
      }

      if(m_position_state == BOSSR_STRATEGY_POSITION_FLAT ||
         m_position_state == BOSSR_STRATEGY_POSITION_PENDING)
      {
         m_position_state         = BOSSR_STRATEGY_POSITION_OPEN;
         m_position_direction     = broker_direction;
         m_position_ticket        = broker_ticket;
         m_position_open_time     = broker_open_time;
         m_position_open_bar_time = broker_open_bar_time;
         m_position_entry_price   = broker_entry_price;
         m_position_open_count++;
         m_reconcile_change_count++;
         return(BOSSR_STRATEGY_RECONCILE_ADOPTED_OPEN);
      }

      bool changed = false;

      if(m_position_ticket != broker_ticket)
      {
         m_position_ticket = broker_ticket;
         changed = true;
      }

      if(m_position_direction != broker_direction)
      {
         m_position_direction = broker_direction;
         changed = true;
      }

      if(m_position_open_time != broker_open_time)
      {
         m_position_open_time = broker_open_time;
         changed = true;
      }

      if(m_position_open_bar_time != broker_open_bar_time)
      {
         m_position_open_bar_time = broker_open_bar_time;
         changed = true;
      }

      if(m_position_entry_price != broker_entry_price)
      {
         m_position_entry_price = broker_entry_price;
         changed = true;
      }

      if(changed)
      {
         m_reconcile_change_count++;
         return(BOSSR_STRATEGY_RECONCILE_UPDATED_OPEN);
      }

      return(BOSSR_STRATEGY_RECONCILE_NO_CHANGE);
   }

   long ReconcileCount(void) const
   {
      return(m_reconcile_count);
   }

   long ReconcileChangeCount(void) const
   {
      return(m_reconcile_change_count);
   }

   long ReconcileRejectCount(void) const
   {
      return(m_reconcile_reject_count);
   }

   datetime LastReconcileTime(void) const
   {
      return(m_last_reconcile_time);
   }

   string ReconcileResultText(
      const ENUM_BOSSR_STRATEGY_RECONCILE_RESULT result) const
   {
      if(result == BOSSR_STRATEGY_RECONCILE_NO_CHANGE)
         return("NO_CHANGE");

      if(result == BOSSR_STRATEGY_RECONCILE_ADOPTED_OPEN)
         return("ADOPTED_OPEN");

      if(result == BOSSR_STRATEGY_RECONCILE_UPDATED_OPEN)
         return("UPDATED_OPEN");

      if(result == BOSSR_STRATEGY_RECONCILE_CLEARED_STALE)
         return("CLEARED_STALE");

      if(result == BOSSR_STRATEGY_RECONCILE_REJECTED)
         return("REJECTED");

      return("INVALID");
   }


   void ResetPerformanceStatistics(void)
   {
      m_performance_trade_count = 0;
      m_performance_win_count = 0;
      m_performance_loss_count = 0;
      m_performance_breakeven_count = 0;
      m_gross_profit = 0.0;
      m_gross_loss = 0.0;
      m_net_profit = 0.0;
      m_largest_win = 0.0;
      m_largest_loss = 0.0;
      m_current_win_streak = 0;
      m_current_loss_streak = 0;
      m_max_win_streak = 0;
      m_max_loss_streak = 0;
      m_r_multiple_count = 0;
      m_total_r_multiple = 0.0;
      m_best_r_multiple = 0.0;
      m_worst_r_multiple = 0.0;
      m_total_mfe = 0.0;
      m_total_mae = 0.0;
      m_largest_mfe = 0.0;
      m_largest_mae = 0.0;
      m_open_trade_mfe = 0.0;
      m_open_trade_mae = 0.0;
   }

   bool RecordOpenTradeExcursion(const double mfe,
                                 const double mae)
   {
      if(!MathIsValidNumber(mfe) || !MathIsValidNumber(mae) ||
         mfe < 0.0 || mae < 0.0)
         return(false);

      if(mfe > m_open_trade_mfe)
         m_open_trade_mfe = mfe;
      if(mae > m_open_trade_mae)
         m_open_trade_mae = mae;
      return(true);
   }

   void ResetOpenTradeExcursion(void)
   {
      m_open_trade_mfe = 0.0;
      m_open_trade_mae = 0.0;
   }

   bool RecordClosedTrade(const double net_profit,
                          const double initial_risk,
                          const double mfe,
                          const double mae)
   {
      if(!MathIsValidNumber(net_profit) ||
         !MathIsValidNumber(initial_risk) ||
         !MathIsValidNumber(mfe) ||
         !MathIsValidNumber(mae) ||
         initial_risk < 0.0 || mfe < 0.0 || mae < 0.0)
         return(false);

      m_performance_trade_count++;
      m_net_profit += net_profit;

      if(net_profit > 0.0)
      {
         m_performance_win_count++;
         m_gross_profit += net_profit;
         if(m_performance_win_count == 1 || net_profit > m_largest_win)
            m_largest_win = net_profit;
         m_current_win_streak++;
         m_current_loss_streak = 0;
         if(m_current_win_streak > m_max_win_streak)
            m_max_win_streak = m_current_win_streak;
      }
      else if(net_profit < 0.0)
      {
         m_performance_loss_count++;
         m_gross_loss += net_profit;
         if(m_performance_loss_count == 1 || net_profit < m_largest_loss)
            m_largest_loss = net_profit;
         m_current_loss_streak++;
         m_current_win_streak = 0;
         if(m_current_loss_streak > m_max_loss_streak)
            m_max_loss_streak = m_current_loss_streak;
      }
      else
      {
         m_performance_breakeven_count++;
         m_current_win_streak = 0;
         m_current_loss_streak = 0;
      }

      if(initial_risk > 0.0)
      {
         const double r_multiple = net_profit / initial_risk;
         m_r_multiple_count++;
         m_total_r_multiple += r_multiple;
         if(m_r_multiple_count == 1 || r_multiple > m_best_r_multiple)
            m_best_r_multiple = r_multiple;
         if(m_r_multiple_count == 1 || r_multiple < m_worst_r_multiple)
            m_worst_r_multiple = r_multiple;
      }

      m_total_mfe += mfe;
      m_total_mae += mae;
      if(mfe > m_largest_mfe)
         m_largest_mfe = mfe;
      if(mae > m_largest_mae)
         m_largest_mae = mae;
      return(true);
   }

   bool RecordClosedTrade(const double net_profit,
                          const double initial_risk)
   {
      const bool recorded = RecordClosedTrade(net_profit,
                                               initial_risk,
                                               m_open_trade_mfe,
                                               m_open_trade_mae);
      if(recorded)
         ResetOpenTradeExcursion();
      return(recorded);
   }

   long PerformanceTradeCount(void) const { return(m_performance_trade_count); }
   long WinCount(void) const { return(m_performance_win_count); }
   long LossCount(void) const { return(m_performance_loss_count); }
   long BreakevenCount(void) const { return(m_performance_breakeven_count); }
   double GrossProfit(void) const { return(m_gross_profit); }
   double GrossLoss(void) const { return(m_gross_loss); }
   double NetProfit(void) const { return(m_net_profit); }
   double ProfitFactor(void) const
   {
      if(m_gross_loss >= 0.0)
         return(0.0);
      return(m_gross_profit / MathAbs(m_gross_loss));
   }
   double AverageWin(void) const
   {
      if(m_performance_win_count <= 0) return(0.0);
      return(m_gross_profit / (double)m_performance_win_count);
   }
   double AverageLoss(void) const
   {
      if(m_performance_loss_count <= 0) return(0.0);
      return(m_gross_loss / (double)m_performance_loss_count);
   }
   double LargestWin(void) const { return(m_largest_win); }
   double LargestLoss(void) const { return(m_largest_loss); }
   int CurrentWinStreak(void) const { return(m_current_win_streak); }
   int CurrentLossStreak(void) const { return(m_current_loss_streak); }
   int MaxWinStreak(void) const { return(m_max_win_streak); }
   int MaxLossStreak(void) const { return(m_max_loss_streak); }
   double Expectancy(void) const
   {
      if(m_performance_trade_count <= 0) return(0.0);
      return(m_net_profit / (double)m_performance_trade_count);
   }
   long RMultipleCount(void) const { return(m_r_multiple_count); }
   double TotalRMultiple(void) const { return(m_total_r_multiple); }
   double AverageRMultiple(void) const
   {
      if(m_r_multiple_count <= 0) return(0.0);
      return(m_total_r_multiple / (double)m_r_multiple_count);
   }
   double BestRMultiple(void) const { return(m_best_r_multiple); }
   double WorstRMultiple(void) const { return(m_worst_r_multiple); }
   double TotalMFE(void) const { return(m_total_mfe); }
   double TotalMAE(void) const { return(m_total_mae); }
   double AverageMFE(void) const
   {
      if(m_performance_trade_count <= 0) return(0.0);
      return(m_total_mfe / (double)m_performance_trade_count);
   }
   double AverageMAE(void) const
   {
      if(m_performance_trade_count <= 0) return(0.0);
      return(m_total_mae / (double)m_performance_trade_count);
   }
   double LargestMFE(void) const { return(m_largest_mfe); }
   double LargestMAE(void) const { return(m_largest_mae); }
   double OpenTradeMFE(void) const { return(m_open_trade_mfe); }
   double OpenTradeMAE(void) const { return(m_open_trade_mae); }

};

#endif // __BOSSR_STRATEGY_BLOCK7_PERFORMANCE_FULL_MQH__
//+------------------------------------------------------------------+
