% This script will fit the Paci model to experimental data in two stages:
%
%   Stage 1: Fit iKs and iKr currents to current density data
%   Stage 2: Fit the maximal conductances of remainin transmembrane
%            currents to match certain averaged characteristics of the
%            action potential data
%
% For both stages, a particle swarm algorithm will be used to optimise for
% a solution vector corresponding to transmemrane current parameters in the 
% model.
%
% Parameters that have to be set:
%
% Parameter                   Description                  Location in code
% ------------------------------------------------------------------------
% data_iKs                    iKs voltage clamp data       Line 60
% iKs_LB                      iKs lower bounds             Line 90
% iKs_UB                      iKs upper bounds             Line 91
% data_iKr                    iKr voltage clamp data       Line 109
% iKr_LB                      iKr lower bounds             Line 140
% iKr_UB                      iKr upper bounds             Line 141
% experimental_parameters     AP parameters to fit to      Line 162
% current_LB                  current lower bounds         Line 174
% current_UB                  current upper bounds         Line 175
%
% Author: Eric Liu

%% Setting up
close all
clear

warning('off','all')
warning

% Reset output text file
fileid = fopen('fitness.txt','w');

fprintf(fileid, 'Fitting results for optimising Paci model \n');
fprintf(fileid, '========================================= \n \n');
fclose(fileid);

% Preset iKs and iKr parameters if stage 1 has already been run (skip the
% fitting process for stage 1)

user = input('Have iKs and iKr been fitted already (Y/N)?','s');

if user == 'Y' || 'y'
    iKs_solution = [53.9505, 3.103];
    iKr_solution = [27.2299, 4.0188, 9.2981];
    
    iKs_feval = 3.0289;
    iKr_feval = 7.9155;

elseif user == 'N' || 'n'     
%% Stage 1: Fit to current density data

% Step 1: Find optimal scaling factors for iKs maximal conductance and time
%         constant.

fileid = fopen('fitness.txt','a');
fprintf(fileid, 'Optimisation results for fitting iKs \n');
fprintf(fileid, '------------------------------------ \n');
fclose(fileid);

% Set up the experimental data from the voltage clamp experiments. If
% different voltage clamps are used, then you'll have to tweak iKs_setup.m
% to match your data.

iKs_data =[ 0.7749, ...     % -50mV
            1.0038, ...     % -40mV
            1.6244, ...     % -30mV
            2.8005, ...     % -20mV
            4.3462, ...     % -10mV
            5.1302, ...     %   0mV
            5.8443, ...     % +10mV
            6.0113, ...     % +20mV
            6.8195, ...     % +30mV 
            7.6049]; ...    % +40mV

iKs_fitness = @(iKs_scaling_factors) iKs_setup(iKs_scaling_factors,iKs_data);
        
% Set up an initial swarm to speed up the particle swarm. Otherwise,
% comment out this section if you want to start anew and uncomment the
% following line of code:

% options = optimoptions('particleswarm','PlotFcns',@pswplotbestf);

initial_iKs_swarm = zeros(20,2);
initial_iKs_swarm(:,1) = 53.9505;
initial_iKs_swarm(:,2) = 3.103;
options = optimoptions('particleswarm','InitialSwarmMatrix',initial_iKs_swarm,'PlotFcns',@pswplotbestf);

% Set lower and upper bounds for the particle swarm. You can choose these,
% though the lower bound should always be positive.
iKs_LB = [0 0];
iKs_UB = [100 100];

% Run the particle swarm. Each iteration of the particle swarm will be
% noted down in fitness.txt
fprintf('Optimising for iKs model parameters...');
[iKs_solution,iKs_feval] = particleswarm(iKs_fitness,2,iKs_LB,iKs_UB,options);

% -------------------------------------------------------------------------

% Step 2: Find optimal scaling factors for iKr maximal conductance and time
%         constants.

fileid = fopen('fitness.txt','a');
fprintf(fileid, '\nOptimisation results for fitting iKs \n');
fprintf(fileid, '------------------------------------ \n');
fclose(fileid);


% Set up the experimental data from the voltage clamp experiments. If
% different voltage clamps are used, then you'll have to tweak iKr_setup.m
% to match your data.

iKr_data =[ -0.4913,  ...    % -70mV
            -0.0112,  ...    % -60mV
             0.3762,  ...    % -50mV
             0.7226,  ...    % -40mV
             1.0652   ...    % -30mV             
             1.8283,  ...    % -20mV
             2.8620,  ...    % -10mV
             3.4178,  ...    %   0mV
             3.8957,  ...    % +10mV
             4.2523,  ...    % +20mV
             4.7768,  ...    % +30mV
             5.4879];  ...   % +40mV 

% Set up an initial swarm to speed up the particle swarm. Otherwise,
% comment out this section if you want to start anew and uncomment the
% following line of code:

% options = optimoptions('particleswarm','PlotFcns',@pswplotbestf);

initial_iKr_swarm = zeros(100,2);
initial_iKr_swarm(:,1) = 27.2299;
initial_iKr_swarm(:,2) = 4.0188;
initial_iKr_swarm(:,3) = 9.2981;
options = optimoptions('particleswarm','InitialSwarmMatrix',initial_iKr_swarm,'PlotFcns',@pswplotbestf);

% Set lower and upper bounds for the particle swarm. You can choose these,
% though the lower bound should always be positive.
iKr_LB = [0,0,0];
iKr_UB = [100 100 100];

% Run the particle swarm. Each iteration of the particle swarm will be
% noted down in fitness.txt
fprintf('Optimising for iKs model parameters... \n');
iKs_fitness = @(iKr_scaling_factors) iKr_setup(iKr_scaling_factors,iKr_data);
[iKr_solution,iKr_feval] = particleswarm(@iKr_fitness,3,iKr_LB,iKr_UB,options);
end

fprintf('\n iKs and iKr model parameters have been scaled: \n');
fprintf('\t gKs \t\t tauKs \t\t gKr \t\t tauXr1 \t tauXr2   \n');
fprintf('\t %f \t %f \t %f \t %f \t %f \n\n', iKs_solution(1), iKs_solution(2), iKr_solution(1), iKr_solution(2), iKr_solution(3));
newline;
fprintf('\t iKs fitness = %f \n', iKs_feval);
fprintf('\t iKr fitness = %f \n \n', iKr_feval);

%% Stage 2: Fit to action potential

% Set up the averaged action potential characteristics to be compared
% against in the fitness evaluation.
                                           
experimental_parameters = [-65.0    ... % Baseline voltage
                            29.5    ... % Peak voltage
                           0.2327    ... % APD50
                            0.0259    ... % Rise time
                            1.059];      % RR interval

AP_fitness = @(current_scaling_factors) AP_setup(current_scaling_factors,experimental_parameters, iKr_solution, iKs_solution);


% Set lower and upper bounds for the particle swarm. You can choose these,
% though the lower bound should always be positive.

%             Na   CaL  K1   f    NaK  NaCa to   PCa  bNa  bCa
current_LB = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0];     
current_UB = [5.0, 5.0, 5.0, 5.0, 5.0, 5.0, 5.0, 5.0, 5.0, 5.0];

% Set up an initial swarm to speed up the particle swarm. Otherwise,
% comment out this section if you want to start anew and uncomment the
% following line of code:

options = optimoptions('particleswarm','PlotFcns',@pswplotbestf);

% initial_swarm = zeros(20,10);
% initial_swarm(:,1)  = 0.9389;   % Na
% initial_swarm(:,2)  = 2.4000;   % CaL
% initial_swarm(:,3)  = 1.5779;   % K1
% initial_swarm(:,4)  = 1.0000;   % f
% initial_swarm(:,5)  = 0.2036;   % NaK
% initial_swarm(:,6)  = 1.4999;   % NaCa
% initial_swarm(:,7)  = 0.9771;   % to
% initial_swarm(:,8)  = 0.5991;   % PCa
% initial_swarm(:,9)  = 1.3415;   % bNa
% initial_swarm(:,10) = 1.4990;   % bCa
% options = optimoptions(@particleswarm,'InitialSwarmMatrix',initial_swarm,'PlotFcns',@pswplotbestf);

% Run the particle swarm. Each iteration of the particle swarm will be
% noted down in fitness.txt
fprintf('Optimising for remaining current model parameters...');

fileid = fopen('fitness.txt','a');
fprintf(fileid, '==========================================================================');
fprintf(fileid, '\n \n');
fprintf(fileid, 'Optimisation results for fitting Paci model to action potential parameters \n');
fprintf(fileid, '-------------------------------------------------------------------------- \n');
fclose(fileid);

[currents_solution,currents_feval] = particleswarm(AP_fitness,10,current_LB,current_UB,options);

fprintf('\n Remaining current model parameters have been scaled: \n');
fprintf('\t Na \t\t CaL \t\t K1 \t\t f \t\t NaK \t\t NaCa \t\t to \t\t PCa \t\t bNa \t\t bCa     \n')
fprintf('\t %f \t %f \t %f \t %f \t %f \t %f \t %f \t %f \t %f \t %f      \n \n', ...
    currents_solution(1), currents_solution(2), currents_solution(3), currents_solution(4), ...
    currents_solution(5), currents_solution(6), currents_solution(7), currents_solution(8), ...
    currents_solution(9), currents_solution(10))
fprintf('Currents fitness = %f \n', currents_feval);
fprintf('================ \n');
fprintf('Fitting complete \n');
fprintf('================');

