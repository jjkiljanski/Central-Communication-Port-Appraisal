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
%%% This script executes a series of counterfactuals in which we        %%% 
%%% first estimate the future economic activity, and then assess        %%%
%%% the economic impact of counterfactuals                              %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Create the estimation of the future economic activity

% Load data
dataDistanceRailway_future = 'travel-time-matrix-future-railway.csv';
dataDistanceHighway_future = 'travel-time-matrix-2021-highway.csv';

dist_mat_rail_future = readmatrix(dataDistanceRailway_future);
dist_mat_highway_future = readmatrix(dataDistanceHighway_future);

% I fill in the distance from the county to itself as the half of the
% average distance to three closest counties.
% Function to calculate the average of the three smallest non-diagonal elements
sortedRow = @(row) sort(row(row > 0), 'ascend');

% Process the railway distance matrix
for i = 1:size(dist_mat_rail_future, 1)
    if dist_mat_rail_future(i, i) == 0
        values = sortedRow(dist_mat_rail_future(i, :));
        dist_mat_rail_future(i, i) = mean(values(1:3));
        dist_mat_rail_future(i, i) = dist_mat_rail_future(i, i)/2;
    end
end

% Process the highway distance matrix
for i = 1:size(dist_mat_highway_future, 1)
    if dist_mat_highway_future(i, i) == 0
        values = sortedRow(dist_mat_highway_future(i, :));
        dist_mat_highway_future(i, i) = mean(values(1:3));
        dist_mat_highway_future(i, i) = dist_mat_highway_future(i, i)/2;
    end
end

% logicalMatrix = (dist_mat_rail_future == 0);
% numZeros = sum(logicalMatrix(:))

future_dist_mat = (dist_mat_rail_future.^0.9).*(dist_mat_highway_future.^0.91);
future_dist_mat = future_dist_mat/min(future_dist_mat(:));
future_dni = future_dist_mat.^psi; 

% Primitives that do not change => Changes are set to ones
aChange_future = ones(J, 1);
bChange_future = ones(J);
dChange_future = ones(J);
kapChange_future = ones(J,J);

% Set the change in transport cost
kapChange_future = future_dni./dni;

% Solve for counterfactual values
[fut_wChange, fut_vChange, fut_qChange, fut_piChange, fut_lamChange, fut_pChange, fut_rChange, ...
    fut_lChange, fut_welfChange] = counterFactsTK(...
        aChange_future, bChange_future, kapChange_future, dChange_future, w_n, v_n, uncondCom, L_n, ...
        R_n, tradesh);

fut_lChange(50,1)

fut_percentageChange = (fut_welfChange(1,1) - 1) * 100;

fprintf('...Change in welfare in comparison to 2021 in the baseline scenario is %.2f%%\n', fut_percentageChange);


% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ASSESS COUNTERFACTUAL 1
dataDistanceRailway_ctf1 = 'travel-time-matrix-future-railway-counterfactual.csv';
dist_mat_rail_ctf1 = readmatrix(dataDistanceRailway_ctf1);

sortedRow = @(row) sort(row(row > 0), 'ascend');

% Process the railway distance matrix
for i = 1:size(dist_mat_rail_ctf1, 1)
    if dist_mat_rail_ctf1(i, i) == 0
        values = sortedRow(dist_mat_rail_ctf1(i, :));
        dist_mat_rail_ctf1(i, i) = mean(values(1:3));
        dist_mat_rail_ctf1(i, i) = dist_mat_rail_ctf1(i, i) / 2;
    end
end

ctf1_dist_mat = (dist_mat_rail_ctf1.^0.9) .* (dist_mat_highway.^0.91);
ctf1_dist_mat = ctf1_dist_mat / min(ctf1_dist_mat(:));
ctf1_dni = ctf1_dist_mat.^psi;

% Primitives that do not change => Changes are set to ones
aChange_ctf1 = ones(J, 1);
bChange_ctf1 = ones(J);
dChange_ctf1 = ones(J);
kapChange_ctf1 = ones(J, J);

% Set the change in transport cost
kapChange_ctf1 = ctf1_dni ./ dni;

isequal(aChange_future, aChange_ctf1)

% Solve for counterfactual values
[ctf1_wChange, ctf1_vChange, ctf1_qChange, ctf1_piChange, ctf1_lamChange, ctf1_pChange, ctf1_rChange, ...
    ctf1_lChange, ctf1_welfChange] = counterFactsTK(...
        aChange_ctf1, bChange_ctf1, kapChange_ctf1, dChange_ctf1, w_n, v_n, uncondCom, L_n, ...
        R_n, tradesh);

%ctf1_lChange(50,1)

ctf1_percentageChange = ((ctf1_welfChange(1, 1)/fut_wChange(1,1)) - 1) * 100

fprintf('...Change in welfare in comparison to the baseline scenario in the Y-line scenario is %.2f%%\n', ctf1_percentageChange);

Map findings
RESULT = MAPIT('shape/powiaty', log(ctf1_qChange ./ fut_qChange), 'Relative change in house price; Y-Line Scenario', 'figs', 'MAP_COUNT1_Qchange');
RESULT = MAPIT('shape/powiaty', log(ctf1_vChange ./ fut_vChange), 'Relative change in average residential wages; Y-Line Scenario', 'figs', 'MAP_COUNT1_Vchange'); 
RESULT = MAPIT('shape/powiaty', log(ctf1_pChange ./ fut_pChange), 'Relative change in tradable goods price; Y-Line Scenario', 'figs', 'MAP_COUNT1_Pchange'); 
RESULT = MAPIT('shape/powiaty', log(ctf1_rChange ./ fut_rChange), 'Relative change in population; Y-Line Scenario', 'figs', 'MAP_COUNT1_Rchange');

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ASSESS COUNTERFACTUAL 2
dataDistanceRailway_ctf2 = 'travel-time-matrix-future-railway-counterfactual2.csv';
dist_mat_rail_ctf2 = readmatrix(dataDistanceRailway_ctf2);

sortedRow = @(row) sort(row(row > 0), 'ascend');

% Process the railway distance matrix
for i = 1:size(dist_mat_rail_ctf2, 1)
    if dist_mat_rail_ctf2(i, i) == 0
        values = sortedRow(dist_mat_rail_ctf2(i, :));
        dist_mat_rail_ctf2(i, i) = mean(values(1:3));
        dist_mat_rail_ctf2(i, i) = dist_mat_rail_ctf2(i, i) / 2;
    end
end

ctf2_dist_mat = (dist_mat_rail_ctf2.^0.9) .* (dist_mat_highway.^0.91);
ctf2_dist_mat = ctf2_dist_mat / min(ctf2_dist_mat(:));
ctf2_dni = ctf2_dist_mat.^psi;

% Primitives that do not change => Changes are set to ones
aChange_ctf2 = ones(J, 1);
bChange_ctf2 = ones(J);
dChange_ctf2 = ones(J);
kapChange_ctf2 = ones(J, J);

% Set the change in transport cost
kapChange_ctf2 = ctf2_dni ./ dni;

% Solve for counterfactual values
[ctf2_wChange, ctf2_vChange, ctf2_qChange, ctf2_piChange, ctf2_lamChange, ctf2_pChange, ctf2_rChange, ...
    ctf2_lChange, ctf2_welfChange] = counterFactsTK(...
        aChange_ctf2, bChange_ctf2, kapChange_ctf2, dChange_ctf2, w_n, v_n, uncondCom, L_n, ...
        R_n, tradesh);

%ctf2_lChange(50,1)

ctf2_percentageChange = ((ctf2_welfChange(1, 1)/fut_wChange(1,1)) - 1) * 100

fprintf('...Change in welfare in comparison to the baseline scenario in the PIS Spokes scenario %.2f%%\n', ctf2_percentageChange);

Map findings
RESULT = MAPIT('shape/powiaty', log(ctf2_qChange ./ fut_qChange), 'Relative change in house price; PIS "Spokes" Scenario', 'figs', 'MAP_COUNT2_Qchange');
RESULT = MAPIT('shape/powiaty', log(ctf2_vChange ./ fut_vChange), 'Relative change in average residential wages; PIS "Spokes" Scenario', 'figs', 'MAP_COUNT2_Vchange'); 
RESULT = MAPIT('shape/powiaty', log(ctf2_pChange ./ fut_pChange), 'Relative change in tradable goods price; PIS "Spokes" Scenario', 'figs', 'MAP_COUNT2_Pchange'); 
RESULT = MAPIT('shape/powiaty', log(ctf2_rChange ./ fut_rChange), 'Relative change in population; PIS "Spokes" Scenario', 'figs', 'MAP_COUNT2_Rchange');

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ASSESS COUNTERFACTUAL 3
dataDistanceRailway_ctf3 = 'travel-time-matrix-future-railway-counterfactual3.csv';
dist_mat_rail_ctf3 = readmatrix(dataDistanceRailway_ctf3);

sortedRow = @(row) sort(row(row > 0), 'ascend');

% Process the railway distance matrix
for i = 1:size(dist_mat_rail_ctf3, 1)
    if dist_mat_rail_ctf3(i, i) == 0
        values = sortedRow(dist_mat_rail_ctf3(i, :));
        dist_mat_rail_ctf3(i, i) = mean(values(1:3));
        dist_mat_rail_ctf3(i, i) = dist_mat_rail_ctf3(i, i) / 2;
    end
end

ctf3_dist_mat = (dist_mat_rail_ctf3.^0.9) .* (dist_mat_highway.^0.91);
ctf3_dist_mat = ctf3_dist_mat / min(ctf3_dist_mat(:));
ctf3_dni = ctf3_dist_mat.^psi;

% Primitives that do not change => Changes are set to ones
aChange_ctf3 = ones(J, 1);
bChange_ctf3 = ones(J);
dChange_ctf3 = ones(J);
kapChange_ctf3 = ones(J, J);

% Set the change in transport cost for counterfactual 3
kapChange_ctf3 = ctf3_dni ./ dni;

% Solve for counterfactual values for counterfactual 3
[ctf3_wChange, ctf3_vChange, ctf3_qChange, ctf3_piChange, ctf3_lamChange, ctf3_pChange, ctf3_rChange, ...
    ctf3_lChange, ctf3_welfChange] = counterFactsTK(...
        aChange_ctf3, bChange_ctf3, kapChange_ctf3, dChange_ctf3, w_n, v_n, uncondCom, L_n, ...
        R_n, tradesh);

%ctf3_lChange(50,1)

ctf3_percentageChange = ((ctf3_welfChange(1, 1)/fut_wChange(1,1)) - 1) * 100

fprintf('...Change in welfare in comparison to the baseline scenario in the KO scenario %.2f%%\n', ctf3_percentageChange);

Map findings
RESULT = MAPIT('shape/powiaty', log(ctf3_qChange ./ fut_qChange), 'Relative change in house price; KO Scenario', 'figs', 'MAP_COUNT3_Qchange');
RESULT = MAPIT('shape/powiaty', log(ctf3_vChange ./ fut_vChange), 'Relative change in average residential wages; KO Scenario', 'figs', 'MAP_COUNT3_Vchange'); 
RESULT = MAPIT('shape/powiaty', log(ctf3_pChange ./ fut_pChange), 'Relative change in tradable goods price; KO Scenario', 'figs', 'MAP_COUNT3_Pchange'); 
RESULT = MAPIT('shape/powiaty', log(ctf3_rChange ./ fut_rChange), 'Relative change in population; KO Scenario', 'figs', 'MAP_COUNT3_Rchange');
%


display('<<<<<<<<<<<<<<< Couterfactuals completed >>>>>>>>>>>>>>>')