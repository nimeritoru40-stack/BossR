//+------------------------------------------------------------------+
//| BossR_Filter_Block6_VOLUME_FULL.mqh                              |
//| BossR Framework - Filter Module                                  |
//| Block 6: core lifecycle, spread, session, volatility, trend and volume filters                        |
//| MT4 only                                                         |
//+------------------------------------------------------------------+
#ifndef __BOSSR_FILTER_BLOCK6_VOLUME_FULL_MQH__
#define __BOSSR_FILTER_BLOCK6_VOLUME_FULL_MQH__

enum ENUM_BOSSR_FILTER_DECISION
{
   BOSSR_FILTER_DECISION_UNAVAILABLE = 0,
   BOSSR_FILTER_DECISION_PASS        = 1,
   BOSSR_FILTER_DECISION_FAIL        = 2
};

enum ENUM_BOSSR_FILTER_STATE
{
   BOSSR_FILTER_STATE_RESET    = 0,
   BOSSR_FILTER_STATE_READY    = 1,
   BOSSR_FILTER_STATE_RUNNING  = 2,
   BOSSR_FILTER_STATE_PAUSED   = 3,
   BOSSR_FILTER_STATE_STOPPED  = 4,
   BOSSR_FILTER_STATE_ERROR    = 5
};

struct SBossRFilterResult
{
   ENUM_BOSSR_FILTER_DECISION decision;
   bool                       valid;
   datetime                   evaluated_at;
   double                     value;
   double                     threshold;
   string                     reason;

   void Reset(void)
   {
      decision     = BOSSR_FILTER_DECISION_UNAVAILABLE;
      valid        = false;
      evaluated_at = 0;
      value        = 0.0;
      threshold    = 0.0;
      reason       = "";
   }
};

class CBossRFilter
{
private:
   string                     m_name;
   int                        m_id;
   bool                       m_enabled;
   ENUM_BOSSR_FILTER_STATE    m_state;
   datetime                   m_last_evaluation_time;
   ENUM_BOSSR_FILTER_DECISION m_last_decision;
   string                     m_last_reason;
   double                     m_last_value;
   double                     m_last_threshold;
   long                       m_evaluation_count;
   long                       m_pass_count;
   long                       m_fail_count;
   long                       m_unavailable_count;
   long                       m_error_count;

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

   bool IsValidState(const ENUM_BOSSR_FILTER_STATE state) const
   {
      return(state == BOSSR_FILTER_STATE_RESET ||
             state == BOSSR_FILTER_STATE_READY ||
             state == BOSSR_FILTER_STATE_RUNNING ||
             state == BOSSR_FILTER_STATE_PAUSED ||
             state == BOSSR_FILTER_STATE_STOPPED ||
             state == BOSSR_FILTER_STATE_ERROR);
   }

   bool IsFiniteNumber(const double value) const
   {
      return(MathIsValidNumber(value));
   }

   bool RecordUnavailable(const datetime evaluated_at,
                          const double threshold,
                          const string reason)
   {
      SBossRFilterResult result;

      if(!BuildResult(result,
                      BOSSR_FILTER_DECISION_UNAVAILABLE,
                      evaluated_at,
                      0.0,
                      threshold,
                      reason))
      {
         return(false);
      }

      return(RecordResult(result));
   }

public:
   CBossRFilter(void)
   {
      Reset();
   }

   void Reset(void)
   {
      m_name                 = "";
      m_id                   = 0;
      m_enabled              = false;
      m_state                = BOSSR_FILTER_STATE_RESET;
      m_last_evaluation_time = 0;
      m_last_decision        = BOSSR_FILTER_DECISION_UNAVAILABLE;
      m_last_reason          = "";
      m_last_value           = 0.0;
      m_last_threshold       = 0.0;
      m_evaluation_count     = 0;
      m_pass_count           = 0;
      m_fail_count           = 0;
      m_unavailable_count    = 0;
      m_error_count          = 0;
   }

   bool Configure(const string name,
                  const int id,
                  const bool enabled = true)
   {
      const string clean_name = Trimmed(name);

      if(clean_name == "")
         return(false);

      if(id <= 0)
         return(false);

      m_name    = clean_name;
      m_id      = id;
      m_enabled = enabled;
      m_state   = BOSSR_FILTER_STATE_READY;

      return(true);
   }

   bool IsConfigured(void) const
   {
      return(m_name != "" &&
             m_id > 0 &&
             m_state != BOSSR_FILTER_STATE_RESET);
   }

   bool IsOperational(void) const
   {
      if(!IsConfigured())
         return(false);

      if(!m_enabled)
         return(false);

      return(m_state == BOSSR_FILTER_STATE_READY ||
             m_state == BOSSR_FILTER_STATE_RUNNING);
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

   void SetEnabled(const bool enabled)
   {
      m_enabled = enabled;
   }

   bool IsEnabled(void) const
   {
      return(m_enabled);
   }

   bool SetState(const ENUM_BOSSR_FILTER_STATE state)
   {
      if(!IsValidState(state))
         return(false);

      m_state = state;
      return(true);
   }

   ENUM_BOSSR_FILTER_STATE State(void) const
   {
      return(m_state);
   }

   bool Start(void)
   {
      if(!IsConfigured())
         return(false);

      if(!m_enabled)
         return(false);

      if(m_state != BOSSR_FILTER_STATE_READY &&
         m_state != BOSSR_FILTER_STATE_PAUSED &&
         m_state != BOSSR_FILTER_STATE_STOPPED)
      {
         return(false);
      }

      m_state = BOSSR_FILTER_STATE_RUNNING;
      return(true);
   }

   bool Pause(void)
   {
      if(m_state != BOSSR_FILTER_STATE_RUNNING)
         return(false);

      m_state = BOSSR_FILTER_STATE_PAUSED;
      return(true);
   }

   bool Stop(void)
   {
      if(m_state == BOSSR_FILTER_STATE_RESET)
         return(false);

      m_state = BOSSR_FILTER_STATE_STOPPED;
      return(true);
   }

   void MarkError(void)
   {
      m_error_count++;
      m_state = BOSSR_FILTER_STATE_ERROR;
   }

   bool ValidateResult(const SBossRFilterResult &result) const
   {
      if(!result.valid)
         return(false);

      if(!IsValidDecision(result.decision))
         return(false);

      if(result.evaluated_at <= 0)
         return(false);

      if(!IsFiniteNumber(result.value) ||
         !IsFiniteNumber(result.threshold))
      {
         return(false);
      }

      return(true);
   }

   bool BuildResult(SBossRFilterResult &result,
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

      if(!IsFiniteNumber(value) ||
         !IsFiniteNumber(threshold))
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

   bool RecordResult(const SBossRFilterResult &result)
   {
      if(!IsOperational())
         return(false);

      if(!ValidateResult(result))
         return(false);

      m_last_evaluation_time = result.evaluated_at;
      m_last_decision        = result.decision;
      m_last_reason          = result.reason;
      m_last_value           = result.value;
      m_last_threshold       = result.threshold;
      m_evaluation_count++;

      if(result.decision == BOSSR_FILTER_DECISION_PASS)
         m_pass_count++;
      else if(result.decision == BOSSR_FILTER_DECISION_FAIL)
         m_fail_count++;
      else
         m_unavailable_count++;

      return(true);
   }

   bool Passed(void) const
   {
      return(m_last_decision == BOSSR_FILTER_DECISION_PASS);
   }

   bool Failed(void) const
   {
      return(m_last_decision == BOSSR_FILTER_DECISION_FAIL);
   }

   bool Unavailable(void) const
   {
      return(m_last_decision == BOSSR_FILTER_DECISION_UNAVAILABLE);
   }

   datetime LastEvaluationTime(void) const
   {
      return(m_last_evaluation_time);
   }

   ENUM_BOSSR_FILTER_DECISION LastDecision(void) const
   {
      return(m_last_decision);
   }

   string LastReason(void) const
   {
      return(m_last_reason);
   }

   double LastValue(void) const
   {
      return(m_last_value);
   }

   double LastThreshold(void) const
   {
      return(m_last_threshold);
   }

   long EvaluationCount(void) const
   {
      return(m_evaluation_count);
   }

   long PassCount(void) const
   {
      return(m_pass_count);
   }

   long FailCount(void) const
   {
      return(m_fail_count);
   }

   long UnavailableCount(void) const
   {
      return(m_unavailable_count);
   }

   long ErrorCount(void) const
   {
      return(m_error_count);
   }

   double PassRate(void) const
   {
      if(m_evaluation_count <= 0)
         return(0.0);

      return((double)m_pass_count * 100.0 /
             (double)m_evaluation_count);
   }

   void ClearRuntimeStatistics(void)
   {
      m_last_evaluation_time = 0;
      m_last_decision        = BOSSR_FILTER_DECISION_UNAVAILABLE;
      m_last_reason          = "";
      m_last_value           = 0.0;
      m_last_threshold       = 0.0;
      m_evaluation_count     = 0;
      m_pass_count           = 0;
      m_fail_count           = 0;
      m_unavailable_count    = 0;
      m_error_count          = 0;
   }

   string DecisionText(const ENUM_BOSSR_FILTER_DECISION decision) const
   {
      if(decision == BOSSR_FILTER_DECISION_UNAVAILABLE)
         return("UNAVAILABLE");

      if(decision == BOSSR_FILTER_DECISION_PASS)
         return("PASS");

      if(decision == BOSSR_FILTER_DECISION_FAIL)
         return("FAIL");

      return("INVALID");
   }

   string StateText(void) const
   {
      if(m_state == BOSSR_FILTER_STATE_RESET)
         return("RESET");

      if(m_state == BOSSR_FILTER_STATE_READY)
         return("READY");

      if(m_state == BOSSR_FILTER_STATE_RUNNING)
         return("RUNNING");

      if(m_state == BOSSR_FILTER_STATE_PAUSED)
         return("PAUSED");

      if(m_state == BOSSR_FILTER_STATE_STOPPED)
         return("STOPPED");

      if(m_state == BOSSR_FILTER_STATE_ERROR)
         return("ERROR");

      return("INVALID");
   }

   // ---------------------------------------------------------------
   // Block 2: spread normalization
   // ---------------------------------------------------------------
   bool IsSupportedDigits(const int digits) const
   {
      return(digits >= 2 && digits <= 5);
   }

   double PointsPerPip(const int digits) const
   {
      if(!IsSupportedDigits(digits))
         return(0.0);

      if(digits == 3 || digits == 5)
         return(10.0);

      return(1.0);
   }

   double PipSize(const double point,
                  const int digits) const
   {
      if(!IsFiniteNumber(point) || point <= 0.0)
         return(0.0);

      const double points_per_pip = PointsPerPip(digits);

      if(points_per_pip <= 0.0)
         return(0.0);

      return(point * points_per_pip);
   }

   bool CalculateSpreadPoints(const double bid,
                              const double ask,
                              const double point,
                              double &spread_points) const
   {
      spread_points = 0.0;

      if(!IsFiniteNumber(bid) ||
         !IsFiniteNumber(ask) ||
         !IsFiniteNumber(point))
      {
         return(false);
      }

      if(bid <= 0.0 || ask <= 0.0 || point <= 0.0)
         return(false);

      if(ask < bid)
         return(false);

      spread_points = (ask - bid) / point;

      if(!IsFiniteNumber(spread_points) || spread_points < 0.0)
      {
         spread_points = 0.0;
         return(false);
      }

      return(true);
   }

   bool CalculateSpreadPips(const double bid,
                            const double ask,
                            const double point,
                            const int digits,
                            double &spread_pips) const
   {
      spread_pips = 0.0;

      const double pip_size = PipSize(point, digits);

      if(pip_size <= 0.0)
         return(false);

      if(!IsFiniteNumber(bid) || !IsFiniteNumber(ask))
         return(false);

      if(bid <= 0.0 || ask <= 0.0 || ask < bid)
         return(false);

      spread_pips = (ask - bid) / pip_size;

      if(!IsFiniteNumber(spread_pips) || spread_pips < 0.0)
      {
         spread_pips = 0.0;
         return(false);
      }

      return(true);
   }

   ENUM_BOSSR_FILTER_DECISION SpreadDecision(
      const double spread_pips,
      const double maximum_spread_pips) const
   {
      if(!IsFiniteNumber(spread_pips) ||
         !IsFiniteNumber(maximum_spread_pips))
      {
         return(BOSSR_FILTER_DECISION_UNAVAILABLE);
      }

      if(spread_pips < 0.0 || maximum_spread_pips < 0.0)
         return(BOSSR_FILTER_DECISION_UNAVAILABLE);

      if(spread_pips <= maximum_spread_pips)
         return(BOSSR_FILTER_DECISION_PASS);

      return(BOSSR_FILTER_DECISION_FAIL);
   }

   bool EvaluateSpread(const double bid,
                       const double ask,
                       const double point,
                       const int digits,
                       const double maximum_spread_pips,
                       const datetime evaluated_at)
   {
      if(!IsOperational())
         return(false);

      const datetime event_time =
         (evaluated_at > 0 ? evaluated_at : TimeCurrent());

      if(event_time <= 0)
         return(false);

      if(!IsFiniteNumber(maximum_spread_pips) ||
         maximum_spread_pips < 0.0)
      {
         return(RecordUnavailable(event_time,
                                  0.0,
                                  "Invalid maximum spread"));
      }

      double spread_pips = 0.0;

      if(!CalculateSpreadPips(bid,
                              ask,
                              point,
                              digits,
                              spread_pips))
      {
         return(RecordUnavailable(event_time,
                                  maximum_spread_pips,
                                  "Invalid market data"));
      }

      const ENUM_BOSSR_FILTER_DECISION decision =
         SpreadDecision(spread_pips, maximum_spread_pips);

      if(decision == BOSSR_FILTER_DECISION_UNAVAILABLE)
      {
         return(RecordUnavailable(event_time,
                                  maximum_spread_pips,
                                  "Spread unavailable"));
      }

      SBossRFilterResult result;
      const string reason =
         (decision == BOSSR_FILTER_DECISION_PASS)
         ? "Spread within limit"
         : "Spread exceeds limit";

      if(!BuildResult(result,
                      decision,
                      event_time,
                      spread_pips,
                      maximum_spread_pips,
                      reason))
      {
         return(false);
      }

      return(RecordResult(result));
   }

   bool EvaluateCurrentSpread(const string symbol,
                              const double maximum_spread_pips,
                              const datetime evaluated_at = 0)
   {
      if(!IsOperational())
         return(false);

      const string clean_symbol = Trimmed(symbol);
      const datetime event_time =
         (evaluated_at > 0 ? evaluated_at : TimeCurrent());

      if(event_time <= 0)
         return(false);

      if(clean_symbol == "")
      {
         return(RecordUnavailable(event_time,
                                  maximum_spread_pips,
                                  "Invalid symbol"));
      }

      ResetLastError();
      const double bid    = MarketInfo(clean_symbol, MODE_BID);
      const double ask    = MarketInfo(clean_symbol, MODE_ASK);
      const double point  = MarketInfo(clean_symbol, MODE_POINT);
      const int digits    = (int)MarketInfo(clean_symbol, MODE_DIGITS);
      const int last_error = GetLastError();

      if(last_error != 0 ||
         bid <= 0.0 ||
         ask <= 0.0 ||
         point <= 0.0 ||
         !IsSupportedDigits(digits))
      {
         return(RecordUnavailable(event_time,
                                  maximum_spread_pips,
                                  "Market data unavailable"));
      }

      return(EvaluateSpread(bid,
                            ask,
                            point,
                            digits,
                            maximum_spread_pips,
                            event_time));
   }

   // ---------------------------------------------------------------
   // Block 3: session and weekday filter
   // Session boundaries are inclusive.
   // start == end represents a full 24-hour session.
   // ---------------------------------------------------------------
   bool IsValidHour(const int hour) const
   {
      return(hour >= 0 && hour <= 23);
   }

   bool IsValidMinute(const int minute) const
   {
      return(minute >= 0 && minute <= 59);
   }

   bool IsValidDayOfWeek(const int day_of_week) const
   {
      return(day_of_week >= 0 && day_of_week <= 6);
   }

   bool IsValidSessionTime(const int hour,
                           const int minute) const
   {
      return(IsValidHour(hour) && IsValidMinute(minute));
   }

   int MinuteOfDay(const int hour,
                   const int minute) const
   {
      if(!IsValidSessionTime(hour, minute))
         return(-1);

      return(hour * 60 + minute);
   }

   int DateTimeMinuteOfDay(const datetime value) const
   {
      if(value <= 0)
         return(-1);

      return(TimeHour(value) * 60 + TimeMinute(value));
   }

   bool IsOvernightSession(const int start_hour,
                           const int start_minute,
                           const int end_hour,
                           const int end_minute) const
   {
      const int start_total = MinuteOfDay(start_hour, start_minute);
      const int end_total   = MinuteOfDay(end_hour, end_minute);

      if(start_total < 0 || end_total < 0)
         return(false);

      return(start_total > end_total);
   }

   bool IsFullDaySession(const int start_hour,
                         const int start_minute,
                         const int end_hour,
                         const int end_minute) const
   {
      const int start_total = MinuteOfDay(start_hour, start_minute);
      const int end_total   = MinuteOfDay(end_hour, end_minute);

      if(start_total < 0 || end_total < 0)
         return(false);

      return(start_total == end_total);
   }

   bool IsMinuteInsideSession(const int current_minute,
                              const int start_minute,
                              const int end_minute) const
   {
      if(current_minute < 0 || current_minute > 1439)
         return(false);

      if(start_minute < 0 || start_minute > 1439)
         return(false);

      if(end_minute < 0 || end_minute > 1439)
         return(false);

      if(start_minute == end_minute)
         return(true);

      if(start_minute < end_minute)
      {
         return(current_minute >= start_minute &&
                current_minute <= end_minute);
      }

      return(current_minute >= start_minute ||
             current_minute <= end_minute);
   }

   bool IsTimeInsideSession(const datetime evaluated_at,
                            const int start_hour,
                            const int start_minute,
                            const int end_hour,
                            const int end_minute) const
   {
      if(evaluated_at <= 0)
         return(false);

      const int current_total = DateTimeMinuteOfDay(evaluated_at);
      const int start_total   = MinuteOfDay(start_hour, start_minute);
      const int end_total     = MinuteOfDay(end_hour, end_minute);

      if(current_total < 0 || start_total < 0 || end_total < 0)
         return(false);

      return(IsMinuteInsideSession(current_total,
                                   start_total,
                                   end_total));
   }

   bool IsWeekdayEnabled(const int day_of_week,
                         const bool sunday,
                         const bool monday,
                         const bool tuesday,
                         const bool wednesday,
                         const bool thursday,
                         const bool friday,
                         const bool saturday) const
   {
      if(!IsValidDayOfWeek(day_of_week))
         return(false);

      if(day_of_week == 0)
         return(sunday);

      if(day_of_week == 1)
         return(monday);

      if(day_of_week == 2)
         return(tuesday);

      if(day_of_week == 3)
         return(wednesday);

      if(day_of_week == 4)
         return(thursday);

      if(day_of_week == 5)
         return(friday);

      return(saturday);
   }

   ENUM_BOSSR_FILTER_DECISION SessionDecision(
      const datetime evaluated_at,
      const int start_hour,
      const int start_minute,
      const int end_hour,
      const int end_minute,
      const bool sunday,
      const bool monday,
      const bool tuesday,
      const bool wednesday,
      const bool thursday,
      const bool friday,
      const bool saturday) const
   {
      if(evaluated_at <= 0)
         return(BOSSR_FILTER_DECISION_UNAVAILABLE);

      if(!IsValidSessionTime(start_hour, start_minute) ||
         !IsValidSessionTime(end_hour, end_minute))
      {
         return(BOSSR_FILTER_DECISION_UNAVAILABLE);
      }

      const int day_of_week = TimeDayOfWeek(evaluated_at);

      if(!IsValidDayOfWeek(day_of_week))
         return(BOSSR_FILTER_DECISION_UNAVAILABLE);

      if(!IsWeekdayEnabled(day_of_week,
                           sunday,
                           monday,
                           tuesday,
                           wednesday,
                           thursday,
                           friday,
                           saturday))
      {
         return(BOSSR_FILTER_DECISION_FAIL);
      }

      if(IsTimeInsideSession(evaluated_at,
                             start_hour,
                             start_minute,
                             end_hour,
                             end_minute))
      {
         return(BOSSR_FILTER_DECISION_PASS);
      }

      return(BOSSR_FILTER_DECISION_FAIL);
   }

   bool EvaluateSession(const datetime evaluated_at,
                        const int start_hour,
                        const int start_minute,
                        const int end_hour,
                        const int end_minute,
                        const bool sunday,
                        const bool monday,
                        const bool tuesday,
                        const bool wednesday,
                        const bool thursday,
                        const bool friday,
                        const bool saturday)
   {
      if(!IsOperational())
         return(false);

      const datetime event_time =
         (evaluated_at > 0 ? evaluated_at : TimeCurrent());

      if(event_time <= 0)
         return(false);

      if(!IsValidSessionTime(start_hour, start_minute) ||
         !IsValidSessionTime(end_hour, end_minute))
      {
         return(RecordUnavailable(event_time,
                                  0.0,
                                  "Invalid session configuration"));
      }

      const ENUM_BOSSR_FILTER_DECISION decision =
         SessionDecision(event_time,
                         start_hour,
                         start_minute,
                         end_hour,
                         end_minute,
                         sunday,
                         monday,
                         tuesday,
                         wednesday,
                         thursday,
                         friday,
                         saturday);

      if(decision == BOSSR_FILTER_DECISION_UNAVAILABLE)
      {
         return(RecordUnavailable(event_time,
                                  0.0,
                                  "Session unavailable"));
      }

      const int current_minute = DateTimeMinuteOfDay(event_time);
      const int session_end    = MinuteOfDay(end_hour, end_minute);
      const bool day_enabled   =
         IsWeekdayEnabled(TimeDayOfWeek(event_time),
                          sunday,
                          monday,
                          tuesday,
                          wednesday,
                          thursday,
                          friday,
                          saturday);

      string reason = "";

      if(decision == BOSSR_FILTER_DECISION_PASS)
         reason = "Inside enabled session";
      else if(!day_enabled)
         reason = "Weekday disabled";
      else
         reason = "Outside session";

      SBossRFilterResult result;

      if(!BuildResult(result,
                      decision,
                      event_time,
                      (double)current_minute,
                      (double)session_end,
                      reason))
      {
         return(false);
      }

      return(RecordResult(result));
   }

   bool EvaluateCurrentSession(const int start_hour,
                               const int start_minute,
                               const int end_hour,
                               const int end_minute,
                               const bool sunday,
                               const bool monday,
                               const bool tuesday,
                               const bool wednesday,
                               const bool thursday,
                               const bool friday,
                               const bool saturday)
   {
      return(EvaluateSession(TimeCurrent(),
                             start_hour,
                             start_minute,
                             end_hour,
                             end_minute,
                             sunday,
                             monday,
                             tuesday,
                             wednesday,
                             thursday,
                             friday,
                             saturday));
   }

   // ---------------------------------------------------------------
   // Block 4: volatility filter
   // ATR is normalized to pips before threshold evaluation.
   // A maximum threshold of zero disables the upper bound.
   // ---------------------------------------------------------------
   bool IsValidAtrPeriod(const int period) const
   {
      return(period > 0);
   }

   bool IsValidShift(const int shift) const
   {
      return(shift >= 0);
   }

   bool NormalizePriceDistanceToPoints(const double distance,
                                       const double point,
                                       double &distance_points) const
   {
      distance_points = 0.0;

      if(!IsFiniteNumber(distance) ||
         !IsFiniteNumber(point))
      {
         return(false);
      }

      if(distance < 0.0 || point <= 0.0)
         return(false);

      distance_points = distance / point;

      if(!IsFiniteNumber(distance_points) ||
         distance_points < 0.0)
      {
         distance_points = 0.0;
         return(false);
      }

      return(true);
   }

   bool NormalizePriceDistanceToPips(const double distance,
                                     const double point,
                                     const int digits,
                                     double &distance_pips) const
   {
      distance_pips = 0.0;

      const double pip_size = PipSize(point, digits);

      if(pip_size <= 0.0)
         return(false);

      if(!IsFiniteNumber(distance) || distance < 0.0)
         return(false);

      distance_pips = distance / pip_size;

      if(!IsFiniteNumber(distance_pips) ||
         distance_pips < 0.0)
      {
         distance_pips = 0.0;
         return(false);
      }

      return(true);
   }

   ENUM_BOSSR_FILTER_DECISION VolatilityDecision(
      const double volatility_pips,
      const double minimum_volatility_pips,
      const double maximum_volatility_pips) const
   {
      if(!IsFiniteNumber(volatility_pips) ||
         !IsFiniteNumber(minimum_volatility_pips) ||
         !IsFiniteNumber(maximum_volatility_pips))
      {
         return(BOSSR_FILTER_DECISION_UNAVAILABLE);
      }

      if(volatility_pips < 0.0 ||
         minimum_volatility_pips < 0.0 ||
         maximum_volatility_pips < 0.0)
      {
         return(BOSSR_FILTER_DECISION_UNAVAILABLE);
      }

      if(maximum_volatility_pips > 0.0 &&
         maximum_volatility_pips < minimum_volatility_pips)
      {
         return(BOSSR_FILTER_DECISION_UNAVAILABLE);
      }

      if(volatility_pips < minimum_volatility_pips)
         return(BOSSR_FILTER_DECISION_FAIL);

      if(maximum_volatility_pips > 0.0 &&
         volatility_pips > maximum_volatility_pips)
      {
         return(BOSSR_FILTER_DECISION_FAIL);
      }

      return(BOSSR_FILTER_DECISION_PASS);
   }

   bool EvaluateVolatilityValue(
      const double volatility_price,
      const double point,
      const int digits,
      const double minimum_volatility_pips,
      const double maximum_volatility_pips,
      const datetime evaluated_at)
   {
      if(!IsOperational())
         return(false);

      const datetime event_time =
         (evaluated_at > 0 ? evaluated_at : TimeCurrent());

      if(event_time <= 0)
         return(false);

      if(!IsFiniteNumber(minimum_volatility_pips) ||
         !IsFiniteNumber(maximum_volatility_pips) ||
         minimum_volatility_pips < 0.0 ||
         maximum_volatility_pips < 0.0 ||
         (maximum_volatility_pips > 0.0 &&
          maximum_volatility_pips < minimum_volatility_pips))
      {
         return(RecordUnavailable(event_time,
                                  0.0,
                                  "Invalid volatility thresholds"));
      }

      double volatility_pips = 0.0;

      if(!NormalizePriceDistanceToPips(volatility_price,
                                      point,
                                      digits,
                                      volatility_pips))
      {
         return(RecordUnavailable(event_time,
                                  maximum_volatility_pips,
                                  "Invalid volatility data"));
      }

      const ENUM_BOSSR_FILTER_DECISION decision =
         VolatilityDecision(volatility_pips,
                            minimum_volatility_pips,
                            maximum_volatility_pips);

      if(decision == BOSSR_FILTER_DECISION_UNAVAILABLE)
      {
         return(RecordUnavailable(event_time,
                                  maximum_volatility_pips,
                                  "Volatility unavailable"));
      }

      string reason = "";

      if(decision == BOSSR_FILTER_DECISION_PASS)
         reason = "Volatility inside limits";
      else if(volatility_pips < minimum_volatility_pips)
         reason = "Volatility below minimum";
      else
         reason = "Volatility above maximum";

      SBossRFilterResult result;

      if(!BuildResult(result,
                      decision,
                      event_time,
                      volatility_pips,
                      maximum_volatility_pips,
                      reason))
      {
         return(false);
      }

      return(RecordResult(result));
   }

   bool EvaluateAtr(const string symbol,
                    const int timeframe,
                    const int atr_period,
                    const int shift,
                    const double minimum_volatility_pips,
                    const double maximum_volatility_pips,
                    const datetime evaluated_at = 0)
   {
      if(!IsOperational())
         return(false);

      const datetime event_time =
         (evaluated_at > 0 ? evaluated_at : TimeCurrent());

      if(event_time <= 0)
         return(false);

      const string clean_symbol = Trimmed(symbol);

      if(clean_symbol == "")
      {
         return(RecordUnavailable(event_time,
                                  maximum_volatility_pips,
                                  "Invalid symbol"));
      }

      if(!IsValidAtrPeriod(atr_period) ||
         !IsValidShift(shift))
      {
         return(RecordUnavailable(event_time,
                                  maximum_volatility_pips,
                                  "Invalid ATR configuration"));
      }

      if(iBars(clean_symbol, timeframe) <= atr_period + shift)
      {
         return(RecordUnavailable(event_time,
                                  maximum_volatility_pips,
                                  "Insufficient ATR history"));
      }

      ResetLastError();
      const double atr    = iATR(clean_symbol,
                                 timeframe,
                                 atr_period,
                                 shift);
      const int atr_error = GetLastError();

      ResetLastError();
      const double point  = MarketInfo(clean_symbol, MODE_POINT);
      const int digits    = (int)MarketInfo(clean_symbol, MODE_DIGITS);
      const int market_error = GetLastError();

      if(atr_error != 0 ||
         market_error != 0 ||
         atr <= 0.0 ||
         point <= 0.0 ||
         !IsSupportedDigits(digits))
      {
         return(RecordUnavailable(event_time,
                                  maximum_volatility_pips,
                                  "ATR data unavailable"));
      }

      return(EvaluateVolatilityValue(atr,
                                     point,
                                     digits,
                                     minimum_volatility_pips,
                                     maximum_volatility_pips,
                                     event_time));
   }

   bool EvaluateCurrentAtr(const int atr_period,
                           const int shift,
                           const double minimum_volatility_pips,
                           const double maximum_volatility_pips)
   {
      return(EvaluateAtr(Symbol(),
                         Period(),
                         atr_period,
                         shift,
                         minimum_volatility_pips,
                         maximum_volatility_pips,
                         TimeCurrent()));
   }

   // ---------------------------------------------------------------
   // Block 5: trend filter
   // Uses fast/slow moving-average alignment and optional price
   // confirmation. Direction: +1 bullish, -1 bearish, 0 neutral.
   // ---------------------------------------------------------------
   bool IsValidMaPeriod(const int period) const
   {
      return(period > 0);
   }

   bool IsValidMaMethod(const int method) const
   {
      return(method == MODE_SMA ||
             method == MODE_EMA ||
             method == MODE_SMMA ||
             method == MODE_LWMA);
   }

   bool IsValidAppliedPrice(const int applied_price) const
   {
      return(applied_price == PRICE_CLOSE ||
             applied_price == PRICE_OPEN ||
             applied_price == PRICE_HIGH ||
             applied_price == PRICE_LOW ||
             applied_price == PRICE_MEDIAN ||
             applied_price == PRICE_TYPICAL ||
             applied_price == PRICE_WEIGHTED);
   }

   bool IsValidTrendDirection(const int direction) const
   {
      return(direction == -1 || direction == 0 || direction == 1);
   }

   int TrendDirectionFromValues(const double fast_ma,
                                const double slow_ma,
                                const double tolerance = 0.0) const
   {
      if(!IsFiniteNumber(fast_ma) ||
         !IsFiniteNumber(slow_ma) ||
         !IsFiniteNumber(tolerance) ||
         tolerance < 0.0)
      {
         return(0);
      }

      if(fast_ma > slow_ma + tolerance)
         return(1);

      if(fast_ma < slow_ma - tolerance)
         return(-1);

      return(0);
   }

   bool PriceConfirmsTrend(const double price,
                           const double fast_ma,
                           const double slow_ma,
                           const int direction,
                           const double tolerance = 0.0) const
   {
      if(!IsFiniteNumber(price) ||
         !IsFiniteNumber(fast_ma) ||
         !IsFiniteNumber(slow_ma) ||
         !IsFiniteNumber(tolerance) ||
         tolerance < 0.0 ||
         !IsValidTrendDirection(direction))
      {
         return(false);
      }

      if(direction > 0)
      {
         return(price >= fast_ma - tolerance &&
                price >= slow_ma - tolerance);
      }

      if(direction < 0)
      {
         return(price <= fast_ma + tolerance &&
                price <= slow_ma + tolerance);
      }

      return(false);
   }

   ENUM_BOSSR_FILTER_DECISION TrendDecision(
      const double price,
      const double fast_ma,
      const double slow_ma,
      const int required_direction,
      const bool require_price_confirmation,
      const double tolerance = 0.0) const
   {
      if(!IsFiniteNumber(price) ||
         !IsFiniteNumber(fast_ma) ||
         !IsFiniteNumber(slow_ma) ||
         !IsFiniteNumber(tolerance) ||
         tolerance < 0.0 ||
         price <= 0.0 ||
         fast_ma <= 0.0 ||
         slow_ma <= 0.0 ||
         !IsValidTrendDirection(required_direction) ||
         required_direction == 0)
      {
         return(BOSSR_FILTER_DECISION_UNAVAILABLE);
      }

      const int actual_direction =
         TrendDirectionFromValues(fast_ma, slow_ma, tolerance);

      if(actual_direction == 0)
         return(BOSSR_FILTER_DECISION_FAIL);

      if(actual_direction != required_direction)
         return(BOSSR_FILTER_DECISION_FAIL);

      if(require_price_confirmation &&
         !PriceConfirmsTrend(price,
                             fast_ma,
                             slow_ma,
                             required_direction,
                             tolerance))
      {
         return(BOSSR_FILTER_DECISION_FAIL);
      }

      return(BOSSR_FILTER_DECISION_PASS);
   }

   bool EvaluateTrendValues(
      const double price,
      const double fast_ma,
      const double slow_ma,
      const int required_direction,
      const bool require_price_confirmation,
      const double tolerance,
      const datetime evaluated_at)
   {
      if(!IsOperational())
         return(false);

      const datetime event_time =
         (evaluated_at > 0 ? evaluated_at : TimeCurrent());

      if(event_time <= 0)
         return(false);

      if(!IsFiniteNumber(price) ||
         !IsFiniteNumber(fast_ma) ||
         !IsFiniteNumber(slow_ma) ||
         !IsFiniteNumber(tolerance) ||
         tolerance < 0.0 ||
         price <= 0.0 ||
         fast_ma <= 0.0 ||
         slow_ma <= 0.0 ||
         !IsValidTrendDirection(required_direction) ||
         required_direction == 0)
      {
         return(RecordUnavailable(event_time,
                                  0.0,
                                  "Invalid trend data"));
      }

      const int actual_direction =
         TrendDirectionFromValues(fast_ma, slow_ma, tolerance);

      const ENUM_BOSSR_FILTER_DECISION decision =
         TrendDecision(price,
                       fast_ma,
                       slow_ma,
                       required_direction,
                       require_price_confirmation,
                       tolerance);

      if(decision == BOSSR_FILTER_DECISION_UNAVAILABLE)
      {
         return(RecordUnavailable(event_time,
                                  (double)required_direction,
                                  "Trend unavailable"));
      }

      string reason = "";

      if(decision == BOSSR_FILTER_DECISION_PASS)
         reason = "Trend requirements met";
      else if(actual_direction == 0)
         reason = "Trend neutral";
      else if(actual_direction != required_direction)
         reason = "Trend direction mismatch";
      else
         reason = "Price confirmation failed";

      SBossRFilterResult result;

      if(!BuildResult(result,
                      decision,
                      event_time,
                      (double)actual_direction,
                      (double)required_direction,
                      reason))
      {
         return(false);
      }

      return(RecordResult(result));
   }

   bool EvaluateMovingAverageTrend(
      const string symbol,
      const int timeframe,
      const int fast_period,
      const int slow_period,
      const int ma_method,
      const int applied_price,
      const int shift,
      const int required_direction,
      const bool require_price_confirmation,
      const double tolerance = 0.0,
      const datetime evaluated_at = 0)
   {
      if(!IsOperational())
         return(false);

      const datetime event_time =
         (evaluated_at > 0 ? evaluated_at : TimeCurrent());

      if(event_time <= 0)
         return(false);

      const string clean_symbol = Trimmed(symbol);

      if(clean_symbol == "")
      {
         return(RecordUnavailable(event_time,
                                  0.0,
                                  "Invalid symbol"));
      }

      if(!IsValidMaPeriod(fast_period) ||
         !IsValidMaPeriod(slow_period) ||
         fast_period >= slow_period ||
         !IsValidMaMethod(ma_method) ||
         !IsValidAppliedPrice(applied_price) ||
         !IsValidShift(shift) ||
         !IsValidTrendDirection(required_direction) ||
         required_direction == 0 ||
         !IsFiniteNumber(tolerance) ||
         tolerance < 0.0)
      {
         return(RecordUnavailable(event_time,
                                  0.0,
                                  "Invalid trend configuration"));
      }

      if(iBars(clean_symbol, timeframe) <= slow_period + shift)
      {
         return(RecordUnavailable(event_time,
                                  0.0,
                                  "Insufficient trend history"));
      }

      ResetLastError();
      const double fast_ma =
         iMA(clean_symbol,
             timeframe,
             fast_period,
             0,
             ma_method,
             applied_price,
             shift);
      const int fast_error = GetLastError();

      ResetLastError();
      const double slow_ma =
         iMA(clean_symbol,
             timeframe,
             slow_period,
             0,
             ma_method,
             applied_price,
             shift);
      const int slow_error = GetLastError();

      ResetLastError();
      const double price =
         iClose(clean_symbol, timeframe, shift);
      const int price_error = GetLastError();

      if(fast_error != 0 ||
         slow_error != 0 ||
         price_error != 0 ||
         fast_ma <= 0.0 ||
         slow_ma <= 0.0 ||
         price <= 0.0)
      {
         return(RecordUnavailable(event_time,
                                  0.0,
                                  "Trend market data unavailable"));
      }

      return(EvaluateTrendValues(price,
                                 fast_ma,
                                 slow_ma,
                                 required_direction,
                                 require_price_confirmation,
                                 tolerance,
                                 event_time));
   }

   bool EvaluateCurrentMovingAverageTrend(
      const int fast_period,
      const int slow_period,
      const int ma_method,
      const int applied_price,
      const int shift,
      const int required_direction,
      const bool require_price_confirmation,
      const double tolerance = 0.0)
   {
      return(EvaluateMovingAverageTrend(Symbol(),
                                        Period(),
                                        fast_period,
                                        slow_period,
                                        ma_method,
                                        applied_price,
                                        shift,
                                        required_direction,
                                        require_price_confirmation,
                                        tolerance,
                                        TimeCurrent()));
   }

   // ---------------------------------------------------------------
   // Block 6: volume filter
   // Supports absolute tick-volume thresholds and relative volume
   // against an average of prior bars. Ratio 1.0 = 100% of average.
   // A maximum value of zero disables the upper bound.
   // ---------------------------------------------------------------
   bool IsValidVolumeLookback(const int lookback) const
   {
      return(lookback > 0);
   }

   bool IsValidVolumeValue(const double volume) const
   {
      return(IsFiniteNumber(volume) && volume >= 0.0);
   }

   bool CalculateAverageVolume(const double &volumes[],
                               const int count,
                               double &average_volume) const
   {
      average_volume = 0.0;

      if(count <= 0 || ArraySize(volumes) < count)
         return(false);

      double total = 0.0;

      for(int i = 0; i < count; i++)
      {
         if(!IsValidVolumeValue(volumes[i]))
            return(false);

         total += volumes[i];

         if(!IsFiniteNumber(total))
         {
            average_volume = 0.0;
            return(false);
         }
      }

      average_volume = total / (double)count;

      return(IsFiniteNumber(average_volume) &&
             average_volume >= 0.0);
   }

   bool CalculateVolumeRatio(const double current_volume,
                             const double average_volume,
                             double &volume_ratio) const
   {
      volume_ratio = 0.0;

      if(!IsValidVolumeValue(current_volume) ||
         !IsValidVolumeValue(average_volume) ||
         average_volume <= 0.0)
      {
         return(false);
      }

      volume_ratio = current_volume / average_volume;

      if(!IsFiniteNumber(volume_ratio) || volume_ratio < 0.0)
      {
         volume_ratio = 0.0;
         return(false);
      }

      return(true);
   }

   ENUM_BOSSR_FILTER_DECISION VolumeDecision(
      const double value,
      const double minimum_value,
      const double maximum_value) const
   {
      if(!IsValidVolumeValue(value) ||
         !IsValidVolumeValue(minimum_value) ||
         !IsValidVolumeValue(maximum_value))
      {
         return(BOSSR_FILTER_DECISION_UNAVAILABLE);
      }

      if(maximum_value > 0.0 &&
         maximum_value < minimum_value)
      {
         return(BOSSR_FILTER_DECISION_UNAVAILABLE);
      }

      if(value < minimum_value)
         return(BOSSR_FILTER_DECISION_FAIL);

      if(maximum_value > 0.0 && value > maximum_value)
         return(BOSSR_FILTER_DECISION_FAIL);

      return(BOSSR_FILTER_DECISION_PASS);
   }

   bool EvaluateVolumeValue(const double value,
                            const double minimum_value,
                            const double maximum_value,
                            const datetime evaluated_at,
                            const string label = "Volume")
   {
      if(!IsOperational())
         return(false);

      const datetime event_time =
         (evaluated_at > 0 ? evaluated_at : TimeCurrent());

      if(event_time <= 0)
         return(false);

      if(!IsValidVolumeValue(minimum_value) ||
         !IsValidVolumeValue(maximum_value) ||
         (maximum_value > 0.0 &&
          maximum_value < minimum_value))
      {
         return(RecordUnavailable(event_time,
                                  0.0,
                                  "Invalid volume thresholds"));
      }

      if(!IsValidVolumeValue(value))
      {
         return(RecordUnavailable(event_time,
                                  maximum_value,
                                  "Invalid volume data"));
      }

      const ENUM_BOSSR_FILTER_DECISION decision =
         VolumeDecision(value, minimum_value, maximum_value);

      if(decision == BOSSR_FILTER_DECISION_UNAVAILABLE)
      {
         return(RecordUnavailable(event_time,
                                  maximum_value,
                                  "Volume unavailable"));
      }

      string reason = "";

      if(decision == BOSSR_FILTER_DECISION_PASS)
         reason = label + " inside limits";
      else if(value < minimum_value)
         reason = label + " below minimum";
      else
         reason = label + " above maximum";

      SBossRFilterResult result;

      if(!BuildResult(result,
                      decision,
                      event_time,
                      value,
                      maximum_value,
                      reason))
      {
         return(false);
      }

      return(RecordResult(result));
   }

   bool EvaluateAbsoluteVolume(const string symbol,
                               const int timeframe,
                               const int shift,
                               const double minimum_volume,
                               const double maximum_volume,
                               const datetime evaluated_at = 0)
   {
      if(!IsOperational())
         return(false);

      const datetime event_time =
         (evaluated_at > 0 ? evaluated_at : TimeCurrent());

      if(event_time <= 0)
         return(false);

      const string clean_symbol = Trimmed(symbol);

      if(clean_symbol == "")
      {
         return(RecordUnavailable(event_time,
                                  maximum_volume,
                                  "Invalid symbol"));
      }

      if(!IsValidShift(shift))
      {
         return(RecordUnavailable(event_time,
                                  maximum_volume,
                                  "Invalid volume configuration"));
      }

      if(iBars(clean_symbol, timeframe) <= shift)
      {
         return(RecordUnavailable(event_time,
                                  maximum_volume,
                                  "Insufficient volume history"));
      }

      ResetLastError();
      const long raw_volume = iVolume(clean_symbol,
                                      timeframe,
                                      shift);
      const int volume_error = GetLastError();

      if(volume_error != 0 || raw_volume < 0)
      {
         return(RecordUnavailable(event_time,
                                  maximum_volume,
                                  "Volume market data unavailable"));
      }

      return(EvaluateVolumeValue((double)raw_volume,
                                 minimum_volume,
                                 maximum_volume,
                                 event_time,
                                 "Volume"));
   }

   bool EvaluateRelativeVolume(const string symbol,
                               const int timeframe,
                               const int shift,
                               const int lookback,
                               const double minimum_ratio,
                               const double maximum_ratio,
                               const datetime evaluated_at = 0)
   {
      if(!IsOperational())
         return(false);

      const datetime event_time =
         (evaluated_at > 0 ? evaluated_at : TimeCurrent());

      if(event_time <= 0)
         return(false);

      const string clean_symbol = Trimmed(symbol);

      if(clean_symbol == "")
      {
         return(RecordUnavailable(event_time,
                                  maximum_ratio,
                                  "Invalid symbol"));
      }

      if(!IsValidShift(shift) ||
         !IsValidVolumeLookback(lookback))
      {
         return(RecordUnavailable(event_time,
                                  maximum_ratio,
                                  "Invalid volume configuration"));
      }

      if(iBars(clean_symbol, timeframe) <= shift + lookback)
      {
         return(RecordUnavailable(event_time,
                                  maximum_ratio,
                                  "Insufficient volume history"));
      }

      ResetLastError();
      const long current_raw = iVolume(clean_symbol,
                                       timeframe,
                                       shift);
      const int current_error = GetLastError();

      if(current_error != 0 || current_raw < 0)
      {
         return(RecordUnavailable(event_time,
                                  maximum_ratio,
                                  "Volume market data unavailable"));
      }

      double total = 0.0;

      for(int i = 1; i <= lookback; i++)
      {
         ResetLastError();
         const long historical_raw =
            iVolume(clean_symbol, timeframe, shift + i);
         const int historical_error = GetLastError();

         if(historical_error != 0 || historical_raw < 0)
         {
            return(RecordUnavailable(event_time,
                                     maximum_ratio,
                                     "Volume history unavailable"));
         }

         total += (double)historical_raw;

         if(!IsFiniteNumber(total))
         {
            return(RecordUnavailable(event_time,
                                     maximum_ratio,
                                     "Volume history unavailable"));
         }
      }

      const double average_volume = total / (double)lookback;
      double ratio = 0.0;

      if(!CalculateVolumeRatio((double)current_raw,
                               average_volume,
                               ratio))
      {
         return(RecordUnavailable(event_time,
                                  maximum_ratio,
                                  "Relative volume unavailable"));
      }

      return(EvaluateVolumeValue(ratio,
                                 minimum_ratio,
                                 maximum_ratio,
                                 event_time,
                                 "Relative volume"));
   }

   bool EvaluateCurrentAbsoluteVolume(
      const int shift,
      const double minimum_volume,
      const double maximum_volume)
   {
      return(EvaluateAbsoluteVolume(Symbol(),
                                    Period(),
                                    shift,
                                    minimum_volume,
                                    maximum_volume,
                                    TimeCurrent()));
   }

   bool EvaluateCurrentRelativeVolume(
      const int shift,
      const int lookback,
      const double minimum_ratio,
      const double maximum_ratio)
   {
      return(EvaluateRelativeVolume(Symbol(),
                                    Period(),
                                    shift,
                                    lookback,
                                    minimum_ratio,
                                    maximum_ratio,
                                    TimeCurrent()));
   }
};

#endif // __BOSSR_FILTER_BLOCK6_VOLUME_FULL_MQH__
//+------------------------------------------------------------------+
