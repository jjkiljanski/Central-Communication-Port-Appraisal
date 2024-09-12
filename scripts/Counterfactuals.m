% Ensure the output directory exists
outputDir = 'data/output/';
if ~exist(outputDir, 'dir')
    mkdir(outputDir);
end

% Load data
dataDistanceRailway_future = 'travel-time-matrix-future-railway.csv';
dataDistanceHighway_future = 'travel-time-matrix-future-highway.csv';

% Import distance data and compute trade costs from distances
dist_mat_rail_future = readmatrix(dataDistanceRailway_future);
dist_mat_highway_future = readmatrix(dataDistanceHighway_future);

% Ensure that both of the matrices are symmetric
dist_mat_rail_future = (dist_mat_rail_future + dist_mat_rail_future')/2;
dist_mat_highway_future = (dist_mat_highway_future + dist_mat_highway_future')/2;

% If a counterfactual travel time between 2 counties was computed as
% bigger than the future time, set the counterfactual time to the
% future time (the future connection is still available, so
% counterfactual should be at least as good as future)
dist_mat_rail_future(dist_mat_rail_future > dist_mat_rail) = dist_mat_rail(dist_mat_rail_future > dist_mat_rail);
dist_mat_highway_future(dist_mat_highway_future > dist_mat_highway) = dist_mat_highway(dist_mat_highway_future > dist_mat_highway);

% Process the future distance matrix
sortedRow = @(row) sort(row(row > 0), 'ascend');
for i = 1:size(dist_mat_rail_future, 1)
    if dist_mat_rail_future(i, i) == 0
        values = sortedRow(dist_mat_rail_future(i, :));
        dist_mat_rail_future(i, i) = mean(values(1:3));
        dist_mat_rail_future(i, i) = dist_mat_rail_future(i, i)/2;
    end
end

% Process the future distance matrix
sortedRow = @(row) sort(row(row > 0), 'ascend');
for i = 1:size(dist_mat_highway_future, 1)
    if dist_mat_highway_future(i, i) == 0
        values = sortedRow(dist_mat_highway_future(i, :));
        dist_mat_highway_future(i, i) = mean(values(1:3));
        dist_mat_highway_future(i, i) = dist_mat_highway_future(i, i)/2;
    end
end

writematrix(dist_mat_rail_future, fullfile(outputDir, 'MAP_dist_mat_rail_future.csv'));

future_dist_mat = (dist_mat_rail_future.^0.09) .* (dist_mat_highway_future.^0.91);
future_dist_mat = future_dist_mat / min(future_dist_mat(:));
future_dni = future_dist_mat.^psi;

writematrix(future_dni, fullfile(outputDir, 'MAP_fut_dni.csv'));

future_avDist = mean(future_dist_mat, 2);
avDistChange = (mean(((dist_mat_rail_future.^0.09) .* (dist_mat_highway_future.^0.91)), 2)) ./ (mean(((dist_mat_rail.^0.09) .* (dist_mat_highway.^0.91)), 2));
avDistChange_rail = mean(dist_mat_rail_future, 2) ./ mean(dist_mat_rail, 2);
avDistChange_highway = mean(dist_mat_highway_future, 2) ./ mean(dist_mat_highway, 2);

% Primitives that do not change => Changes are set to ones
aChange_future = ones(J, 1);
bChange_future = ones(J);
dChange_future = ones(J);
kapChange_future = ones(J, J);

% Set the change in commuting cost
kapChange_future = future_dni ./ dni;

% Solve for future counterfactual values
[fut_wChange, fut_vChange, fut_qChange, fut_piChange, fut_lamChange, fut_pChange, fut_rChange, ...
    fut_lChange, fut_welfChange] = counterFactsTK(...
        aChange_future, bChange_future, kapChange_future, dChange_future, w_n, v_n, uncondCom, L_n, ...
        R_n, tradesh);

% Define headers for each variable based on the description
headers_fut_wChange = {'Regional wages (future baseline) - change relative to 2021'};
headers_fut_vChange = {'Average residential wages (future baseline) - change relative to 2021'};
headers_fut_qChange = {'Regional house prices (future baseline) - change relative to 2021'};
headers_fut_pChange = {'Regional price indices (future baseline) - change relative to 2021'};
headers_fut_rChange = {'Population density (future baseline) - change relative to 2021'};
headers_fut_lChange = {'Regional employment (future baseline) - change relative to 2021'};
headers_fut_welfChange = {'Aggregate worker welfare (future baseline) - change relative to 2021'};

% Save future results
% Write as matrix with Header
writeMatrixWithHeader(fut_wChange, headers_fut_wChange, outputDir, 'fut_wChange.csv');
writeMatrixWithHeader(fut_vChange, headers_fut_vChange, outputDir, 'fut_vChange.csv');
writeMatrixWithHeader(fut_qChange, headers_fut_qChange, outputDir, 'fut_qChange.csv');
% Write as matrix
writematrix(fut_piChange, fullfile(outputDir, 'fut_piChange.csv'));
writematrix(fut_lamChange, fullfile(outputDir, 'fut_lamChange.csv'));
% Write as matrix with Header
writeMatrixWithHeader(fut_pChange, headers_fut_pChange, outputDir, 'fut_pChange.csv');
writeMatrixWithHeader(fut_rChange, headers_fut_rChange, outputDir, 'fut_rChange.csv');
writeMatrixWithHeader(fut_lChange, headers_fut_lChange, outputDir, 'fut_lChange.csv');
avdniChange_future = mean(future_dni, 2) ./ mean(dni, 2);
% Write as matrix
writematrix(fut_welfChange, fullfile(outputDir, 'fut_welfChange.csv'));

fut_percentageChange = (fut_welfChange(1,1) - 1) * 100;
fprintf('...Change in welfare in comparison to 2021 in the baseline scenario is %.2f%%\n', fut_percentageChange);

% Save changes in average future accessibility
headers_avDist = {'Average distance to other counties (future baseline) - change relative to 2021'};
headers_avDist_rail = {'Average rail distance to other counties (future baseline) - change relative to 2021'};
headers_avDist_highway = {'Average road distance to other counties (future baseline) - change relative to 2021'};
headers_avdniChange = {'Average change in commuting costs (future baseline) - change relative to 2021'};
writeMatrixWithHeader(avDistChange_rail, headers_avDist, outputDir, 'fut_AvDist.csv');
writeMatrixWithHeader(avDistChange_highway, headers_avDist, outputDir, 'fut_AvDistRail.csv');
writeMatrixWithHeader(avDistChange, headers_avDist, outputDir, 'fut_AvDistHighway.csv');
writeMatrixWithHeader(avdniChange_future, headers_avdniChange, outputDir, 'fut_avdniChange.csv');

%%%%%%%%%%%%%%%%%%%%%%%% COUNTERFACTUAL SCENARIOS %%%%%%%%%%%%%%%%%%%%%%%%%

% Define the counterfactual scenarios
ctfFiles = {
    'travel-time-matrix-future-railway-counterfactual.csv',
    'travel-time-matrix-future-railway-counterfactual2.csv',
    'travel-time-matrix-future-railway-counterfactual3.csv'
};

% Process each counterfactual scenario
for i = 1:3
    dist_mat_rail_ctf = readmatrix(ctfFiles{i});
    % Assuming the same highway matrix for all scenarios

    % Read in the counterfactual railway matrix
    dist_mat_rail_ctf = (dist_mat_rail_ctf + dist_mat_rail_ctf')/2;

    % If a counterfactual travel time between 2 counties was computed as
    % bigger than the future time, set the counterfactual time to the
    % future time (the future connection is still available, so
    % counterfactual should be at least as good as future)
    dist_mat_rail_ctf(dist_mat_rail_ctf > dist_mat_rail_future) = dist_mat_rail_future(dist_mat_rail_ctf > dist_mat_rail_future);
    
    [wChange, vChange, qChange, piChange, lamChange, pChange, rChange, lChange, welfChange] = processCounterfactual(...
        dist_mat_rail_ctf, dist_mat_highway_future, dni, psi, J, w_n, v_n, uncondCom, L_n, ...
        R_n, tradesh, outputDir, i);

    result = dist_mat_rail_ctf > dist_mat_rail_future;
    sum(result(:))
    
    % Calculate percentage change for each counterfactual scenario
    percentageChange = ((welfChange(1,1)/fut_wChange(1,1)) - 1) * 100;
    fprintf('...Change in welfare in comparison to the baseline scenario in counterfactual %d is %.2f%%\n', i, percentageChange);
end

% Additional mapping code if necessary
% ...

display('<<<<<<<<<<<<<<< Counterfactuals completed >>>>>>>>>>>>>>>')
