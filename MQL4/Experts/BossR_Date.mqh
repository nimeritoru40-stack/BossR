//+------------------------------------------------------------------+
//| BossR_Date.mqh                                                   |
//| BossR Framework                                                  |
//+------------------------------------------------------------------+
#ifndef __BOSSR_DATE_MQH__
#define __BOSSR_DATE_MQH__

#property strict

class C_BossR_Date
{
private:
   string Pad2(const int value) const
   {
      if(value < 10) return "0" + IntegerToString(value);
      return IntegerToString(value);
   }

   string Pad4(const int value) const
   {
      if(value < 10) return "000" + IntegerToString(value);
      if(value < 100) return "00" + IntegerToString(value);
      if(value < 1000) return "0" + IntegerToString(value);
      return IntegerToString(value);
   }

public:
   C_BossR_Date() {}
   ~C_BossR_Date() {}

   int Year(const datetime value) const
   {
      return TimeYear(value);
   }

   int Month(const datetime value) const
   {
      return TimeMonth(value);
   }

   int Day(const datetime value) const
   {
      return TimeDay(value);
   }

   int Hour(const datetime value) const
   {
      return TimeHour(value);
   }

   int Minute(const datetime value) const
   {
      return TimeMinute(value);
   }

   int Second(const datetime value) const
   {
      return TimeSeconds(value);
   }

   int DayOfWeek(const datetime value) const
   {
      return TimeDayOfWeek(value);
   }

   int DayOfYear(const datetime value) const
   {
      return TimeDayOfYear(value);
   }

   bool IsLeapYear(const int year) const
   {
      if(year <= 0) return false;
      if((year % 400) == 0) return true;
      if((year % 100) == 0) return false;
      return ((year % 4) == 0);
   }

   int DaysInMonth(const int year, const int month) const
   {
      if(month < 1 || month > 12) return 0;

      if(month == 1) return 31;
      if(month == 2) return (IsLeapYear(year) ? 29 : 28);
      if(month == 3) return 31;
      if(month == 4) return 30;
      if(month == 5) return 31;
      if(month == 6) return 30;
      if(month == 7) return 31;
      if(month == 8) return 31;
      if(month == 9) return 30;
      if(month == 10) return 31;
      if(month == 11) return 30;
      if(month == 12) return 31;

      return 0;
   }

   bool IsValidDate(const int year, const int month, const int day) const
   {
      if(year < 1970) return false;
      if(month < 1 || month > 12) return false;
      if(day < 1) return false;
      return (day <= DaysInMonth(year, month));
   }

   bool IsValidTime(const int hour, const int minute, const int second) const
   {
      if(hour < 0 || hour > 23) return false;
      if(minute < 0 || minute > 59) return false;
      if(second < 0 || second > 59) return false;
      return true;
   }

   datetime MakeDate(const int year, const int month, const int day) const
   {
      if(!IsValidDate(year, month, day)) return 0;
      string text = Pad4(year) + "." + Pad2(month) + "." + Pad2(day) + " 00:00:00";
      return StrToTime(text);
   }

   datetime MakeDateTime(const int year, const int month, const int day,
                         const int hour, const int minute, const int second) const
   {
      if(!IsValidDate(year, month, day)) return 0;
      if(!IsValidTime(hour, minute, second)) return 0;

      string text = Pad4(year) + "." + Pad2(month) + "." + Pad2(day) + " " +
                    Pad2(hour) + ":" + Pad2(minute) + ":" + Pad2(second);
      return StrToTime(text);
   }

   datetime DateOnly(const datetime value) const
   {
      return MakeDate(TimeYear(value), TimeMonth(value), TimeDay(value));
   }

   int TimeOnlySeconds(const datetime value) const
   {
      return (TimeHour(value) * 3600 + TimeMinute(value) * 60 + TimeSeconds(value));
   }

   datetime StartOfDay(const datetime value) const
   {
      return DateOnly(value);
   }

   datetime EndOfDay(const datetime value) const
   {
      return DateOnly(value) + 86399;
   }

   datetime AddSeconds(const datetime value, const int seconds) const
   {
      return value + seconds;
   }

   datetime AddMinutes(const datetime value, const int minutes) const
   {
      return value + minutes * 60;
   }

   datetime AddHours(const datetime value, const int hours) const
   {
      return value + hours * 3600;
   }

   datetime AddDays(const datetime value, const int days) const
   {
      return value + days * 86400;
   }

   datetime AddWeeks(const datetime value, const int weeks) const
   {
      return value + weeks * 604800;
   }

   bool IsWeekend(const datetime value) const
   {
      int dow = TimeDayOfWeek(value);
      return (dow == 0 || dow == 6);
   }

   bool IsWeekday(const datetime value) const
   {
      return !IsWeekend(value);
   }

   bool IsSameDay(const datetime left, const datetime right) const
   {
      return (TimeYear(left) == TimeYear(right) &&
              TimeMonth(left) == TimeMonth(right) &&
              TimeDay(left) == TimeDay(right));
   }

   bool IsSameMonth(const datetime left, const datetime right) const
   {
      return (TimeYear(left) == TimeYear(right) && TimeMonth(left) == TimeMonth(right));
   }

   bool IsSameYear(const datetime left, const datetime right) const
   {
      return (TimeYear(left) == TimeYear(right));
   }

   bool IsBefore(const datetime left, const datetime right) const
   {
      return (left < right);
   }

   bool IsAfter(const datetime left, const datetime right) const
   {
      return (left > right);
   }

   string DayOfWeekName(const datetime value) const
   {
      int dow = TimeDayOfWeek(value);
      if(dow == 0) return "Sunday";
      if(dow == 1) return "Monday";
      if(dow == 2) return "Tuesday";
      if(dow == 3) return "Wednesday";
      if(dow == 4) return "Thursday";
      if(dow == 5) return "Friday";
      if(dow == 6) return "Saturday";
      return "";
   }

   string MonthName(const int month) const
   {
      if(month == 1) return "January";
      if(month == 2) return "February";
      if(month == 3) return "March";
      if(month == 4) return "April";
      if(month == 5) return "May";
      if(month == 6) return "June";
      if(month == 7) return "July";
      if(month == 8) return "August";
      if(month == 9) return "September";
      if(month == 10) return "October";
      if(month == 11) return "November";
      if(month == 12) return "December";
      return "";
   }


   int Quarter(const datetime value) const
   {
      int month = TimeMonth(value);
      if(month >= 1 && month <= 3) return 1;
      if(month >= 4 && month <= 6) return 2;
      if(month >= 7 && month <= 9) return 3;
      if(month >= 10 && month <= 12) return 4;
      return 0;
   }

   int QuarterStartMonth(const int quarter) const
   {
      if(quarter < 1 || quarter > 4) return 0;
      return ((quarter - 1) * 3) + 1;
   }

   int QuarterEndMonth(const int quarter) const
   {
      if(quarter < 1 || quarter > 4) return 0;
      return quarter * 3;
   }

   datetime StartOfMonth(const datetime value) const
   {
      return MakeDate(TimeYear(value), TimeMonth(value), 1);
   }

   datetime EndOfMonth(const datetime value) const
   {
      int year = TimeYear(value);
      int month = TimeMonth(value);
      return MakeDate(year, month, DaysInMonth(year, month)) + 86399;
   }

   datetime StartOfYear(const datetime value) const
   {
      return MakeDate(TimeYear(value), 1, 1);
   }

   datetime EndOfYear(const datetime value) const
   {
      return MakeDate(TimeYear(value), 12, 31) + 86399;
   }

   datetime StartOfQuarter(const datetime value) const
   {
      int quarter = Quarter(value);
      return MakeDate(TimeYear(value), QuarterStartMonth(quarter), 1);
   }

   datetime EndOfQuarter(const datetime value) const
   {
      int year = TimeYear(value);
      int quarter = Quarter(value);
      int month = QuarterEndMonth(quarter);
      return MakeDate(year, month, DaysInMonth(year, month)) + 86399;
   }

   bool IsFirstDayOfMonth(const datetime value) const
   {
      return (TimeDay(value) == 1);
   }

   bool IsLastDayOfMonth(const datetime value) const
   {
      return (TimeDay(value) == DaysInMonth(TimeYear(value), TimeMonth(value)));
   }

   bool IsFirstDayOfYear(const datetime value) const
   {
      return (TimeMonth(value) == 1 && TimeDay(value) == 1);
   }

   bool IsLastDayOfYear(const datetime value) const
   {
      return (TimeMonth(value) == 12 && TimeDay(value) == 31);
   }

   bool IsSameQuarter(const datetime left, const datetime right) const
   {
      return (TimeYear(left) == TimeYear(right) && Quarter(left) == Quarter(right));
   }

   string MonthShortName(const int month) const
   {
      if(month == 1) return "Jan";
      if(month == 2) return "Feb";
      if(month == 3) return "Mar";
      if(month == 4) return "Apr";
      if(month == 5) return "May";
      if(month == 6) return "Jun";
      if(month == 7) return "Jul";
      if(month == 8) return "Aug";
      if(month == 9) return "Sep";
      if(month == 10) return "Oct";
      if(month == 11) return "Nov";
      if(month == 12) return "Dec";
      return "";
   }

   string FormatDate(const datetime value) const
   {
      return TimeToString(value, TIME_DATE);
   }

   string FormatTime(const datetime value) const
   {
      return TimeToString(value, TIME_SECONDS);
   }

   string FormatDateTime(const datetime value) const
   {
      return TimeToString(value, TIME_DATE | TIME_SECONDS);
   }

   int DayOfWeekISO(const datetime value) const
   {
      int dow = TimeDayOfWeek(value);
      if(dow == 0) return 7;
      return dow;
   }

   bool IsMonday(const datetime value) const
   {
      return (TimeDayOfWeek(value) == 1);
   }

   bool IsTuesday(const datetime value) const
   {
      return (TimeDayOfWeek(value) == 2);
   }

   bool IsWednesday(const datetime value) const
   {
      return (TimeDayOfWeek(value) == 3);
   }

   bool IsThursday(const datetime value) const
   {
      return (TimeDayOfWeek(value) == 4);
   }

   bool IsFriday(const datetime value) const
   {
      return (TimeDayOfWeek(value) == 5);
   }

   bool IsSaturday(const datetime value) const
   {
      return (TimeDayOfWeek(value) == 6);
   }

   bool IsSunday(const datetime value) const
   {
      return (TimeDayOfWeek(value) == 0);
   }

   datetime StartOfWeek(const datetime value, const int week_start_day = 1) const
   {
      int start_day = week_start_day;
      if(start_day < 0 || start_day > 6) start_day = 1;

      int dow = TimeDayOfWeek(value);
      int delta = dow - start_day;
      if(delta < 0) delta += 7;

      return DateOnly(value) - delta * 86400;
   }

   datetime EndOfWeek(const datetime value, const int week_start_day = 1) const
   {
      return StartOfWeek(value, week_start_day) + 604800 - 1;
   }

   bool IsFirstDayOfWeek(const datetime value, const int week_start_day = 1) const
   {
      int start_day = week_start_day;
      if(start_day < 0 || start_day > 6) start_day = 1;
      return (TimeDayOfWeek(value) == start_day);
   }

   bool IsLastDayOfWeek(const datetime value, const int week_start_day = 1) const
   {
      int start_day = week_start_day;
      if(start_day < 0 || start_day > 6) start_day = 1;
      int last_day = start_day - 1;
      if(last_day < 0) last_day = 6;
      return (TimeDayOfWeek(value) == last_day);
   }

   datetime NextDayStart(const datetime value) const
   {
      return DateOnly(value) + 86400;
   }

   datetime PreviousDayStart(const datetime value) const
   {
      return DateOnly(value) - 86400;
   }

   datetime NextWeekStart(const datetime value, const int week_start_day = 1) const
   {
      return StartOfWeek(value, week_start_day) + 604800;
   }

   datetime PreviousWeekStart(const datetime value, const int week_start_day = 1) const
   {
      return StartOfWeek(value, week_start_day) - 604800;
   }

   int SecondsBetween(const datetime left, const datetime right) const
   {
      return (int)(right - left);
   }

   int MinutesBetween(const datetime left, const datetime right) const
   {
      return (int)((right - left) / 60);
   }

   int HoursBetween(const datetime left, const datetime right) const
   {
      return (int)((right - left) / 3600);
   }

   int DaysBetween(const datetime left, const datetime right) const
   {
      return (int)((DateOnly(right) - DateOnly(left)) / 86400);
   }

   bool IsBetween(const datetime value, const datetime start_time, const datetime end_time, const bool inclusive = true) const
   {
      if(start_time > end_time) return false;

      if(inclusive)
         return (value >= start_time && value <= end_time);

      return (value > start_time && value < end_time);
   }

   datetime MinDateTime(const datetime left, const datetime right) const
   {
      if(left <= right) return left;
      return right;
   }

   datetime MaxDateTime(const datetime left, const datetime right) const
   {
      if(left >= right) return left;
      return right;
   }


   int MakeTimeSeconds(const int hour, const int minute, const int second = 0) const
   {
      if(!IsValidTime(hour, minute, second)) return -1;
      return hour * 3600 + minute * 60 + second;
   }

   int MinutesSinceMidnight(const datetime value) const
   {
      return TimeHour(value) * 60 + TimeMinute(value);
   }

   int SecondsSinceMidnight(const datetime value) const
   {
      return TimeOnlySeconds(value);
   }

   datetime WithTime(const datetime value, const int hour, const int minute, const int second = 0) const
   {
      if(!IsValidTime(hour, minute, second)) return 0;
      return DateOnly(value) + MakeTimeSeconds(hour, minute, second);
   }

   datetime HourStart(const datetime value) const
   {
      return DateOnly(value) + TimeHour(value) * 3600;
   }

   datetime MinuteStart(const datetime value) const
   {
      return DateOnly(value) + TimeHour(value) * 3600 + TimeMinute(value) * 60;
   }

   datetime NextHourStart(const datetime value) const
   {
      return HourStart(value) + 3600;
   }

   datetime PreviousHourStart(const datetime value) const
   {
      return HourStart(value) - 3600;
   }

   datetime NextMinuteStart(const datetime value) const
   {
      return MinuteStart(value) + 60;
   }

   datetime PreviousMinuteStart(const datetime value) const
   {
      return MinuteStart(value) - 60;
   }

   datetime SessionStart(const datetime value, const int hour, const int minute, const int second = 0) const
   {
      return WithTime(value, hour, minute, second);
   }

   datetime SessionEnd(const datetime value, const int hour, const int minute, const int second = 0) const
   {
      return WithTime(value, hour, minute, second);
   }

   bool IsTimeBetweenSeconds(const int value_seconds, const int start_seconds, const int end_seconds, const bool inclusive = true) const
   {
      if(value_seconds < 0 || value_seconds > 86399) return false;
      if(start_seconds < 0 || start_seconds > 86399) return false;
      if(end_seconds < 0 || end_seconds > 86399) return false;

      if(start_seconds == end_seconds) return true;

      if(start_seconds < end_seconds)
      {
         if(inclusive)
            return (value_seconds >= start_seconds && value_seconds <= end_seconds);
         return (value_seconds > start_seconds && value_seconds < end_seconds);
      }

      if(inclusive)
         return (value_seconds >= start_seconds || value_seconds <= end_seconds);
      return (value_seconds > start_seconds || value_seconds < end_seconds);
   }

   bool IsTimeBetween(const datetime value,
                      const int start_hour, const int start_minute,
                      const int end_hour, const int end_minute,
                      const bool inclusive = true) const
   {
      int start_seconds = MakeTimeSeconds(start_hour, start_minute, 0);
      int end_seconds   = MakeTimeSeconds(end_hour, end_minute, 0);
      if(start_seconds < 0 || end_seconds < 0) return false;

      return IsTimeBetweenSeconds(TimeOnlySeconds(value), start_seconds, end_seconds, inclusive);
   }

   bool IsInSession(const datetime value,
                    const int start_hour, const int start_minute,
                    const int end_hour, const int end_minute,
                    const bool inclusive = true) const
   {
      return IsTimeBetween(value, start_hour, start_minute, end_hour, end_minute, inclusive);
   }
   int WeeksInISOYear(const int year) const
   {
      if(year < 1970) return 0;

      datetime jan1 = MakeDate(year, 1, 1);
      int jan1_iso_dow = DayOfWeekISO(jan1);

      if(jan1_iso_dow == 4) return 53;
      if(IsLeapYear(year) && jan1_iso_dow == 3) return 53;

      return 52;
   }

   int WeekOfYear(const datetime value, const int week_start_day = 1) const
   {
      int start_day = week_start_day;
      if(start_day < 0 || start_day > 6) start_day = 1;

      datetime year_start = MakeDate(TimeYear(value), 1, 1);
      datetime first_week_start = StartOfWeek(year_start, start_day);

      return (int)((DateOnly(value) - first_week_start) / 604800) + 1;
   }

   int ISOWeekOfYear(const datetime value) const
   {
      int year = TimeYear(value);
      int doy = DayOfYear(value);
      int dow = DayOfWeekISO(value);

      int week = (doy - dow + 10) / 7;

      if(week < 1)
         return WeeksInISOYear(year - 1);

      int weeks_this_year = WeeksInISOYear(year);
      if(week > weeks_this_year)
         return 1;

      return week;
   }
};

#endif
