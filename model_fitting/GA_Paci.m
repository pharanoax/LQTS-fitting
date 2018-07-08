% This program will run a genetic algorithm on the Paci model to match
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
[iPSC_baseline,iPSC_peak,iPSC_APD,iPSC_max_upstroke,~,~,iPSC_upstroke_i,iPSC_V90_t] = initialise(iPSC_AP,iPSC_t);
iPSC_upstroke_t = iPSC_upstroke_i*si*10^(-3);

experiment_parameters = [iPSC_baseline,iPSC_peak,iPSC_APD,iPSC_max_upstroke,iPSC_V90_t];

%% Assessing fitness

%     Na  CaL Kr  Ks  K1  f   NaK NaCa
LB = [0.8,0.5,0.5,0.5,0.5,1.0,0.5,0.5];
UB = [1.2,1.5,1.5,1.5,1.5,2.0,1.5,1.5];

options = optimoptions('patternsearch','Display','iter','PlotFcn',@psplotbestf);
[x,feval] = patternsearch(@Fitness_Paci,[1,1,1,1,1,1,1,1],[],[],[],[],LB,UB,[],options);

% options = optimoptions(@ga,'MutationFcn',@mutationadaptfeasible,'PlotFcn',{@gaplotbestf,@gaplotmaxconstr}, ...
%     'Display','iter');
% [x,feval] = ga(@Fitness_Paci,8,[],[],[],[],LB,UB,[],options);
