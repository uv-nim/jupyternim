set terminal svg size 600,400 dynamic enhanced font 'arial,10' mousing name "simple_1" butt dashlength 1.0 
set output 'simple.1.svg'
set key fixed left top vertical Right noreverse enhanced autotitle box lt black linewidth 1.000 dashtype solid
set style increment default
set samples 50, 50
set title "Simple Plots" 
set title  font ",20" norotate
set xrange [ * : * ] noreverse writeback
set x2range [ * : * ] noreverse writeback
set yrange [ * : * ] noreverse writeback
set y2range [ * : * ] noreverse writeback
set zrange [ * : * ] noreverse writeback
set cbrange [ * : * ] noreverse writeback
set rrange [ * : * ] noreverse writeback
plot [-10:10] sin(x),atan(x),cos(atan(x))