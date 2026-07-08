//+------------------------------------------------------------------+
//| BossR_Market.mqh                                                 |
//+------------------------------------------------------------------+
#ifndef __BOSSR_MARKET_MQH__
#define __BOSSR_MARKET_MQH__

#property strict

#include <BossR\BossR_Common.mqh>

class C_BossR_Market
{
private:
   string m_symbol;
   bool   m_initialized;

public:
   C_BossR_Market()
   {
      m_symbol      = "";
      m_initialized = false;
   }

   bool Init(const string symbol = "")
   {
      if(symbol == "")
         m_symbol = Symbol();
      else
         m_symbol = symbol;

      if(m_symbol == "")
      {
         m_initialized = false;
         return false;
      }

      if(MarketInfo(m_symbol, MODE_POINT) <= 0.0)
      {
         m_initialized = false;
         return false;
      }

      m_initialized = true;
      return true;
   }

   void Shutdown()
   {
      m_symbol      = "";
      m_initialized = false;
   }

   bool IsInitialized() const
   {
      return m_initialized;
   }

   string SymbolName() const
   {
      return m_symbol;
   }

   int DigitsValue() const
   {
      if(!m_initialized) return 0;
      return (int)MarketInfo(m_symbol, MODE_DIGITS);
   }

   double PointValue() const
   {
      if(!m_initialized) return 0.0;
      return MarketInfo(m_symbol, MODE_POINT);
   }

   double PipValue() const
   {
      if(!m_initialized) return 0.0;

      int digits = DigitsValue();
      double point = PointValue();

      if(digits == 3 || digits == 5)
         return point * 10.0;

      return point;
   }

   double BidValue() const
   {
      if(!m_initialized) return 0.0;
      return MarketInfo(m_symbol, MODE_BID);
   }

   double AskValue() const
   {
      if(!m_initialized) return 0.0;
      return MarketInfo(m_symbol, MODE_ASK);
   }

   double SpreadPoints() const
   {
      if(!m_initialized) return 0.0;
      return MarketInfo(m_symbol, MODE_SPREAD);
   }

   double SpreadPips() const
   {
      if(!m_initialized) return 0.0;

      double point = PointValue();
      double pip   = PipValue();

      if(point <= 0.0 || pip <= 0.0)
         return 0.0;

      return SpreadPoints() * point / pip;
   }

   bool Refresh()
   {
      if(!m_initialized) return false;
      RefreshRates();
      return true;
   }

   bool HasValidPrices() const
   {
      if(!m_initialized) return false;

      double bid = BidValue();
      double ask = AskValue();

      if(bid <= 0.0) return false;
      if(ask <= 0.0) return false;
      if(ask < bid)  return false;

      return true;
   }

   double NormalizePrice(const double price) const
   {
      if(!m_initialized) return price;
      return NormalizeDouble(price, DigitsValue());
   }

   double PipsToPrice(const double pips) const
   {
      if(!m_initialized) return 0.0;
      return pips * PipValue();
   }

   double PriceToPips(const double price_distance) const
   {
      if(!m_initialized) return 0.0;

      double pip = PipValue();
      if(pip <= 0.0) return 0.0;

      return price_distance / pip;
   }
};

#endif