%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Master MATLAB programme file for the MRRH2018 tolkit by             %%%
%%% Gabriel Ahlfeldt M. Ahlfeldt and Tobias Seidel                      %%%
%%% Adjusted to Polish data for the estimation of the impact of three   %%%
%%% development scenarios of the Polish railway network by              %%%
%%% Jan Kiljański.                                                      %%%
%%% The toolkit covers a class of quantitative spatial models           %%%
%%% introduced in Monte, Redding, Rossi-Hansberg (2018): Commuting,     %%%
%%% Migration, and Local Employment Elasticities.                       %%%
%%% The original toolkit uses data and code compiled for                %%%
%%% Seidel and Wckerath (2020): Rush hours and urbanization             %%%
%%% Codes and data have been re-organized to make the toolkit more      %%%
%%% accessible. Seval programmes have been added to allow for more      %%%
%%% general applications. Discriptive analyses and counterfactuals      %%%
%%% serve didactic purposes and are unrelated to both research papers   %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% First version of original toolkit: Gabriel M Ahlfeldt, 05/2024        %%%
% Based on original code provided by Tobias Seidel                      %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Forked by Jan Kiljański and adjusted to the custom analysis:          %%%
% Jan Kiljański, 08/2024                                                %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% This is the master script that calls other scripts
%%% Please the following toolboxes
%%%% Global optimization
%%%% Statistics and Machine learning 
%%%% Mapping
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Root folder of working directory %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cd 'E:/Studia/Studia magisterskie/Wirtschaftwissenschaft/Quantitative Spatial Economics/Central-Communication-Port-Appraisal';             
addpath('data/input')                                                       % Adding path to data
addpath('progs')                                                            % Adding path to programmes
addpath('scripts')                                                          % Adding path to scripts that execture various steps of the analysis
clear;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Parameters
global epsi mu alp delta sigg fixC nu J psi;                             % Define all parameters as globals so that they can be found by programmes
alp = 0.7;
epsi = 4.6;
mu = 0.47;
delta = 0.38;
sigg = 4;
fixC = 1;
nu = 0.05;
psi = 0.42;
J = 380;
save('data/output/parameters')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ReadPolandData                                                                   
% Executes script that reads in data for 2021 Poland. This data set
% contains bilateral commuting flows similar to the data used by MMRH2017.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Descriptives
% Executres script that generates mapa written to csv files and scatter
% plots illustrating the data and some variables solved within the model

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Counterfactuals
% Estimates the equilibrium in case of the future baseline development
% scenario, and three counterfactuals corresponding to three development
% scenarios of the Polish railway network.