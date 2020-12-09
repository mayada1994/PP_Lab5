with Ada.Text_IO, Calculate_Sum, ada.Unchecked_Deallocation;

use Ada.Text_IO;

function Calculate_Sum (NumArray : in out CustomArray) return Long_Integer is

   function SumPair (First, Last : in Integer) return Long_Integer;

   function Min (First, Last : in Integer) return Integer;

   protected Server is
      procedure TaskIsFinished;
      procedure ResetWave(Size : in Integer);
      entry Wait;

   private
      ActualSize : Integer;
      TaskCounter : Integer := 0 ;
   end;

   protected body Server is
      procedure TaskIsFinished is
      begin
         TaskCounter:= TaskCounter + 1;
      end;

      procedure ResetWave(Size : in Integer) is
      begin
         TaskCounter := 0;
         ActualSize := Size;
      end;

      entry Wait when TaskCounter = ActualSize is
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
      MinIndex: Integer;
   begin
      accept Start (First, Last : Integer) do
         SumCalculator.First := First;
         SumCalculator.Last  := Last;
      end Start;

      Sum := SumPair (First, Last);

      Put("Pair: ");Put(First'Image);Put(" -");Put(Last'Image);Put(", Pair sum: ");Put_Line(Sum'Image);

      MinIndex := Min(First, Last);

      NumArray(MinIndex) := Sum;

      Server.TaskIsFinished;
   end SumCalculator;

   type AccessToSumCalculator is access SumCalculator;

   function Min(First, Last : in Integer) return Integer is
   begin
      if First<Last then
         return First;
      else
         return Last;
      end if;
   end Min;

   function SumPair (First, Last : in Integer) return Long_Integer is
   begin
      return NumArray(First) + NumArray(Last);
   end SumPair;

   CurrentSize: Integer := NumArray'Length;
   LastElement: Integer := CurrentSize - 1;
   SumCalcTasks : array (0 .. CurrentSize/2) of AccessToSumCalculator;

begin
   while CurrentSize > 1 loop
      Server.ResetWave(CurrentSize/2);
      for i in 0 .. (CurrentSize/2 - 1) loop
         SumCalcTasks(i) := new SumCalculator;
         SumCalcTasks(i).Start(i, LastElement);
         LastElement := LastElement - 1;
      end loop;

      Server.Wait;
      CurrentSize := (CurrentSize/2) + (CurrentSize mod 2);
   end loop;

   Put("Total sum: ");
   return NumArray(NumArray'First);
end Calculate_Sum;
