@Echo off
title sonlayout

if not exist *.bin goto EXIT

echo Input layout format
set /p "input=>"
cls
if not defined input goto ERROR

echo Output layout format
set /p "output=>"
cls
if not defined output goto ERROR

for %%f in (*.bin) do (
		sonlayout -i %input% -o %output% "%%f" "%%~nf.bin.out"
	)

:EXIT
pause & exit

:ERROR
echo Format undefined
pause
