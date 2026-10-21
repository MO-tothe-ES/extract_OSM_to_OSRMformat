@echo off
setlocal enabledelayedexpansion

REM -----------------------------
REM CHECK FOR OSMIUM IN ANACONDA
REM -----------------------------
if exist "%USERPROFILE%\AppData\Local\Anaconda3\Library\bin\osmium.exe" (
    set OSMIUM=%USERPROFILE%\AppData\Local\Anaconda3\Library\bin\osmium.exe
) else (
    set OSMIUM=osmium
)

REM -----------------------------
REM CONFIGURATION
REM -----------------------------
set INPUT_PBF=D:\tung_databehandling\OSRM\denmark-history\denmark-history.osm.pbf
set OUTPUT_BASE=D:\tung_databehandling\OSRM\denmark-history\year-files

REM -----------------------------
REM LOOP OVER YEARS
REM -----------------------------
for /L %%Y in (2008,1,2025) do (
    echo -------------------------------
    echo Processing year %%Y
    echo -------------------------------

    REM Create output folder
    set YEAR_FOLDER=%OUTPUT_BASE%\%%Y
    if not exist "!YEAR_FOLDER!" mkdir "!YEAR_FOLDER!"

    REM Create timestamp string for Jan 1 of the year
    set TIMESTAMP=%%Y-01-01T00:00:00Z

    REM Run osmium time-filter
    echo Running osmium for year %%Y...
    "!OSMIUM!" time-filter ^
        "%INPUT_PBF%" ^
        !TIMESTAMP! ^
        -o "!YEAR_FOLDER!\denmark-%%Y.osm.pbf"
)

echo -------------------------------
echo ALL YEARS DONE
echo -------------------------------
pause
