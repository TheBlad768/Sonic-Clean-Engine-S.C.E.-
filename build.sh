#!/bin/sh
rm -f Sonic.gen
rm -f Sonic.p
rm -f Sonic.h

AS/Linux/as/asl -xx -q -c -A -L -i . Sonic.asm
test -f Sonic.log && cat Sonic.log
test -f Sonic.p || exit

AS/Linux/as/p2bin -p=FF -z=0,kosinski-optimised,Size_of_Mega_PCM_guess,after Sonic.p Sonic.gen Sonic.h

rm -f Sonic.p
rm -f Sonic.h

AS/Linux/convsym Sonic.lst Sonic.gen -a -input as_lst -exclude -filter "z[A-Z].+"

#AS/Linux/rompad Sonic.gen 255 0
AS/Linux/fixheader Sonic.gen

test -f Sonic.gen || exit 1
exit 0
