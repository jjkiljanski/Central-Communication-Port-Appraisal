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
%%% This script executes some descriptive exercises                     %%% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear
load('data/output/DATAusingSW');

% Define output directory
outputDir = 'data/output';

% Compute densities
EmpDensity_n = L_n./Area_n;
lEmpDensity_n = log(L_n)-log(Area_n);
PopDensity_n = R_n./Area_n;
lPopDensity_n = log(R_n)-log(Area_n);
lCommImport_n = log(L_n)-log(R_n);

% Map some input data
writeMatrixWithHeader(lEmpDensity_n, {'Log employment density'}, outputDir, 'MAP_EmpDensity.csv');
writeMatrixWithHeader(lPopDensity_n, {'Log population density'}, outputDir, 'MAP_PopDensity.csv');
writeMatrixWithHeader(lCommImport_n, {'Log commuting import'}, outputDir, 'MAP_CommImport.csv');
writeMatrixWithHeader(h_price, {'House price'}, outputDir, 'MAP_HousePrice.csv');
writeMatrixWithHeader(w_n, {'Wage'}, outputDir, 'MAP_Wage.csv'); 

% Check distances
avDist = mean(dist_mat, 2);
writeMatrixWithHeader(avDist, {'Average distance to other counties'}, outputDir, 'MAP_AvDist.csv');
avDist_rail = mean(dist_mat_rail, 2);
writeMatrixWithHeader(avDist_rail, {'Average rail distance to other counties'}, outputDir, 'MAP_AvDist_rail.csv');
avDist_highway = mean(dist_mat_highway, 2);
writeMatrixWithHeader(avDist_highway, {'Average road distance to other counties'}, outputDir, 'MAP_AvDist_highway.csv');
% Distances looks sensible

% Correlate commuting probabilities with distance %%%%%%%%%%%%%%%%%%%%%%%%%
% Clear current figure
clf;
disp('Figure cleared.');

% Create scatter plot for log-log model
figureHandle = figure; % Explicitly create a new figure and capture its handle
disp('New figure created.');

% Check if figure was created successfully
if isempty(figureHandle)
    error('Failed to create a new figure.');
end

clf;
scatter(log(dist_mat), log(comMat));
xlabel('Distance (log)'); % Label x-axis
ylabel('Commuting probability (log)'); % Label y-axis
title('Commuting probability, log-log model'); % Title for the plot
grid on; % Optionally, turn the grid on for easier visualization
print('figs/Scatter_Lambda_log_log', '-dpng', '-r300');

clf;
scatter((dist_mat), log(comMat));
xlabel('Distance (km)'); % Label x-axis
ylabel('Commuting probability (log)'); % Label y-axis
title('Commuting probability, log-lin model'); % Title for the plot
grid on; % Optionally, turn the grid on for easier visualization
print('figs/Scatter_Lambda_log_lin', '-dpng', '-r300');

% Simple bivariate regressions to get slopes %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Flatten the matrices into vectors
dist_mat_vec = reshape(dist_mat, [], 1);
comMat_vec = reshape(comMat, [], 1);
log_dist_mat = log(dist_mat_vec);
log_comMat = log(comMat_vec);
% Filtering for positive values in log_comMat
positive_idx = log_comMat > 0;
filtered_log_comMat = log_comMat(positive_idx);
filtered_log_dist_mat = log_dist_mat(positive_idx);
% for the log log model
X_filtered = [ones(size(filtered_log_dist_mat)), filtered_log_dist_mat];
[b, bint, r, rint, stats] = regress(filtered_log_comMat, X_filtered);
slope = b(2);  % Access the second row, first column
disp(['The slope of the regression is: ', num2str(slope)]);

% For the log-lin model 
filtered_dist_mat = dist_mat(positive_idx);
X_filtered = [ones(size(filtered_dist_mat)), filtered_dist_mat];
[b, bint, r, rint, stats] = regress(filtered_log_comMat, X_filtered);
slope = b(2);  % Access the second row, first column
disp(['The slope of the regression is: ', num2str(slope)]);

% Fixed effects regressions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

comMat_vec = reshape(comMat, [], 1);
dist_mat_vec = reshape(dist_mat, [], 1);

% Ensuring all entries are positive before taking logs
positive_idx = comMat_vec > 0;  % Index of positive values in comMat
log_comMat_vec = log(comMat_vec(positive_idx));
log_dist_mat_vec = log(dist_mat_vec(positive_idx));
dist_mat_vec = (dist_mat_vec(positive_idx));

n = size(dist_mat, 1);  % Assuming dist_mat is 401x401
[row_indices, col_indices] = find(reshape(positive_idx, n, n));  % Find row and column indices of positive entries

% Generate dummy variables
origin_dummies = dummyvar(row_indices);
destination_dummies = dummyvar(col_indices);

% Remove the first column to avoid multicollinearity
origin_dummies(:, 1) = [];
destination_dummies(:, 1) = [];

X = [ones(length(log_dist_mat_vec), 1), log_dist_mat_vec, origin_dummies, destination_dummies];

% Assuming the Statistics and Machine Learning Toolbox is available
[b, bint, r, rint, stats] = regress(log_comMat_vec, X);
slope = b(2);  % Access the second row, first column
disp(['The slope of the regression is: ', num2str(slope)]);

% For log-lin model
X = [ones(length(dist_mat_vec), 1), dist_mat_vec, origin_dummies, destination_dummies];
[b, bint, r, rint, stats] = regress(log_comMat_vec, X);
Comm_slope = b(2);  % Access the second row, first column
disp(['The slope of the regression is: ', num2str(Comm_slope)]);
% Slightly larger effect on 

% And now only recover the residuals
X = [ones(length(dist_mat_vec), 1), origin_dummies, destination_dummies];
[b, bint, r, rint, stats] = regress(log_comMat_vec, X);
clf;
scatter(dist_mat_vec, log_comMat_vec);
xlabel('Distance (log)'); % Label x-axis
ylabel('Commuting probability (log)'); % Label y-axis
title('Commuting probability, log-log model'); % Title for the plot
grid on; % Optionally, turn the grid on for easier visualization

% Compute commuter market access
omega_n = w_n.^epsi; 
CommWeight_ni = dist_mat.^(-mu.*epsi);
CMA_n = CommWeight_ni*omega_n;
writeMatrixWithHeader(log(CMA_n), {'Log commuting market access'}, outputDir, 'MAP_CMA.csv');
EmpPot_n = CommWeight_ni*L_n;
writeMatrixWithHeader(log(EmpPot_n), {'Log employment potential'}, outputDir, 'MAP_EmpPot.csv');

% Map productivities  
writeMatrixWithHeader(log(A_n), {'Log productivity'}, outputDir, 'Map_A.csv');

clf;
scatter(log(A_n), log(w_n));
xlabel('Log productivity A'); % Label x-axis
ylabel('Log wage w'); % Label y-axis
title('Productivity vs. wage'); % Title for the plot
grid on; % Optionally, turn the grid on for easier visualization
print('figs/Scatter_A_w', '-dpng', '-r300');

% Map trade shares and price index
writeMatrixWithHeader(tradeshOwn, {'Own trade share'}, outputDir, 'MAP_pi_nn.csv');
writeMatrixWithHeader(P_n, {'Tradables price index'}, outputDir, 'MAP_P_n.csv') 

display('<<<<<<<<<<<<<<< Descriptive analysis completed >>>>>>>>>>>>>>>')