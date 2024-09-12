import geopandas as gpd
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd

def color_counties(shapefile_path, color_values, title, color_scheme = 'green', railway_gdf=None, write_path=None):
    """
    Colors the counties in Poland according to the numbers passed in the list.

    Parameters:
    - shapefile_path: Path to the shapefile containing the administrative borders of counties.
    - color_values: List of numbers used to color the counties. The order should match the order of the counties in the shapefile.
    """
    # Load the shapefile using GeoPandas
    gdf = gpd.read_file(shapefile_path)
    
    # Ensure the color_values list is the same alength as the number of counties
    if len(color_values) != len(gdf):
        raise ValueError("The length of the color_values list must match the number of counties in the shapefile.")
    
    # Add the color values to the GeoDataFrame
    gdf['color_value'] = color_values

    # Set the colormap
    if color_scheme == 'green':
        cmap = plt.cm.viridis  # Use green colormap
    elif color_scheme == 'grey':
        cmap = plt.colormaps['Greys']   # Use gray colormap
    else:
        raise ValueError("Invalid color_scheme. Choose 'gray' or 'green'.")
    
    # Normalize the color values to a colormap range
    norm = plt.Normalize(vmin=min(color_values), vmax=max(color_values))
    
    # Plot the counties with the assigned colors
    fig, ax = plt.subplots(1, 1, figsize=(10, 10))
    gdf.plot(column='color_value', cmap=cmap, linewidth=0.8, ax=ax, edgecolor='0.8')

    # Add the railway line if provided
    if railway_gdf is not None:
        railway_gdf.plot(ax=ax, color='red', linewidth=1, linestyle='-', edgecolor='none')
    
    # Add a colorbar
    sm = plt.cm.ScalarMappable(cmap=cmap, norm=norm)
    sm.set_array([])
    fig.colorbar(sm, ax=ax)
    
    # Set title and show plot
    plt.title(title)
    
    # Save or show plot
    if write_path:
        plt.savefig(write_path, bbox_inches='tight')
        print(f"Plot saved to {write_path}")
    else:
        plt.show()

def main():

    # Initiate

    plots = ["rChange", "vChange", "qChange", "pChange", "avDistRail", "avDistHighway", "avDist", "avdniChange"]
    root_path = "E:/Studia/Studia magisterskie/Wirtschaftwissenschaft/Quantitative Spatial Economics/Central-Communication-Port-Appraisal/shape/"
    csv_root = "E:/Studia/Studia magisterskie/Wirtschaftwissenschaft/Quantitative Spatial Economics/Central-Communication-Port-Appraisal/data/output/"
    powiaty_path = "E:/Studia/Studia magisterskie/Wirtschaftwissenschaft/Quantitative Spatial Economics/Central-Communication-Port-Appraisal/shape/powiaty.shp"
    write_root = "E:/Studia/Studia magisterskie/Wirtschaftwissenschaft/Quantitative Spatial Economics/Central-Communication-Port-Appraisal/figs/"

    print("Importing necessary shapefiles.")
    
    gdf_y = gpd.read_file(root_path + "poland-railway-proposed-latest-y.shp")
    gdf_pis_project = gpd.read_file(root_path + "poland-railways-proposed-pis.shp")
    gdf_ko_project = gpd.read_file(root_path + "KO.shp")
    scenarios = [gdf_y, gdf_pis_project, gdf_ko_project]
    
    # Map counterfactuals
    
    for plot in plots:
        # Load the baseline CSV data
        csv_path = csv_root + "fut_" + plot + ".csv"
        csv_data_baseline = pd.read_csv(csv_path, header=0)

        # Plot baseline future scenario in comparison to 2021
        if (plot in ["rChange", "vChange", "qChange", "pChange"]):
            write_path = write_root + "counterfactuals/economic_equilibrium/" + plot + "_future_vs_2021.png"
        else:
            write_path = write_root + "counterfactuals/average_distance/" + plot + "_future_vs_2021.png"
        print(csv_path)
        print(write_path)
        title = list(csv_data_baseline.columns)[0]
        color_counties(powiaty_path, list(csv_data_baseline.iloc[:, 0]), title + " (%)", color_scheme = 'grey', write_path = write_path)
        
        for i, scenario in enumerate(scenarios):
            # Load the CSV data
            csv_path = csv_root + "ctf" + str(i+1) + "_" + plot + ".csv"
            csv_data = pd.read_csv(csv_path, header=0)

            if (plot in ["rChange", "vChange", "qChange", "pChange"]):
                write_path = write_root + "counterfactuals/economic_equilibrium/" + plot + "_ctf" + str(i+1) + ".png"
            else:
                write_path = write_root + "counterfactuals/average_distance/" + plot + "_ctf" + str(i+1) + ".png"
            print(csv_path)
            print(write_path)
            ctf_values = np.array(list(csv_data.iloc[:, 0]))
            fut_values = np.array(list(csv_data_baseline.iloc[:, 0]))
            print(plot)
            relative_change = ((ctf_values/fut_values)-1)*100
            relative_change = list(relative_change)
            title = list(csv_data.columns)[0]
            # Replace '2021' with 'future baseline'
            title = title.replace('2021', 'future baseline')
            color_counties(powiaty_path, relative_change, title + " (%)", color_scheme = 'grey', railway_gdf = scenario, write_path = write_path)
    
    # Map descriptives

    descriptives = ["A", "AvDist", "CMA", "CommImport", "EmpDensity", "EmpPot", "HousePrice", "P_n", "pi_nn", "PopDensity", "Wage"]
    
    for descriptive in descriptives:
            # Load the CSV data
            csv_path = csv_root + "MAP_" + descriptive + ".csv"
            csv_data = pd.read_csv(csv_path, header=0)
            
            write_path = write_root + "descriptives/" + descriptive + ".png"
            print(csv_path)
            print(write_path)
            title = list(csv_data.columns)[0]
            values = list(csv_data.iloc[:, 0])
            color_counties(powiaty_path, values, title, color_scheme = 'grey', write_path = write_path)

if __name__ == "__main__":
    main()