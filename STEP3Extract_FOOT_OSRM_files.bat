@echo off
setlocal enabledelayedexpansion

set "INPUT_YEARDATA=D:\tung_databehandling\OSRM\denmark-history\year-files"
set "OUTPUT_BASE=D:\tung_databehandling\OSRM\denmark-history-extracted\foot"
set "OSRM_DOCKER_IMAGE=ghcr.io/project-osrm/osrm-backend"
set "PROFILE=/opt/foot.lua"

for /L %%Y in (2008,1,2025) do (
    echo ===============================
    echo Processing year %%Y
    echo ===============================

    set "INPUT_FOLDER=%INPUT_YEARDATA%\%%Y"
    set "YEAR_FOLDER=%OUTPUT_BASE%\%%Y"
    if not exist "!YEAR_FOLDER!" mkdir "!YEAR_FOLDER!"

    set "INPUT_FILE=!INPUT_FOLDER!\denmark-%%Y.osm.pbf"

    if not exist "!INPUT_FILE!" (
        echo ERROR: Missing input file: "!INPUT_FILE!"
        echo Skipping year %%Y
    ) else (
        echo Running OSRM preprocessing for year %%Y...

    REM (inside your existing for loop, after YEAR_FOLDER/INPUT_FILE are set)

    REM Ensure input file exists in your INPUT_YEARDATA
    if not exist "!INPUT_FILE!" (
        echo ERROR: Missing input file: "!INPUT_FILE!"
        echo Skipping year %%Y
    ) else (
        REM Copy PBF into the writable YEAR_FOLDER if it's not already there
        if not exist "!YEAR_FOLDER!\denmark-%%Y.osm.pbf" (
            echo Copying source PBF into year folder...
            copy /Y "!INPUT_FILE!" "!YEAR_FOLDER!\denmark-%%Y.osm.pbf" >nul
        ) else (
            echo Input already present in year folder, reusing it.
        )

        echo Running OSRM preprocessing for year %%Y...

    REM Run extract/partition/customize mounting only the YEAR_FOLDER as /data (writable)
    docker run --rm -t -v "!YEAR_FOLDER!:/data" -w /data %OSRM_DOCKER_IMAGE% osrm-extract -p %PROFILE% /data/denmark-%%Y.osm.pbf
    docker run --rm -t -v "!YEAR_FOLDER!:/data" -w /data %OSRM_DOCKER_IMAGE% osrm-partition /data/denmark-%%Y.osrm
    docker run --rm -t -v "!YEAR_FOLDER!:/data" -w /data %OSRM_DOCKER_IMAGE% osrm-customize /data/denmark-%%Y.osrm

    echo Year %%Y completed.
)


        echo Year %%Y completed.
    )

    echo.
)

pause
