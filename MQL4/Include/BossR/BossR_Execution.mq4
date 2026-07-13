//+------------------------------------------------------------------+
//| BossR_Execution_Verify_Block8_FACADE_FULL.mq4                           |
//| BossR Framework - Execution Module Verification                  |
//| Block 8                                                          |
//| Compile this EA only                                             |
//+------------------------------------------------------------------+
#property strict

#include <BossR\BossR_Execution_Block8_FACADE_FULL.mqh>

C_BossR_Execution BossExecution;

int g_pass = 0;
int g_fail = 0;

//+------------------------------------------------------------------+
//| Test helpers                                                     |
//+------------------------------------------------------------------+
void Pass(const string test_name)
{
   g_pass++;
   Print("PASS: ", test_name);
}

void Fail(const string test_name)
{
   g_fail++;
   Print("FAIL: ", test_name);
}

void ExpectBool(const string test_name,
                const bool actual,
                const bool expected)
{
   if(actual == expected)
   {
      Pass(test_name);
      return;
   }

   Fail(test_name);
   Print("   actual=", actual,
         " expected=", expected);
}

void ExpectInt(const string test_name,
               const int actual,
               const int expected)
{
   if(actual == expected)
   {
      Pass(test_name);
      return;
   }

   Fail(test_name);
   Print("   actual=", actual,
         " expected=", expected);
}

void ExpectDouble(const string test_name,
                  const double actual,
                  const double expected,
                  const double epsilon = 0.000000001)
{
   if(MathAbs(actual - expected) <= epsilon)
   {
      Pass(test_name);
      return;
   }

   Fail(test_name);
   Print("   actual=",
         DoubleToString(actual, 10),
         " expected=",
         DoubleToString(expected, 10));
}

void ExpectString(const string test_name,
                  const string actual,
                  const string expected)
{
   if(actual == expected)
   {
      Pass(test_name);
      return;
   }

   Fail(test_name);
   Print("   actual=[", actual,
         "] expected=[", expected, "]");
}

//+------------------------------------------------------------------+
//| Reset tests                                                      |
//+------------------------------------------------------------------+
void TestResetRequest()
{
   S_BossR_ExecutionRequest request;

   request.symbol = "EURUSD";
   request.order_type = OP_BUY;
   request.lots = 1.0;
   request.price = 1.1000;
   request.slippage_points = 5;
   request.stop_loss = 1.0900;
   request.take_profit = 1.1100;
   request.comment = "x";
   request.magic_number = 7;
   request.expiration = TimeCurrent();
   request.arrow_color = clrRed;

   BossExecution.ResetRequest(request);

   ExpectString("ResetRequest symbol", request.symbol, "");
   ExpectInt("ResetRequest type", request.order_type, -1);
   ExpectDouble("ResetRequest lots", request.lots, 0.0);
   ExpectDouble("ResetRequest price", request.price, 0.0);
   ExpectInt("ResetRequest slippage", request.slippage_points, 0);
   ExpectDouble("ResetRequest SL", request.stop_loss, 0.0);
   ExpectDouble("ResetRequest TP", request.take_profit, 0.0);
   ExpectString("ResetRequest comment", request.comment, "");
   ExpectInt("ResetRequest magic", request.magic_number, 0);
   ExpectInt("ResetRequest expiration", (int)request.expiration, 0);
   ExpectInt("ResetRequest color", (int)request.arrow_color, (int)CLR_NONE);
}

void TestResetResult()
{
   S_BossR_ExecutionResult result;

   result.attempted = true;
   result.succeeded = true;
   result.ticket = 100;
   result.error_code = 5;
   result.attempts = 3;
   result.requested_price = 1.1000;
   result.executed_price = 1.1001;

   BossExecution.ResetResult(result);

   ExpectBool("ResetResult attempted", result.attempted, false);
   ExpectBool("ResetResult succeeded", result.succeeded, false);
   ExpectInt("ResetResult ticket", result.ticket, -1);
   ExpectInt("ResetResult error", result.error_code, 0);
   ExpectInt("ResetResult attempts", result.attempts, 0);
   ExpectDouble("ResetResult requested", result.requested_price, 0.0);
   ExpectDouble("ResetResult executed", result.executed_price, 0.0);
}

//+------------------------------------------------------------------+
//| Builder tests                                                    |
//+------------------------------------------------------------------+
void TestMarketRequestBuilder()
{
   S_BossR_ExecutionRequest request;

   ExpectBool("Build BUY valid",
      BossExecution.BuildMarketRequest(
         request,"EURUSD",OP_BUY,0.10,
         1.10020,1.10000,3,
         1.09900,1.10200,
         "BossR",260713,clrBlue),true);

   ExpectString("Build BUY symbol", request.symbol, "EURUSD");
   ExpectInt("Build BUY type", request.order_type, OP_BUY);
   ExpectDouble("Build BUY lots", request.lots, 0.10);
   ExpectDouble("Build BUY Ask price", request.price, 1.10020);
   ExpectInt("Build BUY slippage", request.slippage_points, 3);
   ExpectDouble("Build BUY SL", request.stop_loss, 1.09900);
   ExpectDouble("Build BUY TP", request.take_profit, 1.10200);
   ExpectString("Build BUY comment", request.comment, "BossR");
   ExpectInt("Build BUY magic", request.magic_number, 260713);
   ExpectInt("Build BUY expiration zero", (int)request.expiration, 0);
   ExpectInt("Build BUY color", (int)request.arrow_color, (int)clrBlue);

   ExpectBool("Build SELL valid",
      BossExecution.BuildMarketRequest(
         request,"EURUSD",OP_SELL,0.20,
         1.10020,1.10000,5,
         1.10100,1.09800,
         "Sell",5,CLR_NONE),true);

   ExpectDouble("Build SELL Bid price", request.price, 1.10000);

   ExpectBool("Build empty symbol false",
      BossExecution.BuildMarketRequest(
         request,"",OP_BUY,0.10,
         1.10020,1.10000,3,
         0.0,0.0,"",1),false);

   ExpectBool("Build pending false",
      BossExecution.BuildMarketRequest(
         request,"EURUSD",OP_BUYSTOP,0.10,
         1.10020,1.10000,3,
         0.0,0.0,"",1),false);

   ExpectBool("Build zero lots false",
      BossExecution.BuildMarketRequest(
         request,"EURUSD",OP_BUY,0.0,
         1.10020,1.10000,3,
         0.0,0.0,"",1),false);

   ExpectBool("Build negative slippage false",
      BossExecution.BuildMarketRequest(
         request,"EURUSD",OP_BUY,0.10,
         1.10020,1.10000,-1,
         0.0,0.0,"",1),false);

   ExpectBool("Build negative magic false",
      BossExecution.BuildMarketRequest(
         request,"EURUSD",OP_BUY,0.10,
         1.10020,1.10000,3,
         0.0,0.0,"",-1),false);

   ExpectBool("Build crossed market false",
      BossExecution.BuildMarketRequest(
         request,"EURUSD",OP_BUY,0.10,
         1.09990,1.10000,3,
         0.0,0.0,"",1),false);

   ExpectBool("Build negative SL false",
      BossExecution.BuildMarketRequest(
         request,"EURUSD",OP_BUY,0.10,
         1.10020,1.10000,3,
         -1.0,0.0,"",1),false);

   ExpectBool("Build negative TP false",
      BossExecution.BuildMarketRequest(
         request,"EURUSD",OP_BUY,0.10,
         1.10020,1.10000,3,
         0.0,-1.0,"",1),false);
}

//+------------------------------------------------------------------+
//| Classification and structural tests                             |
//+------------------------------------------------------------------+
void TestRequestValidation()
{
   S_BossR_ExecutionRequest request;

   BossExecution.BuildMarketRequest(
      request,"EURUSD",OP_BUY,0.10,
      1.10020,1.10000,3,
      1.09900,1.10200,
      "BossR",260713);

   ExpectBool("Request market true",
      BossExecution.IsMarketRequest(request),true);

   ExpectBool("Request pending false",
      BossExecution.IsPendingRequest(request),false);

   ExpectBool("Request structural valid",
      BossExecution.IsRequestStructurallyValid(
         request,0.01,100.0,0.01),true);

   request.lots = 0.125;

   ExpectBool("Request structural off-step false",
      BossExecution.IsRequestStructurallyValid(
         request,0.01,100.0,0.01),false);

   request.lots = 0.10;
   request.symbol = "";

   ExpectBool("Request structural empty symbol false",
      BossExecution.IsRequestStructurallyValid(
         request,0.01,100.0,0.01),false);
}

//+------------------------------------------------------------------+
//| Market preflight tests                                           |
//+------------------------------------------------------------------+
void TestMarketPreflight()
{
   S_BossR_ExecutionRequest request;

   BossExecution.BuildMarketRequest(
      request,"EURUSD",OP_BUY,0.10,
      1.10020,1.10000,3,
      1.09900,1.10200,
      "BossR",260713);

   ExpectBool("Market preflight valid",
      BossExecution.IsMarketRequestPreflightValid(
         request,
         0.01,100.0,0.01,
         1.10020,1.10000,
         0.00001,30.0),true);

   ExpectBool("Market preflight spread false",
      BossExecution.IsMarketRequestPreflightValid(
         request,
         0.01,100.0,0.01,
         1.10040,1.10000,
         0.00001,30.0),false);

   ExpectBool("Market preflight price changed false",
      BossExecution.IsMarketRequestPreflightValid(
         request,
         0.01,100.0,0.01,
         1.10021,1.10000,
         0.00001,30.0),false);

   request.lots = 0.125;

   ExpectBool("Market preflight lots false",
      BossExecution.IsMarketRequestPreflightValid(
         request,
         0.01,100.0,0.01,
         1.10020,1.10000,
         0.00001,30.0),false);
}

//+------------------------------------------------------------------+
//| Stop preflight and full readiness tests                          |
//+------------------------------------------------------------------+
void TestMarketReadiness()
{
   S_BossR_ExecutionRequest request;

   BossExecution.BuildMarketRequest(
      request,"EURUSD",OP_BUY,0.10,
      1.10020,1.10000,3,
      1.09900,1.10200,
      "BossR",260713);

   ExpectBool("Stops preflight valid",
      BossExecution.AreMarketStopsPreflightValid(
         request,50.0,0.00001),true);

   ExpectBool("Execution ready valid",
      BossExecution.IsMarketExecutionReady(
         request,
         0.01,100.0,0.01,
         1.10020,1.10000,
         0.00001,30.0,50.0),true);

   request.stop_loss = 1.10000;

   ExpectBool("Stops preflight bad SL false",
      BossExecution.AreMarketStopsPreflightValid(
         request,50.0,0.00001),false);

   ExpectBool("Execution ready bad SL false",
      BossExecution.IsMarketExecutionReady(
         request,
         0.01,100.0,0.01,
         1.10020,1.10000,
         0.00001,30.0,50.0),false);

   BossExecution.BuildMarketRequest(
      request,"EURUSD",OP_SELL,0.10,
      1.10020,1.10000,3,
      1.10100,1.09800,
      "BossR",260713);

   ExpectBool("Execution ready SELL valid",
      BossExecution.IsMarketExecutionReady(
         request,
         0.01,100.0,0.01,
         1.10020,1.10000,
         0.00001,30.0,50.0),true);
}

//+------------------------------------------------------------------+
//| Result semantics tests                                           |
//+------------------------------------------------------------------+
void TestResultSemantics()
{
   S_BossR_ExecutionResult result;

   BossExecution.ResetResult(result);

   ExpectBool("Reset not success",
      BossExecution.IsResultSuccess(result),false);

   ExpectBool("Reset not failure",
      BossExecution.IsResultFailure(result),false);

   ExpectBool("Ticket positive success",
      BossExecution.IsSuccessTicket(1),true);

   ExpectBool("Ticket zero false",
      BossExecution.IsSuccessTicket(0),false);

   ExpectBool("Ticket negative false",
      BossExecution.IsSuccessTicket(-1),false);

   BossExecution.SetSuccessResult(
      result,12345,1,1.10020,1.10021);

   ExpectBool("Success attempted", result.attempted, true);
   ExpectBool("Success succeeded", result.succeeded, true);
   ExpectInt("Success ticket", result.ticket, 12345);
   ExpectInt("Success error zero", result.error_code, 0);
   ExpectInt("Success attempts", result.attempts, 1);
   ExpectDouble("Success requested", result.requested_price, 1.10020);
   ExpectDouble("Success executed", result.executed_price, 1.10021);
   ExpectBool("Success semantic true",
      BossExecution.IsResultSuccess(result),true);
   ExpectBool("Success failure false",
      BossExecution.IsResultFailure(result),false);

   BossExecution.SetFailureResult(
      result,130,2,1.10020);

   ExpectBool("Failure attempted", result.attempted, true);
   ExpectBool("Failure succeeded false", result.succeeded, false);
   ExpectInt("Failure ticket", result.ticket, -1);
   ExpectInt("Failure error", result.error_code, 130);
   ExpectInt("Failure attempts", result.attempts, 2);
   ExpectDouble("Failure requested", result.requested_price, 1.10020);
   ExpectDouble("Failure executed zero", result.executed_price, 0.0);
   ExpectBool("Failure semantic true",
      BossExecution.IsResultFailure(result),true);
   ExpectBool("Failure success false",
      BossExecution.IsResultSuccess(result),false);

   BossExecution.SetSuccessResult(
      result,-1,1,1.10020,1.10020);

   ExpectBool("Bad success ticket semantic false",
      BossExecution.IsResultSuccess(result),false);

   ExpectBool("Bad success ticket is failure",
      BossExecution.IsResultFailure(result),true);

   BossExecution.SetSuccessResult(
      result,10,0,1.10020,1.10020);

   ExpectBool("Zero attempts success false",
      BossExecution.IsResultSuccess(result),false);

   BossExecution.SetFailureResult(
      result,-5,-2,1.10020);

   ExpectInt("Failure negative error clamped", result.error_code, 0);
   ExpectInt("Failure negative attempts clamped", result.attempts, 0);
}


//+------------------------------------------------------------------+
//| Block 2 reject-code tests                                        |
//+------------------------------------------------------------------+
void TestExecutionRejectCodes()
{
   S_BossR_ExecutionRequest request;

   BossExecution.BuildMarketRequest(
      request,"EURUSD",OP_BUY,0.10,
      1.10020,1.10000,3,
      1.09900,1.10200,
      "BossR",260713);

   ExpectInt("Reject code ready OK",
      BossExecution.MarketExecutionRejectCode(
         request,
         0.01,100.0,0.01,
         1.10020,1.10000,
         0.00001,30.0,50.0),
      BOSSR_EXECUTION_OK);

   ExpectBool("Can attempt ready true",
      BossExecution.CanAttemptMarketSend(
         request,
         0.01,100.0,0.01,
         1.10020,1.10000,
         0.00001,30.0,50.0),true);

   request.order_type = OP_BUYSTOP;

   ExpectInt("Reject code non-market",
      BossExecution.MarketExecutionRejectCode(
         request,
         0.01,100.0,0.01,
         1.10020,1.10000,
         0.00001,30.0,50.0),
      BOSSR_EXECUTION_REJECT_NOT_MARKET);

   request.order_type = OP_BUY;
   request.lots = 0.125;

   ExpectInt("Reject code structure",
      BossExecution.MarketExecutionRejectCode(
         request,
         0.01,100.0,0.01,
         1.10020,1.10000,
         0.00001,30.0,50.0),
      BOSSR_EXECUTION_REJECT_STRUCTURE);

   request.lots = 0.10;

   ExpectInt("Reject code preflight",
      BossExecution.MarketExecutionRejectCode(
         request,
         0.01,100.0,0.01,
         1.10040,1.10000,
         0.00001,30.0,50.0),
      BOSSR_EXECUTION_REJECT_PREFLIGHT);

   request.stop_loss = 1.10000;

   ExpectInt("Reject code stops",
      BossExecution.MarketExecutionRejectCode(
         request,
         0.01,100.0,0.01,
         1.10020,1.10000,
         0.00001,30.0,50.0),
      BOSSR_EXECUTION_REJECT_STOPS);

   ExpectBool("Can attempt bad stops false",
      BossExecution.CanAttemptMarketSend(
         request,
         0.01,100.0,0.01,
         1.10020,1.10000,
         0.00001,30.0,50.0),false);
}

//+------------------------------------------------------------------+
//| Block 2 classification tests                                     |
//+------------------------------------------------------------------+
void TestExecutionCodeClassification()
{
   ExpectBool("Execution code OK not reject",
      BossExecution.IsExecutionRejectCode(
         BOSSR_EXECUTION_OK),false);

   ExpectBool("Structure code reject",
      BossExecution.IsExecutionRejectCode(
         BOSSR_EXECUTION_REJECT_STRUCTURE),true);

   ExpectBool("Preflight code reject",
      BossExecution.IsExecutionRejectCode(
         BOSSR_EXECUTION_REJECT_PREFLIGHT),true);

   ExpectBool("Stops code reject",
      BossExecution.IsExecutionRejectCode(
         BOSSR_EXECUTION_REJECT_STOPS),true);

   ExpectBool("Not-market code reject",
      BossExecution.IsExecutionRejectCode(
         BOSSR_EXECUTION_REJECT_NOT_MARKET),true);

   ExpectBool("Broker-style code not local reject",
      BossExecution.IsExecutionRejectCode(130),false);
}

//+------------------------------------------------------------------+
//| Block 2 no-send execution-path tests                             |
//| These deliberately fail before OrderSend and cannot open trades. |
//+------------------------------------------------------------------+
void TestExecuteMarketOnceRejectedPaths()
{
   S_BossR_ExecutionRequest request;
   S_BossR_ExecutionResult result;

   BossExecution.BuildMarketRequest(
      request,"EURUSD",OP_BUY,0.10,
      1.10020,1.10000,3,
      1.09900,1.10200,
      "BossR",260713);

   request.order_type = OP_BUYSTOP;

   ExpectBool("Execute non-market false",
      BossExecution.ExecuteMarketOnce(
         request,result,
         0.01,100.0,0.01,
         1.10020,1.10000,
         0.00001,30.0,50.0),false);

   ExpectBool("Execute non-market attempted flag true",
      result.attempted,true);

   ExpectBool("Execute non-market succeeded false",
      result.succeeded,false);

   ExpectInt("Execute non-market ticket",
      result.ticket,-1);

   ExpectInt("Execute non-market reject code",
      result.error_code,
      BOSSR_EXECUTION_REJECT_NOT_MARKET);

   ExpectInt("Execute non-market attempts zero",
      result.attempts,0);

   ExpectBool("Execute non-market no broker send",
      BossExecution.WasBrokerSendAttempted(result),false);

   ExpectBool("Execute non-market rejected before send",
      BossExecution.WasRejectedBeforeSend(result),true);

   BossExecution.BuildMarketRequest(
      request,"EURUSD",OP_BUY,0.10,
      1.10020,1.10000,3,
      1.10000,1.10200,
      "BossR",260713);

   ExpectBool("Execute bad stops false",
      BossExecution.ExecuteMarketOnce(
         request,result,
         0.01,100.0,0.01,
         1.10020,1.10000,
         0.00001,30.0,50.0),false);

   ExpectInt("Execute bad stops code",
      result.error_code,
      BOSSR_EXECUTION_REJECT_STOPS);

   ExpectInt("Execute bad stops attempts zero",
      result.attempts,0);

   ExpectDouble("Execute bad stops requested price",
      result.requested_price,1.10020);

   ExpectDouble("Execute bad stops executed zero",
      result.executed_price,0.0);

   ExpectBool("Execute bad stops local rejection",
      BossExecution.WasRejectedBeforeSend(result),true);

   BossExecution.BuildMarketRequest(
      request,"EURUSD",OP_BUY,0.10,
      1.10020,1.10000,3,
      1.09900,1.10200,
      "BossR",260713);

   request.lots = 0.125;

   ExpectBool("Execute structural false",
      BossExecution.ExecuteMarketOnce(
         request,result,
         0.01,100.0,0.01,
         1.10020,1.10000,
         0.00001,30.0,50.0),false);

   ExpectInt("Execute structural code",
      result.error_code,
      BOSSR_EXECUTION_REJECT_STRUCTURE);

   ExpectBool("Execute structural rejected before send",
      BossExecution.WasRejectedBeforeSend(result),true);

   BossExecution.BuildMarketRequest(
      request,"EURUSD",OP_SELL,0.10,
      1.10020,1.10000,3,
      1.10100,1.09800,
      "BossR",260713);

   ExpectBool("Execute spread preflight false",
      BossExecution.ExecuteMarketOnce(
         request,result,
         0.01,100.0,0.01,
         1.10040,1.10000,
         0.00001,30.0,50.0),false);

   ExpectInt("Execute spread preflight code",
      result.error_code,
      BOSSR_EXECUTION_REJECT_PREFLIGHT);

   ExpectBool("Execute spread no broker send",
      BossExecution.WasBrokerSendAttempted(result),false);
}

//+------------------------------------------------------------------+
//| Block 2 result routing tests                                     |
//+------------------------------------------------------------------+
void TestSendRoutingSemantics()
{
   S_BossR_ExecutionResult result;

   BossExecution.ResetResult(result);

   ExpectBool("Reset broker send false",
      BossExecution.WasBrokerSendAttempted(result),false);

   ExpectBool("Reset rejected before send false",
      BossExecution.WasRejectedBeforeSend(result),false);

   BossExecution.SetFailureResult(
      result,
      BOSSR_EXECUTION_REJECT_PREFLIGHT,
      0,
      1.10020);

   ExpectBool("Local reject broker send false",
      BossExecution.WasBrokerSendAttempted(result),false);

   ExpectBool("Local reject before send true",
      BossExecution.WasRejectedBeforeSend(result),true);

   BossExecution.SetFailureResult(
      result,
      138,
      1,
      1.10020);

   ExpectBool("Broker failure send attempted true",
      BossExecution.WasBrokerSendAttempted(result),true);

   ExpectBool("Broker failure local reject false",
      BossExecution.WasRejectedBeforeSend(result),false);

   BossExecution.SetSuccessResult(
      result,
      12345,
      1,
      1.10020,
      1.10021);

   ExpectBool("Success broker send attempted true",
      BossExecution.WasBrokerSendAttempted(result),true);

   ExpectBool("Success local reject false",
      BossExecution.WasRejectedBeforeSend(result),false);
}


//+------------------------------------------------------------------+
//| Block 3 retryable error classification tests                     |
//+------------------------------------------------------------------+
void TestRetryableBrokerErrors()
{
   ExpectBool("Retryable server busy",
      BossExecution.IsRetryableBrokerError(4),true);

   ExpectBool("Retryable no connection",
      BossExecution.IsRetryableBrokerError(6),true);

   ExpectBool("Retryable too frequent",
      BossExecution.IsRetryableBrokerError(8),true);

   ExpectBool("Retryable timeout",
      BossExecution.IsRetryableBrokerError(128),true);

   ExpectBool("Retryable price changed",
      BossExecution.IsRetryableBrokerError(135),true);

   ExpectBool("Retryable off quotes",
      BossExecution.IsRetryableBrokerError(136),true);

   ExpectBool("Retryable broker busy",
      BossExecution.IsRetryableBrokerError(137),true);

   ExpectBool("Retryable requote",
      BossExecution.IsRetryableBrokerError(138),true);

   ExpectBool("Retryable trade context busy",
      BossExecution.IsRetryableBrokerError(146),true);

   ExpectBool("Zero not retryable",
      BossExecution.IsRetryableBrokerError(0),false);

   ExpectBool("Invalid price not retryable",
      BossExecution.IsRetryableBrokerError(129),false);

   ExpectBool("Invalid stops not retryable",
      BossExecution.IsRetryableBrokerError(130),false);

   ExpectBool("Not enough money not retryable",
      BossExecution.IsRetryableBrokerError(134),false);

   ExpectBool("Trade disabled not retryable",
      BossExecution.IsRetryableBrokerError(133),false);

   ExpectBool("Local reject not retryable",
      BossExecution.IsRetryableBrokerError(
         BOSSR_EXECUTION_REJECT_PREFLIGHT),false);
}

//+------------------------------------------------------------------+
//| Block 3 hard-stop classification tests                           |
//+------------------------------------------------------------------+
void TestHardStopBrokerErrors()
{
   ExpectBool("Hard stop zero false",
      BossExecution.IsHardStopBrokerError(0),false);

   ExpectBool("Hard stop retryable false",
      BossExecution.IsHardStopBrokerError(138),false);

   ExpectBool("Hard stop invalid price true",
      BossExecution.IsHardStopBrokerError(129),true);

   ExpectBool("Hard stop invalid stops true",
      BossExecution.IsHardStopBrokerError(130),true);

   ExpectBool("Hard stop not enough money true",
      BossExecution.IsHardStopBrokerError(134),true);

   ExpectBool("Hard stop trade disabled true",
      BossExecution.IsHardStopBrokerError(133),true);

   ExpectBool("Hard stop local reject true",
      BossExecution.IsHardStopBrokerError(
         BOSSR_EXECUTION_REJECT_STRUCTURE),true);
}

//+------------------------------------------------------------------+
//| Block 3 bounded-attempt policy tests                             |
//+------------------------------------------------------------------+
void TestAttemptBounds()
{
   ExpectInt("Clamp attempts negative to one",
      BossExecution.ClampMaxAttempts(-5),1);

   ExpectInt("Clamp attempts zero to one",
      BossExecution.ClampMaxAttempts(0),1);

   ExpectInt("Clamp attempts one",
      BossExecution.ClampMaxAttempts(1),1);

   ExpectInt("Clamp attempts five",
      BossExecution.ClampMaxAttempts(5),5);

   ExpectInt("Clamp attempts ten",
      BossExecution.ClampMaxAttempts(10),10);

   ExpectInt("Clamp attempts eleven to ten",
      BossExecution.ClampMaxAttempts(11),10);

   ExpectInt("Clamp attempts huge to ten",
      BossExecution.ClampMaxAttempts(1000),10);

   ExpectBool("Remaining negative attempts true",
      BossExecution.HasAttemptsRemaining(-1,3),true);

   ExpectBool("Remaining zero of three true",
      BossExecution.HasAttemptsRemaining(0,3),true);

   ExpectBool("Remaining two of three true",
      BossExecution.HasAttemptsRemaining(2,3),true);

   ExpectBool("Remaining three of three false",
      BossExecution.HasAttemptsRemaining(3,3),false);

   ExpectBool("Remaining four of three false",
      BossExecution.HasAttemptsRemaining(4,3),false);

   ExpectBool("Remaining one of zero false",
      BossExecution.HasAttemptsRemaining(1,0),false);

   ExpectBool("Remaining zero of zero true",
      BossExecution.HasAttemptsRemaining(0,0),true);
}

//+------------------------------------------------------------------+
//| Block 3 retry decision tests                                     |
//+------------------------------------------------------------------+
void TestShouldRetryResult()
{
   S_BossR_ExecutionResult result;

   BossExecution.ResetResult(result);

   ExpectBool("Retry reset false",
      BossExecution.ShouldRetryResult(result,3),false);

   BossExecution.SetSuccessResult(
      result,12345,1,1.10020,1.10021);

   ExpectBool("Retry success false",
      BossExecution.ShouldRetryResult(result,3),false);

   BossExecution.SetFailureResult(
      result,
      BOSSR_EXECUTION_REJECT_PREFLIGHT,
      0,
      1.10020);

   ExpectBool("Retry local reject false",
      BossExecution.ShouldRetryResult(result,3),false);

   BossExecution.SetFailureResult(
      result,130,1,1.10020);

   ExpectBool("Retry hard error false",
      BossExecution.ShouldRetryResult(result,3),false);

   BossExecution.SetFailureResult(
      result,138,1,1.10020);

   ExpectBool("Retry requote first true",
      BossExecution.ShouldRetryResult(result,3),true);

   BossExecution.SetFailureResult(
      result,138,2,1.10020);

   ExpectBool("Retry requote second true",
      BossExecution.ShouldRetryResult(result,3),true);

   BossExecution.SetFailureResult(
      result,138,3,1.10020);

   ExpectBool("Retry requote exhausted false",
      BossExecution.ShouldRetryResult(result,3),false);

   BossExecution.SetFailureResult(
      result,146,9,1.10020);

   ExpectBool("Retry context busy nine of ten true",
      BossExecution.ShouldRetryResult(result,50),true);

   BossExecution.SetFailureResult(
      result,146,10,1.10020);

   ExpectBool("Retry context busy ten exhausted false",
      BossExecution.ShouldRetryResult(result,50),false);
}

//+------------------------------------------------------------------+
//| Block 3 next-attempt and exhaustion tests                        |
//+------------------------------------------------------------------+
void TestRetryPolicyState()
{
   S_BossR_ExecutionResult result;

   BossExecution.ResetResult(result);

   ExpectInt("Next attempt reset one",
      BossExecution.NextAttemptNumber(result),1);

   result.attempts = -5;

   ExpectInt("Next attempt negative one",
      BossExecution.NextAttemptNumber(result),1);

   result.attempts = 0;

   ExpectInt("Next attempt zero one",
      BossExecution.NextAttemptNumber(result),1);

   result.attempts = 1;

   ExpectInt("Next attempt one two",
      BossExecution.NextAttemptNumber(result),2);

   result.attempts = 9;

   ExpectInt("Next attempt nine ten",
      BossExecution.NextAttemptNumber(result),10);

   BossExecution.SetFailureResult(
      result,138,1,1.10020);

   ExpectBool("Policy first not exhausted",
      BossExecution.IsRetryPolicyExhausted(result,3),false);

   BossExecution.SetFailureResult(
      result,138,2,1.10020);

   ExpectBool("Policy second not exhausted",
      BossExecution.IsRetryPolicyExhausted(result,3),false);

   BossExecution.SetFailureResult(
      result,138,3,1.10020);

   ExpectBool("Policy third exhausted",
      BossExecution.IsRetryPolicyExhausted(result,3),true);

   BossExecution.SetFailureResult(
      result,130,3,1.10020);

   ExpectBool("Policy hard error not retry-exhausted",
      BossExecution.IsRetryPolicyExhausted(result,3),false);

   BossExecution.SetFailureResult(
      result,
      BOSSR_EXECUTION_REJECT_STOPS,
      0,
      1.10020);

   ExpectBool("Policy local reject not retry-exhausted",
      BossExecution.IsRetryPolicyExhausted(result,3),false);

   BossExecution.SetSuccessResult(
      result,12345,3,1.10020,1.10021);

   ExpectBool("Policy success not exhausted",
      BossExecution.IsRetryPolicyExhausted(result,3),false);

   BossExecution.ResetResult(result);

   ExpectBool("Policy reset not exhausted",
      BossExecution.IsRetryPolicyExhausted(result,3),false);
}


//+------------------------------------------------------------------+
//| Block 4 market-price refresh tests                               |
//+------------------------------------------------------------------+
void TestRefreshMarketRequestPrice()
{
   S_BossR_ExecutionRequest request;

   BossExecution.BuildMarketRequest(
      request,"EURUSD",OP_BUY,0.10,
      1.10020,1.10000,3,
      0.0,0.0,
      "BossR",260713);

   ExpectBool("Refresh BUY price true",
      BossExecution.RefreshMarketRequestPrice(
         request,1.10120,1.10100),true);

   ExpectDouble("Refresh BUY uses Ask",
      request.price,1.10120);

   request.order_type = OP_SELL;

   ExpectBool("Refresh SELL price true",
      BossExecution.RefreshMarketRequestPrice(
         request,1.10220,1.10200),true);

   ExpectDouble("Refresh SELL uses Bid",
      request.price,1.10200);

   request.order_type = OP_BUYSTOP;

   ExpectBool("Refresh pending false",
      BossExecution.RefreshMarketRequestPrice(
         request,1.10320,1.10300),false);

   request.order_type = OP_BUY;
   request.price = 7.0;

   ExpectBool("Refresh crossed market false",
      BossExecution.RefreshMarketRequestPrice(
         request,1.09990,1.10000),false);

   ExpectDouble("Refresh failure preserves prior price",
      request.price,7.0);
}

//+------------------------------------------------------------------+
//| Block 4 retry-executor consistency tests                         |
//+------------------------------------------------------------------+
void TestRetryExecutorConsistency()
{
   S_BossR_ExecutionResult result;

   BossExecution.ResetResult(result);

   ExpectBool("Consistency reset true",
      BossExecution.IsRetryExecutorResultConsistent(
         result,3),true);

   BossExecution.SetSuccessResult(
      result,12345,1,1.10020,1.10021);

   ExpectBool("Consistency success true",
      BossExecution.IsRetryExecutorResultConsistent(
         result,3),true);

   BossExecution.SetSuccessResult(
      result,12345,4,1.10020,1.10021);

   ExpectBool("Consistency success over cap false",
      BossExecution.IsRetryExecutorResultConsistent(
         result,3),false);

   BossExecution.SetFailureResult(
      result,
      BOSSR_EXECUTION_REJECT_STOPS,
      0,
      1.10020);

   ExpectBool("Consistency local reject true",
      BossExecution.IsRetryExecutorResultConsistent(
         result,3),true);

   BossExecution.SetFailureResult(
      result,
      BOSSR_EXECUTION_REJECT_STOPS,
      1,
      1.10020);

   ExpectBool("Consistency local reject one attempt false",
      BossExecution.IsRetryExecutorResultConsistent(
         result,3),false);

   BossExecution.SetFailureResult(
      result,138,1,1.10020);

   ExpectBool("Consistency broker failure true",
      BossExecution.IsRetryExecutorResultConsistent(
         result,3),true);

   BossExecution.SetFailureResult(
      result,138,3,1.10020);

   ExpectBool("Consistency broker failure at cap true",
      BossExecution.IsRetryExecutorResultConsistent(
         result,3),true);

   BossExecution.SetFailureResult(
      result,138,4,1.10020);

   ExpectBool("Consistency broker failure over cap false",
      BossExecution.IsRetryExecutorResultConsistent(
         result,3),false);

   result.attempted = true;
   result.succeeded = false;
   result.ticket = -1;
   result.error_code = 0;
   result.attempts = 0;
   result.requested_price = 1.10020;
   result.executed_price = 0.0;

   ExpectBool("Consistency attempted no route false",
      BossExecution.IsRetryExecutorResultConsistent(
         result,3),false);
}

//+------------------------------------------------------------------+
//| Block 4 live-function safe rejection tests                       |
//| These cannot reach OrderSend because the request is non-market.  |
//+------------------------------------------------------------------+
void TestExecuteMarketWithRetrySafeReject()
{
   S_BossR_ExecutionRequest request;
   S_BossR_ExecutionResult result;

   BossExecution.BuildMarketRequest(
      request,"EURUSD",OP_BUY,0.10,
      1.10020,1.10000,3,
      0.0,0.0,
      "BossR",260713);

   request.order_type = OP_BUYSTOP;

   ExpectBool("Retry executor non-market false",
      BossExecution.ExecuteMarketWithRetry(
         request,
         result,
         0.01,100.0,0.01,
         0.00001,30.0,50.0,
         3),false);

   ExpectBool("Retry executor rejected attempted true",
      result.attempted,true);

   ExpectBool("Retry executor rejected success false",
      result.succeeded,false);

   ExpectInt("Retry executor rejected attempts zero",
      result.attempts,0);

   ExpectInt("Retry executor rejected code preflight",
      result.error_code,
      BOSSR_EXECUTION_REJECT_PREFLIGHT);

   ExpectBool("Retry executor rejected before send true",
      BossExecution.WasRejectedBeforeSend(result),true);

   ExpectBool("Retry executor rejected broker send false",
      BossExecution.WasBrokerSendAttempted(result),false);

   ExpectBool("Retry executor rejection consistent",
      BossExecution.IsRetryExecutorResultConsistent(
         result,3),true);
}

//+------------------------------------------------------------------+
//| Block 4 cap consistency tests                                    |
//+------------------------------------------------------------------+
void TestRetryExecutorCapSemantics()
{
   S_BossR_ExecutionResult result;

   BossExecution.SetFailureResult(
      result,138,1,1.10020);

   ExpectBool("Cap zero consistency attempt one true",
      BossExecution.IsRetryExecutorResultConsistent(
         result,0),true);

   BossExecution.SetFailureResult(
      result,138,2,1.10020);

   ExpectBool("Cap zero consistency attempt two false",
      BossExecution.IsRetryExecutorResultConsistent(
         result,0),false);

   BossExecution.SetFailureResult(
      result,138,10,1.10020);

   ExpectBool("Cap huge consistency ten true",
      BossExecution.IsRetryExecutorResultConsistent(
         result,100),true);

   BossExecution.SetFailureResult(
      result,138,11,1.10020);

   ExpectBool("Cap huge consistency eleven false",
      BossExecution.IsRetryExecutorResultConsistent(
         result,100),false);
}


//+------------------------------------------------------------------+
//| Block 5 close request validation tests                           |
//+------------------------------------------------------------------+
void TestCloseRequestValidation()
{
   ExpectBool("Close request valid",
      BossExecution.IsCloseRequestValid(
         12345,0.10,1.10000,3),true);

   ExpectBool("Close ticket zero false",
      BossExecution.IsCloseRequestValid(
         0,0.10,1.10000,3),false);

   ExpectBool("Close ticket negative false",
      BossExecution.IsCloseRequestValid(
         -1,0.10,1.10000,3),false);

   ExpectBool("Close lots zero false",
      BossExecution.IsCloseRequestValid(
         12345,0.0,1.10000,3),false);

   ExpectBool("Close lots negative false",
      BossExecution.IsCloseRequestValid(
         12345,-0.10,1.10000,3),false);

   ExpectBool("Close price zero false",
      BossExecution.IsCloseRequestValid(
         12345,0.10,0.0,3),false);

   ExpectBool("Close price negative false",
      BossExecution.IsCloseRequestValid(
         12345,0.10,-1.0,3),false);

   ExpectBool("Close slippage negative false",
      BossExecution.IsCloseRequestValid(
         12345,0.10,1.10000,-1),false);
}

//+------------------------------------------------------------------+
//| Block 5 delete request validation tests                          |
//+------------------------------------------------------------------+
void TestDeleteRequestValidation()
{
   ExpectBool("Delete ticket valid",
      BossExecution.IsDeleteRequestValid(1),true);

   ExpectBool("Delete ticket high valid",
      BossExecution.IsDeleteRequestValid(999999),true);

   ExpectBool("Delete ticket zero false",
      BossExecution.IsDeleteRequestValid(0),false);

   ExpectBool("Delete ticket negative false",
      BossExecution.IsDeleteRequestValid(-1),false);
}

//+------------------------------------------------------------------+
//| Block 5 safe close rejection tests                               |
//| Invalid inputs stop before OrderClose.                           |
//+------------------------------------------------------------------+
void TestCloseOrderOnceSafeReject()
{
   S_BossR_ExecutionResult result;

   ExpectBool("Close invalid ticket false",
      BossExecution.CloseOrderOnce(
         0,0.10,1.10000,3,CLR_NONE,result),false);

   ExpectBool("Close reject attempted true",
      result.attempted,true);

   ExpectBool("Close reject succeeded false",
      result.succeeded,false);

   ExpectInt("Close reject ticket",
      result.ticket,-1);

   ExpectInt("Close reject code",
      result.error_code,
      BOSSR_EXECUTION_REJECT_STRUCTURE);

   ExpectInt("Close reject attempts zero",
      result.attempts,0);

   ExpectDouble("Close reject requested price",
      result.requested_price,1.10000);

   ExpectDouble("Close reject executed zero",
      result.executed_price,0.0);

   ExpectBool("Close reject before broker call",
      BossExecution.WasRejectedBeforeSend(result),true);

   ExpectBool("Close reject result consistent",
      BossExecution.IsCloseResultConsistent(result),true);

   ExpectBool("Close invalid lots false",
      BossExecution.CloseOrderOnce(
         12345,0.0,1.10000,3,CLR_NONE,result),false);

   ExpectInt("Close invalid lots code",
      result.error_code,
      BOSSR_EXECUTION_REJECT_STRUCTURE);

   ExpectBool("Close invalid price false",
      BossExecution.CloseOrderOnce(
         12345,0.10,0.0,3,CLR_NONE,result),false);

   ExpectBool("Close invalid slippage false",
      BossExecution.CloseOrderOnce(
         12345,0.10,1.10000,-1,CLR_NONE,result),false);
}

//+------------------------------------------------------------------+
//| Block 5 safe delete rejection tests                              |
//| Invalid inputs stop before OrderDelete.                          |
//+------------------------------------------------------------------+
void TestDeleteOrderOnceSafeReject()
{
   S_BossR_ExecutionResult result;

   ExpectBool("Delete invalid ticket false",
      BossExecution.DeleteOrderOnce(
         0,CLR_NONE,result),false);

   ExpectBool("Delete reject attempted true",
      result.attempted,true);

   ExpectBool("Delete reject succeeded false",
      result.succeeded,false);

   ExpectInt("Delete reject ticket",
      result.ticket,-1);

   ExpectInt("Delete reject code",
      result.error_code,
      BOSSR_EXECUTION_REJECT_STRUCTURE);

   ExpectInt("Delete reject attempts zero",
      result.attempts,0);

   ExpectDouble("Delete reject requested zero",
      result.requested_price,0.0);

   ExpectDouble("Delete reject executed zero",
      result.executed_price,0.0);

   ExpectBool("Delete reject before broker call",
      BossExecution.WasRejectedBeforeSend(result),true);

   ExpectBool("Delete reject result consistent",
      BossExecution.IsDeleteResultConsistent(result),true);
}

//+------------------------------------------------------------------+
//| Block 5 close-result consistency tests                           |
//+------------------------------------------------------------------+
void TestCloseResultConsistency()
{
   S_BossR_ExecutionResult result;

   BossExecution.ResetResult(result);

   ExpectBool("Close consistency reset true",
      BossExecution.IsCloseResultConsistent(result),true);

   BossExecution.SetFailureResult(
      result,
      BOSSR_EXECUTION_REJECT_STRUCTURE,
      0,
      1.10000);

   ExpectBool("Close consistency local reject true",
      BossExecution.IsCloseResultConsistent(result),true);

   BossExecution.SetFailureResult(
      result,
      BOSSR_EXECUTION_REJECT_STRUCTURE,
      1,
      1.10000);

   ExpectBool("Close consistency local reject attempt false",
      BossExecution.IsCloseResultConsistent(result),false);

   BossExecution.SetFailureResult(
      result,
      146,
      1,
      1.10000);

   ExpectBool("Close consistency broker failure true",
      BossExecution.IsCloseResultConsistent(result),true);

   BossExecution.SetFailureResult(
      result,
      146,
      2,
      1.10000);

   ExpectBool("Close consistency broker failure two false",
      BossExecution.IsCloseResultConsistent(result),false);

   BossExecution.SetSuccessResult(
      result,
      12345,
      1,
      1.10000,
      1.10000);

   ExpectBool("Close consistency success true",
      BossExecution.IsCloseResultConsistent(result),true);

   BossExecution.SetSuccessResult(
      result,
      12345,
      2,
      1.10000,
      1.10000);

   ExpectBool("Close consistency success two false",
      BossExecution.IsCloseResultConsistent(result),false);

   BossExecution.SetSuccessResult(
      result,
      12345,
      1,
      0.0,
      0.0);

   ExpectBool("Close consistency zero prices false",
      BossExecution.IsCloseResultConsistent(result),false);
}

//+------------------------------------------------------------------+
//| Block 5 delete-result consistency tests                          |
//+------------------------------------------------------------------+
void TestDeleteResultConsistency()
{
   S_BossR_ExecutionResult result;

   BossExecution.ResetResult(result);

   ExpectBool("Delete consistency reset true",
      BossExecution.IsDeleteResultConsistent(result),true);

   BossExecution.SetFailureResult(
      result,
      BOSSR_EXECUTION_REJECT_STRUCTURE,
      0,
      0.0);

   ExpectBool("Delete consistency local reject true",
      BossExecution.IsDeleteResultConsistent(result),true);

   BossExecution.SetFailureResult(
      result,
      130,
      1,
      0.0);

   ExpectBool("Delete consistency broker failure true",
      BossExecution.IsDeleteResultConsistent(result),true);

   BossExecution.SetFailureResult(
      result,
      130,
      2,
      0.0);

   ExpectBool("Delete consistency broker failure two false",
      BossExecution.IsDeleteResultConsistent(result),false);

   BossExecution.SetSuccessResult(
      result,
      12345,
      1,
      0.0,
      0.0);

   ExpectBool("Delete consistency success true",
      BossExecution.IsDeleteResultConsistent(result),true);

   BossExecution.SetSuccessResult(
      result,
      12345,
      1,
      1.10000,
      0.0);

   ExpectBool("Delete consistency requested nonzero false",
      BossExecution.IsDeleteResultConsistent(result),false);

   BossExecution.SetSuccessResult(
      result,
      12345,
      1,
      0.0,
      1.10000);

   ExpectBool("Delete consistency executed nonzero false",
      BossExecution.IsDeleteResultConsistent(result),false);
}


//+------------------------------------------------------------------+
//| Block 6 modify request validation tests                          |
//+------------------------------------------------------------------+
void TestModifyRequestValidation()
{
   ExpectBool("Modify request valid all zero optional",
      BossExecution.IsModifyRequestValid(
         12345,0.0,0.0,0.0,0),true);

   ExpectBool("Modify request valid values",
      BossExecution.IsModifyRequestValid(
         12345,1.10000,1.09000,1.11000,2000000000),true);

   ExpectBool("Modify ticket zero false",
      BossExecution.IsModifyRequestValid(
         0,1.10000,0.0,0.0,0),false);

   ExpectBool("Modify ticket negative false",
      BossExecution.IsModifyRequestValid(
         -1,1.10000,0.0,0.0,0),false);

   ExpectBool("Modify price negative false",
      BossExecution.IsModifyRequestValid(
         12345,-1.0,0.0,0.0,0),false);

   ExpectBool("Modify SL negative false",
      BossExecution.IsModifyRequestValid(
         12345,1.10000,-1.0,0.0,0),false);

   ExpectBool("Modify TP negative false",
      BossExecution.IsModifyRequestValid(
         12345,1.10000,0.0,-1.0,0),false);

   ExpectBool("Modify expiration negative false",
      BossExecution.IsModifyRequestValid(
         12345,1.10000,0.0,0.0,(datetime)-1),false);
}

//+------------------------------------------------------------------+
//| Block 6 safe modify rejection tests                              |
//| Invalid inputs stop before OrderModify.                          |
//+------------------------------------------------------------------+
void TestModifyOrderOnceSafeReject()
{
   S_BossR_ExecutionResult result;

   ExpectBool("Modify invalid ticket false",
      BossExecution.ModifyOrderOnce(
         0,
         1.10000,
         1.09000,
         1.11000,
         0,
         CLR_NONE,
         result),false);

   ExpectBool("Modify reject attempted true",
      result.attempted,true);

   ExpectBool("Modify reject succeeded false",
      result.succeeded,false);

   ExpectInt("Modify reject ticket",
      result.ticket,-1);

   ExpectInt("Modify reject code",
      result.error_code,
      BOSSR_EXECUTION_REJECT_STRUCTURE);

   ExpectInt("Modify reject attempts zero",
      result.attempts,0);

   ExpectDouble("Modify reject requested price",
      result.requested_price,1.10000);

   ExpectDouble("Modify reject executed zero",
      result.executed_price,0.0);

   ExpectBool("Modify reject before broker call",
      BossExecution.WasRejectedBeforeSend(result),true);

   ExpectBool("Modify reject result consistent",
      BossExecution.IsModifyResultConsistent(result),true);

   ExpectBool("Modify negative price false",
      BossExecution.ModifyOrderOnce(
         12345,
         -1.0,
         0.0,
         0.0,
         0,
         CLR_NONE,
         result),false);

   ExpectInt("Modify negative price reject code",
      result.error_code,
      BOSSR_EXECUTION_REJECT_STRUCTURE);

   ExpectBool("Modify negative SL false",
      BossExecution.ModifyOrderOnce(
         12345,
         1.10000,
         -1.0,
         0.0,
         0,
         CLR_NONE,
         result),false);

   ExpectBool("Modify negative TP false",
      BossExecution.ModifyOrderOnce(
         12345,
         1.10000,
         0.0,
         -1.0,
         0,
         CLR_NONE,
         result),false);

   ExpectBool("Modify negative expiration false",
      BossExecution.ModifyOrderOnce(
         12345,
         1.10000,
         0.0,
         0.0,
         (datetime)-1,
         CLR_NONE,
         result),false);
}

//+------------------------------------------------------------------+
//| Block 6 modify-result consistency tests                          |
//+------------------------------------------------------------------+
void TestModifyResultConsistency()
{
   S_BossR_ExecutionResult result;

   BossExecution.ResetResult(result);

   ExpectBool("Modify consistency reset true",
      BossExecution.IsModifyResultConsistent(result),true);

   BossExecution.SetFailureResult(
      result,
      BOSSR_EXECUTION_REJECT_STRUCTURE,
      0,
      1.10000);

   ExpectBool("Modify consistency local reject true",
      BossExecution.IsModifyResultConsistent(result),true);

   BossExecution.SetFailureResult(
      result,
      BOSSR_EXECUTION_REJECT_STRUCTURE,
      1,
      1.10000);

   ExpectBool("Modify consistency local reject attempt false",
      BossExecution.IsModifyResultConsistent(result),false);

   BossExecution.SetFailureResult(
      result,
      146,
      1,
      1.10000);

   ExpectBool("Modify consistency broker failure true",
      BossExecution.IsModifyResultConsistent(result),true);

   BossExecution.SetFailureResult(
      result,
      146,
      2,
      1.10000);

   ExpectBool("Modify consistency broker failure two false",
      BossExecution.IsModifyResultConsistent(result),false);

   BossExecution.SetSuccessResult(
      result,
      12345,
      1,
      1.10000,
      1.10000);

   ExpectBool("Modify consistency success true",
      BossExecution.IsModifyResultConsistent(result),true);

   BossExecution.SetSuccessResult(
      result,
      12345,
      2,
      1.10000,
      1.10000);

   ExpectBool("Modify consistency success two false",
      BossExecution.IsModifyResultConsistent(result),false);

   BossExecution.SetSuccessResult(
      result,
      12345,
      1,
      1.10000,
      1.10001);

   ExpectBool("Modify consistency executed mismatch false",
      BossExecution.IsModifyResultConsistent(result),false);

   BossExecution.SetSuccessResult(
      result,
      12345,
      1,
      0.0,
      0.0);

   ExpectBool("Modify consistency zero price success true",
      BossExecution.IsModifyResultConsistent(result),true);
}

//+------------------------------------------------------------------+
//| Block 6 no-op modify tests                                       |
//+------------------------------------------------------------------+
void TestNoOpModifySemantics()
{
   ExpectBool("No price change exact true",
      BossExecution.IsNoPriceChangeModify(
         1.10000,1.10000),true);

   ExpectBool("No price change epsilon true",
      BossExecution.IsNoPriceChangeModify(
         1.10000,1.1000000000005),true);

   ExpectBool("Price change false",
      BossExecution.IsNoPriceChangeModify(
         1.10000,1.10010),false);

   ExpectBool("No stop change exact true",
      BossExecution.IsNoStopChangeModify(
         1.09000,1.11000,
         1.09000,1.11000),true);

   ExpectBool("SL changed false",
      BossExecution.IsNoStopChangeModify(
         1.09000,1.11000,
         1.09100,1.11000),false);

   ExpectBool("TP changed false",
      BossExecution.IsNoStopChangeModify(
         1.09000,1.11000,
         1.09000,1.11100),false);

   ExpectBool("Expiration unchanged true",
      BossExecution.IsNoExpirationChangeModify(
         1000,1000),true);

   ExpectBool("Expiration changed false",
      BossExecution.IsNoExpirationChangeModify(
         1000,1001),false);

   ExpectBool("No-op modify exact true",
      BossExecution.IsNoOpModify(
         1.10000,
         1.09000,
         1.11000,
         1000,
         1.10000,
         1.09000,
         1.11000,
         1000),true);

   ExpectBool("No-op modify price changed false",
      BossExecution.IsNoOpModify(
         1.10000,
         1.09000,
         1.11000,
         1000,
         1.10010,
         1.09000,
         1.11000,
         1000),false);

   ExpectBool("No-op modify SL changed false",
      BossExecution.IsNoOpModify(
         1.10000,
         1.09000,
         1.11000,
         1000,
         1.10000,
         1.09100,
         1.11000,
         1000),false);

   ExpectBool("No-op modify TP changed false",
      BossExecution.IsNoOpModify(
         1.10000,
         1.09000,
         1.11000,
         1000,
         1.10000,
         1.09000,
         1.11100,
         1000),false);

   ExpectBool("No-op modify expiration changed false",
      BossExecution.IsNoOpModify(
         1.10000,
         1.09000,
         1.11000,
         1000,
         1.10000,
         1.09000,
         1.11000,
         1001),false);

   ExpectBool("No-op modify all zero true",
      BossExecution.IsNoOpModify(
         0.0,0.0,0.0,0,
         0.0,0.0,0.0,0),true);
}


//+------------------------------------------------------------------+
//| Block 7 close-price refresh tests                                |
//+------------------------------------------------------------------+
void TestRefreshClosePrice()
{
   double close_price = 7.0;

   ExpectBool("Refresh close empty symbol false",
      BossExecution.RefreshClosePrice(
         OP_BUY,"",close_price),false);

   ExpectDouble("Refresh close empty preserves",
      close_price,7.0);

   close_price = 8.0;

   ExpectBool("Refresh close pending false",
      BossExecution.RefreshClosePrice(
         OP_BUYSTOP,Symbol(),close_price),false);

   ExpectDouble("Refresh close pending preserves",
      close_price,8.0);

   double bid_price = MarketInfo(Symbol(),MODE_BID);
   double ask_price = MarketInfo(Symbol(),MODE_ASK);

   ExpectBool("Refresh close BUY true",
      BossExecution.RefreshClosePrice(
         OP_BUY,Symbol(),close_price),true);

   ExpectDouble("Refresh close BUY uses Bid",
      close_price,bid_price,0.0000001);

   ExpectBool("Refresh close SELL true",
      BossExecution.RefreshClosePrice(
         OP_SELL,Symbol(),close_price),true);

   ExpectDouble("Refresh close SELL uses Ask",
      close_price,ask_price,0.0000001);
}

//+------------------------------------------------------------------+
//| Block 7 safe close retry rejection tests                         |
//| Invalid structure stops before OrderClose.                       |
//+------------------------------------------------------------------+
void TestExecuteCloseWithRetrySafeReject()
{
   S_BossR_ExecutionResult result;

   ExpectBool("Close retry invalid ticket false",
      BossExecution.ExecuteCloseWithRetry(
         0,
         OP_BUY,
         Symbol(),
         0.10,
         3,
         CLR_NONE,
         3,
         result),false);

   ExpectInt("Close retry invalid ticket code",
      result.error_code,
      BOSSR_EXECUTION_REJECT_STRUCTURE);

   ExpectInt("Close retry invalid ticket attempts zero",
      result.attempts,0);

   ExpectBool("Close retry invalid ticket consistent",
      BossExecution.IsActionRetryResultConsistent(
         result,3),true);

   ExpectBool("Close retry invalid type false",
      BossExecution.ExecuteCloseWithRetry(
         12345,
         OP_BUYSTOP,
         Symbol(),
         0.10,
         3,
         CLR_NONE,
         3,
         result),false);

   ExpectInt("Close retry invalid type code",
      result.error_code,
      BOSSR_EXECUTION_REJECT_STRUCTURE);

   ExpectBool("Close retry empty symbol false",
      BossExecution.ExecuteCloseWithRetry(
         12345,
         OP_BUY,
         "",
         0.10,
         3,
         CLR_NONE,
         3,
         result),false);

   ExpectBool("Close retry zero lots false",
      BossExecution.ExecuteCloseWithRetry(
         12345,
         OP_BUY,
         Symbol(),
         0.0,
         3,
         CLR_NONE,
         3,
         result),false);

   ExpectBool("Close retry negative slippage false",
      BossExecution.ExecuteCloseWithRetry(
         12345,
         OP_BUY,
         Symbol(),
         0.10,
         -1,
         CLR_NONE,
         3,
         result),false);
}

//+------------------------------------------------------------------+
//| Block 7 safe delete retry rejection tests                        |
//+------------------------------------------------------------------+
void TestExecuteDeleteWithRetrySafeReject()
{
   S_BossR_ExecutionResult result;

   ExpectBool("Delete retry invalid ticket false",
      BossExecution.ExecuteDeleteWithRetry(
         0,
         CLR_NONE,
         3,
         result),false);

   ExpectBool("Delete retry reject attempted true",
      result.attempted,true);

   ExpectInt("Delete retry reject code",
      result.error_code,
      BOSSR_EXECUTION_REJECT_STRUCTURE);

   ExpectInt("Delete retry reject attempts zero",
      result.attempts,0);

   ExpectBool("Delete retry reject consistent",
      BossExecution.IsActionRetryResultConsistent(
         result,3),true);
}

//+------------------------------------------------------------------+
//| Block 7 safe modify retry rejection tests                        |
//+------------------------------------------------------------------+
void TestExecuteModifyWithRetrySafeReject()
{
   S_BossR_ExecutionResult result;

   ExpectBool("Modify retry invalid ticket false",
      BossExecution.ExecuteModifyWithRetry(
         0,
         1.10000,
         1.09000,
         1.11000,
         0,
         CLR_NONE,
         3,
         result),false);

   ExpectInt("Modify retry invalid ticket code",
      result.error_code,
      BOSSR_EXECUTION_REJECT_STRUCTURE);

   ExpectInt("Modify retry invalid ticket attempts zero",
      result.attempts,0);

   ExpectBool("Modify retry invalid ticket consistent",
      BossExecution.IsActionRetryResultConsistent(
         result,3),true);

   ExpectBool("Modify retry negative price false",
      BossExecution.ExecuteModifyWithRetry(
         12345,
         -1.0,
         0.0,
         0.0,
         0,
         CLR_NONE,
         3,
         result),false);

   ExpectBool("Modify retry negative SL false",
      BossExecution.ExecuteModifyWithRetry(
         12345,
         1.10000,
         -1.0,
         0.0,
         0,
         CLR_NONE,
         3,
         result),false);

   ExpectBool("Modify retry negative TP false",
      BossExecution.ExecuteModifyWithRetry(
         12345,
         1.10000,
         0.0,
         -1.0,
         0,
         CLR_NONE,
         3,
         result),false);
}

//+------------------------------------------------------------------+
//| Block 7 action-retry consistency tests                           |
//+------------------------------------------------------------------+
void TestActionRetryResultConsistency()
{
   S_BossR_ExecutionResult result;

   BossExecution.ResetResult(result);

   ExpectBool("Action retry consistency reset true",
      BossExecution.IsActionRetryResultConsistent(
         result,3),true);

   BossExecution.SetFailureResult(
      result,
      BOSSR_EXECUTION_REJECT_STRUCTURE,
      0,
      0.0);

   ExpectBool("Action retry consistency local reject true",
      BossExecution.IsActionRetryResultConsistent(
         result,3),true);

   BossExecution.SetFailureResult(
      result,
      BOSSR_EXECUTION_REJECT_STRUCTURE,
      1,
      0.0);

   ExpectBool("Action retry consistency local reject attempt false",
      BossExecution.IsActionRetryResultConsistent(
         result,3),false);

   BossExecution.SetFailureResult(
      result,
      138,
      1,
      1.10000);

   ExpectBool("Action retry consistency failure one true",
      BossExecution.IsActionRetryResultConsistent(
         result,3),true);

   BossExecution.SetFailureResult(
      result,
      138,
      3,
      1.10000);

   ExpectBool("Action retry consistency failure at cap true",
      BossExecution.IsActionRetryResultConsistent(
         result,3),true);

   BossExecution.SetFailureResult(
      result,
      138,
      4,
      1.10000);

   ExpectBool("Action retry consistency failure over cap false",
      BossExecution.IsActionRetryResultConsistent(
         result,3),false);

   BossExecution.SetSuccessResult(
      result,
      12345,
      1,
      1.10000,
      1.10000);

   ExpectBool("Action retry consistency success one true",
      BossExecution.IsActionRetryResultConsistent(
         result,3),true);

   BossExecution.SetSuccessResult(
      result,
      12345,
      3,
      1.10000,
      1.10000);

   ExpectBool("Action retry consistency success at cap true",
      BossExecution.IsActionRetryResultConsistent(
         result,3),true);

   BossExecution.SetSuccessResult(
      result,
      12345,
      4,
      1.10000,
      1.10000);

   ExpectBool("Action retry consistency success over cap false",
      BossExecution.IsActionRetryResultConsistent(
         result,3),false);

   BossExecution.SetFailureResult(
      result,
      138,
      10,
      1.10000);

   ExpectBool("Action retry huge max clamps ten true",
      BossExecution.IsActionRetryResultConsistent(
         result,100),true);

   BossExecution.SetFailureResult(
      result,
      138,
      11,
      1.10000);

   ExpectBool("Action retry huge max eleven false",
      BossExecution.IsActionRetryResultConsistent(
         result,100),false);
}


//+------------------------------------------------------------------+
//| Block 8 action classification tests                              |
//+------------------------------------------------------------------+
void TestExecutionActionClassification()
{
   ExpectBool("Action NONE invalid",
      BossExecution.IsExecutionActionValid(
         BOSSR_EXECUTION_ACTION_NONE),false);

   ExpectBool("Action SEND valid",
      BossExecution.IsExecutionActionValid(
         BOSSR_EXECUTION_ACTION_SEND),true);

   ExpectBool("Action CLOSE valid",
      BossExecution.IsExecutionActionValid(
         BOSSR_EXECUTION_ACTION_CLOSE),true);

   ExpectBool("Action DELETE valid",
      BossExecution.IsExecutionActionValid(
         BOSSR_EXECUTION_ACTION_DELETE),true);

   ExpectBool("Action MODIFY valid",
      BossExecution.IsExecutionActionValid(
         BOSSR_EXECUTION_ACTION_MODIFY),true);

   ExpectBool("Action random invalid",
      BossExecution.IsExecutionActionValid(99),false);

   ExpectBool("SEND opening true",
      BossExecution.IsExecutionActionTradeOpening(
         BOSSR_EXECUTION_ACTION_SEND),true);

   ExpectBool("CLOSE opening false",
      BossExecution.IsExecutionActionTradeOpening(
         BOSSR_EXECUTION_ACTION_CLOSE),false);

   ExpectBool("CLOSE closing true",
      BossExecution.IsExecutionActionTradeClosing(
         BOSSR_EXECUTION_ACTION_CLOSE),true);

   ExpectBool("DELETE closing true",
      BossExecution.IsExecutionActionTradeClosing(
         BOSSR_EXECUTION_ACTION_DELETE),true);

   ExpectBool("MODIFY closing false",
      BossExecution.IsExecutionActionTradeClosing(
         BOSSR_EXECUTION_ACTION_MODIFY),false);

   ExpectBool("SEND mutation true",
      BossExecution.IsExecutionActionMutation(
         BOSSR_EXECUTION_ACTION_SEND),true);

   ExpectBool("CLOSE mutation true",
      BossExecution.IsExecutionActionMutation(
         BOSSR_EXECUTION_ACTION_CLOSE),true);

   ExpectBool("DELETE mutation true",
      BossExecution.IsExecutionActionMutation(
         BOSSR_EXECUTION_ACTION_DELETE),true);

   ExpectBool("MODIFY mutation true",
      BossExecution.IsExecutionActionMutation(
         BOSSR_EXECUTION_ACTION_MODIFY),true);

   ExpectBool("NONE mutation false",
      BossExecution.IsExecutionActionMutation(
         BOSSR_EXECUTION_ACTION_NONE),false);
}

//+------------------------------------------------------------------+
//| Block 8 unified result consistency tests                         |
//+------------------------------------------------------------------+
void TestUnifiedResultConsistency()
{
   S_BossR_ExecutionResult result;

   BossExecution.ResetResult(result);

   ExpectBool("Unified SEND reset true",
      BossExecution.IsUnifiedResultConsistent(
         BOSSR_EXECUTION_ACTION_SEND,
         result,
         3),true);

   ExpectBool("Unified CLOSE reset true",
      BossExecution.IsUnifiedResultConsistent(
         BOSSR_EXECUTION_ACTION_CLOSE,
         result,
         3),true);

   ExpectBool("Unified DELETE reset true",
      BossExecution.IsUnifiedResultConsistent(
         BOSSR_EXECUTION_ACTION_DELETE,
         result,
         3),true);

   ExpectBool("Unified MODIFY reset true",
      BossExecution.IsUnifiedResultConsistent(
         BOSSR_EXECUTION_ACTION_MODIFY,
         result,
         3),true);

   ExpectBool("Unified NONE false",
      BossExecution.IsUnifiedResultConsistent(
         BOSSR_EXECUTION_ACTION_NONE,
         result,
         3),false);

   BossExecution.SetFailureResult(
      result,
      BOSSR_EXECUTION_REJECT_STRUCTURE,
      0,
      0.0);

   ExpectBool("Unified SEND local reject true",
      BossExecution.IsUnifiedResultConsistent(
         BOSSR_EXECUTION_ACTION_SEND,
         result,
         3),true);

   ExpectBool("Unified MODIFY local reject true",
      BossExecution.IsUnifiedResultConsistent(
         BOSSR_EXECUTION_ACTION_MODIFY,
         result,
         3),true);

   BossExecution.SetFailureResult(
      result,
      138,
      3,
      1.10000);

   ExpectBool("Unified SEND broker failure true",
      BossExecution.IsUnifiedResultConsistent(
         BOSSR_EXECUTION_ACTION_SEND,
         result,
         3),true);

   ExpectBool("Unified CLOSE broker failure true",
      BossExecution.IsUnifiedResultConsistent(
         BOSSR_EXECUTION_ACTION_CLOSE,
         result,
         3),true);

   BossExecution.SetSuccessResult(
      result,
      12345,
      1,
      1.10000,
      1.10000);

   ExpectBool("Unified SEND success true",
      BossExecution.IsUnifiedResultConsistent(
         BOSSR_EXECUTION_ACTION_SEND,
         result,
         3),true);

   ExpectBool("Unified CLOSE success true",
      BossExecution.IsUnifiedResultConsistent(
         BOSSR_EXECUTION_ACTION_CLOSE,
         result,
         3),true);
}

//+------------------------------------------------------------------+
//| Block 8 terminal-state tests                                     |
//+------------------------------------------------------------------+
void TestTerminalExecutionResult()
{
   S_BossR_ExecutionResult result;

   BossExecution.ResetResult(result);

   ExpectBool("Terminal reset false",
      BossExecution.IsTerminalExecutionResult(
         result,3),false);

   BossExecution.SetSuccessResult(
      result,
      12345,
      1,
      1.10000,
      1.10000);

   ExpectBool("Terminal success true",
      BossExecution.IsTerminalExecutionResult(
         result,3),true);

   BossExecution.SetFailureResult(
      result,
      BOSSR_EXECUTION_REJECT_PREFLIGHT,
      0,
      1.10000);

   ExpectBool("Terminal local reject true",
      BossExecution.IsTerminalExecutionResult(
         result,3),true);

   BossExecution.SetFailureResult(
      result,
      130,
      1,
      1.10000);

   ExpectBool("Terminal hard broker error true",
      BossExecution.IsTerminalExecutionResult(
         result,3),true);

   BossExecution.SetFailureResult(
      result,
      138,
      1,
      1.10000);

   ExpectBool("Terminal retryable first false",
      BossExecution.IsTerminalExecutionResult(
         result,3),false);

   BossExecution.SetFailureResult(
      result,
      138,
      2,
      1.10000);

   ExpectBool("Terminal retryable second false",
      BossExecution.IsTerminalExecutionResult(
         result,3),false);

   BossExecution.SetFailureResult(
      result,
      138,
      3,
      1.10000);

   ExpectBool("Terminal retryable exhausted true",
      BossExecution.IsTerminalExecutionResult(
         result,3),true);
}

//+------------------------------------------------------------------+
//| Block 8 retry-pending tests                                      |
//+------------------------------------------------------------------+
void TestRetryPendingExecutionResult()
{
   S_BossR_ExecutionResult result;

   BossExecution.ResetResult(result);

   ExpectBool("Retry pending reset false",
      BossExecution.IsRetryPendingExecutionResult(
         result,3),false);

   BossExecution.SetFailureResult(
      result,
      138,
      1,
      1.10000);

   ExpectBool("Retry pending first true",
      BossExecution.IsRetryPendingExecutionResult(
         result,3),true);

   BossExecution.SetFailureResult(
      result,
      138,
      2,
      1.10000);

   ExpectBool("Retry pending second true",
      BossExecution.IsRetryPendingExecutionResult(
         result,3),true);

   BossExecution.SetFailureResult(
      result,
      138,
      3,
      1.10000);

   ExpectBool("Retry pending exhausted false",
      BossExecution.IsRetryPendingExecutionResult(
         result,3),false);

   BossExecution.SetFailureResult(
      result,
      130,
      1,
      1.10000);

   ExpectBool("Retry pending hard error false",
      BossExecution.IsRetryPendingExecutionResult(
         result,3),false);

   BossExecution.SetSuccessResult(
      result,
      12345,
      1,
      1.10000,
      1.10000);

   ExpectBool("Retry pending success false",
      BossExecution.IsRetryPendingExecutionResult(
         result,3),false);
}

//+------------------------------------------------------------------+
//| Block 8 outcome-code tests                                       |
//+------------------------------------------------------------------+
void TestExecutionOutcomeCode()
{
   S_BossR_ExecutionResult result;

   BossExecution.ResetResult(result);

   ExpectInt("Outcome untouched zero",
      BossExecution.ExecutionOutcomeCode(
         result,3),0);

   BossExecution.SetSuccessResult(
      result,
      12345,
      1,
      1.10000,
      1.10000);

   ExpectInt("Outcome success one",
      BossExecution.ExecutionOutcomeCode(
         result,3),1);

   BossExecution.SetFailureResult(
      result,
      138,
      1,
      1.10000);

   ExpectInt("Outcome retry pending two",
      BossExecution.ExecutionOutcomeCode(
         result,3),2);

   BossExecution.SetFailureResult(
      result,
      138,
      3,
      1.10000);

   ExpectInt("Outcome exhausted minus one",
      BossExecution.ExecutionOutcomeCode(
         result,3),-1);

   BossExecution.SetFailureResult(
      result,
      130,
      1,
      1.10000);

   ExpectInt("Outcome hard failure minus one",
      BossExecution.ExecutionOutcomeCode(
         result,3),-1);

   BossExecution.SetFailureResult(
      result,
      BOSSR_EXECUTION_REJECT_STOPS,
      0,
      1.10000);

   ExpectInt("Outcome local reject minus one",
      BossExecution.ExecutionOutcomeCode(
         result,3),-1);
}

//+------------------------------------------------------------------+
//| Expert initialization                                            |
//+------------------------------------------------------------------+
int OnInit()
{
   Print("BossR_Execution Block 8 verification started");

   TestResetRequest();
   TestResetResult();
   TestMarketRequestBuilder();
   TestRequestValidation();
   TestMarketPreflight();
   TestMarketReadiness();
   TestResultSemantics();
   TestExecutionRejectCodes();
   TestExecutionCodeClassification();
   TestExecuteMarketOnceRejectedPaths();
   TestSendRoutingSemantics();
   TestRetryableBrokerErrors();
   TestHardStopBrokerErrors();
   TestAttemptBounds();
   TestShouldRetryResult();
   TestRetryPolicyState();
   TestRefreshMarketRequestPrice();
   TestRetryExecutorConsistency();
   TestExecuteMarketWithRetrySafeReject();
   TestRetryExecutorCapSemantics();
   TestCloseRequestValidation();
   TestDeleteRequestValidation();
   TestCloseOrderOnceSafeReject();
   TestDeleteOrderOnceSafeReject();
   TestCloseResultConsistency();
   TestDeleteResultConsistency();
   TestModifyRequestValidation();
   TestModifyOrderOnceSafeReject();
   TestModifyResultConsistency();
   TestNoOpModifySemantics();
   TestRefreshClosePrice();
   TestExecuteCloseWithRetrySafeReject();
   TestExecuteDeleteWithRetrySafeReject();
   TestExecuteModifyWithRetrySafeReject();
   TestActionRetryResultConsistency();
   TestExecutionActionClassification();
   TestUnifiedResultConsistency();
   TestTerminalExecutionResult();
   TestRetryPendingExecutionResult();
   TestExecutionOutcomeCode();

   Print("BossR_Execution_Verify_Block8_FACADE_FULL ",
         Symbol(),
         ",",
         Period(),
         ": PASS ",
         g_pass,
         " / FAIL ",
         g_fail);

   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert tick                                                      |
//+------------------------------------------------------------------+
void OnTick()
{
}
