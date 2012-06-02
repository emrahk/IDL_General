#!/usr/bin/ksh -f


time /home/katja/zuramo/execute/zuramo1.`uname` << xxx
$1z.txt 
$1z.par1
$1z.out1
2000
2,1
1
$3
2000
0
200
xxx

rm -f $1z.out1
rm -f $1z.out1KS

tau=`grep tau $1z.par1 | sed s/"P&tau"//`
dyn=`grep Dyn $1z.par1 | sed s/Dyn//`
wwn=`grep WfWNR $1z.par1 | sed s/WfWNR//`
vdr=`grep VdBeoR $1z.par1 | sed s/VdBeoR//`
sup=`grep supremum $1z.par1 | sed s/supremum//`
ite=`grep "Iterationen im EM-Algorithmus" $1z.par1 | sed s/"Iterationen im EM-Algorithmus"//` 

echo $dyn $tau $wwn $vdr $sup $ite >> $1_$2.par1

rm -f $1z.par1
rm -f $1z.txt










