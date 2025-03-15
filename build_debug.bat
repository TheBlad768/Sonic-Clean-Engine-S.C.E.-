@ECHO OFF

REM // Ensure the script runs in the correct directory
cd /d "%~dp0"

REM // Delete some intermediate assembler output just in case
IF EXIST S3CE.Debug.gen (
    del S3CE.Debug.gen
    IF ERRORLEVEL 1 goto LABLERROR1
)
IF EXIST Main.p (
    del Main.p
    IF ERRORLEVEL 1 goto LABLERROR2
)
IF EXIST Main.h (
    del Main.h
    IF ERRORLEVEL 1 goto LABLERROR3
)
IF EXIST Main.log (
    del Main.log
    IF ERRORLEVEL 1 goto LABLERROR4
)

REM // Run the assembler
REM // '-xx' shows the most detailed error output
REM // '-q' shuts up AS
REM // '-c' outputs a shared file (*.h)
REM // '-A' gives us a small speedup
REM // '-L' listing to file
REM // '-U' forces case-sensitivity
REM // '-E' output errors to a file (*.log)
REM // '-i .' allows (b)include paths to be absolute
set AS_MSGPATH=Tools/AS/Windows
set USEANSI=n

REM // Allow the user to choose to print error messages out by supplying the -pe parameter
"%AS_MSGPATH%/asw.exe" -xx -n -q -c -D __DEBUG__ -olist Main.Debug.lst -A -L -U -E -i . Main.asm
IF ERRORLEVEL 1 (
    echo Assembler failed to execute.
    goto LABLERROR5
)
IF NOT EXIST Main.p (
    echo Assembler did not produce Main.p.
    goto LABLERROR5
)

REM // Convert the assembled file to binary
"%AS_MSGPATH%/p2bin.exe" -p=FF -z=0,kosinskiplus,Size_of_DAC_driver_guess,after Main.p S3CE.Debug.gen Main.h
IF ERRORLEVEL 1 (
    echo Failed to convert Main.p to S3CE.Debug.gen.
    pause & exit /b 1
)

REM // Delete temporary files with error checking
IF EXIST Main.p (
    del Main.p
    IF ERRORLEVEL 1 (
        echo Failed to delete Main.p during final cleanup.
        pause & exit /b 1
    )
)
IF EXIST Main.h (
    del Main.h
    IF ERRORLEVEL 1 (
        echo Failed to delete Main.h during final cleanup.
        pause & exit /b 1
    )
)

REM // Check if the output file was created
IF NOT EXIST S3CE.Debug.gen (
    echo Failed to generate S3CE.Debug.gen.
    pause & exit /b 1
)

REM // Generate debug information
"%AS_MSGPATH%/convsym.exe" Main.lst S3CE.Debug.gen -input as_lst -range 0 FFFFFF -exclude -filter \"z[A-Z].+\" -a
IF ERRORLEVEL 1 (
    echo Failed to generate debug information for S3CE.Debug.gen.
    pause & exit /b 1
)
"%AS_MSGPATH%/convsym.exe" Main.lst "Engine/_RAM.Debug.asm" -in as_lst -out asm -range FF0000 FFFFFF
IF ERRORLEVEL 1 (
    echo Failed to generate debug information for Engine/_RAM.Debug.asm.
    pause & exit /b 1
)

REM // Make ROM padding (commented out as in the original)
REM // "%AS_MSGPATH%/rompad.exe" S3CE.Debug.gen 255 0

REM // Fix the ROM header (checksum)
"%AS_MSGPATH%/fixheader.exe" S3CE.Debug.gen
IF ERRORLEVEL 1 (
    echo Failed to fix the ROM header for S3CE.Debug.gen.
    pause & exit /b 1
)

REM // Copy rom to CD folder
IF EXIST S3CE.Debug.gen (
    copy S3CE.Debug.gen _CD
    IF ERRORLEVEL 1 (
        echo Failed to copy S3CE.Debug.gen.
        pause & exit /b 1
    )
)

REM // Successful completion: exit and close the console
exit 0

:LABLERROR1
echo Failed to build because write access to S3CE.Debug.gen was denied.
pause & exit /b 1

:LABLERROR2
echo Failed to build because write access to Main.p was denied.
pause & exit /b 1

:LABLERROR3
echo Failed to build because write access to Main.h was denied.
pause & exit /b 1

:LABLERROR4
echo Failed to build because write access to Main.log was denied.
pause & exit /b 1

:LABLERROR5
IF EXIST Main.log (
    type Main.log
) ELSE (
    echo Main.log not found, check if assembler ran correctly.
)
REM // Display a noticeable message
echo.
echo **********************************************************************
echo *                                                                    *
echo *      There were build errors. See Main.log for more details.      *
echo *                                                                    *
echo **********************************************************************
echo.
pause & exit /b 1
