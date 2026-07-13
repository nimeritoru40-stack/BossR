//+------------------------------------------------------------------+
//| BossR_Order_Verify_Block7_ANALYTICS_FULL.mq4                    |
//| BossR Framework - Order Module Verification                      |
//| Block 7                                                          |
//| Compile this EA only                                             |
//+------------------------------------------------------------------+
#property strict

#include <BossR\BossR_Order_Block7_ANALYTICS_FULL.mqh>

C_BossR_Order BossOrder;

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

//+------------------------------------------------------------------+
//| Independent reference helpers                                    |
//+------------------------------------------------------------------+
bool ReferenceMatches(const string required_symbol,
                      const int required_magic)
{
   return(
      OrderSymbol() == required_symbol &&
      OrderMagicNumber() == required_magic
   );
}

bool ReferenceIsMarket(const int order_type)
{
   return(
      order_type == OP_BUY ||
      order_type == OP_SELL
   );
}

bool ReferenceIsPending(const int order_type)
{
   return(
      order_type == OP_BUYLIMIT ||
      order_type == OP_SELLLIMIT ||
      order_type == OP_BUYSTOP ||
      order_type == OP_SELLSTOP
   );
}

int ReferenceCountAll(const string required_symbol,
                      const int required_magic)
{
   int count = 0;

   for(int position = OrdersTotal() - 1;
       position >= 0;
       position--)
   {
      if(!OrderSelect(position, SELECT_BY_POS, MODE_TRADES))
         continue;

      if(!ReferenceMatches(required_symbol,
                           required_magic))
      {
         continue;
      }

      count++;
   }

   return(count);
}

int ReferenceCountMarket(const string required_symbol,
                         const int required_magic)
{
   int count = 0;

   for(int position = OrdersTotal() - 1;
       position >= 0;
       position--)
   {
      if(!OrderSelect(position, SELECT_BY_POS, MODE_TRADES))
         continue;

      if(!ReferenceMatches(required_symbol,
                           required_magic))
      {
         continue;
      }

      if(!ReferenceIsMarket(OrderType()))
         continue;

      count++;
   }

   return(count);
}

int ReferenceCountPending(const string required_symbol,
                          const int required_magic)
{
   int count = 0;

   for(int position = OrdersTotal() - 1;
       position >= 0;
       position--)
   {
      if(!OrderSelect(position, SELECT_BY_POS, MODE_TRADES))
         continue;

      if(!ReferenceMatches(required_symbol,
                           required_magic))
      {
         continue;
      }

      if(!ReferenceIsPending(OrderType()))
         continue;

      count++;
   }

   return(count);
}

int ReferenceCountType(const string required_symbol,
                       const int required_magic,
                       const int required_order_type)
{
   int count = 0;

   for(int position = OrdersTotal() - 1;
       position >= 0;
       position--)
   {
      if(!OrderSelect(position, SELECT_BY_POS, MODE_TRADES))
         continue;

      if(!ReferenceMatches(required_symbol,
                           required_magic))
      {
         continue;
      }

      if(OrderType() != required_order_type)
         continue;

      count++;
   }

   return(count);
}

double ReferenceSumLotsAll(const string required_symbol,
                           const int required_magic)
{
   double total_lots = 0.0;

   for(int position = OrdersTotal() - 1;
       position >= 0;
       position--)
   {
      if(!OrderSelect(position, SELECT_BY_POS, MODE_TRADES))
         continue;

      if(!ReferenceMatches(required_symbol,
                           required_magic))
      {
         continue;
      }

      if(OrderLots() > 0.0)
         total_lots += OrderLots();
   }

   return(total_lots);
}

double ReferenceSumLotsMarket(const string required_symbol,
                              const int required_magic)
{
   double total_lots = 0.0;

   for(int position = OrdersTotal() - 1;
       position >= 0;
       position--)
   {
      if(!OrderSelect(position, SELECT_BY_POS, MODE_TRADES))
         continue;

      if(!ReferenceMatches(required_symbol,
                           required_magic))
      {
         continue;
      }

      if(!ReferenceIsMarket(OrderType()))
         continue;

      if(OrderLots() > 0.0)
         total_lots += OrderLots();
   }

   return(total_lots);
}

double ReferenceSumLotsPending(const string required_symbol,
                               const int required_magic)
{
   double total_lots = 0.0;

   for(int position = OrdersTotal() - 1;
       position >= 0;
       position--)
   {
      if(!OrderSelect(position, SELECT_BY_POS, MODE_TRADES))
         continue;

      if(!ReferenceMatches(required_symbol,
                           required_magic))
      {
         continue;
      }

      if(!ReferenceIsPending(OrderType()))
         continue;

      if(OrderLots() > 0.0)
         total_lots += OrderLots();
   }

   return(total_lots);
}

int ReferenceFirstTicket(const string required_symbol,
                         const int required_magic,
                         const int filter_mode)
{
   for(int position = 0;
       position < OrdersTotal();
       position++)
   {
      if(!OrderSelect(position, SELECT_BY_POS, MODE_TRADES))
         continue;

      if(!ReferenceMatches(required_symbol,
                           required_magic))
      {
         continue;
      }

      if(filter_mode == 1 &&
         !ReferenceIsMarket(OrderType()))
      {
         continue;
      }

      if(filter_mode == 2 &&
         !ReferenceIsPending(OrderType()))
      {
         continue;
      }

      if(OrderTicket() > 0)
         return(OrderTicket());
   }

   return(-1);
}

//+------------------------------------------------------------------+
//| Pool and selection tests                                         |
//+------------------------------------------------------------------+
void TestPoolAndSelection()
{
   ExpectInt("PoolTotal matches OrdersTotal",
      BossOrder.PoolTotal(),
      MathMax(0, OrdersTotal()));

   ExpectBool("Select position negative false",
      BossOrder.SelectOpenByPosition(-1),
      false);

   ExpectBool("Select position total false",
      BossOrder.SelectOpenByPosition(BossOrder.PoolTotal()),
      false);

   ExpectBool("Select ticket zero false",
      BossOrder.SelectOpenByTicket(0),
      false);

   ExpectBool("Select ticket negative false",
      BossOrder.SelectOpenByTicket(-1),
      false);

   if(BossOrder.PoolTotal() > 0)
   {
      ExpectBool("Select position zero true",
         BossOrder.SelectOpenByPosition(0),
         true);

      int selected_ticket = OrderTicket();

      ExpectBool("Selected ticket positive",
         selected_ticket > 0,
         true);

      ExpectBool("Select existing ticket true",
         BossOrder.SelectOpenByTicket(selected_ticket),
         true);
   }
}

//+------------------------------------------------------------------+
//| Filter guard tests                                               |
//+------------------------------------------------------------------+
void TestFilterGuards()
{
   ExpectInt("CountAll empty symbol zero",
      BossOrder.CountAll("", 260713),
      0);

   ExpectInt("CountAll negative magic zero",
      BossOrder.CountAll(Symbol(), -1),
      0);

   ExpectInt("CountMarket empty symbol zero",
      BossOrder.CountMarket("", 260713),
      0);

   ExpectInt("CountPending negative magic zero",
      BossOrder.CountPending(Symbol(), -1),
      0);

   ExpectInt("CountType invalid type zero",
      BossOrder.CountType(Symbol(), 260713, 99),
      0);

   ExpectBool("HasAny empty symbol false",
      BossOrder.HasAny("", 260713),
      false);

   ExpectBool("HasMarket negative magic false",
      BossOrder.HasMarket(Symbol(), -1),
      false);

   ExpectBool("HasPending empty symbol false",
      BossOrder.HasPending("", 260713),
      false);

   ExpectDouble("SumLotsAll empty symbol zero",
      BossOrder.SumLotsAll("", 260713),
      0.0);

   ExpectDouble("SumLotsMarket negative magic zero",
      BossOrder.SumLotsMarket(Symbol(), -1),
      0.0);

   ExpectDouble("SumLotsPending empty symbol zero",
      BossOrder.SumLotsPending("", 260713),
      0.0);

   ExpectInt("FirstTicket empty symbol -1",
      BossOrder.FirstTicket("", 260713),
      -1);

   ExpectInt("FirstMarketTicket negative magic -1",
      BossOrder.FirstMarketTicket(Symbol(), -1),
      -1);

   ExpectInt("FirstPendingTicket empty symbol -1",
      BossOrder.FirstPendingTicket("", 260713),
      -1);
}

//+------------------------------------------------------------------+
//| Runtime reference comparison tests                               |
//+------------------------------------------------------------------+
void TestRuntimeReferenceComparison()
{
   string test_symbol = Symbol();
   int test_magic = 260713;

   int expected_all =
      ReferenceCountAll(test_symbol, test_magic);

   int expected_market =
      ReferenceCountMarket(test_symbol, test_magic);

   int expected_pending =
      ReferenceCountPending(test_symbol, test_magic);

   ExpectInt("CountAll runtime match",
      BossOrder.CountAll(test_symbol, test_magic),
      expected_all);

   ExpectInt("CountMarket runtime match",
      BossOrder.CountMarket(test_symbol, test_magic),
      expected_market);

   ExpectInt("CountPending runtime match",
      BossOrder.CountPending(test_symbol, test_magic),
      expected_pending);

   ExpectInt("Count partition invariant",
      BossOrder.CountMarket(test_symbol, test_magic) +
      BossOrder.CountPending(test_symbol, test_magic),
      BossOrder.CountAll(test_symbol, test_magic));

   ExpectBool("HasAny runtime match",
      BossOrder.HasAny(test_symbol, test_magic),
      expected_all > 0);

   ExpectBool("HasMarket runtime match",
      BossOrder.HasMarket(test_symbol, test_magic),
      expected_market > 0);

   ExpectBool("HasPending runtime match",
      BossOrder.HasPending(test_symbol, test_magic),
      expected_pending > 0);

   ExpectDouble("SumLotsAll runtime match",
      BossOrder.SumLotsAll(test_symbol, test_magic),
      ReferenceSumLotsAll(test_symbol, test_magic));

   ExpectDouble("SumLotsMarket runtime match",
      BossOrder.SumLotsMarket(test_symbol, test_magic),
      ReferenceSumLotsMarket(test_symbol, test_magic));

   ExpectDouble("SumLotsPending runtime match",
      BossOrder.SumLotsPending(test_symbol, test_magic),
      ReferenceSumLotsPending(test_symbol, test_magic));

   ExpectDouble("Lot partition invariant",
      BossOrder.SumLotsMarket(test_symbol, test_magic) +
      BossOrder.SumLotsPending(test_symbol, test_magic),
      BossOrder.SumLotsAll(test_symbol, test_magic));

   ExpectInt("FirstTicket runtime match",
      BossOrder.FirstTicket(test_symbol, test_magic),
      ReferenceFirstTicket(test_symbol, test_magic, 0));

   ExpectInt("FirstMarketTicket runtime match",
      BossOrder.FirstMarketTicket(test_symbol, test_magic),
      ReferenceFirstTicket(test_symbol, test_magic, 1));

   ExpectInt("FirstPendingTicket runtime match",
      BossOrder.FirstPendingTicket(test_symbol, test_magic),
      ReferenceFirstTicket(test_symbol, test_magic, 2));

   int supported_types[6];
   supported_types[0] = OP_BUY;
   supported_types[1] = OP_SELL;
   supported_types[2] = OP_BUYLIMIT;
   supported_types[3] = OP_SELLLIMIT;
   supported_types[4] = OP_BUYSTOP;
   supported_types[5] = OP_SELLSTOP;

   for(int i = 0; i < 6; i++)
   {
      int order_type = supported_types[i];

      ExpectInt(
         "CountType runtime type " +
         IntegerToString(order_type),
         BossOrder.CountType(
            test_symbol,
            test_magic,
            order_type
         ),
         ReferenceCountType(
            test_symbol,
            test_magic,
            order_type
         )
      );
   }
}

//+------------------------------------------------------------------+
//| Selected order tests                                             |
//+------------------------------------------------------------------+
void TestSelectedOrderState()
{
   if(BossOrder.PoolTotal() <= 0)
      return;

   if(!BossOrder.SelectOpenByPosition(0))
   {
      Fail("Selected state setup");
      return;
   }

   string selected_symbol = OrderSymbol();
   int selected_magic = OrderMagicNumber();
   int selected_type = OrderType();

   ExpectBool("SelectedMatches exact",
      BossOrder.SelectedMatches(
         selected_symbol,
         selected_magic
      ),
      true);

   ExpectBool("SelectedMatches symbol mismatch",
      BossOrder.SelectedMatches(
         selected_symbol + "_X",
         selected_magic
      ),
      false);

   ExpectBool("SelectedMatches magic mismatch",
      BossOrder.SelectedMatches(
         selected_symbol,
         selected_magic + 1
      ),
      false);

   ExpectBool("SelectedMatches empty symbol false",
      BossOrder.SelectedMatches(
         "",
         selected_magic
      ),
      false);

   ExpectBool("Selected market classification",
      BossOrder.SelectedIsMarket(),
      ReferenceIsMarket(selected_type));

   ExpectBool("Selected pending classification",
      BossOrder.SelectedIsPending(),
      ReferenceIsPending(selected_type));
}


//+------------------------------------------------------------------+
//| Selected metadata accessor tests                                 |
//+------------------------------------------------------------------+
void TestSelectedMetadataAccessors()
{
   if(BossOrder.PoolTotal() <= 0)
      return;

   if(!BossOrder.SelectOpenByPosition(0))
   {
      Fail("Metadata setup selection");
      return;
   }

   int expected_ticket = OrderTicket();
   int expected_type = OrderType();
   string expected_symbol = OrderSymbol();
   int expected_magic = OrderMagicNumber();
   string expected_comment = OrderComment();
   double expected_lots = OrderLots();
   double expected_open_price = OrderOpenPrice();
   datetime expected_open_time = OrderOpenTime();
   double expected_stop_loss = OrderStopLoss();
   double expected_take_profit = OrderTakeProfit();
   datetime expected_expiration = OrderExpiration();
   double expected_profit = OrderProfit();
   double expected_swap = OrderSwap();
   double expected_commission = OrderCommission();
   double expected_net =
      expected_profit +
      expected_swap +
      expected_commission;

   ExpectInt("SelectedTicket native match",
      BossOrder.SelectedTicket(),
      expected_ticket);

   ExpectInt("SelectedType native match",
      BossOrder.SelectedType(),
      expected_type);

   ExpectBool("SelectedSymbol native match",
      BossOrder.SelectedSymbol() == expected_symbol,
      true);

   ExpectInt("SelectedMagicNumber native match",
      BossOrder.SelectedMagicNumber(),
      expected_magic);

   ExpectBool("SelectedComment native match",
      BossOrder.SelectedComment() == expected_comment,
      true);

   ExpectDouble("SelectedLots native match",
      BossOrder.SelectedLots(),
      expected_lots);

   ExpectDouble("SelectedOpenPrice native match",
      BossOrder.SelectedOpenPrice(),
      expected_open_price);

   ExpectInt("SelectedOpenTime native match",
      (int)BossOrder.SelectedOpenTime(),
      (int)expected_open_time);

   ExpectDouble("SelectedStopLoss native match",
      BossOrder.SelectedStopLoss(),
      expected_stop_loss);

   ExpectDouble("SelectedTakeProfit native match",
      BossOrder.SelectedTakeProfit(),
      expected_take_profit);

   ExpectInt("SelectedExpiration native match",
      (int)BossOrder.SelectedExpiration(),
      (int)expected_expiration);

   ExpectDouble("SelectedProfit native match",
      BossOrder.SelectedProfit(),
      expected_profit);

   ExpectDouble("SelectedSwap native match",
      BossOrder.SelectedSwap(),
      expected_swap);

   ExpectDouble("SelectedCommission native match",
      BossOrder.SelectedCommission(),
      expected_commission);

   ExpectDouble("SelectedNetResult arithmetic",
      BossOrder.SelectedNetResult(),
      expected_net);

   ExpectDouble("SelectedNetResult component invariant",
      BossOrder.SelectedNetResult(),
      BossOrder.SelectedProfit() +
      BossOrder.SelectedSwap() +
      BossOrder.SelectedCommission());

   datetime same_time = expected_open_time;

   ExpectInt("SelectedAgeSeconds same time zero",
      BossOrder.SelectedAgeSeconds(same_time),
      0);

   ExpectInt("SelectedAgeSeconds before open zero",
      BossOrder.SelectedAgeSeconds(expected_open_time - 60),
      0);

   ExpectInt("SelectedAgeSeconds plus one",
      BossOrder.SelectedAgeSeconds(expected_open_time + 1),
      1);

   ExpectInt("SelectedAgeSeconds plus minute",
      BossOrder.SelectedAgeSeconds(expected_open_time + 60),
      60);

   datetime fixed_future = expected_open_time + 86400;

   ExpectInt("SelectedAgeSeconds fixed day",
      BossOrder.SelectedAgeSeconds(fixed_future),
      86400);

   int expected_now_age = 0;
   datetime current_time = TimeCurrent();

   if(expected_open_time > 0 &&
      current_time > expected_open_time)
   {
      expected_now_age =
         (int)(current_time - expected_open_time);
   }

   int actual_now_age = BossOrder.SelectedAgeSecondsNow();

   ExpectBool("SelectedAgeSecondsNow close to native",
      MathAbs(actual_now_age - expected_now_age) <= 1,
      true);
}

//+------------------------------------------------------------------+
//| Metadata tests across every selected trade-pool order             |
//+------------------------------------------------------------------+
void TestMetadataAcrossPool()
{
   int total = BossOrder.PoolTotal();

   for(int position = 0;
       position < total;
       position++)
   {
      if(!BossOrder.SelectOpenByPosition(position))
         continue;

      int expected_ticket = OrderTicket();
      int expected_type = OrderType();
      string expected_symbol = OrderSymbol();
      int expected_magic = OrderMagicNumber();
      double expected_lots = OrderLots();
      double expected_open_price = OrderOpenPrice();
      datetime expected_open_time = OrderOpenTime();
      double expected_stop_loss = OrderStopLoss();
      double expected_take_profit = OrderTakeProfit();
      datetime expected_expiration = OrderExpiration();
      double expected_profit = OrderProfit();
      double expected_swap = OrderSwap();
      double expected_commission = OrderCommission();

      string suffix =
         " pool position " +
         IntegerToString(position);

      ExpectInt("Ticket" + suffix,
         BossOrder.SelectedTicket(),
         expected_ticket);

      ExpectInt("Type" + suffix,
         BossOrder.SelectedType(),
         expected_type);

      ExpectBool("Symbol" + suffix,
         BossOrder.SelectedSymbol() == expected_symbol,
         true);

      ExpectInt("Magic" + suffix,
         BossOrder.SelectedMagicNumber(),
         expected_magic);

      ExpectDouble("Lots" + suffix,
         BossOrder.SelectedLots(),
         expected_lots);

      ExpectDouble("OpenPrice" + suffix,
         BossOrder.SelectedOpenPrice(),
         expected_open_price);

      ExpectInt("OpenTime" + suffix,
         (int)BossOrder.SelectedOpenTime(),
         (int)expected_open_time);

      ExpectDouble("StopLoss" + suffix,
         BossOrder.SelectedStopLoss(),
         expected_stop_loss);

      ExpectDouble("TakeProfit" + suffix,
         BossOrder.SelectedTakeProfit(),
         expected_take_profit);

      ExpectInt("Expiration" + suffix,
         (int)BossOrder.SelectedExpiration(),
         (int)expected_expiration);

      ExpectDouble("Profit" + suffix,
         BossOrder.SelectedProfit(),
         expected_profit);

      ExpectDouble("Swap" + suffix,
         BossOrder.SelectedSwap(),
         expected_swap);

      ExpectDouble("Commission" + suffix,
         BossOrder.SelectedCommission(),
         expected_commission);

      ExpectDouble("NetResult" + suffix,
         BossOrder.SelectedNetResult(),
         expected_profit +
         expected_swap +
         expected_commission);
   }
}


//+------------------------------------------------------------------+
//| Independent directional references                               |
//+------------------------------------------------------------------+
double ReferenceSumLotsType(const string required_symbol,
                            const int required_magic,
                            const int required_type)
{
   double total_lots = 0.0;

   for(int position = OrdersTotal() - 1;
       position >= 0;
       position--)
   {
      if(!OrderSelect(position, SELECT_BY_POS, MODE_TRADES))
         continue;

      if(!ReferenceMatches(required_symbol,
                           required_magic))
      {
         continue;
      }

      if(OrderType() != required_type)
         continue;

      if(OrderLots() > 0.0)
         total_lots += OrderLots();
   }

   return(total_lots);
}

int ReferenceChronologyTicket(const string required_symbol,
                              const int required_magic,
                              const bool want_oldest)
{
   int found_ticket = -1;
   datetime found_time = 0;

   for(int position = 0;
       position < OrdersTotal();
       position++)
   {
      if(!OrderSelect(position, SELECT_BY_POS, MODE_TRADES))
         continue;

      if(!ReferenceMatches(required_symbol,
                           required_magic))
      {
         continue;
      }

      int ticket = OrderTicket();
      datetime open_time = OrderOpenTime();

      if(ticket <= 0)
         continue;

      if(found_ticket < 0)
      {
         found_ticket = ticket;
         found_time = open_time;
         continue;
      }

      if(want_oldest)
      {
         if(open_time < found_time ||
            (open_time == found_time &&
             ticket < found_ticket))
         {
            found_ticket = ticket;
            found_time = open_time;
         }
      }
      else
      {
         if(open_time > found_time ||
            (open_time == found_time &&
             ticket > found_ticket))
         {
            found_ticket = ticket;
            found_time = open_time;
         }
      }
   }

   return(found_ticket);
}

datetime ReferenceTicketOpenTime(const int ticket)
{
   if(ticket <= 0)
      return(0);

   if(!OrderSelect(ticket, SELECT_BY_TICKET, MODE_TRADES))
      return(0);

   return(OrderOpenTime());
}

//+------------------------------------------------------------------+
//| Block 3 exposure tests                                           |
//+------------------------------------------------------------------+
void TestDirectionalExposure()
{
   string test_symbol = Symbol();
   int test_magic = 260713;

   int expected_buy =
      ReferenceCountType(test_symbol,
                         test_magic,
                         OP_BUY);

   int expected_sell =
      ReferenceCountType(test_symbol,
                         test_magic,
                         OP_SELL);

   double expected_buy_lots =
      ReferenceSumLotsType(test_symbol,
                           test_magic,
                           OP_BUY);

   double expected_sell_lots =
      ReferenceSumLotsType(test_symbol,
                           test_magic,
                           OP_SELL);

   double expected_net =
      expected_buy_lots -
      expected_sell_lots;

   int expected_direction = 0;

   if(expected_net > 0.000000001)
      expected_direction = 1;
   else if(expected_net < -0.000000001)
      expected_direction = -1;

   ExpectInt("CountBuy runtime match",
      BossOrder.CountBuy(test_symbol, test_magic),
      expected_buy);

   ExpectInt("CountSell runtime match",
      BossOrder.CountSell(test_symbol, test_magic),
      expected_sell);

   ExpectBool("HasBuy runtime match",
      BossOrder.HasBuy(test_symbol, test_magic),
      expected_buy > 0);

   ExpectBool("HasSell runtime match",
      BossOrder.HasSell(test_symbol, test_magic),
      expected_sell > 0);

   ExpectDouble("SumLotsBuy runtime match",
      BossOrder.SumLotsBuy(test_symbol, test_magic),
      expected_buy_lots);

   ExpectDouble("SumLotsSell runtime match",
      BossOrder.SumLotsSell(test_symbol, test_magic),
      expected_sell_lots);

   ExpectDouble("NetMarketLots runtime match",
      BossOrder.NetMarketLots(test_symbol, test_magic),
      expected_net);

   ExpectDouble("Market lot partition invariant",
      BossOrder.SumLotsBuy(test_symbol, test_magic) +
      BossOrder.SumLotsSell(test_symbol, test_magic),
      BossOrder.SumLotsMarket(test_symbol, test_magic));

   ExpectInt("ExposureDirection runtime match",
      BossOrder.ExposureDirection(test_symbol, test_magic),
      expected_direction);

   ExpectInt("CountBuy empty symbol zero",
      BossOrder.CountBuy("", test_magic),
      0);

   ExpectInt("CountSell invalid magic zero",
      BossOrder.CountSell(test_symbol, -1),
      0);

   ExpectBool("HasBuy empty symbol false",
      BossOrder.HasBuy("", test_magic),
      false);

   ExpectBool("HasSell invalid magic false",
      BossOrder.HasSell(test_symbol, -1),
      false);

   ExpectDouble("SumLotsBuy empty symbol zero",
      BossOrder.SumLotsBuy("", test_magic),
      0.0);

   ExpectDouble("SumLotsSell invalid magic zero",
      BossOrder.SumLotsSell(test_symbol, -1),
      0.0);

   ExpectDouble("NetMarketLots empty symbol zero",
      BossOrder.NetMarketLots("", test_magic),
      0.0);

   ExpectInt("ExposureDirection empty symbol flat",
      BossOrder.ExposureDirection("", test_magic),
      0);

   ExpectInt("ExposureDirection huge epsilon flat",
      BossOrder.ExposureDirection(
         test_symbol,
         test_magic,
         1000000.0),
      0);
}

//+------------------------------------------------------------------+
//| Block 3 chronology tests                                         |
//+------------------------------------------------------------------+
void TestOrderChronology()
{
   string test_symbol = Symbol();
   int test_magic = 260713;

   int expected_oldest =
      ReferenceChronologyTicket(test_symbol,
                                test_magic,
                                true);

   int expected_newest =
      ReferenceChronologyTicket(test_symbol,
                                test_magic,
                                false);

   datetime expected_oldest_time =
      ReferenceTicketOpenTime(expected_oldest);

   datetime expected_newest_time =
      ReferenceTicketOpenTime(expected_newest);

   ExpectInt("OldestTicket runtime match",
      BossOrder.OldestTicket(test_symbol, test_magic),
      expected_oldest);

   ExpectInt("NewestTicket runtime match",
      BossOrder.NewestTicket(test_symbol, test_magic),
      expected_newest);

   ExpectInt("OldestOpenTime runtime match",
      (int)BossOrder.OldestOpenTime(
         test_symbol,
         test_magic),
      (int)expected_oldest_time);

   ExpectInt("NewestOpenTime runtime match",
      (int)BossOrder.NewestOpenTime(
         test_symbol,
         test_magic),
      (int)expected_newest_time);

   ExpectInt("OldestTicket empty symbol -1",
      BossOrder.OldestTicket("", test_magic),
      -1);

   ExpectInt("NewestTicket invalid magic -1",
      BossOrder.NewestTicket(test_symbol, -1),
      -1);

   ExpectInt("OldestOpenTime empty symbol zero",
      (int)BossOrder.OldestOpenTime("", test_magic),
      0);

   ExpectInt("NewestOpenTime invalid magic zero",
      (int)BossOrder.NewestOpenTime(test_symbol, -1),
      0);

   if(expected_oldest > 0 &&
      expected_newest > 0)
   {
      ExpectBool("Chronology oldest not after newest",
         expected_oldest_time <= expected_newest_time,
         true);

      if(expected_oldest == expected_newest)
      {
         ExpectInt("Single-match chronology time same",
            (int)expected_oldest_time,
            (int)expected_newest_time);
      }
   }
}


//+------------------------------------------------------------------+
//| Independent deterministic lookup reference                       |
//+------------------------------------------------------------------+
int ReferenceTicketAtMatch(const string required_symbol,
                           const int required_magic,
                           const int filter_mode,
                           const int required_type,
                           const int match_index)
{
   if(match_index < 0)
      return(-1);

   int matched = 0;

   for(int position = 0;
       position < OrdersTotal();
       position++)
   {
      if(!OrderSelect(position, SELECT_BY_POS, MODE_TRADES))
         continue;

      if(!ReferenceMatches(required_symbol,
                           required_magic))
      {
         continue;
      }

      if(filter_mode == 1 &&
         !ReferenceIsMarket(OrderType()))
      {
         continue;
      }

      if(filter_mode == 2 &&
         !ReferenceIsPending(OrderType()))
      {
         continue;
      }

      if(filter_mode == 3 &&
         OrderType() != required_type)
      {
         continue;
      }

      if(matched == match_index)
         return(OrderTicket());

      matched++;
   }

   return(-1);
}

//+------------------------------------------------------------------+
//| Verify selection returns exact ticket                            |
//+------------------------------------------------------------------+
void ExpectSelectedTicket(const string test_name,
                          const bool selected,
                          const int expected_ticket)
{
   if(expected_ticket <= 0)
   {
      ExpectBool(test_name + " selection false",
         selected,
         false);
      return;
   }

   ExpectBool(test_name + " selection true",
      selected,
      true);

   if(!selected)
      return;

   ExpectInt(test_name + " exact ticket",
      OrderTicket(),
      expected_ticket);
}

//+------------------------------------------------------------------+
//| Block 4 lookup guard tests                                       |
//+------------------------------------------------------------------+
void TestLookupGuards()
{
   string test_symbol = Symbol();
   int test_magic = 260713;

   ExpectInt("TicketAtMatch negative index -1",
      BossOrder.TicketAtMatch(
         test_symbol,
         test_magic,
         -1),
      -1);

   ExpectInt("MarketTicketAtMatch empty symbol -1",
      BossOrder.MarketTicketAtMatch(
         "",
         test_magic,
         0),
      -1);

   ExpectInt("PendingTicketAtMatch invalid magic -1",
      BossOrder.PendingTicketAtMatch(
         test_symbol,
         -1,
         0),
      -1);

   ExpectInt("TypeTicketAtMatch invalid type -1",
      BossOrder.TypeTicketAtMatch(
         test_symbol,
         test_magic,
         99,
         0),
      -1);

   ExpectInt("TypeTicketAtMatch negative index -1",
      BossOrder.TypeTicketAtMatch(
         test_symbol,
         test_magic,
         OP_BUY,
         -1),
      -1);

   ExpectBool("SelectMatch negative index false",
      BossOrder.SelectMatch(
         test_symbol,
         test_magic,
         -1),
      false);

   ExpectBool("SelectMarketMatch empty symbol false",
      BossOrder.SelectMarketMatch(
         "",
         test_magic,
         0),
      false);

   ExpectBool("SelectPendingMatch invalid magic false",
      BossOrder.SelectPendingMatch(
         test_symbol,
         -1,
         0),
      false);

   ExpectBool("SelectTypeMatch invalid type false",
      BossOrder.SelectTypeMatch(
         test_symbol,
         test_magic,
         99,
         0),
      false);

   ExpectBool("SelectBuyMatch negative index false",
      BossOrder.SelectBuyMatch(
         test_symbol,
         test_magic,
         -1),
      false);

   ExpectBool("SelectSellMatch empty symbol false",
      BossOrder.SelectSellMatch(
         "",
         test_magic,
         0),
      false);
}

//+------------------------------------------------------------------+
//| Block 4 nth-match traversal tests                                |
//+------------------------------------------------------------------+
void TestNthMatchTraversal()
{
   string test_symbol = Symbol();
   int test_magic = 260713;

   int total_all =
      ReferenceCountAll(test_symbol,
                        test_magic);

   int total_market =
      ReferenceCountMarket(test_symbol,
                           test_magic);

   int total_pending =
      ReferenceCountPending(test_symbol,
                            test_magic);

   for(int index = 0;
       index < total_all;
       index++)
   {
      int expected =
         ReferenceTicketAtMatch(
            test_symbol,
            test_magic,
            0,
            -1,
            index);

      ExpectInt(
         "TicketAtMatch index " +
         IntegerToString(index),
         BossOrder.TicketAtMatch(
            test_symbol,
            test_magic,
            index),
         expected);

      ExpectSelectedTicket(
         "SelectMatch index " +
         IntegerToString(index),
         BossOrder.SelectMatch(
            test_symbol,
            test_magic,
            index),
         expected);
   }

   ExpectInt("TicketAtMatch past end -1",
      BossOrder.TicketAtMatch(
         test_symbol,
         test_magic,
         total_all),
      -1);

   ExpectBool("SelectMatch past end false",
      BossOrder.SelectMatch(
         test_symbol,
         test_magic,
         total_all),
      false);

   for(int index = 0;
       index < total_market;
       index++)
   {
      int expected =
         ReferenceTicketAtMatch(
            test_symbol,
            test_magic,
            1,
            -1,
            index);

      ExpectInt(
         "MarketTicketAtMatch index " +
         IntegerToString(index),
         BossOrder.MarketTicketAtMatch(
            test_symbol,
            test_magic,
            index),
         expected);

      ExpectSelectedTicket(
         "SelectMarketMatch index " +
         IntegerToString(index),
         BossOrder.SelectMarketMatch(
            test_symbol,
            test_magic,
            index),
         expected);
   }

   ExpectInt("MarketTicketAtMatch past end -1",
      BossOrder.MarketTicketAtMatch(
         test_symbol,
         test_magic,
         total_market),
      -1);

   ExpectBool("SelectMarketMatch past end false",
      BossOrder.SelectMarketMatch(
         test_symbol,
         test_magic,
         total_market),
      false);

   for(int index = 0;
       index < total_pending;
       index++)
   {
      int expected =
         ReferenceTicketAtMatch(
            test_symbol,
            test_magic,
            2,
            -1,
            index);

      ExpectInt(
         "PendingTicketAtMatch index " +
         IntegerToString(index),
         BossOrder.PendingTicketAtMatch(
            test_symbol,
            test_magic,
            index),
         expected);

      ExpectSelectedTicket(
         "SelectPendingMatch index " +
         IntegerToString(index),
         BossOrder.SelectPendingMatch(
            test_symbol,
            test_magic,
            index),
         expected);
   }

   ExpectInt("PendingTicketAtMatch past end -1",
      BossOrder.PendingTicketAtMatch(
         test_symbol,
         test_magic,
         total_pending),
      -1);

   ExpectBool("SelectPendingMatch past end false",
      BossOrder.SelectPendingMatch(
         test_symbol,
         test_magic,
         total_pending),
      false);
}

//+------------------------------------------------------------------+
//| Block 4 type and direction lookup tests                          |
//+------------------------------------------------------------------+
void TestTypeAndDirectionLookup()
{
   string test_symbol = Symbol();
   int test_magic = 260713;

   int supported_types[6];
   supported_types[0] = OP_BUY;
   supported_types[1] = OP_SELL;
   supported_types[2] = OP_BUYLIMIT;
   supported_types[3] = OP_SELLLIMIT;
   supported_types[4] = OP_BUYSTOP;
   supported_types[5] = OP_SELLSTOP;

   for(int type_index = 0;
       type_index < 6;
       type_index++)
   {
      int order_type =
         supported_types[type_index];

      int type_count =
         ReferenceCountType(
            test_symbol,
            test_magic,
            order_type);

      for(int index = 0;
          index < type_count;
          index++)
      {
         int expected =
            ReferenceTicketAtMatch(
               test_symbol,
               test_magic,
               3,
               order_type,
               index);

         string suffix =
            " type " +
            IntegerToString(order_type) +
            " index " +
            IntegerToString(index);

         ExpectInt(
            "TypeTicketAtMatch" + suffix,
            BossOrder.TypeTicketAtMatch(
               test_symbol,
               test_magic,
               order_type,
               index),
            expected);

         ExpectSelectedTicket(
            "SelectTypeMatch" + suffix,
            BossOrder.SelectTypeMatch(
               test_symbol,
               test_magic,
               order_type,
               index),
            expected);
      }

      ExpectInt(
         "TypeTicketAtMatch past end type " +
         IntegerToString(order_type),
         BossOrder.TypeTicketAtMatch(
            test_symbol,
            test_magic,
            order_type,
            type_count),
         -1);

      ExpectBool(
         "SelectTypeMatch past end type " +
         IntegerToString(order_type),
         BossOrder.SelectTypeMatch(
            test_symbol,
            test_magic,
            order_type,
            type_count),
         false);
   }

   int buy_count =
      ReferenceCountType(
         test_symbol,
         test_magic,
         OP_BUY);

   for(int index = 0;
       index < buy_count;
       index++)
   {
      int expected =
         ReferenceTicketAtMatch(
            test_symbol,
            test_magic,
            3,
            OP_BUY,
            index);

      ExpectInt(
         "BuyTicketAtMatch index " +
         IntegerToString(index),
         BossOrder.BuyTicketAtMatch(
            test_symbol,
            test_magic,
            index),
         expected);

      ExpectSelectedTicket(
         "SelectBuyMatch index " +
         IntegerToString(index),
         BossOrder.SelectBuyMatch(
            test_symbol,
            test_magic,
            index),
         expected);
   }

   int sell_count =
      ReferenceCountType(
         test_symbol,
         test_magic,
         OP_SELL);

   for(int index = 0;
       index < sell_count;
       index++)
   {
      int expected =
         ReferenceTicketAtMatch(
            test_symbol,
            test_magic,
            3,
            OP_SELL,
            index);

      ExpectInt(
         "SellTicketAtMatch index " +
         IntegerToString(index),
         BossOrder.SellTicketAtMatch(
            test_symbol,
            test_magic,
            index),
         expected);

      ExpectSelectedTicket(
         "SelectSellMatch index " +
         IntegerToString(index),
         BossOrder.SelectSellMatch(
            test_symbol,
            test_magic,
            index),
         expected);
   }
}


//+------------------------------------------------------------------+
//| Independent financial references                                 |
//+------------------------------------------------------------------+
double ReferenceFinancialSum(const string required_symbol,
                             const int required_magic,
                             const int value_mode,
                             const int required_type = -1)
{
   double total_value = 0.0;

   for(int position = OrdersTotal() - 1;
       position >= 0;
       position--)
   {
      if(!OrderSelect(position, SELECT_BY_POS, MODE_TRADES))
         continue;

      if(!ReferenceMatches(required_symbol,
                           required_magic))
      {
         continue;
      }

      if(required_type >= 0 &&
         OrderType() != required_type)
      {
         continue;
      }

      if(value_mode == 0)
         total_value += OrderProfit();
      else if(value_mode == 1)
         total_value += OrderSwap();
      else if(value_mode == 2)
         total_value += OrderCommission();
      else
      {
         total_value += (
            OrderProfit() +
            OrderSwap() +
            OrderCommission()
         );
      }
   }

   return(total_value);
}

int ReferenceResultCount(const string required_symbol,
                         const int required_magic,
                         const int result_mode,
                         const double epsilon)
{
   int count = 0;

   for(int position = OrdersTotal() - 1;
       position >= 0;
       position--)
   {
      if(!OrderSelect(position, SELECT_BY_POS, MODE_TRADES))
         continue;

      if(!ReferenceMatches(required_symbol,
                           required_magic))
      {
         continue;
      }

      double net_result =
         OrderProfit() +
         OrderSwap() +
         OrderCommission();

      if(result_mode == 1 &&
         net_result > epsilon)
      {
         count++;
      }
      else if(result_mode == -1 &&
              net_result < -epsilon)
      {
         count++;
      }
      else if(result_mode == 0 &&
              MathAbs(net_result) <= epsilon)
      {
         count++;
      }
   }

   return(count);
}

//+------------------------------------------------------------------+
//| Block 5 financial aggregate tests                                |
//+------------------------------------------------------------------+
void TestFinancialAggregates()
{
   string test_symbol = Symbol();
   int test_magic = 260713;
   double epsilon = 0.000000001;

   double expected_profit =
      ReferenceFinancialSum(
         test_symbol,
         test_magic,
         0);

   double expected_swap =
      ReferenceFinancialSum(
         test_symbol,
         test_magic,
         1);

   double expected_commission =
      ReferenceFinancialSum(
         test_symbol,
         test_magic,
         2);

   double expected_net =
      ReferenceFinancialSum(
         test_symbol,
         test_magic,
         3);

   double expected_buy_net =
      ReferenceFinancialSum(
         test_symbol,
         test_magic,
         3,
         OP_BUY);

   double expected_sell_net =
      ReferenceFinancialSum(
         test_symbol,
         test_magic,
         3,
         OP_SELL);

   ExpectDouble("SumProfit runtime match",
      BossOrder.SumProfit(
         test_symbol,
         test_magic),
      expected_profit);

   ExpectDouble("SumSwap runtime match",
      BossOrder.SumSwap(
         test_symbol,
         test_magic),
      expected_swap);

   ExpectDouble("SumCommission runtime match",
      BossOrder.SumCommission(
         test_symbol,
         test_magic),
      expected_commission);

   ExpectDouble("SumNetResult runtime match",
      BossOrder.SumNetResult(
         test_symbol,
         test_magic),
      expected_net);

   ExpectDouble("SumNetResult component invariant",
      BossOrder.SumNetResult(
         test_symbol,
         test_magic),
      BossOrder.SumProfit(
         test_symbol,
         test_magic) +
      BossOrder.SumSwap(
         test_symbol,
         test_magic) +
      BossOrder.SumCommission(
         test_symbol,
         test_magic));

   ExpectDouble("SumNetResultBuy runtime match",
      BossOrder.SumNetResultBuy(
         test_symbol,
         test_magic),
      expected_buy_net);

   ExpectDouble("SumNetResultSell runtime match",
      BossOrder.SumNetResultSell(
         test_symbol,
         test_magic),
      expected_sell_net);

   ExpectInt("CountProfitable runtime match",
      BossOrder.CountProfitable(
         test_symbol,
         test_magic,
         epsilon),
      ReferenceResultCount(
         test_symbol,
         test_magic,
         1,
         epsilon));

   ExpectInt("CountLosing runtime match",
      BossOrder.CountLosing(
         test_symbol,
         test_magic,
         epsilon),
      ReferenceResultCount(
         test_symbol,
         test_magic,
         -1,
         epsilon));

   ExpectInt("CountFlatResult runtime match",
      BossOrder.CountFlatResult(
         test_symbol,
         test_magic,
         epsilon),
      ReferenceResultCount(
         test_symbol,
         test_magic,
         0,
         epsilon));

   ExpectInt("Result count partition invariant",
      BossOrder.CountProfitable(
         test_symbol,
         test_magic,
         epsilon) +
      BossOrder.CountLosing(
         test_symbol,
         test_magic,
         epsilon) +
      BossOrder.CountFlatResult(
         test_symbol,
         test_magic,
         epsilon),
      BossOrder.CountAll(
         test_symbol,
         test_magic));
}

//+------------------------------------------------------------------+
//| Block 5 financial guard tests                                    |
//+------------------------------------------------------------------+
void TestFinancialGuards()
{
   string test_symbol = Symbol();
   int test_magic = 260713;

   ExpectDouble("SumProfit empty symbol zero",
      BossOrder.SumProfit("", test_magic),
      0.0);

   ExpectDouble("SumSwap invalid magic zero",
      BossOrder.SumSwap(test_symbol, -1),
      0.0);

   ExpectDouble("SumCommission empty symbol zero",
      BossOrder.SumCommission("", test_magic),
      0.0);

   ExpectDouble("SumNetResult invalid magic zero",
      BossOrder.SumNetResult(test_symbol, -1),
      0.0);

   ExpectDouble("SumNetResultType invalid type zero",
      BossOrder.SumNetResultType(
         test_symbol,
         test_magic,
         99),
      0.0);

   ExpectDouble("SumNetResultBuy empty symbol zero",
      BossOrder.SumNetResultBuy("", test_magic),
      0.0);

   ExpectDouble("SumNetResultSell invalid magic zero",
      BossOrder.SumNetResultSell(test_symbol, -1),
      0.0);

   ExpectInt("CountProfitable empty symbol zero",
      BossOrder.CountProfitable("", test_magic),
      0);

   ExpectInt("CountLosing invalid magic zero",
      BossOrder.CountLosing(test_symbol, -1),
      0);

   ExpectInt("CountFlatResult empty symbol zero",
      BossOrder.CountFlatResult("", test_magic),
      0);
}

//+------------------------------------------------------------------+
//| Block 5 type-net tests                                           |
//+------------------------------------------------------------------+
void TestFinancialByType()
{
   string test_symbol = Symbol();
   int test_magic = 260713;

   int supported_types[6];
   supported_types[0] = OP_BUY;
   supported_types[1] = OP_SELL;
   supported_types[2] = OP_BUYLIMIT;
   supported_types[3] = OP_SELLLIMIT;
   supported_types[4] = OP_BUYSTOP;
   supported_types[5] = OP_SELLSTOP;

   double type_sum = 0.0;

   for(int i = 0; i < 6; i++)
   {
      int order_type = supported_types[i];

      double expected =
         ReferenceFinancialSum(
            test_symbol,
            test_magic,
            3,
            order_type);

      double actual =
         BossOrder.SumNetResultType(
            test_symbol,
            test_magic,
            order_type);

      ExpectDouble(
         "SumNetResultType runtime type " +
         IntegerToString(order_type),
         actual,
         expected);

      type_sum += actual;
   }

   ExpectDouble("Type net partition invariant",
      type_sum,
      BossOrder.SumNetResult(
         test_symbol,
         test_magic));
}


//+------------------------------------------------------------------+
//| Independent protective-state references                          |
//+------------------------------------------------------------------+
bool ReferenceHasStopLoss()
{
   return(
      ReferenceIsMarket(OrderType()) &&
      OrderStopLoss() > 0.0
   );
}

bool ReferenceHasTakeProfit()
{
   return(
      ReferenceIsMarket(OrderType()) &&
      OrderTakeProfit() > 0.0
   );
}

bool ReferenceAtBreakEven(const double epsilon)
{
   if(!ReferenceHasStopLoss())
      return(false);

   return(
      MathAbs(OrderStopLoss() - OrderOpenPrice()) <= epsilon
   );
}

bool ReferenceLocksProfit(const double epsilon)
{
   if(!ReferenceHasStopLoss())
      return(false);

   if(OrderType() == OP_BUY)
   {
      return(
         OrderStopLoss() >
         OrderOpenPrice() + epsilon
      );
   }

   if(OrderType() == OP_SELL)
   {
      return(
         OrderStopLoss() <
         OrderOpenPrice() - epsilon
      );
   }

   return(false);
}

bool ReferenceStopIsProtective(const double epsilon)
{
   return(
      ReferenceAtBreakEven(epsilon) ||
      ReferenceLocksProfit(epsilon)
   );
}

int ReferenceProtectionCount(const string required_symbol,
                             const int required_magic,
                             const int mode,
                             const double epsilon)
{
   int count = 0;

   for(int position = OrdersTotal() - 1;
       position >= 0;
       position--)
   {
      if(!OrderSelect(position, SELECT_BY_POS, MODE_TRADES))
         continue;

      if(!ReferenceMatches(required_symbol,
                           required_magic))
      {
         continue;
      }

      if(!ReferenceIsMarket(OrderType()))
         continue;

      bool match = false;

      if(mode == 1)
         match = ReferenceHasStopLoss();
      else if(mode == 2)
         match = !ReferenceHasStopLoss();
      else if(mode == 3)
         match = ReferenceHasTakeProfit();
      else if(mode == 4)
         match = !ReferenceHasTakeProfit();
      else if(mode == 5)
         match = ReferenceAtBreakEven(epsilon);
      else if(mode == 6)
         match = ReferenceLocksProfit(epsilon);

      if(match)
         count++;
   }

   return(count);
}

double ReferenceProtectionLots(const string required_symbol,
                               const int required_magic,
                               const bool protected_only,
                               const double epsilon)
{
   double total_lots = 0.0;

   for(int position = OrdersTotal() - 1;
       position >= 0;
       position--)
   {
      if(!OrderSelect(position, SELECT_BY_POS, MODE_TRADES))
         continue;

      if(!ReferenceMatches(required_symbol,
                           required_magic))
      {
         continue;
      }

      if(!ReferenceIsMarket(OrderType()))
         continue;

      bool is_protected =
         ReferenceStopIsProtective(epsilon);

      if(protected_only != is_protected)
         continue;

      if(OrderLots() > 0.0)
         total_lots += OrderLots();
   }

   return(total_lots);
}

//+------------------------------------------------------------------+
//| Block 6 selected protection tests                                |
//+------------------------------------------------------------------+
void TestSelectedProtectionState()
{
   int total = BossOrder.PoolTotal();
   double epsilon = 0.000000001;

   for(int position = 0;
       position < total;
       position++)
   {
      if(!BossOrder.SelectOpenByPosition(position))
         continue;

      string suffix =
         " pool position " +
         IntegerToString(position);

      bool expected_has_sl =
         ReferenceHasStopLoss();

      bool expected_has_tp =
         ReferenceHasTakeProfit();

      double expected_sl_distance = 0.0;

      if(expected_has_sl)
      {
         expected_sl_distance =
            MathAbs(
               OrderOpenPrice() -
               OrderStopLoss()
            );
      }

      double expected_tp_distance = 0.0;

      if(expected_has_tp)
      {
         expected_tp_distance =
            MathAbs(
               OrderTakeProfit() -
               OrderOpenPrice()
            );
      }

      ExpectBool("SelectedHasStopLoss" + suffix,
         BossOrder.SelectedHasStopLoss(),
         expected_has_sl);

      ExpectBool("SelectedHasTakeProfit" + suffix,
         BossOrder.SelectedHasTakeProfit(),
         expected_has_tp);

      ExpectDouble("SelectedStopDistancePrice" + suffix,
         BossOrder.SelectedStopDistancePrice(),
         expected_sl_distance);

      ExpectDouble("SelectedTakeProfitDistancePrice" + suffix,
         BossOrder.SelectedTakeProfitDistancePrice(),
         expected_tp_distance);

      ExpectBool("SelectedAtBreakEven" + suffix,
         BossOrder.SelectedAtBreakEven(epsilon),
         ReferenceAtBreakEven(epsilon));

      ExpectBool("SelectedLocksProfit" + suffix,
         BossOrder.SelectedLocksProfit(epsilon),
         ReferenceLocksProfit(epsilon));

      ExpectBool("SelectedStopIsProtective" + suffix,
         BossOrder.SelectedStopIsProtective(epsilon),
         ReferenceStopIsProtective(epsilon));
   }
}

//+------------------------------------------------------------------+
//| Block 6 aggregate protection tests                               |
//+------------------------------------------------------------------+
void TestProtectionAggregates()
{
   string test_symbol = Symbol();
   int test_magic = 260713;
   double epsilon = 0.000000001;

   int expected_with_sl =
      ReferenceProtectionCount(
         test_symbol,
         test_magic,
         1,
         epsilon);

   int expected_without_sl =
      ReferenceProtectionCount(
         test_symbol,
         test_magic,
         2,
         epsilon);

   int expected_with_tp =
      ReferenceProtectionCount(
         test_symbol,
         test_magic,
         3,
         epsilon);

   int expected_without_tp =
      ReferenceProtectionCount(
         test_symbol,
         test_magic,
         4,
         epsilon);

   int expected_break_even =
      ReferenceProtectionCount(
         test_symbol,
         test_magic,
         5,
         epsilon);

   int expected_locked =
      ReferenceProtectionCount(
         test_symbol,
         test_magic,
         6,
         epsilon);

   double expected_protected_lots =
      ReferenceProtectionLots(
         test_symbol,
         test_magic,
         true,
         epsilon);

   double expected_unprotected_lots =
      ReferenceProtectionLots(
         test_symbol,
         test_magic,
         false,
         epsilon);

   ExpectInt("CountWithStopLoss runtime match",
      BossOrder.CountWithStopLoss(
         test_symbol,
         test_magic),
      expected_with_sl);

   ExpectInt("CountWithoutStopLoss runtime match",
      BossOrder.CountWithoutStopLoss(
         test_symbol,
         test_magic),
      expected_without_sl);

   ExpectInt("StopLoss count partition invariant",
      BossOrder.CountWithStopLoss(
         test_symbol,
         test_magic) +
      BossOrder.CountWithoutStopLoss(
         test_symbol,
         test_magic),
      BossOrder.CountMarket(
         test_symbol,
         test_magic));

   ExpectInt("CountWithTakeProfit runtime match",
      BossOrder.CountWithTakeProfit(
         test_symbol,
         test_magic),
      expected_with_tp);

   ExpectInt("CountWithoutTakeProfit runtime match",
      BossOrder.CountWithoutTakeProfit(
         test_symbol,
         test_magic),
      expected_without_tp);

   ExpectInt("TakeProfit count partition invariant",
      BossOrder.CountWithTakeProfit(
         test_symbol,
         test_magic) +
      BossOrder.CountWithoutTakeProfit(
         test_symbol,
         test_magic),
      BossOrder.CountMarket(
         test_symbol,
         test_magic));

   ExpectInt("CountBreakEven runtime match",
      BossOrder.CountBreakEven(
         test_symbol,
         test_magic,
         epsilon),
      expected_break_even);

   ExpectInt("CountLockingProfit runtime match",
      BossOrder.CountLockingProfit(
         test_symbol,
         test_magic,
         epsilon),
      expected_locked);

   ExpectDouble("SumProtectedMarketLots runtime match",
      BossOrder.SumProtectedMarketLots(
         test_symbol,
         test_magic,
         epsilon),
      expected_protected_lots);

   ExpectDouble("SumUnprotectedMarketLots runtime match",
      BossOrder.SumUnprotectedMarketLots(
         test_symbol,
         test_magic,
         epsilon),
      expected_unprotected_lots);

   ExpectDouble("Protection lot partition invariant",
      BossOrder.SumProtectedMarketLots(
         test_symbol,
         test_magic,
         epsilon) +
      BossOrder.SumUnprotectedMarketLots(
         test_symbol,
         test_magic,
         epsilon),
      BossOrder.SumLotsMarket(
         test_symbol,
         test_magic));
}

//+------------------------------------------------------------------+
//| Block 6 protection guard tests                                   |
//+------------------------------------------------------------------+
void TestProtectionGuards()
{
   string test_symbol = Symbol();
   int test_magic = 260713;

   ExpectInt("CountWithStopLoss empty symbol zero",
      BossOrder.CountWithStopLoss("", test_magic),
      0);

   ExpectInt("CountWithoutStopLoss invalid magic zero",
      BossOrder.CountWithoutStopLoss(test_symbol, -1),
      0);

   ExpectInt("CountWithTakeProfit empty symbol zero",
      BossOrder.CountWithTakeProfit("", test_magic),
      0);

   ExpectInt("CountWithoutTakeProfit invalid magic zero",
      BossOrder.CountWithoutTakeProfit(test_symbol, -1),
      0);

   ExpectInt("CountBreakEven empty symbol zero",
      BossOrder.CountBreakEven("", test_magic),
      0);

   ExpectInt("CountLockingProfit invalid magic zero",
      BossOrder.CountLockingProfit(test_symbol, -1),
      0);

   ExpectDouble("SumProtectedMarketLots empty symbol zero",
      BossOrder.SumProtectedMarketLots("", test_magic),
      0.0);

   ExpectDouble("SumUnprotectedMarketLots invalid magic zero",
      BossOrder.SumUnprotectedMarketLots(test_symbol, -1),
      0.0);
}


//+------------------------------------------------------------------+
//| Independent price analytics references                           |
//+------------------------------------------------------------------+
double ReferenceWeightedAverageOpenPrice(
   const string required_symbol,
   const int required_magic,
   const int required_type = -1)
{
   double weighted_sum = 0.0;
   double total_lots = 0.0;

   for(int position = OrdersTotal() - 1;
       position >= 0;
       position--)
   {
      if(!OrderSelect(position, SELECT_BY_POS, MODE_TRADES))
         continue;

      if(!ReferenceMatches(required_symbol,
                           required_magic))
      {
         continue;
      }

      if(!ReferenceIsMarket(OrderType()))
         continue;

      if(required_type >= 0 &&
         OrderType() != required_type)
      {
         continue;
      }

      double lots = OrderLots();

      if(lots <= 0.0)
         continue;

      weighted_sum += OrderOpenPrice() * lots;
      total_lots += lots;
   }

   if(total_lots <= 0.0)
      return(0.0);

   return(weighted_sum / total_lots);
}

double ReferenceExtremeMarketOpenPrice(
   const string required_symbol,
   const int required_magic,
   const bool want_minimum)
{
   bool found = false;
   double found_price = 0.0;

   for(int position = OrdersTotal() - 1;
       position >= 0;
       position--)
   {
      if(!OrderSelect(position, SELECT_BY_POS, MODE_TRADES))
         continue;

      if(!ReferenceMatches(required_symbol,
                           required_magic))
      {
         continue;
      }

      if(!ReferenceIsMarket(OrderType()))
         continue;

      double open_price = OrderOpenPrice();

      if(!found)
      {
         found = true;
         found_price = open_price;
         continue;
      }

      if(want_minimum &&
         open_price < found_price)
      {
         found_price = open_price;
      }
      else if(!want_minimum &&
              open_price > found_price)
      {
         found_price = open_price;
      }
   }

   if(!found)
      return(0.0);

   return(found_price);
}

//+------------------------------------------------------------------+
//| Independent age analytics references                             |
//+------------------------------------------------------------------+
int ReferenceAgeFromOpenTime(
   const datetime open_time,
   const datetime current_time)
{
   if(open_time <= 0)
      return(0);

   if(current_time <= open_time)
      return(0);

   return((int)(current_time - open_time));
}

double ReferenceAverageAgeSeconds(
   const string required_symbol,
   const int required_magic,
   const datetime current_time)
{
   double age_sum = 0.0;
   int count = 0;

   for(int position = OrdersTotal() - 1;
       position >= 0;
       position--)
   {
      if(!OrderSelect(position, SELECT_BY_POS, MODE_TRADES))
         continue;

      if(!ReferenceMatches(required_symbol,
                           required_magic))
      {
         continue;
      }

      age_sum += ReferenceAgeFromOpenTime(
         OrderOpenTime(),
         current_time);

      count++;
   }

   if(count <= 0)
      return(0.0);

   return(age_sum / count);
}

//+------------------------------------------------------------------+
//| Block 7 entry-price analytics tests                              |
//+------------------------------------------------------------------+
void TestEntryPriceAnalytics()
{
   string test_symbol = Symbol();
   int test_magic = 260713;

   double expected_all =
      ReferenceWeightedAverageOpenPrice(
         test_symbol,
         test_magic);

   double expected_buy =
      ReferenceWeightedAverageOpenPrice(
         test_symbol,
         test_magic,
         OP_BUY);

   double expected_sell =
      ReferenceWeightedAverageOpenPrice(
         test_symbol,
         test_magic,
         OP_SELL);

   double expected_min =
      ReferenceExtremeMarketOpenPrice(
         test_symbol,
         test_magic,
         true);

   double expected_max =
      ReferenceExtremeMarketOpenPrice(
         test_symbol,
         test_magic,
         false);

   ExpectDouble("WeightedAverageOpenPrice runtime match",
      BossOrder.WeightedAverageOpenPrice(
         test_symbol,
         test_magic),
      expected_all);

   ExpectDouble("WeightedAverageBuyOpenPrice runtime match",
      BossOrder.WeightedAverageBuyOpenPrice(
         test_symbol,
         test_magic),
      expected_buy);

   ExpectDouble("WeightedAverageSellOpenPrice runtime match",
      BossOrder.WeightedAverageSellOpenPrice(
         test_symbol,
         test_magic),
      expected_sell);

   ExpectDouble("WeightedAverageOpenPriceType buy match",
      BossOrder.WeightedAverageOpenPriceType(
         test_symbol,
         test_magic,
         OP_BUY),
      expected_buy);

   ExpectDouble("WeightedAverageOpenPriceType sell match",
      BossOrder.WeightedAverageOpenPriceType(
         test_symbol,
         test_magic,
         OP_SELL),
      expected_sell);

   ExpectDouble("MinMarketOpenPrice runtime match",
      BossOrder.MinMarketOpenPrice(
         test_symbol,
         test_magic),
      expected_min);

   ExpectDouble("MaxMarketOpenPrice runtime match",
      BossOrder.MaxMarketOpenPrice(
         test_symbol,
         test_magic),
      expected_max);

   if(BossOrder.CountMarket(
         test_symbol,
         test_magic) > 0)
   {
      ExpectBool("Min open not above max open",
         BossOrder.MinMarketOpenPrice(
            test_symbol,
            test_magic) <=
         BossOrder.MaxMarketOpenPrice(
            test_symbol,
            test_magic),
         true);

      ExpectBool("Weighted average inside open range",
         BossOrder.WeightedAverageOpenPrice(
            test_symbol,
            test_magic) >=
         BossOrder.MinMarketOpenPrice(
            test_symbol,
            test_magic) &&
         BossOrder.WeightedAverageOpenPrice(
            test_symbol,
            test_magic) <=
         BossOrder.MaxMarketOpenPrice(
            test_symbol,
            test_magic),
         true);
   }
}

//+------------------------------------------------------------------+
//| Block 7 age analytics tests                                      |
//+------------------------------------------------------------------+
void TestAgeAnalytics()
{
   string test_symbol = Symbol();
   int test_magic = 260713;

   datetime fixed_time = TimeCurrent();

   datetime expected_oldest_time =
      ReferenceTicketOpenTime(
         ReferenceChronologyTicket(
            test_symbol,
            test_magic,
            true));

   datetime expected_newest_time =
      ReferenceTicketOpenTime(
         ReferenceChronologyTicket(
            test_symbol,
            test_magic,
            false));

   int expected_oldest_age =
      ReferenceAgeFromOpenTime(
         expected_oldest_time,
         fixed_time);

   int expected_newest_age =
      ReferenceAgeFromOpenTime(
         expected_newest_time,
         fixed_time);

   double expected_average_age =
      ReferenceAverageAgeSeconds(
         test_symbol,
         test_magic,
         fixed_time);

   ExpectInt("OldestAgeSeconds runtime match",
      BossOrder.OldestAgeSeconds(
         test_symbol,
         test_magic,
         fixed_time),
      expected_oldest_age);

   ExpectInt("NewestAgeSeconds runtime match",
      BossOrder.NewestAgeSeconds(
         test_symbol,
         test_magic,
         fixed_time),
      expected_newest_age);

   ExpectDouble("AverageAgeSeconds runtime match",
      BossOrder.AverageAgeSeconds(
         test_symbol,
         test_magic,
         fixed_time),
      expected_average_age);

   ExpectBool("Oldest age not below newest age",
      BossOrder.OldestAgeSeconds(
         test_symbol,
         test_magic,
         fixed_time) >=
      BossOrder.NewestAgeSeconds(
         test_symbol,
         test_magic,
         fixed_time),
      true);

   int actual_oldest_now =
      BossOrder.OldestAgeSecondsNow(
         test_symbol,
         test_magic);

   int actual_newest_now =
      BossOrder.NewestAgeSecondsNow(
         test_symbol,
         test_magic);

   double actual_average_now =
      BossOrder.AverageAgeSecondsNow(
         test_symbol,
         test_magic);

   ExpectBool("OldestAgeSecondsNow close to fixed",
      MathAbs(actual_oldest_now -
              expected_oldest_age) <= 1,
      true);

   ExpectBool("NewestAgeSecondsNow close to fixed",
      MathAbs(actual_newest_now -
              expected_newest_age) <= 1,
      true);

   ExpectBool("AverageAgeSecondsNow close to fixed",
      MathAbs(actual_average_now -
              expected_average_age) <= 1.0,
      true);
}

//+------------------------------------------------------------------+
//| Block 7 analytics guard tests                                    |
//+------------------------------------------------------------------+
void TestAnalyticsGuards()
{
   string test_symbol = Symbol();
   int test_magic = 260713;
   datetime fixed_time = TimeCurrent();

   ExpectDouble("WeightedAverageOpenPrice empty symbol zero",
      BossOrder.WeightedAverageOpenPrice(
         "",
         test_magic),
      0.0);

   ExpectDouble("WeightedAverageOpenPriceType invalid type zero",
      BossOrder.WeightedAverageOpenPriceType(
         test_symbol,
         test_magic,
         OP_BUYLIMIT),
      0.0);

   ExpectDouble("WeightedAverageBuyOpenPrice invalid magic zero",
      BossOrder.WeightedAverageBuyOpenPrice(
         test_symbol,
         -1),
      0.0);

   ExpectDouble("WeightedAverageSellOpenPrice empty symbol zero",
      BossOrder.WeightedAverageSellOpenPrice(
         "",
         test_magic),
      0.0);

   ExpectDouble("MinMarketOpenPrice invalid magic zero",
      BossOrder.MinMarketOpenPrice(
         test_symbol,
         -1),
      0.0);

   ExpectDouble("MaxMarketOpenPrice empty symbol zero",
      BossOrder.MaxMarketOpenPrice(
         "",
         test_magic),
      0.0);

   ExpectInt("OldestAgeSeconds empty symbol zero",
      BossOrder.OldestAgeSeconds(
         "",
         test_magic,
         fixed_time),
      0);

   ExpectInt("NewestAgeSeconds invalid magic zero",
      BossOrder.NewestAgeSeconds(
         test_symbol,
         -1,
         fixed_time),
      0);

   ExpectDouble("AverageAgeSeconds empty symbol zero",
      BossOrder.AverageAgeSeconds(
         "",
         test_magic,
         fixed_time),
      0.0);

   ExpectInt("OldestAgeSecondsNow empty symbol zero",
      BossOrder.OldestAgeSecondsNow(
         "",
         test_magic),
      0);

   ExpectInt("NewestAgeSecondsNow invalid magic zero",
      BossOrder.NewestAgeSecondsNow(
         test_symbol,
         -1),
      0);

   ExpectDouble("AverageAgeSecondsNow empty symbol zero",
      BossOrder.AverageAgeSecondsNow(
         "",
         test_magic),
      0.0);
}

//+------------------------------------------------------------------+
//| Expert initialization                                            |
//+------------------------------------------------------------------+
int OnInit()
{
   Print("BossR_Order Block 7 verification started");

   TestPoolAndSelection();
   TestFilterGuards();
   TestRuntimeReferenceComparison();
   TestSelectedOrderState();
   TestSelectedMetadataAccessors();
   TestMetadataAcrossPool();
   TestDirectionalExposure();
   TestOrderChronology();
   TestLookupGuards();
   TestNthMatchTraversal();
   TestTypeAndDirectionLookup();
   TestFinancialAggregates();
   TestFinancialGuards();
   TestFinancialByType();
   TestSelectedProtectionState();
   TestProtectionAggregates();
   TestProtectionGuards();
   TestEntryPriceAnalytics();
   TestAgeAnalytics();
   TestAnalyticsGuards();

   Print("BossR_Order_Verify_Block7_ANALYTICS_FULL ",
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
