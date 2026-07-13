//+------------------------------------------------------------------+
//| BossR_Portfolio_Block6_CONTROL_FULL.mqh                             |
//| BossR Framework - Portfolio Module                               |
//| Block 6: portfolio admission and control facade                            |
//| MT4 only                                                         |
//+------------------------------------------------------------------+
#ifndef __BOSSR_PORTFOLIO_BLOCK6_CONTROL_FULL_MQH__
#define __BOSSR_PORTFOLIO_BLOCK6_CONTROL_FULL_MQH__

class CBossRPortfolio
{
private:
   int SafeCount(const int requested_count,
                 const int array_size) const
   {
      if(requested_count <= 0 || array_size <= 0)
         return(0);

      return(MathMin(requested_count, array_size));
   }

public:
   CBossRPortfolio(void)
   {
   }

   double SumSigned(const double &values[],
                    const int count) const
   {
      const int limit = SafeCount(count, ArraySize(values));

      double total = 0.0;

      for(int i = 0; i < limit; i++)
         total += values[i];

      return(total);
   }

   double SumPositive(const double &values[],
                      const int count) const
   {
      const int limit = SafeCount(count, ArraySize(values));

      double total = 0.0;

      for(int i = 0; i < limit; i++)
      {
         if(values[i] > 0.0)
            total += values[i];
      }

      return(total);
   }

   double SumNegative(const double &values[],
                      const int count) const
   {
      const int limit = SafeCount(count, ArraySize(values));

      double total = 0.0;

      for(int i = 0; i < limit; i++)
      {
         if(values[i] < 0.0)
            total += values[i];
      }

      return(total);
   }

   double SumAbsolute(const double &values[],
                      const int count) const
   {
      const int limit = SafeCount(count, ArraySize(values));

      double total = 0.0;

      for(int i = 0; i < limit; i++)
         total += MathAbs(values[i]);

      return(total);
   }

   double AverageSigned(const double &values[],
                        const int count) const
   {
      const int limit = SafeCount(count, ArraySize(values));

      if(limit <= 0)
         return(0.0);

      return(SumSigned(values, limit) / (double)limit);
   }

   double AveragePositive(const double &values[],
                          const int count) const
   {
      const int limit = SafeCount(count, ArraySize(values));

      double total = 0.0;
      int positive_count = 0;

      for(int i = 0; i < limit; i++)
      {
         if(values[i] > 0.0)
         {
            total += values[i];
            positive_count++;
         }
      }

      if(positive_count <= 0)
         return(0.0);

      return(total / (double)positive_count);
   }

   double AverageNegative(const double &values[],
                          const int count) const
   {
      const int limit = SafeCount(count, ArraySize(values));

      double total = 0.0;
      int negative_count = 0;

      for(int i = 0; i < limit; i++)
      {
         if(values[i] < 0.0)
         {
            total += values[i];
            negative_count++;
         }
      }

      if(negative_count <= 0)
         return(0.0);

      return(total / (double)negative_count);
   }

   int CountPositive(const double &values[],
                     const int count) const
   {
      const int limit = SafeCount(count, ArraySize(values));

      int total = 0;

      for(int i = 0; i < limit; i++)
      {
         if(values[i] > 0.0)
            total++;
      }

      return(total);
   }

   int CountNegative(const double &values[],
                     const int count) const
   {
      const int limit = SafeCount(count, ArraySize(values));

      int total = 0;

      for(int i = 0; i < limit; i++)
      {
         if(values[i] < 0.0)
            total++;
      }

      return(total);
   }

   int CountZero(const double &values[],
                 const int count,
                 const double epsilon = 0.000000001) const
   {
      if(epsilon < 0.0)
         return(0);

      const int limit = SafeCount(count, ArraySize(values));

      int total = 0;

      for(int i = 0; i < limit; i++)
      {
         if(MathAbs(values[i]) <= epsilon)
            total++;
      }

      return(total);
   }

   int CountActive(const bool &active_flags[],
                   const int count) const
   {
      const int limit = SafeCount(count, ArraySize(active_flags));

      int total = 0;

      for(int i = 0; i < limit; i++)
      {
         if(active_flags[i])
            total++;
      }

      return(total);
   }

   double GrossExposureLots(const double &buy_lots[],
                            const double &sell_lots[],
                            const int count) const
   {
      const int buy_limit = SafeCount(count, ArraySize(buy_lots));
      const int sell_limit = SafeCount(count, ArraySize(sell_lots));

      return(
         SumPositive(buy_lots, buy_limit) +
         SumPositive(sell_lots, sell_limit)
      );
   }

   double NetExposureLots(const double &buy_lots[],
                          const double &sell_lots[],
                          const int count) const
   {
      const int buy_limit = SafeCount(count, ArraySize(buy_lots));
      const int sell_limit = SafeCount(count, ArraySize(sell_lots));

      return(
         SumPositive(buy_lots, buy_limit) -
         SumPositive(sell_lots, sell_limit)
      );
   }

   double LongExposureLots(const double &buy_lots[],
                           const int count) const
   {
      return(SumPositive(buy_lots, count));
   }

   double ShortExposureLots(const double &sell_lots[],
                            const int count) const
   {
      return(SumPositive(sell_lots, count));
   }

   bool IsNetLong(const double &buy_lots[],
                  const double &sell_lots[],
                  const int count,
                  const double epsilon = 0.000000001) const
   {
      if(epsilon < 0.0)
         return(false);

      return(NetExposureLots(buy_lots, sell_lots, count) > epsilon);
   }

   bool IsNetShort(const double &buy_lots[],
                   const double &sell_lots[],
                   const int count,
                   const double epsilon = 0.000000001) const
   {
      if(epsilon < 0.0)
         return(false);

      return(NetExposureLots(buy_lots, sell_lots, count) < -epsilon);
   }

   bool IsExposureFlat(const double &buy_lots[],
                       const double &sell_lots[],
                       const int count,
                       const double epsilon = 0.000000001) const
   {
      if(epsilon < 0.0)
         return(false);

      return(
         MathAbs(NetExposureLots(buy_lots, sell_lots, count)) <=
         epsilon
      );
   }


   double AllocationPercent(const double component_value,
                            const double total_value) const
   {
      if(component_value < 0.0 || total_value <= 0.0)
         return(0.0);

      return((component_value / total_value) * 100.0);
   }

   double LargestPositive(const double &values[],
                          const int count) const
   {
      const int limit = SafeCount(count, ArraySize(values));

      double largest = 0.0;

      for(int i = 0; i < limit; i++)
      {
         if(values[i] > largest)
            largest = values[i];
      }

      return(largest);
   }

   double SmallestPositive(const double &values[],
                           const int count) const
   {
      const int limit = SafeCount(count, ArraySize(values));

      double smallest = 0.0;
      bool found = false;

      for(int i = 0; i < limit; i++)
      {
         if(values[i] > 0.0)
         {
            if(!found || values[i] < smallest)
            {
               smallest = values[i];
               found = true;
            }
         }
      }

      if(!found)
         return(0.0);

      return(smallest);
   }

   int LargestPositiveIndex(const double &values[],
                            const int count) const
   {
      const int limit = SafeCount(count, ArraySize(values));

      int largest_index = -1;
      double largest = 0.0;

      for(int i = 0; i < limit; i++)
      {
         if(values[i] > largest)
         {
            largest = values[i];
            largest_index = i;
         }
      }

      return(largest_index);
   }

   double LargestAllocationPercent(const double &values[],
                                   const int count) const
   {
      const double total = SumPositive(values, count);

      if(total <= 0.0)
         return(0.0);

      return(AllocationPercent(
         LargestPositive(values, count),
         total
      ));
   }

   double HerfindahlIndex(const double &values[],
                          const int count) const
   {
      const int limit = SafeCount(count, ArraySize(values));
      const double total = SumPositive(values, limit);

      if(total <= 0.0)
         return(0.0);

      double hhi = 0.0;

      for(int i = 0; i < limit; i++)
      {
         if(values[i] > 0.0)
         {
            const double weight = values[i] / total;
            hhi += weight * weight;
         }
      }

      return(hhi);
   }

   double EffectivePositionCount(const double &values[],
                                 const int count) const
   {
      const double hhi = HerfindahlIndex(values, count);

      if(hhi <= 0.0)
         return(0.0);

      return(1.0 / hhi);
   }

   bool IsAllocationWithinLimit(const double component_value,
                                const double total_value,
                                const double max_percent,
                                const double epsilon = 0.000000001) const
   {
      if(component_value < 0.0 ||
         total_value <= 0.0 ||
         max_percent < 0.0 ||
         epsilon < 0.0)
      {
         return(false);
      }

      return(
         AllocationPercent(component_value, total_value) <=
         (max_percent + epsilon)
      );
   }

   bool IsPortfolioConcentrated(const double &values[],
                                const int count,
                                const double max_allocation_percent,
                                const double epsilon = 0.000000001) const
   {
      if(max_allocation_percent < 0.0 || epsilon < 0.0)
         return(false);

      const double total = SumPositive(values, count);

      if(total <= 0.0)
         return(false);

      return(
         LargestAllocationPercent(values, count) >
         (max_allocation_percent + epsilon)
      );
   }

   double RemainingAllocationCapacity(const double current_value,
                                      const double total_limit) const
   {
      if(current_value < 0.0 || total_limit <= 0.0)
         return(0.0);

      return(MathMax(0.0, total_limit - current_value));
   }

   bool CanAddAllocation(const double current_value,
                         const double proposed_value,
                         const double total_limit,
                         const double epsilon = 0.000000001) const
   {
      if(current_value < 0.0 ||
         proposed_value < 0.0 ||
         total_limit <= 0.0 ||
         epsilon < 0.0)
      {
         return(false);
      }

      return(
         (current_value + proposed_value) <=
         (total_limit + epsilon)
      );
   }

   double ScaleToAllocationLimit(const double requested_value,
                                 const double current_value,
                                 const double total_limit) const
   {
      if(requested_value <= 0.0 ||
         current_value < 0.0 ||
         total_limit <= 0.0)
      {
         return(0.0);
      }

      return(MathMin(
         requested_value,
         RemainingAllocationCapacity(current_value, total_limit)
      ));
   }


   double TargetAllocationValue(const double total_value,
                                const double target_percent) const
   {
      if(total_value <= 0.0 ||
         target_percent < 0.0)
      {
         return(0.0);
      }

      return(total_value * (target_percent / 100.0));
   }

   double RebalanceDeltaValue(const double current_value,
                              const double total_value,
                              const double target_percent) const
   {
      if(current_value < 0.0 ||
         total_value <= 0.0 ||
         target_percent < 0.0)
      {
         return(0.0);
      }

      return(
         TargetAllocationValue(total_value, target_percent) -
         current_value
      );
   }

   double TrimToAllocationPercent(const double current_value,
                                  const double total_value,
                                  const double max_percent) const
   {
      if(current_value < 0.0 ||
         total_value <= 0.0 ||
         max_percent < 0.0)
      {
         return(0.0);
      }

      const double max_value =
         TargetAllocationValue(total_value, max_percent);

      return(MathMax(0.0, current_value - max_value));
   }

   double AddToAllocationPercent(const double current_value,
                                 const double total_value,
                                 const double target_percent) const
   {
      if(current_value < 0.0 ||
         total_value <= 0.0 ||
         target_percent < 0.0)
      {
         return(0.0);
      }

      const double target_value =
         TargetAllocationValue(total_value, target_percent);

      return(MathMax(0.0, target_value - current_value));
   }

   bool IsAtOrAboveAllocationPercent(const double current_value,
                                     const double total_value,
                                     const double threshold_percent,
                                     const double epsilon = 0.000000001) const
   {
      if(current_value < 0.0 ||
         total_value <= 0.0 ||
         threshold_percent < 0.0 ||
         epsilon < 0.0)
      {
         return(false);
      }

      return(
         AllocationPercent(current_value, total_value) + epsilon >=
         threshold_percent
      );
   }

   bool IsAtOrBelowAllocationPercent(const double current_value,
                                     const double total_value,
                                     const double threshold_percent,
                                     const double epsilon = 0.000000001) const
   {
      if(current_value < 0.0 ||
         total_value <= 0.0 ||
         threshold_percent < 0.0 ||
         epsilon < 0.0)
      {
         return(false);
      }

      return(
         AllocationPercent(current_value, total_value) <=
         threshold_percent + epsilon
      );
   }

   double ClampAllocationPercent(const double requested_percent,
                                 const double min_percent,
                                 const double max_percent) const
   {
      if(min_percent < 0.0 ||
         max_percent < min_percent)
      {
         return(0.0);
      }

      return(
         MathMax(
            min_percent,
            MathMin(requested_percent, max_percent)
         )
      );
   }

   double NormalizeWeightPercent(const double weight_value,
                                 const double total_weight) const
   {
      if(weight_value < 0.0 ||
         total_weight <= 0.0)
      {
         return(0.0);
      }

      return((weight_value / total_weight) * 100.0);
   }

   double WeightGapPercent(const double current_percent,
                           const double target_percent) const
   {
      if(current_percent < 0.0 ||
         target_percent < 0.0)
      {
         return(0.0);
      }

      return(target_percent - current_percent);
   }

   bool NeedsRebalance(const double current_percent,
                       const double target_percent,
                       const double tolerance_percent,
                       const double epsilon = 0.000000001) const
   {
      if(current_percent < 0.0 ||
         target_percent < 0.0 ||
         tolerance_percent < 0.0 ||
         epsilon < 0.0)
      {
         return(false);
      }

      return(
         MathAbs(current_percent - target_percent) >
         (tolerance_percent + epsilon)
      );
   }

   int CountBreachedAllocations(const double &values[],
                                const int count,
                                const double max_percent) const
   {
      if(max_percent < 0.0)
         return(0);

      const int limit = SafeCount(count, ArraySize(values));
      const double total = SumPositive(values, limit);

      if(total <= 0.0)
         return(0);

      int breached = 0;

      for(int i = 0; i < limit; i++)
      {
         if(values[i] > 0.0 &&
            AllocationPercent(values[i], total) > max_percent)
         {
            breached++;
         }
      }

      return(breached);
   }

   double TotalTrimRequired(const double &values[],
                            const int count,
                            const double max_percent) const
   {
      if(max_percent < 0.0)
         return(0.0);

      const int limit = SafeCount(count, ArraySize(values));
      const double total = SumPositive(values, limit);

      if(total <= 0.0)
         return(0.0);

      const double max_value =
         TargetAllocationValue(total, max_percent);

      double trim_total = 0.0;

      for(int i = 0; i < limit; i++)
      {
         if(values[i] > max_value)
            trim_total += (values[i] - max_value);
      }

      return(trim_total);
   }


   double DrawdownValue(const double peak_value,
                        const double current_value) const
   {
      if(peak_value <= 0.0 || current_value < 0.0)
         return(0.0);

      return(MathMax(0.0, peak_value - current_value));
   }

   double DrawdownPercent(const double peak_value,
                          const double current_value) const
   {
      if(peak_value <= 0.0 || current_value < 0.0)
         return(0.0);

      return(
         (DrawdownValue(peak_value, current_value) /
          peak_value) * 100.0
      );
   }

   bool IsInDrawdown(const double peak_value,
                     const double current_value,
                     const double epsilon = 0.000000001) const
   {
      if(peak_value <= 0.0 ||
         current_value < 0.0 ||
         epsilon < 0.0)
      {
         return(false);
      }

      return(current_value < (peak_value - epsilon));
   }

   bool IsDrawdownWithinLimit(const double peak_value,
                              const double current_value,
                              const double max_drawdown_percent,
                              const double epsilon = 0.000000001) const
   {
      if(peak_value <= 0.0 ||
         current_value < 0.0 ||
         max_drawdown_percent < 0.0 ||
         epsilon < 0.0)
      {
         return(false);
      }

      return(
         DrawdownPercent(peak_value, current_value) <=
         (max_drawdown_percent + epsilon)
      );
   }

   double RemainingDrawdownPercent(const double peak_value,
                                   const double current_value,
                                   const double max_drawdown_percent) const
   {
      if(peak_value <= 0.0 ||
         current_value < 0.0 ||
         max_drawdown_percent < 0.0)
      {
         return(0.0);
      }

      return(
         MathMax(
            0.0,
            max_drawdown_percent -
            DrawdownPercent(peak_value, current_value)
         )
      );
   }

   double RecoveryPercent(const double trough_value,
                          const double current_value,
                          const double prior_peak_value) const
   {
      if(trough_value < 0.0 ||
         prior_peak_value <= trough_value ||
         current_value < trough_value)
      {
         return(0.0);
      }

      const double recovery_range =
         prior_peak_value - trough_value;

      const double recovered =
         MathMin(current_value, prior_peak_value) -
         trough_value;

      return((recovered / recovery_range) * 100.0);
   }

   double PeakValue(const double &values[],
                    const int count) const
   {
      const int limit = SafeCount(count, ArraySize(values));

      if(limit <= 0)
         return(0.0);

      double peak = values[0];

      for(int i = 1; i < limit; i++)
      {
         if(values[i] > peak)
            peak = values[i];
      }

      return(peak);
   }

   double TroughValue(const double &values[],
                      const int count) const
   {
      const int limit = SafeCount(count, ArraySize(values));

      if(limit <= 0)
         return(0.0);

      double trough = values[0];

      for(int i = 1; i < limit; i++)
      {
         if(values[i] < trough)
            trough = values[i];
      }

      return(trough);
   }

   double MaximumDrawdownValue(const double &equity_values[],
                               const int count) const
   {
      const int limit =
         SafeCount(count, ArraySize(equity_values));

      if(limit <= 0)
         return(0.0);

      double peak = equity_values[0];
      double max_drawdown = 0.0;

      for(int i = 1; i < limit; i++)
      {
         if(equity_values[i] > peak)
            peak = equity_values[i];

         if(peak > 0.0 && equity_values[i] >= 0.0)
         {
            const double drawdown =
               peak - equity_values[i];

            if(drawdown > max_drawdown)
               max_drawdown = drawdown;
         }
      }

      return(MathMax(0.0, max_drawdown));
   }

   double MaximumDrawdownPercent(const double &equity_values[],
                                 const int count) const
   {
      const int limit =
         SafeCount(count, ArraySize(equity_values));

      if(limit <= 0)
         return(0.0);

      double peak = equity_values[0];
      double max_drawdown_percent = 0.0;

      for(int i = 1; i < limit; i++)
      {
         if(equity_values[i] > peak)
            peak = equity_values[i];

         if(peak > 0.0 && equity_values[i] >= 0.0)
         {
            const double drawdown_percent =
               ((peak - equity_values[i]) / peak) * 100.0;

            if(drawdown_percent > max_drawdown_percent)
               max_drawdown_percent = drawdown_percent;
         }
      }

      return(MathMax(0.0, max_drawdown_percent));
   }

   int CountUnderwater(const double &equity_values[],
                       const int count,
                       const double epsilon = 0.000000001) const
   {
      if(epsilon < 0.0)
         return(0);

      const int limit =
         SafeCount(count, ArraySize(equity_values));

      if(limit <= 0)
         return(0);

      double peak = equity_values[0];
      int underwater = 0;

      for(int i = 1; i < limit; i++)
      {
         if(equity_values[i] > peak)
            peak = equity_values[i];

         if(equity_values[i] < (peak - epsilon))
            underwater++;
      }

      return(underwater);
   }

   double UnderwaterPercent(const double &equity_values[],
                            const int count,
                            const double epsilon = 0.000000001) const
   {
      if(epsilon < 0.0)
         return(0.0);

      const int limit =
         SafeCount(count, ArraySize(equity_values));

      if(limit <= 1)
         return(0.0);

      return(
         ((double)CountUnderwater(
            equity_values, limit, epsilon
         ) / (double)(limit - 1)) * 100.0
      );
   }

   bool PortfolioHealthPass(const double peak_value,
                            const double current_value,
                            const double max_drawdown_percent,
                            const double gross_exposure,
                            const double max_gross_exposure,
                            const double epsilon = 0.000000001) const
   {
      if(peak_value <= 0.0 ||
         current_value < 0.0 ||
         max_drawdown_percent < 0.0 ||
         gross_exposure < 0.0 ||
         max_gross_exposure < 0.0 ||
         epsilon < 0.0)
      {
         return(false);
      }

      return(
         IsDrawdownWithinLimit(
            peak_value,
            current_value,
            max_drawdown_percent,
            epsilon
         ) &&
         gross_exposure <=
         (max_gross_exposure + epsilon)
      );
   }


   double ClampCorrelation(const double correlation) const
   {
      return(MathMax(-1.0, MathMin(correlation, 1.0)));
   }

   double AbsoluteCorrelation(const double correlation) const
   {
      return(MathAbs(ClampCorrelation(correlation)));
   }

   bool IsPositiveCorrelation(const double correlation,
                              const double threshold,
                              const double epsilon = 0.000000001) const
   {
      if(threshold < 0.0 ||
         threshold > 1.0 ||
         epsilon < 0.0)
      {
         return(false);
      }

      return(
         ClampCorrelation(correlation) + epsilon >= threshold
      );
   }

   bool IsNegativeCorrelation(const double correlation,
                              const double threshold,
                              const double epsilon = 0.000000001) const
   {
      if(threshold < 0.0 ||
         threshold > 1.0 ||
         epsilon < 0.0)
      {
         return(false);
      }

      return(
         ClampCorrelation(correlation) - epsilon <= -threshold
      );
   }

   bool IsHighlyCorrelated(const double correlation,
                           const double threshold,
                           const double epsilon = 0.000000001) const
   {
      if(threshold < 0.0 ||
         threshold > 1.0 ||
         epsilon < 0.0)
      {
         return(false);
      }

      return(
         AbsoluteCorrelation(correlation) + epsilon >= threshold
      );
   }

   double CorrelationPenalty(const double correlation,
                             const double threshold) const
   {
      if(threshold < 0.0 || threshold >= 1.0)
         return(0.0);

      const double absolute_correlation =
         AbsoluteCorrelation(correlation);

      if(absolute_correlation <= threshold)
         return(0.0);

      return(
         (absolute_correlation - threshold) /
         (1.0 - threshold)
      );
   }

   double CorrelationAdjustedValue(const double requested_value,
                                   const double correlation,
                                   const double threshold) const
   {
      if(requested_value <= 0.0)
         return(0.0);

      return(
         requested_value *
         (1.0 - CorrelationPenalty(
            correlation,
            threshold
         ))
      );
   }

   int CountHighCorrelations(const double &correlations[],
                             const int count,
                             const double threshold) const
   {
      if(threshold < 0.0 || threshold > 1.0)
         return(0);

      const int limit =
         SafeCount(count, ArraySize(correlations));

      int total = 0;

      for(int i = 0; i < limit; i++)
      {
         if(AbsoluteCorrelation(correlations[i]) >= threshold)
            total++;
      }

      return(total);
   }

   double AverageAbsoluteCorrelation(
      const double &correlations[],
      const int count) const
   {
      const int limit =
         SafeCount(count, ArraySize(correlations));

      if(limit <= 0)
         return(0.0);

      double total = 0.0;

      for(int i = 0; i < limit; i++)
         total += AbsoluteCorrelation(correlations[i]);

      return(total / (double)limit);
   }

   double MaximumAbsoluteCorrelation(
      const double &correlations[],
      const int count) const
   {
      const int limit =
         SafeCount(count, ArraySize(correlations));

      double maximum = 0.0;

      for(int i = 0; i < limit; i++)
      {
         const double value =
            AbsoluteCorrelation(correlations[i]);

         if(value > maximum)
            maximum = value;
      }

      return(maximum);
   }

   bool DependencyLimitPass(const double &correlations[],
                            const int count,
                            const double threshold,
                            const int max_high_count) const
   {
      if(threshold < 0.0 ||
         threshold > 1.0 ||
         max_high_count < 0)
      {
         return(false);
      }

      return(
         CountHighCorrelations(
            correlations,
            count,
            threshold
         ) <= max_high_count
      );
   }

   double DependencyScore(const double &correlations[],
                          const int count,
                          const double threshold) const
   {
      if(threshold < 0.0 || threshold >= 1.0)
         return(0.0);

      const int limit =
         SafeCount(count, ArraySize(correlations));

      if(limit <= 0)
         return(0.0);

      double total_penalty = 0.0;

      for(int i = 0; i < limit; i++)
      {
         total_penalty += CorrelationPenalty(
            correlations[i],
            threshold
         );
      }

      return(total_penalty / (double)limit);
   }


   bool ExposureLimitPass(const double current_exposure,
                          const double proposed_exposure,
                          const double max_exposure,
                          const double epsilon = 0.000000001) const
   {
      if(current_exposure < 0.0 ||
         proposed_exposure < 0.0 ||
         max_exposure < 0.0 ||
         epsilon < 0.0)
      {
         return(false);
      }

      return(
         (current_exposure + proposed_exposure) <=
         (max_exposure + epsilon)
      );
   }

   bool ConcentrationLimitPass(const double current_value,
                               const double proposed_value,
                               const double portfolio_value,
                               const double max_percent,
                               const double epsilon = 0.000000001) const
   {
      if(current_value < 0.0 ||
         proposed_value < 0.0 ||
         portfolio_value <= 0.0 ||
         max_percent < 0.0 ||
         epsilon < 0.0)
      {
         return(false);
      }

      const double projected_portfolio_value =
         portfolio_value + proposed_value;

      const double projected_component_value =
         current_value + proposed_value;

      return(
         AllocationPercent(
            projected_component_value,
            projected_portfolio_value
         ) <= (max_percent + epsilon)
      );
   }

   double MaximumAdmissibleExposure(const double current_exposure,
                                    const double max_exposure) const
   {
      if(current_exposure < 0.0 || max_exposure < 0.0)
         return(0.0);

      return(MathMax(0.0, max_exposure - current_exposure));
   }

   double MaximumAdmissibleConcentrationValue(
      const double current_value,
      const double portfolio_value,
      const double max_percent) const
   {
      if(current_value < 0.0 ||
         portfolio_value <= 0.0 ||
         max_percent < 0.0 ||
         max_percent >= 100.0)
      {
         return(0.0);
      }

      const double fraction = max_percent / 100.0;

      return(
         MathMax(
            0.0,
            ((fraction * portfolio_value) - current_value) /
            (1.0 - fraction)
         )
      );
   }

   double MaximumAdmissibleValue(const double current_exposure,
                                 const double max_exposure,
                                 const double current_component_value,
                                 const double portfolio_value,
                                 const double max_allocation_percent) const
   {
      const double exposure_capacity =
         MaximumAdmissibleExposure(
            current_exposure,
            max_exposure
         );

      const double concentration_capacity =
         MaximumAdmissibleConcentrationValue(
            current_component_value,
            portfolio_value,
            max_allocation_percent
         );

      return(MathMin(
         exposure_capacity,
         concentration_capacity
      ));
   }

   double ScaleAdmissionValue(const double requested_value,
                              const double current_exposure,
                              const double max_exposure,
                              const double current_component_value,
                              const double portfolio_value,
                              const double max_allocation_percent,
                              const double correlation,
                              const double correlation_threshold) const
   {
      if(requested_value <= 0.0)
         return(0.0);

      const double capacity =
         MaximumAdmissibleValue(
            current_exposure,
            max_exposure,
            current_component_value,
            portfolio_value,
            max_allocation_percent
         );

      const double capacity_scaled =
         MathMin(requested_value, capacity);

      return(
         CorrelationAdjustedValue(
            capacity_scaled,
            correlation,
            correlation_threshold
         )
      );
   }

   bool PortfolioAdmissionPass(
      const double peak_value,
      const double current_value,
      const double max_drawdown_percent,
      const double current_exposure,
      const double proposed_exposure,
      const double max_exposure,
      const double current_component_value,
      const double portfolio_value,
      const double max_allocation_percent,
      const double &correlations[],
      const int correlation_count,
      const double correlation_threshold,
      const int max_high_correlation_count,
      const double epsilon = 0.000000001) const
   {
      if(epsilon < 0.0)
         return(false);

      if(!IsDrawdownWithinLimit(
            peak_value,
            current_value,
            max_drawdown_percent,
            epsilon))
      {
         return(false);
      }

      if(!ExposureLimitPass(
            current_exposure,
            proposed_exposure,
            max_exposure,
            epsilon))
      {
         return(false);
      }

      if(!ConcentrationLimitPass(
            current_component_value,
            proposed_exposure,
            portfolio_value,
            max_allocation_percent,
            epsilon))
      {
         return(false);
      }

      if(!DependencyLimitPass(
            correlations,
            correlation_count,
            correlation_threshold,
            max_high_correlation_count))
      {
         return(false);
      }

      return(true);
   }

   int PortfolioControlCode(
      const double peak_value,
      const double current_value,
      const double max_drawdown_percent,
      const double current_exposure,
      const double proposed_exposure,
      const double max_exposure,
      const double current_component_value,
      const double portfolio_value,
      const double max_allocation_percent,
      const double &correlations[],
      const int correlation_count,
      const double correlation_threshold,
      const int max_high_correlation_count,
      const double epsilon = 0.000000001) const
   {
      if(epsilon < 0.0)
         return(-1);

      if(!IsDrawdownWithinLimit(
            peak_value,
            current_value,
            max_drawdown_percent,
            epsilon))
      {
         return(1);
      }

      if(!ExposureLimitPass(
            current_exposure,
            proposed_exposure,
            max_exposure,
            epsilon))
      {
         return(2);
      }

      if(!ConcentrationLimitPass(
            current_component_value,
            proposed_exposure,
            portfolio_value,
            max_allocation_percent,
            epsilon))
      {
         return(3);
      }

      if(!DependencyLimitPass(
            correlations,
            correlation_count,
            correlation_threshold,
            max_high_correlation_count))
      {
         return(4);
      }

      return(0);
   }

   double PortfolioPnL(const double &profit_values[],
                       const int count) const
   {
      return(SumSigned(profit_values, count));
   }

   double PortfolioProfit(const double &profit_values[],
                          const int count) const
   {
      return(SumPositive(profit_values, count));
   }

   double PortfolioLoss(const double &profit_values[],
                        const int count) const
   {
      return(MathAbs(SumNegative(profit_values, count)));
   }

   double PortfolioPnLPercent(const double capital,
                              const double portfolio_pnl) const
   {
      if(capital <= 0.0)
         return(0.0);

      return((portfolio_pnl / capital) * 100.0);
   }

   double WinRatePercent(const double &results[],
                         const int count) const
   {
      const int limit = SafeCount(count, ArraySize(results));

      if(limit <= 0)
         return(0.0);

      return(
         ((double)CountPositive(results, limit) /
          (double)limit) * 100.0
      );
   }

   double ProfitFactor(const double &results[],
                       const int count) const
   {
      const double gross_profit = SumPositive(results, count);
      const double gross_loss = MathAbs(SumNegative(results, count));

      if(gross_loss <= 0.0)
         return(0.0);

      return(gross_profit / gross_loss);
   }

   bool HasPositivePnL(const double &profit_values[],
                       const int count,
                       const double epsilon = 0.000000001) const
   {
      if(epsilon < 0.0)
         return(false);

      return(PortfolioPnL(profit_values, count) > epsilon);
   }

   bool HasNegativePnL(const double &profit_values[],
                       const int count,
                       const double epsilon = 0.000000001) const
   {
      if(epsilon < 0.0)
         return(false);

      return(PortfolioPnL(profit_values, count) < -epsilon);
   }

   bool HasFlatPnL(const double &profit_values[],
                   const int count,
                   const double epsilon = 0.000000001) const
   {
      if(epsilon < 0.0)
         return(false);

      return(
         MathAbs(PortfolioPnL(profit_values, count)) <= epsilon
      );
   }
};

#endif
