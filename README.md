# Appraisal of Investment in the Railway component of the Central Communication Port (CPK) in Poland

**© Jan Kiljański**

## Project Overview

This repository is a fork of the "Toolkit for Quantitative Spatial Models" developed by Gabriel Ahlfeldt and Tobias Seidel. The original repository provides a MATLAB framework for simulating and analyzing quantitative spatial economic model à la Monte, Redding, and Rossi-Hansberg (2018).

In this fork, the toolkit has been adapted to study the economic impacts of the three most important scenarios of the development of Polish railway infrastructure:
1. The construction of the so called "Y-line" railway, a significant component of the Central Communication Port (CPK) project in Poland.
2. The so called "Spokes" project proposed by PiS government
3. The KO project proposed by the new government that came to power in the late 2023.

![y-line-schema](https://github.com/user-attachments/assets/5d4a3f60-32c7-4b2c-914f-b75b7f16468b)
![pis-spokes-schema](https://github.com/user-attachments/assets/c1e410e1-f907-42f0-b5f4-2a92e8966c74)
![ko-schema](https://github.com/user-attachments/assets/57c6316c-e990-4719-bd14-ed3cad8c7f74)







All the projects aim to enhance railway connectivity across key regions in Poland, and this repository provides the necessary modifications and data to apply the Monte, Redding, and Rossi-Hansberg (2018) model to assess their potential economic effects and compare them.

## Objectives

The primary objective of this project is to apply the quantitative spatial model to analyze how the considered railway projects might influence spatial economic outcomes in Poland. This includes examining changes in commuting patterns, employment distribution, and other relevant economic indicators under various scenarios associated with the new infrastructure.

## Specific Modifications and Additions

### Data Inputs

The original toolkit has been supplemented with Poland-specific data relevant to all the three projects:

- **Poland Commuting Data:** Bilateral commuting flows specific to regions affected by the Y-line.
- **Distance Matrices:** Updated matrices that reflect travel times and distances within Poland.
- **Economic Indicators:** Region-specific economic data such as employment, population, and wages, tailored to the Polish context.

### Custom MATLAB Scripts

Additional scripts have been created or modified to facilitate the analysis of the Y-line project:

- `ReadPolandData.m`: A script to load and preprocess Poland-specific data inputs.
- `Counterfactuals.m`: A modified counterfactual analysis script to assess the impact of the Y-line on regional economic outcomes.
- `transport_matrix_computation.ipynb`: Jupyter Notebook python script to produce the transport matrix from shapefiles extracted from OpenSteetMap
- `generate_transport_matrices.py`: Python script creating transport matrices on the basis of counties centroids, railway network and road network shapefile. It is the same code as in the `transport_matrix_computation`, but can be run in one go.

### Shapefiles

Poland-specific shapefiles have been added to support spatial analysis and visualization:

- **powiaty.shp:** Shapefiles with all the counties in Poland.
- **powiaty_centroids.shp:** Centroids of counties in Poland.
- **poland-railway-proposed-latest-y.shp:** Schema of the Railway Expansion in the Y-Line Scenario.
- **poland-railways-proposed-pis.shp:** Schema of the Railway Expansion in the PiS "Spokes" Scenario.
- **KO.shp** Schema of the railway in the KO Scenario.

## How to Use This Repository
The repository presents ready outcomes of my analysis. In order to rerun my code, you should follow the steps below:

1. **Install basic tools:** The scripts where written and executed in Python 3.12.5 version. You need to install osmosis for processing .osm.pbf files (binary files are available in the official github repository: https://github.com/openstreetmap/osmosis). Ensure that all necessary MATLAB toolboxes are installed, as outlined in the original toolkit's README. QGIS is very useful for maintaining high control over generated and processed files. I used it to manually create different scenario shapefiles.
2. **Generate shapefiles:** Follow the steps described in the `shapes/README.md` to generate the shapefiles, and later transport matrices.
3. **Run Scripts in Sequence:** Execute the master script `MRRH2018_toolkit.m` as detailed in the original README.
4. **Modify and Experiment:** Users are encouraged to modify the provided scripts to explore various scenarios related to the railway network expansion scenarios, such as changes in travel times, employment distribution, or population shifts.

## Project Citation

When using this repository in your work, please cite it as:

Kiljański, J. (2024): Appraisal of Investment in the Railway component of the Central Communication Port (CPK) in Poland. https://github.com/jjkiljanski/Central-Communication-Port-Appraisal.git

Please also consider citing the original toolkit and the relevant academic papers associated with this work.

## Acknowledgments

This project was prepared as part of the Quantitative Spatial Economics course taught by Professor Gabriel Ahlfeldt at Humboldt University of Berlin. It builds on the original toolkit developed by Gabriel Ahlfeldt and Tobias Seidel. The toolkit, as well as the QSE course, have been instrumental in the development of this project. I would like to extend my sincere thanks to Professor Ahlfeldt for his guidance and support throughout the course.
