%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Master MATLAB programme file for the MRRH2018 tolkit by             %%%
%%% Gabriel Ahlfeldt M. Ahlfeldt and Tobias Seidel                      %%%
%%% The toolkit covers a class of quantitative spatial models           %%%
%%% introduced in Monte, Redding, Rossi-Hansberg (2018): Commuting,     %%%
%%% Migration, and Local Employment Elasticities.                       %%%
%%% The toolkit uses data and code compiled for                         %%%
%%% Seidel and Wckerath (2020): Rush hours and urbanization             %%%
%%% Codes and data have been re-organized to make the toolkit more      %%%
%%% accessible. Seval programmes have been added to allow for more      %%%
%%% general applications. Discriptive analyses and counterfactuals      %%%
%%% serve didactic purposes and are unrelated to both research papers   %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% First version: Gabriel M Ahlfeldt, 05/2024                            %%%
% Based on original code provided by Tobias Seidel                      %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% This script compiles the data                                       %%% 
%%% This script also inverts productivities and computes trade shares   %%%
%%% and the tradable price index                                        %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Read in data
% addpath src/model_code/;
clear;
load('data/output/parameters');
dataComm = 'commuting_wide_poland.csv';                                    
dataEmployment = 'employment_poland.csv';
dataHous = 'house_prices_poland.csv';
dataDistanceRailway = 'travel-time-matrix-2021-railway.csv';
dataDistanceHighway = 'travel-time-matrix-2021-highway.csv';
dataArea = 'CountyArea_poland.csv';

labor_file = 'labor_tidy_poland.csv';
df = readtable(labor_file);

outVar = 'data/output/modelVar.mat';

% Import employment data (data on all workers in county according to place
% of living)
employment = readmatrix(dataEmployment, 'Range', 'B1');

% Import commuting data (contains only information on those workers that
% commute)
comMat = readmatrix(dataComm, 'Range', 'B2');
%comMat = comMat';
diff = sum(comMat, 2) - sum(comMat', 2);                                    %Check difference between all outcommuters and incommuters
% Compute the amount of people that do not commute
employment_static = employment - sum(comMat, 1)';
% Create a diagonal matrix with static employment
diag_employment_static = diag(employment_static);
% Add the static employment to the commuting matrix
comMat = comMat + diag_employment_static;
L = sum(comMat, 'all');
uncondCom = comMat ./ L;
condCom = uncondCom./ sum(uncondCom, 2);
%condCom = condCommut(comMat);

% Import wage data
w_n = [df.median_income_workplace];
w_n = w_n ./ mean(w_n);
%v_i = residWage(w_i, condCom);
v_n = condCom * w_n;

% Import employment data
L_n = sum(uncondCom, 1)' * L;
L_n = L_n ./ mean(L_n);
%R_i = residLoc(L_i, uncondCom);
R_n = sum(uncondCom, 2) * L;
R_n = R_n ./ mean(R_n);

% Import house price data
h_price = readtable(dataHous);
h_price = [h_price.rentindex];
lh_price = log(h_price);

% Import distance data and compute trade costs from distances
dist_mat_rail = readmatrix(dataDistanceRailway);
dist_mat_highway = readmatrix(dataDistanceHighway);

% Ensure that both of the matrices are symmetric
dist_mat_rail = (dist_mat_rail + dist_mat_rail')/2;
dist_mat_highway = (dist_mat_highway + dist_mat_highway')/2;

% I fill in the distance from the county to itself as the half of the
% average distance to three closest counties.
% Function to calculate the average of the three smallest non-diagonal elements
sortedRow = @(row) sort(row(row > 0), 'ascend');

% Process the railway distance matrix
for i = 1:size(dist_mat_rail, 1)
    if dist_mat_rail(i, i) == 0
        values = sortedRow(dist_mat_rail(i, :));
        dist_mat_rail(i, i) = mean(values(1:3));
        dist_mat_rail(i, i) = dist_mat_rail(i, i)/2;
    end
end

% Process the highway distance matrix
for i = 1:size(dist_mat_highway, 1)
    if dist_mat_highway(i, i) == 0
        values = sortedRow(dist_mat_highway(i, :));
        dist_mat_highway(i, i) = mean(values(1:3));
        dist_mat_highway(i, i) = dist_mat_highway(i, i)/2;
    end
end

% Ensure the output directory exists
outputDir = 'data/output/';
if ~exist(outputDir, 'dir')
    mkdir(outputDir);
end

writematrix(dist_mat_rail, fullfile(outputDir, 'MAP_dist_mat_rail.csv'));
writematrix(dist_mat_highway, fullfile(outputDir, 'MAP_dist_mat_highway.csv'));

dist_mat = (dist_mat_rail.^0.09).*(dist_mat_highway.^0.91);
dist_mat = dist_mat/min(dist_mat(:));
dni = dist_mat.^psi;

writematrix(dni, fullfile(outputDir, 'MAP_dni.csv'));

%Distance elasticity taken from Head/ Mayer, cost elasticity assuming sigma 4 from Broda and Weinstein (2004)

% Import geographic area
Area_n = readmatrix(dataArea, 'Range','B1');

% Define files containing data
nobs = length(L_n);

% Now read in matrices
% baseline = csvread(no_traffic, 1, 1);
% baseline = baseline';

% Drop some auxi. variables
clear dataArea dataComm dataDistance dataHous diff labour_file lCommImport_n no_traffic dataHous A_n P_n labor_file uncondComOld

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Quantification

% Compute productivities and trade shares 
[A_n,tradesh,tradeshOwn,P_n ] = solveProductTradeTK(L_n, R_n, w_n, v_n, dni);               
 
% Save data
save('data/output/DATAusingSW')

display('<<<<<<<<<<<<<<< Data compilation completed >>>>>>>>>>>>>>>')