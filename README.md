# Denmark · Historical OSRM routing

Build local routing servers for **driving, cycling and walking** from Denmark’s OpenStreetMap history. The scripts create **1 January snapshots for 2008–2025**, prepare OSRM networks, and serve routes and travel-time matrices over HTTP.

> **Workflow:** Download history → extract yearly snapshots → build routing networks → start servers.

## 1 · Install the tools

- **[Docker Desktop for Windows](https://docs.docker.com/desktop/setup/install/windows-install/)** — start Docker and use Linux containers.
- **[Anaconda or Miniconda](https://www.anaconda.com/download)** and **[Osmium Tool](https://anaconda.org/conda-forge/osmium-tool)**. In Anaconda Prompt, run:

  ```bat
  conda install -c conda-forge osmium-tool
  osmium --version
  ```

- **Windows Terminal** (`wt.exe`) — required by the driving server launcher.

OSRM and its Lua routing profiles come with the Docker image; no separate profile download is needed.

## 2 · Download the input data

The only external data input is **Denmark’s full-history OpenStreetMap PBF**.

1. Open [Geofabrik’s authenticated Denmark download page](https://osm-internal.download.geofabrik.de/europe/denmark.html).
2. Sign in with your OpenStreetMap account and follow the access terms. Download **`denmark-internal.osh.pbf`** (the full-history file).
3. Rename it to **`denmark-history.osm.pbf`** and place it here:

   ```text
   D:\tung_databehandling\OSRM\denmark-history\denmark-history.osm.pbf
   ```

Renaming preserves the history inside the file. The usual `denmark-latest.osm.pbf` contains only a current snapshot and cannot supply the historical years. See [Geofabrik’s download information](https://www.geofabrik.de/data/download.html).

## 3 · Run the scripts in order

Run the `.bat` files from Command Prompt / Anaconda Prompt. Before starting, replace the hard-coded `D:\tung_databehandling\OSRM` paths if your data lives elsewhere.

### STEP 2 — Extract yearly maps

Run **`STEP2extract_years_from_DKfullhistory.bat`**. It uses `osmium time-filter` to select the map at **00:00 UTC on 1 January** of each year, writing:

```text
denmark-history\year-files\YYYY\denmark-YYYY.osm.pbf
```

Adjust `INPUT_PBF`, `OUTPUT_BASE`, or the loop `(2008,1,2025)` as needed. Run from the environment where `osmium` is installed; the script otherwise tries a specific Anaconda installation path.

### STEP 3 — Build the routing networks

Run whichever transport modes you need:

| Script | Profile | Output beneath `denmark-history-extracted` |
| --- | --- | --- |
| `STEP3Extract_DRIVING_OSRM_files.bat` | `/opt/car.lua` | `driving\YYYY` |
| `STEP3Extract_BICYCLE_OSRM_files.bat` | `/opt/bicycle.lua` | `bicycle\YYYY` |
| `STEP3Extract_FOOT_OSRM_files.bat` | `/opt/foot.lua` | `foot\YYYY` |

Each copies the yearly PBF into its output folder, then runs **extract → partition → customize** for OSRM’s MLD algorithm. Keep the entire generated **`denmark-YYYY.osrm.*` file set** together.

> **Use one OSRM version throughout.** The driving launcher specifies `v6.0.0`, while the other scripts use an untagged image. Before building, set all image references to `ghcr.io/project-osrm/osrm-backend:v6.0.0`, or consistently choose another release for both building and serving.

### STEP 4 — Start the servers

| Script | Local endpoint |
| --- | --- |
| `STEP4run_server_driving_year_range_6108_to_6125.bat` | Ports **6108–6125**; one terminal tab per year |
| `STEP4run_server_foot_hostnumber5015_2015.bat` | `http://localhost:5015` — walking, 2015 |
| `STEP4run_server_foot_hostnumber5025_2025.bat` | `http://localhost:5025` — walking, 2025 |

For driving, edit `YYYY1`, `YYYY2` and `BASE_DIR`. Ports follow **61YY**: 2015 → 6115. Rerunning replaces containers named `osrm-driving-YYYY`. No bicycle server launcher is included.

Test driving for 2025 in a browser:

```text
http://localhost:6125/route/v1/driving/12.5683,55.6761;12.5830,55.6830?overview=false
```

Coordinates are **longitude,latitude**. A successful response includes `"code":"Ok"`; route distances are in metres and durations in seconds. See the [OSRM documentation](https://github.com/Project-OSRM/osrm-backend).

---

**Practical notes:** Start with one year to check resources. STEP 3 prints “completed” even if a Docker command fails, so check the logs. STEP 2 does not overwrite existing snapshots by default; STEP 3 reuses copied PBFs. Historical snapshots reflect **OSM mapping at that date**, which can differ from when roads actually opened.
