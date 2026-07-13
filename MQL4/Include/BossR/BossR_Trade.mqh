//+------------------------------------------------------------------+
//| BossR_Trade_Block6_FULL.mqh                                     |
//| BossR Framework - Trade Module                                  |
//| Block 6: Trailing stop and final execution preflight helpers                        |
//| MT4 / MQL4                                                      |
//+------------------------------------------------------------------+
#ifndef BOSSR_TRADE_BLOCK6_FULL_MQH
#define BOSSR_TRADE_BLOCK6_FULL_MQH

class C_BossR_Trade
{
private:
   double Epsilon() const
   {
      return(0.000000000001);
   }

public:
   C_BossR_Trade()
   {
   }

   bool IsMarketOrderType(const int order_type) const
   {
      return(order_type == OP_BUY || order_type == OP_SELL);
   }

   bool IsPendingOrderType(const int order_type) const
   {
      return(
         order_type == OP_BUYLIMIT ||
         order_type == OP_SELLLIMIT ||
         order_type == OP_BUYSTOP ||
         order_type == OP_SELLSTOP
      );
   }

   bool IsSupportedOrderType(const int order_type) const
   {
      return(IsMarketOrderType(order_type) ||
             IsPendingOrderType(order_type));
   }

   bool IsBuySideType(const int order_type) const
   {
      return(
         order_type == OP_BUY ||
         order_type == OP_BUYLIMIT ||
         order_type == OP_BUYSTOP
      );
   }

   bool IsSellSideType(const int order_type) const
   {
      return(
         order_type == OP_SELL ||
         order_type == OP_SELLLIMIT ||
         order_type == OP_SELLSTOP
      );
   }

   int DirectionSign(const int order_type) const
   {
      if(IsBuySideType(order_type))
         return(1);

      if(IsSellSideType(order_type))
         return(-1);

      return(0);
   }

   bool IsValidMagicNumber(const int magic_number) const
   {
      return(magic_number >= 0);
   }

   int LotDigits(const double lot_step) const
   {
      if(lot_step <= 0.0)
         return(0);

      int digits = 0;
      double scaled = lot_step;

      while(digits < 8 &&
            MathAbs(scaled - MathRound(scaled)) > Epsilon())
      {
         scaled *= 10.0;
         digits++;
      }

      return(digits);
   }

   double PipSize(const double point_size,
                  const int digits) const
   {
      if(point_size <= 0.0 || digits < 0)
         return(0.0);

      if(digits == 3 || digits == 5)
         return(point_size * 10.0);

      return(point_size);
   }

   double NormalizePriceValue(const double price,
                              const int digits) const
   {
      if(price < 0.0 || digits < 0 || digits > 8)
         return(0.0);

      return(NormalizeDouble(price, digits));
   }

   double NormalizeLotsValue(const double lots,
                             const double min_lot,
                             const double max_lot,
                             const double lot_step) const
   {
      if(lots < 0.0 ||
         min_lot <= 0.0 ||
         max_lot < min_lot ||
         lot_step <= 0.0)
      {
         return(0.0);
      }

      double bounded = MathMax(min_lot, MathMin(max_lot, lots));
      double steps   = MathFloor(((bounded - min_lot) / lot_step) + Epsilon());
      double result  = min_lot + (steps * lot_step);

      if(result < min_lot)
         result = min_lot;

      if(result > max_lot)
         result = max_lot;

      int lot_digits = MathMax(LotDigits(lot_step),
                               LotDigits(min_lot));

      return(NormalizeDouble(result, lot_digits));
   }

   bool IsValidLots(const double lots,
                    const double min_lot,
                    const double max_lot,
                    const double lot_step) const
   {
      if(lots < 0.0 ||
         min_lot <= 0.0 ||
         max_lot < min_lot ||
         lot_step <= 0.0)
      {
         return(false);
      }

      if(lots < (min_lot - Epsilon()) ||
         lots > (max_lot + Epsilon()))
      {
         return(false);
      }

      double steps = (lots - min_lot) / lot_step;

      return(MathAbs(steps - MathRound(steps)) <= Epsilon());
   }

   double SpreadPoints(const double ask_price,
                       const double bid_price,
                       const double point_size) const
   {
      if(ask_price < 0.0 ||
         bid_price < 0.0 ||
         ask_price < bid_price ||
         point_size <= 0.0)
      {
         return(0.0);
      }

      return((ask_price - bid_price) / point_size);
   }

   double PriceDistancePoints(const double first_price,
                              const double second_price,
                              const double point_size) const
   {
      if(first_price < 0.0 ||
         second_price < 0.0 ||
         point_size <= 0.0)
      {
         return(0.0);
      }

      return(MathAbs(first_price - second_price) / point_size);
   }

   bool IsStopLossValid(const int order_type,
                        const double entry_price,
                        const double stop_loss,
                        const double minimum_distance_points,
                        const double point_size) const
   {
      if(!IsSupportedOrderType(order_type) ||
         entry_price <= 0.0 ||
         stop_loss <= 0.0 ||
         minimum_distance_points < 0.0 ||
         point_size <= 0.0)
      {
         return(false);
      }

      double minimum_distance =
         minimum_distance_points * point_size;

      if(IsBuySideType(order_type))
      {
         return(
            stop_loss <
            (entry_price - minimum_distance + Epsilon())
         );
      }

      return(
         stop_loss >
         (entry_price + minimum_distance - Epsilon())
      );
   }

   bool IsTakeProfitValid(const int order_type,
                          const double entry_price,
                          const double take_profit,
                          const double minimum_distance_points,
                          const double point_size) const
   {
      if(!IsSupportedOrderType(order_type) ||
         entry_price <= 0.0 ||
         take_profit <= 0.0 ||
         minimum_distance_points < 0.0 ||
         point_size <= 0.0)
      {
         return(false);
      }

      double minimum_distance =
         minimum_distance_points * point_size;

      if(IsBuySideType(order_type))
      {
         return(
            take_profit >
            (entry_price + minimum_distance - Epsilon())
         );
      }

      return(
         take_profit <
         (entry_price - minimum_distance + Epsilon())
      );
   }

   double SignedPriceMove(const int order_type,
                          const double entry_price,
                          const double exit_price) const
   {
      int direction = DirectionSign(order_type);

      if(direction == 0 ||
         entry_price < 0.0 ||
         exit_price < 0.0)
      {
         return(0.0);
      }

      return((exit_price - entry_price) * direction);
   }

   double SignedMovePoints(const int order_type,
                           const double entry_price,
                           const double exit_price,
                           const double point_size) const
   {
      if(point_size <= 0.0)
         return(0.0);

      return(SignedPriceMove(order_type,
                             entry_price,
                             exit_price) / point_size);
   }

   bool IsProfitableMove(const int order_type,
                         const double entry_price,
                         const double exit_price) const
   {
      return(SignedPriceMove(order_type,
                             entry_price,
                             exit_price) > Epsilon());
   }

   bool IsLosingMove(const int order_type,
                     const double entry_price,
                     const double exit_price) const
   {
      return(SignedPriceMove(order_type,
                             entry_price,
                             exit_price) < -Epsilon());
   }

   double RiskDistancePoints(const int order_type,
                             const double entry_price,
                             const double stop_loss,
                             const double point_size) const
   {
      if(!IsSupportedOrderType(order_type) ||
         entry_price <= 0.0 ||
         stop_loss <= 0.0 ||
         point_size <= 0.0)
      {
         return(0.0);
      }

      double signed_distance =
         SignedMovePoints(order_type,
                          entry_price,
                          stop_loss,
                          point_size);

      if(signed_distance >= 0.0)
         return(0.0);

      return(MathAbs(signed_distance));
   }

   double RewardDistancePoints(const int order_type,
                               const double entry_price,
                               const double take_profit,
                               const double point_size) const
   {
      if(!IsSupportedOrderType(order_type) ||
         entry_price <= 0.0 ||
         take_profit <= 0.0 ||
         point_size <= 0.0)
      {
         return(0.0);
      }

      double signed_distance =
         SignedMovePoints(order_type,
                          entry_price,
                          take_profit,
                          point_size);

      if(signed_distance <= 0.0)
         return(0.0);

      return(signed_distance);
   }

   double RiskRewardRatio(const int order_type,
                          const double entry_price,
                          const double stop_loss,
                          const double take_profit,
                          const double point_size) const
   {
      double risk_points =
         RiskDistancePoints(order_type,
                            entry_price,
                            stop_loss,
                            point_size);

      double reward_points =
         RewardDistancePoints(order_type,
                              entry_price,
                              take_profit,
                              point_size);

      if(risk_points <= 0.0 || reward_points <= 0.0)
         return(0.0);

      return(reward_points / risk_points);
   }

   double RiskMoney(const double balance,
                    const double risk_percent) const
   {
      if(balance <= 0.0 ||
         risk_percent <= 0.0 ||
         risk_percent > 100.0)
      {
         return(0.0);
      }

      return(balance * (risk_percent / 100.0));
   }

   double RawLotsByRisk(const double risk_money,
                        const double stop_distance_points,
                        const double tick_value_per_lot,
                        const double tick_size_points) const
   {
      if(risk_money <= 0.0 ||
         stop_distance_points <= 0.0 ||
         tick_value_per_lot <= 0.0 ||
         tick_size_points <= 0.0)
      {
         return(0.0);
      }

      double ticks_to_stop =
         stop_distance_points / tick_size_points;

      if(ticks_to_stop <= 0.0)
         return(0.0);

      double money_risk_per_lot =
         ticks_to_stop * tick_value_per_lot;

      if(money_risk_per_lot <= 0.0)
         return(0.0);

      return(risk_money / money_risk_per_lot);
   }

   double LotsByRisk(const double balance,
                     const double risk_percent,
                     const double stop_distance_points,
                     const double tick_value_per_lot,
                     const double tick_size_points,
                     const double min_lot,
                     const double max_lot,
                     const double lot_step) const
   {
      double risk_money = RiskMoney(balance, risk_percent);

      double raw_lots =
         RawLotsByRisk(risk_money,
                       stop_distance_points,
                       tick_value_per_lot,
                       tick_size_points);

      if(raw_lots <= 0.0)
         return(0.0);

      return(NormalizeLotsValue(raw_lots,
                                min_lot,
                                max_lot,
                                lot_step));
   }

   bool IsRiskRewardAtLeast(const int order_type,
                            const double entry_price,
                            const double stop_loss,
                            const double take_profit,
                            const double point_size,
                            const double minimum_ratio) const
   {
      if(minimum_ratio < 0.0)
         return(false);

      double ratio =
         RiskRewardRatio(order_type,
                         entry_price,
                         stop_loss,
                         take_profit,
                         point_size);

      if(ratio <= 0.0)
         return(false);

      return(ratio + Epsilon() >= minimum_ratio);
   }

   bool IsSpreadWithinLimit(const double ask_price,
                            const double bid_price,
                            const double point_size,
                            const double maximum_spread_points) const
   {
      if(maximum_spread_points < 0.0 ||
         ask_price < bid_price ||
         point_size <= 0.0)
      {
         return(false);
      }

      double spread_points =
         SpreadPoints(ask_price,
                      bid_price,
                      point_size);

      return(spread_points <=
             (maximum_spread_points + Epsilon()));
   }


   bool MatchesTradeIdentity(const string order_symbol,const int order_magic,
                             const string required_symbol,const int required_magic) const
   {
      if(StringLen(order_symbol)<=0 || StringLen(required_symbol)<=0 ||
         !IsValidMagicNumber(order_magic) || !IsValidMagicNumber(required_magic))
         return(false);
      return(order_symbol==required_symbol && order_magic==required_magic);
   }

   bool IsEntryBarAllowed(const datetime current_bar_time,
                          const datetime last_entry_bar_time) const
   {
      if(current_bar_time<=0) return(false);
      if(last_entry_bar_time<=0) return(true);
      return(current_bar_time!=last_entry_bar_time);
   }

   bool IsSlippageValid(const int slippage_points) const
   {
      return(slippage_points>=0);
   }

   double MarketEntryPrice(const int order_type,const double ask_price,
                           const double bid_price) const
   {
      if(ask_price<=0.0 || bid_price<=0.0 || ask_price<bid_price) return(0.0);
      if(order_type==OP_BUY) return(ask_price);
      if(order_type==OP_SELL) return(bid_price);
      return(0.0);
   }

   bool IsPendingEntryPriceValid(const int order_type,const double pending_price,
                                 const double ask_price,const double bid_price,
                                 const double minimum_distance_points,
                                 const double point_size) const
   {
      if(!IsPendingOrderType(order_type) || pending_price<=0.0 ||
         ask_price<=0.0 || bid_price<=0.0 || ask_price<bid_price ||
         minimum_distance_points<0.0 || point_size<=0.0)
         return(false);

      double d=minimum_distance_points*point_size;
      if(order_type==OP_BUYLIMIT)
         return(pending_price <= ask_price-d+Epsilon());
      if(order_type==OP_SELLLIMIT)
         return(pending_price >= bid_price+d-Epsilon());
      if(order_type==OP_BUYSTOP)
         return(pending_price >= ask_price+d-Epsilon());
      return(pending_price <= bid_price-d+Epsilon());
   }

   bool IsExpirationValid(const datetime expiration_time,
                          const datetime current_time) const
   {
      if(current_time<=0) return(false);
      if(expiration_time==0) return(true);
      return(expiration_time>current_time);
   }

   bool IsTradeRequestStructurallyValid(const int order_type,const double lots,
                                        const double min_lot,const double max_lot,
                                        const double lot_step,const int magic_number,
                                        const int slippage_points) const
   {
      return(IsSupportedOrderType(order_type) &&
             IsValidLots(lots,min_lot,max_lot,lot_step) &&
             IsValidMagicNumber(magic_number) &&
             IsSlippageValid(slippage_points));
   }


   double GrossProfitMoney(const int order_type,
                           const double entry_price,
                           const double exit_price,
                           const double lots,
                           const double tick_value_per_lot,
                           const double tick_size_points,
                           const double point_size) const
   {
      if(!IsMarketOrderType(order_type) ||
         entry_price <= 0.0 ||
         exit_price <= 0.0 ||
         lots <= 0.0 ||
         tick_value_per_lot <= 0.0 ||
         tick_size_points <= 0.0 ||
         point_size <= 0.0)
      {
         return(0.0);
      }

      double move_points =
         SignedMovePoints(order_type,
                          entry_price,
                          exit_price,
                          point_size);

      double ticks_moved = move_points / tick_size_points;

      return(ticks_moved * tick_value_per_lot * lots);
   }

   double NetProfitMoney(const double gross_profit,
                         const double commission,
                         const double swap) const
   {
      return(gross_profit + commission + swap);
   }

   bool IsNetWinner(const double gross_profit,
                    const double commission,
                    const double swap) const
   {
      return(NetProfitMoney(gross_profit,
                            commission,
                            swap) > Epsilon());
   }

   bool IsNetLoser(const double gross_profit,
                   const double commission,
                   const double swap) const
   {
      return(NetProfitMoney(gross_profit,
                            commission,
                            swap) < -Epsilon());
   }

   bool IsTradeOpen(const datetime close_time) const
   {
      return(close_time == 0);
   }

   bool IsTradeClosed(const datetime close_time) const
   {
      return(close_time > 0);
   }

   int HeldSeconds(const datetime open_time,
                   const datetime close_or_current_time) const
   {
      if(open_time <= 0 ||
         close_or_current_time <= 0 ||
         close_or_current_time < open_time)
      {
         return(0);
      }

      return((int)(close_or_current_time - open_time));
   }

   bool HasReachedHoldLimit(const datetime open_time,
                            const datetime current_time,
                            const int maximum_hold_seconds) const
   {
      if(maximum_hold_seconds < 0)
         return(false);

      if(open_time <= 0 ||
         current_time <= 0 ||
         current_time < open_time)
      {
         return(false);
      }

      return(HeldSeconds(open_time, current_time) >=
             maximum_hold_seconds);
   }

   double ProfitPoints(const int order_type,
                       const double entry_price,
                       const double exit_price,
                       const double point_size) const
   {
      if(!IsMarketOrderType(order_type))
         return(0.0);

      return(SignedMovePoints(order_type,
                              entry_price,
                              exit_price,
                              point_size));
   }

   bool HasReachedProfitTargetPoints(const int order_type,
                                     const double entry_price,
                                     const double current_price,
                                     const double point_size,
                                     const double target_points) const
   {
      if(target_points < 0.0)
         return(false);

      double profit_points =
         ProfitPoints(order_type,
                      entry_price,
                      current_price,
                      point_size);

      double comparison_tolerance = 0.00000001;

      return(profit_points + comparison_tolerance >= target_points);
   }

   bool HasReachedLossLimitPoints(const int order_type,
                                  const double entry_price,
                                  const double current_price,
                                  const double point_size,
                                  const double maximum_loss_points) const
   {
      if(maximum_loss_points < 0.0)
         return(false);

      double profit_points =
         ProfitPoints(order_type,
                      entry_price,
                      current_price,
                      point_size);

      double comparison_tolerance = 0.00000001;

      return(profit_points <=
             (-maximum_loss_points + comparison_tolerance));
   }


   bool IsCloseLotsValid(const double close_lots,
                         const double order_lots,
                         const double min_lot,
                         const double lot_step) const
   {
      if(close_lots <= 0.0 ||
         order_lots <= 0.0 ||
         min_lot <= 0.0 ||
         lot_step <= 0.0 ||
         close_lots > (order_lots + Epsilon()))
      {
         return(false);
      }

      if(!IsValidLots(close_lots,
                      min_lot,
                      order_lots,
                      lot_step))
      {
         return(false);
      }

      double remaining_lots = order_lots - close_lots;

      if(MathAbs(remaining_lots) <= Epsilon())
         return(true);

      return(IsValidLots(remaining_lots,
                         min_lot,
                         order_lots,
                         lot_step));
   }

   double ClosePriceForMarketOrder(const int order_type,
                                   const double ask_price,
                                   const double bid_price) const
   {
      if(ask_price <= 0.0 ||
         bid_price <= 0.0 ||
         ask_price < bid_price)
      {
         return(0.0);
      }

      if(order_type == OP_BUY)
         return(bid_price);

      if(order_type == OP_SELL)
         return(ask_price);

      return(0.0);
   }

   bool IsStopModificationImprovement(const int order_type,
                                      const double current_stop_loss,
                                      const double proposed_stop_loss) const
   {
      if(!IsMarketOrderType(order_type) ||
         proposed_stop_loss <= 0.0)
      {
         return(false);
      }

      if(current_stop_loss <= 0.0)
         return(true);

      if(order_type == OP_BUY)
      {
         return(proposed_stop_loss >
                (current_stop_loss + Epsilon()));
      }

      return(proposed_stop_loss <
             (current_stop_loss - Epsilon()));
   }

   bool IsTakeProfitModificationImprovement(const int order_type,
                                            const double current_take_profit,
                                            const double proposed_take_profit) const
   {
      if(!IsMarketOrderType(order_type) ||
         proposed_take_profit <= 0.0)
      {
         return(false);
      }

      if(current_take_profit <= 0.0)
         return(true);

      if(order_type == OP_BUY)
      {
         return(proposed_take_profit >
                (current_take_profit + Epsilon()));
      }

      return(proposed_take_profit <
             (current_take_profit - Epsilon()));
   }

   double BreakevenPrice(const int order_type,
                         const double entry_price,
                         const double offset_points,
                         const double point_size,
                         const int digits) const
   {
      if(!IsMarketOrderType(order_type) ||
         entry_price <= 0.0 ||
         offset_points < 0.0 ||
         point_size <= 0.0 ||
         digits < 0 ||
         digits > 8)
      {
         return(0.0);
      }

      double price = entry_price;

      if(order_type == OP_BUY)
         price += offset_points * point_size;
      else
         price -= offset_points * point_size;

      return(NormalizePriceValue(price, digits));
   }

   bool HasReachedBreakevenTrigger(const int order_type,
                                   const double entry_price,
                                   const double current_price,
                                   const double point_size,
                                   const double trigger_points) const
   {
      if(trigger_points < 0.0)
         return(false);

      double comparison_tolerance = 0.00000001;

      return(ProfitPoints(order_type,
                          entry_price,
                          current_price,
                          point_size) + comparison_tolerance >= trigger_points);
   }

   bool ShouldMoveStopToBreakeven(const int order_type,
                                  const double entry_price,
                                  const double current_price,
                                  const double current_stop_loss,
                                  const double trigger_points,
                                  const double offset_points,
                                  const double point_size,
                                  const int digits) const
   {
      if(!HasReachedBreakevenTrigger(order_type,
                                     entry_price,
                                     current_price,
                                     point_size,
                                     trigger_points))
      {
         return(false);
      }

      double proposed_stop =
         BreakevenPrice(order_type,
                        entry_price,
                        offset_points,
                        point_size,
                        digits);

      if(proposed_stop <= 0.0)
         return(false);

      return(IsStopModificationImprovement(order_type,
                                           current_stop_loss,
                                           proposed_stop));
   }

   bool IsMarketCloseRequestValid(const int order_type,
                                  const double close_lots,
                                  const double order_lots,
                                  const double min_lot,
                                  const double lot_step,
                                  const int slippage_points) const
   {
      return(
         IsMarketOrderType(order_type) &&
         IsCloseLotsValid(close_lots,
                          order_lots,
                          min_lot,
                          lot_step) &&
         IsSlippageValid(slippage_points)
      );
   }


   double TrailingStopPrice(const int order_type,
                            const double current_price,
                            const double trailing_distance_points,
                            const double point_size,
                            const int digits) const
   {
      if(!IsMarketOrderType(order_type) ||
         current_price <= 0.0 ||
         trailing_distance_points < 0.0 ||
         point_size <= 0.0 ||
         digits < 0 ||
         digits > 8)
      {
         return(0.0);
      }

      double stop_price = current_price;

      if(order_type == OP_BUY)
         stop_price -= trailing_distance_points * point_size;
      else
         stop_price += trailing_distance_points * point_size;

      return(NormalizePriceValue(stop_price, digits));
   }

   bool HasReachedTrailingTrigger(const int order_type,
                                  const double entry_price,
                                  const double current_price,
                                  const double point_size,
                                  const double trigger_points) const
   {
      if(trigger_points < 0.0)
         return(false);

      double comparison_tolerance = 0.00000001;

      return(
         ProfitPoints(order_type,
                      entry_price,
                      current_price,
                      point_size) +
         comparison_tolerance >= trigger_points
      );
   }

   bool ShouldTrailStop(const int order_type,
                        const double entry_price,
                        const double current_price,
                        const double current_stop_loss,
                        const double trigger_points,
                        const double trailing_distance_points,
                        const double point_size,
                        const int digits) const
   {
      if(!HasReachedTrailingTrigger(order_type,
                                    entry_price,
                                    current_price,
                                    point_size,
                                    trigger_points))
      {
         return(false);
      }

      double proposed_stop =
         TrailingStopPrice(order_type,
                           current_price,
                           trailing_distance_points,
                           point_size,
                           digits);

      if(proposed_stop <= 0.0)
         return(false);

      return(IsStopModificationImprovement(order_type,
                                           current_stop_loss,
                                           proposed_stop));
   }

   bool IsMarketOrderPreflightValid(const int order_type,
                                    const double lots,
                                    const double min_lot,
                                    const double max_lot,
                                    const double lot_step,
                                    const int magic_number,
                                    const int slippage_points,
                                    const double ask_price,
                                    const double bid_price,
                                    const double point_size,
                                    const double maximum_spread_points) const
   {
      if(!IsTradeRequestStructurallyValid(order_type,
                                          lots,
                                          min_lot,
                                          max_lot,
                                          lot_step,
                                          magic_number,
                                          slippage_points))
      {
         return(false);
      }

      if(!IsMarketOrderType(order_type))
         return(false);

      if(MarketEntryPrice(order_type,
                          ask_price,
                          bid_price) <= 0.0)
      {
         return(false);
      }

      return(IsSpreadWithinLimit(ask_price,
                                 bid_price,
                                 point_size,
                                 maximum_spread_points));
   }

   bool IsPendingOrderPreflightValid(const int order_type,
                                     const double lots,
                                     const double min_lot,
                                     const double max_lot,
                                     const double lot_step,
                                     const int magic_number,
                                     const int slippage_points,
                                     const double pending_price,
                                     const double ask_price,
                                     const double bid_price,
                                     const double minimum_distance_points,
                                     const double point_size,
                                     const datetime expiration_time,
                                     const datetime current_time) const
   {
      if(!IsTradeRequestStructurallyValid(order_type,
                                          lots,
                                          min_lot,
                                          max_lot,
                                          lot_step,
                                          magic_number,
                                          slippage_points))
      {
         return(false);
      }

      if(!IsPendingOrderType(order_type))
         return(false);

      if(!IsPendingEntryPriceValid(order_type,
                                   pending_price,
                                   ask_price,
                                   bid_price,
                                   minimum_distance_points,
                                   point_size))
      {
         return(false);
      }

      return(IsExpirationValid(expiration_time,
                               current_time));
   }

   bool IsMarketStopsPreflightValid(const int order_type,
                                    const double entry_price,
                                    const double stop_loss,
                                    const double take_profit,
                                    const double minimum_distance_points,
                                    const double point_size) const
   {
      if(!IsMarketOrderType(order_type) ||
         entry_price <= 0.0 ||
         minimum_distance_points < 0.0 ||
         point_size <= 0.0)
      {
         return(false);
      }

      if(stop_loss > 0.0 &&
         !IsStopLossValid(order_type,
                          entry_price,
                          stop_loss,
                          minimum_distance_points,
                          point_size))
      {
         return(false);
      }

      if(take_profit > 0.0 &&
         !IsTakeProfitValid(order_type,
                            entry_price,
                            take_profit,
                            minimum_distance_points,
                            point_size))
      {
         return(false);
      }

      return(true);
   }

};

#endif
