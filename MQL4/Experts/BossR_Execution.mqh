//+------------------------------------------------------------------+
//| BossR_Execution_Block8_FACADE_FULL.mqh                                  |
//| BossR Framework - Execution Module                               |
//| Block 8: unified execution facade and action semantics       |
//| MT4 only                                                         |
//+------------------------------------------------------------------+
#ifndef __BOSSR_EXECUTION_BLOCK8_FACADE_FULL_MQH__
#define __BOSSR_EXECUTION_BLOCK8_FACADE_FULL_MQH__

#include <BossR\BossR_Trade.mqh>


//+------------------------------------------------------------------+
//| Execution-local result codes                                     |
//+------------------------------------------------------------------+
enum ENUM_BOSSR_EXECUTION_CODE
{
   BOSSR_EXECUTION_OK                    = 0,
   BOSSR_EXECUTION_REJECT_STRUCTURE      = 9001,
   BOSSR_EXECUTION_REJECT_PREFLIGHT      = 9002,
   BOSSR_EXECUTION_REJECT_STOPS          = 9003,
   BOSSR_EXECUTION_REJECT_NOT_MARKET     = 9004
};


//+------------------------------------------------------------------+
//| Unified execution actions                                        |
//+------------------------------------------------------------------+
enum ENUM_BOSSR_EXECUTION_ACTION
{
   BOSSR_EXECUTION_ACTION_NONE   = 0,
   BOSSR_EXECUTION_ACTION_SEND   = 1,
   BOSSR_EXECUTION_ACTION_CLOSE  = 2,
   BOSSR_EXECUTION_ACTION_DELETE = 3,
   BOSSR_EXECUTION_ACTION_MODIFY = 4
};

//+------------------------------------------------------------------+
//| Execution request                                                |
//+------------------------------------------------------------------+
struct S_BossR_ExecutionRequest
{
   string   symbol;
   int      order_type;
   double   lots;
   double   price;
   int      slippage_points;
   double   stop_loss;
   double   take_profit;
   string   comment;
   int      magic_number;
   datetime expiration;
   color    arrow_color;
};

//+------------------------------------------------------------------+
//| Execution result                                                 |
//+------------------------------------------------------------------+
struct S_BossR_ExecutionResult
{
   bool     attempted;
   bool     succeeded;
   int      ticket;
   int      error_code;
   int      attempts;
   double   requested_price;
   double   executed_price;
};

//+------------------------------------------------------------------+
//| C_BossR_Execution                                                |
//+------------------------------------------------------------------+
class C_BossR_Execution
{
private:
   C_BossR_Trade m_trade;

public:
   // ---------------------------------------------------------------
   // Request/result initialization
   // ---------------------------------------------------------------
   void ResetRequest(S_BossR_ExecutionRequest &request) const
   {
      request.symbol          = "";
      request.order_type      = -1;
      request.lots            = 0.0;
      request.price           = 0.0;
      request.slippage_points = 0;
      request.stop_loss       = 0.0;
      request.take_profit     = 0.0;
      request.comment         = "";
      request.magic_number    = 0;
      request.expiration      = 0;
      request.arrow_color     = CLR_NONE;
   }

   void ResetResult(S_BossR_ExecutionResult &result) const
   {
      result.attempted       = false;
      result.succeeded       = false;
      result.ticket          = -1;
      result.error_code      = 0;
      result.attempts        = 0;
      result.requested_price = 0.0;
      result.executed_price  = 0.0;
   }

   // ---------------------------------------------------------------
   // Request builders
   // ---------------------------------------------------------------
   bool BuildMarketRequest(
      S_BossR_ExecutionRequest &request,
      const string symbol,
      const int order_type,
      const double lots,
      const double ask_price,
      const double bid_price,
      const int slippage_points,
      const double stop_loss,
      const double take_profit,
      const string comment,
      const int magic_number,
      const color arrow_color = CLR_NONE
   ) const
   {
      ResetRequest(request);

      if(StringLen(symbol) <= 0)
         return(false);

      if(!m_trade.IsMarketOrderType(order_type))
         return(false);

      if(lots <= 0.0)
         return(false);

      if(slippage_points < 0)
         return(false);

      if(!m_trade.IsValidMagicNumber(magic_number))
         return(false);

      double entry_price =
         m_trade.MarketEntryPrice(order_type,
                                  ask_price,
                                  bid_price);

      if(entry_price <= 0.0)
         return(false);

      if(stop_loss < 0.0 || take_profit < 0.0)
         return(false);

      request.symbol          = symbol;
      request.order_type      = order_type;
      request.lots            = lots;
      request.price           = entry_price;
      request.slippage_points = slippage_points;
      request.stop_loss       = stop_loss;
      request.take_profit     = take_profit;
      request.comment         = comment;
      request.magic_number    = magic_number;
      request.expiration      = 0;
      request.arrow_color     = arrow_color;

      return(true);
   }

   // ---------------------------------------------------------------
   // Request classification
   // ---------------------------------------------------------------
   bool IsMarketRequest(
      const S_BossR_ExecutionRequest &request
   ) const
   {
      return(m_trade.IsMarketOrderType(request.order_type));
   }

   bool IsPendingRequest(
      const S_BossR_ExecutionRequest &request
   ) const
   {
      return(m_trade.IsPendingOrderType(request.order_type));
   }

   // ---------------------------------------------------------------
   // Request validation
   // ---------------------------------------------------------------
   bool IsRequestStructurallyValid(
      const S_BossR_ExecutionRequest &request,
      const double min_lot,
      const double max_lot,
      const double lot_step
   ) const
   {
      if(StringLen(request.symbol) <= 0)
         return(false);

      return(
         m_trade.IsTradeRequestStructurallyValid(
            request.order_type,
            request.lots,
            min_lot,
            max_lot,
            lot_step,
            request.magic_number,
            request.slippage_points
         )
      );
   }

   bool IsMarketRequestPreflightValid(
      const S_BossR_ExecutionRequest &request,
      const double min_lot,
      const double max_lot,
      const double lot_step,
      const double ask_price,
      const double bid_price,
      const double point_size,
      const double maximum_spread_points
   ) const
   {
      if(StringLen(request.symbol) <= 0)
         return(false);

      if(!m_trade.IsMarketOrderPreflightValid(
            request.order_type,
            request.lots,
            min_lot,
            max_lot,
            lot_step,
            request.magic_number,
            request.slippage_points,
            ask_price,
            bid_price,
            point_size,
            maximum_spread_points))
      {
         return(false);
      }

      double expected_price =
         m_trade.MarketEntryPrice(request.order_type,
                                  ask_price,
                                  bid_price);

      if(expected_price <= 0.0)
         return(false);

      if(MathAbs(request.price - expected_price) >
         0.000000000001)
      {
         return(false);
      }

      return(true);
   }

   bool AreMarketStopsPreflightValid(
      const S_BossR_ExecutionRequest &request,
      const double minimum_distance_points,
      const double point_size
   ) const
   {
      return(
         m_trade.IsMarketStopsPreflightValid(
            request.order_type,
            request.price,
            request.stop_loss,
            request.take_profit,
            minimum_distance_points,
            point_size
         )
      );
   }

   bool IsMarketExecutionReady(
      const S_BossR_ExecutionRequest &request,
      const double min_lot,
      const double max_lot,
      const double lot_step,
      const double ask_price,
      const double bid_price,
      const double point_size,
      const double maximum_spread_points,
      const double minimum_stop_distance_points
   ) const
   {
      if(!IsRequestStructurallyValid(request,
                                     min_lot,
                                     max_lot,
                                     lot_step))
      {
         return(false);
      }

      if(!IsMarketRequestPreflightValid(request,
                                        min_lot,
                                        max_lot,
                                        lot_step,
                                        ask_price,
                                        bid_price,
                                        point_size,
                                        maximum_spread_points))
      {
         return(false);
      }

      return(
         AreMarketStopsPreflightValid(
            request,
            minimum_stop_distance_points,
            point_size
         )
      );
   }

   // ---------------------------------------------------------------
   // Result semantics
   // ---------------------------------------------------------------
   bool IsSuccessTicket(const int ticket) const
   {
      return(ticket > 0);
   }

   bool IsResultSuccess(
      const S_BossR_ExecutionResult &result
   ) const
   {
      return(
         result.attempted &&
         result.succeeded &&
         IsSuccessTicket(result.ticket) &&
         result.error_code == 0 &&
         result.attempts > 0
      );
   }

   bool IsResultFailure(
      const S_BossR_ExecutionResult &result
   ) const
   {
      if(!result.attempted)
         return(false);

      return(!IsResultSuccess(result));
   }

   void SetSuccessResult(
      S_BossR_ExecutionResult &result,
      const int ticket,
      const int attempts,
      const double requested_price,
      const double executed_price
   ) const
   {
      ResetResult(result);

      result.attempted       = true;
      result.succeeded       = IsSuccessTicket(ticket);
      result.ticket          = ticket;
      result.error_code      = 0;
      result.attempts        = MathMax(0, attempts);
      result.requested_price = requested_price;
      result.executed_price  = executed_price;
   }

   void SetFailureResult(
      S_BossR_ExecutionResult &result,
      const int error_code,
      const int attempts,
      const double requested_price
   ) const
   {
      ResetResult(result);

      result.attempted       = true;
      result.succeeded       = false;
      result.ticket          = -1;
      result.error_code      = MathMax(0, error_code);
      result.attempts        = MathMax(0, attempts);
      result.requested_price = requested_price;
      result.executed_price  = 0.0;
   }

   // ---------------------------------------------------------------
   // Block 2: single-attempt market execution
   // ---------------------------------------------------------------
   int MarketExecutionRejectCode(
      const S_BossR_ExecutionRequest &request,
      const double min_lot,
      const double max_lot,
      const double lot_step,
      const double ask_price,
      const double bid_price,
      const double point_size,
      const double maximum_spread_points,
      const double minimum_stop_distance_points
   ) const
   {
      if(!IsMarketRequest(request))
         return(BOSSR_EXECUTION_REJECT_NOT_MARKET);

      if(!IsRequestStructurallyValid(request,
                                     min_lot,
                                     max_lot,
                                     lot_step))
      {
         return(BOSSR_EXECUTION_REJECT_STRUCTURE);
      }

      if(!IsMarketRequestPreflightValid(request,
                                        min_lot,
                                        max_lot,
                                        lot_step,
                                        ask_price,
                                        bid_price,
                                        point_size,
                                        maximum_spread_points))
      {
         return(BOSSR_EXECUTION_REJECT_PREFLIGHT);
      }

      if(!AreMarketStopsPreflightValid(request,
                                       minimum_stop_distance_points,
                                       point_size))
      {
         return(BOSSR_EXECUTION_REJECT_STOPS);
      }

      return(BOSSR_EXECUTION_OK);
   }

   bool CanAttemptMarketSend(
      const S_BossR_ExecutionRequest &request,
      const double min_lot,
      const double max_lot,
      const double lot_step,
      const double ask_price,
      const double bid_price,
      const double point_size,
      const double maximum_spread_points,
      const double minimum_stop_distance_points
   ) const
   {
      return(
         MarketExecutionRejectCode(
            request,
            min_lot,
            max_lot,
            lot_step,
            ask_price,
            bid_price,
            point_size,
            maximum_spread_points,
            minimum_stop_distance_points
         ) == BOSSR_EXECUTION_OK
      );
   }

   bool ExecuteMarketOnce(
      const S_BossR_ExecutionRequest &request,
      S_BossR_ExecutionResult &result,
      const double min_lot,
      const double max_lot,
      const double lot_step,
      const double ask_price,
      const double bid_price,
      const double point_size,
      const double maximum_spread_points,
      const double minimum_stop_distance_points
   ) const
   {
      ResetResult(result);

      int reject_code =
         MarketExecutionRejectCode(
            request,
            min_lot,
            max_lot,
            lot_step,
            ask_price,
            bid_price,
            point_size,
            maximum_spread_points,
            minimum_stop_distance_points
         );

      if(reject_code != BOSSR_EXECUTION_OK)
      {
         SetFailureResult(result,
                          reject_code,
                          0,
                          request.price);

         return(false);
      }

      ResetLastError();

      int ticket =
         OrderSend(
            request.symbol,
            request.order_type,
            request.lots,
            request.price,
            request.slippage_points,
            request.stop_loss,
            request.take_profit,
            request.comment,
            request.magic_number,
            request.expiration,
            request.arrow_color
         );

      if(ticket <= 0)
      {
         int error_code = GetLastError();

         SetFailureResult(result,
                          error_code,
                          1,
                          request.price);

         return(false);
      }

      double executed_price = request.price;

      if(OrderSelect(ticket,SELECT_BY_TICKET))
         executed_price = OrderOpenPrice();

      SetSuccessResult(result,
                       ticket,
                       1,
                       request.price,
                       executed_price);

      return(IsResultSuccess(result));
   }

   bool IsExecutionRejectCode(const int error_code) const
   {
      return(
         error_code == BOSSR_EXECUTION_REJECT_STRUCTURE ||
         error_code == BOSSR_EXECUTION_REJECT_PREFLIGHT ||
         error_code == BOSSR_EXECUTION_REJECT_STOPS ||
         error_code == BOSSR_EXECUTION_REJECT_NOT_MARKET
      );
   }

   bool WasBrokerSendAttempted(
      const S_BossR_ExecutionResult &result
   ) const
   {
      return(result.attempted && result.attempts > 0);
   }

   bool WasRejectedBeforeSend(
      const S_BossR_ExecutionResult &result
   ) const
   {
      return(
         result.attempted &&
         result.attempts == 0 &&
         IsExecutionRejectCode(result.error_code)
      );
   }

   // ---------------------------------------------------------------
   // Block 3: retry classification and bounded policy
   // ---------------------------------------------------------------
   bool IsRetryableBrokerError(const int error_code) const
   {
      return(
         error_code == 4   ||   // ERR_SERVER_BUSY
         error_code == 6   ||   // ERR_NO_CONNECTION
         error_code == 8   ||   // ERR_TOO_FREQUENT_REQUESTS
         error_code == 128 ||   // ERR_TRADE_TIMEOUT
         error_code == 135 ||   // ERR_PRICE_CHANGED
         error_code == 136 ||   // ERR_OFF_QUOTES
         error_code == 137 ||   // ERR_BROKER_BUSY
         error_code == 138 ||   // ERR_REQUOTE
         error_code == 146      // ERR_TRADE_CONTEXT_BUSY
      );
   }

   bool IsHardStopBrokerError(const int error_code) const
   {
      if(error_code <= 0)
         return(false);

      if(IsExecutionRejectCode(error_code))
         return(true);

      return(!IsRetryableBrokerError(error_code));
   }

   int ClampMaxAttempts(const int max_attempts) const
   {
      if(max_attempts < 1)
         return(1);

      if(max_attempts > 10)
         return(10);

      return(max_attempts);
   }

   bool HasAttemptsRemaining(
      const int attempts_used,
      const int max_attempts
   ) const
   {
      int bounded_max = ClampMaxAttempts(max_attempts);

      if(attempts_used < 0)
         return(true);

      return(attempts_used < bounded_max);
   }

   bool ShouldRetryResult(
      const S_BossR_ExecutionResult &result,
      const int max_attempts
   ) const
   {
      if(!result.attempted)
         return(false);

      if(IsResultSuccess(result))
         return(false);

      if(IsExecutionRejectCode(result.error_code))
         return(false);

      if(!IsRetryableBrokerError(result.error_code))
         return(false);

      return(
         HasAttemptsRemaining(
            result.attempts,
            max_attempts
         )
      );
   }

   int NextAttemptNumber(
      const S_BossR_ExecutionResult &result
   ) const
   {
      if(result.attempts < 0)
         return(1);

      return(result.attempts + 1);
   }

   bool IsRetryPolicyExhausted(
      const S_BossR_ExecutionResult &result,
      const int max_attempts
   ) const
   {
      if(IsResultSuccess(result))
         return(false);

      if(!result.attempted)
         return(false);

      if(IsExecutionRejectCode(result.error_code))
         return(false);

      if(!IsRetryableBrokerError(result.error_code))
         return(false);

      return(
         !HasAttemptsRemaining(
            result.attempts,
            max_attempts
         )
      );
   }

   // ---------------------------------------------------------------
   // Block 4: bounded retry executor
   // ---------------------------------------------------------------
   bool RefreshMarketRequestPrice(
      S_BossR_ExecutionRequest &request,
      const double ask_price,
      const double bid_price
   ) const
   {
      if(!IsMarketRequest(request))
         return(false);

      double refreshed_price =
         m_trade.MarketEntryPrice(
            request.order_type,
            ask_price,
            bid_price
         );

      if(refreshed_price <= 0.0)
         return(false);

      request.price = refreshed_price;
      return(true);
   }

   bool ExecuteMarketWithRetry(
      S_BossR_ExecutionRequest &request,
      S_BossR_ExecutionResult &result,
      const double min_lot,
      const double max_lot,
      const double lot_step,
      const double point_size,
      const double maximum_spread_points,
      const double minimum_stop_distance_points,
      const int max_attempts
   ) const
   {
      ResetResult(result);

      int bounded_max_attempts =
         ClampMaxAttempts(max_attempts);

      for(int attempt = 1;
          attempt <= bounded_max_attempts;
          attempt++)
      {
         RefreshRates();

         double ask_price =
            MarketInfo(request.symbol,MODE_ASK);

         double bid_price =
            MarketInfo(request.symbol,MODE_BID);

         if(!RefreshMarketRequestPrice(
               request,
               ask_price,
               bid_price))
         {
            SetFailureResult(
               result,
               BOSSR_EXECUTION_REJECT_PREFLIGHT,
               attempt - 1,
               request.price
            );

            return(false);
         }

         S_BossR_ExecutionResult attempt_result;

         bool success =
            ExecuteMarketOnce(
               request,
               attempt_result,
               min_lot,
               max_lot,
               lot_step,
               ask_price,
               bid_price,
               point_size,
               maximum_spread_points,
               minimum_stop_distance_points
            );

         result = attempt_result;
         result.attempts = attempt;

         if(success)
            return(true);

         if(!ShouldRetryResult(
               result,
               bounded_max_attempts))
         {
            return(false);
         }
      }

      return(false);
   }

   bool IsRetryExecutorResultConsistent(
      const S_BossR_ExecutionResult &result,
      const int max_attempts
   ) const
   {
      int bounded_max_attempts =
         ClampMaxAttempts(max_attempts);

      if(!result.attempted)
      {
         return(
            !result.succeeded &&
            result.ticket <= 0 &&
            result.attempts == 0
         );
      }

      if(result.attempts < 0 ||
         result.attempts > bounded_max_attempts)
      {
         return(false);
      }

      if(IsResultSuccess(result))
         return(result.attempts >= 1);

      if(IsExecutionRejectCode(result.error_code))
         return(result.attempts == 0);

      if(WasBrokerSendAttempted(result))
         return(result.attempts >= 1);

      return(false);
   }

   // ---------------------------------------------------------------
   // Block 5: close/delete execution wrappers
   // ---------------------------------------------------------------
   bool IsCloseRequestValid(
      const int ticket,
      const double lots,
      const double close_price,
      const int slippage_points
   ) const
   {
      if(ticket <= 0)
         return(false);

      if(lots <= 0.0)
         return(false);

      if(close_price <= 0.0)
         return(false);

      if(slippage_points < 0)
         return(false);

      return(true);
   }

   bool IsDeleteRequestValid(
      const int ticket
   ) const
   {
      return(ticket > 0);
   }

   bool CloseOrderOnce(
      const int ticket,
      const double lots,
      const double close_price,
      const int slippage_points,
      const color arrow_color,
      S_BossR_ExecutionResult &result
   ) const
   {
      ResetResult(result);

      if(!IsCloseRequestValid(
            ticket,
            lots,
            close_price,
            slippage_points))
      {
         SetFailureResult(
            result,
            BOSSR_EXECUTION_REJECT_STRUCTURE,
            0,
            close_price
         );

         return(false);
      }

      ResetLastError();

      bool closed =
         OrderClose(
            ticket,
            lots,
            close_price,
            slippage_points,
            arrow_color
         );

      if(!closed)
      {
         int error_code = GetLastError();

         SetFailureResult(
            result,
            error_code,
            1,
            close_price
         );

         return(false);
      }

      SetSuccessResult(
         result,
         ticket,
         1,
         close_price,
         close_price
      );

      return(IsResultSuccess(result));
   }

   bool DeleteOrderOnce(
      const int ticket,
      const color arrow_color,
      S_BossR_ExecutionResult &result
   ) const
   {
      ResetResult(result);

      if(!IsDeleteRequestValid(ticket))
      {
         SetFailureResult(
            result,
            BOSSR_EXECUTION_REJECT_STRUCTURE,
            0,
            0.0
         );

         return(false);
      }

      ResetLastError();

      bool deleted =
         OrderDelete(
            ticket,
            arrow_color
         );

      if(!deleted)
      {
         int error_code = GetLastError();

         SetFailureResult(
            result,
            error_code,
            1,
            0.0
         );

         return(false);
      }

      SetSuccessResult(
         result,
         ticket,
         1,
         0.0,
         0.0
      );

      return(IsResultSuccess(result));
   }

   bool IsCloseResultConsistent(
      const S_BossR_ExecutionResult &result
   ) const
   {
      if(!result.attempted)
      {
         return(
            !result.succeeded &&
            result.ticket <= 0 &&
            result.attempts == 0
         );
      }

      if(IsExecutionRejectCode(result.error_code))
      {
         return(
            !result.succeeded &&
            result.ticket <= 0 &&
            result.attempts == 0
         );
      }

      if(IsResultSuccess(result))
      {
         return(
            result.ticket > 0 &&
            result.attempts == 1 &&
            result.requested_price > 0.0 &&
            result.executed_price > 0.0
         );
      }

      return(
         !result.succeeded &&
         result.ticket <= 0 &&
         result.attempts == 1
      );
   }

   bool IsDeleteResultConsistent(
      const S_BossR_ExecutionResult &result
   ) const
   {
      if(!result.attempted)
      {
         return(
            !result.succeeded &&
            result.ticket <= 0 &&
            result.attempts == 0
         );
      }

      if(IsExecutionRejectCode(result.error_code))
      {
         return(
            !result.succeeded &&
            result.ticket <= 0 &&
            result.attempts == 0
         );
      }

      if(IsResultSuccess(result))
      {
         return(
            result.ticket > 0 &&
            result.attempts == 1 &&
            result.requested_price == 0.0 &&
            result.executed_price == 0.0
         );
      }

      return(
         !result.succeeded &&
         result.ticket <= 0 &&
         result.attempts == 1
      );
   }

   // ---------------------------------------------------------------
   // Block 6: modify execution wrapper
   // ---------------------------------------------------------------
   bool IsModifyRequestValid(
      const int ticket,
      const double price,
      const double stop_loss,
      const double take_profit,
      const datetime expiration
   ) const
   {
      if(ticket <= 0)
         return(false);

      if(price < 0.0)
         return(false);

      if(stop_loss < 0.0)
         return(false);

      if(take_profit < 0.0)
         return(false);

      if(expiration < 0)
         return(false);

      return(true);
   }

   bool ModifyOrderOnce(
      const int ticket,
      const double price,
      const double stop_loss,
      const double take_profit,
      const datetime expiration,
      const color arrow_color,
      S_BossR_ExecutionResult &result
   ) const
   {
      ResetResult(result);

      if(!IsModifyRequestValid(
            ticket,
            price,
            stop_loss,
            take_profit,
            expiration))
      {
         SetFailureResult(
            result,
            BOSSR_EXECUTION_REJECT_STRUCTURE,
            0,
            price
         );

         return(false);
      }

      ResetLastError();

      bool modified =
         OrderModify(
            ticket,
            price,
            stop_loss,
            take_profit,
            expiration,
            arrow_color
         );

      if(!modified)
      {
         int error_code = GetLastError();

         SetFailureResult(
            result,
            error_code,
            1,
            price
         );

         return(false);
      }

      SetSuccessResult(
         result,
         ticket,
         1,
         price,
         price
      );

      return(IsResultSuccess(result));
   }

   bool IsModifyResultConsistent(
      const S_BossR_ExecutionResult &result
   ) const
   {
      if(!result.attempted)
      {
         return(
            !result.succeeded &&
            result.ticket <= 0 &&
            result.attempts == 0
         );
      }

      if(IsExecutionRejectCode(result.error_code))
      {
         return(
            !result.succeeded &&
            result.ticket <= 0 &&
            result.attempts == 0
         );
      }

      if(IsResultSuccess(result))
      {
         return(
            result.ticket > 0 &&
            result.attempts == 1 &&
            result.requested_price >= 0.0 &&
            result.executed_price == result.requested_price
         );
      }

      return(
         !result.succeeded &&
         result.ticket <= 0 &&
         result.attempts == 1
      );
   }

   bool IsNoPriceChangeModify(
      const double old_price,
      const double new_price,
      const double epsilon = 0.000000000001
   ) const
   {
      return(MathAbs(old_price - new_price) <= epsilon);
   }

   bool IsNoStopChangeModify(
      const double old_stop_loss,
      const double old_take_profit,
      const double new_stop_loss,
      const double new_take_profit,
      const double epsilon = 0.000000000001
   ) const
   {
      return(
         MathAbs(old_stop_loss - new_stop_loss) <= epsilon &&
         MathAbs(old_take_profit - new_take_profit) <= epsilon
      );
   }

   bool IsNoExpirationChangeModify(
      const datetime old_expiration,
      const datetime new_expiration
   ) const
   {
      return(old_expiration == new_expiration);
   }

   bool IsNoOpModify(
      const double old_price,
      const double old_stop_loss,
      const double old_take_profit,
      const datetime old_expiration,
      const double new_price,
      const double new_stop_loss,
      const double new_take_profit,
      const datetime new_expiration,
      const double epsilon = 0.000000000001
   ) const
   {
      return(
         IsNoPriceChangeModify(
            old_price,
            new_price,
            epsilon
         ) &&
         IsNoStopChangeModify(
            old_stop_loss,
            old_take_profit,
            new_stop_loss,
            new_take_profit,
            epsilon
         ) &&
         IsNoExpirationChangeModify(
            old_expiration,
            new_expiration
         )
      );
   }

   // ---------------------------------------------------------------
   // Block 8: unified execution facade and action semantics
   // ---------------------------------------------------------------
   bool RefreshClosePrice(
      const int order_type,
      const string symbol,
      double &close_price
   ) const
   {
      if(StringLen(symbol) <= 0)
         return(false);

      RefreshRates();

      double ask_price =
         MarketInfo(symbol,MODE_ASK);

      double bid_price =
         MarketInfo(symbol,MODE_BID);

      if(order_type == OP_BUY)
      {
         if(bid_price <= 0.0)
            return(false);

         close_price = bid_price;
         return(true);
      }

      if(order_type == OP_SELL)
      {
         if(ask_price <= 0.0)
            return(false);

         close_price = ask_price;
         return(true);
      }

      return(false);
   }

   bool ExecuteCloseWithRetry(
      const int ticket,
      const int order_type,
      const string symbol,
      const double lots,
      const int slippage_points,
      const color arrow_color,
      const int max_attempts,
      S_BossR_ExecutionResult &result
   ) const
   {
      ResetResult(result);

      int bounded_max_attempts =
         ClampMaxAttempts(max_attempts);

      if(ticket <= 0 ||
         lots <= 0.0 ||
         slippage_points < 0 ||
         StringLen(symbol) <= 0 ||
         !m_trade.IsMarketOrderType(order_type))
      {
         SetFailureResult(
            result,
            BOSSR_EXECUTION_REJECT_STRUCTURE,
            0,
            0.0
         );

         return(false);
      }

      for(int attempt = 1;
          attempt <= bounded_max_attempts;
          attempt++)
      {
         double close_price = 0.0;

         if(!RefreshClosePrice(
               order_type,
               symbol,
               close_price))
         {
            SetFailureResult(
               result,
               BOSSR_EXECUTION_REJECT_PREFLIGHT,
               attempt - 1,
               0.0
            );

            return(false);
         }

         S_BossR_ExecutionResult attempt_result;

         bool success =
            CloseOrderOnce(
               ticket,
               lots,
               close_price,
               slippage_points,
               arrow_color,
               attempt_result
            );

         result = attempt_result;
         result.attempts = attempt;

         if(success)
            return(true);

         if(!ShouldRetryResult(
               result,
               bounded_max_attempts))
         {
            return(false);
         }
      }

      return(false);
   }

   bool ExecuteDeleteWithRetry(
      const int ticket,
      const color arrow_color,
      const int max_attempts,
      S_BossR_ExecutionResult &result
   ) const
   {
      ResetResult(result);

      int bounded_max_attempts =
         ClampMaxAttempts(max_attempts);

      if(!IsDeleteRequestValid(ticket))
      {
         SetFailureResult(
            result,
            BOSSR_EXECUTION_REJECT_STRUCTURE,
            0,
            0.0
         );

         return(false);
      }

      for(int attempt = 1;
          attempt <= bounded_max_attempts;
          attempt++)
      {
         S_BossR_ExecutionResult attempt_result;

         bool success =
            DeleteOrderOnce(
               ticket,
               arrow_color,
               attempt_result
            );

         result = attempt_result;
         result.attempts = attempt;

         if(success)
            return(true);

         if(!ShouldRetryResult(
               result,
               bounded_max_attempts))
         {
            return(false);
         }
      }

      return(false);
   }

   bool ExecuteModifyWithRetry(
      const int ticket,
      const double price,
      const double stop_loss,
      const double take_profit,
      const datetime expiration,
      const color arrow_color,
      const int max_attempts,
      S_BossR_ExecutionResult &result
   ) const
   {
      ResetResult(result);

      int bounded_max_attempts =
         ClampMaxAttempts(max_attempts);

      if(!IsModifyRequestValid(
            ticket,
            price,
            stop_loss,
            take_profit,
            expiration))
      {
         SetFailureResult(
            result,
            BOSSR_EXECUTION_REJECT_STRUCTURE,
            0,
            price
         );

         return(false);
      }

      for(int attempt = 1;
          attempt <= bounded_max_attempts;
          attempt++)
      {
         S_BossR_ExecutionResult attempt_result;

         bool success =
            ModifyOrderOnce(
               ticket,
               price,
               stop_loss,
               take_profit,
               expiration,
               arrow_color,
               attempt_result
            );

         result = attempt_result;
         result.attempts = attempt;

         if(success)
            return(true);

         if(!ShouldRetryResult(
               result,
               bounded_max_attempts))
         {
            return(false);
         }
      }

      return(false);
   }

   bool IsActionRetryResultConsistent(
      const S_BossR_ExecutionResult &result,
      const int max_attempts
   ) const
   {
      int bounded_max_attempts =
         ClampMaxAttempts(max_attempts);

      if(!result.attempted)
      {
         return(
            !result.succeeded &&
            result.ticket <= 0 &&
            result.attempts == 0
         );
      }

      if(IsExecutionRejectCode(result.error_code))
      {
         return(
            !result.succeeded &&
            result.ticket <= 0 &&
            result.attempts == 0
         );
      }

      if(result.attempts < 1 ||
         result.attempts > bounded_max_attempts)
      {
         return(false);
      }

      if(IsResultSuccess(result))
         return(true);

      return(
         !result.succeeded &&
         result.ticket <= 0
      );
   }

   // ---------------------------------------------------------------
   // Block 8: unified execution facade
   // ---------------------------------------------------------------
   bool IsExecutionActionValid(
      const int action
   ) const
   {
      return(
         action == BOSSR_EXECUTION_ACTION_SEND   ||
         action == BOSSR_EXECUTION_ACTION_CLOSE  ||
         action == BOSSR_EXECUTION_ACTION_DELETE ||
         action == BOSSR_EXECUTION_ACTION_MODIFY
      );
   }

   bool IsExecutionActionTradeOpening(
      const int action
   ) const
   {
      return(action == BOSSR_EXECUTION_ACTION_SEND);
   }

   bool IsExecutionActionTradeClosing(
      const int action
   ) const
   {
      return(
         action == BOSSR_EXECUTION_ACTION_CLOSE ||
         action == BOSSR_EXECUTION_ACTION_DELETE
      );
   }

   bool IsExecutionActionMutation(
      const int action
   ) const
   {
      return(
         action == BOSSR_EXECUTION_ACTION_SEND   ||
         action == BOSSR_EXECUTION_ACTION_CLOSE  ||
         action == BOSSR_EXECUTION_ACTION_DELETE ||
         action == BOSSR_EXECUTION_ACTION_MODIFY
      );
   }

   bool IsUnifiedResultConsistent(
      const int action,
      const S_BossR_ExecutionResult &result,
      const int max_attempts
   ) const
   {
      if(!IsExecutionActionValid(action))
         return(false);

      if(action == BOSSR_EXECUTION_ACTION_SEND)
      {
         return(
            IsRetryExecutorResultConsistent(
               result,
               max_attempts
            )
         );
      }

      if(action == BOSSR_EXECUTION_ACTION_CLOSE ||
         action == BOSSR_EXECUTION_ACTION_DELETE ||
         action == BOSSR_EXECUTION_ACTION_MODIFY)
      {
         return(
            IsActionRetryResultConsistent(
               result,
               max_attempts
            )
         );
      }

      return(false);
   }

   bool IsTerminalExecutionResult(
      const S_BossR_ExecutionResult &result,
      const int max_attempts
   ) const
   {
      if(IsResultSuccess(result))
         return(true);

      if(!result.attempted)
         return(false);

      if(IsExecutionRejectCode(result.error_code))
         return(true);

      if(IsHardStopBrokerError(result.error_code))
         return(true);

      if(IsRetryPolicyExhausted(
            result,
            max_attempts))
      {
         return(true);
      }

      return(false);
   }

   bool IsRetryPendingExecutionResult(
      const S_BossR_ExecutionResult &result,
      const int max_attempts
   ) const
   {
      if(IsTerminalExecutionResult(
            result,
            max_attempts))
      {
         return(false);
      }

      return(
         ShouldRetryResult(
            result,
            max_attempts
         )
      );
   }

   int ExecutionOutcomeCode(
      const S_BossR_ExecutionResult &result,
      const int max_attempts
   ) const
   {
      if(IsResultSuccess(result))
         return(1);

      if(!result.attempted)
         return(0);

      if(IsRetryPendingExecutionResult(
            result,
            max_attempts))
      {
         return(2);
      }

      if(IsTerminalExecutionResult(
            result,
            max_attempts))
      {
         return(-1);
      }

      return(0);
   }
};

#endif
