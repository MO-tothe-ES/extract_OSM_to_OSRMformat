@echo off
setlocal EnableExtensions EnableDelayedExpansion

REM =====================================================
REM Locate osmium.exe (Anaconda)
REM =====================================================
set OSMIUM=

if exist "%USERPROFILE%\AppData\Local\Anaconda3\Library\bin\osmium.exe" (
    set OSMIUM=%USERPROFILE%\AppData\Local\Anaconda3\Library\bin\osmium.exe
)

if exist "C:\ProgramData\Anaconda3\Library\bin\osmium.exe" (
    set OSMIUM=C:\ProgramData\Local\Anaconda3\Library\bin\osmium.exe
)

if "%OSMIUM%"=="" (
    for /f "delims=" %%i in ('where conda 2^>nul') do (
        set CONDA_PATH=%%~dpi
        set OSMIUM=!CONDA_PATH!..\Library\bin\osmium.exe
        if exist "!OSMIUM!" goto FOUND_OSMIUM
    )
)

:FOUND_OSMIUM
if not exist "%OSMIUM%" (
    echo ERROR: osmium.exe not found.
    echo Please install osmium-tool in your conda base environment.
    pause
    exit /b 1
)

echo Using osmium:
echo %OSMIUM%
echo.

REM =====================================================
REM Settings
REM =====================================================
set INPUT_PLANET=D:\tung_databehandling\OSRM\denmark-history\history-latest.osm.pbf
set DENMARK_HISTORY=D:\tung_databehandling\OSRM\denmark-history\denmark-history.osm.pbf
set POLY=D:\tung_databehandling\OSRM\denmark-history\denmark.poly




REM =====================================================
REM Check input files
REM =====================================================
if not exist "%INPUT_PLANET%" (
    echo ERROR: Full history file "%INPUT_PLANET%" not found.
    pause
    exit /b 1
)

if not exist "%POLY%" (
    echo Downloading Denmark polygon...
    powershell -Command ^
      "Invoke-WebRequest -Uri 'https://download.geofabrik.de/europe/denmark.poly' -OutFile '%POLY%'"
)

REM =====================================================
REM Extract Denmark from full history
REM =====================================================
echo.
echo Extracting Denmark from planet history...
echo.

"%OSMIUM%" extract --with-history ^
    --strategy complete_ways ^
    --verbose --progress ^
    -p "%POLY%" ^
    -o "%DENMARK_HISTORY%" ^
    "%INPUT_PLANET%"

if ERRORLEVEL 1 (
    echo ERROR: Denmark extraction failed.
    pause
    exit /b 1
)


echo.
echo =========================================
echo DONE! All years processed successfully.
echo Output files are in %OUTDIR%
echo =========================================
pause
