//+------------------------------------------------------------------+
//| BossR_Order_Block7_ANALYTICS_FULL.mqh                           |
//| BossR Framework - Order pool utilities                           |
//| Block 7                                                          |
//| MT4 only                                                         |
//+------------------------------------------------------------------+
#ifndef __BOSSR_ORDER_BLOCK7_ANALYTICS_FULL_MQH__
#define __BOSSR_ORDER_BLOCK7_ANALYTICS_FULL_MQH__

#include <BossR\BossR_Trade.mqh>

//+------------------------------------------------------------------+
//| C_BossR_Order                                                    |
//+------------------------------------------------------------------+
class C_BossR_Order
{
private:
   C_BossR_Trade m_trade;

   bool IsFilterValid(const string required_symbol,
                      const int required_magic) const
   {
      if(StringLen(required_symbol) <= 0)
         return(false);

      return(m_trade.IsValidMagicNumber(required_magic));
   }

   bool SelectedOrderMatches(const string required_symbol,
                             const int required_magic) const
   {
      return(
         m_trade.MatchesTradeIdentity(
            OrderSymbol(),
            OrderMagicNumber(),
            required_symbol,
            required_magic
         )
      );
   }

public:
   // ---------------------------------------------------------------
   // Trade-pool size
   // ---------------------------------------------------------------
   int PoolTotal() const
   {
      int total = OrdersTotal();

      if(total < 0)
         return(0);

      return(total);
   }

   // ---------------------------------------------------------------
   // Selection helpers
   // ---------------------------------------------------------------
   bool SelectOpenByPosition(const int position) const
   {
      if(position < 0)
         return(false);

      if(position >= PoolTotal())
         return(false);

      return(OrderSelect(position, SELECT_BY_POS, MODE_TRADES));
   }

   bool SelectOpenByTicket(const int ticket) const
   {
      if(ticket <= 0)
         return(false);

      return(OrderSelect(ticket, SELECT_BY_TICKET, MODE_TRADES));
   }

   // ---------------------------------------------------------------
   // Selected-order classification
   // ---------------------------------------------------------------
   bool SelectedIsMarket() const
   {
      return(m_trade.IsMarketOrderType(OrderType()));
   }

   bool SelectedIsPending() const
   {
      return(m_trade.IsPendingOrderType(OrderType()));
   }

   bool SelectedMatches(const string required_symbol,
                        const int required_magic) const
   {
      if(!IsFilterValid(required_symbol, required_magic))
         return(false);

      return(SelectedOrderMatches(required_symbol,
                                  required_magic));
   }


   // ---------------------------------------------------------------
   // Selected-order metadata accessors
   // ---------------------------------------------------------------
   int SelectedTicket() const
   {
      return(OrderTicket());
   }

   int SelectedType() const
   {
      return(OrderType());
   }

   string SelectedSymbol() const
   {
      return(OrderSymbol());
   }

   int SelectedMagicNumber() const
   {
      return(OrderMagicNumber());
   }

   string SelectedComment() const
   {
      return(OrderComment());
   }

   double SelectedLots() const
   {
      return(OrderLots());
   }

   double SelectedOpenPrice() const
   {
      return(OrderOpenPrice());
   }

   datetime SelectedOpenTime() const
   {
      return(OrderOpenTime());
   }

   double SelectedStopLoss() const
   {
      return(OrderStopLoss());
   }

   double SelectedTakeProfit() const
   {
      return(OrderTakeProfit());
   }

   datetime SelectedExpiration() const
   {
      return(OrderExpiration());
   }

   double SelectedProfit() const
   {
      return(OrderProfit());
   }

   double SelectedSwap() const
   {
      return(OrderSwap());
   }

   double SelectedCommission() const
   {
      return(OrderCommission());
   }

   double SelectedNetResult() const
   {
      return(
         SelectedProfit() +
         SelectedSwap() +
         SelectedCommission()
      );
   }

   int SelectedAgeSeconds(const datetime current_time) const
   {
      datetime open_time = SelectedOpenTime();

      if(open_time <= 0)
         return(0);

      if(current_time <= open_time)
         return(0);

      return((int)(current_time - open_time));
   }

   int SelectedAgeSecondsNow() const
   {
      return(SelectedAgeSeconds(TimeCurrent()));
   }

   // ---------------------------------------------------------------
   // Identity-filtered counts
   // ---------------------------------------------------------------
   int CountAll(const string required_symbol,
                const int required_magic) const
   {
      if(!IsFilterValid(required_symbol, required_magic))
         return(0);

      int count = 0;
      int total = PoolTotal();

      for(int position = total - 1;
          position >= 0;
          position--)
      {
         if(!SelectOpenByPosition(position))
            continue;

         if(!SelectedOrderMatches(required_symbol,
                                  required_magic))
         {
            continue;
         }

         count++;
      }

      return(count);
   }

   int CountMarket(const string required_symbol,
                   const int required_magic) const
   {
      if(!IsFilterValid(required_symbol, required_magic))
         return(0);

      int count = 0;
      int total = PoolTotal();

      for(int position = total - 1;
          position >= 0;
          position--)
      {
         if(!SelectOpenByPosition(position))
            continue;

         if(!SelectedOrderMatches(required_symbol,
                                  required_magic))
         {
            continue;
         }

         if(!SelectedIsMarket())
            continue;

         count++;
      }

      return(count);
   }

   int CountPending(const string required_symbol,
                    const int required_magic) const
   {
      if(!IsFilterValid(required_symbol, required_magic))
         return(0);

      int count = 0;
      int total = PoolTotal();

      for(int position = total - 1;
          position >= 0;
          position--)
      {
         if(!SelectOpenByPosition(position))
            continue;

         if(!SelectedOrderMatches(required_symbol,
                                  required_magic))
         {
            continue;
         }

         if(!SelectedIsPending())
            continue;

         count++;
      }

      return(count);
   }

   int CountType(const string required_symbol,
                 const int required_magic,
                 const int required_order_type) const
   {
      if(!IsFilterValid(required_symbol, required_magic))
         return(0);

      if(!m_trade.IsSupportedOrderType(required_order_type))
         return(0);

      int count = 0;
      int total = PoolTotal();

      for(int position = total - 1;
          position >= 0;
          position--)
      {
         if(!SelectOpenByPosition(position))
            continue;

         if(!SelectedOrderMatches(required_symbol,
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

   // ---------------------------------------------------------------
   // Presence helpers
   // ---------------------------------------------------------------
   bool HasAny(const string required_symbol,
               const int required_magic) const
   {
      return(CountAll(required_symbol,
                      required_magic) > 0);
   }

   bool HasMarket(const string required_symbol,
                  const int required_magic) const
   {
      return(CountMarket(required_symbol,
                         required_magic) > 0);
   }

   bool HasPending(const string required_symbol,
                   const int required_magic) const
   {
      return(CountPending(required_symbol,
                          required_magic) > 0);
   }

   // ---------------------------------------------------------------
   // Lot aggregation
   // ---------------------------------------------------------------
   double SumLotsAll(const string required_symbol,
                     const int required_magic) const
   {
      if(!IsFilterValid(required_symbol, required_magic))
         return(0.0);

      double total_lots = 0.0;
      int total = PoolTotal();

      for(int position = total - 1;
          position >= 0;
          position--)
      {
         if(!SelectOpenByPosition(position))
            continue;

         if(!SelectedOrderMatches(required_symbol,
                                  required_magic))
         {
            continue;
         }

         double lots = OrderLots();

         if(lots > 0.0)
            total_lots += lots;
      }

      return(total_lots);
   }

   double SumLotsMarket(const string required_symbol,
                        const int required_magic) const
   {
      if(!IsFilterValid(required_symbol, required_magic))
         return(0.0);

      double total_lots = 0.0;
      int total = PoolTotal();

      for(int position = total - 1;
          position >= 0;
          position--)
      {
         if(!SelectOpenByPosition(position))
            continue;

         if(!SelectedOrderMatches(required_symbol,
                                  required_magic))
         {
            continue;
         }

         if(!SelectedIsMarket())
            continue;

         double lots = OrderLots();

         if(lots > 0.0)
            total_lots += lots;
      }

      return(total_lots);
   }

   double SumLotsPending(const string required_symbol,
                         const int required_magic) const
   {
      if(!IsFilterValid(required_symbol, required_magic))
         return(0.0);

      double total_lots = 0.0;
      int total = PoolTotal();

      for(int position = total - 1;
          position >= 0;
          position--)
      {
         if(!SelectOpenByPosition(position))
            continue;

         if(!SelectedOrderMatches(required_symbol,
                                  required_magic))
         {
            continue;
         }

         if(!SelectedIsPending())
            continue;

         double lots = OrderLots();

         if(lots > 0.0)
            total_lots += lots;
      }

      return(total_lots);
   }


   // ---------------------------------------------------------------
   // Directional counts and exposure
   // ---------------------------------------------------------------
   int CountBuy(const string required_symbol,
                const int required_magic) const
   {
      return(CountType(required_symbol,
                       required_magic,
                       OP_BUY));
   }

   int CountSell(const string required_symbol,
                 const int required_magic) const
   {
      return(CountType(required_symbol,
                       required_magic,
                       OP_SELL));
   }

   bool HasBuy(const string required_symbol,
               const int required_magic) const
   {
      return(CountBuy(required_symbol,
                      required_magic) > 0);
   }

   bool HasSell(const string required_symbol,
                const int required_magic) const
   {
      return(CountSell(required_symbol,
                       required_magic) > 0);
   }

   double SumLotsBuy(const string required_symbol,
                     const int required_magic) const
   {
      if(!IsFilterValid(required_symbol, required_magic))
         return(0.0);

      double total_lots = 0.0;
      int total = PoolTotal();

      for(int position = total - 1;
          position >= 0;
          position--)
      {
         if(!SelectOpenByPosition(position))
            continue;

         if(!SelectedOrderMatches(required_symbol,
                                  required_magic))
         {
            continue;
         }

         if(OrderType() != OP_BUY)
            continue;

         if(OrderLots() > 0.0)
            total_lots += OrderLots();
      }

      return(total_lots);
   }

   double SumLotsSell(const string required_symbol,
                      const int required_magic) const
   {
      if(!IsFilterValid(required_symbol, required_magic))
         return(0.0);

      double total_lots = 0.0;
      int total = PoolTotal();

      for(int position = total - 1;
          position >= 0;
          position--)
      {
         if(!SelectOpenByPosition(position))
            continue;

         if(!SelectedOrderMatches(required_symbol,
                                  required_magic))
         {
            continue;
         }

         if(OrderType() != OP_SELL)
            continue;

         if(OrderLots() > 0.0)
            total_lots += OrderLots();
      }

      return(total_lots);
   }

   double NetMarketLots(const string required_symbol,
                        const int required_magic) const
   {
      return(
         SumLotsBuy(required_symbol, required_magic) -
         SumLotsSell(required_symbol, required_magic)
      );
   }

   int ExposureDirection(const string required_symbol,
                         const int required_magic,
                         const double epsilon = 0.000000001) const
   {
      double net_lots =
         NetMarketLots(required_symbol,
                       required_magic);

      if(net_lots > epsilon)
         return(1);

      if(net_lots < -epsilon)
         return(-1);

      return(0);
   }

   // ---------------------------------------------------------------
   // Order chronology
   // ---------------------------------------------------------------
   int OldestTicket(const string required_symbol,
                    const int required_magic) const
   {
      if(!IsFilterValid(required_symbol, required_magic))
         return(-1);

      int found_ticket = -1;
      datetime found_time = 0;
      int total = PoolTotal();

      for(int position = 0;
          position < total;
          position++)
      {
         if(!SelectOpenByPosition(position))
            continue;

         if(!SelectedOrderMatches(required_symbol,
                                  required_magic))
         {
            continue;
         }

         datetime open_time = OrderOpenTime();
         int ticket = OrderTicket();

         if(ticket <= 0)
            continue;

         if(found_ticket < 0 ||
            open_time < found_time ||
            (open_time == found_time && ticket < found_ticket))
         {
            found_ticket = ticket;
            found_time = open_time;
         }
      }

      return(found_ticket);
   }

   int NewestTicket(const string required_symbol,
                    const int required_magic) const
   {
      if(!IsFilterValid(required_symbol, required_magic))
         return(-1);

      int found_ticket = -1;
      datetime found_time = 0;
      int total = PoolTotal();

      for(int position = 0;
          position < total;
          position++)
      {
         if(!SelectOpenByPosition(position))
            continue;

         if(!SelectedOrderMatches(required_symbol,
                                  required_magic))
         {
            continue;
         }

         datetime open_time = OrderOpenTime();
         int ticket = OrderTicket();

         if(ticket <= 0)
            continue;

         if(found_ticket < 0 ||
            open_time > found_time ||
            (open_time == found_time && ticket > found_ticket))
         {
            found_ticket = ticket;
            found_time = open_time;
         }
      }

      return(found_ticket);
   }

   datetime OldestOpenTime(const string required_symbol,
                           const int required_magic) const
   {
      int ticket = OldestTicket(required_symbol,
                                required_magic);

      if(ticket <= 0)
         return(0);

      if(!SelectOpenByTicket(ticket))
         return(0);

      return(OrderOpenTime());
   }

   datetime NewestOpenTime(const string required_symbol,
                           const int required_magic) const
   {
      int ticket = NewestTicket(required_symbol,
                                required_magic);

      if(ticket <= 0)
         return(0);

      if(!SelectOpenByTicket(ticket))
         return(0);

      return(OrderOpenTime());
   }


   // ---------------------------------------------------------------
   // Deterministic filtered ticket lookup
   // ---------------------------------------------------------------
   int TicketAtMatch(const string required_symbol,
                     const int required_magic,
                     const int match_index) const
   {
      if(!IsFilterValid(required_symbol, required_magic))
         return(-1);

      if(match_index < 0)
         return(-1);

      int matched = 0;
      int total = PoolTotal();

      for(int position = 0;
          position < total;
          position++)
      {
         if(!SelectOpenByPosition(position))
            continue;

         if(!SelectedOrderMatches(required_symbol,
                                  required_magic))
         {
            continue;
         }

         if(matched == match_index)
            return(OrderTicket());

         matched++;
      }

      return(-1);
   }

   int MarketTicketAtMatch(const string required_symbol,
                           const int required_magic,
                           const int match_index) const
   {
      if(!IsFilterValid(required_symbol, required_magic))
         return(-1);

      if(match_index < 0)
         return(-1);

      int matched = 0;
      int total = PoolTotal();

      for(int position = 0;
          position < total;
          position++)
      {
         if(!SelectOpenByPosition(position))
            continue;

         if(!SelectedOrderMatches(required_symbol,
                                  required_magic))
         {
            continue;
         }

         if(!SelectedIsMarket())
            continue;

         if(matched == match_index)
            return(OrderTicket());

         matched++;
      }

      return(-1);
   }

   int PendingTicketAtMatch(const string required_symbol,
                            const int required_magic,
                            const int match_index) const
   {
      if(!IsFilterValid(required_symbol, required_magic))
         return(-1);

      if(match_index < 0)
         return(-1);

      int matched = 0;
      int total = PoolTotal();

      for(int position = 0;
          position < total;
          position++)
      {
         if(!SelectOpenByPosition(position))
            continue;

         if(!SelectedOrderMatches(required_symbol,
                                  required_magic))
         {
            continue;
         }

         if(!SelectedIsPending())
            continue;

         if(matched == match_index)
            return(OrderTicket());

         matched++;
      }

      return(-1);
   }

   int TypeTicketAtMatch(const string required_symbol,
                         const int required_magic,
                         const int required_order_type,
                         const int match_index) const
   {
      if(!IsFilterValid(required_symbol, required_magic))
         return(-1);

      if(!m_trade.IsSupportedOrderType(required_order_type))
         return(-1);

      if(match_index < 0)
         return(-1);

      int matched = 0;
      int total = PoolTotal();

      for(int position = 0;
          position < total;
          position++)
      {
         if(!SelectOpenByPosition(position))
            continue;

         if(!SelectedOrderMatches(required_symbol,
                                  required_magic))
         {
            continue;
         }

         if(OrderType() != required_order_type)
            continue;

         if(matched == match_index)
            return(OrderTicket());

         matched++;
      }

      return(-1);
   }

   int BuyTicketAtMatch(const string required_symbol,
                        const int required_magic,
                        const int match_index) const
   {
      return(TypeTicketAtMatch(required_symbol,
                               required_magic,
                               OP_BUY,
                               match_index));
   }

   int SellTicketAtMatch(const string required_symbol,
                         const int required_magic,
                         const int match_index) const
   {
      return(TypeTicketAtMatch(required_symbol,
                               required_magic,
                               OP_SELL,
                               match_index));
   }

   // ---------------------------------------------------------------
   // Deterministic filtered selection
   // ---------------------------------------------------------------
   bool SelectMatch(const string required_symbol,
                    const int required_magic,
                    const int match_index) const
   {
      int ticket = TicketAtMatch(required_symbol,
                                 required_magic,
                                 match_index);

      if(ticket <= 0)
         return(false);

      return(SelectOpenByTicket(ticket));
   }

   bool SelectMarketMatch(const string required_symbol,
                          const int required_magic,
                          const int match_index) const
   {
      int ticket = MarketTicketAtMatch(required_symbol,
                                       required_magic,
                                       match_index);

      if(ticket <= 0)
         return(false);

      return(SelectOpenByTicket(ticket));
   }

   bool SelectPendingMatch(const string required_symbol,
                           const int required_magic,
                           const int match_index) const
   {
      int ticket = PendingTicketAtMatch(required_symbol,
                                        required_magic,
                                        match_index);

      if(ticket <= 0)
         return(false);

      return(SelectOpenByTicket(ticket));
   }

   bool SelectTypeMatch(const string required_symbol,
                        const int required_magic,
                        const int required_order_type,
                        const int match_index) const
   {
      int ticket = TypeTicketAtMatch(required_symbol,
                                     required_magic,
                                     required_order_type,
                                     match_index);

      if(ticket <= 0)
         return(false);

      return(SelectOpenByTicket(ticket));
   }

   bool SelectBuyMatch(const string required_symbol,
                       const int required_magic,
                       const int match_index) const
   {
      return(SelectTypeMatch(required_symbol,
                             required_magic,
                             OP_BUY,
                             match_index));
   }

   bool SelectSellMatch(const string required_symbol,
                        const int required_magic,
                        const int match_index) const
   {
      return(SelectTypeMatch(required_symbol,
                             required_magic,
                             OP_SELL,
                             match_index));
   }


   // ---------------------------------------------------------------
   // Aggregate financial state
   // ---------------------------------------------------------------
   double SumProfit(const string required_symbol,
                    const int required_magic) const
   {
      if(!IsFilterValid(required_symbol, required_magic))
         return(0.0);

      double total_value = 0.0;
      int total = PoolTotal();

      for(int position = total - 1;
          position >= 0;
          position--)
      {
         if(!SelectOpenByPosition(position))
            continue;

         if(!SelectedOrderMatches(required_symbol,
                                  required_magic))
         {
            continue;
         }

         total_value += OrderProfit();
      }

      return(total_value);
   }

   double SumSwap(const string required_symbol,
                  const int required_magic) const
   {
      if(!IsFilterValid(required_symbol, required_magic))
         return(0.0);

      double total_value = 0.0;
      int total = PoolTotal();

      for(int position = total - 1;
          position >= 0;
          position--)
      {
         if(!SelectOpenByPosition(position))
            continue;

         if(!SelectedOrderMatches(required_symbol,
                                  required_magic))
         {
            continue;
         }

         total_value += OrderSwap();
      }

      return(total_value);
   }

   double SumCommission(const string required_symbol,
                        const int required_magic) const
   {
      if(!IsFilterValid(required_symbol, required_magic))
         return(0.0);

      double total_value = 0.0;
      int total = PoolTotal();

      for(int position = total - 1;
          position >= 0;
          position--)
      {
         if(!SelectOpenByPosition(position))
            continue;

         if(!SelectedOrderMatches(required_symbol,
                                  required_magic))
         {
            continue;
         }

         total_value += OrderCommission();
      }

      return(total_value);
   }

   double SumNetResult(const string required_symbol,
                       const int required_magic) const
   {
      return(
         SumProfit(required_symbol, required_magic) +
         SumSwap(required_symbol, required_magic) +
         SumCommission(required_symbol, required_magic)
      );
   }

   double SumNetResultType(const string required_symbol,
                           const int required_magic,
                           const int required_order_type) const
   {
      if(!IsFilterValid(required_symbol, required_magic))
         return(0.0);

      if(!m_trade.IsSupportedOrderType(required_order_type))
         return(0.0);

      double total_value = 0.0;
      int total = PoolTotal();

      for(int position = total - 1;
          position >= 0;
          position--)
      {
         if(!SelectOpenByPosition(position))
            continue;

         if(!SelectedOrderMatches(required_symbol,
                                  required_magic))
         {
            continue;
         }

         if(OrderType() != required_order_type)
            continue;

         total_value += (
            OrderProfit() +
            OrderSwap() +
            OrderCommission()
         );
      }

      return(total_value);
   }

   double SumNetResultBuy(const string required_symbol,
                          const int required_magic) const
   {
      return(
         SumNetResultType(required_symbol,
                          required_magic,
                          OP_BUY)
      );
   }

   double SumNetResultSell(const string required_symbol,
                           const int required_magic) const
   {
      return(
         SumNetResultType(required_symbol,
                          required_magic,
                          OP_SELL)
      );
   }

   int CountProfitable(const string required_symbol,
                       const int required_magic,
                       const double epsilon = 0.000000001) const
   {
      if(!IsFilterValid(required_symbol, required_magic))
         return(0);

      int count = 0;
      int total = PoolTotal();

      for(int position = total - 1;
          position >= 0;
          position--)
      {
         if(!SelectOpenByPosition(position))
            continue;

         if(!SelectedOrderMatches(required_symbol,
                                  required_magic))
         {
            continue;
         }

         double net_result =
            OrderProfit() +
            OrderSwap() +
            OrderCommission();

         if(net_result > epsilon)
            count++;
      }

      return(count);
   }

   int CountLosing(const string required_symbol,
                   const int required_magic,
                   const double epsilon = 0.000000001) const
   {
      if(!IsFilterValid(required_symbol, required_magic))
         return(0);

      int count = 0;
      int total = PoolTotal();

      for(int position = total - 1;
          position >= 0;
          position--)
      {
         if(!SelectOpenByPosition(position))
            continue;

         if(!SelectedOrderMatches(required_symbol,
                                  required_magic))
         {
            continue;
         }

         double net_result =
            OrderProfit() +
            OrderSwap() +
            OrderCommission();

         if(net_result < -epsilon)
            count++;
      }

      return(count);
   }

   int CountFlatResult(const string required_symbol,
                       const int required_magic,
                       const double epsilon = 0.000000001) const
   {
      if(!IsFilterValid(required_symbol, required_magic))
         return(0);

      int count = 0;
      int total = PoolTotal();

      for(int position = total - 1;
          position >= 0;
          position--)
      {
         if(!SelectOpenByPosition(position))
            continue;

         if(!SelectedOrderMatches(required_symbol,
                                  required_magic))
         {
            continue;
         }

         double net_result =
            OrderProfit() +
            OrderSwap() +
            OrderCommission();

         if(MathAbs(net_result) <= epsilon)
            count++;
      }

      return(count);
   }


   // ---------------------------------------------------------------
   // Selected-order protective state
   // ---------------------------------------------------------------
   bool SelectedHasStopLoss() const
   {
      if(!SelectedIsMarket())
         return(false);

      return(OrderStopLoss() > 0.0);
   }

   bool SelectedHasTakeProfit() const
   {
      if(!SelectedIsMarket())
         return(false);

      return(OrderTakeProfit() > 0.0);
   }

   double SelectedStopDistancePrice() const
   {
      if(!SelectedHasStopLoss())
         return(0.0);

      return(MathAbs(OrderOpenPrice() - OrderStopLoss()));
   }

   double SelectedTakeProfitDistancePrice() const
   {
      if(!SelectedHasTakeProfit())
         return(0.0);

      return(MathAbs(OrderTakeProfit() - OrderOpenPrice()));
   }

   bool SelectedAtBreakEven(const double epsilon = 0.000000001) const
   {
      if(!SelectedHasStopLoss())
         return(false);

      return(MathAbs(OrderStopLoss() - OrderOpenPrice()) <= epsilon);
   }

   bool SelectedLocksProfit(const double epsilon = 0.000000001) const
   {
      if(!SelectedHasStopLoss())
         return(false);

      int order_type = OrderType();
      double stop_loss = OrderStopLoss();
      double open_price = OrderOpenPrice();

      if(order_type == OP_BUY)
         return(stop_loss > open_price + epsilon);

      if(order_type == OP_SELL)
         return(stop_loss < open_price - epsilon);

      return(false);
   }

   bool SelectedStopIsProtective(const double epsilon = 0.000000001) const
   {
      if(!SelectedHasStopLoss())
         return(false);

      if(SelectedAtBreakEven(epsilon))
         return(true);

      return(SelectedLocksProfit(epsilon));
   }

   // ---------------------------------------------------------------
   // Aggregate protective state
   // ---------------------------------------------------------------
   int CountWithStopLoss(const string required_symbol,
                         const int required_magic) const
   {
      if(!IsFilterValid(required_symbol, required_magic))
         return(0);

      int count = 0;
      int total = PoolTotal();

      for(int position = total - 1;
          position >= 0;
          position--)
      {
         if(!SelectOpenByPosition(position))
            continue;

         if(!SelectedOrderMatches(required_symbol,
                                  required_magic))
         {
            continue;
         }

         if(!SelectedIsMarket())
            continue;

         if(OrderStopLoss() > 0.0)
            count++;
      }

      return(count);
   }

   int CountWithoutStopLoss(const string required_symbol,
                            const int required_magic) const
   {
      if(!IsFilterValid(required_symbol, required_magic))
         return(0);

      return(
         CountMarket(required_symbol, required_magic) -
         CountWithStopLoss(required_symbol, required_magic)
      );
   }

   int CountWithTakeProfit(const string required_symbol,
                           const int required_magic) const
   {
      if(!IsFilterValid(required_symbol, required_magic))
         return(0);

      int count = 0;
      int total = PoolTotal();

      for(int position = total - 1;
          position >= 0;
          position--)
      {
         if(!SelectOpenByPosition(position))
            continue;

         if(!SelectedOrderMatches(required_symbol,
                                  required_magic))
         {
            continue;
         }

         if(!SelectedIsMarket())
            continue;

         if(OrderTakeProfit() > 0.0)
            count++;
      }

      return(count);
   }

   int CountWithoutTakeProfit(const string required_symbol,
                              const int required_magic) const
   {
      if(!IsFilterValid(required_symbol, required_magic))
         return(0);

      return(
         CountMarket(required_symbol, required_magic) -
         CountWithTakeProfit(required_symbol, required_magic)
      );
   }

   int CountBreakEven(const string required_symbol,
                      const int required_magic,
                      const double epsilon = 0.000000001) const
   {
      if(!IsFilterValid(required_symbol, required_magic))
         return(0);

      int count = 0;
      int total = PoolTotal();

      for(int position = total - 1;
          position >= 0;
          position--)
      {
         if(!SelectOpenByPosition(position))
            continue;

         if(!SelectedOrderMatches(required_symbol,
                                  required_magic))
         {
            continue;
         }

         if(SelectedAtBreakEven(epsilon))
            count++;
      }

      return(count);
   }

   int CountLockingProfit(const string required_symbol,
                          const int required_magic,
                          const double epsilon = 0.000000001) const
   {
      if(!IsFilterValid(required_symbol, required_magic))
         return(0);

      int count = 0;
      int total = PoolTotal();

      for(int position = total - 1;
          position >= 0;
          position--)
      {
         if(!SelectOpenByPosition(position))
            continue;

         if(!SelectedOrderMatches(required_symbol,
                                  required_magic))
         {
            continue;
         }

         if(SelectedLocksProfit(epsilon))
            count++;
      }

      return(count);
   }

   double SumProtectedMarketLots(const string required_symbol,
                                 const int required_magic,
                                 const double epsilon = 0.000000001) const
   {
      if(!IsFilterValid(required_symbol, required_magic))
         return(0.0);

      double total_lots = 0.0;
      int total = PoolTotal();

      for(int position = total - 1;
          position >= 0;
          position--)
      {
         if(!SelectOpenByPosition(position))
            continue;

         if(!SelectedOrderMatches(required_symbol,
                                  required_magic))
         {
            continue;
         }

         if(!SelectedIsMarket())
            continue;

         if(!SelectedStopIsProtective(epsilon))
            continue;

         if(OrderLots() > 0.0)
            total_lots += OrderLots();
      }

      return(total_lots);
   }

   double SumUnprotectedMarketLots(const string required_symbol,
                                   const int required_magic,
                                   const double epsilon = 0.000000001) const
   {
      if(!IsFilterValid(required_symbol, required_magic))
         return(0.0);

      return(
         SumLotsMarket(required_symbol, required_magic) -
         SumProtectedMarketLots(required_symbol,
                                required_magic,
                                epsilon)
      );
   }


   // ---------------------------------------------------------------
   // Entry-price analytics
   // ---------------------------------------------------------------
   double WeightedAverageOpenPrice(const string required_symbol,
                                   const int required_magic) const
   {
      if(!IsFilterValid(required_symbol, required_magic))
         return(0.0);

      double weighted_sum = 0.0;
      double total_lots = 0.0;
      int total = PoolTotal();

      for(int position = total - 1;
          position >= 0;
          position--)
      {
         if(!SelectOpenByPosition(position))
            continue;

         if(!SelectedOrderMatches(required_symbol,
                                  required_magic))
         {
            continue;
         }

         if(!SelectedIsMarket())
            continue;

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

   double WeightedAverageOpenPriceType(const string required_symbol,
                                       const int required_magic,
                                       const int required_order_type) const
   {
      if(!IsFilterValid(required_symbol, required_magic))
         return(0.0);

      if(!m_trade.IsMarketOrderType(required_order_type))
         return(0.0);

      double weighted_sum = 0.0;
      double total_lots = 0.0;
      int total = PoolTotal();

      for(int position = total - 1;
          position >= 0;
          position--)
      {
         if(!SelectOpenByPosition(position))
            continue;

         if(!SelectedOrderMatches(required_symbol,
                                  required_magic))
         {
            continue;
         }

         if(OrderType() != required_order_type)
            continue;

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

   double WeightedAverageBuyOpenPrice(const string required_symbol,
                                      const int required_magic) const
   {
      return(
         WeightedAverageOpenPriceType(required_symbol,
                                      required_magic,
                                      OP_BUY)
      );
   }

   double WeightedAverageSellOpenPrice(const string required_symbol,
                                       const int required_magic) const
   {
      return(
         WeightedAverageOpenPriceType(required_symbol,
                                      required_magic,
                                      OP_SELL)
      );
   }

   double MinMarketOpenPrice(const string required_symbol,
                             const int required_magic) const
   {
      if(!IsFilterValid(required_symbol, required_magic))
         return(0.0);

      bool found = false;
      double found_price = 0.0;
      int total = PoolTotal();

      for(int position = total - 1;
          position >= 0;
          position--)
      {
         if(!SelectOpenByPosition(position))
            continue;

         if(!SelectedOrderMatches(required_symbol,
                                  required_magic))
         {
            continue;
         }

         if(!SelectedIsMarket())
            continue;

         double open_price = OrderOpenPrice();

         if(!found || open_price < found_price)
         {
            found = true;
            found_price = open_price;
         }
      }

      if(!found)
         return(0.0);

      return(found_price);
   }

   double MaxMarketOpenPrice(const string required_symbol,
                             const int required_magic) const
   {
      if(!IsFilterValid(required_symbol, required_magic))
         return(0.0);

      bool found = false;
      double found_price = 0.0;
      int total = PoolTotal();

      for(int position = total - 1;
          position >= 0;
          position--)
      {
         if(!SelectOpenByPosition(position))
            continue;

         if(!SelectedOrderMatches(required_symbol,
                                  required_magic))
         {
            continue;
         }

         if(!SelectedIsMarket())
            continue;

         double open_price = OrderOpenPrice();

         if(!found || open_price > found_price)
         {
            found = true;
            found_price = open_price;
         }
      }

      if(!found)
         return(0.0);

      return(found_price);
   }

   // ---------------------------------------------------------------
   // Age analytics
   // ---------------------------------------------------------------
   int OldestAgeSeconds(const string required_symbol,
                        const int required_magic,
                        const datetime current_time) const
   {
      datetime open_time =
         OldestOpenTime(required_symbol,
                        required_magic);

      if(open_time <= 0)
         return(0);

      if(current_time <= open_time)
         return(0);

      return((int)(current_time - open_time));
   }

   int NewestAgeSeconds(const string required_symbol,
                        const int required_magic,
                        const datetime current_time) const
   {
      datetime open_time =
         NewestOpenTime(required_symbol,
                        required_magic);

      if(open_time <= 0)
         return(0);

      if(current_time <= open_time)
         return(0);

      return((int)(current_time - open_time));
   }

   double AverageAgeSeconds(const string required_symbol,
                            const int required_magic,
                            const datetime current_time) const
   {
      if(!IsFilterValid(required_symbol, required_magic))
         return(0.0);

      double age_sum = 0.0;
      int count = 0;
      int total = PoolTotal();

      for(int position = total - 1;
          position >= 0;
          position--)
      {
         if(!SelectOpenByPosition(position))
            continue;

         if(!SelectedOrderMatches(required_symbol,
                                  required_magic))
         {
            continue;
         }

         datetime open_time = OrderOpenTime();
         int age_seconds = 0;

         if(open_time > 0 &&
            current_time > open_time)
         {
            age_seconds =
               (int)(current_time - open_time);
         }

         age_sum += age_seconds;
         count++;
      }

      if(count <= 0)
         return(0.0);

      return(age_sum / count);
   }

   int OldestAgeSecondsNow(const string required_symbol,
                           const int required_magic) const
   {
      return(
         OldestAgeSeconds(required_symbol,
                          required_magic,
                          TimeCurrent())
      );
   }

   int NewestAgeSecondsNow(const string required_symbol,
                           const int required_magic) const
   {
      return(
         NewestAgeSeconds(required_symbol,
                          required_magic,
                          TimeCurrent())
      );
   }

   double AverageAgeSecondsNow(const string required_symbol,
                               const int required_magic) const
   {
      return(
         AverageAgeSeconds(required_symbol,
                           required_magic,
                           TimeCurrent())
      );
   }

   // ---------------------------------------------------------------
   // Ticket lookup
   // ---------------------------------------------------------------
   int FirstTicket(const string required_symbol,
                   const int required_magic) const
   {
      if(!IsFilterValid(required_symbol, required_magic))
         return(-1);

      int total = PoolTotal();

      for(int position = 0;
          position < total;
          position++)
      {
         if(!SelectOpenByPosition(position))
            continue;

         if(!SelectedOrderMatches(required_symbol,
                                  required_magic))
         {
            continue;
         }

         int ticket = OrderTicket();

         if(ticket > 0)
            return(ticket);
      }

      return(-1);
   }

   int FirstMarketTicket(const string required_symbol,
                         const int required_magic) const
   {
      if(!IsFilterValid(required_symbol, required_magic))
         return(-1);

      int total = PoolTotal();

      for(int position = 0;
          position < total;
          position++)
      {
         if(!SelectOpenByPosition(position))
            continue;

         if(!SelectedOrderMatches(required_symbol,
                                  required_magic))
         {
            continue;
         }

         if(!SelectedIsMarket())
            continue;

         int ticket = OrderTicket();

         if(ticket > 0)
            return(ticket);
      }

      return(-1);
   }

   int FirstPendingTicket(const string required_symbol,
                          const int required_magic) const
   {
      if(!IsFilterValid(required_symbol, required_magic))
         return(-1);

      int total = PoolTotal();

      for(int position = 0;
          position < total;
          position++)
      {
         if(!SelectOpenByPosition(position))
            continue;

         if(!SelectedOrderMatches(required_symbol,
                                  required_magic))
         {
            continue;
         }

         if(!SelectedIsPending())
            continue;

         int ticket = OrderTicket();

         if(ticket > 0)
            return(ticket);
      }

      return(-1);
   }
};

#endif
