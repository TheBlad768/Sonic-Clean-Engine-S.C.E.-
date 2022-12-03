@ECHO OFF

REM // delete some intermediate assembler output just in case
IF EXIST Sonic.gen del Sonic.gen
IF EXIST Sonic.gen goto LABLERROR3
IF EXIST Sonic.p del Sonic.p
IF EXIST Sonic.p goto LABLERROR2
IF EXIST Sonic.h del Sonic.h
IF EXIST Sonic.h goto LABLERROR1

REM // run the assembler
REM // '-xx' shows the most detailed error output
REM // '-q' shuts up AS
REM // '-c' outputs a shared file (Sonic.h)
REM // '-A' gives us a small speedup
REM // '-L' listing to file
REM // '-i .' allows (b)include paths to be absolute
set AS_MSGPATH=Win32/as
set USEANSI=n

REM // allow the user to choose to print error messages out by supplying the -pe parameter
"Win32/as/asw.exe" -xx -q -c -A -L -i . Sonic.asm
IF NOT EXIST Sonic.p pause & exit

"Win32/s1p2bin" Sonic.p Sonic.gen Sonic.h
IF EXIST Sonic.p del Sonic.p
IF EXIST Sonic.h del Sonic.h

IF NOT EXIST Sonic.gen pause & exit

REM // generate debug information
"Win32/convsym.exe" Sonic.lst Sonic.gen -a -input as_lst

REM // "Win32/rompad.exe" Sonic.gen 255 0

REM // fix the rom header (checksum)
"Win32/fixheader.exe" Sonic.gen

REM // Copy rom to CD folder
copy Sonic.gen _CD
exit /b

:LABLERROR1
echo Failed to build because write access to Sonic.h was denied.
pause & exit
:LABLERROR2
echo Failed to build because write access to Sonic.p was denied.
pause & exit
:LABLERROR3
echo Failed to build because write access to Sonic.gen was denied.
pause
