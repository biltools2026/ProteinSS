#!usr/bin/perl
#
@aa=("A","C","D","E","F","G","H","I","K","L","M","N","P","Q","R","S","T","V","W","Y");

for($i=0;$i<20;$i++)
{
  $first=$aa[$i];
  for($j=0;$j<20;$j++)
  {
   $second=$aa[$j];
   $gram=$first.$second;
   @num=0;
  $number=0;
  $sum_number=0;
  open (FILE,"sequence.txt")or die("cannot open file:sequence.txt");
   $/ = undef;
   $tt = <FILE>;
   @seq = split(/>MGG/,$tt);
   $long=@seq;
 #  print "$seq[1]";
     for($x=0;$x<$long;$x++)
     {
      @num = $seq[$x]=~/$gram/g;
      $number=@num;
      }
      $sum_number+=$number;
    

  print  "$gram:$sum_number\n"; 
}
}
close (FILE);   


  
 #   $/ = undef;
  #  $tt = <FILE>;
