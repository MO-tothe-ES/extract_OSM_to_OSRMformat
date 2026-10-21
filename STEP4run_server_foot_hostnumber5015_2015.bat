docker run -t -i -p 5015:5000 -v "D:/tung_databehandling/OSRM/denmark-history-extracted/foot/2015:/data" ghcr.io/project-osrm/osrm-backend osrm-routed --algorithm mld /data/denmark-2015.osrm
IF ERRORLEVEL 1 (
    echo "osrm-extract failed"
    exit /b 1
)
