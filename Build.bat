@ECHO OFF

REM // delete some intermediate assembler output just in case
IF EXIST Sonic.gen del Sonic.gen
IF EXIST Sonic.gen goto LABLERROR3
IF EXIST Sonic.p del Sonic.p
IF EXIST Sonic.p goto LABLERROR2
IF EXIST Sonic.h del Sonic.h
IF EXIST Sonic.h goto LABLERROR1

REM // clear the output window
cls

REM // run the assembler
REM // -xx shows the most detailed error output
REM // -c outputs a shared file (Sonic.h)
REM // -A gives us a small speedup
set AS_MSGPATH=Win32
set USEANSI=n

REM // allow the user to choose to print error messages out by supplying the -pe parameter
IF "%1"=="-logerrors" ( "Win32/asw.exe" -xx -q -c -E -A -L Sonic.asm ) ELSE "Win32/asw.exe" -xx -q -c -A -L Sonic.asm
IF "%1"=="-logerrors" ( IF EXIST Sonic.log goto LABLERROR4 )
IF EXIST Sonic.p "Win32/s1p2bin" Sonic.p Sonic.gen Sonic.h
IF NOT EXIST Sonic.p goto LABLPAUSE

REM // generate debug information
IF EXIST Sonic.gen "Win32/convsym" Sonic.lst Sonic.gen -a -input as_lst

REM // "Win32/rompad" Sonic.gen 255 0

REM // fix the rom header (checksum)
IF EXIST Sonic.gen "Win32/fixheadr" Sonic.gen

REM // done -- pause if we seem to have failed, then exit
IF EXIST Sonic.p del Sonic.p
IF EXIST Sonic.h del Sonic.h
IF EXIST Sonic.gen goto LABLEXIT
:LABLPAUSE
pause
goto LABLEXIT
:LABLERROR1
echo Failed to build because write access to Sonic.h was denied.
pause
goto LABLEXIT
:LABLERROR2
echo Failed to build because write access to Sonic.p was denied.
pause
goto LABLEXIT
:LABLERROR3
echo Failed to build because write access to Sonic.gen was denied.
pause
goto LABLEXIT
:LABLERROR4
REM // display a noticeable message
echo.
echo **********************************************************************
echo *                                                                    *
echo *   There were build errors/warnings. See Sonic.log for more details.   *
echo *                                                                    *
echo **********************************************************************
echo.
pause
:LABLEXIT
exit /b