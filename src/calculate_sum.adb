with Ada.Text_IO, Calculate_Sum;

use Ada.Text_IO;

function Calculate_Sum
  (NumArray : in CustomArray;
   Tasks  : in Integer) return Long_Integer is

   function PartialSum (First, Last : in Integer) return Long_Integer;

   protected Server is
      procedure SetSum(Current : in Long_Integer);
      function GetSum return Long_Integer;
      entry Wait;

   private
      Sum : Long_Integer := 0;
      TaskCounter : Integer := 0;
   end;

   protected body Server is
      procedure SetSum(Current : in Long_Integer) is
      begin
         Sum := Sum + Current;
         TaskCounter := TaskCounter + 1;
      end SetSum;

      function GetSum return Long_Integer is
      begin
         return Sum;
      end GetSum;

      entry Wait when TaskCounter = Tasks is
      begin
         null;
      end Wait;
   end Server;

   task type SumCalculator is
      entry Start (First, Last : in Integer);
   end;

   task body SumCalculator is
      First, Last : Integer;
      Sum : Long_Integer;
   begin
      accept Start (First, Last : Integer) do
         SumCalculator.First := First;
         SumCalculator.Last  := Last;
      end Start;

      Sum := PartialSum (First, Last);

      Server.SetSum(Sum);

      Put("Range: ");Put(First'Image);Put("..");Put(Last'Image);Put(", Partial sum: ");Put_Line(Sum'Image);
   end SumCalculator;

   function PartialSum (First, Last : in Integer) return Long_Integer is
      Sum : Long_Integer := 0;
   begin
      for i in First .. Last loop
         Sum := Sum + NumArray (i);
      end loop;

      return Sum;
   end PartialSum;

   Sub_Length : constant Integer := NumArray'Length / Tasks;
   SumCalcTasks : array (0 .. Tasks - 1) of SumCalculator;


   Index  : Integer := NumArray'First;
   Next   : Integer;
   Sum    : Long_Integer := 0;

begin

   for i in SumCalcTasks'Range loop
      Next := Index + Sub_Length;
      SumCalcTasks (i).Start (First => Index, Last => Next - 1);
      Index := Next;
   end loop;

   Server.Wait;
   Sum := Sum + Server.GetSum;
   Put("Total sum: ");
   return Sum;
end Calculate_Sum;
