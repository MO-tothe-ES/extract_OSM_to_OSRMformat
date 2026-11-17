@echo off
setlocal EnableExtensions EnableDelayedExpansion

REM ============================================================
REM Change only these two years:
set "YYYY1=2008"
set "YYYY2=2025"

REM Base folder containing one subfolder per year:
set "BASE_DIR=D:\tung_databehandling\OSRM\denmark-history-extracted\driving"

REM Docker image and OSRM algorithm:
set "OSRM_IMAGE=ghcr.io/project-osrm/osrm-backend:v6.0.0"
set "ALGORITHM=mld"

REM All tabs will be opened in this named Windows Terminal window:
set "WT_WINDOW=OSRM-SERVERS"
REM ============================================================

if %YYYY1% GTR %YYYY2% (
    echo ERROR: YYYY1 must be less than or equal to YYYY2.
    pause
    exit /b 1
)

REM Check that Windows Terminal is available.
where wt.exe >nul 2>&1
if errorlevel 1 (
    echo ERROR: Windows Terminal ^(wt.exe^) was not found.
    echo Install Windows Terminal or enable its App Execution Alias.
    pause
    exit /b 1
)

set "FIRST_SERVER=1"
set /A STARTED_COUNT=0

for /L %%Y in (%YYYY1%,1,%YYYY2%) do (
    set /A YY=%%Y %% 100

    if !YY! LSS 10 (
        set "YY_PADDED=0!YY!"
    ) else (
        set "YY_PADDED=!YY!"
    )

    REM Driving ports are 61YY:
    REM 2008 -> 6108, 2015 -> 6115, 2025 -> 6125
    set "HOST_PORT=51!YY_PADDED!"
    set "YEAR_DIR=%BASE_DIR%\%%Y"
    set "OSRM_BASE=denmark-%%Y.osrm"
    set "CONTAINER_NAME=osrm-driving-51-%%Y"

    if not exist "!YEAR_DIR!\!OSRM_BASE!.properties" (
        echo WARNING: Skipping %%Y because this file does not exist:
        echo          !YEAR_DIR!\!OSRM_BASE!.properties
        echo.
    ) else (
        echo Starting OSRM %%Y on localhost:!HOST_PORT! ...

        REM Remove an old container with the same name, if one exists.
        docker rm -f "!CONTAINER_NAME!" >nul 2>&1

        REM Open the server in a new tab in the same Terminal window.
        wt.exe -w "%WT_WINDOW%" new-tab ^
            --title "OSRM %%Y - port !HOST_PORT!" ^
            --suppressApplicationTitle ^
            cmd.exe /k docker run --rm ^
            --name "!CONTAINER_NAME!" ^
            -p !HOST_PORT!:5000 ^
            -v "!YEAR_DIR!:/data" ^
            "%OSRM_IMAGE%" ^
            osrm-routed --algorithm "%ALGORITHM%" "/data/!OSRM_BASE!"

        set /A STARTED_COUNT+=1

        REM Give the first Windows Terminal window time to initialize.
        if "!FIRST_SERVER!"=="1" (
            set "FIRST_SERVER=0"
            timeout /t 2 /nobreak >nul
        )
    )
)

echo.
echo Launched !STARTED_COUNT! OSRM servers in Windows Terminal window "%WT_WINDOW%".
echo Each server has its own tab.