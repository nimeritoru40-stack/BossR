//+------------------------------------------------------------------+
//| BossR_Buffer.mqh                                                 |
//+------------------------------------------------------------------+
#ifndef __BOSSR_BUFFER_MQH__
#define __BOSSR_BUFFER_MQH__

#property strict

class C_BossR_Buffer
{
private:
   double m_data[];

public:
   C_BossR_Buffer()
   {
      Clear();
   }

   void Clear()
   {
      ArrayResize(m_data, 0);
   }

   int Size() const
   {
      return ArraySize(m_data);
   }

   bool IsEmpty() const
   {
      return ArraySize(m_data) <= 0;
   }

   bool Resize(const int size)
   {
      if(size < 0)
         return false;

      return ArrayResize(m_data, size) == size;
   }

   bool Push(const double value)
   {
      int n = ArraySize(m_data);

      if(ArrayResize(m_data, n + 1) != n + 1)
         return false;

      m_data[n] = value;
      return true;
   }

   bool Pop(double &value)
   {
      int n = ArraySize(m_data);

      if(n <= 0)
         return false;

      value = m_data[n - 1];
      return ArrayResize(m_data, n - 1) == n - 1;
   }

   bool RemoveAt(const int index)
   {
      int n = ArraySize(m_data);

      if(index < 0 || index >= n)
         return false;

      for(int i = index; i < n - 1; i++)
         m_data[i] = m_data[i + 1];

      return ArrayResize(m_data, n - 1) == n - 1;
   }

   bool InsertAt(const int index, const double value)
   {
      int n = ArraySize(m_data);

      if(index < 0 || index > n)
         return false;

      if(ArrayResize(m_data, n + 1) != n + 1)
         return false;

      for(int i = n; i > index; i--)
         m_data[i] = m_data[i - 1];

      m_data[index] = value;
      return true;
   }

   bool Set(const int index, const double value)
   {
      if(index < 0 || index >= ArraySize(m_data))
         return false;

      m_data[index] = value;
      return true;
   }

   bool Get(const int index, double &value) const
   {
      if(index < 0 || index >= ArraySize(m_data))
         return false;

      value = m_data[index];
      return true;
   }

   double At(const int index, const double fallback = 0.0) const
   {
      if(index < 0 || index >= ArraySize(m_data))
         return fallback;

      return m_data[index];
   }

   bool Front(double &value) const
   {
      if(ArraySize(m_data) <= 0)
         return false;

      value = m_data[0];
      return true;
   }

   bool Back(double &value) const
   {
      int n = ArraySize(m_data);

      if(n <= 0)
         return false;

      value = m_data[n - 1];
      return true;
   }
      bool Swap(const int index1, const int index2)
   {
      int n = ArraySize(m_data);

      if(index1 < 0 || index1 >= n)
         return false;

      if(index2 < 0 || index2 >= n)
         return false;

      if(index1 == index2)
         return true;

      double tmp = m_data[index1];
      m_data[index1] = m_data[index2];
      m_data[index2] = tmp;

      return true;
   }

   void Reverse()
   {
      int left = 0;
      int right = ArraySize(m_data) - 1;

      while(left < right)
      {
         double tmp = m_data[left];
         m_data[left] = m_data[right];
         m_data[right] = tmp;

         left++;
         right--;
      }
   }

   void Fill(const double value)
   {
      for(int i = 0; i < ArraySize(m_data); i++)
         m_data[i] = value;
   }

   bool FindMin(double &value) const
   {
      int n = ArraySize(m_data);

      if(n <= 0)
         return false;

      value = m_data[0];

      for(int i = 1; i < n; i++)
         if(m_data[i] < value)
            value = m_data[i];

      return true;
   }

   bool FindMax(double &value) const
   {
      int n = ArraySize(m_data);

      if(n <= 0)
         return false;

      value = m_data[0];

      for(int i = 1; i < n; i++)
         if(m_data[i] > value)
            value = m_data[i];

      return true;
   }   bool Sum(double &value) const
   {
      int n = ArraySize(m_data);

      if(n <= 0)
         return false;

      value = 0.0;

      for(int i = 0; i < n; i++)
         value += m_data[i];

      return true;
   }

   bool Average(double &value) const
   {
      int n = ArraySize(m_data);

      if(n <= 0)
         return false;

      double sum = 0.0;

      for(int i = 0; i < n; i++)
         sum += m_data[i];

      value = sum / n;
      return true;
   }

   bool Range(double &value) const
   {
      double min_value;
      double max_value;

      if(!FindMin(min_value))
         return false;

      if(!FindMax(max_value))
         return false;

      value = max_value - min_value;
      return true;
   }

   int IndexOfMin() const
   {
      int n = ArraySize(m_data);

      if(n <= 0)
         return -1;

      int index = 0;
      double value = m_data[0];

      for(int i = 1; i < n; i++)
      {
         if(m_data[i] < value)
         {
            value = m_data[i];
            index = i;
         }
      }

      return index;
   }

   int IndexOfMax() const
   {
      int n = ArraySize(m_data);

      if(n <= 0)
         return -1;

      int index = 0;
      double value = m_data[0];

      for(int i = 1; i < n; i++)
      {
         if(m_data[i] > value)
         {
            value = m_data[i];
            index = i;
         }
      }

      return index;
   }   bool SortAscending()
   {
      int n = ArraySize(m_data);

      if(n <= 1)
         return true;

      for(int i = 0; i < n - 1; i++)
      {
         for(int j = i + 1; j < n; j++)
         {
            if(m_data[j] < m_data[i])
            {
               double tmp = m_data[i];
               m_data[i] = m_data[j];
               m_data[j] = tmp;
            }
         }
      }

      return true;
   }

   bool SortDescending()
   {
      int n = ArraySize(m_data);

      if(n <= 1)
         return true;

      for(int i = 0; i < n - 1; i++)
      {
         for(int j = i + 1; j < n; j++)
         {
            if(m_data[j] > m_data[i])
            {
               double tmp = m_data[i];
               m_data[i] = m_data[j];
               m_data[j] = tmp;
            }
         }
      }

      return true;
   }

   bool CopyTo(double &target[]) const
   {
      int n = ArraySize(m_data);

      if(ArrayResize(target, n) != n)
         return false;

      for(int i = 0; i < n; i++)
         target[i] = m_data[i];

      return true;
   }

   bool Median(double &value) const
   {
      int n = ArraySize(m_data);

      if(n <= 0)
         return false;

      double tmp[];

      if(ArrayResize(tmp, n) != n)
         return false;

      for(int i = 0; i < n; i++)
         tmp[i] = m_data[i];

      for(int a = 0; a < n - 1; a++)
      {
         for(int b = a + 1; b < n; b++)
         {
            if(tmp[b] < tmp[a])
            {
               double swap_value = tmp[a];
               tmp[a] = tmp[b];
               tmp[b] = swap_value;
            }
         }
      }

      if((n % 2) == 1)
      {
         value = tmp[n / 2];
         return true;
      }

      value = (tmp[(n / 2) - 1] + tmp[n / 2]) / 2.0;
      return true;
   }   bool TrimFront(const int count)
   {
      int n = ArraySize(m_data);

      if(count < 0)
         return false;

      if(count == 0)
         return true;

      if(count >= n)
      {
         Clear();
         return true;
      }

      for(int i = 0; i < n - count; i++)
         m_data[i] = m_data[i + count];

      return ArrayResize(m_data, n - count) == n - count;
   }

   bool TrimBack(const int count)
   {
      int n = ArraySize(m_data);

      if(count < 0)
         return false;

      if(count == 0)
         return true;

      if(count >= n)
      {
         Clear();
         return true;
      }

      return ArrayResize(m_data, n - count) == n - count;
   }

   bool KeepNewest(const int count)
   {
      int n = ArraySize(m_data);

      if(count < 0)
         return false;

      if(count >= n)
         return true;

      return TrimFront(n - count);
   }

   bool LimitSize(const int max_size)
   {
      if(max_size < 0)
         return false;

      return KeepNewest(max_size);
   }   int IndexOf(const double value, const double epsilon = 0.00000001) const
   {
      for(int i = 0; i < ArraySize(m_data); i++)
      {
         if(MathAbs(m_data[i] - value) <= epsilon)
            return i;
      }

      return -1;
   }

   int LastIndexOf(const double value, const double epsilon = 0.00000001) const
   {
      for(int i = ArraySize(m_data) - 1; i >= 0; i--)
      {
         if(MathAbs(m_data[i] - value) <= epsilon)
            return i;
      }

      return -1;
   }

   bool Contains(const double value, const double epsilon = 0.00000001) const
   {
      return IndexOf(value, epsilon) >= 0;
   }

   int CountValue(const double value, const double epsilon = 0.00000001) const
   {
      int count = 0;

      for(int i = 0; i < ArraySize(m_data); i++)
      {
         if(MathAbs(m_data[i] - value) <= epsilon)
            count++;
      }

      return count;
   }

   bool Equals(C_BossR_Buffer &other, const double epsilon = 0.00000001) const
   {
      int n = ArraySize(m_data);

      if(other.Size() != n)
         return false;

      for(int i = 0; i < n; i++)
      {
         if(MathAbs(m_data[i] - other.At(i)) > epsilon)
            return false;
      }

      return true;
   }   bool IsValidIndex(const int index) const
   {
      return (index >= 0 && index < ArraySize(m_data));
   }

   bool ReplaceFirst(const double old_value, const double new_value, const double epsilon = 0.00000001)
   {
      int index = IndexOf(old_value, epsilon);

      if(index < 0)
         return false;

      m_data[index] = new_value;
      return true;
   }

   int ReplaceAll(const double old_value, const double new_value, const double epsilon = 0.00000001)
   {
      int count = 0;

      for(int i = 0; i < ArraySize(m_data); i++)
      {
         if(MathAbs(m_data[i] - old_value) <= epsilon)
         {
            m_data[i] = new_value;
            count++;
         }
      }

      return count;
   }

   bool RemoveFirstValue(const double value, const double epsilon = 0.00000001)
   {
      int index = IndexOf(value, epsilon);

      if(index < 0)
         return false;

      return RemoveAt(index);
   }

   int RemoveAllValue(const double value, const double epsilon = 0.00000001)
   {
      int removed = 0;

      for(int i = ArraySize(m_data) - 1; i >= 0; i--)
      {
         if(MathAbs(m_data[i] - value) <= epsilon)
         {
            if(RemoveAt(i))
               removed++;
         }
      }

      return removed;
   }
};

#endif