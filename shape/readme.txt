For the generation of the shapefiles for the downstream tasks, I used two GeoFabrik OpenStreetMap extracts:
1. OSM 01.01.2022 snapshot for Poland (poland-220101-internal.osm.pbf, https://download.geofabrik.de/europe/poland.html#),
2. OSM 17.08.2024 snapshot for Poland (poland-latest-internal.osm.pbf, https://download.geofabrik.de/europe/poland.html).

I placed them in the ./shape folder, and use osmosis to extract the highways. Osmosis has to be installed independently (simply download the latest osmosis binaries to a chosen folder and add to the path).

I ran the following commands in Windows cmd to generated the respective osm.pbf extracts.

1. I generated the complete highway and railway extracts for both snapshots, to make the processing of the further steps shorter.

osmosis --read-pbf file="poland-latest-internal.osm.pbf" --tf accept-ways railway=* --used-node --write-pbf file="poland-railways-latest.osm.pbf"

osmosis --read-pbf file="poland-220101-internal.osm.pbf" --tf accept-ways railway=* --used-node --write-pbf file="poland-railways-220101.osm.pbf"

osmosis --read-pbf file="poland-latest-internal.osm.pbf" --tf accept-ways highway=motorway,motorway_link,trunk,trunk_link,primary,primary_link,secondary,secondary_link,tertiary,tertiary_link,proposed,construction --used-node --write-pbf file="poland-highway-latest.osm.pbf"

osmosis --read-pbf file="poland-220101-internal.osm.pbf" --tf accept-ways highway=motorway,motorway_link,trunk,trunk_link,primary,primary_link,secondary,secondary_link,tertiary,tertiary_link,proposed,construction --used-node --write-pbf file="poland-highway-220101.osm.pbf"

2a. From the railway extracts, I extracted ways with railway=rail, railway=construction, railway=proposed to three distinct files for every snapshot:

osmosis --read-pbf file="poland-railways-220101.osm.pbf" --tf accept-ways railway=rail --used-node --write-pbf file="poland-railways-rail-220101.osm.pbf"

osmosis --read-pbf file="poland-railways-220101.osm.pbf" --tf accept-ways railway=construction --used-node --write-pbf file="poland-railways-construction-220101.osm.pbf"

osmosis --read-pbf file="poland-railways-220101.osm.pbf" --tf accept-ways railway=proposed --used-node --write-pbf file="poland-railways-proposed-220101.osm.pbf"

osmosis --read-pbf file="poland-railways-latest.osm.pbf" --tf accept-ways railway=rail --used-node --write-pbf file="poland-railways-rail-latest.osm.pbf"

osmosis --read-pbf file="poland-railways-latest.osm.pbf" --tf accept-ways railway=construction --used-node --write-pbf file="poland-railways-construction-latest.osm.pbf"

osmosis --read-pbf file="poland-railways-latest.osm.pbf" --tf accept-ways railway=proposed --used-node --write-pbf file="poland-railways-proposed-latest.osm.pbf"

2b. From the highway extracts, I extracted ways with highway=construction, highway=proposed, and highway=[everything else] to three distinct files for every snapshot:

osmosis --read-pbf file="poland-highway-220101.osm.pbf" --tf reject-ways highway=proposed,construction --used-node --write-pbf file="poland-highway-roads-220101.osm.pbf"

osmosis --read-pbf file="poland-highway-220101.osm.pbf" --tf accept-ways highway=construction --used-node --write-pbf file="poland-highway-construction-220101.osm.pbf"

osmosis --read-pbf file="poland-highway-220101.osm.pbf" --tf accept-ways highway=proposed --used-node --write-pbf file="poland-highway-proposed-220101.osm.pbf"

osmosis --read-pbf file="poland-highway-latest.osm.pbf" --tf reject-ways highway=proposed,construction --used-node --write-pbf file="poland-highway-roads-latest.osm.pbf"

osmosis --read-pbf file="poland-highway-latest.osm.pbf" --tf accept-ways highway=construction --used-node --write-pbf file="poland-highway-construction-latest.osm.pbf"

osmosis --read-pbf file="poland-highway-latest.osm.pbf" --tf accept-ways highway=proposed --used-node --write-pbf file="poland-highway-proposed-latest.osm.pbf" 

3. I used QGIS to convert every shapefile to GeoJSON for preliminary inspection and data cleaning. I didn't use ESRI shapefile format on this stage to prevent the loss of data: some way attribute descriptions were longer than accepted ESRI shapefile attribute length and were truncated. GeoJSON doesn't have maximum attribute length.

4. The data was further processed with python code. I provide python code to process everything in one step, as well as Jupyter Notebook to 

REMARK: The poland-railways-proposed-latest.shp file generated during the processing in python was manually split in QGIS into Y-line and the rest.
