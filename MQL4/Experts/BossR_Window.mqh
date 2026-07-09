//+------------------------------------------------------------------+
//| BossR_Window.mqh                                                 |
//+------------------------------------------------------------------+
#ifndef __BOSSR_WINDOW_MQH__
#define __BOSSR_WINDOW_MQH__

#property strict

class C_BossR_Window
{
private:
   bool m_initialized;

public:
   C_BossR_Window()
   {
      m_initialized = false;
   }

   bool Init()
   {
      m_initialized = true;
      return true;
   }

   void Deinit()
   {
      m_initialized = false;
   }

   bool IsInitialized() const
   {
      return m_initialized;
   }

   int MainWindow() const
   {
      return 0;
   }

 int WindowsTotal() const
{
   return ::WindowsTotal();
}

   bool IsValidWindow(const int window_index) const
   {
      if(window_index < 0)
         return false;

      if(window_index >= WindowsTotal())
         return false;

      return true;
   }

   int CurrentChartWindow() const
   {
      return WindowFind(WindowExpertName());
   }   int WidthPixels(const int window_index = 0) const
   {
      if(!IsValidWindow(window_index))
         return -1;

      return (int)ChartGetInteger(0, CHART_WIDTH_IN_PIXELS, window_index);
   }

   int HeightPixels(const int window_index = 0) const
   {
      if(!IsValidWindow(window_index))
         return -1;

      return (int)ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS, window_index);
   }

   int FirstVisibleBar() const
   {
      return WindowFirstVisibleBar();
   }

   int VisibleBars() const
   {
      return WindowBarsPerChart();
   }

   double PriceMin(const int window_index = 0) const
   {
      if(!IsValidWindow(window_index))
         return 0.0;

      return WindowPriceMin(window_index);
   }

   double PriceMax(const int window_index = 0) const
   {
      if(!IsValidWindow(window_index))
         return 0.0;

      return WindowPriceMax(window_index);
   }   bool XYToTimePrice(const int x,
                      const int y,
                      int &window_index,
                      datetime &time_value,
                      double &price_value) const
   {
      return ChartXYToTimePrice(0, x, y, window_index, time_value, price_value);
   }

   bool TimePriceToXY(const datetime time_value,
                      const double price_value,
                      const int window_index,
                      int &x,
                      int &y) const
   {
      if(!IsValidWindow(window_index))
         return false;

      return ChartTimePriceToXY(0, window_index, time_value, price_value, x, y);
   }

   bool CenterXY(int &x, int &y, const int window_index = 0) const
   {
      int w = WidthPixels(window_index);
      int h = HeightPixels(window_index);

      if(w <= 0 || h <= 0)
         return false;

      x = w / 2;
      y = h / 2;

      return true;
   }   bool Redraw() const
   {
      ChartRedraw(0);
      return true;
   }

   bool SetAutoScroll(const bool enabled) const
   {
      return ChartSetInteger(0, CHART_AUTOSCROLL, 0, enabled);
   }

   bool SetChartShift(const bool enabled) const
   {
      return ChartSetInteger(0, CHART_SHIFT, 0, enabled);
   }

   bool IsAutoScroll() const
   {
      return (bool)ChartGetInteger(0, CHART_AUTOSCROLL, 0);
   }

   bool IsChartShift() const
   {
      return (bool)ChartGetInteger(0, CHART_SHIFT, 0);
   }

   bool SetScale(const int scale_value) const
   {
      if(scale_value < 0 || scale_value > 5)
         return false;

      return ChartSetInteger(0, CHART_SCALE, 0, scale_value);
   }

   int GetScale() const
   {
      return (int)ChartGetInteger(0, CHART_SCALE, 0);
   }   bool SetShowGrid(const bool enabled) const
   {
      return ChartSetInteger(0, CHART_SHOW_GRID, 0, enabled);
   }

   bool IsShowGrid() const
   {
      return (bool)ChartGetInteger(0, CHART_SHOW_GRID, 0);
   }

   bool SetForeground(const bool enabled) const
   {
      return ChartSetInteger(0, CHART_FOREGROUND, 0, enabled);
   }

   bool IsForeground() const
   {
      return (bool)ChartGetInteger(0, CHART_FOREGROUND, 0);
   }

   bool SetMode(const int mode_value) const
   {
      if(mode_value != CHART_BARS &&
         mode_value != CHART_CANDLES &&
         mode_value != CHART_LINE)
         return false;

      return ChartSetInteger(0, CHART_MODE, 0, mode_value);
   }

   int GetMode() const
   {
      return (int)ChartGetInteger(0, CHART_MODE, 0);
   }

   bool IsMainWindow(const int window_index) const
   {
      return (window_index == 0);
   }
};

#endif