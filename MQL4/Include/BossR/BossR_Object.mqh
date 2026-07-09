//+------------------------------------------------------------------+
//| BossR_Object.mqh                                                 |
//+------------------------------------------------------------------+
#ifndef __BOSSR_OBJECT_MQH__
#define __BOSSR_OBJECT_MQH__

#property strict

class C_BossR_Object
{
public:
   bool IsInitialized(){ return true; }

   bool Exists(string name)
   {
      if(name == "") return false;
      return (ObjectFind(0, name) >= 0);
   }

   bool Delete(string name)
   {
      if(name == "") return false;
      if(!Exists(name)) return true;
      return ObjectDelete(0, name);
   }

   bool StartsWith(string text, string prefix)
   {
      if(prefix == "") return true;
      if(StringLen(text) < StringLen(prefix)) return false;
      return (StringFind(text, prefix, 0) == 0);
   }

   int CountPrefix(string prefix)
   {
      int count = 0;
      int total = ObjectsTotal(0, -1, -1);

      for(int i = 0; i < total; i++)
      {
         string name = ObjectName(0, i, -1, -1);
         if(StartsWith(name, prefix)) count++;
      }
      return count;
   }

   int DeletePrefix(string prefix)
   {
      int deleted = 0;

      for(int i = ObjectsTotal(0, -1, -1) - 1; i >= 0; i--)
      {
         string name = ObjectName(0, i, -1, -1);
         if(StartsWith(name, prefix))
         {
            if(ObjectDelete(0, name)) deleted++;
         }
      }
      return deleted;
   }

   int CountType(int type, string prefix = "")
   {
      int count = 0;
      int total = ObjectsTotal(0, -1, -1);

      for(int i = 0; i < total; i++)
      {
         string name = ObjectName(0, i, -1, -1);
         if(!StartsWith(name, prefix)) continue;

         if((int)ObjectGetInteger(0, name, OBJPROP_TYPE) == type)
            count++;
      }

      return count;
   }

   int DeleteType(int type, string prefix = "")
   {
      int deleted = 0;

      for(int i = ObjectsTotal(0, -1, -1) - 1; i >= 0; i--)
      {
         string name = ObjectName(0, i, -1, -1);
         if(!StartsWith(name, prefix)) continue;

         if((int)ObjectGetInteger(0, name, OBJPROP_TYPE) == type)
         {
            if(ObjectDelete(0, name)) deleted++;
         }
      }

      return deleted;
   }

   int SetColorPrefix(string prefix, color clr)
   {
      int changed = 0;
      int total = ObjectsTotal(0, -1, -1);

      for(int i = 0; i < total; i++)
      {
         string name = ObjectName(0, i, -1, -1);
         if(StartsWith(name, prefix))
         {
            if(SetColor(name, clr)) changed++;
         }
      }

      return changed;
   }

   int SetWidthPrefix(string prefix, int width)
   {
      int changed = 0;
      int total = ObjectsTotal(0, -1, -1);

      for(int i = 0; i < total; i++)
      {
         string name = ObjectName(0, i, -1, -1);
         if(StartsWith(name, prefix))
         {
            if(SetWidth(name, width)) changed++;
         }
      }

      return changed;
   }

   int SetStylePrefix(string prefix, int style)
   {
      int changed = 0;
      int total = ObjectsTotal(0, -1, -1);

      for(int i = 0; i < total; i++)
      {
         string name = ObjectName(0, i, -1, -1);
         if(StartsWith(name, prefix))
         {
            if(SetStyle(name, style)) changed++;
         }
      }

      return changed;
   }

   int SetHiddenPrefix(string prefix, bool hidden)
   {
      int changed = 0;
      int total = ObjectsTotal(0, -1, -1);

      for(int i = 0; i < total; i++)
      {
         string name = ObjectName(0, i, -1, -1);
         if(StartsWith(name, prefix))
         {
            if(SetHidden(name, hidden)) changed++;
         }
      }

      return changed;
   }

   int SetSelectablePrefix(string prefix, bool selectable)
   {
      int changed = 0;
      int total = ObjectsTotal(0, -1, -1);

      for(int i = 0; i < total; i++)
      {
         string name = ObjectName(0, i, -1, -1);
         if(StartsWith(name, prefix))
         {
            if(SetSelectable(name, selectable)) changed++;
         }
      }

      return changed;
   }

   int SetBackPrefix(string prefix, bool back)
   {
      int changed = 0;
      int total = ObjectsTotal(0, -1, -1);

      for(int i = 0; i < total; i++)
      {
         string name = ObjectName(0, i, -1, -1);
         if(StartsWith(name, prefix))
         {
            if(SetBack(name, back)) changed++;
         }
      }

      return changed;
   }

   int Type(string name)
   {
      if(!Exists(name)) return -1;
      return (int)ObjectGetInteger(0, name, OBJPROP_TYPE);
   }

   bool IsType(string name, int type){ return (Type(name) == type); }

   bool CreateHLine(string name, double price, color clr = clrDodgerBlue, int width = 1, int style = STYLE_SOLID)
   {
      Delete(name);
      if(!ObjectCreate(0, name, OBJ_HLINE, 0, 0, price)) return false;

      SetHidden(name, true);
      SetSelectable(name, false);
      SetSelected(name, false);
      SetColor(name, clr);
      SetWidth(name, width);
      SetStyle(name, style);
      return true;
   }

   bool CreateVLine(string name, datetime when, color clr = clrDodgerBlue, int width = 1, int style = STYLE_SOLID)
   {
      Delete(name);
      if(!ObjectCreate(0, name, OBJ_VLINE, 0, when, 0)) return false;

      SetColor(name, clr);
      SetWidth(name, width);
      SetStyle(name, style);
      return true;
   }

   bool CreateTrend(string name, datetime t1, double p1, datetime t2, double p2, color clr = clrDodgerBlue, int width = 1, int style = STYLE_SOLID, bool rayRight = false)
   {
      Delete(name);
      if(!ObjectCreate(0, name, OBJ_TREND, 0, t1, p1, t2, p2)) return false;

      SetColor(name, clr);
      SetWidth(name, width);
      SetStyle(name, style);
      ObjectSetInteger(0, name, OBJPROP_RAY_RIGHT, rayRight);
      return true;
   }

   bool CreateHSegment(string name, datetime t1, datetime t2, double price, color clr = clrDodgerBlue, int width = 1, int style = STYLE_SOLID)
   {
      if(t2 < t1)
      {
         datetime tmp = t1;
         t1 = t2;
         t2 = tmp;
      }

      return CreateTrend(name, t1, price, t2, price, clr, width, style, false);
   }

   bool CreateRectangle(string name, datetime t1, double p1, datetime t2, double p2, color clr = clrDodgerBlue, bool back = false)
   {
      Delete(name);
      if(!ObjectCreate(0, name, OBJ_RECTANGLE, 0, t1, p1, t2, p2)) return false;

      SetColor(name, clr);
      SetBack(name, back);
      return true;
   }

   bool CreateRectangle(string name, datetime t1, double p1, datetime t2, double p2, color clr, bool back, bool fill)
   {
      Delete(name);
      if(!ObjectCreate(0, name, OBJ_RECTANGLE, 0, t1, p1, t2, p2)) return false;

      SetColor(name, clr);
      SetBack(name, back);
      SetFill(name, fill);
      return true;
   }

   bool CreateText(string name, datetime when, double price, string text, color clr = clrDodgerBlue, int fontSize = 10)
   {
      Delete(name);
      if(!ObjectCreate(0, name, OBJ_TEXT, 0, when, price)) return false;

      SetColor(name, clr);
      ObjectSetString(0, name, OBJPROP_TEXT, text);
      ObjectSetInteger(0, name, OBJPROP_FONTSIZE, fontSize);
      return true;
   }

   bool CreateLabel(string name, int x, int y, string text, color clr = clrDodgerBlue, int corner = CORNER_LEFT_UPPER, int fontSize = 10)
   {
      Delete(name);
      if(!ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0)) return false;

      SetColor(name, clr);
      SetText(name, text);
      SetCorner(name, corner);
      SetX(name, x);
      SetY(name, y);
      SetFontSize(name, fontSize);
      return true;
   }

   bool CreateArrow(string name, datetime when, double price, int arrowCode = 159, color clr = clrDodgerBlue, int width = 1)
   {
      Delete(name);
      if(!ObjectCreate(0, name, OBJ_ARROW, 0, when, price)) return false;

      SetColor(name, clr);
      SetWidth(name, width);
      ObjectSetInteger(0, name, OBJPROP_ARROWCODE, arrowCode);
      return true;
   }

   bool MovePoint(string name, int pointIndex, datetime when, double price)
   {
      if(!Exists(name)) return false;
      return ObjectMove(0, name, pointIndex, when, price);
   }

   bool SetRectangle(string name, datetime t1, double p1, datetime t2, double p2)
   {
      if(!Exists(name)) return false;
      ObjectMove(0, name, 0, t1, p1);
      ObjectMove(0, name, 1, t2, p2);
      return true;
   }

   bool SetRectangle(string name, datetime t1, double p1, datetime t2, double p2, bool fill)
   {
      if(!SetRectangle(name, t1, p1, t2, p2)) return false;
      return SetFill(name, fill);
   }

   datetime Time1(string name){ if(!Exists(name)) return 0; return (datetime)ObjectGetInteger(0, name, OBJPROP_TIME1); }
   datetime Time2(string name){ if(!Exists(name)) return 0; return (datetime)ObjectGetInteger(0, name, OBJPROP_TIME2); }
   datetime GetTime1(string name){ return Time1(name); }
   datetime GetTime2(string name){ return Time2(name); }

   double Price1(string name){ if(!Exists(name)) return 0.0; return ObjectGetDouble(0, name, OBJPROP_PRICE1); }
   double Price2(string name){ if(!Exists(name)) return 0.0; return ObjectGetDouble(0, name, OBJPROP_PRICE2); }
   double GetPrice1(string name){ return Price1(name); }
   double GetPrice2(string name){ return Price2(name); }
   double GetPrice(string name){ return Price1(name); }

   bool SetPrice(string name, double price)
   {
      if(!Exists(name)) return false;
      return ObjectSetDouble(0, name, OBJPROP_PRICE1, price);
   }

   bool SetColor(string name, color clr){ if(!Exists(name)) return false; return ObjectSetInteger(0, name, OBJPROP_COLOR, clr); }
   color GetColor(string name){ if(!Exists(name)) return clrNONE; return (color)ObjectGetInteger(0, name, OBJPROP_COLOR); }

   bool SetWidth(string name, int width)
   {
      if(!Exists(name)) return false;
      if(width < 1) width = 1;
      if(width > 5) width = 5;
      return ObjectSetInteger(0, name, OBJPROP_WIDTH, width);
   }

   int GetWidth(string name){ if(!Exists(name)) return -1; return (int)ObjectGetInteger(0, name, OBJPROP_WIDTH); }

   bool SetStyle(string name, int style){ if(!Exists(name)) return false; return ObjectSetInteger(0, name, OBJPROP_STYLE, style); }
   int GetStyle(string name){ if(!Exists(name)) return -1; return (int)ObjectGetInteger(0, name, OBJPROP_STYLE); }

   bool SetBack(string name, bool back){ if(!Exists(name)) return false; return ObjectSetInteger(0, name, OBJPROP_BACK, back); }
   bool IsBack(string name){ if(!Exists(name)) return false; return (bool)ObjectGetInteger(0, name, OBJPROP_BACK); }
   bool GetBack(string name){ return IsBack(name); }

   bool SetFill(string name, bool fill){ if(!Exists(name)) return false; return ObjectSetInteger(0, name, OBJPROP_FILL, fill); }
   bool GetFill(string name){ if(!Exists(name)) return false; return (bool)ObjectGetInteger(0, name, OBJPROP_FILL); }

   bool SetHidden(string name, bool hidden){ if(!Exists(name)) return false; return ObjectSetInteger(0, name, OBJPROP_HIDDEN, hidden); }
   bool IsHidden(string name){ if(!Exists(name)) return false; return (bool)ObjectGetInteger(0, name, OBJPROP_HIDDEN); }
   bool GetHidden(string name){ return IsHidden(name); }

   bool SetSelectable(string name, bool selectable){ if(!Exists(name)) return false; return ObjectSetInteger(0, name, OBJPROP_SELECTABLE, selectable); }
   bool IsSelectable(string name){ if(!Exists(name)) return false; return (bool)ObjectGetInteger(0, name, OBJPROP_SELECTABLE); }
   bool GetSelectable(string name){ return IsSelectable(name); }

   bool SetSelected(string name, bool selected){ if(!Exists(name)) return false; return ObjectSetInteger(0, name, OBJPROP_SELECTED, selected); }
   bool IsSelected(string name){ if(!Exists(name)) return false; return (bool)ObjectGetInteger(0, name, OBJPROP_SELECTED); }

   bool SetZOrder(string name, long zorder){ if(!Exists(name)) return false; return ObjectSetInteger(0, name, OBJPROP_ZORDER, zorder); }
   long GetZOrder(string name){ if(!Exists(name)) return -1; return ObjectGetInteger(0, name, OBJPROP_ZORDER); }

   bool SetText(string name, string text){ if(!Exists(name)) return false; return ObjectSetString(0, name, OBJPROP_TEXT, text); }
   string GetText(string name){ if(!Exists(name)) return ""; return ObjectGetString(0, name, OBJPROP_TEXT); }

   bool SetTooltip(string name, string text){ if(!Exists(name)) return false; return ObjectSetString(0, name, OBJPROP_TOOLTIP, text); }
   string GetTooltip(string name){ if(!Exists(name)) return ""; return ObjectGetString(0, name, OBJPROP_TOOLTIP); }

   bool SetX(string name, int x){ if(!Exists(name)) return false; return ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x); }
   int GetX(string name){ if(!Exists(name)) return -1; return (int)ObjectGetInteger(0, name, OBJPROP_XDISTANCE); }

   bool SetY(string name, int y){ if(!Exists(name)) return false; return ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y); }
   int GetY(string name){ if(!Exists(name)) return -1; return (int)ObjectGetInteger(0, name, OBJPROP_YDISTANCE); }

   bool SetCorner(string name, int corner){ if(!Exists(name)) return false; return ObjectSetInteger(0, name, OBJPROP_CORNER, corner); }
   int GetCorner(string name){ if(!Exists(name)) return -1; return (int)ObjectGetInteger(0, name, OBJPROP_CORNER); }

   bool SetFontSize(string name, int size)
   {
      if(!Exists(name)) return false;
      if(size < 1) size = 1;
      return ObjectSetInteger(0, name, OBJPROP_FONTSIZE, size);
   }

   int GetFontSize(string name){ if(!Exists(name)) return -1; return (int)ObjectGetInteger(0, name, OBJPROP_FONTSIZE); }

   bool SetFont(string name, string font){ if(!Exists(name)) return false; return ObjectSetString(0, name, OBJPROP_FONT, font); }
   string GetFont(string name){ if(!Exists(name)) return ""; return ObjectGetString(0, name, OBJPROP_FONT); }

   bool SetRayRight(string name, bool rayRight)
   {
      if(!Exists(name)) return false;
      return ObjectSetInteger(0, name, OBJPROP_RAY_RIGHT, rayRight);
   }

   bool GetRayRight(string name)
   {
      if(!Exists(name)) return false;
      return (bool)ObjectGetInteger(0, name, OBJPROP_RAY_RIGHT);
   }
};

#endif