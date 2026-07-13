@echo off

:: Change to the directory containing this batch file
cd /d "%~dp0"

echo Welcome to the CaNDy Lab EEM correction tool.
echo.
set /p user_path=Copy/paste the path to the directory here: 

:: Remove surrounding quotes (if present)
set user_path=%user_path:"=%

echo.
echo Correcting EEMs in: %user_path%
echo.

Rscript scriptFiles\MAIN.R "%user_path%"

echo.
pause