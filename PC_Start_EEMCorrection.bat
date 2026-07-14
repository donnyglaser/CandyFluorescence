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

:: Try PATH first
where Rscript >nul 2>nul
if %errorlevel%==0 (
    Rscript scriptFiles\MAIN.R "%user_path%"
    goto end
)

:: Try default installation directory
for /d %%D in ("C:\Program Files\R\R-*") do (
    if exist "%%D\bin\Rscript.exe" (
        "%%D\bin\Rscript.exe" scriptFiles\MAIN.R "%user_path%"
        goto end
    )
)

echo.
echo ERROR: Could not find Rscript.exe.
echo Please install R from https://cran.r-project.org/.

:end
echo.
pause