# Shapefile Generation for Downstream Tasks

This process uses OpenStreetMap (OSM) extracts from GeoFabrik to generate shapefiles for downstream analysis. The extracts used are:

1. **OSM 01.01.2022 snapshot for Poland**: [`poland-220101-internal.osm.pbf`](https://download.geofabrik.de/europe/poland.html#)
2. **OSM 17.08.2024 snapshot for Poland**: [`poland-latest-internal.osm.pbf`](https://download.geofabrik.de/europe/poland.html)

Both files are placed in the `./shape` folder, and the highway data is extracted using **Osmosis**. Osmosis must be installed separately. You can download the latest binaries and add them to your system's PATH.

## Step-by-Step Instructions

### 1. Generate Highway and Railway Extracts
To process OSM data more efficiently, generate extracts of highways and railways from both snapshots using the following commands in Windows Command Prompt.

#### Railways Extracts:
```bash
osmosis --read-pbf file="poland-latest-internal.osm.pbf" --tf accept-ways railway=* --used-node --write-pbf file="poland-railways-latest.osm.pbf"
osmosis --read-pbf file="poland-220101-internal.osm.pbf" --tf accept-ways railway=* --used-node --write-pbf file="poland-railways-220101.osm.pbf"
```

#### Highways Extracts:
```bash
osmosis --read-pbf file="poland-latest-internal.osm.pbf" --tf accept-ways highway=motorway,motorway_link,trunk,trunk_link,primary,primary_link,secondary,secondary_link,tertiary,tertiary_link,proposed,construction --used-node --write-pbf file="poland-highway-latest.osm.pbf"
osmosis --read-pbf file="poland-220101-internal.osm.pbf" --tf accept-ways highway=motorway,motorway_link,trunk,trunk_link,primary,primary_link,secondary,secondary_link,tertiary,tertiary_link,proposed,construction --used-node --write-pbf file="poland-highway-220101.osm.pbf"
```

### 2. Refining Extracts

#### 2a. Railway Refinement
To further process the railway data, extract specific types of railways into distinct files for each snapshot.

- **Railways (rail):**
  ```bash
  osmosis --read-pbf file="poland-railways-220101.osm.pbf" --tf accept-ways railway=rail --used-node --write-pbf file="poland-railways-rail-220101.osm.pbf"
  osmosis --read-pbf file="poland-railways-latest.osm.pbf" --tf accept-ways railway=rail --used-node --write-pbf file="poland-railways-rail-latest.osm.pbf"
  ```

- **Railways (construction):**
  ```bash
  osmosis --read-pbf file="poland-railways-220101.osm.pbf" --tf accept-ways railway=construction --used-node --write-pbf file="poland-railways-construction-220101.osm.pbf"
  osmosis --read-pbf file="poland-railways-latest.osm.pbf" --tf accept-ways railway=construction --used-node --write-pbf file="poland-railways-construction-latest.osm.pbf"
  ```

- **Railways (proposed):**
  ```bash
  osmosis --read-pbf file="poland-railways-220101.osm.pbf" --tf accept-ways railway=proposed --used-node --write-pbf file="poland-railways-proposed-220101.osm.pbf"
  osmosis --read-pbf file="poland-railways-latest.osm.pbf" --tf accept-ways railway=proposed --used-node --write-pbf file="poland-railways-proposed-latest.osm.pbf"
  ```

#### 2b. Highway Refinement
Similarly, split the highway data into construction, proposed, and other roads.

- **Regular Roads:**
  ```bash
  osmosis --read-pbf file="poland-highway-220101.osm.pbf" --tf reject-ways highway=proposed,construction --used-node --write-pbf file="poland-highway-roads-220101.osm.pbf"
  osmosis --read-pbf file="poland-highway-latest.osm.pbf" --tf reject-ways highway=proposed,construction --used-node --write-pbf file="poland-highway-roads-latest.osm.pbf"
  ```

- **Highways (construction):**
  ```bash
  osmosis --read-pbf file="poland-highway-220101.osm.pbf" --tf accept-ways highway=construction --used-node --write-pbf file="poland-highway-construction-220101.osm.pbf"
  osmosis --read-pbf file="poland-highway-latest.osm.pbf" --tf accept-ways highway=construction --used-node --write-pbf file="poland-highway-construction-latest.osm.pbf"
  ```

- **Highways (proposed):**
  ```bash
  osmosis --read-pbf file="poland-highway-220101.osm.pbf" --tf accept-ways highway=proposed --used-node --write-pbf file="poland-highway-proposed-220101.osm.pbf"
  osmosis --read-pbf file="poland-highway-latest.osm.pbf" --tf accept-ways highway=proposed --used-node --write-pbf file="poland-highway-proposed-latest.osm.pbf"
  ```

### 3. Convert Shapefiles to GeoJSON
To prevent attribute truncation due to ESRI shapefile limitations, convert the shapefiles to **GeoJSON** format using **QGIS** for preliminary inspection and data cleaning. GeoJSON preserves all attribute data without any length restrictions.

### 4. Further Processing with Python
The final data processing is done using Python. Python scripts and a Jupyter Notebook are provided to automate the entire workflow. After running the Python script, additional manual adjustments may be necessary.

### Note:
- The file `poland-railways-proposed-latest.shp` was manually split in **QGIS** into **Y-line** and the rest.