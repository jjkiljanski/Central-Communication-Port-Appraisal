"""
The following modules need to be installed: numpy, pandas, geopandas, shapely, networkx.

You can use:
pip install numpy
pip install pandas
pip install geopandas
pip install shapely
pip install networkx
pip install matplotlib

"""

import numpy as np
import pandas as pd
import geopandas as gpd
from shapely.geometry import LineString, Point
from shapely.ops import nearest_points, unary_union
import networkx as nx
import matplotlib.pyplot as plt


def upload_centroids(root_path):
    print("Loading centroids")
    try:
        gdfCentroids = gpd.read_file(root_path + "powiaty_centroids.shp")
    except FileNotFoundError:
        print(f"File not found: {root_path + 'powiaty_centroids.shp'}")
    gdfCentroids = gdfCentroids.to_crs(epsg=3035)
    return gdfCentroids

def plot_gdf(gdf, output_file):
    """
    Plots the provided shapefile and saves the plot to the output file.
    """
    
    # Create the plot
    ax = gdf.plot(color='pink')
    
    # Save the plot to the output file
    plt.savefig(output_file)
    plt.close()  # Close the plot to free up memory



  
def upload_shapefile(file, default_speed, root_path):
    print("Loading shapefile")
    try: 
        gdfNet = gpd.read_file(root_path + file + ".shp")
    except FileNotFoundError:
        print(f"File not found: {root_path + file + '.shp'}")

    gdfNet = gdfNet.to_crs(epsg=3035)
    gdfNet["maxspeed"] = pd.to_numeric(gdfNet["maxspeed"], errors='coerce')
    gdfNet.loc[gdfNet["maxspeed"].isna(), "maxspeed"] = default_speed
    gdfNet.loc[gdfNet["maxspeed"]==0, "maxspeed"] = default_speed

    return gdfNet






def prepare_network_shapefile(gdfNet):
    print("Preparing network shapefile")

    # Step 1: Prepare the transportation network shapefile for conversion into a Graph
    n_segments_before_split = len(gdfNet)

    # Fix geometries to avoid issues during graph conversion
    unary = gdfNet.geometry.unary_union
    gdfNet.geometry = gdfNet.geometry.buffer(0.01)  # Float arithmetic correction
    geom = [i for i in unary.geoms]
    id = [j for j in range(len(geom))]
    unary = gpd.GeoDataFrame({'id': id, 'geometry': geom}, crs=3035)
    gdfNet = gpd.sjoin(unary, gdfNet, how='inner', predicate='within')

    n_segments_after_split = len(gdfNet)

    print(f'\tSegments before split: {n_segments_before_split}.')
    print(f'\tSegments after split: {n_segments_after_split}.')


    # Step 2: Create a graph from the geometries
    G = nx.Graph()

    # Add edges to the graph based on the LineString geometries
    for idx, geom in enumerate(gdfNet.geometry):
        if isinstance(geom, LineString):
            coords = list(geom.coords)
            for i in range(len(coords) - 1):
                G.add_edge(coords[i], coords[i + 1], index=idx)


    # Step 3: Identify the largest connected component
    largest_cc = max(nx.connected_components(G), key=len)
    

    # Step 4: Filter the GeoDataFrame to keep only the geometries that are part of the largest connected component
    def is_part_of_largest_cc(geom):
        coords = list(geom.coords)
        return any(coord in largest_cc for coord in coords)

    gdfNet = gdfNet[gdfNet.geometry.apply(is_part_of_largest_cc)]


    # Step 5: Assign travel time to each segment
    gdfNet['travel_time'] = ((gdfNet.length / 1000) / gdfNet["maxspeed"].astype(float)) * 60


    # Step 6: Assign unique IDs and clean the dataframe
    gdfNet = gdfNet.reset_index(drop=True)
    gdfNet = gdfNet.drop(columns=['index_right'])

    print(f'\tSegments after filtering: {len(gdfNet)}.')

    return gdfNet



def prepare_centroids_for_conversion_into_graph(gdfNet, gdfCentroids):

    # Assume the entry points to the railway line are all geometry nodes in the line.
    # It is a simplifying assumption.

    print("Preparing centroids for conversion into graph")

    entryPoints = []
    for geom in gdfNet.geometry:
        if geom.geom_type == 'Point':
            entryPoints.append(geom)
        elif geom.geom_type in ['LineString', 'Polygon']:
            entryPoints.append(list(geom.coords)[0])
            entryPoints.append(list(geom.coords)[-1])
        else:
            print("None of the three types.")

    print("\nCreated entryPoints list.")

    entryPoints = set(entryPoints)
    gdfEntryPoints = gpd.GeoDataFrame(geometry=gpd.points_from_xy([tpl[0] for tpl in entryPoints], [tpl[1] for tpl in entryPoints]), crs=3035)
    powiaty_codes = list(gdfCentroids['JPT_KOD_JE'])

    #Use geopandas's sjoin_nearest to find the closest street network vertice for each zonal centroid, then build straight lines.
    mappingCentroidToNet = gpd.sjoin_nearest(gdfCentroids, gdfEntryPoints, how='left')['index_right'].to_dict()
    lines = []
    for centroid, entryPoint in mappingCentroidToNet.items():
        ptStart = gdfCentroids.loc[centroid, 'geometry']
        ptEnd = gdfEntryPoints.loc[entryPoint, 'geometry']
        line = LineString([ptStart, ptEnd])
        lines.append(line)

    gdfConnections = gpd.GeoDataFrame(geometry=lines, crs=3035)

    # I assume the travel time to the nearest railway access at pace of 30km/h
    gdfConnections['travel_time'] = ((gdfConnections.length / 1000) / 30) * 60

    return gdfConnections, powiaty_codes




def plot_network_with_connections(gdfNet, gdfConnections, gdfCentroids, file_name):
    """
    Plots the railway network, connections, and centroids of Powiaty.
    Optionally saves the plot to a file.
    
    Parameters:
    - gdfNet: GeoDataFrame of the railway network.
    - gdfConnections: GeoDataFrame of connections to the nearest railway.
    - gdfCentroids: GeoDataFrame of the centroids of Powiaty.
    - title: Title for the plot.
    - file_name: Optional file name to save the plot. If None, the plot is not saved.
    """

    print("\tPlotting connections.")
    
    # Create the plot
    fig, ax = plt.subplots(figsize=(10, 10))
    
    # Plot the street network
    gdfNet.plot(ax=ax, color='grey', linewidth=2, label='2021 Railway Network')
    
    # Plot the connections
    gdfConnections.plot(ax=ax, color='red', linewidth=0.5, label='Connections to the Nearest Road Network Entry')
    
    # Add the centroids of Powiaty
    gdfCentroids.plot(ax=ax, color='red', marker='o', markersize=8, label='Centroids of Powiaty')
    
    # Set the title and legend
    #ax.set_title(title)
    ax.legend()
    
    # Save the plot to a file if file_name is provided
    plt.savefig(file_name, format='png', bbox_inches='tight')
    print(f"\tPlot saved to {file_name}")




def check_edges_have_attribute(graph, attribute):
    for u, v, data in graph.edges(data=True):
        if attribute not in data:
            return False
    return True




def create_nx_graph(gdfNet, gdfConnections, powiaty_codes):

    print("Creating nx graph")
    # Step 1: Create a graph from the geometries
    G = nx.Graph()

    # Add edges to the graph based on the gdfNet LineString geometries
    for idx, geom in enumerate(gdfNet.geometry):
        if isinstance(geom, LineString):
            coords = list(geom.coords)
            G.add_edge(coords[0], coords[-1], index=idx, travel_time = gdfNet.loc[idx, 'travel_time'])

    # Check if the graph G is connected
    is_connected = nx.is_connected(G)

    # Print the result
    if is_connected:
        print("\nThe graph G is connected.")
    else:
        print("\nThe graph G is not connected.")

    # Step 2: Add edges to the graph based on the gdfConnections LineString geometries
    for idx, geom in enumerate(gdfConnections.geometry):
        if isinstance(geom, LineString):
            coords = list(geom.coords)
            
            # Add the centroid (starting point) as a vertex with a unique identifier
            centroid_vertex = coords[0]
            network_vertex = coords[-1]

            # Add the centroid vertex with a 'centroid_id' attribute
            G.add_node(centroid_vertex, centroid_id=powiaty_codes[idx])

            # Add the edge from the centroid to the network with 'travel_time' attribute
            G.add_edge(centroid_vertex, network_vertex, connection_idx=idx, travel_time=gdfConnections.loc[idx, 'travel_time'])

    # Check if the graph G is connected
    is_connected = nx.is_connected(G)

    # Print the result
    if is_connected:
        print("\nThe graph G is connected.")
    else:
        print("\nThe graph G is not connected.")

    print(f"\nTotal number of graph edges: {len(G.edges())}")

    # Check if all edges have "travel_time" attribute
    if check_edges_have_attribute(G, "travel_time"):
        print("\tAll edges have the 'travel_time' attribute.")
    else:
        print("\tNot all edges have the 'travel_time' attribute.")

    return G





def shortest_path_between_centroids(G, centroid_id_1, centroid_id_2):
    """
    Computes the shortest path between two centroids in the graph G and the total travel time.

    Parameters:
    - G: NetworkX graph where nodes corresponding to centroids have a 'centroid_id' attribute.
    - centroid_id_1: ID of the starting centroid.
    - centroid_id_2: ID of the destination centroid.

    Returns:
    - path: List of nodes representing the shortest path.
    - total_travel_time: Total travel time for the shortest path in minutes.
    """
    
    # Find the nodes in the graph corresponding to the centroid IDs
    start_node = None
    end_node = None
    
    for node, data in G.nodes(data=True):
        if data.get('centroid_id') == centroid_id_1:
            start_node = node
        elif data.get('centroid_id') == centroid_id_2:
            end_node = node
    
    if start_node is None or end_node is None:
        raise ValueError("One or both of the centroid IDs do not exist in the graph.")
    
    # Compute the shortest path between the two nodes
    path = nx.shortest_path(G, source=start_node, target=end_node, weight='travel_time')
    
    # Compute the total travel time for the path
    total_travel_time = sum(G[u][v].get('travel_time', 0) for u, v in zip(path[:-1], path[1:]))
    
    return path, total_travel_time

# Example usage
# path, travel_time = shortest_path_between_centroids(G, centroid_id_1=powiaty_codes[10], centroid_id_2=powiaty_codes[14])




def plot_shortest_path(path, travel_time, gdfNet, file_name, ax=None):
    """
    Plots the shortest path on the same plot as the gdfNet and adds the travel time to the legend.
    Optionally saves the plot to a file.
    
    Parameters:
    - G: NetworkX graph where nodes corresponding to centroids have a 'centroid_id' attribute.
    - path: List of nodes representing the shortest path.
    - travel_time: Total travel time for the shortest path in minutes.
    - gdfNet: GeoDataFrame of the railway network.
    - file_name: Optional file name to save the plot. If None, the plot is not saved.
    - ax: Matplotlib axis to plot on. If None, a new figure and axis will be created.
    """
    
    # Create a LineString from the path nodes
    path_coords = [node for node in path]
    path_line = LineString(path_coords)
    
    # Convert the LineString to a GeoDataFrame for easy plotting
    gdfPath = gpd.GeoDataFrame(geometry=[path_line], crs=gdfNet.crs)
    
    # Plot the railway network (gdfNet) if an axis is not provided
    if ax is None:
        fig, ax = plt.subplots(1, 1, figsize=(10, 10))
    else:
        fig = ax.figure
    
    # Plot the railway network
    gdfNet.plot(ax=ax, color='grey', linewidth=2, label='2021 Railway Network')
    
    # Plot the shortest path
    gdfPath.plot(ax=ax, color='red', linewidth=3, linestyle='--', label=f'Shortest Path (Travel Time: {travel_time:.2f} min)')
    
    # Add a legend
    ax.legend()
    
    # Save the plot to a file if file_name is provided
    plt.savefig(file_name, format='png', bbox_inches='tight')
    print(f"\tPlot saved to {file_name}")




def compute_travel_time_matrix(G, set_1, set_2):
    """
    Computes a travel time matrix between two sets of points based on the shortest path in the graph G.

    Parameters:
    - G: NetworkX graph where edges have a 'travel_time' attribute.
    - set_1: List of centroid IDs corresponding to the first set of points.
    - set_2: List of centroid IDs corresponding to the second set of points.

    Returns:
    - travel_time_matrix: A 2D NumPy array where each element (i, j) is the travel time from set_1[i] to set_2[j].
    """

    print("Computing travel time matrix")
    
    # Extract the nodes corresponding to centroid IDs in set_1 and set_2
    nodes_set_1 = [next(node for node, data in G.nodes(data=True) if data.get('centroid_id') == cid) for cid in set_1]
    nodes_set_2 = [next(node for node, data in G.nodes(data=True) if data.get('centroid_id') == cid) for cid in set_2]
    
    # Initialize the travel time matrix
    travel_time_matrix = np.full((len(set_1), len(set_2)), np.inf)  # Fill with infinity as default
    
    # Compute shortest paths from all nodes in set_1 to all nodes in set_2
    for i, node_start in enumerate(nodes_set_1):
        print(f"\tBatch {i} out of {len(nodes_set_1)}.")
        lengths = nx.single_source_dijkstra_path_length(G, source=node_start, weight='travel_time')
        for j, node_end in enumerate(nodes_set_2):
            travel_time_matrix[i, j] = lengths.get(node_end, np.inf)  # Default to infinity if no path exists
    
    return travel_time_matrix




def color_counties(shapefile_path, color_values, write_path):
    """
    Colors the counties in Poland according to the numbers passed in the list.

    Parameters:
    - shapefile_path: Path to the shapefile containing the administrative borders of counties.
    - color_values: List of numbers used to color the counties. The order should match the order of the counties in the shapefile.
    """

    # Load the shapefile using GeoPandas
    try:
        gdf = gpd.read_file(shapefile_path)
    except FileNotFoundError:
        print(f"File not found: {shapefile_path}")

    
    # Ensure the color_values list is the same alength as the number of counties
    if len(color_values) != len(gdf):
        raise ValueError("The length of the color_values list must match the number of counties in the shapefile.")
    
    # Add the color values to the GeoDataFrame
    gdf['color_value'] = color_values

    cmap = plt.cm.viridis  # Use green colormap
    
    # Normalize the color values to a colormap range
    norm = plt.Normalize(vmin=min(color_values), vmax=max(color_values))
    
    # Plot the counties with the assigned colors
    fig, ax = plt.subplots(1, 1, figsize=(10, 10))
    gdf.plot(column='color_value', cmap=cmap, linewidth=0.8, ax=ax, edgecolor='0.8')
    
    # Add a colorbar
    sm = plt.cm.ScalarMappable(cmap=cmap, norm=norm)
    sm.set_array([])
    fig.colorbar(sm, ax=ax)
    
    # Set title and show plot
    plt.title("Poland: Counties (Powiaty) Colored by Distance from an Example Origin")
    
    # Save plot
    plt.savefig(write_path, bbox_inches='tight')
    print(f"\nPlot saved to {write_path}")





def save(data_input_path, file, travel_time_matrix):
    print("Saving travel time matrix to csv")
    try:
        np.savetxt(data_input_path + file + '.csv', travel_time_matrix, delimiter=',')
    except Exception as e:
        print(f"An unexpected error occurred: {e}")









def main():
    railway_speed = 90
    road_speed = 56

    resources_config = [
        #("poland-railway-rail-220101", "travel-time-matrix-2021-railway", railway_speed),
        # ("poland-railway-future", "travel-time-matrix-future-railway", railway_speed),
        # ("poland-railway-future_counterfactual", "travel-time-matrix-future-railway-counterfactual", railway_speed),
        # ("poland-railway-future_counterfactual2", "travel-time-matrix-future-railway-counterfactual2", railway_speed),
        # ("poland-railway-future_counterfactual3", "travel-time-matrix-future-railway-counterfactual3", railway_speed),
        # ("poland-highway-roads-220101", "travel-time-matrix-2021-highway", road_speed),
        ("poland-highway-future", "travel-time-matrix-future-highway", road_speed)
    ]

    root_path = "E:/Studia/Studia magisterskie/Wirtschaftwissenschaft/Quantitative Spatial Economics/Central-Communication-Port-Appraisal/shape/"
    data_input_path = "E:/Studia/Studia magisterskie/Wirtschaftwissenschaft/Quantitative Spatial Economics/Central-Communication-Port-Appraisal/data/input/"
    plots_path = "E:/Studia/Studia magisterskie/Wirtschaftwissenschaft/Quantitative Spatial Economics/Central-Communication-Port-Appraisal/figs/travel_matrix_computation/"

    gdfCentroids = upload_centroids(root_path)
    plot_gdf(gdfCentroids, plots_path + "centroids.png")
    
    for resource in resources_config:
        file, write_file, default_speed = resource
        gdfNet = upload_shapefile(file, default_speed, root_path)
        
        plot_gdf(gdfNet, plots_path + file + ".png")
        gdfNet = prepare_network_shapefile(gdfNet)
        plot_gdf(gdfNet, plots_path + file + "_biggest_component.png")
        gdfConnections, powiaty_codes = prepare_centroids_for_conversion_into_graph(gdfNet, gdfCentroids)
        plot_network_with_connections(gdfNet, gdfConnections, gdfCentroids, file_name = plots_path + file + "_with_centroids.png")
        G = create_nx_graph(gdfNet, gdfConnections, powiaty_codes)
        path, travel_time = shortest_path_between_centroids(G, centroid_id_1=powiaty_codes[10], centroid_id_2=powiaty_codes[144])
        plot_shortest_path(path, travel_time, gdfNet, file_name = plots_path + file + "example_path.png")
        travel_time_matrix = compute_travel_time_matrix(G, powiaty_codes, powiaty_codes)
        color_values = travel_time_matrix[179, :]
        color_counties(root_path + 'powiaty.shp', color_values, plots_path + file + "_example_distances.png")
        
        save(data_input_path, file, travel_time_matrix)

if __name__ == "__main__":
    main()