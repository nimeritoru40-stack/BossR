//+------------------------------------------------------------------+
//| BossR_Risk_Block6_FIXED_FULL.mqh                         |
//| BossR Framework - Risk Module                                    |
//| Block 6: unified pre-trade risk facade                            |
//| MT4 only                                                         |
//+------------------------------------------------------------------+
#ifndef __BOSSR_RISK_BLOCK6_FIXED_FULL_MQH__
#define __BOSSR_RISK_BLOCK6_FIXED_FULL_MQH__

class CBossRRisk
{
private:
   double Clamp(const double value,
                const double minimum,
                const double maximum) const
   {
      if(value < minimum)
         return(minimum);

      if(value > maximum)
         return(maximum);

      return(value);
   }

   int LotDigits(const double lot_step) const
   {
      if(lot_step <= 0.0)
         return(0);

      int digits = 0;
      double step = lot_step;

      while(digits < 8 && MathAbs(step - MathRound(step)) > 0.000000001)
      {
         step *= 10.0;
         digits++;
      }

      return(digits);
   }

public:
   CBossRRisk(void)
   {
   }

   double ClampRiskPercent(const double risk_percent,
                           const double minimum_percent = 0.0,
                           const double maximum_percent = 100.0) const
   {
      if(minimum_percent < 0.0)
         return(0.0);

      if(maximum_percent < minimum_percent)
         return(0.0);

      return(Clamp(risk_percent,
                   minimum_percent,
                   maximum_percent));
   }

   double PercentToFraction(const double percent) const
   {
      return(percent / 100.0);
   }

   double FractionToPercent(const double fraction) const
   {
      return(fraction * 100.0);
   }

   double RiskMoney(const double capital,
                    const double risk_percent) const
   {
      if(capital <= 0.0)
         return(0.0);

      if(risk_percent <= 0.0)
         return(0.0);

      return(capital * PercentToFraction(risk_percent));
   }

   double RemainingCapital(const double capital,
                           const double loss_money) const
   {
      if(capital <= 0.0)
         return(0.0);

      if(loss_money <= 0.0)
         return(capital);

      return(MathMax(0.0, capital - loss_money));
   }

   double DrawdownMoney(const double peak_capital,
                        const double current_capital) const
   {
      if(peak_capital <= 0.0)
         return(0.0);

      if(current_capital >= peak_capital)
         return(0.0);

      return(peak_capital - MathMax(0.0, current_capital));
   }

   double DrawdownPercent(const double peak_capital,
                          const double current_capital) const
   {
      if(peak_capital <= 0.0)
         return(0.0);

      return(
         FractionToPercent(
            DrawdownMoney(peak_capital, current_capital) /
            peak_capital
         )
      );
   }

   double PriceDistance(const double price_a,
                        const double price_b) const
   {
      return(MathAbs(price_a - price_b));
   }

   double PriceDistancePoints(const double price_a,
                              const double price_b,
                              const double point_size) const
   {
      if(point_size <= 0.0)
         return(0.0);

      return(PriceDistance(price_a, price_b) / point_size);
   }

   double RewardRiskRatio(const double reward_distance,
                          const double risk_distance) const
   {
      if(reward_distance < 0.0)
         return(0.0);

      if(risk_distance <= 0.0)
         return(0.0);

      return(reward_distance / risk_distance);
   }

   double RewardDistanceFromR(const double risk_distance,
                              const double reward_r) const
   {
      if(risk_distance <= 0.0)
         return(0.0);

      if(reward_r <= 0.0)
         return(0.0);

      return(risk_distance * reward_r);
   }

   double LossAtR(const double risk_money,
                  const double result_r) const
   {
      if(risk_money <= 0.0)
         return(0.0);

      if(result_r >= 0.0)
         return(0.0);

      return(risk_money * MathAbs(result_r));
   }

   double ProfitAtR(const double risk_money,
                    const double result_r) const
   {
      if(risk_money <= 0.0)
         return(0.0);

      if(result_r <= 0.0)
         return(0.0);

      return(risk_money * result_r);
   }

   double MoneyAtR(const double risk_money,
                   const double result_r) const
   {
      if(risk_money <= 0.0)
         return(0.0);

      return(risk_money * result_r);
   }

   bool IsRiskPercentValid(const double risk_percent,
                           const double minimum_percent = 0.0,
                           const double maximum_percent = 100.0) const
   {
      if(minimum_percent < 0.0)
         return(false);

      if(maximum_percent < minimum_percent)
         return(false);

      return(
         risk_percent >= minimum_percent &&
         risk_percent <= maximum_percent
      );
   }

   bool IsPositiveRisk(const double risk_money) const
   {
      return(risk_money > 0.0);
   }

   bool IsDrawdownLimitBreached(const double peak_capital,
                                const double current_capital,
                                const double maximum_drawdown_percent) const
   {
      if(peak_capital <= 0.0)
         return(false);

      if(maximum_drawdown_percent < 0.0)
         return(false);

      return(
         DrawdownPercent(peak_capital, current_capital) >
         maximum_drawdown_percent
      );
   }

   bool IsDrawdownLimitReached(const double peak_capital,
                               const double current_capital,
                               const double maximum_drawdown_percent) const
   {
      if(peak_capital <= 0.0)
         return(false);

      if(maximum_drawdown_percent < 0.0)
         return(false);

      return(
         DrawdownPercent(peak_capital, current_capital) >=
         maximum_drawdown_percent
      );
   }

   // ---------------------------------------------------------------
   // Block 2: position sizing
   // ---------------------------------------------------------------
   double MoneyPerPointPerLot(const double tick_value,
                              const double tick_size,
                              const double point_size) const
   {
      if(tick_value <= 0.0)
         return(0.0);

      if(tick_size <= 0.0)
         return(0.0);

      if(point_size <= 0.0)
         return(0.0);

      return(tick_value * point_size / tick_size);
   }

   double RiskMoneyPerLot(const double stop_distance_points,
                          const double money_per_point_per_lot) const
   {
      if(stop_distance_points <= 0.0)
         return(0.0);

      if(money_per_point_per_lot <= 0.0)
         return(0.0);

      return(stop_distance_points * money_per_point_per_lot);
   }

   double RawLotsFromRiskMoney(const double risk_money,
                               const double stop_distance_points,
                               const double money_per_point_per_lot) const
   {
      if(risk_money <= 0.0)
         return(0.0);

      const double risk_per_lot =
         RiskMoneyPerLot(stop_distance_points,
                         money_per_point_per_lot);

      if(risk_per_lot <= 0.0)
         return(0.0);

      return(risk_money / risk_per_lot);
   }

   double RawLotsFromCapital(const double capital,
                             const double risk_percent,
                             const double stop_distance_points,
                             const double money_per_point_per_lot) const
   {
      return(
         RawLotsFromRiskMoney(
            RiskMoney(capital, risk_percent),
            stop_distance_points,
            money_per_point_per_lot
         )
      );
   }

   double FloorLotsToStep(const double lots,
                          const double lot_step) const
   {
      if(lots <= 0.0)
         return(0.0);

      if(lot_step <= 0.0)
         return(0.0);

      const double steps =
         MathFloor((lots / lot_step) + 0.0000000001);

      return(
         NormalizeDouble(
            steps * lot_step,
            LotDigits(lot_step)
         )
      );
   }

   double CeilLotsToStep(const double lots,
                         const double lot_step) const
   {
      if(lots <= 0.0)
         return(0.0);

      if(lot_step <= 0.0)
         return(0.0);

      const double steps =
         MathCeil((lots / lot_step) - 0.0000000001);

      return(
         NormalizeDouble(
            steps * lot_step,
            LotDigits(lot_step)
         )
      );
   }

   double RoundLotsToStep(const double lots,
                          const double lot_step) const
   {
      if(lots <= 0.0)
         return(0.0);

      if(lot_step <= 0.0)
         return(0.0);

      const double steps = MathRound(lots / lot_step);

      return(
         NormalizeDouble(
            steps * lot_step,
            LotDigits(lot_step)
         )
      );
   }

   double ClampLots(const double lots,
                    const double minimum_lots,
                    const double maximum_lots) const
   {
      if(minimum_lots < 0.0)
         return(0.0);

      if(maximum_lots < minimum_lots)
         return(0.0);

      return(Clamp(lots, minimum_lots, maximum_lots));
   }

   double NormalizeLotsDown(const double lots,
                            const double minimum_lots,
                            const double maximum_lots,
                            const double lot_step) const
   {
      if(minimum_lots < 0.0)
         return(0.0);

      if(maximum_lots < minimum_lots)
         return(0.0);

      if(lot_step <= 0.0)
         return(0.0);

      if(lots < minimum_lots)
         return(0.0);

      const double clamped =
         MathMin(lots, maximum_lots);

      const double normalized =
         FloorLotsToStep(clamped, lot_step);

      if(normalized < minimum_lots)
         return(0.0);

      return(normalized);
   }

   double PositionLots(const double capital,
                       const double risk_percent,
                       const double stop_distance_points,
                       const double tick_value,
                       const double tick_size,
                       const double point_size,
                       const double minimum_lots,
                       const double maximum_lots,
                       const double lot_step) const
   {
      const double money_per_point =
         MoneyPerPointPerLot(tick_value,
                             tick_size,
                             point_size);

      const double raw_lots =
         RawLotsFromCapital(capital,
                            risk_percent,
                            stop_distance_points,
                            money_per_point);

      return(
         NormalizeLotsDown(raw_lots,
                           minimum_lots,
                           maximum_lots,
                           lot_step)
      );
   }

   double ActualRiskMoney(const double lots,
                          const double stop_distance_points,
                          const double money_per_point_per_lot) const
   {
      if(lots <= 0.0)
         return(0.0);

      return(
         lots *
         RiskMoneyPerLot(stop_distance_points,
                         money_per_point_per_lot)
      );
   }

   double ActualRiskPercent(const double capital,
                            const double lots,
                            const double stop_distance_points,
                            const double money_per_point_per_lot) const
   {
      if(capital <= 0.0)
         return(0.0);

      return(
         FractionToPercent(
            ActualRiskMoney(lots,
                            stop_distance_points,
                            money_per_point_per_lot) /
            capital
         )
      );
   }

   bool IsLotConfigurationValid(const double minimum_lots,
                                const double maximum_lots,
                                const double lot_step) const
   {
      if(minimum_lots < 0.0)
         return(false);

      if(maximum_lots < minimum_lots)
         return(false);

      if(lot_step <= 0.0)
         return(false);

      return(true);
   }

   // ---------------------------------------------------------------
   // Block 3: stop / target geometry
   // ---------------------------------------------------------------
   bool IsBuyDirection(const int order_type) const
   {
      return(order_type == OP_BUY);
   }

   bool IsSellDirection(const int order_type) const
   {
      return(order_type == OP_SELL);
   }

   bool IsMarketDirection(const int order_type) const
   {
      return(IsBuyDirection(order_type) ||
             IsSellDirection(order_type));
   }

   bool IsStopPriceValid(const int order_type,
                         const double entry_price,
                         const double stop_price) const
   {
      if(entry_price <= 0.0 || stop_price <= 0.0)
         return(false);

      if(IsBuyDirection(order_type))
         return(stop_price < entry_price);

      if(IsSellDirection(order_type))
         return(stop_price > entry_price);

      return(false);
   }

   bool IsTargetPriceValid(const int order_type,
                           const double entry_price,
                           const double target_price) const
   {
      if(entry_price <= 0.0 || target_price <= 0.0)
         return(false);

      if(IsBuyDirection(order_type))
         return(target_price > entry_price);

      if(IsSellDirection(order_type))
         return(target_price < entry_price);

      return(false);
   }

   double StopDistancePrice(const int order_type,
                            const double entry_price,
                            const double stop_price) const
   {
      if(!IsStopPriceValid(order_type, entry_price, stop_price))
         return(0.0);

      return(PriceDistance(entry_price, stop_price));
   }

   double StopDistancePoints(const int order_type,
                             const double entry_price,
                             const double stop_price,
                             const double point_size) const
   {
      if(point_size <= 0.0)
         return(0.0);

      return(
         StopDistancePrice(order_type, entry_price, stop_price) /
         point_size
      );
   }

   double TargetDistancePrice(const int order_type,
                              const double entry_price,
                              const double target_price) const
   {
      if(!IsTargetPriceValid(order_type, entry_price, target_price))
         return(0.0);

      return(PriceDistance(entry_price, target_price));
   }

   double TargetDistancePoints(const int order_type,
                               const double entry_price,
                               const double target_price,
                               const double point_size) const
   {
      if(point_size <= 0.0)
         return(0.0);

      return(
         TargetDistancePrice(order_type, entry_price, target_price) /
         point_size
      );
   }

   double StopPriceFromDistance(const int order_type,
                                const double entry_price,
                                const double distance_price) const
   {
      if(entry_price <= 0.0 || distance_price <= 0.0)
         return(0.0);

      if(IsBuyDirection(order_type))
         return(entry_price - distance_price);

      if(IsSellDirection(order_type))
         return(entry_price + distance_price);

      return(0.0);
   }

   double TargetPriceFromDistance(const int order_type,
                                  const double entry_price,
                                  const double distance_price) const
   {
      if(entry_price <= 0.0 || distance_price <= 0.0)
         return(0.0);

      if(IsBuyDirection(order_type))
         return(entry_price + distance_price);

      if(IsSellDirection(order_type))
         return(entry_price - distance_price);

      return(0.0);
   }

   double StopPriceFromPoints(const int order_type,
                              const double entry_price,
                              const double distance_points,
                              const double point_size) const
   {
      if(distance_points <= 0.0 || point_size <= 0.0)
         return(0.0);

      return(
         StopPriceFromDistance(order_type,
                               entry_price,
                               distance_points * point_size)
      );
   }

   double TargetPriceFromPoints(const int order_type,
                                const double entry_price,
                                const double distance_points,
                                const double point_size) const
   {
      if(distance_points <= 0.0 || point_size <= 0.0)
         return(0.0);

      return(
         TargetPriceFromDistance(order_type,
                                 entry_price,
                                 distance_points * point_size)
      );
   }

   double TargetPriceFromR(const int order_type,
                           const double entry_price,
                           const double stop_price,
                           const double reward_r) const
   {
      if(reward_r <= 0.0)
         return(0.0);

      const double risk_distance =
         StopDistancePrice(order_type, entry_price, stop_price);

      if(risk_distance <= 0.0)
         return(0.0);

      return(
         TargetPriceFromDistance(
            order_type,
            entry_price,
            RewardDistanceFromR(risk_distance, reward_r)
         )
      );
   }

   double GeometryRewardRisk(const int order_type,
                             const double entry_price,
                             const double stop_price,
                             const double target_price) const
   {
      const double risk_distance =
         StopDistancePrice(order_type, entry_price, stop_price);

      const double reward_distance =
         TargetDistancePrice(order_type, entry_price, target_price);

      return(RewardRiskRatio(reward_distance, risk_distance));
   }

   bool IsGeometryValid(const int order_type,
                        const double entry_price,
                        const double stop_price,
                        const double target_price) const
   {
      return(
         IsStopPriceValid(order_type, entry_price, stop_price) &&
         IsTargetPriceValid(order_type, entry_price, target_price)
      );
   }

   bool MeetsMinimumStopPoints(const int order_type,
                               const double entry_price,
                               const double stop_price,
                               const double point_size,
                               const double minimum_stop_points) const
   {
      if(minimum_stop_points < 0.0)
         return(false);

      if(!IsStopPriceValid(order_type, entry_price, stop_price))
         return(false);

      const double actual_stop_points =
         StopDistancePoints(order_type,
                            entry_price,
                            stop_price,
                            point_size);

      return(
         actual_stop_points + 0.000000001 >=
         minimum_stop_points
      );
   }

   bool MeetsMinimumRewardRisk(const int order_type,
                               const double entry_price,
                               const double stop_price,
                               const double target_price,
                               const double minimum_reward_risk) const
   {
      if(minimum_reward_risk < 0.0)
         return(false);

      if(!IsGeometryValid(order_type,
                          entry_price,
                          stop_price,
                          target_price))
         return(false);

      const double actual_reward_risk =
         GeometryRewardRisk(order_type,
                            entry_price,
                            stop_price,
                            target_price);

      return(
         actual_reward_risk + 0.000000001 >=
         minimum_reward_risk
      );
   }

   // ---------------------------------------------------------------
   // Block 4: exposure and aggregate open-risk controls
   // ---------------------------------------------------------------
   double AggregateRiskMoney(const double &risk_values[],
                             const int count) const
   {
      if(count <= 0)
         return(0.0);

      const int size = ArraySize(risk_values);
      if(size <= 0)
         return(0.0);

      const int limit = MathMin(count, size);
      double total = 0.0;

      for(int i = 0; i < limit; i++)
      {
         if(risk_values[i] > 0.0)
            total += risk_values[i];
      }

      return(total);
   }

   double AggregateRiskPercent(const double capital,
                               const double &risk_values[],
                               const int count) const
   {
      if(capital <= 0.0)
         return(0.0);

      return(
         FractionToPercent(
            AggregateRiskMoney(risk_values, count) / capital
         )
      );
   }

   double RemainingRiskCapacityMoney(const double capital,
                                     const double maximum_risk_percent,
                                     const double current_open_risk_money) const
   {
      if(capital <= 0.0)
         return(0.0);

      if(maximum_risk_percent < 0.0)
         return(0.0);

      const double maximum_risk_money =
         RiskMoney(capital, maximum_risk_percent);

      if(current_open_risk_money <= 0.0)
         return(maximum_risk_money);

      return(
         MathMax(
            0.0,
            maximum_risk_money - current_open_risk_money
         )
      );
   }

   double RemainingRiskCapacityPercent(const double capital,
                                       const double maximum_risk_percent,
                                       const double current_open_risk_money) const
   {
      if(capital <= 0.0)
         return(0.0);

      return(
         FractionToPercent(
            RemainingRiskCapacityMoney(
               capital,
               maximum_risk_percent,
               current_open_risk_money
            ) / capital
         )
      );
   }

   bool IsOpenRiskLimitBreached(const double capital,
                                const double current_open_risk_money,
                                const double maximum_risk_percent) const
   {
      if(capital <= 0.0)
         return(false);

      if(maximum_risk_percent < 0.0)
         return(false);

      return(
         current_open_risk_money >
         RiskMoney(capital, maximum_risk_percent) + 0.000000001
      );
   }

   bool IsOpenRiskLimitReached(const double capital,
                               const double current_open_risk_money,
                               const double maximum_risk_percent) const
   {
      if(capital <= 0.0)
         return(false);

      if(maximum_risk_percent < 0.0)
         return(false);

      return(
         current_open_risk_money + 0.000000001 >=
         RiskMoney(capital, maximum_risk_percent)
      );
   }

   bool CanAddRiskMoney(const double capital,
                        const double current_open_risk_money,
                        const double proposed_risk_money,
                        const double maximum_risk_percent) const
   {
      if(capital <= 0.0)
         return(false);

      if(current_open_risk_money < 0.0)
         return(false);

      if(proposed_risk_money <= 0.0)
         return(false);

      if(maximum_risk_percent < 0.0)
         return(false);

      const double maximum_risk_money =
         RiskMoney(capital, maximum_risk_percent);

      return(
         current_open_risk_money + proposed_risk_money <=
         maximum_risk_money + 0.000000001
      );
   }

   bool IsTradeCountLimitBreached(const int current_trade_count,
                                  const int maximum_trade_count) const
   {
      if(current_trade_count < 0)
         return(false);

      if(maximum_trade_count < 0)
         return(false);

      return(current_trade_count > maximum_trade_count);
   }

   bool IsTradeCountLimitReached(const int current_trade_count,
                                 const int maximum_trade_count) const
   {
      if(current_trade_count < 0)
         return(false);

      if(maximum_trade_count < 0)
         return(false);

      return(current_trade_count >= maximum_trade_count);
   }

   bool CanAddTrade(const int current_trade_count,
                    const int maximum_trade_count) const
   {
      if(current_trade_count < 0)
         return(false);

      if(maximum_trade_count <= 0)
         return(false);

      return(current_trade_count < maximum_trade_count);
   }

   bool IsSymbolExposureLimitBreached(const double current_symbol_lots,
                                      const double maximum_symbol_lots) const
   {
      if(current_symbol_lots < 0.0)
         return(false);

      if(maximum_symbol_lots < 0.0)
         return(false);

      return(
         current_symbol_lots >
         maximum_symbol_lots + 0.000000001
      );
   }

   bool IsSymbolExposureLimitReached(const double current_symbol_lots,
                                     const double maximum_symbol_lots) const
   {
      if(current_symbol_lots < 0.0)
         return(false);

      if(maximum_symbol_lots < 0.0)
         return(false);

      return(
         current_symbol_lots + 0.000000001 >=
         maximum_symbol_lots
      );
   }

   bool CanAddSymbolLots(const double current_symbol_lots,
                         const double proposed_lots,
                         const double maximum_symbol_lots) const
   {
      if(current_symbol_lots < 0.0)
         return(false);

      if(proposed_lots <= 0.0)
         return(false);

      if(maximum_symbol_lots < 0.0)
         return(false);

      return(
         current_symbol_lots + proposed_lots <=
         maximum_symbol_lots + 0.000000001
      );
   }

   double RemainingSymbolLotCapacity(const double current_symbol_lots,
                                     const double maximum_symbol_lots) const
   {
      if(current_symbol_lots < 0.0)
         return(0.0);

      if(maximum_symbol_lots < 0.0)
         return(0.0);

      return(
         MathMax(
            0.0,
            maximum_symbol_lots - current_symbol_lots
         )
      );
   }

   // ---------------------------------------------------------------
   // Block 5: loss limits, streak controls and lockout state
   // ---------------------------------------------------------------
   double LossMoneyFromPnL(const double pnl_money) const
   {
      if(pnl_money >= 0.0)
         return(0.0);

      return(MathAbs(pnl_money));
   }

   double LossPercentFromPnL(const double reference_capital,
                             const double pnl_money) const
   {
      if(reference_capital <= 0.0)
         return(0.0);

      return(
         FractionToPercent(
            LossMoneyFromPnL(pnl_money) / reference_capital
         )
      );
   }

   bool IsLossLimitBreached(const double reference_capital,
                            const double pnl_money,
                            const double maximum_loss_percent) const
   {
      if(reference_capital <= 0.0)
         return(false);

      if(maximum_loss_percent < 0.0)
         return(false);

      return(
         LossPercentFromPnL(reference_capital, pnl_money) >
         maximum_loss_percent + 0.000000001
      );
   }

   bool IsLossLimitReached(const double reference_capital,
                           const double pnl_money,
                           const double maximum_loss_percent) const
   {
      if(reference_capital <= 0.0)
         return(false);

      if(maximum_loss_percent < 0.0)
         return(false);

      return(
         LossPercentFromPnL(reference_capital, pnl_money) +
         0.000000001 >= maximum_loss_percent
      );
   }

   int NextConsecutiveLossCount(const int current_loss_count,
                                const double closed_trade_pnl) const
   {
      if(current_loss_count < 0)
         return(0);

      if(closed_trade_pnl < 0.0)
         return(current_loss_count + 1);

      return(0);
   }

   bool IsConsecutiveLossLimitReached(const int consecutive_losses,
                                      const int maximum_consecutive_losses) const
   {
      if(consecutive_losses < 0)
         return(false);

      if(maximum_consecutive_losses < 0)
         return(false);

      return(
         consecutive_losses >= maximum_consecutive_losses
      );
   }

   bool IsConsecutiveLossLimitBreached(const int consecutive_losses,
                                       const int maximum_consecutive_losses) const
   {
      if(consecutive_losses < 0)
         return(false);

      if(maximum_consecutive_losses < 0)
         return(false);

      return(
         consecutive_losses > maximum_consecutive_losses
      );
   }

   bool ShouldLockForLossLimit(const double reference_capital,
                               const double pnl_money,
                               const double maximum_loss_percent) const
   {
      return(
         IsLossLimitReached(
            reference_capital,
            pnl_money,
            maximum_loss_percent
         )
      );
   }

   bool ShouldLockForLossStreak(const int consecutive_losses,
                                const int maximum_consecutive_losses) const
   {
      if(maximum_consecutive_losses <= 0)
         return(false);

      return(
         IsConsecutiveLossLimitReached(
            consecutive_losses,
            maximum_consecutive_losses
         )
      );
   }

   bool ShouldRiskLock(const double reference_capital,
                       const double pnl_money,
                       const double maximum_loss_percent,
                       const int consecutive_losses,
                       const int maximum_consecutive_losses) const
   {
      return(
         ShouldLockForLossLimit(
            reference_capital,
            pnl_money,
            maximum_loss_percent
         ) ||
         ShouldLockForLossStreak(
            consecutive_losses,
            maximum_consecutive_losses
         )
      );
   }

   bool CanTradeWhileUnlocked(const bool risk_locked,
                              const bool manual_lock = false) const
   {
      return(!risk_locked && !manual_lock);
   }

   bool CanRecoverFromLock(const bool risk_locked,
                           const bool recovery_allowed,
                           const double current_loss_percent,
                           const double recovery_threshold_percent,
                           const int consecutive_losses,
                           const int recovery_maximum_losses) const
   {
      if(!risk_locked)
         return(false);

      if(!recovery_allowed)
         return(false);

      if(current_loss_percent < 0.0)
         return(false);

      if(recovery_threshold_percent < 0.0)
         return(false);

      if(consecutive_losses < 0)
         return(false);

      if(recovery_maximum_losses < 0)
         return(false);

      return(
         current_loss_percent <=
         recovery_threshold_percent + 0.000000001 &&
         consecutive_losses <= recovery_maximum_losses
      );
   }

   double RiskScaleAfterLosses(const int consecutive_losses,
                               const double reduction_per_loss,
                               const double minimum_scale = 0.0) const
   {
      if(consecutive_losses < 0)
         return(0.0);

      if(reduction_per_loss < 0.0)
         return(0.0);

      if(minimum_scale < 0.0 || minimum_scale > 1.0)
         return(0.0);

      const double scale =
         1.0 -
         ((double)consecutive_losses * reduction_per_loss);

      return(Clamp(scale, minimum_scale, 1.0));
   }

   double ScaledRiskPercent(const double base_risk_percent,
                            const double risk_scale) const
   {
      if(base_risk_percent <= 0.0)
         return(0.0);

      if(risk_scale < 0.0 || risk_scale > 1.0)
         return(0.0);

      return(base_risk_percent * risk_scale);
   }

   // ---------------------------------------------------------------
   // Block 6: unified pre-trade risk facade
   // ---------------------------------------------------------------
   bool IsPreTradeGeometryAllowed(const int order_type,
                                  const double entry_price,
                                  const double stop_price,
                                  const double target_price,
                                  const double point_size,
                                  const double minimum_stop_points,
                                  const double minimum_reward_risk) const
   {
      if(!IsGeometryValid(order_type,
                          entry_price,
                          stop_price,
                          target_price))
         return(false);

      if(!MeetsMinimumStopPoints(order_type,
                                entry_price,
                                stop_price,
                                point_size,
                                minimum_stop_points))
         return(false);

      if(!MeetsMinimumRewardRisk(order_type,
                                entry_price,
                                stop_price,
                                target_price,
                                minimum_reward_risk))
         return(false);

      return(true);
   }

   bool IsPreTradeCapacityAllowed(const double capital,
                                  const double current_open_risk_money,
                                  const double proposed_risk_money,
                                  const double maximum_open_risk_percent,
                                  const int current_trade_count,
                                  const int maximum_trade_count,
                                  const double current_symbol_lots,
                                  const double proposed_lots,
                                  const double maximum_symbol_lots) const
   {
      if(!CanAddRiskMoney(capital,
                          current_open_risk_money,
                          proposed_risk_money,
                          maximum_open_risk_percent))
         return(false);

      if(!CanAddTrade(current_trade_count,
                      maximum_trade_count))
         return(false);

      if(!CanAddSymbolLots(current_symbol_lots,
                           proposed_lots,
                           maximum_symbol_lots))
         return(false);

      return(true);
   }

   bool IsPreTradeLockAllowed(const bool risk_locked,
                              const bool manual_lock) const
   {
      return(CanTradeWhileUnlocked(risk_locked, manual_lock));
   }

   bool CanOpenTrade(const int order_type,
                     const double entry_price,
                     const double stop_price,
                     const double target_price,
                     const double point_size,
                     const double minimum_stop_points,
                     const double minimum_reward_risk,
                     const double capital,
                     const double current_open_risk_money,
                     const double proposed_risk_money,
                     const double maximum_open_risk_percent,
                     const int current_trade_count,
                     const int maximum_trade_count,
                     const double current_symbol_lots,
                     const double proposed_lots,
                     const double maximum_symbol_lots,
                     const bool risk_locked,
                     const bool manual_lock) const
   {
      if(!IsPreTradeLockAllowed(risk_locked, manual_lock))
         return(false);

      if(!IsPreTradeGeometryAllowed(order_type,
                                    entry_price,
                                    stop_price,
                                    target_price,
                                    point_size,
                                    minimum_stop_points,
                                    minimum_reward_risk))
         return(false);

      if(!IsPreTradeCapacityAllowed(capital,
                                    current_open_risk_money,
                                    proposed_risk_money,
                                    maximum_open_risk_percent,
                                    current_trade_count,
                                    maximum_trade_count,
                                    current_symbol_lots,
                                    proposed_lots,
                                    maximum_symbol_lots))
         return(false);

      return(true);
   }

   double MaximumAdditionalRiskMoney(const double capital,
                                     const double current_open_risk_money,
                                     const double maximum_open_risk_percent) const
   {
      return(
         RemainingRiskCapacityMoney(capital,
                                    maximum_open_risk_percent,
                                    current_open_risk_money)
      );
   }

   double MaximumAdditionalSymbolLots(const double current_symbol_lots,
                                      const double maximum_symbol_lots,
                                      const double lot_step) const
   {
      if(lot_step <= 0.0)
         return(0.0);

      return(
         FloorLotsToStep(
            RemainingSymbolLotCapacity(current_symbol_lots,
                                       maximum_symbol_lots),
            lot_step
         )
      );
   }

   double CappedProposedRiskMoney(const double capital,
                                  const double current_open_risk_money,
                                  const double proposed_risk_money,
                                  const double maximum_open_risk_percent) const
   {
      if(proposed_risk_money <= 0.0)
         return(0.0);

      return(
         MathMin(
            proposed_risk_money,
            MaximumAdditionalRiskMoney(capital,
                                       current_open_risk_money,
                                       maximum_open_risk_percent)
         )
      );
   }

   double CappedProposedLots(const double current_symbol_lots,
                             const double proposed_lots,
                             const double maximum_symbol_lots,
                             const double lot_step) const
   {
      if(proposed_lots <= 0.0)
         return(0.0);

      if(lot_step <= 0.0)
         return(0.0);

      const double maximum_additional_lots =
         MaximumAdditionalSymbolLots(current_symbol_lots,
                                     maximum_symbol_lots,
                                     lot_step);

      const double capped_lots =
         MathMin(proposed_lots, maximum_additional_lots);

      return(FloorLotsToStep(capped_lots, lot_step));
   }

   double EffectiveRiskPercent(const double base_risk_percent,
                               const int consecutive_losses,
                               const double reduction_per_loss,
                               const double minimum_scale,
                               const bool risk_locked,
                               const bool manual_lock) const
   {
      if(!CanTradeWhileUnlocked(risk_locked, manual_lock))
         return(0.0);

      const double scale =
         RiskScaleAfterLosses(consecutive_losses,
                              reduction_per_loss,
                              minimum_scale);

      return(ScaledRiskPercent(base_risk_percent, scale));
   }

   double FacadePositionLots(const double capital,
                             const double base_risk_percent,
                             const int consecutive_losses,
                             const double reduction_per_loss,
                             const double minimum_scale,
                             const int order_type,
                             const double entry_price,
                             const double stop_price,
                             const double tick_value,
                             const double tick_size,
                             const double point_size,
                             const double minimum_lots,
                             const double maximum_lots,
                             const double lot_step,
                             const double current_symbol_lots,
                             const double maximum_symbol_lots,
                             const bool risk_locked,
                             const bool manual_lock) const
   {
      if(!IsStopPriceValid(order_type,
                           entry_price,
                           stop_price))
         return(0.0);

      const double effective_risk_percent =
         EffectiveRiskPercent(base_risk_percent,
                              consecutive_losses,
                              reduction_per_loss,
                              minimum_scale,
                              risk_locked,
                              manual_lock);

      if(effective_risk_percent <= 0.0)
         return(0.0);

      const double stop_distance_points =
         StopDistancePoints(order_type,
                            entry_price,
                            stop_price,
                            point_size);

      const double position_lots =
         PositionLots(capital,
                      effective_risk_percent,
                      stop_distance_points,
                      tick_value,
                      tick_size,
                      point_size,
                      minimum_lots,
                      maximum_lots,
                      lot_step);

      return(
         CappedProposedLots(current_symbol_lots,
                            position_lots,
                            maximum_symbol_lots,
                            lot_step)
      );
   }
};

#endif
