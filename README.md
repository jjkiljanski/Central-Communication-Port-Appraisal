# Appraisal of Investment in the Railway component of the Central Communication Port (CPK) in Poland

**© [Your Name]**

## Project Overview

This repository is a fork of the "Toolkit for Quantitative Spatial Models" developed by Gabriel Ahlfeldt and Tobias Seidel. The original repository provides a MATLAB framework for simulating and analyzing quantitative spatial economic model à la Monte, Redding, and Rossi-Hansberg (2018).

In this fork, the toolkit has been adapted to study the economic impacts of the construction of the so called "Y-line" railway, a significant component of the Central Communication Port (CPK) project in Poland. The Y-line project aims to enhance railway connectivity across key regions in Poland, and this repository provides the necessary modifications and data to apply the Monte, Redding, and Rossi-Hansberg (2018) model to assess its potential economic effects.

## Objectives

The primary objective of this project is to apply the quantitative spatial model to analyze how the Y-line railway project might influence spatial economic outcomes in Poland. This includes examining changes in commuting patterns, employment distribution, and other relevant economic indicators under various scenarios associated with the new infrastructure.

## Specific Modifications and Additions

### Data Inputs

The original toolkit has been supplemented with Poland-specific data relevant to the Y-line project:

- **Poland Commuting Data:** Bilateral commuting flows specific to regions affected by the Y-line.
- **Distance Matrices:** Updated matrices that reflect travel times and distances within Poland, with special focus on regions connected by the Y-line.
- **Economic Indicators:** Region-specific economic data such as employment, population, and wages, tailored to the Polish context.

### Custom MATLAB Scripts

Additional scripts have been created or modified to facilitate the analysis of the Y-line project:

- `ReadPolandData.m`: A script to load and preprocess Poland-specific data inputs.
- `YlineCounterfactuals.m`: A modified counterfactual analysis script to assess the impact of the Y-line on regional economic outcomes.
- `VisualizePoland.m`: A script to generate visualizations of the model outputs specific to the Y-line project, utilizing Polish shapefiles.

### Shapefiles

Poland-specific shapefiles have been added to support spatial analysis and visualization:

- **Poland Regions:** Shapefiles corresponding to the regions impacted by the Y-line.

## How to Use This Repository

1. **Install MATLAB Toolboxes:** Ensure that all necessary MATLAB toolboxes are installed, as outlined in the original toolkit's README.
2. **Run Scripts in Sequence:** Follow the order of script execution starting with `MRRH2018_toolkit.m` as detailed in the original README, substituting Poland-specific scripts where applicable.
3. **Modify and Experiment:** Users are encouraged to modify the provided scripts to explore various scenarios related to the Y-line project, such as changes in travel times, employment distribution, or population shifts.

## Project Citation

When using this repository in your work, please cite it as:

Kiljański, J. (2024): Appraisal of Investment in the Railway component of the Central Communication Port (CPK) in Poland. [GitHub Repository URL]

Please also consider citing the original toolkit and the relevant academic papers associated with this work.

## Acknowledgments

This project was prepared as part of the Quantitative Spatial Economics course taught by Professor Gabriel Ahlfeldt at Humboldt University of Berlin. It builds on the original toolkit developed by Gabriel Ahlfeldt and Tobias Seidel. The toolkit, as well as the QSE course, have been instrumental in the development of this project. I would like to extend my sincere thanks to Professor Ahlfeldt for his guidance and support throughout the course.
