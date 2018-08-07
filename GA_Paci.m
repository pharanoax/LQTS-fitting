% This program will run an optimisation algorithm on the Paci model to match
% characteristics of experimental data collected on action potentials.
%
% Author: Eric Liu
% Date: 25/06/18

clear;
clc;
close all;

%% Setting up iPSC-CM data
% Load in experimental data (You can change the filename here)
[V_iPSC,si] = abfload('C_0005.abf');
V_iPSC = V_iPSC(1:48:end);
si = si*48;
iPSC_t = (0:si*10^(-3):(length(V_iPSC)-1)*si*10^(-3));

% Select one action potential
[iPSC_start, iPSC_end] = single_AP(V_iPSC,0.8);
iPSC_AP = V_iPSC(iPSC_start:iPSC_end);
iPSC_t = iPSC_t(iPSC_start:iPSC_end)-iPSC_t(iPSC_start);

% Initialise parameters for iPSC-CM
[iPSC_baseline,iPSC_peak,iPSC_APD,iPSC_max_upstroke,iPSC_upstroke_V,iPSC_upstroke_i,iPSC_V90,iPSC_V90_t] = initialise(iPSC_AP,iPSC_t);
iPSC_upstroke_t = iPSC_upstroke_i*si*10^(-3);

experiment_parameters = [iPSC_baseline,iPSC_peak,iPSC_APD,iPSC_max_upstroke,iPSC_V90_t];

%% Assessing fitness

% Resetting output text file
fileid = fopen('fitness.txt','w');

fprintf(fileid, '');
fclose(fileid);

%     Na   CaL  K1   f    NaK  NaCa to   PCa  bNa  bCa
LB = [0.8, 0.5, 0.2, 0.5, 0.1, 0.1, 0.5, 0.5, 0.5, 0.5];     % Tweak these as deemed necessary
UB = [1.3, 3.0, 2.1, 3.0, 1.8, 2.0, 1.5, 1.5, 1.5, 2.0];

%     Na   CaL  K1   f    NaK  NaCa to   PCa  bNa  bCa
LB = [0 0 0 0 0 0 0 0 0 0];     % Tweak these as deemed necessary
UB = [5 5 5 5 5 5 5 5 5 5];

% Set up initial swarm based off previous optimisation results
initial_swarm = zeros(20,10);
initial_swarm(:,1)  = 0.9389;   % Na
initial_swarm(:,2)  = 2.4000;   % CaL
initial_swarm(:,3)  = 1.5779;   % K1
initial_swarm(:,4)  = 1.0000;   % f
initial_swarm(:,5)  = 0.2036;   % NaK
initial_swarm(:,6)  = 1.4999;   % NaCa
initial_swarm(:,7)  = 0.9771;   % to
initial_swarm(:,8)  = 0.5991;   % PCa
initial_swarm(:,9)  = 1.3415;   % bNa
initial_swarm(:,10) = 1.4990;   % bCa

options = optimoptions(@particleswarm,'InitialSwarmMatrix',initial_swarm,'PlotFcns',@pswplotbestf);
[x,feval] = particleswarm(@Fitness_Paci,10,LB,UB,options);

fileid = fopen('fitness.txt','a');
fprintf(fileid, '\n Fitness = %f \t scaling factors = %f %f %f %f %f %f %f %f %f %f', feval, x);
fclose(fileid);


%% Making comparisons
[VOI, STATES, ~, ~] = Paci_mod(x);
Paci_V = STATES(:,1)*1000;  % Scale from V to mV
Paci_t = VOI;

% Load up the Paci model
% Select one action potential
[Paci_start, Paci_end] = single_AP(Paci_V,0);
Paci_AP = Paci_V(Paci_start:Paci_end);
Paci_t = (Paci_t(Paci_start:Paci_end)-Paci_t(Paci_start))*1000;  % Scale from s to ms and recalibrate back to Paci_t(0)=0

% Initialise parameters for Paci model
[Paci_baseline, Paci_peak, Paci_APD, Paci_max_upstroke, Paci_upstroke_V, Paci_upstroke_i,Paci_V90,Paci_V90_t] = initialise(Paci_AP,Paci_t);
Paci_upstroke_t = Paci_t(Paci_upstroke_i);

%% Plot the intial action potentials
figure

% Plot iPSC action potential
subplot(2,1,1)
plot(((0:length(iPSC_AP)-1)*si*10^(-3)),iPSC_AP);
title('Single iPSC-CM action potential')
axis([0 2000 -100 50]);
xlabel('Time (ms)');
ylabel('Membrane Potential (mV)')
    
% Plot Paci action potential
subplot(2,1,2)
plot(Paci_t,Paci_AP);
title('Single Paci action potential')
axis([0 2000 -100 50]);
xlabel('Time (ms)');
ylabel('Membrane Potential (mV)')

